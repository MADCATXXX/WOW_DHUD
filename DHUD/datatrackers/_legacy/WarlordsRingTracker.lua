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

-----------------------------------------------------
-- Warlords of Draenor 6.2 Legendary Ring Tracking --
-----------------------------------------------------
DHUDWarlordsLegendaryRingTracker = MCCreateSubClass(DHUDCustomTimerTracker, {
	-- ids of the ring items that enable tracking to ring effects map (damage - strength (Thorasus), damage - intellect (Nithramus), damage - agility (Maalus), tank (Sanctus), heal (Etheralus))
	RING_ITEM_TO_SPELL_IDS = { ["124634"] = 187614, ["124635"] = 187611, ["124636"] = 187615, ["124637"] = 187613, ["124638"] = 187612 },
	-- current ring spell id, that is tied to ring item id, 0 - if not equipped
	currentRingSpellId = 0,
	-- time at which buff appeared (in order to update time left)
	buffAppearTime = 0,
})
		
--- Create new legendary ring tracker
function DHUDWarlordsLegendaryRingTracker:new()
	local o = self:defconstructor();
	o:constructor();
	return o;
end
		
--- Initialize legendary ring tracking
function DHUDWarlordsLegendaryRingTracker:init()
	local tracker = self;
	-- create combat event frame
	self.combatEventsFrame = MCCreateBlizzCombatEventFrame();
	-- update vars
	self.timerIdsToUpdate = self.RING_EFFECT_SPELL_IDS[0];
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
	self:attachToTimersTrackerIfAllowed(DHUDDataTrackers.ALL.selfAuras, 0);
end

--- Update timer with custom data
-- @param timer timer to be updated { type, timeLeft, duration, id, tooltipId, name, stacks, texture, exists, iterating, sortOrder, grouped, groupData }
-- @return default timer
function DHUDWarlordsLegendaryRingTracker:updateTimer(timer)
	-- get duration
	local duration = timer[3];
	-- check if duration is set (ring used by ourselves)
	if (duration <= 0) then
		return; -- no update is required
	end;
	-- calculate timeleft
	local timerMs = trackingHelper.timerMs;
	local timeDiff = timerMs - self.buffAppearTime;
	-- check if buff is new or existing one
	if (timeDiff > 30) then
		self.buffAppearTime = timerMs;
		timeDiff = 0;
	end
	-- update duration
	timer[3] = 15;
	-- update timeLeft
	timer[2] = 15 - timeDiff;
	-- update stacksCount with user that initiated Ring (read tooltip?)
	timer[7] = "";
end
		
--- process sinister damage and absorb events
function DHUDWarlordsLegendaryRingTracker:processSinisterDamageAndAbsorb()
	local timerMs = trackingHelper.timerMs;
	if (timerMs - self.lastProcessedCombatEventTime > 0.75) then
		--print("timeDiff " .. (timerMs - self.lastProcessedCombatEventTime));
		self.lastProcessedCombatEventTime = timerMs;
		self.stacks = self.stacks + 1;
		self:updateBanditsGuile();
	end
end
		
--- update bandits guile state
function DHUDWarlordsLegendaryRingTracker:updateBanditsGuile()
	self:processDataChanged();
end

--- Check if this tracker data is exists
function DHUDWarlordsLegendaryRingTracker:checkIsExists()
	if (not DHUDCustomTimerTracker.checkIsExists(self)) then -- call super
		return false;
	end
	return (currentRingSpellId ~= 0); -- ring not equipped
end

--- Start tracking data
function DHUDWarlordsLegendaryRingTracker:startTracking()
	--print("banditsGuile start");
	--self.combatEventsFrame:RegisterEvent("SPELL_DAMAGE");
	--self.combatEventsFrame:RegisterEvent("SPELL_ABSORBED");
end

--- Stop tracking data
function DHUDWarlordsLegendaryRingTracker:stopTracking()
	--print("banditsGuile stop");
	--self.combatEventsFrame:UnregisterEvent("SPELL_DAMAGE");
	--self.combatEventsFrame:UnregisterEvent("SPELL_ABSORBED");
end

--- Update all data for current unitId
function DHUDWarlordsLegendaryRingTracker:updateData()
	self:updateBanditsGuile();
end