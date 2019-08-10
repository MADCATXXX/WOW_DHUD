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
-- Unit auras tracker base class --
-----------------------------------

--- Class to track unit buffs and debuffs
DHUDAurasTracker = MCCreateSubClass(DHUDTimersTracker, {
	-- mask for the type, that specifies that aura is a buff
	TIMER_TYPE_MASK_BUFF			= 1,
	-- mask for the type, that specifies that aura is a debuff
	TIMER_TYPE_MASK_DEBUFF			= 2,
	-- mask for the type, that specifies that aura is of magic type
	TIMER_TYPE_MASK_IS_MAGIC		= 4,
	-- mask for the type, that specifies that aura is of poison type
	TIMER_TYPE_MASK_IS_POISON		= 8,
	-- mask for the type, that specifies that aura is of curse type
	TIMER_TYPE_MASK_IS_CURSE		= 16,
	-- mask for the type, that specifies that aura is of disease type
	TIMER_TYPE_MASK_IS_DISEASE		= 32,
	-- mask for the type, that specifies that aura is of enrage type
	TIMER_TYPE_MASK_IS_ENRAGE		= 64,
	-- mask for the type, that specifies that aura can be purged
	TIMER_TYPE_MASK_IS_PURGABLE		= 128,
	-- mask for the type, that specifies that aura was applied by player
	TIMER_TYPE_MASK_IS_CAST_BY_PLAYER = 256,
	-- table to convert blizz debuffType string to addon type mask
	debuffTypeMask = {
		["Magic"] = 4,
		["Disease"] = 32,
		["Poison"] = 8,
		["Curse"] = 16,
		[""] = 64,
	},
})

--- Create new unit auras tracker, unitId should be specified after constructor
function DHUDAurasTracker:new()
	local o = self:defconstructor();
	o:constructor();
	return o;
end

--- Initialize aura tracking
function DHUDAurasTracker:init()
	local tracker = self;
	-- process units auras change event
	function self.eventsFrame:UNIT_AURA(unitId)
		if (tracker.unitId ~= unitId) then
			return;
		end
		tracker:updateAuras();
	end
end

--- Update unit auras
function DHUDAurasTracker:updateAuras()
	--print("updateAuras Buffs");
	local timerMs = trackingHelper.timerMs;
	local playerCasterUnitId = trackingHelper.playerCasterUnitId;
	-- create variables
	local name, icon, count, debuffType, duration, expirationTime, unitCaster, canPurge, consolidate, spellId, canBeCastByPlayer, isCastByBoss, isCastByPlayer;
	local timer;
	-- update buffs
	self:findSourceTimersBegin(0);
	-- iterate
	local i = 1;
	while (true) do
		name, icon, count, debuffType, duration, expirationTime, unitCaster, canPurge, consolidate, spellId, canBeCastByPlayer, isCastByBoss = UnitBuff(self.unitId, i);
		if (name == nil) then
			break;
		end
		timer = self:findTimer(i, spellId);
		-- fill timer info, { type, timeLeft, duration, id, tooltipId, name, stacks, texture, exists, iterating, sortOrder }
		timer[1] = self.TIMER_TYPE_MASK_BUFF + (self.debuffTypeMask[debuffType] or 0) + (canPurge and self.TIMER_TYPE_MASK_IS_PURGABLE or 0) + (unitCaster == playerCasterUnitId and self.TIMER_TYPE_MASK_IS_CAST_BY_PLAYER or 0); -- type
		timer[2] = expirationTime - timerMs; -- timeLeft
		timer[3] = trackingHelper:getUnitAuraCorrectDuration(spellId, duration); -- duration
		timer[4] = spellId; -- id
		timer[5] = i; -- tooltip id
		timer[6] = name; -- name
		timer[7] = count; -- stacks
		timer[8] = icon; -- texture
		-- continue
		i = i + 1;
	end
	-- stop
	self:findSourceTimersEnd(0);
	-- update debuffs
	--print("updateAuras DeBuffs");
	self:findSourceTimersBegin(1);
	-- iterate
	i = 1;
	while (true) do
		name, icon, count, debuffType, duration, expirationTime, unitCaster, canPurge, consolidate, spellId, canBeCastByPlayer, isCastByBoss = UnitDebuff(self.unitId, i);
		if (name == nil) then
			break;
		end
		timer = self:findTimer(i, spellId);
		-- fill timer info, { type, timeLeft, duration, id, tooltipId, name, stacks, texture, exists, iterating, sortOrder }
		--print("name " .. name .. ", unitCaster " .. unitCaster);
		timer[1] = self.TIMER_TYPE_MASK_DEBUFF + (self.debuffTypeMask[debuffType] or 0) + (canPurge and self.TIMER_TYPE_MASK_IS_PURGABLE or 0) + (unitCaster == playerCasterUnitId and self.TIMER_TYPE_MASK_IS_CAST_BY_PLAYER or 0); -- type
		timer[2] = expirationTime - timerMs; -- timeLeft
		timer[3] = trackingHelper:getUnitAuraCorrectDuration(spellId, duration); -- duration
		timer[4] = spellId; -- id
		timer[5] = i; -- tooltip id
		timer[6] = name; -- name
		timer[7] = count; -- stacks
		timer[8] = icon; -- texture
		-- continue
		i = i + 1;
	end
	-- stop
	self:findSourceTimersEnd(1);
	-- updateTimers for other source groups
	--print("force Update");
	self:forceUpdateTimers();
	-- dispatch event
	--print("data changed");
	self:processDataChanged();
end

--- Update all data for current unitId
function DHUDAurasTracker:updateData()
	self:updateAuras();
end

--- Start tracking data
function DHUDAurasTracker:startTracking()
	-- listen to game events
	self.eventsFrame:RegisterEvent("UNIT_AURA");
	-- call super
	DHUDTimersTracker.startTracking(self);
end

--- Stop tracking data
function DHUDAurasTracker:stopTracking()
	-- stop listening to game events
	self.eventsFrame:UnregisterEvent("UNIT_AURA");
	-- call super
	DHUDTimersTracker.stopTracking(self);
end
