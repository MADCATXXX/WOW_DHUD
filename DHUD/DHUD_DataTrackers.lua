--[[-----------------------------------------------------------------------------------
 Original Drathals HUD (c) 2006 by Markus Inger / Drathal / Silberklinge / Silbersegen
 DHUD for WotLK and later expansions (c) 2013 by MADCAT (EU-��������, ������)
 (http://eu.battle.net/wow/en/character/��������/������/advanced)
---------------------------------------------------------------------------------------
 This file contains functions and classes to track data about unit resources, health,
 buffs and other information
 @author: MADCAT
-----------------------------------------------------------------------------------]]--

-- antitaint local "_" var
local _;

-------------------------------------
-- Unit tracker helper event class --
-------------------------------------

--- Class for tracker helper event, it will be fired by data tracker helper
DHUDDataTrackerHelperEvent = MCCreateSubClass(MADCATEvent, {
	-- dispatched in order to update resources (every 100 ms)
	EVENT_UPDATE = "time",
	-- dispatched in order to do some updates on next time tick (every 17 ms)
	EVENT_UPDATE_FREQUENT = "timeFrequent",
	-- dispatched in order to update some values that don't require regular ticks (every 1000 ms)
	EVENT_UPDATE_INFREQUENT = "timeInFrequent",
	-- dispatched when player changes specialization
	EVENT_SPECIALIZATION_CHANGED = "specialization",
	-- dispatched when player character enter or leave vehicle
	EVENT_VEHICLE_STATE_CHANGED = "vehicle",
	-- dispatched when players target changes
	EVENT_TARGET_UPDATED = "target",
	-- dispatched when players target of target changes
	EVENT_TARGET_OF_TARGET_UPDATED = "targetTarget",
	-- dispatched when pet appear or disappear
	EVENT_PET_STATE_CHANGED = "pet",
	-- dispatched when player character enters or leaves combat
	EVENT_COMBAT_STATE_CHANGED = "combat",
	-- dispatched when player start or stops auto attack on target
	EVENT_ATTACK_STATE_CHANGED = "attack",
	-- dispatched when player character becomes dead or alive
	EVENT_DEATH_STATE_CHANGED = "death",
	-- dispatched when player enters or leaves inn or major city
	EVENT_RESTING_STATE_CHANGED = "resting",
	-- dispatched when player enters or leaves pet battle
	EVENT_PETBATTLE_STATE_CHANGED = "petBattle",
	-- dispatched when user presses or releases modifier keys
	EVENT_MODIFIER_KEYS_STATE_CHANGED = "modifierKeys",
	-- dispatched when player is entering world, all data trackers should update them selves
	EVENT_ENTERING_WORLD = "enteringWorld",
})

--- Create new tracker helper event
-- @param type type of the event
function DHUDDataTrackerHelperEvent:new(type)
	local o = self:defconstructor();
	o:constructor(type);
	return o;
end

--- Constructor for tracker helper event
-- @param type type of the event
function DHUDDataTrackerHelperEvent:constructor(type)
	-- call super constructor
	MADCATEvent.constructor(self, type);
end

-------------------------------
-- Unit tracker helper class --
-------------------------------

--- Class to help track update time, vehicle state and other tasks
DHUDDataTrackerHelper = MCCreateSubClass(MADCATEventDispatcher, {
	-- frame that is listening to events
	eventsFrame			= nil,
	-- number of milliseconds since some event in the past (e.g. entering world), float number, whole part is seconds, fractional pars is milliseconds
	timerMs				= 0,
	-- amount of time since last dispatch of update event
	timeSinceLastUpdate = 0,
	-- amount of time since last dispatch of infrequent update event
	timeSinceLastUpdateLong = 0,
	-- localization-independent player class name, e.g. "ROGUE"
	playerClass			= "",
	-- localization-independent player specialization id (number from 1 to 3, from 1 to 4 for druids)
	playerSpecialization	= 0,
	-- defines if player character is in vehicle with vehicle ui
	isInVehicle			= false,
	-- id of the player casting unit, "vehicle" when in vehicle or "player" otherwise
	playerCasterUnitId	= "player",
	-- defines if player has pet or not
	isPetAvailable		= false,
	-- defines if player has something in target or not
	isTargetAvailable	= false,
	-- defines if player has target and target of target exists
	isTargetOfTargetAvailable = false,
	-- defines if player is in combat
	isInCombat			= false,
	-- defines if player autoattack is turned on
	isAttacking			= false,
	-- defines if player is dead
	isDead				= false,
	-- defines if player is inside inn or major city
	isResting			= false,
	-- defines if player is in pet battle
	isInPetBattle		= false,
	-- table with conversion from spell id to spell data
	spellIdData			= {},
	-- table with conversion from item id to item data
	itemIdData			= {},
	-- table with durations of auras
	auraIdDurationData = {},
	-- table with guids for various unit ids, contains guids for player, pet, vehicle and target
	guids				= {},
	-- mask with currently pressed modifier keys
	modifierKeysMask	= 0,
	-- defines if alt modifier key is currently pressed
	MODIFIER_KEY_ALT	= 1,
	-- defines if ctrl modifier key is currently pressed
	MODIFIER_KEY_CTRL	= 2,
	-- defines if shift modifier key is currently pressed
	MODIFIER_KEY_SHIFT	= 4,
})

--- Create data tracking helper
function DHUDDataTrackerHelper:new()
	local o = self:defconstructor();
	o:constructor();
	return o;
end

--- Constructor of data tracker
function DHUDDataTrackerHelper:constructor()
	-- events frame
	self.eventsFrame = MCCreateBlizzEventFrame();
	-- custom events
	self.eventVehicleState = DHUDDataTrackerHelperEvent:new(DHUDDataTrackerHelperEvent.EVENT_VEHICLE_STATE_CHANGED);
	self.eventUpdate = DHUDDataTrackerHelperEvent:new(DHUDDataTrackerHelperEvent.EVENT_UPDATE);
	self.eventUpdateFrequent = DHUDDataTrackerHelperEvent:new(DHUDDataTrackerHelperEvent.EVENT_UPDATE_FREQUENT);
	self.eventUpdateInFrequent = DHUDDataTrackerHelperEvent:new(DHUDDataTrackerHelperEvent.EVENT_UPDATE_INFREQUENT);
	self.eventTarget = DHUDDataTrackerHelperEvent:new(DHUDDataTrackerHelperEvent.EVENT_TARGET_UPDATED);
	self.eventTargetTarget = DHUDDataTrackerHelperEvent:new(DHUDDataTrackerHelperEvent.EVENT_TARGET_OF_TARGET_UPDATED);
	self.eventPet = DHUDDataTrackerHelperEvent:new(DHUDDataTrackerHelperEvent.EVENT_PET_STATE_CHANGED);
	self.eventCombat = DHUDDataTrackerHelperEvent:new(DHUDDataTrackerHelperEvent.EVENT_COMBAT_STATE_CHANGED);
	self.eventAttack = DHUDDataTrackerHelperEvent:new(DHUDDataTrackerHelperEvent.EVENT_ATTACK_STATE_CHANGED);
	self.eventDeath = DHUDDataTrackerHelperEvent:new(DHUDDataTrackerHelperEvent.EVENT_DEATH_STATE_CHANGED);
	self.eventResting = DHUDDataTrackerHelperEvent:new(DHUDDataTrackerHelperEvent.EVENT_RESTING_STATE_CHANGED);
	self.eventPetBattle =  DHUDDataTrackerHelperEvent:new(DHUDDataTrackerHelperEvent.EVENT_PETBATTLE_STATE_CHANGED);
	self.eventSpecialization = DHUDDataTrackerHelperEvent:new(DHUDDataTrackerHelperEvent.EVENT_SPECIALIZATION_CHANGED);
	self.eventModifierKeysState = DHUDDataTrackerHelperEvent:new(DHUDDataTrackerHelperEvent.EVENT_MODIFIER_KEYS_STATE_CHANGED);
	self.eventEnteringWorld = DHUDDataTrackerHelperEvent:new(DHUDDataTrackerHelperEvent.EVENT_ENTERING_WORLD);
	-- call super constructor
	MADCATEventDispatcher.constructor(self);
end

--- Initalize data tracker
function DHUDDataTrackerHelper:init()
	local helper = self;
	-- subscribe to events
	self.eventsFrame:RegisterEvent("UNIT_ENTERED_VEHICLE");
	self.eventsFrame:RegisterEvent("UNIT_EXITED_VEHICLE");
	self.eventsFrame:RegisterEvent("VEHICLE_PASSENGERS_CHANGED");
	self.eventsFrame:RegisterEvent("UPDATE_VEHICLE_ACTIONBAR");
	self.eventsFrame:RegisterEvent("PLAYER_TARGET_CHANGED");
	self.eventsFrame:RegisterEvent("UNIT_TARGET");
	self.eventsFrame:RegisterEvent("UNIT_PET");
	self.eventsFrame:RegisterEvent("PLAYER_REGEN_DISABLED");
	self.eventsFrame:RegisterEvent("PLAYER_REGEN_ENABLED");
	self.eventsFrame:RegisterEvent("PLAYER_ENTER_COMBAT");
	self.eventsFrame:RegisterEvent("PLAYER_LEAVE_COMBAT");
	self.eventsFrame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED");
	self.eventsFrame:RegisterEvent("PLAYER_ALIVE");
	self.eventsFrame:RegisterEvent("PLAYER_DEAD");
	self.eventsFrame:RegisterEvent("PLAYER_UNGHOST");
	self.eventsFrame:RegisterEvent("PLAYER_UPDATE_RESTING");
	self.eventsFrame:RegisterEvent("PET_BATTLE_OPENING_START");
	self.eventsFrame:RegisterEvent("PET_BATTLE_CLOSE");
	self.eventsFrame:RegisterEvent("MODIFIER_STATE_CHANGED");
	self.eventsFrame:RegisterEvent("PLAYER_ENTERING_WORLD");
	-- initialize player class
	_, self.playerClass = UnitClass("player");
	-- process events
	function self.eventsFrame:UNIT_ENTERED_VEHICLE(unitId)
		if (unitId ~= "player") then
			return;
		end
		--print("UNIT_ENTERED_VEHICLE");
		-- force event rethrow, as VEHICLE_PASSENGERS_CHANGED set it at incorrect time
		helper:setIsInVehicle(UnitHasVehicleUI("player"));
	end
	function self.eventsFrame:UNIT_EXITED_VEHICLE(unitId)
		if (unitId ~= "player") then
			return;
		end
		--print("UNIT_EXITED_VEHICLE");
		helper:setIsInVehicle(false);
	end
	function self.eventsFrame:VEHICLE_PASSENGERS_CHANGED()
		--print("VEHICLE_PASSENGERS_CHANGED");
		helper:setIsInVehicle(UnitHasVehicleUI("player"));
	end
	function self.eventsFrame:UPDATE_VEHICLE_ACTIONBAR()
		--print("UPDATE_VEHICLE_ACTIONBAR");
		helper:setIsInVehicle(UnitHasVehicleUI("player"));
	end
	function self.eventsFrame:PLAYER_TARGET_CHANGED()
		helper:setIsTargetAvailable(UnitExists("target"));
		helper:setIsTargetOfTargetAvailable(UnitExists("targettarget"));
	end
	function self.eventsFrame:UNIT_TARGET(unitId)
		if (unitId ~= "target") then
			return;
		end
		helper:setIsTargetOfTargetAvailable(UnitExists("targettarget"));
	end
	function self.eventsFrame:UNIT_PET(unitId)
		if (unitId ~= "player") then
			return;
		end
		local hasPet = HasPetUI();
		helper:setIsPetAvailable(hasPet); -- UnitExists("pet") may return incorrect results for vehicles
	end
	function self.eventsFrame:PLAYER_REGEN_DISABLED()
		helper:setIsInCombat(true);
	end
	function self.eventsFrame:PLAYER_REGEN_ENABLED()
		helper:setIsInCombat(false);
	end
	function self.eventsFrame:PLAYER_ENTER_COMBAT()
		helper:setIsAttacking(true);
	end
	function self.eventsFrame:PLAYER_LEAVE_COMBAT()
		helper:setIsAttacking(false);
	end
	function self.eventsFrame:PLAYER_SPECIALIZATION_CHANGED(unitId)
		if (unitId ~= "player") then
			return;
		end
		helper:setPlayerSpecialization(GetSpecialization());
	end
	function self.eventsFrame:PLAYER_ALIVE()
		helper:setIsDead(UnitIsDeadOrGhost("player") == 1);
	end
	function self.eventsFrame:PLAYER_DEAD()
		helper:setIsDead(true);
	end
	function self.eventsFrame:PLAYER_UNGHOST()
		helper:setIsDead(false);
	end
	function self.eventsFrame:PLAYER_UPDATE_RESTING()
		helper:setIsResting(IsResting());
	end
	function self.eventsFrame:PET_BATTLE_OPENING_START()
		helper:setIsInPetBattle(true);
	end
	function self.eventsFrame:PET_BATTLE_CLOSE()
		helper:setIsInPetBattle(false);
	end
	function self.eventsFrame:MODIFIER_STATE_CHANGED(key, state)
		helper:setModifierKeysMask((IsAltKeyDown() and helper.MODIFIER_KEY_ALT or 0) + (IsControlKeyDown() and helper.MODIFIER_KEY_CTRL or 0) + (IsShiftKeyDown() and helper.MODIFIER_KEY_SHIFT or 0));
	end
	function self.eventsFrame:PLAYER_ENTERING_WORLD()
		--print("PLAYER_ENTERING_WORLD");
		helper:onEnteringWorld();
	end
	-- initialize other values
	self.guids[""] = "";
	self:updateData();
	-- process update events
	self.timerMs = GetTime();
	self.eventsFrame:SetScript("OnUpdate", function (self, timeElapsed) helper:onUpdate(timeElapsed); end);
end

--- Update helpers data, this function is invoked on init and when entering world
function DHUDDataTrackerHelper:updateData()
	self:setIsInCombat(UnitAffectingCombat("player") == 1);
	self:setIsAttacking(false);
	self:setIsInPetBattle(false);
	self:setIsResting(IsResting() == 1);
	self.eventsFrame:UNIT_ENTERED_VEHICLE("player");
	self.eventsFrame:PLAYER_TARGET_CHANGED();
	self.eventsFrame:UNIT_PET("player");
	self.eventsFrame:PLAYER_SPECIALIZATION_CHANGED("player");
	self.eventsFrame:PLAYER_ALIVE();
	-- update player guid
	self.guids["player"] = UnitGUID("player");
end

--- Function that is called by blizzard event frame to update ui
-- @param timeElapsed amount of time elapsed since last update
function DHUDDataTrackerHelper:onUpdate(timeElapsed)
	self:dispatchEvent(self.eventUpdateFrequent);
	self.timeSinceLastUpdate = self.timeSinceLastUpdate + timeElapsed;
	self.timerMs = GetTime();
	if (self.timeSinceLastUpdate < 0.1) then
		return;
	end
	self.timeSinceLastUpdateLong = self.timeSinceLastUpdateLong + self.timeSinceLastUpdate;
	self.timeSinceLastUpdate = 0;
	self:dispatchEvent(self.eventUpdate);
	if (self.timeSinceLastUpdateLong < 1.0) then
		return;
	end
	self.timeSinceLastUpdateLong = 0;
	self:dispatchEvent(self.eventUpdateInFrequent);
end

--- Function that updates current time for event processing and returns it
function DHUDDataTrackerHelper:getTimerMs()
	self.timerMs = GetTime();
	return self.timerMs;
end

--- set modifierKeysMask variable
function DHUDDataTrackerHelper:setModifierKeysMask(mask)
	if (self.modifierKeysMask == mask) then
		return;
	end
	self.modifierKeysMask = mask;
	self:dispatchEvent(self.eventModifierKeysState);
end

--- set isInVehicle variable
function DHUDDataTrackerHelper:setIsInVehicle(isInVehicle)
	if (self.isInVehicle == isInVehicle and (not isInVehicle)) then -- if set to true than redispatch event again (e.g. passenger seat changed)
		return;
	end
	self.guids["vehicle"] = isInVehicle and UnitGUID("vehicle") or "";
	self.isInVehicle = isInVehicle;
	self.playerCasterUnitId = isInVehicle and "vehicle" or "player";
	self:dispatchEvent(self.eventVehicleState);
end

--- set isTargetAvailable variable
function DHUDDataTrackerHelper:setIsTargetAvailable(isTargetAvailable)
	self.guids["target"] = isTargetAvailable and UnitGUID("target") or "";
	self.isTargetAvailable = isTargetAvailable;
	-- dispatch target event as it means that target is changed (target existence doesn't matter)
	self:dispatchEvent(self.eventTarget);
end

--- set isTargetAvailable variable
function DHUDDataTrackerHelper:setIsTargetOfTargetAvailable(isTargetOfTargetAvailable)
	self.isTargetOfTargetAvailable = isTargetOfTargetAvailable;
	-- dispatch target of target event as it means that target of target is changed (unit existence doesn't matter)
	self:dispatchEvent(self.eventTargetTarget);
end

--- set isPetAvailable variable
function DHUDDataTrackerHelper:setIsPetAvailable(isPetAvailable)
	if (self.isPetAvailable == isPetAvailable) then
		return;
	end
	self.guids["pet"] = isPetAvailable and UnitGUID("pet") or "";
	self.isPetAvailable = isPetAvailable;
	self:dispatchEvent(self.eventPet);
end

--- set isInCombat variable
function DHUDDataTrackerHelper:setIsInCombat(isInCombat)
	if (self.isInCombat == isInCombat) then
		return;
	end
	self.isInCombat = isInCombat;
	self:dispatchEvent(self.eventCombat);
end

--- set isAttacking variable
function DHUDDataTrackerHelper:setIsAttacking(isAttacking)
	if (self.isAttacking == isAttacking) then
		return;
	end
	self.isAttacking = isAttacking;
	self:dispatchEvent(self.eventAttack);
end

-- set isDead variable
function DHUDDataTrackerHelper:setIsDead(isDead)
	if (self.isDead == isDead) then
		return;
	end
	self.isDead = isDead;
	self:dispatchEvent(self.eventDeath);
end

-- set isResting variable
function DHUDDataTrackerHelper:setIsResting(isResting)
	if (self.isResting == isResting) then
		return;
	end
	self.isResting = isResting;
	self:dispatchEvent(self.eventResting);
end

-- set isInPetBattle variable
function DHUDDataTrackerHelper:setIsInPetBattle(isInPetBattle)
	if (self.isInPetBattle == isInPetBattle) then
		return;
	end
	self.isInPetBattle = isInPetBattle;
	self:dispatchEvent(self.eventPetBattle);
end

--- set playerSpecialization variable
function DHUDDataTrackerHelper:setPlayerSpecialization(playerSpecialization)
	if (self.playerSpecialization == playerSpecialization) then
		return;
	end
	self.playerSpecialization = playerSpecialization;
	self:dispatchEvent(self.eventSpecialization);
end

--- player is entering world
function DHUDDataTrackerHelper:onEnteringWorld()
	self:updateData();
	self:dispatchEvent(self.eventEnteringWorld);
end

--- Get cached spell data for spell Id specified
-- @param spellId spell id of the spell
-- @return spellData to be used in other functions
function DHUDDataTrackerHelper:getSpellData(spellId)
	local spellData = self.spellIdData[spellId];
	if (spellData) then
		return spellData;
	end
	spellData = { GetSpellInfo(spellId) };
	self.spellIdData[spellId] = spellData;
	--[[if (spellData == nil) then
		print("Spell with id " .. spellId .. " is nil!");
	end]]--
	return spellData;
end

--- Get cached spell name for spell Id specified
-- @param spellId spell id of the spell
-- @return spellName to be used in UnitBuff function
function DHUDDataTrackerHelper:getSpellName(spellId)
	return self:getSpellData(spellId)[1];
end

--- Get cached item data for item Id specified
-- @param itemId item id of the item
-- @return itemData to be used in other functions
function DHUDDataTrackerHelper:getItemData(itemId)
	local itemData = self.itemIdData[itemId];
	if (itemData) then
		return itemData;
	end
	itemData = { GetItemInfo(itemId) };
	self.itemIdData[itemId] = itemData;
	--[[if (itemData == nil) then
		print("Item with id " .. itemId .. " is nil!");
	end]]--
	return itemData;
end

--- Get cached item name for item Id specified
-- @param itemId item id of the item
-- @return itemName to be used in other functions
function DHUDDataTrackerHelper:getItemName(itemId)
	return self:getItemData(itemId)[1];
end

--- Get spell info on the target unit for spellId specified (this function is just here in case of equal spell names for different spell ids)
-- @param unitId unitId to search aura on
-- @param spellId id of the spell to search
-- @param fullScan perform full aura search instead of using spell name
-- @return parameters that are returned by UnitAura or nil
function DHUDDataTrackerHelper:getUnitAuraById(unitId, spellId, fullScan)
	if (not fullScan) then
		-- may return incorrect result if there is another spell with this name
		return UnitAura(unitId, self:getSpellName(spellId));
	else
		for i = 1, 80 do
			local vars = pack(UnitAura(unitId, i)); -- try {} if pack not exists
			local auraSpellId = vars[11];
			if (auraSpellId == spellId) then
				return unpack(vars);
			elseif (auraSpellId == nil) then
				return nil;
			end
		end
		return nil;
	end
end

--- Get aura duration for spellId specified
-- @param spellId id of the spell to search
-- @param duration duration that was returned by the API
function DHUDDataTrackerHelper:getUnitAuraCorrectDuration(spellId, duration)
	local currentMax = self.auraIdDurationData[spellId];
	if (currentMax == nil) then
		self.auraIdDurationData[spellId] = duration * 1.3;
		return duration;
	end
	if (currentMax < duration) then
		currentMax = duration;
		self.auraIdDurationData[spellId] = duration;
	end
	return currentMax / 1.3;
end

--- Get information about player tank spec index
-- @return indexes of tank specs, or nil if player is not tank capable
function DHUDDataTrackerHelper:getTankSpecializations()
	local numSpecs = GetNumSpecializations();
	local tankSpecs = { };
	for i = 1, numSpecs do
		local role = GetSpecializationRole(i);
		if (role == "TANK") then
			table.insert(tankSpecs, i);
		end
	end
	return unpack(tankSpecs);
end

--- Get information if player can tank or not
-- @return true if player can tank, false otherwise
function DHUDDataTrackerHelper:isTankSpecializationCapable()
	return self:getTankSpecializationIndex() ~= nil;
end

--- Get information if player is currently using tank specialization
-- @return true if player is in tank spec, false otherwise
function DHUDDataTrackerHelper:isTankSpecializationActive()
	local role = GetSpecializationRole(self.playerSpecialization);
	if (role == "TANK") then
		return true;
	end
	return false;
end

-- helper object
local trackingHelper = DHUDDataTrackerHelper:new();

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
	-- id of the unit that this tracker is set to track, vehicle is treated as "player"
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
		self:dispatchEvent(self.eventDataChanged);
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
		self:setUnitId(trackingHelper.isTargetAvailable and "target" or "", true);
	end
	self.trackUnitId = "target";
	self:onTargetEvent(nil);
	trackingHelper:addEventListener(DHUDDataTrackerHelperEvent.EVENT_TARGET_UPDATED, self, self.onTargetEvent);
end

--- set target of target unit id for this tracker
function DHUDDataTracker:initTargetOfTargetUnitId()
	function self:onTargetOfTargetEvent(e)
		self:setUnitId(trackingHelper.isTargetOfTargetAvailable and "targettarget" or "", true);
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

-----------------------------------
-- Unit power tracker base class --
-----------------------------------

--- Base class for trackers of base resources like mana or health
DHUDPowerTracker = MCCreateSubClass(DHUDDataTracker, {
	-- resource power type if provided by game
	resourceType		= -1,
	-- resource power type string if provided by game
	resourceTypeString	= "",
	-- defines if resource power type is custom
	resourceTypeIsCustom = false,
	-- maximum amount of tracked resource
	amountMax			= 0,
	-- maximum amount of tracked resource without talants, glyphs, etc.., e.g. 5 combo-points, 4 chi. This value should not be changed during run-time
	amountMaxDefault	= 0,
	-- minumum amount of tracked resource, usually 0, currently in use only for Moonkin Eclipse power
	amountMin			= 0,
	-- percent of maximum to set minimum amount of tracked resource, usually 0, currently in use only for Moonkin Eclipse power
	amountMinPercent	= 0,
	-- extra amount of resource, can be set event if amount is not at max (e.g. Power word shield for health, or extra combo-points for anticipation talent)
	amountExtra			= 0,
	-- maximum extra amount of resource while it's in use (e.g. maximum amount of all shield on target until shield fades, needed for GUI), calculated when changing amountExtra
	amountExtraMax		= 0,
	-- base amount of resource at which regenerating stops, in percents
	amountBasePercent	= 0,
	-- set to track amount max events when unit become existant, data tracker should override startTrackingAmountMax and stopTrackingAmountMax
	trackAmountMax		= false,
	-- defines if maximum amount being tracked?
	isTrackingAmountMax = false,
	-- table with power type names, used to convert power id to power name
	POWER_TYPES = {
		[0]		= "MANA",
		[1]		= "RAGE",
		[2]		= "FOCUS",
		[3]		= "ENERGY",
		[4]		= "COMBO_POINTS",
		[5]		= "RUNES",
		[6]		= "RUNIC_POWER",
		[7]		= "SOUL_SHARDS",
		[8]		= "ECLIPSE",
		[9]		= "HOLY_POWER",
		[10]	= "ALTERNATE_POWER",
		[11]	= "DARK_FORCE",
		[12]	= "LIGHT_FORCE",
		[13]	= "SHADOW_ORBS",
		[14]	= "BURNING_EMBERS",
		[15]	= "DEMONIC_FURY",
	},
	-- table with base percents for resource types, all unset resource types will be treated as 0
	BASE_PERCENT_FOR_RESOURCE_TYPE = {
		["MANA"]			= 1,
		["ENERGY"]			= 1,
		["FOCUS"]			= 1,
		["SOUL_SHARDS"]		= 1,
		["DEMONIC_FURY"]	= 0.2,
		["BURNING_EMBERS"]	= 0.25,
	},
	-- table with min percents for resource types, all unset resource types will be treated as 0
	MIN_PERCENT_FOR_RESOURCE_TYPE = {
		["ECLIPSE"]			= -1,
	},
})

--- Constructor of power tracker
function DHUDPowerTracker:constructor()
	-- custom events
	self.eventResourceTypeChanged = DHUDDataTrackerEvent:new(DHUDDataTrackerEvent.EVENT_RESOURCE_TYPE_CHANGED, self);
	-- call super constructor
	DHUDDataTracker.constructor(self);
end

--- set amountMax variable
function DHUDPowerTracker:setAmountMax(amountMax)
	if (self.amountMax == amountMax) then
		return;
	end
	self.amountMax = amountMax;
	self:setAmountBase(self.amountBasePercent * self.amountMax);
	self:setAmountMin(self.amountMinPercent * self.amountMax);
	self:processDataChanged();
	self:setIsExists(self:checkIsExists());
end

--- Check if this tracker data is exists
function DHUDPowerTracker:checkIsExists()
	if (not DHUDDataTracker.checkIsExists(self)) then -- call super
		if (self.trackAmountMax) then
			self:changeAmountMaxTrackingState(false);
		end
		return false;
	end
	-- amount max tracking activated?
	if (self.trackAmountMax) then
		self:changeAmountMaxTrackingState(true);
		self:updateAmountMax();
		--print("checkIsExists " .. self.amountMax);
		return (self.amountMax ~= 0); -- power maximum should not be equal to zero
	end
	return true;
end

--- Start tracking amountMax data, should be invoked only from changeTrackingState function!
function DHUDPowerTracker:startTrackingAmountMax()
	-- to be overriden by subclasses
end

--- Update maximum amount or resource, should be invoked only from changeTrackingState function!
function DHUDPowerTracker:updateAmountMax()

end

--- Stop tracking amountMax data, should be invoked only from changeTrackingState function!
function DHUDPowerTracker:stopTrackingAmountMax()
	-- to be overriden by subclasses
end

--- Enable or disable tracking of maximum amount for this data tracker
-- @param enable if true then this data tracker will begin to track data
function DHUDPowerTracker:changeAmountMaxTrackingState(enable)
	if (self.isTrackingAmountMax == enable) then
		return;
	end
	self.isTrackingAmountMax = enable;
	if (enable) then
		self:startTrackingAmountMax();
	else
		self:stopTrackingAmountMax();
	end
end

--- set amountBasePercent variable
function DHUDPowerTracker:setAmountBasePercent(amountBasePercent)
	if (self.amountBasePercent == amountBasePercent) then
		return;
	end
	self.amountBasePercent = amountBasePercent;
	self:setAmountBase(self.amountBasePercent * self.amountMax);
end

--- set amountMin variable
function DHUDPowerTracker:setAmountMin(amountMin)
	if (self.amountMin == amountMin) then
		return;
	end
	self.amountMin = amountMin;
	self:processDataChanged();
end

--- set amountMinPercent variable
function DHUDPowerTracker:setAmountMinPercent(amountMinPercent)
	--print("set amountMinPercent " .. MCTableToString(amountMinPercent));
	if (self.amountMinPercent == amountMinPercent) then
		return;
	end
	self.amountMinPercent = amountMinPercent;
	self:setAmountMin(self.amountMinPercent * self.amountMax);
end

--- set amountExtra variable
function DHUDPowerTracker:setAmountExtra(amountExtra)
	if (self.amountExtra == amountExtra) then
		return;
	end
	self.amountExtra = amountExtra;
	if (amountExtra >= self.amountExtraMax) then
		self.amountExtraMax = amountExtra;
	elseif (amountExtra <= 0) then
		self.amountExtraMax = 0;
	end
	self:processDataChanged();
end

--- set resourceType variable
-- @param resourceType id of the resource type
-- @param resourceTypeName name of the resource, used to improve performance, pass empty string to allow updates on every UNIT_POWER event
function DHUDPowerTracker:setResourceType(resourceType, resourceTypeName)
	-- don't save string if it's not usual resource, it will be reported as different in power change events
	--print("self.POWER_TYPES[resourceType] " .. self.POWER_TYPES[resourceType] .. ", resourceTypeName " .. resourceTypeName);
	if (self.POWER_TYPES[resourceType] ~= resourceTypeName) then
		resourceTypeName = "";
	end
	-- return if already set
	if (self.resourceType == resourceType and self.resourceTypeString == resourceTypeName) then
		return;
	end
	self.resourceType = resourceType;
	self.resourceTypeString = resourceTypeName or "";
	self.resourceTypeIsCustom = false;
	self:dispatchEvent(self.eventResourceTypeChanged);
	-- change base amount
	self:setAmountBasePercent(self.BASE_PERCENT_FOR_RESOURCE_TYPE[self.resourceTypeString] or 0);
	self:setAmountMinPercent(self.MIN_PERCENT_FOR_RESOURCE_TYPE[self.resourceTypeString] or 0);
	-- update data
	self:updateData();
end

--- change power tracker to custom resourceType
-- @param resourceType id of the resource type from DHUDColorizeTools class
function DHUDPowerTracker:setCustomResourceType(resourceType)
	self.resourceType = resourceType;
	self.resourceTypeString = "CUSTOM";
	self.resourceTypeIsCustom = true;
end

------------------------------------
-- Unit health tracker base class --
------------------------------------

--- Base class for trackers of health points (actually it's subclasses will only set unitId to track)
DHUDHealthTracker = MCCreateSubClass(DHUDPowerTracker, {
	-- List of absorb spells to query for negative absorbs (there is UNIT_ABSORB_AMOUNT_CHANGED event for positive absorb but not for negative)
	SPELLIDS_ABSORB_HEAL = {
		--73975,			-- DK: Necrotic Strike
	};
	-- amount of incoming heal (e.g. when casting non-instant healing spell on the target)
	amountHealIncoming	= 0,
	-- amount of healing absorption (e.g. Necrotic Strike that should be healed through)
	amountHealAbsorb	= 0,
	-- defines state at which killing unit won't give credit to player (unit tagging)
	noCreditForKill		= false,
	-- reference to tracker which will make tracking of unit tagging
	creditInfoTracker	= nil,
})

--- Create new health points tracker, unitId should be specified after constructor
function DHUDHealthTracker:new()
	local o = self:defconstructor();
	o:constructor();
	return o;
end

--- Initialize health-points tracking
function DHUDHealthTracker:init()
	local tracker = self;
	-- process units health points change event
	function self.eventsFrame:UNIT_HEALTH(unitId)
		if (tracker.unitId ~= unitId) then
			return;
		end
		tracker:updateHealth();
	end
	-- process units max health points change event
	function self.eventsFrame:UNIT_MAXHEALTH(unitId)
		if (tracker.unitId ~= unitId) then
			return;
		end
		tracker:updateMaxHealth();
	end
	-- process units absorb amount change event
	function self.eventsFrame:UNIT_HEAL_PREDICTION(unitId)
		if (tracker.unitId ~= unitId) then
			return;
		end
		tracker:updateIncomingHeal();
	end
	-- process units absorb amount change event
	function self.eventsFrame:UNIT_ABSORB_AMOUNT_CHANGED(unitId)
		if (tracker.unitId ~= unitId) then
			return;
		end
		tracker:updateAbsorbs();
	end
	-- process units absorb amount change event
	function self.eventsFrame:UNIT_AURA(unitId)
		if (tracker.unitId ~= unitId) then
			return;
		end
		tracker:updateAbsorbedHeal();
	end
	-- change base amount of health
	self:setAmountBasePercent(1);
	-- track maximum amount event if data tracker is not activated
	self.trackAmountMax = true;
end

--- set noCreditForKill variable value
function DHUDHealthTracker:setNoCreditForKill(noCreditForKill)
	if (self.noCreditForKill == noCreditForKill) then
		return;
	end
	self.noCreditForKill = noCreditForKill;
	self:dispatchEvent(self.eventResourceTypeChanged);
end

--- Start tracking data
function DHUDHealthTracker:startTracking()
	-- listen to game events
	self.eventsFrame:RegisterEvent("UNIT_HEALTH");
	self.eventsFrame:RegisterEvent("UNIT_HEAL_PREDICTION");
	self.eventsFrame:RegisterEvent("UNIT_ABSORB_AMOUNT_CHANGED");
	self.eventsFrame:RegisterEvent("UNIT_AURA");
	if (self.creditInfoTracker ~= nil) then
		self.creditInfoTracker:addEventListener(DHUDDataTrackerEvent.EVENT_DATA_CHANGED, self, self.updateTagging);
	end
end

--- Stop tracking data
function DHUDHealthTracker:stopTracking()
	-- stop listening to game events
	self.eventsFrame:UnregisterEvent("UNIT_HEALTH");
	self.eventsFrame:UnregisterEvent("UNIT_HEAL_PREDICTION");
	self.eventsFrame:UnregisterEvent("UNIT_ABSORB_AMOUNT_CHANGED");
	self.eventsFrame:UnregisterEvent("UNIT_AURA");
	if (self.creditInfoTracker ~= nil) then
		self.creditInfoTracker:removeEventListener(DHUDDataTrackerEvent.EVENT_DATA_CHANGED, self, self.updateTagging);
	end
end

--- Start tracking amountMax data
function DHUDHealthTracker:startTrackingAmountMax()
	self.eventsFrame:RegisterEvent("UNIT_MAXHEALTH");
end

--- Update maximum amount or resource
function DHUDHealthTracker:updateAmountMax()
	self.eventsFrame:UNIT_MAXHEALTH(self.unitId);
end

--- Stop tracking amountMax data
function DHUDHealthTracker:stopTrackingAmountMax()
	self.eventsFrame:UnregisterEvent("UNIT_MAXHEALTH");
end

--- Update absorb amounts for unit
function DHUDHealthTracker:updateAbsorbs()
	self:setAmountExtra(UnitGetTotalAbsorbs(self.unitId) or 0);
	self:processDataChanged();
end

--- Update incoming heal for unit
function DHUDHealthTracker:updateIncomingHeal()
	local before = self.amountHealIncoming;
	self.amountHealIncoming = UnitGetIncomingHeals(self.unitId) or 0;
	-- dispatch event
	if (before ~= self.amountHealIncoming) then
		self:processDataChanged();
	end
end

--- Update incoming heal for unit
function DHUDHealthTracker:updateAbsorbedHeal()
	local before = self.amountHealAbsorb;
	self.amountHealAbsorb = 0;
	-- iterate over absorbing spellids
	for i, v in ipairs(self.SPELLIDS_ABSORB_HEAL) do
		--name, rank, icon, count, dispelType, duration, expires, caster, isStealable, shouldConsolidate, spellID, canApplyAura, isBossDebuff, value1, value2, value3
		local value = select(15, UnitDebuff(self.unitId, trackingHelper:getSpellName(v)));
		--[[if (UnitDebuff(self.unitId, trackingHelper:getSpellName(v)) ~= nil) then
			print(MCTableToString({UnitDebuff(self.unitId, trackingHelper:getSpellName(v)) } ));
		end]]--
		self.amountHealAbsorb = self.amountHealAbsorb + (value or 0);
	end
	-- dispatch event
	if (before ~= self.amountHealAbsorb) then
		self:processDataChanged();
	end
end

--- Update health for unit
function DHUDHealthTracker:updateHealth()
	--print("UnitHealth(self.unitId) " .. MCTableToString(UnitHealth(self.unitId)));
	self:setAmount(UnitHealth(self.unitId) or 0);
end

--- Update maximum health for unit
function DHUDHealthTracker:updateMaxHealth()
	--print("UnitHealthMax(self.unitId) " .. MCTableToString(UnitHealthMax(self.unitId)));
	self:setAmountMax(UnitHealthMax(self.unitId) or 0);
end

--- Update unit tagging for unit
function DHUDHealthTracker:updateTagging(e)
	if (self.creditInfoTracker == nil) then
		return;
	end
	self:setNoCreditForKill(not self.creditInfoTracker.tagged);
end

--- Update all data for current unitId
function DHUDHealthTracker:updateData()
	self:updateAbsorbs();
	self:updateIncomingHeal();
	self:updateAbsorbedHeal();
	self:updateMaxHealth();
	self:updateTagging();
	self:updateHealth();
end

--- Attach info tracker to track unit tagging inside this tracker
function DHUDHealthTracker:attachCreditTracker(infoTracker)
	-- remove listener from old tracker
	if (self.creditInfoTracker ~= nil) then
		self.creditInfoTracker:removeEventListener(DHUDDataTrackerEvent.EVENT_DATA_CHANGED, self, self.updateTagging);
	end
	self.creditInfoTracker = infoTracker;
	-- add listener to new tracker
	if (infoTracker ~= nil and self.isTracking) then
		self.creditInfoTracker:removeEventListener(DHUDDataTrackerEvent.EVENT_DATA_CHANGED, self, self.updateTagging);
		self:updateTagging();
	end
end

------------------------------------
-- Unit timers tracker base class --
------------------------------------

--- Base class for trackers of timers for player buffs and cooldowns
DHUDTimersTracker = MCCreateSubClass(DHUDDataTracker, {
	-- list with timers, that should be shown in GUI, each element is table with following data: { type, timeLeft, duration, id, tooltipId, name, stacks, texture, exists, iterating, sortOrder } (where type - type of the timer from class consts, id - spell or item id for tooltip)
	timers				= nil,
	-- table with tables of filtered timers, updated on each filterTimers function call
	filteredTimers		= nil,
	-- list with sources information, used to make mapping between blizzard infomation and internal timer tables, each value contains table with following data: { indexTimerBegin, numTimers, numToSkipMinusOne, timeUpdateAt }
	sources				= nil,
	-- found value from sources table
	sourceInfo			= nil,
	-- time at which timers was updated
	timeUpdatedAt		= 0,
	-- table to describe inactive timer when timers are grouped using groupTimersByTime function
	GROUP_INACTIVE_TIMER = { },
})

--- Constructor of timers tracker
function DHUDTimersTracker:constructor()
	-- init tables
	self.timers = { };
	self.filteredTimers = { };
	self.sources = { };
	-- custom events
	self.eventDataTimersChanged = DHUDDataTrackerEvent:new(DHUDDataTrackerEvent.EVENT_DATA_TIMERS_UPDATED, self);
	-- call super constructor
	DHUDDataTracker.constructor(self);
end

--- Time passed, update all timers
function DHUDTimersTracker:onUpdateTime()
	local timerMs = trackingHelper.timerMs;
	local timeUpdatedAt = self.timeUpdatedAt;
	local diff = timerMs - timeUpdatedAt;
	-- already updated by data update
	if (diff == 0 or #self.timers == 0) then
		return;
	end
	-- iterate over timers
	for i, v in ipairs(self.timers) do
		-- update time left
		v[2] = v[2] - diff;
	end
	self.timeUpdatedAt = timerMs;
	-- dispatch time update event
	self:dispatchEvent(self.eventDataTimersChanged);
end

--- Search for timer that is created for source index specified, and contains info about id specified (internal use only)
-- @param sourceIndex index of timer in source, e.g. index of buff
-- @param id id of the data, e.g. buff spell id
-- @return table with data about timer
function DHUDTimersTracker:findTimer(sourceIndex, id)
	--print("findTimerBegin");
	-- search at index specified
	local indexBegin = self.sourceInfo[1];
	local numTimers = self.sourceInfo[2];
	local numToSkipMinusOne = self.sourceInfo[3];
	local indexToCheck = indexBegin + sourceIndex + numToSkipMinusOne;
	local indexBounds = indexBegin + numTimers;
	--print("indexBegin " .. indexBegin .. ", numTimers " .. numTimers .. ", indexToCheck " .. indexToCheck);
	local timer = self.timers[indexToCheck];
	-- check timer at index
	if (indexToCheck < indexBounds and timer[4] == id and timer[10] ~= true) then
		timer[10] = true; -- set iterating flag
		--print("Timer " .. id .. ", sourceIndex " .. sourceIndex .. ", predictedIndex " ..  indexToCheck .. " was at predicted position");
		return timer;
	end
	--print("findTimer indexBounds " .. indexBounds .. ", indexBegin " .. indexBegin .. ", numTimers " .. numTimers .. ",#timers " .. #self.timers);
	-- perform full search
	local indexLast = indexBounds - 1;
	indexToCheck = indexToCheck - 1; -- start from previous since it's logical location if timer was removed
	-- apply bounds
	if (indexToCheck > indexLast) then
		indexToCheck = indexLast;
	elseif (indexToCheck < indexBegin) then
		indexToCheck = indexBegin;
	end
	-- iterate further after index to check
	for i = indexToCheck, indexLast, 1 do
		timer = self.timers[i];
		-- not already used?
		if (timer[10] ~= true) then
			-- check id
			if (timer[4] == id) then
				timer[10] = true; -- set iterating flag
				-- update number of timers to skip to increase next search speed
				self.sourceInfo[3] = i - indexBegin - sourceIndex;
				--print("Timer " .. id .. ", sourceIndex " .. sourceIndex .. ", predictedIndex " ..  indexToCheck .. ", currentIndex " .. i .. " was not predicted, predict offset is " .. self.sourceInfo[3]);
				return timer;
			end
		end
	end
	indexLast = indexToCheck - 1;
	-- iterate from indexBegin to index to check
	for i = indexBegin, indexLast, 1 do
		timer = self.timers[i];
		-- not already used?
		if (timer[10] ~= true) then
			-- check id
			if (timer[4] == id) then
				timer[10] = true; -- set iterating flag
				-- update number of timers to skip to increase next search speed
				self.sourceInfo[3] = i - indexBegin - sourceIndex;
				--print("Timer " .. id .. ", sourceIndex " .. sourceIndex .. ", predictedIndex " ..  indexToCheck .. ", currentIndex " .. i .. " was not predicted, predict offset is " .. self.sourceInfo[3]);
				return timer;
			end
		end
	end
	-- timer not found, create new { type, timeLeft, duration, id, tooltipId, name, stacks, texture, exists, iterating, sortOrder, grouped, groupData }
	timer = { 0, 0, 0, 0, 0, "", 0, "", true, true, 0 };
	--print("Timer " .. id .. ", sourceIndex " .. sourceIndex .. ", predictedIndex " ..  indexToCheck .. " was created at " .. indexBounds);
	table.insert(self.timers, indexBounds, timer);
	self.sourceInfo[2] = numTimers + 1;
	return timer;
end

--- Search for timer that is created for source, and contains info about id specified (internal use only), this functions always perform full table search
-- do not invoke this function twice if timer was returned once
-- @param id id of the data, e.g. buff spell id
-- @param createIfNone defines if timer should be created if not found
-- @return table with data about timer
function DHUDTimersTracker:findTimerByIdOnly(id, createIfNone)
	local indexBegin = self.sourceInfo[1];
	local numTimers = self.sourceInfo[2];
	local indexLast = indexBegin + numTimers - 1;
	-- iterate over timers
	for i = indexBegin, indexLast, 1 do
		timer = self.timers[i];
		-- not already used?
		if (timer[10] ~= true) then
			-- check id
			if (timer[4] == id) then
				timer[10] = true; -- set iterating flag
				return timer;
			end
		end
	end
	-- timer not found, create new { type, timeLeft, duration, id, tooltipId, name, stacks, texture, exists, iterating, sortOrder, grouped, groupData } or return
	if (not createIfNone) then
		return nil;
	end
	timer = { 0, 0, 0, 0, 0, "", 0, "", true, true, 0 };
	--print("Timer " .. id .. ", sourceIndex " .. sourceIndex .. ", predictedIndex " ..  indexToCheck .. " was created at " .. indexBounds);
	table.insert(self.timers, indexLast + 1, timer);
	self.sourceInfo[2] = numTimers + 1;
	return timer;
end

--- Check if source contains timer with negative duration
-- @param sourceId id of the source
-- @return true if timers with negative duration are present
function DHUDTimersTracker:containsTimerWithNegativeDuration(sourceId)
	local sourceInfo = self.sources[sourceId];
	local indexBegin = sourceInfo[1];
	local numTimers = sourceInfo[2];
	local n = indexBegin + numTimers - 1;
	for i = indexBegin, n, 1 do
		if (self.timers[i][2] < 0) then
			return true;
		end
	end
	return false;
end

--- Function that should be invoked before iterating over findTimer (internal use only)
-- @param sourceId id of the source, number
function DHUDTimersTracker:findSourceTimersBegin(sourceId)
	--print("findSourceTimersBegin");
	local sourceInfo = self.sources[sourceId];
	-- source not found?
	if (sourceInfo == nil) then
		sourceInfo = { 1, 0, 0, 0 };
		self.sources[sourceId] = sourceInfo;
		-- correct start index if required
		local i = sourceId - 1;
		while (i >= 1) do
			if (self.sources[i] ~= nil) then
				sourceInfo[1] = self.sources[i][1] + self.sources[i][2];
				break;
			end
			i = i - 1;
		end
	end
	--print("findTimer begin source " .. sourceId);
	-- update numToSkipMinusOne
	sourceInfo[3] = -1;
	-- save found source info
	self.sourceInfo = sourceInfo;
end

--- Function that should be invoked after iterating over findTimer (internal use only)
-- @param sourceId id of the source, number
function DHUDTimersTracker:findSourceTimersEnd(sourceId)
	--print("findSourceTimersEnd");
	local sourceInfo = self.sources[sourceId];
	-- remove all timers that no longer exists in source
	local indexBegin = sourceInfo[1];
	local numTimers = sourceInfo[2];
	local i = indexBegin + numTimers - 1;
	while (i >= indexBegin) do
		local timer = self.timers[i];
		if (timer[10] == false) then
			timer[9] = false;
			table.remove(self.timers, i);
			numTimers = numTimers - 1;
		end
		timer[10] = false;
		i = i - 1;
	end
	-- save new count
	sourceInfo[2] = numTimers;
	-- save time updated
	sourceInfo[4] = trackingHelper.timerMs;
	-- update indexes for other sources
	i = sourceId + 1;
	indexBegin = indexBegin + numTimers;
	local numSources = #self.sources;
	while (i <= numSources) do
		sourceInfo = self.sources[i];
		sourceInfo[1] = indexBegin;
		indexBegin = indexBegin + sourceInfo[2];
		i = i + 1;
	end
	--print("findTimer end source " .. sourceId);
end

--- Updates timeUpdatedAt variable and timers for sources that wasn't updated, must be called after partial timers update
function DHUDTimersTracker:forceUpdateTimers()
	local timerMs = trackingHelper.timerMs;
	-- iterate over sources
	for i, v in ipairs(self.sources) do
		-- check if source timers are updated
		if (v[4] ~= timerMs) then
			-- update
			local indexBegin = v[1];
			local indexEnd = indexBegin + v[2] - 1;
			local diff = timerMs - v[4];
			-- iterate over timers
			for j = indexBegin, indexEnd, 1 do
				local timer = self.timers[j];
				-- update time left
				timer[2] = timer[2] - diff;
			end
		end
		v[4] = timerMs;
	end
	-- update time updated var, but don't dispatch time update event (not required)
	self.timeUpdatedAt = timerMs;
end

--- Group timers together that have identical timeleft, duration and don't have stacks, timers are grouped only once (internal use only)
-- excess timers won't be deleted but won't be filetered either
-- @param sourceId id of the source, number
-- @param funcSelf self parameter to be passed to function
-- @param func funcion that receives timers and should decide if they are aprotiate to be grouped
function DHUDTimersTracker:groupTimersByTime(sourceId, funcSelf, func)
	local sourceInfo = self.sources[sourceId];
	local firstTimer = sourceInfo[1];
	local lastTimer = firstTimer + sourceInfo[2] - 1;
	local timer, timer2;
	local timersGroup = { };
	-- iterate
	for i = firstTimer, lastTimer, 1 do
		timer = self.timers[i];
		-- timer is active?
		if (timer[10] == true) then
			-- timer was already attemted to be grouped?
			if (timer[12] == true) then
				-- timer was part of the group?
				if (timer[13] ~= nil) then
					-- update timer info, atleast type and stacks, use group info { type, stacks }
					if (timer[13] ~= self.GROUP_INACTIVE_TIMER) then
						timer[1] = timer[13][1]; -- type
						timer[7] = timer[13][2]; -- stacks
					end
				end
			else
				-- timer doesn't have stacks?
				if (timer[7] == 1) then
					-- clear timers group table
					for k, v in ipairs(timersGroup) do timersGroup[k]=nil; end
					-- iterate over other timers
					for j = i + 1, lastTimer, 1 do
						timer2 = self.timers[j];
						-- timer is active, not grouped and don't have stacks?
						if (timer2[10] == true and timer2[12] == nil and timer2[7] == 1) then
							-- check if timeleft and duration is the same
							if (timer[2] == timer2[2] and timer[3] == timer2[3]) then
								-- add to the table
								table.insert(timersGroup, timer2);
							end
						end
					end
					-- found group?
					local numTimersGroup = #timersGroup;
					if (numTimersGroup > 0) then
						-- add to the table first timer
						table.insert(timersGroup, 1, timer);
						numTimersGroup = numTimersGroup + 1;
						-- check back if it's valid group
						local mainTimer = func(funcSelf, timersGroup);
						-- update all timers
						for k, v in ipairs(timersGroup) do
							-- set attempted to be grouped flag
							v[12] = true;
						end
						-- check if we have main timer
						if (mainTimer ~= nil) then
							for k, v in ipairs(timersGroup) do
								if (v == mainTimer) then
									-- update group info { type, stacks }
									local groupInfo = { };
									groupInfo[1] = mainTimer[1];
									groupInfo[2] = numTimersGroup;
									v[13] = groupInfo; -- groupInfo
									v[7] = numTimersGroup; -- stacks
								else
									v[13] = self.GROUP_INACTIVE_TIMER;
								end
							end
						end
					end
				end
			end
		end
	end
end

--- Filter out timers using function specified
-- @param func funcion that desides if item is required or not, also returning sort order (invoked with data about timer, should return nil if timer is not required or number for timer sorting order)
-- @param cacheKey key to be used when storing results in cache, and at which will be stored sorting order for prioritizied spells
-- @param forceUpdate force existsing timers to be refiltered, use for data update only
-- @return table with sorted timers and boolean that defines if only time was changed
function DHUDTimersTracker:filterTimers(func, cacheKey, forceUpdate)
	local changed = false;
	-- find cached timers list
	local filtered = self.filteredTimers[cacheKey];
	if (filtered == nil) then
		filtered = { };
		self.filteredTimers[cacheKey] = filtered;
	end
	-- check current timers existance
	local i = #filtered;
	while (i >= 1) do
		local v = filtered[i];
		v[10] = true;
		-- timer no longer valid?
		if (v[9] == false) then
			table.remove(filtered, i);
			changed = true;
		end
		-- timer no longer filtered?
		if (forceUpdate) then
			v[11] = func(v);
			if (v[11] == nil) then
				table.remove(filtered, i);
				changed = true;
			elseif (v[11] < 1000) then
				v[cacheKey] = v[11];
			end
		end
		i = i - 1;
	end
	local currentNum = #filtered;
	-- check if new timers can be added
	for i, v in ipairs(self.timers) do
		-- already checked?
		if (v[10] == true) then
			v[10] = false;
		elseif (v[13] ~= self.GROUP_INACTIVE_TIMER) then
			local sortOrder = func(v);
			if (sortOrder ~= nil) then
				v[11] = sortOrder;
				table.insert(filtered, v);
				changed = true;
				if (v[11] < 1000) then
					v[cacheKey] = v[11];
				end
				--print("inserting " .. v[6] .. " to " .. cacheKey);
			end
		end
	end
	--[[local text = "";
	for i,v in ipairs(filtered) do
		text = text .. v[6] .. "(" .. v[11] .. "), ";
	end
	print("before sort " .. text);]]--
	-- sort the table if required
	if (changed) then
		-- update sort order for existing items
		i = currentNum;
		while (i >= 1) do
			local v = filtered[i];
			if (v[10]) then
				v[11] = func(v) or 0;
				if (v[11] < 1000) then
					v[cacheKey] = v[11];
				end
			end
			i = i - 1;
		end
		-- sort
		MCSortTableBySubValue(filtered, 11);
	end
	--[[text = cacheKey .. ": ";
	for i,v in ipairs(filtered) do
		text = text .. v[6] .. "(" .. v[11] .. "), ";
	end
	print("after sort " .. text);]]--
	return filtered, changed;
end

--- Compare function for table.sort, must return a boolean value specifying whether the first argument should be before the second argument in the sequence (not a class function, self is nil!)
-- @param a first argument
-- @param b second argument
-- @return return -1 if first parameter should be before second, or 1 if first parameter should be after
function DHUDTimersTracker.compareFilteredTimersForSort(a, b)
	return a[11] - b[11];
end

--- Start tracking data
function DHUDTimersTracker:startTracking()
	-- listen to game events
	trackingHelper:addEventListener(DHUDDataTrackerHelperEvent.EVENT_UPDATE, self, self.onUpdateTime);
end

--- Stop tracking data
function DHUDTimersTracker:stopTracking()
	-- stop listening to game events
	trackingHelper:removeEventListener(DHUDDataTrackerHelperEvent.EVENT_UPDATE, self, self.onUpdateTime);
end

-----------------------------------
-- Unit auras tracker base class --
-----------------------------------

--- Class to track unit buffs and debuffs
DHUDAurasTracker = MCCreateSubClass(DHUDTimersTracker, {
	-- mask for the type, that specifies that aura is a buff
	TIMER_TYPE_MASK_BUFF			= 1,
	-- mask for the type, that specifies that aura is a debuff
	TIMER_TYPE_MASK_DEBUFF			= 2,
	-- mask for the type, that specifies that aura is of magic type
	TIMER_TYPE_MASK_IS_MAGIC		= 4,
	-- mask for the type, that specifies that aura is of poison type
	TIMER_TYPE_MASK_IS_POISON		= 8,
	-- mask for the type, that specifies that aura is of curse type
	TIMER_TYPE_MASK_IS_CURSE		= 16,
	-- mask for the type, that specifies that aura is of disease type
	TIMER_TYPE_MASK_IS_DISEASE		= 32,
	-- mask for the type, that specifies that aura is of enrage type
	TIMER_TYPE_MASK_IS_ENRAGE		= 64,
	-- mask for the type, that specifies that aura can be purged
	TIMER_TYPE_MASK_IS_PURGABLE		= 128,
	-- mask for the type, that specifies that aura was applied by player
	TIMER_TYPE_MASK_IS_CAST_BY_PLAYER = 256,
	-- table to convert blizz debuffType string to addon type mask
	debuffTypeMask = {
		["Magic"] = 4,
		["Disease"] = 32,
		["Poison"] = 8,
		["Curse"] = 16,
		[""] = 64,
	},
})

--- Create new unit auras tracker, unitId should be specified after constructor
function DHUDAurasTracker:new()
	local o = self:defconstructor();
	o:constructor();
	return o;
end

--- Initialize aura tracking
function DHUDAurasTracker:init()
	local tracker = self;
	-- process units auras change event
	function self.eventsFrame:UNIT_AURA(unitId)
		if (tracker.unitId ~= unitId) then
			return;
		end
		tracker:updateAuras();
	end
end

--- Update unit auras
function DHUDAurasTracker:updateAuras()
	--print("updateAuras Buffs");
	local timerMs = trackingHelper.timerMs;
	local playerCasterUnitId = trackingHelper.playerCasterUnitId;
	-- create variables
	local name, rank, icon, count, debuffType, duration, expirationTime, unitCaster, canPurge, consolidate, spellId, canBeCastByPlayer, isCastByBoss, isCastByPlayer;
	local timer;
	-- update buffs
	self:findSourceTimersBegin(0);
	-- iterate
	local i = 1;
	while (true) do
		name, rank, icon, count, debuffType, duration, expirationTime, unitCaster, canPurge, consolidate, spellId, canBeCastByPlayer, isCastByBoss = UnitBuff(self.unitId, i);
		if (name == nil) then
			break;
		end
		timer = self:findTimer(i, spellId);
		-- fill timer info, { type, timeLeft, duration, id, tooltipId, name, stacks, texture, exists, iterating, sortOrder }
		timer[1] = self.TIMER_TYPE_MASK_BUFF + (self.debuffTypeMask[debuffType] or 0) + (canPurge and self.TIMER_TYPE_MASK_IS_PURGABLE or 0) + (unitCaster == playerCasterUnitId and self.TIMER_TYPE_MASK_IS_CAST_BY_PLAYER or 0); -- type
		timer[2] = expirationTime - timerMs; -- timeLeft
		timer[3] = trackingHelper:getUnitAuraCorrectDuration(spellId, duration); -- duration
		timer[4] = spellId; -- id
		timer[5] = i; -- tooltip id
		timer[6] = name; -- name
		timer[7] = count; -- stacks
		timer[8] = icon; -- texture
		-- continue
		i = i + 1;
	end
	-- stop
	self:findSourceTimersEnd(0);
	-- update debuffs
	--print("updateAuras DeBuffs");
	self:findSourceTimersBegin(1);
	-- iterate
	i = 1;
	while (true) do
		name, rank, icon, count, debuffType, duration, expirationTime, unitCaster, canPurge, consolidate, spellId, canBeCastByPlayer, isCastByBoss = UnitDebuff(self.unitId, i);
		if (name == nil) then
			break;
		end
		timer = self:findTimer(i, spellId);
		-- fill timer info, { type, timeLeft, duration, id, tooltipId, name, stacks, texture, exists, iterating, sortOrder }
		--print("name " .. name .. ", unitCaster " .. unitCaster);
		timer[1] = self.TIMER_TYPE_MASK_DEBUFF + (self.debuffTypeMask[debuffType] or 0) + (canPurge and self.TIMER_TYPE_MASK_IS_PURGABLE or 0) + (unitCaster == playerCasterUnitId and self.TIMER_TYPE_MASK_IS_CAST_BY_PLAYER or 0); -- type
		timer[2] = expirationTime - timerMs; -- timeLeft
		timer[3] = trackingHelper:getUnitAuraCorrectDuration(spellId, duration); -- duration
		timer[4] = spellId; -- id
		timer[5] = i; -- tooltip id
		timer[6] = name; -- name
		timer[7] = count; -- stacks
		timer[8] = icon; -- texture
		-- continue
		i = i + 1;
	end
	-- stop
	self:findSourceTimersEnd(1);
	-- updateTimers for other source groups
	--print("force Update");
	self:forceUpdateTimers();
	-- dispatch event
	--print("data changed");
	self:processDataChanged();
end

--- Update all data for current unitId
function DHUDAurasTracker:updateData()
	self:updateAuras();
end

--- Start tracking data
function DHUDAurasTracker:startTracking()
	-- listen to game events
	self.eventsFrame:RegisterEvent("UNIT_AURA");
	-- call super
	DHUDTimersTracker.startTracking(self);
end

--- Stop tracking data
function DHUDAurasTracker:stopTracking()
	-- stop listening to game events
	self.eventsFrame:UnregisterEvent("UNIT_AURA");
	-- call super
	DHUDTimersTracker.stopTracking(self);
end

---------------------------------------
-- Unit cooldowns tracker base class --
---------------------------------------

--- Class to track unit cooldowns
DHUDCooldownsTracker = MCCreateSubClass(DHUDTimersTracker, {
	-- mask for the type, that specifies that cooldown is associated with spell
	TIMER_TYPE_MASK_SPELL			= 1,
	-- mask for the type, that specifies that cooldown is associated with item
	TIMER_TYPE_MASK_ITEM			= 2,
	-- mask for the type, that specifies that cooldown is associated with pet spell
	TIMER_TYPE_MASK_PETSPELL		= 4,
	-- mask for the type, that specifies that cooldown is associated with spell school lock
	TIMER_TYPE_MASK_SCHOOLLOCK		= 8,
	-- mask for the type, that specifies that cooldown was activated manually
	TIMER_TYPE_MASK_ACTIVE			= 16,
	-- mask for the type, that specifies that cooldown was activated automatically and has internal cooldown
	TIMER_TYPE_MASK_PASSIVE			= 32,
	-- mask for the type, that specifies that cooldown was activated automatically and using rppm system
	TIMER_TYPE_MASK_PASSIVE_RPPM	= 64,
	-- cooldown of deathknight runes
	DEATHKNIGHT_RUNE_COOLDOWN		= 10,
	-- combat event frame to listen to combat events
	combatEventsFrame				= nil,
	-- table with time at which spells were successfully cast (key = id, value = time in ms)
	spellsCastSuccessTime			= nil,
	-- school that was locked
	schoolLockType					= 0,
	-- time at which schools was locked?
	schoolLockTime					= 0,
})

--- Create new unit cooldowns tracker, unitId should be specified after constructor
function DHUDCooldownsTracker:new()
	local o = self:defconstructor();
	o:constructor();
	return o;
end

--- Constructor of cooldowns tracker
function DHUDCooldownsTracker:constructor()
	-- init tables
	self.spellsCastSuccessTime = { };
	-- create combat events frame
	self.combatEventsFrame = MCCreateBlizzCombatEventFrame();
	-- call super constructor
	DHUDTimersTracker.constructor(self);
end

--- Initialize cooldowns tracking
function DHUDCooldownsTracker:init()
	local tracker = self;
	-- process units cooldown change event, fires few times for every cooldown (gcd?)
	function self.eventsFrame:SPELL_UPDATE_COOLDOWN()
		tracker:updateSpellCooldowns();
		tracker:updateItemCooldowns();
		tracker:updateActionBarCooldowns();
		tracker:updatePetCooldowns();
	end
	-- process units cooldown end event, fires every gcd or even every update? 
	function self.eventsFrame:SPELL_UPDATE_USABLE(unitId)
		
	end
	-- process spell cast succeed event, fires when spell was cast
	function self.eventsFrame:UNIT_SPELLCAST_SUCCEEDED(unitId, spell, rank, lineId, spellId)
		if (unitId ~= tracker.unitId) then
			return;
		end
		tracker.spellsCastSuccessTime[spellId] = trackingHelper.timerMs;
		--print("spellid " .. MCTableToString(spellId) .. ", timerMs " .. MCTableToString(timerMs));
	end
	-- process combat spell cast interrupt event
	function self.combatEventsFrame:SPELL_INTERRUPT(timestamp, hideCaster, sourceGUID, sourceName, sourceFlags, sourceFlags2, destGUID, destName, destFlags, destFlags2, spellId, spellName, spellSchool, extraSpellID, extraSpellName, extraSchool)
		--print("SPELL_INTERRUPT sourceName " .. MCTableToString(sourceName) .. ", destName " .. MCTableToString(destName) .. ", spellSchool " .. MCTableToString(spellSchool) .. ", extraSchool " .. MCTableToString(extraSchool));
		if (destGUID ~= trackingHelper.guids[tracker.unitId]) then
			return;
		end
		tracker.schoolLockTime = trackingHelper.timerMs;
		tracker.schoolLockType = extraSchool;
	end
end

--- Time passed, update all timers
function DHUDCooldownsTracker:onUpdateTime()
	-- nothing to update?
	if (#self.timers == 0) then
		return;
	end
	-- update spell cooldowns if required, wow doesn't throw event for cooldown end
	if (self:containsTimerWithNegativeDuration(0)) then
		self:updateSpellCooldowns();
	end
	-- update item cooldowns if required, wow doesn't throw event for cooldown end
	if (self:containsTimerWithNegativeDuration(1)) then
		self:updateItemCooldowns();
	end
	-- update action bar cooldowns if required, wow doesn't throw event for cooldown end
	if (self:containsTimerWithNegativeDuration(2)) then
		self:updateActionBarCooldowns();
	end
	-- update pet cooldowns if required, wow doesn't throw event for cooldown end
	if (self:containsTimerWithNegativeDuration(3)) then
		self:updatePetCooldowns();
	end
	-- call super
	DHUDTimersTracker.onUpdateTime(self);
end

--- Function that should decide if timers are required to be grouped
-- @param timerList list with timers
-- @return main timer in the list if timers should be grouped, this timer can be modified by this function
function DHUDCooldownsTracker:groupSpellCooldowns(timersList)
	local timerMs = trackingHelper.timerMs;
	-- check if it's multispell cooldown?
	local castedAtThisTime = 0;
	local cooldownStartTime, castTime;
	local mainTimer = timersList[1];
	cooldownStartTime = mainTimer[2] - mainTimer[3] + timerMs;
	-- iterate over timers
	for i, v in ipairs(timersList) do
		castTime = self.spellsCastSuccessTime[v[4]] or 0;
		if ((castTime - cooldownStartTime) >= 0 and (castTime - cooldownStartTime) <= 1) then
			castedAtThisTime = castedAtThisTime + 1;
			mainTimer = v;
		end
	end
	-- single cast
	if (castedAtThisTime == 1) then
		return mainTimer;
	-- multiple casts in macro
	elseif (castedAtThisTime > 1) then
		return nil;
	end
	-- most probably it is school lock, change type
	mainTimer[1] = self.TIMER_TYPE_MASK_SCHOOLLOCK + self.TIMER_TYPE_MASK_ACTIVE;
	-- change school lock type if required
	if (not((self.schoolLockTime - cooldownStartTime) >= -1 and (self.schoolLockTime - cooldownStartTime) <= 1)) then
		self.schoolLockType = 127;
	end
	return mainTimer;
end

--- Update spell cooldowns from main spellbook (don't update cooldowns on guild perks, etc.)
function DHUDCooldownsTracker:updateSpellCooldowns()
	local timerMs = trackingHelper.timerMs;
	-- create variables
	local cooldownId = 0;
	local startTime, duration, enable, charges, maxCharges, cooldownCharges;
	local spellType, spellId, spellData;
	local flyoutId, flyoutName, flyoutDecription, flyoutNumSlots, flyoutIsKnown;
	local timer;
	-- update spell cooldowns
	self:findSourceTimersBegin(0);
	-- spell cooldowns are only required for player, not vehicle
	if (self.unitId == "player") then
		-- skip cooldowns with invalid duration
		local invalidDuration = 0;
		-- special cooldowns processing for deathknights
		-- This is a hack to compensate for Blizzard's API reporting incorrect cooldown information for death knights.
		-- Ignore cooldowns that are the same duration as a rune cooldown except for the abilities that truly have the same cooldown.
		if (trackingHelper.playerClass == "DEATHKNIGHT") then
			invalidDuration = self.DEATHKNIGHT_RUNE_COOLDOWN;
		end
		-- spell tab info
		local bookName, bookTexture, bookOffset, bookNumSpells = GetSpellTabInfo(2); -- 2 is always main spell book for current spec
		local n = bookOffset + bookNumSpells - 1;
		-- iterate over spell book
		for i = bookOffset, n, 1 do
			-- get spell info
			spellType, spellId = GetSpellBookItemInfo(i, BOOKTYPE_SPELL);
			spellData = trackingHelper:getSpellData(spellId);
			-- check spells with charges
			charges, maxCharges, startTime, duration = GetSpellCharges(spellData[1]);
			if (charges ~= nil and (maxCharges - charges) > 0) then
				cooldownCharges = (maxCharges - charges);
			else -- check usual cooldown
				startTime, duration, enable = GetSpellCooldown(i, BOOKTYPE_SPELL);
				cooldownCharges = 1;
			end
			-- valid cooldown?
			if (startTime ~= nil and duration > 1.5 and duration ~= invalidDuration) then
				cooldownId = cooldownId + 1;
				timer = self:findTimer(cooldownId, spellId);
				-- degroup timers if their duration has changed, for spells like "Death from above"
				if (timer[13] ~= nil and timer[3] ~= duration) then
					timer[12] = nil;
					timer[13] = nil;
				end
				-- fill timer info, { type, timeLeft, duration, id, tooltipId, name, stacks, texture, exists, iterating, sortOrder }
				timer[1] = self.TIMER_TYPE_MASK_SPELL + self.TIMER_TYPE_MASK_ACTIVE; -- type
				timer[2] = startTime + duration - timerMs; -- timeLeft
				timer[3] = duration; -- duration
				timer[4] = spellId; -- id
				timer[5] = spellId; -- tooltipId
				timer[6] = spellData[1]; -- name
				timer[7] = cooldownCharges; -- stacks
				timer[8] = spellData[3]; -- texture
			end
		end
		-- number of flyout spells like mage portals and shaman totems (spelltype = FLYOUT)
		local flyouts = GetNumFlyouts();
		-- iterate over flyout spells
		for i = 1, flyouts, 1 do
			flyoutId = GetFlyoutID(i);
			flyoutName, flyoutDecription, flyoutNumSlots, flyoutIsKnown = GetFlyoutInfo(flyoutId);
			for j = 1, flyoutNumSlots, 1 do
				-- get spell info
				spellId, flyoutIsKnown = GetFlyoutSlotInfo(flyoutId, j);
				spellData = trackingHelper:getSpellData(spellId);
				-- check spells with charges
				charges, maxCharges, startTime, duration = GetSpellCharges(spellData[1]);
				if (charges ~= nil and (maxCharges - charges) > 0) then
					cooldownCharges = (maxCharges - charges);
				else -- check usual cooldown
					startTime, duration, enable = GetSpellCooldown(spellId);
					cooldownCharges = 1;
				end
				-- valid cooldown?
				if (startTime ~= nil and duration > 1.5 and duration ~= invalidDuration) then
					cooldownId = cooldownId + 1;
					timer = self:findTimer(cooldownId, spellId);
					-- fill timer info, { type, timeLeft, duration, id, tooltipId, name, stacks, texture, exists, iterating, sortOrder }
					timer[1] = self.TIMER_TYPE_MASK_SPELL + self.TIMER_TYPE_MASK_ACTIVE; -- type
					timer[2] = startTime + duration - timerMs; -- timeLeft
					timer[3] = duration; -- duration
					timer[4] = spellId; -- id
					timer[5] = spellId; -- tooltipId
					timer[6] = spellData[1]; -- name
					timer[7] = cooldownCharges; -- stacks
					timer[8] = spellData[3]; -- texture
				end
			end
		end
		-- iterate over similiar cooldowns and reintegrate them together
		self:groupTimersByTime(0, self, self.groupSpellCooldowns);
	end
	-- stop
	self:findSourceTimersEnd(0);
	-- updateTimers for other source groups
	self:forceUpdateTimers();
	-- dispatch event
	self:processDataChanged();
end

--- Update spell cooldowns from main spellbook (don't update cooldowns on guild perks, etc.)
function DHUDCooldownsTracker:updatePetCooldowns()
	-- update pet cooldowns
	self:findSourceTimersBegin(3);
	-- check if pet can cast something?
	local numPetSpells = HasPetSpells();
	-- if we don't have pet or are inside vehicle - this cooldowns are not required
	if (numPetSpells == nil or self.unitId ~= "player" or not trackingHelper.isPetAvailable) then
		-- clear cooldowns if any and return
		self:findSourceTimersEnd(3);
		return;
	end
	-- get time
	local timerMs = trackingHelper.timerMs;
	-- create variables
	local cooldownId = 0;
	local spellType, spellId, autocastAllowed, autocastEnabled, spellData, startTime, duration, enable;
	-- iterate over spell book
	for i = 1, numPetSpells, 1 do
		-- get spell info
		spellType, spellId = GetSpellBookItemInfo(i, BOOKTYPE_PET);
		-- only process spells
		if (spellId ~= nil) then
			-- check if spell is on autocast, we should only display non-autocast spells
			autocastAllowed, autocastEnabled = GetSpellAutocast(i, BOOKTYPE_PET);
			--print("i " .. i .. ", spellType " .. MCTableToString(spellType) .. ", spellId " .. MCTableToString(spellId) .. ", autocastEnabled " .. MCTableToString(autocastEnabled));
			if (not autocastEnabled) then
				spellData = trackingHelper:getSpellData(spellId);
				-- check usual cooldown
				startTime, duration, enable = GetSpellCooldown(i, BOOKTYPE_PET);
				-- valid cooldown?
				if (startTime ~= nil and duration > 1.5) then
					--print("filling spelldId " .. MCTableToString(spellId) .. ", name " .. MCTableToString(spellData[1]) .. ", texture " .. MCTableToString(spellData[3]));
					cooldownId = cooldownId + 1;
					timer = self:findTimer(cooldownId, spellId);
					-- fill timer info, { type, timeLeft, duration, id, tooltipId, name, stacks, texture, exists, iterating, sortOrder }
					timer[1] = self.TIMER_TYPE_MASK_PETSPELL + self.TIMER_TYPE_MASK_ACTIVE; -- type
					timer[2] = startTime + duration - timerMs; -- timeLeft
					timer[3] = duration; -- duration
					timer[4] = spellId; -- id
					timer[5] = spellId; -- tooltipId
					timer[6] = spellData[1]; -- name
					timer[7] = 1; -- stacks
					timer[8] = spellData[3]; -- texture
				end
			end
		end
	end
	-- stop
	self:findSourceTimersEnd(3);
	-- updateTimers for other source groups
	self:forceUpdateTimers();
	-- dispatch event
	self:processDataChanged();
end

--- Update item cooldowns that are equipped by player (don't update cooldowns on items in bags, etc.)
function DHUDCooldownsTracker:updateItemCooldowns()
	local timerMs = trackingHelper.timerMs;
	-- create variables
	local cooldownId = 0;
	local startTime, duration, enable;
	local itemId, itemData;
	local timer;
	-- update item cooldowns
	self:findSourceTimersBegin(1);
	-- item cooldowns are only required for player, not vehicle
	if (self.unitId == "player") then
		-- iterate
		for i = 1, 17, 1 do -- INVSLOT_HEAD, INVSLOT_OFFHAND, 1
			startTime, duration, enable = GetInventoryItemCooldown(self.unitId, i);
			if (startTime ~= nil and duration > 1.5) then
				cooldownId = cooldownId + 1;
				itemId = GetInventoryItemID(self.unitId, i);
				itemData = trackingHelper:getItemData(itemId);
				timer = self:findTimer(cooldownId, itemId);
				-- fill timer info, { type, timeLeft, duration, id, tooltipId, name, stacks, texture, exists, iterating, sortOrder }
				timer[1] = self.TIMER_TYPE_MASK_ITEM + self.TIMER_TYPE_MASK_ACTIVE; -- type
				timer[2] = startTime + duration - timerMs; -- timeLeft
				timer[3] = duration; -- duration
				timer[4] = itemId; -- id
				timer[5] = i; -- tooltipId
				timer[6] = itemData[1]; -- name
				timer[7] = 0; -- stacks
				timer[8] = itemData[10]; -- texture
			end
		end
	end
	-- stop
	self:findSourceTimersEnd(1);
	-- updateTimers for other source groups
	self:forceUpdateTimers();
	-- dispatch event
	self:processDataChanged();
end

--- Update action bar cooldowns (such as ExtraButton or Vehicle Buttons)
function DHUDCooldownsTracker:updateActionBarCooldowns()
	local timerMs = trackingHelper.timerMs;
	-- create variables
	local cooldownId = 0;
	local startTime, duration, enable;
	local actionType, actionSubType, spellId, spellData;
	local timer;
	-- update action bar cooldowns
	self:findSourceTimersBegin(2);
	-- update extra action button spell cooldown ( /script print("id is " .. ActionButton_GetPagedID(ExtraActionButton1)) )
	if (self.unitId == "player") then
		-- iterate
		for i = 169, 169, 1 do
			startTime, duration, enable = GetActionCooldown(i);
			if (startTime ~= nil and duration > 1.5) then
				actionType, spellId, actionSubType = GetActionInfo(i);
				if (actionType == "spell") then
					cooldownId = cooldownId + 1;
					spellData = trackingHelper:getSpellData(spellId);
					timer = self:findTimer(cooldownId, spellId);
					-- fill timer info, { type, timeLeft, duration, id, tooltipId, name, stacks, texture, exists, iterating, sortOrder }
					timer[1] = self.TIMER_TYPE_MASK_SPELL + self.TIMER_TYPE_MASK_ACTIVE; -- type
					timer[2] = startTime + duration - timerMs; -- timeLeft
					timer[3] = duration; -- duration
					timer[4] = spellId; -- id
					timer[5] = spellId; -- tooltipId
					timer[6] = spellData[1]; -- name
					timer[7] = 0; -- stacks
					timer[8] = spellData[3]; -- texture
				end
			end
		end
	-- update vehicle cooldowns
	elseif (self.unitId == "vehicle") then
		-- iterate
		for i = 133, 138, 1 do
			startTime, duration, enable = GetActionCooldown(i);
			if (startTime ~= nil and duration > 1.5) then
				actionType, spellId, actionSubType = GetActionInfo(i);
				if (actionType == "spell") then
					cooldownId = cooldownId + 1;
					spellData = trackingHelper:getSpellData(spellId);
					timer = self:findTimer(cooldownId, spellId);
					-- fill timer info, { type, timeLeft, duration, id, tooltipId, name, stacks, texture, exists, iterating, sortOrder }
					timer[1] = self.TIMER_TYPE_MASK_SPELL + self.TIMER_TYPE_MASK_ACTIVE; -- type
					timer[2] = startTime + duration - timerMs; -- timeLeft
					timer[3] = duration; -- duration
					timer[4] = spellId; -- id
					timer[5] = spellId; -- tooltipId
					timer[6] = spellData[1]; -- name
					timer[7] = 0; -- stacks
					timer[8] = spellData[3]; -- texture
				end
			end
		end
	end
	-- stop
	self:findSourceTimersEnd(2);
	-- updateTimers for other source groups
	self:forceUpdateTimers();
	-- dispatch event
	self:processDataChanged();
	-- debug
	--[[for i=1, 10000 do -- Show all actions currently on cooldown
		local start,duration,enable = GetActionCooldown(i)
		if start > 0 and enable == 1 then
			local actiontype, id, subtype = GetActionInfo(i)
			local timeLeft = math.floor((start + duration) - GetTime())
			print("Cooldown on " .. i .. " " .. MCTableToString(actiontype) .. "[" .. MCTableToString(subtype) .. "] " .. MCTableToString(name) .. " (" .. MCTableToString(timeLeft) .. " seconds left)");
		end
	end]]--
end

--- Update item internal cooldowns that are equipped by player (e.g. trinkets that was added before 5.2)
function DHUDCooldownsTracker:updateItemInternalCooldowns()
	-- TODO
end

--- Update item rppm chances that are equipped by player (e.g. trinkets that was added after 5.2)
function DHUDCooldownsTracker:updateItemRealProcPerMinuteChances()
	-- TODO
end

--- Update all data for current unitId
function DHUDCooldownsTracker:updateData()
	self:updateSpellCooldowns();
	self:updateItemCooldowns();
	self:updateActionBarCooldowns();
	self:updatePetCooldowns();
end

--- Start tracking data
function DHUDCooldownsTracker:startTracking()
	-- listen to game combat events
	self.combatEventsFrame:RegisterEvent("SPELL_INTERRUPT");
	-- listen to game events
	self.eventsFrame:RegisterEvent("SPELL_UPDATE_COOLDOWN");
	self.eventsFrame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED");
	--self.eventsFrame:RegisterEvent("SPELL_UPDATE_USABLE");
	--self.eventsFrame:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN");
	--[[self.eventsFrame:RegisterEvent("ACTIONBAR_UPDATE_STATE");
	self.eventsFrame:RegisterEvent("ACTIONBAR_UPDATE_USABLE");
	self.eventsFrame:RegisterEvent("BAG_UPDATE_COOLDOWN");
	self.eventsFrame:RegisterEvent("UPDATE_INVENTORY_ALERTS");
	self.eventsFrame:RegisterEvent("UNIT_INVENTORY_CHANGED");
	self.eventsFrame:RegisterEvent("SPELL_ACTIVATION_OVERLAY_GLOW_SHOW");
	self.eventsFrame:RegisterEvent("SPELL_ACTIVATION_OVERLAY_GLOW_HIDE");]]--
	-- call super
	DHUDTimersTracker.startTracking(self);
end

--- Stop tracking data
function DHUDCooldownsTracker:stopTracking()
	-- stop listening to game combat events
	self.combatEventsFrame:UnregisterEvent("SPELL_INTERRUPT");
	-- stop listening to game events
	self.eventsFrame:UnregisterEvent("SPELL_UPDATE_COOLDOWN");
	self.eventsFrame:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED");
	--self.eventsFrame:UnregisterEvent("SPELL_UPDATE_USABLE");
	--self.eventsFrame:UnregisterEvent("ACTIONBAR_UPDATE_COOLDOWN");
	-- call super
	DHUDTimersTracker.stopTracking(self);
end

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
	-- nothing to update?
	if (#self.timers == 0) then
		return;
	end
	-- update guardians when last saved guardian timed out
	if (self:containsTimerWithNegativeDuration(1)) then
		self:updateGuardians();
	end
	-- call super
	DHUDTimersTracker.onUpdateTime(self);
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
		canHaveTwoAlternativeGuardians = select(2, GetTalentRowSelectionInfo(3)) == 8; -- TotemicPersistance
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

----------------------------------------
-- Unit aura value tracker base class --
----------------------------------------

--- Base class for trackers of aura value (actually it's subclasses will only set unitId to track, auras to track and max value)
DHUDAuraValueTracker = MCCreateSubClass(DHUDPowerTracker, {
	-- auras to track, aura value tracker will stop on first found aura from this list
	aurasToTrack = { },
	-- modifier to be used when calculating maximum aura value
	maxAuraValuePercentModifier = 1,
})

--- Create new aura value tracker, unitId should be specified after constructor
function DHUDAuraValueTracker:new()
	local o = self:defconstructor();
	o:constructor();
	return o;
end

--- Initialize aura value tracking
function DHUDAuraValueTracker:init()
	local tracker = self;
	-- process units absorb amount change event
	function self.eventsFrame:UNIT_AURA(unitId)
		if (tracker.unitId ~= unitId) then
			return;
		end
		tracker:updateAuraValue();
	end
end

--- Start tracking data
function DHUDAuraValueTracker:startTracking()
	-- listen to game events
	self.eventsFrame:RegisterEvent("UNIT_AURA");
end

--- Stop tracking data
function DHUDAuraValueTracker:stopTracking()
	-- stop listening to game events
	self.eventsFrame:UnregisterEvent("UNIT_AURA");
end

--- Update value for unit
function DHUDAuraValueTracker:updateAuraValue()
	local auraValue;
	-- iterate over auras spellids
	for i, v in ipairs(self.aurasToTrack) do
		--name, rank, icon, count, dispelType, duration, expires, caster, isStealable, shouldConsolidate, spellID, canApplyAura, isBossDebuff, value1, value2, value3
		auraValue = select(15, UnitAura(self.unitId, trackingHelper:getSpellName(v)));
		if (auraValue ~= nil) then
			break;
		end
	end
	self:setAmount(auraValue or 0);
end

--- Update maximum value for unit
function DHUDAuraValueTracker:updateAuraValueMax()
	self:setAmountMax(100);
end

--- Update all data for current unitId
function DHUDAuraValueTracker:updateData()
	self:updateAuraValue();
	self:updateAuraValueMax();
end

--- Set auras to track by data tracker
-- @param ... auras list, aura value tracker will stop on first found aura from this list
function DHUDAuraValueTracker:setAurasToTrack(...)
	self.aurasToTrack = { ... };
end

--- Set aura maximum value as percent of players health
-- @param percent percent of players health
function DHUDAuraValueTracker:setMaxAuraValueAsHealthPercent(percent)
	-- save percent
	self.maxAuraValuePercentModifier = percent;
	-- update functions to subscribe to game events about health
	local tracker = self;
	-- process units max health points change event
	function self.eventsFrame:UNIT_MAXHEALTH(unitId)
		if (tracker.unitId ~= unitId) then
			return;
		end
		tracker:updateAuraValueMax();
	end
	--- Update maximum value for unit
	function self:updateAuraValueMax()
		self:setAmountMax((UnitHealthMax(self.unitId) or 0) * self.maxAuraValuePercentModifier);
	end
	--- Start tracking amountMax data
	function self:startTrackingAmountMax()
		self.eventsFrame:RegisterEvent("UNIT_MAXHEALTH");
	end
	--- Update maximum amount or resource
	function self:updateAmountMax()
		self.eventsFrame:UNIT_MAXHEALTH(self.unitId);
	end
	--- Stop tracking amountMax data
	function self:stopTrackingAmountMax()
		self.eventsFrame:UnregisterEvent("UNIT_MAXHEALTH");
	end
end

--- Start tracking amountMax data
function DHUDAuraValueTracker:startTrackingAmountMax()
	
end

--- Update maximum amount or resource
function DHUDAuraValueTracker:updateAmountMax()
	
end

--- Stop tracking amountMax data
function DHUDAuraValueTracker:stopTrackingAmountMax()
	
end

--------------------------------------------
-- Unit specific power tracker base class --
--------------------------------------------

--- Base class to track unit specific resource, e.g. mana (actually it's subclasses will only set unitId to track and resource type)
DHUDSpecificPowerTracker = MCCreateSubClass(DHUDPowerTracker, {
	-- precision at which resource is tracked (can be used for soul shards, and embers), number of digits after comma
	precision			= 0,
	-- if true than this resource will also be updated by onUpdate event when in regeneration state, this variable should not be changed during runtime!
	updateFrequently	= true,
})

--- Create new specific power points tracker, unitId and resourceType should be specified after constructor
function DHUDSpecificPowerTracker:new()
	local o = self:defconstructor();
	o:constructor();
	return o;
end

--- Initialize specific power-points tracking
function DHUDSpecificPowerTracker:init()
	local tracker = self;
	-- process units power points change event
	function self.eventsFrame:UNIT_POWER(unitId, resourceTypeString)
		if (tracker.unitId ~= unitId) then
			return;
		end
		--[[if (unitId == "vehicle") then
			print("UNIT_POWER " .. MCTableToString(unitId) .. ", "  .. MCTableToString(resourceTypeString));
			print("tracker.resourceTypeString " .. tracker.resourceTypeString .. ", resourceTypeString " .. resourceTypeString);
		end]]--
		if (tracker.resourceTypeString ~= "" and tracker.resourceTypeString ~= resourceTypeString) then
			return;
		end
		tracker:updatePower();
	end
	-- process units max power points change event
	function self.eventsFrame:UNIT_MAXPOWER(unitId, resourceTypeString)
		if (tracker.unitId ~= unitId) then
			return;
		end
		--[[if (unitId == "vehicle") then
			print("UNIT_MAXPOWER " .. MCTableToString(unitId) .. ", "  .. MCTableToString(resourceTypeString) .. ", current " .. tracker.unitId);
		end]]--
		tracker:updateMaxPower();
		--[[if (unitId == "vehicle") then
			print("update max power to " .. MCTableToString(tracker.amountMax));
		end]]--
	end
	-- track maximum amount event if data tracker is not activated
	self.trackAmountMax = true;
end

--- Game time updated, update unit power
function DHUDSpecificPowerTracker:onUpdateTime()
	if (self.isRegenerating == true) then
		self:updatePower();
	end
end

--- Start tracking data
function DHUDSpecificPowerTracker:startTracking()
	-- listen to game events
	self.eventsFrame:RegisterEvent("UNIT_POWER");
	--print("self " .. self.trackUnitId .. " start amount data");
	if (self.updateFrequently) then
		trackingHelper:addEventListener(DHUDDataTrackerHelperEvent.EVENT_UPDATE, self, self.onUpdateTime);
	end
end

--- Stop tracking data
function DHUDSpecificPowerTracker:stopTracking()
	-- stop listening to game events
	self.eventsFrame:UnregisterEvent("UNIT_POWER");
	--print("self " .. self.trackUnitId .. " stop amount data");
	if (self.updateFrequently) then
		trackingHelper:removeEventListener(DHUDDataTrackerHelperEvent.EVENT_UPDATE, self, self.onUpdateTime);
	end
end

--- Start tracking amountMax data
function DHUDSpecificPowerTracker:startTrackingAmountMax()
	self.eventsFrame:RegisterEvent("UNIT_MAXPOWER");
	--print("self " .. self.trackUnitId .. " start amount max");
end

--- Update maximum amount or resource
function DHUDSpecificPowerTracker:updateAmountMax()
	self.eventsFrame:UNIT_MAXPOWER(self.unitId);
	--print("self " .. self.trackUnitId .. " update amount max");
end

--- Stop tracking amountMax data
function DHUDSpecificPowerTracker:stopTrackingAmountMax()
	self.eventsFrame:UnregisterEvent("UNIT_MAXPOWER");
	--print("self " .. self.trackUnitId .. " stop amount max");
end

--- Update power for unit
function DHUDSpecificPowerTracker:updatePower()
	local power;
	if (self.precision ~= 0) then
		power = UnitPower(self.unitId, self.resourceType, true);
		--print("powerWithPrecision " .. power);
		--print("powerWithoutPrecision " .. UnitPower(self.unitId, self.resourceType));
		power = power / (10 ^ self.precision);
	else
		power = UnitPower(self.unitId, self.resourceType);
	end
	--print("power is " .. power);
	self:setAmount(power);
end

--- Update maximum power for unit
function DHUDSpecificPowerTracker:updateMaxPower()
	local powerMax;
	if (self.precision ~= 0) then
		powerMax = UnitPowerMax(self.unitId, self.resourceType, true);
		powerMax = powerMax / (10 ^ self.precision);
	else
		powerMax = UnitPowerMax(self.unitId, self.resourceType);
	end
	self:setAmountMax(powerMax);
end

--- Update all data for current unitId
function DHUDSpecificPowerTracker:updateData()
	self:updateMaxPower();
	self:updatePower();
end

--- set tracking to be tracked only if resource is not main, should not be called if subclassed (this will override UNIT_DISPLAYPOWER event handling)
function DHUDSpecificPowerTracker:initTrackIfNotMain()
	local tracker = self;
	function self.eventsFrame:UNIT_DISPLAYPOWER(unitId)
		if (tracker.unitId ~= unitId) then
			return;
		end
		tracker:setIsExists(tracker:checkIsExists());
		--print("not main display power changed, exists: " .. MCTableToString(tracker.isExists));
	end
	-- update check is exists function to also check unit power
	function self:checkIsExists()
		if (not DHUDSpecificPowerTracker.checkIsExists(self)) then -- call super
			return false;
		end
		local powerType = UnitPowerType(self.unitId);
		--print("not main checkIsExists, main powerType " .. MCTableToString(powerType) .. ", tracked " .. MCTableToString(self.resourceType));
		return (powerType ~= self.resourceType);
	end
	-- register to display power event
	self.eventsFrame:RegisterEvent("UNIT_DISPLAYPOWER");
	self.eventsFrame:UNIT_DISPLAYPOWER(self.unitId);
end

----------------------------------------
-- Unit main power tracker base class --
----------------------------------------

--- Base class to track unit main resource, e.g. mana (actually it's subclasses will only set unitId to track and resource type)
DHUDMainPowerTracker = MCCreateSubClass(DHUDSpecificPowerTracker, {
	
})

--- Create new health points tracker, unitId should be specified after constructor
function DHUDMainPowerTracker:new()
	local o = self:defconstructor();
	o:constructor();
	return o;
end

--- Initialize main power-points tracking
function DHUDMainPowerTracker:init()
	local tracker = self;
	-- process units power points type change event
	function self.eventsFrame:UNIT_DISPLAYPOWER(unitId)
		if (tracker.unitId ~= unitId) then
			return;
		end
		--[[if (unitId == "vehicle") then
			print("UNIT_DISPLAYPOWER " .. MCTableToString(unitId) .. ", "  .. MCTableToString(resourceTypeString) .. ", current " .. tracker.unitId);
		end]]--
		tracker:updatePowerType();
		--print("update display power to " .. MCTableToString(tracker.resourceType) .. ", " .. MCTableToString(tracker.resourceTypeString));
	end
	-- call super
	DHUDSpecificPowerTracker.init(self);
end

--- Update unit power type
function DHUDMainPowerTracker:updatePowerType()
	local powerType, powerTypeString = UnitPowerType(self.unitId);
	--print("powerType " .. powerType .. ", powerTypeString " .. powerTypeString);
	-- update resource
	self:setResourceType(powerType, powerTypeString);
end

--- Start tracking amountMax data
function DHUDMainPowerTracker:startTrackingAmountMax()
	self.eventsFrame:RegisterEvent("UNIT_DISPLAYPOWER");
	DHUDSpecificPowerTracker.startTrackingAmountMax(self); -- call super
end

--- Update maximum amount or resource
function DHUDMainPowerTracker:updateAmountMax()
	self.eventsFrame:UNIT_DISPLAYPOWER(self.unitId);
	DHUDSpecificPowerTracker.updateAmountMax(self); -- call super
end

--- Stop tracking amountMax data
function DHUDMainPowerTracker:stopTrackingAmountMax()
	self.eventsFrame:UnregisterEvent("UNIT_DISPLAYPOWER");
	DHUDSpecificPowerTracker.stopTrackingAmountMax(self); -- call super
end

--- Update all data for current unitId
function DHUDMainPowerTracker:updateData()
	self:updatePowerType();
	-- call super
	DHUDSpecificPowerTracker.updateData(self);
end

----------------------------
-- Unit spellcast tracker --
----------------------------
--- Base class to track unit spell castings, spells channeling and delays
DHUDSpellCastTracker = MCCreateSubClass(DHUDDataTracker, {
	-- defines if current unit has casted something or not (updated after unit change)
	hasCasted			= false,
	-- defines if current unit is casting or channgeling something or not
	isCasting			= false,
	-- defines if current spell is channeling
	isChannelSpell		= false,
	-- defines if current spell is interruptable, e.g. no lock
	isInterruptible		= true,
	-- time at which the spell casting was started, in seconds
	timeStart			= 0,
	-- amount of time the spell is casting or amount of time for channel to end, in seconds, this value may be less than zero as reported by game!
	timeProgress		= 0,
	-- total amount of time this spell will be casted, in seconds
	timeTotal			= 0,
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
	-- name of the spell being casted
	spellName			= "",
	-- path to the texture associated with spell
	spellTexture		= "",
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
	DHUDPowerTracker.constructor(self);
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

--- Game time updated, update spell cast progress, updated every 100 ms, animation should use it's own timer
function DHUDSpellCastTracker:onUpdateTime()
	if (self.isCasting == false) then
		return;
	end
	local timerMs = trackingHelper.timerMs;
	local diff = timerMs - self.timeUpdatedAt;
	if (diff <= 0) then
		return;
	end
	-- update timer
	if (self.isChannelSpell) then
		self.timeProgress = self.timeProgress - diff;
	else
		self.timeProgress = self.timeProgress + diff;
	end
	-- update timeUpdated var
	self.timeUpdatedAt = timerMs;
	-- dispatch event
	self:dispatchEvent(self.eventDataTimersChanged);
end

--- Get spell cast progress, updating value according to current game time
function DHUDSpellCastTracker:getTimeProgress()
	local timerMs = trackingHelper.timerMs;
	local diff = timerMs - self.timeUpdatedAt;
	local progress;
	if (self.isChannelSpell) then
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
	self.isChannelSpell = false;
	self:setIsRegenerating(true);
	self.finishState = self.SPELL_FINISH_STATE_IS_CASTING;
	-- update spell cast info
	local timerMs = trackingHelper:getTimerMs();
	local name, nameSubtext, text, texture, startTime, endTime, isTradeSkill, castID, notInterruptible = UnitCastingInfo(self.unitId);
	self.isInterruptible = not notInterruptible;
	self.spellName = name;
	self.spellTexture = texture;
	self.timeStart = startTime / 1000;
	self.timeTotal = (endTime - startTime) / 1000;
	self.timeProgress = timerMs - startTime / 1000;
	self.delay = 0;
	self.timeUpdatedAt = timerMs;
	--print("startTime " .. startTime .. ", endTime " .. endTime .. ", timerMs " .. timerMs);
	-- process data change
	self:processDataChanged();
end

--- update spell cast delay
function DHUDSpellCastTracker:updateSpellCastDelay()
	-- update delay
	local timerMs = trackingHelper:getTimerMs();
	local name, nameSubtext, text, texture, startTime, endTime, isTradeSkill, castID, notInterruptible = UnitCastingInfo(self.unitId);
	local newTimeTotal = endTime / 1000 - self.timeStart;
	self.delay = newTimeTotal - self.timeTotal;
	self.timeProgress = timerMs - startTime / 1000;
	self.timeUpdatedAt = timerMs;
	--print("delay startTime " .. startTime .. ", endTime " .. endTime .. ", timerMs " .. timerMs .. ", delay " .. self.delay);
	-- process data change
	self:processDataChanged();
end

--- update spell cast time
function DHUDSpellCastTracker:updateSpellCastTime()
	-- update time
	local timerMs = trackingHelper:getTimerMs();
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
	self.isChannelSpell = true;
	self:setIsRegenerating(true);
	self.finishState = self.SPELL_FINISH_STATE_IS_CASTING;
	-- update channel cast info
	local timerMs = trackingHelper:getTimerMs();
	local name, nameSubtext, text, texture, startTime, endTime, isTradeSkill, notInterruptible = UnitChannelInfo(self.unitId);
	self.isInterruptible = not notInterruptible;
	self.spellName = name;
	self.spellTexture = texture;
	self.timeStart = startTime / 1000;
	self.timeTotal = (endTime - startTime) / 1000;
	self.timeProgress = endTime / 1000 - timerMs;
	self.delay = 0;
	self.timeUpdatedAt = timerMs;
	-- process data change
	self:processDataChanged();
end

--- update spell cast delay
function DHUDSpellCastTracker:updateSpellChannelDelay()
	-- update delay
	local timerMs = trackingHelper:getTimerMs();
	local name, nameSubtext, text, texture, startTime, endTime, isTradeSkill, notInterruptible = UnitChannelInfo(self.unitId);
	if (name == nil) then
		--print("noChannelInfo");
		return;
	end
	local newTimeTotal = endTime / 1000 - self.timeStart;
	self.delay = newTimeTotal - self.timeTotal;
	--print("delay is " .. self.delay);
	self.timeProgress = endTime / 1000 - timerMs;
	self.timeUpdatedAt = timerMs;
	-- process data change
	self:processDataChanged();
end

--- update channel cast time
function DHUDSpellCastTracker:updateSpellChannelTime()
	-- update time
	local timerMs = trackingHelper:getTimerMs();
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
		if (self.isChannelSpell) then
			self:updateSpellChannelTime();
		else
			self:updateSpellCastTime();
		end
	end
	-- update stop info
	self.isCasting = false;
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
end

--- Stop tracking data
function DHUDSpellCastTracker:stopTracking()
	-- stop listen to combat game events
	self.combatEventsFrame:UnregisterEvent("SPELL_INTERRUPT");
	-- stop listening to game events
	self.eventsFrame:UnregisterEvent("UNIT_SPELLCAST_CHANNEL_START");
	self.eventsFrame:UnregisterEvent("UNIT_SPELLCAST_CHANNEL_STOP");
	self.eventsFrame:UnregisterEvent("UNIT_SPELLCAST_CHANNEL_UPDATE");
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
end

--- Update all data for current unitId
function DHUDSpellCastTracker:updateData()
	self:updateSpellCastStopReason(self.SPELL_FINISH_STATE_NOT_CASTING);
	self:updateSpellCastStop();
end

--- set unitId variable
-- @param unitId new unitId value
-- @param dispatchUnitChange causes unit change event to be dispatched
function DHUDSpellCastTracker:setUnitId(unitId, dispatchUnitChange)
	self.hasCasted = false;
	DHUDDataTracker.setUnitId(self, unitId, dispatchUnitChange); -- call super
end

-----------------------
-- Unit info tracker --
-----------------------
--- Base class to track unit spell castings, spells channeling and delays
DHUDUnitInfoTracker = MCCreateSubClass(DHUDDataTracker, {
	-- unit name
	name				= "",
	-- name of the guild
	guild				= "",
	-- defines unit type
	type				= 0,
	-- defines unit relation, e.g. friendly, neutral, or hostile
	relation			= 0,
	-- defines if unit can be attacked
	canAttack			= false,
	-- unit level
	level				= 0,
	-- unit class name
	class				= "",
	-- unit english class name
	classEng			= "",
	-- unit specialization id
	spec				= 0,
	-- texture of the specialization
	specTexture			= "",
	-- unit specialization role (e.g. "TANK")
	specRole			= "",
	-- defines unit elite type, e.g. golden dragon or silver dragon
	eliteType			= 0,
	-- type of the npc, e.g. critter
	npcType				= 0,
	-- defines if player will receive credit for killing unit
	tagged				= true,
	-- defines if anyone can tag unit and receive credit for killing unit
	communityTagged		= true,
	-- defines number of raid icon on unit, 0 = no icon
	raidIcon			= 0,
	-- defines unit pvp faction, e.g. alliance or horde
	pvpFaction			= 0,
	-- defines if unit pvp faction differs from player
	isDifferentPvPFaction = false,
	-- defines unit pvp state
	pvpState			= 0,
	-- unit is player
	UNIT_TYPE_PLAYER	= 0,
	-- unit is pet
	UNIT_TYPE_PET		= 1,
	-- unit is an ally npc
	UNIT_TYPE_ALLY_NPC	= 2,
	-- unit is not any of the above
	UNIT_TYPE_OTHER		= 3,
	-- unit faction is neutral
	UNIT_PVP_FACTION_NONE = 0,
	-- unit faction is alliance
	UNIT_PVP_FACTION_ALLIANCE = 1,
	-- unit faction is horde
	UNIT_PVP_FACTION_HORDE = 2,
	-- unit is not flagged for pvp
	UNIT_PVP_STATE_OFF = 0,
	-- unit is flagged for pvp
	UNIT_PVP_STATE_ON = 1,
	-- unit is flagged for pvp in arena
	UNIT_PVP_STATE_FFA = 2,
	-- unit is hostile to player
	UNIT_RELATION_HOSTILE = -1,
	-- unit is neutral to player
	UNIT_RELATION_NEUTRAL = 0,
	-- unit is friendly to player
	UNIT_RELATION_FRIENDLY = 1,
	-- unit is not elite
	UNIT_ELITE_TYPE_NONE	= 0,
	-- unit is minion and has low health amount
	UNIT_ELITE_TYPE_MINION	= 1,
	-- unit is rare, e.g. silver dragon in standard interface
	UNIT_ELITE_TYPE_RARE	= 2,
	-- unit is elite, e.g. golden dragon in standard interface
	UNIT_ELITE_TYPE_ELITE	= 3,
	-- unit is elite and rare, e.g. silver dragon in standard interface
	UNIT_ELITE_TYPE_RAREELITE	= 4,
	--  unit is boss and elite, e.g. golden dragon in standard interface
	UNIT_ELITE_TYPE_BOSS = 5,
})

--- Create new unit info tracker, unitId should be specified after constructor
function DHUDUnitInfoTracker:new()
	local o = self:defconstructor();
	o:constructor();
	return o;
end

--- Initialize health-points tracking
function DHUDUnitInfoTracker:init()
	local tracker = self;
	-- process unit name change event
	function self.eventsFrame:UNIT_NAME_UPDATE(unitId)
		if (tracker.unitId ~= unitId) then
			return;
		end
		tracker:updateUnitName();
	end
	-- process unit faction change event
	function self.eventsFrame:UNIT_FACTION(unitId)
		if (tracker.unitId ~= unitId) then
			return;
		end
		tracker:updateRelation();
		tracker:updateTagging();
		tracker:updatePvPInfo();
	end
	-- process unit classification change event
	function self.eventsFrame:UNIT_CLASSIFICATION_CHANGED(unitId)
		if (tracker.unitId ~= unitId) then
			return;
		end
		tracker:updateEliteType();
	end
	-- process unit level change event
	function self.eventsFrame:UNIT_LEVEL(unitId)
		if (tracker.unitId ~= unitId) then
			return;
		end
		tracker:updateLevel();
	end
	-- process unit specialization (not only player) change event
	function self.eventsFrame:PLAYER_SPECIALIZATION_CHANGED(unitId)
		tracker:updateSpecialization();
	end
	-- process raid target icon change event
	function self.eventsFrame:RAID_TARGET_UPDATE(unitId)
		tracker:updateRaidIcon();
	end
end

--- Update name of the unit
function DHUDUnitInfoTracker:updateUnitName()
	self.name = UnitName(self.unitId);
	self:processDataChanged();
end

--- Update guild name of the unit
function DHUDUnitInfoTracker:updateGuildName()
	self.guild = GetGuildInfo(self.unitId);
	self:processDataChanged();
end

--- update information about unit type
function DHUDUnitInfoTracker:updateUnitType()
	self.type = self.UNIT_TYPE_OTHER;
	if (UnitIsPlayer(self.unitId)) then
		self.type = self.UNIT_TYPE_PLAYER;
	elseif (not UnitCanAttack("player", self.unitId)) then
		if (UnitPlayerControlled(self.unitId) == 1) then
			self.type = self.UNIT_TYPE_PET;
		else
			self.type = self.UNIT_TYPE_ALLY_NPC;
		end
	end
	self:processDataChanged();
end

--- update unit relation info
function DHUDUnitInfoTracker:updateRelation()
	local reaction = UnitReaction("player", self.unitId) or 4;
	if (reaction < 4) then
		self.relation = self.UNIT_RELATION_HOSTILE;
	elseif (reaction > 4) then
		self.relation = self.UNIT_RELATION_FRIENDLY;
	else
		self.relation = self.UNIT_RELATION_NEUTRAL;
	end
	self.canAttack = UnitCanAttack("player", self.unitId) == 1;
	self:processDataChanged();
end

--- update unit level information
function DHUDUnitInfoTracker:updateLevel()
	self.level = UnitLevel(self.unitId);
	self:processDataChanged();
end

--- update unit class information
function DHUDUnitInfoTracker:updateClass()
	self.class, self.classEng = UnitClass(self.unitId);
	self:processDataChanged();
end

--- update unit spec information
function DHUDUnitInfoTracker:updateSpecialization()
	--[[self.spec = GetInspectSpecialization(self.unitId);
	local id, name, description, icon, background, role = GetSpecializationInfoByID(self.spec);
	self.specTexture = icon;
	self.specRole = role;]]--
	self:processDataChanged();
end

--- update unit classification information
function DHUDUnitInfoTracker:updateEliteType()
	local classification = UnitClassification(self.unitId);
	if (classification == "worldboss") then
		self.eliteType = self.UNIT_ELITE_TYPE_BOSS;
	elseif (classification == "rareelite") then
		self.eliteType = self.UNIT_ELITE_TYPE_RAREELITE;
	elseif (classification == "elite") then
		self.eliteType = self.UNIT_ELITE_TYPE_ELITE;
	elseif (classification == "rare") then
		self.eliteType = self.UNIT_ELITE_TYPE_RARE;
	elseif (classification == "minus") then
		self.eliteType = self.UNIT_ELITE_TYPE_MINION;
	else
		self.eliteType = self.UNIT_ELITE_TYPE_NONE;
	end
	self:processDataChanged();
end

--- update unit npc type information
function DHUDUnitInfoTracker:updateNpcType()
	self.npcType = UnitCreatureType(self.unitId);
	self.isNPC = 
	self:processDataChanged();
end

--- update unit tagging information
function DHUDUnitInfoTracker:updateTagging()
	local tapped = UnitIsTapped(self.unitId);
	self.tagged = not(tapped and not UnitIsTappedByPlayer(self.unitId));
	self.communityTagged = UnitIsTappedByAllThreatList(self.unitId) == 1;
	--print("UnitIsTappedByAllThreatList(self.unitId) " .. MCTableToString(UnitIsTappedByAllThreatList(self.unitId)));
	self:processDataChanged();
end


--- update unit raid icon information
function DHUDUnitInfoTracker:updateRaidIcon()
	self.raidIcon = GetRaidTargetIndex(self.unitId);
	self:processDataChanged();
end

--- update unit pvp information
function DHUDUnitInfoTracker:updatePvPInfo()
	local faction = UnitFactionGroup(self.unitId);
	local playerFaction = UnitFactionGroup("player");
	if (faction == "Alliance") then
		self.pvpFaction = self.UNIT_PVP_FACTION_ALLIANCE;
	elseif (faction == "Horde") then
		self.pvpFaction = self.UNIT_PVP_FACTION_HORDE;
	else
		self.pvpFaction = self.UNIT_PVP_FACTION_NONE;
	end
	self.isDifferentPvPFaction = faction ~= playerFaction;
	local isPvP = UnitIsPVP(self.unitId);
	local isPvPFFA = UnitIsPVPFreeForAll(self.unitId);
	if (not isPvP) then
		self.pvpState = self.UNIT_PVP_STATE_OFF;
	elseif (isPvPFFA) then
		self.pvpState = self.UNIT_PVP_STATE_FFA;
	else
		self.pvpState = self.UNIT_PVP_STATE_ON;
	end
	self:processDataChanged();
end

--- Start tracking data
function DHUDUnitInfoTracker:startTracking()
	-- listen to game events
	self.eventsFrame:RegisterEvent("UNIT_NAME_UPDATE");
	self.eventsFrame:RegisterEvent("UNIT_FACTION");
	self.eventsFrame:RegisterEvent("UNIT_CLASSIFICATION_CHANGED");
	self.eventsFrame:RegisterEvent("UNIT_LEVEL");
	self.eventsFrame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED");
	self.eventsFrame:RegisterEvent("RAID_TARGET_UPDATE");
end

--- Stop tracking data
function DHUDUnitInfoTracker:stopTracking()
	-- stop listening to game events
	self.eventsFrame:UnregisterEvent("UNIT_NAME_UPDATE");
	self.eventsFrame:UnregisterEvent("UNIT_FACTION");
	self.eventsFrame:UnregisterEvent("UNIT_CLASSIFICATION_CHANGED");
	self.eventsFrame:UnregisterEvent("UNIT_LEVEL");
	self.eventsFrame:UnregisterEvent("PLAYER_SPECIALIZATION_CHANGED");
	self.eventsFrame:UnregisterEvent("RAID_TARGET_UPDATE");
end

--- Update all data for current unitId
function DHUDUnitInfoTracker:updateData()
	self:updateUnitName();
	self:updateGuildName();
	self:updateUnitType();
	self:updateRelation();
	self:updateLevel();
	self:updateClass();
	self:updateSpecialization();
	self:updateEliteType();
	self:updateNpcType();
	self:updateTagging();
	self:updateRaidIcon();
	self:updatePvPInfo();
end

-----------------------
-- Self info tracker --
-----------------------
--- Base class to track unit spell castings, spells channeling and delays
DHUDSelfInfoTracker = MCCreateSubClass(DHUDUnitInfoTracker, {
	-- defines if unit is resting in the inn (self only)
	isResting			= false,
	-- defines if unit is affecting combat (self only)
	isInCombat			= false,
})

--- Create new unit info tracker, unitId should be specified after constructor
function DHUDSelfInfoTracker:new()
	local o = self:defconstructor();
	o:constructor();
	return o;
end

--- Initialize health-points tracking
function DHUDSelfInfoTracker:init()
	local tracker = self;
	-- process unit name change event
	function self.eventsFrame:PLAYER_GUILD_UPDATE()
		tracker:updateGuildName();
	end
	-- init player only tracking
	self:initPlayerUnitId();
	-- call super
	DHUDUnitInfoTracker.init(self);
end

--- resting state has changed, update
function DHUDSelfInfoTracker:onRestingState(e)
	self.isResting = trackingHelper.isResting;
	self:processDataChanged();
end

--- combat state has changed, update
function DHUDSelfInfoTracker:onCombatState(e)
	self.isInCombat = trackingHelper.isInCombat;
	self:processDataChanged();
end

--- Start tracking data
function DHUDSelfInfoTracker:startTracking()
	-- listen to game events
	self.eventsFrame:RegisterEvent("PLAYER_GUILD_UPDATE");
	trackingHelper:addEventListener(DHUDDataTrackerHelperEvent.EVENT_RESTING_STATE_CHANGED, self, self.onRestingState);
	trackingHelper:addEventListener(DHUDDataTrackerHelperEvent.EVENT_COMBAT_STATE_CHANGED, self, self.onCombatState);
	-- call super
	DHUDUnitInfoTracker.startTracking(self);
end

--- Stop tracking data
function DHUDSelfInfoTracker:stopTracking()
	-- stop listening to game events
	self.eventsFrame:UnregisterEvent("PLAYER_GUILD_UPDATE");
	trackingHelper:removeEventListener(DHUDDataTrackerHelperEvent.EVENT_RESTING_STATE_CHANGED, self, self.onRestingState);
	trackingHelper:removeEventListener(DHUDDataTrackerHelperEvent.EVENT_COMBAT_STATE_CHANGED, self, self.onCombatState);
	-- call super
	DHUDUnitInfoTracker.stopTracking(self);
end

--- Update all data for current unitId
function DHUDSelfInfoTracker:updateData()
	self:onRestingState(nil);
	self:onCombatState(nil);
	-- call super
	DHUDUnitInfoTracker.updateData(self);
end

---------------------------------
-- Player Combo-points Tracker --
---------------------------------
--- Class to track players combopoints
local DHUDPlayerComboPointsTracker = MCCreateSubClass(DHUDSpecificPowerTracker, {
	-- maximum of 5 combo-points
	amountMax			= 5,
	-- default maximum of 5 combo-points
	amountMaxDefault	= 5,
	-- default base of 0 combo-points
	amountBase			= 0,
	-- spell id of the rogue buff for bonus combo-points
	SPELLID_ROGUE_ANTICIPATION = 115189,
})
		
--- Create new combo points tracker for player and vehicle
function DHUDPlayerComboPointsTracker:new()
	local o = self:defconstructor();
	o:constructor();
	return o;
end
		
--- Initialize combo-points tracking
function DHUDPlayerComboPointsTracker:init()
	local tracker = self;
	-- call super
	DHUDSpecificPowerTracker.init(self);
	-- set unit power type
	self:setResourceType(4, "COMBO_POINTS");
	-- combopoints available only for druid and rogue
	if (trackingHelper.playerClass == "ROGUE" or trackingHelper.playerClass == "DRUID") then
		self:initPlayerNotInVehicleOrNoneUnitId();
	end
	-- process aura changing and data update for rogues
	if (trackingHelper.playerClass == "ROGUE") then
		function self.eventsFrame:UNIT_AURA(unitId)
			if (unitId == tracker.unitId) then
				tracker:updateRogueAnticipation();
			end
		end
		--- Update all data for current unitId
		function self:updateData()
			self:updateRogueAnticipation();
			-- call super
			DHUDSpecificPowerTracker.updateData(self);
		end
	end
end

--- Start tracking data
function DHUDPlayerComboPointsTracker:startTracking()
	-- listen to game events
	if (trackingHelper.playerClass == "ROGUE") then
		self.eventsFrame:RegisterEvent("UNIT_AURA");
	end
	-- call super
	DHUDSpecificPowerTracker.startTracking(self);
end

--- Stop tracking data
function DHUDPlayerComboPointsTracker:stopTracking()
	-- stop listening to game events
	if (trackingHelper.playerClass == "ROGUE") then
		self.eventsFrame:UnregisterEvent("UNIT_AURA");
	end
	-- call super
	DHUDSpecificPowerTracker.stopTracking(self);
end

--- Update number of rogue anticipation stacks
function DHUDPlayerComboPointsTracker:updateRogueAnticipation()
	-- add anticipation for rogues
	if (self.amountExtra > 0 or self.amount >= self.amountMax) then
		local buffcount;
		_, _, _, buffcount = UnitBuff(self.unitId, trackingHelper:getSpellName(self.SPELLID_ROGUE_ANTICIPATION));
		if (buffcount) then
			self:setAmountExtra(buffcount);
		else
			self:setAmountExtra(0);
		end
	end
end

-----------------------------------------
-- Vehicle Combo-points Tracker --
-----------------------------------------
--- Class to track vehicle combopoints
local DHUDVehicleComboPointsTracker = MCCreateSubClass(DHUDPowerTracker, {
	-- maximum of 5 combo-points
	amountMax			= 5,
	-- default maximum of 5 combo-points
	amountMaxDefault	= 5,
	-- default base of 0 combo-points
	amountBase			= 0,
})
		
--- Create new combo points tracker for player and vehicle
function DHUDVehicleComboPointsTracker:new()
	local o = self:defconstructor();
	o:constructor();
	return o;
end
		
--- Initialize combo-points tracking
function DHUDVehicleComboPointsTracker:init()
	local tracker = self;
	-- process combo point event
	function self.eventsFrame:UNIT_COMBO_POINTS()
		tracker:updateComboPoints();
	end
	-- init unit ids
	self:initVehicleOrNoneUnitId();
end

--- Start tracking data
function DHUDVehicleComboPointsTracker:startTracking()
	-- listen to game events
	self.eventsFrame:RegisterEvent("UNIT_COMBO_POINTS");
end

--- Stop tracking data
function DHUDVehicleComboPointsTracker:stopTracking()
	-- stop listening to game events
	self.eventsFrame:UnregisterEvent("UNIT_COMBO_POINTS");
end

--- Update combopoints data
function DHUDVehicleComboPointsTracker:updateComboPoints()
	self:setAmount(GetComboPoints(self.unitId, "target"));
end

--- Update all data for current unitId
function DHUDVehicleComboPointsTracker:updateData()
	self:updateComboPoints();
end

--------------------
-- Trackers table --
--------------------

--- Table with data trackers
DHUDDataTrackers = {
	-- trackers that are used by any class
	ALL = {},
	fillAll = function(self, charclass)
		-- fill table with trackers
		local ALL = self.ALL;
		-------------------------
		-- Player Combo Points --
		-------------------------
		ALL.selfComboPoints = DHUDPlayerComboPointsTracker:new();

		--------------------------
		-- Vehicle Combo Points --
		--------------------------
		ALL.vehicleComboPoints = DHUDVehicleComboPointsTracker:new();

		---------------------------
		-- Player/Vehicle Health --
		---------------------------
		ALL.selfHealth = DHUDHealthTracker:new();
		ALL.selfHealth:initPlayerOrVehicleUnitId();
		
		------------------------------
		-- Player Health in Vehicle --
		------------------------------
		ALL.selfCharInVehicleHealth = DHUDHealthTracker:new();
		ALL.selfCharInVehicleHealth:initPlayerInVehicleOrNoneUnitId();

		-------------------
		-- Target Health --
		-------------------
		ALL.targetHealth = DHUDHealthTracker:new();
		ALL.targetHealth:initTargetUnitId();

		----------------
		-- Pet Health --
		----------------
		ALL.petHealth = DHUDHealthTracker:new();
		ALL.petHealth:initPetOrNoneUnitId();
		
		-----------------------
		-- Player Main Power --
		-----------------------
		ALL.selfPower = DHUDMainPowerTracker:new();
		ALL.selfPower:initPlayerOrVehicleUnitId();
		
		-----------------------
		-- Target Main Power --
		-----------------------
		ALL.targetPower = DHUDMainPowerTracker:new();
		ALL.targetPower:initTargetUnitId();

		-----------------------
		-- Target Main Power --
		-----------------------
		ALL.selfCharInVehiclePower = DHUDMainPowerTracker:new();
		ALL.selfCharInVehiclePower:initPlayerInVehicleOrNoneUnitId();
		
		--------------------
		-- Pet Main Power --
		--------------------
		ALL.petPower = DHUDMainPowerTracker:new();
		ALL.petPower:initPetOrNoneUnitId();
		
		----------------------
		-- Player cast info --
		----------------------
		ALL.selfCast = DHUDSpellCastTracker:new();
		ALL.selfCast:initPlayerOrVehicleUnitId();

		----------------------
		-- Target cast info --
		----------------------
		ALL.targetCast = DHUDSpellCastTracker:new();
		ALL.targetCast:initTargetUnitId();
		
		-----------------
		-- Player Info --
		-----------------
		ALL.selfInfo = DHUDSelfInfoTracker:new();
		
		-----------------
		-- Target Info --
		-----------------
		ALL.targetInfo = DHUDUnitInfoTracker:new();
		ALL.targetInfo:initTargetUnitId();
		ALL.targetHealth:attachCreditTracker(ALL.targetInfo);
		
		---------------------------
		-- Target of Target Info --
		---------------------------
		ALL.targetOfTargetInfo = DHUDUnitInfoTracker:new();
		ALL.targetOfTargetInfo:initTargetOfTargetUnitId();

		---------------
		-- Vengeance --
		---------------
		ALL.vengeanceInfo = DHUDAuraValueTracker:new();
		ALL.vengeanceInfo:initPlayerNotInVehicleOrNoneUnitId();
		ALL.vengeanceInfo:initPlayerSpecsOnly(trackingHelper:getTankSpecializations());
		ALL.vengeanceInfo:setAurasToTrack(158300); -- old vengeance 132365
		ALL.vengeanceInfo:setAmountMax(200); -- max value is in percent
		ALL.vengeanceInfo:setCustomResourceType(DHUDColorizeTools.COLOR_ID_TYPE_CUSTOM_VENGEANCE);

		------------
		-- Threat --
		------------
		
		--------------------------
		-- Player/Vehicle Auras --
		--------------------------
		ALL.selfAuras = DHUDAurasTracker:new();
		ALL.selfAuras:initPlayerOrVehicleUnitId();

		------------------
		-- Target Auras --
		------------------
		ALL.targetAuras = DHUDAurasTracker:new();
		ALL.targetAuras:initTargetUnitId();

		-----------------------------
		-- Cooldowns, Trinket ICDs --
		-----------------------------
		ALL.selfCooldowns = DHUDCooldownsTracker:new();
		ALL.selfCooldowns:initPlayerOrVehicleUnitId();

		---------------
		-- Range (?) --
		---------------
	end,
	-- trackers that are used by death knight
	DEATHKNIGHT = { },
	fillDEATHKNIGHT = function(self, charclass)
		-- fill table with trackers
		local DEATHKNIGHT = self.DEATHKNIGHT;
		-----------
		-- Runes --
		-----------
		--- Class to track players runes
		local DHUDRunesTracker = MCCreateSubClass(DHUDPowerTracker, {
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
			function self.eventsFrame:RUNE_TYPE_UPDATE()
				tracker:updateRuneTypes();
			end
			-- init unit ids
			self:initPlayerNotInVehicleOrNoneUnitId();
		end
		
		--- Update rune types through API
		function DHUDRunesTracker:updateRuneTypes()
			-- create vars
			local runeType; -- 1 : RUNETYPE_BLOOD, 2 : RUNETYPE_CHROMATIC, 3 : RUNETYPE_FROST, 4 : RUNETYPE_DEATH
			-- update runes
			for i = 1, 6, 1 do
				runeType = GetRuneType(i);
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
			self.eventsFrame:RegisterEvent("RUNE_TYPE_UPDATE");
			trackingHelper:addEventListener(DHUDDataTrackerHelperEvent.EVENT_UPDATE, self, self.onUpdateTime);
		end

		--- Stop tracking data
		function DHUDRunesTracker:stopTracking()
			-- stop listening to game events
			self.eventsFrame:UnregisterEvent("RUNE_POWER_UPDATE");
			self.eventsFrame:UnregisterEvent("RUNE_TYPE_UPDATE");
			trackingHelper:removeEventListener(DHUDDataTrackerHelperEvent.EVENT_UPDATE, self, self.onUpdateTime);
		end
		
		--- Update all data for current unitId
		function DHUDRunesTracker:updateData()
			self:updateRuneTypes();
			self:updateRuneCooldowns();
		end
		DEATHKNIGHT.selfRunes = DHUDRunesTracker:new();
	end,
	-- trackers that are used by druid
	DRUID = { },
	fillDRUID = function(self, charclass)
		-- fill table with trackers
		local DRUID = self.DRUID;
		--------------------------------
		-- Mana in bear and cat forms --
		--------------------------------
		DRUID.selfMana = DHUDSpecificPowerTracker:new();
		DRUID.selfMana:setResourceType(0, "MANA");
		DRUID.selfMana:initPlayerNotInVehicleOrNoneUnitId();
		DRUID.selfMana:initTrackIfNotMain();
		
		------------------------------------
		-- Energy in bear and usual forms --
		------------------------------------
		DRUID.selfEnergy = DHUDSpecificPowerTracker:new();
		DRUID.selfEnergy:setResourceType(3, "ENERGY");
		DRUID.selfEnergy:initPlayerNotInVehicleOrNoneUnitId();
		DRUID.selfEnergy:initTrackIfNotMain();

		------------------------------
		-- Eclipse for moonkin form --
		------------------------------
		DRUID.selfEclipse = DHUDSpecificPowerTracker:new();
		DRUID.selfEclipse.canRegenerate = false;
		DRUID.selfEclipse:setResourceType(8, "ECLIPSE");
		DRUID.selfEclipse:initPlayerNotInVehicleOrNoneUnitId();
		DRUID.selfEclipse:initPlayerSpecsOnly(1);
		DRUID.selfEclipse.updateFrequently = false;
	end,
	-- trackers that are used by monk
	MONK = { },
	fillMONK = function(self, charclass)
		-- fill table with trackers
		local MONK = self.MONK;
		-------------------------------------
		-- Mana when not in serpent stance --
		-------------------------------------
		MONK.selfMana = DHUDSpecificPowerTracker:new();
		MONK.selfMana:setResourceType(0, "MANA");
		MONK.selfMana:initPlayerSpecsOnly(2);
		MONK.selfMana:initPlayerNotInVehicleOrNoneUnitId();
		MONK.selfMana:initTrackIfNotMain();
		
		-----------------------------------
		-- Energy when in serpent stance --
		-----------------------------------
		MONK.selfEnergy = DHUDSpecificPowerTracker:new();
		MONK.selfEnergy:setResourceType(3, "ENERGY");
		MONK.selfEnergy:initPlayerNotInVehicleOrNoneUnitId();
		MONK.selfEnergy:initTrackIfNotMain();

		---------
		-- Chi --
		---------
		MONK.selfChi = DHUDSpecificPowerTracker:new();
		MONK.selfChi:setResourceType(12, "CHI");
		MONK.selfChi:initPlayerNotInVehicleOrNoneUnitId();
		MONK.selfChi.updateFrequently = false;
		
		-------------
		-- Stagger --
		-------------
		--- Class to track players stagger
		local DHUDStaggerTracker = MCCreateSubClass(DHUDPowerTracker, {
			
		})
		
		--- Create new runes tracker for player and vehicle
		function DHUDStaggerTracker:new()
			local o = self:defconstructor();
			o:constructor();
			return o;
		end
		
		--- Initialize stagger tracking
		function DHUDStaggerTracker:init()
			local tracker = self;
			-- process units max health points change event
			function self.eventsFrame:UNIT_MAXHEALTH(unitId)
				if (tracker.unitId ~= unitId) then
					return;
				end
				tracker:updateHealthMax();
			end
			-- init unit ids
			self:initPlayerNotInVehicleOrNoneUnitId();
			-- change resource type
			self:setCustomResourceType(DHUDColorizeTools.COLOR_ID_TYPE_CUSTOM_STAGGER);
		end

		--- Game time updated, update unit power
		function DHUDStaggerTracker:onUpdateTime()
			self:updateStagger();
		end

		--- Start tracking data
		function DHUDStaggerTracker:startTracking()
			-- no game events currently, resource is updated by timer
			trackingHelper:addEventListener(DHUDDataTrackerHelperEvent.EVENT_UPDATE, self, self.onUpdateTime);
		end

		--- Stop tracking data
		function DHUDStaggerTracker:stopTracking()
			-- no game events currently, resource is updated by timer
			trackingHelper:addEventListener(DHUDDataTrackerHelperEvent.EVENT_UPDATE, self, self.onUpdateTime);
		end

		--- Update stagger for unit
		function DHUDStaggerTracker:updateStagger()
			self:setAmount(UnitStagger(self.unitId) or 0);
		end

		--- Update maximum stagger for unit
		function DHUDStaggerTracker:updateHealthMax()
			self:setAmountMax(UnitHealthMax(self.unitId) or 0)
		end

		--- Update all data for current unitId
		function DHUDStaggerTracker:updateData()
			self:updateStagger();
			self:updateHealthMax();
		end

		--- Start tracking amountMax data
		function DHUDStaggerTracker:startTrackingAmountMax()
			self.eventsFrame:RegisterEvent("UNIT_MAXHEALTH");
		end

		--- Update maximum amount or resource
		function DHUDStaggerTracker:updateAmountMax()
			self.eventsFrame:UNIT_MAXHEALTH(self.unitId);
		end

		--- Stop tracking amountMax data
		function DHUDStaggerTracker:stopTrackingAmountMax()
			self.eventsFrame:UnregisterEvent("UNIT_MAXHEALTH");
		end
		MONK.selfStagger = DHUDStaggerTracker:new();
	end,
	-- trackers that are used by warlock
	WARLOCK = { },
	fillWARLOCK = function(self, charclass)
		-- fill table with trackers
		local WARLOCK = self.WARLOCK;
		------------------
		-- Sould shards --
		------------------
		WARLOCK.selfSoulShards = DHUDSpecificPowerTracker:new();
		WARLOCK.selfSoulShards:setResourceType(7, "SOUL_SHARDS");
		WARLOCK.selfSoulShards:initPlayerSpecsOnly(1);
		WARLOCK.selfSoulShards:initPlayerNotInVehicleOrNoneUnitId();
		WARLOCK.selfSoulShards.precision = 2;
		
		--------------------
		-- Burning embers --
		--------------------
		WARLOCK.selfBurningEmbers = DHUDSpecificPowerTracker:new();
		WARLOCK.selfBurningEmbers:setResourceType(14, "BURNING_EMBERS");
		WARLOCK.selfBurningEmbers:initPlayerSpecsOnly(3);
		WARLOCK.selfBurningEmbers:initPlayerNotInVehicleOrNoneUnitId();
		WARLOCK.selfBurningEmbers.precision = 1;
		WARLOCK.selfBurningEmbers.updateFrequently = false;

		------------------
		-- Demonic fury --
		------------------
		WARLOCK.selfDemonicFury = DHUDSpecificPowerTracker:new();
		WARLOCK.selfDemonicFury:setResourceType(15, "DEMONIC_FURY");
		WARLOCK.selfDemonicFury:initPlayerSpecsOnly(2);
		WARLOCK.selfDemonicFury:initPlayerNotInVehicleOrNoneUnitId();
	end,
	-- trackers that are used by paladin
	PALADIN = { },
	fillPALADIN = function(self, charclass)
		-- fill table with trackers
		local PALADIN = self.PALADIN;
		----------------
		-- Holy Power --
		----------------
		PALADIN.selfHolyPower = DHUDSpecificPowerTracker:new();
		PALADIN.selfHolyPower:setResourceType(9, "HOLY_POWER");
		PALADIN.selfHolyPower:initPlayerNotInVehicleOrNoneUnitId();
		PALADIN.selfHolyPower.updateFrequently = false;
	end,
	-- trackers that are used by priest
	PRIEST = { },
	fillPRIEST = function(self, charclass)
		-- fill table with trackers
		local PRIEST = self.PRIEST;
		-----------------
		-- Shadow orbs --
		-----------------
		PRIEST.selfShadowOrbs = DHUDSpecificPowerTracker:new();
		PRIEST.selfShadowOrbs:setResourceType(13, "SHADOW_ORBS");
		PRIEST.selfShadowOrbs:initPlayerSpecsOnly(3);
		PRIEST.selfShadowOrbs:initPlayerNotInVehicleOrNoneUnitId();
		PRIEST.selfShadowOrbs.updateFrequently = false;
	end,
	-- trackers that are used by shaman
	SHAMAN = { },
	fillSHAMAN = function(self, charclass)
		-- fill table with trackers
		local SHAMAN = self.SHAMAN;
		------------
		-- Totems --
		------------
		SHAMAN.selfTotems = DHUDGuardiansTracker:new();
		SHAMAN.selfTotems:initPlayerNotInVehicleOrNoneUnitId();
	end,
	-- reference to data helper
	helper = nil,
	-- initialize all trackers
	-- @param class class of game character
	init = function(self)
		-- init tracking helper
		trackingHelper:init();
		self.helper = trackingHelper;
		local charclass = trackingHelper.playerClass;
		-- init trackers for any class
		self:fillAll(charclass);
		for i, v in pairs(self.ALL) do
			v:init();
		end
		-- init trackers for specific class
		local fillClassSpecific = self["fill" .. charclass];
		if (fillClassSpecific ~= nil) then
			fillClassSpecific(self, charclass);
			for i, v in pairs(self[charclass]) do
				v:init();
			end
		end
		--print("DataTrackers inited for class: " .. charclass);
	end,
}
