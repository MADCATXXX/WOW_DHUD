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
-- Unit aura value tracker base class --
----------------------------------------

--- Base class for trackers of aura value (actually it's subclasses will only set unitId to track, auras to track and max value)
DHUDAuraValueTracker = MCCreateSubClass(DHUDPowerTracker, {
	-- auras to track, aura value tracker will stop on first found aura from this list
	aurasToTrack = { },
	-- modifier to be used when calculating maximum aura value
	maxAuraValuePercentModifier = 1,
})

--- Create new aura value tracker, unitId should be specified after constructor
function DHUDAuraValueTracker:new()
	local o = self:defconstructor();
	o:constructor();
	return o;
end

--- Initialize aura value tracking
function DHUDAuraValueTracker:init()
	local tracker = self;
	-- process units absorb amount change event
	function self.eventsFrame:UNIT_AURA(unitId)
		if (tracker.unitId ~= unitId) then
			return;
		end
		tracker:updateAuraValue();
	end
end

--- Start tracking data
function DHUDAuraValueTracker:startTracking()
	-- listen to game events
	self.eventsFrame:RegisterEvent("UNIT_AURA");
end

--- Stop tracking data
function DHUDAuraValueTracker:stopTracking()
	-- stop listening to game events
	self.eventsFrame:UnregisterEvent("UNIT_AURA");
end

--- Update value for unit
function DHUDAuraValueTracker:updateAuraValue()
	local auraValue;
	-- iterate over auras spellids
	for i, v in ipairs(self.aurasToTrack) do
		--name, icon, count, dispelType, duration, expires, caster, isStealable, shouldConsolidate, spellID, canApplyAura, isBossDebuff, value1, value2, value3
		auraValue = select(14, UnitAura(self.unitId, trackingHelper:getSpellName(v)));
		if (auraValue ~= nil) then
			break;
		end
	end
	self:setAmount(auraValue or 0);
end

--- Update maximum value for unit
function DHUDAuraValueTracker:updateAuraValueMax()
	self:setAmountMax(100);
end

--- Update all data for current unitId
function DHUDAuraValueTracker:updateData()
	self:updateAuraValue();
	self:updateAuraValueMax();
end

--- Set auras to track by data tracker
-- @param ... auras list, aura value tracker will stop on first found aura from this list
function DHUDAuraValueTracker:setAurasToTrack(...)
	self.aurasToTrack = { ... };
end

--- Set aura maximum value as percent of players health
-- @param percent percent of players health
function DHUDAuraValueTracker:setMaxAuraValueAsHealthPercent(percent)
	-- save percent
	self.maxAuraValuePercentModifier = percent;
	-- update functions to subscribe to game events about health
	local tracker = self;
	-- process units max health points change event
	function self.eventsFrame:UNIT_MAXHEALTH(unitId)
		if (tracker.unitId ~= unitId) then
			return;
		end
		tracker:updateAuraValueMax();
	end
	--- Update maximum value for unit
	function self:updateAuraValueMax()
		self:setAmountMax((UnitHealthMax(self.unitId) or 0) * self.maxAuraValuePercentModifier);
	end
	--- Start tracking amountMax data
	function self:startTrackingAmountMax()
		self.eventsFrame:RegisterEvent("UNIT_MAXHEALTH");
	end
	--- Update maximum amount or resource
	function self:updateAmountMax()
		self.eventsFrame:UNIT_MAXHEALTH(self.unitId);
	end
	--- Stop tracking amountMax data
	function self:stopTrackingAmountMax()
		self.eventsFrame:UnregisterEvent("UNIT_MAXHEALTH");
	end
end

--- Start tracking amountMax data
function DHUDAuraValueTracker:startTrackingAmountMax()
	
end

--- Update maximum amount or resource
function DHUDAuraValueTracker:updateAmountMax()
	
end

--- Stop tracking amountMax data
function DHUDAuraValueTracker:stopTrackingAmountMax()
	
end
