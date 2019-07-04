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
-- tracker helper
local trackingHelper = DHUDDataTrackingHelper;

-----------
-- Runes --
-----------
--- Class to track players runes
DHUDRunesTracker = MCCreateSubClass(DHUDPowerTracker, {
	-- table with runes information, each value is table with following data: { runeType, runeCooldown }
	runes				= { },
	-- time at which rune cooldowns was updated
	timeUpdatedAt		= 0,
	-- rune type is blood
	RUNETYPE_BLOOD		= 1,
	-- rune type is unholy
	RUNETYPE_CHROMATIC	= 2,
	-- rune type is frost
	RUNETYPE_FROST		= 3,
	-- rune type is death
	RUNETYPE_DEATH		= 4,
})

--- Create new runes tracker for player and vehicle
function DHUDRunesTracker:new()
	local o = self:defconstructor();
	o:constructor();
	return o;
end

--- Rune tracker constructor
function DHUDRunesTracker:constructor()
	-- fill rune table with subtables
	for i = 1, 6, 1 do
		table.insert(self.runes, { 0, 0 });
	end
	-- custom events
	self.eventDataTimersChanged = DHUDDataTrackerEvent:new(DHUDDataTrackerEvent.EVENT_DATA_TIMERS_UPDATED, self);
	-- call super constructor
	DHUDPowerTracker.constructor(self);
end

--- Initialize runes tracking
function DHUDRunesTracker:init()
	local tracker = self;
	-- process rune enabled state
	function self.eventsFrame:RUNE_POWER_UPDATE(rune, enabled)
		tracker:updateRuneCooldowns();
	end
	-- process rune type change
	function self.eventsFrame:PLAYER_SPECIALIZATION_CHANGED(unitId)
		if (unitId ~= "player") then
			return;
		end
		tracker:updateRuneTypes();
	end
	-- init unit ids
	self:initPlayerNotInVehicleOrNoneUnitId();
end

--- Update rune types through API
function DHUDRunesTracker:updateRuneTypes()
	-- create vars
	local spec = GetSpecialization();
	local runeType; -- 1 : RUNETYPE_BLOOD, 2 : RUNETYPE_CHROMATIC, 3 : RUNETYPE_FROST, 4 : RUNETYPE_DEATH
	runeType = spec == 1 and 1 or (spec == 2 and 3 or 2);
	-- update runes
	for i = 1, 6, 1 do
		--runeType = 1; -- GetRuneType(i);
		local rune = self.runes[i];
		rune[1] = runeType;
	end
	-- dispatch event
	self:processDataChanged();
end

--- Update rune cooldowns through API
function DHUDRunesTracker:updateRuneCooldowns()
	local timerMs = trackingHelper.timerMs;
	-- create vars
	local runesReady = 0;
	local start, duration, runeReady;
	-- update runes
	for i = 1, 6, 1 do
		start, duration, runeReady = GetRuneCooldown(i);
		local rune = self.runes[i];
		rune[2] = start + duration - timerMs;
		-- update if rune is ready
		runesReady = runesReady + (runeReady and 1 or 0);
	end
	-- update timeUpdateAt variable
	self.timeUpdatedAt = timerMs;
	-- check if all runes are ready
	self:setIsRegenerating(runesReady ~= 6);
	-- dispatch event
	self:processDataChanged();
end

--- Update rune cooldowns using onUpdate event
function DHUDRunesTracker:onUpdateTime()
	-- no runes are regenerating, nothing to do
	if (not self.isRegenerating) then
		return;
	end
	-- check if updated recently
	local timerMs = trackingHelper.timerMs;
	local diff = timerMs - self.timeUpdatedAt;
	if (diff <= 0) then
		return;
	end
	-- update runes
	for i = 1, 6, 1 do
		local rune = self.runes[i];
		if (rune[2] > 0) then
			rune[2] = rune[2] - diff;
		end
	end
	-- update timeUpdateAt variable
	self.timeUpdatedAt = timerMs;
	-- dispatch time update
	self:dispatchEvent(self.eventDataTimersChanged);
end

--- Start tracking data
function DHUDRunesTracker:startTracking()
	-- listen to game events
	self.eventsFrame:RegisterEvent("RUNE_POWER_UPDATE");
	self.eventsFrame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED");
	--self.eventsFrame:RegisterEvent("RUNE_TYPE_UPDATE");
	trackingHelper:addEventListener(DHUDDataTrackerHelperEvent.EVENT_UPDATE, self, self.onUpdateTime);
end

--- Stop tracking data
function DHUDRunesTracker:stopTracking()
	-- stop listening to game events
	self.eventsFrame:UnregisterEvent("RUNE_POWER_UPDATE");
	self.eventsFrame:UnregisterEvent("PLAYER_SPECIALIZATION_CHANGED");
	--self.eventsFrame:UnregisterEvent("RUNE_TYPE_UPDATE");
	trackingHelper:removeEventListener(DHUDDataTrackerHelperEvent.EVENT_UPDATE, self, self.onUpdateTime);
end

--- Update all data for current unitId
function DHUDRunesTracker:updateData()
	self:updateRuneTypes();
	self:updateRuneCooldowns();
end