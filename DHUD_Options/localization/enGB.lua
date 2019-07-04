DHUDOptionsLocalization = DHUDOptionsLocalization or { };
local L = DHUDOptionsLocalization;
-- buttons text
L["BUTTON_RESET"] = "Reset";
L["BUTTON_PROFILES"] = "Profiles";
L["BUTTON_YES"] = "Yes";
L["BUTTON_NO"] = "No";
-- popup texts
L["POPUP_RESET"] = "Do you really want to\nreset your Settings?";
-- help texts
L["HELP_TIMERS"] = "Enter timer names\nseparated by comma\nor new line feed.\nFor items use item name\nor <slot:id> tag.\n" ..
	"|cff88ff88SlotIds:|r\n" ..
	"Head = 1\nNeck = 2\nShoulder = 3\nShirt = 4\nChest = 5\nWaist = 6\nLegs = 7\nFeet = 8\nWrist = 9\nHands = 10\nRings = 11,12\nTrinkets = 13,14\nCloak = 15\nWeapons = 16,17,18\nTabard = 19";
L["HELP_UNITTEXTS"] = "You can specify tags to\nchange displayed\ninformation.\nEach slot type has\nit's own tags.\nTag parameters are\nparsed as LUA code.\n" ..
	"|cff88ff88Available Tags:|r\n" ..
	"\n|cffff0000All trackers:|r\n" ..
	"<color(\"ffffff\")>\n</color>\n";
L["HELP_UNITTEXTS_TYPE"] = {
	["health"] = 
		"\n|cffff0000Health trackers:|r\n" ..
		"<amount>\n<amount_extra>\n<amount_habsorb>\n<amount_hincome>\n<amount_max>\n<amount_percent>\narg1 = prefix\narg2 = precision\n\n" ..
		"<color_amount>\n<color_amount_extra>\n<color_amount_habsorb>\n<color_amount_hincome>\n",
	["power"] = 
		"\n|cffff0000Power trackers:|r\n" ..
		"<amount>\n<amount_max>\n<amount_percent>\narg1 = prefix\narg2 = precision\n\n" ..
		"<color_amount>\n",
	["unitInfo"] = 
		"\n|cffff0000Info trackers:|r\n" ..
		"<level>\n<elite>\n<name>\n<class>\n<pvp>\n<color_level>\n<color_reaction>\n<color_class>\n\n" ..
		"<guild>\narg1 = prefix\narg2 = postfix\n",
	["cast"] = 
		"\n|cffff0000Cast trackers:|r\n" ..
		"<time>\n<time_remain>\n<time_total>\n\n" ..
		"<delay>\narg1 = cast prefix\narg2 = channel prefix\n\n" ..
		"<spellname>\narg1 = interrupt text\n",
};
-- tabs
L["TAB_GENERAL"] = "General";
L["TAB_LAYOUTS"] = "Layouts";
L["TAB_TIMERS"] = "Timers";
L["TAB_COLORS"] = "Colors";
L["TAB_UNITTEXTS"] = "Unit Texts";
L["TAB_OFFSETS"] = "Offsets";
L["TAB_SERVICE"] = "Service";
-- general blizzard
L["HEADER_BLIZZARD"] = "Blizzard Frames:";

L["SETTING_BLIZZARD_PLAYER"] = "Show Player Frame";
L["SETTING_BLIZZARD_PLAYER_TOOLTIP"] = "Show Blizzard Player Frame";

L["SETTING_BLIZZARD_TARGET"] = "Show Target Frame";
L["SETTING_BLIZZARD_TARGET_TOOLTIP"] = "Show Blizzard Target Frame";

L["SETTING_BLIZZARD_CASTBAR"] = "Show Castingbar";
L["SETTING_BLIZZARD_CASTBAR_TOOLTIP"] = "Show Blizzard Castingbar";

L["SETTING_BLIZZARD_SPELLACTIVATION_ALPHA"] = "SpellActivation Alpha";
L["SETTING_BLIZZARD_SPELLACTIVATION_ALPHA_TOOLTIP"] = "Change Alpha of Blizzard Spell Activation Frame";

L["SETTING_BLIZZARD_SPELLACTIVATION_SCALE"] = "SpellActivation Scale";
L["SETTING_BLIZZARD_SPELLACTIVATION_SCALE_TOOLTIP"] = "Change Scale of Blizzard Spell Activation Frame";

-- general scale
L["HEADER_SCALE"] = "Scale:";

L["SETTING_SCALE_MAIN"] = "HUD";
L["SETTING_SCALE_MAIN_TOOLTIP"] = "Scale the HUD";

L["SETTING_SCALE_SPELL_CIRCLES"] = "Spell circles";
L["SETTING_SCALE_SPELL_CIRCLES_TOOLTIP"] = "Scale the spell circle frames";

L["SETTING_SCALE_SPELL_RECTANGLES"] = "Spell rectangles";
L["SETTING_SCALE_SPELL_RECTANGLES_TOOLTIP"] = "Scale the spell rectangle frames";

L["SETTING_SCALE_RESOURCES"] = "Resources";
L["SETTING_SCALE_RESOURCES_TOOLTIP"] = "Scale the resource frames, e.g. combo-points or runes";

-- general alpha
L["HEADER_ALPHA"] = "Alpha:";

L["SETTING_ALPHA_COMBAT"] = "Combat Alpha";
L["SETTING_ALPHA_COMBAT_TOOLTIP"] = "Change HUD alpha for combat situation";

L["SETTING_ALPHA_HASTARGET"] = "Has Target Alpha";
L["SETTING_ALPHA_HASTARGET_TOOLTIP"] = "Change HUD alpha for out of combat situation with target selected";

L["SETTING_ALPHA_REGEN"] = "Regen Alpha";
L["SETTING_ALPHA_REGEN_TOOLTIP"] = "Change HUD alpha for out of combat situation with resources regenerating";

L["SETTING_ALPHA_OUTOFCOMBAT"] = "Out Of Combat Alpha";
L["SETTING_ALPHA_OUTOFCOMBAT_TOOLTIP"] = "Change HUD alpha for out of combat situation without target and without resources regenerating";

-- general font size
L["HEADER_FONTSIZE"] = "Font Size:";

L["SETTING_FONTSIZE_LEFTBIGBAR1"] = "Left Big Inner Bar";
L["SETTING_FONTSIZE_LEFTBIGBAR1_TOOLTIP"] = "Change Font Size for Left Big Inner Bar";

L["SETTING_FONTSIZE_LEFTBIGBAR2"] = "Left Big Outer Bar";
L["SETTING_FONTSIZE_LEFTBIGBAR2_TOOLTIP"] = "Change Font Size for Left Big Outer Bar";

L["SETTING_FONTSIZE_LEFTSMALLBAR1"] = "Left Small Inner Bar";
L["SETTING_FONTSIZE_LEFTSMALLBAR1_TOOLTIP"] = "Change Font Size for Left Small Inner Bar";

L["SETTING_FONTSIZE_LEFTSMALLBAR2"] = "Left Small Outer Bar";
L["SETTING_FONTSIZE_LEFTSMALLBAR2_TOOLTIP"] = "Change Font Size for Left Small Outer Bar";

