--[[-----------------------------------------------------------------------------------
 Original Drathals HUD (c) 2006 by Markus Inger / Drathal / Silberklinge / Silbersegen
 DHUD for WotLK and later expansions (c) 2013 by MADCAT (EU-Гордунни, Мадкат)
 (http://eu.battle.net/wow/en/character/гордунни/Мадкат/advanced)
---------------------------------------------------------------------------------------
 This file contains user settings and notifies other objects about settings change
 @author: MADCAT
-----------------------------------------------------------------------------------]]--

--------------------
-- Settings Event --
--------------------

--- Class for settings event, it will be fired by settings manager
DHUDSettingsEvent = MCCreateSubClass(MADCATEvent, {
	-- name of the changed setting
	setting = "",
	-- dispatched when dhud settings addon starts to change some value
	EVENT_START_PREVIEW = "previewStart",
	-- dispatched when dhud settings addon stops to change some value
	EVENT_STOP_PREVIEW = "previewStop",
	-- dispatched when some setting changed
	EVENT_SETTING_CHANGED = "settingChanged",
	-- prefix for event that will be dispatched when some group of the settings was changed
	EVENT_SPECIFIC_GROUP_SETTING_CHANGED_PREFIX = "groupSettingChanged_",
	-- prefix for event that will be dispatched when specific setting changed
	EVENT_SPECIFIC_SETTING_CHANGED_PREFIX = "settingChanged_",
})

--- Create new settings event
-- @param type type of the event
function DHUDSettingsEvent:new(type)
	local o = self:defconstructor();
	o:constructor(type);
	return o;
end

--- Constructor for settings event
-- @param type type of the event
function DHUDSettingsEvent:constructor(type)
	-- call super constructor
	MADCATEvent.constructor(self, type);
end

--------------
-- Settings --
--------------

-- temprorary variable for saved vars
DHUD_SAVED_VARS_TEMP = { ["scale_main"] = 0.8, ["scale_resource"] = 1.0, ["scale_spellCircles"] = 1.0, ["shortAurasOptions_targetAurasWhiteList"] = { {"CustomSpell1"}, {"spellName48792"} }, ["shortAurasOptions_aurasTimeLeftMax"] = 240,
						["outlines_spellCirclesTime"] = 0, ["outlines_spellCirclesStacks"] = 0, ["shortAurasOptions_cooldownsBlackList"] = { {"<slot:10>"}, { } }, };

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
			["castingFrame"] = { true, 0 },
		}, 1 },
		-- allows to apply text outlines to the text frames
		["outlines"] = { {
			-- change outline of the text corresponding to inner left big bar
			["leftBigBar1"] = { 0, 0, { range = { 0, 2, 1 } } },
			-- change outline of the text corresponding to outer left big bar
			["leftBigBar2"] = { 0, 0, { range = { 0, 2, 1 } } },
			-- change outline of the text corresponding to inner left small bar
			["leftSmallBar1"] = { 0, 0, { range = { 0, 2, 1 } } },
			-- change outline of the text corresponding to inner right big bar
			["rightBigBar1"] = { 0, 0, { range = { 0, 2, 1 } } },
			-- change outline of the text corresponding to outer right big bar
			["rightBigBar2"] = { 0, 0, { range = { 0, 2, 1 } } },
			-- change outline of the text corresponding to inner right small bar
			["rightSmallBar1"] = { 0, 0, { range = { 0, 2, 1 } } },
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
			["resourceTime"] = { 0, 0, { range = { 0, 2, 1 } } },
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
			-- change text size of the text corresponding to inner right big bar
			["rightBigBar1"] = { 10, 0, { range = { 6, 30, 1 } } },
			-- change text size of the text corresponding to outer right big bar
			["rightBigBar2"] = { 10, 0, { range = { 6, 30, 1 } } },
			-- change text size of the text corresponding to inner right small bar
			["rightSmallBar1"] = { 9, 0, { range = { 6, 30, 1 } } },
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
			["castBarsSpell"] = { 10, 0, { range = { 6, 30, 1 } } },
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
			["targetSpecRoleIcon"] = { true, 0 },
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
			-- change text position of the text corresponding to inner right big bar
			["rightBigBar1"] = { { 0, 0 }, 3 },
			-- change text position of the text corresponding to outer right big bar
			["rightBigBar2"] = { { 0, 0 }, 3 },
			-- change text position of the text corresponding to inner right small bar
			["rightSmallBar1"] = { { 0, 0 }, 3 },
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
				["healthAbsorb"] = { { "FF0000", "FF0000", "FF0000" }, 3 },
				-- allows to change color of player health incoming heal on bars
				["healthHeal"] = { { "0000FF", "0000FF", "0000FF" }, 3 },
				-- allows to change color of player mana on bars
				["mana"] = { { "00FFFF", "0000FF", "FF00FF" }, 3 },
				-- allows to change color of player rage on bars
				["rage"] = { { "FF0000", "FF0000", "FF0000" }, 3 },
				-- allows to change color of player energy on bars
				["energy"] = { { "FFFF00", "FFFF00", "FFFF00" }, 3 },
				-- allows to change color of player runic power on bars
				["runicPower"] = { { "004060", "004060", "004060" }, 3 },
				-- allows to change color of player focus on bars
				["focus"] = { { "aa4400", "aa4400", "aa4400" }, 3 },
				-- allows to change color of player druid eclipse on bars
				["eclipse"] = { { "00FFFF", "0000FF", "FF00FF" }, 3 },
				-- allows to change color of player druid eclipse on bars
				["burningEmbers"] = { { "00FFFF", "0000FF", "FF00FF" }, 3 },
				-- allows to change color of player druid eclipse on bars
				["demonicFury"] = { { "00FFFF", "0000FF", "FF00FF" }, 3 },
			}, 1 },
			-- list with colors to visualize target data on bars
			["target"] = { {
				-- allows to change color of target health on bars
				["health"] = { { "00aa00", "aaaa00", "aa0000" }, 3 },
				-- allows to change color of target health shield on bars
				["healthShield"] = { { "aaaaaa", "aaaaaa", "aaaaaa" }, 3 },
				-- allows to change color of target health absorbed on bars
				["healthAbsorb"] = { { "aa0000", "aa0000", "aa0000" }, 3 },
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
			}, 1 },
			-- list with colors to visualize pet data on bars
			["pet"] = { {
				-- allows to change color of pet health on bars
				["health"] = { { "00FF00", "FFFF00", "FF0000" }, 3 },
				-- allows to change color of pet health shield on bars
				["healthShield"] = { { "FFFFFF", "FFFFFF", "FFFFFF" }, 3 },
				-- allows to change color of pet health absorbed on bars
				["healthAbsorb"] = { { "FF0000", "FF0000", "FF0000" }, 3 },
				-- allows to change color of pet health incoming heal on bars
				["healthHeal"] = { { "0000FF", "0000FF", "0000FF" }, 3 },
				-- allows to change color of target mana on bars
				["mana"] = { { "00FFFF", "0000FF", "FF00FF" }, 3 },
				-- allows to change color of pet focus on bars
				["focus"] = { { "aa4400", "aa4400", "aa4400" }, 3 },
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
				["debuff"] = { { "ffffff", "ffffff", "eeeeee" }, 3 },
				-- allows to change color of player applied spells
				["appliedByPlayer"] = { { "ffffff", "ffffff", "eeeeee" }, 3 },
			}, 1 },
			-- list with colors to visualize spell rectangles that are showing target auras
			["selfCooldowns"] = { {
				-- allows to change color of spell circle when it shows spell cooldown
				["spell"] = { { "ffffff", "ffffff", "eeeeee" }, 3 },
				-- allows to change color of spell circle when it shows item cooldown
				["item"] = { { "ffffff", "ffffff", "eeeeee" }, 3 },
			}, 1 },
			-- list with colors to visualize spell rectangles that are showing self auras
			["selfAuras"] = { {
				-- allows to change color of spell circle when it shows buff
				["buff"] = { { "ffffff", "ffffff", "eeeeee" }, 3 },
				-- allows to change color of spell circle when it shows debuff
				["debuff"] = { { "FFFF00", "FFFF00", "FFFF00" }, 3 },
			}, 1 },
			-- list with colors to visualize spell rectangles that are showing target auras
			["targetAuras"] = { {
				-- allows to change color of spell circle when it shows debuff
				["buff"] = { { "FFFF00", "FFFF00", "FFFF00" }, 3 },
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
			["health1"] = "<color_amount><amount></color><color_amount_habsorb><amount_habsorb(\" - \")></color><color_amount_extra><amount_extra(\" + \")></color><color_amount_hincome><amount_hincome(\" + \")></color>",
			-- health amount with health max amount
			["health2"] = "<color_amount><amount></color>/<amount_max><color_amount_habsorb><amount_habsorb(\" - \")></color><color_amount_extra><amount_extra(\" + \")></color><color_amount_hincome><amount_hincome(\" + \")></color>",
			-- health percent only
			["health3"] = "<color_amount><amount_percent>%</color><color_amount_habsorb><amount_habsorb(\" - \")></color><color_amount_extra><amount_extra(\" + \")></color><color_amount_hincome><amount_hincome(\" + \")></color>",
			-- health amount with health percent
			["health4"] = "<color_amount><amount></color> <color(\"999999\")>(</color><amount_percent>%<color(\"999999\")>)</color><color_amount_habsorb><amount_habsorb(\" + \")></color><color_amount_extra><amount_extra(\" + \")></color><color_amount_hincome><amount_hincome(\" + \")></color>";
			-- health amount with health max amount and percent
			["health5"] = "<color_amount><amount>/<amount_max></color> <color(\"999999\")>(</color><amount_percent>%<color(\"999999\")>)</color><color_amount_habsorb><amount_habsorb(\" - \")></color><color_amount_extra><amount_extra(\" + \")></color><color_amount_hincome><amount_hincome(\" + \")></color>",
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
			["unitInfo1"] = "<color_level><level><elite></color> <color_reaction><name></color> [<color_class><class></color>] <guild(\"<\",\">\")> <pvp>",
			-- medium user info
			["unitInfo2"] = "<color_level><level><elite></color> <color_reaction><name></color> [<color_class><class></color>] <pvp>",
			-- minimum user info
			["unitInfo3"] = "<color_level><level><elite></color> <color_reaction><name></color> <pvp>",
			-- cast time text
			["castTime1"] = "<color(\"ffff00\")><time></color>",
			-- cast time remaining time
			["castTime2"] = "<color(\"ffff00\")><time_remain></color>",
			-- cast delay text
			["castDelay1"] = "<color(\"ff0000\")><delay></color>",
			-- cast spell name text
			["castSpellName1"] = "<color(\"ffffff\")><spellname(\"|cffff0000Interrupted|r\")></color>",
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
			["aurasTimeLeftMax"] = { 60, 0, { range = { 0, 3600, 1 } } },
			-- allows to show player debuffs along with player buffs
			["playerDebuffs"] = { true, 0 },
			-- allows to colorize player debuffs according to debuff type
			["colorizePlayerDebuffs"] = { true, 0 },
			-- allows to show auras from this list, regardless of time or charges
			["playerAurasWhiteList"] = { { }, 5 },
			-- allows to not show auras from this list, regardless of time or charges
			["playerAurasBlackList"] = { { }, 5 },
			-- allows to show auras from this list, regardless of time or charges
			["targetAurasWhiteList"] = { { -- druid symbiosis spells are named the same, no point in including them
				48792, -- DK: Icebound Fortiture, prevents stuns on target
				33786, -- Druid: Cyclone, prevents any damage to target
				1022, -- Paladin: Hand of protection, prevents physical damage to target
				642, -- Paladin: Divine Shield, prevents all damage to target
				19263, -- Hunter: Deterrence, prevents all damage to target
				45438, -- Mage: Ice block, prevents all damage to target
				122464, -- Monk: Dematerialize, causes all abilities to miss
			}, 5 },
			-- allows to not show auras from this list, regardless of time or charges
			["targetAurasBlackList"] = { { }, 5 },
			-- minimum cooldown duration to be shown in short cooldowns
			["cooldownsDurationMin"] = { 0, 0, { range = { 0, 3600, 1 } } },
			-- maximum cooldown duration to be shown in short cooldowns
			["cooldownsDurationMax"] = { 3600, 0, { range = { 0, 3600, 1 } } },
			-- allows to show item cooldowns
			["cooldownsItem"] = { true, 0 },
			-- allows to show cooldowns from this list, regardless of time
			["cooldownsWhiteList"] = { { }, 5 },
			-- allows to not show cooldowns from this list, regardless of time
			["cooldownsBlackList"] = { { }, 5 },
		}, 1 },
		-- list with options for all auras
		["aurasOptions"] = { {
			-- allows to show tooltips when mouse is over some aura
			["showTooltips"] = { true, 0 },
			-- allows to show timers on target buffs
			["showTimersOnTargetBuffs"] = { false, 0 },
			-- allows to show timers on target debuffs
			["showTimersOnTargetDeBuffs"] = { false, 0 },
		}, 1 },
		-- list with options for health
		["healthBarOptions"] = { {
			-- allows to show shield on health bars
			["showShields"] = { true, 0 },
			-- allows to show how much of the health will be absorbed by heal
			["showHealAbsorb"] = { true, 0 },
			-- allows to show incoming heal
			["showHealIncoming"] = { true, 0 },
		}, 1 },
		-- what data to display on bars, not filled if not custom
		["framesData"] = { {
			-- layout to use, 0 = custom, all unset settings will be readed from layout specified
			["layout"] = { 1, 0 },
			-- what to show in inner left big bar
			["leftBigBar1"] = { false, 7 },
			-- what to show on outer left big bar
			["leftBigBar2"] = { false, 7 },
			-- what to show on inner left small bar
			["leftSmallBar1"] = { false, 7 },
			-- what to show on inner right big bar
			["rightBigBar1"] = { false, 7 },
			-- what to show on outer right big bar
			["rightBigBar2"] = { false, 7 },
			-- what to show on inner right small bar
			["rightSmallBar1"] = { false, 7 },
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
						 "characterInVehicleHealth", "characterInVehiclePower" },
			-- data that can be shown on cast bars
			["castBars"] = { "playerCastBar", "targetCastBar" },
			-- data that can be shown on resource frames
			["resource"] = { "comboPoints", "dkRunes", "paladinHolyPower", "monkChi", "priestSpheres", "warlockShards" },
			-- data that can be shown on spell circles
			["spellCircles"] = { "playerShortAuras", "targetShortAuras", "cooldowns" },
			-- data that can be shown on spell rectangles
			["spellRectangles"] = { "targetBuffs", "targetDebuffs" },
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
					-- what to show on inner right big bar
					["rightBigBar1"] = { "playerPower" },
					-- what to show on outer right big bar
					["rightBigBar2"] = { "targetPower" },
					-- what to show on inner right small bar
					["rightSmallBar1"] = { "characterInVehiclePower", "petPower" },
					-- what to show in inner left big cast bar
					["leftBigCastBar1"] = { },
					-- what to show on outer left big cast bar
					["leftBigCastBar2"] = { },
					-- what to show on inner right big cast bar
					["rightBigCastBar1"] = { "playerCastBar" },
					-- what to show on outer right big cast bar
					["rightBigCastBar2"] = { "targetCastBar" },
					-- what to show on the left outer side info
					["leftOuterSideInfo"] = { "playerComboPoints" },
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
					-- what to show on inner right small bar
					["rightSmallBar1"] = { "characterInVehiclePower", "druidEclipse", "druidMana" },
				},
				-- druid overrides
				["MONK"] = {
					-- what to show on the left outer side info
					["leftOuterSideInfo"] = { "monkChi", "playerComboPoints" },
					-- what to show on inner right small bar
					["rightSmallBar1"] = { "characterInVehiclePower", "monkMana" },
				},
				-- warlock overrides
				["WARLOCK"] = {
					-- what to show on the left outer side info
					["leftOuterSideInfo"] = { "warlockSoulShards", "playerComboPoints" },
					-- what to show on inner right small bar
					["rightSmallBar1"] = { "characterInVehiclePower", "warlockBurningEmbers", "warlockDemonicFury" },
				},
				-- paladin overrides
				["PALADIN"] = {
					-- what to show on the left outer side info
					["leftOuterSideInfo"] = { "paladinHolyPower", "playerComboPoints" },
				},
				-- priest overrides
				["PRIEST"] = {
					-- what to show on the left outer side info
					["leftOuterSideInfo"] = { "priestShadowOrbs", "playerComboPoints" },
				},
				-- death knight overrides
				["DEATHKNIGHT"] = {
					-- what to show on the left outer side info
					["leftOuterSideInfo"] = { "deathKnightRunes", "playerComboPoints" },
				},
			},
		}, 2 },
		-- all other settings that didn't fit to other groups
		["misc"] = { {
			-- allows to animate bars
			["animateBars"] = { true, 0 },
			-- allows to reverse casting bar animation
			["reverseCastingBars"] = { true, 0 },
			-- allows all timers to show milliseconds instead of seconds (when 10 or less seconds left)
			["textTimerShowMilliSeconds"] = { true, 0 },
			-- allows all numbers to be shortened (for numbers that use more than 5 chars)
			["textShortNumbers"] = { true, 0 },
			-- allows to show what you are casting
			["showPlayerCastBarInfo"] = { false, 0 },
			-- allows to store combo-points on targets that are no longer selected
			["storeComboPoints"] = { true, 0 },
			-- allows to show DHUD icon on minimap
			["minimapIcon"] = { true, 0 },
		}, 1 },
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
	-- numeric version of the addon at which saved vars was saved last time
	savedVarsVersion = 0,
	-- represents nil array, required for dataSource settings
	NILTABLE = { },
})

