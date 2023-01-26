--[[-----------------------------------------------------------------------------------
 Original Drathals HUD (c) 2006 by Markus Inger / Drathal / Silberklinge / Silbersegen
 DHUD for WotLK and later expansions (c) 2013 by MADCAT (EU-Гордунни, Мадкат)
 (http://eu.battle.net/wow/en/character/гордунни/Мадкат/advanced)
---------------------------------------------------------------------------------------
 This file contains object that will show casting information data on castbar GUI slot
 @author: MADCAT
-----------------------------------------------------------------------------------]]--

--------------------------
-- Gui Cast Bar Manager --
--------------------------

--- Class to manage single bar
DHUDCastBarManager = MCCreateSubClass(DHUDGuiSlotManager, {
	-- group with cast bar to be used when displaying data
	group		= nil,
	-- reference to cast bar animation helper
	helper		= nil,
	-- defines if data exists?
	isExists	= false,
	-- defines if cast bar info is currently visible
	castBarInfoVisible = true,
	-- defines if cast bar info should be visible
	castBarInfoShouldBeVisible = false,
	-- number of castbar stage frames in use by this manager
	castBarStages = 0,
	-- id of the unit from DHUDColorizeTools constants
	unitColorId = 0,
	-- allows to show or hide player cast bar info
	STATIC_showPlayerCastBarInfo = true,
	-- allows to show or hide player gcd
	STATIC_showPlayerGcd = true,
	-- allows to always show cast bar background texture
	STATIC_alwaysShowCastBarBackground = true,
	-- map with functions that are available to output cast info to text
	FUNCTIONS_MAP_CASTINFO = { },
})

--- show player cast bar info setting changed
function DHUDCastBarManager:STATIC_onSelfCastBarInfoSettingChange(e)
	self.STATIC_showPlayerCastBarInfo = DHUDSettings:getValue("misc_showPlayerCastBarInfo");
end

--- show player cast bar gcd setting changed
function DHUDCastBarManager:STATIC_onSelfCastBarGcdSettingChange(e)
	self.STATIC_showPlayerGcd = DHUDSettings:getValue("misc_showGcdOnPlayerCastBar");
end

--- always show cast bar background setting changed
function DHUDCastBarManager:STATIC_onAlwaysShowCastBarBackgroundSettingChange(e)
	self.STATIC_alwaysShowCastBarBackground = DHUDSettings:getValue("misc_alwaysShowCastBarBackground");
end

--- Initialize DHUDGuiBarManager static values
function DHUDCastBarManager:STATIC_init()
	-- init functions map
	self.FUNCTIONS_MAP_CASTINFO["color"] = DHUDTextTools.createTextColorizeStart;
	self.FUNCTIONS_MAP_CASTINFO["/color"] = DHUDTextTools.createTextColorizeStop;
	self.FUNCTIONS_MAP_CASTINFO["time"] = self.createTextTime;
	self.FUNCTIONS_MAP_CASTINFO["time_remain"] = self.createTextTimeRemain;
	self.FUNCTIONS_MAP_CASTINFO["time_total"] = self.createTextTimeTotal;
	self.FUNCTIONS_MAP_CASTINFO["delay"] = self.createTextDelay;
	self.FUNCTIONS_MAP_CASTINFO["spellname"] = self.createTextSpellName;
	-- listen to settings
	DHUDSettings:addEventListener(DHUDSettingsEvent.EVENT_SPECIFIC_SETTING_CHANGED_PREFIX .. "misc_showGcdOnPlayerCastBar", self, self.STATIC_onSelfCastBarGcdSettingChange);
	DHUDSettings:addEventListener(DHUDSettingsEvent.EVENT_SPECIFIC_SETTING_CHANGED_PREFIX .. "misc_showPlayerCastBarInfo", self, self.STATIC_onSelfCastBarInfoSettingChange);
	DHUDSettings:addEventListener(DHUDSettingsEvent.EVENT_SPECIFIC_SETTING_CHANGED_PREFIX .. "misc_alwaysShowCastBarBackground", self, self.STATIC_onAlwaysShowCastBarBackgroundSettingChange);
	self:STATIC_onSelfCastBarInfoSettingChange(nil);
	self:STATIC_onSelfCastBarGcdSettingChange(nil);
	self:STATIC_onAlwaysShowCastBarBackgroundSettingChange(nil);
end

--- Create new bar manager
function DHUDCastBarManager:new()
	local o = self:defconstructor();
	o:constructor();
	return o;
end

--- Construct bar manager
function DHUDCastBarManager:constructor()
	DHUDGuiSlotManager.constructor(self); -- call super
end

--- Create text that contains data cast time
-- @param this reference to this bar manager (self is nil)
-- @return text to be shown in gui
function DHUDCastBarManager:createTextTime(this)
	local value = this.currentDataTracker.timeProgress;
	if (value < 0) then
		value = 0;
	end
	return DHUDTextTools:formatNumberWithPrecision(value, 1);
end

--- Create text that contains data remaining cast time
-- @param this reference to this bar manager (self is nil)
-- @return text to be shown in gui
function DHUDCastBarManager:createTextTimeRemain(this)
	local value;
	if (this.currentDataTracker.isChannelSpell ~= 1) then
		value = this.currentDataTracker.timeTotal - this.currentDataTracker.timeProgress;
	else
		value = this.currentDataTracker.timeProgress;
	end
	--print("timeRemain progress " .. this.currentDataTracker.timeProgress .. " total " .. this.currentDataTracker.timeTotal);
	if (value < 0) then
		value = 0;
	end
	return DHUDTextTools:formatNumberWithPrecision(value, 1);
end

--- Create text that contains data total cast time
-- @param this reference to this bar manager (self is nil)
-- @return text to be shown in gui
function DHUDCastBarManager:createTextTimeTotal(this)
	local value = this.currentDataTracker.timeTotal;
	return DHUDTextTools:formatNumberWithPrecision(value, 1);
end

--- Create text that contains data cast delay
-- @param this reference to this bar manager (self is nil)
-- @param castPrefix prefix before delay text for spell casts
-- @param channelPrefix prefix before delay text for spell channels
-- @return text to be shown in gui
function DHUDCastBarManager:createTextDelay(this, castPrefix, channelPrefix)
	local value = this.currentDataTracker.delay;
	if (value <= 0) then
		return "";
	end
	if (this.currentDataTracker.isChannelSpell == 1) then
		return (channelPrefix or "") .. DHUDTextTools:formatNumberWithPrecision(value, 1);
	else
		return (castPrefix or "") .. DHUDTextTools:formatNumberWithPrecision(value, 1);
	end
end

--- Create text that contains data cast spell name
-- @param this reference to this bar manager (self is nil)
-- @param canceledText text to be shown when spell was canceled
-- @param interruptedText text to be shown when spell was interrupted
-- @param interruptedByPlayerText text to be shown when spell was interrupted by player
-- @param interruptedNamePrefix text to be shown before player name that interrupted spell, or nil if name is not required
-- @return text to be shown in gui
function DHUDCastBarManager:createTextSpellName(this, canceledText, interruptedText, interruptedByPlayerText, interruptedNamePrefix, interruptedNamePostfix)
	interruptedText = interruptedText or "|cff0000ffINTERRUPTED|r";
	canceledText = canceledText or "|cff0000ffCANCELED|r";
	interruptedByPlayerText = interruptedByPlayerText or "|cff0000ffINTERRUPTED BY ME|r";
	local value = this.currentDataTracker.spellName;
	local finishState = this.currentDataTracker.finishState;
	if (not this.currentDataTracker.isCasting and (not this.currentDataTracker.isGcd or not this.STATIC_showPlayerGcd)) then
		if (finishState == DHUDSpellCastTracker.SPELL_FINISH_STATE_INTERRUPTED) then
			local interruptState = this.currentDataTracker.interruptState;
			if (interruptState == DHUDSpellCastTracker.SPELL_INTERRUPT_STATE_CANCELED) then
				value = canceledText;
			elseif (interruptState == DHUDSpellCastTracker.SPELL_INTERRUPT_STATE_KICKED_BY_PLAYER) then
				value = interruptedByPlayerText;
			else
				if (interruptedNamePrefix ~= nil and interruptedNamePostfix ~= nil) then
					value = interruptedText .. interruptedNamePrefix .. DHUDTextTools:getShortPlayerName(this.currentDataTracker.interruptedBy) .. interruptedNamePostfix;
				else
					value = interruptedText;
				end
			end
		end
	end
	return value;
end

--- Colorize cast bar according to value height
-- @param valueHeight height of the value
function DHUDCastBarManager:colorizeCastBar(valueHeight)
	local colors;
	-- return another color if interrupted
	if (not self.currentDataTracker.isCasting and (not self.currentDataTracker.isGcd or not self.STATIC_showPlayerGcd)) then
		if (self.currentDataTracker.finishState == DHUDSpellCastTracker.SPELL_FINISH_STATE_INTERRUPTED) then
			colors = DHUDColorizeTools:getColorTableForId(DHUDColorizeTools.COLOR_ID_TYPE_CASTBAR_INTERRUPTED + self.unitColorId);
			return DHUDColorizeTools:colorizePercentUsingTable(valueHeight, colors);
		end
	end
	-- get colors table
	if (self.currentDataTracker.isChannelSpell == 1) then
		if (self.currentDataTracker.isInterruptible) then
			colors = DHUDColorizeTools:getColorTableForId(DHUDColorizeTools.COLOR_ID_TYPE_CASTBAR_CHANNEL + self.unitColorId);
		else
			colors = DHUDColorizeTools:getColorTableForId(DHUDColorizeTools.COLOR_ID_TYPE_CASTBAR_LOCKED_CHANNEL + self.unitColorId);
		end
	else
		if (self.currentDataTracker.isInterruptible) then
			colors = DHUDColorizeTools:getColorTableForId(DHUDColorizeTools.COLOR_ID_TYPE_CASTBAR_CAST + self.unitColorId);
		else
			colors = DHUDColorizeTools:getColorTableForId(DHUDColorizeTools.COLOR_ID_TYPE_CASTBAR_LOCKED_CAST + self.unitColorId);
		end
	end
	-- colorize
	return DHUDColorizeTools:colorizePercentUsingTable(valueHeight, colors);
end

--- Get current cast time progress
function DHUDCastBarManager:getCurrentCastTime()
	return self.currentDataTracker:getTimeProgress();
end

--- Change visibility of cast info frames
-- @param visible defines if cast info frames should be visible
function DHUDCastBarManager:changeCastInfoVisibility(visible)
	if (self.castBarInfoVisible == visible)	then
		return;
	end
	self.castBarInfoVisible = visible;
	if (visible) then
		self.group[DHUDGUI.CASTBAR_GROUP_INDEX_SPELLNAME]:DShow(DHUDGUI.FRAME_VISIBLE_REASON_ENABLED);
		self.group[DHUDGUI.CASTBAR_GROUP_INDEX_ICON]:DShow(DHUDGUI.FRAME_VISIBLE_REASON_ENABLED);
	else
		self.group[DHUDGUI.CASTBAR_GROUP_INDEX_SPELLNAME]:DHide(DHUDGUI.FRAME_VISIBLE_REASON_ENABLED);
		self.group[DHUDGUI.CASTBAR_GROUP_INDEX_ICON]:DHide(DHUDGUI.FRAME_VISIBLE_REASON_ENABLED);
	end
end


--- current data tracker data changed
function DHUDCastBarManager:onDataChange(e)
	-- check if atleast one cast was made
	if (not self.isExists) then
		if (self.currentDataTracker.hasCasted) then
			self.isExists = true;
			DHUDGUIManager:onSlotExistanceStateChanged();
		end
	end
	-- update text
	self.group[DHUDGUI.CASTBAR_GROUP_INDEX_CASTTIME].textField:DSetText(self.textFormatTimeFunction());
	self.group[DHUDGUI.CASTBAR_GROUP_INDEX_DELAY].textField:DSetText(self.textFormatDelayFunction());
	self.group[DHUDGUI.CASTBAR_GROUP_INDEX_SPELLNAME].textField:DSetText(self.textFormatSpellNameFunction());
	-- update empower groups
	local numStages = self.currentDataTracker.numStages;
	for i = numStages, self.castBarStages, 1 do
		self.group[DHUDGUI.CASTBAR_GROUP_INDEX_EMPOWER1 + i - 1]:DHide();
	end
	if (numStages > 0) then
		local totalTime = self.currentDataTracker.timeTotal;
		local empowerTimes = self.currentDataTracker.stageDurations;
		local empowerTime = 0;
		for i = 1, numStages, 1 do
			empowerTime = empowerTime + empowerTimes[i];
			local height = empowerTime / totalTime;
			--print("i " .. i .. " height " .. height .. " empower " .. empowerTime .. " total " .. totalTime);
			local empowerFrame = self.group[DHUDGUI.CASTBAR_GROUP_INDEX_EMPOWER1 + i - 1];
			empowerFrame:DShow();
			self.helper:updateCastBarEmpowerPosition(empowerFrame, empowerTime / totalTime, {1, 1, 1});
		end
	end
	self.castBarStages = numStages;
	-- update icon
	local icon = self.group[DHUDGUI.CASTBAR_GROUP_INDEX_ICON];
	icon:SetNormalTexture(self.currentDataTracker.spellTexture);
	if (self.currentDataTracker.isInterruptible) then
		icon.border:Hide();
	else
		icon.border:Show();
	end
	self:changeCastInfoVisibility(self.castBarInfoShouldBeVisible);
	-- update animation state
	if (self.currentDataTracker.isCasting) then
		self.helper:startCastBarAnimation(self.currentDataTracker.timeTotal);
	elseif (self.currentDataTracker.isGcd and self.STATIC_showPlayerGcd) then
		self.helper:startCastBarAnimation(self.currentDataTracker.timeTotal);
		self:changeCastInfoVisibility(false);
	else
		local finishState = self.currentDataTracker.finishState;
		if (finishState == DHUDSpellCastTracker.SPELL_FINISH_STATE_SUCCEDED) then
			self.helper:flashAndFadeOut();
		elseif (finishState == DHUDSpellCastTracker.SPELL_FINISH_STATE_INTERRUPTED) then
			self.helper:holdAndFadeOut();
		else -- unknown state or unit is not casting
			self.helper:hideCastBar();
		end
	end
end

--- current data tracker timers changed
function DHUDCastBarManager:onDataTimersChange(e)
	-- update time text
	self.group[DHUDGUI.CASTBAR_GROUP_INDEX_CASTTIME].textField:DSetText(self.textFormatTimeFunction());
end

--- new data tracker has been set for this slot, update if neccesary
function DHUDCastBarManager:onDataTrackerChange(e)
	self.castBarInfoShouldBeVisible = true;
	-- switch by unit type
	if (self.currentDataTracker.trackUnitId == "player") then
		self.unitColorId = DHUDColorizeTools.COLOR_ID_UNIT_SELF;
		self:setTextFormatParamsForVariable("unitTexts_player_castTime", self.FUNCTIONS_MAP_CASTINFO, "textFormatTimeFunction");
		self:setTextFormatParamsForVariable("unitTexts_player_castDelay", self.FUNCTIONS_MAP_CASTINFO, "textFormatDelayFunction");
		self:setTextFormatParamsForVariable("unitTexts_player_castSpellName", self.FUNCTIONS_MAP_CASTINFO, "textFormatSpellNameFunction");
		-- hide cast info if required
		self.castBarInfoShouldBeVisible = self.STATIC_showPlayerCastBarInfo;
	else
		self.unitColorId = DHUDColorizeTools.COLOR_ID_UNIT_TARGET;
		self:setTextFormatParamsForVariable("unitTexts_target_castTime", self.FUNCTIONS_MAP_CASTINFO, "textFormatTimeFunction");
		self:setTextFormatParamsForVariable("unitTexts_target_castDelay", self.FUNCTIONS_MAP_CASTINFO, "textFormatDelayFunction");
		self:setTextFormatParamsForVariable("unitTexts_target_castSpellName", self.FUNCTIONS_MAP_CASTINFO, "textFormatSpellNameFunction");
	end
end

--- new unit has been selected by data tracker
function DHUDCastBarManager:onDataUnitChange(e)
	-- until unit didn't cast anything - bar background should be hidden, if unit has no bar in this slot, notify gui manager
	self.isExists = self.STATIC_alwaysShowCastBarBackground;
	DHUDGUIManager:onSlotExistanceStateChanged();
end

--- current data tracker existance changed, check currentDataTracker variable for existance
function DHUDCastBarManager:onExistanceChange()
	-- no data to visualize
	if (self.currentDataTracker == nil) then
		self.helper:hideCastBar();
		self.isExists = false;
	else
		self.isExists = self.STATIC_alwaysShowCastBarBackground;
	end
	-- notify gui manager
	DHUDGUIManager:onSlotExistanceStateChanged();
end

--- cast bar setting changed, update
function DHUDCastBarManager:onCastBarSettingChange(e)
	if (self.currentDataTracker == nil) then
		return;
	end
	self:onDataTrackerChange(nil); -- this will cause to hide or show player cast bar info or gcd
end

--- cast bar background setting changed, update
function DHUDCastBarManager:onCastBarBackgroundSettingChange(e)
	if (self.currentDataTracker == nil) then
		return;
	end
	-- this will cause to update background texture
	self:onDataUnitChange(nil);
	self:onDataChange(nil);
end

--- Initialize cast bar manager
-- @param groupName name of the group to use
-- @param settingName name of the setting that holds data trackers list
function DHUDCastBarManager:init(groupName, settingName)
	self.group = DHUDGUI.frameGroups[groupName];
	self.helper = self.group.helper;
	-- initialize helper
	self.helper:init(self.colorizeCastBar, self.getCurrentCastTime, self);
	-- initialize setting name
	self:setDataTrackerListSetting(settingName);
	-- track cast bar info setting change
	DHUDSettings:addEventListener(DHUDSettingsEvent.EVENT_SPECIFIC_SETTING_CHANGED_PREFIX .. "misc_showGcdOnPlayerCastBar", self, self.onCastBarSettingChange);
	DHUDSettings:addEventListener(DHUDSettingsEvent.EVENT_SPECIFIC_SETTING_CHANGED_PREFIX .. "misc_showPlayerCastBarInfo", self, self.onCastBarSettingChange);
	DHUDSettings:addEventListener(DHUDSettingsEvent.EVENT_SPECIFIC_SETTING_CHANGED_PREFIX .. "misc_alwaysShowCastBarBackground", self, self.onCastBarBackgroundSettingChange);
	-- track color settings change
	self:trackColorSettingsChanges();
end

--- Return true if this slot shows some data, false otherwise
function DHUDCastBarManager:getIsExists()
	return self.isExists;
end

--- Show preview data
function DHUDCastBarManager:showPreviewData()
	-- just show all ui elements
	for i, v in ipairs(self.group) do
		v:DShow();
	end
end

--- Clear preview data
function DHUDCastBarManager:clearPreviewData()
	-- hide all ui elements
	for i, v in ipairs(self.group) do
		v:DHide();
	end
	-- call super
	if (self.currentDataTracker ~= nil) then
		DHUDGuiSlotManager.clearPreviewData(self);
	end
end