L["SETTING_FONTSIZE_RIGHTBIGBAR1"] = "Right Big Inner Bar";
L["SETTING_FONTSIZE_RIGHTBIGBAR1_TOOLTIP"] = "Change Font Size for Right Big Inner Bar";

L["SETTING_FONTSIZE_RIGHTBIGBAR2"] = "Right Big Outer Bar";
L["SETTING_FONTSIZE_RIGHTBIGBAR2_TOOLTIP"] = "Change Font Size for Right Big Outer Bar";

L["SETTING_FONTSIZE_RIGHTSMALLBAR1"] = "Right Small Inner Bar";
L["SETTING_FONTSIZE_RIGHTSMALLBAR1_TOOLTIP"] = "Change Font Size for Right Small Inner Bar";

L["SETTING_FONTSIZE_RIGHTSMALLBAR2"] = "Right Small Outer Bar";
L["SETTING_FONTSIZE_RIGHTSMALLBAR2_TOOLTIP"] = "Change Font Size for Right Small Outer Bar";

L["SETTING_FONTSIZE_TARGETINFO1"] = "Top Target Info";
L["SETTING_FONTSIZE_TARGETINFO1_TOOLTIP"] = "Change Font Size for Top Target Info";

L["SETTING_FONTSIZE_TARGETINFO2"] = "Bottom Target Info";
L["SETTING_FONTSIZE_TARGETINFO2_TOOLTIP"] = "Change Font Size for Bottom Target Info";

L["SETTING_FONTSIZE_SPELLCIRCLESTIME"] = "Spell Circles Time";
L["SETTING_FONTSIZE_SPELLCIRCLESTIME_TOOLTIP"] = "Change Font Size of Time in Spell Circles";

L["SETTING_FONTSIZE_SPELLCIRCLESSTACKS"] = "Spell Circles Stacks";
L["SETTING_FONTSIZE_SPELLCIRCLESSTACKS_TOOLTIP"] = "Change Font Size of Stacks in Spell Circles";

L["SETTING_FONTSIZE_SPELLRECTANGLESTIME"] = "Spell Rects Time";
L["SETTING_FONTSIZE_SPELLRECTANGLESTIME_TOOLTIP"] = "Change Font Size of Time in Spell Rectangles";

L["SETTING_FONTSIZE_SPELLRECTANGLESSTACKS"] = "Spell Rects Stacks";
L["SETTING_FONTSIZE_SPELLRECTANGLESSTACKS_TOOLTIP"] = "Change Font Size of Stacks in Spell Rectangles";

L["SETTING_FONTSIZE_RESOURCETIME"] = "Resources Time";
L["SETTING_FONTSIZE_RESOURCETIME_TOOLTIP"] = "Change Font Size of Time in Resource Frames, e.g. Runes Cooldown";

L["SETTING_FONTSIZE_CASTBARSTIME"] = "Cast Bars Time";
L["SETTING_FONTSIZE_CASTBARSTIME_TOOLTIP"] = "Change Font Size of Time in Cast Bars";

L["SETTING_FONTSIZE_CASTBARSDELAY"] = "Cast Bars Delay";
L["SETTING_FONTSIZE_CASTBARSDELAY_TOOLTIP"] = "Change Font Size of Delay in Cast Bars";

L["SETTING_FONTSIZE_CASTBARSSPELL"] = "Cast Bars Spell";
L["SETTING_FONTSIZE_CASTBARSSPELL_TOOLTIP"] = "Change Font Size of Spell Name in Cast Bars";

-- general font outlines
L["HEADER_FONTOUTLINE"] = "Font Outlines:";

L["SETTING_FONTOUTLINE_LEFTBIGBAR1"] = "Left Big Inner Bar";
L["SETTING_FONTOUTLINE_LEFTBIGBAR1_TOOLTIP"] = "Change Font Outline for Left Big Inner Bar";

L["SETTING_FONTOUTLINE_LEFTBIGBAR2"] = "Left Big Outer Bar";
L["SETTING_FONTOUTLINE_LEFTBIGBAR2_TOOLTIP"] = "Change Font Outline for Left Big Outer Bar";

L["SETTING_FONTOUTLINE_LEFTSMALLBAR1"] = "Left Small Inner Bar";
L["SETTING_FONTOUTLINE_LEFTSMALLBAR1_TOOLTIP"] = "Change Font Outline for Left Small Inner Bar";

L["SETTING_FONTOUTLINE_LEFTSMALLBAR2"] = "Left Small Outer Bar";
L["SETTING_FONTOUTLINE_LEFTSMALLBAR2_TOOLTIP"] = "Change Font Outline for Left Small Outer Bar";

L["SETTING_FONTOUTLINE_RIGHTBIGBAR1"] = "Right Big Inner Bar";
L["SETTING_FONTOUTLINE_RIGHTBIGBAR1_TOOLTIP"] = "Change Font Outline for Right Big Inner Bar";

L["SETTING_FONTOUTLINE_RIGHTBIGBAR2"] = "Right Big Outer Bar";
L["SETTING_FONTOUTLINE_RIGHTBIGBAR2_TOOLTIP"] = "Change Font Outline for Right Big Outer Bar";

L["SETTING_FONTOUTLINE_RIGHTSMALLBAR1"] = "Right Small Inner Bar";
L["SETTING_FONTOUTLINE_RIGHTSMALLBAR1_TOOLTIP"] = "Change Font Outline for Right Small Inner Bar";

L["SETTING_FONTOUTLINE_RIGHTSMALLBAR2"] = "Right Small Outer Bar";
L["SETTING_FONTOUTLINE_RIGHTSMALLBAR2_TOOLTIP"] = "Change Font Outline for Right Small Outer Bar";

L["SETTING_FONTOUTLINE_TARGETINFO1"] = "Top Target Info";
L["SETTING_FONTOUTLINE_TARGETINFO1_TOOLTIP"] = "Change Font Outline for Top Target Info";

L["SETTING_FONTOUTLINE_TARGETINFO2"] = "Bottom Target Info";
L["SETTING_FONTOUTLINE_TARGETINFO2_TOOLTIP"] = "Change Font Outline for Bottom Target Info";

L["SETTING_FONTOUTLINE_SPELLCIRCLESTIME"] = "Spell Circles Time";
L["SETTING_FONTOUTLINE_SPELLCIRCLESTIME_TOOLTIP"] = "Change Font Outline of Time in Spell Circles";

L["SETTING_FONTOUTLINE_SPELLCIRCLESSTACKS"] = "Spell Circles Stacks";
L["SETTING_FONTOUTLINE_SPELLCIRCLESSTACKS_TOOLTIP"] = "Change Font Outline of Stacks in Spell Circles";

L["SETTING_FONTOUTLINE_SPELLRECTANGLESTIME"] = "Spell Rects Time";
L["SETTING_FONTOUTLINE_SPELLRECTANGLESTIME_TOOLTIP"] = "Change Font Outline of Time in Spell Rectangles";

L["SETTING_FONTOUTLINE_SPELLRECTANGLESSTACKS"] = "Spell Rects Stacks";
L["SETTING_FONTOUTLINE_SPELLRECTANGLESSTACKS_TOOLTIP"] = "Change Font Outline of Stacks in Spell Rectangles";

L["SETTING_FONTOUTLINE_RESOURCETIME"] = "Resources Time";
L["SETTING_FONTOUTLINE_RESOURCETIME_TOOLTIP"] = "Change Font Outline of Time in Resource Frames, e.g. Runes Cooldown";

