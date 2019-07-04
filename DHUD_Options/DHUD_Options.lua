DHUDO_NUMTABS = 6;
DHUDDROPDOWNSELECTED = "";

--Ace3 Profile Support
local AppName = "DHUDO"
local VERSION = AppName .. "v 1.5.50000f"

local AceConfig = LibStub("AceConfig-3.0")
local AceDBOptions = LibStub("AceDBOptions-3.0")
local ACD = LibStub("AceConfigDialog-3.0")
--local L = LibStub("AceLocale-3.0"):GetLocale("DHUD")
local SML = LibStub:GetLibrary("LibSharedMedia-3.0", true)

local db

local defaults = {
	profile = {
				["dhudsettingloaded"]  = false,
                ["version"]            = DHUD_VERSION,
                ["layouttyp"]          = "DHUD_Standard_Layout",
				["textureset"]		   = 2,

                ["combatalpha"]        = 0.8,
                ["oocalpha"]           = 0,
				["petbattlealpha"]     = 0,
                ["selectalpha"]        = 0.5,
                ["regenalpha"]         = 0.3,
                
                ["scale"]              = 1,              
                ["mmb"]                = {},
				
				["scalecp"]			   = 1,
                
                ["showmmb"]            = 1,
                ["showresticon"]       = 1,
                ["showcombaticon"]     = 1,
                ["showplayerpvpicon"]  = 1,   
                ["showtargetpvpicon"]  = 1,  
                ["showpeticon"]        = 1, 
                ["showeliteicon"]      = 1, 
				["showraidicon"]	   = 1,
				["debufftimer"]		   = 0,
				["dkrunes"]			   = 1,
				["pallyhollypower"]    = 1,
				["warlockshards"]      = 1,
				["priestspheres"]      = 1,
				["storecombos"]        = 1,
				["monkchi"]        	   = 1,
				["playerdebuffs"]	   = 0,
				["playerdebuffscolorize"] = 1,
                ["animatebars"]        = 1,
                ["barborders"]         = 1,
                ["showauras"]          = 1,
                ["showauratips"]       = 1,
                ["showplayerbuffs"]    = 1,
				["showtargetdebuffs"]  = 1,
                ["castingbar"]         = 1,
				["enemycastingbar"]	   = 1,
				["castingbarinfo"]	   = 0,
				["buffswithcharges"]   = 1,
                ["reversecasting"]     = 0,
                ["shownpc"]            = 1,
                ["showtarget"]         = 1,
                ["showtargettarget"]   = 1,
                ["showpet"]            = 1,
                ["btarget"]            = 0,
                ["bplayer"]            = 0,                
                ["bcastingbar"]        = 0,
                ["swaptargetauras"]    = 0,
                                                  
                ["DHUD_Castdelay_Text"]    = "<color>ff0000<casttime_delay></color>",    
                ["DHUD_Casttime_Text"]     = "<color>ffff00<casttime_remain></color>",
				["DHUD_EnemyCastdelay_Text"]    = "<color>ff0000<enemycasttime_delay></color>",    
                ["DHUD_EnemyCasttime_Text"]     = "<color>ffff00<enemycasttime_remain></color>",
				["DHUD_EnemyCB_Text"]     = "<color>ffff00<enemyspellname></color>",
                ["DHUD_PlayerHealth_Text"] = "<color_hp><hp_value></color> <color>999999(</color><hp_percent><color>999999)</color>",
                ["DHUD_PlayerMana_Text"]   = "<color_mp><mp_value></color> <color>999999(</color><mp_percent><color>999999)</color>",
                ["DHUD_TargetHealth_Text"] = "<color_hp><hp_value></color> <color>999999(</color><hp_percent><color>999999)</color>",
                ["DHUD_TargetMana_Text"]   = "<color_mp><mp_value></color> <color>999999(</color><mp_percent><color>999999)</color>",
                ["DHUD_PetHealth_Text"]    = "<color_hp><hp_value></color>",
                ["DHUD_PetMana_Text"]      = "<color_mp><mp_value></color>",
                ["DHUD_Target_Text"]       = "<color_level><level><elite></color> <color_reaction><name></color> [<color_class><class><type><pet><npc></color>] <pvp>",
                ["DHUD_TargetTarget_Text"] = "<color_level><level><elite></color> <color_reaction><name></color> [<color_class><class><type><pet><npc></color>] <pvp>",
				["DHUD_Rune1_Text"]		   = "<color>ffff00<Rune1CD></color>",
				["DHUD_Rune2_Text"]		   = "<color>ffff00<Rune2CD></color>",
				["DHUD_Rune3_Text"]		   = "<color>ffff00<Rune3CD></color>",
				["DHUD_Rune4_Text"]		   = "<color>ffff00<Rune4CD></color>",
				["DHUD_Rune5_Text"]		   = "<color>ffff00<Rune5CD></color>",
				["DHUD_Rune6_Text"]		   = "<color>ffff00<Rune6CD></color>",
                                
                ["playerhpoutline"]     = 1,
                ["playermanaoutline"]   = 1,
                ["targethpoutline"]     = 1,
                ["targetmanaoutline"]   = 1,
                ["pethpoutline"]        = 1,
                ["petmanaoutline"]      = 1,
                ["casttimeoutline"]     = 1,
                ["castdelayoutline"]    = 1,
                ["targetoutline"]       = 1,
                ["targettargetoutline"] = 1,
                
                ["fontsizepet"]        = 9,
                ["fontsizeplayer"]     = 10,
                ["fontsizetarget"]     = 10,	
                ["fontsizetargetname"] = 12,	
                ["fontsizetargettargetname"] = 10,	
                ["fontsizecasttime"]   = 10,
                ["fontsizecastdelay"]  = 10,

                ["xoffset"]            = 0,
                ["yoffset"]            = 0,
                ["hudspacing"]         = 0,
                ["targettextx"]        = 0,
                ["targettexty"]        = 0,
                ["targettargetx"]      = 0,
                ["targettargety"]      = 0,
                ["playerhptextx"]      = 0,
                ["playerhptexty"]      = 0,
                ["playermanatextx"]    = 0,
                ["playermanatexty"]    = 0,
                ["targethptextx"]      = 0,
                ["targethptexty"]      = 0,
                ["targetmanatextx"]    = 0,
                ["targetmanatexty"]    = 0,
                ["pethptextx"]         = 0,
                ["pethptexty"]         = 0,
                ["petmanatextx"]       = 0,
                ["petmanatexty"]       = 0,
                
                
                -- player buffs
                ["playerbufftimefilter"] = 60,
                ["fontsizeplayerbuff"] = 12,
                ["playerbuffoutline"]  = 1,
                
                ["colors"]             = {
                                        aura_player   = { "ffffff", "ffffff", "eeeeee" },
										debuffaura_player   = { "FFFF00", "FFFF00", "FFFF00" },
										debuffmagic   = { "3397ff", "3397ff", "3397ff" },
										debuffcurse   = { "9900ff", "9900ff", "9900ff" },
										debuffdisease = { "996400", "996400", "996400" },
										debuffpoison  = { "009700", "009700", "009700" },
                                        health_player = { "00FF00", "FFFF00", "FF0000" }, --
                                        health_target = { "00aa00", "aaaa00", "aa0000" }, --
                                        health_pet    = { "00FF00", "FFFF00", "FF0000" }, --
                                        mana_player   = { "00FFFF", "0000FF", "FF00FF" }, --
                                        mana_target   = { "00aaaa", "0000aa", "aa00aa" }, --
                                        mana_pet      = { "00FFFF", "0000FF", "FF00FF" }, --
                                        rage_player   = { "FF0000", "FF0000", "FF0000" }, --
                                        rage_target   = { "aa0000", "aa0000", "aa0000" }, --
                                        energy_player = { "FFFF00", "FFFF00", "FFFF00" }, --
                                        energy_target = { "aaaa00", "aaaa00", "aaaa00" }, --
										runic_power_player  = { "004060", "004060", "004060" }, --
										runic_power_target  = { "004060", "004060", "004060" }, --
										focus_player  = { "aa4400", "aa4400", "aa4400" }, --
                                        focus_target  = { "aa4400", "aa4400", "aa4400" }, --
                                        focus_pet     = { "aa4400", "aa4400", "aa4400" }, --
                                        castbar       = { "00FF00", "88FF00", "FFFF00" }, --
                                        channelbar    = { "E0E0FF", "C0C0FF", "A0A0FF" }, --
                                        tapped        = { "cccccc", "bbbbbb", "aaaaaa" }, --
                },
	},
}


