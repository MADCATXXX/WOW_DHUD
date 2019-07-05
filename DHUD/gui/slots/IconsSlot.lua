--[[-----------------------------------------------------------------------------------
 Original Drathals HUD (c) 2006 by Markus Inger / Drathal / Silberklinge / Silbersegen
 DHUD for WotLK and later expansions (c) 2013 by MADCAT (EU-Гордунни, Мадкат)
 (http://eu.battle.net/wow/en/character/гордунни/Мадкат/advanced)
---------------------------------------------------------------------------------------
 This file contains object that will show unit info data as icons
 @author: MADCAT
-----------------------------------------------------------------------------------]]--

-------------------
-- Icons Manager --
-------------------

--- Class to manage icons
DHUDIconsManager = MCCreateClass{
	-- position id of target icons
	positionTarget	= "",
	-- position id of self icons
	positionSelf	= "",
	-- position id of dragon icon
	positionDragon	= "",
	-- reference to self pvp frame
	selfPvPFrame	= nil,
	-- reference to self state frame
	selfStateFrame	= nil,
	-- reference to target dragon frame
	targetDragonFrame = nil,
	-- reference to group with target state icons
	targetStateGroup = nil,
	-- reference to slef info tracker
	selfInfoTracker = nil,
	-- reference to target info tracker
	targetInfoTracker = nil,
	-- defines if resting icon should be visible
	STATIC_restingIcon = true,
	-- defines if combat icon should be visible
	STATIC_combatIcon = true,
	-- defines if player pvp icon should be visible
	STATIC_playerPvPIcon = true,
	-- defines if target pvp icon should be visible
	STATIC_targetPvPIcon = true,
	-- defines if target elite icon should be visible
	icons_targetEliteIcon = true,
	-- defines if target raid icon should be visible
	icons_targetRaidIcon = true,
	-- defines if target spec role icon should be visible
	icons_targetSpecRoleIcon = true,
	-- defines if target spec icon should be visible
	icons_targetSpecIcon = true,
}

--- Process icon setting
-- @param settingName name of the setting
-- @param varName name of the variable to fill
function DHUDIconsManager:STATIC_processIconSetting(settingName, varName)
	local process = function(self, e)
		self[varName] = DHUDSettings:getValue(settingName);
	end
	DHUDSettings:addEventListener(DHUDSettingsEvent.EVENT_SPECIFIC_SETTING_CHANGED_PREFIX .. settingName, self, process);
	process(self, nil);
end

--- Initialize DHUDIconsManager class
function DHUDIconsManager:STATIC_init()
	self:STATIC_processIconSetting("icons_restingIcon", "STATIC_restingIcon");
	self:STATIC_processIconSetting("icons_combatIcon", "STATIC_combatIcon");
	self:STATIC_processIconSetting("icons_playerPvPIcon", "STATIC_playerPvPIcon");
	self:STATIC_processIconSetting("icons_targetPvPIcon", "STATIC_targetPvPIcon");
	self:STATIC_processIconSetting("icons_targetEliteIcon", "STATIC_targetEliteIcon");
	self:STATIC_processIconSetting("icons_targetRaidIcon", "STATIC_targetRaidIcon");
	self:STATIC_processIconSetting("icons_targetSpecRoleIcon", "STATIC_targetSpecRoleIcon");
	self:STATIC_processIconSetting("icons_targetSpecIcon", "STATIC_targetSpecIcon");
end

--- Create new icons manager
function DHUDIconsManager:new()
	local o = self:defconstructor();
	o:constructor();
	return o;
end

--- construct icons manager
function DHUDIconsManager:constructor()

end

--- self data changed, update icons
function DHUDIconsManager:onSelfDataChanged(e)
	-- update state icon
	local textureName = "";
	if (self.selfInfoTracker.isInCombat and self.STATIC_combatIcon) then
		textureName = "BlizzardPlayerInCombat";
	elseif (self.selfInfoTracker.isResting and self.STATIC_restingIcon) then
		textureName = "BlizzardPlayerResting";
	end
	-- update texture
	if (textureName ~= "") then
		self.selfStateFrame:DShow();
		local path, x0, x1, y0, y1 = unpack(DHUDGUI.textures[textureName]);
		local texture = self.selfStateFrame.texture;
		texture:SetTexture(path);
		texture:SetTexCoord(x0, x1, y0, y1);
	else
		self.selfStateFrame:DHide();
	end
	-- update pvp
	textureName = "";
	local pvp = self.selfInfoTracker.pvpState;
	if (pvp ~= DHUDUnitInfoTracker.UNIT_PVP_STATE_OFF and self.STATIC_playerPvPIcon) then
		if (pvp == DHUDUnitInfoTracker.UNIT_PVP_STATE_FFA) then
			textureName = "BlizzardPvPArena";
		else
			local pvpFaction = self.selfInfoTracker.pvpFaction
			if (pvpFaction == DHUDUnitInfoTracker.UNIT_PVP_FACTION_ALLIANCE) then
				textureName = "BlizzardPvPAlliance";
			elseif (pvpFaction == DHUDUnitInfoTracker.UNIT_PVP_FACTION_HORDE) then
				textureName = "BlizzardPvPHorde";
			else
				textureName = "BlizzardPvPArena";
			end
		end
	end
	-- update texture
	if (textureName ~= "") then
		self.selfPvPFrame:DShow();
		local path, x0, x1, y0, y1 = unpack(DHUDGUI.textures[textureName]);
		local texture = self.selfPvPFrame.texture;
		texture:SetTexture(path);
		texture:SetTexCoord(x0, x1, y0, y1);
	else
		self.selfPvPFrame:DHide();
	end
end

--- target data changed, update icons
function DHUDIconsManager:onTargetDataChanged(e)
	-- check elite
	local textureName = "";
	local elite = self.targetInfoTracker.eliteType;
	if (self.STATIC_targetEliteIcon) then
		if (elite == DHUDUnitInfoTracker.UNIT_ELITE_TYPE_BOSS or elite == DHUDUnitInfoTracker.UNIT_ELITE_TYPE_ELITE) then
			textureName = "TargetEliteDragon";
		elseif (elite == DHUDUnitInfoTracker.UNIT_ELITE_TYPE_RAREELITE or elite == DHUDUnitInfoTracker.UNIT_ELITE_TYPE_RARE) then
			textureName = "TargetRareDragon";
		end
	end
	-- update dragon texture
	if (textureName ~= "") then
		self.targetDragonFrame:DShow();
		local texturePath = DHUDGUI.textures[textureName][1];
		self.targetDragonFrame.texture:SetTexture(texturePath);
	else
		self.targetDragonFrame:DHide();
	end
	-- update target icons
	local numIcons = 0;
	local pvp = self.targetInfoTracker.pvpState;
	if (pvp ~= DHUDUnitInfoTracker.UNIT_PVP_STATE_OFF and self.STATIC_targetPvPIcon) then
		numIcons = numIcons + 1;
		if (pvp == DHUDUnitInfoTracker.UNIT_PVP_STATE_FFA) then
			textureName = "BlizzardPvPArena";
		else
			local pvpFaction = self.targetInfoTracker.pvpFaction
			if (pvpFaction == DHUDUnitInfoTracker.UNIT_PVP_FACTION_ALLIANCE) then
				textureName = "BlizzardPvPAlliance";
			elseif (pvpFaction == DHUDUnitInfoTracker.UNIT_PVP_FACTION_HORDE) then
				textureName = "BlizzardPvPHorde";
			else
				textureName = "BlizzardPvPArena";
			end
		end
		local path, x0, x1, y0, y1 = unpack(DHUDGUI.textures[textureName]);
		local texture = self.targetStateGroup[numIcons].texture;
		-- set texture and coordinates
		texture:SetTexture(path);
		texture:SetTexCoord(x0, x1, y0, y1);
	end
	local raidIcon = self.targetInfoTracker.raidIcon;
	if (raidIcon ~= 0 and self.STATIC_targetRaidIcon) then
		numIcons = numIcons + 1;
		textureName = "BlizzardRaidIcon" .. raidIcon;
		local path, x0, x1, y0, y1 = unpack(DHUDGUI.textures[textureName]);
		local texture = self.targetStateGroup[numIcons].texture;
		-- set texture and coordinates
		texture:SetTexture(path);
		texture:SetTexCoord(x0, x1, y0, y1);
	end
	-- show and reposition icons
	self.targetStateGroup:setFramesShown(numIcons);
	self.targetStateGroup.reposition(DHUDGUI);
end

--- target data no longer exists or started to exists
function DHUDIconsManager:onTargetDataExistanceChanged(e)
	local exists = self.targetInfoTracker.isExists;
	-- hide frames if no data is available
	if (not exists) then
		self.targetDragonFrame:DHide();
		self.targetStateGroup:setFramesShown(0);
	end
end

--- icon settings has changed, update
function DHUDIconsManager:onIconsSettingChange(e)
	self:onSelfDataChanged(nil);
	if (self.targetInfoTracker.isExists) then
		self:onTargetDataChanged(nil);
	end
end

--- Initialize side info manager
-- @param spellRectanglesGroupName name of the group with spell circles to use
-- @param settingName name of the setting that holds data trackers list
function DHUDIconsManager:init(selfPvPFrameName, selfStateFrameName, targetDragonFrameName, targetStateGroupName)
	self.selfPvPFrame = DHUDGUI.frames[selfPvPFrameName];
	self.selfStateFrame = DHUDGUI.frames[selfStateFrameName];
	self.targetDragonFrame = DHUDGUI.frames[targetDragonFrameName];
	self.targetStateGroup = DHUDGUI.frameGroups[targetStateGroupName];
	-- track icons data
	self.selfInfoTracker = DHUDDataTrackers.ALL.selfInfo;
	self.selfInfoTracker:addEventListener(DHUDDataTrackerEvent.EVENT_DATA_CHANGED, self, self.onSelfDataChanged);
	self.targetInfoTracker = DHUDDataTrackers.ALL.targetInfo;
	self.targetInfoTracker:addEventListener(DHUDDataTrackerEvent.EVENT_DATA_CHANGED, self, self.onTargetDataChanged);
	self.targetInfoTracker:addEventListener(DHUDDataTrackerEvent.EVENT_EXISTANCE_CHANGED, self, self.onTargetDataExistanceChanged);
	self:onSelfDataChanged(nil);
	self:onTargetDataChanged(nil);
	-- track settings change
	DHUDSettings:addEventListener(DHUDSettingsEvent.EVENT_SPECIFIC_GROUP_SETTING_CHANGED_PREFIX .. "icons", self, self.onIconsSettingChange);
end