L["SETTING_FONTOUTLINE_CASTBARSTIME"] = "Cast Bars Time";
L["SETTING_FONTOUTLINE_CASTBARSTIME_TOOLTIP"] = "Change Font Outline of Time in Cast Bars";

L["SETTING_FONTOUTLINE_CASTBARSDELAY"] = "Cast Bars Delay";
L["SETTING_FONTOUTLINE_CASTBARSDELAY_TOOLTIP"] = "Change Font Outline of Delay in Cast Bars";

L["SETTING_FONTOUTLINE_CASTBARSSPELL"] = "Cast Bars Spell";
L["SETTING_FONTOUTLINE_CASTBARSSPELL_TOOLTIP"] = "Change Font Outline of Spell Name in Cast Bars";

-- general icons
L["HEADER_ICONS"] = "Icons:";

L["SETTING_ICON_RESTING"] = "Resting Icon";
L["SETTING_ICON_RESTING_TOOLTIP"] = "Show resting icon when in the inn";

L["SETTING_ICON_COMBAT"] = "Combat Icon";
L["SETTING_ICON_COMBAT_TOOLTIP"] = "Show combat icon when in combat";

L["SETTING_ICON_SELFPVP"] = "Player PvP Icon";
L["SETTING_ICON_SELFPVP_TOOLTIP"] = "Show player pvp icon when flagged for pvp";

L["SETTING_ICON_TARGETPVP"] = "Target PvP Icon";
L["SETTING_ICON_TARGETPVP_TOOLTIP"] = "Show target pvp icon when target is flagged for pvp";

L["SETTING_ICON_TARGETELITE"] = "Target Elite Icon";
L["SETTING_ICON_TARGETELITE_TOOLTIP"] = "Show target elite dragon icon when target is elite or rare";

L["SETTING_ICON_TARGETRAID"] = "Target Raid Icon";
L["SETTING_ICON_TARGETRAID_TOOLTIP"] = "Show target raid icon";

L["SETTING_ICON_TARGETSPECROLE"] = "Target Role Icon";
L["SETTING_ICON_TARGETSPECROLE_TOOLTIP"] = "[NYI] Show target specialization role (players only)";

L["SETTING_ICON_TARGETSPEC"] = "Target Spec Icon";
L["SETTING_ICON_TARGETSPEC_TOOLTIP"] = "[NYI] Show target specialization (players only)";

-- general textures
L["HEADER_TEXTURES"] = "Textures:";

L["SETTING_TEXTURES_BARS_1"] = "Plain";
L["SETTING_TEXTURES_BARS_1_TOOLTIP"] = "Change bar textures to Plain";

L["SETTING_TEXTURES_BARS_2"] = "Bubbles";
L["SETTING_TEXTURES_BARS_2_TOOLTIP"] = "Change bar textures to Bubbles";

L["SETTING_TEXTURES_BARS_3"] = "Brick";
L["SETTING_TEXTURES_BARS_3_TOOLTIP"] = "Change bar textures to Brick";

L["SETTING_TEXTURES_BARS_4"] = "Rough";
L["SETTING_TEXTURES_BARS_4_TOOLTIP"] = "Change bar textures to Rough";

L["SETTING_TEXTURES_BARS_5"] = "Fog";
L["SETTING_TEXTURES_BARS_5_TOOLTIP"] = "Change bar textures to Fog";

L["SETTING_TEXTURES_BARS_BACKGROUND"] = "Background";
L["SETTING_TEXTURES_BARS_BACKGROUND_TOOLTIP"] = "Allows to show or hide hud background texture";

-- general health bar options
L["HEADER_HEALTHBAR"] = "Health Bars:";

L["SETTING_HEALTHBAR_SHIELDS"] = "Show Shields";
L["SETTING_HEALTHBAR_SHIELDS_TOOLTIP"] = "If set to 2 then shields will be displayed over maximum health, if set to 1 then shields will not be displayed over maximum health, if set to 0 then shields won't be displayed on health bar and in it's text";

L["SETTING_HEALTHBAR_HEALABSORBS"] = "Heal Absorption";
L["SETTING_HEALTHBAR_HEALABSORBS_TOOLTIP"] = "If checked then summary of heal absorption effects (e.g. Nectrotic Strike) will be displayed on health bar and it's text";

L["SETTING_HEALTHBAR_HEALINCOMING"] = "Incoming Heal";
L["SETTING_HEALTHBAR_HEALINCOMING_TOOLTIP"] = "If checked then summary of incoming heal effects will be displayed on health bar and it's text";


-- general misc options
L["HEADER_MISC"] = "Miscellaneous:";

L["SETTING_MISC_ANIMATEBARS"] = "Animate bars";
L["SETTING_MISC_ANIMATEBARS_TOOLTIP"] = "If checked then bars will be animated, otherwise data will be shown instantly";

L["SETTING_MISC_REVERSECASTBARS"] = "Reverse Cast Bars";
L["SETTING_MISC_REVERSECASTBARS_TOOLTIP"] = "If checked then cast bars animation will be reversed for spell casts";

L["SETTING_MISC_SHOWPLAYERCASTINFO"] = "Player Cast Info";
L["SETTING_MISC_SHOWPLAYERCASTINFO_TOOLTIP"] = "If checked then cast info will be also shown for player casts";

L["SETTING_MISC_ALWAYSSHOWCASTBARBACKGROUND"] = "Cast Bars Background";
L["SETTING_MISC_ALWAYSSHOWCASTBARBACKGROUND_TOOLTIP"] = "If checked then cast bars will draw background texture beneath them regardless of unit ability to cast";

L["SETTING_MISC_SHOWMILLISECONDS"] = "Show milliseconds";
L["SETTING_MISC_SHOWMILLISECONDS_TOOLTIP"] = "If checked then milliseconds will be shown when formatting time numbers.";

L["SETTING_MISC_SHORTNUMBERS"] = "Short numbers";
L["SETTING_MISC_SHORTNUMBERS_TOOLTIP"] = "If checked then numbers will be truncated when formatting general numbers that exceed 5 digits.";

L["SETTING_MISC_MINIMAP"] = "Minimap Icon";
L["SETTING_MISC_MINIMAP_TOOLTIP"] = "If checked then dhud will show icon near minimap.\nIf disabled you can still access options via interface menu or /dhud slash command";

L["SETTING_MISC_HIDEINPETBATTLES"] = "Hide in pet battles";
L["SETTING_MISC_HIDEINPETBATTLES_TOOLTIP"] = "If checked then HUD will be hidden during pet battles.";

L["SETTING_MISC_MOUSECONDITIONSMASK"] = "Mouse conditions";
L["SETTING_MISC_MOUSECONDITIONSMASK_TOOLTIP"] = "Check conditions that should be met in order for frames to be mouse enabled to show tooltips and target options.";
L["SETTING_MISC_MOUSECONDITIONSMASK_MASK"] = {
	["UNSET"] = "No conditions",
	["ALT"] = "ALT",
	["CTRL"] = "CTRL",
	["SHIFT"] = "SHIFT",
};

-- layouts
L["HEADER_FRAMESDATA"] = "Frames Data:";

