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

-----------------------------------
-- Unit power tracker base class --
-----------------------------------

--- Base class for trackers of base resources like mana or health
DHUDPowerTracker = MCCreateSubClass(DHUDDataTracker, {
	-- resource power type if provided by game
	resourceType		= -1,
	-- resource power type string if provided by game
	resourceTypeString	= "",
	-- defines if resource power type is custom
	resourceTypeIsCustom = false,
	-- maximum amount of tracked resource
	amountMax			= 0,
	-- maximum amount of tracked resource without talants, glyphs, etc.., e.g. 5 combo-points, 4 chi. This value should not be changed during run-time
	amountMaxDefault	= 0,
	-- minumum amount of tracked resource, usually 0, currently in use only for Moonkin Eclipse power
	amountMin			= 0,
	-- percent of maximum to set minimum amount of tracked resource, usually 0, currently in use only for Moonkin Eclipse power
	amountMinPercent	= 0,
	-- extra amount of resource, can be set event if amount is not at max (e.g. Power word shield for health, or extra combo-points for anticipation talent)
	amountExtra			= 0,
	-- maximum extra amount of resource while it's in use (e.g. maximum amount of all shield on target until shield fades, needed for GUI), calculated when changing amountExtra
	amountExtraMax		= 0,
	-- base amount of resource at which regenerating stops, in percents
	amountBasePercent	= 0,
	-- set to track amount max events when unit become existant, data tracker should override startTrackingAmountMax and stopTrackingAmountMax
	trackAmountMax		= false,
	-- defines if maximum amount being tracked?
	isTrackingAmountMax = false,
	-- table with power type names, used to convert power id to power name
	POWER_TYPES = {
		[0]		= "MANA",
		[1]		= "RAGE",
		[2]		= "FOCUS",
		[3]		= "ENERGY",
		[4]		= "COMBO_POINTS",
		[5]		= "RUNES",
		[6]		= "RUNIC_POWER",
		[7]		= "SOUL_SHARDS",
		[8]		= "LUNAR_POWER",
		[9]		= "HOLY_POWER",
		[10]	= "ALTERNATE_POWER",
		[11]	= "MAELSTROM",
		[12]	= "CHI",
		[13]	= "INSANITY",
		[14]	= "OBSOLETE", -- was Burning Embers
		[15]	= "OBSOLETE2", -- was Demonic Fury
		[16]	= "ARCANE_CHARGES",
		[17]	= "FURY",
		[18]	= "PAIN",
		[19]	= "ESSENCE",
	},
	-- table with base percents for resource types, all unset resource types will be treated as 0
	BASE_PERCENT_FOR_RESOURCE_TYPE = {
		["MANA"]			= 1,
		["ENERGY"]			= 1,
		["FOCUS"]			= 1,
		["SOUL_SHARDS"]		= 0.2,
	},
	-- table with min percents for resource types, all unset resource types will be treated as 0
	MIN_PERCENT_FOR_RESOURCE_TYPE = {
		--["LUNAR_POWER"]			= -1,
	},
})

--- Constructor of power tracker
function DHUDPowerTracker:constructor()
	-- custom events
	self.eventResourceTypeChanged = DHUDDataTrackerEvent:new(DHUDDataTrackerEvent.EVENT_RESOURCE_TYPE_CHANGED, self);
	-- call super constructor
	DHUDDataTracker.constructor(self);
end

--- set amountMax variable
function DHUDPowerTracker:setAmountMax(amountMax)
	if (self.amountMax == amountMax) then
		return;
	end
	self.amountMax = amountMax;
	self:setAmountBase(self.amountBasePercent * self.amountMax);
	self:setAmountMin(self.amountMinPercent * self.amountMax);
	self:processDataChanged();
	self:setIsExists(self:checkIsExists());
end

--- Check if this tracker data is exists
function DHUDPowerTracker:checkIsExists()
	if (not DHUDDataTracker.checkIsExists(self)) then -- call super
		--print("checkIsExists base false " .. self.amountMax);
		if (self.trackAmountMax) then
			self:changeAmountMaxTrackingState(false);
		end
		return false;
	end
	-- amount max tracking activated?
	if (self.trackAmountMax) then
		self:changeAmountMaxTrackingState(true);
		--print("checkIsExists " .. self.amountMax);
		return (self.amountMax ~= 0); -- power maximum should not be equal to zero
	end
	return true;
end

--- Start tracking amountMax data, should be invoked only from changeTrackingState function!
function DHUDPowerTracker:startTrackingAmountMax()
	-- to be overriden by subclasses
end

