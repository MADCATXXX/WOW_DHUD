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
-- Unit data tracker event class --
-----------------------------------

--- Class for events that will be fired from data tracker objects 
DHUDDataTrackerEvent = MCCreateSubClass(MADCATEvent, {
	-- pointer to tracker that was dispatching this event, use it to read new values
	tracker				= nil,
	-- this event will be fired when resource existance is toggled
	EVENT_EXISTANCE_CHANGED = "exists",
	-- this event will be fired when data tracker unit changes
	EVENT_UNIT_CHANGED = "unit",
	-- this event will be fired when resource regeneration is toggled
	EVENT_REGENERATION_STATE_CHANGED = "regen",
	-- this event will be fired when resource amount is changed (or any other value that should be displayed, e.g. maximum amount, new buff or debuff, rune type changed, etc..)
	EVENT_DATA_CHANGED = "data",
	-- this event will be fired when timers for resourse was updated, e.g. buff time left changed
	EVENT_DATA_TIMERS_UPDATED = "dataTimers",
	-- this event will be fired when resource type is changed (e.g. entering Bear form, etc.)
	EVENT_RESOURCE_TYPE_CHANGED = "resourceType",
	
})

--- Create new tracker event
-- @param type type of the event
-- @param tracker pointer to tracker, that will dispatch this event
function DHUDDataTrackerEvent:new(type, tracker)
	local o = self:defconstructor();
	o:constructor(type, tracker);
	return o;
end

--- Constructor for tracker event
-- @param type type of the event
-- @param tracker pointer to tracker, that will dispatch this event
function DHUDDataTrackerEvent:constructor(type, tracker)
	self.tracker = tracker;
	-- call super constructor
	MADCATEvent.constructor(self, type);
end

----------------------------------
-- Unit data tracker base class --
----------------------------------

--- Base class for all data trackers
DHUDDataTracker = MCCreateSubClass(MADCATEventDispatcher, {
	-- frame that is listening to events
	eventsFrame			= nil,
	-- defines if this tracker is listened to, no point in tracking data if it's not used...
	hasListeners		= false,
	-- defines if this tracker is tracking some data or not?
	isTracking			= false,
	-- defines if this tracker will dispatch amount event on the end of the tick
	isQueriedDataEvent = false,
	-- defines if this tracker listens to update event to dispatch queried amount event
	isQueriedDataEventWaiting = false,
	-- id of unit to track data for, this value changes according to situation
	unitId				= "",
	-- id of the unit that this tracker is set to track, vehicle is treated as "player", "softenemy" is treated as "target", etc...
	trackUnitId			= "",
	-- defines if resource exists (should be shown in GUI), e.g. target health is not required without target
	isExists			= true,
	-- defines if datatracker resource is restricted only for certain player specializations
	restrictedToPlayerSpecs = nil,
	-- amount of tracked resource or number of buffs/debuffs/cooldowns, etc..
	amount				= 0,
	-- base amount of tracked resource (at which regeneration will stop, e.g. 0 rage or full mana)
	amountBase			= 0,
	-- defines if resource is currently regenerating (not equals to base)
	isRegenerating		= false,
	-- defines if resource can be regenerated
	canRegenerate		= true,
})

--- Constructor of data tracker
function DHUDDataTracker:constructor()
	-- events frame
	self.eventsFrame = MCCreateBlizzEventFrame();
	-- custom events
	self.eventExistanceChanged = DHUDDataTrackerEvent:new(DHUDDataTrackerEvent.EVENT_EXISTANCE_CHANGED, self);
	self.eventUnitChanged = DHUDDataTrackerEvent:new(DHUDDataTrackerEvent.EVENT_UNIT_CHANGED, self);
	self.eventDataChanged = DHUDDataTrackerEvent:new(DHUDDataTrackerEvent.EVENT_DATA_CHANGED, self);
	self.eventRegenerationChanged = DHUDDataTrackerEvent:new(DHUDDataTrackerEvent.EVENT_REGENERATION_STATE_CHANGED, self);
	-- call super constructor
	MADCATEventDispatcher.constructor(self);
