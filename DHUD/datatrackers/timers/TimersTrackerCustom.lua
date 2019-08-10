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

--- Base class for tracking of custom timer, e.g. rogue's bandits guile
DHUDCustomTimerTracker = MCCreateSubClass(DHUDDataTracker, {
	-- defeines timer that was created customly
	TIMER_TYPE_CUSTOM_CREATED = 2147483648,
	-- define if tracking by this class is allowed
	STATIC_trackingAllowed = true,
	-- timer id's to change
	timerIdsToUpdate = nil,
	-- timers tracker to update
	timersTracker = nil,
	-- timers group to update
	timersGroup = 0,
	-- defines if this tracker currently updates timers tracker that was attached
	trackingAllowed = false,
})

--- allow tracking setting has changed
function DHUDCustomTimerTracker:STATIC_onCustomAurasTrackersAllowedChange(e)
	self.STATIC_trackingAllowed = DHUDSettings:getValue("misc_useCustomAurasTrackers");
end

--- Initialize DHUDCustomTimerTracker static values
function DHUDCustomTimerTracker:STATIC_init()
	DHUDSettings:addEventListener(DHUDSettingsEvent.EVENT_SPECIFIC_SETTING_CHANGED_PREFIX .. "misc_useCustomAurasTrackers", self, self.STATIC_onCustomAurasTrackersAllowedChange);
	self:STATIC_onCustomAurasTrackersAllowedChange(nil);
end

--- Constructor of timers tracker
function DHUDCustomTimerTracker:constructor()
	-- init tables
	self.timerIdsToUpdate = { };
	-- call super constructor
	DHUDDataTracker.constructor(self);
end

--- get default timer if required, to be overriden by subclasses
-- @return default timer if required
function DHUDCustomTimerTracker:getDefaultTimer()
	return nil;
end

--- create default timer
-- @param id of the timer
-- @return default timer
function DHUDCustomTimerTracker:createDefaultTimer(id)
	local timer = self.timersTracker:findTimerByIdOnly(id, true, false);
	timer[1] = DHUDCustomTimerTracker.TIMER_TYPE_CUSTOM_CREATED;
	return timer;
end

--- Update timer with custom data
-- @param timer timer to be updated { type, timeLeft, duration, id, tooltipId, name, stacks, texture, exists, iterating, sortOrder, grouped, groupData }
-- @return default timer
function DHUDCustomTimerTracker:updateTimer(timer)
	
end

--- update timers tracker timers
-- @param timersTracker timers tracker to update
function DHUDCustomTimerTracker:updateTimers()
	--print("updateTimers");
	-- search for timer to be updated
	local timer;
	for i, v in ipairs(self.timerIdsToUpdate) do
		timer = self.timersTracker:findTimerByIdOnly(v, false, true);
		if (timer ~= nil) then
			--print("update timer by id found " .. v);
			break;
		end
	end
	-- check if we should create default timer
	if (timer == nil) then
		--print("update timer by id not found ");
		timer = self:getDefaultTimer();
		if (timer == nil) then
			return;
		end
	end
	-- update timer
	self:updateTimer(timer);
end

-- allow timer tracking
function DHUDCustomTimerTracker:allowTimerTracking(allow)
	--print("isExists " .. MCTableToString(self.isExists) .. ", allowed " .. MCTableToString(self.STATIC_trackingAllowed) .. ", timersTracker " .. (timersTracker ~= nil and "true" or "false") .. " = allow " .. MCTableToString(allow));
	if (self.trackingAllowed == allow or self.timersTracker == nil) then
		return;
	end
	self.trackingAllowed = allow;
	if (allow) then
		self.timersTracker:addCustomTracker(self, self.timersGroup);
	else
		self.timersTracker:removeCustomTracker(self, self.timersGroup);
	end
end

--- set isExists variable
function DHUDCustomTimerTracker:setIsExists(isExists)
	-- call super
	DHUDDataTracker.setIsExists(self, isExists);
	-- update tracking
	self:allowTimerTracking(isExists and self.STATIC_trackingAllowed);
end

--- process settings change
function DHUDCustomTimerTracker:onCustomAurasTrackerAllowedChange(e)
	self:allowTimerTracking(self.isExists and self.STATIC_trackingAllowed);
end

--- attach custom timer tracker to timers tracker
-- @param timersTracker timers tracker that should be updated by this tracker
-- @param timersGroup timersGroup to update
function DHUDCustomTimerTracker:attachToTimersTrackerIfAllowed(timersTracker, timersGroup)
	if (self.timersTracker ~= nil) then
		self.timersTracker:removeCustomTracker(self, self.timersGroup);
		DHUDSettings:removeEventListener(DHUDSettingsEvent.EVENT_SPECIFIC_SETTING_CHANGED_PREFIX .. "misc_useCustomAurasTrackers", self, self.onCustomAurasTrackerAllowedChange);
	end
	self.timersTracker = timersTracker;
	self.timersGroup = timersGroup;
	self.eventDataChanged.timersGroup = timersGroup;
	-- listen for settings change
	if (timersTracker ~= nil) then
		DHUDSettings:addEventListener(DHUDSettingsEvent.EVENT_SPECIFIC_SETTING_CHANGED_PREFIX .. "misc_useCustomAurasTrackers", self, self.onCustomAurasTrackerAllowedChange);
		self:onCustomAurasTrackerAllowedChange(nil);
	end
end