--- Custom getter to read frames data settings
function DHUDSettings:getFramesData(name)
	local valueStored = self.settings[name];
	-- setting not exists?
	if (valueStored == nil) then
		return nil;
	end
	-- check not default
	if (valueStored ~= false) then
		return valueStored;
	end
	-- read default table data
	local defaultTable = self:getValueDefaultTable(name);
	local tableInfo = defaultTable[3];
	local groups = tableInfo.groups;
	local lastName = tableInfo.lastName;
	-- read layout data
	local layout = self.settings["framesData_layout"];
	local layoutData = self.default["layouts"][1]["layout" .. layout];
	-- check for class specific value
	local value = nil;
	local class = DHUDDataTrackers.helper.playerClass;
	local table = layoutData[class];
	if (table ~= nil) then
		for i = 2, #groups, 1 do
			table = table[groups[i]];
			if (table == nil) then
				break;
			end
		end
		if (table ~= nil) then
			value = table[lastName];
		end
	end
	if (value ~= nil) then
		return value;
	end
	-- read value for any class
	local table = layoutData[1];
	for i = 2, #groups, 1 do
		table = table[groups[i]];
	end
	value = table[lastName];
	return value;
end

--- Custom getter to read unit texts settings
function DHUDSettings:getUnitTexts(name)
	local value = self.settings[name];
	if (value == nil) then
		return nil;
	end
	-- check first symbol
	local firstSymbol = value:sub(1, 1);
	if (firstSymbol ~= "@") then
		return value;
	end
	-- check if it uses default value
	if (value == "@default") then
		local infoDefault = self:getValueDefaultTable(name)[3].default;
		local class = DHUDDataTrackers.helper.playerClass;
		if (infoDefault[class] ~= nil) then
			value = infoDefault[class];
		else
			value = infoDefault[1];
		end
	end
	-- return predefined value
	local predefinedName = value:sub(2);
	local predefinedValues = self.default["unitTextsPredefined"][1];
	local predefinedValue = predefinedValues[predefinedName];
	if (predefinedValue ~= nil) then
		return predefinedValue;
	end
	return value;
