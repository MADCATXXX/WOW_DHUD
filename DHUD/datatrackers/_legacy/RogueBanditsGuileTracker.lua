--[[-----------------------------------------------------------------------------------
 Original Drathals HUD (c) 2006 by Markus Inger / Drathal / Silberklinge / Silbersegen
 DHUD for WotLK and later expansions (c) 2013 by MADCAT (EU-Гордунни, Мадкат)
 (http://eu.battle.net/wow/en/character/гордунни/Мадкат/advanced)
---------------------------------------------------------------------------------------
 This file contains functions and classes to track data about unit resources, health,
 buffs and other information
 @author: MADCAT
-----------------------------------------------------------------------------------]]--

-- antitaint local "_" var
local _;

-------------------
-- Bandits Guile --
-------------------
DHUDBanditsGuileTracker = MCCreateSubClass(DHUDCustomTimerTracker, {
	-- ids of the bandits guile spell progress
	BANDITS_GUILE_PROGRESS_SPELL_IDS = { 84745, 84746, 84747 },
	-- id of the bandits guile spell
	BANDITS_GUILE_SPELL_ID = 84654,
	-- id of the sinister strike spell
	SINISTER_STRIKE_SPELL_ID = 1752,
	-- data about bandits guile ability { name, rank, icon, castTime, minRange, maxRange }
	banditsGuileSpellData = nil,
	-- combat events frame to listen for combat events
	combatEventsFrame = nil,
	-- current stack count
	stacks = 1,
	-- current bandits guile state (0 - white, 3 - red)
	state = 0,
	-- last processed combat event time, since game can report absord and damage events on one cast
	lastProcessedCombatEventTime = 0,
})

--- Create new runes tracker for player and vehicle
function DHUDBanditsGuileTracker:new()
	local o = self:defconstructor();
	o:constructor();
	return o;
end

--- Initialize bandits guile tracking
function DHUDBanditsGuileTracker:init()
	local tracker = self;
	-- create combat event frame
	self.combatEventsFrame = MCCreateBlizzCombatEventFrame();
	-- update vars
	self.timerIdsToUpdate = self.BANDITS_GUILE_PROGRESS_SPELL_IDS;
	self.banditsGuileSpellData = trackingHelper:getSpellData(self.BANDITS_GUILE_SPELL_ID);
	-- process units max health points change event
	function self.combatEventsFrame:SPELL_DAMAGE(timestamp, hideCaster, sourceGUID, ...)
		if (sourceGUID ~= trackingHelper.guids[tracker.unitId]) then
			return;
		end
		local spellId = select(8, ...);
		local multistrike = select(21, ...);
		if (tracker.SINISTER_STRIKE_SPELL_ID ~= spellId or multistrike == true) then
			return;
		end
		--print("SPELL_DAMAGE " .. MCTableToString({ ... }));
		tracker:processSinisterDamageAndAbsorb();
	end
	function self.combatEventsFrame:SPELL_ABSORBED(timestamp, hideCaster, sourceGUID, ...)
		if (sourceGUID ~= trackingHelper.guids[tracker.unitId]) then
			return;
		end
		local spellId = select(8, ...);
		if (tracker.SINISTER_STRIKE_SPELL_ID ~= spellId) then
			return;
		end
		--print("SPELL_ABSORBED " .. MCTableToString({ ... }));
		tracker:processSinisterDamageAndAbsorb();
	end
	-- init unit ids
	self:initPlayerNotInVehicleOrNoneUnitId();
	self:initPlayerSpecsOnly(2);
	self:attachToTimersTrackerIfAllowed(DHUDDataTrackers.ALL.selfAuras, 0);
end

--- get default timer if required, to be overriden by subclasses
-- @return default timer if required
function DHUDBanditsGuileTracker:getDefaultTimer()
	local timer = self:createDefaultTimer(self.BANDITS_GUILE_SPELL_ID);
	timer[8] = "Interface\\Icons\\inv_bijou_silver"; -- white bijou
	timer[4] = self.BANDITS_GUILE_SPELL_ID;
	return timer;
end

--- Update timer with custom data
-- @param timer timer to be updated { type, timeLeft, duration, id, tooltipId, name, stacks, texture, exists, iterating, sortOrder, grouped, groupData }
-- @return default timer
function DHUDBanditsGuileTracker:updateTimer(timer)
	-- update name
	timer[6] = self.banditsGuileSpellData[1];
	--print("timer[6] " .. timer[6]);
	-- if spell id is not at current state then reset stack count
	local spellId = timer[4];
	local index = 0;
	for i, v in ipairs(self.BANDITS_GUILE_PROGRESS_SPELL_IDS) do
		if (v == spellId) then
			index = i;
			break;
		end
	end
	--print("index " .. index .. ", state " .. self.state .. ", stacks " .. self.stacks);
	if (index ~= self.state or index == 3) then
		self.state = index;
		self.stacks = 1;
	end
	-- update stacks
	timer[7] = self.stacks;
end

--- process sinister damage and absorb events
function DHUDBanditsGuileTracker:processSinisterDamageAndAbsorb()
	local timerMs = trackingHelper.timerMs;
	if (timerMs - self.lastProcessedCombatEventTime > 0.75) then
		--print("timeDiff " .. (timerMs - self.lastProcessedCombatEventTime));
		self.lastProcessedCombatEventTime = timerMs;
		self.stacks = self.stacks + 1;
		self:updateBanditsGuile();
	end
end

--- character is entering world, update
function DHUDBanditsGuileTracker:onEnteringWorld(e)
	self.state = 0;
	self.stacks = 1;
	-- call super
	DHUDDataTracker.onEnteringWorld(self, e); -- this will cause updateData
end

--- update bandits guile state
function DHUDBanditsGuileTracker:updateBanditsGuile()
	self:processDataChanged();
end

--- Start tracking data
function DHUDBanditsGuileTracker:startTracking()
	--print("banditsGuile start");
	self.combatEventsFrame:RegisterEvent("SPELL_DAMAGE");
	self.combatEventsFrame:RegisterEvent("SPELL_ABSORBED");
end

--- Stop tracking data
function DHUDBanditsGuileTracker:stopTracking()
	--print("banditsGuile stop");
	self.combatEventsFrame:UnregisterEvent("SPELL_DAMAGE");
	self.combatEventsFrame:UnregisterEvent("SPELL_ABSORBED");
end

--- Update all data for current unitId
function DHUDBanditsGuileTracker:updateData()
	self:updateBanditsGuile();
end