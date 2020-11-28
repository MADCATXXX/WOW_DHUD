--[[-----------------------------------------------------------------------------------
 Original Drathals HUD (c) 2006 by Markus Inger / Drathal / Silberklinge / Silbersegen
 DHUD for WotLK and later expansions (c) 2013 by MADCAT (EU-Гордунни, Мадкат)
 (http://eu.battle.net/wow/en/character/Гордунни/Мадкат/advanced)
---------------------------------------------------------------------------------------
 This file contains functions and classes to point combo points (to support charged
 combo points that were introduced in ShadowLands)
 @author: MADCAT
-----------------------------------------------------------------------------------]]--

-- antitaint local "_" var
local _;
-- tracker helper
local trackingHelper = DHUDDataTrackingHelper;

----------------------------------------
-- Unit main power tracker base class --
----------------------------------------

--- Base class to track combo-points, including charged combo points
DHUDComboPointTracker = MCCreateSubClass(DHUDSpecificPowerTracker, {
	-- index of charged combo-point if any
	chargedPowerPointIndex = 0,
})

--- Create new health points tracker, unitId should be specified after constructor
function DHUDComboPointTracker:new()
	local o = self:defconstructor();
	o:constructor();
	return o;
end

--- Initialize main power-points tracking
function DHUDComboPointTracker:init()
	local tracker = self;
	-- process units power points type change event
	function self.eventsFrame:UNIT_POWER_POINT_CHARGE(unitId)
		if (tracker.unitId ~= unitId) then
			return;
		end
		tracker:updateChargedComboPoints();
		--print("update charged combo-points to " .. MCTableToString(tracker.chargedPowerPointIndex));
	end
	-- set resource type
	self:setResourceType(Enum.PowerType.ComboPoints, "COMBO_POINTS");
	-- call super
	DHUDSpecificPowerTracker.init(self);
end

--- Update charged combo points
function DHUDComboPointTracker:updateChargedComboPoints()
	local chargedPowerPoints = GetUnitChargedPowerPoints(self.unitId);
	-- there's only going to be 1 max
	local chargedPowerPointIndex = chargedPowerPoints and chargedPowerPoints[1];
	-- check if changed
	if (self.chargedPowerPointIndex ~= chargedPowerPointIndex) then
		self.chargedPowerPointIndex = chargedPowerPointIndex;
		-- dispatch event
		self:processDataChanged();
	end
end

--- Start tracking data
function DHUDComboPointTracker:startTracking()
	-- listen to game events
	self.eventsFrame:RegisterEvent("UNIT_POWER_POINT_CHARGE");
	-- call super
	DHUDSpecificPowerTracker.startTracking(self);
end

--- Stop tracking data
function DHUDComboPointTracker:stopTracking()
	-- stop listening to game events
	self.eventsFrame:UnregisterEvent("UNIT_POWER_POINT_CHARGE");
	-- call super
	DHUDSpecificPowerTracker.stopTracking(self);
end

--- Update all data for current unitId
function DHUDComboPointTracker:updateData()
	self:updateChargedComboPoints();
	-- call super
	DHUDSpecificPowerTracker.updateData(self);
end

