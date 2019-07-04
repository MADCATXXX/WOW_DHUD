
-- Settingnames
if not DHUD_Layouts then DHUD_Layouts = {} end;
DHUD_Layouts.DHUD_Standard_Layout = { 
    ["name"] = "Default Layout",
    ["DHUD_textures"] = {
        ["DHUD_PlayerHealth_Bar"] = { "Interface\\AddOns\\DHUD\\layout\\1"      , 0 , 1 , 0 , 1 },
        ["DHUD_PlayerMana_Bar"]   = { "Interface\\AddOns\\DHUD\\layout\\1"      , 1 , 0 , 0 , 1 },
        ["DHUD_TargetHealth_Bar"] = { "Interface\\AddOns\\DHUD\\layout\\2"      , 0 , 1 , 0 , 1 },
        ["DHUD_TargetMana_Bar"]   = { "Interface\\AddOns\\DHUD\\layout\\2"      , 1 , 0 , 0 , 1 },
        ["DHUD_PetHealth_Bar"]    = { "Interface\\AddOns\\DHUD\\layout\\p1"     , 0 , 1 , 0 , 1 },
        ["DHUD_PetMana_Bar"]      = { "Interface\\AddOns\\DHUD\\layout\\p1"     , 1 , 0 , 0 , 1 },
        ["DHUD_Casting_Bar"]      = { "Interface\\AddOns\\DHUD\\layout\\cb"     , 1 , 0 , 0 , 1 },
        ["DHUD_Flash_Bar"]        = { "Interface\\AddOns\\DHUD\\layout\\cbh"    , 1 , 0 , 0 , 1 },
		["DHUD_EnemyCasting_Bar"] = { "Interface\\AddOns\\DHUD\\layout\\ecb"    , 1 , 0 , 0 , 1 },
        ["DHUD_EnemyFlash_Bar"]   = { "Interface\\AddOns\\DHUD\\layout\\ecbh"   , 1 , 0 , 0 , 1 },
		["DHUD_EnemyCB_Texture"]  = { "Interface\\TargetingFrame\\UI-PVP-FFA"   , 0 , 1 , 0 , 1 },
		["DHUD_CB_Texture"]       = { "Interface\\TargetingFrame\\UI-PVP-FFA"   , 0 , 1 , 0 , 1 },
        ["DHUD_Combo1"]           = { "Interface\\AddOns\\DHUD\\layout\\c1"     , 0 , 1 , 0 , 1 },
        ["DHUD_Combo2"]           = { "Interface\\AddOns\\DHUD\\layout\\c2"     , 0 , 1 , 0 , 1 },
        ["DHUD_Combo3"]           = { "Interface\\AddOns\\DHUD\\layout\\c3"     , 0 , 1 , 0 , 1 },
        ["DHUD_Combo4"]           = { "Interface\\AddOns\\DHUD\\layout\\c4"     , 0 , 1 , 0 , 1 },
        ["DHUD_Combo5"]           = { "Interface\\AddOns\\DHUD\\layout\\c5"     , 0 , 1 , 0 , 1 },
        
		["DHUD_Rune1"]            = { "Interface\\PlayerFrame\\UI-PlayerFrame-Deathknight-Blood"     , 0 , 1 , 0 , 1 },
		["DHUD_Rune2"]            = { "Interface\\PlayerFrame\\UI-PlayerFrame-Deathknight-Blood"     , 0 , 1 , 0 , 1 },
		["DHUD_Rune5"]            = { "Interface\\PlayerFrame\\UI-PlayerFrame-Deathknight-Frost"     , 0 , 1 , 0 , 1 },
		["DHUD_Rune6"]            = { "Interface\\PlayerFrame\\UI-PlayerFrame-Deathknight-Frost"     , 0 , 1 , 0 , 1 },
		["DHUD_Rune3"]            = { "Interface\\PlayerFrame\\UI-PlayerFrame-Deathknight-Unholy"     , 0 , 1 , 0 , 1 },
		["DHUD_Rune4"]            = { "Interface\\PlayerFrame\\UI-PlayerFrame-Deathknight-Unholy"     , 0 , 1 , 0 , 1 },
		--Death rune: Interface\\PlayerFrame\\UI-PlayerFrame-Deathknight-Death
		
        ["l_ph_pm"]               = { "Interface\\AddOns\\DHUD\\layout\\bg_1"    , 0 , 1 , 0 , 1 },
        ["r_ph_pm"]               = { "Interface\\AddOns\\DHUD\\layout\\bg_1"    , 1 , 0 , 0 , 1 },
        
        ["l_ph_pm_em"]            = { "Interface\\AddOns\\DHUD\\layout\\bg_1"    , 0 , 1 , 0 , 1 },        
        ["r_ph_pm_em"]            = { "Interface\\AddOns\\DHUD\\layout\\bg_1p"   , 1 , 0 , 0 , 1 },
        
        ["l_ph_pm_eh_em"]         = { "Interface\\AddOns\\DHUD\\layout\\bg_1p"   , 0 , 1 , 0 , 1 },        
        ["r_ph_pm_eh_em"]         = { "Interface\\AddOns\\DHUD\\layout\\bg_1p"   , 1 , 0 , 0 , 1 },

        ["l_ph_pm_eh"]            = { "Interface\\AddOns\\DHUD\\layout\\bg_1p"   , 0 , 1 , 0 , 1 },        
        ["r_ph_pm_eh"]            = { "Interface\\AddOns\\DHUD\\layout\\bg_1"    , 1 , 0 , 0 , 1 },
                
        ["l_ph_pm_th"]            = { "Interface\\AddOns\\DHUD\\layout\\bg_21"   , 0 , 1 , 0 , 1 },
        ["r_ph_pm_th"]            = { "Interface\\AddOns\\DHUD\\layout\\bg_1"    , 1 , 0 , 0 , 1 },
        
        ["l_ph_pm_em_th"]         = { "Interface\\AddOns\\DHUD\\layout\\bg_21"   , 0 , 1 , 0 , 1 },
        ["r_ph_pm_em_th"]         = { "Interface\\AddOns\\DHUD\\layout\\bg_1p"   , 1 , 0 , 0 , 1 },

        --["l_ph_pm_eh_th"]         = { "Interface\\AddOns\\DHUD\\layout\\bg_21"   , 0 , 1 , 0 , 1 },
        --["r_ph_pm_eh_th"]         = { "Interface\\AddOns\\DHUD\\layout\\bg_1p"   , 1 , 0 , 0 , 1 },

        ["l_ph_pm_th_tm"]         = { "Interface\\AddOns\\DHUD\\layout\\bg_21"   , 0 , 1 , 0 , 1 },
        ["r_ph_pm_th_tm"]         = { "Interface\\AddOns\\DHUD\\layout\\bg_21"   , 1 , 0 , 0 , 1 },
                        
        ["l_ph_pm_eh_th"]         = { "Interface\\AddOns\\DHUD\\layout\\bg_21p"  , 0 , 1 , 0 , 1 },
        ["r_ph_pm_eh_th"]         = { "Interface\\AddOns\\DHUD\\layout\\bg_1"    , 1 , 0 , 0 , 1 },

        ["l_ph_pm_eh_th_tm"]      = { "Interface\\AddOns\\DHUD\\layout\\bg_21"   , 0 , 1 , 0 , 1 }, 
        ["r_ph_pm_eh_th_tm"]      = { "Interface\\AddOns\\DHUD\\layout\\bg_21p"  , 1 , 0 , 0 , 1 },
        
        ["l_ph_pm_em_th_tm"]      = { "Interface\\AddOns\\DHUD\\layout\\bg_21"   , 0 , 1 , 0 , 1 },
        ["r_ph_pm_em_th_tm"]      = { "Interface\\AddOns\\DHUD\\layout\\bg_21p"  , 1 , 0 , 0 , 1 },

        ["l_ph_pm_eh_em_th"]      = { "Interface\\AddOns\\DHUD\\layout\\bg_21p"  , 0 , 1 , 0 , 1 },
        ["r_ph_pm_eh_em_th"]      = { "Interface\\AddOns\\DHUD\\layout\\bg_1p"   , 1 , 0 , 0 , 1 },
                
        ["l_ph_pm_eh_em_th_tm"]   = { "Interface\\AddOns\\DHUD\\layout\\bg_21p"  , 0 , 1 , 0 , 1 },
        ["r_ph_pm_eh_em_th_tm"]   = { "Interface\\AddOns\\DHUD\\layout\\bg_21p"  , 1 , 0 , 0 , 1 },
		
		["l_ph_pm_eh_th_tm"]      = { "Interface\\AddOns\\DHUD\\layout\\bg_21p"  , 0 , 1 , 0 , 1 },
        ["r_ph_pm_eh_th_tm"]      = { "Interface\\AddOns\\DHUD\\layout\\bg_21p"  , 1 , 0 , 0 , 1 },
                
        ["DHUD_LeftFrame"]        = { "Interface\\AddOns\\DHUD\\layout\\bg_21p"  , 0 , 1 , 0 , 1 },
        ["DHUD_RightFrame"]       = { "Interface\\AddOns\\DHUD\\layout\\bg_21p"  , 1 , 0 , 0 , 1 },
        
        ["DHUD_PlayerResting"]    = { "Interface\\CharacterFrame\\UI-StateIcon"             , 0.0625 , 0.4475 , 0.0625 , 0.4375 },
        ["DHUD_PlayerInCombat"]   = { "Interface\\CharacterFrame\\UI-StateIcon"             , 0.5625 , 0.9375 , 0.0625 , 0.4375 },
        ["DHUD_PlayerLeader"]     = { "Interface\\GroupFrame\\UI-Group-LeaderIcon"          , 0     , 1     , 0     , 1     },
        ["DHUD_PlayerLooter"]     = { "Interface\\GroupFrame\\UI-Group-MasterLooter"        , 0     , 1     , 0     , 1     },
        ["DHUD_PetHappy"]         = { "Interface\\PetPaperDollFrame\\UI-PetHappiness"       , 0     , 0.1875, 0     , 0.359375 },
        ["DHUD_PetNormal"]        = { "Interface\\PetPaperDollFrame\\UI-PetHappiness"       , 0.1875, 0.375 , 0     , 0.359375 },
        ["DHUD_PetUnhappy"]       = { "Interface\\PetPaperDollFrame\\UI-PetHappiness"       , 0.375 , 0.5625, 0     , 0.359375 },
        ["DHUD_TargetPvP"]        = { "Interface\\TargetingFrame\\UI-PVP-Horde"             , 0.6   , 0     , 0     , 0.6   },
        ["DHUD_PlayerPvP"]        = { "Interface\\TargetingFrame\\UI-PVP-Alliance"          , 0     , 0.6   , 0     , 0.6   }, 
        ["DHUD_FreePvP"]          = { "Interface\\TargetingFrame\\UI-PVP-FFA"               , 0     , 0.6   , 0     , 0.6   },    
        ["DHUD_TargetElite"]      = { "Interface\\AddOns\\DHUD\\layout\\elite"              , 0     , 1     , 0     , 1     },   
        ["DHUD_TargetRare"]       = { "Interface\\AddOns\\DHUD\\layout\\rare"               , 0     , 1     , 0     , 1     }, 
        ["DHUD_RaidIcon"]         = { "Interface\\TargetingFrame\\UI-RaidTargetingIcons"    , 0.75  , 0.75  , 0.75  , 0.75  },
        ["DHUD_RaidIcon1"]        = { "Interface\\TargetingFrame\\UI-RaidTargetingIcons"    , 0     , 0.25  , 0     , 0.25  },
        ["DHUD_RaidIcon2"]        = { "Interface\\TargetingFrame\\UI-RaidTargetingIcons"    , 0.25  , 0.50  , 0     , 0.25  },
        ["DHUD_RaidIcon3"]        = { "Interface\\TargetingFrame\\UI-RaidTargetingIcons"    , 0.50  , 0.75  , 0     , 0.25  },
        ["DHUD_RaidIcon4"]        = { "Interface\\TargetingFrame\\UI-RaidTargetingIcons"    , 0.75  , 1     , 0     , 0.25  },
        ["DHUD_RaidIcon5"]        = { "Interface\\TargetingFrame\\UI-RaidTargetingIcons"    , 0     , 0.25  , 0.25  , 0.50  },
        ["DHUD_RaidIcon6"]        = { "Interface\\TargetingFrame\\UI-RaidTargetingIcons"    , 0.25  , 0.50  , 0.25  , 0.50  },
        ["DHUD_RaidIcon7"]        = { "Interface\\TargetingFrame\\UI-RaidTargetingIcons"    , 0.50  , 0.75  , 0.25  , 0.50  },
        ["DHUD_RaidIcon8"]        = { "Interface\\TargetingFrame\\UI-RaidTargetingIcons"    , 0.75  , 1     , 0.25  , 0.50  },
        --["DHUD_PlayerAura"]       = { "Interface\\AddOns\\DHUD\\layout\\serenity0"          , 0   , 1 , 0 , 1 },
    },
    ["DHUD_frames"] = {
        ["DHUD_Main"]              = { "Frame"      , "CENTER" , "UIParent"          , "CENTER"  , 0    , 0    , 512 , 256 },
        ["DHUD_LeftFrame"]         = { "Texture"    , "LEFT"   , "DHUD_Main"         , "LEFT"    , 0    , 0    , 128 , 256 },
        ["DHUD_RightFrame"]        = { "Texture"    , "RIGHT"  , "DHUD_Main"         , "RIGHT"   , 0    , 0    , 128 , 256 },
        ["DHUD_PlayerHealth_Bar"]  = { "Bar"        , "BOTTOM" , "DHUD_LeftFrame"    , "BOTTOM"  , 0    , 0    , 128 , 256 },
        ["DHUD_PlayerMana_Bar"]    = { "Bar"        , "BOTTOM" , "DHUD_RightFrame"   , "BOTTOM"  , 0    , 0    , 128 , 256 },
        ["DHUD_TargetHealth_Bar"]  = { "Bar"        , "BOTTOM" , "DHUD_LeftFrame"    , "BOTTOM"  , 0    , 0    , 128 , 256 },
        ["DHUD_TargetMana_Bar"]    = { "Bar"        , "BOTTOM" , "DHUD_RightFrame"   , "BOTTOM"  , 0    , 0    , 128 , 256 },
        ["DHUD_PetHealth_Bar"]     = { "Bar"        , "BOTTOM" , "DHUD_LeftFrame"    , "BOTTOM"  , 0    , 0    , 128 , 256 },
        ["DHUD_PetMana_Bar"]       = { "Bar"        , "BOTTOM" , "DHUD_RightFrame"   , "BOTTOM"  , 0    , 0    , 128 , 256 },
        ["DHUD_Casting_Bar"]       = { "Bar"        , "BOTTOM" , "DHUD_RightFrame"   , "BOTTOM"  , 0    , 0    , 128 , 256 },
        ["DHUD_Flash_Bar"]         = { "Bar"        , "BOTTOM" , "DHUD_RightFrame"   , "BOTTOM"  , 0    , 0    , 128 , 256 },
		["DHUD_EnemyCasting_Bar"]  = { "Bar"        , "BOTTOM" , "DHUD_RightFrame"   , "BOTTOM"  , 1    , -1    , 128 , 256 },
        ["DHUD_EnemyFlash_Bar"]    = { "Bar"        , "BOTTOM" , "DHUD_RightFrame"   , "BOTTOM"  , -3   , 0    , 128 , 256 },
		["DHUD_EnemyCB_Texture"]   = { "Texture"    , "BOTTOM" , "DHUD_RightFrame"   , "BOTTOM"  , -25  , 285  , 30  , 30 },
		["DHUD_EnemyCB_Text"]      = { "Text"       , "TOPLEFT", "DHUD_RightFrame"   , "TOPLEFT" , 50  , 43    , 100 , 14 },
		["DHUD_CB_Texture"]        = { "Texture"    , "BOTTOM" , "DHUD_RightFrame"   , "BOTTOM"  , -60  , 275  , 30  , 30 },
		["DHUD_CB_Text"]           = { "Text"       , "TOPRIGHT", "DHUD_RightFrame"  , "TOPRIGHT", -138  , 33    , 100 , 14 },
        ["DHUD_Combo1"]            = { "Texture"    , "BOTTOM" , "DHUD_LeftFrame"    , "BOTTOM"  , 6    , 0    , 20  , 20 },
        ["DHUD_Combo2"]            = { "Texture"    , "BOTTOM" , "DHUD_LeftFrame"    , "BOTTOM"  , -1   , 20   , 20  , 20 },
        ["DHUD_Combo3"]            = { "Texture"    , "BOTTOM" , "DHUD_LeftFrame"    , "BOTTOM"  , -7   , 40   , 20  , 20 },
        ["DHUD_Combo4"]            = { "Texture"    , "BOTTOM" , "DHUD_LeftFrame"    , "BOTTOM"  , -11  , 60   , 20  , 20 },
        ["DHUD_Combo5"]            = { "Texture"    , "BOTTOM" , "DHUD_LeftFrame"    , "BOTTOM"  , -13  , 80   , 20  , 20 },
        ["DHUD_Target_Text"]       = { "Text"       , "BOTTOM" , "DHUD_Main"         , "BOTTOM"  , 0    , -45  , 200 , 14 },
        ["DHUD_TargetTarget_Text"] = { "Text"       , "BOTTOM" , "DHUD_Main"         , "BOTTOM"  , 0    , -65  , 200 , 14 },
		
		["DHUD_Rune1"]             = { "Texture"    , "BOTTOM" , "DHUD_LeftFrame"    , "BOTTOM"  , -10    , 0    , 30  , 30 },
        ["DHUD_Rune2"]             = { "Texture"    , "BOTTOM" , "DHUD_LeftFrame"    , "BOTTOM"  , -17   , 30   , 30  , 30 },
        ["DHUD_Rune5"]             = { "Texture"    , "BOTTOM" , "DHUD_LeftFrame"    , "BOTTOM"  , -22   , 60   , 30  , 30 },
        ["DHUD_Rune6"]             = { "Texture"    , "BOTTOM" , "DHUD_LeftFrame"    , "BOTTOM"  , -24  , 90   , 30  , 30 },
        ["DHUD_Rune3"]             = { "Texture"    , "BOTTOM" , "DHUD_LeftFrame"    , "BOTTOM"  , -24  , 120  , 30  , 30 },
		["DHUD_Rune4"]             = { "Texture"    , "BOTTOM" , "DHUD_LeftFrame"    , "BOTTOM"  , -22  , 150  , 30  , 30 },
        ["DHUD_Rune1_Text"] 	   = { "Text"       , "BOTTOM" , "DHUD_LeftFrame"    , "BOTTOM"  , -10  , 9    , 200 , 14 },
		["DHUD_Rune2_Text"] 	   = { "Text"       , "BOTTOM" , "DHUD_LeftFrame"    , "BOTTOM"  , -17  , 39   , 100 , 14 },
		["DHUD_Rune5_Text"] 	   = { "Text"       , "BOTTOM" , "DHUD_LeftFrame"    , "BOTTOM"  , -22  , 69   , 100 , 14 },
		["DHUD_Rune6_Text"] 	   = { "Text"       , "BOTTOM" , "DHUD_LeftFrame"    , "BOTTOM"  , -24  , 99   , 100 , 14 },
		["DHUD_Rune3_Text"] 	   = { "Text"       , "BOTTOM" , "DHUD_LeftFrame"    , "BOTTOM"  , -24  , 129  , 100 , 14 },
		["DHUD_Rune4_Text"] 	   = { "Text"       , "BOTTOM" , "DHUD_LeftFrame"    , "BOTTOM"  , -22  , 159  , 100 , 14 },
		
        ["DHUD_PlayerHealth_Text"] = { "Text"       , "BOTTOM" , "DHUD_LeftFrame"    , "BOTTOM"  , 95   , 2    , 200 , 14 },
        ["DHUD_PlayerMana_Text"]   = { "Text"       , "BOTTOM" , "DHUD_RightFrame"   , "BOTTOM"  , -95  , 2    , 200 , 14 },
        
        ["DHUD_TargetHealth_Text"] = { "Text"       , "BOTTOM" , "DHUD_LeftFrame"    , "BOTTOM"  , 80   , -16  , 200 , 14 },
        ["DHUD_TargetMana_Text"]   = { "Text"       , "BOTTOM" , "DHUD_RightFrame"   , "BOTTOM"  , -80  , -16  , 200 , 14 },
        
        ["DHUD_PetHealth_Text"]    = { "Text"       , "BOTTOM" , "DHUD_LeftFrame"    , "BOTTOM"  , 110  , 19   , 200 , 14 },
        ["DHUD_PetMana_Text"]      = { "Text"       , "BOTTOM" , "DHUD_RightFrame"   , "BOTTOM"  , -110 , 19   , 200 , 14 }, 
        
        ["DHUD_Casttime_Text"]     = { "Text"       , "TOPRIGHT", "DHUD_RightFrame"   , "TOPRIGHT" , -88  , 5    , 100 , 14 },
        ["DHUD_Castdelay_Text"]    = { "Text"       , "TOPRIGHT", "DHUD_RightFrame"   , "TOPRIGHT" , -88  , 19   , 100 , 14 }, 
        
		["DHUD_EnemyCasttime_Text"]  = { "Text"       , "TOPRIGHT", "DHUD_RightFrame"   , "TOPRIGHT" , -60  , 15    , 100 , 14 },
        ["DHUD_EnemyCastdelay_Text"] = { "Text"       , "TOPRIGHT", "DHUD_RightFrame"   , "TOPRIGHT" , -60  , 29   , 100 , 14 }, 
        
        ["DHUD_Buff1"]             = { "Buff"       , "RIGHT"  , "DHUD_Target_Text"  , "LEFT"    , -1   , 0    , 20  , 20 },
        ["DHUD_Buff2"]             = { "Buff"       , "RIGHT"  , "DHUD_Buff1"        , "LEFT"    , -1   , 0    , 20  , 20 },
        ["DHUD_Buff3"]             = { "Buff"       , "RIGHT"  , "DHUD_Buff2"        , "LEFT"    , -1   , 0    , 20  , 20 },
        ["DHUD_Buff4"]             = { "Buff"       , "RIGHT"  , "DHUD_Buff3"        , "LEFT"    , -1   , 0    , 20  , 20 },
        ["DHUD_Buff5"]             = { "Buff"       , "RIGHT"  , "DHUD_Buff4"        , "LEFT"    , -1   , 0    , 20  , 20 },
        ["DHUD_Buff6"]             = { "Buff"       , "RIGHT"  , "DHUD_Buff5"        , "LEFT"    , -1   , 0    , 20  , 20 },
        ["DHUD_Buff7"]             = { "Buff"       , "RIGHT"  , "DHUD_Buff6"        , "LEFT"    , -1   , 0    , 20  , 20 },
        ["DHUD_Buff8"]             = { "Buff"       , "RIGHT"  , "DHUD_Buff7"        , "LEFT"    , -1   , 0    , 20  , 20 },
        ["DHUD_Buff9"]             = { "Buff"       , "RIGHT"  , "DHUD_Buff1"        , "LEFT"    , 20   , -21  , 20  , 20 },
        ["DHUD_Buff10"]            = { "Buff"       , "RIGHT"  , "DHUD_Buff9"        , "LEFT"    , -1   , 0    , 20  , 20 },
        ["DHUD_Buff11"]            = { "Buff"       , "RIGHT"  , "DHUD_Buff10"       , "LEFT"    , -1   , 0    , 20  , 20 },
        ["DHUD_Buff12"]            = { "Buff"       , "RIGHT"  , "DHUD_Buff11"       , "LEFT"    , -1   , 0    , 20  , 20 },
        ["DHUD_Buff13"]            = { "Buff"       , "RIGHT"  , "DHUD_Buff12"       , "LEFT"    , -1   , 0    , 20  , 20 },
        ["DHUD_Buff14"]            = { "Buff"       , "RIGHT"  , "DHUD_Buff13"       , "LEFT"    , -1   , 0    , 20  , 20 },
        ["DHUD_Buff15"]            = { "Buff"       , "RIGHT"  , "DHUD_Buff14"       , "LEFT"    , -1   , 0    , 20  , 20 },
        ["DHUD_Buff16"]            = { "Buff"       , "RIGHT"  , "DHUD_Buff15"       , "LEFT"    , -1   , 0    , 20  , 20 },
        ["DHUD_Buff17"]            = { "Buff"       , "RIGHT"  , "DHUD_Buff9"        , "LEFT"    , 20   , -21  , 20  , 20 },
        ["DHUD_Buff18"]            = { "Buff"       , "RIGHT"  , "DHUD_Buff17"       , "LEFT"    , -1   , 0    , 20  , 20 },
        ["DHUD_Buff19"]            = { "Buff"       , "RIGHT"  , "DHUD_Buff18"       , "LEFT"    , -1   , 0    , 20  , 20 },
        ["DHUD_Buff20"]            = { "Buff"       , "RIGHT"  , "DHUD_Buff19"       , "LEFT"    , -1   , 0    , 20  , 20 },
        ["DHUD_Buff21"]            = { "Buff"       , "RIGHT"  , "DHUD_Buff20"       , "LEFT"    , -1   , 0    , 20  , 20 },
        ["DHUD_Buff22"]            = { "Buff"       , "RIGHT"  , "DHUD_Buff21"       , "LEFT"    , -1   , 0    , 20  , 20 },
        ["DHUD_Buff23"]            = { "Buff"       , "RIGHT"  , "DHUD_Buff22"       , "LEFT"    , -1   , 0    , 20  , 20 },
        ["DHUD_Buff24"]            = { "Buff"       , "RIGHT"  , "DHUD_Buff23"       , "LEFT"    , -1   , 0    , 20  , 20 },
        ["DHUD_Buff25"]            = { "Buff"       , "RIGHT"  , "DHUD_Buff17"       , "LEFT"    , 20   , -21  , 20  , 20 },
        ["DHUD_Buff26"]            = { "Buff"       , "RIGHT"  , "DHUD_Buff25"       , "LEFT"    , -1   , 0    , 20  , 20 },
        ["DHUD_Buff27"]            = { "Buff"       , "RIGHT"  , "DHUD_Buff26"       , "LEFT"    , -1   , 0    , 20  , 20 },
        ["DHUD_Buff28"]            = { "Buff"       , "RIGHT"  , "DHUD_Buff27"       , "LEFT"    , -1   , 0    , 20  , 20 },
        ["DHUD_Buff29"]            = { "Buff"       , "RIGHT"  , "DHUD_Buff28"       , "LEFT"    , -1   , 0    , 20  , 20 },
        ["DHUD_Buff30"]            = { "Buff"       , "RIGHT"  , "DHUD_Buff29"       , "LEFT"    , -1   , 0    , 20  , 20 },
        ["DHUD_Buff31"]            = { "Buff"       , "RIGHT"  , "DHUD_Buff30"       , "LEFT"    , -1   , 0    , 20  , 20 },
        ["DHUD_Buff32"]            = { "Buff"       , "RIGHT"  , "DHUD_Buff31"       , "LEFT"    , -1   , 0    , 20  , 20 },
        ["DHUD_Buff33"]            = { "Buff"       , "RIGHT"  , "DHUD_Buff25"       , "LEFT"    , 20   , -21  , 20  , 20 },
        ["DHUD_Buff34"]            = { "Buff"       , "RIGHT"  , "DHUD_Buff33"       , "LEFT"    , -1   , 0    , 20  , 20 },
        ["DHUD_Buff35"]            = { "Buff"       , "RIGHT"  , "DHUD_Buff34"       , "LEFT"    , -1   , 0    , 20  , 20 },
        ["DHUD_Buff36"]            = { "Buff"       , "RIGHT"  , "DHUD_Buff35"       , "LEFT"    , -1   , 0    , 20  , 20 },
        ["DHUD_Buff37"]            = { "Buff"       , "RIGHT"  , "DHUD_Buff36"       , "LEFT"    , -1   , 0    , 20  , 20 },
        ["DHUD_Buff38"]            = { "Buff"       , "RIGHT"  , "DHUD_Buff37"       , "LEFT"    , -1   , 0    , 20  , 20 },
        ["DHUD_Buff39"]            = { "Buff"       , "RIGHT"  , "DHUD_Buff38"       , "LEFT"    , -1   , 0    , 20  , 20 },
        ["DHUD_Buff40"]            = { "Buff"       , "RIGHT"  , "DHUD_Buff39"       , "LEFT"    , -1   , 0    , 20  , 20 },
        ["DHUD_DeBuff1"]           = { "Buff"       , "LEFT"   , "DHUD_Target_Text"  , "RIGHT"   , 1    , 0    , 20  , 20 },
        ["DHUD_DeBuff2"]           = { "Buff"       , "LEFT"   , "DHUD_DeBuff1"      , "RIGHT"   , 1    , 0    , 20  , 20 },
        ["DHUD_DeBuff3"]           = { "Buff"       , "LEFT"   , "DHUD_DeBuff2"      , "RIGHT"   , 1    , 0    , 20  , 20 },
        ["DHUD_DeBuff4"]           = { "Buff"       , "LEFT"   , "DHUD_DeBuff3"      , "RIGHT"   , 1    , 0    , 20  , 20 },
        ["DHUD_DeBuff5"]           = { "Buff"       , "LEFT"   , "DHUD_DeBuff4"      , "RIGHT"   , 1    , 0    , 20  , 20 },
        ["DHUD_DeBuff6"]           = { "Buff"       , "LEFT"   , "DHUD_DeBuff5"      , "RIGHT"   , 1    , 0    , 20  , 20 },
        ["DHUD_DeBuff7"]           = { "Buff"       , "LEFT"   , "DHUD_DeBuff6"      , "RIGHT"   , 1    , 0    , 20  , 20 },
        ["DHUD_DeBuff8"]           = { "Buff"       , "LEFT"   , "DHUD_DeBuff7"      , "RIGHT"   , 1    , 0    , 20  , 20 },
        ["DHUD_DeBuff9"]           = { "Buff"       , "LEFT"   , "DHUD_DeBuff1"      , "RIGHT"   , -20  , -21  , 20  , 20 },
        ["DHUD_DeBuff10"]          = { "Buff"       , "LEFT"   , "DHUD_DeBuff9"      , "RIGHT"   , 1    , 0    , 20  , 20 },
        ["DHUD_DeBuff11"]          = { "Buff"       , "LEFT"   , "DHUD_DeBuff10"     , "RIGHT"   , 1    , 0    , 20  , 20 },
        ["DHUD_DeBuff12"]          = { "Buff"       , "LEFT"   , "DHUD_DeBuff11"     , "RIGHT"   , 1    , 0    , 20  , 20 },
        ["DHUD_DeBuff13"]          = { "Buff"       , "LEFT"   , "DHUD_DeBuff12"     , "RIGHT"   , 1    , 0    , 20  , 20 },
        ["DHUD_DeBuff14"]          = { "Buff"       , "LEFT"   , "DHUD_DeBuff13"     , "RIGHT"   , 1    , 0    , 20  , 20 },
        ["DHUD_DeBuff15"]          = { "Buff"       , "LEFT"   , "DHUD_DeBuff14"     , "RIGHT"   , 1    , 0    , 20  , 20 },
        ["DHUD_DeBuff16"]          = { "Buff"       , "LEFT"   , "DHUD_DeBuff15"     , "RIGHT"   , 1    , 0    , 20  , 20 },
        ["DHUD_DeBuff17"]          = { "Buff"       , "LEFT"   , "DHUD_DeBuff9"      , "RIGHT"   , -20  , -21  , 20  , 20 },
        ["DHUD_DeBuff18"]          = { "Buff"       , "LEFT"   , "DHUD_DeBuff17"     , "RIGHT"   , 1    , 0    , 20  , 20 },
        ["DHUD_DeBuff19"]          = { "Buff"       , "LEFT"   , "DHUD_DeBuff18"     , "RIGHT"   , 1    , 0    , 20  , 20 },
        ["DHUD_DeBuff20"]          = { "Buff"       , "LEFT"   , "DHUD_DeBuff19"     , "RIGHT"   , 1    , 0    , 20  , 20 },
        ["DHUD_DeBuff21"]          = { "Buff"       , "LEFT"   , "DHUD_DeBuff20"     , "RIGHT"   , 1    , 0    , 20  , 20 },
        ["DHUD_DeBuff22"]          = { "Buff"       , "LEFT"   , "DHUD_DeBuff21"     , "RIGHT"   , 1    , 0    , 20  , 20 },
        ["DHUD_DeBuff23"]          = { "Buff"       , "LEFT"   , "DHUD_DeBuff22"     , "RIGHT"   , 1    , 0    , 20  , 20 },
        ["DHUD_DeBuff24"]          = { "Buff"       , "LEFT"   , "DHUD_DeBuff23"     , "RIGHT"   , 1    , 0    , 20  , 20 },
        ["DHUD_DeBuff25"]          = { "Buff"       , "LEFT"   , "DHUD_DeBuff17"     , "RIGHT"   , -20  , -21  , 20  , 20 },
        ["DHUD_DeBuff26"]          = { "Buff"       , "LEFT"   , "DHUD_DeBuff25"     , "RIGHT"   , 1    , 0    , 20  , 20 },
        ["DHUD_DeBuff27"]          = { "Buff"       , "LEFT"   , "DHUD_DeBuff26"     , "RIGHT"   , 1    , 0    , 20  , 20 },
        ["DHUD_DeBuff28"]          = { "Buff"       , "LEFT"   , "DHUD_DeBuff27"     , "RIGHT"   , 1    , 0    , 20  , 20 },
        ["DHUD_DeBuff29"]          = { "Buff"       , "LEFT"   , "DHUD_DeBuff28"     , "RIGHT"   , 1    , 0    , 20  , 20 },
        ["DHUD_DeBuff30"]          = { "Buff"       , "LEFT"   , "DHUD_DeBuff29"     , "RIGHT"   , 1    , 0    , 20  , 20 },
        ["DHUD_DeBuff31"]          = { "Buff"       , "LEFT"   , "DHUD_DeBuff30"     , "RIGHT"   , 1    , 0    , 20  , 20 },
        ["DHUD_DeBuff32"]          = { "Buff"       , "LEFT"   , "DHUD_DeBuff31"     , "RIGHT"   , 1    , 0    , 20  , 20 },
        ["DHUD_DeBuff33"]          = { "Buff"       , "LEFT"   , "DHUD_DeBuff25"     , "RIGHT"   , -20  , -21  , 20  , 20 },
        ["DHUD_DeBuff34"]          = { "Buff"       , "LEFT"   , "DHUD_DeBuff33"     , "RIGHT"   , 1    , 0    , 20  , 20 },
        ["DHUD_DeBuff35"]          = { "Buff"       , "LEFT"   , "DHUD_DeBuff34"     , "RIGHT"   , 1    , 0    , 20  , 20 },
        ["DHUD_DeBuff36"]          = { "Buff"       , "LEFT"   , "DHUD_DeBuff35"     , "RIGHT"   , 1    , 0    , 20  , 20 },
        ["DHUD_DeBuff37"]          = { "Buff"       , "LEFT"   , "DHUD_DeBuff36"     , "RIGHT"   , 1    , 0    , 20  , 20 },
        ["DHUD_DeBuff38"]          = { "Buff"       , "LEFT"   , "DHUD_DeBuff37"     , "RIGHT"   , 1    , 0    , 20  , 20 },
        ["DHUD_DeBuff39"]          = { "Buff"       , "LEFT"   , "DHUD_DeBuff38"     , "RIGHT"   , 1    , 0    , 20  , 20 },
        ["DHUD_DeBuff40"]          = { "Buff"       , "LEFT"   , "DHUD_DeBuff39"     , "RIGHT"   , 1    , 0    , 20  , 20 },
        ["DHUD_PlayerBuff1"]       = { "PlayerBuff" , "BOTTOM" , "DHUD_RightFrame"   , "BOTTOM"  , 7    , 0    , 26  , 26 },
        ["DHUD_PlayerBuff2"]       = { "PlayerBuff" , "BOTTOM" , "DHUD_RightFrame"   , "BOTTOM"  , 16   , 31   , 26  , 26 },
        ["DHUD_PlayerBuff3"]       = { "PlayerBuff" , "BOTTOM" , "DHUD_RightFrame"   , "BOTTOM"  , 21   , 63   , 26  , 26 },
        ["DHUD_PlayerBuff4"]       = { "PlayerBuff" , "BOTTOM" , "DHUD_RightFrame"   , "BOTTOM"  , 24   , 96   , 26  , 26 },
        ["DHUD_PlayerBuff5"]       = { "PlayerBuff" , "BOTTOM" , "DHUD_RightFrame"   , "BOTTOM"  , 24   , 128  , 26  , 26 },
        ["DHUD_PlayerBuff6"]       = { "PlayerBuff" , "BOTTOM" , "DHUD_RightFrame"   , "BOTTOM"  , 22   , 162  , 26  , 26 },
        ["DHUD_PlayerBuff7"]       = { "PlayerBuff" , "BOTTOM" , "DHUD_RightFrame"   , "BOTTOM"  , 17   , 194  , 26  , 26 },
        ["DHUD_PlayerBuff8"]       = { "PlayerBuff" , "BOTTOM" , "DHUD_RightFrame"   , "BOTTOM"  , 9    , 226  , 26  , 26 },
        ["DHUD_PlayerBuff9"]       = { "PlayerBuff" , "BOTTOM" , "DHUD_RightFrame"   , "BOTTOM"  , 40   , 7    , 26  , 26 },
        ["DHUD_PlayerBuff10"]      = { "PlayerBuff" , "BOTTOM" , "DHUD_RightFrame"   , "BOTTOM"  , 47   , 42   , 26  , 26 },
        ["DHUD_PlayerBuff11"]      = { "PlayerBuff" , "BOTTOM" , "DHUD_RightFrame"   , "BOTTOM"  , 52   , 76   , 26  , 26 },
        ["DHUD_PlayerBuff12"]      = { "PlayerBuff" , "BOTTOM" , "DHUD_RightFrame"   , "BOTTOM"  , 53   , 111  , 26  , 26 },
        ["DHUD_PlayerBuff13"]      = { "PlayerBuff" , "BOTTOM" , "DHUD_RightFrame"   , "BOTTOM"  , 52   , 146  , 26  , 26 },
        ["DHUD_PlayerBuff14"]      = { "PlayerBuff" , "BOTTOM" , "DHUD_RightFrame"   , "BOTTOM"  , 49   , 182  , 26  , 26 },
        ["DHUD_PlayerBuff15"]      = { "PlayerBuff" , "BOTTOM" , "DHUD_RightFrame"   , "BOTTOM"  , 42   , 217  , 26  , 26 },
        ["DHUD_PlayerBuff16"]      = { "PlayerBuff" , "BOTTOM" , "DHUD_RightFrame"   , "BOTTOM"  , 35   , 250  , 26  , 26 },
		["DHUD_PlayerBuff17"]      = { "PlayerBuff" , "BOTTOM" , "DHUD_RightFrame"   , "BOTTOM"  , 73   , 16   , 26  , 26 },
		["DHUD_PlayerBuff18"]      = { "PlayerBuff" , "BOTTOM" , "DHUD_RightFrame"   , "BOTTOM"  , 80   , 51   , 26  , 26 },
		["DHUD_PlayerBuff19"]      = { "PlayerBuff" , "BOTTOM" , "DHUD_RightFrame"   , "BOTTOM"  , 86   , 85   , 26  , 26 },
		["DHUD_PlayerBuff20"]      = { "PlayerBuff" , "BOTTOM" , "DHUD_RightFrame"   , "BOTTOM"  , 87   , 117  , 26  , 26 },
		["DHUD_PlayerBuff21"]      = { "PlayerBuff" , "BOTTOM" , "DHUD_RightFrame"   , "BOTTOM"  , 86   , 150  , 26  , 26 },
		["DHUD_PlayerBuff22"]      = { "PlayerBuff" , "BOTTOM" , "DHUD_RightFrame"   , "BOTTOM"  , 83   , 183  , 26  , 26 },
		["DHUD_PlayerBuff23"]      = { "PlayerBuff" , "BOTTOM" , "DHUD_RightFrame"   , "BOTTOM"  , 75   , 216  , 26  , 26 },
		["DHUD_PlayerBuff24"]      = { "PlayerBuff" , "BOTTOM" , "DHUD_RightFrame"   , "BOTTOM"  , 70   , 248  , 26  , 26 },
		["DHUD_TargetDeBuff1"]     = { "PlayerBuff" , "BOTTOM" , "DHUD_RightFrame"   , "BOTTOM"  , -63  , 28    , 26  , 26 },
		["DHUD_TargetDeBuff2"]     = { "PlayerBuff" , "BOTTOM" , "DHUD_RightFrame"   , "BOTTOM"  , -55  , 61   , 26  , 26 },
		["DHUD_TargetDeBuff3"]     = { "PlayerBuff" , "BOTTOM" , "DHUD_RightFrame"   , "BOTTOM"  , -52  , 94   , 26  , 26 },
		["DHUD_TargetDeBuff4"]     = { "PlayerBuff" , "BOTTOM" , "DHUD_RightFrame"   , "BOTTOM"  , -50  , 127   , 26  , 26 },
		["DHUD_TargetDeBuff5"]     = { "PlayerBuff" , "BOTTOM" , "DHUD_RightFrame"   , "BOTTOM"  , -52  , 160  , 26  , 26 },
		["DHUD_TargetDeBuff6"]     = { "PlayerBuff" , "BOTTOM" , "DHUD_RightFrame"   , "BOTTOM"  , -55  , 193  , 26  , 26 },
		["DHUD_TargetDeBuff7"]     = { "PlayerBuff" , "BOTTOM" , "DHUD_RightFrame"   , "BOTTOM"  , -88  , 53  , 26  , 26 },
		["DHUD_TargetDeBuff8"]     = { "PlayerBuff" , "BOTTOM" , "DHUD_RightFrame"   , "BOTTOM"  , -85  , 86  , 26  , 26 },
		["DHUD_TargetDeBuff9"]     = { "PlayerBuff" , "BOTTOM" , "DHUD_RightFrame"   , "BOTTOM"  , -85  , 118  , 26  , 26 },
		["DHUD_TargetDeBuff10"]     = { "PlayerBuff" , "BOTTOM" , "DHUD_RightFrame"   , "BOTTOM"  , -85  , 150  , 26  , 26 },
		["DHUD_TargetDeBuff11"]     = { "PlayerBuff" , "BOTTOM" , "DHUD_RightFrame"   , "BOTTOM"  , -87  , 182  , 26  , 26 },
		["DHUD_TargetDeBuff12"]     = { "PlayerBuff" , "BOTTOM" , "DHUD_RightFrame"   , "BOTTOM"  , -91  , 214  , 26  , 26 },
		["DHUD_PlayerResting"]     = { "Texture"    , "TOP"    , "DHUD_LeftFrame"    , "TOP"     , 42   , 12   , 25  , 25 },
        ["DHUD_PlayerInCombat"]    = { "Texture"    , "TOP"    , "DHUD_LeftFrame"    , "TOP"     , 42   , 12   , 25  , 25 },
        ["DHUD_PlayerLeader"]      = { "Texture"    , "TOP"    , "DHUD_LeftFrame"    , "TOP"     , 48   , -20  , 20  , 20 },
        ["DHUD_PlayerLooter"]      = { "Texture"    , "TOP"    , "DHUD_LeftFrame"    , "TOP"     , 43   , -40  , 18  , 18 },
        ["DHUD_PlayerPvP"]         = { "Texture"    , "TOP"    , "DHUD_LeftFrame"    , "TOP"     , 50   , -15  , 25  , 25 },
        ["DHUD_PetHappy"]          = { "Texture"    , "TOP"    , "DHUD_LeftFrame"    , "TOP"     , 32   , -107 , 20  , 20 },
        ["DHUD_TargetPvP"]         = { "Texture"    , "BOTTOM" , "DHUD_Target_Text"  , "TOP"     , 0    , 0    , 25  , 25 },
        ["DHUD_TargetElite"]       = { "Texture"    , "TOP"    , "DHUD_LeftFrame"    , "TOP"     , 18   , 20   , 64  , 64 },
        ["DHUD_RaidIcon"]          = { "Texture"    , "BOTTOM" , "DHUD_Target_Text"  , "TOP"     , 25   , 0  , 25  , 25 },
        
    },
    ["DHUD_textures_clip"] = {
        ["Interface\\AddOns\\DHUD\\layout\\1"]   = { 256, 11  , 11 },
        ["Interface\\AddOns\\DHUD\\layout\\2"]   = { 256, 5   , 5  },
        ["Interface\\AddOns\\DHUD\\layout\\p1"]  = { 256, 128 , 20 },
        ["Interface\\AddOns\\DHUD\\layout\\p2"]  = { 256, 128 , 20 },	
        ["Interface\\AddOns\\DHUD\\layout\\cb"]  = { 256, 11  , 11 }, 	
        ["Interface\\AddOns\\DHUD\\layout\\cbh"] = { 256, 11  , 11 },
		["Interface\\AddOns\\DHUD\\layout\\ecb"]  = { 258, 4  , 4 },
		["Interface\\AddOns\\DHUD\\layout\\ecbh"]  = { 256, 11  , 11 },
    },
    ["defaultfont"]     = "Fonts/FRIZQT__.TTF",  
    ["defaultfont_num"] = "Interface\\AddOns\\DHUD\\layout\\Number.TTF", 
    ["DHUD_names"] = { 
        "DHUD_Main", 
        "DHUD_LeftFrame",
        "DHUD_RightFrame",
        "DHUD_PlayerHealth_Bar",
        "DHUD_PlayerMana_Bar",
        "DHUD_TargetHealth_Bar",
        "DHUD_TargetMana_Bar",
        "DHUD_PetHealth_Bar",
        "DHUD_PetMana_Bar",
        "DHUD_Combo1",
        "DHUD_Combo2",
        "DHUD_Combo3",
        "DHUD_Combo4",
        "DHUD_Combo5",
		"DHUD_Rune1",
		"DHUD_Rune2",
		"DHUD_Rune3",
		"DHUD_Rune4",
		"DHUD_Rune5",
		"DHUD_Rune6",
		"DHUD_Rune1_Text",
		"DHUD_Rune2_Text",
		"DHUD_Rune3_Text",
		"DHUD_Rune4_Text",
		"DHUD_Rune5_Text",
		"DHUD_Rune6_Text",
        "DHUD_Target_Text",
        "DHUD_TargetTarget_Text",
        "DHUD_PlayerHealth_Text",
        "DHUD_PlayerMana_Text",
        "DHUD_TargetHealth_Text",
        "DHUD_TargetMana_Text",
        "DHUD_PetHealth_Text",
        "DHUD_PetMana_Text",
        "DHUD_Casttime_Text",
        "DHUD_Castdelay_Text",
		"DHUD_EnemyCasttime_Text",
        "DHUD_EnemyCastdelay_Text",
		"DHUD_EnemyCB_Texture",
		"DHUD_EnemyCB_Text",
		"DHUD_CB_Texture",
		"DHUD_CB_Text",
        "DHUD_Buff1",
        "DHUD_Buff2",
        "DHUD_Buff3",
        "DHUD_Buff4",
        "DHUD_Buff5",
        "DHUD_Buff6",
        "DHUD_Buff7",
        "DHUD_Buff8",
        "DHUD_Buff9",
        "DHUD_Buff10",
        "DHUD_Buff11",
        "DHUD_Buff12",
        "DHUD_Buff13",
        "DHUD_Buff14",
        "DHUD_Buff15",
        "DHUD_Buff16",
        "DHUD_Buff17",
        "DHUD_Buff18",
        "DHUD_Buff19",
        "DHUD_Buff20",
        "DHUD_Buff21",
        "DHUD_Buff22",
        "DHUD_Buff23",
        "DHUD_Buff24",
        "DHUD_Buff25",
        "DHUD_Buff26",
        "DHUD_Buff27",
        "DHUD_Buff28",
        "DHUD_Buff29",
        "DHUD_Buff30",
        "DHUD_Buff31",
        "DHUD_Buff32",
        "DHUD_Buff33",
        "DHUD_Buff34",
        "DHUD_Buff35",
        "DHUD_Buff36",
        "DHUD_Buff37",
        "DHUD_Buff38",
        "DHUD_Buff39",
        "DHUD_Buff40",
        "DHUD_DeBuff1",
        "DHUD_DeBuff2",
        "DHUD_DeBuff3",
        "DHUD_DeBuff4",
        "DHUD_DeBuff5",
        "DHUD_DeBuff6",
        "DHUD_DeBuff7",
        "DHUD_DeBuff8",
        "DHUD_DeBuff9",
        "DHUD_DeBuff10",
        "DHUD_DeBuff11",
        "DHUD_DeBuff12",
        "DHUD_DeBuff13",
        "DHUD_DeBuff14",
        "DHUD_DeBuff15",
        "DHUD_DeBuff16",  
        "DHUD_DeBuff17",
        "DHUD_DeBuff18",
        "DHUD_DeBuff19",
        "DHUD_DeBuff20",
        "DHUD_DeBuff21",
        "DHUD_DeBuff22",
        "DHUD_DeBuff23",
        "DHUD_DeBuff24",
        "DHUD_DeBuff25",
        "DHUD_DeBuff26",
        "DHUD_DeBuff27",
        "DHUD_DeBuff28",
        "DHUD_DeBuff29",
        "DHUD_DeBuff30",
        "DHUD_DeBuff31",
        "DHUD_DeBuff32",
        "DHUD_DeBuff33",
        "DHUD_DeBuff34",
        "DHUD_DeBuff35",
        "DHUD_DeBuff36",
        "DHUD_DeBuff37",
        "DHUD_DeBuff38",
        "DHUD_DeBuff39",
        "DHUD_DeBuff40",
        "DHUD_PlayerBuff1",
        "DHUD_PlayerBuff2",
        "DHUD_PlayerBuff3",
        "DHUD_PlayerBuff4",
        "DHUD_PlayerBuff5",
        "DHUD_PlayerBuff6",
        "DHUD_PlayerBuff7",
        "DHUD_PlayerBuff8",
        "DHUD_PlayerBuff9",
        "DHUD_PlayerBuff10",
        "DHUD_PlayerBuff11",
        "DHUD_PlayerBuff12",
        "DHUD_PlayerBuff13",
        "DHUD_PlayerBuff14",
        "DHUD_PlayerBuff15",
        "DHUD_PlayerBuff16",
		"DHUD_PlayerBuff17",
		"DHUD_PlayerBuff18",
		"DHUD_PlayerBuff19",
		"DHUD_PlayerBuff20",
		"DHUD_PlayerBuff21",
		"DHUD_PlayerBuff22",
		"DHUD_PlayerBuff23",
		"DHUD_PlayerBuff24",
		"DHUD_TargetDeBuff1",
        "DHUD_TargetDeBuff2",
        "DHUD_TargetDeBuff3",
        "DHUD_TargetDeBuff4",
        "DHUD_TargetDeBuff5",
        "DHUD_TargetDeBuff6",
        "DHUD_TargetDeBuff7",
        "DHUD_TargetDeBuff8",
		"DHUD_TargetDeBuff9",
		"DHUD_TargetDeBuff10",
		"DHUD_TargetDeBuff11",
		"DHUD_TargetDeBuff12",
        "DHUD_Casting_Bar",
        "DHUD_Flash_Bar",
		"DHUD_EnemyCasting_Bar",
		"DHUD_EnemyFlash_Bar",
        "DHUD_PlayerResting",
        "DHUD_PlayerInCombat",
        --"DHUD_PlayerLeader",
        --"DHUD_PlayerLooter",
        "DHUD_PlayerPvP",
        --"DHUD_PetHappy",
        "DHUD_TargetPvP",
        "DHUD_TargetElite",
        "DHUD_RaidIcon",
    },
}
