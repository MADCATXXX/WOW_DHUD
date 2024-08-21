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

-------------------------------------
-- Unit tracker helper event class --
-------------------------------------

--- Class for tracker helper event, it will be fired by data tracker helper
DHUDDataTrackerHelperEvent = MCCreateSubClass(MADCATEvent, {
	-- dispatched in order to update resources (every 95-100 ms)
	EVENT_UPDATE = "time",
	-- dispatched in order to do some updates on next time tick (every 10 ms)
	EVENT_UPDATE_FREQUENT = "timeFrequent",
	-- dispatched in order to do some heavy updates frequently (every 45-50 ms)
	EVENT_UPDATE_SEMIFREQUENT = "timeSemiFrequent",
	-- dispatched in order to update some values that don't require regular ticks (every 1000 ms)
	EVENT_UPDATE_INFREQUENT = "timeInFrequent",
	-- dispatched when player changes specialization
	EVENT_SPECIALIZATION_CHANGED = "specialization",
	-- dispatched when player changes PvE/PvP talents (and also on specialization change), this may add or remove some spells from spellbook
	EVENT_TALENTS_CHANGED = "talents",
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
	-- number of milliseconds since some event in the past (e.g. entering world), float number, whole part is seconds!!!, fractional parts is milliseconds
	timerMs				= 0,
	-- tick identifier that is changed on every tick (e.g. int number that is increased with each tick)
	tickId				= 0,
	-- amount of time since last dispatch of semi frequent update event
	timeSinceLastUpdateFast = 0,
	-- amount of time since last dispatch of update event
	timeSinceLastUpdate = 0,
	-- amount of time since last dispatch of infrequent update event
	timeSinceLastUpdateLong = 0,
	-- localization-independent player class name, e.g. "ROGUE"
	playerClass			= "",
	-- localization-independent player specialization id (number from 1 to 3, from 1 to 4 for druids)
	playerSpecialization	= 0,
	-- list with player talents (this value format is different for Vanilla/TBC/WotLK/Retail, and updated on different events)
	playerTalents       = {},
	-- defines if player character is in vehicle with vehicle ui
	isInVehicle			= false,
	-- id of the player casting unit, "vehicle" when in vehicle or "player" otherwise
	playerCasterUnitId	= "player",
	-- id of the target casting unit, "softenemy"/"softfriend" if soft target exists and setting is enabled, empty string if nothing is selected
	targetCasterUnitId = "target",
	-- id of the target of target casting unit, usually "targettarget", but in case of "softenemy"/"softfriend" usage - may change to another
	targetOfTargetCasterUnitId = "targettarget",
	-- defines if player has pet or not
	isPetAvailable		= false,
	-- defines if player has something in target or not (in case of soft targets if something is in soft target)
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
	-- defines type of the zone, that the player is currently in, e.g. "pvp"/"arena"
	zoneType			= "",
	-- table with conversion from spell id to spell data
	spellIdData			= {},
	-- table with conversion from item id to item data
	itemIdData			= {},
	-- table with durations of auras
	auraIdDurationData = {},
	-- table with guids for various unit ids, contains guids for exact ids: player, pet, vehicle and target, softenemy, softfriend
	guids				= {},
	-- table with specs, initialized on demand, example usage: getSpecsTable[SpecName or ID]
	specsTable			= nil,
	-- mask with currently pressed modifier keys
	modifierKeysMask	= 0,
	-- defines if alt modifier key is currently pressed
	MODIFIER_KEY_ALT	= 1,
	-- defines if ctrl modifier key is currently pressed
	MODIFIER_KEY_CTRL	= 2,
	-- defines if shift modifier key is currently pressed
	MODIFIER_KEY_SHIFT	= 4,
	-- defines if Soft Targets should be prioritized over usual Target (when Target is dead or is player)
	PRIORITIZE_SOFT_TARGETS = false,
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
	self.eventUpdateSemiFrequent = DHUDDataTrackerHelperEvent:new(DHUDDataTrackerHelperEvent.EVENT_UPDATE_SEMIFREQUENT);
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
	self.eventTalents = DHUDDataTrackerHelperEvent:new(DHUDDataTrackerHelperEvent.EVENT_TALENTS_CHANGED);
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
	self.eventsFrame:RegisterEvent("PLAYER_SOFT_ENEMY_CHANGED");
	self.eventsFrame:RegisterEvent("PLAYER_SOFT_FRIEND_CHANGED");
	self.eventsFrame:RegisterEvent("UNIT_TARGET");
	self.eventsFrame:RegisterEvent("UNIT_PET");
	self.eventsFrame:RegisterEvent("PLAYER_REGEN_DISABLED");
	self.eventsFrame:RegisterEvent("PLAYER_REGEN_ENABLED");
	self.eventsFrame:RegisterEvent("PLAYER_ENTER_COMBAT");
	self.eventsFrame:RegisterEvent("PLAYER_LEAVE_COMBAT");
	self.eventsFrame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED");
	self.eventsFrame:RegisterEvent("PLAYER_TALENT_UPDATE"); -- only PvP talents on retail
	self.eventsFrame:RegisterEvent("PET_SPECIALIZATION_CHANGED");
	self.eventsFrame:RegisterEvent("LEARNED_SPELL_IN_TAB");
	self.eventsFrame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED"); -- currently the only way to track PvE talents update on retail
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
		helper:processTargetChangeEvents(false);
	end
	function self.eventsFrame:PLAYER_SOFT_ENEMY_CHANGED()
		if (helper.PRIORITIZE_SOFT_TARGETS ~= true) then
			return;
		end
		helper:processTargetChangeEvents(true);
	end
	function self.eventsFrame:PLAYER_SOFT_FRIEND_CHANGED()
		if (helper.PRIORITIZE_SOFT_TARGETS ~= true) then
			return;
		end
		helper:processTargetChangeEvents(true);
	end
	function self.eventsFrame:UNIT_TARGET(unitId)
		if (unitId ~= helper.targetCasterUnitId) then
			return;
		end
		helper:setIsTargetOfTargetAvailable(UnitExists(helper.targetOfTargetCasterUnitId));
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
	function self.eventsFrame:PLAYER_TALENT_UPDATE() -- always refer to player
		--print("PvP Talent update");
		helper:onTalentsChanged();
	end
	function self.eventsFrame:UNIT_SPELLCAST_SUCCEEDED(unitId, castGUID, spellId)
		if (unitId ~= "player" or spellId ~= 384255) then
			return;
		end
		--print("PvE Talent update " .. spellId);
		helper:onTalentsChanged();
	end
	function self.eventsFrame:PET_SPECIALIZATION_CHANGED()
		--print("Pet Talent update " .. spellId);
		helper:onTalentsChanged();
	end
	function self.eventsFrame:LEARNED_SPELL_IN_TAB(spellId, skillInfoIndex, isGuildPerkSpell)
		--print("New spell " .. spellId);
		helper:removeEventListener(DHUDDataTrackerHelperEvent.EVENT_UPDATE_FREQUENT, helper, helper.onTalentsChangedDelayed);
		helper:addEventListener(DHUDDataTrackerHelperEvent.EVENT_UPDATE_FREQUENT, helper, helper.onTalentsChangedDelayed);
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

--- Update helpers data, this function is invoked on init and when entering world (e.g. /reload or map change, basically whenever the loading screen appears)
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
	-- update player zone
	local _, zoneType = IsInInstance();
	self.zoneType = zoneType;
end

--- Function that is called by blizzard event frame to update ui
-- @param timeElapsed amount of time elapsed since last update
function DHUDDataTrackerHelper:onUpdate(timeElapsed)
	self.timeSinceLastUpdateFast = self.timeSinceLastUpdateFast + timeElapsed;
	self.tickId = self.tickId + 1;
	self.timerMs = GetTime();
	self:dispatchEvent(self.eventUpdateFrequent);
	if (self.timeSinceLastUpdateFast < 0.045) then
		return;
	end
	self.timeSinceLastUpdate = self.timeSinceLastUpdate + self.timeSinceLastUpdateFast;
	self.timeSinceLastUpdateFast = 0;
	self:dispatchEvent(self.eventUpdateSemiFrequent);
	if (self.timeSinceLastUpdate < 0.095) then
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
	self.isTargetAvailable = isTargetAvailable;
	-- dispatch target event as it means that target is changed (target existence doesn't matter)
	self:dispatchEvent(self.eventTarget);
end

--- set isTargetAvailable variable
function DHUDDataTrackerHelper:setIsTargetOfTargetAvailable(isTargetOfTargetAvailable)
	self.isTargetOfTargetAvailable = isTargetOfTargetAvailable;
	if (isTargetOfTargetAvailable) then
		self.guids[self.targetOfTargetCasterUnitId] = UnitGUID(self.targetOfTargetCasterUnitId);
	else
		self.guids[self.targetOfTargetCasterUnitId] = "";
	end
	-- dispatch target of target event as it means that target of target is changed (unit existence doesn't matter)
	self:dispatchEvent(self.eventTargetTarget);
end

--- Process events that are related to target changes (soft or non soft related)
function DHUDDataTrackerHelper:processTargetChangeEvents(softTargetRelated)
	local targetAvailable = UnitExists("target");
	if (targetAvailable) then
		self.targetCasterUnitId = "target";
		self.targetOfTargetCasterUnitId = "targettarget";
		self.guids["target"] = UnitGUID("target");
	else
		self.guids["target"] = "";
	end
	-- soft target mode?
	if (self.PRIORITIZE_SOFT_TARGETS) then
		local checkEnemy = UnitExists("softenemy");
		local checkAlly = UnitExists("softfriend");
		self.guids["softenemy"] = checkEnemy and UnitGUID("softenemy") or "";
		self.guids["softfriend"] = checkAlly and UnitGUID("softfriend") or "";
		-- replace target with this values
		if ((checkEnemy or checkAlly) and ((not targetAvailable) or UnitIsDead("target") or UnitIsPlayer("target"))) then
			self.targetCasterUnitId = checkEnemy and "softenemy" or "softfriend";
			self.targetOfTargetCasterUnitId = self.targetCasterUnitId .. "target";
			targetAvailable = true;
		end
	end
	--print("target is " .. self.targetCasterUnitId .. ", available " .. MCTableToString(targetAvailable));
	self:setIsTargetAvailable(targetAvailable);
	self:setIsTargetOfTargetAvailable(UnitExists(self.targetOfTargetCasterUnitId));
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
	self:onTalentsChanged();
end

--- player talents updated, this should be processed differently for Vanilla/TBC/WotLK/Retail
function DHUDDataTrackerHelper:onTalentsChanged()
	-- TODO: Iterate over all nodes and save them? It may be easier to find nodeIds via TalentTreeTweaker addon
	if (MCVanilla <= 0) then -- retail
		--[[local configID = C_ClassTalents.GetActiveConfigID();
		local configInfo = C_Traits.GetConfigInfo(configID);
		local treeID = configInfo.treeIDs[1];
		local nodeIds = C_Traits.GetTreeNodes(treeID);
		print("configID " .. configID .. ", configInfo " .. MCTableToString(configInfo) .. ", nodeIds " .. MCTableToString(#nodeIds));
		for i, v in ipairs(nodeIds) do
			local nodeInfo = C_Traits.GetNodeInfo(C_ClassTalents.GetActiveConfigID(), v);
			print("Node " .. i .. ": " .. MCTableToString(nodeInfo));
		end]]--
	end
	--self.playerTalents = {};
	self:dispatchEvent(self.eventTalents);
end

--- player talents were recently updated, one tick passed (due to API not always updating spell book instantly)
function DHUDDataTrackerHelper:onTalentsChangedDelayed()
	self:removeEventListener(DHUDDataTrackerHelperEvent.EVENT_UPDATE_FREQUENT, self, self.onTalentsChangedDelayed);
	self:onTalentsChanged();
end

--- player is entering world
function DHUDDataTrackerHelper:onEnteringWorld()
	--print("Entering world " .. ", unit exists " .. MCTableToString(UnitExists("player")));
	self:updateData();
	self:dispatchEvent(self.eventEnteringWorld);
end

--- Get cached spell data for spell Id specified
-- @param spellId spell id of the spell
-- @param silent if true than error message will not be printed (game can report broken ids too)
-- @return spellData to be used in other functions { name, rank, icon, castTime, minRange, maxRange, spellID }, originalIcon not used
function DHUDDataTrackerHelper:getSpellData(spellId, silent)
	local spellData = self.spellIdData[spellId];
	if (spellData) then
		return spellData;
	end
	local spell = C_Spell.GetSpellInfo(spellId);
	if (spell ~= nil) then
		spellData = { spell.name, 1, spell.iconID, spell.castTime, spell.minTime, spell.maxRange, spell.spellID };
	else
		if (not silent) then
			DHUDMain:print("[E] Spell with id " .. spellId .. " is nil!");
			--geterrorhandler()("DHUD: [E] Spell with id " .. spellId .. " is nil!");
		end
		spellData = { "id:" .. tostring(spellId), 1, "", 0, 0, 0, 0 };
	end
	self.spellIdData[spellId] = spellData;
	return spellData;
end

--- Get cached spell name for spell Id specified
-- @param spellId spell id of the spell
-- @param silent if true than error message will not be printed (game can report broken ids too)
-- @return spellName to be used in UnitBuff function
function DHUDDataTrackerHelper:getSpellName(spellId, silent)
	return self:getSpellData(spellId, silent)[1];
end

--- Get cached item data for item Id specified
-- @param itemId item id of the item
-- @param silent if true than error message will not be printed (game can report broken ids too)
-- @return itemData to be used in other functions { "itemName", "itemLink", itemRarity, itemLevel, itemMinLevel, "itemType", "itemSubType", itemStackCount, "itemEquipLoc", "invTexture", "itemSellPrice" }
function DHUDDataTrackerHelper:getItemData(itemId, silent)
	local itemData = self.itemIdData[itemId];
	if (itemData) then
		return itemData;
	end
	itemData = { GetItemInfo(itemId) };
	if (#itemData == 0) then
		if (not silent) then
			DHUDMain:print("[E] Item with id " .. spellId .. " is nil!");
			--geterrorhandler()("DHUD: [E] Item with id " .. spellId .. " is nil!");
		end
		itemData = { "id:" .. tostring(itemId), "", 0, 0, 0, "", "", 0, "", "", "" };
	end
	self.itemIdData[itemId] = itemData;
	return itemData;
end

--- Get cached item name for item Id specified
-- @param itemId item id of the item
-- @param silent if true than error message will not be printed (game can report broken ids too)
-- @return itemName to be used in other functions
function DHUDDataTrackerHelper:getItemName(itemId, silent)
	return self:getItemData(itemId, silent)[1];
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

--- Initialize specs table on demand
-- @return specs table, example usage: getSpecsTable[SpecName or ID]
function DHUDDataTrackerHelper:getSpecsTable()
	if (self.specsTable ~= nil) then
		return self.specsTable;
	end
	local specsTable = {};
	self.specsTable = specsTable;
	if (not (MCVanilla == 0 or MCVanilla >= 5)) then
		return self.specsTable;
	end
	local classTag, specID, maleSpecName, femaleSpecName, icon, role;
	for classID = 1, GetNumClasses() do
		_, classTag = GetClassInfo(classID);
		for i = 1, GetNumSpecializationsForClassID(classID) do
			specID, maleSpecName, _, icon, role = GetSpecializationInfoForClassID(classID, i, 2); -- male version
			specID, femaleSpecName, _, icon, role = GetSpecializationInfoForClassID(classID, i, 3); -- female version
			local specInfo = { classTag = classTag, role = role, specID = specID, specName = maleSpecName, femaleSpecName = femaleSpecName, specIcon = icon };
			specsTable[maleSpecName] = specInfo;
			specsTable[specID] = specInfo;
			if (maleSpecName ~= femaleSpecName) then
				specsTable[femaleSpecName] = specInfo;
			end
		end
	end
	--print("Specs table " .. MCTableToString(self.specsTable));
	return specs;
end


-- helper object
DHUDDataTrackingHelper = DHUDDataTrackerHelper:new();