DHUDO = LibStub("AceAddon-3.0"):NewAddon(AppName, "AceConsole-3.0", "AceEvent-3.0")
DHUDO:SetDefaultModuleState(false)

function DHUDO:Profiles()
	DHUD:OptionsFrame_Toggle()
	DHUDO:OpenConfigDialog()
end

function DHUDO:LoadDHUDSettingsToDB()
	for k, v in pairs(DHUD_Settings) do
        db[k] = DHUD_Settings[k];
    end
end

function DHUDO:ResetColorSettings()
	for k, v in pairs(defaults.profile["colors"]) do
		DHUD_Settings["colors"][k] = defaults.profile["colors"][k];
		db["colors"][k] = defaults.profile["colors"][k];
	end
end

function DHUDO:SetDBSetting(key,value)
	db[key] = value;
end

function DHUDO:DHUDODBLOAD()
	self.db = LibStub("AceDB-3.0"):New("DHUDODB3", defaults)
	self.db.RegisterCallback(self, "OnProfileChanged")
	self.db.RegisterCallback(self, "OnProfileCopied")
	self.db.RegisterCallback(self, "OnProfileReset")
	db = self.db.profile
	self:addConfigTab('profiles', AceDBOptions:GetOptionsTable(self.db), 20, false)
    AceDBOptions:GetOptionsTable(self.db);
	AceConfig:RegisterOptionsTable(AppName, self.configOptions, "dhudo")
	ACD:AddToBlizOptions(AppName)
	if ( not db.dhudsettingloaded or db.dhudsettingloaded == false ) then
		db.dhudsettingloaded = true
		DHUDO:LoadDHUDSettingsToDB()
	end
	for k, v in pairs(DHUD_Settings["mmb"]) do
        db["mmb"][k] = DHUD_Settings["mmb"][k];
    end
	DHUDO:applySettings()