L["SETTING_FRAMESDATA_LEFTBIGBAR1"] = "Left Big Inner Bar";
L["SETTING_FRAMESDATA_LEFTBIGBAR1_TOOLTIP"] = "Change Displayed Data for Left Big Inner Bar";

L["SETTING_FRAMESDATA_LEFTBIGBAR2"] = "Left Big Outer Bar";
L["SETTING_FRAMESDATA_LEFTBIGBAR2_TOOLTIP"] = "Change Displayed Data for Left Big Outer Bar";

L["SETTING_FRAMESDATA_LEFTSMALLBAR1"] = "Left Small Inner Bar";
L["SETTING_FRAMESDATA_LEFTSMALLBAR1_TOOLTIP"] = "Change Displayed Data for Left Small Inner Bar";

L["SETTING_FRAMESDATA_LEFTSMALLBAR2"] = "Left Small Outer Bar";
L["SETTING_FRAMESDATA_LEFTSMALLBAR2_TOOLTIP"] = "Change Displayed Data for Left Small Outer Bar";

L["SETTING_FRAMESDATA_RIGHTBIGBAR1"] = "Right Big Inner Bar";
L["SETTING_FRAMESDATA_RIGHTBIGBAR1_TOOLTIP"] = "Change Displayed Data for Right Big Inner Bar";

L["SETTING_FRAMESDATA_RIGHTBIGBAR2"] = "Right Big Outer Bar";
L["SETTING_FRAMESDATA_RIGHTBIGBAR2_TOOLTIP"] = "Change Displayed Data for Right Big Outer Bar";

L["SETTING_FRAMESDATA_RIGHTSMALLBAR1"] = "Right Small Inner Bar";
L["SETTING_FRAMESDATA_RIGHTSMALLBAR1_TOOLTIP"] = "Change Displayed Data for Right Small Inner Bar";

L["SETTING_FRAMESDATA_RIGHTSMALLBAR2"] = "Right Small Outer Bar";
L["SETTING_FRAMESDATA_RIGHTSMALLBAR2_TOOLTIP"] = "Change Displayed Data for Right Small Outer Bar";

L["SETTING_FRAMESDATA_TARGETINFO1"] = "Top-Center Unit Info";
L["SETTING_FRAMESDATA_TARGETINFO1_TOOLTIP"] = "Change Displayed Data for Top Target Info";

L["SETTING_FRAMESDATA_TARGETINFO2"] = "Bottom-Center Unit Info";
L["SETTING_FRAMESDATA_TARGETINFO2_TOOLTIP"] = "Change Displayed Data for Bottom Target Info";

L["SETTING_FRAMESDATA_LEFTOUTERSIDE"] = "Left Outer Side Info";
L["SETTING_FRAMESDATA_LEFTOUTERSIDE_TOOLTIP"] = "Change Displayed Data on the Left Outer Side";

L["SETTING_FRAMESDATA_LEFTINNERSIDE"] = "Left Inner Side Info";
L["SETTING_FRAMESDATA_LEFTINNERSIDE_TOOLTIP"] = "Change Displayed Data on the Left Inner Side";

L["SETTING_FRAMESDATA_RIGHTOUTERSIDE"] = "Right Outer Side Info";
L["SETTING_FRAMESDATA_RIGHTOUTERSIDE_TOOLTIP"] = "Change Displayed Data on the Right Outer Side";

L["SETTING_FRAMESDATA_RIGHTINNERSIDE"] = "Right Inner Side Info";
L["SETTING_FRAMESDATA_RIGHTINNERSIDE_TOOLTIP"] = "Change Displayed Data on the Right Inner Side";

L["SETTING_FRAMESDATA_LEFTRECTANGLES"] = "Left Rectangles";
L["SETTING_FRAMESDATA_LEFTRECTANGLES_TOOLTIP"] = "Change Displayed Data on the Left Rectangles";

L["SETTING_FRAMESDATA_RIGHTRECTANGLES"] = "Right Rectangles";
L["SETTING_FRAMESDATA_RIGHTRECTANGLES_TOOLTIP"] = "Change Displayed Data on the Right Rectangles";

L["HEADER_FRAMESDATA_POSITION"] = "Frames Positions:";

L["SETTING_FRAMESDATA_POSITION_SELFSTATE"] = "Player State Position";
L["SETTING_FRAMESDATA_POSITION_SELFSTATE_TOOLTIP"] = "Change Position of Player State Icons";

L["SETTING_FRAMESDATA_POSITION_TARGETSTATE"] = "Target State Position";
L["SETTING_FRAMESDATA_POSITION_TARGETSTATE_TOOLTIP"] = "Change Position of Target State Icons";

L["SETTING_FRAMESDATA_POSITION_TARGETDRAGON"] = "Target Dragon Position";
L["SETTING_FRAMESDATA_POSITION_TARGETDRAGON_TOOLTIP"] = "Change Position of Target Elite Dragon Icon";

L["HEADER_LAYOUTS"] = "Ready to use layouts:";

L["SETTING_LAYOUTS_1"] = "HitPoints Left - Mana Right";
L["SETTING_LAYOUTS_1_TOOLTIP"] = "Show Hit-Points on the Left Bars, Mana on the Right Bars";

L["SETTING_LAYOUTS_2"] = "Player Left - Target Right";
L["SETTING_LAYOUTS_2_TOOLTIP"] = "Show Player Info on the Left Bars, Target info on the Right Bars";

L["SETTING_LAYOUTS_0"] = "Custom";
L["SETTING_LAYOUTS_0_TOOLTIP"] = "Show data in user defined slots";

L["SETTING_LAYOUTS_DATA_SOURCES"] = {
	["playerHealth"] = "Player: Health",
	["targetHealth"] = "Target: Health",
	["characterInVehicleHealth"] = "Player: Character Health In Vehicle",
	["petHealth"] = "Pet: Health",
	["playerPower"] = "Player: Main Power",
	["targetPower"] = "Target: Main Power",
	["characterInVehiclePower"] = "Player: Character Power In Vehicle",
	["petPower"] = "Pet: Power",
	["playerCastBar"] = "Player: Cast Info",
	["targetCastBar"] = "Target: Cast Info",
	["playerComboPoints"] = "Player: Combo-Points",
	["vehicleComboPoints"] = "Vehicle: Combo-Points",
	["playerCooldowns"] = "Player: Spell and Item Cooldowns",
	["playerShortAuras"] = "Player: Short Auras",
	["targetShortAuras"] = "Target: Short Auras",
	["targetInfo"] = "Target: Unit Info",
	["targetOfTargetInfo"] = "Target of Target: Unit Info",
	["targetBuffs"] = "Target: Buffs",
	["targetDebuffs"] = "Target: Debuffs",
	["druidMana"] = "Player: Mana while in shapeshift",
	["druidEnergy"] = "Player: Energy while not in cat form",
	["druidEclipse"] = "Player: Druid Moonkin Eclipse",
	["monkChi"] = "Player: Monk Chi",
	["monkMana"] = "Player: Mana while not in serpent stance",
	["monkEnergy"] = "Player: Energy while in serpent stance",
	["warlockSoulShards"] = "Player: Warlock Soul Shards",
	["warlockBurningEmbers"] = "Player: Warlock Burning Embers",
	["warlockDemonicFury"] = "Player: Warlock Demonic Fury",
	["paladinHolyPower"] = "Player: Paladin Holy Power",
	["priestShadowOrbs"] = "Player: Priest Shadow Orbs",
	["deathKnightRunes"] = "Player: Death-Knight Runes",
	["shamanTotems"] = "Player: Shaman Totems",
	["tankVengeance"] = "Player: Tank Vengeance",
	["monkStagger"] = "Player: Monk Stagger",
};
L["SETTING_LAYOUTS_DATA_POSITIONS"] = {
	["LEFT"] = "Left",
	["CENTER"] = "Center",
	["RIGHT"] = "Right",
};

