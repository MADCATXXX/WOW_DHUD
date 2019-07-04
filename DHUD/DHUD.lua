--[[-----------------------------------------------------------------------------------
Drathals HUD (c) 2006 by Markus Inger / Drathal / Silberklinge / Silbersegen
DHUD modification for WotLK and Cataclysm by MADCAT
-----------------------------------------------------------------------------------]]--

-- Init Vars --
DHUD_VERSION    = "Version: 1.5.40000f";
DHUD_TEXT_EMPTY = "";
DHUD_TEXT_HP2   = "<color_hp><hp_value></color>";
DHUD_TEXT_HP3   = "<color_hp><hp_value></color>/<hp_max>";
DHUD_TEXT_HP4   = "<color_hp><hp_percent></color>";
DHUD_TEXT_HP5   = "<color_hp><hp_value></color> <color>999999(</color><hp_percent><color>999999)</color>";
DHUD_TEXT_HP6   = "<color_hp><hp_value>/<hp_max></color> <color>999999(</color><hp_percent><color>999999)</color>";
DHUD_TEXT_MP2   = "<color_mp><mp_value></color>";
DHUD_TEXT_MP3   = "<color_mp><mp_value></color>/<mp_max>";
DHUD_TEXT_MP4   = "<color_mp><mp_percent></color>";
DHUD_TEXT_MP5   = "<color_mp><mp_value></color> <color>999999(</color><mp_percent><color>999999)</color>";
DHUD_TEXT_MP6   = "<color_mp><mp_value>/<mp_max></color> <color>999999(</color><mp_percent><color>999999)</color>";
DHUD_TEXT_MP7   = "<color_mp><mp_value_druid></color>";
DHUD_TEXT_TA1   = "<color_level><level><elite></color> <color_reaction><name></color> [<color_class><class><type><pet><npc></color>] <guild> <pvp> <pvp_rank>";
DHUD_TEXT_TA2   = "<color_level><level><elite></color> <color_reaction><name></color> [<color_class><class><type><pet><npc></color>] <pvp>";
DHUD_TEXT_TA3   = "<color_level><level><elite></color> <color_reaction><name></color> <pvp>";
DHUD_TEXT_CT1   = "<color>ffff00<casttime_remain></color>"; 
DHUD_TEXT_CT2   = "<spellname><color>ffff00<casttime_remain></color>"; 
DHUD_TEXT_CD1   = "<color>ff0000<casttime_delay></color>";

