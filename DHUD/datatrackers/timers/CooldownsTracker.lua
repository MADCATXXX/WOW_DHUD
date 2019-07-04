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
	-- time at which gcd will end
	gcdTimeLeft						= 0,
	-- time that defines current player gcd
	gcdTimeTotal					= 0,
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
	function self.eventsFrame:UNIT_SPELLCAST_SUCCEEDED(unitId, lineId, spellId)
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
	-- update gcd
	local timerMs = trackingHelper.timerMs;
	local timeDiff = timerMs - self.timeUpdatedAt;
	self.gcdTimeLeft = self.gcdTimeLeft - timeDiff;
	-- call super
	DHUDTimersTracker.onUpdateTime(self);
	-- no timers to update?
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
	local gcdUpdated = false;
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
			spellData = trackingHelper:getSpellData(spellId, true);
			-- check spells with charges
			charges, maxCharges, startTime, duration = GetSpellCharges(spellData[1]);
			if (charges ~= nil and (maxCharges - charges) > 0) then
				cooldownCharges = (maxCharges - charges);
			else -- check usual cooldown
				startTime, duration, enable = GetSpellCooldown(i, BOOKTYPE_SPELL);
				cooldownCharges = 1;
			end
			-- valid cooldown?
			if (startTime ~= nil) then
				if (duration <= 1.5) then
					if (not gcdUpdated and duration > 0) then
						self.gcdTimeLeft = startTime + duration - timerMs; -- timeLeft
						self.gcdTimeTotal = duration; -- duration
						gcdUpdated = true;
					end
				elseif (duration ~= invalidDuration) then
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
				spellData = trackingHelper:getSpellData(spellId, true);
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
		-- update gcd if it wasn't updated
		if (not gcdUpdated) then
			self.gcdTimeLeft = 0; -- timeLeft
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
	local spellType, petActionId, autocastAllowed, autocastEnabled, spellData, startTime, duration, enable, name, texture;
	-- iterate over spell book
	for i = 1, numPetSpells, 1 do
		-- get spell info
		spellType, petActionId = GetSpellBookItemInfo(i, BOOKTYPE_PET);
		-- only process spells
		if (petActionId ~= nil) then
			-- check if spell is on autocast, we should only display non-autocast spells
			autocastAllowed, autocastEnabled = GetSpellAutocast(i, BOOKTYPE_PET);
			--print("i " .. i .. ", spellType " .. MCTableToString(spellType) .. ", petActionId " .. MCTableToString(petActionId) .. ", autocastEnabled " .. MCTableToString(autocastEnabled));
			if (not autocastEnabled) then
				name = GetSpellBookItemName(i, BOOKTYPE_PET);
				spellData = trackingHelper:getSpellData(name, true);
				--texture = GetSpellBookItemTexture(i, BOOKTYPE_PET);
				-- check usual cooldown
				startTime, duration, enable = GetSpellCooldown(i, BOOKTYPE_PET);
				-- valid cooldown?
				if (startTime ~= nil and duration > 1.5) then
					--print("filling spelldId " .. MCTableToString(petActionId) .. ", name " .. MCTableToString(spellData[1]) .. ", texture " .. MCTableToString(spellData[3]));
					cooldownId = cooldownId + 1;
					timer = self:findTimer(cooldownId, petActionId);
					-- fill timer info, { type, timeLeft, duration, id, tooltipId, name, stacks, texture, exists, iterating, sortOrder }
					timer[1] = self.TIMER_TYPE_MASK_PETSPELL + self.TIMER_TYPE_MASK_ACTIVE; -- type
					timer[2] = startTime + duration - timerMs; -- timeLeft
					timer[3] = duration; -- duration
					timer[4] = petActionId; -- id
					timer[5] = spellData[7]; -- tooltipId
					timer[6] = name; -- spellData[1]; -- name
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
					spellData = trackingHelper:getSpellData(spellId, true);
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
		local gcdUpdated = false;
		-- iterate
		for i = 133, 138, 1 do
			startTime, duration, enable = GetActionCooldown(i);
			if (startTime ~= nil) then
				if (duration <= 1.5) then
					if (not gcdUpdated and duration > 0) then
						self.gcdTimeLeft = startTime + duration - timerMs; -- timeLeft
						self.gcdTimeTotal = duration; -- duration
						gcdUpdated = true;
					end
				else
					actionType, spellId, actionSubType = GetActionInfo(i);
					if (actionType == "spell") then
						cooldownId = cooldownId + 1;
						spellData = trackingHelper:getSpellData(spellId, true);
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
		-- update gcd if it wasn't updated
		if (not gcdUpdated) then
			self.gcdTimeLeft = 0; -- timeLeft
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