-- timers
L["HEADER_TIMERS_GENERAL"] = "Timers:";

L["SETTING_TIMERS_TIMERSFORTARGETBUFFS"] = "Target buffs time";
L["SETTING_TIMERS_TIMERSFORTARGETBUFFS_TOOLTIP"] = "Show time text field in target buffs slot";

L["SETTING_TIMERS_TIMERSFORTARGETDEBUFFS"] = "Target debuffs time";
L["SETTING_TIMERS_TIMERSFORTARGETDEBUFFS_TOOLTIP"] = "Show time text field in target debuffs slot";

L["HEADER_TIMERS_SHORTAURAS"] = "Short Auras:";

L["SETTING_TIMERS_SHORTAURASWITHCHARGES"] = "Short auras with charges";
L["SETTING_TIMERS_SHORTAURASWITHCHARGES_TOOLTIP"] = "If enabled then short player auras and short target auras will be shown regardless of time left";

L["SETTING_TIMERS_SHORTAURASTIMELEFT"] = "Short auras Time Left";
L["SETTING_TIMERS_SHORTAURASTIMELEFT_TOOLTIP"] = "Maximum time left on the aura to be displayed in short player auras and short target auras";

L["SETTING_TIMERS_ANIMATEPRIORITYAURASATEND"] = "Animate priority auras at 30%";
L["SETTING_TIMERS_ANIMATEPRIORITYAURASATEND_TOOLTIP"] = "Allows to animate auras that are prioritizied at 30% of their duration";

L["SETTING_TIMERS_ANIMATEPRIORITYAURASDISAPPEAR"] = "Animate priority auras at disappear";
L["SETTING_TIMERS_ANIMATEPRIORITYAURASDISAPPEAR_TOOLTIP"] = "Allows to animate auras that are prioritizied at 1 second left of their duration";

L["HEADER_TIMERS_PLAYERSHORT"] = "Player Short Auras:";

L["SETTING_TIMERS_PLAYERSHORT_ALLBUFFS"] = "Show All Buffs";
L["SETTING_TIMERS_PLAYERSHORT_ALLBUFFS_TOOLTIP"] = "If checked then all player buffs will be shown, not just self";

L["SETTING_TIMERS_PLAYERSHORT_DEBUFFS"] = "Show Debuffs";
L["SETTING_TIMERS_PLAYERSHORT_DEBUFFS_TOOLTIP"] = "If checked then player debuffs will be shown as well";

L["SETTING_TIMERS_PLAYERSHORT_COLORIZEDEBUFFS"] = "Colorize Debuffs";
L["SETTING_TIMERS_PLAYERSHORT_COLORIZEDEBUFFS_TOOLTIP"] = "Colorize debuff timers according to their debuff type";

L["SETTING_TIMERS_PLAYERSHORT_WHITELIST"] = "White List";
L["SETTING_TIMERS_PLAYERSHORT_WHITELIST_TOOLTIP"] = "List with auras to be shown regardless of their time left and charges";

L["SETTING_TIMERS_PLAYERSHORT_BLACKLIST"] = "Black List";
L["SETTING_TIMERS_PLAYERSHORT_BLACKLIST_TOOLTIP"] = "List with auras to be hidden regardless of their time left and charges";

L["SETTING_TIMERS_PLAYERSHORT_PRIORITYLIST"] = "Priority List";
L["SETTING_TIMERS_PLAYERSHORT_PRIORITYLIST_TOOLTIP"] = "List with auras to be displayed first on spell frames";

L["HEADER_TIMERS_TARGETSHORT"] = "Target Short Auras:";

L["SETTING_TIMERS_TARGETSHORT_WHITELIST"] = "White List";
L["SETTING_TIMERS_TARGETSHORT_WHITELIST_TOOLTIP"] = "List with auras to be shown regardless of their time left and charges";

L["SETTING_TIMERS_TARGETSHORT_BLACKLIST"] = "Black List";
L["SETTING_TIMERS_TARGETSHORT_BLACKLIST_TOOLTIP"] = "List with auras to be hidden regardless of their time left and charges";

L["SETTING_TIMERS_TARGETSHORT_PRIORITYLIST"] = "Priority List";
L["SETTING_TIMERS_TARGETSHORT_PRIORITYLIST_TOOLTIP"] = "List with auras to be displayed first on spell frames";

L["HEADER_TIMERS_PLAYERCOOLDOWNS"] = "Player Cooldowns:";

L["SETTING_TIMERS_PLAYERCOOLDOWNS_DURATIONMIN"] = "Minimum duration";
L["SETTING_TIMERS_PLAYERCOOLDOWNS_DURATIONMIN_TOOLTIP"] = "Minimum duration on the cooldown to be displayed in player cooldowns";

L["SETTING_TIMERS_PLAYERCOOLDOWNS_DURATIONMAX"] = "Maximum duration";
L["SETTING_TIMERS_PLAYERCOOLDOWNS_DURATIONMAX_TOOLTIP"] = "Maximum duration on the cooldown to be displayed in player cooldowns";

L["SETTING_TIMERS_PLAYERCOOLDOWNS_ITEM"] = "Item cooldowns";
L["SETTING_TIMERS_PLAYERCOOLDOWNS_ITEM_TOOLTIP"] = "Show item cooldowns, note that you can blacklist individual item cooldowns using ther name or slot";

L["SETTING_TIMERS_PLAYERCOOLDOWNS_COLORIZELOCKS"] = "Colorize Spell Locks";
L["SETTING_TIMERS_PLAYERCOOLDOWNS_COLORIZELOCKS_TOOLTIP"] = "Colorize spell locks according to spell lock type";

L["SETTING_TIMERS_PLAYERCOOLDOWNS_WHITELIST"] = "White List";
L["SETTING_TIMERS_PLAYERCOOLDOWNS_WHITELIST_TOOLTIP"] = "List with cooldowns to be shown regardless of their duration";

L["SETTING_TIMERS_PLAYERCOOLDOWNS_BLACKLIST"] = "Black List";
L["SETTING_TIMERS_PLAYERCOOLDOWNS_BLACKLIST_TOOLTIP"] = "List with cooldowns to be hidden regardless of their duration";

L["SETTING_TIMERS_PLAYERCOOLDOWNS_PRIORITYLIST"] = "Priority List";
L["SETTING_TIMERS_PLAYERCOOLDOWNS_PRIORITYLIST_TOOLTIP"] = "List with cooldowns to be displayed first on spell frames";

-- colors
L["HEADER_COLORS_PLAYER"] = "Player:";

L["SETTING_COLORS_PLAYER_HEALTH"] = "Health";
L["SETTING_COLORS_PLAYER_HEALTH_TOOLTIP"] = "Color to be used on bar and text when displaying Player Health";

