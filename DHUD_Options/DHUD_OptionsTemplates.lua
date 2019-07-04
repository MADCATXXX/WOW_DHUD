--[[-----------------------------------------------------------------------------------
 Original Drathals HUD (c) 2006 by Markus Inger / Drathal / Silberklinge / Silbersegen
 DHUD for WotLK and later expansions (c) 2013 by MADCAT (EU-Гордунни, Мадкат)
 (http://eu.battle.net/wow/en/character/гордунни/Мадкат/advanced)
---------------------------------------------------------------------------------------
 This file contains frame onLoad functions
 @author: MADCAT
-----------------------------------------------------------------------------------]]--

--- table that will contain lua functions that are required to initialize frames
DHUD_OptionsTemplates_LUA = {
	-- map with buttons names to tab names
	buttonToTabName = { },
	-- list with tab buttons, tabname = button
	tabButtons	= { },
	-- list with available tabs, tabname = tab
	tabs = { },
	-- list with tab pages, tabname = pages list
	tabPages = { },
	-- map with radiogroups, radioGroup = radio buttons list
	radioGroups = { },
	-- name of the active tab
	activeTab = "",
	-- reference to active tab frame
	activeTabFrame = nil,
	-- number of the active tab page
	activeTabPage = 0,
	-- drop down frames for frame data
	frameDataDropDowns = { },
	-- drop down frames for radio buttons
	frameDataRadioButtons = { },
	-- focused text box
	focusedTextBox = nil,
};

--- Invoked by UI when mouse is pressed over free space
function DHUD_OptionsTemplates_LUA:onOptionsMouseDown()
	if (self.focusedTextBox == nil) then
		return;
	end
	self.focusedTextBox:ClearFocus();
end

--- Invoked by UI when settings has been changed
function DHUD_OptionsTemplates_LUA:reloadSettingTab()
	if (self.activeTabFrame == nil) then
		return;
	end
	-- trigger onShow events
	self.activeTabFrame:Hide();
	self.activeTabFrame:Show();
end

--- Changes active tab
-- @param name name of the tab to be set as active
function DHUD_OptionsTemplates_LUA:setActiveTab(name)
	--print("set active tab " .. name);
	-- save tab name
	self.activeTab = name;
	-- hide all tabs
	for k, v in pairs(self.tabs) do
		v:Hide();
	end
	-- deselect buttons
	for k, v in pairs(self.tabButtons) do
		v:changeActiveState(false);
	end
	-- show tab
	self.activeTabFrame = self.tabs[name];
	self.activeTabFrame:Show();
	-- select tab button
	self.tabButtons[name]:changeActiveState(true);
	-- change page to 1
	self:setActivePage(1);
end

--- Changes active tab page
-- @param index index of the page to show, or nil for current page index
-- @param offset offset for the index
function DHUD_OptionsTemplates_LUA:setActivePage(index, offset)
	index = index or self.activeTabPage;
	index = index + (offset or 0);
	-- get pages
	local pages = self.tabPages[self.activeTab];
	--print("pages " .. MCTableToString(pages));
	local numPages = (pages ~= nil) and #pages or 0;
	-- set index bound
	if (index < 1) then
		index = 1;
	elseif (index > numPages) then
		index = numPages;
	end
	-- save page index
	self.activeTabPage = index;
	-- process button left visibility
	if (index > 1) then
		_G[self.activeTab .. "_ScrollLeft"]:Show();
	else
		_G[self.activeTab .. "_ScrollLeft"]:Hide();
	end
	-- process button right visibility
	if (index < numPages) then
		_G[self.activeTab .. "_ScrollRight"]:Show();
	else
		_G[self.activeTab .. "_ScrollRight"]:Hide();
	end
	-- hide all pages
	if (pages == nil) then
		return;
	end
	for i, v in ipairs(pages) do
		v:Hide();
	end
	-- show page one
	pages[index]:Show();
end

--- Options tab button is loaded
function DHUD_OptionsTemplates_LUA:processTabButtonOnLoad(frame)
	local name = frame:GetName();
	local tabName = strsub(name, 1, -7);
	-- save references
	self.buttonToTabName[name] = tabName;
	self.tabButtons[tabName] = frame;
	-- update text on button
	local ltext = frame:GetAttribute("LTEXT") or "";
	frame:SetText(DHUDOptionsLocalization[ltext] or ("LTEXT: " .. ltext));
	-- update higlight width
	_G[name .. "_HighlightTexture"]:SetWidth(frame:GetTextWidth() + 31);
	-- set on click handler
	frame:SetScript("OnClick", function(frame, arg1)
		DHUD_OptionsTemplates_LUA:setActiveTab(DHUD_OptionsTemplates_LUA.buttonToTabName[frame:GetName()]);
	end);
	-- add function to change button active state
	function frame:changeActiveState(active)
		-- change button active state
		if (active) then
			self:Disable();
			_G[name .. "_Left"]:Hide();
			_G[name .. "_Middle"]:Hide();
			_G[name .. "_Right"]:Hide();
			_G[name .. "_LeftActive"]:Show();
			_G[name .. "_MiddleActive"]:Show();
			_G[name .. "_RightActive"]:Show();
		else
			self:Enable();
			_G[name .. "_Left"]:Show();
			_G[name .. "_Middle"]:Show();
			_G[name .. "_Right"]:Show();
			_G[name .. "_LeftActive"]:Hide();
			_G[name .. "_MiddleActive"]:Hide();
			_G[name .. "_RightActive"]:Hide();
		end
	end
end

--- Options tab frame is loaded
function DHUD_OptionsTemplates_LUA:processTabOnLoad(frame)
	local name = frame:GetName();
	-- save reference
	self.tabs[name] = frame;
	-- correct anchor point as all tabs are placed offscreen in design tab of addon studio
	frame:SetPoint("TopLeft", 5, -73);
	-- update button click handlers
	local leftButton = _G[name .. "_ScrollLeft"];
	leftButton:RegisterForClicks("LeftButtonUp");
	leftButton:SetScript("OnClick", function(frame, arg1)
		DHUD_OptionsTemplates_LUA:setActivePage(nil, -1);
	end);
	local rightButton = _G[name .. "_ScrollRight"];
	rightButton:RegisterForClicks("LeftButtonUp");
	rightButton:SetScript("OnClick", function(frame, arg1)
		DHUD_OptionsTemplates_LUA:setActivePage(nil, 1);
	end);
	-- debug
	--print("name " .. name .. " onLoad");
end

--- Options tab page frame is loaded
function DHUD_OptionsTemplates_LUA:processTabPageOnLoad(frame)
	local name = frame:GetName();
	local tabName = frame:GetParent():GetName();
	-- correct anchor point as all pages are placed offscreen in design tab of addon studio
	frame:SetPoint("TopLeft", 0, 0);
	-- get page number
	local pageString = strmatch(name, "Page%d+");
	local pageNum = tonumber(strsub(pageString, 5));
	-- save reference
	local list = self.tabPages[tabName];
	--print("page " .. tabName);
	if (list == nil) then
		list = { };
		self.tabPages[tabName] = list;
	end
	list[pageNum] = frame;
end

--- Options header frame is loaded
function DHUD_OptionsTemplates_LUA:processHeaderOnLoad(frame)
	local name = frame:GetName();
	local ltext = frame:GetAttribute("LTEXT") or "";
	frame.textField:SetText(DHUDOptionsLocalization[ltext] or ("LTEXT: " .. ltext));
	--print("header on load " .. frame:GetName() .. ", ltext " .. MCTableToString(ltext));
	--print("DHUDOptionsLocalization " .. MCTableToString(DHUDOptionsLocalization) .. ", ltext " .. ltext);
end

--- Options red button frame is loaded
function DHUD_OptionsTemplates_LUA:processRedButtonOnLoad(frame)
	local name = frame:GetName();
	local ltext = frame:GetAttribute("LTEXT") or "";
	frame:SetText(DHUDOptionsLocalization[ltext] or ("LTEXT: " .. ltext));
end

--- Options checkbox frame is loaded
function DHUD_OptionsTemplates_LUA:processCheckBoxOnLoad(frame)
	local name = frame:GetName();
	local ltext = frame:GetAttribute("LTEXT") or "";
	local setting = frame:GetAttribute("SETTING");
	-- set text
	_G[name .. "Text"]:SetText(DHUDOptionsLocalization[ltext] or ("LTEXT: " .. ltext));
	-- save setting
	frame.setting = setting;
	-- set on click handler
	frame:SetScript("OnClick", function(frame, arg1)
		DHUDOptions:toggleBooleanSetting(frame.setting);
	end);
	-- set on show handler
	frame:SetScript("OnShow", function(frame)
		frame:SetChecked(DHUDOptions:getSettingValue(frame.setting));
	end);
	-- set tooltip handlers
	frame:SetScript("OnEnter", function(frame)
		GameTooltip:SetOwner(frame, "ANCHOR_RIGHT");
		GameTooltip:SetText(DHUDOptionsLocalization[ltext .. "_TOOLTIP"] or ("LTOOLTIP: " .. ltext), 1, 1, 1, 1);
	end);
	frame:SetScript("OnLeave", function(frame)
		GameTooltip:Hide();
	end);
	--print("header on load " .. frame:GetName() .. ", ltext " .. MCTableToString(ltext));
end

--- Options slider frame is loaded
function DHUD_OptionsTemplates_LUA:processSliderOnLoad(frame)
	local name = frame:GetName();
	local ltext = frame:GetAttribute("LTEXT") or "";
	local setting = frame:GetAttribute("SETTING");
	-- save text
	frame.text = DHUDOptionsLocalization[ltext] or ("LTEXT: " .. ltext);
	-- save setting
	frame.setting = setting;
	-- get slider step info
	local stepInfo = DHUDOptions:getSettingRange(setting);
	-- save it and update text
	frame.stepInfo = stepInfo;
	frame:SetMinMaxValues(stepInfo[1], stepInfo[2]);
	frame:SetValueStep(stepInfo[3]);
	_G[name .. "Low"]:SetText(stepInfo[1]);
	_G[name .. "High"]:SetText(stepInfo[2]);
	-- set on click handler
	frame:SetScript("OnValueChanged", function(frame, arg1)
		local value = frame:GetValue();
		-- update value
		local step = frame.stepInfo[3];
		local oneDivStep = 1 / step;
		value =  math.floor((value + 0.00001) * oneDivStep) / oneDivStep;
		-- update slider position, required since 5.4
		if (not frame.updatingSlider) then
			frame.updatingSlider = true;
			frame:SetValue(value);
			frame.updatingSlider = false;
		else
			return; --ignore recursion handler
		end
		-- update text
		_G[name .. "Text"]:SetText(frame.text .. " " .. value);
		-- set value
		DHUDOptions:setSettingValue(frame.setting, value);
	end);
	-- set on show handler
	frame:SetScript("OnShow", function(frame)
		local value = DHUDOptions:getSettingValue(frame.setting) or -1;
		-- update text and slider
		_G[name .. "Text"]:SetText(frame.text .. " " .. value);
		frame:SetValue(value);
	end);
	-- set tooltip handlers
	frame:SetScript("OnEnter", function(frame)
		GameTooltip:SetOwner(frame, "ANCHOR_RIGHT");
		GameTooltip:SetText(DHUDOptionsLocalization[ltext .. "_TOOLTIP"] or ("LTOOLTIP: " .. ltext), 1, 1, 1, 1);
	end);
	frame:SetScript("OnLeave", function(frame)
		GameTooltip:Hide();
	end);
	--print("header on load " .. frame:GetName() .. ", ltext " .. MCTableToString(ltext));
end

--- Options radio button frame is loaded
function DHUD_OptionsTemplates_LUA:processRadioButtonOnLoad(frame)
	local name = frame:GetName();
	local ltext = frame:GetAttribute("LTEXT") or "";
	local setting = frame:GetAttribute("SETTING");
	local value = frame:GetAttribute("VALUE");
	local radioGroup = frame:GetAttribute("RADIOGROUP");
	if (radioGroup == nil) then
		DHUDOptions:print("Radio button radiogroup is nil for frame " .. frame:GetName());
		return;
	end
	-- update value to number
	if ((tonumber(value) .. "") == value) then
		value = tonumber(value);
	end
	-- save setting
	frame.setting = setting;
	frame.value = value;
	-- save radiogroup
	frame.radioGroup = radioGroup;
	local radioList = self.radioGroups[radioGroup];
	if (radioList == nil) then
		radioList = { };
		self.radioGroups[radioGroup] = radioList;
	end
	table.insert(radioList, frame);
	-- set text
	_G[name .. "Text"]:SetText(DHUDOptionsLocalization[ltext] or ("LTEXT: " .. ltext));
	-- set on click handler
	frame:SetScript("OnClick", function(frame, arg1)
		DHUDOptions:setSettingValue(frame.setting, frame.value);
		local list = DHUD_OptionsTemplates_LUA.radioGroups[frame.radioGroup];
		for i, v in ipairs(list) do
			v:SetChecked(false);
		end
		frame:SetChecked(true);
	end);
	-- set on show handler
	frame:SetScript("OnShow", function(frame)
		frame:SetChecked(frame.value == DHUDOptions:getSettingValue(frame.setting));
	end);
	-- set tooltip handlers
	frame:SetScript("OnEnter", function(frame)
		GameTooltip:SetOwner(frame, "ANCHOR_RIGHT");
		GameTooltip:SetText(DHUDOptionsLocalization[ltext .. "_TOOLTIP"] or ("LTOOLTIP: " .. ltext), 1, 1, 1, 1);
	end);
	frame:SetScript("OnLeave", function(frame)
		GameTooltip:Hide();
	end);
end

--- Options drop down check box frame is loaded
function DHUD_OptionsTemplates_LUA:processDropDownMaskOnLoad(frame)
	local name = frame:GetName();
	local ltext = frame:GetAttribute("LTEXT") or "";
	local setting = frame:GetAttribute("SETTING");
	local mask = DHUDSettings:getValueDefaultTable(setting)[3]["mask"];
	local maskLocale = DHUDOptionsLocalization[ltext .. "_MASK"];
	--print("mask is " .. MCTableToString(mask));
	-- update width
	UIDropDownMenu_SetWidth(frame, frame:GetWidth(), 0);
	-- update text
	_G[name .. "_Label"]:SetText(DHUDOptionsLocalization[ltext] or ("LTEXT: " .. ltext));
	-- save settings
	frame.setting = setting;
	frame.mask = mask;
	frame.maskLocale = maskLocale;
	-- add update text function
	frame.updateText = function(frame)
		-- read setting value
		local settingValue = DHUDOptions:getSettingValue(frame.setting);
		local mask = frame.mask;
		local maskLocale = frame.maskLocale;
		-- create text
		local text = "";
		for k, v in pairs(mask) do
			if (bit.band(settingValue, v) ~= 0) then
				local valueText = maskLocale[k] or ("LTEXT:" .. k);
				if (text == "") then
					text = text .. valueText;
				else
					text = text .. "+" .. valueText;
				end
			end
		end
		if (text == "") then
			text = maskLocale["UNSET"] or ("LTEXT:" .. "UNSET");
		end
		UIDropDownMenu_SetText(frame, text);
	end
	-- initialize drop down
	UIDropDownMenu_Initialize(frame, function(frame)
		-- for nested function
		local dropDownFrame = frame;
		-- read setting value and copy it
		local settingValue = DHUDOptions:getSettingValue(frame.setting);
		local mask = frame.mask;
		local maskLocale = frame.maskLocale;
		-- go through mask
		for k, v in pairs(mask) do
			local info = {};
			info.text = maskLocale[k] or ("LTEXT:" .. k);
			info.isNotRadio = true;
			info.keepShownOnClick = true;
			info.checked = bit.band(settingValue, v) ~= 0;
			info.owner = dropDownFrame;
			info.arg1 = v;
			-- dropdown click function
			info.func = function(frame, value, arg2, checked)
				-- update setting for source
				if (checked) then
					settingValue = bit.bor(settingValue, value);
				else
					settingValue = bit.band(settingValue, bit.bnot(value));
				end
				--settingValue = 2;
				DHUDOptions:setSettingValue(setting, settingValue);
				-- update text
				dropDownFrame:updateText();
				--print("setting " .. setting .. ", [value " .. value .. "] - set to " .. MCTableToString(settingValue));
				--frame:SetText("clicked");
			end
			-- add button
			UIDropDownMenu_AddButton(info);
		end
	end);
	-- set on show handler
	frame:SetScript("OnShow", function(frame)
		frame:updateText();
	end);
	-- set tooltip handlers
	frame:SetScript("OnEnter", function(frame)
		GameTooltip:SetOwner(frame, "ANCHOR_RIGHT");
		GameTooltip:SetText(DHUDOptionsLocalization[ltext .. "_TOOLTIP"] or ("LTOOLTIP: " .. ltext), 1, 1, 1, 1);
	end);
	frame:SetScript("OnLeave", function(frame)
		GameTooltip:Hide();
	end);
end

--- Options drop down frames data frame is loaded
function DHUD_OptionsTemplates_LUA:processDropDownFramesDataOnLoad(frame)
	local name = frame:GetName();
	local ltext = frame:GetAttribute("LTEXT") or "";
	local setting = frame:GetAttribute("SETTING");
	local setting2 = frame:GetAttribute("SETTING2");
	local frameType = frame:GetAttribute("FRAMETYPE");
	local frameType2 = frame:GetAttribute("FRAMETYPE2");
	-- update width
	UIDropDownMenu_SetWidth(frame, frame:GetWidth(), 0);
	-- update text
	_G[name .. "_Label"]:SetText(DHUDOptionsLocalization[ltext] or ("LTEXT: " .. ltext));
	-- save settings
	frame.setting = setting;
	frame.frameType = frameType;
	frame.setting2 = setting2;
	frame.frameType2 = frameType2;
	-- reference to DHUD settings data sources table
	local frameDataSources = DHUDSettings.default["framesDataSources"][1];
	-- add update text function
	frame.updateText = function(frame)
		-- read setting value
		local settingValue = DHUDOptions:getSettingValue(frame.setting);
		local settingValue2 = DHUDOptions:getSettingValue(frame.setting2, false, {});
		-- create text
		local text = "";
		for i, v in ipairs(settingValue) do
			local valueText = DHUDOptionsLocalization["SETTING_LAYOUTS_DATA_SOURCES"][v];
			if (settingValue2[i] ~= nil) then
				valueText = valueText .. " + " .. DHUDOptionsLocalization["SETTING_LAYOUTS_DATA_SOURCES"][settingValue2[i]];
			end
			if (text == "") then
				text = text .. valueText;
			else
				text = text .. ", " .. valueText;
			end
		end
		UIDropDownMenu_SetText(frame, text);
	end
	-- add update buttons text function
	frame.updateButtonsText = function(frame)
		-- read setting value
		local settingValue = DHUDOptions:getSettingValue(frame.setting);
		local settingValue2 = DHUDOptions:getSettingValue(frame.setting2, false, {});
		-- update buttons text
		for i = 1, UIDROPDOWNMENU_MAXBUTTONS do
			local button = _G["DropDownList"..UIDROPDOWNMENU_MENU_LEVEL.."Button"..i];
			local owner = button.owner;
			if (owner == frame) then
				local value = button.arg2;
				local buttonText = DHUDOptionsLocalization["SETTING_LAYOUTS_DATA_SOURCES"][value];
				local order1 = MCIndexOfValueInTable(settingValue, value);
				local order2 = MCIndexOfValueInTable(settingValue2, value);
				if (order1 >= 1) then
					button:SetText(order1 .. ". " .. buttonText);
				elseif (order2 >= 1) then
					button:SetText("+" .. order2 .. ". " .. buttonText);
				else
					button:SetText(buttonText);
				end
			end
		end
	end
	-- initialize drop down
	UIDropDownMenu_Initialize(frame, function(frame)
		-- for nested function
		local dropDownFrame = frame;
		-- read setting value and copy it
		local settingValue = DHUDOptions:getSettingValue(frame.setting, true);
		local settingValue2 = DHUDOptions:getSettingValue(frame.setting2, true, {});
		-- get available sources
		local availableDataSources = frameDataSources[frame.frameType] or {};
		local availableDataSources2 = frameDataSources[frame.frameType2] or {};
		-- go through sources
		for sourceIndex = 1, 2, 1 do
			local sources = (sourceIndex == 1) and availableDataSources or availableDataSources2;
			for i, v in ipairs(sources) do
				-- check if datasource is available
				if (frameDataSources.dataTrackersMap[v] == nil or frameDataSources.dataTrackersMap[v][1] == nil) then
					-- datasource is not available for current class
				else
					-- datasource is available
					local info = {};
					info.text = DHUDOptionsLocalization["SETTING_LAYOUTS_DATA_SOURCES"][v] or ("LTEXT:" .. v);
					info.isNotRadio = true;
					info.keepShownOnClick = true;
					info.checked = (MCIndexOfValueInTable(settingValue, v) >= 1) or (MCIndexOfValueInTable(settingValue2, v) >= 1);
					info.owner = dropDownFrame;
					info.arg1 = sourceIndex;
					info.arg2 = v;
					-- dropdown click function
					info.func = function(frame, sourceIndex, value, checked)
						-- update setting for source
						if (sourceIndex == 1) then
							if (checked) then
								table.insert(settingValue, value);
							else
								local index = MCIndexOfValueInTable(settingValue, value);
								table.remove(settingValue, index);
							end
							DHUDOptions:setSettingValue(setting, settingValue);
						else
							if (checked) then
								table.insert(settingValue2, value);
							else
								local index = MCIndexOfValueInTable(settingValue2, value);
								table.remove(settingValue2, index);
							end
							DHUDOptions:setSettingValue(setting2, settingValue2);
						end
						-- update text
						dropDownFrame:updateText();
						-- update order
						dropDownFrame:updateButtonsText();
						-- update radio buttons
						for i, v in ipairs(DHUD_OptionsTemplates_LUA.frameDataRadioButtons) do
							local onShow = v:GetScript("OnShow");
							onShow(v);
						end
						--print("setting " .. setting .. " set to " .. MCTableToString(settingValue));
						--print("clicked " .. arg1 .. ", checked " .. MCTableToString(checked));
						--frame:SetText("clicked");
					end
					-- add button
					UIDropDownMenu_AddButton(info);
				end
			end
		end
		-- update text
		frame:updateButtonsText();
	end);
	-- set on show handler
	frame:SetScript("OnShow", function(frame)
		frame:updateText();
	end);
	-- set tooltip handlers
	frame:SetScript("OnEnter", function(frame)
		GameTooltip:SetOwner(frame, "ANCHOR_RIGHT");
		GameTooltip:SetText(DHUDOptionsLocalization[ltext .. "_TOOLTIP"] or ("LTOOLTIP: " .. ltext), 1, 1, 1, 1);
	end);
	frame:SetScript("OnLeave", function(frame)
		GameTooltip:Hide();
	end);
	-- add to list
	table.insert(self.frameDataDropDowns, frame);
end

--- Options drop down frames data frame is loaded
function DHUD_OptionsTemplates_LUA:processDropDownFramesPositionOnLoad(frame)
	local name = frame:GetName();
	local ltext = frame:GetAttribute("LTEXT") or "";
	local setting = frame:GetAttribute("SETTING");
	local settingLastName = "";
	if (setting ~= nil) then
		local default = DHUDSettings:getValueDefaultTable(setting);
		if (default ~= nil) then
			settingLastName = default[3].lastName;
		end
	end
	-- update width
	UIDropDownMenu_SetWidth(frame, frame:GetWidth(), 0);
	-- update text
	_G[name .. "_Label"]:SetText(DHUDOptionsLocalization[ltext] or ("LTEXT: " .. ltext));
	-- save settings
	frame.setting = setting;
	frame.settingLastName = settingLastName;
	-- reference to DHUD settings data sources table
	local frameDataPositions = DHUDSettings.default["framesDataSources"][1]["positions"];
	-- initialize drop down
	UIDropDownMenu_Initialize(frame, function(frame)
		-- for nested function
		local dropDownFrame = frame;
		-- read setting value and copy it
		local settingValue = DHUDOptions:getSettingValue(frame.setting, true);
		-- button id to select
		local idToSelect = 1;
		-- go through positions
		local positions = frameDataPositions[settingLastName] or {};
		for i, v in ipairs(positions) do
			-- dataposition is available
			local info = {};
			info.text = DHUDOptionsLocalization["SETTING_LAYOUTS_DATA_POSITIONS"][v] or ("LTEXT:" .. v);
			info.owner = dropDownFrame;
			info.arg2 = v;
			idToSelect = (v == settingValue) and i or idToSelect;
			-- dropdown click function
			info.func = function(frame, arg1, value, checked)
				-- update setting for source
				DHUDOptions:setSettingValue(setting, value);
				-- set selected
				UIDropDownMenu_SetSelectedID(dropDownFrame, frame:GetID());
				-- update radio
				for i, v in ipairs(DHUD_OptionsTemplates_LUA.frameDataRadioButtons) do
					local onShow = v:GetScript("OnShow");
					onShow(v);
				end
			end
			-- add button
			UIDropDownMenu_AddButton(info);
		end
		-- select required button
		UIDropDownMenu_SetSelectedID(frame, idToSelect);
	end);
	-- set on show handler
	frame:SetScript("OnShow", function(frame)
		-- read setting value
		local settingValue = DHUDOptions:getSettingValue(frame.setting);
		-- update text, no need in selecting button as they are disposed
		UIDropDownMenu_SetText(frame, DHUDOptionsLocalization["SETTING_LAYOUTS_DATA_POSITIONS"][settingValue]);
	end);
	-- set tooltip handlers
	frame:SetScript("OnEnter", function(frame)
		GameTooltip:SetOwner(frame, "ANCHOR_RIGHT");
		GameTooltip:SetText(DHUDOptionsLocalization[ltext .. "_TOOLTIP"] or ("LTOOLTIP: " .. ltext), 1, 1, 1, 1);
	end);
	frame:SetScript("OnLeave", function(frame)
		GameTooltip:Hide();
	end);
	-- add to list
	table.insert(self.frameDataDropDowns, frame);
end

--- Options lauout radio button frame is loaded
function DHUD_OptionsTemplates_LUA:processLayoutsRadioButtonOnLoad(frame)
	local name = frame:GetName();
	local setting = frame:GetAttribute("SETTING");
	local value = frame:GetAttribute("VALUE");
	-- call super
	self:processRadioButtonOnLoad(frame);
	-- rewrite onShow
	frame:SetScript("OnShow", function(frame)
		local value = DHUDOptions:getSettingValue(frame.setting);
		-- check if other setting are not custom
		local isLayoutCustom = DHUDOptions:isLayoutCustom();
		if (isLayoutCustom) then
			frame:SetChecked(frame.value == 0);
		else
			frame:SetChecked(frame.value == value);
		end
	end);
	-- rewrite onClick
	local script = frame:GetScript("OnClick");
	frame:SetScript("OnClick", function(frame)
		script(frame); -- call super
		-- update drop downs
		for i, v in ipairs(DHUD_OptionsTemplates_LUA.frameDataDropDowns) do
			local onShow = v:GetScript("OnShow");
			onShow(v);
		end
	end);
	-- add to list
	table.insert(self.frameDataRadioButtons, frame);
end

--- Options spell list text box frame is loaded
function DHUD_OptionsTemplates_LUA:processSpellListTextBoxOnLoad(frame)
	local name = frame:GetName();
	local ltext = frame:GetAttribute("LTEXT") or "";
	local setting = frame:GetAttribute("SETTING");
	-- save settings
	frame.setting = setting;
	-- update backdrop color
	frame:SetBackdropColor(0.1, 0.1, 0.1, 1);
	-- update text box handlers
	local scrollFrame = _G[name .. "_ScrollFrame"];
	local scrollBar = _G[name .. "_ScrollFrameScrollBar"];
	local textBox = _G[name .. "_ScrollFrame_Text"];
	-- text changed handler
	textBox:SetScript("OnTextChanged", function(frame)
		
	end);
	-- text changed handler
	textBox:SetScript("OnCursorChanged", function(frame, x, y, w, h)
		--print("x " .. x .. ", y " .. y .. ", w " .. w .. ", h " .. h);
		local scrollPos = scrollFrame:GetVerticalScroll();
		local frameHeight  = scrollFrame:GetHeight();
		-- at top?
		if ((scrollPos + y) > 0) then
			scrollFrame:SetVerticalScroll(-y);
		elseif (0 > (scrollPos + y - h + frameHeight)) then
			scrollFrame:SetVerticalScroll(-y + h - frameHeight);
		end
	end);
	-- escape handler
	textBox:SetScript("OnEscapePressed", function(frame)
		frame:ClearFocus();
	end);
	-- focus gained handler
	textBox:SetScript("OnEditFocusGained", function(frame)
		DHUD_OptionsTemplates_LUA.focusedTextBox = frame;
		DHUD_OptionsFrame_LUA:showHelp(DHUDOptionsLocalization["HELP_TIMERS"] or ("HELP_TIMERS"));
	end);
	-- focus lost handler
	textBox:SetScript("OnEditFocusLost", function(frame)
		DHUD_OptionsTemplates_LUA.focusedTextBox = nil;
		DHUD_OptionsFrame_LUA:hideHelp();
		-- update setting
		local text = textBox:GetText();
		local newValue = { strsplit("[,\n]", text) };
		--print("newValue " .. MCTableToString(newValue));
		-- remove excess spaces
		local removeLeadingAndTrailingWhiteSpace = "^%s*(.-)%s*$";
		local n = #newValue;
		for i = n, 1, -1 do
			newValue[i] = newValue[i]:match(removeLeadingAndTrailingWhiteSpace);
			-- empty string are not required
			if (newValue[i] == "") then
				table.remove(newValue, i);
			end
		end
		--print("newValue new " .. MCTableToString(newValue));
		-- save value
		DHUDOptions:setSettingValue(setting, newValue);
		--print("newVal " .. MCTableToString(newValue));
	end);
	textBox:SetAutoFocus(false);
	textBox:SetMaxLetters(4096);
	-- update click area handler
	local clickArea = _G[name .. "_Clicker"];
	clickArea:SetScript("OnClick", function(frame)
		textBox:SetFocus();
	end);
	-- update label
	_G[name .. "_Label"]:SetText(DHUDOptionsLocalization[ltext] or ("LTEXT: " .. ltext));
	-- set on show handler
	frame:SetScript("OnShow", function(frame)
		-- read setting value
		local settingValue = DHUDOptions:getSettingValue(frame.setting);
		--print("frame.setting " .. frame.setting .. ", settingValue " .. MCTableToString(settingValue));
		-- generate text
		local text = table.concat(settingValue, ", ") or "";
		-- update text
		textBox:SetText(text);
	end);
	-- set tooltip handlers
	frame:SetScript("OnEnter", function(frame)
		GameTooltip:SetOwner(frame, "ANCHOR_RIGHT");
		GameTooltip:SetText(DHUDOptionsLocalization[ltext .. "_TOOLTIP"] or ("LTOOLTIP: " .. ltext), 1, 1, 1, 1);
	end);
	frame:SetScript("OnLeave", function(frame)
		GameTooltip:Hide();
	end);
end

--- Options colors line frame is loaded
function DHUD_OptionsTemplates_LUA:processColorsLineOnLoad(frame)
	local name = frame:GetName();
	local ltext = frame:GetAttribute("LTEXT") or "";
	local setting = frame:GetAttribute("SETTING");
	-- save settings
	frame.setting = setting;
	-- update text
	_G[name .. "_Text"]:SetText(DHUDOptionsLocalization[ltext] or ("LTEXT: " .. ltext));
	-- to be referenced in nested function
	local colorsLineFrame = frame;
	-- add color picker functions
	frame.onAcceptColorPick = function()
		local rgb = { ColorPickerFrame:GetColorRGB() };
		local hex = DHUDColorizeTools:colorToHex(rgb);
		local buttonIndex = ColorPickerFrame.objindex;
		-- read setting value
		local settingValue = DHUDOptions:getSettingValue(frame.setting, true);
		-- set setting
		settingValue[buttonIndex] = hex;
		DHUDOptions:setSettingValue(frame.setting, settingValue);
		-- update colors line
		frame:updateColors();
	end
	frame.onCancelColorPick = function()
		local rgb = ColorPickerFrame.previousValues;
		local hex = DHUDColorizeTools:colorToHex(rgb);
		local buttonIndex = ColorPickerFrame.objindex;
		-- read setting value
		local settingValue = DHUDOptions:getSettingValue(frame.setting, true);
		-- set setting
		settingValue[buttonIndex] = hex;
		DHUDOptions:setSettingValue(frame.setting, settingValue);
		-- update colors line
		frame:updateColors();
	end
	-- add onClick handlers and count colors
	local i = 1;
	while (true) do
		local colorButton = _G[name .. "_" .. i];
		if (colorButton == nil) then
			frame.colorsCount = i - 1;
			break;
		end
		local buttonIndex = i;
		-- add on click
		colorButton:SetScript("OnClick", function(frame, arg1)
			-- read setting value
			local settingValue = DHUDOptions:getSettingValue(colorsLineFrame.setting);
			-- read color
			local colorHex = settingValue[buttonIndex] or "FFFFFF";
			local color = DHUDColorizeTools:hexToColor(colorHex);
			
			-- fill color picker settings
			ColorPickerFrame.previousValues = color;
			ColorPickerFrame.cancelFunc = colorsLineFrame.onCancelColorPick;
			ColorPickerFrame.func = colorsLineFrame.onAcceptColorPick;
			ColorPickerFrame.objname = frame:GetName();
			ColorPickerFrame.objindex = buttonIndex;
			ColorPickerFrame.tohue = name .. "_" .. buttonIndex .. "Texture";
			ColorPickerFrame.hasOpacity = false;
			ColorPickerFrame:SetColorRGB(color[1], color[2], color[3]);
			ColorPickerFrame:ClearAllPoints();
			-- update color picker position
			local x = DHUD_OptionsFrame:GetCenter();
			if (x < UIParent:GetWidth() / 2) then
				ColorPickerFrame:SetPoint("LEFT", "DHUD_OptionsFrame", "RIGHT", 0, 0);
			else
				ColorPickerFrame:SetPoint("RIGHT", "DHUD_OptionsFrame", "LEFT", 0, 0);
			end
			-- show color picker
			ColorPickerFrame:Show();
		end);
		i = i + 1;
	end
	-- add update colors function
	frame.updateColors = function(frame)
		-- read setting value
		local settingValue = DHUDOptions:getSettingValue(frame.setting);
		-- iterate
		local colorsCount = frame.colorsCount;
		for i = 1, colorsCount, 1 do
			local colorHex = settingValue[i] or "FFFFFF";
			local color = DHUDColorizeTools:hexToColor(colorHex);
			_G[name .. "_" .. i .. "Texture"]:SetTexture(color[1], color[2], color[3]);
			if (i > 1) then
				local colorHexPrev = settingValue[i - 1] or "FFFFFF";
				local colorPrev = DHUDColorizeTools:hexToColor(colorHexPrev);
				_G[name .. "_G" .. (i - 1) .. "Texture"]:SetGradient("HORIZONTAL", colorPrev[1], colorPrev[2], colorPrev[3], color[1], color[2], color[3]);
			end
		end
	end
	-- set on show handler
	frame:SetScript("OnShow", function(frame)
		frame:updateColors();
	end);
	-- set tooltip handlers
	frame:SetScript("OnEnter", function(frame)
		GameTooltip:SetOwner(frame, "ANCHOR_RIGHT");
		GameTooltip:SetText(DHUDOptionsLocalization[ltext .. "_TOOLTIP"] or ("LTOOLTIP: " .. ltext), 1, 1, 1, 1);
	end);
	frame:SetScript("OnLeave", function(frame)
		GameTooltip:Hide();
	end);
end

--- Options unit text frame is loaded
function DHUD_OptionsTemplates_LUA:processUnitTextOnLoad(frame)
	local name = frame:GetName();
	local ltext = frame:GetAttribute("LTEXT") or "";
	local setting = frame:GetAttribute("SETTING");
	local settingType = frame:GetAttribute("SETTINGTYPE");
	-- save settings
	frame.setting = setting;
	-- update backdrop color
	frame:SetBackdropColor(0.1, 0.1, 0.1, 1);
	-- for nested function
	local unitTextFrame = frame;
	-- update text box handlers
	local scrollFrame = _G[name .. "_ScrollFrame"];
	local scrollBar = _G[name .. "_ScrollFrameScrollBar"];
	local textBox = _G[name .. "_ScrollFrame_Text"];
	-- text changed handler
	textBox:SetScript("OnTextChanged", function(frame)
		
	end);
	-- text changed handler
	textBox:SetScript("OnCursorChanged", function(frame, x, y, w, h)
		--print("x " .. x .. ", y " .. y .. ", w " .. w .. ", h " .. h);
		local scrollPos = scrollFrame:GetVerticalScroll();
		local frameHeight  = scrollFrame:GetHeight();
		-- at top?
		if ((scrollPos + y) > 0) then
			scrollFrame:SetVerticalScroll(-y);
		elseif (0 > (scrollPos + y - h + frameHeight)) then
			scrollFrame:SetVerticalScroll(-y + h - frameHeight);
		end
	end);
	-- escape handler
	textBox:SetScript("OnEscapePressed", function(frame)
		frame:ClearFocus();
	end);
	-- focus gained handler
	textBox:SetScript("OnEditFocusGained", function(frame)
		DHUD_OptionsTemplates_LUA.focusedTextBox = frame;
		local helpId = settingType;
		if (strmatch(helpId, "cast")) then
			helpId = "cast";
		end
		DHUD_OptionsFrame_LUA:showHelp((DHUDOptionsLocalization["HELP_UNITTEXTS"] or ("HELP_UNITTEXTS")) .. (DHUDOptionsLocalization["HELP_UNITTEXTS_TYPE"][helpId] or ("HELP: " .. helpId)));
	end);
	-- focus lost handler
	textBox:SetScript("OnEditFocusLost", function(frame)
		DHUD_OptionsTemplates_LUA.focusedTextBox = nil;
		DHUD_OptionsFrame_LUA:hideHelp();
		-- update setting
		local text = textBox:GetText();
		DHUDOptions:setSettingValue(setting, text);
		-- update frame
		unitTextFrame:onShow();
	end);
	textBox:SetAutoFocus(false);
	textBox:SetMaxLetters(4096);
	-- update click area handler
	local clickArea = _G[name .. "_Clicker"];
	clickArea:SetScript("OnClick", function(frame)
		textBox:SetFocus();
	end);
	-- update label
	_G[name .. "_DropDown_Label"]:SetText(DHUDOptionsLocalization[ltext] or ("LTEXT: " .. ltext));
	-- reference to DHUD settings predefined texts
	local predefinedTexts = DHUDSettings.default["unitTextsPredefined"][1];
	-- sort predefined texts in fixed order
	local predefinedTextsKeys = { };
	for k, v in pairs(predefinedTexts) do
		table.insert(predefinedTextsKeys, k);
	end
	table.sort(predefinedTextsKeys);
	-- initialize drop down
	local dropDownFrame = _G[name .. "_DropDown"];
	UIDropDownMenu_Initialize(dropDownFrame, function(frame)
		-- for nested function
		local dropDownFrame = frame;
		-- read setting value and copy it
		local settingValue = DHUDOptions:getSettingValue(setting, true);
		-- button id to select
		local idToSelect = -1;
		local i = 1;
		-- go through predefined texts
		for ki, k in pairs(predefinedTextsKeys) do
			-- check if text matches setting type
			if (strmatch(k, settingType .. "%d+") ~= nil) then
				local v = predefinedTexts[k];
				local info = {};
				info.text = DHUDOptionsLocalization["SETTING_UNITTEXTS_PREDEFINED_CUSTOM"][k] or ("LTEXT:" .. k);
				info.owner = dropDownFrame;
				info.arg2 = k;
				idToSelect = (v == settingValue) and i or idToSelect;
				-- dropdown click function
				info.func = function(frame, arg1, value, checked)
					-- update setting
					DHUDOptions:setSettingValue(setting, "@" .. value);
					-- set selected
					UIDropDownMenu_SetSelectedID(dropDownFrame, frame:GetID());
					-- update text box
					unitTextFrame:onShow();
				end
				-- add button
				UIDropDownMenu_AddButton(info);
				i = i + 1;
			end
		end
		-- add empty text
		local info = {};
		info.text = DHUDOptionsLocalization["SETTING_UNITTEXTS_PREDEFINED_ALL"]["empty"] or ("LTEXT:" .. "empty");
		info.owner = dropDownFrame;
		idToSelect = ("" == settingValue) and i or idToSelect;
		-- dropdown click function
		info.func = function(frame, arg1, arg2, checked)
			-- update setting
			DHUDOptions:setSettingValue(setting, "");
			-- set selected
			UIDropDownMenu_SetSelectedID(dropDownFrame, frame:GetID());
			-- update text box
			unitTextFrame:onShow();
		end
		-- add button
		UIDropDownMenu_AddButton(info);
		i = i + 1;
		-- add custom text
		local info = {};
		info.text = DHUDOptionsLocalization["SETTING_UNITTEXTS_PREDEFINED_ALL"]["custom"] or ("LTEXT:" .. "custom");
		info.owner = dropDownFrame;
		idToSelect = (-1 == idToSelect) and i or idToSelect;
		-- dropdown click function
		info.func = function(frame, arg1, arg2, checked)
			-- set selected
			UIDropDownMenu_SetSelectedID(dropDownFrame, frame:GetID());
		end
		-- add button
		UIDropDownMenu_AddButton(info);
		i = i + 1;
		-- select required button
		UIDropDownMenu_SetSelectedID(frame, idToSelect);
	end);
	-- set on show handler
	frame.onShow = function(frame)
		-- read setting value
		local settingValue = DHUDOptions:getSettingValue(frame.setting);
		-- update text
		textBox:SetText(settingValue);
		-- create text for drop down
		local textDropDown = "";
		-- go through predefined texts
		for k, v in pairs(predefinedTexts) do
			if (v == settingValue) then
				textDropDown = DHUDOptionsLocalization["SETTING_UNITTEXTS_PREDEFINED_CUSTOM"][k] or ("LTEXT:" .. k);
			end
		end
		-- check if empty
		if ("" == settingValue) then
			textDropDown = DHUDOptionsLocalization["SETTING_UNITTEXTS_PREDEFINED_ALL"]["empty"] or ("LTEXT:" .. "empty");
		end
		-- check if custom
		if ("" == textDropDown) then
			textDropDown = DHUDOptionsLocalization["SETTING_UNITTEXTS_PREDEFINED_ALL"]["custom"] or ("LTEXT:" .. "custom");
		end
		-- update drop down text, no need in selecting button as they are disposed
		UIDropDownMenu_SetText(dropDownFrame, textDropDown);
	end;
	frame:SetScript("OnShow", function(frame)
		frame:onShow();
	end);
	-- set tooltip handlers
	frame:SetScript("OnEnter", function(frame)
		GameTooltip:SetOwner(frame, "ANCHOR_RIGHT");
		GameTooltip:SetText(DHUDOptionsLocalization[ltext .. "_TOOLTIP"] or ("LTOOLTIP: " .. ltext), 1, 1, 1, 1);
	end);
	frame:SetScript("OnLeave", function(frame)
		GameTooltip:Hide();
	end);
	dropDownFrame:SetScript("OnEnter", function(frame)
		GameTooltip:SetOwner(frame, "ANCHOR_RIGHT");
		GameTooltip:SetText(DHUDOptionsLocalization[ltext .. "_TOOLTIP"] or ("LTOOLTIP: " .. ltext), 1, 1, 1, 1);
	end);
	dropDownFrame:SetScript("OnLeave", function(frame)
		GameTooltip:Hide();
	end);
end

--- Options distance box frame is loaded
function DHUD_OptionsTemplates_LUA:processDistanceBoxOnLoad(frame)
	local name = frame:GetName();
	local ltext = frame:GetAttribute("LTEXT") or "";
	local setting = frame:GetAttribute("SETTING");
	-- save settings
	frame.setting = setting;
	-- for nested functions
	local distanceBox = frame;
	-- update text
	_G[name .. "_Text"]:SetText(DHUDOptionsLocalization[ltext] or ("LTEXT: " .. ltext));
	-- update text box and button handlers
	local textBox = _G[name .. "_MiniEditBox"];
	textBox:SetAutoFocus(false);
	-- enter and escape handlers
	textBox:SetScript("OnEnterPressed", function(frame)
		frame:ClearFocus();
	end);
	textBox:SetScript("OnEscapePressed", function(frame)
		frame:ClearFocus();
	end);
	-- text changed handler
	textBox:SetScript("OnTextChanged", function(frame)
		local number = frame:GetNumber() or 0;
		-- update text to accept only numbers
		if (frame:GetText() ~= "-") then -- SetNumeric doesn't support negative numbers
			frame:SetText(number);
		end
		-- update setting
		DHUDOptions:setSettingValue(setting, number);
	end);
	-- select on focus
	textBox:SetScript("OnEditFocusGained", function(frame)
		DHUD_OptionsTemplates_LUA.focusedTextBox = frame;
		frame:HighlightText();
	end);
	textBox:SetScript("OnEditFocusLost", function(frame)
		DHUD_OptionsTemplates_LUA.focusedTextBox = nil;
		frame:HighlightText(0, 0);
	end);
	-- left button
	local leftButton = _G[name .. "_DecButton"];
	leftButton:RegisterForClicks("LeftButtonUp", "RightButtonUp");
	leftButton:SetScript("OnClick", function(frame, arg1)
		-- read setting value
		local settingValue = DHUDOptions:getSettingValue(setting, true);
		-- update setting value
		if (arg1 == "RightButton") then
			DHUDOptions:setSettingValue(setting, settingValue - 10);
		else
			DHUDOptions:setSettingValue(setting, settingValue - 1);
		end
		distanceBox:onShow();
	end);
	-- right button
	local rightButton = _G[name .. "_IncButton"];
	rightButton:RegisterForClicks("LeftButtonUp", "RightButtonUp");
	rightButton:SetScript("OnClick", function(frame, arg1)
		-- read setting value
		local settingValue = DHUDOptions:getSettingValue(setting, true);
		-- update setting value
		if (arg1 == "RightButton") then
			DHUDOptions:setSettingValue(setting, settingValue + 10);
		else
			DHUDOptions:setSettingValue(setting, settingValue + 1);
		end
		distanceBox:onShow();
	end);
	-- set onShow handler
	frame.onShow = function(frame)
		-- read setting value
		local settingValue = DHUDOptions:getSettingValue(frame.setting) or 0;
		-- update text
		textBox:SetText(settingValue);
	end;
	frame:SetScript("OnShow", function(frame)
		frame:onShow();
	end);
	-- set tooltip handlers
	frame:SetScript("OnEnter", function(frame)
		GameTooltip:SetOwner(frame, "ANCHOR_RIGHT");
		GameTooltip:SetText(DHUDOptionsLocalization[ltext .. "_TOOLTIP"] or ("LTOOLTIP: " .. ltext), 1, 1, 1, 1);
	end);
	frame:SetScript("OnLeave", function(frame)
		GameTooltip:Hide();
	end);
end

--- Options position box frame is loaded
function DHUD_OptionsTemplates_LUA:processPositionBoxOnLoad(frame)
	local name = frame:GetName();
	local ltext = frame:GetAttribute("LTEXT") or "";
	local setting = frame:GetAttribute("SETTING");
	-- save settings
	frame.setting = setting;
	-- for nested functions
	local positionBox = frame;
	-- update text
	_G[name .. "_Text"]:SetText(DHUDOptionsLocalization[ltext] or ("LTEXT: " .. ltext));
	-- update text box and button handlers
	for i = 1, 2, 1 do
		local postfix = (i ~= 1) and i or "";
		local index = i;
		-- get textbox
		local textBox = _G[name .. "_MiniEditBox" .. postfix];
		textBox:SetAutoFocus(false);
		-- enter and escape handlers
		textBox:SetScript("OnEnterPressed", function(frame)
			frame:ClearFocus();
		end);
		textBox:SetScript("OnEscapePressed", function(frame)
			frame:ClearFocus();
		end);
		-- text changed handler
		textBox:SetScript("OnTextChanged", function(frame)
			-- read setting value
			local settingValue = DHUDOptions:getSettingValue(setting, true);
			-- get number
			local number = frame:GetNumber() or 0;
			-- update text to accept only numbers
			if (frame:GetText() ~= "-") then -- SetNumeric doesn't support negative numbers
				frame:SetText(number);
			end
			-- update setting
			settingValue[index] = number;
			DHUDOptions:setSettingValue(setting, settingValue);
		end);
		-- select on focus
		textBox:SetScript("OnEditFocusGained", function(frame)
			DHUD_OptionsTemplates_LUA.focusedTextBox = frame;
			frame:HighlightText();
		end);
		textBox:SetScript("OnEditFocusLost", function(frame)
			DHUD_OptionsTemplates_LUA.focusedTextBox = nil;
			frame:HighlightText(0, 0);
		end);
		-- left button
		local leftButton = _G[name .. "_DecButton" .. postfix];
		leftButton:RegisterForClicks("LeftButtonUp", "RightButtonUp");
		leftButton:SetScript("OnClick", function(frame, arg1)
			-- read setting value
			local settingValue = DHUDOptions:getSettingValue(setting, true);
			-- update setting value
			if (arg1 == "RightButton") then
				settingValue[index] = settingValue[index] - 10;
			else
				settingValue[index] = settingValue[index] - 1;
			end
			DHUDOptions:setSettingValue(setting, settingValue);
			positionBox:onShow();
		end);
		-- right button
		local rightButton = _G[name .. "_IncButton" .. postfix];
		rightButton:RegisterForClicks("LeftButtonUp", "RightButtonUp");
		rightButton:SetScript("OnClick", function(frame, arg1)
			-- read setting value
			local settingValue = DHUDOptions:getSettingValue(setting, true);
			-- update setting value
			if (arg1 == "RightButton") then
				settingValue[index] = settingValue[index] + 10;
			else
				settingValue[index] = settingValue[index] + 1;
			end
			DHUDOptions:setSettingValue(setting, settingValue);
			positionBox:onShow();
		end);
	end
	-- set onShow handler
	frame.onShow = function(frame)
		-- read setting value
		local settingValue = DHUDOptions:getSettingValue(frame.setting) or { 0, 0 };
		-- update text
		_G[name .. "_MiniEditBox"]:SetText(settingValue[1]);
		_G[name .. "_MiniEditBox2"]:SetText(settingValue[2]);
	end;
	frame:SetScript("OnShow", function(frame)
		frame:onShow();
	end);
	-- set tooltip handlers
	frame:SetScript("OnEnter", function(frame)
		GameTooltip:SetOwner(frame, "ANCHOR_RIGHT");
		GameTooltip:SetText(DHUDOptionsLocalization[ltext .. "_TOOLTIP"] or ("LTOOLTIP: " .. ltext), 1, 1, 1, 1);
	end);
	frame:SetScript("OnLeave", function(frame)
		GameTooltip:Hide();
	end);
end

--- Options general text box frame is loaded
function DHUD_OptionsTemplates_LUA:processGeneralTextBoxOnLoad(frame)
	local name = frame:GetName();
	local ltext = frame:GetAttribute("LTEXT") or "";
	local setting = frame:GetAttribute("SETTING");
	local help = frame:GetAttribute("HELP") or "";
	-- save settings
	frame.setting = setting;
	-- update backdrop color
	frame:SetBackdropColor(0.1, 0.1, 0.1, 1);
	-- for nested function
	local generalTextBoxFrame = frame;
	-- update text box handlers
	local scrollFrame = _G[name .. "_ScrollFrame"];
	local scrollBar = _G[name .. "_ScrollFrameScrollBar"];
	local textBox = _G[name .. "_ScrollFrame_Text"];
	-- update text box size
	textBox:SetWidth(frame:GetWidth() - 36);
	-- text changed handler
	textBox:SetScript("OnTextChanged", function(frame)
		
	end);
	-- text changed handler
	textBox:SetScript("OnCursorChanged", function(frame, x, y, w, h)
		--print("x " .. x .. ", y " .. y .. ", w " .. w .. ", h " .. h);
		local scrollPos = scrollFrame:GetVerticalScroll();
		local frameHeight  = scrollFrame:GetHeight();
		-- at top?
		if ((scrollPos + y) > 0) then
			scrollFrame:SetVerticalScroll(-y);
		elseif (0 > (scrollPos + y - h + frameHeight)) then
			scrollFrame:SetVerticalScroll(-y + h - frameHeight);
		end
	end);
	-- escape handler
	textBox:SetScript("OnEscapePressed", function(frame)
		frame:ClearFocus();
	end);
	-- focus gained handler
	textBox:SetScript("OnEditFocusGained", function(frame)
		DHUD_OptionsTemplates_LUA.focusedTextBox = frame;
		local helpId = help;
		if (helpId ~= "") then
			DHUD_OptionsFrame_LUA:showHelp(DHUDOptionsLocalization[helpId] or (helpId));
		end
	end);
	-- focus lost handler
	textBox:SetScript("OnEditFocusLost", function(frame)
		DHUD_OptionsTemplates_LUA.focusedTextBox = nil;
		DHUD_OptionsFrame_LUA:hideHelp();
		-- update setting
		local text = textBox:GetText();
		DHUDOptions:setSettingValue(setting, text);
		-- update frame
		generalTextBoxFrame:onShow();
	end);
	textBox:SetAutoFocus(false);
	textBox:SetMaxLetters(4096);
	-- update click area handler
	local clickArea = _G[name .. "_Clicker"];
	clickArea:SetScript("OnClick", function(frame)
		textBox:SetFocus();
	end);
	-- update label
	_G[name .. "_Label"]:SetText(DHUDOptionsLocalization[ltext] or ("LTEXT: " .. ltext));
	-- set on show handler
	frame.onShow = function(frame)
		-- read setting value
		local settingValue = DHUDOptions:getSettingValue(frame.setting);
		-- update text
		textBox:SetText(settingValue);
	end;
	frame:SetScript("OnShow", function(frame)
		frame:onShow();
	end);
	-- set tooltip handlers
	frame:SetScript("OnEnter", function(frame)
		GameTooltip:SetOwner(frame, "ANCHOR_RIGHT");
		GameTooltip:SetText(DHUDOptionsLocalization[ltext .. "_TOOLTIP"] or ("LTOOLTIP: " .. ltext), 1, 1, 1, 1);
	end);
	frame:SetScript("OnLeave", function(frame)
		GameTooltip:Hide();
	end);
end