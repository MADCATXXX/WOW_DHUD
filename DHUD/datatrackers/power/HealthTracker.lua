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

------------------------------------
-- Unit health tracker base class --
------------------------------------

--- Base class for trackers of health points (actually it's subclasses will only set unitId to track)
DHUDHealthTracker = MCCreateSubClass(DHUDPowerTracker, {
	-- List of absorb spells to query for negative absorbs (there is UNIT_ABSORB_AMOUNT_CHANGED event for positive absorb but not for negative)
	SPELLIDS_ABSORB_HEAL = {
		--73975,			-- DK: Necrotic Strike
	};
	-- amount of incoming heal (e.g. when casting non-instant healing spell on the target)
	amountHealIncoming	= 0,
	-- amount of healing absorption (e.g. Necrotic Strike that should be healed through)
	amountHealAbsorb	= 0,
	-- defines state at which killing unit won't give credit to player (unit tagging)
	noCreditForKill		= false,
	-- reference to tracker which will make tracking of unit tagging
	creditInfoTracker	= nil,
	-- if true than this resource will also be updated by onUpdate event, this variable should not be changed during runtime!
	updateFrequently	= true, -- TODO: check, why UNIT_HEALTH is reporting old value
})

--- Create new health points tracker, unitId should be specified after constructor
function DHUDHealthTracker:new()
	local o = self:defconstructor();
	o:constructor();
	return o;
end

--- Initialize health-points tracking
function DHUDHealthTracker:init()
	local tracker = self;
	-- process units health points change event
	function self.eventsFrame:UNIT_HEALTH(unitId)
		if (tracker.unitId ~= unitId) then
			return;
		end
		tracker:updateHealth();
	end
	-- process units max health points change event
	function self.eventsFrame:UNIT_MAXHEALTH(unitId)
		if (tracker.unitId ~= unitId) then
			return;
		end
		tracker:updateMaxHealth();
	end
	-- process units absorb amount change event
	function self.eventsFrame:UNIT_HEAL_PREDICTION(unitId)
		if (tracker.unitId ~= unitId) then
			return;
		end
		tracker:updateIncomingHeal();
	end
	-- process units absorb amount change event
	function self.eventsFrame:UNIT_ABSORB_AMOUNT_CHANGED(unitId)
		if (tracker.unitId ~= unitId) then
			return;
		end
		tracker:updateAbsorbs();
	end
	-- process units heal absorb amount change event
	function self.eventsFrame:UNIT_HEAL_ABSORB_AMOUNT_CHANGED(unitId)
		if (tracker.unitId ~= unitId) then
			return;
		end
		tracker:updateAbsorbedHeal();
	end
	-- process units heal absorb amount change event
	function self.eventsFrame:UNIT_AURA(unitId)
		if (tracker.unitId ~= unitId) then
			return;
		end
		tracker:updateAbsorbedHeal();
	end
	-- change base amount of health
	self:setAmountBasePercent(1);
	-- track maximum amount event if data tracker is not activated
	self.trackAmountMax = true;
end

--- set noCreditForKill variable value
function DHUDHealthTracker:setNoCreditForKill(noCreditForKill)
	if (self.noCreditForKill == noCreditForKill) then
		return;
	end
	self.noCreditForKill = noCreditForKill;
	self:dispatchEvent(self.eventResourceTypeChanged);
end

--- Game time updated, update unit health
function DHUDHealthTracker:onUpdateTime()
	self:updateHealth();
	self:updateMaxHealth();
end

--- Start tracking data
function DHUDHealthTracker:startTracking()
	-- listen to game events
	self.eventsFrame:RegisterEvent("UNIT_HEALTH");
	self.eventsFrame:RegisterEvent("UNIT_HEAL_PREDICTION");
	self.eventsFrame:RegisterEvent("UNIT_ABSORB_AMOUNT_CHANGED");
	self.eventsFrame:RegisterEvent("UNIT_HEAL_ABSORB_AMOUNT_CHANGED");
	--self.eventsFrame:RegisterEvent("UNIT_AURA");
	if (self.creditInfoTracker ~= nil) then
		self.creditInfoTracker:addEventListener(DHUDDataTrackerEvent.EVENT_DATA_CHANGED, self, self.updateTagging);
	end
	if (self.updateFrequently) then
		trackingHelper:addEventListener(DHUDDataTrackerHelperEvent.EVENT_UPDATE, self, self.onUpdateTime);
	end
end

--- Stop tracking data
function DHUDHealthTracker:stopTracking()
	-- stop listening to game events
	self.eventsFrame:UnregisterEvent("UNIT_HEALTH");
	self.eventsFrame:UnregisterEvent("UNIT_HEAL_PREDICTION");
	self.eventsFrame:UnregisterEvent("UNIT_ABSORB_AMOUNT_CHANGED");
	self.eventsFrame:UnregisterEvent("UNIT_HEAL_ABSORB_AMOUNT_CHANGED");
	--self.eventsFrame:UnregisterEvent("UNIT_AURA");
	if (self.creditInfoTracker ~= nil) then
		self.creditInfoTracker:removeEventListener(DHUDDataTrackerEvent.EVENT_DATA_CHANGED, self, self.updateTagging);
	end
	if (self.updateFrequently) then
		trackingHelper:removeEventListener(DHUDDataTrackerHelperEvent.EVENT_UPDATE, self, self.onUpdateTime);
	end
end

--- Start tracking amountMax data
function DHUDHealthTracker:startTrackingAmountMax()
	self.eventsFrame:RegisterEvent("UNIT_MAXHEALTH");
end

--- Update maximum amount or resource
function DHUDHealthTracker:updateAmountMax()
	self.eventsFrame:UNIT_MAXHEALTH(self.unitId);
end

--- Stop tracking amountMax data
function DHUDHealthTracker:stopTrackingAmountMax()
	self.eventsFrame:UnregisterEvent("UNIT_MAXHEALTH");
end

--- Update absorb amounts for unit
function DHUDHealthTracker:updateAbsorbs()
	self:setAmountExtra(UnitGetTotalAbsorbs(self.unitId) or 0);
	self:processDataChanged();
end

--- Update incoming heal for unit
function DHUDHealthTracker:updateIncomingHeal()
	local before = self.amountHealIncoming;
	self.amountHealIncoming = UnitGetIncomingHeals(self.unitId) or 0;
	-- dispatch event
	if (before ~= self.amountHealIncoming) then
		self:processDataChanged();
	end
end

--- Update incoming heal for unit
function DHUDHealthTracker:updateAbsorbedHeal()
	local before = self.amountHealAbsorb;
	--[[self.amountHealAbsorb = 0;
	-- iterate over absorbing spellids
	for i, v in ipairs(self.SPELLIDS_ABSORB_HEAL) do
		--name, icon, count, dispelType, duration, expires, caster, isStealable, shouldConsolidate, spellID, canApplyAura, isBossDebuff, value1, value2, value3
		local value = select(14, UnitDebuff(self.unitId, trackingHelper:getSpellName(v)));
		--if (UnitDebuff(self.unitId, trackingHelper:getSpellName(v)) ~= nil) then
		--	print(MCTableToString({UnitDebuff(self.unitId, trackingHelper:getSpellName(v)) } ));
		--end
		self.amountHealAbsorb = self.amountHealAbsorb + (value or 0);
	end]]--
	self.amountHealAbsorb = UnitGetTotalHealAbsorbs(self.unitId) or 0;
	-- dispatch event
	if (before ~= self.amountHealAbsorb) then
		self:processDataChanged();
	end
end

--- Update health for unit
function DHUDHealthTracker:updateHealth()
	--print("UnitHealth(self.unitId) " .. MCTableToString(UnitHealth(self.unitId)));
	self:setAmount(UnitHealth(self.unitId) or 0);
end

--- Update maximum health for unit
function DHUDHealthTracker:updateMaxHealth()
	--print("UnitHealthMax(self.unitId) " .. MCTableToString(UnitHealthMax(self.unitId)));
	self:setAmountMax(UnitHealthMax(self.unitId) or 0);
end

--- Update unit tagging for unit
function DHUDHealthTracker:updateTagging(e)
	if (self.creditInfoTracker == nil) then
		return;
	end
	self:setNoCreditForKill(not self.creditInfoTracker.tagged);
end

--- Update all data for current unitId
function DHUDHealthTracker:updateData()
	self:setAmountExtra(0); -- this will update shield amount max
	self:updateAbsorbs();
	self:updateIncomingHeal();
	self:updateAbsorbedHeal();
	self:updateMaxHealth();
	self:updateTagging();
	self:updateHealth();
end

--- Attach info tracker to track unit tagging inside this tracker
function DHUDHealthTracker:attachCreditTracker(infoTracker)
	-- remove listener from old tracker
	if (self.creditInfoTracker ~= nil) then
		self.creditInfoTracker:removeEventListener(DHUDDataTrackerEvent.EVENT_DATA_CHANGED, self, self.updateTagging);
	end
	self.creditInfoTracker = infoTracker;
	-- add listener to new tracker
	if (infoTracker ~= nil and self.isTracking) then
		self.creditInfoTracker:addEventListener(DHUDDataTrackerEvent.EVENT_DATA_CHANGED, self, self.updateTagging);
		self:updateTagging();
	end
end