--- Update maximum amount or resource, should be invoked only from changeTrackingState function!
function DHUDPowerTracker:updateAmountMax()

end

--- Stop tracking amountMax data, should be invoked only from changeTrackingState function!
function DHUDPowerTracker:stopTrackingAmountMax()
	-- to be overriden by subclasses
end

--- character is entering world, update maximum amount, tracking might become available
function DHUDDataTracker:onEnteringWorldToCheckMax(e)
	-- recheck if data tracker exists, some events are not fired when player enters world (e.g. shapeshift form when teleporting from instance)
	self:updateAmountMax();
	self:setIsExists(self:checkIsExists());
end

--- Enable or disable tracking of maximum amount for this data tracker
-- @param enable if true then this data tracker will begin to track data
function DHUDPowerTracker:changeAmountMaxTrackingState(enable)
	if (enable) then
		self:updateAmountMax(); -- always recheck amount max as this function can be called on unitId change
	end
	if (self.isTrackingAmountMax == enable) then
		return;
	end
	self.isTrackingAmountMax = enable;
	if (enable) then
		self:startTrackingAmountMax();
		trackingHelper:addEventListener(DHUDDataTrackerHelperEvent.EVENT_ENTERING_WORLD, self, self.onEnteringWorldToCheckMax);
	else
		self:stopTrackingAmountMax();
		trackingHelper:removeEventListener(DHUDDataTrackerHelperEvent.EVENT_ENTERING_WORLD, self, self.onEnteringWorldToCheckMax);
	end
end

--- set amountBasePercent variable
function DHUDPowerTracker:setAmountBasePercent(amountBasePercent)
	if (self.amountBasePercent == amountBasePercent) then
		return;
	end
	self.amountBasePercent = amountBasePercent;
	self:setAmountBase(self.amountBasePercent * self.amountMax);
end

--- set amountMin variable
function DHUDPowerTracker:setAmountMin(amountMin)
	if (self.amountMin == amountMin) then
		return;
	end
	self.amountMin = amountMin;
	self:processDataChanged();
end

--- set amountMinPercent variable
function DHUDPowerTracker:setAmountMinPercent(amountMinPercent)
	--print("set amountMinPercent " .. MCTableToString(amountMinPercent));
	if (self.amountMinPercent == amountMinPercent) then
		return;
	end
	self.amountMinPercent = amountMinPercent;
	self:setAmountMin(self.amountMinPercent * self.amountMax);
end

--- set amountExtra variable
function DHUDPowerTracker:setAmountExtra(amountExtra)
	if (self.amountExtra == amountExtra) then
		return;
	end
	self.amountExtra = amountExtra;
	if (amountExtra >= self.amountExtraMax) then
		self.amountExtraMax = amountExtra;
	elseif (amountExtra <= 0) then
		self.amountExtraMax = 0;
	end
	self:processDataChanged();
end

--- set resourceType variable
-- @param resourceType id of the resource type
-- @param resourceTypeName name of the resource, used to improve performance, pass empty string to allow updates on every UNIT_POWER event
function DHUDPowerTracker:setResourceType(resourceType, resourceTypeName)
	-- don't save string if it's not usual resource, it will be reported as different in power change events
	--print("self.POWER_TYPES[resourceType] " .. MCTableToString(self.POWER_TYPES[resourceType]) .. ", resourceTypeName " .. MCTableToString(resourceTypeName));
	if (resourceType == nil) then
		resourceType = -1;
	end
	if (resourceTypeName == nil or self.POWER_TYPES[resourceType] ~= resourceTypeName) then
		resourceTypeName = "";
	end
	-- return if already set
	if (self.resourceType == resourceType and self.resourceTypeString == resourceTypeName) then
		return;
	end
	self.resourceType = resourceType;
	self.resourceTypeString = resourceTypeName or "";
	self.resourceTypeIsCustom = false;
	self:dispatchEvent(self.eventResourceTypeChanged);
	-- change base amount
	self:setAmountBasePercent(self.BASE_PERCENT_FOR_RESOURCE_TYPE[self.resourceTypeString] or 0);
	self:setAmountMinPercent(self.MIN_PERCENT_FOR_RESOURCE_TYPE[self.resourceTypeString] or 0);
	-- update data
	self:updateData();
end

--- change power tracker to custom resourceType
-- @param resourceType id of the resource type from DHUDColorizeTools class
function DHUDPowerTracker:setCustomResourceType(resourceType)
	self.resourceType = resourceType;
	self.resourceTypeString = "CUSTOM";
	self.resourceTypeIsCustom = true;
end
