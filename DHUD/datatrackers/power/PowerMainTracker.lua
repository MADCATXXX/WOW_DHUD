--[[-----------------------------------------------------------------------------------
 Original Drathals HUD (c) 2006 by Markus Inger / Drathal / Silberklinge / Silbersegen
 DHUD for WotLK and later expansions (c) 2013 by MADCAT (EU-Гордунни, Мадкат)
 (http://eu.battle.net/wow/en/character/Гордунни/Мадкат/advanced)
---------------------------------------------------------------------------------------
 This file contains functions and classes to track data about unit resources, health,
 buffs and other information
 @author: MADCAT
-----------------------------------------------------------------------------------]]--

-- antitaint local "_" var
local _;
-- tracker helper
local trackingHelper = DHUDDataTrackingHelper;

----------------------------------------
-- Unit main power tracker base class --
----------------------------------------

--- Base class to track unit main resource, e.g. mana (actually it's subclasses will only set unitId to track and resource type)
DHUDMainPowerTracker = MCCreateSubClass(DHUDSpecificPowerTracker, {
	
})

--- Create new health points tracker, unitId should be specified after constructor
function DHUDMainPowerTracker:new()
	local o = self:defconstructor();
	o:constructor();
	return o;
end

--- Initialize main power-points tracking
function DHUDMainPowerTracker:init()
	local tracker = self;
	-- process units power points type change event
	function self.eventsFrame:UNIT_DISPLAYPOWER(unitId)
		if (tracker.unitId ~= unitId) then
			return;
		end
		--[[if (unitId == "vehicle") then
			print("UNIT_DISPLAYPOWER " .. MCTableToString(unitId) .. ", "  .. MCTableToString(resourceTypeString) .. ", current " .. tracker.unitId);
		end]]--
		tracker:updatePowerType();
		--print("update display power to " .. MCTableToString(tracker.resourceType) .. ", " .. MCTableToString(tracker.resourceTypeString));
	end
	-- call super
	DHUDSpecificPowerTracker.init(self);
end

--- Update unit power type
function DHUDMainPowerTracker:updatePowerType()
	local powerType, powerTypeString = UnitPowerType(self.unitId);
	--print("powerType " .. MCTableToString(powerType) .. ", powerTypeString " .. MCTableToString(powerTypeString));
	-- update resource
	self:setResourceType(powerType, powerTypeString);
end

--- Start tracking amountMax data
function DHUDMainPowerTracker:startTrackingAmountMax()
	self.eventsFrame:RegisterEvent("UNIT_DISPLAYPOWER");
	DHUDSpecificPowerTracker.startTrackingAmountMax(self); -- call super
end

--- Update maximum amount or resource
function DHUDMainPowerTracker:updateAmountMax()
	self.eventsFrame:UNIT_DISPLAYPOWER(self.unitId);
	DHUDSpecificPowerTracker.updateAmountMax(self); -- call super
end

--- Stop tracking amountMax data
function DHUDMainPowerTracker:stopTrackingAmountMax()
	self.eventsFrame:UnregisterEvent("UNIT_DISPLAYPOWER");
	DHUDSpecificPowerTracker.stopTrackingAmountMax(self); -- call super
end

--- Update all data for current unitId
function DHUDMainPowerTracker:updateData()
	self:updatePowerType();
	-- call super
	DHUDSpecificPowerTracker.updateData(self);
end
