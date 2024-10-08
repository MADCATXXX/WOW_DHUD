--[[-----------------------------------------------------------------------------------
 Original Drathals HUD (c) 2006 by Markus Inger / Drathal / Silberklinge / Silbersegen
 DHUD for WotLK and later expansions (c) 2013 by MADCAT (EU-Гордунни, Мадкат)
 (http://eu.battle.net/wow/en/character/Гордунни/Мадкат/advanced)
---------------------------------------------------------------------------------------
 This file contains functions and classes to track data about unit spell cast related
 information
 @author: MADCAT
-----------------------------------------------------------------------------------]]--

-- antitaint local "_" var
local _;
-- tracker helper
local trackingHelper = DHUDDataTrackingHelper;

----------------------------
-- Unit spellcast tracker --
----------------------------
--- Base class to track unit spell castings, spells channeling and delays
DHUDSpellCastTracker = MCCreateSubClass(DHUDDataTracker, {
	-- defines if current unit has casted something or not (updated after unit change)
	hasCasted			= false,
	-- defines if current unit is casting or channgeling something or not
	isCasting			= false,
	-- defines if current unit is having global cooldown
	isGcd				= false,
	-- defines if current spell is channeling, 0 = usual cast, 1 = channeling/gcd tracker, 2 = empowered channeling
	isChannelSpell		= 0,
	-- defines if current spell is interruptable, e.g. no lock
	isInterruptible		= true,
	-- defines if player interrupt is on cd or not, tracked only for non player instances, data change event is not thrown for this variable
	isInterruptOnCd		= false,
	-- defines if current spell is interruptable by player, e.g. it's not locked and player kick is not on cooldown (or cooldown will expire during spell cast)
	canBeInterruptedByPlayer = true,
	-- time at which the spell casting was started, in seconds
	timeStart			= 0,
	-- amount of time the spell is casting or amount of time for channel to end, in seconds, this value may be less than zero as reported by game!
	timeProgress		= 0,
	-- total amount of time this spell will be casted, in seconds
	timeTotal			= 0,
	-- number of stages during cast (for evoker charged spells), isChannelSpell == 2
	numStages			= 0,
	-- total delay of the cast in progress, in miliseconds
	delay				= 0,
	-- defines if previous spell cast was interrupted by someone
	finishState			= 0,
	-- defines interrupt type if spell was interrupted during cast
	interruptState		= 0,
	-- guid of the player that interrupted spell casting
	interruptedByGuid	= "",
	-- name of the player that interrupted spell casting
	interruptedBy		= "",
	-- time at which spell was interrupted in combat log
	interruptedTime		= 0,
	-- time at which this tracker was updated
	timeUpdatedAt		= 0,
	-- time at which gcd was updated
	timeGcdUpdatedAt	= 0,
	-- name of the spell being casted
	spellName			= "",
	-- path to the texture associated with spell
	spellTexture		= "",
	-- array with stage durations or nil if spell is not empowered
	stageDurations		= nil,
	-- spell is being cast right now
	SPELL_FINISH_STATE_IS_CASTING = -1,
	-- no spells were cast recently
	SPELL_FINISH_STATE_NOT_CASTING = 0,
	-- spell was interrupted by something, check interruptState variable for more info
	SPELL_FINISH_STATE_INTERRUPTED = 1,
	-- spell was successfully casted
	SPELL_FINISH_STATE_SUCCEDED = 2,
	-- spell was cancelled by moving
	SPELL_INTERRUPT_STATE_CANCELED = 0,
	-- spell was interrupted using kick or similiar ability
	SPELL_INTERRUPT_STATE_KICKED = 1,
	-- spell was interrupted by player using kick or similiar ability
	SPELL_INTERRUPT_STATE_KICKED_BY_PLAYER = 2,
	-- combat event frame to listen to combat events
	combatEventsFrame				= nil,
	-- cooldowns tracker to track gcds
	cooldownsTracker				= nil,
	-- interrupt cooldown tracker to track player ability to interrupt spells
	interruptCdTracker				= nil,
})

--- Create new spell cast tracker, unitId should be specified after constructor
function DHUDSpellCastTracker:new()
	local o = self:defconstructor();
	o:constructor();
	return o;
end

--- Constructor of spell cast tracker
function DHUDSpellCastTracker:constructor()
	-- create combat event frame
	self.combatEventsFrame = MCCreateBlizzCombatEventFrame();
	-- custom events
	self.eventDataTimersChanged = DHUDDataTrackerEvent:new(DHUDDataTrackerEvent.EVENT_DATA_TIMERS_UPDATED, self);
	-- call super constructor
	DHUDDataTracker.constructor(self);
end

--- Initialize health-points tracking
function DHUDSpellCastTracker:init()
	local tracker = self;
	-- process unit cast start
	function self.eventsFrame:UNIT_SPELLCAST_START(unitId)
		if (tracker.unitId ~= unitId) then
			return;
		end
		--print("UNIT_SPELLCAST_START");
		tracker:updateSpellCastStart();
	end
	-- process unit cast stop
	function self.eventsFrame:UNIT_SPELLCAST_STOP(unitId)
		if (tracker.unitId ~= unitId) then
			return;
		end
		--print("UNIT_SPELLCAST_STOP");
		tracker:updateSpellCastStop();
	end
	-- process unit cast interrupted
	function self.eventsFrame:UNIT_SPELLCAST_INTERRUPTED(unitId)
		if (tracker.unitId ~= unitId) then
			return;
		end
		--print("UNIT_SPELLCAST_INTERRUPTED");
		tracker:updateSpellCastInterrupt();
	end
	-- process unit cast interrupted
	function self.eventsFrame:UNIT_SPELLCAST_SUCCEEDED(unitId)
		if (tracker.unitId ~= unitId) then
			return;
		end
		--print("UNIT_SPELLCAST_SUCCEEDED");
		tracker:updateSpellCastStopReason(tracker.SPELL_FINISH_STATE_SUCCEDED);
	end
	-- process unit cast failed (channel on cooldown, etc., the cast was not even started)
	function self.eventsFrame:UNIT_SPELLCAST_FAILED(unitId)
		if (tracker.unitId ~= unitId) then
			return;
		end
		--print("UNIT_SPELLCAST_FAILED");
		tracker:updateSpellCastStop();
	end
	-- process unit cast interruptible
	function self.eventsFrame:UNIT_SPELLCAST_INTERRUPTIBLE(unitId)
		if (tracker.unitId ~= unitId) then
			return;
		end
		tracker:updateSpellInfoIsInterruptible(true);
	end
	-- process unit cast not interruptible
	function self.eventsFrame:UNIT_SPELLCAST_NOT_INTERRUPTIBLE(unitId)
		if (tracker.unitId ~= unitId) then
			return;
		end
		tracker:updateSpellInfoIsInterruptible(false);
	end
	-- process unit cast delay
	function self.eventsFrame:UNIT_SPELLCAST_DELAYED(unitId)
		if (tracker.unitId ~= unitId) then
			return;
		end
		tracker:updateSpellCastDelay();
	end
	-- process unit channel start
	function self.eventsFrame:UNIT_SPELLCAST_CHANNEL_START(unitId)
		if (tracker.unitId ~= unitId) then
			return;
		end
		tracker:updateSpellChannelStart();
	end
	-- process unit channel stop, separate event will be fired for spell cast interrupt, this event is only for channel stop (as some spells can be casted during channel)
	function self.eventsFrame:UNIT_SPELLCAST_CHANNEL_STOP(unitId)
		if (tracker.unitId ~= unitId) then
			return;
		end
		tracker:updateSpellCastStop();
	end
	-- process unit channel update
	function self.eventsFrame:UNIT_SPELLCAST_CHANNEL_UPDATE(unitId)
		if (tracker.unitId ~= unitId) then
			return;
		end
		tracker:updateSpellChannelDelay();
	end
	-- process unit empower start
	function self.eventsFrame:UNIT_SPELLCAST_EMPOWER_START(unitId)
		if (tracker.unitId ~= unitId) then
			return;
		end
		tracker:updateSpellChannelStart();
	end
	-- process unit empower stop, separate event will be fired for spell cast interrupt, this event is only for empower stop (as some spells can be casted during channel)
	function self.eventsFrame:UNIT_SPELLCAST_EMPOWER_STOP(unitId)
		if (tracker.unitId ~= unitId) then
			return;
		end
		tracker:updateSpellCastStop();
	end
	-- process unit empower update
	function self.eventsFrame:UNIT_SPELLCAST_EMPOWER_UPDATE(unitId)
		if (tracker.unitId ~= unitId) then
			return;
		end
		tracker:updateSpellChannelDelay();
	end
	-- process combat spell interrupt event
	function self.combatEventsFrame:SPELL_INTERRUPT(timestamp, hideCaster, sourceGUID, sourceName, sourceFlags, sourceFlags2, destGUID, destName, destFlags, destFlags2, spellId, spellName, spellSchool, extraSpellID, extraSpellName, extraSchool)
		if (destGUID ~= trackingHelper.guids[tracker.unitId]) then
			return;
		end
		tracker.interruptedByGuid = sourceGUID;
		tracker.interruptedBy = sourceName;
		tracker.interruptedTime = trackingHelper.timerMs;
		tracker:updateSpellCastInterrupt();
	end
end

-- process gcd update
function DHUDSpellCastTracker:updateGcd(e)
	if (self.cooldownsTracker == nil) then
		return;
	end
	-- do not updated gcd when casting
	if (self.isCasting) then
		self.isGcd = false;
		return;
	end
	local timeLeft = self.cooldownsTracker.gcdTimeLeft;
	if (timeLeft > 0) then
		self.timeProgress = timeLeft;
		self.timeTotal = self.cooldownsTracker.gcdTimeTotal;
		self.timeUpdatedAt = self.cooldownsTracker.timeUpdatedAt;
		self.delay = 0;
		self.isChannelSpell = 1;
		self.isGcd = true;
	else
		if (self.isGcd) then
			self.finishState = SPELL_FINISH_STATE_NOT_CASTING;
		end
		self.isGcd = false;
	end
	-- process data change
	self:processDataChanged();
end

-- process interrupt cooldown change
function DHUDSpellCastTracker:updateInterruptCd(e)
	local isInterruptOnCd = false;
	if (self.interruptCdTracker ~= nil) then
		isInterruptOnCd = self.interruptCdTracker.isInterruptOnCd;
	end
	self.isInterruptOnCd = isInterruptOnCd;
	self:updateCanInterruptSpell();
end

--- Update possibility to interrupt enemy spell
function DHUDSpellCastTracker:updateCanInterruptSpell()
	local canBeInterruptedByPlayer = self.isCasting and self.isInterruptible;
	if (canBeInterruptedByPlayer and self.isInterruptOnCd) then
		local cdEndTime = trackingHelper.timerMs + self.interruptCdTracker:getInterruptCooldown();
		local spellEndTime = 0;
		if (self.isChannelSpell == 0) then -- usual cast
			spellEndTime = self.timeStart + self.timeTotal + self.delay;
		elseif (self.isChannelSpell == 1) then -- channel
			spellEndTime = self.timeStart + self.timeTotal - self.delay;
		elseif (self.isChannelSpell == 2) then -- evoker charged spell
			spellEndTime = self.timeStart + self.stageDurations[1] + self.delay;
		end
		canBeInterruptedByPlayer = (cdEndTime - spellEndTime) <= -0.2;
		--print("onCd, cdEnd " .. cdEndTime .. " spell end " .. spellEndTime);
	end
	--print("name " .. self.spellName .. " can be interrupted " .. MCTableToString(canBeInterruptedByPlayer) .. " interrupt cd " .. MCTableToString(self.isInterruptOnCd));
	if (self.canBeInterruptedByPlayer ~= canBeInterruptedByPlayer) then
		self.canBeInterruptedByPlayer = canBeInterruptedByPlayer;
		self:processDataChanged();
	end
end

--- Game time updated, update spell cast progress, updated every 100 ms, animation should use it's own timer
function DHUDSpellCastTracker:onUpdateTime()
	if (self.isCasting == false and self.isGcd == false) then
		return;
	end
	local timerMs = trackingHelper.timerMs;
	local diff = timerMs - self.timeUpdatedAt;
	if (diff <= 0) then
		return;
	end
	-- update timer
	if (self.isChannelSpell == 1) then
		self.timeProgress = self.timeProgress - diff;
	else
		self.timeProgress = self.timeProgress + diff;
	end
	-- update timeUpdated var
	self.timeUpdatedAt = timerMs;
	-- update gcd
	if (self.isGcd and self.timeProgress <= 0) then
		self.finishState = SPELL_FINISH_STATE_NOT_CASTING;
		self.isGcd = false;
		self:processDataChanged();
	end
	-- dispatch event
	self:dispatchEvent(self.eventDataTimersChanged);
end

--- Get spell cast progress, updating value according to current game time
function DHUDSpellCastTracker:getTimeProgress()
	local timerMs = trackingHelper.timerMs;
	local diff = timerMs - self.timeUpdatedAt;
	local progress;
	if (self.isChannelSpell == 1) then
		progress = self.timeProgress - diff;
	else
		progress = self.timeProgress + diff;
	end
	--print("progress " .. progress);
	return progress;
end

--- update spell cast start
function DHUDSpellCastTracker:updateSpellCastStart()
	-- update boolean variables with casting info
	self.hasCasted = true;
	self.isCasting = true;
	self.isChannelSpell = 0;
	self:setIsRegenerating(true);
	self.finishState = self.SPELL_FINISH_STATE_IS_CASTING;
	-- update spell cast info
	local timerMs = trackingHelper.timerMs;
	local name, text, texture, startTime, endTime, isTradeSkill, castID, notInterruptible = UnitCastingInfo(self.unitId);
	if (startTime == nil) then
		self:updateData(); -- not casting anymore (why event about spell cast start fired?), update
		return;
	end
	self.isInterruptible = not notInterruptible;
	self.spellName = name;
	self.spellTexture = texture;
	self.timeStart = startTime / 1000;
	self.timeTotal = (endTime - startTime) / 1000;
	self.timeProgress = timerMs - startTime / 1000;
	self.delay = 0;
	self.timeUpdatedAt = timerMs;
	self:updateCanInterruptSpell();
	--print("startTime " .. startTime .. ", endTime " .. endTime .. ", timerMs " .. timerMs);
	-- process data change
	self:processDataChanged();
end

--- update spell cast delay
function DHUDSpellCastTracker:updateSpellCastDelay()
	-- update delay
	local timerMs = trackingHelper.timerMs;
	local name, text, texture, startTime, endTime, isTradeSkill, castID, notInterruptible = UnitCastingInfo(self.unitId);
	if (endTime == nil) then
		self:updateData(); -- not casting anymore (why event about delay fired?), update
		return;
	end
	local newTimeTotal = endTime / 1000 - self.timeStart;
	self.delay = newTimeTotal - self.timeTotal;
	self.timeProgress = timerMs - startTime / 1000;
	self.timeUpdatedAt = timerMs;
	self:updateCanInterruptSpell();
	--print("delay startTime " .. startTime .. ", endTime " .. endTime .. ", timerMs " .. timerMs .. ", delay " .. self.delay);
	-- process data change
	self:processDataChanged();
end

--- update spell cast time
function DHUDSpellCastTracker:updateSpellCastTime()
	-- update time
	local timerMs = trackingHelper.timerMs;
	self.timeProgress = timerMs - self.timeStart;
	-- process data change
	self:processDataChanged();
end

--- update spell cast continue
function DHUDSpellCastTracker:updateSpellCastContinue()
	self.isCasting = true;
	self:setIsRegenerating(true);
	-- process data change
	self:processDataChanged();
end

--- update channel cast start
function DHUDSpellCastTracker:updateSpellChannelStart()
	-- update boolean variables with casting info
	self.hasCasted = true;
	self.isCasting = true;
	self.isChannelSpell = 1;
	self:setIsRegenerating(true);
	self.finishState = self.SPELL_FINISH_STATE_IS_CASTING;
	-- update channel cast info
	local timerMs = trackingHelper.timerMs;
	local name, text, texture, startTime, endTime, isTradeSkill, notInterruptible, spellID, _, numStages = UnitChannelInfo(self.unitId);
	if (startTime == nil) then
		self:updateData(); -- not casting anymore (why event about spell cast start fired?), update
		return;
	end
	self.numStages = numStages or 0; -- evoker charged spells
	local isChargeSpell = self.numStages > 0;
	self.isInterruptible = not notInterruptible;
	self.spellName = name;
	self.spellTexture = texture;
	self.timeStart = startTime / 1000;
	if (isChargeSpell) then
		self.isChannelSpell = 2;
		local lastStageDuration = GetUnitEmpowerHoldAtMaxTime(self.unitId);
		endTime = endTime + lastStageDuration;
		self.timeProgress = timerMs - startTime / 1000;
		self.stageDurations = {};
		for i = 1, self.numStages, 1 do
			local stageDuration = GetUnitEmpowerStageDuration(self.unitId, i-1);
			table.insert(self.stageDurations, stageDuration / 1000);
		end
		table.insert(self.stageDurations, lastStageDuration / 1000);
		--self.numStages = self.numStages + 1; -- last is holding stage which is not reported as stage
		--print("durations " .. MCTableToString(self.stageDurations) .. ", stages " .. self.numStages);
	else
		self.timeProgress = endTime / 1000 - timerMs;
		self.stageDurations = nil;
	end
	self.timeTotal = (endTime - startTime) / 1000;
	self.delay = 0;
	self.timeUpdatedAt = timerMs;
	self:updateCanInterruptSpell();
	-- process data change
	self:processDataChanged();
end

--- update spell channel delay
function DHUDSpellCastTracker:updateSpellChannelDelay()
	-- update delay
	local timerMs = trackingHelper.timerMs;
	local name, text, texture, startTime, endTime, isTradeSkill, notInterruptible, spellID, _, numStages = UnitChannelInfo(self.unitId);
	if (endTime == nil) then
		self:updateData(); -- not casting anymore (why event about delay fired?), update
		return;
	end
	local newTimeTotal = endTime / 1000 - self.timeStart;
	self.delay = newTimeTotal - self.timeTotal;
	--print("delay is " .. self.delay);
	self.timeProgress = endTime / 1000 - timerMs;
	self.timeUpdatedAt = timerMs;
	self:updateCanInterruptSpell();
	-- process data change
	self:processDataChanged();
end

--- update channel cast time
function DHUDSpellCastTracker:updateSpellChannelTime()
	-- update time
	local timerMs = trackingHelper.timerMs;
	self.timeProgress = self.timeStart + self.timeTotal - self.delay - timerMs;
	-- process data change
	self:processDataChanged();
end

--- update spell channel continue
function DHUDSpellCastTracker:updateSpellChannelContinue()
	self.isCasting = true;
	self:setIsRegenerating(true);
	-- process data change
	self:processDataChanged();
end

--- update spell cast interruptable status
-- @param isInterruptible defines if spell is interruptable
function DHUDSpellCastTracker:updateSpellInfoIsInterruptible(isInterruptible)
	self.isInterruptible = isInterruptible;
	-- process data change
	self:processDataChanged();
end

--- update stopping of spell cast reason
-- @param reason reason spell casting is stopped
function DHUDSpellCastTracker:updateSpellCastStopReason(reason)
	self.finishState = reason;
end

--- update interrupt of spell cast
function DHUDSpellCastTracker:updateSpellCastInterrupt()
	self:updateSpellCastStopReason(self.SPELL_FINISH_STATE_INTERRUPTED);
	-- update interrupt reason
	if (self.interruptedTime == trackingHelper.timerMs) then
		if (self.interruptedByGuid == trackingHelper.guids[trackingHelper.playerCasterUnitId]) then
			self.interruptState = self.SPELL_INTERRUPT_STATE_KICKED_BY_PLAYER;
		else
			self.interruptState = self.SPELL_INTERRUPT_STATE_KICKED;
		end
	else
		self.interruptState = SPELL_INTERRUPT_STATE_CANCELED;
	end
	--print("self.interruptTime " .. self.interruptedTime .. ", trackingHelper.timerMs " .. trackingHelper.timerMs);
	-- process data change
	self:processDataChanged();
end

--- update stopping of spell cast
function DHUDSpellCastTracker:updateSpellCastStop()
	-- update spell cast time
	if (self.isCasting) then
		if (self.isChannelSpell == 1) then
			self:updateSpellChannelTime();
		else
			self:updateSpellCastTime();
		end
	end
	-- update stop info
	self.isCasting = false;
	self.numStages = 0;
	self:setIsRegenerating(false);
	-- update spell info if any
	if (self.finishState ~= self.SPELL_FINISH_STATE_IS_CASTING) then
		if (UnitCastingInfo(self.unitId) ~= nil) then
			self:updateSpellCastStart();
		elseif (UnitChannelInfo(self.unitId) ~= nil) then
			self:updateSpellChannelStart();
		end
	else
		if (UnitCastingInfo(self.unitId) ~= nil) then
			self:updateSpellCastContinue();
		elseif (UnitChannelInfo(self.unitId) ~= nil) then
			self:updateSpellChannelContinue();
		end
	end
	-- update gcd
	self:updateGcd();
	-- process data change
	self:processDataChanged();
end

--- Start tracking data
function DHUDSpellCastTracker:startTracking()
	-- listen to combat game events
	self.combatEventsFrame:RegisterEvent("SPELL_INTERRUPT");
	-- listen to game events
	self.eventsFrame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START");
	self.eventsFrame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP");
	self.eventsFrame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_UPDATE");
	self.eventsFrame:RegisterEvent("UNIT_SPELLCAST_EMPOWER_START");
	self.eventsFrame:RegisterEvent("UNIT_SPELLCAST_EMPOWER_STOP");
	self.eventsFrame:RegisterEvent("UNIT_SPELLCAST_EMPOWER_UPDATE");
	self.eventsFrame:RegisterEvent("UNIT_SPELLCAST_DELAYED");
	self.eventsFrame:RegisterEvent("UNIT_SPELLCAST_FAILED");
	--self.eventsFrame:RegisterEvent("UNIT_SPELLCAST_FAILED_QUIET");
	self.eventsFrame:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED");
	self.eventsFrame:RegisterEvent("UNIT_SPELLCAST_INTERRUPTIBLE");
	self.eventsFrame:RegisterEvent("UNIT_SPELLCAST_NOT_INTERRUPTIBLE");
	--self.eventsFrame:RegisterEvent("UNIT_SPELLCAST_SENT");
	self.eventsFrame:RegisterEvent("UNIT_SPELLCAST_START");
	self.eventsFrame:RegisterEvent("UNIT_SPELLCAST_STOP");
	self.eventsFrame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED");
	trackingHelper:addEventListener(DHUDDataTrackerHelperEvent.EVENT_UPDATE, self, self.onUpdateTime);
	if (self.cooldownsTracker ~= nil and self.trackUnitId == "player") then
		self.cooldownsTracker:addEventListener(DHUDDataTrackerEvent.EVENT_DATA_CHANGED, self, self.updateGcd);
	end
	if (self.interruptCdTracker ~= nil and self.trackUnitId ~= "player") then
		self.interruptCdTracker:addEventListener(DHUDDataTrackerEvent.EVENT_DATA_CHANGED, self, self.updateInterruptCd);
	end
end

--- Stop tracking data
function DHUDSpellCastTracker:stopTracking()
	-- stop listen to combat game events
	self.combatEventsFrame:UnregisterEvent("SPELL_INTERRUPT");
	-- stop listening to game events
	self.eventsFrame:UnregisterEvent("UNIT_SPELLCAST_CHANNEL_START");
	self.eventsFrame:UnregisterEvent("UNIT_SPELLCAST_CHANNEL_STOP");
	self.eventsFrame:UnregisterEvent("UNIT_SPELLCAST_CHANNEL_UPDATE");
	self.eventsFrame:UnregisterEvent("UNIT_SPELLCAST_EMPOWER_START");
	self.eventsFrame:UnregisterEvent("UNIT_SPELLCAST_EMPOWER_STOP");
	self.eventsFrame:UnregisterEvent("UNIT_SPELLCAST_EMPOWER_UPDATE");
	self.eventsFrame:UnregisterEvent("UNIT_SPELLCAST_DELAYED");
	self.eventsFrame:UnregisterEvent("UNIT_SPELLCAST_FAILED");
	--self.eventsFrame:UnregisterEvent("UNIT_SPELLCAST_FAILED_QUIET");
	self.eventsFrame:UnregisterEvent("UNIT_SPELLCAST_INTERRUPTED");
	self.eventsFrame:UnregisterEvent("UNIT_SPELLCAST_INTERRUPTIBLE");
	self.eventsFrame:UnregisterEvent("UNIT_SPELLCAST_NOT_INTERRUPTIBLE");
	--self.eventsFrame:UnregisterEvent("UNIT_SPELLCAST_SENT");
	self.eventsFrame:UnregisterEvent("UNIT_SPELLCAST_START");
	self.eventsFrame:UnregisterEvent("UNIT_SPELLCAST_STOP");
	self.eventsFrame:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED");
	trackingHelper:removeEventListener(DHUDDataTrackerHelperEvent.EVENT_UPDATE, self, self.onUpdateTime);
	if (self.cooldownsTracker ~= nil) then
		self.cooldownsTracker:removeEventListener(DHUDDataTrackerEvent.EVENT_DATA_CHANGED, self, self.updateGcd);
	end
	if (self.interruptCdTracker ~= nil) then
		self.interruptCdTracker:removeEventListener(DHUDDataTrackerEvent.EVENT_DATA_CHANGED, self, self.updateInterruptCd);
	end
end

--- Update all data for current unitId
function DHUDSpellCastTracker:updateData()
	self:updateSpellCastStopReason(self.SPELL_FINISH_STATE_NOT_CASTING);
	self:updateSpellCastStop();
	self:updateInterruptCd();
end

--- set unitId variable
-- @param unitId new unitId value
-- @param dispatchUnitChange causes unit change event to be dispatched
function DHUDSpellCastTracker:setUnitId(unitId, dispatchUnitChange)
	self.hasCasted = false;
	DHUDDataTracker.setUnitId(self, unitId, dispatchUnitChange); -- call super
end

--- Attach cooldowns tracker to track gcd inside this tracker
function DHUDSpellCastTracker:attachCooldownsTracker(cooldownsTracker)
	-- remove listener from old tracker
	if (self.cooldownsTracker ~= nil) then
		self.cooldownsTracker:removeEventListener(DHUDDataTrackerEvent.EVENT_DATA_CHANGED, self, self.updateGcd);
		self.isGcd = false;
	end
	self.cooldownsTracker = cooldownsTracker;
	-- add listener to new tracker
	if (cooldownsTracker ~= nil and self.isTracking and self.trackUnitId == "player") then
		self.cooldownsTracker:addEventListener(DHUDDataTrackerEvent.EVENT_DATA_CHANGED, self, self.updateGcd);
		self:updateGcd();
	end
end

--- Attach interrupt tracker to track player ability to interrupt spell inside this tracker
function DHUDSpellCastTracker:attachInterruptCdTracker(interruptCdTracker)
	-- remove listener from old tracker
	if (self.interruptCdTracker ~= nil) then
		self.interruptCdTracker:removeEventListener(DHUDDataTrackerEvent.EVENT_DATA_CHANGED, self, self.updateInterruptCd);
		self.isInterruptOnCd = false;
	end
	self.interruptCdTracker = interruptCdTracker;
	-- add listener to new tracker
	if (interruptCdTracker ~= nil and self.isTracking and self.trackUnitId ~= "player") then
		self.interruptCdTracker:addEventListener(DHUDDataTrackerEvent.EVENT_DATA_CHANGED, self, self.updateInterruptCd);
		self:updateInterruptCd();
	end
end


