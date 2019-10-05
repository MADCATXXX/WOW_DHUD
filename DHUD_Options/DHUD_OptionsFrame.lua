--[[-----------------------------------------------------------------------------------
 Original Drathals HUD (c) 2006 by Markus Inger / Drathal / Silberklinge / Silbersegen
 DHUD for WotLK and later expansions (c) 2013 by MADCAT (EU-Гордунни, Мадкат)
 (http://eu.battle.net/wow/en/character/гордунни/Мадкат/advanced)
---------------------------------------------------------------------------------------
 This file contains frame onLoad functions
 @author: MADCAT
-----------------------------------------------------------------------------------]]--

--- table that will contain lua functions that are required to initialize frames
DHUD_OptionsFrame_LUA = {
	--- yes/no popup yes button handler
	popupYesHandler = nil,
	--- yes/no popup no button handler
	popupNoHandler = nil,
};

--- Options frame is loaded
function DHUD_OptionsFrame_LUA:processOptionsFrameOnLoad(frame)
	-- show gradients, they look weird in world of warcraft addon studio
	local frameName = frame:GetName();
	_G[frameName .. "_TopGradient"]:Show();
	_G[frameName .. "_BottomGradient"]:Show();
	-- register for drag
	frame:RegisterForDrag("LeftButton");
	-- set on click function
	frame:SetScript("OnMouseDown", function(frame, arg1)
		DHUD_OptionsTemplates_LUA:onOptionsMouseDown();
	end);
	-- set on drag functions
	frame:SetScript("OnDragStart", function(frame, arg1)
		frame:StartMoving();
	end);
	frame:SetScript("OnDragStop", function(frame, arg1)
		frame:StopMovingOrSizing();
	end);
	-- set on show handler
	frame:SetScript("OnShow", function(frame)
		DHUD_OptionsTemplates_LUA:setActiveTab("DHUD_OptionsFrame_GeneralTab");
	end);
	-- set reset button hadler
	local resetButton = _G[frameName .. "_ResetButton"];
	resetButton:SetScript("OnClick", function(frame)
		DHUD_OptionsFrame_LUA:showYesNoPopup(DHUDOptionsLocalization["POPUP_RESET"] or "POPUP_RESET", function()
			DHUDOptions:resetSettings();
			DHUD_OptionsTemplates_LUA:reloadSettingTab();
		end, nil);
	end);
	-- set profiles button hadler
	local profilesButton = _G[frameName .. "_ProfilesButton"];
	profilesButton:SetScript("OnClick", function(frame)
		DHUDOptions:openAceConfig();
	end);
	-- update version string
	_G["DHUD_OptionsFrame_VersionString"]:SetText(DHUDMain.version);
	-- invoke DHUD_Options main function
	DHUDOptions:main();
end

--- Process yes no popup is loaded
function DHUD_OptionsFrame_LUA:processYesNoPopupOnLoad(frame)
	local frameName = frame:GetName();
	-- update yes handler
	local yesButton = _G[frameName .. "_YesButton"];
	yesButton:SetScript("OnClick", function(frame, arg1)
		DHUD_YesNoPopup:Hide();
		if (DHUD_OptionsFrame_LUA.popupYesHandler ~= nil) then
			DHUD_OptionsFrame_LUA.popupYesHandler();
		end
	end);
	-- update no handler
	local noButton = _G[frameName .. "_NoButton"];
	noButton:SetScript("OnClick", function(frame, arg1)
		DHUD_YesNoPopup:Hide();
		if (DHUD_OptionsFrame_LUA.popupNoHandler ~= nil) then
			DHUD_OptionsFrame_LUA.popupNoHandler();
		end
	end);
end

--- Show yes no popup
-- @param text text to be shown in the popup
-- @param yesFunc handler of yes button, this function will be invoked without "self" arg!
-- @param noFunc handler of no button, this function will be invoked without "self" arg!
function DHUD_OptionsFrame_LUA:showYesNoPopup(text, yesFunc, noFunc)
	DHUD_YesNoPopup:Show();
	_G["DHUD_YesNoPopup_Text"]:SetText(text);
	self.popupYesHandler = yesFunc;
	self.popupNoHandler = noFunc;
end

--- Show help frame
-- @param text text to be shown in help frame
function DHUD_OptionsFrame_LUA:showHelp(text)
	DHUD_HelpFrame:Show();
	_G["DHUD_HelpFrame_Text"]:SetText(text);
end

--- Hide help frame
function DHUD_OptionsFrame_LUA:hideHelp()
	DHUD_HelpFrame:Hide();
end

