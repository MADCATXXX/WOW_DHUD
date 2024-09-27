--[[-----------------------------------------------------------------------------------
 Original Drathals HUD (c) 2006 by Markus Inger / Drathal / Silberklinge / Silbersegen
 DHUD for WotLK and later expansions (c) 2013 by MADCAT (EU-Гордунни, Мадкат)
 (http://eu.battle.net/wow/en/character/гордунни/Мадкат/advanced)
---------------------------------------------------------------------------------------
 This file contains settings handlers for settings that are not tied to DHUD addon
 @author: MADCAT
-----------------------------------------------------------------------------------]]--

-- antitaint local "_" var
local _;
-- tracker helper
local trackingHelper = DHUDDataTrackingHelper;

-----------------------------------------
-- Non Addon Specific Settings Handler --
-----------------------------------------

--- Class to handle settings that are not addon specific, e.g. showing/hiding blizzard frames
DHUDNonAddonSettingsHandler = {
	-- events frame to listen to game events
	eventsFrame = nil,
	-- required alpha for blizzard power auras, this value will be set to frame when required
	blizzardPowerAurasAlpha = 1,
	-- required scale for blizzard power auras, this value will be set to frame when required
	blizzardPowerAurasScale = 1,
	-- name of the setting that changes visibility of the player frame
	SETTING_NAME_BLIZZARD_PLAYER = "blizzardFrames_playerFrame",
	-- name of the setting that changes visibility of the target frame
	SETTING_NAME_BLIZZARD_TARGET = "blizzardFrames_targetFrame",
	-- name of the setting that changes visibility of the castbar frame
	SETTING_NAME_BLIZZARD_CASTBAR = "blizzardFrames_castingFrame",
	-- name of the setting that changes visibility of the self nameplate frame
	SETTING_NAME_BLIZZARD_SELFNAMEPLATE = "blizzardFrames_selfNameplateFrame",
	-- name of the setting that changes alpha of SpellActivationOverlayFrame
	SETTING_NAME_BLIZZARD_SPELL_ACTIVATION_ALPHA = "blizzardFrames_spellActivationFrameAlpha",
	-- name of the setting that changes scale of SpellActivationOverlayFrame
	SETTING_NAME_BLIZZARD_SPELL_ACTIVATION_SCALE = "blizzardFrames_spellActivationFrameScale",
	-- name of the setting that changes level of ui errors filtering
	SETTING_NAME_SERVICE_UI_ERROR_FILTER = "service_uiErrorFilter",
	-- name of the setting that contains code to be executed on start up
	SETTING_NAME_SERVICE_LUA_START_UP = "service_luaStartUp",
	-- name of the setting that contains result of the last start up code
	SETTING_NAME_SERVICE_LUA_START_UP_ERROR = "service_luaStartUpError",
	-- name of the setting that contains soft targeting mode (e.g. use "softenemy" instead of "target")
	SETTING_NAME_SERVICE_SOFT_TARGET_TRACKING = "service_softTargetingMode",
	-- name of the setting that contains if stealth break events should be printed to chat
	SETTING_NAME_SERVICE_DESTEALTH_TRACKING = "service_destealthTracker",
}

-- value of the setting has changed
function DHUDNonAddonSettingsHandler:onBlizzardPlayerFrameChange(e)
	trackingHelper:removeEventListener(DHUDDataTrackerHelperEvent.EVENT_COMBAT_STATE_CHANGED, self, self.onBlizzardPlayerFrameChange);
	if (trackingHelper.isInCombat) then
		trackingHelper:addEventListener(DHUDDataTrackerHelperEvent.EVENT_COMBAT_STATE_CHANGED, self, self.onBlizzardPlayerFrameChange);
		DHUDMain:print("Can't change player frame visibility in combat, setting will be updated after combat ends, or use /reload to apply now");
		return;
	end
	local val = DHUDSettings:getValue(self.SETTING_NAME_BLIZZARD_PLAYER);
	if (val) then
		self:showBlizzardPlayerFrame();
	else
		self:hideBlizzardPlayerFrame();
	end
end

-- value of the setting has changed
function DHUDNonAddonSettingsHandler:onBlizzardTargetFrameChange(e)
	trackingHelper:removeEventListener(DHUDDataTrackerHelperEvent.EVENT_COMBAT_STATE_CHANGED, self, self.onBlizzardTargetFrameChange);
	if (trackingHelper.isInCombat) then
		trackingHelper:addEventListener(DHUDDataTrackerHelperEvent.EVENT_COMBAT_STATE_CHANGED, self, self.onBlizzardTargetFrameChange);
		DHUDMain:print("Can't change target frame visibility in combat, setting will be updated after combat ends, or use /reload to apply now");
		return;
	end
	local val = DHUDSettings:getValue(self.SETTING_NAME_BLIZZARD_TARGET);
	if (val) then
		self:showBlizzardTargetFrame();
	else
		self:hideBlizzardTargetFrame();
	end
end

-- value of the setting has changed
function DHUDNonAddonSettingsHandler:onBlizzardCastbarFrameChange(e)
	trackingHelper:removeEventListener(DHUDDataTrackerHelperEvent.EVENT_COMBAT_STATE_CHANGED, self, self.onBlizzardCastbarFrameChange);
	if (trackingHelper.isInCombat) then
		trackingHelper:addEventListener(DHUDDataTrackerHelperEvent.EVENT_COMBAT_STATE_CHANGED, self, self.onBlizzardCastbarFrameChange);
		DHUDMain:print("Can't change castbar frame visibility in combat, setting will be updated after combat ends, or use /reload to apply now");
		return;
	end
	local val = DHUDSettings:getValue(self.SETTING_NAME_BLIZZARD_CASTBAR);
	if (val) then
		self:showBlizzardCastingFrame();
	else
		self:hideBlizzardCastingFrame();
	end
end

-- value of the setting has changed
function DHUDNonAddonSettingsHandler:onBlizzardSelfNameplateFrameChange(e)
	self:updateBlizzardSelfNameplateFrameVisibility();
end

-- value of the setting has changed
function DHUDNonAddonSettingsHandler:onBlizzardSpellActivationFrameAlphaChange(e)
	self.blizzardPowerAurasAlpha = DHUDSettings:getValue(self.SETTING_NAME_BLIZZARD_SPELL_ACTIVATION_ALPHA);
	-- update frame
	self:updateBlizzardPowerAurasFrame();
end

-- value of the setting has changed
function DHUDNonAddonSettingsHandler:onBlizzardSpellActivationFrameScaleChange(e)
	self.blizzardPowerAurasScale = DHUDSettings:getValue(self.SETTING_NAME_BLIZZARD_SPELL_ACTIVATION_SCALE);
	-- update frame
	self:updateBlizzardPowerAurasFrame();
end

-- value of the setting has changed
function DHUDNonAddonSettingsHandler:onServiceUIErrorLevelChange(e)
	local val = DHUDSettings:getValue(self.SETTING_NAME_SERVICE_UI_ERROR_FILTER);
	self:changeServiceUIErrorFiltering(val);
end

-- value of the setting has changed
function DHUDNonAddonSettingsHandler:onLuaStartUpChange(e)
	DHUDSettings:setValue(self.SETTING_NAME_SERVICE_LUA_START_UP_ERROR, false);
end

-- value of the soft targeting has changed
function DHUDNonAddonSettingsHandler:onSoftTargetingChange(e)
	local val = DHUDSettings:getValue(self.SETTING_NAME_SERVICE_SOFT_TARGET_TRACKING);
	trackingHelper.PRIORITIZE_SOFT_TARGETS = val;
end

-- value of the setting has changed
function DHUDNonAddonSettingsHandler:onDestealthTrackingChange(e)
	local val = DHUDSettings:getValue(self.SETTING_NAME_SERVICE_DESTEALTH_TRACKING);
	self:processDestealthTracking(val);
end

--- initialize non addon specific settings handler
function DHUDNonAddonSettingsHandler:init()
	-- events frame
	self.eventsFrame = MCCreateBlizzEventFrame();
	-- read settings
	local playerFrameVisible = DHUDSettings:getValue(self.SETTING_NAME_BLIZZARD_PLAYER);
	local targetFrameVisible = DHUDSettings:getValue(self.SETTING_NAME_BLIZZARD_TARGET);
	local castbarFrameVisible = DHUDSettings:getValue(self.SETTING_NAME_BLIZZARD_CASTBAR);
	local uiErrorsLevel = DHUDSettings:getValue(self.SETTING_NAME_SERVICE_UI_ERROR_FILTER);
	local luaStartUp = DHUDSettings:getValue(self.SETTING_NAME_SERVICE_LUA_START_UP);
	local luaStartUpError = DHUDSettings:getValue(self.SETTING_NAME_SERVICE_LUA_START_UP_ERROR);
	local softTargetingMode = DHUDSettings:getValue(self.SETTING_NAME_SERVICE_SOFT_TARGET_TRACKING);
	local destealthTracking = DHUDSettings:getValue(self.SETTING_NAME_SERVICE_DESTEALTH_TRACKING);
	self.blizzardPowerAurasAlpha = DHUDSettings:getValue(self.SETTING_NAME_BLIZZARD_SPELL_ACTIVATION_ALPHA);
	self.blizzardPowerAurasScale = DHUDSettings:getValue(self.SETTING_NAME_BLIZZARD_SPELL_ACTIVATION_SCALE);
	-- listen to events
	DHUDSettings:addEventListener(DHUDSettingsEvent.EVENT_SPECIFIC_SETTING_CHANGED_PREFIX .. self.SETTING_NAME_BLIZZARD_PLAYER, self, self.onBlizzardPlayerFrameChange);
	DHUDSettings:addEventListener(DHUDSettingsEvent.EVENT_SPECIFIC_SETTING_CHANGED_PREFIX .. self.SETTING_NAME_BLIZZARD_TARGET, self, self.onBlizzardTargetFrameChange);
	DHUDSettings:addEventListener(DHUDSettingsEvent.EVENT_SPECIFIC_SETTING_CHANGED_PREFIX .. self.SETTING_NAME_BLIZZARD_CASTBAR, self, self.onBlizzardCastbarFrameChange);
	DHUDSettings:addEventListener(DHUDSettingsEvent.EVENT_SPECIFIC_SETTING_CHANGED_PREFIX .. self.SETTING_NAME_BLIZZARD_SELFNAMEPLATE, self, self.onBlizzardSelfNameplateFrameChange);
	DHUDSettings:addEventListener(DHUDSettingsEvent.EVENT_SPECIFIC_SETTING_CHANGED_PREFIX .. self.SETTING_NAME_BLIZZARD_SPELL_ACTIVATION_ALPHA, self, self.onBlizzardSpellActivationFrameAlphaChange);
	DHUDSettings:addEventListener(DHUDSettingsEvent.EVENT_SPECIFIC_SETTING_CHANGED_PREFIX .. self.SETTING_NAME_BLIZZARD_SPELL_ACTIVATION_SCALE, self, self.onBlizzardSpellActivationFrameScaleChange);
	DHUDSettings:addEventListener(DHUDSettingsEvent.EVENT_SPECIFIC_SETTING_CHANGED_PREFIX .. self.SETTING_NAME_SERVICE_UI_ERROR_FILTER, self, self.onServiceUIErrorLevelChange);
	DHUDSettings:addEventListener(DHUDSettingsEvent.EVENT_SPECIFIC_SETTING_CHANGED_PREFIX .. self.SETTING_NAME_SERVICE_LUA_START_UP, self, self.onLuaStartUpChange);
	DHUDSettings:addEventListener(DHUDSettingsEvent.EVENT_SPECIFIC_SETTING_CHANGED_PREFIX .. self.SETTING_NAME_SERVICE_SOFT_TARGET_TRACKING, self, self.onSoftTargetingChange);
	DHUDSettings:addEventListener(DHUDSettingsEvent.EVENT_SPECIFIC_SETTING_CHANGED_PREFIX .. self.SETTING_NAME_SERVICE_DESTEALTH_TRACKING, self, self.onDestealthTrackingChange);
	-- register to power auras event
	self.eventsFrame:RegisterEvent("SPELL_ACTIVATION_OVERLAY_SHOW");
	-- process power auras event
	function self.eventsFrame:SPELL_ACTIVATION_OVERLAY_SHOW()
		DHUDNonAddonSettingsHandler:updateBlizzardPowerAurasFrame();
	end
	self:updateBlizzardPowerAurasFrame();
	-- hide frames if required
	if (not playerFrameVisible) then
		self:hideBlizzardPlayerFrame();
	end
	if (not targetFrameVisible) then
		self:hideBlizzardTargetFrame();
	end
	if (not castbarFrameVisible) then
		self:hideBlizzardCastingFrame();
	end
	self:updateBlizzardSelfNameplateFrameVisibility();
	-- process service settings if required
	if (uiErrorsLevel ~= 0) then
		self:changeServiceUIErrorFiltering(uiErrorsLevel);
	end
	if (luaStartUp ~= "" and luaStartUpError ~= true) then
		self:processLuaStartUpCode(luaStartUp);
	end
	if (softTargetingMode == true) then
		self:onSoftTargetingChange(nil);
	end
	if (destealthTracking == true) then
		self:processDestealthTracking(true);
	end
end

--- Function to show blizzard player frame
function DHUDNonAddonSettingsHandler:showBlizzardPlayerFrame()
	PlayerFrame:RegisterEvent("UNIT_LEVEL");
	PlayerFrame:RegisterEvent("UNIT_FACTION");
	PlayerFrame:RegisterEvent("PLAYER_ENTERING_WORLD");
	PlayerFrame:RegisterEvent("PLAYER_ENTER_COMBAT");
	PlayerFrame:RegisterEvent("PLAYER_LEAVE_COMBAT");
	PlayerFrame:RegisterEvent("PLAYER_REGEN_DISABLED");
	PlayerFrame:RegisterEvent("PLAYER_REGEN_ENABLED");
	PlayerFrame:RegisterEvent("PLAYER_UPDATE_RESTING");
	PlayerFrame:RegisterEvent("PARTY_LEADER_CHANGED");
	PlayerFrame:RegisterEvent("GROUP_ROSTER_UPDATE");
	PlayerFrame:RegisterEvent("READY_CHECK");
	PlayerFrame:RegisterEvent("READY_CHECK_CONFIRM");
	PlayerFrame:RegisterEvent("READY_CHECK_FINISHED");
	if (not MCVanilla) then
		PlayerFrame:RegisterEvent("UNIT_ENTERED_VEHICLE");
		PlayerFrame:RegisterEvent("UNIT_ENTERING_VEHICLE");
		PlayerFrame:RegisterEvent("UNIT_EXITING_VEHICLE");
		PlayerFrame:RegisterEvent("UNIT_EXITED_VEHICLE");
	end
	PlayerFrame:RegisterEvent("PVP_TIMER_UPDATE");
	PlayerFrame:RegisterEvent("PLAYER_ROLES_ASSIGNED");
	PlayerFrame:RegisterEvent("VARIABLES_LOADED");
	PlayerFrame:RegisterUnitEvent("UNIT_COMBAT", "player", "vehicle");
	PlayerFrame:RegisterUnitEvent("UNIT_MAXPOWER", "player", "vehicle");
    PlayerFrame:Show();
	if (DHUDDataTrackers.helper.playerClass == "DEATHKNIGHT") then
		RuneFrame:Show();
	end
end

--- Function to hide blizzard player frame
function DHUDNonAddonSettingsHandler:hideBlizzardPlayerFrame()
	PlayerFrame:UnregisterEvent("UNIT_LEVEL");
	PlayerFrame:UnregisterEvent("UNIT_FACTION");
	PlayerFrame:UnregisterEvent("PLAYER_ENTERING_WORLD");
	PlayerFrame:UnregisterEvent("PLAYER_ENTER_COMBAT");
	PlayerFrame:UnregisterEvent("PLAYER_LEAVE_COMBAT");
	PlayerFrame:UnregisterEvent("PLAYER_REGEN_DISABLED");
	PlayerFrame:UnregisterEvent("PLAYER_REGEN_ENABLED");
	PlayerFrame:UnregisterEvent("PLAYER_UPDATE_RESTING");
	PlayerFrame:UnregisterEvent("PARTY_LEADER_CHANGED");
	PlayerFrame:UnregisterEvent("GROUP_ROSTER_UPDATE");
	PlayerFrame:UnregisterEvent("READY_CHECK");
	PlayerFrame:UnregisterEvent("READY_CHECK_CONFIRM");
	PlayerFrame:UnregisterEvent("READY_CHECK_FINISHED");
	if (not MCVanilla) then
		PlayerFrame:UnregisterEvent("UNIT_ENTERED_VEHICLE");
		PlayerFrame:UnregisterEvent("UNIT_ENTERING_VEHICLE");
		PlayerFrame:UnregisterEvent("UNIT_EXITING_VEHICLE");
		PlayerFrame:UnregisterEvent("UNIT_EXITED_VEHICLE");
	end
	PlayerFrame:UnregisterEvent("PVP_TIMER_UPDATE");
	PlayerFrame:UnregisterEvent("PLAYER_ROLES_ASSIGNED");
	PlayerFrame:UnregisterEvent("VARIABLES_LOADED");
	PlayerFrame:UnregisterEvent("UNIT_COMBAT");
	PlayerFrame:UnregisterEvent("UNIT_MAXPOWER");
	PlayerFrame:Hide();
	if (DHUDDataTrackers.helper.playerClass == "DEATHKNIGHT") then
		RuneFrame:Hide();
	end
end

--- Function to show blizzard casting frame
function DHUDNonAddonSettingsHandler:showBlizzardCastingFrame()
	local frame = CastingBarFrame; -- vanilla/tbc/wotlk
	if (frame == nil) then
		frame = PlayerCastingBarFrame; -- retail dragonflight
		frame:RegisterEvent("UNIT_SPELLCAST_EMPOWER_START");
		frame:RegisterEvent("UNIT_SPELLCAST_EMPOWER_UPDATE");
		frame:RegisterEvent("UNIT_SPELLCAST_EMPOWER_STOP");
	end
	frame:RegisterEvent("UNIT_SPELLCAST_START");
	frame:RegisterEvent("UNIT_SPELLCAST_STOP");
	frame:RegisterEvent("UNIT_SPELLCAST_FAILED");
	frame:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED");
	frame:RegisterEvent("UNIT_SPELLCAST_DELAYED");
	frame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START");
	frame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_UPDATE");
	frame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP");
end

--- Function to hide blizzard casting frame
function DHUDNonAddonSettingsHandler:hideBlizzardCastingFrame()
	local frame = CastingBarFrame;
	if (frame == nil) then
		frame = PlayerCastingBarFrame;
		frame:UnregisterEvent("UNIT_SPELLCAST_EMPOWER_START");
		frame:UnregisterEvent("UNIT_SPELLCAST_EMPOWER_UPDATE");
		frame:UnregisterEvent("UNIT_SPELLCAST_EMPOWER_STOP");
	end
	frame:UnregisterEvent("UNIT_SPELLCAST_START");
	frame:UnregisterEvent("UNIT_SPELLCAST_STOP");
	frame:UnregisterEvent("UNIT_SPELLCAST_FAILED");
	frame:UnregisterEvent("UNIT_SPELLCAST_INTERRUPTED");
	frame:UnregisterEvent("UNIT_SPELLCAST_DELAYED");
	frame:UnregisterEvent("UNIT_SPELLCAST_CHANNEL_START");
	frame:UnregisterEvent("UNIT_SPELLCAST_CHANNEL_UPDATE");
	frame:UnregisterEvent("UNIT_SPELLCAST_CHANNEL_STOP");
	frame:Hide();
end

--- Function to show blizzard target frame
function DHUDNonAddonSettingsHandler:showBlizzardTargetFrame()
	TargetFrame:RegisterEvent("PLAYER_TARGET_CHANGED");
	TargetFrame:RegisterEvent("PLAYER_ENTERING_WORLD");
	TargetFrame:RegisterEvent("UNIT_HEALTH");
	TargetFrame:RegisterEvent("UNIT_LEVEL");
	TargetFrame:RegisterEvent("UNIT_FACTION");
	TargetFrame:RegisterEvent("UNIT_CLASSIFICATION_CHANGED");
	TargetFrame:RegisterEvent("PLAYER_FLAGS_CHANGED");
	TargetFrame:RegisterEvent("GROUP_ROSTER_UPDATE");
	TargetFrame:RegisterEvent("RAID_TARGET_UPDATE");
	TargetFrame:RegisterUnitEvent("UNIT_AURA", "target");
	if (DHUDDataTrackers.helper.isTargetAvailable) then
		TargetFrame:Show();
	end
	ComboFrame:RegisterEvent("PLAYER_TARGET_CHANGED");
end

--- Function to show blizzard target frame
function DHUDNonAddonSettingsHandler:hideBlizzardTargetFrame()
	TargetFrame:UnregisterEvent("PLAYER_TARGET_CHANGED");
	TargetFrame:UnregisterEvent("PLAYER_ENTERING_WORLD");
	TargetFrame:UnregisterEvent("UNIT_HEALTH");
	TargetFrame:UnregisterEvent("UNIT_LEVEL");
	TargetFrame:UnregisterEvent("UNIT_FACTION");
	TargetFrame:UnregisterEvent("UNIT_CLASSIFICATION_CHANGED");
	TargetFrame:UnregisterEvent("PLAYER_FLAGS_CHANGED");
	TargetFrame:UnregisterEvent("GROUP_ROSTER_UPDATE");
	TargetFrame:UnregisterEvent("RAID_TARGET_UPDATE");
	TargetFrame:UnregisterEvent("UNIT_AURA");
	TargetFrame:Hide();
	ComboFrame:UnregisterEvent("PLAYER_TARGET_CHANGED");
	ComboFrame:Hide();
end

--- Function to update power auras frame alpha and scale
function DHUDNonAddonSettingsHandler:updateBlizzardSelfNameplateFrameVisibility()
	local val = DHUDSettings:getValue(self.SETTING_NAME_BLIZZARD_SELFNAMEPLATE);
	if (val == -1) then return; end
	local exValue = GetCVar("nameplateShowSelf");
	if (exValue == val) then return; end
	
	trackingHelper:removeEventListener(DHUDDataTrackerHelperEvent.EVENT_COMBAT_STATE_CHANGED, self, self.updateBlizzardSelfNameplateFrameVisibility);
	if (trackingHelper.isInCombat) then
		trackingHelper:addEventListener(DHUDDataTrackerHelperEvent.EVENT_COMBAT_STATE_CHANGED, self, self.updateBlizzardSelfNameplateFrameVisibility);
		DHUDMain:print("Can't change self nameplate frame visibility in combat, setting will be updated after combat ends, or use /reload to apply now");
		return;
	end
	SetCVar("nameplateShowSelf", val);
end

--- Function to update power auras frame alpha and scale
function DHUDNonAddonSettingsHandler:updateBlizzardPowerAurasFrame()
	-- change alpha and scale of blizzard power auras
	SpellActivationOverlayFrame:SetAlpha(self.blizzardPowerAurasAlpha);
	SpellActivationOverlayFrame:SetScale(self.blizzardPowerAurasScale);
end

--- Function to filter ui error messages of blizzard interface
-- @param level level of ui error filtering, 0 - all errors shown, 1 - ui errors hidden, 2 - ui error frame is hidden (including quest messages)
function DHUDNonAddonSettingsHandler:changeServiceUIErrorFiltering(level)
	if (level == 0) then
		UIErrorsFrame:RegisterEvent("UI_ERROR_MESSAGE");
		UIErrorsFrame:Show();
	elseif (level == 1) then
		UIErrorsFrame:UnregisterEvent("UI_ERROR_MESSAGE");
		UIErrorsFrame:Show();
	elseif (level == 2) then
		UIErrorsFrame:UnregisterEvent("UI_ERROR_MESSAGE");
		UIErrorsFrame:Hide();
	end
end

--- Function to process lua start up code
-- @param code code to be executed on startup
function DHUDNonAddonSettingsHandler:processLuaStartUpCode(code)
	self.onLuaError = function(msg)
		DHUDMain:print("Lua start up code contains errors, it will be disabled: " .. MCTableToString(msg));
		DHUDSettings:setValue(self.SETTING_NAME_SERVICE_LUA_START_UP_ERROR, true);
		seterrorhandler(self.origErrorHandler);
		self.origErrorHandler(msg);
	end
	self.onProcessLuaStartUpCode = function(self, e)
		DHUDDataTrackers.helper:removeEventListener(DHUDDataTrackerHelperEvent.EVENT_UPDATE_FREQUENT, self, self.onProcessLuaStartUpCode);
		self.origErrorHandler = geterrorhandler();
		seterrorhandler(self.onLuaError);
		--DHUDMain:print("Lua start up code: " .. code);
		local evalFunc, error = loadstring(code, "DHUD onLoad text input");
		if (evalFunc ~= nil) then
			evalFunc();
		else
			DHUDMain:print("Lua start up code contains syntax errors: " .. error);
		end
		seterrorhandler(self.origErrorHandler);
	end
	-- execute function on first timer tick to not break initialization if code contains errors
	DHUDDataTrackers.helper:addEventListener(DHUDDataTrackerHelperEvent.EVENT_UPDATE_FREQUENT, self, self.onProcessLuaStartUpCode);
end

--- Function to change tracking of destealth code
-- @param track defines if tracking should be enabled
function DHUDNonAddonSettingsHandler:processDestealthTracking(track)
	if (MCVanilla > 0) then
		return;
	end
	if (trackingHelper.playerClass == "ROGUE") then
		DHUDDataTrackers.ROGUE.selfDeStealthTracker:changeTrackingState(track);
	elseif (trackingHelper.playerClass == "DRUID") then
		DHUDDataTrackers.DRUID.selfDeStealthTracker:changeTrackingState(track);
	end
end
