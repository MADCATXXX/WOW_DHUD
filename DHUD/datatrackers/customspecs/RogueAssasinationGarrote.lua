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

----------------------------------
-- Rogue Stealth Garrote Detect --
----------------------------------
DHUDRogueAssasinationGarroteTracker = MCCreateSubClass(DHUDCustomTimerTracker, {
	-- ids of the garrote spell progress
	GARROTE_PROGRESS_SPELL_IDS = { 703, 360830 },
	-- id of the garrote spell
	GARROTE_SPELL_ID = 703,
	-- ids that define application of garrote from stealth
	STEALTH_APPLICATION_SPELL_IDS = { 392403, 392401 }, -- garrote buff is always present, if removed use stealthIds 1784, 115191
	-- combat events frame to listen for combat events
	combatEventsFrame = nil,
	-- table with GUIDS for which spell is improved
	imrovedGUIDS = nil,
	-- maximum amount of GUIDs to track (3 in stealth + 3 in vanish)
	MAX_TRACKED_GUIDS = 6,
})

--- Create new runes tracker for player and vehicle
function DHUDRogueAssasinationGarroteTracker:new()
	local o = self:defconstructor();
	o:constructor();
	return o;
end

--- Initialize bandits guile tracking
function DHUDRogueAssasinationGarroteTracker:init()
	local tracker = self;
	-- create combat event frame and guids
	self.combatEventsFrame = MCCreateBlizzCombatEventFrame();
	self.imrovedGUIDS = {};
	for i = 1, self.MAX_TRACKED_GUIDS do
		table.insert(self.imrovedGUIDS, "");
	end
	-- update vars
	self.timerIdsToUpdate = self.GARROTE_PROGRESS_SPELL_IDS;
	self.trackingMultiple = true;
	-- process units aura events
	function self.combatEventsFrame:SPELL_AURA_APPLIED(timestamp, hideCaster, sourceGUID, ...)
		if (sourceGUID ~= trackingHelper.guids[tracker.unitId]) then
			return;
		end
		local spellId = select(8, ...);
		if (tracker.GARROTE_SPELL_ID ~= spellId) then
			return;
		end
		--print("SPELL_AURA_APPLIED " .. MCTableToString({ ... }));
		local targetGUID = select(4, ...);
		tracker:processGarroteAppliedToGUID(targetGUID);
	end
	function self.combatEventsFrame:SPELL_AURA_REFRESH(timestamp, hideCaster, sourceGUID, ...)
		if (sourceGUID ~= trackingHelper.guids[tracker.unitId]) then
			return;
		end
		local spellId = select(8, ...);
		if (tracker.GARROTE_SPELL_ID ~= spellId) then
			return;
		end
		--print("SPELL_AURA_REFRESH " .. MCTableToString({ ... }));
		local targetGUID = select(4, ...);
		tracker:processGarroteAppliedToGUID(targetGUID);
	end
	function self.combatEventsFrame:SPELL_AURA_REMOVED(timestamp, hideCaster, sourceGUID, ...)
		if (sourceGUID ~= trackingHelper.guids[tracker.unitId]) then
			return;
		end
		local spellId = select(8, ...);
		if (tracker.GARROTE_SPELL_ID ~= spellId) then
			return;
		end
		--print("SPELL_AURA_REMOVED " .. MCTableToString({ ... }));
		local targetGUID = select(4, ...);
		tracker:processGarroteRemovedFromGUID(targetGUID);
	end
	-- init unit ids
	self:initPlayerNotInVehicleOrNoneUnitId();
	self:initPlayerSpecsOnly(1);
	self:attachToTimersTrackerIfAllowed(DHUDDataTrackers.ALL.targetAuras, DHUDAurasTracker.TIMER_SOURCE_GROUP_DEBUFF);
end

