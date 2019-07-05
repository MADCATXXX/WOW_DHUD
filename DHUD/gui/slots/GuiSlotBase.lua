--[[-----------------------------------------------------------------------------------
 Original Drathals HUD (c) 2006 by Markus Inger / Drathal / Silberklinge / Silbersegen
 DHUD for WotLK and later expansions (c) 2013 by MADCAT (EU-Гордунни, Мадкат)
 (http://eu.battle.net/wow/en/character/гордунни/Мадкат/advanced)
---------------------------------------------------------------------------------------
 This file contains base class for GUI slot managing
 @author: MADCAT
-----------------------------------------------------------------------------------]]--

----------------------
-- Gui Slot Manager --
----------------------

--- Class to manage single gui slot
DHUDGuiSlotManager = MCCreateClass{
	-- reference to current data tracker
	currentDataTracker	= nil,
	-- reference to current data tracker helper function if present
	currentDataTrackerHelperFunction = nil,
	-- list of the trackers to be used
	dataTrackersList	= nil,
	-- defines if gui in current slot is in regeneration state
	isRegenerating		= false,
	-- name of the setting that contains list of data trackers
	dataTrackersListSettingName = nil,
	-- name of the text format setting
	textFormatSettingName = nil,
	-- map with functions to perform text format
	textFormatMap = nil,
	-- function that should be used to format text
	textFormatFunction = nil,
	-- info about current text format functions
	textFormatInfo = nil,
	-- defines if data tracker being changed, prevents some unnecessary data updates
	isChangingDataTracker = false,
}

--- construct gui slot manager
function DHUDGuiSlotManager:constructor()
	self.textFormatInfo = { };
end

--- some of the critical settings was changed, update data if required
function DHUDGuiSlotManager:onCriticalSettingChange(e)
	if (self.currentDataTracker == nil) then
		return;
	end
	self:onDataTrackerChange(nil);
	self:onDataChange(nil);
end

--- some of the color setting was changed, update if required
function DHUDGuiSlotManager:onColorSettingChange(e)
	if (self.currentDataTracker ~= nil) then
		self:onDataChange(nil); -- updating data will cause bar to be recolored
	end
end

--- track changes in color settings to update slot
function DHUDGuiSlotManager:trackColorSettingsChanges()
	DHUDSettings:addEventListener(DHUDSettingsEvent.EVENT_SPECIFIC_GROUP_SETTING_CHANGED_PREFIX .. "colors", self, self.onColorSettingChange);
end

--- Text format setting has changed, update
function DHUDGuiSlotManager:onTextFormatSettingChange(e)
	self.textFormatFunction = DHUDTextTools:parseDataFormatToFunction(DHUDSettings:getValue(self.textFormatSettingName), self.textFormatMap, self);
	if (self.currentDataTracker ~= nil and not self.isChangingDataTracker) then
		self:onDataChange(nil); -- updating data will cause bar text to be refreshed
	end
end

--- Sets text format parameters to generate text format function
-- @param textFormatSettingName setting to read for text format
-- @param textFormatMap map to functions, do not pass this value as nil if setting name is not nil!
function DHUDGuiSlotManager:setTextFormatParams(textFormatSettingName, textFormatMap)
	if (self.textFormatSettingName == textFormatSettingName and self.textFormatMap == textFormatMap) then
		return;
	end
	self.textFormatMap = textFormatMap;
	-- update listener
	if (self.textFormatSettingName ~= nil) then
		DHUDSettings:removeEventListener(DHUDSettingsEvent.EVENT_SPECIFIC_SETTING_CHANGED_PREFIX .. self.textFormatSettingName, self, self.onTextFormatSettingChange);
	end
	self.textFormatSettingName = textFormatSettingName;
	if (self.textFormatSettingName ~= nil) then
		DHUDSettings:addEventListener(DHUDSettingsEvent.EVENT_SPECIFIC_SETTING_CHANGED_PREFIX .. self.textFormatSettingName, self, self.onTextFormatSettingChange);
		self:onTextFormatSettingChange(nil);
	end
end

--- Sets text format parameters to generate text format function for custom variable (this function will be a bit slower but support multiple number of text formats for single slot)
-- @param textFormatSettingName setting to read for text format
-- @param textFormatMap map to functions, do not pass this value as nil if setting name is not nil!
-- @param variableName name of the variable to store function in
function DHUDGuiSlotManager:setTextFormatParamsForVariable(textFormatSettingName, textFormatMap, variableName)
	local variableInfo = self.textFormatInfo[variableName];
	if (variableInfo == nil) then
		variableInfo = { };
		self.textFormatInfo[variableName] = variableInfo;
	end
	if (variableInfo[1] == textFormatSettingName and variableInfo[2] == textFormatMap) then
		return;
	end
	variableInfo[2] = textFormatMap;
	-- update listener
	if (variableInfo[1] ~= nil) then
		DHUDSettings:removeEventListener(DHUDSettingsEvent.EVENT_SPECIFIC_SETTING_CHANGED_PREFIX .. variableInfo[1], self, variableInfo[3]);
	end
	variableInfo[1] = textFormatSettingName;
	if (textFormatSettingName ~= nil) then
		-- create update function
		variableInfo[3] = function(self, e)
			self[variableName] = DHUDTextTools:parseDataFormatToFunction(DHUDSettings:getValue(textFormatSettingName), textFormatMap, self);
			if (self.currentDataTracker ~= nil and not self.isChangingDataTracker) then
				self:onDataChange(nil); -- updating data will cause bar text to be refreshed
			end
		end
		DHUDSettings:addEventListener(DHUDSettingsEvent.EVENT_SPECIFIC_SETTING_CHANGED_PREFIX .. textFormatSettingName, self, variableInfo[3]);
		variableInfo[3](self, nil);
	end
end

--- Data trackers list setting has been changed, read it
function DHUDGuiSlotManager:onDataTrackersSettingChange(e)
	local list = DHUDSettings:getValue(self.dataTrackersListSettingName);
	local convertedList = DHUDSettings:convertDataTrackerNamesArrayToReferenceArray(list);
	self:setDataTrackersList(convertedList);
end

--- set name of the setting, which holds list of data trackers
function DHUDGuiSlotManager:setDataTrackerListSetting(settingName)
	if (self.dataTrackersListSettingName == settingName) then
		return;
	end
	if (self.dataTrackersListSettingName ~= nil) then
		DHUDSettings:removeEventListener(DHUDSettingsEvent.EVENT_SPECIFIC_SETTING_CHANGED_PREFIX .. self.dataTrackersListSettingName, self, self.onDataTrackersSettingChange);
	end
	self.dataTrackersListSettingName = settingName;
	if (self.dataTrackersListSettingName ~= nil) then
		DHUDSettings:addEventListener(DHUDSettingsEvent.EVENT_SPECIFIC_SETTING_CHANGED_PREFIX .. self.dataTrackersListSettingName, self, self.onDataTrackersSettingChange);
	end
	self:onDataTrackersSettingChange(nil);
end

--- Existance of some data tracker has been changed
function DHUDGuiSlotManager:onDataTrackerExistanceChanged(e)
	self:rescanDataTrackersList();
end

--- set list of the trackers to be shown in the gui slot
-- @param dataTrackersList list with trackers
-- @param copy if true, than array will be copied before saving, otherwise stored by reference
function DHUDGuiSlotManager:setDataTrackersList(dataTrackersList, copy)
	-- remove listeners
	if (self.dataTrackersList ~= nil) then
		for i, v in ipairs(self.dataTrackersList) do
			v[1]:removeEventListener(DHUDDataTrackerEvent.EVENT_EXISTANCE_CHANGED, self, self.onDataTrackerExistanceChanged);
		end
	end
	-- copy table
	if (copy) then
		self.dataTrackersList = MCCreateTableCopy(dataTrackersList);
	else
		self.dataTrackersList = dataTrackersList;
	end
	-- set listeners
	if (self.dataTrackersList ~= nil) then
		for i, v in ipairs(self.dataTrackersList) do
			v[1]:addEventListener(DHUDDataTrackerEvent.EVENT_EXISTANCE_CHANGED, self, self.onDataTrackerExistanceChanged);
		end
	end
	-- rescan
	self:rescanDataTrackersList();
end

--- rescan list of data trackers and set first available as dataManager
function DHUDGuiSlotManager:rescanDataTrackersList()
	if (self.dataTrackersList == nil) then
		return;
	end
	for i, v in ipairs(self.dataTrackersList) do
		if (v[1].isExists) then
			self:setCurrentDataTracker(v[1], v[2]);
			return;
		end
	end
	-- not found, set to nil
	self:setCurrentDataTracker(nil);
	return;
end

--- Change isRegenerating variable value
function DHUDGuiSlotManager:setIsRegenerating(isRegenerating)
	if (self.isRegenerating == isRegenerating) then
		return;
	end
	self.isRegenerating = isRegenerating;
	-- notify ui manager
	DHUDGUIManager:onSlotRegenerationStateChanged();
end

--- current data tracker regeneration state changed, not all data trackers will provide correct data, since some of the data is filtered
function DHUDGuiSlotManager:onRegenerationChange(e)
	if (self.currentDataTracker == nil) then
		self:setIsRegenerating(false);
	else
		self:setIsRegenerating(self.currentDataTracker.isRegenerating);
	end
end

--- current data tracker data changed
function DHUDGuiSlotManager:onDataChange(e)
	-- to be overriden
end

--- current data tracker timers changed
function DHUDGuiSlotManager:onDataTimersChange(e)
	-- to be overriden
end

--- current data tracker resource type changed
function DHUDGuiSlotManager:onResourceTypeChange(e)
	-- to be overriden
end

--- new data tracker has been set for this slot, or data tracker unit has changed, update if neccesary
function DHUDGuiSlotManager:onDataTrackerChange(e)
	-- to be overriden
end

--- new unit has been selected by data tracker
function DHUDGuiSlotManager:onDataUnitChange(e)
	-- to be overriden
end

--- current data tracker existance changed, check currentDataTracker variable for existance
function DHUDGuiSlotManager:onExistanceChange()
	-- to be overriden
end

--- set current data tracker to be shown in the gui slot
-- @param currentDataTracker new data tracker to be set
-- @param currentDataTrackerHelperFunction helper function for new data tracker if any
function DHUDGuiSlotManager:setCurrentDataTracker(currentDataTracker, currentDataTrackerHelperFunction)
	-- do almost nothing, if set to the same data tracker
	if (self.currentDataTracker == currentDataTracker and self.currentDataTrackerHelperFunction == currentDataTrackerHelperFunction) then
		return;
	end
	self.isChangingDataTracker = true;
	-- remove listers
	if (self.currentDataTracker ~= nil) then
		self.currentDataTracker:removeEventListener(DHUDDataTrackerEvent.EVENT_REGENERATION_STATE_CHANGED, self, self.onRegenerationChange);
		self.currentDataTracker:removeEventListener(DHUDDataTrackerEvent.EVENT_DATA_CHANGED, self, self.onDataChange);
		self.currentDataTracker:removeEventListener(DHUDDataTrackerEvent.EVENT_DATA_TIMERS_UPDATED, self, self.onDataTimersChange);
		self.currentDataTracker:removeEventListener(DHUDDataTrackerEvent.EVENT_RESOURCE_TYPE_CHANGED, self, self.onResourceTypeChange);
		self.currentDataTracker:removeEventListener(DHUDDataTrackerEvent.EVENT_UNIT_CHANGED, self, self.onDataUnitChange);
	end
	-- save and notify gui about existance change
	local existanceChanged = (self.currentDataTracker == nil or currentDataTracker == nil);
	self.currentDataTracker = currentDataTracker;
	self.currentDataTrackerHelperFunction = currentDataTrackerHelperFunction;
	if (existanceChanged) then
		self:onExistanceChange();
		self:onRegenerationChange(nil);
	end
	-- add listeners
	if (self.currentDataTracker ~= nil) then
		self.currentDataTracker:addEventListener(DHUDDataTrackerEvent.EVENT_REGENERATION_STATE_CHANGED, self, self.onRegenerationChange);
		self.currentDataTracker:addEventListener(DHUDDataTrackerEvent.EVENT_DATA_CHANGED, self, self.onDataChange);
		self.currentDataTracker:addEventListener(DHUDDataTrackerEvent.EVENT_DATA_TIMERS_UPDATED, self, self.onDataTimersChange);
		self.currentDataTracker:addEventListener(DHUDDataTrackerEvent.EVENT_RESOURCE_TYPE_CHANGED, self, self.onResourceTypeChange);
		self.currentDataTracker:addEventListener(DHUDDataTrackerEvent.EVENT_UNIT_CHANGED, self, self.onDataUnitChange);
		-- update
		self:onDataTrackerChange(nil);
		self:onDataUnitChange(nil);
		self:onRegenerationChange(nil);
		self:onDataChange(nil);
	end
	self.isChangingDataTracker = false;
end

--- Show preview data
function DHUDGuiSlotManager:showPreviewData()
	-- to be overriden
end

--- Clear preview data
function DHUDGuiSlotManager:clearPreviewData()
	-- to be overriden
	self:onDataTrackerChange();
	self:onDataUnitChange();
	self:onDataChange();
end

--- Return true if this slot is regenerating something or false otherwise
function DHUDGuiSlotManager:getIsRegenerating()
	return self.isRegenerating;
end

--- Return true if this slot shows some data, false otherwise
function DHUDGuiSlotManager:getIsExists()
	return self.currentDataTracker ~= nil;
end

--- Return unitId that is being tracked by this slot manager
function DHUDGuiSlotManager:getTrackedUnitId()
	if (self.currentDataTracker == nil) then
		return "";
	end
	return self.currentDataTracker.trackUnitId;
end