end

--- Search for custom setter or getter of setting specified
-- @param settingName name of the setting
-- @param funcList list with functions (setters or getters)
-- @return reference to function or nil if no function found
function DHUDSettings:searchCustomSetterOrGetter(settingName, funcList)
	-- search for setting specified
	local func = funcList[settingName];
	if (func ~= nil) then
		return func;
	end
	-- not found, search for rewritten groups
	local groups = { strsplit("_", settingName) };
	table.remove(groups);
	while (#groups > 0) do
		func = funcList[table.concat(groups, "_")];
		if (func ~= nil) then
			return func;
		end
		table.remove(groups);
	end
	return nil;
end

--- Get value of default setting
-- @param settingName name of the setting
-- @param tableDefault this setting default table or nil
-- @return real default value and table default value
function DHUDSettings:getSettingDefaultValue(settingName, tableDefault)
	tableDefault = tableDefault or self:getValueDefaultTable(settingName);
	tableValue = tableDefault[1];
	-- search for getter
	local getter = self:searchCustomSetterOrGetter(settingName, self.getters)
	if (getter == nil) then
		return tableValue, tableValue;
	end
	-- get current value
	local currentVar = self.settings[settingName];
	-- set setting to default and invoke getter
	self.settings[settingName] = tableValue;
	local getterValue = getter(self, settingName);
	-- restore value
	self.settings[settingName] = currentVar;
	-- return calculated default value
	return getterValue, tableValue;
end

--- Set value of the setting
-- @param name name of the setting
-- @param value value to set
function DHUDSettings:setValue(name, value)
	local custom = self:searchCustomSetterOrGetter(name, self.setters);
	-- has custom getter?
	if (custom ~= nil) then
		custom(self, name, value);
		return;
	end
	-- set value
	self:setValueInternal(name, value);
end

--- Internal function to set value of the setting, should not be invoked from other classes
-- @param name name of the setting
-- @param value value to set, pass nil for default value
function DHUDSettings:setValueInternal(name, value)
	-- process default value if required
	if (value == nil) then
		self:processDefaultSettingValue(name, self:getValueDefaultTable(name));
		local defaultVar = self.settings[name];
		if (defaultVar ~= nil) then
			self:setValueInternal(name, defaultVar);
		end
	end
	-- value to be saved in saved vars table
	local valueForSavedVars = nil;
	-- get default table
	local tableDefault = self:getValueDefaultTable(name);
	if (tableDefault == nil) then
		return; -- attempt to set setting that doesn't exists
	end
	local tableValue, tableOrigValue = self:getSettingDefaultValue(name, tableDefault);
	local tableType = tableDefault[2];
	local tableInfo = tableDefault[3];
	-- allow to set specific values for some settings that return different value
	if (value == tableOrigValue) then
		value = tableValue;
	end
	-- apply restrictions to value
	value = self:applyRestrictionsToValue(value, tableValue, tableDefault);
	if (value == nil) then
		return; -- attempt to set value that can't be processed
	end
	-- switch by setting type
	-- setting contains single value
	if (tableType == self.SETTING_TYPE_VALUE) then
		-- compare values
		if (value ~= tableValue) then
			valueForSavedVars = value;
		end
	-- setting contains array of fixed size and order
	elseif (tableType == self.SETTING_TYPE_ARRAY_FIXEDORDERSIZE or tableType == self.SETTING_TYPE_ARRAY_FIXEDORDER) then
		-- compare arrays
		for i, v in ipairs(value) do
			if (v ~= tableValue[i]) then
				-- values are different
				valueForSavedVars = value;
				break;
			end
		end
	-- setting contains list or map, saved vars should contain only difference from it
	elseif (tableType == self.SETTING_TYPE_ARRAY_NOORDERSIZE or tableType == self.SETTING_TYPE_ARRAY_SPELLIDTONAME or tableType == self.SETTING_TYPE_TABLE) then
		local added = { };
		local removed = { };
		local key;
		-- search for removed items
		for i, v in pairs(tableValue) do
			if (tableType == self.SETTING_TYPE_ARRAY_SPELLIDTONAME) then
				v = DHUDDataTrackers.helper:getSpellName(v);
			end
			key = MCFindValueInTable(value, v);
			-- value no longer in table
			if (key == nil) then
				table.insert(removed, v);
			end
		end
		-- search for added items
		for i, v in pairs(value) do
			key = nil;
			-- search if items that were present, using cycle instead of function as we are required to change spellIds to spellNames
			for i2, v2 in pairs(tableValue) do
				if (tableType == self.SETTING_TYPE_ARRAY_SPELLIDTONAME) then
					v2 = DHUDDataTrackers.helper:getSpellName(v2);
				end
				-- check values
				if (v2 == v) then
					key = i2;
					break;
				end
			end
			-- value was not in table
			if (key == nil) then
				table.insert(added, v);
			end
			-- list is changed?
			if (#added > 0 or #removed > 0) then
				valueForSavedVars = { added, removed };
			end
		end
	end
	-- save saved var
	DHUD_SAVED_VARS_TEMP[name] = valueForSavedVars;
	-- save
	self.settings[name] = value;
	-- dispatch events
	-- setting changed event
	self.eventSettingChanged.setting = name;
	self:dispatchEvent(self.eventSettingChanged);
	-- specific setting changed event
	self.eventSpecificSettingChanged.setting = name;
	self.eventSpecificSettingChanged.type = DHUDSettingsEvent.EVENT_SPECIFIC_SETTING_CHANGED_PREFIX .. name;
	self:dispatchEvent(self.eventSpecificSettingChanged);
	-- group setting changed event
	self.eventSpecificGroupChanged.setting = name;
	local groupName;
	local parent = tableDefault;
	while (true) do
		parent = parent[3].parent;
		if (parent == nil) then
			break;
		end
		groupName = parent[3].fullName;
		self.eventSpecificGroupChanged.type = DHUDSettingsEvent.EVENT_SPECIFIC_GROUP_SETTING_CHANGED_PREFIX .. groupName;
		self:dispatchEvent(self.eventSpecificGroupChanged);
	end
end

--- Apply restrictions to value
-- @param value value that is going to be saved
-- @param tableValue value in defaults table
-- @param defaultTable table with default data, that contains restrictions on value
-- @return value with restrictions, or nil if value can't be set
function DHUDSettings:applyRestrictionsToValue(value, tableValue, defaultTable)
	local tableType = defaultTable[2];
	local tableInfo = defaultTable[3];
	-- switch by setting type
	-- setting contains single value
	if (tableType == self.SETTING_TYPE_VALUE) then
		-- check if type of variables are the same
		if (type(value) ~= type(tableValue)) then
			return nil;
		end
		-- check if setting has range
		local rangeData = tableInfo.range;
		if (rangeData ~= nil) then
			local minValue = rangeData[1];
			local maxValue = rangeData[2];
			if (value > maxValue) then
				value = maxValue;
			elseif (value < minValue) then
				value = minValue;
			end
		end
	-- all other variables are tables
	else
		if ("table" ~= type(value)) then
			return nil;
		end
		-- setting contains array of fixed size and order
		if (tableType == self.SETTING_TYPE_ARRAY_FIXEDORDERSIZE) then
			-- array lengths should be the same
			if (#value ~= #tableValue) then
				return nil;
			end
			-- variable types should also be the same
			for i, v in ipairs(value) do
				if (type(v) ~= type(tableValue[i])) then
					return nil;
				end
			end
		end
	end
	return value;
end

--- Get value of the setting
-- @param name name of the setting
-- @return value of the setting
function DHUDSettings:getValue(name)
	local custom = self:searchCustomSetterOrGetter(name, self.getters);
	-- has custom getter?
	if (custom ~= nil) then
		return custom(self, name);
	end
	return self.settings[name];
end

--- Get default value of the table
-- @param name name of the setting
-- @return table with default data about this setting
function DHUDSettings:getValueDefaultTable(name)
	local groups = { strsplit("_", name) };
	-- first iteration
	setting = self.default[groups[1]];
	-- iterate further
	for i = 2, #groups, 1 do
		setting = setting[1][groups[i]];
	end
	return setting;
end

--- Get reference to data tracker by name
-- @param dataTrackerName name of the data tracker
-- @return reference to data tracker
function DHUDSettings:getDataTrackerByName(dataTrackerName)
	local trackersTable = self.default.framesDataSources[1].dataTrackersMap;
	return trackersTable[dataTrackerName];
end

--- Convert data tracker names array to reference array, always constructs new table
-- @param namesArray array with names
-- @return array with references
function DHUDSettings:convertDataTrackerNamesArrayToReferenceArray(namesArray)
	local refArray = { };
	for i, v in ipairs(namesArray) do
		refArray[i] = self:getDataTrackerByName(v);
	end
	return refArray;
end

--- Map data trackers to table values
function DHUDSettings:mapDataTrackers()
	local trackersTable = self.default.framesDataSources[1].dataTrackersMap;
	trackersTable["playerHealth"] = { DHUDDataTrackers.ALL.selfHealth };
	trackersTable["targetHealth"] = { DHUDDataTrackers.ALL.targetHealth };
	trackersTable["characterInVehicleHealth"] = { DHUDDataTrackers.ALL.selfCharInVehicleHealth };
	trackersTable["petHealth"] = { DHUDDataTrackers.ALL.petHealth };
	trackersTable["playerPower"] = { DHUDDataTrackers.ALL.selfPower };
	trackersTable["targetPower"] = { DHUDDataTrackers.ALL.targetPower };
	trackersTable["characterInVehiclePower"] = { DHUDDataTrackers.ALL.selfCharInVehiclePower };
	trackersTable["petPower"] = { DHUDDataTrackers.ALL.petPower };
	trackersTable["playerComboPoints"] = { DHUDDataTrackers.ALL.selfComboPoints };
	trackersTable["playerCooldowns"] = { DHUDDataTrackers.ALL.selfCooldowns, DHUDTimersFilterHelperSettingsHandler.filterPlayerCooldowns };
	trackersTable["playerShortAuras"] = { DHUDDataTrackers.ALL.selfAuras, DHUDTimersFilterHelperSettingsHandler.filterPlayerShortAuras };
	trackersTable["targetShortAuras"] = { DHUDDataTrackers.ALL.targetAuras, DHUDTimersFilterHelperSettingsHandler.filterTargetShortAuras };
	trackersTable["targetInfo"] = { DHUDDataTrackers.ALL.targetInfo };
	trackersTable["targetOfTargetInfo"] = { DHUDDataTrackers.ALL.targetOfTargetInfo };
	trackersTable["targetBuffs"] = { DHUDDataTrackers.ALL.targetAuras, DHUDTimersFilterHelperSettingsHandler.filterBuffAuras };
	trackersTable["targetDebuffs"] = { DHUDDataTrackers.ALL.targetAuras, DHUDTimersFilterHelperSettingsHandler.filterDebuffAuras };
	trackersTable["playerCastBar"] = { DHUDDataTrackers.ALL.selfCast };
	trackersTable["targetCastBar"] = { DHUDDataTrackers.ALL.targetCast };
	-- specific to druid
	trackersTable["druidMana"] = { DHUDDataTrackers.DRUID.selfMana };
	trackersTable["druidEnergy"] = { DHUDDataTrackers.DRUID.selfEnergy };
	trackersTable["druidEclipse"] = { DHUDDataTrackers.DRUID.selfEclipse };
	-- specific to monk
	trackersTable["monkMana"] = { DHUDDataTrackers.MONK.selfMana };
	trackersTable["monkEnergy"] = { DHUDDataTrackers.MONK.selfEnergy };
	trackersTable["monkChi"] = { DHUDDataTrackers.MONK.selfChi };
	-- specific to warlock
	trackersTable["warlockSoulShards"] = { DHUDDataTrackers.WARLOCK.selfSoulShards };
	trackersTable["warlockBurningEmbers"] = { DHUDDataTrackers.WARLOCK.selfBurningEmbers };
	trackersTable["warlockDemonicFury"] = { DHUDDataTrackers.WARLOCK.selfDemonicFury };
	-- specific to paladin
	trackersTable["paladinHolyPower"] = { DHUDDataTrackers.PALADIN.selfHolyPower };
	-- specific to priest
	trackersTable["priestShadowOrbs"] = { DHUDDataTrackers.PRIEST.selfShadowOrbs };
	-- specific to death knight
	trackersTable["deathKnightRunes"] = { DHUDDataTrackers.DEATHKNIGHT.selfRunes };
end

--- Initialize single setting from table
-- @param tableName name of the table
-- @param tableContent table contents to be processed
-- @param parent table, that is parent to this setting
-- @param groupArray array with groups that are parents to this setting
function DHUDSettings:processDefaultSetting(tableName, tableContent, parent, groupArray)
	--print("tableName " .. tableName);
	local tableValue = tableContent[1];
	local tableType = tableContent[2];
	local tableInfo = tableContent[3];
	-- update value full name and groups list
	if (tableInfo == nil) then
		tableInfo = { };
		tableContent[3] = tableInfo;
	end
	local fullName = tableName;
	if (#groupArray > 0) then
		fullName = table.concat(groupArray, "_") .. "_" .. tableName;
	end
	tableInfo["groups"] = groupArray;
	tableInfo["lastName"] = tableName;
	tableInfo["fullName"] = fullName;
	tableInfo["parent"] = parent;
	-- references should not be copied
	if (tableType == self.SETTING_TYPE_CONTAINER_REFERENCE) then
		return;
	-- containers should be processed further
	elseif (tableType == self.SETTING_TYPE_CONTAINER) then
		local containerGroup = MCCreateTableCopy(groupArray);
		table.insert(containerGroup, tableName);
		-- process
		for i, v in pairs(tableValue) do
			self:processDefaultSetting(i, v, tableContent, containerGroup);
		end
		return;
	end
	self:processDefaultSettingValue(fullName, tableContent);
end

--- Save contents of default table to settings table
-- @param fullName fullName of the setting
-- @param defaultTableContent table with default data about setting
function DHUDSettings:processDefaultSettingValue(fullName, defaultTableContent)
	local tableValue = defaultTableContent[1];
	local tableType = defaultTableContent[2];
	-- process setting if required
	if (tableType ~= self.SETTING_TYPE_VALUE) then
		tableValue = MCCreateTableDeepCopy(tableValue);
	end
	-- process spell ids
	if (tableType == self.SETTING_TYPE_ARRAY_SPELLIDTONAME) then
		for i, v in ipairs(tableValue) do
			tableValue[i] = DHUDDataTrackers.helper:getSpellName(v);
		end
	end
	-- save to settings table
	self.settings[fullName] = tableValue;
end

--- Initialize settings table with default table
function DHUDSettings:processDefaultSettingsTable()
	for i, v in pairs(self.default) do
		self:processDefaultSetting(i, v, nil, { });
	end
end

--- Process saved vars table and fill settings table with changes from it
function DHUDSettings:processSavedVars()
	-- read version
	local version = DHUD_SAVED_VARS_TEMP["version"] or 0;
	-- process saved vars
	local defaultTable, settingType, settingDefaultValue, settingInfo;
	-- iterate
	for k, v in pairs(DHUD_SAVED_VARS_TEMP) do
		-- get default table
		defaultTable = self:getValueDefaultTable(k);
		-- value exists?
		if (defaultTable ~= nil) then
			settingType = defaultTable[2];
			settingDefaultValue = self:getSettingDefaultValue(k, tableDefault);
			settingInfo = defaultTable[3];
			-- apply restrictions
			v = self:applyRestrictionsToValue(v, settingDefaultValue, defaultTable);
			if (v ~= nil) then
				-- standard setting?
				if (settingType == self.SETTING_TYPE_VALUE or settingType == self.SETTING_TYPE_ARRAY_FIXEDORDERSIZE) then
					self.settings[k] = v;
				-- list setting, variable contains arrays with added and removed values
				else
					local list = self.settings[k];
					local added = v[1];
					local removed = v[2];
					local key;
					-- process removed vars
					for i2, v2 in ipairs (removed) do
						key = MCFindValueInTable(list, v2);
						if (key ~= nil) then
							table.remove(list, key);
						end
					end
					-- process added vars
					for i2, v2 in ipairs (added) do
						key = MCFindValueInTable(list, v2);
						if (key == nil) then
							table.insert(list, v2);
						end
					end
					-- save
					self.settings[k] = list;
				end
			end
		end
	end
	-- save version
	DHUD_SAVED_VARS_TEMP["version"] = DHUDMain.versionInt;
end

--- Initialize custom setters and getters
function DHUDSettings:initCustomSettersAndGetters()
	self.getters["framesData"] = self.getFramesData;
	self.getters["unitTexts"] = self.getUnitTexts;
end

--- Initialize settings hadler, addon saved variables are loaded at this moment
function DHUDSettings:init()
	-- construct event dispatcher
	self:constructor();
	-- create events
	self.eventSettingChanged = DHUDSettingsEvent:new(DHUDSettingsEvent.EVENT_SETTING_CHANGED);
	self.eventSpecificSettingChanged = DHUDSettingsEvent:new(DHUDSettingsEvent.EVENT_SPECIFIC_SETTING_CHANGED_PREFIX);
	self.eventSpecificGroupChanged = DHUDSettingsEvent:new(DHUDSettingsEvent.EVENT_SPECIFIC_GROUP_SETTING_CHANGED_PREFIX);
	self.eventStartPreview = DHUDSettingsEvent:new(DHUDSettingsEvent.EVENT_START_PREVIEW);
	self.eventStopPreview = DHUDSettingsEvent:new(DHUDSettingsEvent.EVENT_STOP_PREVIEW);
	-- init settings
	self:mapDataTrackers();
	self:processDefaultSettingsTable();
	self:initCustomSettersAndGetters();
	-- read saved vars
	self:processSavedVars();
	-- init non-addon specific settings handler
	DHUDNonAddonSettingsHandler:init();
	-- init timer filter functions
	DHUDTimersFilterHelperSettingsHandler:init();
end

--- Print contents of the table specified to string, used for debugging purposes
-- @param name name of the table
-- @param settings table with settings to print
function DHUDSettings:printSettingTableToString(name, settings)
	local result = "Contents of " .. name .. ":";
	-- sort keys
	local keys = { };
	for k, v in pairs(settings) do
		table.insert(keys, k);
	end
	table.sort(keys);
	-- print values
	for i, k in ipairs(keys) do
		result = result .. "\n  " .. k .. ": " .. MCTableToString(settings[k]);
	end
	return result;
end

--- Function to reset settings to default values
function DHUDSettings:resetToDefaults()
	for k, v in pairs(self.settings) do
		self:setValueInternal(k, nil);
	end
end

--- Start preview of current settings
function DHUDSettings:previewStart()
	self:dispatchEvent(self.eventStartPreview);
end

--- Stop preview of current settings
function DHUDSettings:previewStop()
	self:dispatchEvent(self.eventStopPreview);
end

--- Function to get table with additional saved vars, it may contain other addon data or some statistic data
-- @param tableName name of the sub table, pass nil to get whole additional saved vars table
-- @return table with additional saved vars
function DHUDSettings:getAdditionalSavedVars(tableName)
	local additional = DHUD_SAVED_VARS_TEMP["_additional"];
	if (additional == nil) then
		additional = { };
		DHUD_SAVED_VARS_TEMP["_additional"] = additional;
	end
	if (tableName == nil) then
		return additional;
	end
	local subTable = additional[tableName];
	if (subTable == nil) then
		subTable = { };
		additional[tableName] = subTable;
	end
	return subTable;
end

--------------------------
-- Timers filter helper --
--------------------------

--- Class to filter timers trackers according to settings
DHUDTimersFilterHelperSettingsHandler = {
	-- white list with player auras
	whiteListPlayerAuras = {
	},
	-- black list with player auras
	blackListPlayerAuras = {
	},
	-- white list with target auras
	whiteListTargetAuras = {
	},
	-- black list with target auras
	blackListTargetAuras = {
	},
	-- white list with target cooldowns
	whiteListPlayerCooldowns = {
	},
	-- black list with player cooldowns
	blackListPlayerCooldowns = {
	},
	-- show auras with charges?
	aurasWithCharges = false,
	-- allows to show item cooldowns
	cooldownsItem = false,
	-- auras maximum time left
	aurasTimeLeftMax = 0,
	-- allows to show short player debuffs
	playerDebuffs = false,
	-- cooldowns minimum duration
	cooldownsDurationMin = 0,
	-- cooldowns maximum duration
	cooldownsDurationMax = 0,
}

--- Filter player auras list to show only short auras (not a class function, self is nil!)
-- @param timer timer to filter { type, timeLeft, duration, id, tooltipId, name, stacks, texture, exists, iterating, sortOrder }
-- @return nil if timer is not required or number for timer sorting order
function DHUDTimersFilterHelperSettingsHandler.filterPlayerShortAuras(timer)
	local self = DHUDTimersFilterHelperSettingsHandler;
	-- check blacklist
	if (self.blackListPlayerAuras[timer[6]] == true) then
		return nil;
	end
	-- check white list
	if (self.whiteListPlayerAuras[timer[6]] == nil) then
		-- do not show debuffs?
		if (not self.playerDebuffs and (bit.band(timer[1], DHUDAurasTracker.TIMER_TYPE_MASK_DEBUFF) ~= 0)) then
			return nil;
		end
		-- if duration is too high or stack count is low - return
		if ((timer[2] > self.aurasTimeLeftMax or timer[2] < 0) and (not self.aurasWithCharges or timer[7] < 1)) then
			return nil;
		end
	end
	return (bit.band(timer[1], DHUDAurasTracker.TIMER_TYPE_MASK_BUFF) ~= 0) and 1 or 2;
end

--- Filter target auras list to show only short auras (not a class function, self is nil!)
-- @param timer timer to filter { type, timeLeft, duration, id, tooltipId, name, stacks, texture, exists, iterating, sortOrder }
-- @return nil if timer is not required or number for timer sorting order
function DHUDTimersFilterHelperSettingsHandler.filterTargetShortAuras(timer)
	local self = DHUDTimersFilterHelperSettingsHandler;
	-- check blacklist
	if (self.blackListTargetAuras[timer[6]] == true) then
		return nil;
	end
	-- check white list
	if (self.whiteListPlayerAuras[timer[6]] == nil) then
		-- show only player applied spells
		local mask = DHUDAurasTracker.TIMER_TYPE_MASK_IS_CAST_BY_PLAYER; -- DHUDAurasTracker.TIMER_TYPE_MASK_DEBUFF + 
		--print("name is " .. timer[6] .. ", type is " .. timer[1]);
		if (bit.band(timer[1], mask) ~= mask) then
			return nil;
		end
		-- if duration is too high or stack count is low - return
		if ((timer[2] > self.aurasTimeLeftMax or timer[2] < 0) and (not self.aurasWithCharges or timer[7] < 1)) then
			return nil;
		end
	end
	return (bit.band(timer[1], DHUDAurasTracker.TIMER_TYPE_MASK_DEBUFF) ~= 0) and 1 or 2;
end

--- Filter only buff auras
-- @param timer timer to filter { type, timeLeft, duration, id, tooltipId, name, stacks, texture, exists, iterating, sortOrder }
-- @return nil if timer is not required or number for timer sorting order
function DHUDTimersFilterHelperSettingsHandler.filterBuffAuras(timer)
	local self = DHUDTimersFilterHelperSettingsHandler;
	if (bit.band(timer[1], DHUDAurasTracker.TIMER_TYPE_MASK_BUFF) == 0) then
		return nil;
	end
	return 1;
end

--- Filter only debuff auras
-- @param timer timer to filter { type, timeLeft, duration, id, tooltipId, name, stacks, texture, exists, iterating, sortOrder }
-- @return nil if timer is not required or number for timer sorting order
function DHUDTimersFilterHelperSettingsHandler.filterDebuffAuras(timer)
	local self = DHUDTimersFilterHelperSettingsHandler;
	if (bit.band(timer[1], DHUDAurasTracker.TIMER_TYPE_MASK_DEBUFF) == 0) then
		return nil;
	end
	--print("name is " .. timer[6] .. ", type is " .. timer[1]);
	return 1;
end

--- Filter player cooldowns list to show only short cooldowns (not a class function, self is nil!)
-- @param timer timer to filter { type, timeLeft, duration, id, tooltipId, name, stacks, texture, exists, iterating, sortOrder }
-- @return nil if timer is not required or number for timer sorting order
function DHUDTimersFilterHelperSettingsHandler.filterPlayerCooldowns(timer)
	local self = DHUDTimersFilterHelperSettingsHandler;
	local isItem = bit.band(timer[1], DHUDCooldownsTracker.TIMER_TYPE_MASK_ITEM) ~= 0;
	--print("timer is " .. MCTableToString(timer));
	-- check blacklist
	if (self.blackListPlayerCooldowns[timer[6]] == true or (isItem and self.blackListPlayerCooldowns["_slot"][timer[5]] == true)) then
		return nil;
	end
	-- check white list
	if (self.whiteListPlayerCooldowns[timer[6]] == nil and ((not isItem) or self.whiteListPlayerCooldowns["_slot"][timer[5]] == nil)) then
		-- if duration is too high or too low then return
		if (timer[3] < self.cooldownsDurationMin or timer[3] > self.cooldownsDurationMax or (isItem and (not self.cooldownsItem))) then
			return nil;
		end
	end
	-- cooldownsItem
	return (bit.band(timer[1], DHUDCooldownsTracker.TIMER_TYPE_MASK_SPELL) ~= 0) and 1 or 2;
end

--- Process setting with white or black list
-- @param settingName name of the setting
-- @param tableName name of the table to fill
-- @param additionalProcessFunc function to make additional list processing (invoked with table argument)
function DHUDTimersFilterHelperSettingsHandler:processSpellListSetting(settingName, tableName, additionalProcessFunc)
	local process = function(self, e)
		local list = DHUDSettings:getValue(settingName);
		local table = self[tableName];
		-- remove all previous values
		for k, v in pairs(table) do
			table[k] = nil;
		end
		-- save new values
		for i, v in ipairs(list) do
			table[v] = true;
		end
		-- process table
		if (additionalProcessFunc ~= nil) then
			additionalProcessFunc(self, table);
		end
	end
	DHUDSettings:addEventListener(DHUDSettingsEvent.EVENT_SPECIFIC_SETTING_CHANGED_PREFIX .. settingName, self, process);
	process(self, nil);
end

--- Process setting with condition
-- @param settingName name of the setting
-- @param varName name of the variable to fill
function DHUDTimersFilterHelperSettingsHandler:processConditionSetting(settingName, varName)
	local process = function(self, e)
		self[varName] = DHUDSettings:getValue(settingName);
	end
	DHUDSettings:addEventListener(DHUDSettingsEvent.EVENT_SPECIFIC_SETTING_CHANGED_PREFIX .. settingName, self, process);
	process(self, nil);
end

--- Process table with spells, adding items list
-- @param t name of the setting
function DHUDTimersFilterHelperSettingsHandler:processItemSlotList(t)
	local slots = { };
	--print("item table " .. MCTableToString(t));
	for k, v in pairs(t) do
		-- check syntaxis
		local indexS, indexE = strfind(k, "<slot:.->", 0); -- search for "<slot:13>" text
		if (indexS ~= nil) then
			local slot = strsub(k, indexS + 6, indexE - 1);
			--print("found slot " .. slot);
			slots[slot] = true;
		end
	end
	t["_slot"] = slots;
end

--- initialize timers filter settings handler
function DHUDTimersFilterHelperSettingsHandler:init()
	-- spell lists
	self:processSpellListSetting("shortAurasOptions_playerAurasWhiteList", "whiteListPlayerAuras");
	self:processSpellListSetting("shortAurasOptions_playerAurasBlackList", "blackListPlayerAuras");
	self:processSpellListSetting("shortAurasOptions_targetAurasWhiteList", "whiteListTargetAuras");
	self:processSpellListSetting("shortAurasOptions_targetAurasBlackList", "blackListTargetAuras");
	self:processSpellListSetting("shortAurasOptions_cooldownsWhiteList", "whiteListPlayerCooldowns", self.processItemSlotList);
	self:processSpellListSetting("shortAurasOptions_cooldownsBlackList", "blackListPlayerCooldowns", self.processItemSlotList);
	-- conditions
	self:processConditionSetting("shortAurasOptions_aurasWithCharges", "aurasWithCharges");
	self:processConditionSetting("shortAurasOptions_aurasTimeLeftMax", "aurasTimeLeftMax");
	self:processConditionSetting("shortAurasOptions_playerDebuffs", "playerDebuffs");
	self:processConditionSetting("shortAurasOptions_cooldownsDurationMin", "cooldownsDurationMin");
	self:processConditionSetting("shortAurasOptions_cooldownsDurationMax", "cooldownsDurationMax");
	self:processConditionSetting("shortAurasOptions_cooldownsItem", "cooldownsItem");
end

-------------------------------------
-- Settings slash commands handler --
-------------------------------------

--- Initialize slash commands handling
function DHUDSettings:SlashCommandHandlerInit()
	
end

--- Handler for commands passed from chat using "/dhud"
-- @param args string with variable to set or read
function DHUDSettings:SlashCommandHandler(args)
	if (args == nil) then
		args = "";
	end
	local removeLeadingAndTrailingWhiteSpace = "^%s*(.-)%s*$";
	-- process arguments
	local indexOfEquals = string.find(args, "=");
	local variableName;
	local variableValue;
	-- found equals sign?
	if (indexOfEquals ~= nil) then
		variableName = string.sub(args, 1, indexOfEquals - 1);
		variableValue = string.sub(args, indexOfEquals + 1);
		variableValue = variableValue:match(removeLeadingAndTrailingWhiteSpace);
	else
		variableName = args;
		variableValue = nil;
	end
	variableName = variableName:match(removeLeadingAndTrailingWhiteSpace);
	-- check variable existance
	if (self.settings[variableName] == nil) then
		print("Requested variable not found, printing setting table...");
		print(self:printSettingTableToString("settings", self.settings));
		return;
	end
	-- set variable?
	if (variableValue ~= nil) then
		print("Setting variable " .. variableName .. " to: " .. variableValue);
		local evalFunc = loadstring("return " .. variableValue, "DHUD settings text input");
		if (evalFunc ~= nil) then
			variableValue = evalFunc();
		end
		self:setValue(variableName, variableValue);
		print("Variable " .. variableName .. " is set to: " .. MCTableToString(self:getValue(variableName)));
	else
		print("Reading variable " .. variableName .. ": " .. MCTableToString(self:getValue(variableName)));
	end
end



-----------------------------------------
-- Non Addon Specific Settings Handler --
-----------------------------------------

--- Class to handle settings that are not addon specific, e.g. showing/hiding blizzard frames
DHUDNonAddonSettingsHandler = {
	-- name of the setting that changes visibility of the player frame
	SETTING_NAME_BLIZZARD_PLAYER = "blizzardFrames_playerFrame",
	-- name of the setting that changes visibility of the target frame
	SETTING_NAME_BLIZZARD_TARGET = "blizzardFrames_targetFrame",
	-- name of the setting that changes visibility of the castbar frame
	SETTING_NAME_BLIZZARD_CASTBAR = "blizzardFrames_castingFrame",
}

-- value of the setting has changed
function DHUDNonAddonSettingsHandler:onBlizzardPlayerFrameChange(e)
	local val = DHUDSettings:getValue(self.SETTING_NAME_BLIZZARD_PLAYER);
	if (val) then
		self:showBlizzardPlayerFrame();
	else
		self:hideBlizzardPlayerFrame();
	end
end

-- value of the setting has changed
function DHUDNonAddonSettingsHandler:onBlizzardTargetFrameChange(e)
	local val = DHUDSettings:getValue(self.SETTING_NAME_BLIZZARD_TARGET);
	if (val) then
		self:showBlizzardTargetFrame();
	else
		self:hideBlizzardTargetFrame();
	end
end

-- value of the setting has changed
function DHUDNonAddonSettingsHandler:onBlizzardCastbarFrameChange(e)
	local val = DHUDSettings:getValue(self.SETTING_NAME_BLIZZARD_CASTBAR);
	if (val) then
		self:showBlizzardCastingFrame();
	else
		self:hideBlizzardCastingFrame();
	end
end

--- initialize non addon specific settings handler
function DHUDNonAddonSettingsHandler:init()
	local playerFrameVisible = DHUDSettings:getValue(self.SETTING_NAME_BLIZZARD_PLAYER);
	local targetFrameVisible = DHUDSettings:getValue(self.SETTING_NAME_BLIZZARD_TARGET);
	local castbarFrameVisible = DHUDSettings:getValue(self.SETTING_NAME_BLIZZARD_CASTBAR);
	-- listen to events
	DHUDSettings:addEventListener(DHUDSettingsEvent.EVENT_SPECIFIC_SETTING_CHANGED_PREFIX .. self.SETTING_NAME_BLIZZARD_PLAYER, self, self.onBlizzardPlayerFrameChange);
	DHUDSettings:addEventListener(DHUDSettingsEvent.EVENT_SPECIFIC_SETTING_CHANGED_PREFIX .. self.SETTING_NAME_BLIZZARD_TARGET, self, self.onBlizzardTargetFrameChange);
	DHUDSettings:addEventListener(DHUDSettingsEvent.EVENT_SPECIFIC_SETTING_CHANGED_PREFIX .. self.SETTING_NAME_BLIZZARD_CASTBAR, self, self.onBlizzardCastbarFrameChange);
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
end

--- Function to show blizzard player frame
function DHUDNonAddonSettingsHandler:showBlizzardPlayerFrame()
	PlayerFrame:RegisterEvent("UNIT_LEVEL");
    PlayerFrame:RegisterEvent("UNIT_COMBAT");
    PlayerFrame:RegisterEvent("UNIT_SPELLMISS");
    PlayerFrame:RegisterEvent("UNIT_PVP_UPDATE");
    PlayerFrame:RegisterEvent("UNIT_MAXMANA");
    PlayerFrame:RegisterEvent("PLAYER_ENTER_COMBAT");
    PlayerFrame:RegisterEvent("PLAYER_LEAVE_COMBAT");
    PlayerFrame:RegisterEvent("PLAYER_UPDATE_RESTING");
    PlayerFrame:RegisterEvent("PARTY_MEMBERS_CHANGED");
    PlayerFrame:RegisterEvent("PARTY_LEADER_CHANGED");
    PlayerFrame:RegisterEvent("PARTY_LOOT_METHOD_CHANGED");
    PlayerFrame:RegisterEvent("PLAYER_ENTERING_WORLD");
    PlayerFrame:RegisterEvent("PLAYER_REGEN_DISABLED");
    PlayerFrame:RegisterEvent("PLAYER_REGEN_ENABLED");
    PlayerFrameHealthBar:RegisterEvent("UNIT_HEALTH");
    PlayerFrameHealthBar:RegisterEvent("UNIT_MAXHEALTH");
    PlayerFrameManaBar:RegisterEvent("UNIT_POWER");
    PlayerFrameManaBar:RegisterEvent("UNIT_DISPLAYPOWER");
    PlayerFrame:RegisterEvent("UNIT_NAME_UPDATE");
    PlayerFrame:RegisterEvent("UNIT_PORTRAIT_UPDATE");
    PlayerFrame:RegisterEvent("UNIT_DISPLAYPOWER");
    PlayerFrame:Show();
	if (DHUDDataTrackers.helper.playerClass == "DEATHKNIGHT") then
		RuneFrame:Show();
	end
end

--- Function to hide blizzard player frame
function DHUDNonAddonSettingsHandler:hideBlizzardPlayerFrame()
	PlayerFrame:UnregisterEvent("UNIT_LEVEL");
	PlayerFrame:UnregisterEvent("UNIT_COMBAT");
	PlayerFrame:UnregisterEvent("UNIT_SPELLMISS");
	PlayerFrame:UnregisterEvent("UNIT_PVP_UPDATE");
	PlayerFrame:UnregisterEvent("UNIT_MAXMANA");
	PlayerFrame:UnregisterEvent("PLAYER_ENTER_COMBAT");
	PlayerFrame:UnregisterEvent("PLAYER_LEAVE_COMBAT");
	PlayerFrame:UnregisterEvent("PLAYER_UPDATE_RESTING");
	PlayerFrame:UnregisterEvent("PARTY_MEMBERS_CHANGED");
	PlayerFrame:UnregisterEvent("PARTY_LEADER_CHANGED");
	PlayerFrame:UnregisterEvent("PARTY_LOOT_METHOD_CHANGED");
	PlayerFrame:UnregisterEvent("PLAYER_ENTERING_WORLD");
	PlayerFrame:UnregisterEvent("PLAYER_REGEN_DISABLED");
	PlayerFrame:UnregisterEvent("PLAYER_REGEN_ENABLED");
	PlayerFrameHealthBar:UnregisterEvent("UNIT_HEALTH");
	PlayerFrameHealthBar:UnregisterEvent("UNIT_MAXHEALTH");
	PlayerFrameManaBar:UnregisterEvent("UNIT_POWER");
	PlayerFrameManaBar:UnregisterEvent("UNIT_DISPLAYPOWER");
	PlayerFrame:UnregisterEvent("UNIT_NAME_UPDATE");
	PlayerFrame:UnregisterEvent("UNIT_PORTRAIT_UPDATE");
	PlayerFrame:UnregisterEvent("UNIT_DISPLAYPOWER");
	PlayerFrame:Hide();
	RuneFrame:Hide();
end

--- Function to show blizzard casting frame
function DHUDNonAddonSettingsHandler:showBlizzardCastingFrame()
	CastingBarFrame:RegisterEvent("UNIT_SPELLCAST_START");
	CastingBarFrame:RegisterEvent("UNIT_SPELLCAST_STOP");
	CastingBarFrame:RegisterEvent("UNIT_SPELLCAST_FAILED");
	CastingBarFrame:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED");
	CastingBarFrame:RegisterEvent("UNIT_SPELLCAST_DELAYED");
	CastingBarFrame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START");
	CastingBarFrame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_UPDATE");
	CastingBarFrame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP");
end

--- Function to hide blizzard casting frame
function DHUDNonAddonSettingsHandler:hideBlizzardCastingFrame()
	CastingBarFrame:RegisterEvent("UNIT_SPELLCAST_START");
	CastingBarFrame:RegisterEvent("UNIT_SPELLCAST_STOP");
	CastingBarFrame:RegisterEvent("UNIT_SPELLCAST_FAILED");
	CastingBarFrame:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED");
	CastingBarFrame:RegisterEvent("UNIT_SPELLCAST_DELAYED");
	CastingBarFrame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START");
	CastingBarFrame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_UPDATE");
	CastingBarFrame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP");
end

--- Function to show blizzard target frame
function DHUDNonAddonSettingsHandler:showBlizzardTargetFrame()
	CastingBarFrame:RegisterEvent("UNIT_SPELLCAST_START");
	CastingBarFrame:RegisterEvent("UNIT_SPELLCAST_STOP");
	CastingBarFrame:RegisterEvent("UNIT_SPELLCAST_FAILED");
	CastingBarFrame:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED");
	CastingBarFrame:RegisterEvent("UNIT_SPELLCAST_DELAYED");
	CastingBarFrame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START");
	CastingBarFrame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_UPDATE");
	CastingBarFrame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP");
end

--- Function to show blizzard target frame
function DHUDNonAddonSettingsHandler:showBlizzardTargetFrame()
	TargetFrame:RegisterEvent("PLAYER_TARGET_CHANGED");
	TargetFrame:RegisterEvent("UNIT_HEALTH");
	TargetFrame:RegisterEvent("UNIT_LEVEL");
	TargetFrame:RegisterEvent("UNIT_FACTION");
	TargetFrame:RegisterEvent("UNIT_CLASSIFICATION_CHANGED");
	TargetFrame:RegisterEvent("UNIT_AURA");
	TargetFrame:RegisterEvent("PLAYER_FLAGS_CHANGED");
	TargetFrame:RegisterEvent("PARTY_MEMBERS_CHANGED");
	TargetFrame:RegisterEvent("PLAYER_FOCUS_CHANGED");
	if (DHUDDataTrackers.helper.isTargetAvailable) then
		TargetFrame:Show();
	end
	ComboFrame:RegisterEvent("PLAYER_TARGET_CHANGED");
	ComboFrame:RegisterEvent("UNIT_COMBO_POINTS");
end

--- Function to show blizzard target frame
function DHUDNonAddonSettingsHandler:hideBlizzardTargetFrame()
	TargetFrame:UnregisterEvent("PLAYER_TARGET_CHANGED");
	TargetFrame:UnregisterEvent("UNIT_HEALTH");
	TargetFrame:UnregisterEvent("UNIT_LEVEL");
	TargetFrame:UnregisterEvent("UNIT_FACTION");
	TargetFrame:UnregisterEvent("UNIT_CLASSIFICATION_CHANGED");
	TargetFrame:UnregisterEvent("UNIT_AURA");
	TargetFrame:UnregisterEvent("PLAYER_FLAGS_CHANGED");
	TargetFrame:UnregisterEvent("PARTY_MEMBERS_CHANGED");
	TargetFrame:UnregisterEvent("PLAYER_FOCUS_CHANGED");
	TargetFrame:Hide();
	ComboFrame:UnregisterEvent("PLAYER_TARGET_CHANGED");
	ComboFrame:UnregisterEvent("UNIT_COMBO_POINTS");
	ComboFrame:Hide();
end

