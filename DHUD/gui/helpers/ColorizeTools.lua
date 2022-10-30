--[[-----------------------------------------------------------------------------------
 Original Drathals HUD (c) 2006 by Markus Inger / Drathal / Silberklinge / Silbersegen
 DHUD for WotLK and later expansions (c) 2013 by MADCAT (EU-Гордунни, Мадкат)
 (http://eu.battle.net/wow/en/character/гордунни/Мадкат/advanced)
---------------------------------------------------------------------------------------
 This file contains colors transition tools
 @author: MADCAT
-----------------------------------------------------------------------------------]]--

--------------------
-- Colorize tools --
--------------------

--- Class that contains colorize functions
DHUDColorizeTools = {
	-- hex table to be used when converting colors to numbers and back
	hexTable = { ["0"] = 0, ["1"] = 1, ["2"] = 2, ["3"] = 3, ["4"] = 4, ["5"] = 5, ["6"] = 6, ["7"] = 7, ["8"] = 8, ["9"] = 9, ["a"] = 10, ["b"] = 11,
		["c"] = 12, ["d"] = 13, ["e"] = 14, ["f"] = 15 },
	-- default color table when no other color sources are available
	colors_default = { { 1, 1, 1} },
	-- result table for getColorTableForPower function, to decrease memory allocation, do not use this variable anywhere
	colors_result = { { 1, 1, 1 } },
	-- result table for colorizePercentBetweenColors function, to decrease memory allocation, do not use this variable anywhere
	color_result = { 1, 1, 1 },
	-- colors of unit reactions in hex, this table will be converted on first use
	colors_reaction_hex = { 
		"ff0000", -- hostile
		"ffff00", -- neutral
		"55ff55", -- friendly
		"8888ff", -- friendly player that is not flagged for pvp
		"008800", -- friendly player that is flagged for pvp
		"cccccc", -- hostile, but not tapped by player
	},
	-- colors of unit reactions
	colors_reaction = { },
	-- constant for hostile reaction
	REACTION_ID_HOSTILE = 1,
	-- constant for neutral reaction
	REACTION_ID_NEUTRAL = 2,
	-- constant for friendly reaction
	REACTION_ID_FRIENDLY = 3,
	-- constant for hostile reaction
	REACTION_ID_FRIENDLY_PLAYER = 4,
	-- constant for hostile reaction
	REACTION_ID_FRIENDLY_PLAYER_PVP = 5,
	-- constant for hostile reaction
	REACTION_ID_HOSTILE_NOT_TAPPED = 6,
	-- list of colors that are specified
	colors_specified = { },
	-- constant for mana power type
	COLOR_ID_TYPE_MANA = 0,
	-- constant for rage power type
	COLOR_ID_TYPE_RAGE = 1,
	-- constant for focus power type
	COLOR_ID_TYPE_FOCUS = 2,
	-- constant for energy power type
	COLOR_ID_TYPE_ENERGY = 3,
	-- constant for runicpower power type
	COLOR_ID_TYPE_RUNIC_POWER = 6,
	-- constant for eclipse power type
	COLOR_ID_TYPE_LUNAR_POWER = 8,
	-- constant for maelstorm power type
	COLOR_ID_TYPE_MAELSTROM = 11,
	-- constant for shadow priests insanity power type
	COLOR_ID_TYPE_INSANITY = 13,
	-- constant for demon hunters fury power type
	COLOR_ID_TYPE_FURY = 17,
	-- constant for demon hunters pain power type
	COLOR_ID_TYPE_PAIN = 18,
	-- constant for custom stagger power type
	COLOR_ID_TYPE_CUSTOM_VENGEANCE = 100,
	-- constant for custom stagger power type
	COLOR_ID_TYPE_CUSTOM_STAGGER = 101,
	-- constant for health power type
	COLOR_ID_TYPE_HEALTH = 200,
	-- constant for health shield power type
	COLOR_ID_TYPE_HEALTH_SHIELD = 201,
	-- constant for health absorb power type
	COLOR_ID_TYPE_HEALTH_ABSORB = 202,
	-- constant for health incoming heal power type
	COLOR_ID_TYPE_HEALTH_INCOMINGHEAL = 203,
	-- constant for health of unit that is not tapped
	COLOR_ID_TYPE_HEALTH_NOTTAPPED = 204,
	-- constant for castbar cast colorizing
	COLOR_ID_TYPE_CASTBAR_CAST = 300,
	-- constant for castbar channel colorizing
	COLOR_ID_TYPE_CASTBAR_CHANNEL = 301,
	-- constant for castbar locked cast colorizing
	COLOR_ID_TYPE_CASTBAR_LOCKED_CAST = 303,
	-- constant for castbar locked channel colorizing
	COLOR_ID_TYPE_CASTBAR_LOCKED_CHANNEL = 304,
	-- constant for castbar interrupted state
	COLOR_ID_TYPE_CASTBAR_INTERRUPTED = 305,
	-- constant for buff colorizing
	COLOR_ID_TYPE_AURA_BUFF = 400,
	-- constant for debuff colorizing
	COLOR_ID_TYPE_AURA_DEBUFF = 401,
	-- constant for short buff colorizing
	COLOR_ID_TYPE_SHORTAURA_BUFF = 500,
	-- constant for short debuff colorizing
	COLOR_ID_TYPE_SHORTAURA_DEBUFF = 501,
	-- constant for short debuff colorizing
	COLOR_ID_TYPE_SHORTAURA_DEBUFF_MAGIC = 502,
	-- constant for short debuff colorizing
	COLOR_ID_TYPE_SHORTAURA_DEBUFF_CURSE = 503,
	-- constant for short debuff colorizing
	COLOR_ID_TYPE_SHORTAURA_DEBUFF_DISEASE = 504,
	-- constant for short debuff colorizing
	COLOR_ID_TYPE_SHORTAURA_DEBUFF_POISON = 505,
	-- constant for short aura colorizing, that was applied by player
	COLOR_ID_TYPE_SHORTAURA_APPLIED_BY_PLAYER = 506,
	-- constant for spell cooldown
	COLOR_ID_TYPE_COOLDOWN_SPELL = 600,
	-- constant for spell cooldown
	COLOR_ID_TYPE_COOLDOWN_ITEM = 601,
	-- constant for active guardians
	COLOR_ID_TYPE_GUARDIAN_ACTIVE = 700,
	-- constant for passive guardians
	COLOR_ID_TYPE_GUARDIAN_PASSIVE = 701,
	-- constant for unknown type (default white color is returned)
	COLOR_ID_TYPE_UNKNOWN = "unknown";
	-- constant for color specifing self unit
	COLOR_ID_UNIT_SELF = 0,
	-- constant for color specifing target unit
	COLOR_ID_UNIT_TARGET = 32768,
	-- constant for color specifing pet unit
	COLOR_ID_UNIT_PET = 65536,
	-- table to convert game unit id to class color unit id
	UNIT_ID_TO_COLOR_UNIT_ID = {
		["player"] = 0,
		["target"] = 32768,
		["pet"] = 65536,
	},
	-- if resource string will not exist in this table than class will query API for color
	RESOURCE_POWER_TYPE_STRINGS = {
		[0] = "MANA",
		[1] = "RAGE",
		[2] = "FOCUS",
		[3] = "ENERGY",
		[6] = "RUNIC_POWER",
		[8] = "LUNAR_POWER",
		[11] = "MAELSTROM",
		[13]	= "INSANITY",
		[17] = "FURY",
		[18] = "PAIN",
	}
}

--- Get color table for unit power specified
-- @param unitId id of the unit
-- @param unitPowerTypeId id of the power that is used by unit specified
-- @param unitPowerTypeString name of the power that is used by unit specified, it will be checked to return correct color
-- @return color table that is associated with unit specified
function DHUDColorizeTools:getColorTableForPower(unitId, unitPowerTypeId, unitPowerTypeString)
	-- return default color table when there is no unit
	if (unitId == nil) then
		return self.colors_default;
	end
	local colors;
	local unitColorId;
	if (self.RESOURCE_POWER_TYPE_STRINGS[unitPowerTypeId] == unitPowerTypeString) then
		unitColorId = self.UNIT_ID_TO_COLOR_UNIT_ID[unitId] or 0;
		colors = self.colors_specified[unitPowerTypeId + unitColorId];
	end
	--print("requestsed colors for type " .. MCTableToString(unitPowerTypeId) .. "(" .. MCTableToString(unitPowerTypeString) .. "), unit " .. MCTableToString(unitColorId) .. " is: " .. MCTableToString(colors));
	-- color found?
	if (colors ~= nil) then
		return colors;
	end
	-- if color is not specified in settings, get it from API
	local id, name, r, g, b = UnitPowerType(unitId);
	--print("Unit Power Type " .. MCTableToString({ UnitPowerType(unitId) }));
	-- cannot get color from api, return white
	if (id ~= unitPowerTypeId or r == nil) then
		r = 1;
		g = 1;
		b = 1;
	end
	-- fill and return
	self.colors_result[1][1] = r;
	self.colors_result[1][2] = g;
	self.colors_result[1][3] = b;
	return self.colors_result;
end

--- Get color table for id specified from class consts
-- @param colorId id of the color
function DHUDColorizeTools:getColorTableForId(colorId)
	local colors = self.colors_specified[colorId];
	if (colors ~= nil) then
		return colors;
	end
	return self.colors_default;
end

--- Colorize percent value according between colors
-- @param percent percent to be used when colorizing
-- @param color0 color to be used when percent is equal to 0
-- @param color1 color to be used when percent is equal to 1
-- @return resulting color rgb table
function DHUDColorizeTools:colorizePercentBetweenColors(percent, color0, color1)
	if (percent >= 1) then
		return color1;
	elseif (percent > 0) then
		self.color_result[1] = color0[1] + (color1[1] - color0[1]) * percent;
		self.color_result[2] = color0[2] + (color1[2] - color0[2]) * percent;
		self.color_result[3] = color0[3] + (color1[3] - color0[3]) * percent;
		return self.color_result;
	else
		return color0;
	end
end

--- Colorize percent value according to colorTable specified
-- @param percent percent to be used when colorizing
-- @param colorTable colorTable to use
-- @return resulting color rgb table
function DHUDColorizeTools:colorizePercentUsingTable(percent, colorTable)
	-- color table to colorize bat that can contain positive and negative numbers
	if (#colorTable == 7) then
		-- value below 0.2 percent
		if (percent <= 0.2) then
			return self:colorizePercentBetweenColors((0.2 - percent) / (0.2 - 0), colorTable[6], colorTable[7]);
		-- value below 0.35 percent
		elseif (percent <= 0.35) then
			return self:colorizePercentBetweenColors((0.35 - percent) / (0.35 - 0.2), colorTable[5], colorTable[6]);
		-- value below 0.50 percent
		elseif (percent < 0.5) then
			return self:colorizePercentBetweenColors(0, colorTable[5], colorTable[6]);
		-- value equal to 0.50 percent
		elseif (percent == 0.5) then
			return self:colorizePercentBetweenColors(1, colorTable[4], colorTable[4]);
		-- value equal to 0.65 percent
		elseif (percent <= 0.65) then
			return self:colorizePercentBetweenColors(0, colorTable[3], colorTable[2]);
		-- value equal to 0.80 percent
		elseif (percent <= 0.8) then
			return self:colorizePercentBetweenColors((percent - 0.65) / (0.8 - 0.65), colorTable[3], colorTable[2]);
		-- value below 1.0 percent, equal or greater
		else
			return self:colorizePercentBetweenColors((percent - 0.8) / (1 - 0.8), colorTable[2], colorTable[1]);
		end
	-- color table to colorize bat that can contain positive and negative numbers
	elseif (#colorTable == 3) then
		-- value below 0.3 percent
		if (percent <= 0.3) then
			return self:colorizePercentBetweenColors(0, colorTable[3], colorTable[2]);
		-- value below 0.6 percent
		elseif (percent <= 0.6) then
			return self:colorizePercentBetweenColors((percent - 0.3) / (0.6 - 0.3), colorTable[3], colorTable[2]);
		-- value below 1.0 percent, equal or greater
		else
			return self:colorizePercentBetweenColors((percent - 0.6) / (1 - 0.6), colorTable[2], colorTable[1]);
		end
	-- color table doesn't support colorizing by percent
	else
		return self:colorizePercentBetweenColors(1, colorTable[1], colorTable[1]);
	end
end

--- Colorize by level difficulty
-- @param level level of the target
-- @return resulting color rgb table
function DHUDColorizeTools:colorizeByLevelDifficulty(level)
	if level < 0 then
		level = 256;
	end
	colors = GetQuestDifficultyColor(level);
	self.color_result[1] = colors["r"];
	self.color_result[2] = colors["g"];
	self.color_result[3] = colors["b"];
	return self.color_result;
end

--- Colorize by class
-- @param class non localized class of the unit (e.g. "ROGUE")
-- @return resulting color rgb table
function DHUDColorizeTools:colorizeByClass(class)
	local colors = RAID_CLASS_COLORS[class];
	if (colors == nil) then
		return self.colors_default[1];
	end
	self.color_result[1] = colors["r"];
	self.color_result[2] = colors["g"];
	self.color_result[3] = colors["b"];
	return self.color_result;
end

--- Colorize by unit reaction (friendly/neutral/hostile)
-- @param reactionId reaction id from data trackers
-- @return resulting color rgb table
function DHUDColorizeTools:colorizeByReaction(reactionId)
	-- convert table on first use
	if (#self.colors_reaction == 0) then
		for i,v in ipairs(self.colors_reaction_hex) do
			self.colors_reaction[i] = self:hexToColor(v);
		end
	end
	-- return color from table
	local color = self.colors_reaction[reactionId];
	return color;
end

--- Colorize by spell school
-- @param school school id from data trackers
-- @return resulting color rgb table
function DHUDColorizeTools:colorizeBySpellSchool(school)
	local colors = COMBATLOG_DEFAULT_COLORS.schoolColoring[school];
	--print("colorize by school " .. MCTableToString(school) .. ", default colors " .. MCTableToString(colors));
	if (colors == nil) then
		return self.colors_default[1];
	end
	self.color_result[1] = colors["r"];
	self.color_result[2] = colors["g"];
	self.color_result[3] = colors["b"];
	return self.color_result;
end

--- Convert hex value to rgb values
-- @param hex hex string to convert
-- @return rgb color table
function DHUDColorizeTools:hexToColor(hex)
	local r  = tonumber(string.sub(hex, 1, 2), 16) / 255;
	local g  = tonumber(string.sub(hex, 3, 4), 16) / 255;
	local b  = tonumber(string.sub(hex, 5, 6), 16) / 255;
	return { r, g, b };
end

--- Convert hex value to rgb table
-- @param hex hex string to convert
-- @return rgb color table
function DHUDColorizeTools:hexToColorTable(hex)
	local r  = tonumber(string.sub(hex, 1, 2), 16) / 255;
	local g  = tonumber(string.sub(hex, 3, 4), 16) / 255;
	local b  = tonumber(string.sub(hex, 5, 6), 16) / 255;
	return { r = r, g = g, b = b, a = 1.0 };
end

-- Convert number below 16 to hex symbol
-- @param dec number to convert
-- @return hex symbol corresponding to number
function DHUDColorizeTools:getHexSymbol(dec)
	return format("%02x", dec);
end

-- Convert rgb values to hex value
-- @param colors rgb color table to conver
-- @return hex string
function DHUDColorizeTools:colorToHex(colors)
	local r = colors[1];
	local g = colors[2];
	local b = colors[3];
	r = floor(r * 255);
	g = floor(g * 255);
	b = floor(b * 255);
	return format("%02x%02x%02x", r, g, b);
end

-- Convert rgb values to colorize string
-- @param colors rgb color table to conver
-- @return colorize string
function DHUDColorizeTools:colorToColorizeString(colors)
	local r = colors[1];
	local g = colors[2];
	local b = colors[3];
	r = floor(r * 255);
	g = floor(g * 255);
	b = floor(b * 255);
	return format("|cff%02x%02x%02x", r, g, b);
end

--- Process setting value and save to local table with id specified, also track it for changes
-- @param internalId id of the internal setting
-- @param settingName name of the setting
function DHUDColorizeTools:processSetting(internalId, settingName)
	local onSettingChange = function(self, e)
		--print("settingName " .. settingName);
		local settingValue = DHUDSettings:getValue(settingName);
		local processedValue = { };
		-- iterate
		for i, v in ipairs(settingValue) do
			processedValue[i] = self:hexToColor(v);
		end
		-- save
		self.colors_specified[internalId] = processedValue;
	end
	-- listen to changes
	DHUDSettings:addEventListener(DHUDSettingsEvent.EVENT_SPECIFIC_SETTING_CHANGED_PREFIX .. settingName, self, onSettingChange);
	-- invoke setting change handler
	onSettingChange(self, nil);
end

-- Initialize color tables
function DHUDColorizeTools:init()
	-- mana
	self:processSetting(self.COLOR_ID_TYPE_MANA + self.COLOR_ID_UNIT_SELF, "colors_player_mana");
	self:processSetting(self.COLOR_ID_TYPE_MANA + self.COLOR_ID_UNIT_TARGET, "colors_target_mana");
	self:processSetting(self.COLOR_ID_TYPE_MANA + self.COLOR_ID_UNIT_PET, "colors_pet_mana");
	-- rage
	self:processSetting(self.COLOR_ID_TYPE_RAGE + self.COLOR_ID_UNIT_SELF, "colors_player_rage");
	self:processSetting(self.COLOR_ID_TYPE_RAGE + self.COLOR_ID_UNIT_TARGET, "colors_target_rage");
	-- focus
	self:processSetting(self.COLOR_ID_TYPE_FOCUS + self.COLOR_ID_UNIT_SELF, "colors_player_focus");
	self:processSetting(self.COLOR_ID_TYPE_FOCUS + self.COLOR_ID_UNIT_TARGET, "colors_target_focus");
	self:processSetting(self.COLOR_ID_TYPE_FOCUS + self.COLOR_ID_UNIT_PET, "colors_pet_focus");
	-- energy
	self:processSetting(self.COLOR_ID_TYPE_ENERGY + self.COLOR_ID_UNIT_SELF, "colors_player_energy");
	self:processSetting(self.COLOR_ID_TYPE_ENERGY + self.COLOR_ID_UNIT_TARGET, "colors_target_energy");
	self:processSetting(self.COLOR_ID_TYPE_ENERGY + self.COLOR_ID_UNIT_PET, "colors_pet_energy");
	-- runic power
	self:processSetting(self.COLOR_ID_TYPE_RUNIC_POWER + self.COLOR_ID_UNIT_SELF, "colors_player_runicPower");
	self:processSetting(self.COLOR_ID_TYPE_RUNIC_POWER + self.COLOR_ID_UNIT_TARGET, "colors_target_runicPower");
	-- lunar power/eclipse
	self:processSetting(self.COLOR_ID_TYPE_LUNAR_POWER + self.COLOR_ID_UNIT_SELF, "colors_player_eclipse");
	self:processSetting(self.COLOR_ID_TYPE_LUNAR_POWER + self.COLOR_ID_UNIT_TARGET, "colors_target_eclipse");
	-- maelstorm
	self:processSetting(self.COLOR_ID_TYPE_MAELSTROM + self.COLOR_ID_UNIT_SELF, "colors_player_maelstrom");
	self:processSetting(self.COLOR_ID_TYPE_MAELSTROM + self.COLOR_ID_UNIT_TARGET, "colors_target_maelstrom");
	-- insanity
	self:processSetting(self.COLOR_ID_TYPE_INSANITY + self.COLOR_ID_UNIT_SELF, "colors_player_insanity");
	self:processSetting(self.COLOR_ID_TYPE_INSANITY + self.COLOR_ID_UNIT_TARGET, "colors_target_insanity");
	-- fury
	self:processSetting(self.COLOR_ID_TYPE_FURY + self.COLOR_ID_UNIT_SELF, "colors_player_fury");
	self:processSetting(self.COLOR_ID_TYPE_FURY + self.COLOR_ID_UNIT_TARGET, "colors_target_fury");
	-- pain
	self:processSetting(self.COLOR_ID_TYPE_PAIN + self.COLOR_ID_UNIT_SELF, "colors_player_pain");
	self:processSetting(self.COLOR_ID_TYPE_PAIN + self.COLOR_ID_UNIT_TARGET, "colors_target_pain");
	-- vengeance
	self:processSetting(self.COLOR_ID_TYPE_CUSTOM_VENGEANCE + self.COLOR_ID_UNIT_SELF, "colors_player_vengeance");
	-- stagger
	self:processSetting(self.COLOR_ID_TYPE_CUSTOM_STAGGER + self.COLOR_ID_UNIT_SELF, "colors_player_stagger");
	-- health
	self:processSetting(self.COLOR_ID_TYPE_HEALTH + self.COLOR_ID_UNIT_SELF, "colors_player_health");
	self:processSetting(self.COLOR_ID_TYPE_HEALTH + self.COLOR_ID_UNIT_TARGET, "colors_target_health");
	self:processSetting(self.COLOR_ID_TYPE_HEALTH + self.COLOR_ID_UNIT_PET, "colors_pet_health");
	self:processSetting(self.COLOR_ID_TYPE_HEALTH_SHIELD + self.COLOR_ID_UNIT_SELF, "colors_player_healthShield");
	self:processSetting(self.COLOR_ID_TYPE_HEALTH_SHIELD + self.COLOR_ID_UNIT_TARGET, "colors_target_healthShield");
	self:processSetting(self.COLOR_ID_TYPE_HEALTH_SHIELD + self.COLOR_ID_UNIT_PET, "colors_pet_healthShield");
	self:processSetting(self.COLOR_ID_TYPE_HEALTH_ABSORB + self.COLOR_ID_UNIT_SELF, "colors_player_healthAbsorb");
	self:processSetting(self.COLOR_ID_TYPE_HEALTH_ABSORB + self.COLOR_ID_UNIT_TARGET, "colors_target_healthAbsorb");
	self:processSetting(self.COLOR_ID_TYPE_HEALTH_ABSORB + self.COLOR_ID_UNIT_PET, "colors_pet_healthAbsorb");
	self:processSetting(self.COLOR_ID_TYPE_HEALTH_INCOMINGHEAL + self.COLOR_ID_UNIT_SELF, "colors_player_healthHeal");
	self:processSetting(self.COLOR_ID_TYPE_HEALTH_INCOMINGHEAL + self.COLOR_ID_UNIT_TARGET, "colors_target_healthHeal");
	self:processSetting(self.COLOR_ID_TYPE_HEALTH_INCOMINGHEAL + self.COLOR_ID_UNIT_PET, "colors_pet_healthHeal");
	self:processSetting(self.COLOR_ID_TYPE_HEALTH_NOTTAPPED + self.COLOR_ID_UNIT_TARGET, "colors_target_healthNotTapped");
	-- castbar
	self:processSetting(self.COLOR_ID_TYPE_CASTBAR_CAST + self.COLOR_ID_UNIT_SELF, "colors_selfCastbar_cast");
	self:processSetting(self.COLOR_ID_TYPE_CASTBAR_CAST + self.COLOR_ID_UNIT_TARGET, "colors_targetCastbar_cast");
	self:processSetting(self.COLOR_ID_TYPE_CASTBAR_CHANNEL + self.COLOR_ID_UNIT_SELF, "colors_selfCastbar_channel");
	self:processSetting(self.COLOR_ID_TYPE_CASTBAR_CHANNEL + self.COLOR_ID_UNIT_TARGET, "colors_targetCastbar_channel");
	self:processSetting(self.COLOR_ID_TYPE_CASTBAR_LOCKED_CAST + self.COLOR_ID_UNIT_SELF, "colors_selfCastbar_lockedCast");
	self:processSetting(self.COLOR_ID_TYPE_CASTBAR_LOCKED_CAST + self.COLOR_ID_UNIT_TARGET, "colors_targetCastbar_lockedCast");
	self:processSetting(self.COLOR_ID_TYPE_CASTBAR_LOCKED_CHANNEL + self.COLOR_ID_UNIT_SELF, "colors_selfCastbar_lockedChannel");
	self:processSetting(self.COLOR_ID_TYPE_CASTBAR_LOCKED_CHANNEL + self.COLOR_ID_UNIT_TARGET, "colors_targetCastbar_lockedChannel");
	self:processSetting(self.COLOR_ID_TYPE_CASTBAR_INTERRUPTED + self.COLOR_ID_UNIT_SELF, "colors_selfCastbar_interrupted");
	self:processSetting(self.COLOR_ID_TYPE_CASTBAR_INTERRUPTED + self.COLOR_ID_UNIT_TARGET, "colors_targetCastbar_interrupted");
	-- auras
	self:processSetting(self.COLOR_ID_TYPE_AURA_BUFF + self.COLOR_ID_UNIT_SELF, "colors_selfAuras_buff");
	self:processSetting(self.COLOR_ID_TYPE_AURA_BUFF + self.COLOR_ID_UNIT_TARGET, "colors_targetAuras_buff");
	self:processSetting(self.COLOR_ID_TYPE_AURA_DEBUFF + self.COLOR_ID_UNIT_SELF, "colors_selfAuras_debuff");
	self:processSetting(self.COLOR_ID_TYPE_AURA_DEBUFF + self.COLOR_ID_UNIT_TARGET, "colors_targetAuras_debuff");
	-- short auras
	self:processSetting(self.COLOR_ID_TYPE_SHORTAURA_BUFF + self.COLOR_ID_UNIT_SELF, "colors_selfShortAuras_buff");
	self:processSetting(self.COLOR_ID_TYPE_SHORTAURA_BUFF + self.COLOR_ID_UNIT_TARGET, "colors_targetShortAuras_buff");
	self:processSetting(self.COLOR_ID_TYPE_SHORTAURA_DEBUFF + self.COLOR_ID_UNIT_SELF, "colors_selfShortAuras_debuff");
	self:processSetting(self.COLOR_ID_TYPE_SHORTAURA_DEBUFF + self.COLOR_ID_UNIT_TARGET, "colors_targetShortAuras_debuff");
	self:processSetting(self.COLOR_ID_TYPE_SHORTAURA_DEBUFF_MAGIC + self.COLOR_ID_UNIT_SELF, "colors_selfShortAuras_debuffMagic");
	self:processSetting(self.COLOR_ID_TYPE_SHORTAURA_DEBUFF_CURSE + self.COLOR_ID_UNIT_SELF, "colors_selfShortAuras_debuffCurse");
	self:processSetting(self.COLOR_ID_TYPE_SHORTAURA_DEBUFF_DISEASE + self.COLOR_ID_UNIT_SELF, "colors_selfShortAuras_debuffDisease");
	self:processSetting(self.COLOR_ID_TYPE_SHORTAURA_DEBUFF_POISON + self.COLOR_ID_UNIT_SELF, "colors_selfShortAuras_debuffPoison");
	self:processSetting(self.COLOR_ID_TYPE_SHORTAURA_APPLIED_BY_PLAYER + self.COLOR_ID_UNIT_TARGET, "colors_targetShortAuras_appliedByPlayer");
	-- cooldowns
	self:processSetting(self.COLOR_ID_TYPE_COOLDOWN_SPELL + self.COLOR_ID_UNIT_SELF, "colors_selfCooldowns_spell");
	self:processSetting(self.COLOR_ID_TYPE_COOLDOWN_ITEM + self.COLOR_ID_UNIT_SELF, "colors_selfCooldowns_item");
	-- guardians
	self:processSetting(self.COLOR_ID_TYPE_GUARDIAN_PASSIVE + self.COLOR_ID_UNIT_SELF, "colors_selfGuardians_passive");
	self:processSetting(self.COLOR_ID_TYPE_GUARDIAN_ACTIVE + self.COLOR_ID_UNIT_SELF, "colors_selfGuardians_active");
	--print(DHUDSettings:printSettingTableToString("colors", self.colors_specified));
end