end

--- Update all data for current unitId
function DHUDDataTracker:updateData()
	-- to be overriden by subclasses
end

--- Start tracking data, should be invoked only from changeTrackingState function!
function DHUDDataTracker:startTracking()
	-- to be overriden by subclasses
end

--- Stop tracking data, should be invoked only from changeTrackingState function!
function DHUDDataTracker:stopTracking()
	-- to be overriden by subclasses
end

--- Enable or disable tracking for this data tracker
-- @param enable if true then this data tracker will begin to track data
function DHUDDataTracker:changeTrackingState(enable)
	if (self.isTracking == enable) then
		return;
	end
	self.isTracking = enable;
	if (enable) then
		self:startTracking();
		trackingHelper:addEventListener(DHUDDataTrackerHelperEvent.EVENT_ENTERING_WORLD, self, self.onEnteringWorld);
		self:updateData();
	else
		self:stopTracking();
		trackingHelper:removeEventListener(DHUDDataTrackerHelperEvent.EVENT_ENTERING_WORLD, self, self.onEnteringWorld);
	end
end

--- character is entering world, update
function DHUDDataTracker:onEnteringWorld(e)
	-- recheck if data tracker exists, some events are not fired when player enters world (e.g. shapeshift form when teleporting from instance)
	self:setIsExists(self:checkIsExists());
	-- update data if required
	if (self.isTracking) then
		self:updateData();
	end
end

-- override for tracking purposes
function DHUDDataTracker:addEventListener(eventType, listenerObject, listenerFunction)
	-- call super function
	MADCATEventDispatcher.addEventListener(self, eventType, listenerObject, listenerFunction);
	-- init tracking? existance tracking is not counted as tracking
	self.hasListeners = self.hasListeners or (eventType ~= DHUDDataTrackerEvent.EVENT_EXISTANCE_CHANGED);
	self:changeTrackingState(self.hasListeners and self.isExists);
end

-- override for tracking purposes
function DHUDDataTracker:removeEventListener(eventType, listenerObject, listenerFunction)
	-- call super function
	MADCATEventDispatcher.removeEventListener(self, eventType, listenerObject, listenerFunction);
	-- deinit tracking? existance tracking is not counted as tracking
	self.hasListeners = (self:numberOfAllEventListeners() - self:numberOfEventListeners(DHUDDataTrackerEvent.EVENT_EXISTANCE_CHANGED)) > 0;
	self:changeTrackingState(self.hasListeners and self.isExists);
end

--- set isExists variable
function DHUDDataTracker:setIsExists(isExists)
	if (self.isExists == isExists) then
		return;
	end
	self.isExists = isExists;
	self:changeTrackingState(self.hasListeners and self.isExists);
	self:dispatchEvent(self.eventExistanceChanged);
end

--- Check if this tracker data is exists
function DHUDDataTracker:checkIsExists()
	if (self.unitId == "") then
		return false;
	end
	-- check specs
	if (self.restrictedToPlayerSpecs ~= nil) then
		local spec = trackingHelper.playerSpecialization;
		local isAvailableToSpec = false;
		for i, v in ipairs(self.restrictedToPlayerSpecs) do
			if (v == spec) then
				isAvailableToSpec = true;
				break;
			end
		end
		if (not isAvailableToSpec) then
			return false;
		end
	end
	return true;
end

--- set amount variable
function DHUDDataTracker:setAmount(amount)
	if (self.amount == amount) then
		if (self.isQueriedDataEvent) then
			self:processDataChangedInstant();
		end
		return;
	end
	self.amount = amount;
	self.isQueriedDataEvent = false;
	self:dispatchEvent(self.eventDataChanged);
	self:setIsRegenerating(self.amountBase ~= self.amount);
end

