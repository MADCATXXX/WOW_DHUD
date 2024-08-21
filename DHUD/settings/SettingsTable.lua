--[[-----------------------------------------------------------------------------------
 Original Drathals HUD (c) 2006 by Markus Inger / Drathal / Silberklinge / Silbersegen
 DHUD for WotLK and later expansions (c) 2013 by MADCAT (EU-Гордунни, Мадкат)
 (http://eu.battle.net/wow/en/character/гордунни/Мадкат/advanced)
---------------------------------------------------------------------------------------
 This file contains user settings table, implementation is located in SettingsImpl.lua
 @author: MADCAT
-----------------------------------------------------------------------------------]]--

--------------
-- Settings --
--------------

--- Class to notify about settings change and manage saved vars (only difference is saved)
DHUDSettings = MCCreateSubClass(MADCATEventDispatcher, {
	-- type of the setting, that should be saved by value
	SETTING_TYPE_VALUE = 0,
	-- type of the setting, that holds another set of settings, containers will not be used in actual settings table, instead they will be used as part of the name
	SETTING_TYPE_CONTAINER = 1,
	-- type of the setting that will be used only as reference to possible values
	SETTING_TYPE_CONTAINER_REFERENCE = 2,
	-- type of the setting, that holds array in which order of elements and it's size matter
	SETTING_TYPE_ARRAY_FIXEDORDERSIZE = 3,
	-- type of the setting, that holds array in which order and size is irrelevant
	SETTING_TYPE_ARRAY_NOORDERSIZE = 4,
	-- type of the setting, that holds array with spellids in default table, but will use spellnames in settings table
	SETTING_TYPE_ARRAY_SPELLIDTONAME = 5,
	-- type of the setting that holds key value combinations
	SETTING_TYPE_TABLE = 6,
	-- type of the setting, that holds array in which order of elements matter
	SETTING_TYPE_ARRAY_FIXEDORDER = 7,
	-- default settings table in following format: setting = value, settingType, additionalData table or nil
	default = {
		-- settings group to hide/show blizzard frames
		["blizzardFrames"] = { {
			-- allows to show or hide blizzard player frame
			["playerFrame"] = { true, 0 },
			-- allows to show or hide blizzard target frame
			["targetFrame"] = { true, 0 },
			-- allows to show or hide blizzard casting frame
			["castingFrame"] = { false, 0 },
			-- allows to change alpha of SpellActivationOverlayFrame
			["spellActivationFrameAlpha"] = { 0.5, 0, { range = { 0, 1, 0.1 } } },
			-- allows to change alpha of SpellActivationOverlayFrame
			["spellActivationFrameScale"] = { 1, 0, { range = { 0.2, 2, 0.1 } } },
		}, 1 },
		-- allows to apply text outlines to the text frames
		["outlines"] = { {
			-- change outline of the text corresponding to inner left big bar
			["leftBigBar1"] = { 0, 0, { range = { 0, 2, 1 } } },
			-- change outline of the text corresponding to outer left big bar
			["leftBigBar2"] = { 0, 0, { range = { 0, 2, 1 } } },
			-- change outline of the text corresponding to inner left small bar
			["leftSmallBar1"] = { 0, 0, { range = { 0, 2, 1 } } },
			-- change outline of the text corresponding to outer left small bar
			["leftSmallBar2"] = { 0, 0, { range = { 0, 2, 1 } } },
			-- change outline of the text corresponding to inner right big bar
			["rightBigBar1"] = { 0, 0, { range = { 0, 2, 1 } } },
			-- change outline of the text corresponding to outer right big bar
			["rightBigBar2"] = { 0, 0, { range = { 0, 2, 1 } } },
			-- change outline of the text corresponding to inner right small bar
			["rightSmallBar1"] = { 0, 0, { range = { 0, 2, 1 } } },
			-- change outline of the text corresponding to outer right small bar
			["rightSmallBar2"] = { 0, 0, { range = { 0, 2, 1 } } },
			-- change outline of the text corresponding to target info
			["targetInfo1"] = { 0, 0, { range = { 0, 2, 1 } } },
			-- change outline of the text corresponding to target of target info
			["targetInfo2"] = { 0, 0, { range = { 0, 2, 1 } } },
			-- change outline of the time text in the spell circles
			["spellCirclesTime"] = { 0, 0, { range = { 0, 2, 1 } } },
			-- change outline of the stacks text in in the spell circles
			["spellCirclesStacks"] = { 0, 0, { range = { 0, 2, 1 } } },
			-- change outline of the time text in the spell rectangles
			["spellRectanglesTime"] = { 1, 0, { range = { 0, 2, 1 } } },
			-- change outline of the stacks text in in the spell rectangles
			["spellRectanglesStacks"] = { 1, 0, { range = { 0, 2, 1 } } },
			-- change outline of the time text on resource frames, e.g. death knight rune time left
			["resourceTime"] = { 1, 0, { range = { 0, 2, 1 } } },
			-- change outline of the time text in cast bars
			["castBarsTime"] = { 0, 0, { range = { 0, 2, 1 } } },
			-- change outline of the delay text in cast bars
			["castBarsDelay"] = { 0, 0, { range = { 0, 2, 1 } } },
			-- change  outline of the spell text in cast bars
			["castBarsSpell"] = { 0, 0, { range = { 0, 2, 1 } } },
		}, 1 },
		-- allows to change scale of the frames or change font size
		["scale"] = { {
			-- changes scale of the whole bar
			["main"] = { 1.0, 0, { range = { 0.2, 2.0, 0.1 } } },
			-- changes scale of the spell circles
			["spellCircles"] = { 1.0, 0, { range = { 0.2, 2.0, 0.1 } } },
			-- changes scale of the spell rectangles
			["spellRectangles"] = { 1.0, 0, { range = { 0.2, 2.0, 0.1 } } },
			-- changes scale of the resource indication, such as runes or combo-points
			["resource"] = { 1.0, 0, { range = { 0.2, 2.0, 0.1 } } },
			-- change text size of the text corresponding to inner left big bar
			["leftBigBar1"] = { 10, 0, { range = { 6, 30, 1 } } },
			-- change text size of the text corresponding to outer left big bar
			["leftBigBar2"] = { 10, 0, { range = { 6, 30, 1 } } },
			-- change text size of the text corresponding to inner left small bar
			["leftSmallBar1"] = { 9, 0, { range = { 6, 30, 1 } } },
			-- change text size of the text corresponding to outer left small bar
			["leftSmallBar2"] = { 9, 0, { range = { 6, 30, 1 } } },
			-- change text size of the text corresponding to inner right big bar
			["rightBigBar1"] = { 10, 0, { range = { 6, 30, 1 } } },
			-- change text size of the text corresponding to outer right big bar
			["rightBigBar2"] = { 10, 0, { range = { 6, 30, 1 } } },
			-- change text size of the text corresponding to inner right small bar
			["rightSmallBar1"] = { 9, 0, { range = { 6, 30, 1 } } },
			-- change text size of the text corresponding to outer right small bar
			["rightSmallBar2"] = { 9, 0, { range = { 6, 30, 1 } } },
			-- change text size of the text corresponding to target info
			["targetInfo1"] = { 12, 0, { range = { 6, 30, 1 } } },
			-- change text size of the text corresponding to target of target info
			["targetInfo2"] = { 10, 0, { range = { 6, 30, 1 } } },
			-- change text size of the time text in the spell circles
			["spellCirclesTime"] = { 12, 0, { range = { 6, 30, 1 } } },
			-- change text size of the stacks text in in the spell circles
			["spellCirclesStacks"] = { 8, 0, { range = { 6, 30, 1 } } },
			-- change text size of the time text in the spell rectangles
			["spellRectanglesTime"] = { 8, 0, { range = { 6, 30, 1 } } },
			-- change text size of the stacks text in in the spell rectangles
			["spellRectanglesStacks"] = { 6, 0, { range = { 6, 30, 1 } } },
			-- change text size of the time text on resource frames, e.g. death knight rune time left
			["resourceTime"] = { 12, 0, { range = { 6, 30, 1 } } },
			-- change text size of the time text in cast bars
			["castBarsTime"] = { 10, 0, { range = { 6, 30, 1 } } },
			-- change text size of the delay text in cast bars
			["castBarsDelay"] = { 10, 0, { range = { 6, 30, 1 } } },
			-- change text size of the spell text in cast bars
			["castBarsSpell"] = { 12, 0, { range = { 6, 30, 1 } } },
		}, 1 },
		-- allows to show or hide frames with icons
		["icons"] = { {
			-- allows to show resting icon when in the inn
			["restingIcon"] = { true, 0 },
			-- allows to show combat icon when in combat
			["combatIcon"] = { true, 0 },
			-- allows to show player pvp icon when flagged for pvp
			["playerPvPIcon"] = { true, 0 },
			-- allows to show target pvp icon when target is flagged for pvp
			["targetPvPIcon"] = { true, 0 },
			-- allows to show elite icon for target creatures
			["targetEliteIcon"] = { true, 0 },
			-- allows to show target raid icon
			["targetRaidIcon"] = { true, 0 },
			-- allows to show target spec role (players only)
			["targetSpecRoleIcon"] = { false, 0 },
			-- allows to show target spec (players only)
			["targetSpecIcon"] = { true, 0 },
		}, 1 },
		-- allows to change alpha when certain conditions are met
		["alpha"] = { {
			-- alpha when in combat
			["combat"] = { 0.8, 0, { range = { 0.0, 1.0, 0.1 } } },
			-- alpha when out of combat, but has target
			["hasTarget"] = { 0.5, 0, { range = { 0.0, 1.0, 0.1 } } },
			-- alpha when out of combat, without target, but resources are regenerating
			["regen"] = { 0.3, 0, { range = { 0.0, 1.0, 0.1 } } },
			-- alpha when out of combat and no other condition is met
			["outOfCombat"] = { 0.0, 0, { range = { 0.0, 1.0, 0.1 } } },
		}, 1 },
		-- allows to change position of the bars and text
		["offsets"] = { {
			-- allows to reposition hud
			["hud"] = { { 0, 0 }, 3 },
			-- allows to increase or decrease distance between bars
			["barDistance"] = { 0, 0 },
			-- allows to offset target info frames
			["targetInfo"] = { { 0, 0 }, 3 },
			-- allows to offset target of target info frames
			["targetInfo2"] = { { 0, 0 }, 3 },
			-- change text position of the text corresponding to inner left big bar
			["leftBigBar1"] = { { 0, 0 }, 3 },
			-- change text position of the text corresponding to outer left big bar
			["leftBigBar2"] = { { 0, 0 }, 3 },
			-- change text position of the text corresponding to inner left small bar
			["leftSmallBar1"] = { { 0, 0 }, 3 },
			-- change text position of the text corresponding to outer left small bar
			["leftSmallBar2"] = { { 0, 0 }, 3 },
			-- change text position of the text corresponding to inner right big bar
			["rightBigBar1"] = { { 0, 0 }, 3 },
			-- change text position of the text corresponding to outer right big bar
			["rightBigBar2"] = { { 0, 0 }, 3 },
			-- change text position of the text corresponding to inner right small bar
			["rightSmallBar1"] = { { 0, 0 }, 3 },
			-- change text position of the text corresponding to outer right small bar
			["rightSmallBar2"] = { { 0, 0 }, 3 },
		}, 1 },
		-- allows to change color when colorizing bars and spell icons
		["colors"] = { {
			-- list with colors to visualize player data on bars
			["player"] = { {
				-- allows to change color of player health on bars
				["health"] = { { "00FF00", "FFFF00", "FF0000" }, 3 },
				-- allows to change color of player health shield on bars
				["healthShield"] = { { "FFFFFF", "FFFFFF", "FFFFFF" }, 3 },
				-- allows to change color of player health absorbed on bars
				["healthAbsorb"] = { { "FF0080", "FF0080", "FF0080" }, 3 },
				-- allows to change color of player temporary reduced health on bars
				["healthReduce"] = { { "400020", "500028", "600030" }, 3 },
				-- allows to change color of player health incoming heal on bars
				["healthHeal"] = { { "0000FF", "0000FF", "0000FF" }, 3 },
				-- allows to change color of player mana on bars
				["mana"] = { { "00FFFF", "0000FF", "FF00FF" }, 3 },
				-- allows to change color of player rage on bars
				["rage"] = { { "FF0000", "FF0000", "FF0000" }, 3 },
				-- allows to change color of player energy on bars
				["energy"] = { { "FFFF00", "FFFF00", "FFFF00" }, 3 },
				-- allows to change color of player runic power on bars
				["runicPower"] = { { "0080c0", "0080c0", "0080c0" }, 3 },
				-- allows to change color of player focus on bars
				["focus"] = { { "aa4400", "aa4400", "aa4400" }, 3 },
				-- allows to change color of player druid eclipse on bars
				["eclipse"] = { { "6c7ad9", "6c7ad9", "6c7ad9" }, 3 }, -- { "fcea1e", "d89d3f", "d29835", "ffffff", "4c80ba", "79c9ec", "d9ffff" }
				-- allows to change color of player shaman maelstrom on bars
				["maelstrom"] = { { "00a2d6", "00a2d6", "00a2d6" }, 3 },
				-- allows to change color of player priest insanity on bars
				["insanity"] = { { "462296", "462296", "462296" }, 3 },
				-- allows to change color of player tank vengeance on bars
				["vengeance"] = { { "FF00FF", "FF00FF", "FF00FF" }, 3 },
				-- allows to change color of player monk stagger on bars
				["stagger"] = { { "FF8000", "FFFF00", "80FF00" }, 3 },
				-- allows to change color of player demon hunter anger on bars
				["fury"] = { { "7E2DCD", "7E2DCD", "7E2DCD" }, 3 },
				-- allows to change color of player demon hunter pain on bars
				["pain"] = { { "C48100", "C48100", "C48100" }, 3 },
			}, 1 },
			-- list with colors to visualize target data on bars
			["target"] = { {
				-- allows to change color of target health on bars
				["health"] = { { "00aa00", "aaaa00", "aa0000" }, 3 },
				-- allows to change color of target health shield on bars
				["healthShield"] = { { "aaaaaa", "aaaaaa", "aaaaaa" }, 3 },
				-- allows to change color of target health absorbed on bars
				["healthAbsorb"] = { { "aa0055", "aa0055", "aa0055" }, 3 },
				-- allows to change color of target temporary reduced health on bars
				["healthReduce"] = { { "2a0015", "35001a", "400020" }, 3 },
				-- allows to change color of target health incoming heal on bars
				["healthHeal"] = { { "0000aa", "0000aa", "0000aa" }, 3 },
				-- allows to change color of target health on bars when target is not tapped by player
				["healthNotTapped"] = { { "cccccc", "bbbbbb", "aaaaaa" }, 3 },
				-- allows to change color of target mana on bars
				["mana"] = { { "00aaaa", "0000aa", "aa00aa" }, 3 },
				-- allows to change color of target rage on bars
				["rage"] = { { "aa0000", "aa0000", "aa0000" }, 3 },
				-- allows to change color of target energy on bars
				["energy"] = { { "aaaa00", "aaaa00", "aaaa00" }, 3 },
				-- allows to change color of target runic power on bars
				["runicPower"] = { { "004060", "004060", "004060" }, 3 },
				-- allows to change color of target focus on bars
				["focus"] = { { "aa4400", "aa4400", "aa4400" }, 3 },
				-- allows to change color of target druid eclipse on bars
				["eclipse"] = { { "6c7ad9", "6c7ad9", "6c7ad9" }, 3 }, -- { "fcea1e", "d89d3f", "d29835", "ffffff", "4c80ba", "79c9ec", "d9ffff" }
				-- allows to change color of target shaman maelstrom on bars
				["maelstrom"] = { { "00a2d6", "00a2d6", "00a2d6" }, 3 },
				-- allows to change color of target priest insanity on bars
				["insanity"] = { { "462296", "462296", "462296" }, 3 },
				-- allows to change color of target demon hunter anger on bars
				["fury"] = { { "7E2DCD", "7E2DCD", "7E2DCD" }, 3 },
				-- allows to change color of target demon hunter pain on bars
				["pain"] = { { "C48100", "C48100", "C48100" }, 3 },
			}, 1 },
			-- list with colors to visualize pet data on bars
			["pet"] = { {
				-- allows to change color of pet health on bars
				["health"] = { { "00FF00", "FFFF00", "FF0000" }, 3 },
				-- allows to change color of pet health shield on bars
				["healthShield"] = { { "FFFFFF", "FFFFFF", "FFFFFF" }, 3 },
				-- allows to change color of pet health absorbed on bars
				["healthAbsorb"] = { { "FF0080", "FF0080", "FF0080" }, 3 },
				-- allows to change color of pet temporary reduced health on bars
				["healthReduce"] = { { "400020", "500028", "600030" }, 3 },
				-- allows to change color of pet health incoming heal on bars
				["healthHeal"] = { { "0000FF", "0000FF", "0000FF" }, 3 },
				-- allows to change color of target mana on bars
				["mana"] = { { "00FFFF", "0000FF", "FF00FF" }, 3 },
				-- allows to change color of pet focus on bars
				["focus"] = { { "aa4400", "aa4400", "aa4400" }, 3 },
				-- allows to change color of pet energy on bars
				["energy"] = { { "FFFF00", "FFFF00", "FFFF00" }, 3 },
			}, 1 },
			-- list with colors to visualize self castbars
			["selfCastbar"] = { {
				-- allows to change color of castbar when casting
				["cast"] = { { "00FF00", "88FF00", "FFFF00" }, 3 },
				-- allows to change color of castbar when channeling
				["channel"] = { { "E0E0FF", "C0C0FF", "A0A0FF" }, 3 },
				-- allows to change color of castbar when casting can't be interrupted
				["lockedCast"] = { { "00FF00", "88FF00", "FFFF00" }, 3 },
				-- allows to change color of castbar when channel can't be interrupted
				["lockedChannel"] = { { "E0E0FF", "C0C0FF", "A0A0FF" }, 3 },
				-- allows to change color of castbar when cast was interrupted
				["interrupted"] = { { "FF0000", "FF0000", "FF0000" }, 3 },
			}, 1 },
			-- list with colors to visualize target castbars
			["targetCastbar"] = { {
				-- allows to change color of castbar when casting
				["cast"] = { { "00FF00", "88FF00", "FFFF00" }, 3 },
				-- allows to change color of castbar when channeling
				["channel"] = { { "E0E0FF", "C0C0FF", "A0A0FF" }, 3 },
				-- allows to change color of castbar when casting can't be interrupted
				["lockedCast"] = { { "0000FF", "0000FF", "0000FF" }, 3 },
				-- allows to change color of castbar when channel can't be interrupted
				["lockedChannel"] = { { "0000FF", "0000FF", "0000FF" }, 3 },
				-- allows to change color of castbar when cast was interrupted
				["interrupted"] = { { "FF0000", "FF0000", "FF0000" }, 3 },
			}, 1 },
			-- list with colors to visualize spell circles that are showing self auras
			["selfShortAuras"] = { {
				-- allows to change color of spell circle when it shows buff
				["buff"] = { { "ffffff", "ffffff", "eeeeee" }, 3 },
				-- allows to change color of spell circle when it shows debuff
				["debuff"] = { { "FFFF00", "FFFF00", "FFFF00" }, 3 },
				-- allows to change color of spell circle when it shows magic debuff
				["debuffMagic"] = { { "3397ff", "3397ff", "3397ff" }, 3 },
				-- allows to change color of spell circle when it shows curse debuff
				["debuffCurse"] = { { "9900ff", "9900ff", "9900ff" }, 3 },
				-- allows to change color of spell circle when it shows disease debuff
				["debuffDisease"] = { { "996400", "996400", "996400" }, 3 },
				-- allows to change color of spell circle when it shows poison debuff
				["debuffPoison"] = { { "009700", "009700", "009700" }, 3 },
			}, 1 },
			-- list with colors to visualize spell circles that are showing target auras
			["targetShortAuras"] = { {
				-- allows to change color of spell circle when it shows debuff
				["buff"] = { { "FFFF00", "FFFF00", "FFFF00" }, 3 },
				-- allows to change color of spell circle when it shows buff
				["debuff"] = { { "FFFF00", "FFFF00", "FFFF00" }, 3 },
				-- allows to change color of player applied spells
				["appliedByPlayer"] = { { "ffffff", "ffffff", "eeeeee" }, 3 },
			}, 1 },
			-- list with colors to visualize spell rectangles that are showing self cooldowns
			["selfCooldowns"] = { {
				-- allows to change color of spell circle when it shows spell cooldown
				["spell"] = { { "ffffff", "ffffff", "eeeeee" }, 3 },
				-- allows to change color of spell circle when it shows item cooldown
				["item"] = { { "ffffff", "ffffff", "eeeeee" }, 3 },
			}, 1 },
			-- list with colors to visualize spell rectangles that are showing self guardians
			["selfGuardians"] = { {
				-- allows to change color of spell circle when it shows passive guardian
				["passive"] = { { "808080", "808080", "808080" }, 3 },
				-- allows to change color of spell circle when it shows active guardian
				["active"] = { { "ffffff", "ffffff", "eeeeee" }, 3 },
			}, 1 },
			-- list with colors to visualize spell rectangles that are showing self auras
			["selfAuras"] = { {
				-- allows to change color of spell circle when it shows buff
				["buff"] = { { "ffffff", "ffffff", "eeeeee" }, 3 },
				-- allows to change color of spell circle when it shows debuff
				["debuff"] = { { "ffffff", "ffffff", "eeeeee" }, 3 },
			}, 1 },
			-- list with colors to visualize spell rectangles that are showing target auras
			["targetAuras"] = { {
				-- allows to change color of spell circle when it shows debuff
				["buff"] = { { "ffffff", "ffffff", "eeeeee" }, 3 },
				-- allows to change color of spell circle when it shows buff
				["debuff"] = { { "ffffff", "ffffff", "eeeeee" }, 3 },
			}, 1 },
		}, 1 },
		-- allows to change text formatting in the text fields
		["unitTexts"]  = { {
			-- list with texts to visualize player data in text fields
			["player"] = { {
				-- allows to change - what to output to player health textField
				["health"] = { "@default", 0, { default = { "@health4" }, }, },
				-- allows to change - what to output to player power textField
				["power"] = { "@default", 0, { default = { "@power4", ["ROGUE"] = "@power1", ["WARRIOR"] = "@power1", ["DEATHKNIGHT"] = "@power1" } }, },
				-- allows to change - what to output to player alternative power textField
				["altpower"] = { "@default", 0, { default = { "@power1", ["WARLOCK"] = "@power6" } }, },
				-- allows to change - what to output to player other data type textField (stagger, vengeance, etc)
				["other"] = { "@default", 0, { default = { "@power1" } }, },
				-- allows to change - what to output to player cast time textField
				["castTime"] = { "@default", 0, { default = { "@castTime2" } }, },
				-- allows to change - what to output to player cast delay textField
				["castDelay"] = { "@default", 0, { default = { "@castDelay1" } }, },
				-- allows to change - what to output to player cast spell name textField
				["castSpellName"] = { "@default", 0, { default = { "@castSpellName1" } }, },
			}, 1 },
			-- list with texts to visualize target data in text fields
			["target"] = { {
				-- allows to change - what to output to target health textField
				["health"] = { "@default", 0, { default = { "@health4" } }, },
				-- allows to change - what to output to target power textField
				["power"] = { "@default", 0, { default = { "@power3" } }, },
				-- allows to change - what to output to target info textField
				["info"] = { "@default", 0, { default = { "@unitInfo2" } }, },
				-- allows to change - what to output to target cast time textField
				["castTime"] = { "@default", 0, { default = { "@castTime2" } }, },
				-- allows to change - what to output to target cast delay textField
				["castDelay"] = { "@default", 0, { default = { "@castDelay1" } }, },
				-- allows to change - what to output to target cast spell name textField
				["castSpellName"] = { "@default", 0, { default = { "@castSpellName1" } }, },
			}, 1 },
			-- list with texts to visualize target of target data in text fields
			["targettarget"] = { {
				-- allows to change - what to output to target of target info textField
				["info"] = { "@default", 0, { default = { "@unitInfo2" } }, },
			}, 1 },
			-- list with texts to visualize target data in text fields
			["pet"] = { {
				-- allows to change - what to output to pet health textField
				["health"] = { "@default", 0, { default = { "@health1" } }, },
				-- allows to change - what to output to pet power textField
				["power"] = { "@default", 0, { default = { "@power1" } }, },
			}, 1 },
		}, 1 },
		-- predefines list of texts to be shown in text fields
		["unitTextsPredefined"] = { {
			-- empty text
			["empty"] = "",
			-- health amount only
			["health1"] = "<color_amount><amount></color><color_amount_habsorb><amount_habsorb(\" - \")></color><color_amount_hreduce><amount_hreduce(\" - \")></color><color_amount_extra><amount_extra(\" + \")></color><color_amount_hincome><amount_hincome(\" + \")></color>",
			-- health amount with health max amount
			["health2"] = "<color_amount><amount></color>/<amount_max><color_amount_habsorb><amount_habsorb(\" - \")></color><color_amount_hreduce><amount_hreduce(\" - \")></color><color_amount_extra><amount_extra(\" + \")></color><color_amount_hincome><amount_hincome(\" + \")></color>",
			-- health percent only
			["health3"] = "<color_amount><amount_percent>%</color><color_amount_habsorb><amount_habsorb(\" - \")></color><color_amount_hreduce><amount_hreduce(\" - \")></color><color_amount_extra><amount_extra(\" + \")></color><color_amount_hincome><amount_hincome(\" + \")></color>",
			-- health amount with health percent
			["health4"] = "<color_amount><amount></color> <color(\"999999\")>(</color><amount_percent>%<color(\"999999\")>)</color><color_amount_habsorb><amount_habsorb(\" - \")></color><color_amount_hreduce><amount_hreduce(\" - \")></color><color_amount_extra><amount_extra(\" + \")></color><color_amount_hincome><amount_hincome(\" + \")></color>";
			-- health amount with health max amount and percent
			["health5"] = "<color_amount><amount>/<amount_max></color> <color(\"999999\")>(</color><amount_percent>%<color(\"999999\")>)</color><color_amount_habsorb><amount_habsorb(\" - \")></color><color_amount_hreduce><amount_hreduce(\" - \")></color><color_amount_extra><amount_extra(\" + \")></color><color_amount_hincome><amount_hincome(\" + \")></color>",
			-- power amount only
			["power1"] = "<color_amount><amount></color>",
			-- power amount with power max amount
			["power2"] = "<color_amount><amount></color>/<amount_max>",
			-- power percent only
			["power3"] = "<color_amount><amount_percent>%</color>",
			-- power amount with power percent
			["power4"] = "<color_amount><amount></color> <color(\"999999\")>(</color><amount_percent>%<color(\"999999\")>)</color>",
			-- power amount with power max amount and percent
			["power5"] = "<color_amount><amount>/<amount_max></color> <color(\"999999\")>(</color><amount_percent>%<color(\"999999\")>)</color>",
			-- power amount only with precision to 1 digit
			["power6"] = "<color_amount><amount(nil, 1)></color>",
			-- maximum user info
			["unitInfo1"] = "<color_level><level><elite></color> <color_reaction><name></color> [<color_class><spec></color>] <guild(\"<\",\">\")> <pvp>",
			-- medium user info
			["unitInfo2"] = "<color_level><level><elite></color> <color_reaction><name></color> [<color_class><spec></color>]",
			-- minimum user info
			["unitInfo3"] = "<color_level><level><elite></color> <color_reaction><name></color>",
			-- cast time text
			["castTime1"] = "<color(\"ffff00\")><time></color>",
			-- cast time remaining time
			["castTime2"] = "<color(\"ffff00\")><time_remain></color>",
			-- cast delay text
			["castDelay1"] = "<color(\"ff0000\")><delay(\"+ \", \"- \")></color>",
			-- cast spell name text
			["castSpellName1"] = "<color(\"ffffff\")><spellname(\"|cff\" .. \"0099CC\" .. \"Canceled\" .. \"|\" .. \"r\", \"|cff\" .. \"FF3399\" .. \"Interrupted\", \"|cff\" .. \"66FF00\" .. \"Interrupted by Me\" .. \"|\" .. \"r\", \" by \", \"|\" .. \"r\", \"C0C0C0\")></color>",
		}, 2 },
		-- allows to change bar textures
		["textures"] = { {
			-- holds number of the texture to use for bars (default 2 = bubbles)
			["barTexture"] = { 2, 0, { range = { 1, 5, 1 } } },
			-- allows to show or hide hud background texture
			["barBackground"] = { true, 0 },
		}, 1 },
		-- list with options for short auras and cooldowns
		["shortAurasOptions"] = { {
			-- allows to show auras with charges, regardless of time left
			["aurasWithCharges"] = { true, 0 },
			-- maximum time left on aura to be shown in short auras
			["aurasTimeLeftMax"] = { 180, 0, { range = { 0, 3600, 1 } } },
			-- allows to show all player buffs, not just self
			["playerAllBuffs"] = { true, 0 },
			-- allows to show player debuffs along with player buffs
			["playerDebuffs"] = { true, 0 },
			-- allows to colorize player debuffs according to debuff type
			["colorizePlayerDebuffs"] = { true, 0 },
			-- allows to show auras from this list, regardless of time or charges
			["playerAurasWhiteList"] = { { }, 5 },
			-- allows to not show auras from this list, regardless of time or charges
			["playerAurasBlackList"] = { { }, 5 },
			-- allows to set priority for spell appearance in spell circles
			["playerAurasPriorityList"] = { { }, 5 },
			-- allows to show auras from this list, regardless of time or charges
			["targetAurasWhiteList"] = { { -- druid symbiosis spells are named the same, no point in including them
				-- DEATHKNIGHT
				48792, -- DK: Icebound Fortitude, prevents stuns on target, reduces all damage by 20%
				48707, -- DK: Anti-Magic Shell, prevents all magic damage to target
				-- DRUID
				33786, -- Druid: Cyclone, prevents any damage to target
				61336, -- Druid: Survival Instincts, reduces all gamage by 50%
				305497, -- Druid: Thorns, High self damage (120% spellpower of caster)
				-- EVOKER
				378441, -- Evoker: TimeStop, prevents any damage to target
				378464, -- Evoker: Nullifying Shroud, prevents cc to target
				-- HUNTER
				19263, -- Hunter: Deterrence, reflects all attacks
				186265, -- Hunter: Aspect of the turtle, prevents all damage to target
				-- MAGE
				45438, -- Mage: Ice block, prevents all damage to target
				108978, -- Mage: Alter Time, reverts all damage done to target after 6 seconds
				-- PALADIN
				1022, -- Paladin: Hand of protection, prevents physical damage to target
				642, -- Paladin: Divine Shield, prevents all damage to target
				-- PRIEST
				47585, -- Priest: Dispersion, reduces damage by 90%
				33206, -- Priest: Pain Supression, reduces all damage by 40%
				213602, -- Priest: Greater Fade, 100% miss
				-- ROGUE
				31224, -- Rogue: Cloak of Shadows, prevents all magic damage to target
				5277, -- Rogue: Evasion, increased dodge chance by 100%
				-- MONK
				115176,	-- Monk: Zen Meditation, reduces magic damage by 90%
				122783, -- Monk: Diffuse Magic, reduces all damage by 60%
				--178345, -- Monk: Fist of Fury, increased parry chance by 100%
				--122470, -- Monk: Touch of Karma, redirects all damage to enemy
				-- SHAMAN
				--30823, -- Shaman: Shamanistic Rage, reduces all damage by 30%
				-- WARLOCK
				--110913, -- Warlock: Dark Bargain, prevents all damage, 50% of the damage will be dealed after buff expires
				104773, -- Warlock: Unending Resolve, reduces all damage by 40%
				-- WARRIOR
				871, -- Warrior: Shield Wall, reduces damage by 60%
				118038, -- Warrior: Die by the Sword, reduces damage by 20% and increases parry by 100%
				-- DEMON HUNTER
				198589, -- Demon Hunter: Blur, 50% evasion
				206803, -- Demon Hunter: Rain From Above, prevents all damage to target
				354610, -- Demon Hunter: Glimpse, CC immnunity, reduce damage by 75%
				196555, -- Demon Hunter: Netherwalk, prevents all damage to target
				-- ALL
				121164, -- Battlegrounds Sphere which needs to be killed, prevents some abilities such as BoP, Shadow Duel, etc...
				377360, -- PvP Talent Precognition, cc immunity
			}, 5 },
			-- allows to not show auras from this list, regardless of time or charges
			["targetAurasBlackList"] = { { }, 5 },
			-- allows to set priority for spell appearance in spell circles
			["targetAurasPriorityList"] = { { }, 5 },
			-- minimum cooldown duration to be shown in short cooldowns
			["cooldownsDurationMin"] = { 0, 0, { range = { 0, 3600, 1 } } },
			-- maximum cooldown duration to be shown in short cooldowns
			["cooldownsDurationMax"] = { 3600, 0, { range = { 0, 3600, 1 } } },
			-- allows to show item cooldowns
			["cooldownsItem"] = { true, 0 },
			-- allows to show cooldowns even when they are up (during combat only)
			["cooldownsStayInCombat"] = { true, 0 },
			-- allows to show cooldowns from this list, regardless of time
			["cooldownsWhiteList"] = { { }, 5 },
			-- allows to not show cooldowns from this list, regardless of time
			["cooldownsBlackList"] = { { }, 5 },
			-- allows to set priority for spell appearance in spell circles
			["cooldownsPriorityList"] = { { }, 5 },
			-- allows to colorize player cooldowns according to spell lock type
			["colorizeCooldownsLock"] = { true, 0 },
			-- allows to animate short auras at the end of their time (when <30% left)
			["animatePriorityAurasAtEnd"] = { true, 0 },
			-- allows to animate short auras when they about to disappear (when <1 sec left)
			["animatePriorityAurasDisappear"] = { true, 0 },
		}, 1 },
		-- list with options for all auras
		["aurasOptions"] = { {
			-- allows to show timers on target buffs
			["showTimersOnTargetBuffs"] = { true, 0 },
			-- allows to show timers on target debuffs
			["showTimersOnTargetDeBuffs"] = { true, 0 },
		}, 1 },
		-- list with options for health
		["healthBarOptions"] = { {
			-- allows to show shield on health bars, (0 = do not display, 1 = display in WoW style, 2 = display in LoL style)
			["showShields"] =  { 2, 0, { range = { 0, 2, 1 } } },
			-- allows to show how much of the health will be absorbed by heal
			["showHealAbsorb"] = { true, 0 },
			-- allows to show how much of the health is reduced temporary
			["showHealthReduce"] = { true, 0 },
			-- allows to show incoming heal
			["showHealIncoming"] = { true, 0 },
		}, 1 },
		-- what data to display on bars, not filled if not custom
		["framesData"] = { {
			-- layout to use, 0 = custom, all unset settings will be readed from layout specified
			["layout"] = { 1, 0, { range = { 1, 2, 1 } } },
			-- what to show in inner left big bar
			["leftBigBar1"] = { false, 7 },
			-- what to show on outer left big bar
			["leftBigBar2"] = { false, 7 },
			-- what to show on inner left small bar
			["leftSmallBar1"] = { false, 7 },
			-- what to show on outer left small bar
			["leftSmallBar2"] = { false, 7 },
			-- what to show on inner right big bar
			["rightBigBar1"] = { false, 7 },
			-- what to show on outer right big bar
			["rightBigBar2"] = { false, 7 },
			-- what to show on inner right small bar
			["rightSmallBar1"] = { false, 7 },
			-- what to show on outer right small bar
			["rightSmallBar2"] = { false, 7 },
			-- what to show in inner left big cast bar
			["leftBigCastBar1"] = { false, 7 },
			-- what to show on outer left big cast bar
			["leftBigCastBar2"] = { false, 7 },
			-- what to show on inner right big cast bar
			["rightBigCastBar1"] = { false, 7 },
			-- what to show on outer right big cast bar
			["rightBigCastBar2"] = { false, 7 },
			-- what to show on the left outer side info
			["leftOuterSideInfo"] =  { false, 7 },
			-- what to show on the left inner side info
			["leftInnerSideInfo"] =  { false, 7 },
			-- what to show on the right outer side info
			["rightOuterSideInfo"] =  { false, 7 },
			-- what to show on the right inner side info
			["rightInnerSideInfo"] =  { false, 7 },
			-- what to show on the top unit info plate
			["centerUnitInfo1"] =  { false, 7 },
			-- what to show on the bottom unit info plate
			["centerUnitInfo2"] =  { false, 7 },
			-- what to show on the left rectangle frames
			["leftRectangles"] = { false, 7 },
			-- what to show on the right rectangle frames
			["rightRectangles"] = { false, 7 },
			-- position of icons
			["iconPositions"] = { {
				-- position of dragon
				["dragon"] = { false, 0 },
				-- position of self state icons
				["selfState"] = { false, 0 },
				-- position of target state icons
				["targetState"] = { false, 0 },
			}, 1 },
		}, 1 },
		-- sources of data for frames, settings addon should check if data tracker is not nil, as some of them are class specific
		["framesDataSources"] = { {
			-- table with references to actual data trackers, filled in runtime
			["dataTrackersMap"] = { },
			-- data that can be shown on bars
			["bars"] = { "playerHealth", "playerPower", "targetHealth", "targetPower", "petHealth", "petPower",
						 "characterInVehicleHealth", "characterInVehiclePower", "druidMana", "druidEnergy", "druidEclipse",
						 "monkStagger", "shamanMana", "priestMana" },
			-- data that can be shown on cast bars
			["castBars"] = { "playerCastBar", "targetCastBar" },
			-- data that can be shown on side slots
			["sideSlots"] = { "vehicleComboPoints", "playerComboPoints", "playerShortAuras", "targetShortAuras", "playerCooldowns", "monkChi", "warlockSoulShards", "paladinHolyPower", "mageArcaneCharges", "deathKnightRunes", "shamanTotems", "evokerEssence" },
			-- data that can be shown on spell rectangles
			["spellRectangles"] = { "targetBuffs", "targetDebuffs" },
			-- data that can be shown in unit info frames
			["unitInfo"] = { "targetInfo", "targetOfTargetInfo" },
			-- available position for certain frames
			["positions"] = {
				-- position of dragon
				["dragon"] = { "LEFT", "RIGHT" },
				-- position of self state icons
				["selfState"] = { "LEFT", "RIGHT" },
				-- position of target state icons
				["targetState"] = { "CENTER" },
			},
		}, 2 },
		-- list with default layouts
		["layouts"] = { {
			-- default layout that was used by dhud
			["layout1"] = {
				{
					-- what to show on inner left big bar
					["leftBigBar1"] = { "playerHealth" },
					-- what to show on outer left big bar
					["leftBigBar2"] = { "targetHealth" },
					-- what to show on inner left small bar
					["leftSmallBar1"] = { "characterInVehicleHealth", "petHealth" },
					-- what to show on outer left small bar
					["leftSmallBar2"] = { },
					-- what to show on inner right big bar
					["rightBigBar1"] = { "playerPower" },
					-- what to show on outer right big bar
					["rightBigBar2"] = { "targetPower" },
					-- what to show on inner right small bar
					["rightSmallBar1"] = { "characterInVehiclePower", "petPower" },
					-- what to show on outer right small bar
					["rightSmallBar2"] = { },
					-- what to show in inner left big cast bar
					["leftBigCastBar1"] = { },
					-- what to show on outer left big cast bar
					["leftBigCastBar2"] = { },
					-- what to show on inner right big cast bar
					["rightBigCastBar1"] = { "playerCastBar" },
					-- what to show on outer right big cast bar
					["rightBigCastBar2"] = { "targetCastBar" },
					-- what to show on the left outer side info
					["leftOuterSideInfo"] = { "vehicleComboPoints" },
					-- what to show on the left inner side info
					["leftInnerSideInfo"] = { "playerCooldowns" },
					-- what to show on the right outer side info
					["rightOuterSideInfo"] = { "playerShortAuras" },
					-- what to show on the right inner side info
					["rightInnerSideInfo"] = { "targetShortAuras" },
					-- what to show on the top unit info plate
					["centerUnitInfo1"] =  { "targetInfo" },
					-- what to show on the bottom unit info plate
					["centerUnitInfo2"] =  { "targetOfTargetInfo" },
					-- what to show on the left rectangle frames
					["leftRectangles"] = { "targetBuffs" },
					-- what to show on the right rectangle frames
					["rightRectangles"] = { "targetDebuffs" },
					-- position of icons
					["iconPositions"] = {
						-- position of dragon icon
						["dragon"] = "LEFT",
						-- position of self state icons
						["selfState"] = "LEFT",
						-- position of target state icons
						["targetState"] = "CENTER",
					},
				},
				-- druid overrides
				["DRUID"] = {
					-- what to show on the left outer side info
					["leftOuterSideInfo"] = { "playerComboPoints", "vehicleComboPoints" },
					-- what to show on inner left small bar
					["leftSmallBar1"] = { "characterInVehicleHealth", "petHealth" },
					-- what to show on inner right small bar
					["rightSmallBar1"] = { "characterInVehiclePower", "druidMana", "druidEclipse", "petPower" },
				},
				-- rogue overrides
				["ROGUE"] = {
					-- what to show on the left outer side info
					["leftOuterSideInfo"] = { "playerComboPoints", "vehicleComboPoints" },
				},
				-- monk overrides
				["MONK"] = {
					-- what to show on the left outer side info
					["leftOuterSideInfo"] = { "monkChi", "vehicleComboPoints" },
					-- what to show on inner left small bar
					["leftSmallBar1"] = { "characterInVehicleHealth", "monkStagger", "petHealth" },
					-- what to show on inner right small bar
					["rightSmallBar1"] = { "characterInVehiclePower", "petPower" },
				},
				-- warlock overrides
				["WARLOCK"] = {
					-- what to show on the left outer side info
					["leftOuterSideInfo"] = { "warlockSoulShards", "vehicleComboPoints" },
					-- what to show on inner right small bar
					["rightSmallBar1"] = { "characterInVehiclePower", "petPower" },
				},
				-- warrior overrides
				["WARRIOR"] = {
					-- what to show on inner right small bar
					["rightSmallBar1"] = { "characterInVehiclePower" },
				},
				-- paladin overrides
				["PALADIN"] = {
					-- what to show on the left outer side info
					["leftOuterSideInfo"] = { "paladinHolyPower", "vehicleComboPoints" },
					-- what to show on inner right small bar
					["rightSmallBar1"] = { "characterInVehiclePower", "petPower" },
				},
				-- priest overrides
				["PRIEST"] = {
					-- what to show on the left outer side info
					["leftOuterSideInfo"] = { "vehicleComboPoints" },
					-- what to show on inner right small bar
					["rightSmallBar1"] = { "characterInVehiclePower", "priestMana" },
				},
				-- mage overrides
				["MAGE"] = {
					-- what to show on the left outer side info
					["leftOuterSideInfo"] = { "mageArcaneCharges", "vehicleComboPoints" },
				},
				-- death knight overrides
				["DEATHKNIGHT"] = {
					-- what to show on the left outer side info
					["leftOuterSideInfo"] = { "deathKnightRunes", "vehicleComboPoints" },
					-- what to show on inner right small bar
					["rightSmallBar1"] = { "characterInVehiclePower", "petPower" },
				},
				-- shaman overrides
				["SHAMAN"] = {
					-- what to show on the left outer side info
					["leftOuterSideInfo"] = { "shamanTotems", "vehicleComboPoints" },
					-- what to show on inner right small bar
					["rightSmallBar1"] = { "characterInVehiclePower", "shamanMana", "petPower" },
				},
				-- evoker overrides
				["EVOKER"] = {
					-- what to show on the left outer side info
					["leftOuterSideInfo"] = { "evokerEssence", "vehicleComboPoints" },
				},
			},
			-- layout that shows player on the left and target on the right
			["layout2"] = {
				{
					-- what to show on inner left big bar
					["leftBigBar1"] = { "playerPower" },
					-- what to show on outer left big bar
					["leftBigBar2"] = { "playerHealth" },
					-- what to show on inner left small bar
					["leftSmallBar1"] = { "characterInVehicleHealth", "petHealth" },
					-- what to show on outer left small bar
					["leftSmallBar2"] = { "characterInVehiclePower", "petPower" },
					-- what to show on inner right big bar
					["rightBigBar1"] = { "targetPower" },
					-- what to show on outer right big bar
					["rightBigBar2"] = { "targetHealth" },
					-- what to show on inner right small bar
					["rightSmallBar1"] = { },
					-- what to show on outer right small bar
					["rightSmallBar2"] = { },
					-- what to show in inner left big cast bar
					["leftBigCastBar1"] = { "playerCastBar" },
					-- what to show on outer left big cast bar
					["leftBigCastBar2"] = { },
					-- what to show on inner right big cast bar
					["rightBigCastBar1"] = { "targetCastBar" },
					-- what to show on outer right big cast bar
					["rightBigCastBar2"] = { },
					-- what to show on the left outer side info
					["leftOuterSideInfo"] = { "playerShortAuras" },
					-- what to show on the left inner side info
					["leftInnerSideInfo"] = { "targetShortAuras" },
					-- what to show on the right outer side info
					["rightOuterSideInfo"] = { "vehicleComboPoints" },
					-- what to show on the right inner side info
					["rightInnerSideInfo"] = { "playerCooldowns" },
					-- what to show on the top unit info plate
					["centerUnitInfo1"] =  { "targetInfo" },
					-- what to show on the bottom unit info plate
					["centerUnitInfo2"] =  { "targetOfTargetInfo" },
					-- what to show on the left rectangle frames
					["leftRectangles"] = { "targetBuffs" },
					-- what to show on the right rectangle frames
					["rightRectangles"] = { "targetDebuffs" },
					-- position of icons
					["iconPositions"] = {
						-- position of dragon icon
						["dragon"] = "RIGHT",
						-- position of self state icons
						["selfState"] = "LEFT",
						-- position of target state icons
						["targetState"] = "CENTER",
					},
				},
				-- druid overrides
				["DRUID"] = {
					-- what to show on the right outer side info
					["rightOuterSideInfo"] = { "playerComboPoints", "vehicleComboPoints" },
					-- what to show on inner left small bar
					["leftSmallBar1"] = { "characterInVehiclePower", "druidMana", "druidEclipse", "petPower" },
					-- what to show on outer left small bar
					["leftSmallBar2"] = { "characterInVehicleHealth", "petHealth" },
				},
				-- rogue overrides
				["ROGUE"] = {
					-- what to show on the right outer side info
					["rightOuterSideInfo"] = { "playerComboPoints", "vehicleComboPoints" },
				},
				-- druid overrides
				["MONK"] = {
					-- what to show on the right outer side info
					["rightOuterSideInfo"] = { "monkChi", "vehicleComboPoints" },
					-- what to show on inner left small bar
					["leftSmallBar1"] = { "characterInVehiclePower", "petPower" },
					-- what to show on outer left small bar
					["leftSmallBar2"] = { "characterInVehicleHealth", "monkStagger", "petHealth" },
				},
				-- warlock overrides
				["WARLOCK"] = {
					-- what to show on the right outer side info
					["rightOuterSideInfo"] = { "warlockSoulShards", "vehicleComboPoints" },
					-- what to show on inner left small bar
					["leftSmallBar1"] = { "characterInVehiclePower", "petPower" },
					-- what to show on outer left small bar
					["leftSmallBar2"] = { "characterInVehicleHealth", "petHealth" },
				},
				-- warrior overrides
				["WARRIOR"] = {
					-- what to show on inner left small bar
					["leftSmallBar1"] = { "characterInVehiclePower", "petPower" },
					-- what to show on outer left small bar
					["leftSmallBar2"] = { "characterInVehicleHealth", "petHealth" },
				},
				-- paladin overrides
				["PALADIN"] = {
					-- what to show on the right outer side info
					["rightOuterSideInfo"] = { "paladinHolyPower", "vehicleComboPoints" },
					-- what to show on inner left small bar
					["leftSmallBar1"] = { "characterInVehiclePower", "petPower" },
					-- what to show on outer left small bar
					["leftSmallBar2"] = { "characterInVehicleHealth", "petHealth" },
				},
				-- priest overrides
				["PRIEST"] = {
					-- what to show on the right outer side info
					["rightOuterSideInfo"] = { "vehicleComboPoints" },
					-- what to show on inner left small bar
					["leftSmallBar1"] = { "characterInVehiclePower", "priestMana" },
				},
				-- mage overrides
				["MAGE"] = {
					-- what to show on the right outer side info
					["rightOuterSideInfo"] = { "mageArcaneCharges", "vehicleComboPoints" },
				},
				-- death knight overrides
				["DEATHKNIGHT"] = {
					-- what to show on the right outer side info
					["rightOuterSideInfo"] = { "deathKnightRunes", "vehicleComboPoints" },
					-- what to show on inner left small bar
					["leftSmallBar1"] = { "characterInVehiclePower", "petPower" },
					-- what to show on outer left small bar
					["leftSmallBar2"] = { "characterInVehicleHealth", "petHealth" },
				},
				-- shaman overrides
				["SHAMAN"] = {
					-- what to show on the right outer side info
					["rightOuterSideInfo"] = { "shamanTotems", "vehicleComboPoints" },
					-- what to show on inner left small bar
					["leftSmallBar1"] = { "characterInVehiclePower", "shamanMana", "petPower" },
				},
				-- evoker overrides
				["EVOKER"] = {
					-- what to show on the right outer side info
					["rightOuterSideInfo"] = { "evokerEssence", "vehicleComboPoints" },
				},
			},
		}, 2 },
		-- all other settings that didn't fit to other groups
		["misc"] = { {
			-- allows to animate bars
			["animateBars"] = { true, 0 },
			-- allows to reverse casting bar animation
			["reverseCastingBars"] = { false, 0 },
			-- allows to show gcd on player cast bar
			["showGcdOnPlayerCastBar"] = { false, 0 },
			-- allows to track auras with custom trackers to better update auras like Rogue Bandits Guile
			["useCustomAurasTrackers"] = { true, 0 },
			-- allows all timers to show milliseconds instead of seconds (when 10 or less seconds left)
			["textTimerShowMilliSeconds"] = { true, 0 },
			-- allows all numbers to be shortened (for numbers that use more than 5 chars)
			["textShortNumbers"] = { true, 0 },
			-- allows to show what you are casting
			["showPlayerCastBarInfo"] = { false, 0 },
			-- allows to show background behind cast bars even if unit wasn't casting any spells
			["alwaysShowCastBarBackground"] = { false, 0 },
			-- allows to show DHUD icon on minimap
			["minimapIcon"] = { true, 0 },
			-- allows to hide DHUD during pet battles
			["hideInPetBattles"] = { true, 0 },
			-- allows to click on units names and show tooltips for spell circles and rectangles when mouse conditions are met
			["mouseConditionsMask"] = { 0, 0, { mask = { ["ALT"] = 1, ["CTRL"] = 2, ["SHIFT"] = 4 } } },
		}, 1 },
		-- service settings that do not affect dhud addon but may contain interesting settings that are provided by some other addons
		["service"] = { {
			-- allows to change level of ui errors, 0 - all errors shown, 1 - ui errors hidden, 2 - ui error frame is hidden (including quest messages)
			["uiErrorFilter"] = { 0, 0, { range = { 0, 2, 1 } } },
			-- lua code to be executed when addon is loaded, can be used to increase camera max distance and set other things
			["luaStartUp"] = { "SetCVar(\"cameraDistanceMaxZoomFactor\", 2.6);", 0 },
			-- result of the last lua start up code
			["luaStartUpError"] = { false, 0 },
			-- defines if soft targeting mode should be enabled (so that addons shows soft targets intead of selected target)
			["softTargetingMode"] = { false, 0 },
			-- destealth tracking (reason that broke stealth) via chat messages
			["destealthTracker"] = { false, 0 },
		}, 1 },
		-- reference to codes that can be used at start up
		["luaStartUpCodes"] = { {
			-- increases maximum camera distance to highest value
			["cameraMaxDistance"] = "SetCVar(\"cameraDistanceMaxZoomFactor\", 2.6);",
			-- hide recruit a friend rewards on logon, can be usefull when you don't want to use reward until new mount for RAF is available
			["hideRAF"] = "if (ProductChoiceFrame.mainAlertFrame ~= nil) then ProductChoiceFrame.mainAlertFrame:Hide(); ProductChoiceFrame.mainAlertFrame:Hide(); ProductChoiceFrame.secondAlertFrame:Hide(); end",
			-- use old tab targetting, prior to legion 7.1
			["oldTab"] = "SetCVar(\"TargetNearestUseOld\", 1);"
		}, 2 },
	},
	-- settings table in following format: setting = value
	settings = {
	},
	-- custom setters
	setters = {
	},
	-- custom getters
	getters = {
	},
	-- defines if settings preview is active
	previewActive = false,
	-- numeric version of the addon at which saved vars was saved last time
	savedVarsVersion = 0,
	-- table name where additional saved vars are saved
	SAVED_VARS_ADDITIONAL_TABLE_NAME = "_additional",
	-- reference to created frames with settings for blizzard interface addon tab
	blizzardInterfaceAddonTab = nil,
})
