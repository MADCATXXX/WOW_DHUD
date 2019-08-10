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

---------------------------------------
-- Unit guardians tracker base class --
---------------------------------------

--- Class to track unit guardians like totems, ghouls and mushrooms
DHUDGuardiansTracker = MCCreateSubClass(DHUDTimersTracker, {
	-- mask for the type, that specifies that guardian was activated manually
	TIMER_TYPE_MASK_ACTIVE			= 1,
	-- mask for the type, that specifies that guardian was activated automatically, e.g. passive earth totem
	TIMER_TYPE_MASK_PASSIVE			= 2,
	-- cooldown of deathknight runes
	SHAMAN_PASSIVE_TOTEMS_DURATION	= 300,
	-- maximum time on saved alternative guardian when other guardians are destroyed
	SAVED_ALTERNATIVE_GUARDIAN_ISLAST_MAX_TIME = 15,
	-- last died guardian
	lastDiedGuardian				= nil,
	-- last died guardian time
	lastDiedGuardianTime			= 0,
	-- last summonned guardian
	lastSummonedGuardian			= nil,
	-- last died guardian time
	lastSummonedGuardianTime		= 0,
})

--- Create new unit guardians tracker, unitId should be specified after constructor
function DHUDGuardiansTracker:new()
	local o = self:defconstructor();
	o:constructor();
	return o;
end

--- Initialize cooldowns tracking
function DHUDGuardiansTracker:init()
	local tracker = self;
	-- process unit guardians change event
	function self.eventsFrame:PLAYER_TOTEM_UPDATE()
		tracker:updateGuardians();
	end
end

--- Time passed, update all timers
function DHUDGuardiansTracker:onUpdateTime()
	-- call super
	DHUDTimersTracker.onUpdateTime(self);
	-- nothing to update?
	if (#self.timers == 0) then
		return;
	end
	-- update guardians when last saved guardian timed out
	if (self:containsTimerWithNegativeDuration(1)) then
		self:updateGuardians();
	end
end

--- Update guardians info
function DHUDGuardiansTracker:updateGuardians()
	local timerMs = trackingHelper.timerMs;
	-- create variables
	local haveTotem, name, startTime, duration, icon;
	local timer;
	-- check class specific things
	local durationPassive = 0;
	local canHaveTwoAlternativeGuardians = false;
	if (trackingHelper.playerClass == "SHAMAN") then
		durationPassive = self.SHAMAN_PASSIVE_TOTEMS_DURATION;
		canHaveTwoAlternativeGuardians = false; -- select(2, GetTalentRowSelectionInfo(3)) == 8; -- TotemicPersistance
	end
	-- iterate
	self:findSourceTimersBegin(0);
	-- iterate
	for i = 1, 4, 1 do
		-- get info
		haveTotem, name, startTime, duration, icon = GetTotemInfo(i);
		-- get timer
		timer = self:findTimerByIdOnly(i, false);
		-- check guardian existance
		if (timer ~= nil) then
			if (not haveTotem) then
				self.lastDiedGuardian = timer;
				self.lastDiedGuardianTime = timerMs;
				timer[10] = false;
			end
		else
			if (haveTotem) then
				self.lastSummonedGuardian = timer;
				self.lastSummonedGuardianTime = timerMs;
			end
		end
		-- change info about guardian
		if (haveTotem == true) then
			timer = timer or self:findTimerByIdOnly(i, true);
			-- fill timer info, { type, timeLeft, duration, id, tooltipId, name, stacks, texture, exists, iterating, sortOrder }
			timer[1] = (duration ~= durationPassive) and self.TIMER_TYPE_MASK_ACTIVE or self.TIMER_TYPE_MASK_PASSIVE; -- type
			timer[2] = startTime + duration - timerMs; -- timeLeft
			timer[3] = duration; -- duration
			timer[4] = i; -- id
			timer[5] = i; -- tooltipId
			timer[6] = name; -- name
			timer[7] = 0; -- stacks
			timer[8] = icon; -- texture
		end
	end
	self:findSourceTimersEnd(0);
	-- save number of guardians
	local numGuardians = self.sourceInfo[2];
	-- check double alternative guardian
	self:findSourceTimersBegin(1);
	if (canHaveTwoAlternativeGuardians) then
		timer = self:findTimerByIdOnly(5, false);
		--print("self.lastDiedGuardianTime " .. self.lastDiedGuardianTime .. ", self.lastSummonedGuardianTime " .. self.lastSummonedGuardianTime);
		-- check if resummoned another totem
		if ((self.lastSummonedGuardianTime - self.lastDiedGuardianTime) >= 0.0 and (self.lastSummonedGuardianTime - self.lastDiedGuardianTime) <= 1.0 and self.lastDiedGuardian ~= nil and self.lastDiedGuardian[4] ~= 1) then
			timer = timer or self:findTimerByIdOnly(5, true);
			-- fill timer info, { type, timeLeft, duration, id, tooltipId, name, stacks, texture, exists, iterating, sortOrder }
			timer[1] = self.lastDiedGuardian[1]; -- type
			timer[2] = self.lastDiedGuardian[2]; -- timeLeft
			timer[3] = self.lastDiedGuardian[3]; -- duration
			timer[4] = 5; -- id
			timer[5] = self.lastDiedGuardian[5]; -- tooltipId
			timer[6] = self.lastDiedGuardian[6]; -- name
			timer[7] = self.lastDiedGuardian[7]; -- stacks
			timer[8] = self.lastDiedGuardian[8]; -- texture
			--print("alternative guardian is " .. MCTableToString(timer[6]));
			-- clear saved info
			self.lastDiedGuardian = nil;
			self.lastDiedGuardianTime = 0;
			self.lastSummonedGuardian = nil;
			self.lastSummonedGuardianTime = 0;
		else
			-- delete existing timer if timed out or if it's the last guardian with long time
			if (timer ~= nil and (timer[2] <= 0 or (numGuardians == 0 and timer[2] > self.SAVED_ALTERNATIVE_GUARDIAN_ISLAST_MAX_TIME))) then
				timer[10] = false;
			end
		end
	end
	self:findSourceTimersEnd(1);
	-- updateTimers for other source groups
	self:forceUpdateTimers();
	-- dispatch event
	self:processDataChanged();
end

--- Update all data for current unitId
function DHUDGuardiansTracker:updateData()
	self:updateGuardians();
end

--- Start tracking data
function DHUDGuardiansTracker:startTracking()
	-- listen to game events
	self.eventsFrame:RegisterEvent("PLAYER_TOTEM_UPDATE");
	-- call super
	DHUDTimersTracker.startTracking(self);
end

--- Stop tracking data
function DHUDGuardiansTracker:stopTracking()
	-- stop listening to game events
	self.eventsFrame:UnregisterEvent("PLAYER_TOTEM_UPDATE");
	-- call super
	DHUDTimersTracker.stopTracking(self);
end