L["SETTING_COLORS_PLAYER_HEALTHSHIELD"] = "Health Shield";
L["SETTING_COLORS_PLAYER_HEALTHSHIELD_TOOLTIP"] = "Color to be used on bar and text when displaying Player Health Shield";

L["SETTING_COLORS_PLAYER_HEALTHHEALABSORB"] = "Heal Absorb";
L["SETTING_COLORS_PLAYER_HEALTHHEALABSORB_TOOLTIP"] = "Color to be used on bar and text when displaying Player Absorbed Heal";

L["SETTING_COLORS_PLAYER_HEALTHHEALINCOMING"] = "Incoming Heal";
L["SETTING_COLORS_PLAYER_HEALTHHEALINCOMING_TOOLTIP"] = "Color to be used on bar and text when displaying Player Incoming Heal";

L["SETTING_COLORS_PLAYER_MANA"] = "Mana";
L["SETTING_COLORS_PLAYER_MANA_TOOLTIP"] = "Color to be used on bar and text when displaying Player Mana";

L["SETTING_COLORS_PLAYER_RAGE"] = "Rage";
L["SETTING_COLORS_PLAYER_RAGE_TOOLTIP"] = "Color to be used on bar and text when displaying Player Rage";

L["SETTING_COLORS_PLAYER_ENERGY"] = "Energy";
L["SETTING_COLORS_PLAYER_ENERGY_TOOLTIP"] = "Color to be used on bar and text when displaying Player Energy";

L["SETTING_COLORS_PLAYER_RUNICPOWER"] = "Runic Power";
L["SETTING_COLORS_PLAYER_RUNICPOWER_TOOLTIP"] = "Color to be used on bar and text when displaying Player Runic Power";

L["SETTING_COLORS_PLAYER_FOCUS"] = "Focus";
L["SETTING_COLORS_PLAYER_FOCUS_TOOLTIP"] = "Color to be used on bar and text when displaying Player Focus";

L["SETTING_COLORS_PLAYER_CAST"] = "Cast";
L["SETTING_COLORS_PLAYER_CAST_TOOLTIP"] = "Color to be used on cast bar when displaying Player Cast";

L["SETTING_COLORS_PLAYER_CHANNEL"] = "Channel";
L["SETTING_COLORS_PLAYER_CHANNEL_TOOLTIP"] = "Color to be used on cast bar when displaying Player Channel";

L["SETTING_COLORS_PLAYER_LOCKEDCAST"] = "Locked Cast";
L["SETTING_COLORS_PLAYER_LOCKEDCAST_TOOLTIP"] = "Color to be used on cast bar when displaying Player Locked Cast";

L["SETTING_COLORS_PLAYER_LOCKEDCHANNEL"] = "Locked Channel";
L["SETTING_COLORS_PLAYER_LOCKEDCHANNEL_TOOLTIP"] = "Color to be used on cast bar when displaying Player Locked Channel";

L["SETTING_COLORS_PLAYER_CASTINTERRUPTED"] = "Interrupted Cast";
L["SETTING_COLORS_PLAYER_CASTINTERRUPTED_TOOLTIP"] = "Color to be used on cast bar when displaying Player Interrupted Cast";

L["SETTING_COLORS_PLAYER_SHORTAURABUFF"] = "Short Aura Buff";
L["SETTING_COLORS_PLAYER_SHORTAURABUFF_TOOLTIP"] = "Color to be used on spell circles when displaying Player Short Aura Buff";

L["SETTING_COLORS_PLAYER_SHORTAURADEBUFF"] = "Short Aura Debuff";
L["SETTING_COLORS_PLAYER_SHORTAURADEBUFF_TOOLTIP"] = "Color to be used on spell circles when displaying Player Short Aura Debuff";

L["SETTING_COLORS_PLAYER_COOLDOWNSSPELL"] = "Spell Cooldowns";
L["SETTING_COLORS_PLAYER_COOLDOWNSSPELL_TOOLTIP"] = "Color to be used on spell circles when displaying Player Spell Cooldowns";

L["SETTING_COLORS_PLAYER_COOLDOWNSITEM"] = "Item Cooldowns";
L["SETTING_COLORS_PLAYER_COOLDOWNSITEM_TOOLTIP"] = "Color to be used on spell circles when displaying Player Item Cooldowns";

L["HEADER_COLORS_TARGET"] = "Target:";

L["SETTING_COLORS_TARGET_HEALTH"] = "Health";
L["SETTING_COLORS_TARGET_HEALTH_TOOLTIP"] = "Color to be used on bar and text when displaying Target Health";

L["SETTING_COLORS_TARGET_HEALTHSHIELD"] = "Health Shield";
L["SETTING_COLORS_TARGET_HEALTHSHIELD_TOOLTIP"] = "Color to be used on bar and text when displaying Target Health Shield";

L["SETTING_COLORS_TARGET_HEALTHHEALABSORB"] = "Heal Absorb";
L["SETTING_COLORS_TARGET_HEALTHHEALABSORB_TOOLTIP"] = "Color to be used on bar and text when displaying Target Absorbed Heal";

L["SETTING_COLORS_TARGET_HEALTHHEALINCOMING"] = "Incoming Heal";
L["SETTING_COLORS_TARGET_HEALTHHEALINCOMING_TOOLTIP"] = "Color to be used on bar and text when displaying Target Incoming Heal";

L["SETTING_COLORS_TARGET_HEALTHNOTTAPPED"] = "Not Tapped";
L["SETTING_COLORS_TARGET_HEALTHNOTTAPPED_TOOLTIP"] = "Color to be used on bar and text when displaying Not Tapped Target Health";

L["SETTING_COLORS_TARGET_MANA"] = "Mana";
L["SETTING_COLORS_TARGET_MANA_TOOLTIP"] = "Color to be used on bar and text when displaying Target Mana";

L["SETTING_COLORS_TARGET_RAGE"] = "Rage";
L["SETTING_COLORS_TARGET_RAGE_TOOLTIP"] = "Color to be used on bar and text when displaying Target Rage";

L["SETTING_COLORS_TARGET_ENERGY"] = "Energy";
L["SETTING_COLORS_TARGET_ENERGY_TOOLTIP"] = "Color to be used on bar and text when displaying Target Energy";

L["SETTING_COLORS_TARGET_RUNICPOWER"] = "Runic Power";
L["SETTING_COLORS_TARGET_RUNICPOWER_TOOLTIP"] = "Color to be used on bar and text when displaying Target Runic Power";

L["SETTING_COLORS_TARGET_FOCUS"] = "Focus";
L["SETTING_COLORS_TARGET_FOCUS_TOOLTIP"] = "Color to be used on bar and text when displaying Target Focus";

L["SETTING_COLORS_TARGET_CAST"] = "Cast";
L["SETTING_COLORS_TARGET_CAST_TOOLTIP"] = "Color to be used on cast bar when displaying Target Cast";

L["SETTING_COLORS_TARGET_CHANNEL"] = "Channel";
L["SETTING_COLORS_TARGET_CHANNEL_TOOLTIP"] = "Color to be used on cast bar when displaying Target Channel";

L["SETTING_COLORS_TARGET_LOCKEDCAST"] = "Locked Cast";
L["SETTING_COLORS_TARGET_LOCKEDCAST_TOOLTIP"] = "Color to be used on cast bar when displaying Target Locked Cast";