--- set amount base variable
function DHUDDataTracker:setAmountBase(amountBase)
	if (self.amountBase == amountBase) then
		return;
	end
	self.amountBase = amountBase;
	self:setIsRegenerating(self.amountBase ~= self.amount);
end

--- Force data event to be dispatched without changing "amount" variable value, this function will dispatch one event on the end of the tick
function DHUDDataTracker:processDataChanged()
	if (not self.isQueriedDataEventWaiting) then
		self.isQueriedDataEventWaiting = true;
		trackingHelper:addEventListener(DHUDDataTrackerHelperEvent.EVENT_UPDATE_FREQUENT, self, self.onDataChangedTick);
	end
	self.isQueriedDataEvent = true;
end

--- Force data event to be dispatched without changing "amount" variable value, this function will dispatch one event at current moment
function DHUDDataTracker:processDataChangedInstant()
	self.isQueriedDataEvent = false;
	self:dispatchEvent(self.eventDataChanged);
end

--- End of tick for processDataChanged function, dispatch event if needed
function DHUDDataTracker:onDataChangedTick(e)
	self.isQueriedDataEventWaiting = false;
	trackingHelper:removeEventListener(DHUDDataTrackerHelperEvent.EVENT_UPDATE_FREQUENT, self, self.onDataChangedTick);
	if (self.isQueriedDataEvent and self.isExists) then -- check for datatracker existance or otherwise it will give wrong info
		self:processDataChangedInstant();
	end
end

--- set isRegenerating variable
function DHUDDataTracker:setIsRegenerating(isRegenerating)
	if (self.isRegenerating == isRegenerating) then
		return;
	end
	self.isRegenerating = self.canRegenerate and isRegenerating;
	self:dispatchEvent(self.eventRegenerationChanged);
end

--- set unitId variable
-- @param unitId new unitId value
-- @param dispatchUnitChange causes unit change event to be dispatched
function DHUDDataTracker:setUnitId(unitId, dispatchUnitChange)
	self.unitId = unitId;
	local wasExists = self.isExists;
	self:setIsExists(self:checkIsExists());
	-- update data if required
	if (self.isTracking) then
		self:updateData();
		-- update ui instantly
		if (self.isQueriedDataEvent) then
			self:processDataChangedInstant();
		end
	end
	-- dispatch existance event if required
	if (dispatchUnitChange and wasExists and self.isExists) then
		self:dispatchEvent(self.eventUnitChanged);
	end
end

--- set player or vehicle unit id for this tracker
function DHUDDataTracker:initPlayerOrVehicleUnitId()
	function self:onVehicleEvent(e)
		self:setUnitId(trackingHelper.isInVehicle and "vehicle" or "player", true);
	end
	self.trackUnitId = "player";
	self:onVehicleEvent(nil);
	trackingHelper:addEventListener(DHUDDataTrackerHelperEvent.EVENT_VEHICLE_STATE_CHANGED, self, self.onVehicleEvent);
end

--- set player only unit id for this tracker
function DHUDDataTracker:initPlayerUnitId()
	self:setUnitId("player");
	self.trackUnitId = "player";
end

--- set player in vehicle unit id for this tracker
function DHUDDataTracker:initPlayerInVehicleOrNoneUnitId()
	function self:onVehicleEvent(e)
		self:setUnitId(trackingHelper.isInVehicle and "player" or "");
	end
	self.trackUnitId = "player";
	self:onVehicleEvent(nil);
	trackingHelper:addEventListener(DHUDDataTrackerHelperEvent.EVENT_VEHICLE_STATE_CHANGED, self, self.onVehicleEvent);
end

--- set vehicle unit id for this tracker
function DHUDDataTracker:initVehicleOrNoneUnitId()
	function self:onVehicleEvent(e)
		self:setUnitId(trackingHelper.isInVehicle and "vehicle" or "");
	end
	self.trackUnitId = "player";
	self:onVehicleEvent(nil);
	trackingHelper:addEventListener(DHUDDataTrackerHelperEvent.EVENT_VEHICLE_STATE_CHANGED, self, self.onVehicleEvent);
