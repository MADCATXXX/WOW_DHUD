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

--------------------------------------------
-- Unit specific power tracker base class --
--------------------------------------------

--- Base class to track unit specific resource, e.g. mana (actually it's subclasses will only set unitId to track and resource type)
DHUDSpecificPowerTracker = MCCreateSubClass(DHUDPowerTracker, {
	-- precision at which resource is tracked (can be used for soul shards, and embers), number of digits after comma
	precision			= 0,
	-- if true than this resource will also be updated by onUpdate event when in regeneration state, this variable should not be changed during runtime!
	updateFrequently	= true,
})

--- Create new specific power points tracker, unitId and resourceType should be specified after constructor
function DHUDSpecificPowerTracker:new()
	local o = self:defconstructor();
	o:constructor();
	return o;
end

--- Initialize specific power-points tracking
function DHUDSpecificPowerTracker:init()
	local tracker = self;
	-- process units power points change event
	function self.eventsFrame:UNIT_POWER_UPDATE(unitId, resourceTypeString)
		if (tracker.unitId ~= unitId) then
			return;
		end
		--[[if (unitId == "vehicle") then
			print("UNIT_POWER " .. MCTableToString(unitId) .. ", "  .. MCTableToString(resourceTypeString));
			print("tracker.resourceTypeString " .. tracker.resourceTypeString .. ", resourceTypeString " .. resourceTypeString);
		end]]--
		if (tracker.resourceTypeString ~= "" and tracker.resourceTypeString ~= resourceTypeString) then
			return;
		end
		tracker:updatePower();
	end
	-- process units max power points change event
	function self.eventsFrame:UNIT_MAXPOWER(unitId, resourceTypeString)
		if (tracker.unitId ~= unitId) then
			return;
		end
		--[[if (unitId == "vehicle") then
			print("UNIT_MAXPOWER " .. MCTableToString(unitId) .. ", "  .. MCTableToString(resourceTypeString) .. ", current " .. tracker.unitId);
		end]]--
		tracker:updateMaxPower();
		--[[if (unitId == "vehicle") then
			print("update max power to " .. MCTableToString(tracker.amountMax));
		end]]--
	end
	-- track maximum amount event if data tracker is not activated
	self.trackAmountMax = true;
end

--- Game time updated, update unit power
function DHUDSpecificPowerTracker:onUpdateTime()
	if (self.isRegenerating == true) then
		self:updatePower();
	end
end

--- Start tracking data
function DHUDSpecificPowerTracker:startTracking()
	-- listen to game events
	self.eventsFrame:RegisterEvent("UNIT_POWER_UPDATE");
	--print("self " .. self.trackUnitId .. " start amount data");
	if (self.updateFrequently) then
		trackingHelper:addEventListener(DHUDDataTrackerHelperEvent.EVENT_UPDATE, self, self.onUpdateTime);
	end
end

--- Stop tracking data
function DHUDSpecificPowerTracker:stopTracking()
	-- stop listening to game events
	self.eventsFrame:UnregisterEvent("UNIT_POWER_UPDATE");
	--print("self " .. self.trackUnitId .. " stop amount data");
	if (self.updateFrequently) then
		trackingHelper:removeEventListener(DHUDDataTrackerHelperEvent.EVENT_UPDATE, self, self.onUpdateTime);
	end
end

--- Start tracking amountMax data
function DHUDSpecificPowerTracker:startTrackingAmountMax()
	self.eventsFrame:RegisterEvent("UNIT_MAXPOWER");
	--print("self " .. self.trackUnitId .. " start amount max");
end

--- Update maximum amount or resource
function DHUDSpecificPowerTracker:updateAmountMax()
	self.eventsFrame:UNIT_MAXPOWER(self.unitId);
	--print("self " .. self.trackUnitId .. " update amount max");
end

--- Stop tracking amountMax data
function DHUDSpecificPowerTracker:stopTrackingAmountMax()
	self.eventsFrame:UnregisterEvent("UNIT_MAXPOWER");
	--print("self " .. self.trackUnitId .. " stop amount max");
end

--- Update power for unit
function DHUDSpecificPowerTracker:updatePower()
	local power;
	if (self.precision ~= 0) then
		power = UnitPower(self.unitId, self.resourceType, true);
		--print("powerWithPrecision " .. power);
		--print("powerWithoutPrecision " .. UnitPower(self.unitId, self.resourceType));
		power = power / (10 ^ self.precision);
	else
		power = UnitPower(self.unitId, self.resourceType);
	end
	--print("power is " .. power);
	self:setAmount(power);
end

--- Update maximum power for unit
function DHUDSpecificPowerTracker:updateMaxPower()
	local powerMax;
	if (self.precision ~= 0) then
		powerMax = UnitPowerMax(self.unitId, self.resourceType, true);
		powerMax = powerMax / (10 ^ self.precision);
	else
		powerMax = UnitPowerMax(self.unitId, self.resourceType);
	end
	self:setAmountMax(powerMax);
end

--- Update all data for current unitId
function DHUDSpecificPowerTracker:updateData()
	self:updateMaxPower();
	self:updatePower();
end

--- set tracking to be tracked only if resource is not main, should not be called if subclassed (this will override UNIT_DISPLAYPOWER event handling)
function DHUDSpecificPowerTracker:initTrackIfNotMain()
	local tracker = self;
	function self.eventsFrame:UNIT_DISPLAYPOWER(unitId)
		if (tracker.unitId ~= unitId) then
			return;
		end
		tracker:setIsExists(tracker:checkIsExists());
		--print("not main display power changed, exists: " .. MCTableToString(tracker.isExists));
	end
	-- update check is exists function to also check unit power
	function self:checkIsExists()
		if (not DHUDSpecificPowerTracker.checkIsExists(self)) then -- call super
			return false;
		end
		local powerType = UnitPowerType(self.unitId);
		--print("not main checkIsExists, main powerType " .. MCTableToString(powerType) .. ", tracked " .. MCTableToString(self.resourceType));
		return (powerType ~= self.resourceType);
	end
	-- register to display power event
	self.eventsFrame:RegisterEvent("UNIT_DISPLAYPOWER");
	self.eventsFrame:UNIT_DISPLAYPOWER(self.unitId);
end
