--[[-----------------------------------------------------------------------------------
 Original Drathals HUD (c) 2006 by Markus Inger / Drathal / Silberklinge / Silbersegen
 DHUD for WotLK and later expansions (c) 2013 by MADCAT (EU-Гордунни, Мадкат)
 (http://eu.battle.net/wow/en/character/гордунни/Мадкат/advanced)
---------------------------------------------------------------------------------------
 This file contains object that will show unit information (such as name/class)
 @author: MADCAT
-----------------------------------------------------------------------------------]]--

-----------------------
-- Unit Info Manager --
-----------------------

--- Class to manage single side info slot
DHUDUnitInfoManager = MCCreateSubClass(DHUDGuiSlotManager, {
	-- reference to text frame that is used to display information
	textFrame		= nil,
	-- map with functions that will generate info
	FUNCTIONS_MAP_INFO = { },
})

--- Initialize DHUDGuiBarManager static values
function DHUDUnitInfoManager:STATIC_init()
	-- fill functions map
	self.FUNCTIONS_MAP_INFO["level"] = self.createTextLevel;
	self.FUNCTIONS_MAP_INFO["elite"] = self.createTextElite;
	self.FUNCTIONS_MAP_INFO["name"] = self.createTextName;
	self.FUNCTIONS_MAP_INFO["class"] = self.createTextClass;
	self.FUNCTIONS_MAP_INFO["spec"] = self.createTextSpec;
	self.FUNCTIONS_MAP_INFO["race"] = self.createTextRace;
	self.FUNCTIONS_MAP_INFO["class_race"] = self.createTextClassRace;
	self.FUNCTIONS_MAP_INFO["guild"] = self.createTextGuild;
	self.FUNCTIONS_MAP_INFO["pvp"] = self.createTextPvP;
	self.FUNCTIONS_MAP_INFO["color"] = DHUDTextTools.createTextColorizeStart;
	self.FUNCTIONS_MAP_INFO["/color"] = DHUDTextTools.createTextColorizeStop;
	self.FUNCTIONS_MAP_INFO["color_level"] = self.createTextColorLevel;
	self.FUNCTIONS_MAP_INFO["color_reaction"] = self.createTextColorReaction;
	self.FUNCTIONS_MAP_INFO["color_class"] = self.createTextColorClass;
end

--- Create new unit info manager
function DHUDUnitInfoManager:new()
	local o = self:defconstructor();
	o:constructor();
	return o;
end

--- Construct unit info manager
function DHUDUnitInfoManager:constructor()
	DHUDGuiSlotManager.constructor(self); -- call super
end

--- Toggle unit dropdown list
-- @param frame frame that was clicked on
function DHUDUnitInfoManager:toggleUnitTextDropdown(frame)
	if (self:getTrackedUnitId() == "target") then
		DHUDGUI.ToggleDropDownMenu(1, nil, DHUD_DropDown_TargetMenu, frame, 25, 10); 
	end
end

--- Create text that contains unit level
-- @param this reference to this bar manager (self is nil)
-- @return text to be shown in gui
function DHUDUnitInfoManager:createTextLevel(this)
	local value = this.currentDataTracker.level;
	if (value < 0) then
		return "??"
	end
	return value;
end

--- Create text that contains unit elite type
-- @param this reference to this bar manager (self is nil)
-- @return text to be shown in gui
function DHUDUnitInfoManager:createTextElite(this)
	local value = this.currentDataTracker.eliteType;
	local community = this.currentDataTracker.communityTagged;
	local prefix = community and "*" or "";
	if (value == DHUDUnitInfoTracker.UNIT_ELITE_TYPE_BOSS) then
		return prefix .. "++";
	elseif (value == DHUDUnitInfoTracker.UNIT_ELITE_TYPE_RAREELITE) then
		return prefix .. "r+";
	elseif (value == DHUDUnitInfoTracker.UNIT_ELITE_TYPE_ELITE) then
		return prefix .. "+";
	elseif (value == DHUDUnitInfoTracker.UNIT_ELITE_TYPE_RARE) then
		return prefix .. "r";
	elseif (value == DHUDUnitInfoTracker.UNIT_ELITE_TYPE_BOSS) then
		return prefix .. "++";
	elseif (value == DHUDUnitInfoTracker.UNIT_ELITE_TYPE_MINION) then
		return prefix .. "-";
	else
		return prefix;
	end
end

--- Create text that contains unit name
-- @param this reference to this bar manager (self is nil)
-- @return text to be shown in gui
function DHUDUnitInfoManager:createTextName(this)
	local value = this.currentDataTracker.name;
	return value;
end

--- Create text that contains unit class
-- @param this reference to this bar manager (self is nil)
-- @return text to be shown in gui
function DHUDUnitInfoManager:createTextClass(this)
	local unitType = this.currentDataTracker.unitType;
	if (unitType == DHUDUnitInfoTracker.UNIT_TYPE_CREATURE) then
		return this.currentDataTracker.npcType;
	elseif (unitType == DHUDUnitInfoTracker.UNIT_TYPE_PLAYER) then
		return this.currentDataTracker.class;
	else
		return this.currentDataTracker.friendUnitTypeString;
	end
end

--- Create text that contains unit class
-- @param this reference to this bar manager (self is nil)
-- @return text to be shown in gui
function DHUDUnitInfoManager:createTextSpec(this)
	local unitType = this.currentDataTracker.unitType;
	if (unitType == DHUDUnitInfoTracker.UNIT_TYPE_CREATURE) then
		return this.currentDataTracker.npcType;
	elseif (unitType == DHUDUnitInfoTracker.UNIT_TYPE_PLAYER) then
		return this.currentDataTracker.specName;
	else
		return this.currentDataTracker.friendUnitTypeString;
	end
end

--- Create text that contains unit race
-- @param this reference to this bar manager (self is nil)
-- @return text to be shown in gui
function DHUDUnitInfoManager:createTextRace(this)
	local unitType = this.currentDataTracker.unitType;
	if (unitType == DHUDUnitInfoTracker.UNIT_TYPE_PLAYER) then
		return this.currentDataTracker.race;
	else
		return "";
	end
end

--- Create text that contains unit class and race
-- @param this reference to this bar manager (self is nil)
-- @param delimeter delimeter to use
-- @return text to be shown in gui
function DHUDUnitInfoManager:createTextClassRace(this, delimeter)
	local unitType = this.currentDataTracker.unitType;
	if (unitType == DHUDUnitInfoTracker.UNIT_TYPE_PLAYER) then
		delimeter = delimeter or " - ";
		return this.currentDataTracker.class .. delimeter .. this.currentDataTracker.race;
	elseif (unitType == DHUDUnitInfoTracker.UNIT_TYPE_CREATURE) then
		return this.currentDataTracker.npcType;
	else
		return this.currentDataTracker.friendUnitTypeString;
	end
end

--- Create text that contains unit guild
-- @param this reference to this bar manager (self is nil)
-- @param prefix prefix to use
-- @param postfix postfix to use
-- @return text to be shown in gui
function DHUDUnitInfoManager:createTextGuild(this, prefix, postfix)
	prefix = prefix or "";
	postfix = postfix or "";
	local value = this.currentDataTracker.guild;
	if (value ~= "") then
		return prefix .. value .. postfix;
	end
	return value;
end

--- Create text that contains unit pvp status
-- @param this reference to this bar manager (self is nil)
-- @return text to be shown in gui
function DHUDUnitInfoManager:createTextPvP(this)
	local value = this.currentDataTracker.pvpState;
	if (value ~= DHUDUnitInfoTracker.UNIT_PVP_STATE_OFF) then
		return "PvP";
	end
	return "";
end

--- Create text that will colorize text after it in level color
-- @param this reference to this bar manager (self is nil)
-- @return text to be shown in gui
function DHUDUnitInfoManager:createTextColorLevel(this)
	local value = this.currentDataTracker.level;
	local colors = DHUDColorizeTools:colorizeByLevelDifficulty(value);
	return DHUDColorizeTools:colorToColorizeString(colors);
end

--- Create text that will colorize text after it in reaction color
-- @param this reference to this bar manager (self is nil)
-- @return text to be shown in gui
function DHUDUnitInfoManager:createTextColorReaction(this)
	local relation = this.currentDataTracker.relation;
	local canAttack = this.currentDataTracker.canAttack;
	local unitType = this.currentDataTracker.unitType;
	local reactionId = 0;
	if (unitType == DHUDUnitInfoTracker.UNIT_TYPE_PLAYER) then
		if (this.currentDataTracker.pvpState ~= DHUDUnitInfoTracker.UNIT_PVP_STATE_OFF) then
			if (canAttack) then
				reactionId = DHUDColorizeTools.REACTION_ID_HOSTILE;
			else
				reactionId = DHUDColorizeTools.REACTION_ID_FRIENDLY_PLAYER_PVP;
			end
		else
			if (canAttack or this.currentDataTracker.isDifferentPvPFaction) then
				reactionId = DHUDColorizeTools.REACTION_ID_NEUTRAL;
			else
				reactionId = DHUDColorizeTools.REACTION_ID_FRIENDLY_PLAYER;
			end
		end
	else
		if (not this.currentDataTracker.tagged) then
			reactionId = DHUDColorizeTools.REACTION_ID_HOSTILE_NOT_TAPPED;
		elseif (relation == DHUDUnitInfoTracker.UNIT_RELATION_HOSTILE) then
			reactionId = DHUDColorizeTools.REACTION_ID_HOSTILE;
		elseif (relation == DHUDUnitInfoTracker.UNIT_RELATION_FRIENDLY) then
			reactionId = DHUDColorizeTools.REACTION_ID_FRIENDLY;
		else
			reactionId = DHUDColorizeTools.REACTION_ID_NEUTRAL;
		end
	end
	local colors = DHUDColorizeTools:colorizeByReaction(reactionId);
	return DHUDColorizeTools:colorToColorizeString(colors);
end

--- Create text that will colorize text after it in class color
-- @param this reference to this bar manager (self is nil)
-- @return text to be shown in gui
function DHUDUnitInfoManager:createTextColorClass(this)
	local value = this.currentDataTracker.classEng;
	local colors = DHUDColorizeTools:colorizeByClass(value);
	return DHUDColorizeTools:colorToColorizeString(colors);
end

--- current data tracker data changed
function DHUDUnitInfoManager:onDataChange(e)
	self.textFrame.textField:DSetText(self.textFormatFunction());
end

--- new data tracker has been set for this slot, update if neccesary
function DHUDUnitInfoManager:onDataTrackerChange(e)
	if (self.currentDataTracker == DHUDDataTrackers.ALL.targetOfTargetInfo) then
		self:setTextFormatParams("unitTexts_targettarget_info", self.FUNCTIONS_MAP_INFO);
	else
		self:setTextFormatParams("unitTexts_target_info", self.FUNCTIONS_MAP_INFO);
	end
	-- update mouse eligability for frame
	local enableMouse = self:getTrackedUnitId() == "target";
	self.textFrame:SetMouseEnabledByData(enableMouse);
end

--- current data tracker existance changed, check currentDataTracker variable for existance
function DHUDUnitInfoManager:onExistanceChange()
	-- no data to visualize
	if (self.currentDataTracker == nil) then
		self.textFrame:DHide();
	else
		self.textFrame:DShow();
	end
end

--- Initialize unit info manager
-- @param textFrameName name of the text frame to use
-- @param settingName name of the setting that holds data trackers list
function DHUDUnitInfoManager:init(textFrameName, settingName)
	self.textFrame = DHUDGUI.frames[textFrameName];
	-- initialize setting name
	self:setDataTrackerListSetting(settingName);
end