end

--- set player in vehicle unit id for this tracker
function DHUDDataTracker:initPlayerNotInVehicleOrNoneUnitId()
	function self:onVehicleEvent(e)
		self:setUnitId(trackingHelper.isInVehicle and "" or "player");
	end
	self.trackUnitId = "player";
	self:onVehicleEvent(nil);
	trackingHelper:addEventListener(DHUDDataTrackerHelperEvent.EVENT_VEHICLE_STATE_CHANGED, self, self.onVehicleEvent);
end

--- set pet unit id for this tracker
function DHUDDataTracker:initPetOrNoneUnitId()
	function self:onPetEvent(e)
		self:setUnitId(trackingHelper.isPetAvailable and "pet" or "");
	end
	self.trackUnitId = "pet";
	self:onPetEvent(nil);
	trackingHelper:addEventListener(DHUDDataTrackerHelperEvent.EVENT_PET_STATE_CHANGED, self, self.onPetEvent);
end

--- set target unit id for this tracker
function DHUDDataTracker:initTargetUnitId()
	function self:onTargetEvent(e)
		self:setUnitId(trackingHelper.isTargetAvailable and trackingHelper.targetCasterUnitId or "", true);
	end
	self.trackUnitId = "target";
	self:onTargetEvent(nil);
	trackingHelper:addEventListener(DHUDDataTrackerHelperEvent.EVENT_TARGET_UPDATED, self, self.onTargetEvent);
end

--- set target of target unit id for this tracker
function DHUDDataTracker:initTargetOfTargetUnitId()
	function self:onTargetOfTargetEvent(e)
		self:setUnitId(trackingHelper.isTargetOfTargetAvailable and trackingHelper.targetOfTargetCasterUnitId or "", true);
	end
	self.trackUnitId = "targettarget";
	self:onTargetOfTargetEvent(nil);
	trackingHelper:addEventListener(DHUDDataTrackerHelperEvent.EVENT_TARGET_OF_TARGET_UPDATED, self, self.onTargetOfTargetEvent);
end

--- init target switching track
function DHUDDataTracker:prepareTargetChangeTracking()
	-- create default behaviour
	if (self.processTargetChanged == nil) then
		--- function that will be invoked on target change after initing target change tracking
		function self:processTargetChanged()
			-- default behaviour, to be changed by subclasses if needed
			self:updateData();
		end
	end
	function self:onTargetEvent(e)
		self:processTargetChanged();
	end
	--- add this code to start/stop tracking functions
	--trackingHelper:addEventListener(DHUDDataTrackerHelperEvent.EVENT_TARGET_UPDATED, self, self.onTargetEvent);
	--trackingHelper:removeEventListener(DHUDDataTrackerHelperEvent.EVENT_TARGET_UPDATED, self, self.onTargetEvent);
end

--- set tracker to be tracked only if player is specced to correspondig spec
-- @param ... numbers of player specs
function DHUDDataTracker:initPlayerSpecsOnly(...)
	local tracker = self;
	self.restrictedToPlayerSpecs = { ... };
	-- player specialization changed
	function self:onSpecializationEvent(e)
		tracker:setIsExists(tracker:checkIsExists());
	end
	-- register to spec change event
	trackingHelper:addEventListener(DHUDDataTrackerHelperEvent.EVENT_SPECIALIZATION_CHANGED, self, self.onSpecializationEvent);
	self:onSpecializationEvent(nil);
end

--- find name of this tracker in DataTrackers table (function intented use is for Debug only where performance doesn't matter)
function DHUDDataTracker:getTrackerName()
	local ALL = DHUDDataTrackers.ALL;
	local PCLASS = DHUDDataTrackers[trackingHelper.playerClass];
	for k, v in pairs(ALL) do
		if (v == self) then
			return k;
		end
	end
	for k, v in pairs(PCLASS) do
		if (v == self) then
			return k;
		end
	end
	return "Unnamed";
end