end

function DHUDO:addConfigTab(key, group, order, isCmdInline)
	if (not self.configOptions) then
		self.configOptions = {
			type = "group",
			name = AppName,
			childGroups = "tab",
			args = {},
		}
	end
	self.configOptions.args[key] = group
	self.configOptions.args[key].order = order
	self.configOptions.args[key].cmdInline = isCmdInline
end

function DHUDO:OpenConfigDialog()
    local f = ACD.OpenFrames[AppName]
    ACD:Open(AppName)
    if not f then
        f = ACD.OpenFrames[AppName]
       -- f:SetWidth(400)
       -- f:SetHeight(600)
    end
end

function DHUDO:OnProfileChanged()
	db = self.db.profile
	if ( not db.dhudsettingloaded or db.dhudsettingloaded == false ) then
		db.dhudsettingloaded = true
		DHUDO:LoadDHUDSettingsToDB()
	end
	DHUDO:applySettings()
end

function DHUDO:OnProfileCopied()
	db = self.db.profile
	if ( not db.dhudsettingloaded or db.dhudsettingloaded == false ) then
		db.dhudsettingloaded = true
		DHUDO:LoadDHUDSettingsToDB()
	end
	DEFAULT_CHAT_FRAME:AddMessage("|cff88ff88DHUD:|r ".."settings copied.")
	DHUDO:applySettings()
end

function DHUDO:OnProfileReset()
	db = self.db.profile
	DHUD:reset()
	db.dhudsettingloaded = true
	DHUDO:LoadDHUDSettingsToDB()
	DHUDO:applySettings()
end