L["SETTING_COLORS_TARGET_LOCKEDCHANNEL"] = "Locked Channel";
L["SETTING_COLORS_TARGET_LOCKEDCHANNEL_TOOLTIP"] = "Color to be used on cast bar when displaying Target Locked Channel";

L["SETTING_COLORS_TARGET_CASTINTERRUPTED"] = "Interrupted Cast";
L["SETTING_COLORS_TARGET_CASTINTERRUPTED_TOOLTIP"] = "Color to be used on cast bar when displaying Target Interrupted Cast";

L["SETTING_COLORS_TARGET_PLAYERSHORTAURA"] = "Player Short Aura";
L["SETTING_COLORS_TARGET_PLAYERSHORTAURA_TOOLTIP"] = "Color to be used on spell circles when displaying Target Short Aura applied by Player";

L["SETTING_COLORS_TARGET_SHORTAURABUFF"] = "Short Aura Buff";
L["SETTING_COLORS_TARGET_SHORTAURABUFF_TOOLTIP"] = "Color to be used on spell circles when displaying Target Short Aura Buff";

L["SETTING_COLORS_TARGET_SHORTAURADEBUFF"] = "Short Aura Debuff";
L["SETTING_COLORS_TARGET_SHORTAURADEBUFF_TOOLTIP"] = "Color to be used on spell circles when displaying Target Short Aura Debuff";

L["SETTING_COLORS_TARGET_AURABUFF"] = "Aura Buff";
L["SETTING_COLORS_TARGET_AURABUFF_TOOLTIP"] = "Color to be used on spell rectangles when displaying Target Aura Buff";

L["SETTING_COLORS_TARGET_AURADEBUFF"] = "Aura Debuff";
L["SETTING_COLORS_TARGET_AURADEBUFF_TOOLTIP"] = "Color to be used on spell rectangles when displaying Target Aura Debuff";

L["HEADER_COLORS_PET"] = "Pet:";

L["SETTING_COLORS_PET_HEALTH"] = "Health";
L["SETTING_COLORS_PET_HEALTH_TOOLTIP"] = "Color to be used on bar and text when displaying Pet Health";

L["SETTING_COLORS_PET_HEALTHSHIELD"] = "Health Shield";
L["SETTING_COLORS_PET_HEALTHSHIELD_TOOLTIP"] = "Color to be used on bar and text when displaying Pet Health Shield";

L["SETTING_COLORS_PET_HEALTHHEALABSORB"] = "Heal Absorb";
L["SETTING_COLORS_PET_HEALTHHEALABSORB_TOOLTIP"] = "Color to be used on bar and text when displaying Pet Absorbed Heal";

L["SETTING_COLORS_PET_HEALTHHEALINCOMING"] = "Incoming Heal";
L["SETTING_COLORS_PET_HEALTHHEALINCOMING_TOOLTIP"] = "Color to be used on bar and text when displaying Pet Incoming Heal";

L["SETTING_COLORS_PET_MANA"] = "Mana";
L["SETTING_COLORS_PET_MANA_TOOLTIP"] = "Color to be used on bar and text when displaying Pet Mana";

L["SETTING_COLORS_PET_FOCUS"] = "Focus";
L["SETTING_COLORS_PET_FOCUS_TOOLTIP"] = "Color to be used on bar and text when displaying Pet Focus";

L["SETTING_COLORS_PET_ENERGY"] = "Energy";
L["SETTING_COLORS_PET_ENERGY_TOOLTIP"] = "Color to be used on bar and text when displaying Pet Energy";

L["HEADER_COLORS_ALTERNATIVEPOWER"] = "Player Alternative Powers:";

L["SETTING_COLORS_GUARDIAN_ACTIVE"] = "A.Totems";
L["SETTING_COLORS_GUARDIAN_ACTIVE_TOOLTIP"] = "Color to be used on bar and text when displaying Active Totems";

L["SETTING_COLORS_GUARDIAN_PASSIVE"] = "P.Totems";
L["SETTING_COLORS_GUARDIAN_PASSIVE_TOOLTIP"] = "Color to be used on bar and text when displaying Passive Totems from glyph, e.g. Totem of Earth";

L["SETTING_COLORS_ALTERNATIVEPOWER_ECLIPSE"] = "Eclipse";
L["SETTING_COLORS_ALTERNATIVEPOWER_ECLIPSE_TOOLTIP"] = "Color to be used on bar and text when displaying Player Eclipse";

L["SETTING_COLORS_ALTERNATIVEPOWER_BURNINGEMBERS"] = "Burning Embers";
L["SETTING_COLORS_ALTERNATIVEPOWER_BURNINGEMBERS_TOOLTIP"] = "Color to be used on bar and text when displaying Player Burning Embers";

L["SETTING_COLORS_ALTERNATIVEPOWER_DEMONICFURY"] = "Demonic Fury";
L["SETTING_COLORS_ALTERNATIVEPOWER_DEMONICFURY_TOOLTIP"] = "Color to be used on bar and text when displaying Player Demonic Fury";

L["SETTING_COLORS_OTHERPOWER_VENGEANCE"] = "Vengeance";
L["SETTING_COLORS_OTHERPOWER_VENGEANCE_TOOLTIP"] = "Color to be used on bar and text when displaying Tank Vengeance";

L["SETTING_COLORS_OTHERPOWER_STAGGER"] = "Stagger";
L["SETTING_COLORS_OTHERPOWER_STAGGER_TOOLTIP"] = "Color to be used on bar and text when displaying Monk Brewmaster Stagger";

-- unit texts
L["HEADER_UNITTEXTS_PLAYER"] = "Player:";

L["SETTING_UNITTEXTS_PLAYER_HEALTH"] = "Player Health";
L["SETTING_UNITTEXTS_PLAYER_HEALTH_TOOLTIP"] = "Change Text to be Displayed Near Player Health Bar";

L["SETTING_UNITTEXTS_PLAYER_POWER"] = "Player Power";
L["SETTING_UNITTEXTS_PLAYER_POWER_TOOLTIP"] = "Change Text to be Displayed Near Player Power Bar";

L["SETTING_UNITTEXTS_PLAYER_ALTPOWER"] = "Player Alternative Power";
L["SETTING_UNITTEXTS_PLAYER_ALTPOWER_TOOLTIP"] = "Change Text to be Displayed Near Player Alternative Power Bar";

L["SETTING_UNITTEXTS_PLAYER_OTHERPOWER"] = "Player Other Power";
L["SETTING_UNITTEXTS_PLAYER_OTHERPOWER_TOOLTIP"] = "Change Text to be Displayed Near Player Other Power Bar, e.g. Monk Stagger, Tank Vengeance, etc..";

L["SETTING_UNITTEXTS_PLAYER_CASTTIME"] = "Player Cast Time";
L["SETTING_UNITTEXTS_PLAYER_CASTTIME_TOOLTIP"] = "Change Cast Text to be Displayed Near Player Cast Bar";

L["SETTING_UNITTEXTS_PLAYER_CASTDELAY"] = "Player Cast Delay";
L["SETTING_UNITTEXTS_PLAYER_CASTDELAY_TOOLTIP"] = "Change Cast Delay to be Displayed Near Player Cast Bar";

L["SETTING_UNITTEXTS_PLAYER_CASTNAME"] = "Player Cast Spell Name";
L["SETTING_UNITTEXTS_PLAYER_CASTNAME_TOOLTIP"] = "Change Spell Name Text to be Displayed Near Player Cast Bar";

