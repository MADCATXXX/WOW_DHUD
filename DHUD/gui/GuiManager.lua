--[[-----------------------------------------------------------------------------------
 Original Drathals HUD (c) 2006 by Markus Inger / Drathal / Silberklinge / Silbersegen
 DHUD for WotLK and later expansions (c) 2013 by MADCAT (EU-Гордунни, Мадкат)
 (http://eu.battle.net/wow/en/character/гордунни/Мадкат/advanced)
---------------------------------------------------------------------------------------
 This file contains managing functions, connecting data with gui
 @author: MADCAT
-----------------------------------------------------------------------------------]]--

-----------------
-- GUI Manager --
-----------------

--- Class to control graphical user interface
DHUDGUIManager = {
	-- defines if gui is in regenerating state, required to change alpha
	isRegenerating		= false,
	-- defines if player is in combat
	isInCombat			= false,
	-- defines if player turned auto-attack on
	isAttacking			= false,
	-- defines if player is dead
	isDead				= false,
	-- defines if settings preview mode is active
	isPreviewMode		= false,
	-- defines if player has target selected
	hasTarget			= false,
	-- manager of the left inner big bar
	leftBigBar1			= nil,
	-- manager of the left outer big bar
	leftBigBar2			= nil,
	-- manager of the left inner small bar
	leftSmallBar1		= nil,
	-- manager of the left outer small bar
	leftSmallBar2		= nil,
	-- manager of the right inner big bar
	rightBigBar1		= nil,
	-- manager of the right outer big bar
	rightBigBar2		= nil,
	-- manager of the right inner small bar
	rightSmallBar1		= nil,
	-- manager of the right outer small bar
	rightSmallBar2		= nil,
	-- list with bar managers
	barManagers			= nil,
	-- manager of the left inner big cast bar
	leftBigCastBar1		= nil,
	-- manager of the left outer big cast bar
	leftBigCastBar2		= nil,
	-- manager of the right inner big cast bar
	rightBigCastBar1	= nil,
	-- manager of the right outer big cast bar
	rightBigCastBar2	= nil,
	-- list with cast bar managers
	castBarManagers		= nil,
	-- manager of left outer side info
	leftOuterSideInfo	= nil,
	-- manager of left inner side info
	leftInnerSideInfo	= nil,
	-- manager of right outer side info
	rightOuterSideInfo	= nil,
	-- manager of right inner side info
	rightInnerSideInfo	= nil,
	-- list with side info managers
	sideManagers = nil,
	-- manager of top unit info
	centerUnitInfo1		= nil,
	-- manager of bottom unit info
	centerUnitInfo2		= nil,
	-- list with unit info managers
	unitInfoManagers = nil,
	-- manager of left rectangles
	leftRectangles = nil,
	-- manager of left rectangles
	rightRectangles = nil,
	-- list with rectangle frame managers
	rectangleManagers = nil,
	-- manager for icons
	icons				= nil,
	-- current alpha type
	alphaType = 0,
	-- alpha type for situation when player in combat
	ALPHA_TYPE_INCOMBAT	= 1,
	-- alpha type for situation when player is out of combat, but has target
	ALPHA_TYPE_HASTARGET = 2,
	-- alpha type for situation when player is out of combat, without target, but resources are regenerating
	ALPHA_TYPE_REGENERATING = 3,
	-- alpha type for situation when player is out of combat and no other condition is met
	ALPHA_TYPE_OTHER	= 4,
	-- values of alpha for different alpha types, readed from settings
	ALPHA_VALUES = { },
	-- defines if alpha is switched off due to some game event
	alphaIsSwitchedOff = false,
	-- alpha switch off type for situation when player is engaged in pet battle
	ALPHA_SWITCH_OFF_TYPE_PET_BATTLE = 1,
	-- values of switch off alpha state for different switch off alpha types
	ALPHA_SWITCH_OFF_STATES = { },
	-- values of switch off alpha for different switch off alpha types, readed from settings
	ALPHA_SWITCH_OFF_SETTINGS = { },
}

--- Initialize DHUD gui manager, providing data to frames
function DHUDGUIManager:init()
	DHUDGuiBarManager:STATIC_init();
	DHUDUnitInfoManager:STATIC_init();
	DHUDSideInfoManager:STATIC_init();
	DHUDSpellRectanglesManager:STATIC_init();
	DHUDIconsManager:STATIC_init();
	DHUDCastBarManager:STATIC_init();
	-- create bar managers
	self.leftBigBar1 = DHUDGuiBarManager:new();
	self.leftBigBar2 = DHUDGuiBarManager:new();
	self.leftSmallBar1 = DHUDGuiBarManager:new();
	self.leftSmallBar2 = DHUDGuiBarManager:new();
	self.rightBigBar1 = DHUDGuiBarManager:new();
	self.rightBigBar2 = DHUDGuiBarManager:new();
	self.rightSmallBar1 = DHUDGuiBarManager:new();
	self.rightSmallBar2 = DHUDGuiBarManager:new();
	self.barManagers = { self.leftBigBar1, self.leftBigBar2, self.leftSmallBar1, self.leftSmallBar2, self.rightBigBar1, self.rightBigBar2, self.rightSmallBar1, self.rightSmallBar2 };
	-- create cast bar managers
	self.leftBigCastBar1 = DHUDCastBarManager:new();
	self.leftBigCastBar2 = DHUDCastBarManager:new();
	self.rightBigCastBar1 = DHUDCastBarManager:new();
	self.rightBigCastBar2 = DHUDCastBarManager:new();
	self.castBarManagers = { self.leftBigCastBar1, self.leftBigCastBar2, self.rightBigCastBar1, self.rightBigCastBar2 };
	-- create side info managers
	self.leftOuterSideInfo = DHUDSideInfoManager:new();
	self.leftInnerSideInfo = DHUDSideInfoManager:new();
	self.rightOuterSideInfo = DHUDSideInfoManager:new();
	self.rightInnerSideInfo = DHUDSideInfoManager:new();
	self.sideManagers = { self.leftOuterSideInfo, self.leftInnerSideInfo, self.rightOuterSideInfo, self.rightInnerSideInfo };
	-- create unit info managers
	self.centerUnitInfo1 = DHUDUnitInfoManager:new();
	self.centerUnitInfo2 = DHUDUnitInfoManager:new();
	self.unitInfoManagers = { self.centerUnitInfo1, self.centerUnitInfo2 };
	-- create rectangle frame managers
	self.leftRectangles = DHUDSpellRectanglesManager:new();
	self.rightRectangles = DHUDSpellRectanglesManager:new();
	self.rectangleManagers = { self.leftRectangles, self.rightRectangles };
	-- create icons manager
	self.icons = DHUDIconsManager:new();
	-- track alpha settings
	self:processAlphaSetting(self.ALPHA_TYPE_INCOMBAT, "alpha_combat");
	self:processAlphaSetting(self.ALPHA_TYPE_HASTARGET, "alpha_hasTarget");
	self:processAlphaSetting(self.ALPHA_TYPE_REGENERATING, "alpha_regen");
	self:processAlphaSetting(self.ALPHA_TYPE_OTHER, "alpha_outOfCombat");
	self:processSwitchOffAlphaSetting(self.ALPHA_SWITCH_OFF_TYPE_PET_BATTLE, "misc_hideInPetBattles");
	-- listen to preview settings
	DHUDSettings:addEventListener(DHUDSettingsEvent.EVENT_START_PREVIEW, self, self.onPreviewStart);
	DHUDSettings:addEventListener(DHUDSettingsEvent.EVENT_STOP_PREVIEW, self, self.onPreviewStop);
	-- init slot managers
	self.leftBigBar1:init("leftBigBar1", "framesData_leftBigBar1");
	self.leftBigBar2:init("leftBigBar2", "framesData_leftBigBar2");
	self.leftSmallBar1:init("leftSmallBar1", "framesData_leftSmallBar1");
	self.leftSmallBar2:init("leftSmallBar2", "framesData_leftSmallBar2");
	self.rightBigBar1:init("rightBigBar1", "framesData_rightBigBar1");
	self.rightBigBar2:init("rightBigBar2", "framesData_rightBigBar2");
	self.rightSmallBar1:init("rightSmallBar1", "framesData_rightSmallBar1");
	self.rightSmallBar2:init("rightSmallBar2", "framesData_rightSmallBar2");
	self.leftBigCastBar1:init("leftBigCastBar1", "framesData_leftBigCastBar1");
	self.leftBigCastBar2:init("leftBigCastBar2", "framesData_leftBigCastBar2");
	self.rightBigCastBar1:init("rightBigCastBar1", "framesData_rightBigCastBar1");
	self.rightBigCastBar2:init("rightBigCastBar2", "framesData_rightBigCastBar2");
	self.leftOuterSideInfo:init("runesBigLeft", "spellCirclesBigLeft", "comboPointsBigLeft", "framesData_leftOuterSideInfo");
	self.leftInnerSideInfo:init("runesSmallLeft", "spellCirclesSmallLeft", "comboPointsSmallLeft", "framesData_leftInnerSideInfo");
	self.rightOuterSideInfo:init("runesBigRight", "spellCirclesBigRight", "comboPointsBigRight", "framesData_rightOuterSideInfo");
	self.rightInnerSideInfo:init("runesSmallRight", "spellCirclesSmallRight", "comboPointsSmallRight", "framesData_rightInnerSideInfo");
	self.centerUnitInfo1:init("DHUD_Center_TextInfo1", "framesData_centerUnitInfo1");
	self.centerUnitInfo2:init("DHUD_Center_TextInfo2", "framesData_centerUnitInfo2");
	self.leftRectangles:init("spellRectanglesLeft", "framesData_leftRectangles");
	self.rightRectangles:init("spellRectanglesRight", "framesData_rightRectangles");
	self.icons:init("DHUD_Icon_SelfUnitIconPvP", "DHUD_Icon_SelfUnitIconState", "DHUD_Icon_TargetEliteDragon", "targetIcons");
	-- track values required to change alpha and visibility
	DHUDDataTrackers.helper:addEventListener(DHUDDataTrackerHelperEvent.EVENT_COMBAT_STATE_CHANGED, self, self.onCombatState);
	DHUDDataTrackers.helper:addEventListener(DHUDDataTrackerHelperEvent.EVENT_TARGET_UPDATED, self, self.onTargetUpdated);
	DHUDDataTrackers.helper:addEventListener(DHUDDataTrackerHelperEvent.EVENT_ATTACK_STATE_CHANGED, self, self.onAttackState);
	DHUDDataTrackers.helper:addEventListener(DHUDDataTrackerHelperEvent.EVENT_DEATH_STATE_CHANGED, self, self.onDeathState);
	DHUDDataTrackers.helper:addEventListener(DHUDDataTrackerHelperEvent.EVENT_PETBATTLE_STATE_CHANGED, self, self.onPetBattleState);
	self:onAttackState(nil);
	self:onCombatState(nil);
	self:onTargetUpdated(nil);
	self:onDeathState(nil);
	self:onPetBattleState(nil);
end

--- Shows tooltip for circle frame specified
-- @param circleFrame circle frame to show tooltip for
function DHUDGUIManager:showSpellCircleTooltip(circleFrame)
	-- find group of spellcircle frame
	for i, v in ipairs(self.sideManagers) do
		if (MCIndexOfValueInTable(v.spellCirclesGroup, circleFrame) >= 0) then
			v:showSpellCircleTooltip(circleFrame);
			return;
		end
	end
end

--- Shows tooltip for rectangle frame specified
-- @param circleFrame rectangle frame to show tooltip for
function DHUDGUIManager:showSpellRectangleTooltip(rectangleFrame)
	-- find group of spellrectangle frame
	for i, v in ipairs(self.rectangleManagers) do
		if (MCIndexOfValueInTable(v.group, rectangleFrame) >= 0) then
			v:showSpellRectangleTooltip(rectangleFrame);
			return;
		end
	end
end

--- Shows unit info dropdown
-- @param frame frame that was clicked
function DHUDGUIManager:toggleUnitTextDropdown(frame)
	-- find group of spellrectangle frame
	for i, v in ipairs(self.unitInfoManagers) do
		if (v.textFrame == frame) then
			v:toggleUnitTextDropdown(frame);
			return;
		end
	end
end

--- update gui alpha according to situation
-- @param force if true than alpha will be updated to same valueType, required for setting changes and preview
function DHUDGUIManager:updateAlpha(force)
	-- calculate switch off state
	local newAlphaIsSwitchedOff = false;
	for i, v in ipairs(self.ALPHA_SWITCH_OFF_STATES) do
		if (v and self.ALPHA_SWITCH_OFF_SETTINGS[i]) then
			newAlphaIsSwitchedOff = true;
			break;
		end
	end
	--print("newAlphaIsSwitchedOff " .. MCTableToString(newAlphaIsSwitchedOff) .. " ALPHA_SWITCH_OFF_STATES " .. MCTableToString(self.ALPHA_SWITCH_OFF_STATES) .. " ALPHA_SWITCH_OFF_SETTINGS " .. MCTableToString(self.ALPHA_SWITCH_OFF_SETTINGS));
	local newAlphaType = self.ALPHA_TYPE_OTHER;
	if (self.isInCombat or self.isAttacking) then
		newAlphaType = self.ALPHA_TYPE_INCOMBAT;
	elseif (self.hasTarget) then
		newAlphaType = self.ALPHA_TYPE_HASTARGET;
	elseif (self.isRegenerating) then
		newAlphaType = self.ALPHA_TYPE_REGENERATING;
	end
	if (self.alphaIsSwitchedOff == newAlphaIsSwitchedOff and self.alphaType == newAlphaType and (not force)) then
		return;
	end
	self.alphaIsSwitchedOff = newAlphaIsSwitchedOff;
	self.alphaType = newAlphaType;
	local alpha = 0;
	if (not newAlphaIsSwitchedOff) then
		alpha = self.ALPHA_VALUES[self.alphaType];
	end
	-- alpha should be atleast 0.1 for preview
	if (self.isPreviewMode and alpha < 0.1) then
		alpha = 0.1;
	end
	-- change
	DHUDGUI:changeAlpha(alpha);
end

--- one of gui slots has changed regeneration state
function DHUDGUIManager:onSlotRegenerationStateChanged()
	local before = self.isRegenerating;
	self.isRegenerating = false;
	-- check bar managers
	for i, v in ipairs(self.barManagers) do
		self.isRegenerating = v:getTrackedUnitId() == "player" and v:getIsRegenerating();
		--print("bar unit " .. MCTableToString(v:getTrackedUnitId()) .. ", isRegen " .. MCTableToString(v:getIsRegenerating()));
		if (self.isRegenerating) then
			break;
		end
	end
	-- check side managers
	if (not self.isRegenerating) then
		for i, v in ipairs(self.sideManagers) do
			self.isRegenerating = v:getTrackedUnitId() == "player" and v:getIsRegenerating();
			--print("bar unit " .. MCTableToString(v:getTrackedUnitId()) .. ", isRegen " .. MCTableToString(v:getIsRegenerating()));
			if (self.isRegenerating) then
				break;
			end
		end
	end
	-- check cast bar managers
	if (not self.isRegenerating) then
		for i, v in ipairs(self.castBarManagers) do
			self.isRegenerating = v:getTrackedUnitId() == "player" and v:getIsRegenerating();
			--print("bar unit " .. MCTableToString(v:getTrackedUnitId()) .. ", isRegen " .. MCTableToString(v:getIsRegenerating()));
			if (self.isRegenerating) then
				break;
			end
		end
	end
	--print("set self.isRegenerating " .. MCTableToString(self.isRegenerating));
	if (before ~= self.isRegenerating) then
		self:updateAlpha();
	end
end

--- DHUD Options addon requested to preview settings
function DHUDGUIManager:onPreviewStart(e)
	self.isPreviewMode = true;
	-- update alpha
	self:updateAlpha(true);
	-- update frames
	DHUDDataTrackers.helper:addEventListener(DHUDDataTrackerHelperEvent.EVENT_UPDATE_FREQUENT, self, self.onPreview);
	self:onPreview(nil);
end

--- Function to refresh preview
function DHUDGUIManager:onPreview(e)
	-- preview cast bars
	for i, v in ipairs(self.castBarManagers) do
		if (v.currentDataTracker ~= nil) then
			v:showPreviewData();
		end
	end
	-- preview side info
	for i, v in ipairs(self.sideManagers) do
		if (v.currentDataTracker ~= nil) then
			v:showPreviewData();
		end
	end
	-- preview rectangles
	for i, v in ipairs(self.rectangleManagers) do
		if (v.currentDataTracker ~= nil) then
			v:showPreviewData();
		end
	end
end

--- DHUD Options addon requested to stop settings preview
function DHUDGUIManager:onPreviewStop(e)
	self.isPreviewMode = false;
	DHUDDataTrackers.helper:removeEventListener(DHUDDataTrackerHelperEvent.EVENT_UPDATE_FREQUENT, self, self.onPreview);
	-- update alpha
	self:updateAlpha(true);
	-- stop cast bars preview
	for i, v in ipairs(self.castBarManagers) do
		if (v.currentDataTracker ~= nil) then
			v:clearPreviewData();
		end
	end
	-- stop side info preview
	for i, v in ipairs(self.sideManagers) do
		if (v.currentDataTracker ~= nil) then
			v:clearPreviewData();
		end
	end
	-- stop rectangles preview
	for i, v in ipairs(self.rectangleManagers) do
		if (v.currentDataTracker ~= nil) then
			v:clearPreviewData();
		end
	end
end

--- combat state changed, update alpha
function DHUDGUIManager:onCombatState(e)
	self.isInCombat = DHUDDataTrackers.helper.isInCombat;
	self:updateAlpha();
end

--- combat state changed, update alpha
function DHUDGUIManager:onAttackState(e)
	self.isAttacking = DHUDDataTrackers.helper.isAttacking;
	self:updateAlpha();
end

--- pet battle state changed, update alpha
function DHUDGUIManager:onPetBattleState(e)
	--print("isInPetBattle " .. MCTableToString(DHUDDataTrackers.helper.isInPetBattle));
	self.ALPHA_SWITCH_OFF_STATES[self.ALPHA_SWITCH_OFF_TYPE_PET_BATTLE] = DHUDDataTrackers.helper.isInPetBattle;
	self:updateAlpha();
end

--- death state changed, hide or show some frames
function DHUDGUIManager:onDeathState(e)
	self.isDead = DHUDDataTrackers.helper.isDead;
	-- player is dead hide bar text frames and side info frames
	if (self.isDead) then
		-- get list of frames with player information
		local list = { };
		-- add bars text
		for i, v in ipairs(self.barManagers) do
			if (v:getTrackedUnitId() == "player") then
				table.insert(list, v.textField.frame);
				table.insert(list, v.group);
			end
		end
		-- add side info frames
		for i, v in ipairs(self.sideManagers) do
			if (v:getTrackedUnitId() == "player") then
				table.insert(list, v.currentGroup);
			end
		end
		DHUDGUI:hideFramesWhenDead(list);
	else
		DHUDGUI:showFramesWhenAlive();
	end
end

--- combat state changed, update alpha
function DHUDGUIManager:onTargetUpdated(e)
	local before = self.hasTarget;
	self.hasTarget = DHUDDataTrackers.helper.isTargetAvailable;
	if (before ~= self.hasTarget) then
		self:updateAlpha();
	end
end

--- Process setting value and listen to setting changes
-- @param alphaType internal type of alpha from class consts
-- @param alphaSettingName name of the setting in Settings table
function DHUDGUIManager:processAlphaSetting(alphaType, alphaSettingName)
	local functionOnSettingChange = function(self, e)
		self.ALPHA_VALUES[alphaType] = DHUDSettings:getValue(alphaSettingName);
		if (self.alphaType == alphaType) then
			self:updateAlpha(true);
		end
	end
	DHUDSettings:addEventListener(DHUDSettingsEvent.EVENT_SPECIFIC_SETTING_CHANGED_PREFIX .. alphaSettingName, self, functionOnSettingChange);
	functionOnSettingChange(self, nil);
end

--- Process setting value and listen to setting changes
-- @param alphaType internal type of alpha from class consts
-- @param alphaSettingName name of the setting in Settings table
function DHUDGUIManager:processSwitchOffAlphaSetting(alphaType, alphaSettingName)
	local functionOnSettingChange = function(self, e)
		self.ALPHA_SWITCH_OFF_SETTINGS[alphaType] = DHUDSettings:getValue(alphaSettingName);
		if (self.ALPHA_SWITCH_OFF_STATES[alphaType] == true) then
			self:updateAlpha(true);
		end
	end
	DHUDSettings:addEventListener(DHUDSettingsEvent.EVENT_SPECIFIC_SETTING_CHANGED_PREFIX .. alphaSettingName, self, functionOnSettingChange);
	functionOnSettingChange(self, nil);
end

--- one of gui slots has changed existance state
function DHUDGUIManager:onSlotExistanceStateChanged()
	local backgroundLeft = 0;
	backgroundLeft = bit.bor(backgroundLeft, (self.leftBigBar1:getIsExists() or self.leftBigCastBar1:getIsExists()) and DHUDGUI.BACKGROUND_BAR_BIG1 or 0);
	backgroundLeft = bit.bor(backgroundLeft, (self.leftBigBar2:getIsExists() or self.leftBigCastBar2:getIsExists()) and DHUDGUI.BACKGROUND_BAR_BIG2 or 0);
	backgroundLeft = bit.bor(backgroundLeft, (self.leftSmallBar1:getIsExists()) and DHUDGUI.BACKGROUND_BAR_SMALL1 or 0);
	backgroundLeft = bit.bor(backgroundLeft, (self.leftSmallBar2:getIsExists()) and DHUDGUI.BACKGROUND_BAR_SMALL2 or 0);
	local backgroundRight = 0;
	backgroundRight = bit.bor(backgroundRight, (self.rightBigBar1:getIsExists() or self.rightBigCastBar1:getIsExists()) and DHUDGUI.BACKGROUND_BAR_BIG1 or 0);
	backgroundRight = bit.bor(backgroundRight, (self.rightBigBar2:getIsExists() or self.rightBigCastBar2:getIsExists()) and DHUDGUI.BACKGROUND_BAR_BIG2 or 0);
	backgroundRight = bit.bor(backgroundRight, (self.rightSmallBar1:getIsExists()) and DHUDGUI.BACKGROUND_BAR_SMALL1 or 0);
	backgroundRight = bit.bor(backgroundRight, (self.rightSmallBar2:getIsExists()) and DHUDGUI.BACKGROUND_BAR_SMALL2 or 0);
	-- update background
	DHUDGUI:changeBarsBackground(backgroundLeft, backgroundRight);
end