DHUD = {
    debug             = nil,
    vars_loaded       = nil,
    enter             = nil,
    issetup           = nil,
    isinit            = nil,
    userID            = nil,
    Casting           = nil,
    inCombat          = nil,
    Attacking         = nil,
    Regen             = nil,
    Target            = nil,
    needMana          = nil,
    needHealth        = nil,
    playerDead        = nil,
    PetneedHealth     = nil,
    PetneedMana       = nil,
    has_target_health = nil,
    has_target_mana   = nil,
    has_pet_health    = nil, 
    has_pet_mana      = nil, 
    player_class      = nil,
    CastingAlpha      = 1,
    update_elapsed    = 0,
    step              = 0.005,
    stepfast          = 0.02,
    -- MADCAT variables
    mcplmaxenergy     = 0,
    mcpetmaxenergy    = 0,
	mcenemycasting	  = nil,
	mcinvehicle		  = nil,
	mctargetcancast	  = nil,
	mcdkrune1		  = 1,
	mcdkrune2		  = 1,
	mcdkrune3		  = 2,
	mcdkrune4		  = 2,
	mcdkrune5		  = 3,
	mcdkrune6		  = 3,
	mccpmoved    = 0,
    -- mcplenergy     = 0,
    --
    playerbufffilter  = "HELPFUL",
    trennzeichen      = "/",
    defaultfont       = "Fonts/FRIZQT__.TTF",  
    --defaultfont_num   = "Fonts/FRIZQT__.TTF",  
    defaultfont_num   = "Interface\\AddOns\\DHUD\\layout\\Number.TTF",  
    
    C_textures    = nil,
    C_frames      = nil,
    C_curLayout   = nil,
    C_tClips      = nil,
    C_names       = nil,

    timer         = 0,
    frame_level   = nil,
            
    -- current mana / health values
    bar_values    = {
                    DHUD_PlayerHealth_Bar  = 1,
                    DHUD_PlayerMana_Bar    = 1,
                    DHUD_TargetHealth_Bar  = 0,
                    DHUD_TargetMana_Bar    = 0,
                    DHUD_PetHealth_Bar     = 0,
                    DHUD_PetMana_Bar       = 0,    
    },

    -- animated mana / health values
    bar_anim      = {
                    DHUD_PlayerHealth_Bar  = 1,
                    DHUD_PlayerMana_Bar    = 1,
                    DHUD_TargetHealth_Bar  = 1,
                    DHUD_TargetMana_Bar    = 1,
                    DHUD_PetHealth_Bar     = 1,
                    DHUD_PetMana_Bar       = 1,       
    },
     
    -- flag for animation             
    bar_change    = {
                    DHUD_PlayerHealth_Bar  = 0,
                    DHUD_PlayerMana_Bar    = 0,
                    DHUD_TargetHealth_Bar  = 0,
                    DHUD_TargetMana_Bar    = 0,
                    DHUD_PetHealth_Bar     = 0,
                    DHUD_PetMana_Bar       = 0,        
    },
    
    -- powertypes
    powertypes    = { "mana", "rage", "focus", "energy", "happiness", "runes", "runic_power" },
                  
    -- font outlines
    Outline       = { "", "OUTLINE", "THICKOUTLINE" },
    
    name2unit     = {
                    DHUD_PlayerHealth_Bar  = "player",
                    DHUD_PlayerMana_Bar    = "player",
                    DHUD_TargetHealth_Bar  = "target",
                    DHUD_TargetMana_Bar    = "target",
                    DHUD_PetHealth_Bar     = "pet",
                    DHUD_PetMana_Bar       = "pet",
                    DHUD_Target_Text       = "target",
                    DHUD_TargetTarget_Text = "targettarget",
                    DHUD_Casttime_Text     = "player",
                    DHUD_Castdelay_Text    = "player",
					DHUD_EnemyCasttime_Text     = "target",
                    DHUD_EnemyCastdelay_Text    = "target",
    },

    name2typ      = {
                    DHUD_PlayerHealth_Bar  = "health",
                    DHUD_PlayerMana_Bar    = "mana",
                    DHUD_TargetHealth_Bar  = "health",
                    DHUD_TargetMana_Bar    = "mana",
                    DHUD_PetHealth_Bar     = "health",
                    DHUD_PetMana_Bar       = "mana",
    },
    
    text2bar    = {
                    DHUD_PlayerHealth_Text = "DHUD_PlayerHealth_Bar",
                    DHUD_PlayerMana_Text   = "DHUD_PlayerMana_Bar",
                    DHUD_TargetHealth_Text = "DHUD_TargetHealth_Bar",
                    DHUD_TargetMana_Text   = "DHUD_TargetMana_Bar",
                    DHUD_PetHealth_Text    = "DHUD_PetHealth_Bar",
                    DHUD_PetMana_Text      = "DHUD_PetMana_Bar",
                    DHUD_Target_Text       = "DHUD_Target_Text",
                    DHUD_TargetTarget_Text = "DHUD_TargetTarget_Text",
    },
    
    -- alphamode textures
    alpha_textures = {
                    "DHUD_LeftFrame_Texture",
                    "DHUD_RightFrame_Texture",
                    "DHUD_PlayerHealth_Bar_Texture",
                    "DHUD_PlayerMana_Bar_Texture",
                    "DHUD_TargetHealth_Bar_Texture",
                    "DHUD_TargetMana_Bar_Texture",
                    "DHUD_PetHealth_Bar_Texture",
                    "DHUD_PetMana_Bar_Texture",
                    "DHUD_PlayerResting",
                    "DHUD_PlayerPvP",
                    "DHUD_Casting_Bar",
					"DHUD_Flash_Bar",
					"DHUD_EnemyCasting_Bar",
                    "DHUD_EnemyFlash_Bar",
					"DHUD_EnemyCB_Texture",
					"DHUD_CB_Texture",
                    "DHUD_TargetElite",
                    "DHUD_PetHappy",
					"DHUD_Rune1",
					"DHUD_Rune2",
					"DHUD_Rune3",
					"DHUD_Rune4",
					"DHUD_Rune5",
					"DHUD_Rune6"
                    -- "DHUD_RaidIcon",
--                    "DHUD_PlayerBuff1",
--                    "DHUD_PlayerBuff2",
--                    "DHUD_PlayerBuff3",
--                    "DHUD_PlayerBuff4",
--                    "DHUD_PlayerBuff5",
--                    "DHUD_PlayerBuff6",
--                    "DHUD_PlayerBuff7",
--                    "DHUD_PlayerBuff8",
--                    "DHUD_PlayerBuff9",
--                    "DHUD_PlayerBuff10",
--                    "DHUD_PlayerBuff11",
--                    "DHUD_PlayerBuff12",
--                    "DHUD_PlayerBuff13",
--                    "DHUD_PlayerBuff14",
--                    "DHUD_PlayerBuff15",
--                    "DHUD_PlayerBuff16",
    },
	
	frames_have_texture_set = { "DHUD_PlayerHealth_Bar", "DHUD_PlayerMana_Bar", "DHUD_TargetHealth_Bar", "DHUD_TargetMana_Bar", "DHUD_PetHealth_Bar", "DHUD_PetMana_Bar"},
                         
    -- reaction Colors
    ReacColors    = { "ff0000","ffff00","55ff55","8888ff","008800","cccccc" }, 
    
    -- prepared Colors
    BarColorTab   = {},
                 
    -- Main Events
    -- WotLK PLAYER_COMBO_POINTS changed to UNIT_COMBO_POINTS, PLAYER_AURAS_CHANGED removed
    -- UNIT_ENERGYMAX, UNIT_MANAMAX, UNIT_FOCUSMAX, UNIT_HEALTHMAX, UNIT_RAGEMAX removed
	-- Cata removed UNIT_MANA, UNIT_ENERGY, UNIT_RAGE, UNIT_RUNIC_POWER, UNIT_FOCUS and UNIT_HAPPINESS
	-- instead "UNIT_POWER",
    mainEvents    = { "UNIT_AURA","UNIT_PET","UNIT_HEALTH",
                      "UNIT_POWER",
                      "UNIT_DISPLAYPOWER","UNIT_RUNE","UNIT_TARGET",
                      "PLAYER_ENTER_COMBAT","PLAYER_LEAVE_COMBAT","PLAYER_REGEN_ENABLED","PLAYER_REGEN_DISABLED",
                      "PLAYER_TARGET_CHANGED","UNIT_COMBO_POINTS","PLAYER_ALIVE","PLAYER_DEAD", "RAID_TARGET_UPDATE",
                      "UNIT_SPELLCAST_CHANNEL_START","UNIT_SPELLCAST_CHANNEL_UPDATE","UNIT_SPELLCAST_DELAYED","UNIT_SPELLCAST_FAILED",
                      "UNIT_SPELLCAST_INTERRUPTED","UNIT_SPELLCAST_START","UNIT_SPELLCAST_STOP","UNIT_SPELLCAST_CHANNEL_STOP",
                      "PLAYER_UPDATE_RESTING","UNIT_PVP_UPDATE","PLAYER_PET_CHANGED","UNIT_PVP_STATUS","PLAYER_UNGHOST",
                      "UNIT_ENTERED_VEHICLE", "UNIT_EXITED_VEHICLE", "VEHICLE_PASSENGERS_CHANGED", "UPDATE_SHAPESHIFT_FORM" --"UPDATE_SHAPESHIFT_FORMS"--, "COMPANION_UPDATE" , "UNIT_ENTERING_VEHICLE"
    },

    -- movable farme
    moveFrame     = {
                    DHUD_Main              = { "xoffset"            , "yoffset"               },
                    DHUD_LeftFrame         = { "hudspacing"         , ""               , "-"  },
                    DHUD_RightFrame        = { "hudspacing"         , ""                      },
                    DHUD_Target_Text       = { ""                   , "targettexty"           },
                    DHUD_TargetTarget_Text = { "targettargettextx"  , "targettargettexty"     },
                    DHUD_PlayerHealth_Text = { "playerhptextx"      , "playerhptexty"         },
                    DHUD_PlayerMana_Text   = { "playermanatextx"    , "playermanatexty"       },
                    DHUD_TargetHealth_Text = { "targethptextx"      , "targethptexty"         },
                    DHUD_TargetMana_Text   = { "targetmanatextx"    , "targetmanatexty"       },
                    DHUD_PetHealth_Text    = { "pethptextx"         , "pethptexty"            },
                    DHUD_PetMana_Text      = { "petmanatextx"       , "petmanatexty"          }, 
                    DHUD_Casttime_Text     = { "casttextx"          , "casttexty"             },
                    DHUD_Castdelay_Text    = { "delaytextx"         , "delaytexty"            },
					DHUD_EnemyCasttime_Text  = { "enemycasttextx"          , "enemycasttexty"    },
                    DHUD_EnemyCastdelay_Text = { "enemydelaytextx"         , "enemydelaytexty"   },
					DHUD_Rune1_Text		   = { "rune1textx"         , "rune1texty"            },
					DHUD_Rune2_Text		   = { "rune2textx"         , "rune2texty"            },
					DHUD_Rune3_Text		   = { "rune3textx"         , "rune3texty"            },
					DHUD_Rune4_Text		   = { "rune4textx"         , "rune4texty"            },
					DHUD_Rune5_Text		   = { "rune5textx"         , "rune5texty"            },
					DHUD_Rune6_Text		   = { "rune6textx"         , "rune6texty"            },
    },
                   
    -- default settings                
    Config_default = {
                ["version"]            = DHUD_VERSION,
                ["layouttyp"]          = "DHUD_Standard_Layout",
				["textureset"]		   = 2,

                ["combatalpha"]        = 0.8,
                ["oocalpha"]           = 0,
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
				["playerdebuffs"]	   = 0,
				["playerdebuffscolorize"] = 1,
                ["animatebars"]        = 1,
                ["barborders"]         = 1,
                ["showauras"]          = 1,
                ["showauratips"]       = 1,
                ["showplayerbuffs"]    = 1,
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
				["DHUD_EnemyCB_Text"]      = "<color>ffff00<enemyspellname></color>",
				["DHUD_CB_Text"]    	   = "<color>ffff00<spellname></color>",
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

-- OnLoad --
function DHUD:OnLoad()
    -- Event
    DHUD_EventFrame:RegisterEvent("VARIABLES_LOADED");
    DHUD_EventFrame:RegisterEvent("PLAYER_ENTERING_WORLD");
    DHUD_EventFrame:RegisterEvent("PLAYER_LEAVING_WORLD");
        
    -- slash handler
    SLASH_DHUD1 = "/dhud";
    SlashCmdList["DHUD"] = function(msg)
        self:SCommandHandler(msg);
    end  
   
    -- addon loaded 
    self:print("Loaded "..self.Config_default["version"]);
end

-- firstload
function DHUD:firstload()
    self:printd("self.vars_loaded: "..(self.vars_loaded or "0") );
    self:printd("self.enter: "..(self.enter or "0") );
    if self.vars_loaded == 1 and self.enter == 1 and self.isinit == nil and self.issetup == nil then
        self:setup();
        self:init();
        return true;
    end
    return false;
end

-- OnEvent --
function DHUD:OnEvent(event, arg1, arg2, arg3)

	-- MADCAT debug
	--if event == "UNIT_ENTERED_VEHICLE" or event == "UNIT_EXITED_VEHICLE" or event == "UNIT_ENTERING_VEHICLE" or event == "VEHICLE_PASSENGERS_CHANGED" or event == "COMPANION_UPDATE" then
	--    if arg1 then
	--	self:print("MainEvent: "..event .. " arg1: " .. arg1);
	--	else
	--		self:print("MainEvent: "..event .. " arg1: nill");
	--	end
	--end
	--if event =="UPDATE_SHAPESHIFT_FORM" or event =="UPDATE_SHAPESHIFT_FORMS" then
	--	if arg1 then
	--		self:print("MainEvent: "..event .. " arg1: " .. arg1);
	--	else
	--		self:print("MainEvent: "..event .. " arg1: nill");
	--	end
	--end
	--self:print("MainEvent: "..event);
	--if (arg1) then
	--	self:print("arg1: "..arg1);
	--end
	
    -- debug
    self:printd("MainEvent: "..event);
	
	-- init HUD
    if event == "VARIABLES_LOADED" then    
        self.vars_loaded = 1;
        self:firstload();
    -- zoning    
    elseif event == "PLAYER_ENTERING_WORLD" then
		self.mcinvehicle = 0;
        self.enter = 1;
        if self:firstload() then return; end       
        if self.issetup ~= 2 then return; end
        if self.isinit  ~= 2 then return; end
        self:init();
		self:UpdateValues("DHUD_PlayerHealth_Text");
		self:triggerTextEvent("DHUD_PlayerHealth_Text");
		
	
	--Vehicle support
	elseif event == "UNIT_ENTERED_VEHICLE" then
		if arg1 == "player" then
			--self:print("MainEvent: "..event);
			local hasUI = UnitHasVehicleUI("player")
			if hasUI then
				self.mcinvehicle = 1;
			else
				self.mcinvehicle = 0;
			end			
			self:UpdateValues("DHUD_PetHealth_Text");
		end
	elseif event == "UNIT_EXITED_VEHICLE" then
		if arg1 == "player" then
			--self:print("MainEvent: "..event);
			self.mcinvehicle = 0;
			if DHUD_Settings["animatebars"] == 1 then
				DHUD_Settings["animatebars"] = 0;
				self:UpdateValues("DHUD_PlayerHealth_Text");
				self:UpdateValues("DHUD_PlayerMana_Text");
				self:UpdateValues("DHUD_PetHealth_Text");
				self:UpdateValues("DHUD_PetMana_Text");			
				DHUD_Settings["animatebars"] = 1;
			else
				self:UpdateValues("DHUD_PlayerHealth_Text");
			end
			
			local text = _G["DHUD_PetHealth_Text"].text;
			local font = _G["DHUD_PetHealth_Text".."_Text"];
			text = DHUD:gsub(text, '<color_hp>', "|cffffffff" );
            text = DHUD:gsub(text, '<hp_value>', "");
		    text = DHUD:gsub(text, '</color>', '|r');
		    text = DHUD:gsub(text, '<color>', '|cff');
		    text = DHUD:gsub(text, '<hp_percent>', "");
			text = DHUD:gsub(text, '<hp_max>', "");	
			font:SetText(text);
		end
	elseif event == "VEHICLE_PASSENGERS_CHANGED" then
		local hasUI = UnitHasVehicleUI("player")
		if hasUI then
			self.mcinvehicle = 1;
		else
			self.mcinvehicle = 0;
			if DHUD_Settings["animatebars"] == 1 then
				DHUD_Settings["animatebars"] = 0;
				self:UpdateValues("DHUD_PlayerHealth_Text");
				self:UpdateValues("DHUD_PlayerMana_Text");
				self:UpdateValues("DHUD_PetHealth_Text");
				self:UpdateValues("DHUD_PetMana_Text");			
				DHUD_Settings["animatebars"] = 1;
			else
				self:UpdateValues("DHUD_PlayerHealth_Text");
			end
			self:triggerTextEvent("DHUD_PlayerHealth_Text");
			
			local text = _G["DHUD_PetHealth_Text"].text;
			local font = _G["DHUD_PetHealth_Text".."_Text"];
			text = DHUD:gsub(text, '<color_hp>', "|cffffffff" );
            text = DHUD:gsub(text, '<hp_value>', "");
		    text = DHUD:gsub(text, '</color>', '|r');
		    text = DHUD:gsub(text, '<color>', '|cff');
		    text = DHUD:gsub(text, '<hp_percent>', "");
			text = DHUD:gsub(text, '<hp_max>', "");	
			font:SetText(text);
		end			
		self:UpdateValues("DHUD_PetHealth_Text");
	
	
    -- update HEALTH Bars, UNIT_HEALTHMAX removed  
    elseif ( event == "UNIT_HEALTH" ) then
        if arg1 == "player" then
            self:UpdateValues("DHUD_PlayerHealth_Text");
        elseif arg1 == "target" then
            self:UpdateValues("DHUD_TargetHealth_Text");
        elseif arg1 == "pet" then
            self:UpdateValues("DHUD_PetHealth_Text");
        end
		--do not update alpha if cast complete
        if not(_G["DHUD_EnemyCasting_Bar"].enemyfadeOut) and not(_G["DHUD_Casting_Bar"].fadeOut) then
			self:updateAlpha();
		end
    -- update MANA Bars, UNIT_ENERGYMAX, UNIT_MANAMAX, UNIT_FOCUSMAX, UNIT_RAGEMAX   removed
    elseif ( event == "UNIT_POWER" or event == "UNIT_DISPLAYPOWER") then
        if arg1 == "player" then
            --self:UpdateValues("DHUD_PlayerMana_Text");
            self.mcplmaxenergy = UnitPowerMax("player");
			
			
		-- mcplenergy = UnitPower("player");
        elseif arg1 == "target" then
            self:UpdateValues("DHUD_TargetMana_Text");
		--if (event == "UNIT_RUNIC_POWER" ) then
			--self:triggerTextEvent("DHUD_TargetMana_Text");
		--end
        elseif arg1 == "pet" then
            --self:UpdateValues("DHUD_PetMana_Text");
			self.mcpetmaxenergy = UnitPowerMax("pet");
        end
   
        -- Druidbar support
        if self.player_class == "DRUID" then
            self:UpdateValues("DHUD_PetMana_Text");
            self:triggerTextEvent("DHUD_PlayerMana_Text");
            self:triggerTextEvent("DHUD_PetMana_Text");
        end
		
        --do not update alpha if cast complete
		if not(_G["DHUD_EnemyCasting_Bar"].enemyfadeOut) and not(_G["DHUD_Casting_Bar"].fadeOut) then
			self:updateAlpha();
		end
    -- update self Auras
    -- elseif event == "PLAYER_AURAS_CHANGED" then
    elseif (event == "UNIT_AURA" and arg1 == "player") then
        self:triggerTextEvent("DHUD_PlayerMana_Text");
        self:triggerTextEvent("DHUD_PetMana_Text");
        self:UpdateValues("DHUD_PlayerMana_Text");
        self:UpdateValues("DHUD_PlayerHealth_Text");
        self:UpdateValues("DHUD_PetMana_Text");
        self:ChangeBackgroundTexture();
		--do not update alpha if cast complete
		if not(_G["DHUD_EnemyCasting_Bar"].enemyfadeOut) and not(_G["DHUD_Casting_Bar"].fadeOut) then
			self:updateAlpha();
		end
        self:PlayerAuras();
    -- target changed   
    elseif event == "PLAYER_TARGET_CHANGED" then  
        self:TargetChanged();
		
    --update texture after shapeshift anc  HUD color
	elseif event =="UPDATE_SHAPESHIFT_FORM" then
		mcplenergy = UnitPower("player");
		self.mcplmaxenergy = UnitPowerMax("player");
		local value = tonumber(mcplenergy/self.mcplmaxenergy);
		local typunit = DHUD:getTypUnit("player","mana");
		local color = DHUD_DecToHex(DHUD:Colorize(typunit,value));
		local bar  = self.text2bar["DHUD_PlayerMana_Text"];
		self:SetBarColor(bar,value);
    	self:ChangeBackgroundTexture();	
		
	-- update target Auras
    elseif (event == "UNIT_AURA" and arg1 == "target") then
        self:TargetAuras();
    -- update Combopoints
    elseif event == "UNIT_COMBO_POINTS" then
        self:UpdateCombos();
    -- Combat / Regen / Attack check
    elseif event == "PLAYER_ENTER_COMBAT" then
        self.Attacking = true;
        self.inCombat  = true;
        self:updateAlpha();
    elseif event == "PLAYER_LEAVE_COMBAT" then
        self.Attacking = nil;
        if (self.Regen) then self.inCombat = nil; end
        self:updateAlpha();
    elseif event == "PLAYER_REGEN_ENABLED" then
        self.Regen = true;
        --if (not self.Attacking) then self.inCombat = nil; end
        self.inCombat = nil;
        self:updateAlpha();
        self:updateStatus();
    elseif event == "PLAYER_REGEN_DISABLED" then
        self.Regen    = nil;
        self.inCombat = true;
        self:updateAlpha();
        self:updateStatus();
    -- Update background
    elseif (event == "PLAYER_ALIVE" or event =="PLAYER_DEAD" or event =="PLAYER_UNGHOST") then
        self:UpdateValues("DHUD_PlayerHealth_Text" , 1 );
        self:UpdateValues("DHUD_PlayerMana_Text", 1 );
        self:ChangeBackgroundTexture();
        self:updateAlpha();
    -- player resting
    elseif event == "PLAYER_UPDATE_RESTING" then
        self:updateStatus();
    -- raid icon
    elseif event == "RAID_TARGET_UPDATE" then
        self:updateRaidIcon();
    -- player pvp
    elseif event == "UNIT_PVP_STATUS" or event == "UNIT_PVP_UPDATE" then
        self:updatePlayerPvP();
        self:updateTargetPvP();
    elseif event == "UNIT_PET" or event == "PLAYER_PET_CHANGED"then
        self:UpdateValues("DHUD_PetHealth_Text", 1 );
        self:UpdateValues("DHUD_PetMana_Text", 1 );
        self:ChangeBackgroundTexture();
        self:updatePetIcon();
        self:updateAlpha();
    elseif event == "UNIT_POWER" and arg1 == "pet" then
        self:updatePetIcon();
	end
	
    if self.issetup ~= 2 then return; end
    if self.isinit  ~= 2 then return; end
    
    -- castbar events
    if DHUD_Settings["castingbar"] == 1 then
		local frame = _G["DHUD_Casting_Bar"];
        -- start spellcast
        if (event == "UNIT_SPELLCAST_START") and (arg1 == "player") then
            spell, rank, displayName, icon, startTime, endTime, isTradeSkill = UnitCastingInfo(arg1);
			
            self.spellname  = spell;
            frame.startTime  = startTime / 1000;
            frame.maxValue   = endTime / 1000;
            frame.holdTime   = 0;
            frame.casting    = 1;
            frame.delay      = 0;
            frame.channeling = nil;
            frame.fadeOut    = nil;
            frame.flash      = nil;
            frame.duration   = floor( ( endTime - startTime ) / 100 ) / 10;
            self.Casting    = true;
            self:updateAlpha();
            DHUD_Casttime_Text:SetAlpha(1);
            DHUD_Castdelay_Text:SetAlpha(1);
            DHUD_Casting_Bar:Show();
            DHUD_Flash_Bar:Hide();
			
			--Spell Name and Texture
			if DHUD_Settings["castingbarinfo"] == 1 then
				local casticon = _G["DHUD_CB_Texture_Texture"];
	            casticon:SetTexture( icon );
				_G["DHUD_CB_Texture"]:Show();
				DHUD_CB_Text:SetAlpha(1);
				self:triggerTextEvent("DHUD_CB_Text");
			end
        -- stop 
        elseif ( event == "UNIT_SPELLCAST_STOP" or event == "UNIT_SPELLCAST_CHANNEL_STOP") and (arg1 == "player") then
            if (not DHUD_Casting_Bar:IsVisible()) then
                DHUD_Casting_Bar:Hide();
            end
            if (DHUD_Casting_Bar:IsShown()) then
                if ( event == "UNIT_SPELLCAST_STOP" and frame.casting ) then
                    frame.casting    = nil;
                    frame.channeling = nil;
                    frame.flash      = 1;
                    frame.fadeOut    = 1;
                    DHUD_Casting_Bar_Texture:SetVertexColor(0, 1, 0);
                    self:SetBarHeight("DHUD_Casting_Bar",1);
                    DHUD_Flash_Bar:SetAlpha(0);
                    DHUD_Flash_Bar:Show();
                  elseif  ( event == "UNIT_SPELLCAST_CHANNEL_STOP" and frame.channeling ) then
                    frame.casting    = nil;
                    frame.channeling = nil;
                    frame.flash      = nil;
                    frame.fadeOut    = 1;
                    self.Casting    = nil;
                    self:updateAlpha();
                    self:SetBarHeight("DHUD_Casting_Bar",0);
                end
				--[[Spell Name and Texture
				if DHUD_Settings["castingbarinfo"] == 1 then
					self.spellname = "|cffff0000Interrupted|r";
					self:triggerTextEvent("DHUD_CB_Text");
				end]]--
            end
        -- failed
        elseif (event == "UNIT_SPELLCAST_FAILED" or event == "UNIT_SPELLCAST_INTERRUPTED") and (arg1 == "player") then
            if (DHUD_Casting_Bar:IsShown() and not frame.fadeOut ) then
                DHUD_Casting_Bar_Texture:SetVertexColor(1, 0, 0);
                self:SetBarHeight("DHUD_Casting_Bar",1);
                frame.casting    = nil;
                frame.channeling = nil;
                frame.fadeOut    = 1;
                frame.flash      = nil;
                frame.holdTime = GetTime() + CASTING_BAR_HOLD_TIME;
                DHUD_Flash_Bar:Hide();
                DHUD_Flash_Bar:SetAlpha(0);
				--Spell Name and Texture
				if DHUD_Settings["castingbarinfo"] == 1 then
					self.spellname = "|cffff0000Interrupted|r";
					self:triggerTextEvent("DHUD_CB_Text");
				end
            end
        -- delayed
        elseif (event == "UNIT_SPELLCAST_DELAYED") and (arg1 == "player") then
            if(DHUD_Casting_Bar:IsShown()) then
                spell, rank, displayName, icon, startTime, endTime, isTradeSkill = UnitCastingInfo(arg1);
                if endTime then
					delay = endTime / 1000 - frame.maxValue;
				else
					delay = 0;
				end
                frame.startTime = frame.startTime + delay;
                frame.maxValue  = frame.maxValue + delay;
                frame.delay     = frame.delay + delay;
                
                local time = GetTime();
				--fixes attempt to work with nil value endtime
				if (not frame.endTime) then
					frame.endTime=time
				end
				
                if (time > frame.endTime) then
                    time = frame.endTime
                end
            end		
        -- channel start
        elseif (event == "UNIT_SPELLCAST_CHANNEL_START") and (arg1 == "player") then
            spell, rank, displayName, icon, startTime, endTime, isTradeSkill = UnitChannelInfo(arg1);
            self.spellname  = spell;
            frame.maxValue   = 1;
            frame.startTime  = startTime / 1000;
            frame.endTime    = endTime / 1000;
            frame.duration   = string.format( "%.1f", (endTime - startTime) / 1000);
            frame.holdTime   = 0;
            frame.casting    = nil;
            frame.channeling = 1;
            frame.flash      = nil;
            frame.fadeOut    = nil;
            frame.delay      = 0;
            self.Casting    = true;
            self:SetBarHeight("DHUD_Casting_Bar",1);
            DHUD_Casting_Bar_Texture:SetVertexColor(self:Colorize("channelbar",0));
            self:updateAlpha();
            DHUD_Casttime_Text:SetAlpha(1);
            DHUD_Castdelay_Text:SetAlpha(1);
            DHUD_Casting_Bar:Show();
            DHUD_Flash_Bar:Hide();
        -- channel update
        elseif (event == "UNIT_SPELLCAST_CHANNEL_UPDATE") and (arg1 == "player") then
            if arg1 == 0 then
                frame.channeling = nil;
            elseif (DHUD_Casting_Bar:IsShown()) then
                spell, rank, displayName, icon, startTime, endTime, isTradeSkill = UnitCastingInfo(arg1);
                local origDuration = frame.endTime - frame.startTime
                local elapsedTime = GetTime() - frame.startTime;
--                frame.delay = (origDuration - elapsedTime) - (arg1/1000);
--                frame.endTime = GetTime() + (arg1 / 1000);
                -- hack
                if endTime == nil then
                    endTime = 0;
                end
                frame.endTime = endTime / 1000;
                frame.delay = frame.endTime - frame.startTime + (endTime / 1000);
            end
        end
	
   end
	-- MADCAT Enemy castbar events
    if DHUD_Settings["enemycastingbar"] == 1 then
		local frame = _G["DHUD_EnemyCasting_Bar"];
        --self:print("MainEvent: "..event);
		-- start spellcast
		if (event == "UNIT_SPELLCAST_START") and (arg1 == "target") then
            enemyspell, enemyrank, enemydisplayName, enemyicon, enemystartTime, enemyendTime, enemyisTradeSkill = UnitCastingInfo(arg1);
            self.enemyspellname  = enemyspell;
            frame.enemystartTime  = enemystartTime / 1000;
            frame.enemymaxValue   = enemyendTime / 1000;
            frame.enemyholdTime   = 0;
            frame.enemycasting    = 1;
            frame.enemydelay      = 0;
            frame.enemychanneling = nil;
            frame.enemyfadeOut    = nil;
            frame.enemyflash      = nil;
            frame.enemyduration   = floor( ( enemyendTime - enemystartTime ) / 100 ) / 10;
            self.mcenemycasting    = true;
            self:updateAlpha();
            DHUD_EnemyCasttime_Text:SetAlpha(1);
            DHUD_EnemyCastdelay_Text:SetAlpha(1);
            DHUD_EnemyCasting_Bar:Show();
            DHUD_EnemyFlash_Bar:Hide();
			
			
			--local texture,x0,x1,y0,y1 = unpack( self.C_textures["DHUD_PetUnhappy"] );
			--local tex = _G["DHUD_EnemyCB_Texture"];
            --tex:SetTexture(texture);
            --tex:SetTexCoord(-20,290,30,30);	
			--icon:SetNormalTexture(enemyicon);
			--self.enemyspellname = string.format( "%.1s", enemyspell );
			--_G["DHUD_EnemyCB_Texture"]:Show();
			--icon:SetTexture( "Interface\\Icons\\Ability_Druid_TravelForm" , "Interface\\Icons\\Ability_Druid_TravelForm" );
			--icon = _G["DHUD_EnemyCB_Texture_Texture"];
			--icon:SetTexCoord(10,10,10,10);
			
			--Enemy Spell Name and Texture
			local ecasticon = _G["DHUD_EnemyCB_Texture_Texture"];
            ecasticon:SetTexture( enemyicon );
			_G["DHUD_EnemyCB_Texture"]:Show();
			DHUD_EnemyCB_Text:SetAlpha(1);
			self:triggerTextEvent("DHUD_EnemyCB_Text");
			--Show texture under cast bar if target has no mana
			self.mctargetcancast=1;
			self:ChangeBackgroundTexture(); 
        -- stop 
        elseif ( event == "UNIT_SPELLCAST_STOP" or event == "UNIT_SPELLCAST_CHANNEL_STOP") and (arg1 == "target") then
            if (not DHUD_EnemyCasting_Bar:IsVisible()) then
                DHUD_EnemyCasting_Bar:Hide();
            end
            if (DHUD_EnemyCasting_Bar:IsShown()) then
                if ( event == "UNIT_SPELLCAST_STOP" and frame.enemycasting ) then
                    frame.enemycasting    = nil;
                    frame.enemychanneling = nil;
                    frame.enemyflash      = 1;
                    frame.enemyfadeOut    = 1;
                    DHUD_EnemyCasting_Bar_Texture:SetVertexColor(0, 1, 0);
                    self:SetBarHeight("DHUD_EnemyCasting_Bar",1);
                    DHUD_EnemyFlash_Bar:SetAlpha(0);
                    DHUD_EnemyFlash_Bar:Show();
                  elseif  ( event == "UNIT_SPELLCAST_CHANNEL_STOP" and frame.enemychanneling ) then
                    frame.enemycasting    = nil;
                    frame.enemychanneling = nil;
                    frame.enemyflash      = nil;
                    frame.enemyfadeOut    = 1;
                    self.mcenemycasting    = nil;
                    self:updateAlpha();
                    self:SetBarHeight("DHUD_EnemyCasting_Bar",0);
                end
				--Hide enemy spell info
				--self.enemyspellname = nil;
				--self:triggerTextEvent("DHUD_EnemyCB_Text");
				--_G["DHUD_EnemyCB_Texture"]:Hide();
				--Change enemy spellname text to interrupted
				--self.enemyspellname = "|cffff0000Interrupted|r";
				--self:triggerTextEvent("DHUD_EnemyCB_Text");
            end
        -- failed
        elseif (event == "UNIT_SPELLCAST_FAILED" or event == "UNIT_SPELLCAST_INTERRUPTED") and (arg1 == "target") then
            if (DHUD_EnemyCasting_Bar:IsShown() and not frame.enemyfadeOut ) then
                DHUD_EnemyCasting_Bar_Texture:SetVertexColor(1, 0, 0);
                self:SetBarHeight("DHUD_EnemyCasting_Bar",1);
                frame.enemycasting    = nil;
                frame.enemychanneling = nil;
                frame.enemyfadeOut    = 1;
                frame.enemyflash      = nil;
                frame.enemyholdTime = GetTime() + CASTING_BAR_HOLD_TIME;
                DHUD_EnemyFlash_Bar:Hide();
                DHUD_EnemyFlash_Bar:SetAlpha(0);
				--Change enemy spellname text to interrupted
				self.enemyspellname = "|cffff0000Interrupted|r";
				self:triggerTextEvent("DHUD_EnemyCB_Text");
            end
        -- delayed
        elseif (event == "UNIT_SPELLCAST_DELAYED") and (arg1 == "target") then
			--self:print("MainEvent: "..event);
            if(DHUD_EnemyCasting_Bar:IsShown()) then
                enemyspell, enemyrank, enemydisplayName, enemyicon, enemystartTime, enemyendTime, enemyisTradeSkill = UnitCastingInfo(arg1);
                enemydelay = enemyendTime / 1000 - frame.enemymaxValue;
                frame.enemystartTime = frame.enemystartTime + enemydelay;
                frame.enemymaxValue  = frame.enemymaxValue + enemydelay;
                frame.enemydelay     = frame.enemydelay + enemydelay;
                
                local time = GetTime();
				--fixes attempt to work with nil value enemyendtime
				if (not frame.enemyendTime) then
					frame.enemyendTime=time
				end
				
                if (time > frame.enemyendTime) then
                    time = frame.enemyendTime
                end
            end		
        -- channel start
        elseif (event == "UNIT_SPELLCAST_CHANNEL_START") and (arg1 == "target") then
            enemyspell, enemyrank, enemydisplayName, enemyicon, enemystartTime, enemyendTime, enemyisTradeSkill = UnitChannelInfo(arg1);
            self.enemyspellname  = enemyspell;
            frame.enemymaxValue   = 1;
            frame.enemystartTime  = enemystartTime / 1000;
            frame.enemyendTime    = enemyendTime / 1000;
            frame.enemyduration   = string.format( "%.1f", (enemyendTime - enemystartTime) / 1000);
            frame.enemyholdTime   = 0;
            frame.enemycasting    = nil;
            frame.enemychanneling = 1;
            frame.enemyflash      = nil;
            frame.enemyfadeOut    = nil;
            frame.enemydelay      = 0;
            self.enemyCasting    = true;
            self:SetBarHeight("DHUD_EnemyCasting_Bar",1);
            DHUD_EnemyCasting_Bar_Texture:SetVertexColor(self:Colorize("channelbar",0));
            self:updateAlpha();
            DHUD_EnemyCasttime_Text:SetAlpha(1);
            DHUD_EnemyCastdelay_Text:SetAlpha(1);
            DHUD_EnemyCasting_Bar:Show();
            DHUD_EnemyFlash_Bar:Hide();
			
			--Enemy Spell Name and Texture
			local ecasticon = _G["DHUD_EnemyCB_Texture_Texture"];
            ecasticon:SetTexture( enemyicon );
			_G["DHUD_EnemyCB_Texture"]:Show();
			DHUD_EnemyCB_Text:SetAlpha(1);
			self:triggerTextEvent("DHUD_EnemyCB_Text");
			
			--Show texture under cast bar if target has no mana
			self.mctargetcancast=1;
			self:ChangeBackgroundTexture(); 
        -- channel update
        elseif (event == "UNIT_SPELLCAST_CHANNEL_UPDATE") and (arg1 == "target") then
            if arg1 == 0 then
                frame.enemychanneling = nil;
            elseif (DHUD_EnemyCasting_Bar:IsShown()) then
                enemyspell, enemyrank, enemydisplayName, enemyicon, enemystartTime, enemyendTime, enemyisTradeSkill = UnitCastingInfo(arg1);
                local origDuration = frame.enemyendTime - frame.enemystartTime
                local elapsedTime = GetTime() - frame.enemystartTime;
--                frame.delay = (origDuration - elapsedTime) - (arg1/1000);
--                frame.endTime = GetTime() + (arg1 / 1000);
                -- hack
                if enemyendTime == nil then
                    enemyendTime = 0;
                end
                frame.enemyendTime = enemyendTime / 1000;
                frame.enemydelay = frame.enemyendTime - frame.enemystartTime + (enemyendTime / 1000);
            end
        end
	end
end

-- init textfield
function DHUD:initTextfield(ref,name)
    if DHUD_Settings[name] ~= nil then
        local bar = self.text2bar[name];
        ref.vars = {};
        ref:UnregisterAllEvents();
        ref.text = DHUD_Settings[name] or "";
        ref.unit = self.name2unit[bar];
        if ref.unit == nil then
            ref.unit = "player";
        end
        for var, value in pairs(DHUD_variables) do
            if (string.find(ref.text, var)) then
                ref.vars[var] = true;
                for _,event in pairs(value.events) do
                    ref:RegisterEvent(event);		
                end			
            end
        end
        ref:RegisterEvent("PLAYER_ENTERING_WORLD");
        if ref.unit == "target" then
            ref:RegisterEvent("PLAYER_TARGET_CHANGED");
        elseif ref.unit == "targettarget" then
            ref:RegisterEvent("UNIT_TARGET");
        elseif ref.unit == "pet" then
            ref:RegisterEvent("UNIT_PET");
            ref:RegisterEvent("PLAYER_PET_CHANGED");
        end
        ref:SetScript("OnEvent", function(frame, event, arg1, arg2, arg3) DHUD:TextOnEvent(frame, event, arg1, arg2, arg3); end);
    end
end

-- events for vars
function DHUD:TextOnEvent(frame, event, arg1, arg2, arg3)
    if frame.unit == arg1 or 
        event == "PLAYER_ENTERING_WORLD" or  
        --( event == "PLAYER_TARGET_CHANGED" and frame.unit == "target" ) or 
        ( event == "PLAYER_TARGET_CHANGED" and frame.unit == "target" ) or 
        ( event == "UNIT_TARGET" ) or
        ( (event == "UNIT_PET" or event == "PLAYER_PET_CHANGED") and frame.unit == "pet" ) then 
        self:doText( frame:GetName() );    
    end
    
--    if frame.unit == arg1 and event == "UNIT_TARGET" then
--        self:doText( "DHUD_TargetTarget_Text" );
--    end
end

-- set Textbox
function DHUD:doText(name)
    local font = _G[name.."_Text"];
	local frame = _G[name];

    -- hide npc / target / pet ?
    if frame.unit == "target" and DHUD_Settings["shownpc"] == 0 and self:TargetIsNPC() then 
        font:SetText(" ");
        return; 
    end
    if frame.unit == "target" and DHUD_Settings["showtarget"] == 0 then 
        font:SetText(" ");
        return; 
    end
    if frame.unit == "pet" and DHUD_Settings["showpet"] == 0 then 
        font:SetText(" ");
        return; 
    end
    if frame.unit == "targettarget" and DHUD_Settings["shownpc"] == 0 and self:TargetIsNPC() then
        font:SetText(" ");
        return;
    end
    if frame.unit == "targettarget" and DHUD_Settings["showtargettarget"] == 0 then
        font:SetText(" ");
        return;
    end
    if frame.unit == "targettarget" and UnitExists("targettarget") == nil then
        font:SetText(" ");
        return;
    end
    
    local text  = frame.text;
    local htext = frame.text;
    for var, bol in pairs(frame.vars) do
        text  = DHUD_variables[var].func(text,frame.unit);
        htext = self:gsub(htext, var, DHUD_variables[var].hideval);
    end

    if text == htext then
        font:SetText(" ");
    else
        text = string.gsub(text, "  "," ");
        text = string.gsub(text,"(^%s+)","");
        text = string.gsub(text,"(%s+$)","");
        font:SetText(text);
    end

    font:SetWidth(1000);
    local frame = _G[name];
    local w = font:GetStringWidth() + 10;
    font:SetWidth(w);
    frame:SetWidth(w); 
end
                    
-- trigger all textevents
function DHUD:triggerAllTextEvents()
    self:triggerTextEvent("DHUD_Target_Text");
    self:triggerTextEvent("DHUD_TargetTarget_Text");
    self:triggerTextEvent("DHUD_PlayerHealth_Text");
    self:triggerTextEvent("DHUD_PlayerMana_Text");
    self:triggerTextEvent("DHUD_TargetHealth_Text");
    self:triggerTextEvent("DHUD_TargetMana_Text");
    self:triggerTextEvent("DHUD_PetHealth_Text");
    self:triggerTextEvent("DHUD_PetMana_Text");
    self:triggerTextEvent("DHUD_Castdelay_Text");
    self:triggerTextEvent("DHUD_Casttime_Text");
end

-- fake text event
function DHUD:triggerTextEvent(p)
    --frame.unit = _G[p].unit;
    --frame.vars = _G[p].vars;
    --frame.text = _G[p].text;
    self:doText(p);
end

-- OnUpdate --
function DHUD:OnUpdate(elapsed)    
    
	-- update speed
    self.update_elapsed = self.update_elapsed + elapsed;
    if self.update_elapsed < 0.3 then
        self.update_elapsed = 0;
        return;
    end

    if self.issetup ~= 2 then return; end
    if self.isinit  ~= 2 then return; end
                
    -- animate bars
    if DHUD_Settings["animatebars"] == 1 then
        self:Animate("DHUD_PlayerHealth_Bar");
        self:Animate("DHUD_PlayerMana_Bar");
        if DHUD_Settings["showtarget"] == 1 then
            self:Animate("DHUD_TargetHealth_Bar");
            self:Animate("DHUD_TargetMana_Bar");
        end
        if DHUD_Settings["showpet"] == 1 then
            self:Animate("DHUD_PetHealth_Bar");
            self:Animate("DHUD_PetMana_Bar");
        end
        if self.player_class == "DRUID" and UnitPowerType("player") ~= 0 then
            self:Animate("DHUD_PetMana_Bar");
        end
    end

	
	-- castingbar
    if DHUD_Settings["castingbar"] == 1 then
		local frame = _G["DHUD_Casting_Bar"];
        -- casting
        if frame.casting then
            local time = GetTime();
            if (time > frame.maxValue) then
                time = frame.maxValue
            end
            
            DHUD_Flash_Bar:Hide();
            local v = (time - frame.startTime) / (frame.maxValue - frame.startTime);
            
            if DHUD_Settings["reversecasting"] == 1 then
                self:SetBarHeight("DHUD_Casting_Bar", 1-v );
                DHUD_Casting_Bar_Texture:SetVertexColor(self:Colorize("castbar",v));    
            else
                self:SetBarHeight("DHUD_Casting_Bar", v );
                DHUD_Casting_Bar_Texture:SetVertexColor(self:Colorize("castbar",v));       
            end
            
            self.casting_time_del = string.format( "-%.1f", frame.delay );
            self.casting_time_rev = string.format( "%.1f", frame.maxValue - time );
            self.casting_time     = string.format( "%.1f", (time + frame.delay) - frame.startTime );
            self:triggerTextEvent("DHUD_Casttime_Text");
            self:triggerTextEvent("DHUD_Castdelay_Text");
                        
        -- channeling
        elseif frame.channeling then
            local time = GetTime();
            if (time > frame.endTime) then
                time = frame.endTime
            end
            
            local barValue = frame.startTime + (frame.endTime - time);
            local sparkPosition = (barValue - frame.startTime) / (frame.endTime - frame.startTime);
            DHUD_Flash_Bar:Hide();
            
            self:SetBarHeight("DHUD_Casting_Bar", sparkPosition );
            DHUD_Casting_Bar_Texture:SetVertexColor(self:Colorize("channelbar",(barValue - frame.startTime) / (frame.endTime - frame.startTime)));

            self.casting_time_del = string.format( "+%.1f", frame.delay );
            self.casting_time     = string.format( " %.1f", (time + frame.delay) - frame.startTime );
            self.casting_time_rev = string.format( "%.1f", frame.duration -((time + frame.delay) - frame.startTime) );
            self:triggerTextEvent("DHUD_Casttime_Text");
            self:triggerTextEvent("DHUD_Castdelay_Text");
            
            if (time == frame.endTime) then
                frame.channeling = nil;
                frame.casting    = nil;
                frame.fadeOut    = 1;
                frame.flash      = nil;
                self.Casting    = nil;  
                self:SetBarHeight("DHUD_Casting_Bar", 0 );
                self:updateAlpha();
            end
        -- hold
        elseif frame.holdTime and GetTime() < frame.holdTime then
    
        -- flash
        elseif frame.flash then
            local alpha = DHUD_Flash_Bar:GetAlpha() + CASTING_BAR_FLASH_STEP;
            if alpha < 1 and DHUD_Settings["reversecasting"] == 0 then
                DHUD_Flash_Bar:SetAlpha(alpha);
            else
                frame.flash = nil;
                DHUD_Flash_Bar:SetAlpha(0);
                DHUD_Flash_Bar:Hide();
            end
        -- fade
        elseif frame.fadeOut then
			local alpha = DHUD_Casting_Bar:GetAlpha() - CASTING_BAR_ALPHA_STEP;
            if alpha > 0 and DHUD_Settings["reversecasting"] == 0 then
                DHUD_Casting_Bar:SetAlpha(alpha);
                DHUD_Casttime_Text:SetAlpha(alpha);
                DHUD_Castdelay_Text:SetAlpha(alpha);
				if DHUD_Settings["castingbarinfo"] == 1 then
					DHUD_CB_Texture:SetAlpha(alpha);
					DHUD_CB_Text:SetAlpha(alpha);
				end
            else
                frame.fadeOut = nil;
                DHUD_Casting_Bar:Hide();
                DHUD_Casting_Bar:SetAlpha(0);
                self.Casting = nil;
				if (DHUD_Settings["enemycastingbar"] == 0) then
					self:updateAlpha();
				end
                self.casting_time     = nil;
                self.casting_time_rev = nil;
                self.casting_time_del = nil;
                self.spellname        = nil;
                self:triggerTextEvent("DHUD_Casttime_Text");
                self:triggerTextEvent("DHUD_Castdelay_Text");
				if DHUD_Settings["castingbarinfo"] == 1 then
					self.enemyspellname = nil;
					self:triggerTextEvent("DHUD_CB_Text");
					_G["DHUD_CB_Texture"]:Hide();
				end
            end
        end
    end 
	
	    -- MADCAT enemy castingbar
    if DHUD_Settings["enemycastingbar"] == 1 then
		local frame = _G["DHUD_EnemyCasting_Bar"];
        -- casting
        if frame.enemycasting then
            local enemytime = GetTime();
            if (enemytime > frame.enemymaxValue) then
                enemytime = frame.enemymaxValue
            end
            
            DHUD_EnemyFlash_Bar:Hide();
            local v = (enemytime - frame.enemystartTime) / (frame.enemymaxValue - frame.enemystartTime);
            
            if DHUD_Settings["reversecasting"] == 1 then
                self:SetBarHeight("DHUD_EnemyCasting_Bar", 1-v );
                DHUD_EnemyCasting_Bar_Texture:SetVertexColor(self:Colorize("castbar",v));    
            else
                self:SetBarHeight("DHUD_EnemyCasting_Bar", v );
                DHUD_EnemyCasting_Bar_Texture:SetVertexColor(self:Colorize("castbar",v));       
            end
            
            self.enemycasting_time_del = string.format( "-%.1f", frame.enemydelay );
            self.enemycasting_time_rev = string.format( "%.1f", frame.enemymaxValue - enemytime );
            self.enemycasting_time     = string.format( "%.1f", (enemytime + frame.enemydelay) - frame.enemystartTime );
            self:triggerTextEvent("DHUD_EnemyCasttime_Text");
            self:triggerTextEvent("DHUD_EnemyCastdelay_Text");
                        
        -- channeling
        elseif frame.enemychanneling then
            local enemytime = GetTime();
            if (enemytime > frame.enemyendTime) then
                enemytime = frame.enemyendTime
            end
            
            local enemybarValue = frame.enemystartTime + (frame.enemyendTime - enemytime);
            local enemysparkPosition = (enemybarValue - frame.enemystartTime) / (frame.enemyendTime - frame.enemystartTime);
            DHUD_EnemyFlash_Bar:Hide();
            
            self:SetBarHeight("DHUD_EnemyCasting_Bar", enemysparkPosition );
            DHUD_EnemyCasting_Bar_Texture:SetVertexColor(self:Colorize("channelbar",(enemybarValue - frame.enemystartTime) / (frame.enemyendTime - frame.enemystartTime)));

            self.enemycasting_time_del = string.format( "+%.1f", frame.enemydelay );
            self.enemycasting_time     = string.format( " %.1f", (enemytime + frame.enemydelay) - frame.enemystartTime );
            self.enemycasting_time_rev = string.format( "%.1f", frame.enemyduration -((enemytime + frame.enemydelay) - frame.enemystartTime) );
            self:triggerTextEvent("DHUD_EnemyCasttime_Text");
            self:triggerTextEvent("DHUD_EnemyCastdelay_Text");
            
            if (enemytime == frame.enemyendTime) then
                frame.enemychanneling = nil;
                frame.enemycasting    = nil;
                frame.enemyfadeOut    = 1;
                frame.enemyflash      = nil;
                self.mcenemycasting    = nil;  
                self:SetBarHeight("DHUD_EnemyCasting_Bar", 0 );
                self:updateAlpha();
            end
        -- hold
        elseif frame.enemyholdTime and GetTime() < frame.enemyholdTime then
    
        -- flash
        elseif frame.enemyflash then
            local enemyalpha = DHUD_EnemyFlash_Bar:GetAlpha() + CASTING_BAR_FLASH_STEP;
            if enemyalpha < 1 and DHUD_Settings["reversecasting"] == 0 then
                DHUD_EnemyFlash_Bar:SetAlpha(enemyalpha);
            else
                frame.enemyflash = nil;
                DHUD_EnemyFlash_Bar:SetAlpha(0);
                DHUD_EnemyFlash_Bar:Hide();
            end
        -- fade
        elseif frame.enemyfadeOut then
			local enemyalpha = DHUD_EnemyCasting_Bar:GetAlpha() - CASTING_BAR_ALPHA_STEP;
			--self:print("enemyalpha: ".. enemyalpha);
            if enemyalpha > 0 and DHUD_Settings["reversecasting"] == 0 then
                DHUD_EnemyCasting_Bar:SetAlpha(enemyalpha);
                DHUD_EnemyCasttime_Text:SetAlpha(enemyalpha);
                DHUD_EnemyCastdelay_Text:SetAlpha(enemyalpha);
				DHUD_EnemyCB_Texture:SetAlpha(enemyalpha);
				DHUD_EnemyCB_Text:SetAlpha(enemyalpha);
            else
                frame.enemyfadeOut = nil;
                DHUD_EnemyCasting_Bar:Hide();
                DHUD_EnemyCasting_Bar:SetAlpha(0);
                self.mcenemycasting = nil;
                self:updateAlpha();
                self.enemycasting_time     = nil;
                self.enemycasting_time_rev = nil;
                self.enemycasting_time_del = nil;
                self.enemyspellname        = nil;
                self:triggerTextEvent("DHUD_EnemyCasttime_Text");
                self:triggerTextEvent("DHUD_EnemyCastdelay_Text");
				--Hide enemy spell info
				self.enemyspellname = nil;
				self:triggerTextEvent("DHUD_EnemyCB_Text");
				_G["DHUD_EnemyCB_Texture"]:Hide();
            end
        end
    end
	
    -- MADCAT energy(maybe CPU_consuming)
    -- self:triggerTextEvent("DHUD_PlayerMana_Text");
    -- Self writed function
    self:MCUpdatePlayerEnergy();
    
    -- MADCAT pet energy update, messed up condition a little
	if (DHUD_Settings["showpet"] == 1) and (self.has_pet_mana == 1 or self.mcinvehicle == 1) then
	if not(self.player_class == "DRUID") or self.mcinvehicle == 1 then
    	self:MCUpdatePetEnergy();
	end
    end
    --
    self:PlayerAuras();
	
	--UpdateDebuffTimers,CPU consuming.
	if DHUD_Settings["debufftimer"] == 1 and self.Target == 1 then
		self:TargetAuras();
	end	
	
	--Update DK runes, CPU consuming.
	if self.player_class == "DEATHKNIGHT" and DHUD_Settings["dkrunes"] == 1 then
		self:MCDKRunes();
	end
	
	--Update Pallys Holly Power, CPU consuming
	if self.player_class == "PALADIN" and DHUD_Settings["pallyhollypower"] == 1 then
		self:MCPallyHollyPower();
	end
	
	--Update Warlock Shards, CPU consuming
	if self.player_class == "WARLOCK" and DHUD_Settings["warlockshards"] == 1 then
		self:MCWarlockShards();
	end
end

-- register Events
function DHUD:registerEvents()
    local f = DHUD_EventFrame;   
    for e, v in pairs(self.mainEvents) do
        f:RegisterEvent(self.mainEvents[e]); 
    end
end

-- unregister events (on zoning)
function DHUD:unregisterEvents()
    local f = DHUD_EventFrame;   
    for e, v in pairs(self.mainEvents) do
        f:UnregisterEvent(self.mainEvents[e]); 
    end
end

-- set layout
function DHUD:setLayout()
    self.C_curLayout     = DHUD_Settings["layouttyp"] or "DHUD_Standard_Layout";
    self.C_textures      = DHUD_Layouts[self.C_curLayout]["DHUD_textures"];
    self.C_frames        = DHUD_Layouts[self.C_curLayout]["DHUD_frames"];
    self.C_tClips        = DHUD_Layouts[self.C_curLayout]["DHUD_textures_clip"];
    self.C_names         = DHUD_Layouts[self.C_curLayout]["DHUD_names"];
    self.defaultfont     = DHUD_Layouts[self.C_curLayout]["defaultfont"];
    self.defaultfont_num = DHUD_Layouts[self.C_curLayout]["defaultfont_num"];
	self:ChangeTextureSet();
end

-- Setup DHUD --
function DHUD:setup() 
    self:printd("setup START");
    self.issetup = 1;
    
    -- Get Humanoid Creature Type
    self.humanoid = UnitCreatureType("player");
    
    -- set userid 
    self.userID = GetRealmName()..":"..UnitName("player");
    _, self.player_class = UnitClass("player");
    
    -- set default Values
    if( not DHUD_Settings ) then
        DHUD_Settings = { };
    end

    for k, v in pairs(self.Config_default) do
        self:SetDefaultConfig(k);
    end

    -- init Layout (ref settings to hud)
    self:setLayout();
    
    -- create all Frames
    self:createFrames();
   
    -- init Target Menu
    DHUD_Target_Text:RegisterForClicks('RightButtonUp');
    DHUD_Target_Text:SetScript("OnClick", function() 
        ToggleDropDownMenu(1, nil, DHUD_Target_DropDown, "DHUD_Target_Text", 25, 10);
    end );

    -- create Minimap Button
    self:CreateMMB();
    
    -- MyAddons Support
    self:myAddons();
    
    -- now register events
    self:registerEvents();
                           
    -- we are done
    self:printd("setup END");
    self.issetup = 2;
    
end

-- prepare colors
function DHUD:prepareColors()
    -- for k, v in self.BarColor do
    for k, v in pairs(DHUD_Settings["colors"]) do
        local color0 = {};
        local color1 = {};
        local color2 = {};
        local h0, h1, h2;  
        h0, h1, h2 = unpack(DHUD_Settings["colors"][k]);
		if not h0 or not h1 or not h2 then
			self:print("One of color settings is damaged, reseting to default");
			self:OptionsFrame_Toggle();
			DHUDO:ResetColorSettings();
			self:OptionsFrame_Toggle();
		end
		--mcdebug
		--[[if h0 or h1 or h2 then
			self:print("h0: ".. h0 .. " h1: " .. h1 .. " h2: " .. h2 .. " k: " .. k);
		else
			self:print("h0: ".."nill" .. " h1: " .. "nill" .. " h2: " .. "nill" .. " k: " .. k);
		end]]--
        color0.r , color0.g , color0.b = unpack(DHUD_HexToDec(h0));
        color1.r , color1.g , color1.b = unpack(DHUD_HexToDec(h1));
        color2.r , color2.g , color2.b = unpack(DHUD_HexToDec(h2));
        self.BarColorTab[k] = { color0, color1, color2 };
    end
end

-- init HUD
function DHUD:init()

    self:printd("init START");
    self.isinit = 1;
    		    
    -- prepare colors
   self:prepareColors();
    
    -- set Hud Scale
    DHUD_Main:SetScale(DHUD_Settings["scale"] or 1);
    
    -- set Bars
    self:UpdateValues("DHUD_PlayerHealth_Text", 1 );
    self:UpdateValues("DHUD_PlayerMana_Text", 1 );
    self:UpdateValues("DHUD_TargetHealth_Text", 1);
    self:UpdateValues("DHUD_TargetMana_Text", 1);
    self:UpdateValues("DHUD_PetHealth_Text", 1);
    self:UpdateValues("DHUD_PetMana_Text",  1);
    
    -- Madcat Update Energy Information
    self.mcplmaxenergy = UnitPowerMax("player");
    self.mcpetmaxenergy = UnitPowerMax("pet");
    -- mcplenergy = UnitPower("player");
                    
    -- Update Combos
    self:UpdateCombos();
    
    -- Update Auras
    self:TargetAuras();
    
    self:PlayerAuras();
    
    -- Update background
    self:ChangeBackgroundTexture();

    -- Update Status
    self:updateStatus();
    self:updateRaidIcon();
    self:updatePlayerPvP();
    self:updateTargetPvP();
    self:updatePetIcon();
    
    -- set font
    DHUD_Castdelay_Text_Text:SetFont(self.defaultfont_num, DHUD_Settings["fontsizecastdelay"] / DHUD_Settings["scale"], self.Outline[ DHUD_Settings["castdelayoutline"] ]);
    DHUD_Casttime_Text_Text:SetFont(self.defaultfont_num, DHUD_Settings["fontsizecasttime"] / DHUD_Settings["scale"], self.Outline[ DHUD_Settings["castdelayoutline"] ]);
	DHUD_EnemyCastdelay_Text_Text:SetFont(self.defaultfont_num, DHUD_Settings["fontsizecastdelay"] / DHUD_Settings["scale"], self.Outline[ DHUD_Settings["castdelayoutline"] ]);
    DHUD_EnemyCasttime_Text_Text:SetFont(self.defaultfont_num, DHUD_Settings["fontsizecasttime"] / DHUD_Settings["scale"], self.Outline[ DHUD_Settings["castdelayoutline"] ]);
    DHUD_PlayerHealth_Text_Text:SetFont(self.defaultfont_num, DHUD_Settings["fontsizeplayer"] / DHUD_Settings["scale"], self.Outline[ DHUD_Settings["playerhpoutline"] ]);
    DHUD_PlayerMana_Text_Text:SetFont(self.defaultfont_num, DHUD_Settings["fontsizeplayer"] / DHUD_Settings["scale"], self.Outline[ DHUD_Settings["playermanaoutline"] ]);
    DHUD_TargetHealth_Text_Text:SetFont(self.defaultfont_num, DHUD_Settings["fontsizetarget"] / DHUD_Settings["scale"], self.Outline[ DHUD_Settings["targethpoutline"] ]);
    DHUD_TargetMana_Text_Text:SetFont(self.defaultfont_num, DHUD_Settings["fontsizetarget"] / DHUD_Settings["scale"], self.Outline[ DHUD_Settings["targetmanaoutline"] ]);
    DHUD_PetHealth_Text_Text:SetFont(self.defaultfont_num, DHUD_Settings["fontsizepet"] / DHUD_Settings["scale"], self.Outline[ DHUD_Settings["pethpoutline"] ]);
    DHUD_PetMana_Text_Text:SetFont(self.defaultfont_num, DHUD_Settings["fontsizepet"] / DHUD_Settings["scale"], self.Outline[ DHUD_Settings["petmanaoutline"] ]);
    DHUD_Target_Text_Text:SetFont(self.defaultfont, DHUD_Settings["fontsizetargetname"] / DHUD_Settings["scale"], self.Outline[ DHUD_Settings["targetoutline"] ]);
    DHUD_TargetTarget_Text_Text:SetFont(self.defaultfont, DHUD_Settings["fontsizetargettargetname"] / DHUD_Settings["scale"], self.Outline[ DHUD_Settings["targettargetoutline"] ]);
    DHUD_Rune1_Text_Text:SetFont( self.defaultfont, DHUD_Settings["fontsizeplayerbuff"] / DHUD_Settings["scale"], self.Outline[ DHUD_Settings["playerbuffoutline"] ]);
	DHUD_Rune2_Text_Text:SetFont( self.defaultfont, DHUD_Settings["fontsizeplayerbuff"] / DHUD_Settings["scale"], self.Outline[ DHUD_Settings["playerbuffoutline"] ]);
	DHUD_Rune3_Text_Text:SetFont( self.defaultfont, DHUD_Settings["fontsizeplayerbuff"] / DHUD_Settings["scale"], self.Outline[ DHUD_Settings["playerbuffoutline"] ]);
	DHUD_Rune4_Text_Text:SetFont( self.defaultfont, DHUD_Settings["fontsizeplayerbuff"] / DHUD_Settings["scale"], self.Outline[ DHUD_Settings["playerbuffoutline"] ]);
	DHUD_Rune5_Text_Text:SetFont( self.defaultfont, DHUD_Settings["fontsizeplayerbuff"] / DHUD_Settings["scale"], self.Outline[ DHUD_Settings["playerbuffoutline"] ]);
	DHUD_Rune6_Text_Text:SetFont( self.defaultfont, DHUD_Settings["fontsizeplayerbuff"] / DHUD_Settings["scale"], self.Outline[ DHUD_Settings["playerbuffoutline"] ]);
	
	
    -- player buffs
    DHUD_PlayerBuff1_Text:SetFont( self.defaultfont, DHUD_Settings["fontsizeplayerbuff"] / DHUD_Settings["scale"], self.Outline[ DHUD_Settings["playerbuffoutline"] ]);
    DHUD_PlayerBuff2_Text:SetFont( self.defaultfont, DHUD_Settings["fontsizeplayerbuff"] / DHUD_Settings["scale"], self.Outline[ DHUD_Settings["playerbuffoutline"] ]);
    DHUD_PlayerBuff3_Text:SetFont( self.defaultfont, DHUD_Settings["fontsizeplayerbuff"] / DHUD_Settings["scale"], self.Outline[ DHUD_Settings["playerbuffoutline"] ]);
    DHUD_PlayerBuff4_Text:SetFont( self.defaultfont, DHUD_Settings["fontsizeplayerbuff"] / DHUD_Settings["scale"], self.Outline[ DHUD_Settings["playerbuffoutline"] ]);
    DHUD_PlayerBuff5_Text:SetFont( self.defaultfont, DHUD_Settings["fontsizeplayerbuff"] / DHUD_Settings["scale"], self.Outline[ DHUD_Settings["playerbuffoutline"] ]);
    DHUD_PlayerBuff6_Text:SetFont( self.defaultfont, DHUD_Settings["fontsizeplayerbuff"] / DHUD_Settings["scale"], self.Outline[ DHUD_Settings["playerbuffoutline"] ]);
    DHUD_PlayerBuff7_Text:SetFont( self.defaultfont, DHUD_Settings["fontsizeplayerbuff"] / DHUD_Settings["scale"], self.Outline[ DHUD_Settings["playerbuffoutline"] ]);
    DHUD_PlayerBuff8_Text:SetFont( self.defaultfont, DHUD_Settings["fontsizeplayerbuff"] / DHUD_Settings["scale"], self.Outline[ DHUD_Settings["playerbuffoutline"] ]);
      
    -- Hide Blizz Target Frame
    if DHUD_Settings["btarget"] == 0 then
        TargetFrame:UnregisterEvent("PLAYER_TARGET_CHANGED")
        TargetFrame:UnregisterEvent("UNIT_HEALTH")
        TargetFrame:UnregisterEvent("UNIT_LEVEL")
        TargetFrame:UnregisterEvent("UNIT_FACTION")
        TargetFrame:UnregisterEvent("UNIT_CLASSIFICATION_CHANGED")
        TargetFrame:UnregisterEvent("UNIT_AURA")
        TargetFrame:UnregisterEvent("PLAYER_FLAGS_CHANGED")
        TargetFrame:UnregisterEvent("PARTY_MEMBERS_CHANGED")
        TargetFrame:UnregisterEvent("PLAYER_FOCUS_CHANGED")
        TargetFrame:Hide()
        ComboFrame:UnregisterEvent("PLAYER_TARGET_CHANGED")
        ComboFrame:UnregisterEvent("UNIT_COMBO_POINTS")
		ComboFrame:Hide()
    else
        TargetFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
        TargetFrame:RegisterEvent("UNIT_HEALTH")
        TargetFrame:RegisterEvent("UNIT_LEVEL")
        TargetFrame:RegisterEvent("UNIT_FACTION")
        TargetFrame:RegisterEvent("UNIT_CLASSIFICATION_CHANGED")
        TargetFrame:RegisterEvent("UNIT_AURA")
        TargetFrame:RegisterEvent("PLAYER_FLAGS_CHANGED")
        TargetFrame:RegisterEvent("PARTY_MEMBERS_CHANGED")
        TargetFrame:RegisterEvent("PLAYER_FOCUS_CHANGED")
        if UnitExists("target") then TargetFrame:Show() end
        ComboFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
        ComboFrame:RegisterEvent("UNIT_COMBO_POINTS")
    end
   
    -- Hide Blizz Player Frame
    if DHUD_Settings["bplayer"] == 0 then
        PlayerFrame:UnregisterEvent("UNIT_LEVEL")
        PlayerFrame:UnregisterEvent("UNIT_COMBAT")
        PlayerFrame:UnregisterEvent("UNIT_SPELLMISS")
        PlayerFrame:UnregisterEvent("UNIT_PVP_UPDATE")
        PlayerFrame:UnregisterEvent("UNIT_MAXMANA")
        PlayerFrame:UnregisterEvent("PLAYER_ENTER_COMBAT")
        PlayerFrame:UnregisterEvent("PLAYER_LEAVE_COMBAT")
        PlayerFrame:UnregisterEvent("PLAYER_UPDATE_RESTING")
        PlayerFrame:UnregisterEvent("PARTY_MEMBERS_CHANGED")
        PlayerFrame:UnregisterEvent("PARTY_LEADER_CHANGED")
        PlayerFrame:UnregisterEvent("PARTY_LOOT_METHOD_CHANGED")
        PlayerFrame:UnregisterEvent("PLAYER_ENTERING_WORLD")
        PlayerFrame:UnregisterEvent("PLAYER_REGEN_DISABLED")
        PlayerFrame:UnregisterEvent("PLAYER_REGEN_ENABLED")
        PlayerFrameHealthBar:UnregisterEvent("UNIT_HEALTH")
        PlayerFrameHealthBar:UnregisterEvent("UNIT_MAXHEALTH")
        PlayerFrameManaBar:UnregisterEvent("UNIT_POWER")
        PlayerFrameManaBar:UnregisterEvent("UNIT_DISPLAYPOWER")
        PlayerFrame:UnregisterEvent("UNIT_NAME_UPDATE")
        PlayerFrame:UnregisterEvent("UNIT_PORTRAIT_UPDATE")
        PlayerFrame:UnregisterEvent("UNIT_DISPLAYPOWER")
        PlayerFrame:Hide()
		RuneFrame:Hide()
    else
        PlayerFrame:RegisterEvent("UNIT_LEVEL")
        PlayerFrame:RegisterEvent("UNIT_COMBAT")
        PlayerFrame:RegisterEvent("UNIT_SPELLMISS")
        PlayerFrame:RegisterEvent("UNIT_PVP_UPDATE")
        PlayerFrame:RegisterEvent("UNIT_MAXMANA")
        PlayerFrame:RegisterEvent("PLAYER_ENTER_COMBAT")
        PlayerFrame:RegisterEvent("PLAYER_LEAVE_COMBAT")
        PlayerFrame:RegisterEvent("PLAYER_UPDATE_RESTING")
        PlayerFrame:RegisterEvent("PARTY_MEMBERS_CHANGED")
        PlayerFrame:RegisterEvent("PARTY_LEADER_CHANGED")
        PlayerFrame:RegisterEvent("PARTY_LOOT_METHOD_CHANGED")
        PlayerFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
        PlayerFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
        PlayerFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
        PlayerFrameHealthBar:RegisterEvent("UNIT_HEALTH")
        PlayerFrameHealthBar:RegisterEvent("UNIT_MAXHEALTH")
        PlayerFrameManaBar:RegisterEvent("UNIT_POWER")
        PlayerFrameManaBar:RegisterEvent("UNIT_DISPLAYPOWER")
        PlayerFrame:RegisterEvent("UNIT_NAME_UPDATE")
        PlayerFrame:RegisterEvent("UNIT_PORTRAIT_UPDATE")
        PlayerFrame:RegisterEvent("UNIT_DISPLAYPOWER")
        PlayerFrame:Show()
		if (self.player_class == "DEATHKNIGHT") then
			RuneFrame:Show()
		end
    end
 
    -- hide blizz castbar
    if DHUD_Settings["bcastingbar"] == 0 then
        CastingBarFrame:UnregisterEvent("UNIT_SPELLCAST_START");
        CastingBarFrame:UnregisterEvent("UNIT_SPELLCAST_STOP");
        CastingBarFrame:UnregisterEvent("UNIT_SPELLCAST_FAILED");
        CastingBarFrame:UnregisterEvent("UNIT_SPELLCAST_INTERRUPTED");
        CastingBarFrame:UnregisterEvent("UNIT_SPELLCAST_DELAYED");
        CastingBarFrame:UnregisterEvent("UNIT_SPELLCAST_CHANNEL_START");
        CastingBarFrame:UnregisterEvent("UNIT_SPELLCAST_CHANNEL_UPDATE");
        CastingBarFrame:UnregisterEvent("UNIT_SPELLCAST_CHANNEL_STOP");
        CastingBarFrame:Hide();
    else
        CastingBarFrame:RegisterEvent("UNIT_SPELLCAST_START");
        CastingBarFrame:RegisterEvent("UNIT_SPELLCAST_STOP");
        CastingBarFrame:RegisterEvent("UNIT_SPELLCAST_FAILED");
        CastingBarFrame:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED");
        CastingBarFrame:RegisterEvent("UNIT_SPELLCAST_DELAYED");
        CastingBarFrame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START");
        CastingBarFrame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_UPDATE");
        CastingBarFrame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP");
    end;
   
    -- update Alpha
    self.inCombat = nil;
    self:updateAlpha();
    DHUD_Flash_Bar:SetAlpha(0);
    DHUD_Casting_Bar:SetAlpha(0);
    DHUD_Casting_Bar:Hide();
    DHUD_Flash_Bar:Hide();
	
	--enemycastbar
	DHUD_EnemyFlash_Bar:SetAlpha(0);
    DHUD_EnemyCasting_Bar:SetAlpha(0);
    DHUD_EnemyCasting_Bar:Hide();
    DHUD_EnemyFlash_Bar:Hide();
	_G["DHUD_EnemyCB_Texture"]:Hide();
	self.enemyspellname = nil;
	self:triggerTextEvent("DHUD_EnemyCB_Text");
	_G["DHUD_CB_Texture"]:Hide();
	self.spellname = nil;
	self:triggerTextEvent("DHUD_CB_Text");
	
	--dk runes
    if (not (self.player_class == "DEATHKNIGHT")) or DHUD_Settings["dkrunes"] == 0 then
		_G["DHUD_Rune1"]:Hide();	
		_G["DHUD_Rune2"]:Hide();	
		_G["DHUD_Rune3"]:Hide();	
		_G["DHUD_Rune4"]:Hide();	
		_G["DHUD_Rune5"]:Hide();	
		_G["DHUD_Rune6"]:Hide();
	else
		_G["DHUD_Rune1"]:Show();
		_G["DHUD_Rune2"]:Show();
		_G["DHUD_Rune3"]:Show();
		_G["DHUD_Rune4"]:Show();
		_G["DHUD_Rune5"]:Show();
		_G["DHUD_Rune6"]:Show();
		self:triggerTextEvent("DHUD_Rune1_Text");
		self:triggerTextEvent("DHUD_Rune2_Text");
		self:triggerTextEvent("DHUD_Rune3_Text");
		self:triggerTextEvent("DHUD_Rune4_Text");
		self:triggerTextEvent("DHUD_Rune5_Text");
		self:triggerTextEvent("DHUD_Rune6_Text");
	end
	
	--scale combopoints
	if DHUD_Settings["scalecp"]	then--and not (DHUD_Settings["scalecp"]==1) then
		--scale cp
		DHUD_Combo1:SetScale(DHUD_Settings["scalecp"] or 1);
		DHUD_Combo2:SetScale(DHUD_Settings["scalecp"] or 1);
		DHUD_Combo3:SetScale(DHUD_Settings["scalecp"] or 1);
		DHUD_Combo4:SetScale(DHUD_Settings["scalecp"] or 1);
		DHUD_Combo5:SetScale(DHUD_Settings["scalecp"] or 1);
		local i;
		for i=1,5,1 do
			local typ, point, frame, relative, x, y, width, height = unpack( self.C_frames["DHUD_Combo"..i] );
			local ref = _G["DHUD_Combo"..i];
			local x2;
			--x2=(1-DHUD_Settings["scalecp"])*(1/(1+0.5*(i-1)))*20*(1/DHUD_Settings["scalecp"]);
			x2=(1-DHUD_Settings["scalecp"])*(1/(1+0.5*(i-2)*(i-1)*(i-3)))*20*(1/DHUD_Settings["scalecp"]);
			if i==3 then
				x2=(1-DHUD_Settings["scalecp"])*(1/1.5)*20*(1/DHUD_Settings["scalecp"]);
			elseif i==4 then
				x2=(1-DHUD_Settings["scalecp"])*(1/2.5)*20*(1/DHUD_Settings["scalecp"]);
			end
			--[[if i==1 then
				x2=(1-DHUD_Settings["scalecp"])*20*(1/DHUD_Settings["scalecp"]);
			elseif i==2 then
				x2=(1-DHUD_Settings["scalecp"])*20*(1/DHUD_Settings["scalecp"]);
			elseif i==3 then
				x2=(1-DHUD_Settings["scalecp"])*20*(1/DHUD_Settings["scalecp"]);
			elseif i==4 then
				x2=(1-DHUD_Settings["scalecp"])*20*(1/DHUD_Settings["scalecp"]);
			elseif i==5 then
				x2=(1-DHUD_Settings["scalecp"])*20*(1/DHUD_Settings["scalecp"]);
			end]]--
			ref:SetPoint(point, frame , relative, x + x2, y);
		end
		self.mccpmoved = 0;
	end
	
	
    -- init castbar
	local frame = _G["DHUD_Casting_Bar"];
    frame.endTime = 0;
    
    -- pos frames
    self:PositionFrame("DHUD_Main");
    self:PositionFrame("DHUD_LeftFrame");
    self:PositionFrame("DHUD_RightFrame");
    self:PositionFrame("DHUD_Target_Text");
    self:PositionFrame("DHUD_TargetTarget_Text");
    self:PositionFrame("DHUD_PlayerHealth_Text");
    self:PositionFrame("DHUD_PlayerMana_Text");
    self:PositionFrame("DHUD_TargetHealth_Text");
    self:PositionFrame("DHUD_TargetMana_Text");
    self:PositionFrame("DHUD_PetHealth_Text");
    self:PositionFrame("DHUD_PetMana_Text");    
    self:PositionFrame("DHUD_Casttime_Text");
    self:PositionFrame("DHUD_Castdelay_Text");

    -- top frames
    DHUD_TargetElite:SetFrameLevel(DHUD_LeftFrame:GetFrameLevel() + 1);
    DHUD_Flash_Bar:SetFrameLevel(DHUD_PlayerMana_Bar:GetFrameLevel() + 1);
    DHUD_Casting_Bar:SetFrameLevel(DHUD_Flash_Bar:GetFrameLevel() + 1);
	DHUD_EnemyFlash_Bar:SetFrameLevel(DHUD_PlayerMana_Bar:GetFrameLevel() + 1);
    DHUD_EnemyCasting_Bar:SetFrameLevel(DHUD_Flash_Bar:GetFrameLevel() + 1);
    
    -- minimap button
    if DHUD_Settings["showmmb"] == 1 then
        DHUDMinimapButton:Show();
		DHUDMinimapButton:SetFrameStrata(Minimap:GetFrameStrata());
		DHUDMinimapButton:SetFrameLevel(Minimap:GetFrameLevel() + 3);	
    else
        DHUDMinimapButton:Hide();
    end
    
    -- alter pet manatext when class = DRUID
    if self.player_class == "DRUID" and DHUD_Settings["DHUD_PetMana_Text"] == DHUD_TEXT_MP2 then
        DHUD_Settings["DHUD_PetMana_Text"] = DHUD_TEXT_MP7;
    end
    
    -- trigger all texts
    self:triggerAllTextEvents();
                   
    -- init end   
    self.isinit = 2;
    self:printd("init END");
	
end

-- Change Frame Pos
function DHUD:PositionFrame(name,x2,y2)
    local xn , yn, mx, my = unpack ( self.moveFrame[name] );
    local x2 = tonumber(DHUD_Settings[xn] or 0);
    local y2 = tonumber(DHUD_Settings[yn] or 0);
    if mx == "-" then
        x2 = 0 - x2;
    end
    if my == "-" then
        y2 = 0 - y2;
    end
    local typ, point, frame, relative, x, y, width, height = unpack( self.C_frames[name] );
    local ref = _G[name];
    self:printd( name.." "..(x + x2).." "..(y + y2) );
    ref:SetPoint(point, frame , relative, x + x2, y + y2);
end

-- player changed Target
function DHUD:TargetChanged()     
    -- Target selected?
    if UnitExists("target") then
        self.Target = 1;
    else
        self.Target = nil;
    end

    if (DHUD_Settings["shownpc"] == 0 and self:TargetIsNPC()) or DHUD_Settings["showtarget"] == 0 then
        self:SetBarHeight("DHUD_TargetHealth_Bar",0);
        self:SetBarHeight("DHUD_TargetMana_Bar",0);
        self.Target = nil;
    else
        self:UpdateValues("DHUD_TargetHealth_Text", 1);
        self:UpdateValues("DHUD_TargetMana_Text", 1); 
    end
    
	 if DHUD_Settings["enemycastingbar"] == 1 then
		local frame = _G["DHUD_EnemyCasting_Bar"];
		--Remove Enemy CastBar if target Changed
		if (DHUD_EnemyCasting_Bar:IsShown() and not(frame.enemyfadeOut) ) then
	                DHUD_EnemyCasting_Bar_Texture:SetVertexColor(1, 0, 0);
	                self:SetBarHeight("DHUD_EnemyCasting_Bar",1);
	                frame.enemycasting    = nil;
	                frame.enemychanneling = nil;
	                frame.enemyfadeOut    = 1;
	                frame.enemyflash      = nil;
	                frame.enemyholdTime = GetTime();
	                DHUD_EnemyFlash_Bar:Hide();
	                DHUD_EnemyFlash_Bar:SetAlpha(0);
					self:SetBarHeight("DHUD_EnemyCasting_Bar", 0 );
	    end
		self.enemyspellname = nil;
		self:triggerTextEvent("DHUD_EnemyCB_Text");
		_G["DHUD_EnemyCB_Texture"]:Hide();
		--remove texture
		self.mctargetcancast=nil;
	end
	
	self:UpdateCombos();
    self:updateRaidIcon();
    self:updateTargetPvP();
    self:ChangeBackgroundTexture();     
    self:updateAlpha();
    self:TargetAuras();
    
    -- make name clickable?
    if ( UnitIsUnit("target", "player") and ( GetNumPartyMembers() > 0 or GetNumRaidMembers() > 0 )) or
       ( UnitIsPlayer("target")  and not UnitIsEnemy("player", "target")  and not UnitIsUnit("target", "player") ) or
       UnitIsUnit("target", "pet") then
        _G["DHUD_Target_Text"]:EnableMouse(1);
    else
        _G["DHUD_Target_Text"]:EnableMouse(0);
    end
    
    self:triggerTextEvent("DHUD_TargetTarget_Text");
end

-- player's target changed Target
function DHUD:TargetTargetChanged()
    if UnitExists("targettarget") then
        self.TargetTarget = 1;
    else
        self.TargetTarget = nil;
    end
    
    if DHUD_Settings["showtargettarget"] == 0 then
        self.TargetTarget = nil;
    end
	
end

-- Create all Frames --
function DHUD:createFrames()
    for i = 1, getn(self.C_names) do
        self:createFrame(self.C_names[i]);
    end
end

-- Transform Frames
function DHUD:transformFrames(layout)
    if layout == "DHUD_Standard_Layout" or layout == "DHUD_PlayerLeft_Layout" or layout == "DHUD_StandardMirror_Layout" or layout == "DHUD_PlayerLeftMirror_Layout" then
        self:SetConfig( "layouttyp", layout );
        self:setLayout();
    
        self.frame_level = 0;
        for i = 1, getn(self.C_names) do
            self:transform(self.C_names[i]);
        end
        
        self:init();
    end
end

-- Frame transformer
function DHUD:transform(name)
    
    -- does frame exist in list?
    if not self.C_frames[name] then
        return;
    end
    
    -- get frame settings
    local typ, point, frame, relative, x, y, width, height = unpack( self.C_frames[name] );  
    self.frame_level = self.frame_level + 1;
    
    -- debug
    self:printd("DHUD: transformFrame "..name.." typ:"..typ .." level:"..self.frame_level);
    
    if typ == "Frame" then
        local ref = _G[name];
        ref:SetPoint(point, frame , relative, x, y);
        ref:SetHeight(height);
        ref:SetWidth(width); 
        
        -- debug background
        if self.debug then
            --ref:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", tile = true, tileSize = 32, insets = { left = 0, right = 0, top = 0, bottom = 0 }});
            --ref:SetBackdropColor(0,0,0,0.2);
        end
        
        ref:SetFrameLevel(self.frame_level);
        ref:SetParent(frame);
        ref:EnableMouse(false);
        ref:Show();       
    elseif typ == "Texture" then    
        local texture,x0,x1,y0,y1 = unpack( self.C_textures[name] );
        local ref = _G[name];
        ref:ClearAllPoints();
        ref:SetPoint(point, frame , relative, x, y);
        ref:SetHeight(height);
        ref:SetWidth(width);
        
        -- debug background
        if self.debug then
            --ref:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", tile = true, tileSize = 32, insets = { left = 0, right = 0, top = 0, bottom = 0 }});
            --ref:SetBackdropColor(0,1,0,0.3);
        end
        strata = "BACKGROUND";
        if name == "DHUD_Casting_Bar" or name == "DHUD_Flash_Bar" then
            strata = "LOW";
        end
		 if name == "DHUD_EnemyCasting_Bar" or name == "DHUD_EnemyFlash_Bar" then
            strata = "LOW";
        end

        local bgt = _G[name.."_Texture"];
        bgt:SetTexture(texture);
        bgt:ClearAllPoints();
        bgt:SetPoint("TOPLEFT", ref , "TOPLEFT", 0, 0);
        bgt:SetPoint("BOTTOMRIGHT", ref , "BOTTOMRIGHT", 0, 0);
        bgt:SetTexCoord(x0,x1,y0,y1);
        
        ref:SetFrameStrata(strata);
        ref:SetFrameLevel(self.frame_level);
        ref:SetParent(frame);
        ref:EnableMouse(false);
        ref:Show();

    elseif typ == "Bar" then
        local texture,x0,x1,y0,y1 = unpack( self.C_textures[name] );
		--print("transform " .. name);
		--print("transform " .. texture);
        local ref = _G[name];
        ref:ClearAllPoints();
        ref:SetPoint(point, frame , relative, x, y);
        ref:SetHeight(height);
        ref:SetWidth(width);
        
        -- debug background
        if self.debug then
            --ref:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", tile = true, tileSize = 32, insets = { left = 0, right = 0, top = 0, bottom = 0 }});
            --ref:SetBackdropColor(0,1,0,0.1);
        end
        local bgt = _G[name.."_Texture"];
        bgt:SetTexture(texture);
        bgt:SetPoint(point, ref, relative, 0, 0);
        bgt:SetHeight(height);
        bgt:SetWidth(width);
        bgt:SetTexCoord(x0,x1,y0,y1);
        
        ref:SetFrameStrata("BACKGROUND");
        ref:SetFrameLevel(self.frame_level);
        ref:SetParent(frame);
        ref:EnableMouse(false);
        ref:Show();    
        
    elseif typ == "Text" then
        local ref = _G[name];
        ref:ClearAllPoints();
        ref:SetPoint(point, frame , relative, x, y);
        
        -- debug background
        if self.debug then
           -- ref:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", tile = true, tileSize = 32, insets = { left = 0, right = 0, top = 0, bottom = 0 }});
            --ref:SetBackdropColor(0,0,1,0.5);
        end
        
        local font = _G[name.."_Text"];
        font:SetFontObject(GameFontHighlightSmall);
        if self.debug then
            font:SetText(name);
        else
            font:SetText(" ");
        end
        font:SetJustifyH("CENTER");
        font:SetWidth(font:GetStringWidth());
        font:SetHeight(height);
        font:Show();
        font:ClearAllPoints();
        font:SetPoint(point, ref, relative,0, 0);
        
        -- ref:SetFrameStrata("BACKGROUND");
        ref:SetFrameLevel(self.frame_level);
        ref:SetHeight(height);
        ref:SetWidth(font:GetStringWidth());
        ref:SetParent(frame);
        ref:EnableMouse(false);
        ref:Show();
        self:initTextfield(ref,name);         
        		
    -- set buffs    
    elseif typ == "Buff" then
        ref = _G[name];
        ref:ClearAllPoints();
        ref:SetPoint(point, frame , relative, x, y);
        ref:SetHeight(height);
        ref:SetWidth(width);
        
        -- debug background
        if self.debug then
           -- ref:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", tile = true, tileSize = 32, insets = { left = 0, right = 0, top = 0, bottom = 0 }});
           -- ref:SetBackdropColor(1,0,0,0.2);
        end

        local font = _G[name.."_Text"];
        font:SetFontObject(GameFontHighlightSmall);
        font:SetText("");
        font:SetJustifyH("RIGHT");
        font:SetJustifyV("BOTTOM");
        font:SetWidth(width+1);
        font:SetHeight(height-5);
        font:SetFont( self.defaultfont, width / 2.2, "OUTLINE");
        font:Show();
        font:ClearAllPoints();
        font:SetPoint(point, frame, relative,x, y);
        
        local bgt = _G[name.."_Border"];
        bgt:SetTexture("Interface\\Buttons\\UI-Debuff-Border");
        bgt:SetPoint("BOTTOM", ref, "BOTTOM", 0, 0);
        bgt:SetHeight(height);
        bgt:SetWidth(width);
        bgt:SetTexCoord(0,1,0,1);  
                
        ref:SetNormalTexture( "Interface\\Icons\\Ability_Druid_TravelForm" );
        ref:SetFrameLevel(self.frame_level);
        ref:SetParent(frame);
        
        ref:SetScript("OnEnter", function(frame) 
                if (not frame:IsVisible()) then return; end
                if DHUD_Settings["showauratips"] == 0 then return; end
                GameTooltip:SetOwner(frame, "ANCHOR_BOTTOMRIGHT");
                if frame.hasdebuff == 1 then
                    GameTooltip:SetUnitDebuff(frame.unit, frame.id);
                else
                    GameTooltip:SetUnitBuff(frame.unit, frame.id);
                end
            end );
 
         ref:SetScript("OnLeave", function() 
                GameTooltip:Hide();
            end );
                         
        ref:EnableMouse(true);
        ref:Show();
        
    elseif typ == "PlayerBuff" then
        ref = _G[name];
        ref:ClearAllPoints();
        ref:SetPoint(point, frame , relative, x, y);
        ref:SetHeight(height);
        ref:SetWidth(width);
        
        local font = _G[name.."_Text"];
        font:ClearAllPoints();
        font:SetFontObject(GameFontHighlightSmall);
        font:SetPoint("CENTER", ref, "CENTER", 0,0);
        font:SetText("");
        font:SetJustifyH("CENTER");
        font:SetJustifyV("CENTER");
        font:SetWidth(width*2);
        font:SetHeight(height);
        
        local bgt = _G[name.."_Border"];
        bgt:SetTexture("Interface\\AddOns\\DHUD\\layout\\serenity0");
        bgt:SetVertexColor(1.0,1.0,1.0);
        bgt:SetPoint("TOPLEFT", ref, "TOPLEFT", -7.5, 7.5);
        bgt:SetHeight(height*1.6);
        bgt:SetWidth(width*1.6);
        bgt:SetTexCoord(0,1,0,1);
        bgt:SetBlendMode("BLEND");
                
        ref:SetNormalTexture( "Interface\\Icons\\Ability_Druid_TravelForm" );
        ref:SetFrameLevel(self.frame_level);
        ref:SetParent(frame);
        
        ref:SetScript("OnEnter", function(frame) 
                if (not frame:IsVisible()) then return; end
                if DHUD_Settings["showauratips"] == 0 then return; end
                GameTooltip:SetOwner(frame, "ANCHOR_BOTTOMRIGHT");
				if frame.hasdebuff == 1 then
                    GameTooltip:SetUnitDebuff("player", frame.id);
                else
                    GameTooltip:SetUnitBuff("player", frame.id);
                end
            end );
 
         ref:SetScript("OnLeave", function() 
                GameTooltip:Hide();
            end );
                         
        ref:EnableMouse(true);
        ref:Show();
        
    end
end

-- Frame texture change
function DHUD:ChangeTextureSet()
	for _, value in pairs(self.frames_have_texture_set) do
		local path, v2, v3, v4, v5, changed = unpack( self.C_textures[value] );
		if (changed ~= 1) then
			path = path .. DHUD_Settings["textureset"];
			changed = 1;
		else
			path = string.sub(path, 0, string.len(path) - 1) .. DHUD_Settings["textureset"];
		end
		self.C_textures[value] = {path, v2, v3, v4, v5, changed};
	end
end
    
-- Frame Creator
function DHUD:createFrame(name)
    
    -- does frame exist in list?
    if not self.C_frames[name] then
        return;
    end
    
    -- get frame settings
    local typ, point, frame, relative, x, y, width, height = unpack( self.C_frames[name] );
        
    -- set framelevel
    if not self.frame_level then 
        -- self.frame_level = getn(self.C_names) + 1; 
        self.frame_level = 0;
    end
    
    self.frame_level = self.frame_level + 1;
    
    -- debug
    self:printd("DHUD: createFrame "..name.." parent:"..frame.." typ:"..typ .." level:"..self.frame_level);    

    -- set frame        
    if typ == "Frame" then
        ref = CreateFrame ("Frame", name, _G[frame] );
        ref:ClearAllPoints();
        ref:SetPoint(point, frame , relative, x, y);
        ref:SetHeight(height);
        ref:SetWidth(width);
        
        -- debug background
        if self.debug then
            ----ref:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", tile = true, tileSize = 32, insets = { left = 0, right = 0, top = 0, bottom = 0 }});
            --ref:SetBackdropColor(0,0,0,0.2);
        end
        
        ref:SetFrameLevel(self.frame_level);
        ref:SetParent(frame);
        ref:EnableMouse(false);
        ref:Show();
    
    -- set bar
    elseif typ == "Texture" then    
        local texture,x0,x1,y0,y1 = unpack( self.C_textures[name] );
        ref = CreateFrame("Frame", name, _G[frame] );
        ref:ClearAllPoints();
        ref:SetPoint(point, frame , relative, x, y);
        ref:SetHeight(height);
        ref:SetWidth(width);
        
        -- debug background
        if self.debug then
            --ref:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", tile = true, tileSize = 32, insets = { left = 0, right = 0, top = 0, bottom = 0 }});
            --ref:SetBackdropColor(0,1,0,0.3);
        end
        strata = "BACKGROUND";
        if name == "DHUD_Casting_Bar" or name == "DHUD_Flash_Bar" then
            strata = "LOW";
        end
		if name == "DHUD_EnemyCasting_Bar" or name == "DHUD_EnemyFlash_Bar" then
            strata = "LOW";
        end
        
        local bgt = ref:CreateTexture(name.."_Texture",strata);
        bgt:SetTexture(texture);
        bgt:ClearAllPoints();
        bgt:SetPoint("TOPLEFT", ref , "TOPLEFT", 0, 0);
        bgt:SetPoint("BOTTOMRIGHT", ref , "BOTTOMRIGHT", 0, 0);
        bgt:SetTexCoord(x0,x1,y0,y1);
        ref:SetFrameLevel(self.frame_level);
        ref:SetParent(frame);
        ref:EnableMouse(false);
        ref:Show();
    -- set bar
    elseif typ == "Bar" then    
        local texture,x0,x1,y0,y1 = unpack( self.C_textures[name] );
        ref = CreateFrame("Frame", name, _G[frame]);
        ref:ClearAllPoints();
        ref:SetPoint(point, frame , relative, x, y);
        ref:SetHeight(height);
        ref:SetWidth(width);
        
        -- debug background
        if self.debug then
            --ref:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", tile = true, tileSize = 32, insets = { left = 0, right = 0, top = 0, bottom = 0 }});
            --ref:SetBackdropColor(0,1,0,0.1);
        end
        
        local bgt = ref:CreateTexture(name.."_Texture","BACKGROUND");
        bgt:SetTexture(texture);
        bgt:SetPoint(point, ref, relative, 0, 0);
        bgt:SetHeight(height);
        bgt:SetWidth(width);
        bgt:SetTexCoord(x0,x1,y0,y1);
        ref:SetFrameLevel(self.frame_level);
        ref:SetParent(frame);
        ref:EnableMouse(false);
        ref:Show();
		
		if (name == "DHUD_Casting_Bar") then
			ref.startTime  = 0;
            ref.maxValue   = 0;
            ref.holdTime   = 0;
            ref.casting    = nil;
            ref.delay      = 0;
            ref.channeling = nil;
            ref.fadeOut    = nil;
            ref.flash      = nil;
            ref.duration   = 0;
		elseif (name == "DHUD_EnemyCasting_Bar") then
			ref.enemystartTime  = 0;
            ref.enemymaxValue   = 0;
            ref.enemyholdTime   = 0;
            ref.enemycasting    = nul;
            ref.enemydelay      = 0;
            ref.enemychanneling = nil;
            ref.enemyfadeOut    = nil;
            ref.enemyflash      = nil;
            ref.enemyduration   = 0;
		end
    -- set text
    elseif typ == "Text" then
        ref = CreateFrame("Button", name, _G[frame]);
        ref:ClearAllPoints();
        ref:SetPoint(point, frame , relative, x, y);
        
        -- debug background
        if self.debug then
           -- ref:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", tile = true, tileSize = 32, insets = { left = 0, right = 0, top = 0, bottom = 0 }});
           -- ref:SetBackdropColor(0,0,1,0.5);
        end
        
        local font = ref:CreateFontString(name.."_Text", "ARTWORK");
        font:SetFontObject(GameFontHighlightSmall);
        if self.debug then
            font:SetText(name);
        else
            font:SetText(" ");
        end
        font:SetJustifyH("CENTER");
        font:SetWidth(font:GetStringWidth());
        font:SetHeight(height);
        font:Show();
        font:ClearAllPoints();
        font:SetPoint(point, ref, relative,0, 0);
        
        ref:SetFrameLevel(self.frame_level);
        ref:SetHeight(height);
        ref:SetWidth(font:GetStringWidth());
        ref:SetParent(frame);
        ref:EnableMouse(false);
        ref:Show();
        self:initTextfield(ref,name);        
      		
    -- set buffs    
    elseif typ == "Buff" then
        ref = CreateFrame("Button", name, _G[frame]);
        ref:ClearAllPoints();
        ref:SetPoint(point, frame , relative, x, y);
        ref:SetHeight(height);
        ref:SetWidth(width);
        
        -- debug background
        if self.debug then
           -- ref:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", tile = true, tileSize = 32, insets = { left = 0, right = 0, top = 0, bottom = 0 }});
           -- ref:SetBackdropColor(1,0,0,0.2);
        end

        local font = ref:CreateFontString(name.."_Text", "ARTWORK");
        font:SetFontObject(GameFontHighlightSmall);
        font:SetText("");
        font:SetJustifyH("RIGHT");
        font:SetJustifyV("BOTTOM");
        font:SetWidth(width+1);
        font:SetHeight(height-5);
        font:SetFont( self.defaultfont, width / 2.2, "OUTLINE");
        font:Show();
        font:ClearAllPoints();
        font:SetPoint(point, frame, relative,x, y);
		
		local font2 = ref:CreateFontString(name.."_TimeLeftText", "ARTWORK");
        font2:SetFontObject(GameFontHighlightSmall);
        font2:SetText("");
        font2:SetJustifyH("LEFT");
        font2:SetJustifyV("TOP");
        font2:SetWidth(width+1);
        font2:SetHeight(height-3);
        font2:SetFont( self.defaultfont, width / 2.5, "OUTLINE");
        font2:Show();
        font2:ClearAllPoints();
        font2:SetPoint(point, frame, relative,x, y);
        
        local bgt = ref:CreateTexture(name.."_Border","OVERLAY");
        bgt:SetTexture("Interface\\Buttons\\UI-Debuff-Border");
        bgt:SetPoint("BOTTOM", ref, "BOTTOM", 0, 0);
        bgt:SetHeight(height);
        bgt:SetWidth(width);
        bgt:SetTexCoord(0,1,0,1);  
                
        ref:SetNormalTexture( "Interface\\Icons\\Ability_Druid_TravelForm" );
		--commenting to test if glyph interface will crush?
        --ref:SetFrameLevel(self.frame_level);
        ref:SetParent(frame);
        

        ref:SetScript("OnEnter", function(frame) 
                if (not frame:IsVisible()) then return; end
                if DHUD_Settings["showauratips"] == 0 then return; end
                GameTooltip:SetOwner(frame, "ANCHOR_BOTTOMRIGHT");
                if frame.hasdebuff == 1 then
                    GameTooltip:SetUnitDebuff(frame.unit, frame.id);
                else
                    GameTooltip:SetUnitBuff(frame.unit, frame.id);
                end
            end );

         ref:SetScript("OnLeave", function() 
                GameTooltip:Hide();
            end );
                         
        ref:EnableMouse(true);
        ref:Show();
        
    elseif typ == "PlayerBuff" then
        ref = CreateFrame("Button", name, _G[frame]);
        ref:ClearAllPoints();
        ref:SetPoint(point, frame , relative, x, y);
        ref:SetHeight(height);
        ref:SetWidth(width);
        
        local font = ref:CreateFontString(name.."_Text", "OVERLAY");
        font:ClearAllPoints();
        font:SetFontObject(GameFontHighlightSmall);
        font:SetPoint("CENTER", ref, "CENTER", 0,0);
        font:SetText("");
        font:SetJustifyH("CENTER");
        font:SetJustifyV("CENTER");
        font:SetWidth(width*2);
        font:SetHeight(height);
		
		local font2 = ref:CreateFontString(name.."_CountText", "OVERLAY");
        font2:ClearAllPoints();
        font2:SetFontObject(GameFontHighlightSmall);
        font2:SetPoint("CENTER", ref, "CENTER", 0,0);
        font2:SetText("");
        font2:SetJustifyH("RIGHT");
        font2:SetJustifyV("BOTTOM");
        font2:SetWidth(width*1.7);
        font2:SetHeight(height*1.2);
        
        local bgt = ref:CreateTexture(name.."_Border","OVERLAY");
        bgt:SetTexture("Interface\\AddOns\\DHUD\\layout\\serenity0");
        bgt:SetVertexColor(1.0,1.0,1.0);
        bgt:SetPoint("TOPLEFT", ref, "TOPLEFT", -7.5, 7.5);
        bgt:SetHeight(height*1.6);
        bgt:SetWidth(width*1.6);
        bgt:SetTexCoord(0,1,0,1);
        bgt:SetBlendMode("BLEND");
                
        ref:SetNormalTexture( "Interface\\Icons\\Ability_Druid_TravelForm" );
		-- Glyph and achiviements interface crash if uncomment following line
        --ref:SetFrameLevel(self.frame_level);
        ref:SetParent(frame);
        
        ref:SetScript("OnEnter", function(frame) 
                if (not frame:IsVisible()) then return; end
                if DHUD_Settings["showauratips"] == 0 then return; end
                GameTooltip:SetOwner(frame, "ANCHOR_BOTTOMRIGHT");
                if frame.hasdebuff == 1 then
                    GameTooltip:SetUnitDebuff("player", frame.id);
                else
                    GameTooltip:SetUnitBuff("player", frame.id);
                end
            end );
 
         ref:SetScript("OnLeave", function() 
                GameTooltip:Hide();
            end );
                         
        ref:EnableMouse(true);
        ref:Show();
       	
    end

end

-- create minimap button (thanks to gello's great lib)
function DHUD:CreateMMB()
    local info = {
        icon = "Interface\\Icons\\Ability_Druid_TravelForm",
        position = 0, -- default only. after first use, SavedVariables used
        drag = "CIRCLE", -- default only. after first use, SavedVariables used
        left = function() 
            self:OptionsFrame_Toggle();
        end,
        right = function() 
            if GetNumPartyMembers() > 0 or GetNumRaidMembers() > 0 then
                ToggleDropDownMenu(1, nil, DHUD_Player_DropDown, "DHUDMinimapButton" , 25, 10); 
            else
                self:print("You are not in Group/Raid!");
            end
        end,
        tooltip = "Left click: DHUD Options \nRight click: Player Menu",
        enabled = "ON" -- default only. after first use, SavedVariables used
    }
    MyMinimapButton:Create("DHUD", DHUD_Settings.mmb ,info)
end

-- MyAddonsSupport
function DHUD:myAddons()
    if (myAddOnsFrame_Register) then
        local DHUD_mya = {
            ["name"]         = "DHUD",
            ["version"]      = self.Config_default["version"],
            ["author"]       = "Drathal/Silberklinge (Markus Inger)",
            ["category"]     = MYADDONS_CATEGORY_COMBAT,
            ["email"]        = "dhud@markus-inger.de",
            ["website"]      = "http://www.markus-inger.de",
            ["optionsframe"] = "DHUDOptionsFrame",
        };
        myAddOnsFrame_Register(DHUD_mya);
    end
end

-- colorize bar
function DHUD:SetBarColor(bar,percent)
    local unit = self.name2unit[bar];
    local typ  = self.name2typ[bar];
    typunit = self:getTypUnit(unit,typ);
    local texture = _G[bar.."_Texture"];
    texture:SetVertexColor(self:Colorize(typunit,percent));
end

-- gettypeunit
function DHUD:getTypUnit(unit,typ)
    -- what power type?
    if typ == "mana" then
        if UnitPowerType(unit) then
			--self:print("Unit Power Type: "..UnitPowerType(unit) .. " unit: " .. unit);
            typ = self.powertypes[ UnitPowerType(unit)+1 ];
			-- Hellicopter in Howling Fjord returns UnitPowerType = -1; fixing it
			if not typ then
				typ = self.powertypes [4];
			end
        end
    end
    -- create index
    local typunit = typ.."_"..unit;
    -- default 
    if not self.BarColorTab[typunit] then
        typunit = "mana_pet";
    end
    -- only tap target bars
    if unit == "target" then
        if (UnitIsTapped("target") and (not UnitIsTappedByPlayer("target"))) then
            typunit = "tapped";
        end
    end
    return typunit;
end

-- Colorize
function DHUD:Colorize(typunit,percent)
    if not self.BarColorTab[typunit] then return 0,0,0; end
    local r, g, b, diff;
    local threshold1 = 0.6;    
    local threshold2 = 0.3;
    local color0 = self.BarColorTab[typunit][1];
    local color1 = self.BarColorTab[typunit][2];
    local color2 = self.BarColorTab[typunit][3];
            
    if ( percent <= threshold2 ) then
        r = color2.r;        
        g = color2.g;        
        b = color2.b;    
    elseif ( percent <= threshold1) then        
        diff = 1 - (percent - threshold2) / (threshold1 - threshold2);
        r = color1.r - (color1.r - color2.r) * diff;        
        g = color1.g - (color1.g - color2.g) * diff;        
        b = color1.b - (color1.b - color2.b) * diff;    
    elseif ( percent < 1) then        
        diff = 1 - (percent - threshold1) / (1 - threshold1);        
        r = color0.r - (color0.r - color1.r) * diff;        
        g = color0.g - (color0.g - color1.g) * diff;        
        b = color0.b - (color0.b - color1.b) * diff;    
    else       
        r = color0.r;
        g = color0.g;
        b = color0.b;    
    end 

    if (r < 0) then r = 0; end    
    if (r > 1) then r = 1; end    
    if (g < 0) then g = 0; end    
    if (g > 1) then g = 1; end    
    if (b < 0) then b = 0; end    
    if (b > 1) then b = 1; end     
    return r,g,b;
end

-- set bar height
function DHUD:SetBarHeight(bar,p)
    local texture = _G[bar.."_Texture"];
    
    -- Hide when Bar empty 
    if math.floor(p * 100) == 0 or UnitIsDeadOrGhost("player") then
        texture:Hide();
        return;
    end

    -- Textur Settings laden
    local typ, point, frame, relative, x, y, width, height = unpack( self.C_frames[bar] );
    local texname,x0,x1,y0,y1 = unpack(self.C_textures[bar]);
	if (self:TableContains(self.frames_have_texture_set, bar)) then
		texname = string.sub(texname, 0, string.len(texname) - 1);
	end
    local tex_height, tex_gap_top, tex_gap_bottom = unpack(self.C_tClips[texname]);
        
    -- offsets setzen wenn Balken nicht die ganze höhe ausfüllt
    local tex_gap_top_p    = tex_gap_top / tex_height;    
    local tex_gap_bottom_p = tex_gap_bottom / tex_height;
    local h = (tex_height - tex_gap_top - tex_gap_bottom) * p;
    
    -- Textursettings Ändern
    local top    = 1-(p-(tex_gap_top_p));
    local bottom = 1-tex_gap_bottom_p;
    top = top  - ((tex_gap_top_p+tex_gap_bottom_p)*(1-p));
    texture:SetHeight(h);
	--self:print("x0: ".. x0 .. " x1: " .. x1 .. " top: " .. top .. " bottom: " .. bottom .. " t_g_t_p: " .. tex_gap_top_p .. " t_g_b_p:" .. tex_gap_bottom_p .. " p: " .. p .. " bar: " .. bar);
    texture:SetTexCoord(x0, x1, top, bottom );
    texture:SetPoint(point, _G[frame], relative, x, tex_gap_bottom);
    texture:Show();
end;

-- show / hide combopoints
function DHUD:UpdateCombos()
	local points;
	if (not self.mcinvehicle or self.mcinvehicle == 0) then
		points = GetComboPoints("player","target")
		--self:print("Points: " .. points);
	elseif self.mcinvehicle == 1 then
		points = GetComboPoints("pet","target")
		--self:print("Points: " .. points);
	end
	if points == 0 then 
        DHUD_Combo1:Hide();
        DHUD_Combo2:Hide();
        DHUD_Combo3:Hide();
        DHUD_Combo4:Hide();
        DHUD_Combo5:Hide();
    elseif points == 1 then
        DHUD_Combo1:Show();
        DHUD_Combo2:Hide();
        DHUD_Combo3:Hide();
        DHUD_Combo4:Hide();
        DHUD_Combo5:Hide();       
    elseif points == 2 then
        DHUD_Combo1:Show();
        DHUD_Combo2:Show();
        DHUD_Combo3:Hide();
        DHUD_Combo4:Hide();
        DHUD_Combo5:Hide();        
    elseif points == 3 then
        DHUD_Combo1:Show();
        DHUD_Combo2:Show();
        DHUD_Combo3:Show();
        DHUD_Combo4:Hide();
        DHUD_Combo5:Hide();        
    elseif points == 4 then
        DHUD_Combo1:Show();
        DHUD_Combo2:Show();
        DHUD_Combo3:Show();
        DHUD_Combo4:Show();
        DHUD_Combo5:Hide();        
    elseif points == 5 then
        DHUD_Combo1:Show();
        DHUD_Combo2:Show();
        DHUD_Combo3:Show();
        DHUD_Combo4:Show();
        DHUD_Combo5:Show();       
    end
end

-- update target Auras
function DHUD:TargetAuras()
    
    local i, button, icon;
    local buffBorder, buffText, buffFrame;
    local debuffBorder, debuffText, debuffFrame;
    
    if DHUD_Settings["swaptargetauras"] == 0 then
        buffFrame   = "DHUD_Buff";
        debuffFrame = "DHUD_DeBuff";
    else
        debuffFrame = "DHUD_Buff";
        buffFrame   = "DHUD_DeBuff";    
    end

    -- Buffs
    for i = 1, 40 do
        local buffName, _, buffTexture, buffApplication = UnitBuff("target", i);
        button = _G[buffFrame..i];
        button.hasdebuff = nil;
        button.unit = "target";
        button.id = i;
        if DHUD_Settings["shownpc"] == 0 and self:TargetIsNPC() then
            button:Hide();
        elseif buffName and DHUD_Settings["showauras"] == 1 and DHUD_Settings["showtarget"] == 1 then
            icon = _G[button:GetName()];
            icon:SetNormalTexture(buffTexture);
            
            buffBorder = _G[button:GetName().."_Border"];
            buffBorder:Hide();
            
            buffText   = _G[button:GetName().."_Text"];
            if buffApplication <= 0 then
                buffText:SetText("");
            elseif buffApplication > 1 then
                buffText:SetText(buffApplication);
            else
                buffText:SetText("");
            end
            button:Show();
        else
            button:Hide();
        end
    end
        
    -- DeBuffs
    for i = 1, 40 do
        local debuffName, _, debuffTexture, debuffApplication, _, _, debufftimeLeft = UnitDebuff("target", i);
        button = _G[debuffFrame..i];
        button.hasdebuff = 1;
        button.unit = "target";
        button.id = i;
        if DHUD_Settings["shownpc"] == 0 and self:TargetIsNPC() then
            button:Hide();
        elseif debuffName and DHUD_Settings["showauras"] == 1 and DHUD_Settings["showtarget"] == 1 then
            icon = _G[button:GetName()];
            icon:SetNormalTexture(debuffTexture);
                        
            debuffBorder = _G[button:GetName().."_Border"];
            debuffBorder:Show();
			
			if DHUD_Settings["debufftimer"] == 1 then
				local color = {};
				local debuffTimeLeftText
				--self:print("debufftimeLeft: " .. debufftimeLeft);
	            debufftimeLeft = debufftimeLeft - GetTime();
				--self:print("debufftimeLeft2: " .. debufftimeLeft);
			    
	            if debufftimeLeft > 0 then
	                color.r, color.g, color.b = self:Colorize("aura_player", debufftimeLeft / 20);
					debuffTimeLeftText   = _G[button:GetName().."_TimeLeftText"];
	                debuffTimeLeftText:SetText("|cff"..DHUD_DecToHex(color.r, color.g, color.b)..DHUD_FormatTime(debufftimeLeft));
				else
					debuffTimeLeftText   = _G[button:GetName().."_TimeLeftText"];
	                debuffTimeLeftText:SetText("");
	            end
			else
					debuffTimeLeftText   = _G[button:GetName().."_TimeLeftText"];
					debuffTimeLeftText:SetText("");
			end
				
            debuffText   = _G[button:GetName().."_Text"];
            if debuffApplication <= 0 then
                debuffText:SetText("");
            elseif debuffApplication > 1 then
                debuffText:SetText(debuffApplication);
            else
                debuffText:SetText("");
            end
            button:Show();
        else
            button:Hide();
        end
    end
	
end

-- update player Auras
function DHUD:PlayerAuras()

    local i, icon, button, pbtimeLeft, pbtexture, pbcount, pbtype;
    --local pbrank, pbdebuffType, pbduration;
    local j = 1;
    local buffText;
	local buffCountText;
    local buffframe = "DHUD_PlayerBuff";
    local color = {};
	--added variable for debuffs
	local countbd = 40;
	
	--show debuffs
	if DHUD_Settings["playerdebuffs"] == 1 then
		countbd = 80;
	end
    
    -- Buffs
    if DHUD_Settings["showplayerbuffs"] == 1 and _G[buffframe .. "1"]:IsVisible() then
        for i = 1, countbd do
            -- WotLK GetPlayerBuff changed to UnitBuff
			if (not self.mcinvehicle or self.mcinvehicle == 0) then
				--show debuffs
				if DHUD_Settings["playerdebuffs"] == 1 and i>40 then
					buffI, _, pbtexture, pbcount, pbtype, _, pbtimeLeft  = UnitDebuff( "player", i-40, self.playerbufffilter );
				else
					buffI, _, pbtexture, pbcount, pbtype, _, pbtimeLeft  = UnitBuff( "player", i, self.playerbufffilter );
				end
           	elseif self.mcinvehicle == 1 then
				--show debuffs
				if DHUD_Settings["playerdebuffs"] == 1 and i>40 then
					buffI, _, pbtexture, pbcount, pbtype, _, pbtimeLeft  = UnitDebuff( "pet", i-40, self.playerbufffilter );
				else
					buffI, _, pbtexture, pbcount, pbtype, _, pbtimeLeft  = UnitBuff( "pet", i, self.playerbufffilter );
				end
			end
			
			-- don't show empty frames
            if (buffI==nil) then pbtimeLeft=0; 
			else 
			pbtimeLeft = pbtimeLeft - GetTime();
		            
            if (pbtimeLeft > 0 and pbtimeLeft < DHUD_Settings["playerbufftimefilter"]) or (DHUD_Settings["buffswithcharges"]==1 and pbcount>1) then
				button = _G[buffframe..j];
				
                if DHUD_Settings["playerdebuffs"] == 1 and i>40 then
					color.r, color.g, color.b = self:Colorize("debuffaura_player", pbtimeLeft / 20);
					if DHUD_Settings["playerdebuffscolorize"] == 1 then
						if (pbtype == "Magic")  then
							color.r, color.g, color.b = self:Colorize("debuffmagic", pbtimeLeft / 20);
						elseif (pbtype == "Disease")  then
							color.r, color.g, color.b = self:Colorize("debuffdisease", pbtimeLeft / 20);
						elseif (pbtype == "Poison")  then
							color.r, color.g, color.b = self:Colorize("debuffpoison", pbtimeLeft / 20);
						elseif (pbtype == "Curse")  then
							color.r, color.g, color.b = self:Colorize("debuffcurse", pbtimeLeft / 20);
						end
					end
					button.hasdebuff = 1;
					button.id = i-40;
				else
					color.r, color.g, color.b = self:Colorize("aura_player", pbtimeLeft / 20);
					button.hasdebuff = nil;
					button.id = i;
				end
               
                button.unit = "player";
                
                icon       = _G[button:GetName()];
                icon:SetNormalTexture(pbtexture);
                
                buffBorder = _G[button:GetName().."_Border"];
                buffBorder:SetVertexColor(color.r, color.g, color.b);
                buffBorder:Show();
                
                buffText   = _G[button:GetName().."_Text"];
				if pbtimeLeft > 0 then
				    buffText:SetText("|cff"..DHUD_DecToHex(color.r, color.g, color.b)..DHUD_FormatTime(pbtimeLeft));
				else
					buffText:SetText("");
				end
                
				if (pbcount > 1) then
					buffCountText   = _G[button:GetName().."_CountText"];
	                buffCountText:SetText("|cff"..DHUD_DecToHex(1, 1, 1)..pbcount);
				else
					buffCountText   = _G[button:GetName().."_CountText"];
	                buffCountText:SetText("");
				end
                button:Show();
                
                -- limited number of buff slots
                if j == 24 then
                    self:print("You have reached the buff limit. Contact MADCAT and ask for more buff slots");
                    break;
                else
                    j = j + 1;
                end
		end
            end
        end
    end

    -- hide the buttons not used
    for j = j, 24 do
        button = _G[buffframe..j];
        button.hasdebuff = nil;
        button.unit = "player";
        button.id = j;

        button:Hide();
    end
	
end

-- ######MADCAT: UpdateEnergy smoothly
function DHUD:MCUpdatePlayerEnergy()
    -- run only once a 1/10 second
    -- Currenttime
    -- local time  = GetTime();
    -- Run first time?
    -- if (lasttime==nil) then lasttime=time;
    -- end
    -- if (time - lasttime >= 0.1) then
    -- Lasttime = Current time
    -- lasttime = time;
    
	local frame = _G["DHUD_PlayerMana_Text"];
    
    local font = _G["DHUD_PlayerMana_Text".."_Text"];
    
    local text  = frame.text;
    -- mcplenergy = mcplenergy + 1;
	local mcplenergy = 0;
	local maxplenergytmp = 0;
	--vehicle support
	if self.mcinvehicle == 1 then 
		mcplenergy = UnitPower("pet");
		maxplenergytmp = self.mcplmaxenergy;
		self.mcplmaxenergy = UnitPowerMax("pet");
		if self.mcplmaxenergy==0 then
			self.mcplmaxenergy=100
		end
	else
		mcplenergy = UnitPower("player");
	end
    if (mcplenergy>self.mcplmaxenergy) then
		mcplenergy=self.mcplmaxenergy;
    end

    -- Update Bar
	if self.mcplmaxenergy == 0 then
		value = 0;
	else
	    value = tonumber(mcplenergy/self.mcplmaxenergy);
	end
    local bar  = self.text2bar["DHUD_PlayerMana_Text"];
    self.bar_values[bar] = value;
    if DHUD_Settings["animatebars"] == 0 or set then
        self.bar_anim[bar] = value;
        self:SetBarHeight(bar,value); 
        self:SetBarColor(bar,value);
    end       
    
    -- Set text
    value = math.floor(value * 100);
    local typunit = DHUD:getTypUnit(frame.unit,"mana");
    local color = DHUD_DecToHex(DHUD:Colorize(typunit,100));
    text = DHUD:gsub(text, '<color_mp>', "|cff"..color);
    text = DHUD:gsub(text, '<mp_value>', mcplenergy);
    text = DHUD:gsub(text, '</color>', '|r');
    text = DHUD:gsub(text, '<color>', '|cff');
    text = DHUD:gsub(text, '<mp_percent>', value.."%%");
	text = DHUD:gsub(text, '<mp_max>', self.mcplmaxenergy);
    -- text = string.gsub(text, "  "," ");
    -- text = string.gsub(text,"(^%s+)","");
    -- text = string.gsub(text,"(%s+$)","");
    font:SetText(text);
    -- end
	if self.mcinvehicle == 1 then
		self.mcplmaxenergy = maxplenergytmp;
	end
end

-- ######MADCAT: UpdatePetEnergy smoothly
function DHUD:MCUpdatePetEnergy()    
	local frame = _G["DHUD_PetMana_Text"];
    local font = _G["DHUD_PetMana_Text".."_Text"];
    
    local text  = frame.text;
	
	local mcpetenergy = 0;
	local maxpetenergytmp = 0;
	--vehicle support
	if self.mcinvehicle == 1 then 
		mcpetenergy = UnitPower("player");
		maxpetenergytmp = self.mcpetmaxenergy;
		self.mcpetmaxenergy = UnitPowerMax("player");
	else
		mcpetenergy = UnitPower("pet");
	end
    
    if (mcpetenergy>self.mcpetmaxenergy) then
		mcpetenergy=self.mcpetmaxenergy;
    end

    -- Update Bar
	if self.mcpetmaxenergy == 0 then
		value = 0;
	else
	    value = tonumber(mcpetenergy/self.mcpetmaxenergy);
	end
	
    local bar  = self.text2bar["DHUD_PetMana_Text"];
    self.bar_values[bar] = value;
    if DHUD_Settings["animatebars"] == 0 or set then
        self.bar_anim[bar] = value;
        self:SetBarHeight(bar,value); 
        self:SetBarColor(bar,value);
    end       
    
    -- Set text
    value = math.floor(value * 100);
    local typunit = DHUD:getTypUnit(frame.unit,"mana");
    local color = DHUD_DecToHex(DHUD:Colorize(typunit,100));
    text = DHUD:gsub(text, '<color_mp>', "|cff"..color);
    text = DHUD:gsub(text, '<mp_value>', mcpetenergy);
    text = DHUD:gsub(text, '</color>', '|r');
    text = DHUD:gsub(text, '<color>', '|cff');
    text = DHUD:gsub(text, '<mp_percent>', value.."%%");
	text = DHUD:gsub(text, '<mp_max>', self.mcpetmaxenergy);	
    -- text = string.gsub(text, "  "," ");
    -- text = string.gsub(text,"(^%s+)","");
    -- text = string.gsub(text,"(%s+$)","");
    font:SetText(text);
    -- end
	if self.mcinvehicle == 1 then
		self.mcpetmaxenergy = maxpetenergytmp;
	end
end

-- ######MADCAT: DK Runes CD
function DHUD:MCDKRunes()
	local i, start, duration, runeReady, runeType;
	local startText, startText2;
	local color = {};
	for i = 1, 6 do
		start, duration, runeReady = GetRuneCooldown(i);
		if start > 0 then
			start = duration - (GetTime() - start);
		end
		
		--self:print("RuneID: " .. i .. " CD: ".. start.. " duration: ".. duration..  " runeType: " .. runeType);
		--if runeReady==1 then 
		--	self:print("RuneID: " .. i .. " ready");
		--end
		if start > 0 then
	        color.r, color.g, color.b = self:Colorize("aura_player", start / 20);			
			startText = _G["DHUD_Rune".. i .. "_Text_Text"];
			startText:SetText("|cff"..DHUD_DecToHex(color.r, color.g, color.b)..DHUD_FormatTime(start));
			runeType = GetRuneType(i);
			
			--local runetexture = _G["DHUD_Rune"..i.."_Texture"];
		    --runetexture:SetTexture( "Interface\\PlayerFrame\\UI-PlayerFrame-Deathknight-Death" );
			
			--change texture for rune if needed
			if not (runeType == _G["mcdkrune"..i]) then
				if i == 1 then
					self.mcdkrune1=runeType;
				elseif i == 2 then
					self.mcdkrune2=runeType;
				elseif i == 3 then
					self.mcdkrune3=runeType;
				elseif i == 4 then
					self.mcdkrune4=runeType;
				elseif i == 5 then
					self.mcdkrune5=runeType;
				elseif i == 6 then
					self.mcdkrune6=runeType;
				end
				if runeType == 1 then
					local runetexture = _G["DHUD_Rune"..i.."_Texture"];
		            runetexture:SetTexture( "Interface\\PlayerFrame\\UI-PlayerFrame-Deathknight-Blood" );
				elseif runeType == 2 then
					local runetexture = _G["DHUD_Rune"..i.."_Texture"];
		            runetexture:SetTexture( "Interface\\PlayerFrame\\UI-PlayerFrame-Deathknight-Unholy" );
				elseif runeType == 3 then
					local runetexture = _G["DHUD_Rune"..i.."_Texture"];
		            runetexture:SetTexture( "Interface\\PlayerFrame\\UI-PlayerFrame-Deathknight-Frost" );
				elseif runeType == 4 then
					local runetexture = _G["DHUD_Rune"..i.."_Texture"];
		            runetexture:SetTexture( "Interface\\PlayerFrame\\UI-PlayerFrame-Deathknight-Death" );
				end
			end
			--local runeid = math.floor((i+1)/2);
			--self:print("runeid: " .. runeid .. " i: " .. i);
			--1 : RUNETYPE_BLOOD 
			--2 : RUNETYPE_CHROMATIC 
			--3 : RUNETYPE_FROST 
			--4 : RUNETYPE_DEATH
			--startText = _G["DHUD_PlayerHealth_Text_Text"];
			--("|cff"..DHUD_DecToHex(color.r, color.g, color.b)..DHUD_FormatTime(start));
			--startText:SetFont( self.defaultfont, 14, "OUTLINE");
			--self:print("|cff"..DHUD_DecToHex(color.r, color.g, color.b)..DHUD_FormatTime(start));
		else
			startText = _G["DHUD_Rune".. i .. "_Text_Text"];
	        startText:SetText("");
	    end
	end		
end

-- ######MADCAT: Pally Holly Power
function DHUD:MCPallyHollyPower()
	if (self.CastingAlpha == 0) then
		return;
	end
	local points;
	if (not self.mcinvehicle or self.mcinvehicle == 0) then
		points = UnitPower("player", 9);
	else
		if (self.mccpmoved == 1) then
			local point, frame, relative, x, y = DHUD_Combo4:GetPoint();
			local epoint, eframe, erelative, ex, ey = DHUD_Combo2:GetPoint();
			DHUD_Combo4:SetPoint(epoint, eframe, erelative, ex, ey);
			DHUD_Combo2:SetPoint(point, frame, relative, x, y);
			point, frame, relative, x, y = DHUD_Combo5:GetPoint();
			epoint, eframe, erelative, ex, ey = DHUD_Combo3:GetPoint();
			DHUD_Combo5:SetPoint(epoint, eframe, erelative, ex, ey);
			DHUD_Combo3:SetPoint(point, frame, relative, x, y);
			self.mccpmoved = 0;
		end
		return;
	end
	if points == 0 then
        DHUD_Combo1:Hide();
        DHUD_Combo2:Hide();
        DHUD_Combo3:Hide();
        DHUD_Combo4:Hide();
        DHUD_Combo5:Hide();
    else
		-- exchange combo point position, so red, yellow and green points are placed nearby
		if (self.mccpmoved == 0) then
			local point, frame, relative, x, y = DHUD_Combo4:GetPoint();
			local epoint, eframe, erelative, ex, ey = DHUD_Combo2:GetPoint();
			DHUD_Combo4:SetPoint(epoint, eframe, erelative, ex, ey);
			DHUD_Combo2:SetPoint(point, frame, relative, x, y);
			point, frame, relative, x, y = DHUD_Combo5:GetPoint();
			epoint, eframe, erelative, ex, ey = DHUD_Combo3:GetPoint();
			DHUD_Combo5:SetPoint(epoint, eframe, erelative, ex, ey);
			DHUD_Combo3:SetPoint(point, frame, relative, x, y);
			self.mccpmoved = 1;
			
		end
		if points == 1 then
			DHUD_Combo1:Show();
			DHUD_Combo2:Hide();
			DHUD_Combo3:Hide();
			DHUD_Combo4:Hide();
			DHUD_Combo5:Hide();       
		elseif points == 2 then
			DHUD_Combo1:Show();
			DHUD_Combo2:Hide();
			DHUD_Combo3:Hide();
			DHUD_Combo4:Show();
			DHUD_Combo5:Hide();        
		elseif points == 3 then
			DHUD_Combo1:Show();
			DHUD_Combo2:Hide();
			DHUD_Combo3:Hide();
			DHUD_Combo4:Show();
			DHUD_Combo5:Show();
		end
	end
end

-- ######MADCAT: Warlock Shards
function DHUD:MCWarlockShards()
	if (self.CastingAlpha == 0) then
		return;
	end
	local points;
	if (not self.mcinvehicle or self.mcinvehicle == 0) then
		points = UnitPower("player", 7);
	else
		if (self.mccpmoved == 1) then
			local point, frame, relative, x, y = DHUD_Combo4:GetPoint();
			local epoint, eframe, erelative, ex, ey = DHUD_Combo2:GetPoint();
			DHUD_Combo4:SetPoint(epoint, eframe, erelative, ex, ey);
			DHUD_Combo2:SetPoint(point, frame, relative, x, y);
			point, frame, relative, x, y = DHUD_Combo5:GetPoint();
			epoint, eframe, erelative, ex, ey = DHUD_Combo3:GetPoint();
			DHUD_Combo5:SetPoint(epoint, eframe, erelative, ex, ey);
			DHUD_Combo3:SetPoint(point, frame, relative, x, y);
			self.mccpmoved = 0;
		end
		return;
	end
	if points == 0 then
        DHUD_Combo1:Hide();
        DHUD_Combo2:Hide();
        DHUD_Combo3:Hide();
        DHUD_Combo4:Hide();
        DHUD_Combo5:Hide();
    else
		-- exchange combo point position, so red, yellow and green points are placed nearby
		if (self.mccpmoved == 0) then
			local point, frame, relative, x, y = DHUD_Combo4:GetPoint();
			local epoint, eframe, erelative, ex, ey = DHUD_Combo2:GetPoint();
			DHUD_Combo4:SetPoint(epoint, eframe, erelative, ex, ey);
			DHUD_Combo2:SetPoint(point, frame, relative, x, y);
			point, frame, relative, x, y = DHUD_Combo5:GetPoint();
			epoint, eframe, erelative, ex, ey = DHUD_Combo3:GetPoint();
			DHUD_Combo5:SetPoint(epoint, eframe, erelative, ex, ey);
			DHUD_Combo3:SetPoint(point, frame, relative, x, y);
			self.mccpmoved = 1;
			
		end
		if points == 1 then
			DHUD_Combo1:Show();
			DHUD_Combo2:Hide();
			DHUD_Combo3:Hide();
			DHUD_Combo4:Hide();
			DHUD_Combo5:Hide();       
		elseif points == 2 then
			DHUD_Combo1:Show();
			DHUD_Combo2:Hide();
			DHUD_Combo3:Hide();
			DHUD_Combo4:Show();
			DHUD_Combo5:Hide();        
		elseif points == 3 then
			DHUD_Combo1:Show();
			DHUD_Combo2:Hide();
			DHUD_Combo3:Hide();
			DHUD_Combo4:Show();
			DHUD_Combo5:Show();
		end
	end
end



-- is unit npc?
function DHUD:TargetIsNPC()
    if UnitExists("target") and not UnitIsPlayer("target") and not UnitCanAttack("player", "target") and not UnitPlayerControlled("target") then
        return true;
    else
        return false;
    end
end

-- is unit pet?
function DHUD:TargetIsPet()
    if not UnitIsPlayer("target") and not UnitCanAttack("player", "target") and UnitPlayerControlled("target") then
        return true;
    else
        return false;
    end
end

-- Update Values
function DHUD:UpdateValues(frame,set)
    local value;
	
	--vehicle support
	if self.mcinvehicle == 1 then
		if (frame == "DHUD_PetHealth_Text") then
			frame = "DHUD_PlayerHealth_Text";
		elseif (frame == "DHUD_PlayerHealth_Text") then
			frame = "DHUD_PetHealth_Text";
		elseif (frame == "DHUD_PlayerMana_Text") then
			frame = "DHUD_PetMana_Text";
		elseif (frame == "DHUD_PetMana_Text") then
			frame = "DHUD_PlayerMana_Text";
		end
	end
	
    local bar  = self.text2bar[frame];
	local unit = self.name2unit[bar];
    local typ  = self.name2typ[bar];
    local ref  = _G[frame.. "_Text"];    
    self.PetneedMana   = nil;
    self.PetneedHealth = nil;
    
	--vehicle support
	if self.mcinvehicle == 1 then
		if (unit == "player") then
			unit = "pet";
		elseif (unit == "pet") then
			unit = "player";
		end
	end
	
	if ( UnitExists(unit) ) then
	    if typ == "health" then
		
			--TODO: to increase perfomance  save functions results to variables instead of calling then 5 times
			
			if UnitHealthMax(unit)==0 then
				value = 0;
			elseif UnitHealth(unit)>UnitHealthMax(unit) then
				value = 1;
			else
			    value = tonumber(UnitHealth(unit)/UnitHealthMax(unit));
			end			
	    else
		
			--TODO: to increase perfomance  save functions results to variables instead of calling then 5 times
			--3.1 if mana > max - set percent to 100
			--self:print("UnitPower: " .. UnitPower(unit) .. " UnitPowerMax: " .. UnitPowerMax(unit));
			if UnitPowerMax(unit)==0 then
				value = 0;
			elseif UnitPower(unit)>UnitPowerMax(unit) then
				value = 1;
			else
			    value = tonumber(UnitPower(unit)/UnitPowerMax(unit));
			end
	    end
	else
		value = 0;
	end 
	
	--self:print("Frame: " .. frame .. " Unit:" .. unit .. " Value: " .. value);
	
	--vehicle support
	if self.mcinvehicle == 1 then
		if (frame == "DHUD_PlayerHealth_Text" or frame == "DHUD_PetHealth_Text") then
			local updating = 0;
			if frame == "DHUD_PetHealth_Text" then
				frame = "DHUD_PlayerHealth_Text";
				unit = "pet";
				updating = 1;
			end
			local text = _G[frame].text;
			local font = _G[frame.."_Text"];
			
			local health = UnitHealth(unit);
            local healthmax = UnitHealthMax(unit);
			local percent = 0; -- = health/healthmax;
            if (healthmax > 0 and UnitExists(unit) ) then
                percent = health/healthmax;
                local typunit = DHUD:getTypUnit(unit,"health")
                local color = DHUD_DecToHex(DHUD:Colorize(typunit,percent));
                text = DHUD:gsub(text, '<color_hp>', "|cff"..color );
            else
                text = DHUD:gsub(text, '<color_hp>', "|cffffffff" );
            end
			
			--self:print("Health: " .. health .. " self.mcinvehicle = " .. self.mcinvehicle);	
			--text = DHUD:gsub(text, '<color_hp>', "|cff"..color);
			percent = math.floor(percent * 100);
			text = DHUD:gsub(text, '<hp_value>', health);
		    text = DHUD:gsub(text, '</color>', '|r');
		    text = DHUD:gsub(text, '<color>', '|cff');
		    text = DHUD:gsub(text, '<hp_percent>', percent.."%%");
			text = DHUD:gsub(text, '<hp_max>', healthmax);	
			font:SetText(text);
			
			if (DHUD_Settings["showpet"] == 1) then
				unit = "player";
				text = _G["DHUD_PetHealth_Text"].text;
				font = _G["DHUD_PetHealth_Text".."_Text"];
				
				health = UnitHealth(unit);
	            healthmax = UnitHealthMax(unit);
				percent = 0; -- = health/healthmax;
	            if (healthmax > 0 and UnitExists(unit) ) then
	                percent = health/healthmax;
	                local typunit = DHUD:getTypUnit(unit,"health")
	                local color = DHUD_DecToHex(DHUD:Colorize(typunit,percent));
	                text = DHUD:gsub(text, '<color_hp>', "|cff"..color );
	            else
	                text = DHUD:gsub(text, '<color_hp>', "|cffffffff" );
	            end
				
				--self:print("Health: " .. health .. " self.mcinvehicle = " .. self.mcinvehicle);	
				--text = DHUD:gsub(text, '<color_hp>', "|cff"..color);
				percent = math.floor(percent * 100);
				text = DHUD:gsub(text, '<hp_value>', health);
			    text = DHUD:gsub(text, '</color>', '|r');
			    text = DHUD:gsub(text, '<color>', '|cff');
			    text = DHUD:gsub(text, '<hp_percent>', percent.."%%");
				text = DHUD:gsub(text, '<hp_max>', healthmax);	
				font:SetText(text);
			end
			unit = "pet"
			if updating == 1 then
				updating = 0;
				unit = "player"
			end
			
		end
		if (unit == "player") then
			unit = "pet";
		elseif (unit == "pet") then
			unit = "player";
		end
	end
    
    -- hide pet?
    if unit == "pet" and DHUD_Settings["showpet"] == 0 then
        value = 0;
    end

    -- hide target?
    if unit == "target" and DHUD_Settings["showtarget"] == 0 then
        value = 0;
    end
        
    -- Druidbar support
    if unit == "pet" and typ == "mana" and self.player_class == "DRUID" then
       if UnitPowerType("player") ~= 0 then
           value = tonumber( UnitPower("player",0) / UnitPowerMax("player",0) );
           if math.floor(value * 100) == 100 then
               self.PetneedMana = nil;
           else
               self.PetneedMana = 1;
           end
       else
           value = 0;
           set   = 1;
       end
    end
        
    self.bar_values[bar] = value;
    
    if typ == "health" and unit == "player" then
        if math.floor(value * 100) == 100 then
            self.needHealth = nil;
        else
            self.needHealth = true;
        end
    elseif typ == "mana" and unit == "player" then
        local type = self.powertypes[ UnitPowerType(unit)+1 ];
        if (type == "rage" or type == "runic_power") then
            if math.floor(value * 100) == 100 then
                self.needMana = true;
            else
                self.needMana = nil;
            end
        else
            if math.floor(value * 100) == 100 then
                self.needMana = nil;
            else
                self.needMana = true;
            end
        end
    elseif typ == "mana" and unit == "pet" and self.player_class ~= "DRUID" and DHUD_Settings["showpet"] == 1 and UnitExists(unit) then    
        if math.floor(value * 100) == 100 then
            self.PetneedMana = nil;
        else
            self.PetneedMana = true;
        end
    elseif typ == "health" and unit == "pet" and DHUD_Settings["showpet"] == 1 and UnitExists(unit) then
        if math.floor(value * 100) == 100 then
            self.PetneedHealth = nil;
        else
            self.PetneedHealth = true;
        end 
    end
    
    if DHUD_Settings["animatebars"] == 0 or set then
        self.bar_anim[bar] = value;
		self:SetBarHeight(bar,value); 
        self:SetBarColor(bar,value);
    end       
end

-- animate bars
function DHUD:Animate(bar)

    -- base Ãndern
    local ph  = math.floor(self.bar_values[bar] * 100);
    local pha = math.floor(self.bar_anim[bar] * 100);

    -- AbwÃ¤rts animieren
    if ph < pha then
        self.bar_change[bar] = 1;
        if pha - ph > 10 then
            self.bar_anim[bar] = self.bar_anim[bar] - self.stepfast;
        else
            self.bar_anim[bar] = self.bar_anim[bar] - self.step;
        end   
    -- AufwÃ¤rts animieren
    elseif ph > pha then
        self.bar_change[bar] = 1;
        if ph - pha > 10 then
            self.bar_anim[bar] = self.bar_anim[bar] + self.stepfast;
        else
            self.bar_anim[bar] = self.bar_anim[bar] + self.step;
        end
    end

    -- Anim 
    if self.bar_change[bar] then
        self:SetBarHeight(bar, self.bar_anim[bar] );
        self:SetBarColor(bar, self.bar_anim[bar] );
        self.bar_change[bar] = nil;
    end
end

-- update Background Texture
function DHUD:ChangeBackgroundTexture()
   
    if DHUD_Settings["barborders"] == 1 then
                                    
        -- check target
        if UnitExists("target") and DHUD_Settings["showtarget"] == 1 then 
            -- npc anzeigen?
            if self:TargetIsNPC() and DHUD_Settings["shownpc"] == 0 then
                self.has_target_health = nil;
                self.has_target_mana   = nil;
            else
                -- check health
                if UnitHealthMax("target") then 
                    self.has_target_health = 1;
                else
                    self.has_target_health = nil;
                end
                -- check mana
                if UnitPowerMax("target") > 0 then 
                    self.has_target_mana = 1;
                else
                    self.has_target_mana = nil;
                end       
            end
        else
            self.has_target_health = nil;
            self.has_target_mana   = nil;
        end

        -- check pet
        self.has_pet_health = nil;
        self.has_pet_mana   = nil;
        if DHUD_Settings["showpet"] == 1 then
            if ( UnitName("pet") ) then 
                if UnitHealthMax("pet") then 
                    self.has_pet_health = 1;
                end
    
                if UnitPowerMax("pet") > 0 then 
                    self.has_pet_mana = 1;
                end              
            end
        end
        
        -- check druidbar
        if self.player_class == "DRUID" then
            if UnitPowerType("player") ~= 0 then
                self.has_pet_mana = 1;
            else
                self.has_pet_mana = nil;
            end
        end
    
        local what = "ph_pm";
        if self.has_pet_health    then what = what.."_eh"; end
        if self.has_pet_mana      then what = what.."_em"; end
        if self.has_target_health then what = what.."_th"; end
        if self.has_target_mana   then what = what.."_tm"; end
		-- Create DHUD Background for enemyes that can cast
		if not (self.has_target_mana) and self.mctargetcancast == 1 and self.has_target_health then what = what.."_tm"; end
		
        
        local texture,x0,x1,y0,y1;
        if type(self.C_textures["l_"..what]) == "table" then
            texture,x0,x1,y0,y1 = unpack( self.C_textures["l_"..what] );
            _G["DHUD_LeftFrame_Texture"]:SetTexture(texture);
            _G["DHUD_LeftFrame_Texture"]:SetTexCoord(x0,x1,y0,y1);
        else
            self:print("Please report MADCAT this String: "..what);
        end
        
        if type(self.C_textures["l_"..what]) == "table" then
            texture,x0,x1,y0,y1 = unpack( self.C_textures["r_"..what] );
            _G["DHUD_RightFrame_Texture"]:SetTexture(texture);
            _G["DHUD_RightFrame_Texture"]:SetTexCoord(x0,x1,y0,y1);
        else
            self:print("Please report MADCAT this String: "..what);
        end        
    end
    
    if UnitIsDeadOrGhost("player") then
        _G["DHUD_PlayerHealth_Text"]:Hide();
        _G["DHUD_PlayerMana_Text"]:Hide();
        _G["DHUD_PetHealth_Text"]:Hide();
        _G["DHUD_PetMana_Text"]:Hide();
        _G["DHUD_RightFrame_Texture"]:Hide();
        _G["DHUD_LeftFrame_Texture"]:Hide();
    else
        _G["DHUD_PlayerHealth_Text"]:Show();
        _G["DHUD_PlayerMana_Text"]:Show();
        _G["DHUD_PetHealth_Text"]:Show();
        _G["DHUD_PetMana_Text"]:Show();
        if DHUD_Settings["barborders"] == 1 then
            _G["DHUD_RightFrame_Texture"]:Show();
            _G["DHUD_LeftFrame_Texture"]:Show();
        else
            _G["DHUD_RightFrame_Texture"]:Hide();
            _G["DHUD_LeftFrame_Texture"]:Hide();        
        end
    end  
    
    -- show elite icon?
    if self:CheckElite("target") and DHUD_Settings["shownpc"] == 1 and DHUD_Settings["showtarget"] == 1 and DHUD_Settings["showeliteicon"] == 1 then
        local elite = self:CheckElite("target");
        local tex;
        if elite == "++" or elite == "+" then
            tex = "DHUD_TargetElite";
        elseif elite == "r" or elite == "r+" then
            tex = "DHUD_TargetRare";
        end
        local texture,x0,x1,y0,y1 = unpack( self.C_textures[tex] );
        _G["DHUD_TargetElite_Texture"]:SetTexture(texture);
        _G["DHUD_TargetElite_Texture"]:SetTexCoord(x0,x1,y0,y1);
        _G["DHUD_TargetElite"]:Show();
    else
        _G["DHUD_TargetElite"]:Hide();
    end
    
    -- update Player Pvp
    self:updatePlayerPvP();
       
end

-- safe gsub
function DHUD:gsub(text, var, value)
	if (value) then
		text = string.gsub(text, var, value);
	else
		text = string.gsub(text, var, "");
	end
	return text;
end

-- update Alpha
function DHUD:updateAlpha()

    -- Combat Mode
    if self.inCombat then
        self:setAlpha("combatalpha");
    -- target selected    	    
    elseif self.Target then
        self:setAlpha("selectalpha");
    -- Player / Pet reg
    elseif self.needHealth or self.needMana or self.PetneedHealth or self.PetneedMana then
        self:setAlpha("regenalpha");
    -- Casting
    elseif self.Casting then
        self:setAlpha("regenalpha");	
	--EnemyCasting
	elseif self.mcenemycasting then
		self:setAlpha("regenalpha");
    -- standard mode     	    		       
    else
        self:setAlpha("oocalpha");
    end
    
end
                
-- set alpha (combatalpha oocalpha selectalpha regenalpha)
function DHUD:setAlpha(mode)
    self:printd("Alphamode: "..mode);

    for k, v in pairs(self.alpha_textures) do
        local texture = _G[v];
        texture:SetAlpha(DHUD_Settings[mode]);
    end
    self.CastingAlpha = DHUD_Settings[mode];
    
    -- hide player text when alpha = 0 
    if DHUD_Settings[mode] == 0 then
		_G["DHUD_PlayerHealth_Text"]:Hide();
        _G["DHUD_PlayerMana_Text"]:Hide();
        _G["DHUD_PetHealth_Text"]:Hide();
        _G["DHUD_PetMana_Text"]:Hide();
        _G["DHUD_PlayerBuff1"]:Hide();
        _G["DHUD_PlayerBuff2"]:Hide();
        _G["DHUD_PlayerBuff3"]:Hide();
        _G["DHUD_PlayerBuff4"]:Hide();
        _G["DHUD_PlayerBuff5"]:Hide();
        _G["DHUD_PlayerBuff6"]:Hide();
        _G["DHUD_PlayerBuff7"]:Hide();
        _G["DHUD_PlayerBuff8"]:Hide();
        _G["DHUD_PlayerBuff9"]:Hide();
        _G["DHUD_PlayerBuff10"]:Hide();
        _G["DHUD_PlayerBuff11"]:Hide();
        _G["DHUD_PlayerBuff12"]:Hide();
        _G["DHUD_PlayerBuff13"]:Hide();
        _G["DHUD_PlayerBuff14"]:Hide();
        _G["DHUD_PlayerBuff15"]:Hide();
        _G["DHUD_PlayerBuff16"]:Hide();
		_G["DHUD_Rune1_Text"]:Hide();
		_G["DHUD_Rune2_Text"]:Hide();
		_G["DHUD_Rune3_Text"]:Hide();
		_G["DHUD_Rune4_Text"]:Hide();
		_G["DHUD_Rune5_Text"]:Hide();
		_G["DHUD_Rune6_Text"]:Hide();
		_G["DHUD_Combo1"]:Hide();
		_G["DHUD_Combo2"]:Hide();
		_G["DHUD_Combo3"]:Hide();
		_G["DHUD_Combo4"]:Hide();
		_G["DHUD_Combo5"]:Hide();
    elseif not UnitIsDeadOrGhost("player") then
        _G["DHUD_PlayerHealth_Text"]:Show();
        _G["DHUD_PlayerMana_Text"]:Show();  
        _G["DHUD_PetHealth_Text"]:Show();
        _G["DHUD_PetMana_Text"]:Show(); 
        _G["DHUD_PlayerBuff1"]:Show();
        _G["DHUD_PlayerBuff2"]:Show();
        _G["DHUD_PlayerBuff3"]:Show();
        _G["DHUD_PlayerBuff4"]:Show();
        _G["DHUD_PlayerBuff5"]:Show();
        _G["DHUD_PlayerBuff6"]:Show();
        _G["DHUD_PlayerBuff7"]:Show();
        _G["DHUD_PlayerBuff8"]:Show();
        _G["DHUD_PlayerBuff9"]:Show();
        _G["DHUD_PlayerBuff10"]:Show();
        _G["DHUD_PlayerBuff11"]:Show();
        _G["DHUD_PlayerBuff12"]:Show();
        _G["DHUD_PlayerBuff13"]:Show();
        _G["DHUD_PlayerBuff14"]:Show();
        _G["DHUD_PlayerBuff15"]:Show();
        _G["DHUD_PlayerBuff16"]:Show();
		_G["DHUD_Rune1_Text"]:Show();
		_G["DHUD_Rune2_Text"]:Show();
		_G["DHUD_Rune3_Text"]:Show();
		_G["DHUD_Rune4_Text"]:Show();
		_G["DHUD_Rune5_Text"]:Show();
		_G["DHUD_Rune6_Text"]:Show();
		self:UpdateCombos();
    end 
end

-- is target elite?
function DHUD:CheckElite(unit)
  local el = UnitClassification(unit);
  local ret;
  if ( el == "worldboss" ) then
        ret = "++";
  elseif ( el == "rareelite"  ) then
        ret = "r+";
  elseif ( el == "elite"  ) then
        ret = "+";
  elseif ( el == "rare"  ) then
        ret = "r";
  else
        ret = nil;
  end
  return ret;
end

-- unit reaction
function DHUD:GetReactionColor(unit)
	local i;
	if (UnitIsPlayer(unit)) then
		if (UnitIsPVP(unit)) then
			if (UnitCanAttack("player", unit)) then
				i = 1;
			else
				i = 5;
			end
		else
			if (UnitCanAttack("player", unit) or UnitFactionGroup(unit) ~= UnitFactionGroup("player")) then
				i = 2;
			else
				i = 4;
			end
		end
	elseif (UnitIsTapped(unit) and (not UnitIsTappedByPlayer(unit))) then
		i = 6;
	else
		local reaction = UnitReaction(unit, "player");
		if (reaction) then
			if (reaction < 4) then
				i = 1;
			elseif (reaction == 4) then
				i = 2;
			else
				i = 3;
			end
		end
	end
	
	return self.ReacColors[i];
end

-- resting status
function DHUD:updateStatus()
    if self.inCombat and DHUD_Settings["showcombaticon"] == 1 then
        _G["DHUD_PlayerInCombat"]:Show();
        return;
    else
        _G["DHUD_PlayerInCombat"]:Hide();
    end
    
    if IsResting() and DHUD_Settings["showresticon"] == 1 and not UnitIsDeadOrGhost("player") then
        _G["DHUD_PlayerResting"]:Show();
    else
        _G["DHUD_PlayerResting"]:Hide();
    end
end

-- raid icon
function DHUD:updateRaidIcon()
    local tex = _G["DHUD_RaidIcon_Texture"];
    local texture = nil;
    
    if DHUD_Settings["showraidicon"] == 1 and UnitExists("target") then
        local index = GetRaidTargetIndex("target");
        
        if index and index > 0 and index <= 8 then
            texture,x0,x1,y0,y1 = unpack( self.C_textures["DHUD_RaidIcon" .. index] );
        end
        
        if texture then
            tex:SetTexture(texture);
            tex:SetTexCoord(x0,x1,y0,y1);
            _G["DHUD_RaidIcon"]:Show();
        else
            _G["DHUD_RaidIcon"]:Hide();
        end
    else
        _G["DHUD_RaidIcon"]:Hide();
    end
end


-- pvp status
function DHUD:updatePlayerPvP()    
    local tex = _G["DHUD_PlayerPvP_Texture"];
    local texture = nil;
    if DHUD_Settings["showplayerpvpicon"] == 1 and not UnitIsDeadOrGhost("player") then
        if UnitIsPVPFreeForAll("player")  then
            texture,x0,x1,y0,y1 = unpack( self.C_textures["DHUD_FreePvP"] );
        elseif UnitIsPVP("player") then
            local faction = UnitFactionGroup("player");
            if faction == "Horde" then
                texture,x0,x1,y0,y1 = unpack( self.C_textures["DHUD_TargetPvP"] );
            else
                texture,x0,x1,y0,y1 = unpack( self.C_textures["DHUD_PlayerPvP"] );
            end
        end
        if texture then
            tex:SetTexture(texture);
            tex:SetTexCoord(x0,x1,y0,y1);
            _G["DHUD_PlayerPvP"]:Show();
        else
            _G["DHUD_PlayerPvP"]:Hide();
        end
    else
        _G["DHUD_PlayerPvP"]:Hide();
    end
end

-- pvp icon target
function DHUD:updateTargetPvP()    
    local tex = _G["DHUD_TargetPvP_Texture"];
    local texture = nil;
    local x0,x1,y0,y1;
    if DHUD_Settings["showtargetpvpicon"] == 1 and not self:TargetIsNPC() and DHUD_Settings["showtarget"] == 1 then
        if UnitIsPVPFreeForAll("target")  then
            texture,x0,x1,y0,y1 = unpack( self.C_textures["DHUD_FreePvP"] );
        elseif UnitIsPVP("target") then
            local faction = UnitFactionGroup("target");
            if faction == "Horde" then
                texture,x0,x1,y0,y1 = unpack( self.C_textures["DHUD_TargetPvP"] );
            else
                texture,x0,x1,y0,y1 = unpack( self.C_textures["DHUD_PlayerPvP"] );
            end
        end
        if texture then
            tex:SetTexture(texture);
            tex:SetTexCoord(x0,x1,y0,y1);
            _G["DHUD_TargetPvP"]:Show();
        else
            _G["DHUD_TargetPvP"]:Hide();
        end
    else
        _G["DHUD_TargetPvP"]:Hide();
    end
end

-- pet icon
function DHUD:updatePetIcon()
    if self.has_pet_health ~= nil and DHUD_Settings["showpeticon"] == 1 then
        local texture = nil;
        local x0,x1,y0,y1;
        local happiness, _, _ = GetPetHappiness();
        
        if happiness == 1 then
            texture,x0,x1,y0,y1 = unpack( self.C_textures["DHUD_PetUnhappy"] );
        elseif happiness == 2 then
            texture,x0,x1,y0,y1 = unpack( self.C_textures["DHUD_PetNormal"] );
        elseif happiness == 3 then
            texture,x0,x1,y0,y1 = unpack( self.C_textures["DHUD_PetHappy"] );
        end
        
        if texture then
            local tex = _G["DHUD_PetHappy_Texture"];
            tex:SetTexture(texture);
            tex:SetTexCoord(x0,x1,y0,y1);	
            _G["DHUD_PetHappy"]:Show();
        else
            _G["DHUD_PetHappy"]:Hide();
        end
    else
        _G["DHUD_PetHappy"]:Hide();
    end
end

-- Toggle Options
function DHUD:OptionsFrame_Toggle()
    if not DHUDOptionsFrame then
        LoadAddOn("DHUD_Options");
    end
    
    if(DHUDOptionsFrame:IsVisible()) then
        DHUDOptionsFrame:Hide();
    else
        DHUDOptionsFrame:Show();
    end

end

-- target dropdown
function DHUD_Target_DropDown_Initialize(frame)
    local menu = nil;
    if (UnitIsEnemy("target", "player")) then
        return;
    end
    if (UnitIsUnit("target", "player")) then
        menu = "SELF";
    elseif (UnitIsUnit("target", "pet")) then
        menu = "PET";
    elseif (UnitIsPlayer("target")) then
        if (UnitInParty("target")) then
            menu = "PARTY";
        else
            menu = "PLAYER";
        end
    end
    
    if menu then
        UnitPopup_ShowMenu( frame, menu, "target" );
    end
end

-- player dropdown
function DHUD_Player_DropDown_Initialize(frame)
    UnitPopup_ShowMenu( frame, "SELF", "player" );
end

-- print Debug --
function DHUD:printd(msg)
    if DEFAULT_CHAT_FRAME and self.debug then
	   DEFAULT_CHAT_FRAME:AddMessage("DHUD Debug: "..(msg or "null"), 1,0.5,0.5);
	end
end

-- print Message --
function DHUD:print(msg)
    if DEFAULT_CHAT_FRAME then
	   DEFAULT_CHAT_FRAME:AddMessage("|cff88ff88DHUD:|r "..(msg or "null"), 1,1,1);
	end
end

-- setdefault Config
function DHUD:SetDefaultConfig(key)
--    if (not DHUD_Settings[key]) then
--        if type(self.Config_default[key]) ~= "table" then
--            DHUD_Settings[key] = self.Config_default[key];
--        else
--            DHUD_Settings[key] = DHUD_tablecopy(self.Config_default[key]);
--        end
--    end
    
    if not DHUD_Settings[key] then
        DHUD_Settings[key] = self.Config_default[key];
    end
    
    if type(self.Config_default[key]) == "table" then
        for k, v in pairs(self.Config_default[key]) do
            if not DHUD_Settings[key][k] then
                DHUD_Settings[key][k] = v;
            end
        end
    end
	
	-- Copy default colors for those settings that didn't change fully
	if (key == "colors") then
		for k, v in pairs(self.Config_default["colors"]) do
			--self:print("k: " .. k);
			--self:print("Color: " .. DHUD_Settings["colors"][k][1]);
			if not DHUD_Settings["colors"][k][1] then
				DHUD_Settings["colors"][k][1] = self.Config_default["colors"][k][1]
			end
			if not DHUD_Settings["colors"][k][2] then
				DHUD_Settings["colors"][k][2] = self.Config_default["colors"][k][2]
			end
			if not DHUD_Settings["colors"][k][3] then
				DHUD_Settings["colors"][k][3] = self.Config_default["colors"][k][3]
			end
		end
	end
end

-- SlashCommand Handler
function DHUD:SCommandHandler(msg)

    if (msg) then
        self:OptionsFrame_Toggle()
    end
--[[
    if msg then
        self:OptionsFrame_Toggle()
    
        local b,e,command,rest = string.find(msg, "^%s*([^%s]+)%s*(.*)$");
        
        if b then      
            for var , commandStrings in pairs(DHUD_CommandList) do
                if ( command == commandStrings["command"] ) then
                    if commandStrings["type"] == "range" then
                        self:CommandRange(var,rest);
                        return;
                    elseif commandStrings["type"] == "toggle" then
                        self:ToggleConfig(var);
                        return;
                    elseif commandStrings["type"] == "reset" then
                        self:reset() 
                        return;  
                    elseif commandStrings["type"] == "color" then
                        -- self:SetColor(var, rest);
                        return;
                    elseif commandStrings["type"] == "menu" then
                        self:OptionsFrame_Toggle()
                        return;  
                    end
                end
            end
        end

    end
    ]]--
end

-- reset command
function DHUD:reset()
--    for key, v in pairs(self.Config_default) do
--        
--        if type(self.Config_default[key]) ~= "table" then
--            DHUD_Settings[key] = self.Config_default[key];
--        else
--            DHUD_Settings[key] = DHUD_tablecopy(self.Config_default[key]);
--        end
--        
--    end

--    if not DHUD_Settings[key] then
--        DHUD_Settings[key] = self.Config_default[key];
--    end
    
    for k, v in pairs(self.Config_default) do
        DHUD_Settings[k] = self.Config_default[k];
    end


    self:init();
    self:print("default Settings Loaded.");
end

-- set config value
function DHUD:SetConfig(key, value)
   if (DHUD_Settings[key] ~= value) then
      DHUD_Settings[key] = value;
   end
end

-- get config value
function DHUD:GetConfig(key)
    return DHUD_Settings[key] or nil;
end

-- does table contain a value?
function DHUD:TableContains(tableobj, element)
  for _, value in pairs(tableobj) do
    if value == element then
      return true
    end
  end
  return false
end

-- range command
function DHUD:CommandRange(command,rest)
    local num = tonumber(rest);
    local output   = "/dhud |cff6666cc%s|r |cffcccccc%s - %s|r";
    local response = "|cff6666cc%s|r set to: |cff00ff00%s|r |cffcccccc[%s - %s]|r";
    -- print error
    if num == nil then
        self:print(string.format(
            output,
            command,
            DHUD_CommandList[command]["minvalue"],
            DHUD_CommandList[command]["maxvalue"]
        )); 
        return;
    end
    
    -- in range
    if num >= DHUD_CommandList[command]["minvalue"] and num <= DHUD_CommandList[command]["maxvalue"] then
        DHUD:SetConfig(command,num);
        self:init();
        self:print(string.format(
            response,
            command,
            num,
            DHUD_CommandList[command]["minvalue"],
            DHUD_CommandList[command]["maxvalue"]
        )); 
        return;
    -- out of range
    else    
        self:print(string.format(
            output,
            command,
            DHUD_CommandList[command]["minvalue"],
            DHUD_CommandList[command]["maxvalue"]
        )); 
        return;
    end
    
end

-- toggle config value
function DHUD:ToggleConfig(key)
    local output   = "/dhud %s";
    local response = "|cff6666cc%s|r is now %s";
    if DHUD_Settings[key] == nil then
        DHUD_Settings[key] = 0;
    end
    
    if DHUD_Settings[key] == 1 then
        DHUD_Settings[key] = 0;
        self:print(string.format(
            response,
            key,
            "|cffff0000OFF|r"
        ));                                                   
    else
        DHUD_Settings[key] = 1;
        self:print(string.format(
            response,
            key,
            "|cff00ff00ON|r"
        ));  
    end
    
    self:init();
end

-- set color
function DHUD:SetColor(key, value)
    local output   = "/dhud |cff6666cc%s|r 000000 - FFFFFF";
    local response = "|cff6666cc%s|r set to: |cff%s%s|r";
    if (DHUD_Settings[key] ~= value) then
        DHUD_Settings[key] = value;
        self:print( string.format(
            response, key, value , value
        ) ); 
    end
end