function DHUDO:applySettings()
	--DEFAULT_CHAT_FRAME:AddMessage("Apply Settings called")
	for k, v in pairs(db) do	
		if ( k ~= "dhudsettingloaded" ) then
			--DEFAULT_CHAT_FRAME:AddMessage(k .. " Being copied")
			DHUD_Settings[k] = db[k];
			-- DHUD:SetConfig( k , db[k] );
		end
    end
	DHUD:init();
end


--DHUD Options CODE
function DHUDO_Header_OnLoad(frame, x,y)
    frame.setting_name = string.gsub( frame:GetName() , "DHUD_", "");
    local text = getglobal( frame:GetName().."Text");
    text:SetText( " "..(DHUDO_locale[frame.setting_name] or "["..(frame.setting_name).."]") );
    text:ClearAllPoints();
    text:SetHeight(20);
    text:SetPoint("TOPLEFT", "DHUDOptionsFrame" , "TOPLEFT", x, y);
end

function DHUDO_OnLoad(frame)
	DHUDO:DHUDODBLOAD() --load ACE3 DB Profiles
    table.insert(UISpecialFrames, "DHUDOptionsFrame");
    PanelTemplates_SetNumTabs(frame, DHUDO_NUMTABS);
    PanelTemplates_SetTab(frame, 1);    
end

function DHUDO_DropDown_Initialize(frame)
	local info = {};
	local index;
	
    index = string.gsub( frame:GetName() , "DHUD_Edit_", "");
	index = string.gsub( index , "_Selection", "");
	index = string.gsub( index , "Button", "");
	
	local table = DHUDO_SELECTION[index]["table"];
    for key, text in ipairs(table) do
        info = {};
        info.text = text;
		--DHUD:print("DropDownText: "..text);
        info.func = DHUDO_DropDown_OnClick;
        arg1 = index;
		--arg1 not working, changing it to global variable
		DHUDDROPDOWNSELECTED = index;
		--DHUD:print("DropDownIndex: "..index);
        UIDropDownMenu_AddButton(info);
    end
end

function DHUDO_DropDown_OnClick(frame, list)
	--Can't get list, using global variable
	list = DHUDDROPDOWNSELECTED;
    local sel = getglobal("DHUD_Edit_"..list.."_Selection");
    local box = getglobal("DHUD_Edit_"..list.."ScrollFrameText");
    local text = DHUDO_SELECTION[list]["values"][ frame:GetID() ];
    box:SetText(text);
    UIDropDownMenu_SetSelectedID( sel , frame:GetID() );
    DHUD:SetConfig( list, text );
	db[list] = text ;
    DHUDO_updateTexts(list);
    DHUD:init();
end

function DHUDO_updateTexts(name)
    DHUD:initTextfield(getglobal(name),name);
    DHUD:triggerTextEvent(name);
end
        
function DHUDO_FrameSlider_OnLoad(frame, low, high, step)
    frame.setting_name = string.gsub( frame:GetName() , "DHUD_Slider_", "");
    frame.st = step;
    if frame.nullbase == 1 then
	   getglobal(frame:GetName().."Low"):SetText( (low - low) );
	   getglobal(frame:GetName().."High"):SetText( (high - low));     
	   frame.low = low;  
    else
	   getglobal(frame:GetName().."Low"):SetText(low);
	   getglobal(frame:GetName().."High"):SetText(high);        
    end
	frame:SetMinMaxValues(low, high);
	frame:SetValueStep(frame.st);
end

function DHUDO_FrameSlider_OnShow(frame, key,text)
    getglobal(frame:GetName()):SetValue(DHUD_Settings[key]);
    if frame.nullbase == 1 then
        getglobal(frame:GetName().."Text"):SetText(text.." "..(DHUD_Settings[key] - frame.low ).." ");
    else
        getglobal(frame:GetName().."Text"):SetText(text.." "..DHUD_Settings[key].." ");
    end
end

