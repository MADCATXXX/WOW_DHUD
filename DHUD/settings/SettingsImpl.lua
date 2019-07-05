--[[-----------------------------------------------------------------------------------
 Original Drathals HUD (c) 2006 by Markus Inger / Drathal / Silberklinge / Silbersegen
 DHUD for WotLK and later expansions (c) 2013 by MADCAT (EU-Гордунни, Мадкат)
 (http://eu.battle.net/wow/en/character/гордунни/Мадкат/advanced)
---------------------------------------------------------------------------------------
 This file contains user settings implementation and notifies other objects about
 settings change, to see settings table please open SettingsTable.lua
 @author: MADCAT
-----------------------------------------------------------------------------------]]--

--------------------
-- Settings Event --
--------------------

--- Class for settings event, it will be fired by settings manager
DHUDSettingsEvent = MCCreateSubClass(MADCATEvent, {
	-- name of the changed setting
	setting = "",
	-- dispatched when dhud settings addon starts to change some value
	EVENT_START_PREVIEW = "previewStart",
	-- dispatched when dhud settings addon stops to change some value
	EVENT_STOP_PREVIEW = "previewStop",
	-- dispatched when some setting changed
	EVENT_SETTING_CHANGED = "settingChanged",
	-- prefix for event that will be dispatched when some group of the settings was changed
	EVENT_SPECIFIC_GROUP_SETTING_CHANGED_PREFIX = "groupSettingChanged_",
	-- prefix for event that will be dispatched when specific setting changed
	EVENT_SPECIFIC_SETTING_CHANGED_PREFIX = "settingChanged_",
})

--- Create new settings event
-- @param type type of the event
function DHUDSettingsEvent:new(type)
	local o = self:defconstructor();
	o:constructor(type);
	return o;
end

--- Constructor for settings event
-- @param type type of the event
function DHUDSettingsEvent:constructor(type)
	-- call super constructor
	MADCATEvent.constructor(self, type);
end

--------------
-- Settings --
--------------

--- Custom getter to read frames data settings
function DHUDSettings:getFramesData(name)
	local valueStored = self.settings[name];
	-- setting not exists?
	if (valueStored == nil) then
		return nil;
	end
	-- check not default
	if (valueStored ~= false) then
		return valueStored;
	end
	-- read default table data
	local defaultTable = self:getValueDefaultTable(name);
	local tableInfo = defaultTable[3];
	local groups = tableInfo.groups;
	local lastName = tableInfo.lastName;
	-- read layout data
	local layout = self.settings["framesData_layout"];
	local layoutData = self.default["layouts"][1]["layout" .. layout];
	-- check for class specific value
	local value = nil;
	local class = DHUDDataTrackers.helper.playerClass;
	local table = layoutData[class];
	if (table ~= nil) then
		for i = 2, #groups, 1 do
			table = table[groups[i]];
			if (table == nil) then
				break;
			end
		end
		if (table ~= nil) then
			value = table[lastName];
		end
	end
	if (value ~= nil) then
		return value;
	end
	-- read value for any class
	local table = layoutData[1];
	for i = 2, #groups, 1 do
		table = table[groups[i]];
	end
	value = table[lastName];
	return value;
end

--- Custom setter to set frames layout setting
function DHUDSettings:setFramesDataLayout(name, value)
	local layoutData = self.default["layouts"][1];
	-- layout not exists?
	if (layoutData["layout" .. value] == nil) then
		return;
	end
	-- set layout
	self:setValueInternal(name, value);
	-- set all frames data to default
	local table = self.default["framesData"][1];
	self:resetFramesDataSettings(table);
end

--- helper function for setFramesDataLayout to reset all frame data settings once layout has changed
-- @param table table to reset setting in
function DHUDSettings:resetFramesDataSettings(table)
	for k, v in pairs(table) do
		if (v[2] == self.SETTING_TYPE_CONTAINER) then
			self:resetFramesDataSettings(v[1]);
		else
			local fullname = v[3].fullName;
			if (fullname ~= "framesData_layout") then
				self:setValueInternal(fullname, nil);
			end
		end
	end
end

--- Custom getter to read unit texts settings
function DHUDSettings:getUnitTexts(name)
	local value = self.settings[name];
	if (value == nil) then
		return nil;
	end
	-- check first symbol
	local firstSymbol = value:sub(1, 1);
	if (firstSymbol ~= "@") then
		return value;
	end
	-- check if it uses default value
	if (value == "@default") then
		local infoDefault = self:getValueDefaultTable(name)[3].default;
		local class = DHUDDataTrackers.helper.playerClass;
		if (infoDefault[class] ~= nil) then
			value = infoDefault[class];
		else
			value = infoDefault[1];
		end
	end
	-- return predefined value
	local predefinedName = value:sub(2);
	local predefinedValues = self.default["unitTextsPredefined"][1];
	local predefinedValue = predefinedValues[predefinedName];
	if (predefinedValue ~= nil) then
		return predefinedValue;
	end
	return value;
end

--- Search for custom setter or getter of setting specified
-- @param settingName name of the setting
-- @param funcList list with functions (setters or getters)
-- @return reference to function or nil if no function found
function DHUDSettings:searchCustomSetterOrGetter(settingName, funcList)
	-- search for setting specified
	local func = funcList[settingName];
	if (func ~= nil) then
		return func;
	end
	-- not found, search for rewritten groups
	local groups = { strsplit("_", settingName) };
	table.remove(groups);
	while (#groups > 0) do
		func = funcList[table.concat(groups, "_")];
		if (func ~= nil) then
			return func;
		end
		table.remove(groups);
	end
	return nil;
end

--- Get default value of setting
-- @param settingName name of the setting
-- @param tableDefault this setting default table or nil
-- @return real default value and table default value
function DHUDSettings:getSettingDefaultValue(settingName, tableDefault)
	tableDefault = tableDefault or self:getValueDefaultTable(settingName);
	tableValue = tableDefault[1];
	-- search for getter
	local getter = self:searchCustomSetterOrGetter(settingName, self.getters)
	if (getter == nil) then
		return tableValue, tableValue;
	end
	-- get current value
	local currentVar = self.settings[settingName];
	-- set setting to default and invoke getter
	self.settings[settingName] = tableValue;
	local getterValue = getter(self, settingName);
	-- restore value
	self.settings[settingName] = currentVar;
	-- return calculated default value
	return getterValue, tableValue;
end

--- Defines if settings is set to default value
-- @return true if setting is default, false otherwise
function DHUDSettings:isSettingDefaultValue(settingName)
	local valueStored = self.settings[settingName];
	--print("isSettingDefaultValue settingName " .. settingName .. ", valueStored " .. MCTableToString(valueStored));
	-- setting not exists?
	if (valueStored == nil) then
		return true;
	end
	local tableDefault = self:getValueDefaultTable(settingName);
	--print("isSettingDefaultValue tableDefault[1] " .. MCTableToString(tableDefault[1]));
	return MCCompareTables(valueStored, tableDefault[1]);
end

--- Set value of the setting
-- @param name name of the setting
-- @param value value to set
function DHUDSettings:setValue(name, value)
	local custom = self:searchCustomSetterOrGetter(name, self.setters);
	-- has custom getter?
	if (custom ~= nil) then
		custom(self, name, value);
		return;
	end
	-- set value
	self:setValueInternal(name, value);
end

--- Internal function to set value of the setting, should not be invoked from other classes
-- @param name name of the setting
-- @param value value to set, pass nil for default value
function DHUDSettings:setValueInternal(name, value)
	-- process default value if required
	if (value == nil) then
		self:processDefaultSettingValue(name, self:getValueDefaultTable(name));
		local defaultVar = self.settings[name];
		if (defaultVar ~= nil) then
			self:setValueInternal(name, defaultVar);
		end
	end
	-- value to be saved in saved vars table
	local valueForSavedVars = nil;
	-- get default table
	local tableDefault = self:getValueDefaultTable(name);
	if (tableDefault == nil) then
		return; -- attempt to set setting that doesn't exists
	end
	local tableValue, tableOrigValue = self:getSettingDefaultValue(name, tableDefault);
	local tableType = tableDefault[2];
	local tableInfo = tableDefault[3];
	-- allow to set specific values for some settings that return different value
	if (value == tableOrigValue) then
		value = tableValue;
	end
	-- apply restrictions to value
	value = self:applyRestrictionsToValue(value, tableValue, tableDefault);
	if (value == nil) then
		return; -- attempt to set value that can't be processed
	end
	-- switch by setting type
	-- setting contains single value
	if (tableType == self.SETTING_TYPE_VALUE) then
		-- compare values
		if (value ~= tableValue) then
			valueForSavedVars = value;
		end
	-- setting contains array of fixed size and order
	elseif (tableType == self.SETTING_TYPE_ARRAY_FIXEDORDERSIZE or tableType == self.SETTING_TYPE_ARRAY_FIXEDORDER) then
		-- check array lenghts
		if (#value ~= #tableValue) then
			-- values are different
			valueForSavedVars = value;
		else
			-- compare arrays
			for i, v in ipairs(value) do
				if (v ~= tableValue[i]) then
					-- values are different
					valueForSavedVars = value;
					break;
				end
			end
		end
	-- setting contains list or map, saved vars should contain only difference from it
	elseif (tableType == self.SETTING_TYPE_ARRAY_NOORDERSIZE or tableType == self.SETTING_TYPE_ARRAY_SPELLIDTONAME or tableType == self.SETTING_TYPE_TABLE) then
		local added = { };
		local removed = { };
		local key;
		-- search for removed items
		for i, v in pairs(tableValue) do
			if (tableType == self.SETTING_TYPE_ARRAY_SPELLIDTONAME) then
				v = DHUDDataTrackers.helper:getSpellName(v);
			end
			key = MCFindValueInTable(value, v);
			-- value no longer in table
			if (key == nil) then
				table.insert(removed, v);
			end
		end
		-- search for added items
		for i, v in pairs(value) do
			key = nil;
			-- search if items that were present, using cycle instead of function as we are required to change spellIds to spellNames
			for i2, v2 in pairs(tableValue) do
				if (tableType == self.SETTING_TYPE_ARRAY_SPELLIDTONAME) then
					v2 = DHUDDataTrackers.helper:getSpellName(v2);
				end
				-- check values
				if (v2 == v) then
					key = i2;
					break;
				end
			end
			-- value was not in table
			if (key == nil) then
				table.insert(added, v);
			end
			-- list is changed?
			if (#added > 0 or #removed > 0) then
				valueForSavedVars = { added, removed };
			end
		end
	end
	-- save saved var
	self:getSavedVars()[name] = valueForSavedVars;
	--print("valueForSavedVars " .. MCTableToString(valueForSavedVars));
	-- save
	if (valueForSavedVars ~= nil) then
		self.settings[name] = value;
	else
		self.settings[name] = tableOrigValue;
	end
	-- dispatch events
	-- setting changed event
	self.eventSettingChanged.setting = name;
	self:dispatchEvent(self.eventSettingChanged);
	-- specific setting changed event
	self.eventSpecificSettingChanged.setting = name;
	self.eventSpecificSettingChanged.type = DHUDSettingsEvent.EVENT_SPECIFIC_SETTING_CHANGED_PREFIX .. name;
	self:dispatchEvent(self.eventSpecificSettingChanged);
	-- group setting changed event
	self.eventSpecificGroupChanged.setting = name;
	local groupName;
	local parent = tableDefault;
	while (true) do
		parent = parent[3].parent;
		if (parent == nil) then
			break;
		end
		groupName = parent[3].fullName;
		self.eventSpecificGroupChanged.type = DHUDSettingsEvent.EVENT_SPECIFIC_GROUP_SETTING_CHANGED_PREFIX .. groupName;
		self:dispatchEvent(self.eventSpecificGroupChanged);
	end
end

--- Apply restrictions to value
-- @param value value that is going to be saved
-- @param tableValue value in defaults table
-- @param defaultTable table with default data, that contains restrictions on value
-- @return value with restrictions, or nil if value can't be set
function DHUDSettings:applyRestrictionsToValue(value, tableValue, defaultTable)
	local tableType = defaultTable[2];
	local tableInfo = defaultTable[3];
	-- switch by setting type
	-- setting contains single value
	if (tableType == self.SETTING_TYPE_VALUE) then
		-- check if type of variables are the same
		if (type(value) ~= type(tableValue)) then
			return nil;
		end
		-- check if setting has range
		local rangeData = tableInfo.range;
		if (rangeData ~= nil) then
			local minValue = rangeData[1];
			local maxValue = rangeData[2];
			if (value > maxValue) then
				value = maxValue;
			elseif (value < minValue) then
				value = minValue;
			end
		end
	-- all other variables are tables
	else
		if ("table" ~= type(value)) then
			return nil;
		end
		-- setting contains array of fixed size and order
		if (tableType == self.SETTING_TYPE_ARRAY_FIXEDORDERSIZE) then
			-- array lengths should be the same
			if (#value ~= #tableValue) then
				return nil;
			end
			-- variable types should also be the same
			for i, v in ipairs(value) do
				if (type(v) ~= type(tableValue[i])) then
					return nil;
				end
			end
		end
	end
	return value;
end

--- Get value of the setting
-- @param name name of the setting
-- @return value of the setting
function DHUDSettings:getValue(name)
	local custom = self:searchCustomSetterOrGetter(name, self.getters);
	-- has custom getter?
	if (custom ~= nil) then
		return custom(self, name);
	end
	return self.settings[name];
end

--- Get default value of the table
-- @param name name of the setting
-- @return table with default data about this setting
function DHUDSettings:getValueDefaultTable(name)
	local groups = { strsplit("_", name) };
	-- first iteration
	setting = self.default[groups[1]];
	if (setting == nil) then
		return nil;
	end
	-- iterate further
	for i = 2, #groups, 1 do
		setting = setting[1][groups[i]];
		if (setting == nil) then
			return nil;
		end
	end
	return setting;
end

--- Get reference to data tracker by name
-- @param dataTrackerName name of the data tracker
-- @return reference to data tracker
function DHUDSettings:getDataTrackerByName(dataTrackerName)
	local trackersTable = self.default.framesDataSources[1].dataTrackersMap;
	return trackersTable[dataTrackerName];
end

--- Convert data tracker names array to reference array, always constructs new table
-- @param namesArray array with names
-- @return array with references
function DHUDSettings:convertDataTrackerNamesArrayToReferenceArray(namesArray)
	local refArray = { };
	for i, v in ipairs(namesArray) do
		local dt = self:getDataTrackerByName(v);
		if (dt ~= nil and dt[1] ~= nil) then
			table.insert(refArray, dt);
		end
	end
	return refArray;
end

--- Map data trackers to table values
function DHUDSettings:mapDataTrackers()
	local trackersTable = self.default.framesDataSources[1].dataTrackersMap;
	trackersTable["playerHealth"] = { DHUDDataTrackers.ALL.selfHealth };
	trackersTable["targetHealth"] = { DHUDDataTrackers.ALL.targetHealth };
	trackersTable["characterInVehicleHealth"] = { DHUDDataTrackers.ALL.selfCharInVehicleHealth };
	trackersTable["petHealth"] = { DHUDDataTrackers.ALL.petHealth };
	trackersTable["playerPower"] = { DHUDDataTrackers.ALL.selfPower };
	trackersTable["targetPower"] = { DHUDDataTrackers.ALL.targetPower };
	trackersTable["characterInVehiclePower"] = { DHUDDataTrackers.ALL.selfCharInVehiclePower };
	trackersTable["petPower"] = { DHUDDataTrackers.ALL.petPower };
	trackersTable["playerComboPoints"] = { DHUDDataTrackers.ALL.selfComboPoints };
	trackersTable["vehicleComboPoints"] = { DHUDDataTrackers.ALL.vehicleComboPoints };
	trackersTable["playerCooldowns"] = { DHUDDataTrackers.ALL.selfCooldowns, DHUDTimersFilterHelperSettingsHandler.filterPlayerCooldowns };
	trackersTable["playerShortAuras"] = { DHUDDataTrackers.ALL.selfAuras, DHUDTimersFilterHelperSettingsHandler.filterPlayerShortAuras };
	trackersTable["targetShortAuras"] = { DHUDDataTrackers.ALL.targetAuras, DHUDTimersFilterHelperSettingsHandler.filterTargetShortAuras };
	trackersTable["targetInfo"] = { DHUDDataTrackers.ALL.targetInfo };
	trackersTable["targetOfTargetInfo"] = { DHUDDataTrackers.ALL.targetOfTargetInfo };
	trackersTable["targetBuffs"] = { DHUDDataTrackers.ALL.targetAuras, DHUDTimersFilterHelperSettingsHandler.filterBuffAuras };
	trackersTable["targetDebuffs"] = { DHUDDataTrackers.ALL.targetAuras, DHUDTimersFilterHelperSettingsHandler.filterDebuffAuras };
	trackersTable["playerCastBar"] = { DHUDDataTrackers.ALL.selfCast };
	trackersTable["targetCastBar"] = { DHUDDataTrackers.ALL.targetCast };
	--trackersTable["tankVengeance"] = { DHUDDataTrackers.ALL.vengeanceInfo };
	-- specific to druid
	trackersTable["druidMana"] = { DHUDDataTrackers.DRUID.selfMana };
	trackersTable["druidEnergy"] = { DHUDDataTrackers.DRUID.selfEnergy };
	trackersTable["druidEclipse"] = { DHUDDataTrackers.DRUID.selfEclipse };
	-- specific to monk
	--trackersTable["monkMana"] = { DHUDDataTrackers.MONK.selfMana };
	--trackersTable["monkEnergy"] = { DHUDDataTrackers.MONK.selfEnergy };
	trackersTable["monkChi"] = { DHUDDataTrackers.MONK.selfChi };
	trackersTable["monkStagger"] = { DHUDDataTrackers.MONK.selfStagger };
	-- specific to warlock
	trackersTable["warlockSoulShards"] = { DHUDDataTrackers.WARLOCK.selfSoulShards };
	-- specific to paladin
	trackersTable["paladinHolyPower"] = { DHUDDataTrackers.PALADIN.selfHolyPower };
	-- specific to priest
	--trackersTable["priestShadowOrbs"] = { DHUDDataTrackers.PRIEST.selfShadowOrbs };
	-- specific to mage
	trackersTable["mageArcaneCharges"] = { DHUDDataTrackers.MAGE.selfArcaneCharges };
	-- specific to death knight
	trackersTable["deathKnightRunes"] = { DHUDDataTrackers.DEATHKNIGHT.selfRunes };
	-- specific to shaman
	trackersTable["shamanTotems"] =  { DHUDDataTrackers.SHAMAN.selfTotems, DHUDTimersFilterHelperSettingsHandler.filterTotemGuardians };
	trackersTable["shamanMana"] = { DHUDDataTrackers.SHAMAN.selfMana };
end

--- Initialize single setting from table
-- @param tableName name of the table
-- @param tableContent table contents to be processed
-- @param parent table, that is parent to this setting
-- @param groupArray array with groups that are parents to this setting
function DHUDSettings:processDefaultSetting(tableName, tableContent, parent, groupArray)
	--print("tableName " .. tableName);
	local tableValue = tableContent[1];
	local tableType = tableContent[2];
	local tableInfo = tableContent[3];
	-- update value full name and groups list
	if (tableInfo == nil) then
		tableInfo = { };
		tableContent[3] = tableInfo;
	end
	local fullName = tableName;
	if (#groupArray > 0) then
		fullName = table.concat(groupArray, "_") .. "_" .. tableName;
	end
	tableInfo["groups"] = groupArray;
	tableInfo["lastName"] = tableName;
	tableInfo["fullName"] = fullName;
	tableInfo["parent"] = parent;
	-- references should not be copied
	if (tableType == self.SETTING_TYPE_CONTAINER_REFERENCE) then
		return;
	-- containers should be processed further
	elseif (tableType == self.SETTING_TYPE_CONTAINER) then
		local containerGroup = MCCreateTableCopy(groupArray);
		table.insert(containerGroup, tableName);
		-- process
		for i, v in pairs(tableValue) do
			self:processDefaultSetting(i, v, tableContent, containerGroup);
		end
		return;
	end
	self:processDefaultSettingValue(fullName, tableContent);
end

--- Save contents of default table to settings table
-- @param fullName fullName of the setting
-- @param defaultTableContent table with default data about setting
function DHUDSettings:processDefaultSettingValue(fullName, defaultTableContent)
	local tableValue = defaultTableContent[1];
	local tableType = defaultTableContent[2];
	-- process setting if required
	if (tableType ~= self.SETTING_TYPE_VALUE) then
		tableValue = MCCreateTableDeepCopy(tableValue);
	end
	-- process spell ids
	if (tableType == self.SETTING_TYPE_ARRAY_SPELLIDTONAME) then
		for i, v in ipairs(tableValue) do
			tableValue[i] = DHUDDataTrackers.helper:getSpellName(v);
		end
	end
	-- save to settings table
	self.settings[fullName] = tableValue;
end

--- Initialize settings table with default table
function DHUDSettings:processDefaultSettingsTable()
	for i, v in pairs(self.default) do
		self:processDefaultSetting(i, v, nil, { });
	end
end

--- Process saved vars table and fill settings table with changes from it
function DHUDSettings:processSavedVars()
	local savedVars = self:getSavedVars();
	-- read version
	local version = savedVars["version"] or 0;
	-- process saved vars
	local defaultTable, settingType, settingDefaultValue, settingInfo;
	-- iterate
	for k, v in pairs(savedVars) do
		-- get default table
		defaultTable = self:getValueDefaultTable(k);
		-- value exists?
		if (defaultTable ~= nil) then
			settingType = defaultTable[2];
			settingDefaultValue = self:getSettingDefaultValue(k, tableDefault);
			settingInfo = defaultTable[3];
			-- apply restrictions
			v = self:applyRestrictionsToValue(v, settingDefaultValue, defaultTable);
			if (v ~= nil) then
				-- standard setting?
				if (settingType == self.SETTING_TYPE_VALUE or settingType == self.SETTING_TYPE_ARRAY_FIXEDORDERSIZE or settingType == self.SETTING_TYPE_ARRAY_FIXEDORDER) then
					self.settings[k] = v;
				-- list setting, variable contains arrays with added and removed values
				else
					local list = self.settings[k];
					local added = v[1];
					local removed = v[2];
					local key;
					-- process removed vars
					for i2, v2 in ipairs (removed) do
						key = MCFindValueInTable(list, v2);
						if (key ~= nil) then
							table.remove(list, key);
						end
					end
					-- process added vars
					for i2, v2 in ipairs (added) do
						key = MCFindValueInTable(list, v2);
						if (key == nil) then
							table.insert(list, v2);
						end
					end
					-- save
					self.settings[k] = list;
				end
			end
		-- setting no longer exists
		else
			-- remove unused setting
			if (k ~= self.SAVED_VARS_ADDITIONAL_TABLE_NAME) then
				savedVars[k] = nil;
			end
		end
	end
	-- save version
	savedVars["version"] = DHUDMain.versionInt;
end

--- Initialize custom setters and getters
function DHUDSettings:initCustomSettersAndGetters()
	self.getters["framesData"] = self.getFramesData;
	self.getters["unitTexts"] = self.getUnitTexts;
	self.setters["framesData_layout"] = self.setFramesDataLayout;
end

--- Initialize settings hadler, addon saved variables are loaded at this moment
function DHUDSettings:init()
	-- construct event dispatcher
	self:constructor();
	-- create table with settings if none
	if (not DHUD_SavedVars) then
        DHUD_SavedVars = { };
    end
	-- create events
	self.eventSettingChanged = DHUDSettingsEvent:new(DHUDSettingsEvent.EVENT_SETTING_CHANGED);
	self.eventSpecificSettingChanged = DHUDSettingsEvent:new(DHUDSettingsEvent.EVENT_SPECIFIC_SETTING_CHANGED_PREFIX);
	self.eventSpecificGroupChanged = DHUDSettingsEvent:new(DHUDSettingsEvent.EVENT_SPECIFIC_GROUP_SETTING_CHANGED_PREFIX);
	self.eventStartPreview = DHUDSettingsEvent:new(DHUDSettingsEvent.EVENT_START_PREVIEW);
	self.eventStopPreview = DHUDSettingsEvent:new(DHUDSettingsEvent.EVENT_STOP_PREVIEW);
	-- init settings
	self:mapDataTrackers();
	self:processDefaultSettingsTable();
	self:initCustomSettersAndGetters();
	-- read saved vars
	self:processSavedVars();
	-- init non-addon specific settings handler
	DHUDNonAddonSettingsHandler:init();
	-- init timer filter functions
	DHUDTimersFilterHelperSettingsHandler:init();
end

--- Print contents of the table specified to string, used for debugging purposes
-- @param name name of the table
-- @param settings table with settings to print
function DHUDSettings:printSettingTableToString(name, settings)
	local result = "Contents of " .. name .. ":";
	-- sort keys
	local keys = { };
	for k, v in pairs(settings) do
		table.insert(keys, k);
	end
	table.sort(keys);
	-- print values
	for i, k in ipairs(keys) do
		result = result .. "\n  " .. k .. ": " .. MCTableToString(settings[k]);
	end
	return result;
end

--- Function to reset settings to default values
function DHUDSettings:resetToDefaults()
	for k, v in pairs(self.settings) do
		self:setValueInternal(k, nil);
	end
end

--- Function to reload saved vars, they can be modified by dhud options addon
function DHUDSettings:reloadSavedVars()
	-- copy setting table
	local settingsCopy = MCCreateTableDeepCopy(self.settings);
	-- read saved vars
	self:processDefaultSettingsTable();
	self:processSavedVars();
	-- redispatch events for required settings
	for k, v in pairs(settingsCopy) do
		if (MCCompareTables(v, self.settings[k]) == false) then
			self:setValueInternal(k, self.settings[k]);
		end
	end
end

--- Start preview of current settings
function DHUDSettings:previewStart()
	if (self.previewActive) then
		return;
	end
	self.previewActive = true;
	self:dispatchEvent(self.eventStartPreview);
end

--- Stop preview of current settings
function DHUDSettings:previewStop()
	if (not self.previewActive) then
		return;
	end
	self.previewActive = false;
	self:dispatchEvent(self.eventStopPreview);
end

--- Function to get table with additional saved vars, it may contain other addon data or some statistic data
-- @param tableName name of the sub table, pass nil to get whole additional saved vars table
-- @return table with additional saved vars
function DHUDSettings:getAdditionalSavedVars(tableName)
	local savedVars = self:getSavedVars();
	local additional = savedVars[self.SAVED_VARS_ADDITIONAL_TABLE_NAME];
	if (additional == nil) then
		additional = { };
		savedVars[self.SAVED_VARS_ADDITIONAL_TABLE_NAME] = additional;
	end
	if (tableName == nil) then
		return additional;
	end
	local subTable = additional[tableName];
	if (subTable == nil) then
		subTable = { };
		additional[tableName] = subTable;
	end
	return subTable;
end

-- temprorary variable for saved vars
DHUD_SAVED_VARS_TEMP = { ["scale_main"] = 0.8, ["scale_resource"] = 1.0, ["scale_spellCircles"] = 1.0, ["shortAurasOptions_targetAurasWhiteList"] = { {"CustomSpell1"}, {"spellName48792"} }, ["shortAurasOptions_aurasTimeLeftMax"] = 240,
						["outlines_spellCirclesTime"] = 0, ["outlines_spellCirclesStacks"] = 0, ["shortAurasOptions_cooldownsBlackList"] = { {"<slot:10>"}, { } }, };

--- get table with saved vars
function DHUDSettings:getSavedVars()
	--return DHUD_SAVED_VARS_TEMP;
	return DHUD_SavedVars;
end


-------------------------------------
-- Settings slash commands handler --
-------------------------------------

--- Initialize slash commands handling
function DHUDSettings:SlashCommandHandlerInit()
	
end

--- Handler for commands passed from chat using "/dhud"
-- @param args string with variable to set or read
function DHUDSettings:SlashCommandHandler(args)
	if (args == nil) then
		args = "";
	end
	local removeLeadingAndTrailingWhiteSpace = "^%s*(.-)%s*$";
	-- process arguments
	local indexOfEquals = string.find(args, "=");
	local variableName;
	local variableValue;
	-- found equals sign?
	if (indexOfEquals ~= nil) then
		variableName = string.sub(args, 1, indexOfEquals - 1);
		variableValue = string.sub(args, indexOfEquals + 1);
		variableValue = variableValue:match(removeLeadingAndTrailingWhiteSpace);
	else
		variableName = args;
		variableValue = nil;
	end
	variableName = variableName:match(removeLeadingAndTrailingWhiteSpace);
	-- check variable existance
	if (self.settings[variableName] == nil) then
		print("Requested variable not found, printing setting table...");
		print(self:printSettingTableToString("settings", self.settings));
		return;
	end
	-- set variable?
	if (variableValue ~= nil) then
		print("Setting variable " .. variableName .. " to: " .. variableValue);
		local evalFunc = loadstring("return " .. variableValue, "DHUD settings text input");
		if (evalFunc ~= nil) then
			variableValue = evalFunc();
		end
		self:setValue(variableName, variableValue);
		print("Variable " .. variableName .. " is set to: " .. MCTableToString(self:getValue(variableName)));
	else
		print("Reading variable " .. variableName .. ": " .. MCTableToString(self:getValue(variableName)));
	end
end

-----------------------------
-- Blizzard interface menu --
-----------------------------

--- Create addon tab in blizzard interface menu
function DHUDSettings:createBlizzardInterfaceOptions()
	-- frame with settings
	local frame = CreateFrame("Frame", "DHUD_InterfaceOptions");
	frame.name = "DHUD";
	-- title frame
	local textField = frame:CreateFontString("DHUD_InterfaceOptions_TitleText", "ARTWORK", "GameFontNormalLarge");
	textField:SetText("DHUD");
	textField:SetJustifyH("LEFT");
	textField:SetJustifyV("TOP");
	textField:SetPoint("TOPLEFT", 16, -16);
	frame.titleTextField = textField;
	-- open options button
	local button = CreateFrame("Button", "DHUD_InterfaceOptions_OpenOptionsButton", frame, "OptionsButtonTemplate");
	button:SetText("Open Options");
	button:SetWidth(180);
	button:SetHeight(22);
	button:SetPoint("TOPLEFT", frame.titleTextField, "BOTTOMLEFT", 0, -10);
	button:SetScript("OnClick", function()
		InterfaceOptionsFrame_Show();
		HideUIPanel(GameMenuFrame);
		DHUDMain:openSettings();
	end)
	-- slash command text
	local textField = frame:CreateFontString("DHUD_InterfaceOptions_SlashTipText", "ARTWORK", "GameFontNormalSmall");
	textField:SetText("/dhud");
	textField:SetNonSpaceWrap(true);
	textField:SetPoint("LEFT", button, "RIGHT", 10, 0);
	textField:SetTextColor(1, 1, 0.49, 1);
	frame.slashTextField = command;
	
	-- add to options
	self.blizzardInterfaceAddonTab = frame;
	InterfaceOptions_AddCategory(frame);
end
