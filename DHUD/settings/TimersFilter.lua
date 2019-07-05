--[[-----------------------------------------------------------------------------------
 Original Drathals HUD (c) 2006 by Markus Inger / Drathal / Silberklinge / Silbersegen
 DHUD for WotLK and later expansions (c) 2013 by MADCAT (EU-Гордунни, Мадкат)
 (http://eu.battle.net/wow/en/character/гордунни/Мадкат/advanced)
---------------------------------------------------------------------------------------
 This file contains helping functions to filer out timers
 @author: MADCAT
-----------------------------------------------------------------------------------]]--

--------------------------
-- Timers filter helper --
--------------------------

--- Class to filter timers trackers according to settings
DHUDTimersFilterHelperSettingsHandler = {
	-- white list with player auras
	whiteListPlayerAuras = {
	},
	-- black list with player auras
	blackListPlayerAuras = {
	},
	-- priority list with player auras
	priorityListPlayerAuras = {
	},
	-- white list with target auras
	whiteListTargetAuras = {
	},
	-- black list with target auras
	blackListTargetAuras = {
	},
	-- priority list with target auras
	priorityListTargetAuras = {
	},
	-- white list with target cooldowns
	whiteListPlayerCooldowns = {
	},
	-- black list with player cooldowns
	blackListPlayerCooldowns = {
	},
	-- priority list with player cooldowns
	priorityListPlayerCooldowns = {
	},
	-- show auras with charges?
	aurasWithCharges = false,
	-- allows to show item cooldowns
	cooldownsItem = false,
	-- auras maximum time left
	aurasTimeLeftMax = 0,
	-- allows to show all player buffs, not just self
	playerAllBuffs = false,
	-- allows to show short player debuffs
	playerDebuffs = false,
	-- cooldowns minimum duration
	cooldownsDurationMin = 0,
	-- cooldowns maximum duration
	cooldownsDurationMax = 0,
}

--- Filter player auras list to show only short auras (not a class function, self is nil!)
-- @param timer timer to filter { type, timeLeft, duration, id, tooltipId, name, stacks, texture, exists, iterating, sortOrder }
-- @return nil if timer is not required or number for timer sorting order (<1000 for priority spells)
function DHUDTimersFilterHelperSettingsHandler.filterPlayerShortAuras(timer)
	local self = DHUDTimersFilterHelperSettingsHandler;
	local name = timer[6];
	-- check blacklist
	if (self.blackListPlayerAuras[name] ~= nil) then
		return nil;
	end
	-- check white list
	if (self.whiteListPlayerAuras[name] == nil) then
		-- do not show all player buffs?
		if (not self.playerAllBuffs and (bit.band(timer[1], DHUDAurasTracker.TIMER_TYPE_MASK_BUFF + DHUDAurasTracker.TIMER_TYPE_MASK_IS_CAST_BY_PLAYER) == DHUDAurasTracker.TIMER_TYPE_MASK_BUFF)) then
			return nil;
		end
		-- do not show debuffs?
		if (not self.playerDebuffs and (bit.band(timer[1], DHUDAurasTracker.TIMER_TYPE_MASK_DEBUFF) ~= 0)) then
			return nil;
		end
		-- if duration is too high or stack count is low - return
		if ((timer[2] > self.aurasTimeLeftMax or timer[2] < 0) and (not self.aurasWithCharges or timer[7] < 1)) then
			return nil;
		end
	end
	local priority = self.priorityListPlayerAuras[name];
	if (priority ~= nil) then
		return priority;
	end
	return (bit.band(timer[1], DHUDAurasTracker.TIMER_TYPE_MASK_BUFF) ~= 0) and 1001 or 1002;
end

--- Filter target auras list to show only short auras (not a class function, self is nil!)
-- @param timer timer to filter { type, timeLeft, duration, id, tooltipId, name, stacks, texture, exists, iterating, sortOrder }
-- @return nil if timer is not required or number for timer sorting order (<1000 for priority spells)
function DHUDTimersFilterHelperSettingsHandler.filterTargetShortAuras(timer)
	local self = DHUDTimersFilterHelperSettingsHandler;
	local name = timer[6];
	-- check blacklist
	if (self.blackListTargetAuras[name] ~= nil) then
		return nil;
	end
	-- check white list
	if (self.whiteListTargetAuras[name] == nil) then
		-- show only player applied spells
		local mask = DHUDAurasTracker.TIMER_TYPE_MASK_IS_CAST_BY_PLAYER; -- DHUDAurasTracker.TIMER_TYPE_MASK_DEBUFF + 
		--print("name is " .. timer[6] .. ", type is " .. timer[1]);
		if (bit.band(timer[1], mask) ~= mask) then
			return nil;
		end
		-- if duration is too high or stack count is low - return
		if ((timer[2] > self.aurasTimeLeftMax or timer[2] < 0) and (not self.aurasWithCharges or timer[7] < 1)) then
			return nil;
		end
	end
	local priority = self.priorityListTargetAuras[name];
	--print("name " .. name .. ", table " .. MCTableToString(self.priorityListTargetAuras) .. ", priority " .. priority);
	if (priority ~= nil) then
		return priority;
	end
	return (bit.band(timer[1], DHUDAurasTracker.TIMER_TYPE_MASK_IS_CAST_BY_PLAYER) ~= 0) and 1001 or 1002;
end

--- Filter only buff auras
-- @param timer timer to filter { type, timeLeft, duration, id, tooltipId, name, stacks, texture, exists, iterating, sortOrder }
-- @return nil if timer is not required or number for timer sorting order (<1000 for priority spells)
function DHUDTimersFilterHelperSettingsHandler.filterBuffAuras(timer)
	local self = DHUDTimersFilterHelperSettingsHandler;
	if (bit.band(timer[1], DHUDAurasTracker.TIMER_TYPE_MASK_BUFF) == 0) then
		return nil;
	end
	return 1001;
end

--- Filter only debuff auras
-- @param timer timer to filter { type, timeLeft, duration, id, tooltipId, name, stacks, texture, exists, iterating, sortOrder }
-- @return nil if timer is not required or number for timer sorting order (<1000 for priority spells)
function DHUDTimersFilterHelperSettingsHandler.filterDebuffAuras(timer)
	local self = DHUDTimersFilterHelperSettingsHandler;
	if (bit.band(timer[1], DHUDAurasTracker.TIMER_TYPE_MASK_DEBUFF) == 0) then
		return nil;
	end
	--print("name is " .. timer[6] .. ", type is " .. timer[1]);
	return 1001;
end

--- Filter player cooldowns list to show only short cooldowns (not a class function, self is nil!)
-- @param timer timer to filter { type, timeLeft, duration, id, tooltipId, name, stacks, texture, exists, iterating, sortOrder }
-- @return nil if timer is not required or number for timer sorting order (<1000 for priority spells)
function DHUDTimersFilterHelperSettingsHandler.filterPlayerCooldowns(timer)
	local self = DHUDTimersFilterHelperSettingsHandler;
	local name = timer[6];
	local isItem = bit.band(timer[1], DHUDCooldownsTracker.TIMER_TYPE_MASK_ITEM) ~= 0;
	local slotId = timer[5];
	--print("timer is " .. MCTableToString(timer));
	--print("item black list " .. MCTableToString(self.blackListPlayerCooldowns["_slot"]) .. ", id " .. MCTableToString(timer[5]) .. ", isBlacklisted " .. MCTableToString(self.blackListPlayerCooldowns["_slot"][timer[5]] == true));
	-- check blacklist
	if (self.blackListPlayerCooldowns[name] ~= nil or (isItem and self.blackListPlayerCooldowns["_slot"][slotId] ~= nil)) then
		return nil;
	end
	-- check white list
	if (self.whiteListPlayerCooldowns[name] == nil and ((not isItem) or self.whiteListPlayerCooldowns["_slot"][slotId] == nil)) then
		-- if duration is too high or too low then return
		if (timer[3] < self.cooldownsDurationMin or timer[3] > self.cooldownsDurationMax or (isItem and (not self.cooldownsItem))) then
			return nil;
		end
	end
	--print("priorityListPlayerCooldowns " .. MCTableToString(self.priorityListPlayerCooldowns));
	local priority = self.priorityListPlayerCooldowns[name] or (isItem and self.priorityListPlayerCooldowns["_slot"][slotId] or nil);
	if (priority ~= nil) then
		return priority;
	end
	return (bit.band(timer[1], DHUDCooldownsTracker.TIMER_TYPE_MASK_SPELL) ~= 0) and 1001 or 1002;
end

--- Filter totem guardians
-- @param timer timer to filter { type, timeLeft, duration, id, tooltipId, name, stacks, texture, exists, iterating, sortOrder }
-- @return nil if timer is not required or number for timer sorting order (<1000 for priority spells)
function DHUDTimersFilterHelperSettingsHandler.filterTotemGuardians(timer)
	local self = DHUDTimersFilterHelperSettingsHandler;
	return (bit.band(timer[1], DHUDGuardiansTracker.TIMER_TYPE_MASK_ACTIVE) ~= 0) and 1001 or 1002;
end

--- Process setting with white or black list
-- @param settingName name of the setting
-- @param tableName name of the table to fill
-- @param additionalProcessFunc function to make additional list processing (invoked with table argument)
function DHUDTimersFilterHelperSettingsHandler:processSpellListSetting(settingName, tableName, additionalProcessFunc)
	local process = function(self, e)
		local list = DHUDSettings:getValue(settingName);
		local table = self[tableName];
		-- remove all previous values
		for k, v in pairs(table) do
			table[k] = nil;
		end
		-- save new values
		for i, v in ipairs(list) do
			table[v] = i;
		end
		-- process table
		if (additionalProcessFunc ~= nil) then
			additionalProcessFunc(self, table);
		end
		--print("settingName " .. settingName .. ", table " .. MCTableToString(table));
	end
	DHUDSettings:addEventListener(DHUDSettingsEvent.EVENT_SPECIFIC_SETTING_CHANGED_PREFIX .. settingName, self, process);
	process(self, nil);
end

--- Process setting with condition
-- @param settingName name of the setting
-- @param varName name of the variable to fill
function DHUDTimersFilterHelperSettingsHandler:processConditionSetting(settingName, varName)
	local process = function(self, e)
		self[varName] = DHUDSettings:getValue(settingName);
	end
	DHUDSettings:addEventListener(DHUDSettingsEvent.EVENT_SPECIFIC_SETTING_CHANGED_PREFIX .. settingName, self, process);
	process(self, nil);
end

--- Process table with spells, adding items list
-- @param t name of the setting
function DHUDTimersFilterHelperSettingsHandler:processItemSlotList(t)
	local slots = { };
	--print("item table " .. MCTableToString(t));
	for k, v in pairs(t) do
		-- check syntaxis
		local indexS, indexE = strfind(k, "<slot:.->", 0); -- search for "<slot:13>" text
		if (indexS ~= nil) then
			local slot = strsub(k, indexS + 6, indexE - 1);
			slot = tonumber(slot); -- required as number
			--print("found slot " .. slot);
			slots[slot] = v;
		end
	end
	t["_slot"] = slots;
end

--- initialize timers filter settings handler
function DHUDTimersFilterHelperSettingsHandler:init()
	-- spell lists
	self:processSpellListSetting("shortAurasOptions_playerAurasWhiteList", "whiteListPlayerAuras");
	self:processSpellListSetting("shortAurasOptions_playerAurasBlackList", "blackListPlayerAuras");
	self:processSpellListSetting("shortAurasOptions_playerAurasPriorityList", "priorityListPlayerAuras");
	self:processSpellListSetting("shortAurasOptions_targetAurasWhiteList", "whiteListTargetAuras");
	self:processSpellListSetting("shortAurasOptions_targetAurasBlackList", "blackListTargetAuras");
	self:processSpellListSetting("shortAurasOptions_targetAurasPriorityList", "priorityListTargetAuras");
	self:processSpellListSetting("shortAurasOptions_cooldownsWhiteList", "whiteListPlayerCooldowns", self.processItemSlotList);
	self:processSpellListSetting("shortAurasOptions_cooldownsBlackList", "blackListPlayerCooldowns", self.processItemSlotList);
	self:processSpellListSetting("shortAurasOptions_cooldownsPriorityList", "priorityListPlayerCooldowns", self.processItemSlotList);
	-- conditions
	self:processConditionSetting("shortAurasOptions_aurasWithCharges", "aurasWithCharges");
	self:processConditionSetting("shortAurasOptions_aurasTimeLeftMax", "aurasTimeLeftMax");
	self:processConditionSetting("shortAurasOptions_playerAllBuffs", "playerAllBuffs");
	self:processConditionSetting("shortAurasOptions_playerDebuffs", "playerDebuffs");
	self:processConditionSetting("shortAurasOptions_cooldownsDurationMin", "cooldownsDurationMin");
	self:processConditionSetting("shortAurasOptions_cooldownsDurationMax", "cooldownsDurationMax");
	self:processConditionSetting("shortAurasOptions_cooldownsItem", "cooldownsItem");
end
