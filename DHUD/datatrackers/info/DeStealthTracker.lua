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
	-- id of the stealth spell, 1784 and 115191 for rogue, 5215 for druid
	stealthSpellId = 1784,
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
	-- create combat event frame
	self.combatEventsFrame = MCCreateBlizzCombatEventFrame();
	-- call super constructor
	DHUDDataTracker.constructor(self);
end

--- Initialize health-points tracking
function DHUDSelfDeStealthTracker:init()
	local tracker = self;
	-- process unit aura
	function self.eventsFrame:UNIT_AURA(unitId)
		if (unitId ~= tracker.unitId) then
			return;
		end
		tracker:checkHasStealth(true);
	end
	function self.eventsFrame:PLAYER_TALENT_UPDATE()
		local beforeId = tracker.stealthSpellId;
		tracker:recheckStealthSpellId();
		if (beforeId ~= tracker.stealthSpellId) then
			tracker:checkHasStealth(false);
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
			if (ex1 ~= tracker.stealthSpellId or destGUID ~= requiredGUID) then
				return;
			end
			local lastEventData = { timestamp, event, hideCaster, sourceGUID, sourceName, sourceFlags, sourceFlags2, destGUID, destName, destFlags, destFlags2, ex1, ex2, ex3, ex4, ex5 };
			tracker.lastBrokeData = lastEventData;
			--DHUDMain:print(MCTableToString( { timestamp, event, hideCaster, sourceGUID, sourceName, sourceFlags, sourceFlags2, destGUID, destName, destFlags, destFlags2, spellId, spellName, auraType }));
		else
			local lastEventData = { timestamp, event, hideCaster, sourceGUID, sourceName, sourceFlags, sourceFlags2, destGUID, destName, destFlags, destFlags2, ex1, ex2, ex3, ex4, ex5 };
			if (#tracker.lastEventsData > 0 and math.abs(tracker.lastEventsData[1][1] - timestamp) >= 0.25) then -- another timestamp
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
		self.lastBrokeData = { };
		self.lastEventsData = { };
		self:startTrackingCombatData();
	else
		local events = {};
		local timestamp = self.lastBrokeData[1];
		if (#self.lastEventsData > 0 and timestamp ~= nil and math.abs(self.lastEventsData[1][1] - timestamp) < 0.5) then -- it's normal for event to differ by 0.15 - 0.5 sec
			events = self.lastEventsData;
		end
		local brokeReasonInfoCount = #self.lastBrokeData; -- timestamp, event, hideCaster, sourceGUID, sourceName, sourceFlags, sourceFlags2, destGUID, destName, destFlags, destFlags2, ex1, ex2, ex3, ex4, ex5
		if (brokeReasonInfoCount == 0) then
			self.lastBrokeReason = "Stealth removed without combat events";
		elseif (brokeReason == "SPELL_AURA_BROKEN_SPELL") then
			self.lastBrokeReason = "Stealth broken by " .. MCTableToString(self.lastBrokeData[5]) .. " via spell " .. MCTableToString(self.lastBrokeData[13]) .. ", full data: " .. MCTableToString(self.lastBrokeData);
		else
			local nearEventsCount = #events;
			if (nearEventsCount == 0) then
				if (brokeReason == "SPELL_AURA_BROKEN") then
					self.lastBrokeReason = "Stealth broken by " .. MCTableToString(self.lastBrokeData);
				else
					if (self.lastBrokeReason[4] == self.lastBrokeReason[8]) then
						self.lastBrokeReason = "Stealth removed by self without other combat data";
					else
						self.lastBrokeReason = "Stealth removed by " .. MCTableToString(self.lastBrokeData);
					end
				end
			else
				-- check near events
				local playerGUID = trackingHelper.guids[self.unitId];
				local mostProbableEvent = nil;
				local mostProbableReason = -1;
				local reasonPriorities = { "SPELL_CAST_SUCCESS", "SPELL_DAMAGE", "SWING_DAMAGE", "SPELL_ABSORBED", "SWING_MISSED", "SPELL_AURA_APPLIED" };
				local numReasonPriorities = #reasonPriorities;
				local debugReasons = {};
				for i = 1, nearEventsCount do
					local eventInfo = events[i];
					local event = eventInfo[2];
					local eventReasonCalc = 0;
					for j = 1, numReasonPriorities do
						if (event == reasonPriorities[j]) then
							eventReasonCalc = numReasonPriorities + 1 - j;
							break;
						end
					end
					-- action from priority table
					if (eventReasonCalc > 0) then
						-- player action has more priority
						if (eventInfo[4] == playerGUID) then
							local destGUID = eventInfo[8];
							if (destGUID ~= nil and destGUID ~= "" and destGUID ~= playerGUID) then
								eventReasonCalc = eventReasonCalc + 300;
							else -- self buff (e.g. trinket proc)
								eventReasonCalc = 0; --eventReasonCalc + 100;
							end
						else -- incoming action
							eventReasonCalc = eventReasonCalc + 200;
						end
					else
						table.insert(debugReasons, ((eventInfo[4] == playerGUID and "player " or "incoming ") .. event));
					end
					if (eventReasonCalc >= mostProbableReason) then -- later events have more priority, but not on same tick (since we have window of 500 ms)
						if (eventReasonCalc > mostProbableReason or eventInfo[1] - mostProbableEvent[1] > 0.05) then -- more priority or more later
							mostProbableEvent = eventInfo;
							mostProbableReason = eventReasonCalc;
						end
					end
				end
				if (mostProbableReason <= 0) then
					DHUDMain:print("All possible reasons " .. MCTableToString(debugReasons));
				end
				local eventDescription = mostProbableReason .. ": " .. MCTableToString(mostProbableEvent[2]) .. " from " .. MCTableToString(mostProbableEvent[5]) .. " to " .. MCTableToString(mostProbableEvent[9]) .. " via " .. MCTableToString(mostProbableEvent[13]);
				local diff = self.lastBrokeData[1] - mostProbableEvent[1];
				if (diff >= 0) then
					eventDescription = eventDescription .. string.format(" %.2f seconds ago", diff);
				else
					eventDescription = eventDescription .. string.format(" %.2f seconds after", -diff);
				end
				if (brokeReason == "SPELL_AURA_BROKEN") then
					self.lastBrokeReason = "Stealth broke by " .. MCTableToString(self.lastBrokeData) .. ", most probable reason " .. eventDescription;
				else
					if (self.lastBrokeReason[4] == self.lastBrokeReason[8]) then
						self.lastBrokeReason = "Stealth removed most probable reason " .. eventDescription;
					else
						self.lastBrokeReason = "Stealth removed by " .. MCTableToString(self.lastBrokeData) .. ", most probable reason " .. eventDescription;
					end
				end
			end
		end
		DHUDMain:print(self.lastBrokeReason);
		self:stopTrackingCombatData();
	end
end

--- Start tracking combat data
function DHUDSelfDeStealthTracker:startTrackingCombatData()
	--print("tracking started!");
	-- listen to combat game events
	self.eventsFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
end

--- Stop tracking combat data
function DHUDSelfDeStealthTracker:stopTrackingCombatData()
	--print("tracking stoped!");
	-- stop listen to combat game events
	self.eventsFrame:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
end

-- check if unit has stealth and start/stop tracking destealth
function DHUDSelfDeStealthTracker:checkHasStealth(canRecheck)
	local hasStealth = false;
	i = 1;
	while (true) do
		name, icon, count, debuffType, duration, expirationTime, unitCaster, canPurge, consolidate, spellId = UnitBuff(self.unitId, i);
		if (name == nil) then
			break;
		end
		--print("name " .. name .. ", spellId " .. spellId);
		if (spellId == self.stealthSpellId) then
			hasStealth = true;
			break;
		end
		-- continue
		i = i + 1;
	end
	if (hasStealth) then
		self:changeCombatDataTracking(true);
	else
		-- recheck after one tick if no combat data, sometimes it's not yet collected
		if (canRecheck and self.combatDataTracking and (#self.lastEventsData == 0 or #self.lastBrokeData == 0 or math.abs(self.lastEventsData[1][1] - self.lastBrokeData[1]) >= 0.5)) then
			trackingHelper:addEventListener(DHUDDataTrackerHelperEvent.EVENT_UPDATE_FREQUENT, self, self.onTickRecheckStealth);
			return;
		end
		self:changeCombatDataTracking(false);
	end
end

-- tick passed since UNIT_AURA update, and can check for additional combat events
function DHUDSelfDeStealthTracker:onTickRecheckStealth()
	trackingHelper:removeEventListener(DHUDDataTrackerHelperEvent.EVENT_UPDATE_FREQUENT, self, self.onTickRecheckStealth);
	print("Delayed stealth recheck");
	self:checkHasStealth(false);
end

-- recheck stealth spell id, it changes based on talents
function DHUDSelfDeStealthTracker:recheckStealthSpellId()
	if (trackingHelper.playerClass == "DRUID") then
		self.stealthSpellId = 5215;
	else
		local talentID, name, texture, selected, available, spellID, unknown, row, column, known, grantedByAura = GetTalentInfo(2, 2, GetActiveSpecGroup());
		--print("TalentInfo " .. MCTableToString({talentID, name, texture, selected, available, spellID, unknown, row, column, known, grantedByAura}));
		if (selected) then
			self.stealthSpellId = 115191;
		else
			self.stealthSpellId = 1784;
		end
	end
	--print("Stealth spellId to track " .. self.stealthSpellId);
end

--- Start tracking data
function DHUDSelfDeStealthTracker:startTracking()
	-- listen to combat game events
	self.eventsFrame:RegisterEvent("UNIT_AURA");
	self.eventsFrame:RegisterEvent("PLAYER_TALENT_UPDATE");
end

--- Stop tracking data
function DHUDSelfDeStealthTracker:stopTracking()
	-- stop listen to combat game events
	self.eventsFrame:UnregisterEvent("UNIT_AURA");
	self.eventsFrame:UnregisterEvent("PLAYER_TALENT_UPDATE");
end

--- Update all data for current unitId
function DHUDSelfDeStealthTracker:updateData()
	self:recheckStealthSpellId();
	self:checkHasStealth(false);
end
