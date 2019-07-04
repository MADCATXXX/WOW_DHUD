--[[-----------------------------------------------------------------------------------
 Original Drathals HUD (c) 2006 by Markus Inger / Drathal / Silberklinge / Silbersegen
 DHUD for WotLK and later expansions (c) 2013 by MADCAT (EU-Гордунни, Мадкат)
 (http://eu.battle.net/wow/en/character/гордунни/Мадкат/advanced)
---------------------------------------------------------------------------------------
 This file contains initialization of subsystems and connects subsystems together
 @author: MADCAT
-----------------------------------------------------------------------------------]]--

-------------------
-- Usefull links --
-------------------
-- http://wowprogramming.com/docs/api_types
-- http://wowprogramming.com/docs/api
-- http://wowprogramming.com/docs/events
-- http://wowprogramming.com/utils/artbrowser/Interface
-- http://wow.go-hero.net/framexml/16650/UnitFrame.lua/diff
-- http://wow.go-hero.net/framexml/16650/UnitPopup.lua
-- http://wow.go-hero.net/framexml/16650
-- http://www.wowwiki.com/Events_A-Z_(full_list)
-- http://www.wowwiki.com/Lua_functions
-- http://www.wowwiki.com/Pattern_matching
-- http://www.wowwiki.com/Widget_API
-- http://www.mmo-champion.com/threads/1304330-RPPM-reset-time
-- TODO:
-- Trinket ICDS, RPPM, check: http://www.curse.com/addons/wow/extracd
-- Shadow/Glow Special Effect: http://www.wowinterface.com/downloads/info18479-rSetBackdrop.html#info
-- Range and direction: http://www.curse.com/addons/wow/direction-arrow , http://www.curse.com/addons/wow/range-display , GetMapInfo(), GetPlayerMapPosition(unitId)
-- arrow graphics http://www.wowinterface.com/downloads/info7032-TomTom.html
-- specializations GetArenaOpponentSpec ("ARENA_OPPONENT_UPDATE"), GetInspectSpecialization ("INSPECT_READY" ?), GetBattlefieldScore ("UPDATE_BATTLEFIELD_SCORE")

----------
-- Code --
----------

--- Class to connect subsystems together
DHUDMain = {
	-- version of the addon, will be read from toc file
	version					= "",
	-- numeric version of the addon (last number in version string)
	versionInt				= 0,
	-- list of subsystems for slash commands handling
	slashCommandSubsystems	= {},
}

--- Prints message to player chat frame
-- @param msg message to print
function DHUDMain:print(msg)
	if DEFAULT_CHAT_FRAME then
		DEFAULT_CHAT_FRAME:AddMessage("|cff88ff88DHUD:|r " .. (msg or "null"), 1, 1, 1);
	end
end

--- Open settings panel, loading addon in the process if required
function DHUDMain:openSettings()
	-- check if addon is loaded
	if (not DHUD_OptionsFrame) then
		local res = LoadAddOn("DHUD_Options");
		if (res == nil) then
			self:print("DHUD Options addon is disabled, please enable it first");
			return;
		end
		return;
	end
    -- toggle visibility
	if (DHUD_OptionsFrame:IsVisible()) then
		DHUD_OptionsFrame:Hide();
	else
		DHUD_OptionsFrame:Show();
	end
end

----------------------------
-- Slash command handlers --
-- @endregion
----------------------------

--- Initialize slash commands handling
function DHUDMain:SlashCommandHandlerInit()
	-- set slash command handler
	SLASH_DHUD1 = "/dhud";
	SlashCmdList["DHUD"] = function(msg)
		DHUDMain:SlashCommandHandler(msg);
	end
	-- set subsystems
	DHUDDebug:SlashCommandHandlerInit();
	DHUDSettings:SlashCommandHandlerInit();
	self.slashCommandSubsystems["debug"] = function (args) DHUDDebug:SlashCommandHandler(args[1]); end;
	self.slashCommandSubsystems["settings"] = function (args) DHUDSettings:SlashCommandHandler(table.concat(args, " ")); end;
end

--- Handler for commands passed from chat using "/dhud", usage "/dhud subsystem params"
-- @param msg command arguments
function DHUDMain:SlashCommandHandler(msg)
	local args = { strsplit(" ", msg) };
	local subsystem = table.remove(args, 1);
	if (subsystem == nil) then
		subsystem = "";
	end
	local subsystemHandler = self.slashCommandSubsystems[subsystem];
	if (subsystemHandler ~= nil) then
		subsystemHandler(args);
	else
		self:print("Handler for requested subsystem not found. Opening settings...");
		self:openSettings();
	end
end

------------------
-- Minimap Icon --
------------------

--- Show Minimap Icon setting has changed, process
function DHUDMain:onMinimapSettingChanged(e)
	local show = DHUDSettings:getValue("misc_minimapIcon");
	MyMinimapButton:SetEnable("DHUD", show);
end

--- Create minimap button for addon
function DHUDMain:createMinimapButton()
	-- create minimap icon
	local mmbVars = DHUDSettings:getAdditionalSavedVars("mmb");
	local info = {
		icon = "Interface\\Icons\\Ability_Druid_TravelForm",
		position = 190, -- default position. savedVariables will be used after first use
		drag = "CIRCLE", -- drag method
		left = function() -- left click
			DHUDMain:openSettings();
		end,
		right = function() -- right click
			-- level - Nesting level of this dropdown. value - Value of the dropdown item (if level > 1). dropDownFrame - The frame to toggle (not its name!). This object should be derived from UIDropDownMenuTemplate. anchorName - Sets the relativeTo member of this frame. xOffset - Sets the x offset. yOffset - Sets the y offset.
			DHUDGUI.ToggleDropDownMenu(1, nil, DHUD_DropDown_PlayerMenu, "DHUDMinimapButton", 25, 10); 
		end,
		tooltip = "Left click: DHUD Options\nRight click: Player Menu",
		enabled = true, -- minimap button is enabled by default, saved vars will be used later
	}
	MyMinimapButton:Create("DHUD", mmbVars, info);
	-- check setting
	DHUDSettings:addEventListener(DHUDSettingsEvent.EVENT_SPECIFIC_SETTING_CHANGED_PREFIX .. "misc_minimapIcon", self, self.onMinimapSettingChanged);
	self:onMinimapSettingChanged(nil);
end

-------------------
-- Main function --
-------------------

--- Main function of the addon, invoked once to initialize subsystems
function DHUDMain:main()
	-- read addon version from toc file
	self.version = GetAddOnMetadata("DHUD", "Version");
	self.versionInt = tonumber(strsub(self.version, strfind(self.version, "%.[^%.]*$") + 1)); -- search for last dot and substring int version
	-- slash commands
	self:SlashCommandHandlerInit();
	-- create data trackers
	DHUDDataTrackers:createTrackers();
	-- init settings
	DHUDSettings:init();
	-- init data trackers
	DHUDDataTrackers:init();
	-- init gui
	DHUDGUI:init();
	-- create minimap icon
	self:createMinimapButton();
	-- add options to blizzard interface tab
	DHUDSettings:createBlizzardInterfaceOptions();
	-- print information on addon load
	self:print("Version " .. self.version .. " loaded");
end
--- wait for game onload event
local onLoadEventFrame = MCCreateBlizzEventFrame();
-- invoked when player enters world once, ADDON_LOADED and VARIABLES_LOADED should already be fired
function onLoadEventFrame:PLAYER_ENTERING_WORLD()
	DHUDMain:main();
	self:UnregisterEvent("PLAYER_ENTERING_WORLD");
end
onLoadEventFrame:RegisterEvent("PLAYER_ENTERING_WORLD");