function DHUDO_FrameSlider_OnValueChanged(frame, key,text)

     local m;
     local value;
     
     if frame.st == nil then
        m = 0;
     end
     
     if frame.st == 10 then
        m = 0.1;
     end
     
     if frame.st == 1 then
        m = 0;
     end
     
     if frame.st == 0.1 then
        m = 10;
     end
     
     if frame.st == 0.01 then
        m = 100;
     end
     
     if frame.st == 0.001 then
        m = 1000;
     end
                    
     if m > 0 then
         value =  math.floor( ( frame:GetValue() + 0.00001) * m ) / m; 
     else
         value =  math.floor( frame:GetValue() ); 
     end
     
	 DHUD:SetConfig( key, value );
	 db[key] = value ;
    if frame.nullbase == 1 then
        getglobal(frame:GetName().."Text"):SetText(text.." "..(DHUD_Settings[key] - frame.low ).." ");
    else
        getglobal(frame:GetName().."Text"):SetText(text.." "..DHUD_Settings[key].." ");
    end
	 DHUD:init();
	 
    if frame.triggertext then
        DHUD:triggerAllTextEvents();
    end
end

function DHUD_RadioButton_OnClick(index)
	DHUD_RADIO_layout1:SetChecked(nil);
	DHUD_RADIO_layout2:SetChecked(nil);
	DHUD_RADIO_layout3:SetChecked(nil);
	DHUD_RADIO_layout4:SetChecked(nil);
	DHUD_RADIO_layout5:SetChecked(nil);
	DHUD_RADIO_layout6:SetChecked(nil);
	if index == 1 then
		DHUD_RADIO_layout1:SetChecked(1);
		db["layouttyp"] = "DHUD_Standard_Layout";
		DHUD:transformFrames("DHUD_Standard_Layout");
	elseif index == 2 then
		DHUD_RADIO_layout2:SetChecked(1);
		db["layouttyp"] = "DHUD_PlayerLeft_Layout";
		DHUD:transformFrames("DHUD_PlayerLeft_Layout");
	elseif index == 3 then
		DHUD_RADIO_layout3:SetChecked(1);
		db["layouttyp"] = "DHUD_StandardMirror_Layout";
		DHUD:transformFrames("DHUD_StandardMirror_Layout");
	elseif index == 4 then
		DHUD_RADIO_layout4:SetChecked(1);
		db["layouttyp"] = "DHUD_PlayerLeftMirror_Layout";
		DHUD:transformFrames("DHUD_PlayerLeftMirror_Layout");
	elseif index == 5 then
		DHUD_RADIO_layout5:SetChecked(1);
		db["layouttyp"] = "DHUD_StandardPTD_Layout";
		DHUD:transformFrames("DHUD_StandardPTD_Layout");
	elseif index == 6 then
		DHUD_RADIO_layout6:SetChecked(1);
		db["layouttyp"] = "DHUD_PlayerLeftPTD_Layout";
		DHUD:transformFrames("DHUD_PlayerLeftPTD_Layout");
	end
end

function DHUD_RadioTextureButton_OnClick(index)
	DHUD_RADIO_texture1:SetChecked(nil);
	DHUD_RADIO_texture2:SetChecked(nil);
	DHUD_RADIO_texture3:SetChecked(nil);
	DHUD_RADIO_texture4:SetChecked(nil);
	DHUD_RADIO_texture5:SetChecked(nil);
	if index == 1 then
		DHUD_RADIO_texture1:SetChecked(1);
	elseif index == 2 then
		DHUD_RADIO_texture2:SetChecked(1);
	elseif index == 3 then
		DHUD_RADIO_texture3:SetChecked(1);
	elseif index == 4 then
		DHUD_RADIO_texture4:SetChecked(1);
	elseif index == 5 then
		DHUD_RADIO_texture5:SetChecked(1);
	end
	DHUD:SetConfig( "textureset", index );
	db["textureset"] = index;
	DHUD:transformFrames(DHUD_Settings["layouttyp"]);
end


