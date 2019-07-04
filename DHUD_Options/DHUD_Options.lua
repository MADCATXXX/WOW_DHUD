--[[-----------------------------------------------------------------------------------
 Original Drathals HUD (c) 2006 by Markus Inger / Drathal / Silberklinge / Silbersegen
 DHUD for WotLK and later expansions (c) 2013 by MADCAT (EU-Гордунни, Мадкат)
 (http://eu.battle.net/wow/en/character/гордунни/Мадкат/advanced)
---------------------------------------------------------------------------------------
 This file contains functions to help set setting and code to work with ace3 db
 @author: MADCAT
-----------------------------------------------------------------------------------]]--

-------------------
-- Usefull links --
-------------------
-- http://www.wowpedia.org/Using_UIDropDownMenu
-- http://www.wowpedia.org/API_UIDropDownMenu_AddButton

----------
-- Code --
----------

--- class to help in changing settings
DHUDOptions = {
	-- defines if options are being previewed
	isPreviewing = false,
	-- time at which preview should stop
	previewStopTime = 0,
	-- default setting range
	default_range = { 0, 1, 0.1 },
	-- reference to created addon via ace3
	aceAddon = nil,
	-- reference to created config via ace3
	aceConfig = nil,
	-- reference to created ace db options via ace3
	aceDBOptions = nil,
	-- reference to created config dialog via ace3
	aceConfigDialog = nil,
	-- reference to created shared media via ace3
	aceSharedMedia = nil,
	-- reference to created ace config table
	aceConfigTable = nil,
	-- reference to create data base to store ace data
	aceDB = nil,
	-- reference to ace db saved vars sub table
	aceDBSavedVars = nil,
	-- name of the addon for ace support
	ACE_ADDON_NAME = "DHUDOptionsAce",
	-- name of the profiles saved variables
	ACE_SAVED_VARS = "DHUDODB3",
};

--- Function to toggle settings of boolean type
-- @param settingName name of the setting to toggle
function DHUDOptions:toggleBooleanSetting(settingName)
	if (settingName == nil) then
		return;
	end
	local value = DHUDSettings:getValue(settingName);
	self:setSettingValue(settingName, (not value));
end

--- Function to set setting value of any kind
-- @param settingName name of the setting to set
-- @param value value to set
function DHUDOptions:setSettingValue(settingName, value)
	if (settingName == nil) then
		return;
	end
	--print("DHUDOptions setting " .. settingName .. " to " .. MCTableToString(value));
	DHUDSettings:setValue(settingName, value);
	-- preview setting for 5 seconds
	self:startSettingsPreview(5);
	-- save setting to ace
	self:loadDHUDSettingToAce(settingName);
end

--- Function to get setting value of any type
-- @param settingName name of the setting to read
-- @param copy if true then setting will be copied
-- @param default return value if setting doesn't exists
-- @return setting value
function DHUDOptions:getSettingValue(settingName, copy, default)
	if (settingName == nil) then
		return default;
	end
	local value = DHUDSettings:getValue(settingName);
	if (copy) then
		value = MCCreateTableDeepCopy(value);
	end
	return value;
end

--- Function to get setting range
-- @param settingName name of the setting to get range for
-- @return setting range in format { min, max, step }
function DHUDOptions:getSettingRange(settingName)
	if (settingName == nil) then
		return self.default_range;
	end
	local defaultTable = DHUDSettings:getValueDefaultTable(settingName);
	return defaultTable[3].range;
end

--- Function to check if layout is custom
function DHUDOptions:isLayoutCustom()
	local framesData = DHUDSettings.default["framesData"][1];
	for k, v in pairs(framesData) do
		if (k == "layout") then
		
		elseif (v[2] == DHUDSettings.SETTING_TYPE_CONTAINER) then
			v = v[1];
			for k2, v2 in pairs(v) do
				if (not DHUDSettings:isSettingDefaultValue(v2[3].fullName)) then
					return true;
				end
			end
		else
			if (not DHUDSettings:isSettingDefaultValue(v[3].fullName)) then
				return true;
			end
		end
	end
	return false;
end

--- Function to reset all settings
function DHUDOptions:resetSettings()
	DHUDSettings:resetToDefaults();
end

--- Start preview of settings
-- @param time amount of time for preview to last in seconds
function DHUDOptions:startSettingsPreview(time)
	time = time or 1;
	local helper = DHUDDataTrackers.helper;
	self.previewStopTime = helper.timerMs + time;
	if (not self.isPreviewing) then
		helper:addEventListener(DHUDDataTrackerHelperEvent.EVENT_UPDATE, self, self.onCheckPreview);
		DHUDSettings:previewStart();
		self.isPreviewing = true;
	end
end

--- Timer updated, check if we need to stop preview
function DHUDOptions:onCheckPreview(e)
	local timerMs = DHUDDataTrackers.helper.timerMs;
	if (timerMs > self.previewStopTime) then
		self:stopSettingsPreview();
	end
end

--- Start preview of settings
function DHUDOptions:stopSettingsPreview()
	local helper = DHUDDataTrackers.helper;
	if (self.isPreviewing) then
		helper:removeEventListener(DHUDDataTrackerHelperEvent.EVENT_UPDATE, self, self.onCheckPreview);
		DHUDSettings:previewStop();
		self.isPreviewing = false;
	end
end

--- Prints message to player chat frame
-- @param msg message to print
function DHUDOptions:print(msg)
	if DEFAULT_CHAT_FRAME then
		DEFAULT_CHAT_FRAME:AddMessage("|cff88ff88DHUDOptions:|r " .. (msg or "null"), 1, 1, 1);
	end
end

------------------
-- Ace3 Support --
------------------

--- Create ace3 modules that are required by the addon
function DHUDOptions:createAce3Modules()
	-- create modules
	self.aceConfig = LibStub("AceConfig-3.0");
	self.aceDBOptions = LibStub("AceDBOptions-3.0");
	self.aceConfigDialog = LibStub("AceConfigDialog-3.0");
	self.aceSharedMedia = LibStub:GetLibrary("LibSharedMedia-3.0", true);
	-- create addon
	self.aceAddon = LibStub("AceAddon-3.0"):NewAddon(self.ACE_ADDON_NAME, "AceConsole-3.0", "AceEvent-3.0");
	self.aceAddon:SetDefaultModuleState(false);
	-- create db
	self.aceDB = LibStub("AceDB-3.0"):New(self.ACE_SAVED_VARS, { profile = { } });
	self.aceDB.RegisterCallback(self, "OnProfileChanged", "onAceProfileChanged");
	self.aceDB.RegisterCallback(self, "OnProfileCopied", "onAceProfileCopied");
	self.aceDB.RegisterCallback(self, "OnProfileReset", "onAceProfileReset");
	-- save reference to ace saved vars
	self.aceDBSavedVars = self.aceDB.profile;
	-- add ace profiles config
	self:addAceConfigTab('profiles', self.aceDBOptions:GetOptionsTable(self.aceDB), 20, false);
	-- register options table
	self.aceConfig:RegisterOptionsTable(self.ACE_ADDON_NAME, self.aceConfigTable, "DHUD_Options");
	-- load dhud settings to ace
	self:loadDHUDSettingsToAce();
end

--- add ace config
-- @param key name of of the config tab
-- @param group group of settings
-- @param order order of setting tab
-- @param isCmdInline defines if cmd line should be used
function DHUDOptions:addAceConfigTab(key, group, order, isCmdInline)
	-- create ace config if not exists
	if (self.aceConfigTable == nil) then
		self.aceConfigTable = { type = "group", name = self.ACE_ADDON_NAME, childGroups = "tab", args = { }, };
	end
	self.aceConfigTable.args[key] = group;
	self.aceConfigTable.args[key].order = order;
	self.aceConfigTable.args[key].cmdInline = isCmdInline;
end

--- load ace database setting to dhud
function DHUDOptions:loadAceSettingsToDHUD()
	local aceSV = self.aceDBSavedVars;
	local sv = DHUDSettings:getSavedVars();
	-- clear saved vars
	for k, v in pairs(sv) do
		if (k ~= DHUDSettings.SAVED_VARS_ADDITIONAL_TABLE_NAME) then
			sv[k] = nil;
		end
	end
	-- load ace saved vars
	for k, v in pairs(aceSV) do	
		sv[k] = aceSV[k];
    end
	-- reload settings
	DHUDSettings:reloadSavedVars();
	-- reload options
	DHUD_OptionsTemplates_LUA:reloadSettingTab();
end

--- load dhud setting to ace database
function DHUDOptions:loadDHUDSettingsToAce()
	local aceSV = self.aceDBSavedVars;
	local sv = DHUDSettings:getSavedVars();
	-- clear saved vars
	for k, v in pairs(aceSV) do
		aceSV[k] = nil;
	end
	-- load ace saved vars
	for k, v in pairs(sv) do
		if (k ~= DHUDSettings.SAVED_VARS_ADDITIONAL_TABLE_NAME) then
			aceSV[k] = sv[k];
		end
	end
end

--- load dhud setting to ace database
-- @param settingName name of the setting
function DHUDOptions:loadDHUDSettingToAce(settingName)
	local aceSV = self.aceDBSavedVars;
	local sv = DHUDSettings:getSavedVars();
	if (aceSV == nil) then -- not yet loaded
		return;
	end
	aceSV[settingName] = sv[settingName];
end

--- open ace config dialog
function DHUDOptions:openAceConfig()
	self.aceConfigDialog:Open(self.ACE_ADDON_NAME);
end

-- ace profile changed
function DHUDOptions:onAceProfileChanged()
	self.aceDBSavedVars = self.aceDB.profile;
	--print("onAceProfileChanged " .. MCTableToString(self.aceDBSavedVars));
	--DHUDOptions:print("Profile changed");
	self:loadAceSettingsToDHUD();
end

-- ace profile copied
function DHUDOptions:onAceProfileCopied()
	self.aceDBSavedVars = self.aceDB.profile;
	--print("onAceProfileCopied " .. MCTableToString(self.aceDBSavedVars));
	--DHUDOptions:print("Settings copied");
	self:loadAceSettingsToDHUD();
end

-- ace profile reset
function DHUDOptions:onAceProfileReset()
	self.aceDBSavedVars = self.aceDB.profile;
	--print("onAceProfileReset " .. MCTableToString(self.aceDBSavedVars));
	--DHUDOptions:print("Profile was reset");
	self:loadAceSettingsToDHUD();
end

----------
-- Main --
----------

--- DHUD Options main function, called once addon is loaded
function DHUDOptions:main()
	self:createAce3Modules();
end