L["HEADER_UNITTEXTS_TARGET"] = "Target:";

L["SETTING_UNITTEXTS_TARGET_HEALTH"] = "Target Health";
L["SETTING_UNITTEXTS_TARGET_HEALTH_TOOLTIP"] = "Change Text to be Displayed Near Target Health Bar";

L["SETTING_UNITTEXTS_TARGET_POWER"] = "Target Power";
L["SETTING_UNITTEXTS_TARGET_POWER_TOOLTIP"] = "Change Text to be Displayed Near Target Power Bar";

L["SETTING_UNITTEXTS_TARGET_CASTTIME"] = "Target Cast Time";
L["SETTING_UNITTEXTS_TARGET_CASTTIME_TOOLTIP"] = "Change Cast Text to be Displayed Near Target Cast Bar";

L["SETTING_UNITTEXTS_TARGET_CASTDELAY"] = "Target Cast Delay";
L["SETTING_UNITTEXTS_TARGET_CASTDELAY_TOOLTIP"] = "Change Cast Delay to be Displayed Near Target Cast Bar";

L["SETTING_UNITTEXTS_TARGET_CASTNAME"] = "Target Cast Spell Name";
L["SETTING_UNITTEXTS_TARGET_CASTNAME_TOOLTIP"] = "Change Spell Name Text to be Displayed Near Target Cast Bar";

L["SETTING_UNITTEXTS_TARGET_INFO"] = "Target Info";
L["SETTING_UNITTEXTS_TARGET_INFO_TOOLTIP"] = "Change Text to be Displayed On Target Unit Info";

L["HEADER_UNITTEXTS_TARGETTARGET"] = "Target Of Target:";

L["SETTING_UNITTEXTS_TARGETTARGET_INFO"] = "Target of Target Info";
L["SETTING_UNITTEXTS_TARGETTARGET_INFO_TOOLTIP"] = "Change Text to be Displayed On Target of Target Unit Info";

L["HEADER_UNITTEXTS_PET"] = "Pet:";

L["SETTING_UNITTEXTS_PET_HEALTH"] = "Pet Health";
L["SETTING_UNITTEXTS_PET_HEALTH_TOOLTIP"] = "Change Text to be Displayed Near Pet Health Bar";

L["SETTING_UNITTEXTS_PET_POWER"] = "Pet Power";
L["SETTING_UNITTEXTS_PET_POWER_TOOLTIP"] = "Change Text to be Displayed Near Pet Power Bar";

L["SETTING_UNITTEXTS_PREDEFINED_CUSTOM"] = {
	["health1"] = "50 +...",
	["health2"] = "50/100 +...",
	["health3"] = "50% +...",
	["health4"] = "50 (50%) +...",
	["health5"] = "50/100 (50%) +...",
	["power1"] = "50",
	["power2"] = "50/100",
	["power3"] = "50%",
	["power4"] = "50 (50%)",
	["power5"] = "50/100 (50%)",
	["power6"] = "50.4",
	["unitInfo1"] = "Long",
	["unitInfo2"] = "Middle",
	["unitInfo3"] = "Short",
	["castTime1"] = "Cast Time",
	["castTime2"] = "Remaining Time",
	["castDelay1"] = "Cast Delay",
	["castSpellName1"] = "Spell Name",
};
L["SETTING_UNITTEXTS_PREDEFINED_ALL"] = {
	["empty"] = "Empty",
	["custom"] = "User Defined Text",
};

-- offsets
L["HEADER_OFFSETS"] = "Offsets:";

L["SETTING_OFFSET_HUD"] = "Hud Position";
L["SETTING_OFFSET_HUD_TOOLTIP"] = "Change HUD position, use right click for increased offset step";

L["SETTING_OFFSET_BARDISTANCE"] = "Bar Distance";
L["SETTING_OFFSET_BARDISTANCE_TOOLTIP"] = "Change the distance between bars, use right click for increased offset step";

L["SETTING_OFFSET_TARGETINFO"] = "Top Target Info";
L["SETTING_OFFSET_TARGETINFO_TOOLTIP"] = "Change position of Top Target Info Frame, use right click for increased offset step";

L["SETTING_OFFSET_TARGETINFO2"] = "Bottom Target Info";
L["SETTING_OFFSET_TARGETINFO2_TOOLTIP"] = "Change position of Bottom Target Info Frame, use right click for increased offset step";

L["SETTING_OFFSET_LEFTBIGBAR1"] = "Left Big Inner Bar";
L["SETTING_OFFSET_LEFTBIGBAR1_TOOLTIP"] = "Change position of Left Big Inner Bar Text, use right click for increased offset step";

L["SETTING_OFFSET_LEFTBIGBAR2"] = "Left Big Outer Bar";
L["SETTING_OFFSET_LEFTBIGBAR2_TOOLTIP"] = "Change position of Left Big Outer Bar Text, use right click for increased offset step";

L["SETTING_OFFSET_LEFTSMALLBAR1"] = "Left Small Inner Bar";
L["SETTING_OFFSET_LEFTSMALLBAR1_TOOLTIP"] = "Change position of Left Small Inner Bar Text, use right click for increased offset step";

L["SETTING_OFFSET_LEFTSMALLBAR2"] = "Left Small Outer Bar";
L["SETTING_OFFSET_LEFTSMALLBAR2_TOOLTIP"] = "Change position of Left Small Outer Bar Text, use right click for increased offset step";

L["SETTING_OFFSET_RIGHTBIGBAR1"] = "Right Big Inner Bar";
L["SETTING_OFFSET_RIGHTBIGBAR1_TOOLTIP"] = "Change position of Right Big Inner Bar Text, use right click for increased offset step";

L["SETTING_OFFSET_RIGHTBIGBAR2"] = "Right Big Outer Bar";
L["SETTING_OFFSET_RIGHTBIGBAR2_TOOLTIP"] = "Change position of Right Big Outer Bar Text, use right click for increased offset step";

L["SETTING_OFFSET_RIGHTSMALLBAR1"] = "Right Small Inner Bar";
L["SETTING_OFFSET_RIGHTSMALLBAR1_TOOLTIP"] = "Change position of Right Small Inner Bar Text, use right click for increased offset step";

L["SETTING_OFFSET_RIGHTSMALLBAR2"] = "Right Small Outer Bar";
L["SETTING_OFFSET_RIGHTSMALLBAR2_TOOLTIP"] = "Change position of Right Small Outer Bar Text, use right click for increased offset step";

-- service
L["HEADER_SERVICE_LUA"] = "LUA code:";

L["SETTING_SERVICE_LUA_ONLOAD"] = "On load LUA code:";
L["SETTING_SERVICE_LUA_ONLOAD_TOOLTIP"] = "LUA code that will be executed on game start, usefull to change some things like camera max. distance";

L["HEADER_SERVICE_BLIZZARD"] = "Blizzard Frames:";

L["SETTING_SERVICE_ERRORS"] = "Errors filtering";
L["SETTING_SERVICE_ERRORS_TOOLTIP"] = "Change level of UI error messages filtering (e.g. Not Enough Energy), 0 - all errors are shown, 1 - errors are hidden, 2 - error frame is hidden (quest messages won't be shown)";