function DHUDO_ColorPicker_ColorChanged()
	local r, g, b = ColorPickerFrame:GetColorRGB();

    DHUD_Settings["colors"][ColorPickerFrame.objname][ColorPickerFrame.objindex] = DHUD_DecToHex(r,g,b);
	db["colors"][ColorPickerFrame.objname][ColorPickerFrame.objindex] = DHUD_DecToHex(r,g,b);
    --getglobal(ColorPickerFrame.tohue):SetTexture(r,g,b);
	-- revision13: Copy other colors to options or it will cause an error(hadn't helped)
	--DEFAULT_CHAT_FRAME:AddMessage("objname: ".. ColorPickerFrame.objname .. " objindex: " .. ColorPickerFrame.objindex);
	--if not(ColorPickerFrame.objindex == 1) then
	--	DHUD_Settings["colors"][ColorPickerFrame.objname][1] = DHUD_Settings["colors"][ColorPickerFrame.objname][1];
	--	db["colors"][ColorPickerFrame.objname][1] = DHUD_Settings["colors"][ColorPickerFrame.objname][1];
	--end
	
    DHUDO_changeG(ColorPickerFrame.objname);
    DHUD:init();
end

function DHUDO_ColorPicker_OnClick(frame, boxnumber)

    local name = string.gsub( frame:GetName() , "DHUD_Colorbox_", "");
    name = string.gsub( name , boxnumber, "");
    local Red, Green, Blue = unpack(DHUD_HexToDec(DHUD_Settings["colors"][name][boxnumber]));
    

    ColorPickerFrame.previousValues = {Red, Green, Blue}
    ColorPickerFrame.cancelFunc     = DHUDO_ColorPicker_Cancelled
    ColorPickerFrame.func           = DHUDO_ColorPicker_ColorChanged
    ColorPickerFrame.objname        = name
    ColorPickerFrame.objindex       = boxnumber
    ColorPickerFrame.tohue          = "DHUD_Colorbox_"..name..boxnumber.."Texture";
    ColorPickerFrame.hasOpacity     = false
    ColorPickerFrame:SetColorRGB(Red, Green, Blue)
    ColorPickerFrame:ClearAllPoints()
    local x = DHUDOptionsFrame:GetCenter()
    if (x < UIParent:GetWidth() / 2) then
        ColorPickerFrame:SetPoint("LEFT", "DHUDOptionsFrame", "RIGHT", 0, 0)
    else
        ColorPickerFrame:SetPoint("RIGHT", "DHUDOptionsFrame", "LEFT", 0, 0)
    end

    ColorPickerFrame:Show()
end

function DHUDO_ColorPicker_Cancelled(color)

    local r,g,b = unpack(color);
    DHUD_Settings["colors"][ColorPickerFrame.objname][ColorPickerFrame.objindex] = DHUD_DecToHex(r,g,b);
	db["colors"][ColorPickerFrame.objname][ColorPickerFrame.objindex]  = DHUD_DecToHex(r,g,b);
    --getglobal(ColorPickerFrame.tohue):SetTexture(r,g,b);
    DHUDO_changeG(ColorPickerFrame.objname);
    DHUD:init();
 
end

function DHUDO_changeG(name)
     local Hcolor1 = DHUD_Settings["colors"][name][1];
     local Hcolor2 = DHUD_Settings["colors"][name][2];
     local Hcolor3 = DHUD_Settings["colors"][name][3];
     
     local c1r,c1g,c1b = unpack(DHUD_HexToDec(Hcolor1));
     local c2r,c2g,c2b = unpack(DHUD_HexToDec(Hcolor2));
     local c3r,c3g,c3b = unpack(DHUD_HexToDec(Hcolor3));

     local basename = "DHUD_Colorbox_"..name;
     getglobal(basename.."1Texture"):SetTexture(c1r,c1g,c1b);
     getglobal(basename.."2Texture"):SetTexture(c2r,c2g,c2b);
     getglobal(basename.."3Texture"):SetTexture(c3r,c3g,c3b);

     getglobal(basename.."G1Texture"):SetGradient("HORIZONTAL",c1r,c1g,c1b, c2r,c2g,c2b);
     getglobal(basename.."G2Texture"):SetGradient("HORIZONTAL",c2r,c2g,c2b, c3r,c3g,c3b);
end
