--[[-----------------------------------------------------------------------------------
 Original Drathals HUD (c) 2006 by Markus Inger / Drathal / Silberklinge / Silbersegen
 DHUD for WotLK and later expansions (c) 2013 by MADCAT (EU-Гордунни, Мадкат)
 (http://eu.battle.net/wow/en/character/Гордунни/Мадкат/advanced)
---------------------------------------------------------------------------------------
 This file contains functions and classes to track data about unit losing stealth status
 @author: MADCAT
-----------------------------------------------------------------------------------]]--

-- antitaint local "_" var
local _;
-- tracker helper
local trackingHelper = DHUDDataTrackingHelper;

-----------------------
-- Self info tracker --
-----------------------
--- Base class to track unit spell castings, spells channeling and delays
DHUDSelfDeStealthTracker = MCCreateSubClass(DHUDDataTracker, {
	-- id of the stealth spell, 1784 for rogue, 5215 for druid
	stealthSpellId = 1784,
	-- name of the stealth spell
	stealthSpellName = "",
	-- defines if combat data is being analyzed (increases CPU usage)
	combatDataTracking = false,
	-- combat event frame to listen to combat events
	combatEventsFrame = nil,
	-- data about stealth aura broke combat event
	lastBrokeData = { },
	-- data about last combat events, to be used when determining stealth broke reason
	lastEventsData = { },
	-- reason for which stealth was broken last time
	lastBrokeReason = "",
})

--- Create new unit info tracker, unitId should be specified after constructor
function DHUDSelfDeStealthTracker:new()
	local o = self:defconstructor();
	o:constructor();
	return o;
end

--- Constructor of destealth tracker
function DHUDSelfDeStealthTracker:constructor()
	if (trackingHelper.playerClass == "DRUID") then
		self.stealthSpellId = 5215;
	end
	self.stealthSpellName = trackingHelper:getSpellData(self.stealthSpellId, false)[1];
	-- create combat event frame
	self.combatEventsFrame = MCCreateBlizzCombatEventFrame();
	-- call super constructor
	DHUDDataTracker.constructor(self);
end

--- Initialize health-points tracking
function DHUDSelfDeStealthTracker:init()
	local tracker = self;
	-- process combat spell interrupt event
	function self.combatEventsFrame:SPELL_AURA_BROKEN(timestamp, hideCaster, sourceGUID, sourceName, sourceFlags, sourceFlags2, destGUID, destName, destFlags, destFlags2, spellId, spellName, auraType)
		if (destGUID ~= trackingHelper.guids[tracker.unitId]) then
			return;
		end
		if (spellId ~= tracker.stealthSpellId) then
			return;
		end
		DHUDMain:print("Aura broken " .. MCTableToString( { timestamp, hideCaster, sourceGUID, sourceName, sourceFlags, sourceFlags2, destGUID, destName, destFlags, destFlags2, spellId, spellName, auraType } ));
	end
	function self.combatEventsFrame:SPELL_AURA_BROKEN_SPELL(timestamp, hideCaster, sourceGUID, sourceName, sourceFlags, sourceFlags2, destGUID, destName, destFlags, destFlags2, spellId, spellName, extraSpellId, extraSpellName, extraSchool, auraType)
		if (destGUID ~= trackingHelper.guids[tracker.unitId]) then
			return;
		end
		if (spellId ~= tracker.stealthSpellId) then
			return;
		end
		DHUDMain:print("Aura broken spell " .. MCTableToString( { timestamp, hideCaster, sourceGUID, sourceName, sourceFlags, sourceFlags2, destGUID, destName, destFlags, destFlags2, spellId, spellName, extraSpellId, extraSpellName, extraSchool, auraType } ));
	end
	function self.combatEventsFrame:SPELL_AURA_REMOVED(timestamp, hideCaster, sourceGUID, sourceName, sourceFlags, sourceFlags2, destGUID, destName, destFlags, destFlags2, spellId, spellName, auraType)
		if (destGUID ~= trackingHelper.guids[tracker.unitId]) then
			return;
		end
		if (spellId ~= tracker.stealthSpellId) then
			return;
		end
		DHUDMain:print("Aura removed " .. MCTableToString( { timestamp, hideCaster, sourceGUID, sourceName, sourceFlags, sourceFlags2, destGUID, destName, destFlags, destFlags2, spellId, spellName, auraType } ));
	end
	-- process unit aura
	function self.eventsFrame:UNIT_AURA(unitId)
		if (unitId ~= tracker.unitId) then
			return;
		end
		local hasStealth = false;
		i = 1;
		while (true) do
			name, icon, count, debuffType, duration, expirationTime, unitCaster, canPurge, consolidate, spellId = UnitBuff(tracker.unitId, i);
			if (name == nil) then
				break;
			end
			if (spellId == tracker.stealthSpellId) then
				hasStealth = true;
				break;
			end
			-- continue
			i = i + 1;
		end
		if (hasStealth) then
			tracker:changeCombatDataTracking(true);
		else
			tracker:changeCombatDataTracking(false);
		end
	end
	-- track combat events
	function self.eventsFrame:COMBAT_LOG_EVENT_UNFILTERED()
		local timestamp, event, hideCaster, sourceGUID, sourceName, sourceFlags, sourceFlags2, destGUID, destName, destFlags, destFlags2, ex1, ex2, ex3, ex4, ex5 = CombatLogGetCurrentEventInfo();
		local requiredGUID = trackingHelper.guids[tracker.unitId];
		if (sourceGUID ~= requiredGUID and destGUID ~= requiredGUID) then
			return;
		end
		if (event == "SPELL_AURA_REMOVED" or event == "SPELL_AURA_BROKEN_SPELL" or event == "SPELL_AURA_BROKEN") then
			if (ex1 ~= tracker.stealthSpellId) then
				return;
			end
			local lastEventData = { timestamp, event, hideCaster, sourceGUID, sourceName, sourceFlags, sourceFlags2, destGUID, destName, destFlags, destFlags2, ex1, ex2, ex3, ex4, ex5 };
			tracker.lastBrokeData = lastEventData;
			--DHUDMain:print(MCTableToString( { timestamp, event, hideCaster, sourceGUID, sourceName, sourceFlags, sourceFlags2, destGUID, destName, destFlags, destFlags2, spellId, spellName, auraType }));
		else
			local lastEventData = { timestamp, event, hideCaster, sourceGUID, sourceName, sourceFlags, sourceFlags2, destGUID, destName, destFlags, destFlags2, ex1, ex2, ex3, ex4, ex5 };
			if (#tracker.lastEventsData > 0 and tracker.lastEventsData[1][1] ~= timestamp) then -- another timestamp
				tracker.lastEventsData = {};
			end
			table.insert(tracker.lastEventsData, lastEventData);
			--DHUDMain:print("Save prev event " .. MCTableToString(tracker.lastEventData));
		end
	end
	-- init player only tracking
	self:initPlayerUnitId();
end

-- change combat data tracking state
function DHUDSelfDeStealthTracker:changeCombatDataTracking(enable)
	if (self.combatDataTracking == enable) then
		return;
	end
	self.combatDataTracking = enable;
	if (enable) then
		self.lastEventsData = { };
		self:startTrackingCombatData();
	else
		local events = {};
		local timestamp = self.lastBrokeData[1];
		if (#self.lastEventsData > 0 and timestamp ~= nil and math.abs(self.lastEventsData[1][1] - timestamp) < 0.1) then
			events = self.lastEventsData;
		else
			--events = self.lastEventsData;
		end
		DHUDMain:print(MCTableToString(self.lastBrokeData) .. " near events: " .. MCTableToString(events));
		self:stopTrackingCombatData();
	end
end

--- Start tracking combat data
function DHUDSelfDeStealthTracker:startTrackingCombatData()
	print("tracking started!");
	-- listen to combat game events
	--self.combatEventsFrame:RegisterEvent("SPELL_AURA_BROKEN");
	--self.combatEventsFrame:RegisterEvent("SPELL_AURA_BROKEN_SPELL");
	--self.combatEventsFrame:RegisterEvent("SPELL_AURA_REMOVED");
	
	self.eventsFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
end

--- Stop tracking combat data
function DHUDSelfDeStealthTracker:stopTrackingCombatData()
	print("tracking stoped!");
	-- stop listen to combat game events
	--self.combatEventsFrame:UnregisterEvent("SPELL_AURA_BROKEN");
	--self.combatEventsFrame:UnregisterEvent("SPELL_AURA_REMOVED");
	self.eventsFrame:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
end

--- Start tracking data
function DHUDSelfDeStealthTracker:startTracking()
	-- listen to combat game events
	self.eventsFrame:RegisterEvent("UNIT_AURA");
end

--- Stop tracking data
function DHUDSelfDeStealthTracker:stopTracking()
	-- stop listen to combat game events
	self.eventsFrame:UnregisterEvent("UNIT_AURA");
end

--- Update all data for current unitId
function DHUDSelfDeStealthTracker:updateData()
	-- nothing to do, all data is event based
end
