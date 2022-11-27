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
	chargedPowerPointIndexes = nil,
	-- index of highest charged combo-point, required for GUI
	chargedPowerPointMaxIndex = 0,
})

--- Create new health points tracker, unitId should be specified after constructor
function DHUDComboPointTracker:new()
	local o = self:defconstructor();
	o:constructor();
	return o;
end

--- Constructor of cooldowns tracker
function DHUDComboPointTracker:constructor()
	-- init tables
	self.chargedPowerPointIndexes = { };
	-- call super constructor
	DHUDSpecificPowerTracker.constructor(self);
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
	-- check if changed
	local numNew = chargedPowerPoints and #chargedPowerPoints or 0;
	local numCurrent = #self.chargedPowerPointIndexes;
	local changed = numCurrent ~= numNew;
	if (not changed) then
		for i = 1, numNew, 1 do
			if (self.chargedPowerPointIndexes[i] ~= chargedPowerPoints[i]) then
				changed = true;
				break;
			end
		end
		if (not changed) then
			return;
		end
	end
	-- copy data
	self.chargedPowerPointMaxIndex = 0;
	for i = numCurrent, 1, -1 do
		table.remove(self.chargedPowerPointIndexes, i);
	end
	for i = 1, numNew, 1 do
		local index = chargedPowerPoints[i];
		table.insert(self.chargedPowerPointIndexes, index);
		if (index > self.chargedPowerPointMaxIndex) then
			self.chargedPowerPointMaxIndex = index;
		end
	end
	-- dispatch event
	self:processDataChanged();
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

