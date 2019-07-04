--[[-----------------------------------------------------------------------------------
Drathals HUD (c) 2006 by Markus Inger / Drathal / Silberklinge / Silbersegen
DHUD modification for WotLK Beta by MADCAT
-----------------------------------------------------------------------------------]]--

-- Init Vars --
DHUD_VERSION    = "Version: 1.5.30000b";
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
    -- MADCAT variables for energy
    mcplmaxenergy     = 0,
    mcpetmaxenergy    = 0,
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
                    "DHUD_TargetElite",
                    "DHUD_PetHappy",
                    "DHUD_RaidIcon",
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
                         
    -- reaction Colors
    ReacColors    = { "ff0000","ffff00","55ff55","8888ff","008800","cccccc" }, 
    
    -- prepared Colors
    BarColorTab   = {},
                 
    -- Main Events
    -- WotLK PLAYER_COMBO_POINTS changed to UNIT_COMBO_POINTS, PLAYER_AURAS_CHANGED removed
    -- UNIT_ENERGYMAX, UNIT_MANAMAX, UNIT_FOCUSMAX, UNIT_HEALTHMAX, UNIT_RAGEMAX removed
    mainEvents    = { "UNIT_AURA","UNIT_PET","UNIT_HEALTH",
                      "UNIT_MANA","UNIT_FOCUS","UNIT_RAGE",
                      "UNIT_ENERGY","UNIT_DISPLAYPOWER","UNIT_RUNE","UNIT_RUNIC_POWER","UNIT_TARGET",
                      "PLAYER_ENTER_COMBAT","PLAYER_LEAVE_COMBAT","PLAYER_REGEN_ENABLED","PLAYER_REGEN_DISABLED",
                      "PLAYER_TARGET_CHANGED","UNIT_COMBO_POINTS","PLAYER_ALIVE","PLAYER_DEAD", "RAID_TARGET_UPDATE",
                      "UNIT_SPELLCAST_CHANNEL_START","UNIT_SPELLCAST_CHANNEL_UPDATE","UNIT_SPELLCAST_DELAYED","UNIT_SPELLCAST_FAILED",
                      "UNIT_SPELLCAST_INTERRUPTED","UNIT_SPELLCAST_START","UNIT_SPELLCAST_STOP","UNIT_SPELLCAST_CHANNEL_STOP",
                      "PLAYER_UPDATE_RESTING","UNIT_PVP_UPDATE","PLAYER_PET_CHANGED","UNIT_PVP_STATUS","PLAYER_UNGHOST",
                      "UNIT_HAPPINESS",
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
    },
                   
    -- default settings                
    Config_default = {
                ["version"]            = DHUD_VERSION,
                ["layouttyp"]          = "DHUD_Standard_Layout",

                ["combatalpha"]        = 0.8,
                ["oocalpha"]           = 0,
                ["selectalpha"]        = 0.5,
                ["regenalpha"]         = 0.3,
                
                ["scale"]              = 1,              
                ["mmb"]                = {},
                
                ["showmmb"]            = 1,
                ["showresticon"]       = 1,
                ["showcombaticon"]     = 1,
                ["showplayerpvpicon"]  = 1,   
                ["showtargetpvpicon"]  = 1,  
                ["showpeticon"]        = 1, 
                ["showeliteicon"]      = 1, 
                ["animatebars"]        = 1,
                ["barborders"]         = 1,
                ["showauras"]          = 1,
                ["showauratips"]       = 1,
                ["showplayerbuffs"]    = 1,
                ["castingbar"]         = 1,
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
                ["DHUD_PlayerHealth_Text"] = "<color_hp><hp_value></color> <color>999999(</color><hp_percent><color>999999)</color>",
                ["DHUD_PlayerMana_Text"]   = "<color_mp><mp_value></color> <color>999999(</color><mp_percent><color>999999)</color>",
                ["DHUD_TargetHealth_Text"] = "<color_hp><hp_value></color> <color>999999(</color><hp_percent><color>999999)</color>",
                ["DHUD_TargetMana_Text"]   = "<color_mp><mp_value></color> <color>999999(</color><mp_percent><color>999999)</color>",
                ["DHUD_PetHealth_Text"]    = "<color_hp><hp_value></color>",
                ["DHUD_PetMana_Text"]      = "<color_mp><mp_value></color>",
                ["DHUD_Target_Text"]       = "<color_level><level><elite></color> <color_reaction><name></color> [<color_class><class><type><pet><npc></color>] <pvp>",
                ["DHUD_TargetTarget_Text"] = "<color_level><level><elite></color> <color_reaction><name></color> [<color_class><class><type><pet><npc></color>] <pvp>",
                                
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
function DHUD:OnEvent()
    -- MADCAT debug
    -- self:print("MainEvent: "..event);

    -- debug
    self:printd("MainEvent: "..event);

    -- init HUD
    if event == "VARIABLES_LOADED" then    
        self.vars_loaded = 1;
        self:firstload();
    -- zoning    
    elseif event == "PLAYER_ENTERING_WORLD" then
        self.enter = 1;
        if self:firstload() then return; end       
        if self.issetup ~= 2 then return; end
        if self.isinit  ~= 2 then return; end
        self:init();
    -- update HEALTH Bars, UNIT_HEALTHMAX removed  
    elseif ( event == "UNIT_HEALTH" ) then
        if arg1 == "player" then
            self:UpdateValues("DHUD_PlayerHealth_Text");
        elseif arg1 == "target" then
            self:UpdateValues("DHUD_TargetHealth_Text");
        elseif arg1 == "pet" then
            self:UpdateValues("DHUD_PetHealth_Text");
        end
        self:updateAlpha();
    -- update MANA Bars, UNIT_ENERGYMAX, UNIT_MANAMAX, UNIT_FOCUSMAX, UNIT_RAGEMAX   removed
    elseif ( event == "UNIT_MANA" or 
             event == "UNIT_FOCUS" or
             event == "UNIT_RAGE" or
             event == "UNIT_ENERGY" or event == "UNIT_DISPLAYPOWER" or
             event == "UNIT_RUNIC_POWER" ) then
        if arg1 == "player" then
            self:UpdateValues("DHUD_PlayerMana_Text");
            mcplmaxenergy = UnitManaMax("player");
		-- mcplenergy = UnitMana("player");
        elseif arg1 == "target" then
            self:UpdateValues("DHUD_TargetMana_Text");
		if (event == "UNIT_RUNIC_POWER" ) then
			self:triggerTextEvent("DHUD_TargetMana_Text");
		end
        elseif arg1 == "pet" then
            self:UpdateValues("DHUD_PetMana_Text");
        end
        
        -- Druidbar support
        if DruidBarKey and self.player_class == "DRUID" then
            self:UpdateValues("DHUD_PetMana_Text");
            self:triggerTextEvent("DHUD_PlayerMana_Text");
            self:triggerTextEvent("DHUD_PetMana_Text");
        end
        
        self:updateAlpha();
    -- update self Auras
    -- elseif event == "PLAYER_AURAS_CHANGED" then
    elseif (event == "UNIT_AURA" and arg1 == "player") then
        self:triggerTextEvent("DHUD_PlayerMana_Text");
        self:triggerTextEvent("DHUD_PetMana_Text");
        self:UpdateValues("DHUD_PlayerMana_Text");
        self:UpdateValues("DHUD_PlayerHealth_Text");
        self:UpdateValues("DHUD_PetMana_Text");
        self:ChangeBackgroundTexture();
        self:updateAlpha();
        self:PlayerAuras();
    -- target changed   
    elseif event == "PLAYER_TARGET_CHANGED" then  
        self:TargetChanged();
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
    elseif event == "UNIT_HAPPINESS" and arg1 == "pet" then
        self:updatePetIcon();
    end

    if self.issetup ~= 2 then return; end
    if self.isinit  ~= 2 then return; end
        
    -- castbar events
    if DHUD_Settings["castingbar"] == 1 then
        -- start spellcast
        if (event == "UNIT_SPELLCAST_START") and (arg1 == "player") then
            spell, rank, displayName, icon, startTime, endTime, isTradeSkill = UnitCastingInfo(arg1);
            self.spellname  = spell;
            this.startTime  = startTime / 1000;
            this.maxValue   = endTime / 1000;
            this.holdTime   = 0;
            this.casting    = 1;
            this.delay      = 0;
            this.channeling = nil;
            this.fadeOut    = nil;
            this.flash      = nil;
            this.duration   = floor( ( endTime - startTime ) / 100 ) / 10;
            self.Casting    = true;
            self:updateAlpha();
            DHUD_Casttime_Text:SetAlpha(1);
            DHUD_Castdelay_Text:SetAlpha(1);
            DHUD_Casting_Bar:Show();
            DHUD_Flash_Bar:Hide();
        -- stop 
        elseif ( event == "UNIT_SPELLCAST_STOP" or event == "UNIT_SPELLCAST_CHANNEL_STOP") and (arg1 == "player") then
            if (not DHUD_Casting_Bar:IsVisible()) then
                DHUD_Casting_Bar:Hide();
            end
            if (DHUD_Casting_Bar:IsShown()) then
                if ( event == "UNIT_SPELLCAST_STOP" and this.casting ) then
                    this.casting    = nil;
                    this.channeling = nil;
                    this.flash      = 1;
                    this.fadeOut    = 1;
                    DHUD_Casting_Bar_Texture:SetVertexColor(0, 1, 0);
                    self:SetBarHeight("DHUD_Casting_Bar",1);
                    DHUD_Flash_Bar:SetAlpha(0);
                    DHUD_Flash_Bar:Show();
                  elseif  ( event == "UNIT_SPELLCAST_CHANNEL_STOP" and this.channeling ) then
                    this.casting    = nil;
                    this.channeling = nil;
                    this.flash      = nil;
                    this.fadeOut    = 1;
                    self.Casting    = nil;
                    self:updateAlpha();
                    self:SetBarHeight("DHUD_Casting_Bar",0);
                end
            end
        -- failed
        elseif (event == "UNIT_SPELLCAST_FAILED" or event == "UNIT_SPELLCAST_INTERRUPTED") and (arg1 == "player") then
            if (DHUD_Casting_Bar:IsShown() and not this.fadeOut ) then
                DHUD_Casting_Bar_Texture:SetVertexColor(1, 0, 0);
                self:SetBarHeight("DHUD_Casting_Bar",1);
                this.casting    = nil;
                this.channeling = nil;
                this.fadeOut    = 1;
                this.flash      = nil;
                this.holdTime = GetTime() + CASTING_BAR_HOLD_TIME;
                DHUD_Flash_Bar:Hide();
                DHUD_Flash_Bar:SetAlpha(0);
            end
        -- delayed
        elseif (event == "UNIT_SPELLCAST_DELAYED") and (arg1 == "player") then
            if(DHUD_Casting_Bar:IsShown()) then
                spell, rank, displayName, icon, startTime, endTime, isTradeSkill = UnitCastingInfo(arg1);
                delay = endTime / 1000 - this.maxValue;
                this.startTime = this.startTime + delay;
                this.maxValue  = this.maxValue + delay;
                this.delay     = this.delay + delay;
                
                local time = GetTime();
                if (time > this.endTime) then
                    time = this.endTime
                end
            end		
        -- channel start
        elseif (event == "UNIT_SPELLCAST_CHANNEL_START") and (arg1 == "player") then
            spell, rank, displayName, icon, startTime, endTime, isTradeSkill = UnitChannelInfo(arg1);
            self.spellname  = spell;
            this.maxValue   = 1;
            this.startTime  = startTime / 1000;
            this.endTime    = endTime / 1000;
            this.duration   = string.format( "%.1f", (endTime - startTime) / 1000);
            this.holdTime   = 0;
            this.casting    = nil;
            this.channeling = 1;
            this.flash      = nil;
            this.fadeOut    = nil;
            this.delay      = 0;
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
                this.channeling = nil;
            elseif (DHUD_Casting_Bar:IsShown()) then
                spell, rank, displayName, icon, startTime, endTime, isTradeSkill = UnitCastingInfo(arg1);
                local origDuration = this.endTime - this.startTime
                local elapsedTime = GetTime() - this.startTime;
--                this.delay = (origDuration - elapsedTime) - (arg1/1000);
--                this.endTime = GetTime() + (arg1 / 1000);
                -- hack
                if endTime == nil then
                    endTime = 0;
                end
                this.endTime = endTime / 1000;
                this.delay = this.endTime - this.startTime + (endTime / 1000);
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
        ref:SetScript("OnEvent", function() DHUD:TextOnEvent(); end );
    end
end

-- events for vars
function DHUD:TextOnEvent()

        
    if this.unit == arg1 or 
        event == "PLAYER_ENTERING_WORLD" or  
        --( event == "PLAYER_TARGET_CHANGED" and this.unit == "target" ) or 
        ( event == "PLAYER_TARGET_CHANGED" and this.unit == "target" ) or 
        ( event == "UNIT_TARGET" ) or
        ( (event == "UNIT_PET" or event == "PLAYER_PET_CHANGED") and this.unit == "pet" ) then 
        self:doText( this:GetName() );    
    end
    
--    if this.unit == arg1 and event == "UNIT_TARGET" then
--        self:doText( "DHUD_TargetTarget_Text" );
--    end
end

-- set Textbox
function DHUD:doText(name)
    local font = getglobal(name.."_Text");

    -- hide npc / target / pet ?
    if this.unit == "target" and DHUD_Settings["shownpc"] == 0 and self:TargetIsNPC() then 
        font:SetText(" ");
        return; 
    end
    if this.unit == "target" and DHUD_Settings["showtarget"] == 0 then 
        font:SetText(" ");
        return; 
    end
    if this.unit == "pet" and DHUD_Settings["showpet"] == 0 then 
        font:SetText(" ");
        return; 
    end
    if this.unit == "targettarget" and DHUD_Settings["shownpc"] == 0 and self:TargetIsNPC() then
        font:SetText(" ");
        return;
    end
    if this.unit == "targettarget" and DHUD_Settings["showtargettarget"] == 0 then
        font:SetText(" ");
        return;
    end
    if this.unit == "targettarget" and UnitExists("targettarget") == nil then
        font:SetText(" ");
        return;
    end
    
    local text  = this.text;
    local htext = this.text;
    for var, bol in pairs(this.vars) do
        text  = DHUD_variables[var].func(text,this.unit);
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
    local frame = getglobal(name);
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
    this.unit = getglobal(p).unit;
    this.vars = getglobal(p).vars;
    this.text = getglobal(p).text;
    self:doText(p);
end

-- OnUpdate --
function DHUD:OnUpdate()    
    -- update speed
    self.update_elapsed = self.update_elapsed + arg1;
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
        if DruidBarKey and self.player_class == "DRUID" and UnitPowerType("player") ~= 0 then
            self:Animate("DHUD_PetMana_Bar");
        end
    end

    -- castingbar
    if DHUD_Settings["castingbar"] == 1 then
        -- casting
        if this.casting then
            local time = GetTime();
            if (time > this.maxValue) then
                time = this.maxValue
            end
            
            DHUD_Flash_Bar:Hide();
            local v = (time - this.startTime) / (this.maxValue - this.startTime);
            
            if DHUD_Settings["reversecasting"] == 1 then
                self:SetBarHeight("DHUD_Casting_Bar", 1-v );
                DHUD_Casting_Bar_Texture:SetVertexColor(self:Colorize("castbar",v));    
            else
                self:SetBarHeight("DHUD_Casting_Bar", v );
                DHUD_Casting_Bar_Texture:SetVertexColor(self:Colorize("castbar",v));       
            end
            
            self.casting_time_del = string.format( "-%.1f", this.delay );
            self.casting_time_rev = string.format( "%.1f", this.maxValue - time );
            self.casting_time     = string.format( "%.1f", (time + this.delay) - this.startTime );
            self:triggerTextEvent("DHUD_Casttime_Text");
            self:triggerTextEvent("DHUD_Castdelay_Text");
                        
        -- channeling
        elseif this.channeling then
            local time = GetTime();
            if (time > this.endTime) then
                time = this.endTime
            end
            
            local barValue = this.startTime + (this.endTime - time);
            local sparkPosition = (barValue - this.startTime) / (this.endTime - this.startTime);
            DHUD_Flash_Bar:Hide();
            
            self:SetBarHeight("DHUD_Casting_Bar", sparkPosition );
            DHUD_Casting_Bar_Texture:SetVertexColor(self:Colorize("channelbar",(barValue - this.startTime) / (this.endTime - this.startTime)));

            self.casting_time_del = string.format( "+%.1f", this.delay );
            self.casting_time     = string.format( " %.1f", (time + this.delay) - this.startTime );
            self.casting_time_rev = string.format( "%.1f", this.duration -((time + this.delay) - this.startTime) );
            self:triggerTextEvent("DHUD_Casttime_Text");
            self:triggerTextEvent("DHUD_Castdelay_Text");
            
            if (time == this.endTime) then
                this.channeling = nil;
                this.casting    = nil;
                this.fadeOut    = 1;
                this.flash      = nil;
                self.Casting    = nil;  
                self:SetBarHeight("DHUD_Casting_Bar", 0 );
                self:updateAlpha();
            end
        -- hold
        elseif this.holdTime and GetTime() < this.holdTime then
    
        -- flash
        elseif this.flash then
            local alpha = DHUD_Flash_Bar:GetAlpha() + CASTING_BAR_FLASH_STEP;
            if alpha < 1 and DHUD_Settings["reversecasting"] == 0 then
                DHUD_Flash_Bar:SetAlpha(alpha);
            else
                this.flash = nil;
                DHUD_Flash_Bar:SetAlpha(0);
                DHUD_Flash_Bar:Hide();
            end
        -- fade
        elseif this.fadeOut then
            local alpha = DHUD_Casting_Bar:GetAlpha() - CASTING_BAR_ALPHA_STEP;
            if alpha > 0 and DHUD_Settings["reversecasting"] == 0 then
                DHUD_Casting_Bar:SetAlpha(alpha);
                DHUD_Casttime_Text:SetAlpha(alpha);
                DHUD_Castdelay_Text:SetAlpha(alpha);
            else
                this.fadeOut = nil;
                DHUD_Casting_Bar:Hide();
                DHUD_Casting_Bar:SetAlpha(0);
                self.Casting = nil;
                self:updateAlpha();
                self.casting_time     = nil;
                self.casting_time_rev = nil;
                self.casting_time_del = nil;
                self.spellname        = nil;
                self:triggerTextEvent("DHUD_Casttime_Text");
                self:triggerTextEvent("DHUD_Castdelay_Text");
            end
        end
    end
    
    -- MADCAT energy(maybe CPU_consuming)
    -- self:triggerTextEvent("DHUD_PlayerMana_Text");
    -- Self writed function
    self:MCUpdatePlayerEnergy();
    --
    self:PlayerAuras();
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
    mcplmaxenergy = UnitManaMax("player");
    -- mcplenergy = UnitMana("player");
                    
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
    DHUD_PlayerHealth_Text_Text:SetFont(self.defaultfont_num, DHUD_Settings["fontsizeplayer"] / DHUD_Settings["scale"], self.Outline[ DHUD_Settings["playerhpoutline"] ]);
    DHUD_PlayerMana_Text_Text:SetFont(self.defaultfont_num, DHUD_Settings["fontsizeplayer"] / DHUD_Settings["scale"], self.Outline[ DHUD_Settings["playermanaoutline"] ]);
    DHUD_TargetHealth_Text_Text:SetFont(self.defaultfont_num, DHUD_Settings["fontsizetarget"] / DHUD_Settings["scale"], self.Outline[ DHUD_Settings["targethpoutline"] ]);
    DHUD_TargetMana_Text_Text:SetFont(self.defaultfont_num, DHUD_Settings["fontsizetarget"] / DHUD_Settings["scale"], self.Outline[ DHUD_Settings["targetmanaoutline"] ]);
    DHUD_PetHealth_Text_Text:SetFont(self.defaultfont_num, DHUD_Settings["fontsizepet"] / DHUD_Settings["scale"], self.Outline[ DHUD_Settings["pethpoutline"] ]);
    DHUD_PetMana_Text_Text:SetFont(self.defaultfont_num, DHUD_Settings["fontsizepet"] / DHUD_Settings["scale"], self.Outline[ DHUD_Settings["petmanaoutline"] ]);
    DHUD_Target_Text_Text:SetFont(self.defaultfont, DHUD_Settings["fontsizetargetname"] / DHUD_Settings["scale"], self.Outline[ DHUD_Settings["targetoutline"] ]);
    DHUD_TargetTarget_Text_Text:SetFont(self.defaultfont, DHUD_Settings["fontsizetargettargetname"] / DHUD_Settings["scale"], self.Outline[ DHUD_Settings["targettargetoutline"] ]);
    
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
        ComboFrame:UnregisterEvent("PLAYER_COMBO_POINTS")
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
        ComboFrame:RegisterEvent("PLAYER_COMBO_POINTS")
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
        PlayerFrameManaBar:UnregisterEvent("UNIT_MANA")
        PlayerFrameManaBar:UnregisterEvent("UNIT_RAGE")
        PlayerFrameManaBar:UnregisterEvent("UNIT_FOCUS")
        PlayerFrameManaBar:UnregisterEvent("UNIT_ENERGY")
        PlayerFrameManaBar:UnregisterEvent("UNIT_HAPPINESS")
        PlayerFrameManaBar:UnregisterEvent("UNIT_MAXMANA")
        PlayerFrameManaBar:UnregisterEvent("UNIT_MAXRAGE")
        PlayerFrameManaBar:UnregisterEvent("UNIT_MAXFOCUS")
        PlayerFrameManaBar:UnregisterEvent("UNIT_MAXENERGY")
        PlayerFrameManaBar:UnregisterEvent("UNIT_MAXHAPPINESS")
        PlayerFrameManaBar:UnregisterEvent("UNIT_DISPLAYPOWER")
        PlayerFrame:UnregisterEvent("UNIT_NAME_UPDATE")
        PlayerFrame:UnregisterEvent("UNIT_PORTRAIT_UPDATE")
        PlayerFrame:UnregisterEvent("UNIT_DISPLAYPOWER")
        PlayerFrame:Hide()
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
        PlayerFrameManaBar:RegisterEvent("UNIT_MANA")
        PlayerFrameManaBar:RegisterEvent("UNIT_RAGE")
        PlayerFrameManaBar:RegisterEvent("UNIT_FOCUS")
        PlayerFrameManaBar:RegisterEvent("UNIT_ENERGY")
        PlayerFrameManaBar:RegisterEvent("UNIT_HAPPINESS")
        PlayerFrameManaBar:RegisterEvent("UNIT_MAXMANA")
        PlayerFrameManaBar:RegisterEvent("UNIT_MAXRAGE")
        PlayerFrameManaBar:RegisterEvent("UNIT_MAXFOCUS")
        PlayerFrameManaBar:RegisterEvent("UNIT_MAXENERGY")
        PlayerFrameManaBar:RegisterEvent("UNIT_MAXHAPPINESS")
        PlayerFrameManaBar:RegisterEvent("UNIT_DISPLAYPOWER")
        PlayerFrame:RegisterEvent("UNIT_NAME_UPDATE")
        PlayerFrame:RegisterEvent("UNIT_PORTRAIT_UPDATE")
        PlayerFrame:RegisterEvent("UNIT_DISPLAYPOWER")
        PlayerFrame:Show()
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
   
    -- hide mobhealth frame?
    if DHUD_Settings["btarget"] == 0 then     
        if (MI2_MobHealthFrame) then
            MI2_MobHealthFrame:Hide();
        end
        if (MobHealthFrame) then
            MobHealthFrame:Hide();
        end  
    else
        if (MI2_MobHealthFrame) then
            MI2_MobHealthFrame:Show();
        end
        if (MobHealthFrame) then
            MobHealthFrame:Show();
        end  
    end     
   
    -- update Alpha
    self.inCombat = nil;
    self:updateAlpha();
    DHUD_Flash_Bar:SetAlpha(0);
    DHUD_Casting_Bar:SetAlpha(0);
    DHUD_Casting_Bar:Hide();
    DHUD_Flash_Bar:Hide();
    
    -- init castbar
    this.endTime = 0;
    
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
    
    -- minimap button
    if DHUD_Settings["showmmb"] == 1 then
        DHUDMinimapButton:Show();
		DHUDMinimapButton:SetFrameStrata(Minimap:GetFrameStrata());
		DHUDMinimapButton:SetFrameLevel(Minimap:GetFrameLevel() + 3);	
    else
        DHUDMinimapButton:Hide();
    end
    
    -- alter pet manatext when class = DRUID
    if DruidBarKey and self.player_class == "DRUID" and DHUD_Settings["DHUD_PetMana_Text"] == DHUD_TEXT_MP2 then
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
    local ref = getglobal(name);
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
        getglobal("DHUD_Target_Text"):EnableMouse(1);
    else
        getglobal("DHUD_Target_Text"):EnableMouse(0);
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
    if layout == "DHUD_Standard_Layout" or layout == "DHUD_PlayerLeft_Layout" then
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
        local ref = getglobal(name);
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
        local ref = getglobal(name);
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

        local bgt = getglobal(name.."_Texture");
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
        local ref = getglobal(name);
        ref:ClearAllPoints();
        ref:SetPoint(point, frame , relative, x, y);
        ref:SetHeight(height);
        ref:SetWidth(width);
        
        -- debug background
        if self.debug then
            --ref:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", tile = true, tileSize = 32, insets = { left = 0, right = 0, top = 0, bottom = 0 }});
            --ref:SetBackdropColor(0,1,0,0.1);
        end
        local bgt = getglobal(name.."_Texture");
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
        local ref = getglobal(name);
        ref:ClearAllPoints();
        ref:SetPoint(point, frame , relative, x, y);
        
        -- debug background
        if self.debug then
           -- ref:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", tile = true, tileSize = 32, insets = { left = 0, right = 0, top = 0, bottom = 0 }});
            --ref:SetBackdropColor(0,0,1,0.5);
        end
        
        local font = getglobal(name.."_Text");
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
        ref = getglobal(name);
        ref:ClearAllPoints();
        ref:SetPoint(point, frame , relative, x, y);
        ref:SetHeight(height);
        ref:SetWidth(width);
        
        -- debug background
        if self.debug then
           -- ref:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", tile = true, tileSize = 32, insets = { left = 0, right = 0, top = 0, bottom = 0 }});
           -- ref:SetBackdropColor(1,0,0,0.2);
        end

        local font = getglobal(name.."_Text");
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
        
        local bgt = getglobal(name.."_Border");
        bgt:SetTexture("Interface\\Buttons\\UI-Debuff-Border");
        bgt:SetPoint("BOTTOM", ref, "BOTTOM", 0, 0);
        bgt:SetHeight(height);
        bgt:SetWidth(width);
        bgt:SetTexCoord(0,1,0,1);  
                
        ref:SetNormalTexture( "Interface\\Icons\\Ability_Druid_TravelForm" );
        ref:SetFrameLevel(self.frame_level);
        ref:SetParent(frame);
        
        ref:SetScript("OnEnter", function() 
                if (not this:IsVisible()) then return; end
                if DHUD_Settings["showauratips"] == 0 then return; end
                GameTooltip:SetOwner(this, "ANCHOR_BOTTOMRIGHT");
                if this.hasdebuff == 1 then
                    GameTooltip:SetUnitDebuff(this.unit, this.id);
                else
                    GameTooltip:SetUnitBuff(this.unit, this.id);
                end
            end );
 
         ref:SetScript("OnLeave", function() 
                GameTooltip:Hide();
            end );
                         
        ref:EnableMouse(true);
        ref:Show();
        
    elseif typ == "PlayerBuff" then
        ref = getglobal(name);
        ref:ClearAllPoints();
        ref:SetPoint(point, frame , relative, x, y);
        ref:SetHeight(height);
        ref:SetWidth(width);
        
        local font = getglobal(name.."_Text");
        font:ClearAllPoints();
        font:SetFontObject(GameFontHighlightSmall);
        font:SetPoint("CENTER", ref, "CENTER", 0,0);
        font:SetText("");
        font:SetJustifyH("CENTER");
        font:SetJustifyV("CENTER");
        font:SetWidth(width*2);
        font:SetHeight(height);
        
        local bgt = getglobal(name.."_Border");
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
        
        ref:SetScript("OnEnter", function() 
                if (not this:IsVisible()) then return; end
                if DHUD_Settings["showauratips"] == 0 then return; end
                GameTooltip:SetOwner(this, "ANCHOR_BOTTOMRIGHT");
                GameTooltip:SetUnitBuff("player",this.id);
            end );
 
         ref:SetScript("OnLeave", function() 
                GameTooltip:Hide();
            end );
                         
        ref:EnableMouse(true);
        ref:Show();
        
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
        ref = CreateFrame ("Frame", name, getglobal(frame) );
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
        ref = CreateFrame("Frame", name, getglobal(frame) );
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
        ref = CreateFrame("Frame", name, getglobal(frame));
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
    -- set text
    elseif typ == "Text" then
        ref = CreateFrame("Button", name, getglobal(frame));
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
        ref = CreateFrame("Button", name, getglobal(frame));
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
        
        local bgt = ref:CreateTexture(name.."_Border","OVERLAY");
        bgt:SetTexture("Interface\\Buttons\\UI-Debuff-Border");
        bgt:SetPoint("BOTTOM", ref, "BOTTOM", 0, 0);
        bgt:SetHeight(height);
        bgt:SetWidth(width);
        bgt:SetTexCoord(0,1,0,1);  
                
        ref:SetNormalTexture( "Interface\\Icons\\Ability_Druid_TravelForm" );
        ref:SetFrameLevel(self.frame_level);
        ref:SetParent(frame);
        
        ref:SetScript("OnEnter", function() 
                if (not this:IsVisible()) then return; end
                if DHUD_Settings["showauratips"] == 0 then return; end
                GameTooltip:SetOwner(this, "ANCHOR_BOTTOMRIGHT");
                if this.hasdebuff == 1 then
                    GameTooltip:SetUnitDebuff(this.unit, this.id);
                else
                    GameTooltip:SetUnitBuff(this.unit, this.id);
                end
            end );
 
         ref:SetScript("OnLeave", function() 
                GameTooltip:Hide();
            end );
                         
        ref:EnableMouse(true);
        ref:Show();
        
    elseif typ == "PlayerBuff" then
        ref = CreateFrame("Button", name, getglobal(frame));
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
        
        local bgt = ref:CreateTexture(name.."_Border","OVERLAY");
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
        
        ref:SetScript("OnEnter", function() 
                if (not this:IsVisible()) then return; end
                if DHUD_Settings["showauratips"] == 0 then return; end
                GameTooltip:SetOwner(this, "ANCHOR_BOTTOMRIGHT");
                GameTooltip:SetUnitBuff("player",this.id);
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
    local texture = getglobal(bar.."_Texture");
    texture:SetVertexColor(self:Colorize(typunit,percent));
end

-- gettypeunit
function DHUD:getTypUnit(unit,typ)
    -- what power type?
    if typ == "mana" then
        if UnitPowerType(unit) then
            typ = self.powertypes[ UnitPowerType(unit)+1 ];
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
    local texture = getglobal(bar.."_Texture");
    
    -- Hide when Bar empty 
    if math.floor(p * 100) == 0 or UnitIsDeadOrGhost("player") then
        texture:Hide();
        return;
    end

    -- Textur Settings laden
    local typ, point, frame, relative, x, y, width, height = unpack( self.C_frames[bar] );
    local texname,x0,x1,y0,y1 = unpack(self.C_textures[bar]);        
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
    texture:SetTexCoord(x0, x1, top, bottom );
    texture:SetPoint(point, getglobal(frame), relative, x, tex_gap_bottom);
    texture:Show();
end;

-- show / hide combopoints
function DHUD:UpdateCombos()
    local points = GetComboPoints("player","target")
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
        button = getglobal(buffFrame..i);
        button.hasdebuff = nil;
        button.unit = "target";
        button.id = i;
        if DHUD_Settings["shownpc"] == 0 and self:TargetIsNPC() then
            button:Hide();
        elseif buffName and DHUD_Settings["showauras"] == 1 and DHUD_Settings["showtarget"] == 1 then
            icon = getglobal(button:GetName());
            icon:SetNormalTexture(buffTexture);
            
            buffBorder = getglobal(button:GetName().."_Border");
            buffBorder:Hide();
            
            buffText   = getglobal(button:GetName().."_Text");
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
        local debuffName, _, debuffTexture, debuffApplication = UnitDebuff("target", i);
        button = getglobal(debuffFrame..i);
        button.hasdebuff = 1;
        button.unit = "target";
        button.id = i;
        if DHUD_Settings["shownpc"] == 0 and self:TargetIsNPC() then
            button:Hide();
        elseif debuffName and DHUD_Settings["showauras"] == 1 and DHUD_Settings["showtarget"] == 1 then
            icon = getglobal(button:GetName());
            icon:SetNormalTexture(debuffTexture);
                        
            debuffBorder = getglobal(button:GetName().."_Border");
            debuffBorder:Show();
            
            debuffText   = getglobal(button:GetName().."_Text");
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
    local i, icon, button, pbtimeLeft, pbtexture;
    local pbrank, pbcount, pbdebuffType, pbduration;
    local j = 1;
    local buffText;
    local buffframe = "DHUD_PlayerBuff";
    local color = {};
    
    -- Buffs
    if DHUD_Settings["showplayerbuffs"] == 1 and getglobal(buffframe .. "1"):IsVisible() then
        for i = 1, 40 do
            -- WotLK GetPlayerBuff changed to UnitBuff
            buffI, pbrank, pbtexture, pbcount, pbdebuffType, pbduration, pbtimeLeft  = UnitBuff( "player", i, self.playerbufffilter );
           	
		-- don't show empty frames
            if (buffI==nil) then pbtimeLeft=0; 
		else 
		pbtimeLeft = pbtimeLeft - GetTime();
		            
            if pbtimeLeft > 0 and pbtimeLeft < DHUD_Settings["playerbufftimefilter"] then
                color.r, color.g, color.b = self:Colorize("aura_player", pbtimeLeft / 20);

                button = getglobal(buffframe..j);
                button.hasdebuff = nil;
                button.unit = "player";
                button.id = i;
                
                icon       = getglobal(button:GetName());
                icon:SetNormalTexture(pbtexture);
                
                buffBorder = getglobal(button:GetName().."_Border");
                buffBorder:SetVertexColor(color.r, color.g, color.b);
                buffBorder:Show();
                
                buffText   = getglobal(button:GetName().."_Text");
                buffText:SetText("|cff"..DHUD_DecToHex(color.r, color.g, color.b)..DHUD_FormatTime(pbtimeLeft));
                
                button:Show();
                
                -- limited number of buff slots
                if j == 16 then
                    self:print("You have reached the buff limit. Contact Caeryn and ask for more buff slots");
                    break;
                else
                    j = j + 1;
                end
		end
            end
        end
    end

    -- hide the buttons not used
    for j = j, 16 do
        button = getglobal(buffframe..j);
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
    this.unit = getglobal("DHUD_PlayerMana_Text").unit;
    this.vars = getglobal("DHUD_PlayerMana_Text").vars;
    this.text = getglobal("DHUD_PlayerMana_Text").text;
    
    local font = getglobal("DHUD_PlayerMana_Text".."_Text");
    
    local text  = this.text;
    -- mcplenergy = mcplenergy + 1;
    local mcplenergy = UnitMana("player");
    if (mcplenergy>mcplmaxenergy) then
		mcplenergy=mcplmaxenergy;
    end

    -- Update Bar
    value = tonumber(mcplenergy/mcplmaxenergy);
    local bar  = self.text2bar["DHUD_PlayerMana_Text"];
    self.bar_values[bar] = value;
    if DHUD_Settings["animatebars"] == 0 or set then
        self.bar_anim[bar] = value;
        self:SetBarHeight(bar,value); 
        self:SetBarColor(bar,value);
    end       
    
    -- Set text
    value = math.floor(value * 100);
    local typunit = DHUD:getTypUnit(this.unit,"mana");
    local color = DHUD_DecToHex(DHUD:Colorize(typunit,100));
    text = DHUD:gsub(text, '<color_mp>', "|cff"..color);
    text = DHUD:gsub(text, '<mp_value>', mcplenergy);
    text = DHUD:gsub(text, '</color>', '|r');
    text = DHUD:gsub(text, '<color>', '|cff');
    text = DHUD:gsub(text, '<mp_percent>', value.."%%");
    -- text = string.gsub(text, "  "," ");
    -- text = string.gsub(text,"(^%s+)","");
    -- text = string.gsub(text,"(%s+$)","");
    font:SetText(text);
    -- end
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
    local bar  = self.text2bar[frame];
    local unit = self.name2unit[bar];
    local typ  = self.name2typ[bar];
    local ref  = getglobal(frame.. "_Text");    
    self.PetneedMana   = nil;
    self.PetneedHealth = nil;
        
    if typ == "health" then
        value = tonumber(UnitHealth(unit)/UnitHealthMax(unit));
    else
        value = tonumber(UnitMana(unit)/UnitManaMax(unit));
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
    if unit == "pet" and typ == "mana" and DruidBarKey and self.player_class == "DRUID" then
       if UnitPowerType("player") ~= 0 then
           value = tonumber( DruidBarKey.keepthemana / DruidBarKey.maxmana );
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
        if type == "rage" then
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
                if UnitManaMax("target") > 0 then 
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
    
                if UnitManaMax("pet") > 0 then 
                    self.has_pet_mana = 1;
                end              
            end
        end
        
        -- check druidbar
        if DruidBarKey and self.player_class == "DRUID" then
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
        
        local texture,x0,x1,y0,y1;
        if type(self.C_textures["l_"..what]) == "table" then
            texture,x0,x1,y0,y1 = unpack( self.C_textures["l_"..what] );
            getglobal("DHUD_LeftFrame_Texture"):SetTexture(texture);
            getglobal("DHUD_LeftFrame_Texture"):SetTexCoord(x0,x1,y0,y1);
        else
            self:print("Please report Caeryn this String: "..what);
        end
        
        if type(self.C_textures["l_"..what]) == "table" then
            texture,x0,x1,y0,y1 = unpack( self.C_textures["r_"..what] );
            getglobal("DHUD_RightFrame_Texture"):SetTexture(texture);
            getglobal("DHUD_RightFrame_Texture"):SetTexCoord(x0,x1,y0,y1);
        else
            self:print("Please report Caeryn this String: "..what);
        end        
    end
    
    if UnitIsDeadOrGhost("player") then
        getglobal("DHUD_PlayerHealth_Text"):Hide();
        getglobal("DHUD_PlayerMana_Text"):Hide();
        getglobal("DHUD_PetHealth_Text"):Hide();
        getglobal("DHUD_PetMana_Text"):Hide();
        getglobal("DHUD_RightFrame_Texture"):Hide();
        getglobal("DHUD_LeftFrame_Texture"):Hide();
    else
        getglobal("DHUD_PlayerHealth_Text"):Show();
        getglobal("DHUD_PlayerMana_Text"):Show();
        getglobal("DHUD_PetHealth_Text"):Show();
        getglobal("DHUD_PetMana_Text"):Show();
        if DHUD_Settings["barborders"] == 1 then
            getglobal("DHUD_RightFrame_Texture"):Show();
            getglobal("DHUD_LeftFrame_Texture"):Show();
        else
            getglobal("DHUD_RightFrame_Texture"):Hide();
            getglobal("DHUD_LeftFrame_Texture"):Hide();        
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
        getglobal("DHUD_TargetElite_Texture"):SetTexture(texture);
        getglobal("DHUD_TargetElite_Texture"):SetTexCoord(x0,x1,y0,y1);
        getglobal("DHUD_TargetElite"):Show();
    else
        getglobal("DHUD_TargetElite"):Hide();
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
    -- standard mode     	    		       
    else
        self:setAlpha("oocalpha");
    end
    
end
                
-- set alpha (combatalpha oocalpha selectalpha regenalpha)
function DHUD:setAlpha(mode)
    self:printd("Alphamode: "..mode);

    for k, v in pairs(self.alpha_textures) do
        local texture = getglobal(v);
        texture:SetAlpha(DHUD_Settings[mode]);
    end	
    self.CastingAlpha = DHUD_Settings[mode];
    
    -- hide player text when alpha = 0 
    if DHUD_Settings[mode] == 0 then
        getglobal("DHUD_PlayerHealth_Text"):Hide();
        getglobal("DHUD_PlayerMana_Text"):Hide();
        getglobal("DHUD_PetHealth_Text"):Hide();
        getglobal("DHUD_PetMana_Text"):Hide();
        getglobal("DHUD_PlayerBuff1"):Hide();
        getglobal("DHUD_PlayerBuff2"):Hide();
        getglobal("DHUD_PlayerBuff3"):Hide();
        getglobal("DHUD_PlayerBuff4"):Hide();
        getglobal("DHUD_PlayerBuff5"):Hide();
        getglobal("DHUD_PlayerBuff6"):Hide();
        getglobal("DHUD_PlayerBuff7"):Hide();
        getglobal("DHUD_PlayerBuff8"):Hide();
        getglobal("DHUD_PlayerBuff9"):Hide();
        getglobal("DHUD_PlayerBuff10"):Hide();
        getglobal("DHUD_PlayerBuff11"):Hide();
        getglobal("DHUD_PlayerBuff12"):Hide();
        getglobal("DHUD_PlayerBuff13"):Hide();
        getglobal("DHUD_PlayerBuff14"):Hide();
        getglobal("DHUD_PlayerBuff15"):Hide();
        getglobal("DHUD_PlayerBuff16"):Hide();
    elseif not UnitIsDeadOrGhost("player") then
        getglobal("DHUD_PlayerHealth_Text"):Show();
        getglobal("DHUD_PlayerMana_Text"):Show();  
        getglobal("DHUD_PetHealth_Text"):Show();
        getglobal("DHUD_PetMana_Text"):Show(); 
        getglobal("DHUD_PlayerBuff1"):Show();
        getglobal("DHUD_PlayerBuff2"):Show();
        getglobal("DHUD_PlayerBuff3"):Show();
        getglobal("DHUD_PlayerBuff4"):Show();
        getglobal("DHUD_PlayerBuff5"):Show();
        getglobal("DHUD_PlayerBuff6"):Show();
        getglobal("DHUD_PlayerBuff7"):Show();
        getglobal("DHUD_PlayerBuff8"):Show();
        getglobal("DHUD_PlayerBuff9"):Show();
        getglobal("DHUD_PlayerBuff10"):Show();
        getglobal("DHUD_PlayerBuff11"):Show();
        getglobal("DHUD_PlayerBuff12"):Show();
        getglobal("DHUD_PlayerBuff13"):Show();
        getglobal("DHUD_PlayerBuff14"):Show();
        getglobal("DHUD_PlayerBuff15"):Show();
        getglobal("DHUD_PlayerBuff16"):Show();
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
        getglobal("DHUD_PlayerInCombat"):Show();
        return;
    else
        getglobal("DHUD_PlayerInCombat"):Hide();
    end
    
    if IsResting() and DHUD_Settings["showresticon"] == 1 and not UnitIsDeadOrGhost("player") then
        getglobal("DHUD_PlayerResting"):Show();
    else
        getglobal("DHUD_PlayerResting"):Hide();
    end
end

-- raid icon
function DHUD:updateRaidIcon()
    local tex = getglobal("DHUD_RaidIcon_Texture");
    local texture = nil;
    
    if DHUD_Settings["showraidicon"] == 1 and UnitExists("target") then
        local index = GetRaidTargetIndex("target");
        
        if index and index > 0 and index <= 8 then
            texture,x0,x1,y0,y1 = unpack( self.C_textures["DHUD_RaidIcon" .. index] );
        end
        
        if texture then
            tex:SetTexture(texture);
            tex:SetTexCoord(x0,x1,y0,y1);
            getglobal("DHUD_RaidIcon"):Show();
        else
            getglobal("DHUD_RaidIcon"):Hide();
        end
    else
        getglobal("DHUD_RaidIcon"):Hide();
    end
end


-- pvp status
function DHUD:updatePlayerPvP()    
    local tex = getglobal("DHUD_PlayerPvP_Texture");
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
            getglobal("DHUD_PlayerPvP"):Show();
        else
            getglobal("DHUD_PlayerPvP"):Hide();
        end
    else
        getglobal("DHUD_PlayerPvP"):Hide();
    end
end

-- pvp icon target
function DHUD:updateTargetPvP()    
    local tex = getglobal("DHUD_TargetPvP_Texture");
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
            getglobal("DHUD_TargetPvP"):Show();
        else
            getglobal("DHUD_TargetPvP"):Hide();
        end
    else
        getglobal("DHUD_TargetPvP"):Hide();
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
            local tex = getglobal("DHUD_PetHappy_Texture");
            tex:SetTexture(texture);
            tex:SetTexCoord(x0,x1,y0,y1);	
            getglobal("DHUD_PetHappy"):Show();
        else
            getglobal("DHUD_PetHappy"):Hide();
        end
    else
        getglobal("DHUD_PetHappy"):Hide();
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
function DHUD_Target_DropDown_Initialize()
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
        UnitPopup_ShowMenu( DHUD_Target_DropDown, menu, "target" );
    end
end

-- player dropdown
function DHUD_Player_DropDown_Initialize()
    UnitPopup_ShowMenu( DHUD_Player_DropDown, "SELF", "player" );
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