--- Update timer with custom data
-- @param timer timer to be updated { type, timeLeft, duration, id, tooltipId, name, stacks, texture, exists, iterating, sortOrder, grouped, groupData }
-- @return default timer
function DHUDRogueAssasinationGarroteTracker:updateTimer(timer)
	--print("update " .. MCTableToString(timer));
	local mask = DHUDAurasTracker.TIMER_TYPE_MASK_IS_CAST_BY_PLAYER; -- DHUDAurasTracker.TIMER_TYPE_MASK_DEBUFF + 
	if (bit.band(timer[1], mask) ~= mask) then
		return;
	end
	-- check if improved
	local targetGUID = trackingHelper.guids["target"];
	local stacks = self:isGarroteDebuffImproved(targetGUID) and 2 or 1;
	-- update stacks
	timer[7] = stacks;
end

--- Check if target GUID has improved garrote debuff
-- @param targetGUID guid to be checked if improved garrote was applied to it
-- @return true if target has improved garrote and UI should reflect it
function DHUDRogueAssasinationGarroteTracker:isGarroteDebuffImproved(targetGUID)
	for i = 1, self.MAX_TRACKED_GUIDS do
		if (self.imrovedGUIDS[i] == targetGUID) then
			return true;
		end
	end
	return false;
end

--- Check if improved garrote buff is available
-- @return true if garrote will be improved
function DHUDRogueAssasinationGarroteTracker:hasImprovedGarroteBuff()
	local selfAuras = DHUDDataTrackers.ALL.selfAuras;
	for i, v in ipairs(self.STEALTH_APPLICATION_SPELL_IDS) do
		local timer = selfAuras:findTimerForPublicRead(v, DHUDAurasTracker.TIMER_SOURCE_GROUP_BUFF);
		if (timer ~= nil) then
			--print("timer found " .. MCTableToString(timer));
			return true;
		end
	end
	return false;
end

--- Process new garrote application to target specified
-- @param guid id of the target to which garrote was applied
function DHUDRogueAssasinationGarroteTracker:processGarroteAppliedToGUID(guid)
	local isImproved = self:hasImprovedGarroteBuff();
	local indexGUID = 0;
	for i = 1, self.MAX_TRACKED_GUIDS do
		if (self.imrovedGUIDS[i] == guid) then
			indexGUID = i;
			break;
		end
	end
	--print("isImproved " .. MCTableToString(isImproved) .. " indexGUID " .. indexGUID);
	if (not isImproved) then
		if (indexGUID > 0) then
			self.imrovedGUIDS[indexGUID] = "";
			self:updateGarroteState();
		end
		return;
	elseif (indexGUID > 0) then
		return;
	end
	for i = 1, self.MAX_TRACKED_GUIDS - 1 do
		self.imrovedGUIDS[i] = self.imrovedGUIDS[i + 1];
	end
	self.imrovedGUIDS[self.MAX_TRACKED_GUIDS] = guid;
	--print("imrovedGUIDS " .. MCTableToString(self.imrovedGUIDS));
	self:updateGarroteState();
end

--- Process garrote was removed from target specified
-- @param guid id of the target from which garrote was removed
function DHUDRogueAssasinationGarroteTracker:processGarroteRemovedFromGUID(guid)
	for i = 1, self.MAX_TRACKED_GUIDS do
		if (self.imrovedGUIDS[i] == guid) then
			self.imrovedGUIDS[i] = "";
			break;
		end
	end
end

--- update garrote state
function DHUDRogueAssasinationGarroteTracker:updateGarroteState()
	self:processDataChanged();
end

--- Start tracking data
function DHUDRogueAssasinationGarroteTracker:startTracking()
	self.combatEventsFrame:RegisterEvent("SPELL_AURA_APPLIED");
	self.combatEventsFrame:RegisterEvent("SPELL_AURA_REFRESH");
	self.combatEventsFrame:RegisterEvent("SPELL_AURA_REMOVED");
end

--- Stop tracking data
function DHUDRogueAssasinationGarroteTracker:stopTracking()
	self.combatEventsFrame:UnregisterEvent("SPELL_AURA_APPLIED");
	self.combatEventsFrame:UnregisterEvent("SPELL_AURA_REFRESH");
	self.combatEventsFrame:UnregisterEvent("SPELL_AURA_REMOVED");
end

--- Update all data for current unitId
function DHUDRogueAssasinationGarroteTracker:updateData()
	self:updateGarroteState();
end
