--[[-----------------------------------------------------------------------------------
 Original Drathals HUD (c) 2006 by Markus Inger / Drathal / Silberklinge / Silbersegen
 DHUD for WotLK and later expansions (c) 2013 by MADCAT (EU-Гордунни, Мадкат)
 (http://eu.battle.net/wow/en/character/гордунни/Мадкат/advanced)
---------------------------------------------------------------------------------------
 This file contains object that will show ALL auras as spell rectangles
 @author: MADCAT
-----------------------------------------------------------------------------------]]--

------------------------------
-- Spell rectangles Manager --
------------------------------

--- Class to manage single side info slot
DHUDSpellRectanglesManager = MCCreateSubClass(DHUDGuiSlotManager, {
	-- group with spell rectangles to be used when displaying data
	group = nil,
	-- type of the auras to be shown in spell rectangles
	aurasType = 2,
	-- reference to timers colorize function
	timersColorizeFunc = nil,
	-- defines if timers time text should be shown
	showTimersText = true,
	-- allows to show buff timers on spell rectangles
	STATIC_showBuffTimers = true,
	-- allows to show debuff timers on spell rectangles
	STATIC_showDebuffTimers = true,
	-- All shown auras will be buffs
	AURAS_TYPE_BUFFS = 0,
	-- All shown auras will be debuffs
	AURAS_TYPE_DEBUFFS = 1,
	-- Auras type is not determined
	AURAS_TYPE_OTHER = 2,
})

--- buff timers settings has changed, process
function DHUDSpellRectanglesManager:STATIC_onBuffTimersSetting(e)
	self.STATIC_showBuffTimers = DHUDSettings:getValue("aurasOptions_showTimersOnTargetBuffs");
end

--- buff timers settings has changed, process
function DHUDSpellRectanglesManager:STATIC_onDebuffTimersSetting(e)
	self.STATIC_showDebuffTimers = DHUDSettings:getValue("aurasOptions_showTimersOnTargetDeBuffs");
end

--- Initialize DHUDSpellRectanglesManager class
function DHUDSpellRectanglesManager:STATIC_init()
	DHUDSettings:addEventListener(DHUDSettingsEvent.EVENT_SPECIFIC_SETTING_CHANGED_PREFIX .. "aurasOptions_showTimersOnTargetBuffs", self, self.STATIC_onBuffTimersSetting);
	DHUDSettings:addEventListener(DHUDSettingsEvent.EVENT_SPECIFIC_SETTING_CHANGED_PREFIX .. "aurasOptions_showTimersOnTargetDeBuffs", self, self.STATIC_onDebuffTimersSetting);
	self:STATIC_onBuffTimersSetting(nil);
	self:STATIC_onDebuffTimersSetting(nil);
end

--- Create new side info manager
function DHUDSpellRectanglesManager:new()
	local o = self:defconstructor();
	o:constructor();
	return o;
end

--- Construct side info manager
function DHUDSpellRectanglesManager:constructor()
	DHUDGuiSlotManager.constructor(self); -- call super
end

--- Shows tooltip for rectangle frame specified
-- @param rectangleFrame rectangle frame to show tooltip for
function DHUDSpellRectanglesManager:showSpellRectangleTooltip(rectangleFrame)
	local data = rectangleFrame.data;
	local type = data[1];
	--print("show tooltip for " .. MCTableToString(data));
	if (self.currentDataTracker:isInstanceOf(DHUDAurasTracker)) then
		if (bit.band(type, DHUDAurasTracker.TIMER_TYPE_MASK_BUFF) ~= 0) then
			GameTooltip:SetUnitBuff(self.currentDataTracker.unitId, data[5]);
		elseif (bit.band(type, DHUDAurasTracker.TIMER_TYPE_MASK_DEBUFF) ~= 0) then
			GameTooltip:SetUnitDebuff(self.currentDataTracker.unitId, data[5]);
		end
	elseif (self.currentDataTracker:isInstanceOf(DHUDCooldownsTracker)) then
		if (bit.band(type, DHUDCooldownsTracker.TIMER_TYPE_MASK_SPELL) ~= 0) then
			GameTooltip:SetSpellByID(data[5]);
		elseif (bit.band(type, DHUDCooldownsTracker.TIMER_TYPE_MASK_PETSPELL) ~= 0) then
			GameTooltip:SetSpellByID(data[5]);
		elseif (bit.band(type, DHUDCooldownsTracker.TIMER_TYPE_MASK_ITEM) ~= 0) then
			GameTooltip:SetInventoryItem(self.currentDataTracker.unitId, data[5]);
		end
	end
end

--- Function to colorize target buffs timer
-- @param timer timer info to colorize
-- @return table with color
function DHUDSpellRectanglesManager:colorizeTargetBuffsTimer(timer)
	local t = DHUDColorizeTools:getColorTableForId(DHUDColorizeTools.COLOR_ID_UNIT_TARGET + DHUDColorizeTools.COLOR_ID_TYPE_AURA_BUFF);
	return DHUDColorizeTools:colorizePercentUsingTable(timer[2] / timer[3], t);
end

--- Function to colorize target debuff timer
-- @param timer timer info to colorize
-- @return table with color
function DHUDSpellRectanglesManager:colorizeTargetDebuffsTimer(timer)
	local t = DHUDColorizeTools:getColorTableForId(DHUDColorizeTools.COLOR_ID_UNIT_TARGET + DHUDColorizeTools.COLOR_ID_TYPE_AURA_DEBUFF);
	return DHUDColorizeTools:colorizePercentUsingTable(timer[2] / timer[3], t);
end

--- Function to colorize timer
-- @param timer timer info to colorize
-- @return table with color
function DHUDSpellRectanglesManager:colorizeUnknownTimer(timer)
	local t = DHUDColorizeTools:getColorTableForId(DHUDColorizeTools.COLOR_ID_TYPE_UNKNOWN);
	return DHUDColorizeTools:colorizePercentUsingTable(timer[2] / timer[3], t);
end

--- Function to update spell rectangles data
-- @param timers list with timers
function DHUDSpellRectanglesManager:updateSpellRectangles(timers)
	local showTimersText = self.showTimersText;
	timers = timers or self.currentDataTracker:filterTimers(self.currentDataTrackerHelperFunction, self.dataTrackersListSettingName, true);
	self.group:setFramesShown(#timers);
	-- update icons and times, { type, timeLeft, duration, id, tooltipId, name, stacks, texture, exists, iterating, sortOrder }
	for i, v in ipairs(timers) do
		local spellRectangleFrame = self.group[i];
		spellRectangleFrame.data = v;
		spellRectangleFrame:SetNormalTexture(v[8]);
		-- colorize
		local color = self.timersColorizeFunc(self, v);
		spellRectangleFrame.border:SetVertexColor(color[1], color[2], color[3]);
		-- update text
		local time = (showTimersText and v[2] >= 0) and (DHUDColorizeTools:colorToColorizeString(color) .. DHUDTextTools:formatTime(v[2]) .. "|r") or "";
		spellRectangleFrame.textFieldTime:DSetText(time);
		local stackText = (v[7] > 1) and (DHUDColorizeTools:colorToColorizeString(color) .. ((v[13] ~= nil) and "&" or "") .. v[7] .. "|r") or "";
		spellRectangleFrame.textFieldCount:DSetText(stackText);
	end
end

--- Function to update spell circle times
function DHUDSpellRectanglesManager:updateSpellRectanglesTime()
	-- filter timers
	local timers, changed = self.currentDataTracker:filterTimers(self.currentDataTrackerHelperFunction, self.dataTrackersListSettingName);
	if (changed) then
		self:updateSpellRectangles(timers);
		return;
	end
	-- do not show text?
	if (not self.showTimersText) then
		return;
	end
	-- update icons and times, { type, timeLeft, duration, id, tooltipId, name, stacks, texture, exists, iterating, sortOrder }
	for i, v in ipairs(timers) do
		local spellRectangleFrame = self.group[i];
		-- colorize
		local color = self.timersColorizeFunc(self, v);
		spellRectangleFrame.border:SetVertexColor(color[1], color[2], color[3]);
		-- update text
		local time = (v[2] >= 0) and (DHUDColorizeTools:colorToColorizeString(color) .. DHUDTextTools:formatTime(v[2]) .. "|r") or "";
		spellRectangleFrame.textFieldTime:DSetText(time);
	end
end

--- current data tracker data changed
function DHUDSpellRectanglesManager:onDataChange(e)
	self:updateSpellRectangles();
end

--- current data tracker timers changed
function DHUDSpellRectanglesManager:onDataTimersChange(e)
	self:updateSpellRectanglesTime();
end

--- new data tracker has been set for this slot, update if neccesary
function DHUDSpellRectanglesManager:onDataTrackerChange(e)
	if (self.currentDataTrackerHelperFunction == DHUDTimersFilterHelperSettingsHandler.filterBuffAuras) then
		self.aurasType = self.AURAS_TYPE_BUFFS;
		self.timersColorizeFunc = self.colorizeTargetBuffsTimer;
		self.showTimersText = self.STATIC_showBuffTimers;
	elseif (self.currentDataTrackerHelperFunction == DHUDTimersFilterHelperSettingsHandler.filterDebuffAuras) then
		self.aurasType = self.AURAS_TYPE_DEBUFFS;
		self.timersColorizeFunc = self.colorizeTargetDebuffsTimer;
		self.showTimersText = self.STATIC_showDebuffTimers;
	else
		self.aurasType = self.AURAS_TYPE_OTHER;
		self.timersColorizeFunc = self.colorizeUnknownTimer;
		self.showTimersText = true;
	end
end

--- current data tracker existance changed, check currentDataTracker variable for existance
function DHUDSpellRectanglesManager:onExistanceChange()
	-- no data to visualize
	if (self.currentDataTracker == nil) then
		self.group:setFramesShown(0);
	end
end

--- Initialize side info manager
-- @param spellRectanglesGroupName name of the group with spell circles to use
-- @param settingName name of the setting that holds data trackers list
function DHUDSpellRectanglesManager:init(spellRectanglesGroupName, settingName)
	self.group = DHUDGUI.frameGroups[spellRectanglesGroupName];
	-- initialize setting name
	self:setDataTrackerListSetting(settingName);
	-- track color settings change (for spell rectangles)
	self:trackColorSettingsChanges();
	-- track timer settings change
	DHUDSettings:addEventListener(DHUDSettingsEvent.EVENT_SPECIFIC_SETTING_CHANGED_PREFIX .. "aurasOptions_showTimersOnTargetBuffs", self, self.onCriticalSettingChange);
	DHUDSettings:addEventListener(DHUDSettingsEvent.EVENT_SPECIFIC_SETTING_CHANGED_PREFIX .. "aurasOptions_showTimersOnTargetDeBuffs", self, self.onCriticalSettingChange);
end

--- Show preview data
function DHUDSpellRectanglesManager:showPreviewData()
	-- just show all ui elements
	local num = #self.group;
	self.group:setFramesShown(num);
end
