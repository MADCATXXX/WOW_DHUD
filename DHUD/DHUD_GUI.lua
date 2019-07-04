--[[-----------------------------------------------------------------------------------
 Original Drathals HUD (c) 2006 by Markus Inger / Drathal / Silberklinge / Silbersegen
 DHUD for WotLK and later expansions (c) 2013 by MADCAT (EU-Гордунни, Мадкат)
 (http://eu.battle.net/wow/en/character/гордунни/Мадкат/advanced)
---------------------------------------------------------------------------------------
 This file contains graphical user interface: frames, functions to help positioning the
 frames, text formatting and so on
 @author: MADCAT
-----------------------------------------------------------------------------------]]--

------------------
-- Ellipse Math --
------------------

--- Class to make calculation on ellipses, required to position elements around hud such as buffs, debuffs, cooldowns, combo-points
DHUDEllipseMath = {
	-- cache table to increase calculation speed of same conditions
	cache		= {
		-- table with angles
		angleStep  = { },
		-- table with numFit
		numFit		= { },
		-- table with arc heights
		arcHeight	= { },
		-- table with begin angles
		angleBegin	= { },
	},
	-- radius of circle that is used to define width of ellipse
	radiusX		= 0,
	-- radius of circle that is used to define height of ellipse
	radiusY		= 0,
	-- angle from horizontal line to the end of hud image, addon specific, since arc is cut at angle, this value will change on ellipse rescale
	angleArc	= 0,
	-- default radius in HUD texture that is used to define width of ellipse
	HUD_RADIUS_X = 336, -- can also try other values [90, 140, 200, 300, 336]
	-- default radius in HUD texture that is used to define height of ellipse
	HUD_RADIUS_Y = 336, -- can also try other values [182, 222, 262, 320, 336]
	-- amount of pixels that are part of radius, but cut from image
	HUD_RADIUS_X_OUTOFIMAGE = 280, -- can also try other values [-34, -84, 144, 244, 280]
	-- angle in degrees from horizontal line to the end of hud (-arcsin of: max y value on hud (y = 120) divided by HUD_RADIUS_Y)
	HUD_ANGLE_ARC = 20.2, -- can also try other values [41.2, 32.7, 27.3, 22.0, 20.9] * 95%
	-- width of the big bars at 0 degrees
	HUD_BAR_WIDTH = 14.5,
	-- width of the small bars at 0 degrees
	HUD_SMALLBAR_WIDTH = 12,
	--- Following comments are for drawing graph in graph software (e.g. http://www.padowan.dk/download/):
	--- Ellipse formula for graph software: x(t) = HUD_RADIUS_X * cos(t) - HUD_RADIUS_X_OUTOFIMAGE; y(t) = HUD_RADIUS_Y * sin(t);
	--- Points of HUD image (x,y) for graph software: [(35, 128-9), (50, 128-61), (56, 0), (51, 128-188), (35, 128-245)]
}

--- Sets ellipse that is represented by parameters specified
-- @param radiusX radius of circle that is used to define width of ellipse (do not set to negative or zero)
-- @param radiusY radius of circle that is used to define height of ellipse (do not set to negative or zero)
function DHUDEllipseMath:setEllipse(radiusX, radiusY)
	self.radiusX = radiusX;
	self.radiusY = radiusY;
	self:recalcAngleArc();
end

--- Recalculate angle of arc after changing ellipse radius
function DHUDEllipseMath:recalcAngleArc()
	-- formula should be readjusted manually when changing ellipse parameters
	self.angleArc = self.HUD_ANGLE_ARC + 10 * (self.radiusX - self.HUD_RADIUS_X) / self.HUD_RADIUS_X;
end

--- Scales current ellipse by the scale specified
-- @param scale scale factor to be used (do not set to negative or zero)
function DHUDEllipseMath:scaleEllipse(scale)
	self.radiusX = self.radiusX * scale;
	self.radiusY = self.radiusY * scale;
	self:recalcAngleArc();
end

--- Adjusts radius of circle that defines width of ellipse, it will also scale radiusY accordingly
-- @param offset amount to be added to current radiusX
function DHUDEllipseMath:adjustRadiusX(offset)
	local newRadiusX = self.radiusX + offset;
	if (newRadiusX <= 0) then
		newRadiusX = self.radiusX;
	end
	local scale = newRadiusX / self.radiusX;
	self:scaleEllipse(scale);
end

--- Adjusts radius of circle that defines height of ellipse, it will also scale radiusX accordingly
-- @param offset amount to be added to current radiusY
function DHUDEllipseMath:adjustRadiusY(offset)
	local newRadiusY = self.radiusY + offset;
	if (newRadiusY <= 0) then
		newRadiusY = self.radiusY;
	end
	local scale = newRadiusY / self.radiusY;
	self:scaleEllipse(scale);
end

--- Sets default ellipse that is represented by HUD texture, ellipse will be set to represent figure between two big bars on HUD texture
function DHUDEllipseMath:setDefaultEllipse()
	self:setEllipse(self.HUD_RADIUS_X, self.HUD_RADIUS_Y);
end

--- Calculate perimeter of current ellipse
-- @return perimeter of current ellipse
function DHUDEllipseMath:calculatePerimeter()
	local pi = math.pi;
	local a = self.radiusX;
	local b = self.radiusY;
	self.perimeter = 4 * (pi * a * b + (a - b) * (a - b)) / (a + b);
	return self.perimeter;
end

--- Calculate radius average of current ellipse
-- @return radius average of current ellipse
function DHUDEllipseMath:calculateRadiusAverage()
	local x, y = self:calculatePosition(self.angleArc * 0.666);
	self.radiusAverage = sqrt(x * x + y * y);
	return self.radiusAverage;
end

--- Calculate position at angle specified in current ellipse
-- @param angleDeg angle at which position is required, standard coordinate system
-- @return position at angle specified in current ellipse, 2 values are returned: x and y
function DHUDEllipseMath:calculatePosition(angleDeg)
	local x = self.radiusX * cos(angleDeg);
	local y = self.radiusY * sin(angleDeg);
	return x, y;
end

--- Calculate position at angle specified in current ellipse, correcting position to addon coordinates
-- @param angleDeg angle at which position is required, standard coordinate system
-- @return position at angle specified in current ellipse, 2 values are returned: x and y
function DHUDEllipseMath:calculatePositionInAddonCoordinates(angleDeg)
	local x, y = self:calculatePosition(angleDeg);
	x = x - self.HUD_RADIUS_X_OUTOFIMAGE + 128;
	return floor(x), floor(y);
end

--- Calculate angle step to fit elements at current ellipse radiuses
-- @param elementRadius radius of elements that are required to fit
-- @return angle step in degrees, that should be used in calculations when using calculatePosition function (e.g. angleArc + n * angleStep)
function DHUDEllipseMath:calculateAngleStep(elementRadius)
	-- code to get value from cache
	local cacheKey = elementRadius / self.radiusY;
	local angleStep = self.cache.angleStep[cacheKey];
	if (angleStep ~= nil) then
		return angleStep;
	end
	-- radius of ellipse differs on each point, but we won't consider this (use "self:calculateRadiusAverage();" instead of "self.radiusY"?)
	-- this function considers that all of it's elements are circles, we need to recalculate arc length around this circle, it will be a bit bigger than element radius
	local tanAngleDiv4 = cacheKey / 2; -- cache key contains some of the math already
	angleStep = atan(tanAngleDiv4) * 4;
	-- commented formula doesn't consider that arc length is not equal to double radius
	--angleStep = 720.0 / (self:calculatePerimeter() / elementRadius); -- 720 because we passed radius, not diameter
	self.cache.angleStep[cacheKey] = angleStep;
	--print("radiusEllipse " .. radiusEllipse .. " elementRadius " .. elementRadius .. " angle " .. angleStep);
	return angleStep;
end

--- Calculate number of elements that can fit in arc from -angleArc to angleArc using current ellipse radiuses
-- @param elementRadius radius of elements that are required to fit
-- @return number of elements that can fit in HUD arc at current ellipse radiuses
function DHUDEllipseMath:calculateNumElementsFit(elementRadius)
	-- code to get value from cache
	local cacheKey = elementRadius / self.radiusY;
	local numFit = self.cache.numFit[cacheKey];
	if (numFit ~= nil) then
		return numFit;
	end
	-- calculate
	numFit = floor((self.angleArc * 2) / self:calculateAngleStep(elementRadius)); -- -1 + 1 due to element at start and end occuping half radius
	self.cache.numFit[cacheKey] = numFit;
	return numFit;
end

--- Calculate height of current ellipse arc
-- @return arc height
function DHUDEllipseMath:calculateArcHeight()
	-- code to get value from cache
	local cacheKey = self.radiusY;
	local arcHeight = self.cache.arcHeight[cacheKey];
	if (arcHeight ~= nil) then
		return arcHeight;
	end
	-- calculate
	arcHeight = sin(self.angleArc) * self.radiusY * 2;
	self.cache.arcHeight[cacheKey] = arcHeight;
	return arcHeight;
end

--- Calculate angle at which GUI should start placing elements
-- @param elementRadius radius of elements that are required to fit
-- @param targetArcHeight arcHeight to target or nil if need to use current
-- @param distributeSpace if true then free space will be distributed at top and bottom
-- @return angle at which GUI should start placing elements
function DHUDEllipseMath:calculateAngleBegin(elementRadius, targetArcHeight, distributeSpace)
	-- default var
	targetArcHeight = targetArcHeight or self:calculateArcHeight();
	-- code to get value from cache
	local cacheKey = elementRadius / targetArcHeight * (distributeSpace and 1 or -1);
	local angleBegin = self.cache.angleBegin[cacheKey];
	if (angleBegin ~= nil) then
		return angleBegin;
	end
	-- calculate
	local angleArcToUse = self.angleArc * targetArcHeight / self:calculateArcHeight();
	angleBegin = -angleArcToUse;
	if (distributeSpace) then
		angleBegin = angleBegin + ((angleArcToUse * 2) % self:calculateAngleStep(elementRadius)) / 2;
	end
	return angleBegin;
end

----------------
-- Text tools --
----------------

--- Class to make text changes
DHUDTextTools = {
	-- number to use as boundary to showing milliSeconds
	milliSecondsBound = 10,
	-- number of maximum allowed digits
	numberDigitsLimit = 5,
	-- list of metric prefixes from wikipedia (http://en.wikipedia.org/wiki/Metric_prefix)
	METRIC_PREFIXES = { "k", "M", "G", "T", "P", "E", "Z", "Y" },
	-- table with cached format functions
	cacheFormatToFunction = { },
}

--- setting with short numbers has changed
function DHUDTextTools:onTextShortNumbersSetting(e)
	local value = DHUDSettings:getValue("misc_textShortNumbers");
	self.numberDigitsLimit = value and 5 or 1000;
end

--- setting with milliseconds numbers has changed
function DHUDTextTools:onTextTimerMillisecondsSetting(e)
	local value = DHUDSettings:getValue("misc_textTimerShowMilliSeconds");
	self.milliSecondsBound = value and 10 or 0;
end

--- Initialize DHUDGuiSlotManager static values
function DHUDTextTools:init()
	-- listen to settings change events
	DHUDSettings:addEventListener(DHUDSettingsEvent.EVENT_SPECIFIC_SETTING_CHANGED_PREFIX .. "misc_textShortNumbers", self, self.onTextShortNumbersSetting);
	DHUDSettings:addEventListener(DHUDSettingsEvent.EVENT_SPECIFIC_SETTING_CHANGED_PREFIX .. "misc_textTimerShowMilliSeconds", self, self.onTextTimerMillisecondsSetting);
	self:onTextShortNumbersSetting(nil);
	self:onTextTimerMillisecondsSetting(nil);
end

--- Format seconds to short and readable text (in most cases this function tries to use less than 3 symbols)
-- @param secs number of seconds
-- @return short and readable text
function DHUDTextTools:formatTime(secs, millisecondsBorder)
	-- days
	if secs >= 86400 then
		return format('%dd', floor(secs / 86400 + 0.5));
	-- hours
	elseif secs >= 3600 then
		return format('%dh', floor(secs/3600 + 0.5));
	-- minutes
	elseif secs >= 99 then
		return format('%dm', floor(secs/60 + 0.5));
	-- seconds
	elseif secs >= self.milliSecondsBound then
		return format('%d', floor(secs + 0.5));
	-- milliseconds
	else
		return format('%.1f', secs);
	end
end

--- Format number to short and readable text (in most cases this function tries to use less than <limit> symbols)
-- @param number number to be shortened
-- @param limit limit of chars (maximum number of digit symbols in the result, e.g. 3, 6)
-- @param numberRef number to be used when counting number of digits or nil
-- @return short and readable text
function DHUDTextTools:formatNumber(number, limit, numberRef)
	limit = limit or self.numberDigitsLimit;
	numberRef = numberRef or number;
	local numChars = floor(log10(abs(numberRef)) + 1); -- +1 for digit below
	if (numChars <= limit) then
		return format('%d', number);
	end
	local overLimit = numChars - limit;
	local prefixToUse = floor((overLimit + 2) / 3);
	local divideBy = 10 ^ (prefixToUse * 3);
	local prefix = self.METRIC_PREFIXES[prefixToUse] or "";
	-- return formatted number
	return format('%d%s', floor(number / divideBy + 0.5), prefix);
end

--- Format number to short and readable text using number of digits after comma
-- @param number number to be shortened
-- @param precision number of digits after comma
-- @return short and readable text
function DHUDTextTools:formatNumberWithPrecision(number, precision)
	-- return formatted number
	return format('%.' .. precision .. 'f', number);
end

--- Create text that will colorize the text after it
-- @param arg any value, not readed
-- @param colorHex number corresponding to color (user can pass any value here, even table, so be sure to check it's type)
-- @return text string with color
function DHUDTextTools:createTextColorizeStart(arg, colorHex)
	colorHex = colorHex or "ffffff";
	if ("string" == type(colorHex)) then
		return "|cff" .. colorHex;
	end
	return "|cffffffff";
end

--- Create text that will colorize the text after it
-- @param arg any value, not readed
-- @param colorHex number corresponding to color
-- @return text string with color
function DHUDTextTools:createTextColorizeStop(arg)
	return "|r";
end

--- Create function for user specified number format (e.g. only mana, mana with percents, etc), better for performance then using gsub on every possible combination, all created functions are stored in cache
-- @param textFormat user defined text format, all custom values should be in braces (e.g. "<value> (<percent>)" )
-- @param mapFunctions map with functions to be executed (e.g. { "value": function(self, ref) return ref.amount; end } ), this functions will be invoked with nil self arg!
-- @param argToFunctions argument that will be passed to functions from map (e.g. reference to data tracker)
-- @return function to be executed to generate text in format specified
function DHUDTextTools:parseDataFormatToFunction(textFormat, mapFunctions, argToFunctions)
	-- lookup in cache
	local cacheForTextFormat = self.cacheFormatToFunction[textFormat];
	if (cacheForTextFormat == nil) then
		cacheForTextFormat = { };
		self.cacheFormatToFunction[textFormat] = cacheForTextFormat;
	end
	for ci, cv in ipairs(cacheForTextFormat) do
		if (cv[1] == mapFunctions and cv[2] == argToFunctions) then
			return cv[3];
		end
	end
	local cacheValue = { };
	table.insert(cacheForTextFormat, cacheValue);
	-- process
	local indexStrBegin = 1; -- index of text to substring from before "<word>"
	local indexS = 0; -- index at which "<word>" found
	local indexE = 0; -- index at which "<word>" found
	local indexLocalArgsS = 0; -- index at which "(123, 22)" found in "<word>"
	local indexLocalArgsE = 0; -- index at which "(123, 22)" found in "<word>"
	local arrayFunctions = { }; -- array for functions to execute
	local arrayResults = { }; -- array for functions results
	local subString = "";
	local specialWord = "";
	local specialArgs = nil;
	local specialFunc = nil;
	while (true) do
		indexS, indexE = strfind(textFormat, "<.->", indexE + 1); -- search for "<word>"
		-- no more special words found, end search
		if (indexS == nil) then
			subString = strsub(textFormat, indexStrBegin);
			if (#subString ~= 0) then
				table.insert(arrayFunctions, false); -- can't push nil to array
				table.insert(arrayResults, subString);
			end
			break;
		end
		-- special word found, process
		specialWord = strsub(textFormat, indexS + 1, indexE - 1);
		-- search for local function arguments
		specialArgs = nil;
		indexLocalArgsS, indexLocalArgsE = strfind(specialWord, "%(.-%)"); -- search for "(123, 22)" in "<word>"
		-- function local arguments found, process
		if (indexLocalArgsS ~= nil) then
			specialArgs = { strsplit(",", strsub(specialWord, indexLocalArgsS + 1, indexLocalArgsE - 1)) };
			specialWord = strsub(specialWord, 1, indexLocalArgsS - 1);
			--print("specialWord " .. specialWord);
			-- convert to values
			for i, v in ipairs(specialArgs) do
				local evalFunc = loadstring("return " .. v, "DHUD textField arguments");
				if (evalFunc ~= nil) then
					specialArgs[i] = evalFunc();
				end
			end
		end
		-- search function in map
		specialFunc = mapFunctions[specialWord];
		--print("specialWord: " .. specialWord .. ", func exists: " .. (specialFunc and "yes" or "no"));
		-- function found?
		if (specialFunc ~= nil) then
			-- update function if it has local arguments
			if (specialArgs ~= nil) then
				local specialFuncLocal = specialFunc;
				local specialArgsLocal = specialArgs;
				specialFunc = function(self, arg) return specialFuncLocal(self, arg, unpack(specialArgsLocal)); end
			end
			-- insert substring
			subString = strsub(textFormat, indexStrBegin, indexS - 1);
			if (#subString ~= 0) then
				table.insert(arrayFunctions, false); -- can't push nil to array
				table.insert(arrayResults, subString);
			end
			-- insert function
			table.insert(arrayFunctions, specialFunc);
			table.insert(arrayResults, "");
			-- update index of static text
			indexStrBegin = indexE + 1;
		end
	end
	-- create function, it references local vars (arrayFunctions, arrayResults, argToFunctions)
	local func = function()
		--print("arrayResults: " .. table.concat(arrayResults, ", "));
		-- iterate over functions
		for i, v in ipairs(arrayFunctions) do
			if (v) then
				arrayResults[i] = v(nil, argToFunctions);
			end
			--print("arrayResults " .. i .. " is " .. MCTableToString(arrayResults[i]));
		end
		return table.concat(arrayResults);
	end
	-- save in cache
	cacheValue[1] = mapFunctions;
	cacheValue[2] = argToFunctions;
	cacheValue[3] = func;
	return func;
end

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
	COLOR_ID_TYPE_ECLIPSE = 8,
	-- constant for burning embers power type
	COLOR_ID_TYPE_BURNING_EMBERS = 14,
	-- constant for demonic fury power type
	COLOR_ID_TYPE_DEMONIC_FURY = 15,
	-- constant for health power type
	COLOR_ID_TYPE_HEALTH = 100,
	-- constant for health shield power type
	COLOR_ID_TYPE_HEALTH_SHIELD = 101,
	-- constant for health absorb power type
	COLOR_ID_TYPE_HEALTH_ABSORB = 102,
	-- constant for health incoming heal power type
	COLOR_ID_TYPE_HEALTH_INCOMINGHEAL = 103,
	-- constant for health of unit that is not tapped
	COLOR_ID_TYPE_HEALTH_NOTTAPPED = 104,
	-- constant for castbar cast colorizing
	COLOR_ID_TYPE_CASTBAR_CAST = 200,
	-- constant for castbar channel colorizing
	COLOR_ID_TYPE_CASTBAR_CHANNEL = 201,
	-- constant for castbar locked cast colorizing
	COLOR_ID_TYPE_CASTBAR_LOCKED_CAST = 203,
	-- constant for castbar locked channel colorizing
	COLOR_ID_TYPE_CASTBAR_LOCKED_CHANNEL = 203,
	-- constant for castbar interrupted state
	COLOR_ID_TYPE_CASTBAR_INTERRUPTED = 204,
	-- constant for buff colorizing
	COLOR_ID_TYPE_AURA_BUFF = 300,
	-- constant for debuff colorizing
	COLOR_ID_TYPE_AURA_DEBUFF = 301,
	-- constant for short buff colorizing
	COLOR_ID_TYPE_SHORTAURA_BUFF = 400,
	-- constant for short debuff colorizing
	COLOR_ID_TYPE_SHORTAURA_DEBUFF = 401,
	-- constant for short debuff colorizing
	COLOR_ID_TYPE_SHORTAURA_DEBUFF_MAGIC = 402,
	-- constant for short debuff colorizing
	COLOR_ID_TYPE_SHORTAURA_DEBUFF_CURSE = 403,
	-- constant for short debuff colorizing
	COLOR_ID_TYPE_SHORTAURA_DEBUFF_DISEASE = 404,
	-- constant for short debuff colorizing
	COLOR_ID_TYPE_SHORTAURA_DEBUFF_POISON = 405,
	-- constant for short aura colorizing, that was applied by player
	COLOR_ID_TYPE_SHORTAURA_APPLIED_BY_PLAYER = 406,
	-- constant for spell cooldown
	COLOR_ID_TYPE_COOLDOWN_SPELL = 500,
	-- constant for spell cooldown
	COLOR_ID_TYPE_COOLDOWN_ITEM = 501,
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
}

--- Get color table for unit power specified
-- @param unitId id of the unit
-- @param unitPowerTypeId id of the power that is used by unit specified
-- @return color table that is associated with unit specified
function DHUDColorizeTools:getColorTableForPower(unitId, unitPowerTypeId)
	-- return default color table when there is no unit
	if (unitId == nil) then
		return self.colors_default;
	end
	local unitColorId = self.UNIT_ID_TO_COLOR_UNIT_ID[unitId] or 0;
	local colors = self.colors_specified[unitPowerTypeId + unitColorId];
	--print("requestsed colors for type " .. unitPowerTypeId .. ", unit " .. unitColorId .. " is: " .. MCTableToString(colors));
	-- color found?
	if (colors ~= nil) then
		return colors;
	end
	-- if color is not specified in settings, get it from API
	local id, name, r, g, b = UnitPowerType(unitId);
	-- cannot get color from api, return white
	if (id ~= unitPowerTypeId) then
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
	if (percent <= 0) then
		return color0;
	elseif (percent >= 1) then
		return color1;
	else
		self.color_result[1] = color0[1] + (color1[1] - color0[1]) * percent;
		self.color_result[2] = color0[2] + (color1[2] - color0[2]) * percent;
		self.color_result[3] = color0[3] + (color1[3] - color0[3]) * percent;
		return self.color_result;
	end
end

--- Colorize percent value according to colorTable specified
-- @param percent percent to be used when colorizing
-- @param colorTable colorTable to use
-- @return resulting color rgb table
function DHUDColorizeTools:colorizePercentUsingTable(percent, colorTable)
	local color0 = colorTable[1];
	-- color table doesn't support colorizing by percent
	if (#colorTable == 1) then
		return self:colorizePercentBetweenColors(1, color0, color0);
	end
	local color1 = colorTable[2];
	local color2 = colorTable[3];
	-- treshold bounds
	local threshold1 = 0.6;    
	local threshold2 = 0.3;
	-- value below 0.3 percent
	if (percent <= threshold2) then
		return self:colorizePercentBetweenColors(0, color2, color1);
	-- value below 0.6 percent
	elseif (percent <= threshold1) then
		return self:colorizePercentBetweenColors((percent - threshold2) / (threshold1 - threshold2), color2, color1);
	-- value below 1.0 percent
	elseif (percent < 1) then
		return self:colorizePercentBetweenColors((percent - threshold1) / (1 - threshold1), color1, color0);
	-- value greater or equal to 1.0
	else
		return self:colorizePercentBetweenColors(1, color1, color0);
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

--- Convert hex value to rgb values
-- @param hex hex string to convert
-- @return rgb color table
function DHUDColorizeTools:hexToColor(hex)
	local r  = tonumber(string.sub(hex, 1, 2), 16) / 255;
	local g  = tonumber(string.sub(hex, 3, 4), 16) / 255;
	local b  = tonumber(string.sub(hex, 5, 6), 16) / 255;
	return { r, g, b };
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
	-- runic power
	self:processSetting(self.COLOR_ID_TYPE_RUNIC_POWER + self.COLOR_ID_UNIT_SELF, "colors_player_runicPower");
	self:processSetting(self.COLOR_ID_TYPE_RUNIC_POWER + self.COLOR_ID_UNIT_TARGET, "colors_target_runicPower");
	-- eclipse
	self:processSetting(self.COLOR_ID_TYPE_ECLIPSE + self.COLOR_ID_UNIT_SELF, "colors_player_eclipse");
	-- burning embers
	self:processSetting(self.COLOR_ID_TYPE_BURNING_EMBERS + self.COLOR_ID_UNIT_SELF, "colors_player_burningEmbers");
	-- demonic fury
	self:processSetting(self.COLOR_ID_TYPE_DEMONIC_FURY + self.COLOR_ID_UNIT_SELF, "colors_player_demonicFury");
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
	--print(DHUDSettings:printSettingTableToString("colors", self.colors_specified));
end

------------------------------
-- GUI Bar animation helper --
------------------------------

--- Class to help resize bars and process it's animations
DHUDGUIBarAnimationHelper = MCCreateClass{
	-- group with frames that will autocreate frames if required
	group				= nil,
	-- reference to colorize function
	colorizeFunction	= nil,
	-- reference to colorize function "self" variable
	colorizeFunctionSelf = nil,
	-- time left to animate
	isAnimating			= false,
	-- information about clipping of the bar, table contains following info: { pixelsHeight, pixelsFromTop, pixelsFromBottom, pixelsFromTopPercent, pixelsFromBottomPercent, pixelsRealHeightPercent, textureX1, textureX2, parentFrame, relativePointThis, relativePointParent, offsetX, offsetY }
	clippingInformation = nil,
	-- table with current value type ids, each value is list with following data: { valueType, valuePriority }, where valueType - unique id that will also be used when colorizing
	stateValuesInfo		= { },
	-- current state of frames, required for animation
	stateCurrentAnimation = { },
	-- total height of bars that is significant for colorizing at the current state of animation
	significantHeightCurrentAnimation = 1,
	-- required state at the end of animation
	stateEndAnimation	= { },
	-- total height of bars that is significant for colorizing at the end of animation
	significantHeightEndAnimation	= 1,
	-- table with expired value types, where key - is type priority, and value is true
	expiredValuePriorities	= { },
	-- time at which bar animator was updated
	timeUpdatedAt		= 0,
	-- defines if bars should be animated
	STATIC_animate		= true,
	-- height percent change over 1 second divided by 1000 for fast animation speed
	ANIMATION_SPEED_FAST = 1.2 * 10 / 1000,
	-- height percent change over 1 second divided by 1000 for slow animation speed
	ANIMATION_SPEED_SLOW = 0.3 * 10 / 1000,
}

--- animation settings has changed, process
function DHUDGUIBarAnimationHelper:STATIC_onAnimateSetting(e)
	self.STATIC_animate = DHUDSettings:getValue("misc_animateBars");
end

--- Initialize DHUDGUIBarAnimationHelper class
function DHUDGUIBarAnimationHelper:STATIC_init()
	DHUDSettings:addEventListener(DHUDSettingsEvent.EVENT_SPECIFIC_SETTING_CHANGED_PREFIX .. "misc_animateBars", self, self.STATIC_onAnimateSetting);
	self:STATIC_onAnimateSetting(nil);
end

--- Create new bar animation helper
-- @param group reference to group with frames
-- @param clippingId id of the clipping information from class consts
-- @param positionId id of the position information from class consts
function DHUDGUIBarAnimationHelper:new(group, clippingId, positionId)
	local o = self:defconstructor();
	o:constructor(group, clippingId, positionId);
	return o;
end

--- Construct bar animation helper
-- @param group reference to group with frames
-- @param clippingId id of the clipping information table from class consts
-- @param positionId id of the position information from class consts
function DHUDGUIBarAnimationHelper:constructor(group, clippingId, positionId)
	self.group = group;
	self.stateValuesInfo = {};
	self.stateCurrentAnimation = {};
	self.stateEndAnimation = {};
	self.expiredValuePriorities = {};
	-- fill information for clipping
	local clipInfo = DHUDGUI.clipping[clippingId];
	local textureInfo = DHUDGUI.textures[clippingId];
	local positionInfo = DHUDGUI.positions[positionId];
	self.clippingInformation = { };
	self.clippingInformation[1] = clipInfo[1];
	self.clippingInformation[2] = clipInfo[2];
	self.clippingInformation[3] = clipInfo[3];
	self.clippingInformation[4] = clipInfo[2] / clipInfo[1]; -- pixelsFromTopPercent
	self.clippingInformation[5] = clipInfo[3] / clipInfo[1]; -- pixelsFromBottomPercent
	self.clippingInformation[6] = (clipInfo[1] - clipInfo[2] - clipInfo[3]) / clipInfo[1]; -- pixelsRealHeightPercent
	if (positionId == "leftBars") then
		self.clippingInformation[7] = textureInfo[2]; -- texture1
		self.clippingInformation[8] = textureInfo[3]; -- texture2
	else
		self.clippingInformation[7] = textureInfo[3]; -- texture1
		self.clippingInformation[8] = textureInfo[2]; -- texture2
	end
	self.clippingInformation[9] = _G[positionInfo[1]]; -- parentFrame
	self.clippingInformation[10] = positionInfo[2]; -- relativePointThis
	self.clippingInformation[11] = positionInfo[3]; -- relativePointParent
	self.clippingInformation[12] = positionInfo[4]; -- offsetX
	self.clippingInformation[13] = positionInfo[5]; -- offsetY
end

--- Initialize bar animation helper
-- @param colorizeFunction function that will be used to colorize bars
-- @param colorizeFunctionSelf reference to colorize function "self" variable
function DHUDGUIBarAnimationHelper:init(colorizeFunction, colorizeFunctionSelf)
	self.colorizeFunction = colorizeFunction;
	self.colorizeFunctionSelf = colorizeFunctionSelf;
	-- listen to game updates
	DHUDDataTrackers.helper:addEventListener(DHUDDataTrackerHelperEvent.EVENT_UPDATE_FREQUENT, self, self.onUpdateTime);
end

--- set framesShown variable, updating visibility of frames in the process
function DHUDGUIBarAnimationHelper:setFramesShown(framesShown)
	self.group:setFramesShown(framesShown);
end

--- Internal use function only, updates height and color of bar frames
-- @param index index of frame to update
-- @param heightBegin height to start from
-- @param heightEnd height to end on
-- @param colors color of bar
function DHUDGUIBarAnimationHelper:updateBarHeightAndColor(index, heightBegin, heightEnd, colors)
	-- get texture
	local texture = self.group[index].texture;
	-- read clipping info
	local pixelsHeight = self.clippingInformation[1];
	local pixelsFromTopPercent = self.clippingInformation[4];
	local pixelsFromBottomPercent = self.clippingInformation[5];
	local pixelsRealHeightPercent = self.clippingInformation[6];
	local textureX1 = self.clippingInformation[7];
	local textureX2 = self.clippingInformation[8];
	local parentFrame = self.clippingInformation[9];

	-- calculate height
	local textureHeight = pixelsRealHeightPercent * pixelsHeight * (heightEnd - heightBegin);
	if (textureHeight <= 0) then -- zero height will cause ui to malfunction
		textureHeight = 0.01;
	end

	-- calculate texture position
	local textureTop = 1 - pixelsFromTopPercent - (pixelsRealHeightPercent * (1 - heightEnd));
	local textureBottom = pixelsFromBottomPercent + (pixelsRealHeightPercent * heightBegin);
	local offsetY = pixelsHeight * textureBottom;
	-- update texture
	--print("textureHeight " .. textureHeight);
	texture:SetHeight(textureHeight);
	texture:SetTexCoord(textureX1, textureX2, 1 - textureTop, 1 - textureBottom);
	texture:SetPoint("BOTTOM", parentFrame, "BOTTOM", 0, offsetY);
	-- colorize
	texture:SetVertexColor(colors[1], colors[2], colors[3]);
end

--- Update bar with values
-- @param valuesInfo array with values ids, each value is list with following data: { valueType, valuePriority }, where valueType - unique id that will also be used when colorizing
-- @param valuesHeight array with values heights
-- @param heightSignificant total height of bars that is significant for colorizing
function DHUDGUIBarAnimationHelper:updateBar(valuesInfo, valuesHeight, heightSignificant)
	-- check if value ids has changed?
	local valuesInfoChanged = (#valuesInfo ~= #self.stateValuesInfo) or (#self.expiredValuePriorities > 0);
	if (not valuesInfoChanged) then
		for i, v in ipairs(valuesInfo) do
			if (v ~= self.stateValuesInfo[i]) then
				valuesInfoChanged = true;
				break;
			end
		end
	end
	-- update valuesInfo, remove unused, add new
	if (valuesInfoChanged) then
		local key;
		local insert = {};
		local remove = {};
		-- check values to be removed or changed
		for i, v in ipairs(self.stateValuesInfo) do
			key = MCFindSubValueInTable(valuesInfo, 2, v[2]);
			-- value found, rewrite (e.g. same priority but different type)
			if (key ~= nil) then
				self.stateValuesInfo[i] = valuesInfo[key];
			-- value not found
			else
				-- add only non expired timers
				if (self.expiredValuePriorities[v[2]] == nil) then
					table.insert(remove, v);
				end
			end
		end
		-- check for values to be added
		for i, v in ipairs(valuesInfo) do
			key = MCFindSubValueInTable(self.stateValuesInfo, 2, v[2]);
			-- value not found?
			if (key == nil) then
				table.insert(insert, v);
			end
		end
		-- check for expired values
		for i, v in pairs(self.expiredValuePriorities) do
			key = MCFindSubValueInTable(valuesInfo, 2, i);
			if (key ~= nil) then
				self.expiredValuePriorities[i] = nil;
			end
		end
		-- process remove, all values should be saved in expired table
		for i, v in ipairs(remove) do
			self.expiredValuePriorities[v[2]] = true;
		end
		-- insert any new values
		for i, v in ipairs(insert) do
			local inserted = false;
			for i2, v2 in ipairs(self.stateValuesInfo) do
				-- priority is lower? insert
				if (v[2] < v2[2]) then
					table.insert(self.stateValuesInfo, i2, v);
					table.insert(self.stateCurrentAnimation, i2, 0);
					table.insert(self.stateEndAnimation, i2, 0);
					inserted = true;
					break;
				end
			end
			-- not inserted?
			if (not inserted) then
				table.insert(self.stateValuesInfo, v);
				table.insert(self.stateCurrentAnimation, 0);
				table.insert(self.stateEndAnimation, 0);
			end
		end
	end
	-- update heights
	if (valuesInfoChanged) then
		local key;
		-- update values
		for i, v in ipairs (self.stateValuesInfo) do
			key = MCFindValueInTable(valuesInfo, v);
			if (key ~= nil) then
				self.stateEndAnimation[i] = valuesHeight[key];
			else
				self.stateEndAnimation[i] = 0;
			end
		end
	-- value type are the same, just copy
	else
		for i, v in ipairs(valuesHeight) do
			self.stateEndAnimation[i] = v;
		end
	end
	-- update significant height
	self.significantHeightEndAnimation = heightSignificant;
	-- update timeUpdatedAt
	self.timeUpdatedAt = DHUDDataTrackers.helper.timerMs - 1;
	-- animate
	self.isAnimating = true;
	-- update on timer
	self:onUpdateTime(nil);
end

--- Set bar visibility to false and end any pending animations
function DHUDGUIBarAnimationHelper:hideBar()
	-- stop animation
	self.isAnimating = false;
	-- set visibility to 0
	self:setFramesShown(0);
end

--- time ticked since requesting instant animation
function DHUDGUIBarAnimationHelper:onUpdateTimeInstantAnimation(e)
	-- restore static var
	self.STATIC_animate = nil;
	-- remove listenet
	DHUDDataTrackers.helper:removeEventListener(DHUDDataTrackerHelperEvent.EVENT_UPDATE_FREQUENT, self, self.onUpdateTimeInstantAnimation);
end

--- Forces bar animation to finish for current values
function DHUDGUIBarAnimationHelper:forceInstantAnimation()
	if (self.STATIC_animate == false) then
		return;
	end
	-- rewrite static var
	self.STATIC_animate = false;
	-- update if required
	self:onUpdateTime(nil);
	-- force all animations for one tick to be instant
	DHUDDataTrackers.helper:addEventListener(DHUDDataTrackerHelperEvent.EVENT_UPDATE_FREQUENT, self, self.onUpdateTimeInstantAnimation);
end

--- Time updated, update bars
function DHUDGUIBarAnimationHelper:onUpdateTime(e)
	-- no need in updating?
	if (self.isAnimating ~= true) then
		return;
	end
	local timerMs = DHUDDataTrackers.helper.timerMs;
	local timeDiff = timerMs - self.timeUpdatedAt;
	-- animation turned off?
	if (self.STATIC_animate ~= true) then
		timeDiff = 10000; -- set time passed to 10 seconds, it's enough to finish any animation
	end
	-- update steps
	local stepFast = self.ANIMATION_SPEED_FAST * timeDiff;
	local stepSlow = self.ANIMATION_SPEED_SLOW * timeDiff;
	-- update each value
	local diff;
	local height;
	-- iterate
	for i, v in ipairs(self.stateEndAnimation) do
		height = self.stateCurrentAnimation[i];
		diff = v - height;
		-- value is greater?
		if (diff >= 0) then
			-- fast speed
			if (diff > 0.1) then
				height = height + stepFast;
			-- slow speed
			else
				height = height + stepSlow;
			end
			-- can't go over result
			if (height > v) then
				height = v;
			end
		else
			-- fast speed
			if (diff < -0.1) then
				height = height - stepFast;
			-- slow speed
			else
				height = height - stepSlow;
			end
			-- can't go over result
			if (height < v) then
				height = v;
			end
		end
		-- save
		self.stateCurrentAnimation[i] = height;
	end
	-- update significant height, same formula as usual heights
	diff = self.significantHeightEndAnimation - self.significantHeightCurrentAnimation;
	if (diff ~= 0) then
		if (diff >= 0) then
			if (diff > 0.1) then
				self.significantHeightCurrentAnimation = self.significantHeightCurrentAnimation + stepFast;
			else
				self.significantHeightCurrentAnimation = self.significantHeightCurrentAnimation + stepSlow;
			end
			if (self.significantHeightCurrentAnimation > self.significantHeightEndAnimation) then
				self.significantHeightCurrentAnimation = self.significantHeightEndAnimation;
			end
		else
			if (diff < -0.1) then
				self.significantHeightCurrentAnimation = self.significantHeightCurrentAnimation - stepFast;
			else
				self.significantHeightCurrentAnimation = self.significantHeightCurrentAnimation - stepSlow;
			end
			if (self.significantHeightCurrentAnimation < self.significantHeightEndAnimation) then
				self.significantHeightCurrentAnimation = self.significantHeightEndAnimation;
			end
		end
	end
	-- check if we have ended animation
	self.isAnimating = false;
	for i, v in ipairs(self.stateEndAnimation) do
		if (v ~= self.stateCurrentAnimation[i]) then
			self.isAnimating = true;
			break;
		end
	end
	-- remove expired value types
	for i, v in pairs(self.expiredValuePriorities) do
		local key = MCFindSubValueInTable(self.stateValuesInfo, 2, i);
		if (self.stateCurrentAnimation[key] == self.stateEndAnimation[key]) then
			table.remove(self.stateValuesInfo, key);
			table.remove(self.stateCurrentAnimation, key);
			table.remove(self.stateEndAnimation, key);
			self.expiredValuePriorities[i] = nil;
		end
	end
	-- update to current state
	self:updateToCurrentState();
end

--- Update bars according to current state table
function DHUDGUIBarAnimationHelper:updateToCurrentState()
	--print("update to current state " .. table.concat(self.stateCurrentAnimation, ", "));
	-- calculate num visible
	local numVisible = 0;
	for i, v in ipairs(self.stateCurrentAnimation) do
		numVisible = numVisible + ((v ~= 0) and 1 or 0);
	end
	-- set num visible
	self:setFramesShown(numVisible);
	-- calculate height and update
	local index = 1;
	local heightBegin = 0;
	local heightEnd = 0;
	-- iterate
	for i, v in ipairs(self.stateCurrentAnimation) do
		if (v ~= 0) then
			heightEnd = heightBegin + v;
			if (heightEnd > 1.0) then
				heightEnd = 1.0;
			end
			--print("update bar " .. self.stateValuesInfo[i][1]);
			self:updateBarHeightAndColor(index, heightBegin, heightEnd, self.colorizeFunction(self.colorizeFunctionSelf, self.stateValuesInfo[i][1], v / self.significantHeightCurrentAnimation));
			heightBegin = heightEnd;
			index = index + 1;
		end
	end
end

-----------------------------------
-- GUI Cast Bar animation helper --
-----------------------------------

--- Class to help resize cast bars and process it's animations
DHUDGUICastBarAnimationHelper = MCCreateClass{
	-- group with cast bar frames that will autocreate frames if required
	group				= nil,
	-- reference to colorize function
	colorizeFunction	= nil,
	-- reference to get value function
	getValueFunction	= nil,
	-- reference to colorize ang get value function "self" variable
	functionsSelfVar = nil,
	-- time left to animate
	isAnimating			= false,
	-- information about clipping of the bar, table contains following info: { pixelsHeight, pixelsFromTop, pixelsFromBottom, pixelsFromTopPercent, pixelsFromBottomPercent, pixelsRealHeightPercent, textureX1, textureX2, parentFrame, relativePointThis, relativePointParent, offsetX, offsetY }
	clippingInformation = nil,
	-- total cast bar time value
	valueTotal = 0,
	-- time at which cast bar animator was updated
	timeUpdatedAt		= 0,
	-- time to hold animation, nil if none
	animateHold			= nil,
	-- alpha of fade animation, nil if none
	animateFade			= nil,
	-- alpha of flash animation, nil if none
	animateFlash		= nil,
	-- defines if bars should be animated
	STATIC_reverseCastingBar = false,
	-- alpha step for fade out animation
	CASTING_BAR_ALPHA_STEP = 0.05, -- same as global
	-- alpha step for flash animation
	CASTING_BAR_FLASH_STEP = 0.2, -- same as global
	-- alpha step for hold animation
	CASTING_BAR_HOLD_TIME = 1, -- same as global
}

--- animation settings has changed, process
function DHUDGUICastBarAnimationHelper:STATIC_onReverseCastBarSetting(e)
	self.STATIC_reverseCastingBar = DHUDSettings:getValue("misc_reverseCastingBars");
end

--- Initialize DHUDGUIBarAnimationHelper class
function DHUDGUICastBarAnimationHelper:STATIC_init()
	DHUDSettings:addEventListener(DHUDSettingsEvent.EVENT_SPECIFIC_SETTING_CHANGED_PREFIX .. "misc_reverseCastingBars", self, self.STATIC_onReverseCastBarSetting);
	self:STATIC_onReverseCastBarSetting(nil);
end

--- Create new cast bar animation helper
-- @param group reference to group with frames
-- @param clippingId id of the clipping information from class consts
-- @param positionId id of the position information from class consts
function DHUDGUICastBarAnimationHelper:new(group, clippingId, positionId)
	local o = self:defconstructor();
	o:constructor(group, clippingId, positionId);
	return o;
end

--- Construct cast bar animation helper
-- @param group reference to group with frames
-- @param clippingId id of the clipping information table from class consts
-- @param positionId id of the position information from class consts
function DHUDGUICastBarAnimationHelper:constructor(group, clippingId, positionId)
	self.group = group;
	-- fill information for clipping
	local clipInfo = DHUDGUI.clipping[clippingId];
	local textureInfo = DHUDGUI.textures[clippingId];
	local positionInfo = DHUDGUI.positions[positionId];
	self.clippingInformation = { };
	self.clippingInformation[1] = clipInfo[1];
	self.clippingInformation[2] = clipInfo[2];
	self.clippingInformation[3] = clipInfo[3];
	self.clippingInformation[4] = clipInfo[2] / clipInfo[1]; -- pixelsFromTopPercent
	self.clippingInformation[5] = clipInfo[3] / clipInfo[1]; -- pixelsFromBottomPercent
	self.clippingInformation[6] = (clipInfo[1] - clipInfo[2] - clipInfo[3]) / clipInfo[1]; -- pixelsRealHeightPercent
	if (positionId == "leftCastBars") then
		self.clippingInformation[7] = textureInfo[2]; -- texture1
		self.clippingInformation[8] = textureInfo[3]; -- texture2
	else
		self.clippingInformation[7] = textureInfo[3]; -- texture1
		self.clippingInformation[8] = textureInfo[2]; -- texture2
	end
	self.clippingInformation[9] = _G[positionInfo[1]]; -- parentFrame
	self.clippingInformation[10] = positionInfo[2]; -- relativePointThis
	self.clippingInformation[11] = positionInfo[3]; -- relativePointParent
	self.clippingInformation[12] = positionInfo[4]; -- offsetX
	self.clippingInformation[13] = positionInfo[5]; -- offsetY
end

--- Initialize cast bar animation helper
-- @param colorizeFunction function that will be used to colorize bars
-- @param getValueFunction function that will be used during animation to get current height
-- @param functionsSelfVar reference to colorize and get value function "self" variable
function DHUDGUICastBarAnimationHelper:init(colorizeFunction, getValueFunction, functionsSelfVar)
	self.colorizeFunction = colorizeFunction;
	self.getValueFunction = getValueFunction;
	self.functionsSelfVar = functionsSelfVar;
	-- listen to game updates
	DHUDDataTrackers.helper:addEventListener(DHUDDataTrackerHelperEvent.EVENT_UPDATE_FREQUENT, self, self.onUpdateTime);
end

--- Internal use function only, updates height and color of cast bar frames
-- @param heightEnd height of cast bar
-- @param colors color of cast bar
function DHUDGUICastBarAnimationHelper:updateCastBarHeightAndColor(heightEnd, colors)
	-- get texture
	local texture = self.group[DHUDGUI.CASTBAR_GROUP_INDEX_CAST_INDICATION].texture;
	-- read clipping info
	local pixelsHeight = self.clippingInformation[1];
	local pixelsFromTopPercent = self.clippingInformation[4];
	local pixelsFromBottomPercent = self.clippingInformation[5];
	local pixelsRealHeightPercent = self.clippingInformation[6];
	local textureX1 = self.clippingInformation[7];
	local textureX2 = self.clippingInformation[8];
	local parentFrame = self.clippingInformation[9];

	-- calculate height
	local textureHeight = pixelsRealHeightPercent * pixelsHeight * heightEnd;
	if (textureHeight <= 0) then -- zero height will cause ui to malfunction
		textureHeight = 0.01;
	end

	-- calculate texture position
	local textureTop = 1 - pixelsFromTopPercent - (pixelsRealHeightPercent * (1 - heightEnd));
	local textureBottom = pixelsFromBottomPercent;
	local offsetY = pixelsHeight * textureBottom;
	-- update texture
	texture:SetHeight(textureHeight);
	texture:SetTexCoord(textureX1, textureX2, 1 - textureTop, 1 - textureBottom);
	texture:SetPoint("BOTTOM", parentFrame, "BOTTOM", 0, offsetY);
	--print("textureHeight " .. textureHeight .. ", offsetY " .. offsetY .. ", x0 " .. textureX1 .. ", x1 " .. textureX2 .. ", y0 " .. (1 - textureTop) .. ", y1 " .. (1 - textureBottom));
	-- colorize
	texture:SetVertexColor(colors[1], colors[2], colors[3]);
end

--- Update bar with values
-- @param valueTotal total cast time, current cast time is requested by other function
function DHUDGUICastBarAnimationHelper:startCastBarAnimation(valueTotal)
	-- save vars
	self.valueTotal = valueTotal;
	-- show required frames
	self.group[DHUDGUI.CASTBAR_GROUP_INDEX_CAST_INDICATION]:DShow();
	self.group[DHUDGUI.CASTBAR_GROUP_INDEX_FLASH]:DHide();
	self.group[DHUDGUI.CASTBAR_GROUP_INDEX_ICON]:DShow();
	self.group[DHUDGUI.CASTBAR_GROUP_INDEX_SPELLNAME]:DShow();
	self.group[DHUDGUI.CASTBAR_GROUP_INDEX_CASTTIME]:DShow();
	self.group[DHUDGUI.CASTBAR_GROUP_INDEX_DELAY]:DShow();
	-- update alpha to 1
	for i = 1, DHUDGUI.CASTBAR_GROUP_NUM_FRAMES, 1 do
		self.group[i]:SetAlpha(1);
	end
	-- update timeUpdatedAt
	self.timeUpdatedAt = DHUDDataTrackers.helper.timerMs - 1;
	-- animate
	self.isAnimating = true;
	self.animateHold = nil;
	self.animateFade = nil;
	self.animateFlash = nil;
	-- update on timer
	self:onUpdateTime(nil);
end

--- Set bar visibility to false and end any pending animations
function DHUDGUICastBarAnimationHelper:hideCastBar()
	-- hide frames
	for i = 1, DHUDGUI.CASTBAR_GROUP_NUM_FRAMES, 1 do
		self.group[i]:DHide();
	end
	-- stop animation
	self.isAnimating = false;
	self.animateHold = nil;
	self.animateFade = nil;
	self.animateFlash = nil;
end

--- Change animation to hold and fade out
function DHUDGUICastBarAnimationHelper:holdAndFadeOut()
	if (not self.isAnimating) then
		return;
	end
	-- stop cast animation
	self.isAnimating = false;
	-- update cast bar
	self:updateCastBarHeightAndColor(1, self.colorizeFunction(self.functionsSelfVar, 1));
	-- add hold and fade out animation
	self.animateHold = self.CASTING_BAR_HOLD_TIME;
	self.animateFade = 1;
end

--- Change animation to flash and fade out
function DHUDGUICastBarAnimationHelper:flashAndFadeOut()
	if (not self.isAnimating) then
		return;
	end
	-- stop cast animation
	self.isAnimating = false;
	-- update cast bar
	self:updateCastBarHeightAndColor(1, self.colorizeFunction(self.functionsSelfVar, 1));
	-- show flash bar
	self.group[DHUDGUI.CASTBAR_GROUP_INDEX_FLASH]:DShow();
	self.group[DHUDGUI.CASTBAR_GROUP_INDEX_FLASH]:SetAlpha(0);
	-- add hold and fade out animation
	self.animateFlash = 0;
	self.animateFade = 1;
end

--- Time updated, update bars
function DHUDGUICastBarAnimationHelper:onUpdateTime(e)
	local timerMs = DHUDDataTrackers.helper.timerMs;
	local timeDiff = timerMs - self.timeUpdatedAt;
	if (timeDiff <= 0) then
		return;
	end
	-- update cast bar height
	if (self.isAnimating == true) then
		local heightPercent = self.getValueFunction(self.functionsSelfVar) / self.valueTotal;
		if (heightPercent > 1) then
			heightPercent = 1;
		elseif (heightPercent < 0) then
			heightPercent = 0;
		end
		local heightPercentDisplay = self.STATIC_reverseCastingBar and (1 - heightPercent) or heightPercent;
		self:updateCastBarHeightAndColor(heightPercentDisplay, self.colorizeFunction(self.functionsSelfVar, heightPercent));
	end
	-- update additional animations
	if (self.animateHold ~= nil) then
		self.animateHold = self.animateHold - timerMs;
		-- check for animation stop
		if (self.animateHold <= 0) then
			self.animateHold = nil;
		end
	elseif (self.animateFlash ~= nil) then
		self.animateFlash = self.animateFlash + self.CASTING_BAR_FLASH_STEP;
		self.group[DHUDGUI.CASTBAR_GROUP_INDEX_FLASH]:SetAlpha(self.animateFlash);
		-- check for animation stop
		if (self.animateFlash >= 1) then
			self.animateFlash = nil;
		end
	elseif (self.animateFade ~= nil) then
		self.animateFade = self.animateFade - self.CASTING_BAR_ALPHA_STEP;
		-- update alpha
		for i = 1, DHUDGUI.CASTBAR_GROUP_NUM_FRAMES, 1 do
			self.group[i]:SetAlpha(self.animateFade);
		end
		-- check for animation stop
		if (self.animateFade <= 0) then
			self.animateFade = nil;
			self:hideCastBar();
		end
	end
end

---------
-- GUI --
---------

--- Class to create and change graphical user interface
DHUDGUI = {
	-- current bar texture
	barsTexture	= 2,
	-- list with information about textures
	textures = {
		-- path to background with 0 big bars and 0 small
		["BackgroundBars0B0S"] = {"Interface\\AddOns\\DHUD\\layout\\bg_0", 0, 1, 0, 1 },
		-- path to background with 1 big inner bar and 0 small
		["BackgroundBars1BI0S"] = {"Interface\\AddOns\\DHUD\\layout\\bg_1", 0, 1, 0, 1 },
		-- path to background with 1 big inner bar and 1 small inner
		["BackgroundBars1BI1SI"] = {"Interface\\AddOns\\DHUD\\layout\\bg_1p", 0, 1, 0, 1 },
		-- path to background with 2 big bars and 0 small
		["BackgroundBars1BO0S"] = {"Interface\\AddOns\\DHUD\\layout\\bg_2", 0, 1, 0, 1 },
		-- path to background with 2 big bars and 0 small
		["BackgroundBars2B0S"] = {"Interface\\AddOns\\DHUD\\layout\\bg_21", 0, 1, 0, 1 },
		-- path to background with 2 big bars and 1 small inner
		["BackgroundBars2B1SI"] = {"Interface\\AddOns\\DHUD\\layout\\bg_21p", 0, 1, 0, 1 },
		-- path to background with 2 big bars and 2 small
		["BackgroundBars2B2S"] = {"Interface\\AddOns\\DHUD\\layout\\bg_21pp", 0, 1, 0, 1 },
		-- path prefix to first big bar texture
		["TexturePrefixBarB1"] = { "Interface\\AddOns\\DHUD\\layout\\1", 0, 1, 0, 1 },
		-- path prefix to second big bar texture
		["TexturePrefixBarB2"] = { "Interface\\AddOns\\DHUD\\layout\\2", 0, 1, 0, 1 },
		-- path prefix to first small bar texture
		["TexturePrefixBarS1"] = { "Interface\\AddOns\\DHUD\\layout\\p1", 0, 1, 0, 1 },
		-- path prefix to second small bar texture
		["TexturePrefixBarS2"] = { "Interface\\AddOns\\DHUD\\layout\\p2", 0, 1, 0, 1 },
		-- path to texture with inner casting bar
		["CastingBarB1"] = { "Interface\\AddOns\\DHUD\\layout\\cb", 0, 1, 0, 1 },
		-- path to texture with inner casting bar flash animation
		["CastFlashBarB1"] = { "Interface\\AddOns\\DHUD\\layout\\cbh", 0, 1, 0, 1 },
		-- path to texture with outer casting bar
		["CastingBarB2"] = { "Interface\\AddOns\\DHUD\\layout\\ecb", 0, 1, 0, 1 },
		-- path to texture with outer casting bar flash animation
		["CastFlashBarB2"] = { "Interface\\AddOns\\DHUD\\layout\\ecbh", 0, 1, 0, 1 },
		-- overlay that is drawn over spell circles
		["OverlaySpellCircle"] = { "Interface\\AddOns\\DHUD\\layout\\serenity0", 0, 1, 0, 1 },
		-- path to texture with red combo circle
		["ComboCircleRed"] = { "Interface\\AddOns\\DHUD\\layout\\c1", 0, 1, 0, 1 },
		-- path to texture with red combo circle
		["ComboCircleJadeGreen"] = { "Interface\\AddOns\\DHUD\\layout\\c2", 0, 1, 0, 1 },
		-- path to texture with red combo circle
		["ComboCircleCyan"] = { "Interface\\AddOns\\DHUD\\layout\\c3", 0, 1, 0, 1 },
		-- path to texture with red combo circle
		["ComboCircleOrange"] = { "Interface\\AddOns\\DHUD\\layout\\c4", 0, 1, 0, 1 },
		-- path to texture with red combo circle
		["ComboCircleGreen"] = { "Interface\\AddOns\\DHUD\\layout\\c5", 0, 1, 0, 1 },
		-- path to texture with red combo circle
		["ComboCirclePurple"] = { "Interface\\AddOns\\DHUD\\layout\\c6", 0, 1, 0, 1 },
		-- path to texture with golden dragon for hud
		["TargetEliteDragon"] = { "Interface\\AddOns\\DHUD\\layout\\elite", 0, 1, 0, 1 },
		-- path to texture with silver dragon for hud
		["TargetRareDragon"] = { "Interface\\AddOns\\DHUD\\layout\\rare", 0, 1, 0, 1 },
		-- blizzard cast bar icon shield (http://wowprogramming.com/BlizzArt/Interface/CastingBar/UI-CastingBar-Arena-Shield.png), icon inside is 20x20, border is 38x44
		["BlizzardCastBarIconShield"] = { "Interface\\CastingBar\\UI-CastingBar-Arena-Shield", 0.015625, 0.609375, 0.1875, 0.875 },
		-- blizzard horde pvp flag
		["BlizzardPvPHorde"] = { "Interface\\TargetingFrame\\UI-PVP-Horde", 0.6, 0, 0, 0.6 },
		-- blizzard alliance pvp flag
		["BlizzardPvPAlliance"] = { "Interface\\TargetingFrame\\UI-PVP-Alliance", 0, 0.6, 0, 0.6 },
		-- blizzard arena pvp flag
		["BlizzardPvPArena"] = { "Interface\\TargetingFrame\\UI-PVP-FFA", 0, 0.6, 0, 0.6 },
		-- blizzard raid icon with index 1
		["BlizzardRaidIcon1"] = { "Interface\\TargetingFrame\\UI-RaidTargetingIcons", 0, 0.25, 0, 0.25 },
		-- blizzard raid icon with index 2
		["BlizzardRaidIcon2"] = { "Interface\\TargetingFrame\\UI-RaidTargetingIcons", 0.25, 0.50, 0, 0.25 },
		-- blizzard raid icon with index 3
		["BlizzardRaidIcon3"] = { "Interface\\TargetingFrame\\UI-RaidTargetingIcons", 0.50, 0.75, 0, 0.25 },
		-- blizzard raid icon with index 4
		["BlizzardRaidIcon4"] = { "Interface\\TargetingFrame\\UI-RaidTargetingIcons", 0.75, 1, 0, 0.25 },
		-- blizzard raid icon with index 5
		["BlizzardRaidIcon5"] = { "Interface\\TargetingFrame\\UI-RaidTargetingIcons", 0, 0.25, 0.25, 0.50 },
		-- blizzard raid icon with index 6
		["BlizzardRaidIcon6"] = { "Interface\\TargetingFrame\\UI-RaidTargetingIcons", 0.25, 0.50, 0.25, 0.50 },
		-- blizzard raid icon with index 7
		["BlizzardRaidIcon7"] = { "Interface\\TargetingFrame\\UI-RaidTargetingIcons", 0.50, 0.75, 0.25, 0.50 },
		-- blizzard raid icon with index 8
		["BlizzardRaidIcon8"] = { "Interface\\TargetingFrame\\UI-RaidTargetingIcons", 0.75, 1, 0.25, 0.50 },
		-- blizzard resting icon
		["BlizzardPlayerResting"] = { "Interface\\CharacterFrame\\UI-StateIcon", 0.0625, 0.4475, 0.0625, 0.4375 },
		-- blizzard inCombat icon
		["BlizzardPlayerInCombat"] = { "Interface\\CharacterFrame\\UI-StateIcon", 0.5625, 0.9375, 0.0625, 0.4375 },
		-- blizzard party leaded icon
		["BlizzardPlayerLeader"] = { "Interface\\GroupFrame\\UI-Group-LeaderIcon", 0, 1, 0, 1 },
		-- blizzard party master looter icon
		["BlizzardPlayerLooter"] = { "Interface\\GroupFrame\\UI-Group-MasterLooter", 0, 1, 0, 1 },
		-- blizzard specialization role "TANK" icon (http://wowprogramming.com/BlizzArt/Interface/LFGFRAME/UI-LFG-ICON-PORTRAITROLES.png), (http://wowprogramming.com/BlizzArt/Interface/LFGFRAME/UI-LFG-ICON-ROLES.png)
		["BlizzardSpecializationRoleTank"] = { "Interface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES", 0, 0.5, 0.5, 1 },
		-- blizzard specialization role "DAMAGER" icon
		["BlizzardSpecializationRoleDamager"] = { "Interface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES", 0.5, 1, 0.5, 1 },
		-- blizzard specialization role "HEALER" icon
		["BlizzardSpecializationRoleHealer"] = { "Interface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES", 0.5, 1, 0, 0.5 },
		-- blizzard specialization role "GUIDE" icon (for party groups only)
		["BlizzardSpecializationRoleGuide"] = { "Interface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES", 0, 0.5, 0, 0.5 },
		-- blizzard death-knight rune "Blood"
		["BlizzardDeathKnightRuneBlood"] = { "Interface\\PlayerFrame\\UI-PlayerFrame-Deathknight-Blood", 0, 1, 0, 1 },
		-- blizzard death-knight rune "Frost"
		["BlizzardDeathKnightRuneFrost"] = { "Interface\\PlayerFrame\\UI-PlayerFrame-Deathknight-Frost", 0, 1, 0, 1 },
		-- blizzard death-knight rune "Unholy"
		["BlizzardDeathKnightRuneUnholy"] = { "Interface\\PlayerFrame\\UI-PlayerFrame-Deathknight-Unholy", 0, 1, 0, 1 },
		-- blizzard death-knight rune "Death"
		["BlizzardDeathKnightRuneDeath"] = { "Interface\\PlayerFrame\\UI-PlayerFrame-Deathknight-Death", 0, 1, 0, 1 },
		-- blizzard rectangle border texture
		["BlizzardOverlayRectangleBorder"] = { "Interface\\Buttons\\UI-Debuff-Border", 0, 1, 0, 1 },
	},
	-- list with fonts information
	fonts = {
		-- default font for all text fields if not specified
		["default"] = "Fonts\\FRIZQT__.TTF",
		-- font to be used for text fields that display numbers
		["numeric"] = "Interface\\AddOns\\DHUD\\layout\\Number.TTF",
	},
	-- list with clipping information about textures, required to change height correctly, each value contains following info: { pixelsHeight, pixelsFromTop, pixelsFromBottom
	clipping = {
		-- information about height of the big inner bar
		["TexturePrefixBarB1"]   = { 256, 11, 11 },
		-- information about height of the big outter bar
        ["TexturePrefixBarB2"]   = { 256, 5, 5 },
		-- information about height of the small inner bar
        ["TexturePrefixBarS1"]  = { 256, 128, 20 },
		-- information about height of the small outer bar
        ["TexturePrefixBarS2"]  = { 256, 128, 20 },
		-- information about height of inner casting bar
		["CastingBarB1"]  = { 256, 11, 11 },
		-- information about height of inner casting bar flash animation
		["CastFlashBarB1"] = { 256, 11, 11 },
		-- information about height of inner casting bar
		["CastingBarB2"]  = { 256, 5, 5 },
		-- information about height of inner casting bar flash animation
		["CastFlashBarB1"]  = { 256, 5, 5 },
	},
	-- relative information of some frames, required when changing height of bars
	positions = {
		-- left bars are positioned at the same position as background
		["leftBars"] = { "DHUD_Left_BarsBackground", "BOTTOM", "BOTTOM", 0, 0, 128, 256 },
		-- right bars are positioned at the same position as background
		["rightBars"] = { "DHUD_Right_BarsBackground", "BOTTOM", "BOTTOM", 0, 0, 128, 256 },
		-- left cast bars are positioned at the same position as background
		["leftCastBars"] = { "DHUD_Left_BarsBackground", "BOTTOM", "BOTTOM", 0, 0, 128, 256 },
		-- right cast bars are positioned at the same position as background
		["rightCastBars"] = { "DHUD_Right_BarsBackground", "BOTTOM", "BOTTOM", 0, 0, 128, 256 },
	},
	-- list with dropdown menu references, filled by createFrames function
	dropdownMenus = {
	},
	-- list with frame references, filled by createFrames function
	frames = {
	},
	-- list with frame groups, each group contain references of it's frames, filled by createFrames function
	frameGroups = {
	},
	-- current scale of hud elements, ids for this table will be generated automatically if not specified
	scale		= {
	},
	-- list with function that are required to be executed when some of the scale settings changes
	scaleNotifyList = {
	},
	-- defines scale of the hud in whole
	SCALE_MAIN	= 1,
	-- defines scale of spell circles
	SCALE_SPELL_CIRCLES	= 2,
	-- defines scale of spell rectangles
	SCALE_SPELL_RECTANGLES = 3,
	-- defines scale of the resource frames
	SCALE_RESOURCES = 4,
	-- current scale of fonts, ids for this table will be generated automatically if not specified
	fontSizes = {
	},
	-- current font outlines, ids for this table will be generated automatically if not specified
	fontOutlines = {
	},
	-- current frames alpha
	framesAlpha	= 1,
	-- frame visible due to ui logic
	FRAME_VISIBLE_REASON_UI = 1,
	-- frame visible due to being enabled in settings
	FRAME_VISIBLE_REASON_ENABLED = 2,
	-- frame visible due to alpha value greater than zero
	FRAME_VISIBLE_REASON_ALPHA = 4,
	-- frame visible due to player being alive
	FRAME_VISIBLE_REASON_ALIVE = 8,
	-- frame visible due to all visibility factors
	FRAME_VISIBLE_REASON_ALL = 15,
	-- background texture mask for left bars
	backgroundLeft = 0,
	-- background texture mask for right bars
	backgroundRight = 0,
	-- number to be passed to changeBarsBackground function if inner big bar should be shown
	BACKGROUND_BAR_BIG1 = 1,
	-- number to be passed to changeBarsBackground function if outer big bar should be shown
	BACKGROUND_BAR_BIG2 = 2,
	-- number to be passed to changeBarsBackground function if inner small bar should be shown
	BACKGROUND_BAR_SMALL1 = 4,
	-- number to be passed to changeBarsBackground function if outer small bar should be shown
	BACKGROUND_BAR_SMALL2 = 8,
	-- flags for font to change it's outline
	FONT_OUTLINES = { "", "OUTLINE", "THICKOUTLINE" },
	-- index of cast bar frame in cast bar group
	CASTBAR_GROUP_INDEX_CAST_INDICATION = 1,
	-- index of cast flash animation in cast bar group
	CASTBAR_GROUP_INDEX_FLASH = 2,
	-- index of spell icon in cast bar group
	CASTBAR_GROUP_INDEX_ICON = 3,
	-- index of spell name in cast bar group
	CASTBAR_GROUP_INDEX_SPELLNAME = 4,
	-- index of cast time in cast bar group
	CASTBAR_GROUP_INDEX_CASTTIME = 5,
	-- index of delay in cast bar group
	CASTBAR_GROUP_INDEX_DELAY = 6,
	-- number of total frames in cast bar group
	CASTBAR_GROUP_NUM_FRAMES = 6,
}

--- Draws backdrop on frame specified, good for debugging purposes
-- @param frame frame to draw backdrop on
-- @param r amount of red color
-- @param g amount of green color
-- @param b amount of blue color
-- @param a alpha of the backdrop
function DHUDGUI:drawFrameBackdrop(frame, r, g, b, a)
	frame:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", tile = true, tileSize = 32, insets = { left = 0, right = 0, top = 0, bottom = 0 }});
	if not(r) then
		r = 0; g = 0; b = 0; a = 0.2;
	end
    frame:SetBackdropColor(r, g, b, a);
end

--- Create frame with parameters specified
-- @param name name of the frame, variable with this name will be created in global namespace, it will also be used in local frames table
-- @param parentName name of the parent frame, this frame will be inserted to parent container
-- @param relativePointThis relative point of frame to be used as attach point
-- @param relativePointParent relative point of parent frame to be used as attach point
-- @param offsetX horizontal offset from attach point
-- @param offsetY vertical offset from attach point
-- @param width width of the frame
-- @param height height of the frame
-- @param frameStrata frame layer to be used (one of the following: BACKGROUND, LOW, MEDIUM, HIGH, DIALOG, FULLSCREEN, FULLSCREEN_DIALOG, TOOLTIP), BACKGROUND is default
-- @param frameType type of the frame to create, default is "Frame"
-- @return created frame
function DHUDGUI:createFrame(name, parentName, relativePointThis, relativePointParent, offsetX, offsetY, width, height, frameStrata, frameType)
	-- default layer
	frameStrata = frameStrata or "BACKGROUND";
	-- default type
	frameType = frameType or "Frame";
	local frame = CreateFrame(frameType, name, _G[parentName]);
	frame:SetPoint(relativePointThis, parentName, relativePointParent, offsetX, offsetY);
	frame:SetWidth(width);
	frame:SetHeight(height);
	frame:EnableMouse(false);
	-- update frame strata and level, if you set your frameStrata to "BACKGROUND" it will be blocked from receiving mouse events unless you set frameLevel to 1 or more
	-- Possible values are, from lowest to highest, 'higher' being layered on top of the 'lower' ones at runtime.
	frame:SetFrameStrata(frameStrata);
	--frame:SetFrameLevel(0);
	-- save to table
	self.frames[name] = frame;
	-- update show and hide functions, and set visibility according to current alpha
	frame.DShow = DHUDGUI.showFrame;
	frame.DHide = DHUDGUI.hideFrame;
	frame.visibleReason = self.FRAME_VISIBLE_REASON_ALL;
	if (self.framesAlpha <= 0) then
		frame:DHide(self.FRAME_VISIBLE_REASON_ALPHA);
	end
	-- debug
	--self:drawFrameBackdrop(frame, 0, 0, 0, 0.2);
	return frame;
end

--- Show frame with reason (do not use it manually, as it's not part of this class!)
-- @param self reference to frame!
-- @param reason reason to show
function DHUDGUI.showFrame(self, reason)
	reason = reason or DHUDGUI.FRAME_VISIBLE_REASON_UI;
	self.visibleReason = bit.bor(self.visibleReason, reason);
	if (self.visibleReason == DHUDGUI.FRAME_VISIBLE_REASON_ALL) then
		self.Show(self); -- call super
	end
end
		
--- Hide frame with reason (do not use it manually, as it's not part of this class!)
-- @param self reference to frame!
-- @param reason reason to show
function DHUDGUI.hideFrame(self, reason)
	reason = reason or DHUDGUI.FRAME_VISIBLE_REASON_UI;
	self.visibleReason = bit.band(self.visibleReason, bit.bnot(reason));
	-- frame visible reason is not DHUDGUI.FRAME_VISIBLE_REASON_ALL
	self.Hide(self); -- call super
end

-- Create texture frame with parameters specified
-- @param name name of the frame, variable with this name will be created in global namespace, it will also be used in local frames table
-- @param parentName name of the parent frame, this frame will be inserted to parent container
-- @param relativePointThis relative point of frame to be used as attach point
-- @param relativePointParent relative point of parent frame to be used as attach point
-- @param offsetX horizontal offset from attach point
-- @param offsetY vertical offset from attach point
-- @param width width of the frame
-- @param height height of the frame
-- @param textureName name of the texture from local textures table
-- @param textureMirror if true then this frame will be mirrored around vertical line
-- @param textureLayer layer to be set for texture (one of the following: BACKGROUND, BORDER, ARTWORK, OVERLAY, HIGHLIGHT), BACKGROUND is default
-- @return created frame and texture
function DHUDGUI:createTextureFrame(name, parentName, relativePointThis, relativePointParent, offsetX, offsetY, width, height, textureName, textureMirror, textureLayer)
	-- default layer
	textureLayer = textureLayer or "BACKGROUND";
	-- create frame
	local frame = self:createFrame(name, parentName, relativePointThis, relativePointParent, offsetX, offsetY, width, height);
	-- get texture path and crop info
	local path, x0, x1, y0, y1 = unpack(self.textures[textureName]);
	-- apply mirror effect if required
	if (textureMirror) then
		local xTmp = x0;
		x0 = x1;
		x1 = xTmp;
	end
	-- create texture
	local texture = frame:CreateTexture(name .. "_texture", textureLayer);
	texture:SetTexture(path);
	-- required to map texture size to frame width
	texture:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0);
	texture:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0);
	-- set coordinates
	texture:SetTexCoord(x0, x1, y0, y1); -- parameters: minX, maxX, minY, maxY
	frame.texture = texture; -- save reference to frame local variable
	texture.frame = frame; -- save reference to texture local variable
	--self:drawFrameBackdrop(frame, 0, 1, 0, 0.3);
	return frame, texture;
end

-- Create bar frame with parameters specified
-- @param name name of the frame, variable with this name will be created in global namespace, it will also be used in local frames table
-- @param parentName name of the parent frame, this frame will be inserted to parent container
-- @param relativePointThis relative point of frame to be used as attach point
-- @param relativePointParent relative point of parent frame to be used as attach point
-- @param offsetX horizontal offset from attach point
-- @param offsetY vertical offset from attach point
-- @param width width of the frame
-- @param height height of the frame
-- @param textureName name of the texture from local textures table
-- @param textureMirror if true then this frame will be mirrored around vertical line
-- @return created frame and texture
function DHUDGUI:createBarFrame(name, parentName, relativePointThis, relativePointParent, offsetX, offsetY, width, height, textureName, textureMirror)
	-- create frame
	local frame, texture = self:createTextureFrame(name, parentName, relativePointThis, relativePointParent, offsetX, offsetY, width, height, textureName, textureMirror);
	-- update texture
	texture.pathPrefix = texture:GetTexture(); -- save path prefix to texture local variable
	texture:SetTexture(texture.pathPrefix .. self.barsTexture);
	-- set points
	texture:ClearAllPoints();
	texture:SetPoint("CENTER", frame, "CENTER", 0, 0);
	--self:drawFrameBackdrop(frame, 0, 1, 0, 0.1);
	return frame, texture;
end

-- Create bar frame with parameters specified
-- @param type type of the cast bar frame
-- @param name name of the frames, variable with this name will be created in global namespace, it will also be used in local frames table
-- @param parentName name of the parent frame, this frame will be inserted to parent container
-- @param relativePointThis relative point of frame to be used as attach point
-- @param relativePointParent relative point of parent frame to be used as attach point
-- @param offsetX horizontal offset from attach point
-- @param offsetY vertical offset from attach point
-- @param width width of the frame
-- @param height height of the frame
-- @param textureName name of the texture from local textures table
-- @param textureMirror if true then this frame will be mirrored around vertical line
-- @return created frame and texture
function DHUDGUI:createCastBarFrame(name, parentName, relativePointThis, relativePointParent, offsetX, offsetY, width, height, textureName, textureMirror)
	-- create frame
	local frame, texture = self:createTextureFrame(name, parentName, relativePointThis, relativePointParent, offsetX, offsetY, width, height, textureName, textureMirror, "BORDER");
	-- set points
	texture:ClearAllPoints();
	texture:SetPoint("CENTER", frame, "CENTER", 0, 0);
	--self:drawFrameBackdrop(frame, 0, 1, 0, 0.1);
	return frame, texture;
end

-- Create bar frame with parameters specified
-- @param type type of the cast bar frame
-- @param name name of the frames, variable with this name will be created in global namespace, it will also be used in local frames table
-- @param parentName name of the parent frame, this frame will be inserted to parent container
-- @param relativePointThis relative point of frame to be used as attach point
-- @param relativePointParent relative point of parent frame to be used as attach point
-- @param offsetX horizontal offset from attach point
-- @param offsetY vertical offset from attach point
-- @param width width of the frame
-- @param height height of the frame
-- @return created frame and texture
function DHUDGUI:createCastBarIconFrame(name, parentName, relativePointThis, relativePointParent, offsetX, offsetY, width, height)
	-- create frame
	frame = self:createFrame(name, parentName, relativePointThis, relativePointParent, offsetX, offsetY, width, height, nil, "Button");
	-- create border texture
	local texturePath = unpack(self.textures["BlizzardCastBarIconShield"]); -- icon 20x20, total dimensions 38x44
	local texture = frame:CreateTexture(name .. "_border", "ARTWORK", nil, 7);
	local scaleX = width / 20;
	local scaleY = height / 20;
	texture:SetTexture(texturePath);
	texture:SetVertexColor(1.0, 1.0, 1.0);
	texture:SetPoint("TOPLEFT", frame, "TOPLEFT", -2 * scaleX, 11 * scaleY);
	texture:SetHeight(44 * scaleX);
	texture:SetWidth(38 * scaleY);
	texture:SetTexCoord(0, 1, 0, 1);
	frame.border = texture;
	-- set normal texture
	frame:SetNormalTexture("Interface\\Icons\\Ability_Druid_TravelForm");
	return frame;
end

-- Create text font string with parameters specified
-- @param frame frame for which font string is required
-- @param variableName name of the variable to be used in frame to save reference to this text field
-- @param relativePointThis relative point of font string to be used as attach point
-- @param relativePointParent relative point of frame to be used as attach point
-- @param offsetX horizontal offset from attach point
-- @param offsetY vertical offset from attach point
-- @param width width of the frame, pass nil for auto-resize
-- @param height height of the frame
-- @param alignH align to use along horizontal axis
-- @param alignV align to use along vertical axis
-- @param fontType type of the font to use in text field, default is used if not specified
-- @param fontLayer layer to be set for text (one of the following: BACKGROUND, BORDER, ARTWORK, OVERLAY, HIGHLIGHT), ARTWORK is default
-- @return created textField
function DHUDGUI:createTextFontString(frame, variableName, relativePointThis, relativePointParent, offsetX, offsetY, width, height, alignH, alignV, fontType, fontLayer)
	-- default font
	fontType = fontType or "default";
	-- default layer
	fontLayer = fontLayer or "ARTWORK";
	-- read autoresize
	local autoresize = (width == nil);
	width = width or 200;
	-- create text
	local textField = frame:CreateFontString(frame:GetName() .. "_" .. variableName, fontLayer);
	local fontName = self.fonts[fontType];
	textField:SetFont(fontName, 10, "");
	textField:SetFontObject(GameFontHighlightSmall);
	textField:SetJustifyH(alignH);
	textField:SetJustifyV(alignV);
	textField:SetWidth(width);
	textField:SetHeight(height);
	textField:SetPoint(relativePointThis, frame, relativePointParent, offsetX, offsetY);
	
	frame[variableName] = textField; -- save reference to frame local variable
	textField.frame = frame; -- save reference to textField local variable
	-- update set text function
	if (autoresize) then
		textField.DSetText = DHUDGUI.setTextToTextFrameAndUpdateWidth;
	else
		textField.DSetText = textField.SetText;
	end
	-- debug
	--textField:DSetText(frame:GetName());
	return textField;
end

-- Create text frame with parameters specified
-- @param name name of the frame, variable with this name will be created in global namespace, it will also be used in local frames table
-- @param parentName name of the parent frame, this frame will be inserted to parent container
-- @param relativePointThis relative point of frame to be used as attach point
-- @param relativePointParent relative point of parent frame to be used as attach point
-- @param offsetX horizontal offset from attach point
-- @param offsetY vertical offset from attach point
-- @param width width of the frame, pass nil for auto-resize
-- @param height height of the frame
-- @param alignH align to use along horizontal axis
-- @param alignV align to use along vertical axis
-- @param fontType type of the font to use in text field, default is used if not specified
-- @param fontLayer layer to be set for text (one of the following: BACKGROUND, BORDER, ARTWORK, OVERLAY, HIGHLIGHT), ARTWORK is default
-- @return created frame and textField
function DHUDGUI:createTextFrame(name, parentName, relativePointThis, relativePointParent, offsetX, offsetY, width, height, alignH, alignV, fontType, fontLayer)
	-- read autoresize
	local autoresize = (width == nil);
	-- create frame
	local frame = self:createFrame(name, parentName, relativePointThis, relativePointParent, offsetX, offsetY, width or 200, height);
	frame.resizeWithTextField = autoresize;
	-- create text
	local textField = self:createTextFontString(frame, "textField", "CENTER", "CENTER", 0, 0, width, height, alignH, alignV, fontType, fontLayer);
	-- debug
	--self:drawFrameBackdrop(frame, 0, 0, 1, 0.5);
	return frame, textField;
end

-- Create unit text frame with parameters specified
-- @param name name of the frame, variable with this name will be created in global namespace, it will also be used in local frames table
-- @param parentName name of the parent frame, this frame will be inserted to parent container
-- @param relativePointThis relative point of frame to be used as attach point
-- @param relativePointParent relative point of parent frame to be used as attach point
-- @param offsetX horizontal offset from attach point
-- @param offsetY vertical offset from attach point
-- @param width width of the frame, pass nil for auto-resize
-- @param height height of the frame
-- @param alignH align to use along horizontal axis
-- @param alignV align to use along vertical axis
-- @param fontType type of the font to use in text field, default is used if not specified
-- @param fontLayer layer to be set for text (one of the following: BACKGROUND, BORDER, ARTWORK, OVERLAY, HIGHLIGHT), ARTWORK is default
-- @return created frame and textField
function DHUDGUI:createUnitTextFrame(name, parentName, relativePointThis, relativePointParent, offsetX, offsetY, width, height, alignH, alignV, fontType, fontLayer)
	-- read autoresize
	local autoresize = (width == nil);
	-- create frame
	local frame = self:createFrame(name, parentName, relativePointThis, relativePointParent, offsetX, offsetY, width or 200, height, nil, "Button");
	frame.resizeWithTextField = autoresize;
	-- create text
	local textField = self:createTextFontString(frame, "textField", "CENTER", "CENTER", 0, 0, width, height, alignH, alignV, fontType, fontLayer);
	-- listen to mouse events, mouse will be enabled during runtime if target is eligable for dropdown menu
	frame:EnableMouse(false);
	frame:RegisterForClicks("RightButtonUp");
	frame:SetScript("OnClick", function(frame, arg1)
		-- toggle dropdown
		DHUDGUIManager:toggleUnitTextDropdown(frame);
	end);
	-- debug
	--self:drawFrameBackdrop(frame, 0, 0, 1, 0.5);
	return frame, textfield;
end

--- Create spell circle near bar
-- @param name name of the frame
-- @return frame created
function DHUDGUI:createSpellCircleFrame(name)
	-- create frame
	frame = self:createFrame(name, "DHUD_UIParent", "CENTER", "CENTER", 0, 0, 26, 26, nil, "Button");
	-- create border texture
	local texturePath = unpack(self.textures["OverlaySpellCircle"]);
	local texture = frame:CreateTexture(name .. "_border", "ARTWORK", nil, 7);
	texture:SetTexture(texturePath);
	texture:SetVertexColor(1.0, 1.0, 1.0);
	texture:SetPoint("TOPLEFT", frame, "TOPLEFT", -7.5, 7.5);
	texture:SetHeight(26 * 1.6);
	texture:SetWidth(26 * 1.6);
	texture:SetTexCoord(0, 1, 0, 1);
	texture:SetBlendMode("BLEND");
	frame.border = texture;
	-- set normal texture
	frame:SetNormalTexture("Interface\\Icons\\Ability_Druid_TravelForm");
	-- time left text
	local textField1 = self:createTextFontString(frame, "textFieldTime", "CENTER", "CENTER", 0, 0, 26 * 2, 26, "CENTER", "CENTER", "default", "OVERLAY");
	-- stack text
	local textField2 = self:createTextFontString(frame, "textFieldCount", "BOTTOMRIGHT", "BOTTOMRIGHT", 10, -5, 26, 26, "RIGHT", "BOTTOM", "default", "OVERLAY");
	-- enable mouse events and listen to them
	frame:EnableMouse(true);
	frame:SetScript("OnEnter", function(frame)
		GameTooltip:SetOwner(frame, "ANCHOR_BOTTOMRIGHT");
		-- update using data
		DHUDGUIManager:showSpellCircleTooltip(frame);
	end);
	frame:SetScript("OnLeave", function(frame)
		GameTooltip:Hide();
	end);
	return frame;
end

--- Create spell rectangle frame near bottom text
-- @param name name of the frame
-- @param parentName name of the parent frame, this frame will be inserted to parent container (should be bottom textField)
-- @param relativePointThis relative point of frame to be used as attach point
-- @param relativePointParent relative point of parent frame to be used as attach point
-- @return frame created
function DHUDGUI:createSpellRectangleFrame(name, parentName, relativePointThis, relativePointParent)
	-- create frame
	frame = self:createFrame(name, parentName, relativePointThis, relativePointParent, 0, 0, 20, 20, nil, "Button");
	-- create border texture
	local texturePath = unpack(self.textures["BlizzardOverlayRectangleBorder"]);
	local texture = frame:CreateTexture(name .. "_border", "ARTWORK", nil, 7);
	texture:SetTexture(texturePath);
	texture:SetVertexColor(1.0, 1.0, 1.0);
	texture:SetPoint("CENTER", frame, "CENTER", 0, 0);
	texture:SetHeight(20);
	texture:SetWidth(20);
	texture:SetTexCoord(0, 1, 0, 1);
	frame.border = texture;
	-- set normal texture
	frame:SetNormalTexture("Interface\\Icons\\Ability_Druid_TravelForm");
	-- time left text
	local textField1 = self:createTextFontString(frame, "textFieldTime", "CENTER", "CENTER", 0, 0, 20 * 2, 20, "CENTER", "CENTER", "default", "OVERLAY");
	-- stack text
	local textField2 = self:createTextFontString(frame, "textFieldCount", "BOTTOMRIGHT", "BOTTOMRIGHT", 3, -3, 20, 20, "RIGHT", "BOTTOM", "default", "OVERLAY");
	-- enable mouse events and listen to them
	frame:EnableMouse(true);
	frame:SetScript("OnEnter", function(frame)
		GameTooltip:SetOwner(frame, "ANCHOR_BOTTOMRIGHT");
		-- update using data
		DHUDGUIManager:showSpellRectangleTooltip(frame);
	end);
	frame:SetScript("OnLeave", function(frame)
		GameTooltip:Hide();
	end);
	return frame;
end

--- Create combo point frame near bar
-- @param name name of the frame
-- @return frame created
function DHUDGUI:createComboPointFrame(name)
	-- create frame
	local frame = self:createTextureFrame(name, "DHUD_UIParent", "CENTER", "CENTER", 0, 0, 20, 20, "ComboCircleRed", false);
	return frame;
end

--- Create rune frame near bar
-- @param name name of the frame
-- @return frame created
function DHUDGUI:createRuneFrame(name)
	-- create frame
	local frame, texture = self:createTextureFrame(name, "DHUD_UIParent", "CENTER", "CENTER", 0, 0, 30, 30, "BlizzardDeathKnightRuneDeath", false);
	-- create text
	local textField1 = self:createTextFontString(frame, "textFieldTime", "CENTER", "CENTER", 0, 0, 30 * 2, 30, "CENTER", "CENTER", "default", "OVERLAY");
	return frame;
end

--- Create icon frame near frame specified
-- @param name name of the frame
-- @param parentName name of the parent frame, this frame will be inserted to parent container
-- @param relativePointThis relative point of frame to be used as attach point
-- @param relativePointParent relative point of parent frame to be used as attach point
-- @param offsetX horizontal offset from attach point
-- @param offsetY vertical offset from attach point
-- @param width width of the frame
-- @param height height of the frame
-- @param textureName name of the texture from local textures table
-- @return frame created
function DHUDGUI:createIconFrame(name, parentName, relativePointThis, relativePointParent, offsetX, offsetY, width, height, textureName)
	-- create frame
	local frame, texture = self:createTextureFrame(name, parentName, relativePointThis, relativePointParent, offsetX, offsetY, width, height, textureName);
	return frame;
end

--- Create drop down menu frame with parameters specified
-- @param name name of the frame, variable with this name will be created in global namespace, it will also be used in local dropdownMenus table
-- @param onInit function that will be invoked when drop down menu is invoked, this function should call UnitPopup_ShowMenu with correct arguments
-- @return created frame
function DHUDGUI:createDropDownMenu(name, onInit)
	local frame = CreateFrame("Frame", name, UIParent, "UIDropDownMenuTemplate");
	frame:SetPoint("TOP", 0, 0);
	frame:SetWidth(160);
	frame:SetHeight(160);
	-- initialize, init function is called immediatly but it will throw error, do not invoke passed function first time
	UIDropDownMenu_Initialize(frame, function(frame)
		if (frame.inited) then
			onInit(frame);
		end
	end, "MENU");
	frame.inited = true;
	-- save to table
	self.dropdownMenus[name] = frame;
	return frame;
end

--- Initialize player dropdown list (do not use it manually, as it's not part of this class!)
-- @param frame reference to dropdown frame
function DHUDGUI.initDropDownMenuPlayer(frame)
	UnitPopup_ShowMenu(frame, "SELF", "player");
end

--- Initialize target dropdown list (do not use it manually, as it's not part of this class!)
-- @param frame reference to dropdown frame
function DHUDGUI.initDropDownMenuTarget(frame)
	local menu;
	-- check if enemy
	if (UnitIsEnemy("target", "player")) then
		menu = "TARGET";
	else
		-- check if self
		if (UnitIsUnit("target", "player")) then
			menu = "SELF";
		-- check if pet
		elseif (UnitIsUnit("target", "pet")) then
			menu = "PET";
		-- check if player
		elseif (UnitIsPlayer("target")) then
			-- check if raid player
			if (UnitInRaid("target")) then
				menu = "RAID_PLAYER";
			-- check if party player
			elseif (UnitInParty("target")) then
				menu = "PARTY";
			-- unit is friendly player
			else
				menu = "PLAYER";
			end
		else
			-- unit is other target
			menu = "TARGET";
		end
	end
	UnitPopup_ShowMenu(frame, menu, "target");
end

--- Set text to text field, updating text field width and it's frame (do not use it manually, as it's not part of this class!)
-- @param self reference to textField!
-- @param text text to set
function DHUDGUI.setTextToTextFrameAndUpdateWidth(self, text)
	-- set temprorary width to maximum
	self:SetWidth(1000);
	-- set text
	self.SetText(self, text); -- call super
	-- get real width
	local w = self:GetStringWidth();
	-- update
	self:SetWidth(w);
	if (self.frame.resizeWithTextField == true) then
		self.frame:SetWidth(w);
	end
end

--- Create group of frames and save it
-- @param groupName name of the group, it will be saved in local frameGroups table
-- @param ... list of frames in group
-- @return created frame group
function DHUDGUI:createFrameGroup(groupName, ...)
	-- save
	local group = { };
	self.frameGroups[groupName] = group;
	-- push
	self:pushFramesToGroup(group, ...);
	return group;
end

--- Push frames to group
-- @param group group, to which frames should be pushed
-- @param ... list of frames in group
function DHUDGUI:pushFramesToGroup(group, ...)
	-- get references instead of names
	local n = select("#", ...);
	for i = 1, n do
		table.insert(group, self.frames[select(i, ...)]);
	end
end

--- Create group that will fill itself automatically
-- @param groupName name of the group, it will be saved in local frameGroups table
-- @param createFrameFunction function, that will be invoked when frame doesn't exist
-- @param limit maximum number of frames to prevent situation when creating them has no point (e.g. don't need 9999 spell circles to be shown to player)
-- @param ... if not nil, than all created frames will also be pushed to groups specified
-- @return created frame group
function DHUDGUI:createDynamicFrameGroup(groupName, createFrameFunction, limit, ...)
	local group = { };
	local pushToGroups = { ... };
	-- add dynamic index function
	local dynamicIndexTable = { };
	dynamicIndexTable.__index = function(list, key)
		if (type(key) ~= "number") then
			return nil;
		end
		if (key > limit) then
			return group[limit];
		end
		local frame, onCreate = createFrameFunction(DHUDGUI, key);
		group[key] = frame;
		group.framesShown = key;
		-- check onCreate function
		if (onCreate ~= nil) then
			onCreate(DHUDGUI, frame);
		end
		-- notify group
		if (group.onDynamicFrameCreated ~= nil) then
			group.onDynamicFrameCreated(DHUDGUI, frame);
		end
		-- also add frame to another nondynamic group?
		if (#pushToGroups > 0) then
			for i, v in ipairs(pushToGroups) do
				table.insert(v, frame);
				-- notify group
				if (v.onDynamicFrameCreated ~= nil) then
					v.onDynamicFrameCreated(DHUDGUI, frame);
				end
			end
		end
		return frame;
	end
	setmetatable(group, dynamicIndexTable);
	-- add "set frames visible" function
	group.framesShown = 0;
	function group:setFramesShown(framesShown)
		if (self.framesShown == framesShown) then
			return;
		end
		-- show new frames
		for i = self.framesShown + 1, framesShown, 1 do
			self[i]:DShow();
		end
		-- hide old frames
		for i = self.framesShown, framesShown + 1, -1 do
			self[i]:DHide();
		end
		-- save var
		self.framesShown = framesShown;
	end
	-- save
	self.frameGroups[groupName] = group;
	return group;
end

--- Create group that will fill itself automatically, but frames are specific to index
-- @param groupName name of the group, it will be saved in local frameGroups table
-- @param createFrameFunction function, that will be invoked when frame doesn't exist
-- @param pushToGroupsMap if not nil, than all created frames will also be pushed to groups specified, this argument is a map with following format { index = { groupList }, index2 = { groupList2 } }
-- @return created frame group
function DHUDGUI:createDynamicFrameGroupWithCustomIndexes(groupName, createFrameFunction, pushToGroupsMap)
	local group = { };
	-- add dynamic index function
	local dynamicIndexTable = { };
	dynamicIndexTable.__index = function(list, key)
		if (type(key) ~= "number") then
			return nil;
		end
		local frame = createFrameFunction(DHUDGUI, key);
		group[key] = frame;
		-- notify group
		if (group.onDynamicFrameCreated ~= nil) then
			group.onDynamicFrameCreated(DHUDGUI, frame);
		end
		-- also add frame to another nondynamic group?
		if (pushToGroupsMap ~= nil) then
			local pushToGroups = pushToGroupsMap[key];
			if (pushToGroups ~= nil) then
				for i, v in ipairs(pushToGroups) do
					table.insert(v, frame);
					-- notify group
					if (v.onDynamicFrameCreated ~= nil) then
						v.onDynamicFrameCreated(DHUDGUI, frame);
					end
				end
			end
		end
		return frame;
	end
	setmetatable(group, dynamicIndexTable);
	-- save
	self.frameGroups[groupName] = group;
	return group;
end

--- Create left big inner bar
-- @param index index of frame
-- @return frame created
function DHUDGUI:createBarFrameBigInnerLeft(index)
	local relative = self.positions["leftBars"];
	local frame = self:createBarFrame("DHUD_Left_BarBig1_" .. index, relative[1], relative[2], relative[3], relative[4], relative[5], relative[6], relative[7], "TexturePrefixBarB1");
	return frame;
end

--- Create left big outer bar
-- @param index index of frame
-- @return frame created
function DHUDGUI:createBarFrameBigOuterLeft(index)
	local relative = self.positions["leftBars"];
	local frame = self:createBarFrame("DHUD_Left_BarBig2_" .. index, relative[1], relative[2], relative[3], relative[4], relative[5], relative[6], relative[7], "TexturePrefixBarB2");
	return frame;
end

--- Create left small inner bar
-- @param index index of frame
-- @return frame created
function DHUDGUI:createBarFrameSmallInnerLeft(index)
	local relative = self.positions["leftBars"];
	local frame = self:createBarFrame("DHUD_Left_BarSmall1_" .. index, relative[1], relative[2], relative[3], relative[4], relative[5], relative[6], relative[7], "TexturePrefixBarS1");
	return frame;
end

--- Create right big inner bar
-- @param index index of frame
-- @return frame created
function DHUDGUI:createBarFrameBigInnerRight(index)
	local relative = self.positions["rightBars"];
	local frame = self:createBarFrame("DHUD_Right_BarBig1_" .. index, relative[1], relative[2], relative[3], relative[4], relative[5], relative[6], relative[7], "TexturePrefixBarB1", true);
	return frame;
end

--- Create right bit outer bar
-- @param index index of frame
-- @return frame created
function DHUDGUI:createBarFrameBigOuterRight(index)
	local relative = self.positions["rightBars"];
	local frame = self:createBarFrame("DHUD_Right_BarBig2_" .. index, relative[1], relative[2], relative[3], relative[4], relative[5], relative[6], relative[7], "TexturePrefixBarB2", true);
	return frame;
end

--- Create right small inner bar
-- @param index index of frame
-- @return frame created
function DHUDGUI:createBarFrameSmallInnerRight(index)
	local relative = self.positions["rightBars"];
	local frame = self:createBarFrame("DHUD_Right_BarSmall1_" .. index, relative[1], relative[2], relative[3], relative[4], relative[5], relative[6], relative[7], "TexturePrefixBarS1", true);
	return frame;
end

--- Create left big inner cast bar
-- @param index index of frame
-- @return frame created
function DHUDGUI:createCastBarFrameBigInnerLeft(index)
	local relative = self.positions["leftCastBars"];
	local frame;
	if (index == self.CASTBAR_GROUP_INDEX_CAST_INDICATION) then
		frame = self:createCastBarFrame("DHUD_Left_CastBarBig1", relative[1], relative[2], relative[3], relative[4], relative[5], relative[6], relative[7], "CastingBarB1");
	elseif (index == self.CASTBAR_GROUP_INDEX_FLASH) then
		frame = self:createCastBarFrame("DHUD_Left_CastBarFlashBig1", relative[1], relative[2], relative[3], relative[4], relative[5], relative[6], relative[7], "CastFlashBarB1");
	elseif (index == self.CASTBAR_GROUP_INDEX_ICON) then
		frame = self:createCastBarIconFrame("DHUD_Left_CastBarIconBig1", "DHUD_Left_BarsBackground", "BOTTOM", "BOTTOM", 60, 275, 30, 30);
	elseif (index == self.CASTBAR_GROUP_INDEX_SPELLNAME) then
		frame = self:createTextFrame("DHUD_Left_CastBarSpellTextBig1", "DHUD_Left_BarsBackground", "LEFT", "BOTTOM", 74, 290, nil, 14, "LEFT", "CENTER");
	elseif (index == self.CASTBAR_GROUP_INDEX_CASTTIME) then
		frame = self:createTextFrame("DHUD_Left_CastBarTimeTextBig1", "DHUD_Left_BarsBackground", "LEFT", "BOTTOM", 30, 252, 100, 14, "LEFT", "CENTER");
	elseif (index == self.CASTBAR_GROUP_INDEX_DELAY) then
		frame = self:createTextFrame("DHUD_Left_CastBarDelayTextBig1", "DHUD_Left_BarsBackground", "LEFT", "BOTTOM", 30, 266, 100, 14, "LEFT", "CENTER");
	end
	return frame;
end

--- Create left big outer cast bar
-- @param index index of frame
-- @return frame created
function DHUDGUI:createCastBarFrameBigOuterLeft(index)
	local relative = self.positions["leftCastBars"];
	local frame;
	if (index == self.CASTBAR_GROUP_INDEX_CAST_INDICATION) then
		frame = self:createCastBarFrame("DHUD_Left_CastBarBig2", relative[1], relative[2], relative[3], relative[4], relative[5], relative[6], relative[7], "CastingBarB2");
	elseif (index == self.CASTBAR_GROUP_INDEX_FLASH) then
		frame = self:createCastBarFrame("DHUD_Left_CastBarFlashBig2", relative[1], relative[2], relative[3], relative[4], relative[5], relative[6], relative[7], "CastFlashBarB2");
	elseif (index == self.CASTBAR_GROUP_INDEX_ICON) then
		frame = self:createCastBarIconFrame("DHUD_Left_CastBarIconBig2", "DHUD_Left_BarsBackground", "BOTTOM", "BOTTOM", 25, 285, 30, 30);
	elseif (index == self.CASTBAR_GROUP_INDEX_SPELLNAME) then
		frame = self:createTextFrame("DHUD_Left_CastBarSpellTextBig2", "DHUD_Left_BarsBackground", "RIGHT", "BOTTOM", 10, 300, nil, 14, "RIGHT", "CENTER");
	elseif (index == self.CASTBAR_GROUP_INDEX_CASTTIME) then
		frame = self:createTextFrame("DHUD_Left_CastBarTimeTextBig2", "DHUD_Left_BarsBackground", "RIGHT", "BOTTOM", 25, 262, 100, 14, "RIGHT", "CENTER");
	elseif (index == self.CASTBAR_GROUP_INDEX_DELAY) then
		frame = self:createTextFrame("DHUD_Left_CastBarDelayTextBig2", "DHUD_Left_BarsBackground", "RIGHT", "BOTTOM", 25, 276, 100, 14, "RIGHT", "CENTER");
	end
	return frame;
end

--- Create right big inner cast bar
-- @param index index of frame
-- @return frame created
function DHUDGUI:createCastBarFrameBigInnerRight(index)
	local relative = self.positions["rightCastBars"];
	local frame;
	if (index == self.CASTBAR_GROUP_INDEX_CAST_INDICATION) then
		frame = self:createCastBarFrame("DHUD_Right_CastBarBig1", relative[1], relative[2], relative[3], relative[4], relative[5], relative[6], relative[7], "CastingBarB1", true);
	elseif (index == self.CASTBAR_GROUP_INDEX_FLASH) then
		frame = self:createCastBarFrame("DHUD_Right_CastBarFlashBig1", relative[1], relative[2], relative[3], relative[4], relative[5], relative[6], relative[7], "CastFlashBarB1", true);
	elseif (index == self.CASTBAR_GROUP_INDEX_ICON) then
		frame = self:createCastBarIconFrame("DHUD_Right_CastBarIconBig1", "DHUD_Right_BarsBackground", "BOTTOM", "BOTTOM", -60, 275, 30, 30);
	elseif (index == self.CASTBAR_GROUP_INDEX_SPELLNAME) then
		frame = self:createTextFrame("DHUD_Right_CastBarSpellTextBig1", "DHUD_Right_BarsBackground", "RIGHT", "BOTTOM", -74, 290, nil, 14, "RIGHT", "CENTER");
	elseif (index == self.CASTBAR_GROUP_INDEX_CASTTIME) then
		frame = self:createTextFrame("DHUD_Right_CastBarTimeTextBig1", "DHUD_Right_BarsBackground", "RIGHT", "BOTTOM", -30, 252, 100, 14, "RIGHT", "CENTER");
	elseif (index == self.CASTBAR_GROUP_INDEX_DELAY) then
		frame = self:createTextFrame("DHUD_Right_CastBarDelayTextBig1", "DHUD_Right_BarsBackground", "RIGHT", "BOTTOM", -30, 266, 100, 14, "RIGHT", "CENTER");
	end
	return frame;
end

--- Create right big outer cast bar
-- @param index index of frame
-- @return frame created
function DHUDGUI:createCastBarFrameBigOuterRight(index)
	local relative = self.positions["rightCastBars"];
	local frame;
	if (index == self.CASTBAR_GROUP_INDEX_CAST_INDICATION) then
		frame = self:createCastBarFrame("DHUD_Right_CastBarBig2", relative[1], relative[2], relative[3], relative[4], relative[5], relative[6], relative[7], "CastingBarB2", true);
	elseif (index == self.CASTBAR_GROUP_INDEX_FLASH) then
		frame = self:createCastBarFrame("DHUD_Right_CastBarFlashBig2", relative[1], relative[2], relative[3], relative[4], relative[5], relative[6], relative[7], "CastFlashBarB2", true);
	elseif (index == self.CASTBAR_GROUP_INDEX_ICON) then
		frame = self:createCastBarIconFrame("DHUD_Right_CastBarIconBig2", "DHUD_Right_BarsBackground", "BOTTOM", "BOTTOM", -25, 285, 30, 30);
	elseif (index == self.CASTBAR_GROUP_INDEX_SPELLNAME) then
		frame = self:createTextFrame("DHUD_Right_CastBarSpellTextBig2", "DHUD_Right_BarsBackground", "LEFT", "BOTTOM", -10, 300, nil, 14, "LEFT", "CENTER");
	elseif (index == self.CASTBAR_GROUP_INDEX_CASTTIME) then
		frame = self:createTextFrame("DHUD_Right_CastBarTimeTextBig2", "DHUD_Right_BarsBackground", "LEFT", "BOTTOM", -25, 262, 100, 14, "LEFT", "CENTER");
	elseif (index == self.CASTBAR_GROUP_INDEX_DELAY) then
		frame = self:createTextFrame("DHUD_Right_CastBarDelayTextBig2", "DHUD_Right_BarsBackground", "LEFT", "BOTTOM", -25, 276, 100, 14, "LEFT", "CENTER");
	end
	return frame;
end

--- Helper function to reduce amount of code for reposition functions
-- @param group group to reposition
-- @param frame frame to reposition if any
function DHUDGUI:repositionProcessParams(group, frame)
	local indexBegin = 1;
	local indexEnd = #group;
	if (frame ~= nil) then
		indexBegin = MCLastIndexOfValueInTable(group, frame);
		indexEnd = indexBegin;
	end
	return group, indexBegin, indexEnd;
end

--- Create unit icon near unit info text
-- @param index index of frame
-- @return frame created
function DHUDGUI:createTargetUnitInfoIconCenter(index)
	local frame = self:createIconFrame("DHUD_Icon_TargetUnitIcon" .. index, "DHUD_Center_TextInfo1", "BOTTOM", "TOP", 0, 0, 25, 25, "BlizzardRaidIcon1");
	return frame, self.repositionUnitInfoIconCenter;
end

--- Reposition unit icon near unit info text
-- @param frame reference to frame that should be repositioned, otherwise all elements are repositioned
function DHUDGUI:repositionTargetUnitInfoIconCenter(frame)
	local group = self.frameGroups.targetIcons;
	self:distributeRectangleFramesAlongWidth(group, 1,  group.framesShown, 25, 1, 0, "DHUD_Center_TextInfo1", "BOTTOM", "TOP");
end

--- Reposition unit icon near unit info text
-- @param frame reference to frame that should be repositioned, otherwise all elements are repositioned
function DHUDGUI:repositionTargetUnitInfoStateIcons(frame)
	if (position == "CENTER") then
		group.reposition = self.repositionTargetUnitInfoIconCenter();
		group.reposition(DHUDGUI);
	end
end

--- Reposition self pvp status icon near bar
-- @param position string with required position id (either "LEFT" or "RIGHT")
function DHUDGUI:repositionSelfUnitPvPIcon(position)
	local frame = self.frames["DHUD_Icon_SelfUnitIconPvP"];
	if (position == "LEFT") then
		frame:SetPoint("TOP", "DHUD_Left_BarsBackground", "TOP", 50, -15);
	elseif (position == "RIGHT") then
		frame:SetPoint("TOP", "DHUD_Right_BarsBackground", "TOP", -50, -15);
	end
end

--- Reposition self pvp status icon near bar
-- @param position string with required position id (either "LEFT" or "RIGHT")
function DHUDGUI:repositionSelfUnitStateIcon(position)
	local frame = self.frames["DHUD_Icon_SelfUnitIconState"];
	if (position == "LEFT") then
		frame:SetPoint("TOP", "DHUD_Left_BarsBackground", "TOP", 42, 12);
	elseif (position == "RIGHT") then
		frame:SetPoint("TOP", "DHUD_Right_BarsBackground", "TOP", -42, 12);
	end
end

--- Reposition self pvp status icon near bar
-- @param position string with required position id (either "LEFT" or "RIGHT")
function DHUDGUI:repositionTargetUnitEliteIcon(position)
	local frame = self.frames["DHUD_Icon_TargetEliteDragon"];
	if (position == "LEFT") then
		frame:SetPoint("TOP", "DHUD_Left_BarsBackground", "TOP", 18, 20);
		frame.texture:SetTexCoord(0, 1, 0, 1);
	elseif (position == "RIGHT") then
		frame:SetPoint("TOP", "DHUD_Right_BarsBackground", "TOP", -18, 20);
		frame.texture:SetTexCoord(1, 0, 0, 1);
	end
end

--- Create spell circle near left big bar
-- @param index index of frame
-- @return frame created
function DHUDGUI:createSpellCircleFrameBigLeft(index)
	local frame = self:createSpellCircleFrame("DHUD_Left_SpellCircleBig" .. index);
	return frame, self.repositionSpellCircleFramesBigLeft;
end

--- Reposition spell circles around left big bar
-- @param frame reference to frame that should be repositioned, otherwise all elements are repositioned
function DHUDGUI:repositionSpellCircleFramesBigLeft(frame)
	local group, indexBegin, indexEnd = self:repositionProcessParams(self.frameGroups.spellCirclesBigLeft, frame);
	self:repositionCircleFramesAroundHud(group, indexBegin, indexEnd, 16 * self.scale[self.SCALE_SPELL_CIRCLES], DHUDEllipseMath.HUD_BAR_WIDTH + 2, 0, true);
end

--- Create spell circle near right big bar
-- @param index index of frame
-- @return frame created
function DHUDGUI:createSpellCircleFrameBigRight(index)
	local frame = self:createSpellCircleFrame("DHUD_Right_SpellCircleBig" .. index);
	return frame, self.repositionSpellCircleFramesBigRight;
end

--- Reposition spell circles around right big bar
-- @param frame reference to frame that should be repositioned, otherwise all elements are repositioned
function DHUDGUI:repositionSpellCircleFramesBigRight(frame)
	local group, indexBegin, indexEnd = self:repositionProcessParams(self.frameGroups.spellCirclesBigRight, frame);
	self:repositionCircleFramesAroundHud(group, indexBegin, indexEnd, 16 * self.scale[self.SCALE_SPELL_CIRCLES], DHUDEllipseMath.HUD_BAR_WIDTH + 2, 0, false);
end

--- Create spell circle near left big bar
-- @param index index of frame
-- @return frame created
function DHUDGUI:createSpellCircleFrameSmallLeft(index)
	local frame = self:createSpellCircleFrame("DHUD_Left_SpellCircleSmall" .. index);
	return frame, self.repositionSpellCircleFramesSmallLeft;
end

--- Reposition spell circles around left small bar
-- @param frame reference to frame that should be repositioned, otherwise all elements are repositioned
function DHUDGUI:repositionSpellCircleFramesSmallLeft(frame)
	local group, indexBegin, indexEnd = self:repositionProcessParams(self.frameGroups.spellCirclesSmallLeft, frame);
	local hasSmallBar = bit.band(self.backgroundLeft, self.BACKGROUND_BAR_SMALL1) ~= 0;
	self:repositionCircleFramesAroundHud(group, indexBegin, indexEnd, 16 * self.scale[self.SCALE_SPELL_CIRCLES], -2, -DHUDEllipseMath.HUD_BAR_WIDTH - DHUDEllipseMath.HUD_SMALLBAR_WIDTH, true);
end

--- Create spell circle near right small bar
-- @param index index of frame
-- @return frame created
function DHUDGUI:createSpellCircleFrameSmallRight(index)
	local frame = self:createSpellCircleFrame("DHUD_Right_SpellCircleSmall" .. index);
	return frame, self.repositionSpellCircleFramesSmallRight;
end

--- Reposition spell circles around right small bar
-- @param frame reference to frame that should be repositioned, otherwise all elements are repositioned
function DHUDGUI:repositionSpellCircleFramesSmallRight(frame)
	local group, indexBegin, indexEnd = self:repositionProcessParams(self.frameGroups.spellCirclesSmallRight, frame);
	local hasSmallBar = bit.band(self.backgroundRight, self.BACKGROUND_BAR_SMALL1) ~= 0;
	self:repositionCircleFramesAroundHud(group, indexBegin, indexEnd, 16 * self.scale[self.SCALE_SPELL_CIRCLES], -2, -DHUDEllipseMath.HUD_BAR_WIDTH - DHUDEllipseMath.HUD_SMALLBAR_WIDTH, false);
end

--- Create left spell rectangle near bottom text
-- @param index index of frame
-- @return frame created
function DHUDGUI:createSpellRectangleFrameLeft(index)
	local frame = self:createSpellRectangleFrame("DHUD_Left_SpellRectangle" .. index, "DHUD_Center_TextInfo1", "TOPRIGHT", "TOPLEFT");
	return frame, self.repositionSpellRectangleFramesLeft;
end

--- Reposition left spell rectangles around bottom text
-- @param frame reference to frame that should be repositioned, otherwise all elements are repositioned
function DHUDGUI:repositionSpellRectangleFramesLeft(frame)
	local group, indexBegin, indexEnd = self:repositionProcessParams(self.frameGroups.spellRectanglesLeft, frame);
	self:repositionRectangleFramesAroundFrame(group, indexBegin, indexEnd, 20 * self.scale[self.SCALE_SPELL_RECTANGLES], 20 * self.scale[self.SCALE_SPELL_RECTANGLES], 8, 1, 10, true, "DHUD_Center_TextInfo1", "TOPRIGHT", "TOPLEFT");
end

--- Create left spell rectangle near bottom text
-- @param index index of frame
-- @return frame created
function DHUDGUI:createSpellRectangleFrameRight(index)
	local frame = self:createSpellRectangleFrame("DHUD_Right_SpellRectangle" .. index, "DHUD_Center_TextInfo1", "TOPLEFT", "TOPRIGHT");
	return frame, self.repositionSpellRectangleFramesRight;
end

--- Reposition left spell rectangles around bottom text
-- @param frame reference to frame that should be repositioned, otherwise all elements are repositioned
function DHUDGUI:repositionSpellRectangleFramesRight(frame)
	local group, indexBegin, indexEnd = self:repositionProcessParams(self.frameGroups.spellRectanglesRight, frame);
	self:repositionRectangleFramesAroundFrame(group, indexBegin, indexEnd, 20 * self.scale[self.SCALE_SPELL_RECTANGLES], 20 * self.scale[self.SCALE_SPELL_RECTANGLES], 8, 1, 5, false, "DHUD_Center_TextInfo1", "TOPLEFT", "TOPRIGHT");
end

--- Create combo point frame near left big bar
-- @param index index of frame
-- @return frame created
function DHUDGUI:createComboPointFrameBigLeft(index)
	local frame = self:createComboPointFrame("DHUD_Left_ComboPointBig" .. index);
	return frame, self.repositionComboPointFramesBigLeft;
end

--- Create combo point frame near left big bar
-- @param index index of frame
-- @return frame created
function DHUDGUI:repositionComboPointFramesBigLeft(frame)
	local group, indexBegin, indexEnd = self:repositionProcessParams(self.frameGroups.comboPointsBigLeft, frame);
	self:repositionCircleFramesAroundHud(group, indexBegin, indexEnd, 10 * self.scale[self.SCALE_RESOURCES], DHUDEllipseMath.HUD_BAR_WIDTH + 2, 0, true, 0);
end

--- Create combo point frame near right big bar
-- @param index index of frame
-- @return frame created
function DHUDGUI:createComboPointFrameBigRight(index)
	local frame = self:createComboPointFrame("DHUD_Right_ComboPointBig" .. index);
	return frame, self.repositionComboPointFramesBigRight;
end

--- Create combo point frame right left big bar
-- @param index index of frame
-- @return frame created
function DHUDGUI:repositionComboPointFramesBigRight(frame)
	local group, indexBegin, indexEnd = self:repositionProcessParams(self.frameGroups.comboPointsBigRight, frame);
	self:repositionCircleFramesAroundHud(group, indexBegin, indexEnd, 10 * self.scale[self.SCALE_RESOURCES], DHUDEllipseMath.HUD_BAR_WIDTH + 2, 0, false, 0);
end

--- Create combo point frame near left small bar
-- @param index index of frame
-- @return frame created
function DHUDGUI:createComboPointFrameSmallLeft(index)
	local frame = self:createComboPointFrame("DHUD_Left_ComboPointSmall" .. index);
	return frame, self.repositionComboPointFramesSmallLeft;
end

--- Create combo point frame near left small bar
-- @param index index of frame
-- @return frame created
function DHUDGUI:repositionComboPointFramesSmallLeft(frame)
	local group, indexBegin, indexEnd = self:repositionProcessParams(self.frameGroups.comboPointsSmallLeft, frame);
	local hasSmallBar = bit.band(self.backgroundLeft, self.BACKGROUND_BAR_SMALL1) ~= 0;
	self:repositionCircleFramesAroundHud(group, indexBegin, indexEnd, 10 * self.scale[self.SCALE_RESOURCES], -2, -DHUDEllipseMath.HUD_BAR_WIDTH - DHUDEllipseMath.HUD_SMALLBAR_WIDTH, true, 0);
end

--- Create combo point frame near right small bar
-- @param index index of frame
-- @return frame created
function DHUDGUI:createComboPointFrameSmallRight(index)
	local frame = self:createComboPointFrame("DHUD_Right_ComboPointSmall" .. index);
	return frame, self.repositionComboPointFramesSmallRight;
end

--- Create combo point frame near right small bar
-- @param index index of frame
-- @return frame created
function DHUDGUI:repositionComboPointFramesSmallRight(frame)
	local group, indexBegin, indexEnd = self:repositionProcessParams(self.frameGroups.comboPointsSmallRight, frame);
	local hasSmallBar = bit.band(self.backgroundRight, self.BACKGROUND_BAR_SMALL1) ~= 0;
	self:repositionCircleFramesAroundHud(group, indexBegin, indexEnd, 10 * self.scale[self.SCALE_RESOURCES], -2, -DHUDEllipseMath.HUD_BAR_WIDTH - DHUDEllipseMath.HUD_SMALLBAR_WIDTH, false, 0);
end

--- Create rune frame near left big bar
-- @param index index of frame
-- @return frame created
function DHUDGUI:createRuneFrameBigLeft(index)
	local frame = self:createRuneFrame("DHUD_Left_RuneBig" .. index);
	return frame, self.repositionRuneFramesBigLeft;
end

--- Create rune frame near left big bar
-- @param index index of frame
-- @return frame created
function DHUDGUI:repositionRuneFramesBigLeft(frame)
	local group, indexBegin, indexEnd = self:repositionProcessParams(self.frameGroups.runesBigLeft, frame);
	self:repositionCircleFramesAroundHud(group, indexBegin, indexEnd, 15 * self.scale[self.SCALE_RESOURCES], DHUDEllipseMath.HUD_BAR_WIDTH + 2, 0, true, 0);
end

--- Create rune frame near right big bar
-- @param index index of frame
-- @return frame created
function DHUDGUI:createRuneFrameBigRight(index)
	local frame = self:createRuneFrame("DHUD_Right_RuneBig" .. index);
	return frame, self.repositionRuneFramesBigRight;
end

--- Create rune frame near right big bar
-- @param index index of frame
-- @return frame created
function DHUDGUI:repositionRuneFramesBigRight(frame)
	local group, indexBegin, indexEnd = self:repositionProcessParams(self.frameGroups.runesBigRight, frame);
	self:repositionCircleFramesAroundHud(group, indexBegin, indexEnd, 15 * self.scale[self.SCALE_RESOURCES], DHUDEllipseMath.HUD_BAR_WIDTH + 2, 0, false, 0);
end

--- Create rune frame near left small bar
-- @param index index of frame
-- @return frame created
function DHUDGUI:createRuneFrameSmallLeft(index)
	local frame = self:createRuneFrame("DHUD_Left_RuneSmall" .. index);
	return frame, self.repositionRuneFramesSmallLeft;
end

--- Create rune frame near left small bar
-- @param index index of frame
-- @return frame created
function DHUDGUI:repositionRuneFramesSmallLeft(frame)
	local group, indexBegin, indexEnd = self:repositionProcessParams(self.frameGroups.runesSmallLeft, frame);
	local hasSmallBar = bit.band(self.backgroundLeft, self.BACKGROUND_BAR_SMALL1) ~= 0;
	self:repositionCircleFramesAroundHud(group, indexBegin, indexEnd, 15 * self.scale[self.SCALE_RESOURCES], -2, -DHUDEllipseMath.HUD_BAR_WIDTH - DHUDEllipseMath.HUD_SMALLBAR_WIDTH, true, 0);
end

--- Create rune frame near right small bar
-- @param index index of frame
-- @return frame created
function DHUDGUI:createRuneFrameSmallRight(index)
	local frame = self:createRuneFrame("DHUD_Right_RuneSmall" .. index);
	return frame, self.repositionRuneFramesSmallRight;
end

--- Create rune frame near right small bar
-- @param index index of frame
-- @return frame created
function DHUDGUI:repositionRuneFramesSmallRight(frame)
	local group, indexBegin, indexEnd = self:repositionProcessParams(self.frameGroups.runesSmallRight, frame);
	local hasSmallBar = bit.band(self.backgroundRight, self.BACKGROUND_BAR_SMALL1) ~= 0;
	self:repositionCircleFramesAroundHud(group, indexBegin, indexEnd, 15 * self.scale[self.SCALE_RESOURCES], -2, -DHUDEllipseMath.HUD_BAR_WIDTH - DHUDEllipseMath.HUD_SMALLBAR_WIDTH, false, 0);
end

--- Reposition spell circles around all bars
function DHUDGUI:repositionSpellCircleFramesAll()
	self:repositionSpellCircleFramesBigLeft();
	self:repositionSpellCircleFramesSmallLeft();
	self:repositionSpellCircleFramesBigRight();
	self:repositionSpellCircleFramesSmallRight();
end

--- Reposition spell rectangles around all bars
function DHUDGUI:repositionSpellRectangeFramesAll()
	self:repositionSpellRectangleFramesLeft();
	self:repositionSpellRectangleFramesRight();
end

--- Reposition resources around all bars
function DHUDGUI:repositionResourceFramesAll()
	self:repositionComboPointFramesAll();
	self:repositionRuneFramesAll();
end

--- Reposition combo points around all bars
function DHUDGUI:repositionComboPointFramesAll()
	self:repositionComboPointFramesBigLeft();
	self:repositionComboPointFramesBigRight();
	self:repositionComboPointFramesSmallLeft();
	self:repositionComboPointFramesSmallRight();
end

--- Reposition runes around all bars
function DHUDGUI:repositionRuneFramesAll()
	self:repositionRuneFramesBigLeft();
	self:repositionRuneFramesBigRight();
	self:repositionRuneFramesSmallLeft();
	self:repositionRuneFramesSmallRight();
end

--- Reposition circle frames around left small bar
function DHUDGUI:repositionCircleFramesSmallLeft()
	self:repositionSpellCircleFramesSmallLeft();
	self:repositionComboPointFramesSmallLeft();
	self:repositionRuneFramesSmallLeft();
end

--- Reposition circle frames around left small bar
function DHUDGUI:repositionCircleFramesSmallRight()
	self:repositionSpellCircleFramesSmallRight();
	self:repositionComboPointFramesSmallRight();
	self:repositionRuneFramesSmallRight();
end

--- Reposition circle frames around bar
-- @param group group group with frames to reposition
-- @param indexBegin index of first frame in group to reposition
-- @param indexEnd index of last frame in group to reposition
-- @param elementRadius radius of circle frame
-- @param baseOffset offset of first circles from HUD base ellipse (this offset will be used to calculate numFit and arcHeight vars)
-- @param additionalOffset additional offset of first circles from HUD base ellipse
-- @param mirrorPosition mirror position acros y-axis?
-- @param angleOffset if not nil then first frame will be position angle will be offset by amount specified
function DHUDGUI:repositionCircleFramesAroundHud(group, indexBegin, indexEnd, elementRadius, baseOffset, additionalOffset, mirrorPosition, angleOffset)
	-- noting to do
	if (indexEnd < 1) then
		return;
	end
	local angleDistributeSpace = (angleOffset == nil);
	angleOffset = angleOffset or 0;
	local mirrorSign = mirrorPosition and -1 or 1;
	-- calculate offset sign
	local offsetSign = 1;
	if (baseOffset < 0) then
		offsetSign = -1;
	end
	-- calculate position
	local x, y;
	local angle;
	DHUDEllipseMath:setDefaultEllipse();
	DHUDEllipseMath:adjustRadiusX(baseOffset + (elementRadius) * offsetSign);
	local numFit = DHUDEllipseMath:calculateNumElementsFit(elementRadius);
	local arcHeight = DHUDEllipseMath:calculateArcHeight();
	DHUDEllipseMath:adjustRadiusX(additionalOffset);
	local offset = elementRadius * 2 * offsetSign;
	local angleBegin;
	local angleStep;
	local numFitted = 0;
	local index = indexBegin;
	-- check if we can fit atleast one element
	if (numFit <= 0) then
		return; -- no point to continue
	end
	-- iterate
	while (true) do
		numFitted = numFitted + numFit;
		-- counted until index begin?
		if (numFitted >= index) then
			angleStep = DHUDEllipseMath:calculateAngleStep(elementRadius);
			angleBegin = DHUDEllipseMath:calculateAngleBegin(elementRadius, arcHeight, angleDistributeSpace) + angleOffset;
			while (true) do
				-- calculate angle for index
				angle = angleBegin + angleStep * (index - (numFitted - numFit) - 0.5); -- -1 since index start from 0; +0.5 for half of the radius of first element
				x, y = DHUDEllipseMath:calculatePositionInAddonCoordinates(angle);
				-- set position
				--print("frame " .. index .. " angle " .. angle .. " set to " .. x .. ", " .. y);
				group[index]:SetPoint("CENTER", "DHUD_UIParent", "CENTER", mirrorSign * x, y);
				-- increase index
				index = index + 1;
				-- check for iteration end
				if (index > indexEnd) then
					return;
				elseif (index > numFitted) then
					break;
				end
			end
		end
		-- adjust radius
		DHUDEllipseMath:adjustRadiusX(offset);
	end
end

--- Reposition rectangle frames around frame specified
-- @param group group group with frames to reposition
-- @param indexBegin index of first frame in group to reposition
-- @param indexEnd index of last frame in group to reposition
-- @param elementWidth width of rectangle frames
-- @param elementHeight height of rectangle frames
-- @param numFitWidth number of frames to be fit in width
-- @param offset offset between elements (space)
-- @param offsetFirstX offset for first frame, x - axis
-- @param toTheLeft position frames to the left?
-- @param parentName name of the parent frame, this frame will be inserted to parent container (should be bottom textField)
-- @param relativePointThis relative point of frame to be used as attach point
-- @param relativePointParent relative point of parent frame to be used as attach point
function DHUDGUI:repositionRectangleFramesAroundFrame(group, indexBegin, indexEnd, elementWidth, elementHeight, numFitWidth, offset, offsetFirstX, toTheLeft, parentName, relativePointThis, relativePointParent)
	-- noting to do
	if (indexEnd < 1) then
		return;
	end
	local positionSign = toTheLeft and -1 or 1;
	-- calculate position
	local x, y;
	local numFitted = 0;
	local index = indexBegin;
	local iterationX = 0;
	local iterationY = 0;
	-- check if we can fit atleast one element
	if (numFitWidth <= 0) then
		return; -- no point to continue
	end
	-- iterate
	while (true) do
		numFitted = numFitted + numFitWidth;
		-- counted until index begin?
		if (numFitted >= index) then
			while (true) do
				-- calculate position
				iterationX = index - (numFitted - numFitWidth) - 1;
				x = (offsetFirstX + (offset + elementWidth) * iterationX);
				y = -(elementWidth + offset) * iterationY;
				-- set position
				--print("frame " .. index .. " angle " .. angle .. " set to " .. x .. ", " .. y);
				group[index]:SetPoint(relativePointThis, parentName, relativePointParent, positionSign * x, y);
				-- increase index
				index = index + 1;
				-- check for iteration end
				if (index > indexEnd) then
					return;
				elseif (index > numFitted) then
					break;
				end
			end
		end
		-- adjust y
		iterationY = iterationY + 1;
	end
end

--- Distribute rectangle frames along target width
-- @param group group group with frames to reposition
-- @param indexBegin index of first frame in group to reposition
-- @param indexEnd index of last frame in group to reposition
-- @param elementWidth width of rectangle frames
-- @param offset offset between elements (space)
-- @param offsetFirstY offset for first frame, y - axis
-- @param parentName name of the parent frame, this frame will be inserted to parent container (should be bottom textField)
-- @param relativePointThis relative point of frame to be used as attach point
-- @param relativePointParent relative point of parent frame to be used as attach point
function DHUDGUI:distributeRectangleFramesAlongWidth(group, indexBegin, indexEnd, elementWidth, offset, offsetFirstY, parentName, relativePointThis, relativePointParent)
	-- noting to do
	if (indexEnd < 1) then
		return;
	end
	-- calculate position
	local x;
	local y = offsetFirstY;
	local numFrames = indexEnd - indexBegin + 1;
	local targetWidth = numFrames * elementWidth + (numFrames - 1) * offset;
	local xBegin = -targetWidth / 2 + elementWidth / 2; -- added element width since relative point is center
	local index;
	-- check if we can fit atleast one element
	if (numFrames <= 0) then
		return; -- no point to continue
	end
	-- iterate
	for i = indexBegin, indexEnd, 1 do
		-- calculate position
		index = i - indexBegin;
		x = xBegin + (elementWidth + offset) * index;
		-- set position
		--print("frame " .. index .. " set to " .. x .. ", " .. y);
		group[i]:SetPoint(relativePointThis, parentName, relativePointParent, x, y);
	end
end

--- Change texture of all bars to texture specified
-- @param textureId id of the new texture (from 1 to 5, bounds are set by DHUDSettings class)
function DHUDGUI:changeBarsTextures(textureId)
	if (self.barsTexture == textureId) then
		return;
	end
	self.barsTexture = textureId;
	local texture;
	for i, v in pairs(self.frameGroups.bars) do
		texture = v.texture;
		texture:SetTexture(texture.pathPrefix .. textureId);
	end
end

--- process texture mask to texture name
-- @param mask mask to process
-- @return name of the texture
function DHUDGUI:processBackgroundBarsMaskToTextureName(mask)
	if (bit.band(mask, self.BACKGROUND_BAR_BIG2) ~= 0) then
		if (bit.band(mask, self.BACKGROUND_BAR_SMALL2) ~= 0) then
			return "BackgroundBars2B2S";
		end
		if (bit.band(mask, self.BACKGROUND_BAR_SMALL1) ~= 0) then
			return "BackgroundBars2B1SI";
		end
		if (bit.band(mask, self.BACKGROUND_BAR_BIG1) ~= 0) then
			return "BackgroundBars2B0S";
		end
		return "BackgroundBars1BO0S";
	elseif (bit.band(mask, self.BACKGROUND_BAR_BIG1) ~= 0) then
		if (bit.band(mask, self.BACKGROUND_BAR_SMALL2) ~= 0) then
			return "BackgroundBars2B2S";
		end
		if (bit.band(mask, self.BACKGROUND_BAR_SMALL1) ~= 0) then
			return "BackgroundBars1BI1SI";
		end
		return "BackgroundBars1BI0S";
	elseif (bit.band(mask, self.BACKGROUND_BAR_SMALL1) ~= 0) then
		if (bit.band(mask, self.BACKGROUND_BAR_SMALL2) ~= 0) then
			return "BackgroundBars2B2S";
		end
		return "BackgroundBars1BI1SI";
	elseif (bit.band(mask, self.BACKGROUND_BAR_SMALL2) ~= 0) then
		return "BackgroundBars2B2S";
	end
	return "BackgroundBars0B0S";
end

--- Change background textures to be shown only under bars specified by mask
-- @param leftBarsMask mask of bars that should be shown on the left
-- @param rightBarsMask mask of bars that should be shown on the right
function DHUDGUI:changeBarsBackground(leftBarsMask, rightBarsMask)
	if (self.backgroundLeft == leftBarsMask and self.backgroundRight == rightBarsMask) then
		return;
	end
	-- get texture params
	local textureNameLeft = self:processBackgroundBarsMaskToTextureName(leftBarsMask);
	local textureNameRight = self:processBackgroundBarsMaskToTextureName(rightBarsMask);
	-- update texture on the left
	local path, x0, x1, y0, y1 = unpack(self.textures[textureNameLeft]);
	local frame = self.frames["DHUD_Left_BarsBackground"];
	local texture = frame.texture;
	if (texture:GetTexture() ~= path) then
		texture:SetTexture(path);
		texture:SetTexCoord(x0, x1, y0, y1);
	end
	-- update texture on the right
	path, x0, x1, y0, y1 = unpack(self.textures[textureNameRight]);
	frame = self.frames["DHUD_Right_BarsBackground"];
	texture = frame.texture;
	if (texture:GetTexture() ~= path) then
		texture:SetTexture(path);
		texture:SetTexCoord(x1, x0, y0, y1);
	end
	-- check if reposition required around inner bars
	local repositionLeft = bit.band(self.backgroundLeft, self.BACKGROUND_BAR_SMALL1) ~= bit.band(leftBarsMask, self.BACKGROUND_BAR_SMALL1);
	local repositionRight = bit.band(self.backgroundRight, self.BACKGROUND_BAR_SMALL1) ~= bit.band(rightBarsMask, self.BACKGROUND_BAR_SMALL1);
	-- save
	self.backgroundLeft = leftBarsMask;
	self.backgroundRight = rightBarsMask;
	-- reposition frames if required
	if (repositionLeft) then
		self:repositionCircleFramesSmallLeft();
	end
	if (repositionRight) then
		self:repositionCircleFramesSmallRight();
	end
end

--- Changes alpha of the frames
-- @param alpha new frames alpha
function DHUDGUI:changeAlpha(alpha)
	if (self.framesAlpha == alpha) then
		return;
	end
	local before = self.framesAlpha;
	-- save alpha
	self.framesAlpha = alpha;
	-- set alpha textures alpha
	local alphaFrames = self.frameGroups.alphaFrames;
	for i, v in ipairs(alphaFrames) do
		v.texture:SetAlpha(alpha);
	end
	-- hide all frames if alpha == 0
	if (alpha <= 0) then
		for k, v in pairs(self.frames) do
			v:DHide(self.FRAME_VISIBLE_REASON_ALPHA);
		end
	end
	-- show frames if alpha become greater than 0
	if (before <= 0 and alpha > 0) then
		for k, v in pairs(self.frames) do
			v:DShow(self.FRAME_VISIBLE_REASON_ALPHA);
		end
	end
end

--- Created new frame that should use alpha setting
-- @param frame reference to created frame
function DHUDGUI:onAlphaFrameCreated(frame)
	frame.texture:SetAlpha(self.framesAlpha);
	-- frames will be hidden in createFrame func if required
end

--- Hide frames when player becomes dead, only player information frames should be hidden when dead
-- @param list list with frames and groups to hide when dead
function DHUDGUI:hideFramesWhenDead(list)
	for i, v in ipairs(list) do
		if (#v > 0) then
			for i2, v2 in ipairs(v) do
				v2:DHide(self.FRAME_VISIBLE_REASON_ALIVE);
			end
		else
			v:DHide(self.FRAME_VISIBLE_REASON_ALIVE);
		end
	end
end

--- Show frames that were hidden after player become dead, only player information frames should be hidden when dead
function DHUDGUI:showFramesWhenAlive()
	for k, v in pairs(self.frames) do
		v:DShow(self.FRAME_VISIBLE_REASON_ALIVE);
	end
end

--- Process setting, that contains frame scaling and listen to it's changes
-- @param settingName name of the setting
-- @param settingId id of the setting inside class table, pass nil for automatic generation
-- @param notifyFunction function to invoke when value changes if any
-- @param group group with frames to scale by this setting, this will override group onDynamicFrameCreated function! (create different group if you don't want this to happen)
-- @param ... list of frames to be scaled by this setting
function DHUDGUI:processFrameScaleSetting(settingName, settingId, notifyFunction, group, ...)
	local frames = { ... };
	settingId = settingId or (#self.scale + 1);
	-- create notify list
	self.scaleNotifyList[settingId] = { };
	if (notifyFunction ~= nil) then
		table.insert(self.scaleNotifyList[settingId], notifyFunction);
	end
	-- create function
	local functionOnSettingChange = function(self, e)
		local scale = DHUDSettings:getValue(settingName);
		self.scale[settingId] = scale;
		-- iterate over group frames
		if (group ~= nil) then
			for i, v in ipairs(group) do
				v:SetScale(scale);
			end
		end
		-- iterate over specified frames
		for i, v in ipairs(frames) do
			v:SetScale(scale);
		end
		-- iterate over notify functions
		local notify = self.scaleNotifyList[settingId];
		for i, v in ipairs(notify) do
			v(self, nil);
		end
	end
	-- override group function
	if (group ~= nil) then
		local onCreateCurrent = group.onDynamicFrameCreated;
		group.onDynamicFrameCreated = function(self, frame)
			if (onCreateCurrent ~= nil) then
				onCreateCurrent(self, frame);
			end
			local scale = self.scale[settingId];
			frame:SetScale(scale);
		end
	end
	-- listen
	DHUDSettings:addEventListener(DHUDSettingsEvent.EVENT_SPECIFIC_SETTING_CHANGED_PREFIX .. settingName, self, functionOnSettingChange);
	functionOnSettingChange(self, nil);
end

--- Process setting, that contains frame font size and listen to it's changes
-- @param settingName name of the setting
-- @param settingId id of the setting inside class table, pass nil for automatic generation
-- @param scaledWithSettingId defines id of the scale setting that should be considered when calculating real font size (pass nil for none)
-- @param variableName name of the variable that holds text field inside frame
-- @param group group with frames to scale by this setting, this will override group onDynamicFrameCreated function! (create different group if you don't want this to happen)
-- @param ... list of frames to be scaled by this setting
function DHUDGUI:processFrameFontSizeSetting(settingName, settingId, scaledWithSettingId, variableName, group, ...)
	local frames = { ... };
	variableName = variableName or "textField";
	settingId = settingId or (#self.fontSizes + 1);
	-- create function
	local functionOnSettingChange = function(self, e)
		local fontSize = DHUDSettings:getValue(settingName);
		self.fontSizes[settingId] = fontSize;
		local realFontSize = fontSize / self.scale[self.SCALE_MAIN];
		if (scaledWithSettingId ~= nil) then
			realFontSize = realFontSize / self.scale[scaledWithSettingId];
		end
		local fontName, cFontSize, fontFlags;
		-- iterate over group frames
		if (group ~= nil) then
			for i, v in ipairs(group) do
				v = v[variableName];
				if (v ~= nil) then
					fontName, cFontSize, fontFlags = v:GetFont();
					v:SetFont(fontName, realFontSize, fontFlags);
					v:DSetText(v:GetText()); -- required to resize textFields
				end
			end
		end
		-- iterate over specified frames
		for i, v in ipairs(frames) do
			v = v[variableName];
			if (v ~= nil) then
				fontName, cFontSize, fontFlags = v:GetFont();
				v:SetFont(fontName, realFontSize, fontFlags);
				v:DSetText(v:GetText()); -- required to resize textFields
			end
		end
	end
	-- override group function
	if (group ~= nil) then
		local onCreateCurrent = group.onDynamicFrameCreated;
		group.onDynamicFrameCreated = function(self, frame)
			if (onCreateCurrent ~= nil) then
				onCreateCurrent(self, frame);
			end
			frame = frame[variableName];
			if (frame ~= nil) then
				local fontSize = self.fontSizes[settingId];
				local realFontSize = fontSize / self.scale[self.SCALE_MAIN];
				if (scaledWithSettingId ~= nil) then
					realFontSize = realFontSize / self.scale[scaledWithSettingId];
				end
				local fontName, cFontSize, fontFlags = frame:GetFont();
				frame:SetFont(fontName, realFontSize, fontFlags);
				frame:DSetText(frame:GetText()); -- required to resize textFields
			end
		end
	end
	-- push function to scale notify list as it's dependent on hud scale
	table.insert(self.scaleNotifyList[self.SCALE_MAIN], functionOnSettingChange);
	if (scaledWithSettingId ~= nil) then
		table.insert(self.scaleNotifyList[scaledWithSettingId], functionOnSettingChange);
	end
	-- listen
	DHUDSettings:addEventListener(DHUDSettingsEvent.EVENT_SPECIFIC_SETTING_CHANGED_PREFIX .. settingName, self, functionOnSettingChange);
	functionOnSettingChange(self, nil);
end

--- Process setting, that contains frame font outline and listen to it's changes
-- @param settingName name of the setting
-- @param settingId id of the setting inside class table, pass nil for automatic generation
-- @param variableName name of the variable that holds text field inside frame
-- @param group group with frames to scale by this setting, this will override group onDynamicFrameCreated function! (create different group if you don't want this to happen)
-- @param ... list of frames to be scaled by this setting
function DHUDGUI:processFrameFontOutlineSetting(settingName, settingId, variableName, group, ...)
	local frames = { ... };
	variableName = variableName or "textField";
	settingId = settingId or (#self.fontOutlines + 1);
	-- create function
	local functionOnSettingChange = function(self, e)
		local fontOutline = DHUDSettings:getValue(settingName);
		self.fontOutlines[settingId] = fontOutline;
		local fontFlags = self.FONT_OUTLINES[fontOutline + 1];
		local fontName, fontSize, cFontFlags;
		-- iterate over group frames
		if (group ~= nil) then
			for i, v in ipairs(group) do
				v = v[variableName];
				if (v ~= nil) then
					fontName, fontSize, cFontFlags = v:GetFont();
					v:SetFont(fontName, fontSize, fontFlags);
				end
			end
		end
		-- iterate over specified frames
		for i, v in ipairs(frames) do
			v = v[variableName];
			if (v ~= nil) then
				fontName, fontSize, cFontFlags = v:GetFont();
				v:SetFont(fontName, fontSize, fontFlags);
			end
		end
	end
	-- override group function
	if (group ~= nil) then
		local onCreateCurrent = group.onDynamicFrameCreated;
		group.onDynamicFrameCreated = function(self, frame)
			if (onCreateCurrent ~= nil) then
				onCreateCurrent(self, frame);
			end
			frame = frame[variableName];
			if (frame ~= nil) then
				local fontOutline = self.fontOutlines[settingId];
				local fontFlags = self.FONT_OUTLINES[fontOutline + 1];
				local fontName, fontSize, cFontFlags = frame:GetFont();
				frame:SetFont(fontName, fontSize, fontFlags);
			end
		end
	end
	-- listen
	DHUDSettings:addEventListener(DHUDSettingsEvent.EVENT_SPECIFIC_SETTING_CHANGED_PREFIX .. settingName, self, functionOnSettingChange);
	functionOnSettingChange(self, nil);
end

--- Process setting, that contains frame position and listen to it's changes
-- @param settingName name of the setting
-- @param ... list of functions to invoke
function DHUDGUI:processFramePositionSetting(settingName, ...)
	local functions = { ... };
	-- create function
	local functionOnSettingChange = function(self, e)
		local position = DHUDSettings:getValue(settingName);
		-- iterate over specified functions
		for i, v in ipairs(functions) do
			v(self, position);
		end
	end
	-- listen
	DHUDSettings:addEventListener(DHUDSettingsEvent.EVENT_SPECIFIC_SETTING_CHANGED_PREFIX .. settingName, self, functionOnSettingChange);
	functionOnSettingChange(self, nil);
end


--- textures setting has changed, update gui
function DHUDGUI:onTexturesSetting(e)
	self:changeBarsTextures(DHUDSettings:getValue("textures_barTexture"));
end

--- Create most of the static frames, that aren't going to change
function DHUDGUI:createFrames()
	local group, frame;
	-- create container for all frames
	self:createFrame("DHUD_UIParent", "UIParent", "CENTER", "CENTER", 0, 0, 512, 256);
	-- create bars background
	self:createTextureFrame("DHUD_Left_BarsBackground", "DHUD_UIParent", "LEFT", "LEFT", 0, 0, 128, 256, "BackgroundBars0B0S");
	self:createTextureFrame("DHUD_Right_BarsBackground", "DHUD_UIParent", "RIGHT", "RIGHT", 0, 0, 128, 256, "BackgroundBars0B0S", true);
	-- create alpha group
	group = self:createFrameGroup("alphaFrames", "DHUD_Left_BarsBackground", "DHUD_Right_BarsBackground");
	group.onDynamicFrameCreated = self.onAlphaFrameCreated;
	-- create bars group
	self:createFrameGroup("bars");
	-- create left big inner bar
	group = self:createDynamicFrameGroup("leftBigBar1", self.createBarFrameBigInnerLeft, 10, self.frameGroups.bars, self.frameGroups.alphaFrames);
	frame = self:createTextFrame("DHUD_Left_TextBig1", "DHUD_Left_BarsBackground", "LEFT", "BOTTOM", 95 - 50, 2 + 7, 200, 14, "LEFT", "CENTER", "numeric");
	group["text"] = frame;
	group["helper"] = DHUDGUIBarAnimationHelper:new(group, "TexturePrefixBarB1", "leftBars");
	-- create left big outer bar
	group = self:createDynamicFrameGroup("leftBigBar2", self.createBarFrameBigOuterLeft, 10, self.frameGroups.bars, self.frameGroups.alphaFrames);
	frame = self:createTextFrame("DHUD_Left_TextBig2", "DHUD_Left_BarsBackground", "LEFT", "BOTTOM", 80 - 50, -16 + 7, 200, 14, "LEFT", "CENTER", "numeric");
	group["text"] = frame;
	group["helper"] = DHUDGUIBarAnimationHelper:new(group, "TexturePrefixBarB2", "leftBars");
	-- create left small inner bar
	group = self:createDynamicFrameGroup("leftSmallBar1", self.createBarFrameSmallInnerLeft, 10, self.frameGroups.bars, self.frameGroups.alphaFrames);
	frame = self:createTextFrame("DHUD_Left_TextSmall1", "DHUD_Left_BarsBackground", "LEFT", "BOTTOM", 110 - 50, 19 + 7, 200, 14, "LEFT", "CENTER", "numeric");
	group["text"] = frame;
	group["helper"] = DHUDGUIBarAnimationHelper:new(group, "TexturePrefixBarS1", "leftBars");
	-- create left big inner bar
	group = self:createDynamicFrameGroup("rightBigBar1", self.createBarFrameBigInnerRight, 10, self.frameGroups.bars, self.frameGroups.alphaFrames);
	frame = self:createTextFrame("DHUD_Right_TextBig1", "DHUD_Right_BarsBackground", "RIGHT", "BOTTOM", -95 + 50, 2 + 7, 200, 14, "RIGHT", "CENTER", "numeric");
	group["text"] = frame;
	group["helper"] = DHUDGUIBarAnimationHelper:new(group, "TexturePrefixBarB1", "rightBars");
	-- create left big outer bar
	group = self:createDynamicFrameGroup("rightBigBar2", self.createBarFrameBigOuterRight, 10, self.frameGroups.bars, self.frameGroups.alphaFrames);
	frame = self:createTextFrame("DHUD_Right_TextBig2", "DHUD_Right_BarsBackground", "RIGHT", "BOTTOM", -80 + 50, -16 + 7, 200, 14, "RIGHT", "CENTER", "numeric");
	group["text"] = frame;
	group["helper"] = DHUDGUIBarAnimationHelper:new(group, "TexturePrefixBarB2", "rightBars");
	-- create right small inner bar
	group = self:createDynamicFrameGroup("rightSmallBar1", self.createBarFrameSmallInnerRight, 10, self.frameGroups.bars, self.frameGroups.alphaFrames);
	frame = self:createTextFrame("DHUD_Right_TextSmall1", "DHUD_Right_BarsBackground", "RIGHT", "BOTTOM", -110 + 50, 19 + 7, 200, 14, "RIGHT", "CENTER", "numeric");
	group["text"] = frame;
	group["helper"] = DHUDGUIBarAnimationHelper:new(group, "TexturePrefixBarS1", "rightBars");
	-- create target info text
	frame = self:createUnitTextFrame("DHUD_Center_TextInfo1", "DHUD_UIParent", "BOTTOM", "BOTTOM", 0, -45, nil, 14, "CENTER", "CENTER");
	-- create target2 info text
	frame = self:createUnitTextFrame("DHUD_Center_TextInfo2", "DHUD_Center_TextInfo1", "BOTTOM", "BOTTOM", 0, -20, nil, 14, "CENTER", "CENTER");
	-- create spell circles group
	self:createFrameGroup("spellCircles");
	-- create buff circles
	self:createDynamicFrameGroup("spellCirclesBigLeft", self.createSpellCircleFrameBigLeft, 40, self.frameGroups.spellCircles);
	self:createDynamicFrameGroup("spellCirclesSmallLeft", self.createSpellCircleFrameSmallLeft, 20, self.frameGroups.spellCircles);
	self:createDynamicFrameGroup("spellCirclesBigRight", self.createSpellCircleFrameBigRight, 40, self.frameGroups.spellCircles);
	self:createDynamicFrameGroup("spellCirclesSmallRight", self.createSpellCircleFrameSmallRight, 20, self.frameGroups.spellCircles);
	-- create spell rectangles group
	self:createFrameGroup("spellRectangles");
	-- create buff rectangles
	self:createDynamicFrameGroup("spellRectanglesLeft", self.createSpellRectangleFrameLeft, 64, self.frameGroups.spellRectangles);
	self:createDynamicFrameGroup("spellRectanglesRight", self.createSpellRectangleFrameRight, 64, self.frameGroups.spellRectangles);
	-- create resources group
	self:createFrameGroup("resources");
	-- create combo-points
	self:createDynamicFrameGroup("comboPointsBigLeft", self.createComboPointFrameBigLeft, 10, self.frameGroups.resources);
	self:createDynamicFrameGroup("comboPointsBigRight", self.createComboPointFrameBigRight, 10, self.frameGroups.resources);
	self:createDynamicFrameGroup("comboPointsSmallLeft", self.createComboPointFrameSmallLeft, 10, self.frameGroups.resources);
	self:createDynamicFrameGroup("comboPointsSmallRight", self.createComboPointFrameSmallRight, 10, self.frameGroups.resources);
	-- create runes
	self:createDynamicFrameGroup("runesBigLeft", self.createRuneFrameBigLeft, 6, self.frameGroups.resources);
	self:createDynamicFrameGroup("runesBigRight", self.createRuneFrameBigRight, 6, self.frameGroups.resources);
	self:createDynamicFrameGroup("runesSmallLeft", self.createRuneFrameSmallLeft, 6, self.frameGroups.resources);
	self:createDynamicFrameGroup("runesSmallRight", self.createRuneFrameSmallRight, 6, self.frameGroups.resources);
	-- create group with target icons
	group = self:createDynamicFrameGroup("targetIcons", self.createTargetUnitInfoIconCenter, 10);
	group.reposition = self.repositionTargetUnitInfoIconCenter;
	-- create self icons
	self:createIconFrame("DHUD_Icon_SelfUnitIconPvP", "DHUD_Left_BarsBackground", "TOP", "TOP", 50, -15, 25, 25, "BlizzardRaidIcon1");
	self:createIconFrame("DHUD_Icon_SelfUnitIconState", "DHUD_Left_BarsBackground", "TOP", "TOP", 42, 12, 25, 25, "BlizzardRaidIcon1");
	-- create dragon icon
	self:createIconFrame("DHUD_Icon_TargetEliteDragon", "DHUD_Left_BarsBackground", "TOP", "TOP", 18, 20, 64, 64, "TargetEliteDragon");
	-- all icons should use current alpha
	self:pushFramesToGroup(self.frameGroups.alphaFrames, "DHUD_Icon_SelfUnitIconPvP", "DHUD_Icon_SelfUnitIconState", "DHUD_Icon_TargetEliteDragon");
	-- create dropdowns
	self:createDropDownMenu("DHUD_DropDown_PlayerMenu", self.initDropDownMenuPlayer);
	self:createDropDownMenu("DHUD_DropDown_TargetMenu", self.initDropDownMenuTarget);
	-- create cast delay and cast time groups
	self:createFrameGroup("castDelay");
	self:createFrameGroup("castTime");
	self:createFrameGroup("castSpellName");
	-- create cast bars
	local pushToGroupsMap = { };
	pushToGroupsMap[self.CASTBAR_GROUP_INDEX_CAST_INDICATION] = { self.frameGroups.alphaFrames };
	pushToGroupsMap[self.CASTBAR_GROUP_INDEX_FLASH] = { self.frameGroups.alphaFrames };
	pushToGroupsMap[self.CASTBAR_GROUP_INDEX_SPELLNAME] = { self.frameGroups.castSpellName };
	pushToGroupsMap[self.CASTBAR_GROUP_INDEX_CASTTIME] = { self.frameGroups.castTime };
	pushToGroupsMap[self.CASTBAR_GROUP_INDEX_DELAY] = { self.frameGroups.castDelay };
	group = self:createDynamicFrameGroupWithCustomIndexes("leftBigCastBar1", self.createCastBarFrameBigInnerLeft, pushToGroupsMap);
	group["helper"] = DHUDGUICastBarAnimationHelper:new(group, "CastingBarB1", "leftCastBars");
	group = self:createDynamicFrameGroupWithCustomIndexes("leftBigCastBar2", self.createCastBarFrameBigOuterLeft, pushToGroupsMap);
	group["helper"] = DHUDGUICastBarAnimationHelper:new(group, "CastingBarB2", "leftCastBars");
	group = self:createDynamicFrameGroupWithCustomIndexes("rightBigCastBar1", self.createCastBarFrameBigInnerRight, pushToGroupsMap);
	group["helper"] = DHUDGUICastBarAnimationHelper:new(group, "CastingBarB1", "rightCastBars");
	group = self:createDynamicFrameGroupWithCustomIndexes("rightBigCastBar2", self.createCastBarFrameBigOuterRight, pushToGroupsMap);
	group["helper"] = DHUDGUICastBarAnimationHelper:new(group, "CastingBarB2", "rightCastBars");
end

--- Initialize DHUD gui, creating all frames
function DHUDGUI:init()
	-- create frames and groups
	self:createFrames();
	-- init text tools
	DHUDTextTools:init();
	-- init color tools
	DHUDColorizeTools:init()
	-- init animation helper
	DHUDGUIBarAnimationHelper:STATIC_init()
	-- initialize textures settings track
	DHUDSettings:addEventListener(DHUDSettingsEvent.EVENT_SPECIFIC_SETTING_CHANGED_PREFIX .. "textures_barTexture", self, self.onTexturesSetting);
	self:onTexturesSetting(nil);
	-- initialize icon positions track
	self:processFramePositionSetting("framesData_iconPositions_dragon", self.repositionTargetUnitEliteIcon);
	self:processFramePositionSetting("framesData_iconPositions_selfState", self.repositionSelfUnitPvPIcon, self.repositionSelfUnitStateIcon);
	self:processFramePositionSetting("framesData_iconPositions_targetState", self.repositionTargetUnitInfoStateIcons);
	-- initialize scale settings track
	self:processFrameScaleSetting("scale_main", self.SCALE_MAIN, nil, nil, self.frames["DHUD_UIParent"]);
	self:processFrameScaleSetting("scale_spellCircles", self.SCALE_SPELL_CIRCLES, self.repositionSpellCircleFramesAll, self.frameGroups.spellCircles, nil);
	self:processFrameScaleSetting("scale_spellRectangles", self.SCALE_SPELL_RECTANGLES, self.repositionSpellRectangeFramesAll, self.frameGroups.spellRectangles, nil);
	self:processFrameScaleSetting("scale_resource", self.SCALE_RESOURCES, self.repositionResourceFramesAll, self.frameGroups.resources, nil);
	-- initialize fontSize setting track
	self:processFrameFontSizeSetting("scale_leftBigBar1", nil, nil, nil, nil, self.frames["DHUD_Left_TextBig1"]);
	self:processFrameFontSizeSetting("scale_leftBigBar2", nil, nil, nil, nil, self.frames["DHUD_Left_TextBig2"]);
	self:processFrameFontSizeSetting("scale_leftSmallBar1", nil, nil, nil, nil, self.frames["DHUD_Left_TextSmall1"]);
	self:processFrameFontSizeSetting("scale_rightBigBar1", nil, nil, nil, nil, self.frames["DHUD_Right_TextBig1"]);
	self:processFrameFontSizeSetting("scale_rightBigBar2", nil, nil, nil, nil, self.frames["DHUD_Right_TextBig2"]);
	self:processFrameFontSizeSetting("scale_rightSmallBar1", nil, nil, nil, nil, self.frames["DHUD_Right_TextSmall1"]);
	self:processFrameFontSizeSetting("scale_targetInfo1", nil, nil, nil, nil, self.frames["DHUD_Center_TextInfo1"]);
	self:processFrameFontSizeSetting("scale_targetInfo2", nil, nil, nil, nil, self.frames["DHUD_Center_TextInfo2"]);
	self:processFrameFontSizeSetting("scale_spellCirclesTime", nil, nil, "textFieldTime", self.frameGroups["spellCircles"], nil);
	self:processFrameFontSizeSetting("scale_spellCirclesStacks", nil, nil, "textFieldCount", self.frameGroups["spellCircles"], nil);
	self:processFrameFontSizeSetting("scale_spellRectanglesTime", nil, nil, "textFieldTime", self.frameGroups["spellRectangles"], nil);
	self:processFrameFontSizeSetting("scale_spellRectanglesStacks", nil, nil, "textFieldCount", self.frameGroups["spellRectangles"], nil);
	self:processFrameFontSizeSetting("scale_resourceTime", nil, nil, "textFieldTime", self.frameGroups["resources"], nil);
	self:processFrameFontSizeSetting("scale_castBarsTime", nil, nil, nil, self.frameGroups["castTime"], nil);
	self:processFrameFontSizeSetting("scale_castBarsDelay", nil, nil, nil, self.frameGroups["castDelay"], nil);
	self:processFrameFontSizeSetting("scale_castBarsSpell", nil, nil, nil, self.frameGroups["castSpellName"], nil);
	-- initialize fontOutline setting track
	self:processFrameFontOutlineSetting("outlines_leftBigBar1", nil, nil, nil, self.frames["DHUD_Left_TextBig1"]);
	self:processFrameFontOutlineSetting("outlines_leftBigBar2", nil, nil, nil, self.frames["DHUD_Left_TextBig2"]);
	self:processFrameFontOutlineSetting("outlines_leftSmallBar1", nil, nil, nil, self.frames["DHUD_Left_TextSmall1"]);
	self:processFrameFontOutlineSetting("outlines_rightBigBar1", nil, nil, nil, self.frames["DHUD_Right_TextBig1"]);
	self:processFrameFontOutlineSetting("outlines_rightBigBar2", nil, nil, nil, self.frames["DHUD_Right_TextBig2"]);
	self:processFrameFontOutlineSetting("outlines_rightSmallBar1", nil, nil, nil, self.frames["DHUD_Right_TextSmall1"]);
	self:processFrameFontOutlineSetting("outlines_targetInfo1", nil, nil, nil, self.frames["DHUD_Center_TextInfo1"]);
	self:processFrameFontOutlineSetting("outlines_targetInfo2", nil, nil, nil, self.frames["DHUD_Center_TextInfo2"]);
	self:processFrameFontOutlineSetting("outlines_spellCirclesTime", nil, "textFieldTime", self.frameGroups["spellCircles"], nil);
	self:processFrameFontOutlineSetting("outlines_spellCirclesStacks", nil, "textFieldCount", self.frameGroups["spellCircles"], nil);
	self:processFrameFontOutlineSetting("outlines_spellRectanglesTime", nil, "textFieldTime", self.frameGroups["spellRectangles"], nil);
	self:processFrameFontOutlineSetting("outlines_spellRectanglesStacks", nil, "textFieldCount", self.frameGroups["spellRectangles"], nil);
	self:processFrameFontOutlineSetting("outlines_resourceTime", nil, "textFieldTime", self.frameGroups["resources"], nil);
	self:processFrameFontOutlineSetting("outlines_castBarsTime", nil, nil, self.frameGroups["castTime"], nil);
	self:processFrameFontOutlineSetting("outlines_castBarsDelay", nil, nil, self.frameGroups["castDelay"], nil);
	self:processFrameFontOutlineSetting("outlines_castBarsSpell", nil, nil, self.frameGroups["castSpellName"], nil);
	-- initialize gui manager
	DHUDGUIManager:init();
	-- debug
	--[[for i = 1, 80 do
		local frame = self.frameGroups.leftBigCastBar1[i];
		frame = self.frameGroups.leftBigCastBar2[i];
		frame = self.frameGroups.rightBigCastBar1[i];
		frame = self.frameGroups.rightBigCastBar2[i];
	end]]--
	-- reduce alpha of blizzard power auras
	SpellActivationOverlayFrame:SetAlpha(0.5);
end

----------------------
-- Gui Slot Manager --
----------------------

--- Class to manage single gui slot
DHUDGuiSlotManager = MCCreateClass{
	-- reference to current data tracker
	currentDataTracker	= nil,
	-- reference to current data tracker helper function if present
	currentDataTrackerHelperFunction = nil,
	-- list of the trackers to be used
	dataTrackersList	= nil,
	-- defines if gui in current slot is in regeneration state
	isRegenerating		= false,
	-- name of the setting that contains list of data trackers
	dataTrackersListSettingName = nil,
	-- name of the text format setting
	textFormatSettingName = nil,
	-- map with functions to perform text format
	textFormatMap = nil,
	-- function that should be used to format text
	textFormatFunction = nil,
	-- info about current text format functions
	textFormatInfo = nil,
	-- defines if data tracker being changed, prevents some unnecessary data updates
	isChangingDataTracker = false,
}

--- construct gui slot manager
function DHUDGuiSlotManager:constructor()
	self.textFormatInfo = { };
end

--- some of the color setting was changed, update if required
function DHUDGuiSlotManager:onColorSettingChange(e)
	if (self.currentDataTracker ~= nil) then
		self:onDataChange(nil); -- updating data will cause bar to be recolored
	end
end

--- track changes in color settings to update slot
function DHUDGuiSlotManager:trackColorSettingsChanges()
	DHUDSettings:addEventListener(DHUDSettingsEvent.EVENT_SPECIFIC_GROUP_SETTING_CHANGED_PREFIX .. "colors", self, self.onColorSettingChange);
end

--- Text format setting has changed, update
function DHUDGuiSlotManager:onTextFormatSettingChange(e)
	self.textFormatFunction = DHUDTextTools:parseDataFormatToFunction(DHUDSettings:getValue(self.textFormatSettingName), self.textFormatMap, self);
	if (self.currentDataTracker ~= nil and not self.isChangingDataTracker) then
		self:onDataChange(nil); -- updating data will cause bar text to be refreshed
	end
end

--- Sets text format parameters to generate text format function
-- @param textFormatSettingName setting to read for text format
-- @param textFormatMap map to functions, do not pass this value as nil if setting name is not nil!
function DHUDGuiSlotManager:setTextFormatParams(textFormatSettingName, textFormatMap)
	if (self.textFormatSettingName == textFormatSettingName and self.textFormatMap == textFormatMap) then
		return;
	end
	self.textFormatMap = textFormatMap;
	-- update listener
	if (self.textFormatSettingName ~= nil) then
		DHUDSettings:removeEventListener(DHUDSettingsEvent.EVENT_SPECIFIC_SETTING_CHANGED_PREFIX .. self.textFormatSettingName, self, self.onTextFormatSettingChange);
	end
	self.textFormatSettingName = textFormatSettingName;
	if (self.textFormatSettingName ~= nil) then
		DHUDSettings:addEventListener(DHUDSettingsEvent.EVENT_SPECIFIC_SETTING_CHANGED_PREFIX .. self.textFormatSettingName, self, self.onTextFormatSettingChange);
		self:onTextFormatSettingChange(nil);
	end
end

--- Sets text format parameters to generate text format function for custom variable (this function will be a bit slower but support multiple number of text formats for single slot)
-- @param textFormatSettingName setting to read for text format
-- @param textFormatMap map to functions, do not pass this value as nil if setting name is not nil!
-- @param variableName name of the variable to store function in
function DHUDGuiSlotManager:setTextFormatParamsForVariable(textFormatSettingName, textFormatMap, variableName)
	local variableInfo = self.textFormatInfo[variableName];
	if (variableInfo == nil) then
		variableInfo = { };
		self.textFormatInfo[variableName] = variableInfo;
	end
	if (variableInfo[1] == textFormatSettingName and variableInfo[2] == textFormatMap) then
		return;
	end
	variableInfo[2] = textFormatMap;
	-- update listener
	if (variableInfo[1] ~= nil) then
		DHUDSettings:removeEventListener(DHUDSettingsEvent.EVENT_SPECIFIC_SETTING_CHANGED_PREFIX .. variableInfo[1], self, variableInfo[3]);
	end
	variableInfo[1] = textFormatSettingName;
	if (textFormatSettingName ~= nil) then
		-- create update function
		variableInfo[3] = function(self, e)
			self[variableName] = DHUDTextTools:parseDataFormatToFunction(DHUDSettings:getValue(textFormatSettingName), textFormatMap, self);
			if (self.currentDataTracker ~= nil and not self.isChangingDataTracker) then
				self:onDataChange(nil); -- updating data will cause bar text to be refreshed
			end
		end
		DHUDSettings:addEventListener(DHUDSettingsEvent.EVENT_SPECIFIC_SETTING_CHANGED_PREFIX .. textFormatSettingName, self, variableInfo[3]);
		variableInfo[3](self, nil);
	end
end

--- Data trackers list setting has been changed, read it
function DHUDGuiSlotManager:onDataTrackersSettingChange(e)
	local list = DHUDSettings:getValue(self.dataTrackersListSettingName);
	local convertedList = DHUDSettings:convertDataTrackerNamesArrayToReferenceArray(list);
	self:setDataTrackersList(convertedList);
end

--- set name of the setting, which holds list of data trackers
function DHUDGuiSlotManager:setDataTrackerListSetting(settingName)
	if (self.dataTrackersListSettingName == settingName) then
		return;
	end
	if (self.dataTrackersListSettingName ~= nil) then
		DHUDSettings:removeEventListener(DHUDSettingsEvent.EVENT_SPECIFIC_SETTING_CHANGED_PREFIX .. self.dataTrackersListSettingName, self, self.onDataTrackersSettingChange);
	end
	self.dataTrackersListSettingName = settingName;
	if (self.dataTrackersListSettingName ~= nil) then
		DHUDSettings:addEventListener(DHUDSettingsEvent.EVENT_SPECIFIC_SETTING_CHANGED_PREFIX .. self.dataTrackersListSettingName, self, self.onDataTrackersSettingChange);
	end
	self:onDataTrackersSettingChange(nil);
end

--- Existance of some data tracker has been changed
function DHUDGuiSlotManager:onDataTrackerExistanceChanged(e)
	self:rescanDataTrackersList();
end

--- set list of the trackers to be shown in the gui slot
-- @param dataTrackersList list with trackers
-- @param copy if true, than array will be copied before saving, otherwise stored by reference
function DHUDGuiSlotManager:setDataTrackersList(dataTrackersList, copy)
	-- remove listeners
	if (self.dataTrackersList ~= nil) then
		for i, v in ipairs(self.dataTrackersList) do
			v[1]:removeEventListener(DHUDDataTrackerEvent.EVENT_EXISTANCE_CHANGED, self, self.onDataTrackerExistanceChanged);
		end
	end
	-- copy table
	if (copy) then
		self.dataTrackersList = MCCreateTableCopy(dataTrackersList);
	else
		self.dataTrackersList = dataTrackersList;
	end
	-- set listeners
	if (self.dataTrackersList ~= nil) then
		for i, v in ipairs(self.dataTrackersList) do
			v[1]:addEventListener(DHUDDataTrackerEvent.EVENT_EXISTANCE_CHANGED, self, self.onDataTrackerExistanceChanged);
		end
	end
	-- rescan
	self:rescanDataTrackersList();
end

--- rescan list of data trackers and set first available as dataManager
function DHUDGuiSlotManager:rescanDataTrackersList()
	if (self.dataTrackersList == nil) then
		return;
	end
	for i, v in ipairs(self.dataTrackersList) do
		if (v[1].isExists) then
			self:setCurrentDataTracker(v[1], v[2]);
			return;
		end
	end
	-- not found, set to nil
	self:setCurrentDataTracker(nil);
	return;
end

--- Change isRegenerating variable value
function DHUDGuiSlotManager:setIsRegenerating(isRegenerating)
	if (self.isRegenerating == isRegenerating) then
		return;
	end
	self.isRegenerating = isRegenerating;
	-- notify ui manager
	DHUDGUIManager:onSlotRegenerationStateChanged();
end

--- current data tracker regeneration state changed, not all data trackers will provide correct data, since some of the data is filtered
function DHUDGuiSlotManager:onRegenerationChange(e)
	if (self.currentDataTracker == nil) then
		self:setIsRegenerating(false);
	else
		self:setIsRegenerating(self.currentDataTracker.isRegenerating);
	end
end

--- current data tracker data changed
function DHUDGuiSlotManager:onDataChange(e)
	-- to be overriden
end

--- current data tracker timers changed
function DHUDGuiSlotManager:onDataTimersChange(e)
	-- to be overriden
end

--- current data tracker resource type changed
function DHUDGuiSlotManager:onResourceTypeChange(e)
	-- to be overriden
end

--- new data tracker has been set for this slot, or data tracker unit has changed, update if neccesary
function DHUDGuiSlotManager:onDataTrackerChange(e)
	-- to be overriden
end

--- new unit has been selected by data tracker
function DHUDGuiSlotManager:onDataUnitChange(e)
	-- to be overriden
end

--- current data tracker existance changed, check currentDataTracker variable for existance
function DHUDGuiSlotManager:onExistanceChange()
	-- to be overriden
end

--- set current data tracker to be shown in the gui slot
-- @param currentDataTracker new data tracker to be set
-- @param currentDataTrackerHelperFunction helper function for new data tracker if any
function DHUDGuiSlotManager:setCurrentDataTracker(currentDataTracker, currentDataTrackerHelperFunction)
	-- do almost nothing, if set to the same data tracker
	if (self.currentDataTracker == currentDataTracker and self.currentDataTrackerHelperFunction == currentDataTrackerHelperFunction) then
		return;
	end
	self.isChangingDataTracker = true;
	-- remove listers
	if (self.currentDataTracker ~= nil) then
		self.currentDataTracker:removeEventListener(DHUDDataTrackerEvent.EVENT_REGENERATION_STATE_CHANGED, self, self.onRegenerationChange);
		self.currentDataTracker:removeEventListener(DHUDDataTrackerEvent.EVENT_DATA_CHANGED, self, self.onDataChange);
		self.currentDataTracker:removeEventListener(DHUDDataTrackerEvent.EVENT_DATA_TIMERS_UPDATED, self, self.onDataTimersChange);
		self.currentDataTracker:removeEventListener(DHUDDataTrackerEvent.EVENT_RESOURCE_TYPE_CHANGED, self, self.onResourceTypeChange);
		self.currentDataTracker:removeEventListener(DHUDDataTrackerEvent.EVENT_UNIT_CHANGED, self, self.onDataUnitChange);
	end
	-- save and notify gui about existance change
	local existanceChanged = (self.currentDataTracker == nil or currentDataTracker == nil);
	self.currentDataTracker = currentDataTracker;
	self.currentDataTrackerHelperFunction = currentDataTrackerHelperFunction;
	if (existanceChanged) then
		self:onExistanceChange();
		self:onRegenerationChange(nil);
	end
	-- add listeners
	if (self.currentDataTracker ~= nil) then
		self.currentDataTracker:addEventListener(DHUDDataTrackerEvent.EVENT_REGENERATION_STATE_CHANGED, self, self.onRegenerationChange);
		self.currentDataTracker:addEventListener(DHUDDataTrackerEvent.EVENT_DATA_CHANGED, self, self.onDataChange);
		self.currentDataTracker:addEventListener(DHUDDataTrackerEvent.EVENT_DATA_TIMERS_UPDATED, self, self.onDataTimersChange);
		self.currentDataTracker:addEventListener(DHUDDataTrackerEvent.EVENT_RESOURCE_TYPE_CHANGED, self, self.onResourceTypeChange);
		self.currentDataTracker:addEventListener(DHUDDataTrackerEvent.EVENT_UNIT_CHANGED, self, self.onDataUnitChange);
		-- update
		self:onDataTrackerChange(nil);
		self:onDataUnitChange(nil);
		self:onRegenerationChange(nil);
		self:onDataChange(nil);
	end
	self.isChangingDataTracker = false;
end

--- Return true if this slot is regenerating something or false otherwise
function DHUDGuiSlotManager:getIsRegenerating()
	return self.isRegenerating;
end

--- Return true if this slot shows some data, false otherwise
function DHUDGuiSlotManager:getIsExists()
	return self.currentDataTracker ~= nil;
end

--- Return unitId that is being tracked by this slot manager
function DHUDGuiSlotManager:getTrackedUnitId()
	if (self.currentDataTracker == nil) then
		return "";
	end
	return self.currentDataTracker.trackUnitId;
end

---------------------
-- Gui Bar Manager --
---------------------

--- Class to manage single bar
DHUDGuiBarManager = MCCreateSubClass(DHUDGuiSlotManager, {
	-- group with bar to be used when displaying data
	group		= nil,
	-- reference to bar animation helper
	helper		= nil,
	-- reference to group text field
	textField	= nil,
	-- table with value ids
	valuesInfo	= nil,
	-- table with value heights
	valuesHeight = nil,
	-- reference to update func
	updateFunc	= nil,
	-- id of the unit from DHUDColorizeTools constants
	unitColorId = 0,
	-- defines if health shields should be visible in ui
	STATIC_showHealthShield = true,
	-- defines if health heal absorb should be visible in ui
	STATIC_showHealthHealAbsorb = true,
	-- defines if health heal incoming should be visible in ui
	STATIC_showHealthHealIncoming = true,
	-- power points value and priority
	VALUE_TYPE_POWER = 1,
	VALUE_INFO_POWER = { 1, 1 },
	-- health points value and priority
	VALUE_TYPE_HEALTH = 2,
	VALUE_INFO_HEALTH = { 2, 1 },
	-- health absorb value and priority
	VALUE_TYPE_HEALTH_ABSORB = 3,
	VALUE_INFO_HEALTH_ABSORB = { 3, 2 },
	-- health shield value and priority
	VALUE_TYPE_HEALTH_SHIELD = 4,
	VALUE_INFO_HEALTH_SHIELD = { 4, 3 },
	-- health incomming heal and priority
	VALUE_TYPE_HEALTH_HEAL_INCOMMING = 5,
	VALUE_INFO_HEALTH_HEAL_INCOMMING = { 5, 4 },
	-- custom data value and priority
	VALUE_TYPE_CUSTOMDATA = 6,
	VALUE_INFO_CUSTOMDATA = { 6, 1 },
	-- values info for health
	VALUES_INFO_HEALTH = { },
	-- values info for resources
	VALUES_INFO_RESOURCES = { },
	-- values info for custom data like vengeance
	VALUES_INFO_CUSTOMDATA = { },
	-- map with functions that are available to output health to text
	FUNCTIONS_MAP_HEALTH = { },
	-- map with functions that are available to output power to text
	FUNCTIONS_MAP_POWER = { },
	-- map with functions that are available to output power to text
	FUNCTIONS_MAP_CUSTOMDATA = { },
})

--- show health shield setting has changed
function DHUDGuiBarManager:STATIC_onShowHealthShieldsSetting(e)
	self.STATIC_showHealthShield = DHUDSettings:getValue("healthBarOptions_showShields");
end

--- show health shield setting has changed
function DHUDGuiBarManager:STATIC_onShowHealthHealAbsorbSetting(e)
	self.STATIC_showHealthHealAbsorb = DHUDSettings:getValue("healthBarOptions_showHealAbsorb");
end

--- show health shield setting has changed
function DHUDGuiBarManager:STATIC_onShowHealthHealIncomingSetting(e)
	self.STATIC_showHealthHealIncoming = DHUDSettings:getValue("healthBarOptions_showHealIncoming");
end

--- Initialize DHUDGuiBarManager static values
function DHUDGuiBarManager:STATIC_init()
	table.insert(self.VALUES_INFO_HEALTH, self.VALUE_INFO_HEALTH);
	table.insert(self.VALUES_INFO_HEALTH, self.VALUE_INFO_HEALTH_ABSORB);
	table.insert(self.VALUES_INFO_HEALTH, self.VALUE_INFO_HEALTH_SHIELD);
	table.insert(self.VALUES_INFO_HEALTH, self.VALUE_INFO_HEALTH_HEAL_INCOMMING);
	table.insert(self.VALUES_INFO_RESOURCES, self.VALUE_INFO_POWER);
	-- listen to settings change events
	DHUDSettings:addEventListener(DHUDSettingsEvent.EVENT_SPECIFIC_SETTING_CHANGED_PREFIX .. "healthBarOptions_showShields", self, self.STATIC_onShowHealthShieldsSetting);
	DHUDSettings:addEventListener(DHUDSettingsEvent.EVENT_SPECIFIC_SETTING_CHANGED_PREFIX .. "healthBarOptions_showHealAbsorb", self, self.STATIC_onShowHealthHealAbsorbSetting);
	DHUDSettings:addEventListener(DHUDSettingsEvent.EVENT_SPECIFIC_SETTING_CHANGED_PREFIX .. "healthBarOptions_showHealIncoming", self, self.STATIC_onShowHealthHealIncomingSetting);
	self:STATIC_onShowHealthShieldsSetting(nil);
	self:STATIC_onShowHealthHealAbsorbSetting(nil);
	self:STATIC_onShowHealthHealIncomingSetting(nil);
	-- init functions map
	self.FUNCTIONS_MAP_HEALTH["amount"] = self.createTextAmount;
	self.FUNCTIONS_MAP_HEALTH["amount_extra"] = self.createTextAmountHealthShield;
	self.FUNCTIONS_MAP_HEALTH["amount_habsorb"] = self.createTextAmountHealthHealAbsorb;
	self.FUNCTIONS_MAP_HEALTH["amount_hincome"] = self.createTextAmountHealthHealIncoming;
	self.FUNCTIONS_MAP_HEALTH["amount_max"] = self.createTextAmountMax;
	self.FUNCTIONS_MAP_HEALTH["amount_percent"] = self.createTextAmountPercent;
	self.FUNCTIONS_MAP_HEALTH["color"] = DHUDTextTools.createTextColorizeStart;
	self.FUNCTIONS_MAP_HEALTH["/color"] = DHUDTextTools.createTextColorizeStop;
	self.FUNCTIONS_MAP_HEALTH["color_amount"] = self.createTextColorizeAmountHealthStart;
	self.FUNCTIONS_MAP_HEALTH["color_amount_extra"] = self.createTextColorizeAmountHealthShieldStart;
	self.FUNCTIONS_MAP_HEALTH["color_amount_habsorb"] = self.createTextColorizeAmountHealthHealAbsorbStart;
	self.FUNCTIONS_MAP_HEALTH["color_amount_hincome"] = self.createTextColorizeAmountHealthHealIncomingStart;
	-- power
	self.FUNCTIONS_MAP_POWER["amount"] = self.createTextAmount;
	self.FUNCTIONS_MAP_POWER["amount_max"] = self.createTextAmountMax;
	self.FUNCTIONS_MAP_POWER["amount_percent"] = self.createTextAmountPercent;
	self.FUNCTIONS_MAP_POWER["color"] = DHUDTextTools.createTextColorizeStart;
	self.FUNCTIONS_MAP_POWER["/color"] = DHUDTextTools.createTextColorizeStop;
	self.FUNCTIONS_MAP_POWER["color_amount"] = self.createTextColorizeAmountPowerStart;
end

--- Create new bar manager
function DHUDGuiBarManager:new()
	local o = self:defconstructor();
	o:constructor();
	return o;
end

--- Construct bar manager
function DHUDGuiBarManager:constructor()
	self.valuesHeight = { };
	DHUDGuiSlotManager.constructor(self); -- call super
end

--- Colorize bar according to value height
-- @param valueType type of the value
-- @param valueHeight height of the value
function DHUDGuiBarManager:colorizeBar(valueType, valueHeight)
	local colors;
	-- get colors table
	if (valueType == self.VALUE_TYPE_HEALTH) then
		if (self.currentDataTracker.noCreditForKill) then
			colors = DHUDColorizeTools:getColorTableForId(DHUDColorizeTools.COLOR_ID_TYPE_HEALTH_NOTTAPPED + self.unitColorId);
		else
			colors = DHUDColorizeTools:getColorTableForId(DHUDColorizeTools.COLOR_ID_TYPE_HEALTH + self.unitColorId);
		end
	elseif (valueType == self.VALUE_TYPE_HEALTH_SHIELD) then
		colors = DHUDColorizeTools:getColorTableForId(DHUDColorizeTools.COLOR_ID_TYPE_HEALTH_SHIELD + self.unitColorId);
	elseif (valueType == self.VALUE_TYPE_HEALTH_ABSORB) then
		colors = DHUDColorizeTools:getColorTableForId(DHUDColorizeTools.COLOR_ID_TYPE_HEALTH_ABSORB + self.unitColorId);
	elseif (valueType == self.VALUE_TYPE_HEALTH_HEAL_INCOMMING) then
		colors = DHUDColorizeTools:getColorTableForId(DHUDColorizeTools.COLOR_ID_TYPE_HEALTH_INCOMINGHEAL + self.unitColorId);
	elseif (valueType == self.VALUE_TYPE_POWER) then
		colors = DHUDColorizeTools:getColorTableForPower(self.currentDataTracker.unitId, self.currentDataTracker.resourceType);
	else
		colors = DHUDColorizeTools.colors_default;
	end
	-- colorize
	return DHUDColorizeTools:colorizePercentUsingTable(valueHeight, colors);
end

--- Create text that contains data amount, prefixed if specified
-- @param this reference to this bar manager (self is nil)
-- @param prefix for text
-- @param precision number of digits to use after comma, if not nil, than number will be printed as float
-- @return text to be shown in gui
function DHUDGuiBarManager:createTextAmount(this, prefix, precision)
	local value = this.currentDataTracker.amount;
	local valueMax = this.currentDataTracker.amountMax;
	if (prefix ~= nil) then
		if (value > 0) then
			return prefix .. (precision and DHUDTextTools:formatNumberWithPrecision(value, precision) or DHUDTextTools:formatNumber(value, nil, valueMax));
		end
		return "";
	end
	return (precision and DHUDTextTools:formatNumberWithPrecision(value, precision) or DHUDTextTools:formatNumber(value, nil, valueMax));
end

--- Create text that contains data amount extra, prefixed if specified
-- @param this reference to this bar manager (self is nil)
-- @param prefix for text
-- @param precision number of digits to use after comma, if not nil, than number will be printed as float
-- @return text to be shown in gui
function DHUDGuiBarManager:createTextAmountExtra(this, prefix, precision)
	local value = this.currentDataTracker.amountExtra;
	local valueMax = this.currentDataTracker.amountMax;
	if (prefix ~= nil) then
		if (value > 0) then
			return prefix .. (precision and DHUDTextTools:formatNumberWithPrecision(value, precision) or DHUDTextTools:formatNumber(value, nil, valueMax));
		end
		return "";
	end
	return (precision and DHUDTextTools:formatNumberWithPrecision(value, precision) or DHUDTextTools:formatNumber(value, nil, valueMax));
end

--- Create text that contains data amount max, prefixed if specified
-- @param this reference to this bar manager (self is nil)
-- @param prefix for text
-- @param precision number of digits to use after comma, if not nil, than number will be printed as float
-- @return text to be shown in gui
function DHUDGuiBarManager:createTextAmountMax(this, prefix, precision)
	local value = this.currentDataTracker.amountMax;
	local valueMax = value;
	if (prefix ~= nil) then
		if (value > 0) then
			return prefix .. (precision and DHUDTextTools:formatNumberWithPrecision(value, precision) or DHUDTextTools:formatNumber(value, nil, valueMax));
		end
		return "";
	end
	return (precision and DHUDTextTools:formatNumberWithPrecision(value, precision) or DHUDTextTools:formatNumber(value, nil, valueMax));
end

--- Create text that contains data amount max, prefixed if specified
-- @param this reference to this bar manager (self is nil)
-- @param prefix for text
-- @param precision number of digits to use after comma, if not nil, than number will be printed as float
-- @return text to be shown in gui
function DHUDGuiBarManager:createTextAmountPercent(this, prefix, precision)
	local value = math.floor(this.currentDataTracker.amount * 100 / this.currentDataTracker.amountMax);
	if (prefix ~= nil) then
		if (value > 0) then
			return prefix .. (precision and DHUDTextTools:formatNumberWithPrecision(value, precision) or DHUDTextTools:formatNumber(value, nil, valueMax));
		end
		return "";
	end
	return (precision and DHUDTextTools:formatNumberWithPrecision(value, precision) or DHUDTextTools:formatNumber(value, nil, valueMax));
end

--- Create text that contains data amount extra, prefixed if specified
-- @param this reference to this bar manager (self is nil)
-- @param prefix for text
-- @param precision number of digits to use after comma, if not nil, than number will be printed as float
-- @return text to be shown in gui
function DHUDGuiBarManager:createTextAmountHealthShield(this, prefix, precision)
	local value = this:getHealthShield();
	local valueMax = this.currentDataTracker.amountMax;
	if (prefix ~= nil) then
		if (value > 0) then
			return prefix .. (precision and DHUDTextTools:formatNumberWithPrecision(value, precision) or DHUDTextTools:formatNumber(value, nil, valueMax));
		end
		return "";
	end
	return (precision and DHUDTextTools:formatNumberWithPrecision(value, precision) or DHUDTextTools:formatNumber(value, nil, valueMax));
end

--- Create text that contains data amount heal absorb, prefixed if specified
-- @param this reference to this bar manager (self is nil)
-- @param prefix for text
-- @param precision number of digits to use after comma, if not nil, than number will be printed as float
-- @return text to be shown in gui
function DHUDGuiBarManager:createTextAmountHealthHealAbsorb(this, prefix, precision)
	local value = this:getHealthHealAbsorb();
	local valueMax = this.currentDataTracker.amountMax;
	if (prefix ~= nil) then
		if (value > 0) then
			return prefix .. (precision and DHUDTextTools:formatNumberWithPrecision(value, precision) or DHUDTextTools:formatNumber(value, nil, valueMax));
		end
		return "";
	end
	return(precision and DHUDTextTools:formatNumberWithPrecision(value, precision) or DHUDTextTools:formatNumber(value, nil, valueMax));
end

--- Create text that contains data amount heal incoming, prefixed if specified
-- @param this reference to this bar manager (self is nil)
-- @param prefix for text
-- @param precision number of digits to use after comma, if not nil, than number will be printed as float
-- @return text to be shown in gui
function DHUDGuiBarManager:createTextAmountHealthHealIncoming(this, prefix, precision)
	local value = this:getHealthHealIncoming();
	local valueMax = this.currentDataTracker.amountMax;
	if (prefix ~= nil) then
		if (value > 0) then
			return prefix .. (precision and DHUDTextTools:formatNumberWithPrecision(value, precision) or DHUDTextTools:formatNumber(value, nil, valueMax));
		end
		return "";
	end
	return (precision and DHUDTextTools:formatNumberWithPrecision(value, precision) or DHUDTextTools:formatNumber(value, nil, valueMax));
end

--- Create text that will colorize text after it in amount color
-- @param this reference to this bar manager (self is nil)
-- @return text to be shown in gui
function DHUDGuiBarManager:createTextColorizeAmountHealthStart(this)
	local value = this.currentDataTracker.amount / this.currentDataTracker.amountMax;
	return DHUDColorizeTools:colorToColorizeString(this:colorizeBar(this.VALUE_TYPE_HEALTH, value));
end

--- Create text that will colorize text after it in amount color
-- @param this reference to this bar manager (self is nil)
-- @return text to be shown in gui
function DHUDGuiBarManager:createTextColorizeAmountPowerStart(this)
	local value = this.currentDataTracker.amount / this.currentDataTracker.amountMax;
	return DHUDColorizeTools:colorToColorizeString(this:colorizeBar(this.VALUE_TYPE_POWER, 1));
end

--- Create text that will colorize text after it in amount health shield color
-- @param this reference to this bar manager (self is nil)
-- @return text to be shown in gui
function DHUDGuiBarManager:createTextColorizeAmountHealthShieldStart(this)
	local value = this:getHealthShield() / this.currentDataTracker.amountMax;
	return DHUDColorizeTools:colorToColorizeString(this:colorizeBar(this.VALUE_TYPE_HEALTH_SHIELD, value));
end

--- Create text that will colorize text after it in amount health shield color
-- @param this reference to this bar manager (self is nil)
-- @return text to be shown in gui
function DHUDGuiBarManager:createTextColorizeAmountHealthHealAbsorbStart(this)
	local value = this:getHealthHealAbsorb() / this.currentDataTracker.amountMax;
	return DHUDColorizeTools:colorToColorizeString(this:colorizeBar(this.VALUE_TYPE_HEALTH_ABSORB, value));
end

--- Create text that will colorize text after it in amount health shield color
-- @param this reference to this bar manager (self is nil)
-- @return text to be shown in gui
function DHUDGuiBarManager:createTextColorizeAmountHealthHealIncomingStart(this)
	local value = this:getHealthHealIncoming() / this.currentDataTracker.amountMax;
	return DHUDColorizeTools:colorToColorizeString(this:colorizeBar(this.VALUE_TYPE_HEALTH_HEAL_INCOMMING, value));
end

--- Get health shield amount if settings allow this
function DHUDGuiBarManager:getHealthShield()
	return self.STATIC_showHealthShield and self.currentDataTracker.amountExtra or 0;
end

--- Get health heal absorb amount if settings allow this
function DHUDGuiBarManager:getHealthHealAbsorb()
	return self.STATIC_showHealthHealAbsorb and self.currentDataTracker.amountHealAbsorb or 0;
end

--- Get health heal incoming amount if settings allow this
function DHUDGuiBarManager:getHealthHealIncoming()
	return self.STATIC_showHealthHealIncoming and self.currentDataTracker.amountHealIncoming or 0;
end

--- Function to update health on bar and in the text
function DHUDGuiBarManager:updateHealth()
	-- amount total
	local amountTotal = self.currentDataTracker.amountMax;
	local absorbed = self:getHealthHealAbsorb();
	local amount = self.currentDataTracker.amount;
	local amountNonAbsorbed = amount - absorbed;
	local amountShield = self:getHealthShield();
	local amountHeal = self:getHealthHealIncoming();
	-- heal can't go over total health
	if (amountHeal + amount > amountTotal) then
		amountHeal = amountTotal - amount;
	end
	-- calculate amount total plus absorbed
	local amountTotalPlusAbsorbed = amountTotal;
	if (amount + self.currentDataTracker.amountExtraMax > amountTotal) then
		amountTotalPlusAbsorbed = amount + self.currentDataTracker.amountExtraMax;
	end
	-- update heights
	self.valuesHeight[1] = amountNonAbsorbed / amountTotalPlusAbsorbed;
	self.valuesHeight[2] = absorbed / amountTotalPlusAbsorbed;
	self.valuesHeight[3] = amountShield / amountTotalPlusAbsorbed;
	self.valuesHeight[4] = amountHeal / amountTotalPlusAbsorbed;
	-- significant height
	local heightSignificant = amountTotal / amountTotalPlusAbsorbed;
	-- update gui
	self.helper:updateBar(self.valuesInfo, self.valuesHeight, heightSignificant);
	-- update text
	self.textField:DSetText(self.textFormatFunction());
end

--- Function to update power on bar and in the text
function DHUDGuiBarManager:updatePower()
	-- amount total
	local amountTotal = self.currentDataTracker.amountMax;
	local amount = self.currentDataTracker.amount;
	-- update heights
	self.valuesHeight[1] = amount / amountTotal;
	-- update gui
	self.helper:updateBar(self.valuesInfo, self.valuesHeight, 1);
	-- update text
	self.textField:DSetText(self.textFormatFunction());
end

--- current data tracker data changed
function DHUDGuiBarManager:onDataChange(e)
	self.updateFunc(self);
end

--- new data tracker has been set for this slot, update if neccesary
function DHUDGuiBarManager:onDataTrackerChange(e)
	-- changed to track health
	if (self.currentDataTracker:isInstanceOf(DHUDHealthTracker)) then
		-- set update func and values info to health
		self.updateFunc = self.updateHealth;
		self.valuesInfo = self.VALUES_INFO_HEALTH;
		-- switch by unit type
		if (self.currentDataTracker.trackUnitId == "player") then
			self.unitColorId = DHUDColorizeTools.COLOR_ID_UNIT_SELF;
			self:setTextFormatParams("unitTexts_player_health", self.FUNCTIONS_MAP_HEALTH);
		elseif (self.currentDataTracker.trackUnitId == "pet") then
			self.unitColorId = DHUDColorizeTools.COLOR_ID_UNIT_PET;
			self:setTextFormatParams("unitTexts_pet_health", self.FUNCTIONS_MAP_HEALTH);
		else
			self.unitColorId = DHUDColorizeTools.COLOR_ID_UNIT_TARGET;
			self:setTextFormatParams("unitTexts_target_health", self.FUNCTIONS_MAP_HEALTH);
		end
	elseif (self.currentDataTracker:isInstanceOf(DHUDPowerTracker)) then
		self.updateFunc = self.updatePower;
		self.valuesInfo = self.VALUES_INFO_RESOURCES;
		-- switch by unit type
		if (self.currentDataTracker.trackUnitId == "player") then
			self.unitColorId = DHUDColorizeTools.COLOR_ID_UNIT_SELF;
			-- main power text
			if (self.currentDataTracker:isInstanceOf(DHUDMainPowerTracker)) then
				self:setTextFormatParams("unitTexts_player_power", self.FUNCTIONS_MAP_POWER);
			-- alternative power text
			elseif (self.currentDataTracker:isInstanceOf(DHUDSpecificPowerTracker)) then
				self:setTextFormatParams("unitTexts_player_altpower", self.FUNCTIONS_MAP_POWER);
			-- other info
			else
				self:setTextFormatParams("unitTexts_player_other", self.FUNCTIONS_MAP_POWER);
			end
		elseif (self.currentDataTracker.trackUnitId == "pet") then
			self.unitColorId = DHUDColorizeTools.COLOR_ID_UNIT_PET;
			self:setTextFormatParams("unitTexts_pet_power", self.FUNCTIONS_MAP_POWER);
		else
			self.unitColorId = DHUDColorizeTools.COLOR_ID_UNIT_TARGET;
			self:setTextFormatParams("unitTexts_target_power", self.FUNCTIONS_MAP_POWER);
		end
	end
	-- resize heights array
	MCResizeTable(self.valuesHeight, #self.valuesInfo, 0);
end

--- new unit has been selected by data tracker
function DHUDGuiBarManager:onDataUnitChange(e)
	-- force all animations to be instant for one tick
	self.helper:forceInstantAnimation();
end

--- current data tracker resource type changed
function DHUDGuiBarManager:onResourceTypeChange(e)
	self.updateFunc(self);
end

--- current data tracker existance changed, check currentDataTracker variable for existance
function DHUDGuiBarManager:onExistanceChange()
	-- no data to visualize
	if (self.currentDataTracker == nil) then
		self.textField.frame:DHide();
		self.helper:hideBar();
	else
		self.textField.frame:DShow();
	end
	-- notify gui manager
	DHUDGUIManager:onSlotExistanceStateChanged();
end

--- Initialize bar manager
-- @param groupName name of the group to use
-- @param settingName name of the setting that holds data trackers list
function DHUDGuiBarManager:init(groupName, settingName)
	self.group = DHUDGUI.frameGroups[groupName];
	self.textField = self.group.text.textField;
	self.helper = self.group.helper;
	-- initialize helper
	self.helper:init(self.colorizeBar, self);
	-- initialize setting name
	self:setDataTrackerListSetting(settingName);
	-- track color settings change
	self:trackColorSettingsChanges();
end

-----------------------
-- Side Info Manager --
-----------------------

--- Class to manage single side info slot
DHUDSideInfoManager = MCCreateSubClass(DHUDGuiSlotManager, {
	-- group with runes to be used when displaying data
	runeGroup		= nil,
	-- group with spell circles to be used when displaying data
	spellCirclesGroup = nil,
	-- reference to bar animation helper
	comboPointsGroup = nil,
	-- reference to group that is currently shown
	currentGroup	= nil,
	-- reference to update func
	updateFunc	= nil,
	-- reference to update time func
	updateFuncTime	= nil,
	-- alpha of combo-points
	comboPointsAlpha = 1.0,
	-- current color table for combo-points
	comboPointsColorTable = nil,
	-- table with color exchanges for combo-points
	comboPointsColorOrder = nil,
	-- defines if player short debuffs should be colorized
	STATIC_colorizePlayerShortDebuffs = false,
	-- type of the timers to be shown in spell circles
	timersType = 3,
	-- reference to timers colorize function
	timersColorizeFunc = nil,
	-- All shown timers are player short auras
	TIMER_TYPE_PLAYER_SHORT_AURAS = 0,
	-- All shown timers are target short auras
	TIMER_TYPE_TARGET_SHORT_AURAS = 1,
	-- All shown timers are player cooldowns
	TIMER_TYPE_PLAYER_COOLDOWNS = 2,
	-- All shown auras will be unspecified
	TIMER_TYPE_OTHER = 3,
	-- default combo-point colors
	COMBO_POINT_COLOR_DEFAULT = { "ComboCircleRed", "ComboCircleRed", "ComboCircleRed", "ComboCircleOrange", "ComboCircleGreen", "ComboCirclePurple", "ComboCirclePurple", "ComboCirclePurple", "ComboCircleCyan", "ComboCircleJadeGreen" },
	-- paladin holy power combo-point colors
	COMBO_POINT_COLOR_PALADIN_HOLY_POWER = { "ComboCircleRed", "ComboCircleOrange", "ComboCircleGreen", "ComboCirclePurple", "ComboCircleCyan" },
	-- priest shadow orbs combo-point colors
	COMBO_POINT_COLOR_PRIEST_SHADOW_ORBS = { "ComboCirclePurple", "ComboCirclePurple", "ComboCirclePurple" },
	-- warlock soul shards combo-point colors
	COMBO_POINT_COLOR_WARLOCK_SOUL_SHARDS = { "ComboCirclePurple", "ComboCirclePurple", "ComboCirclePurple" },
	-- monk chi combo-point colors
	COMBO_POINT_COLOR_MONK_CHI = { "ComboCircleJadeGreen", "ComboCircleJadeGreen", "ComboCircleJadeGreen", "ComboCircleJadeGreen", "ComboCircleJadeGreen" },
	-- list with rune type to texture name
	RUNES_TYPE_TO_TEXTURE_NAME = {
		["1"] = "BlizzardDeathKnightRuneBlood",
		["2"] = "BlizzardDeathKnightRuneUnholy",
		["3"] = "BlizzardDeathKnightRuneFrost",
		["4"] = "BlizzardDeathKnightRuneDeath",
	},
})

--- show health shield setting has changed
function DHUDSideInfoManager:STATIC_onColorizePlayerDebuffs(e)
	self.STATIC_colorizePlayerShortDebuffs = DHUDSettings:getValue("shortAurasOptions_colorizePlayerDebuffs");
end

--- Initialize DHUDGuiBarManager static values
function DHUDSideInfoManager:STATIC_init()
	-- listen to settings change events
	DHUDSettings:addEventListener(DHUDSettingsEvent.EVENT_SPECIFIC_SETTING_CHANGED_PREFIX .. "shortAurasOptions_colorizePlayerDebuffs", self, self.STATIC_onColorizePlayerDebuffs);
	self:STATIC_onColorizePlayerDebuffs(nil);
end

--- Create new side info manager
function DHUDSideInfoManager:new()
	local o = self:defconstructor();
	o:constructor();
	return o;
end

--- Construct side info manager
function DHUDSideInfoManager:constructor()
	self.comboPointsColorOrder = { };
	DHUDGuiSlotManager.constructor(self); -- call super
end

--- Change current frames group to another
-- @param currentGroup new frame group to control
function DHUDSideInfoManager:setCurrentGroup(currentGroup)
	-- hide previous group
	if (self.currentGroup ~= nil) then
		self.currentGroup:setFramesShown(0);
	end
	self.currentGroup = currentGroup;
end

--- Changes color of combo-points to table specified
-- @param colorTable table with names of the color textures
function DHUDSideInfoManager:changeComboPointColors(colorTable)
	if (self.comboPointsColorTable == colorTable and #self.comboPointsColorOrder == 0) then
		return;
	end
	self.comboPointsColorTable = colorTable;
	-- iterate over table
	for i, v in ipairs(colorTable) do 
		local comboFrame = self.currentGroup[i];
		-- get texture path and crop info
		local path, x0, x1, y0, y1 = unpack(DHUDGUI.textures[v]);
		-- get texture
		local texture = comboFrame.texture;
		-- set texture and coordinates
		texture:SetTexture(path);
		texture:SetTexCoord(x0, x1, y0, y1); -- parameters: minX, maxX, minY, maxY
	end
	-- hide all colorized frames
	self.currentGroup:setFramesShown(0);
	-- change order info to default
	MCResizeTable(self.comboPointsColorOrder, 0, -1);
end

--- Echanges combo-points colors within current table
-- @param ... list with color indexes (start1, end1, start2, end2, ...)
function DHUDSideInfoManager:changeComboPointColorOrder(...)
	local num = select("#", ...);
	MCResizeTable(self.comboPointsColorOrder, num, -1);
	-- check if we have the same order?
	local v2;
	local same = true;
	for i, v in ipairs(self.comboPointsColorOrder) do
		local v2 = select(i, ...);
		if (v ~= v2) then
			same = false;
			self.comboPointsColorOrder[i] = v2;
		end
	end
	-- nothing to change
	if (same == true) then
		return;
	end
	-- change color order
	local comboIndex = 1;
	local orderIndex = 1;
	local indexS, indexE;
	while (true) do
		indexS = self.comboPointsColorOrder[orderIndex];
		indexE = self.comboPointsColorOrder[orderIndex + 1];
		orderIndex = orderIndex + 2;
		if (indexE == nil) then
			return;
		end
		-- colorize with exchanged colors
		for i = indexS, indexE, 1 do
			-- get texture path and crop info
			local path, x0, x1, y0, y1 = unpack(DHUDGUI.textures[self.comboPointsColorTable[i]]);
			-- get texture
			local texture = self.currentGroup[comboIndex].texture;
			-- set texture and coordinates
			texture:SetTexture(path);
			texture:SetTexCoord(x0, x1, y0, y1); -- parameters: minX, maxX, minY, maxY
			-- update index
			comboIndex = comboIndex + 1;
		end
	end
end

--- Changes alpha of combo-points to alpha specified
-- @param alpha required alpha
function DHUDSideInfoManager:changeComboPointsAlpha(alpha)
	if (self.comboPointsAlpha == alpha) then
		return;
	end
	self.comboPointsAlpha = alpha;
	for i, v in ipairs(self.currentGroup) do 
		-- get texture
		local texture = v.texture;
		-- set combo-points alpha
		v:SetAlpha(alpha);
	end
end

--- Shows tooltip for circle frame specified
-- @param circleFrame circle frame to show tooltip for
function DHUDSideInfoManager:showSpellCircleTooltip(circleFrame)
	local data = circleFrame.data;
	local type = data[1];
	--print("show tooltip for " .. MCTableToString(data));
	if (self.currentDataTracker:isInstanceOf(DHUDAurasTracker)) then
		if (bit.band(type, DHUDAurasTracker.TIMER_TYPE_MASK_BUFF) ~= 0) then
			GameTooltip:SetUnitBuff(self.currentDataTracker.unitId, data[5]);
		elseif (bit.band(type, DHUDAurasTracker.TIMER_TYPE_MASK_DEBUFF) ~= 0) then
			GameTooltip:SetUnitDebuff(self.currentDataTracker.unitId, data[5]);
		end
	elseif (self.currentDataTracker:isInstanceOf(DHUDCooldownsTracker)) then
		if (bit.band(type, DHUDCooldownsTracker.TIMER_TYPE_MASK_SPELL) ~= 0) then
			GameTooltip:SetSpellByID(data[5]);
		elseif (bit.band(type, DHUDCooldownsTracker.TIMER_TYPE_MASK_ITEM) ~= 0) then
			GameTooltip:SetInventoryItem(self.currentDataTracker.unitId, data[5]);
		end
	end
end

--- Function to colorize target short auras timer
-- @param timer timer info to colorize
-- @return table with color
function DHUDSideInfoManager:colorizeTargetShortAurasTimer(timer)
	local t;
	if (bit.band(timer[1], DHUDAurasTracker.TIMER_TYPE_MASK_IS_CAST_BY_PLAYER) ~= 0) then
		t = DHUDColorizeTools:getColorTableForId(DHUDColorizeTools.COLOR_ID_UNIT_TARGET + DHUDColorizeTools.COLOR_ID_TYPE_SHORTAURA_APPLIED_BY_PLAYER);
	elseif (bit.band(timer[1], DHUDAurasTracker.TIMER_TYPE_MASK_DEBUFF) ~= 0) then
		t = DHUDColorizeTools:getColorTableForId(DHUDColorizeTools.COLOR_ID_UNIT_TARGET + DHUDColorizeTools.COLOR_ID_TYPE_SHORTAURA_DEBUFF);
	else
		t = DHUDColorizeTools:getColorTableForId(DHUDColorizeTools.COLOR_ID_UNIT_TARGET + DHUDColorizeTools.COLOR_ID_TYPE_SHORTAURA_BUFF);
	end
	return DHUDColorizeTools:colorizePercentUsingTable(timer[2] / timer[3], t);
end

--- Function to colorize player short auras timer
-- @param timer timer info to colorize
-- @return table with color
function DHUDSideInfoManager:colorizePlayerShortAurasTimer(timer)
	local t;
	if (bit.band(timer[1], DHUDAurasTracker.TIMER_TYPE_MASK_DEBUFF) ~= 0) then
		if (self.STATIC_colorizePlayerShortDebuffs) then
			if (bit.band(timer[1], DHUDAurasTracker.TIMER_TYPE_MASK_IS_MAGIC) ~= 0) then
				t = DHUDColorizeTools:getColorTableForId(DHUDColorizeTools.COLOR_ID_UNIT_SELF + DHUDColorizeTools.COLOR_ID_TYPE_SHORTAURA_DEBUFF_MAGIC);
			elseif (bit.band(timer[1], DHUDAurasTracker.TIMER_TYPE_MASK_IS_POISON) ~= 0) then
				t = DHUDColorizeTools:getColorTableForId(DHUDColorizeTools.COLOR_ID_UNIT_SELF + DHUDColorizeTools.COLOR_ID_TYPE_SHORTAURA_DEBUFF_POISON);
			elseif (bit.band(timer[1], DHUDAurasTracker.TIMER_TYPE_MASK_IS_CURSE) ~= 0) then
				t = DHUDColorizeTools:getColorTableForId(DHUDColorizeTools.COLOR_ID_UNIT_SELF + DHUDColorizeTools.COLOR_ID_TYPE_SHORTAURA_DEBUFF_CURSE);
			elseif (bit.band(timer[1], DHUDAurasTracker.TIMER_TYPE_MASK_IS_DISEASE) ~= 0) then
				t = DHUDColorizeTools:getColorTableForId(DHUDColorizeTools.COLOR_ID_UNIT_SELF + DHUDColorizeTools.COLOR_ID_TYPE_SHORTAURA_DEBUFF_DISEASE);
			else
				t = DHUDColorizeTools:getColorTableForId(DHUDColorizeTools.COLOR_ID_UNIT_SELF + DHUDColorizeTools.COLOR_ID_TYPE_SHORTAURA_DEBUFF);
			end
		else
			t = DHUDColorizeTools:getColorTableForId(DHUDColorizeTools.COLOR_ID_UNIT_SELF + DHUDColorizeTools.COLOR_ID_TYPE_SHORTAURA_DEBUFF);
		end
	else
		t = DHUDColorizeTools:getColorTableForId(DHUDColorizeTools.COLOR_ID_UNIT_SELF + DHUDColorizeTools.COLOR_ID_TYPE_SHORTAURA_BUFF);
	end
	return DHUDColorizeTools:colorizePercentUsingTable(timer[2] / timer[3], t);
end

--- Function to colorize player cooldown timer
-- @param timer timer info to colorize
-- @return table with color
function DHUDSideInfoManager:colorizePlayerCooldownsTimer(timer)
	local t;
	if (bit.band(timer[1], DHUDCooldownsTracker.TIMER_TYPE_MASK_SPELL) ~= 0) then
		t = DHUDColorizeTools:getColorTableForId(DHUDColorizeTools.COLOR_ID_UNIT_SELF + DHUDColorizeTools.COLOR_ID_TYPE_COOLDOWN_SPELL);
	else
		t = DHUDColorizeTools:getColorTableForId(DHUDColorizeTools.COLOR_ID_UNIT_SELF + DHUDColorizeTools.COLOR_ID_TYPE_COOLDOWN_ITEM);
	end
	return DHUDColorizeTools:colorizePercentUsingTable(timer[2] / timer[3], t);
end

--- Function to colorize timer
-- @param timer timer info to colorize
-- @return table with color
function DHUDSideInfoManager:colorizeUnknownTimer(timer)
	local t = DHUDColorizeTools:getColorTableForId(DHUDColorizeTools.COLOR_ID_TYPE_UNKNOWN);
	return DHUDColorizeTools:colorizePercentUsingTable(timer[2] / timer[3], t);
end

--- Function to update spell circle data
-- @param timers list with timers
function DHUDSideInfoManager:updateSpellCircles(timers)
	timers = timers or self.currentDataTracker:filterTimers(self.currentDataTrackerHelperFunction, self.dataTrackersListSettingName, true);
	self.currentGroup:setFramesShown(#timers);
	self:setIsRegenerating(#timers > 0); -- update regeneration since results are filtered
	-- update icons and times, { type, timeLeft, duration, id, tooltipId, name, stacks, texture, exists, iterating, sortOrder }
	for i, v in ipairs(timers) do
		local spellCircleFrame = self.currentGroup[i];
		spellCircleFrame.data = v;
		spellCircleFrame:SetNormalTexture(v[8]);
		-- colorize
		local color = self.timersColorizeFunc(self, v);
		spellCircleFrame.border:SetVertexColor(color[1], color[2], color[3]);
		-- update text
		local time = (v[2] >= 0) and (DHUDColorizeTools:colorToColorizeString(color) .. DHUDTextTools:formatTime(v[2]) .. "|r") or "";
		spellCircleFrame.textFieldTime:DSetText(time);
		local stackText = (v[7] > 1) and (DHUDColorizeTools:colorToColorizeString(color) .. v[7] .. "|r") or "";
		spellCircleFrame.textFieldCount:DSetText(stackText);
		
	end
end

--- Function to update spell circle times
function DHUDSideInfoManager:updateSpellCirclesTime()
	local timers, changed = self.currentDataTracker:filterTimers(self.currentDataTrackerHelperFunction, self.dataTrackersListSettingName);
	if (changed) then
		self:updateSpellCircles(timers);
		return;
	end
	-- update icons and times, { type, timeLeft, duration, id, tooltipId, name, stacks, texture, exists, iterating, sortOrder }
	for i, v in ipairs(timers) do
		local spellCircleFrame = self.currentGroup[i];
		-- colorize
		local color = self.timersColorizeFunc(self, v);
		spellCircleFrame.border:SetVertexColor(color[1], color[2], color[3]);
		-- update text
		local time = (v[2] >= 0) and (DHUDColorizeTools:colorToColorizeString(color) .. DHUDTextTools:formatTime(v[2]) .. "|r") or "";
		spellCircleFrame.textFieldTime:DSetText(time);
	end
end

--- Function to update runes data
function DHUDSideInfoManager:updateRunes()
	local runesInfo = self.currentDataTracker.runes;
	local frame;
	for i, v in ipairs(runes) do
		frame = self.group[i];
		-- change texture
		if (frame.runeType ~= v[1]) then
			frame.runeType = v[1];
			local texture = frame.texture;
			local textureName = self.RUNES_TYPE_TO_TEXTURE_NAME[v[1]];
			-- get texture path and update frame
			local path, x0, x1, y0, y1 = unpack(self.textures[textureName]);
			texture:SetTexture(path);
			texture:SetTexCoord(x0, x1, y0, y1);
		end
		-- update time left
		local time = (v[2] >= 0) and DHUDTextTools:formatTime(v[2]) or "*";
		frame.textFieldTime:DSetText(time);
	end
end

--- Function to update runes time
function DHUDSideInfoManager:updateRunesTime()
	local runesInfo = self.currentDataTracker.runes;
	local frame;
	for i, v in ipairs(runes) do
		frame = self.group[i];
		-- update time left
		local time = (v[2] >= 0) and DHUDTextTools:formatTime(v[2]) or "*";
		frame.textFieldTime:DSetText(time);
	end
end

--- Function to update combo-points data
function DHUDSideInfoManager:updateComboPoints()
	local amount = self.currentDataTracker.amount;
	local amountExtra = self.currentDataTracker.amountExtra;
	local total = amount + amountExtra;
	-- update colors
	if (amount >= 5) then
		self:changeComboPointColorOrder(1, 5, 6, 10);
	else
		self:changeComboPointColorOrder(1, amount, 6, 10);
	end
	self.currentGroup:setFramesShown(amount + amountExtra);
	-- change alpha for stored combo-points
	local alpha = self.currentDataTracker.isStoredAmount and 0.5 or 1.0;
	self:changeComboPointsAlpha(alpha);
end

--- Function to update general data that is displayed as combo-points
function DHUDSideInfoManager:updateComboPointsGeneral()
	local amount = self.currentDataTracker.amount;
	self.currentGroup:setFramesShown(amount);
end

--- nil function to update time (does nothing)
function DHUDSideInfoManager:updateNilTime()
end

--- current data tracker regeneration state changed
function DHUDSideInfoManager:onDataChange(e)
	self.updateFunc(self);
end

--- current data tracker timers changed
function DHUDSideInfoManager:onDataTimersChange(e)
	self.updateFuncTime(self);
end

--- new data tracker has been set for this slot, update if neccesary
function DHUDSideInfoManager:onDataTrackerChange(e)
	-- changed to track spell circle like info
	if (self.currentDataTracker:isInstanceOf(DHUDTimersTracker)) then
		-- set update func and values info to health
		self.updateFunc = self.updateSpellCircles;
		self.updateFuncTime = self.updateSpellCirclesTime;
		self:setCurrentGroup(self.spellCirclesGroup);
		-- update timers type
		if (self.currentDataTracker == DHUDDataTrackers.ALL.selfCooldowns) then
			self.timersType = self.TIMER_TYPE_PLAYER_COOLDOWNS;
			self.timersColorizeFunc = self.colorizePlayerCooldownsTimer;
		elseif (self.currentDataTracker == DHUDDataTrackers.ALL.targetAuras and self.currentDataTrackerHelperFunction == DHUDTimersFilterHelperSettingsHandler.filterTargetShortAuras) then
			self.timersType = self.TIMER_TYPE_TARGET_SHORT_AURAS;
			self.timersColorizeFunc = self.colorizeTargetShortAurasTimer;
		elseif (self.currentDataTracker == DHUDDataTrackers.ALL.selfAuras and self.currentDataTrackerHelperFunction == DHUDTimersFilterHelperSettingsHandler.filterPlayerShortAuras) then
			self.timersType = self.TIMER_TYPE_PLAYER_SHORT_AURAS;
			self.timersColorizeFunc = self.colorizePlayerShortAurasTimer;
		else
			self.timersType = self.TIMER_TYPE_OTHER;
			self.timersColorizeFunc = self.colorizeUnknownTimer;
		end
	-- changed to track death-knight runes
	elseif (self.currentDataTracker == DHUDDataTrackers.DEATHKNIGHT.selfRunes) then
		self.updateFunc = self.updateRunes;
		self.updateFuncTime = self.updateRunesTime;
		self:setCurrentGroup(self.runeGroup);
	-- changed to track combo-points like info
	else
		self.updateFuncTime = self.updateNilTime;
		self:setCurrentGroup(self.comboPointsGroup);
		-- switch by type
		if (self.currentDataTracker == DHUDDataTrackers.ALL.selfComboPoints) then
			self.updateFunc = self.updateComboPoints;
			self:changeComboPointColors(self.COMBO_POINT_COLOR_DEFAULT);
		else
			self.updateFunc = self.updateComboPointsGeneral;
			if (self.currentDataTracker == DHUDDataTrackers.MONK.selfChi) then
				self:changeComboPointColors(self.COMBO_POINT_COLOR_MONK_CHI);
			elseif (self.currentDataTracker == DHUDDataTrackers.PALADIN.selfHolyPower) then
				self:changeComboPointColors(self.COMBO_POINT_COLOR_PALADIN_HOLY_POWER);
			elseif (self.currentDataTracker == DHUDDataTrackers.PRIEST.selfShadowOrbs) then
				self:changeComboPointColors(self.COMBO_POINT_COLOR_PRIEST_SHADOW_ORBS);
			elseif (self.currentDataTracker == DHUDDataTrackers.WARLOCK.selfSoulShards) then
				self:changeComboPointColors(self.COMBO_POINT_COLOR_WARLOCK_SOUL_SHARDS);
			else
				self:changeComboPointColors(self.COMBO_POINT_COLOR_DEFAULT);
			end
		end
		-- change combo-points alpha
		self:changeComboPointsAlpha(1.0);
	end
end

--- current data tracker existance changed, check currentDataTracker variable for existance
function DHUDSideInfoManager:onExistanceChange()
	-- no data to visualize
	if (self.currentDataTracker == nil) then
		self:setCurrentGroup(nil);
	end
end

--- Initialize side info manager
-- @param runeGroupName name of the group with runes to use
-- @param spellCirclesGroupName name of the group with spell circles to use
-- @param comboPointsGroupName name of the group with combo points to use
-- @param settingName name of the setting that holds data trackers list
function DHUDSideInfoManager:init(runeGroupName, spellCirclesGroupName, comboPointsGroupName, settingName)
	self.runeGroup = DHUDGUI.frameGroups[runeGroupName];
	self.spellCirclesGroup = DHUDGUI.frameGroups[spellCirclesGroupName];
	self.comboPointsGroup = DHUDGUI.frameGroups[comboPointsGroupName];
	-- initialize setting name
	self:setDataTrackerListSetting(settingName);
	-- track color settings change (for spell circles)
	self:trackColorSettingsChanges();
end

-----------------------
-- Unit Info Manager --
-----------------------

--- Class to manage single side info slot
DHUDUnitInfoManager = MCCreateSubClass(DHUDGuiSlotManager, {
	-- reference to text frame that is used to display information
	textFrame		= nil,
	-- map with functions that will generate info
	FUNCTIONS_MAP_INFO = { },
})

--- Initialize DHUDGuiBarManager static values
function DHUDUnitInfoManager:STATIC_init()
	-- fill functions map
	self.FUNCTIONS_MAP_INFO["level"] = self.createTextLevel;
	self.FUNCTIONS_MAP_INFO["elite"] = self.createTextElite;
	self.FUNCTIONS_MAP_INFO["name"] = self.createTextName;
	self.FUNCTIONS_MAP_INFO["class"] = self.createTextClass;
	self.FUNCTIONS_MAP_INFO["guild"] = self.createTextGuild;
	self.FUNCTIONS_MAP_INFO["pvp"] = self.createTextPvP;
	self.FUNCTIONS_MAP_INFO["color"] = DHUDTextTools.createTextColorizeStart;
	self.FUNCTIONS_MAP_INFO["/color"] = DHUDTextTools.createTextColorizeStop;
	self.FUNCTIONS_MAP_INFO["color_level"] = self.createTextColorLevel;
	self.FUNCTIONS_MAP_INFO["color_reaction"] = self.createTextColorReaction;
	self.FUNCTIONS_MAP_INFO["color_class"] = self.createTextColorClass;
end

--- Create new unit info manager
function DHUDUnitInfoManager:new()
	local o = self:defconstructor();
	o:constructor();
	return o;
end

--- Construct unit info manager
function DHUDUnitInfoManager:constructor()
	DHUDGuiSlotManager.constructor(self); -- call super
end

--- Toggle unit dropdown list
-- @param frame frame that was clicked on
function DHUDUnitInfoManager:toggleUnitTextDropdown(frame)
	if (self:getTrackedUnitId() == "target") then
		ToggleDropDownMenu(1, nil, DHUD_DropDown_TargetMenu, frame, 25, 10); 
	end
end

--- Create text that contains unit level
-- @param this reference to this bar manager (self is nil)
-- @return text to be shown in gui
function DHUDUnitInfoManager:createTextLevel(this)
	local value = this.currentDataTracker.level;
	if (value < 0) then
		return "??"
	end
	return value;
end

--- Create text that contains unit elite type
-- @param this reference to this bar manager (self is nil)
-- @return text to be shown in gui
function DHUDUnitInfoManager:createTextElite(this)
	local value = this.currentDataTracker.eliteType;
	local community = this.currentDataTracker.communityTagged;
	local prefix = community and "*" or "";
	if (value == DHUDUnitInfoTracker.UNIT_ELITE_TYPE_BOSS) then
		return prefix .. "++";
	elseif (value == DHUDUnitInfoTracker.UNIT_ELITE_TYPE_RAREELITE) then
		return prefix .. "r+";
	elseif (value == DHUDUnitInfoTracker.UNIT_ELITE_TYPE_ELITE) then
		return prefix .. "+";
	elseif (value == DHUDUnitInfoTracker.UNIT_ELITE_TYPE_RARE) then
		return prefix .. "r";
	elseif (value == DHUDUnitInfoTracker.UNIT_ELITE_TYPE_BOSS) then
		return prefix .. "++";
	elseif (value == DHUDUnitInfoTracker.UNIT_ELITE_TYPE_MINION) then
		return prefix .. "-";
	else
		return prefix;
	end
end

--- Create text that contains unit name
-- @param this reference to this bar manager (self is nil)
-- @return text to be shown in gui
function DHUDUnitInfoManager:createTextName(this)
	local value = this.currentDataTracker.name;
	return value;
end

--- Create text that contains unit class
-- @param this reference to this bar manager (self is nil)
-- @return text to be shown in gui
function DHUDUnitInfoManager:createTextClass(this)
	local type = this.currentDataTracker.type;
	if (type == DHUDUnitInfoTracker.UNIT_TYPE_OTHER) then
		return this.currentDataTracker.npcType;
	elseif (type == DHUDUnitInfoTracker.UNIT_TYPE_PET) then
		return "Pet";
	elseif (type == DHUDUnitInfoTracker.UNIT_TYPE_ALLY_NPC) then
		return "NPC";
	else
		return this.currentDataTracker.class;
	end
end

--- Create text that contains unit guild
-- @param this reference to this bar manager (self is nil)
-- @param prefix prefix to use
-- @param postfix postfix to use
-- @return text to be shown in gui
function DHUDUnitInfoManager:createTextGuild(this, prefix, postfix)
	prefix = prefix or "";
	postfix = postfix or "";
	local value = this.currentDataTracker.guild;
	if (value ~= "") then
		return prefix .. value .. postfix;
	end
	return value;
end

--- Create text that contains unit pvp status
-- @param this reference to this bar manager (self is nil)
-- @return text to be shown in gui
function DHUDUnitInfoManager:createTextPvP(this)
	local value = this.currentDataTracker.pvpState;
	if (value ~= DHUDUnitInfoTracker.UNIT_PVP_STATE_OFF) then
		return "PvP";
	end
	return "";
end

--- Create text that will colorize text after it in level color
-- @param this reference to this bar manager (self is nil)
-- @return text to be shown in gui
function DHUDUnitInfoManager:createTextColorLevel(this)
	local value = this.currentDataTracker.level;
	local colors = DHUDColorizeTools:colorizeByLevelDifficulty(value);
	return DHUDColorizeTools:colorToColorizeString(colors);
end

--- Create text that will colorize text after it in reaction color
-- @param this reference to this bar manager (self is nil)
-- @return text to be shown in gui
function DHUDUnitInfoManager:createTextColorReaction(this)
	local relation = this.currentDataTracker.relation;
	local canAttack = this.currentDataTracker.canAttack;
	local type = this.currentDataTracker.type;
	local reactionId = 0;
	if (type == DHUDUnitInfoTracker.UNIT_TYPE_PLAYER) then
		if (this.currentDataTracker.pvpState ~= DHUDUnitInfoTracker.UNIT_PVP_STATE_OFF) then
			if (canAttack) then
				reactionId = DHUDColorizeTools.REACTION_ID_HOSTILE;
			else
				reactionId = DHUDColorizeTools.REACTION_ID_FRIENDLY_PLAYER_PVP;
			end
		else
			if (canAttack or this.currentDataTracker.isDifferentPvPFaction) then
				reactionId = DHUDColorizeTools.REACTION_ID_NEUTRAL;
			else
				reactionId = DHUDColorizeTools.REACTION_ID_FRIENDLY_PLAYER;
			end
		end
	else
		if (not this.currentDataTracker.tagged) then
			reactionId = DHUDColorizeTools.REACTION_ID_HOSTILE_NOT_TAPPED;
		elseif (relation == DHUDUnitInfoTracker.UNIT_RELATION_HOSTILE) then
			reactionId = DHUDColorizeTools.REACTION_ID_HOSTILE;
		elseif (relation == DHUDUnitInfoTracker.UNIT_RELATION_FRIENDLY) then
			reactionId = DHUDColorizeTools.REACTION_ID_FRIENDLY;
		else
			reactionId = DHUDColorizeTools.REACTION_ID_NEUTRAL;
		end
	end
	local colors = DHUDColorizeTools:colorizeByReaction(reactionId);
	return DHUDColorizeTools:colorToColorizeString(colors);
end

--- Create text that will colorize text after it in class color
-- @param this reference to this bar manager (self is nil)
-- @return text to be shown in gui
function DHUDUnitInfoManager:createTextColorClass(this)
	local value = this.currentDataTracker.classEng;
	local colors = DHUDColorizeTools:colorizeByClass(value);
	return DHUDColorizeTools:colorToColorizeString(colors);
end

--- current data tracker data changed
function DHUDUnitInfoManager:onDataChange(e)
	self.textFrame.textField:DSetText(self.textFormatFunction());
end

--- new data tracker has been set for this slot, update if neccesary
function DHUDUnitInfoManager:onDataTrackerChange(e)
	if (self.currentDataTracker == DHUDDataTrackers.ALL.targetOfTargetInfo) then
		self:setTextFormatParams("unitTexts_targettarget_info", self.FUNCTIONS_MAP_INFO);
	else
		self:setTextFormatParams("unitTexts_target_info", self.FUNCTIONS_MAP_INFO);
	end
	-- update mouse eligability for frame
	local enableMouse = self:getTrackedUnitId() == "target";
	self.textFrame:EnableMouse(enableMouse);
end

--- current data tracker existance changed, check currentDataTracker variable for existance
function DHUDUnitInfoManager:onExistanceChange()
	-- no data to visualize
	if (self.currentDataTracker == nil) then
		self.textFrame:DHide();
	else
		self.textFrame:DShow();
	end
end

--- Initialize unit info manager
-- @param textFrameName name of the text frame to use
-- @param settingName name of the setting that holds data trackers list
function DHUDUnitInfoManager:init(textFrameName, settingName)
	self.textFrame = DHUDGUI.frames[textFrameName];
	-- initialize setting name
	self:setDataTrackerListSetting(settingName);
end

------------------------------
-- Spell rectangles Manager --
------------------------------

--- Class to manage single side info slot
DHUDSpellRectanglesManager = MCCreateSubClass(DHUDGuiSlotManager, {
	-- group with spell rectangles to be used when displaying data
	group = nil,
	-- type of the auras to be shown in spell rectangles
	aurasType = 2,
	-- reference to timers colorize function
	timersColorizeFunc = nil,
	-- allows to show buff timers on spell rectangles
	STATIC_showBuffTimers = true,
	-- allows to show debuff timers on spell rectangles
	STATIC_showDebuffTimers = true,
	-- All shown auras will be buffs
	AURAS_TYPE_BUFFS = 0,
	-- All shown auras will be debuffs
	AURAS_TYPE_DEBUFFS = 1,
	-- Auras type is not determined
	AURAS_TYPE_OTHER = 2,
})

--- buff timers settings has changed, process
function DHUDSpellRectanglesManager:STATIC_onBuffTimersSetting(e)
	self.STATIC_showBuffTimers = DHUDSettings:getValue("aurasOptions_showTimersOnTargetBuffs");
end

--- buff timers settings has changed, process
function DHUDSpellRectanglesManager:STATIC_onDebuffTimersSetting(e)
	self.STATIC_showDebuffTimers = DHUDSettings:getValue("aurasOptions_showTimersOnTargetDeBuffs");
end

--- Initialize DHUDGUIBarAnimationHelper class
function DHUDSpellRectanglesManager:STATIC_init()
	DHUDSettings:addEventListener(DHUDSettingsEvent.EVENT_SPECIFIC_SETTING_CHANGED_PREFIX .. "aurasOptions_showTimersOnTargetBuffs", self, self.STATIC_onBuffTimersSetting);
	DHUDSettings:addEventListener(DHUDSettingsEvent.EVENT_SPECIFIC_SETTING_CHANGED_PREFIX .. "aurasOptions_showTimersOnTargetDeBuffs", self, self.STATIC_onDebuffTimersSetting);
	self:STATIC_onBuffTimersSetting(nil);
	self:STATIC_onDebuffTimersSetting(nil);
end

--- Create new side info manager
function DHUDSpellRectanglesManager:new()
	local o = self:defconstructor();
	o:constructor();
	return o;
end

--- Construct side info manager
function DHUDSpellRectanglesManager:constructor()
	DHUDGuiSlotManager.constructor(self); -- call super
end

--- Shows tooltip for rectangle frame specified
-- @param rectangleFrame rectangle frame to show tooltip for
function DHUDSpellRectanglesManager:showSpellRectangleTooltip(rectangleFrame)
	local data = rectangleFrame.data;
	local type = data[1];
	--print("show tooltip for " .. MCTableToString(data));
	if (self.currentDataTracker:isInstanceOf(DHUDAurasTracker)) then
		if (bit.band(type, DHUDAurasTracker.TIMER_TYPE_MASK_BUFF) ~= 0) then
			GameTooltip:SetUnitBuff(self.currentDataTracker.unitId, data[5]);
		elseif (bit.band(type, DHUDAurasTracker.TIMER_TYPE_MASK_DEBUFF) ~= 0) then
			GameTooltip:SetUnitDebuff(self.currentDataTracker.unitId, data[5]);
		end
	elseif (self.currentDataTracker:isInstanceOf(DHUDCooldownsTracker)) then
		if (bit.band(type, DHUDCooldownsTracker.TIMER_TYPE_MASK_SPELL) ~= 0) then
			GameTooltip:SetSpellByID(data[5]);
		elseif (bit.band(type, DHUDCooldownsTracker.TIMER_TYPE_MASK_ITEM) ~= 0) then
			GameTooltip:SetInventoryItem(self.currentDataTracker.unitId, data[5]);
		end
	end
end

--- Function to colorize target buffs timer
-- @param timer timer info to colorize
-- @return table with color
function DHUDSpellRectanglesManager:colorizeTargetBuffsTimer(timer)
	local t = DHUDColorizeTools:getColorTableForId(DHUDColorizeTools.COLOR_ID_UNIT_TARGET + DHUDColorizeTools.COLOR_ID_TYPE_AURA_BUFF);
	return DHUDColorizeTools:colorizePercentUsingTable(timer[2] / timer[3], t);
end

--- Function to colorize target debuff timer
-- @param timer timer info to colorize
-- @return table with color
function DHUDSpellRectanglesManager:colorizeTargetDebuffsTimer(timer)
	local t = DHUDColorizeTools:getColorTableForId(DHUDColorizeTools.COLOR_ID_UNIT_TARGET + DHUDColorizeTools.COLOR_ID_TYPE_AURA_DEBUFF);
	return DHUDColorizeTools:colorizePercentUsingTable(timer[2] / timer[3], t);
end

--- Function to colorize timer
-- @param timer timer info to colorize
-- @return table with color
function DHUDSpellRectanglesManager:colorizeUnknownTimer(timer)
	local t = DHUDColorizeTools:getColorTableForId(DHUDColorizeTools.COLOR_ID_TYPE_UNKNOWN);
	return DHUDColorizeTools:colorizePercentUsingTable(timer[2] / timer[3], t);
end

--- defines if timers text should be shown
function DHUDSpellRectanglesManager:getIsTimersTextShown()
	if (self.aurasType == self.AURAS_TYPE_BUFFS) then
		return self.STATIC_showBuffTimers;
	elseif (self.aurasType == self.AURAS_TYPE_DEBUFFS) then
		return self.STATIC_showDebuffTimers;
	end
	return true;
end

--- Function to update spell rectangles data
-- @param timers list with timers
function DHUDSpellRectanglesManager:updateSpellRectangles(timers)
	local showTimersText = self:getIsTimersTextShown();
	timers = timers or self.currentDataTracker:filterTimers(self.currentDataTrackerHelperFunction, self.dataTrackersListSettingName, true);
	self.group:setFramesShown(#timers);
	-- update icons and times, { type, timeLeft, duration, id, tooltipId, name, stacks, texture, exists, iterating, sortOrder }
	for i, v in ipairs(timers) do
		local spellRectangleFrame = self.group[i];
		spellRectangleFrame.data = v;
		spellRectangleFrame:SetNormalTexture(v[8]);
		-- colorize
		local color = self.timersColorizeFunc(self, v);
		spellRectangleFrame.border:SetVertexColor(color[1], color[2], color[3]);
		-- update text
		local time = (showTimersText and v[2] >= 0) and (DHUDColorizeTools:colorToColorizeString(color) .. DHUDTextTools:formatTime(v[2]) .. "|r") or "";
		spellRectangleFrame.textFieldTime:DSetText(time);
		local stackText = (v[7] > 1) and (DHUDColorizeTools:colorToColorizeString(color) .. v[7] .. "|r") or "";
		spellRectangleFrame.textFieldCount:DSetText(stackText);
	end
end

--- Function to update spell circle times
function DHUDSpellRectanglesManager:updateSpellRectanglesTime()
	-- do not show text?
	local showTimersText = self:getIsTimersTextShown();
	if (not showTimersText) then
		return;
	end
	-- filter timers
	local timers, changed = self.currentDataTracker:filterTimers(self.currentDataTrackerHelperFunction, self.dataTrackersListSettingName);
	if (changed) then
		self:updateSpellRectangles(timers);
		return;
	end
	-- update icons and times, { type, timeLeft, duration, id, tooltipId, name, stacks, texture, exists, iterating, sortOrder }
	for i, v in ipairs(timers) do
		local spellRectangleFrame = self.group[i];
		-- colorize
		local color = self.timersColorizeFunc(self, v);
		spellRectangleFrame.border:SetVertexColor(color[1], color[2], color[3]);
		-- update text
		local time = (v[2] >= 0) and (DHUDColorizeTools:colorToColorizeString(color) .. DHUDTextTools:formatTime(v[2]) .. "|r") or "";
		spellRectangleFrame.textFieldTime:DSetText(time);
	end
end

--- current data tracker data changed
function DHUDSpellRectanglesManager:onDataChange(e)
	self:updateSpellRectangles();
end

--- current data tracker timers changed
function DHUDSpellRectanglesManager:onDataTimersChange(e)
	self:updateSpellRectanglesTime();
end

--- new data tracker has been set for this slot, update if neccesary
function DHUDSpellRectanglesManager:onDataTrackerChange(e)
	if (self.currentDataTrackerHelperFunction == DHUDTimersFilterHelperSettingsHandler.filterBuffAuras) then
		self.aurasType = self.AURAS_TYPE_BUFFS;
		self.timersColorizeFunc = self.colorizeTargetBuffsTimer;
	elseif (self.currentDataTrackerHelperFunction == DHUDTimersFilterHelperSettingsHandler.filterDebuffAuras) then
		self.aurasType = self.AURAS_TYPE_DEBUFFS;
		self.timersColorizeFunc = self.colorizeTargetDebuffsTimer;
	else
		self.aurasType = self.AURAS_TYPE_OTHER;
		self.timersColorizeFunc = self.colorizeUnknownTimer;
	end
end

--- current data tracker existance changed, check currentDataTracker variable for existance
function DHUDSpellRectanglesManager:onExistanceChange()
	-- no data to visualize
	if (self.currentDataTracker == nil) then
		self.group:setFramesShown(0);
	end
end

--- Initialize side info manager
-- @param spellRectanglesGroupName name of the group with spell circles to use
-- @param settingName name of the setting that holds data trackers list
function DHUDSpellRectanglesManager:init(spellRectanglesGroupName, settingName)
	self.group = DHUDGUI.frameGroups[spellRectanglesGroupName];
	-- initialize setting name
	self:setDataTrackerListSetting(settingName);
	-- track color settings change (for spell rectangles)
	self:trackColorSettingsChanges();
end

-------------------
-- Icons Manager --
-------------------

--- Class to manage icons
DHUDIconsManager = MCCreateClass{
	-- position id of target icons
	positionTarget	= "",
	-- position id of self icons
	positionSelf	= "",
	-- position id of dragon icon
	positionDragon	= "",
	-- reference to self pvp frame
	selfPvPFrame	= nil,
	-- reference to self state frame
	selfStateFrame	= nil,
	-- reference to target dragon frame
	targetDragonFrame = nil,
	-- reference to group with target state icons
	targetStateGroup = nil,
	-- reference to slef info tracker
	selfInfoTracker = nil,
	-- reference to target info tracker
	targetInfoTracker = nil,
}

--- Create new icons manager
function DHUDIconsManager:new()
	local o = self:defconstructor();
	o:constructor();
	return o;
end

--- construct icons manager
function DHUDIconsManager:constructor()

end

--- self data changed, update icons
function DHUDIconsManager:onSelfDataChanged(e)
	-- update state icon
	local textureName = "";
	if (self.selfInfoTracker.isInCombat) then
		textureName = "BlizzardPlayerInCombat";
	elseif (self.selfInfoTracker.isResting) then
		textureName = "BlizzardPlayerResting";
	end
	-- update texture
	if (textureName ~= "") then
		self.selfStateFrame:DShow();
		local path, x0, x1, y0, y1 = unpack(DHUDGUI.textures[textureName]);
		local texture = self.selfStateFrame.texture;
		texture:SetTexture(path);
		texture:SetTexCoord(x0, x1, y0, y1);
	else
		self.selfStateFrame:DHide();
	end
	-- update pvp
	textureName = "";
	local pvp = self.selfInfoTracker.pvpState;
	if (pvp ~= DHUDUnitInfoTracker.UNIT_PVP_STATE_OFF) then
		if (pvp == DHUDUnitInfoTracker.UNIT_PVP_STATE_FFA) then
			textureName = "BlizzardPvPArena";
		else
			local pvpFaction = self.selfInfoTracker.pvpFaction
			if (pvpFaction == DHUDUnitInfoTracker.UNIT_PVP_FACTION_ALLIANCE) then
				textureName = "BlizzardPvPAlliance";
			elseif (pvpFaction == DHUDUnitInfoTracker.UNIT_PVP_FACTION_HORDE) then
				textureName = "BlizzardPvPHorde";
			else
				textureName = "BlizzardPvPArena";
			end
		end
	end
	-- update texture
	if (textureName ~= "") then
		self.selfPvPFrame:DShow();
		local path, x0, x1, y0, y1 = unpack(DHUDGUI.textures[textureName]);
		local texture = self.selfPvPFrame.texture;
		texture:SetTexture(path);
		texture:SetTexCoord(x0, x1, y0, y1);
	else
		self.selfPvPFrame:DHide();
	end
end

--- target data changed, update icons
function DHUDIconsManager:onTargetDataChanged(e)
	-- check elite
	local elite = self.targetInfoTracker.eliteType;
	local textureName = "";
	if (elite == DHUDUnitInfoTracker.UNIT_ELITE_TYPE_BOSS or elite == DHUDUnitInfoTracker.UNIT_ELITE_TYPE_ELITE) then
		textureName = "TargetEliteDragon";
	elseif (elite == DHUDUnitInfoTracker.UNIT_ELITE_TYPE_RAREELITE or elite == DHUDUnitInfoTracker.UNIT_ELITE_TYPE_RARE) then
		textureName = "TargetRareDragon";
	end
	-- update dragon texture
	if (textureName ~= "") then
		self.targetDragonFrame:DShow();
		local texturePath = DHUDGUI.textures[textureName][1];
		self.targetDragonFrame.texture:SetTexture(texturePath);
	else
		self.targetDragonFrame:DHide();
	end
	-- update target icons
	local numIcons = 0;
	local pvp = self.targetInfoTracker.pvpState;
	if (pvp ~= DHUDUnitInfoTracker.UNIT_PVP_STATE_OFF) then
		numIcons = numIcons + 1;
		if (pvp == DHUDUnitInfoTracker.UNIT_PVP_STATE_FFA) then
			textureName = "BlizzardPvPArena";
		else
			local pvpFaction = self.targetInfoTracker.pvpFaction
			if (pvpFaction == DHUDUnitInfoTracker.UNIT_PVP_FACTION_ALLIANCE) then
				textureName = "BlizzardPvPAlliance";
			elseif (pvpFaction == DHUDUnitInfoTracker.UNIT_PVP_FACTION_HORDE) then
				textureName = "BlizzardPvPHorde";
			else
				textureName = "BlizzardPvPArena";
			end
		end
		local path, x0, x1, y0, y1 = unpack(DHUDGUI.textures[textureName]);
		local texture = self.targetStateGroup[numIcons].texture;
		-- set texture and coordinates
		texture:SetTexture(path);
		texture:SetTexCoord(x0, x1, y0, y1);
	end
	local raidIcon = self.targetInfoTracker.raidIcon;
	if (raidIcon ~= 0) then
		numIcons = numIcons + 1;
		textureName = "BlizzardRaidIcon" .. raidIcon;
		local path, x0, x1, y0, y1 = unpack(DHUDGUI.textures[textureName]);
		local texture = self.targetStateGroup[numIcons].texture;
		-- set texture and coordinates
		texture:SetTexture(path);
		texture:SetTexCoord(x0, x1, y0, y1);
	end
	-- show and reposition icons
	self.targetStateGroup:setFramesShown(numIcons);
	self.targetStateGroup.reposition(DHUDGUI);
end

--- Initialize side info manager
-- @param spellRectanglesGroupName name of the group with spell circles to use
-- @param settingName name of the setting that holds data trackers list
function DHUDIconsManager:init(selfPvPFrameName, selfStateFrameName, targetDragonFrameName, targetStateGroupName)
	self.selfPvPFrame = DHUDGUI.frames[selfPvPFrameName];
	self.selfStateFrame = DHUDGUI.frames[selfStateFrameName];
	self.targetDragonFrame = DHUDGUI.frames[targetDragonFrameName];
	self.targetStateGroup = DHUDGUI.frameGroups[targetStateGroupName];
	-- track icons data
	self.selfInfoTracker = DHUDDataTrackers.ALL.selfInfo;
	self.selfInfoTracker:addEventListener(DHUDDataTrackerEvent.EVENT_DATA_CHANGED, self, self.onSelfDataChanged);
	self.targetInfoTracker = DHUDDataTrackers.ALL.targetInfo;
	self.targetInfoTracker:addEventListener(DHUDDataTrackerEvent.EVENT_DATA_CHANGED, self, self.onTargetDataChanged);
	self:onSelfDataChanged(nil);
	self:onTargetDataChanged(nil);
end

--------------------------
-- Gui Cast Bar Manager --
--------------------------

--- Class to manage single bar
DHUDCastBarManager = MCCreateSubClass(DHUDGuiSlotManager, {
	-- group with cast bar to be used when displaying data
	group		= nil,
	-- reference to cast bar animation helper
	helper		= nil,
	-- defines if data exists?
	isExists	= false,
	-- id of the unit from DHUDColorizeTools constants
	unitColorId = 0,
	-- map with functions that are available to output cast info to text
	FUNCTIONS_MAP_CASTINFO = { },
})

--- Initialize DHUDGuiBarManager static values
function DHUDCastBarManager:STATIC_init()
	-- init functions map
	self.FUNCTIONS_MAP_CASTINFO["color"] = DHUDTextTools.createTextColorizeStart;
	self.FUNCTIONS_MAP_CASTINFO["/color"] = DHUDTextTools.createTextColorizeStop;
	self.FUNCTIONS_MAP_CASTINFO["time"] = self.createTextTime;
	self.FUNCTIONS_MAP_CASTINFO["time_remain"] = self.createTextTimeRemain;
	self.FUNCTIONS_MAP_CASTINFO["time_total"] = self.createTextTimeTotal;
	self.FUNCTIONS_MAP_CASTINFO["delay"] = self.createTextDelay;
	self.FUNCTIONS_MAP_CASTINFO["spellname"] = self.createTextSpellName;
end

--- Create new bar manager
function DHUDCastBarManager:new()
	local o = self:defconstructor();
	o:constructor();
	return o;
end

--- Construct bar manager
function DHUDCastBarManager:constructor()
	DHUDGuiSlotManager.constructor(self); -- call super
end

--- Create text that contains data cast time
-- @param this reference to this bar manager (self is nil)
-- @return text to be shown in gui
function DHUDCastBarManager:createTextTime(this)
	local value = this.currentDataTracker.timeProgress;
	if (value < 0) then
		value = 0;
	end
	return DHUDTextTools:formatNumberWithPrecision(value, 1);
end

--- Create text that contains data remaining cast time
-- @param this reference to this bar manager (self is nil)
-- @return text to be shown in gui
function DHUDCastBarManager:createTextTimeRemain(this)
	local value;
	if (not this.currentDataTracker.isChannelSpell) then
		value = this.currentDataTracker.timeTotal - this.currentDataTracker.timeProgress;
	else
		value = this.currentDataTracker.timeProgress;
	end
	if (value < 0) then
		value = 0;
	end
	return DHUDTextTools:formatNumberWithPrecision(value, 1);
end

--- Create text that contains data total cast time
-- @param this reference to this bar manager (self is nil)
-- @return text to be shown in gui
function DHUDCastBarManager:createTextTimeTotal(this)
	local value = this.currentDataTracker.timeTotal;
	return DHUDTextTools:formatNumberWithPrecision(value, 1);
end

--- Create text that contains data cast delay
-- @param this reference to this bar manager (self is nil)
-- @return text to be shown in gui
function DHUDCastBarManager:createTextDelay(this)
	local value = this.currentDataTracker.delay;
	if (value <= 0) then
		return "";
	end
	return DHUDTextTools:formatNumberWithPrecision(value, 1);
end

--- Create text that contains data cast spell name
-- @param this reference to this bar manager (self is nil)
-- @param interruptedText text to be shown when spell was interrupted
-- @param canceledText text to be shown when spell was canceled
-- @return text to be shown in gui
function DHUDCastBarManager:createTextSpellName(this, interruptedText, canceledText)
	interruptedText = interruptedText or "|cff0000ffINTERRUPTED|r";
	canceledText = canceledText or "|cff0000ffCANCELED|r";
	local value = this.currentDataTracker.spellName;
	local finishState = this.currentDataTracker.finishState;
	if (not this.currentDataTracker.isCasting) then
		if (finishState == DHUDSpellCastTracker.SPELL_FINISH_STATE_INTERRUPTED) then
			value = interruptedText
		end
	end
	return value;
end

--- Colorize cast bar according to value height
-- @param valueHeight height of the value
function DHUDCastBarManager:colorizeCastBar(valueHeight)
	local colors;
	-- return another color if interrupted
	if (not self.currentDataTracker.isCasting) then
		if (self.currentDataTracker.finishState == DHUDSpellCastTracker.SPELL_FINISH_STATE_INTERRUPTED) then
			colors = DHUDColorizeTools:getColorTableForId(DHUDColorizeTools.COLOR_ID_TYPE_CASTBAR_INTERRUPTED + self.unitColorId);
			return DHUDColorizeTools:colorizePercentUsingTable(valueHeight, colors);
		end
	end
	-- get colors table
	if (self.currentDataTracker.isChannelSpell) then
		if (self.currentDataTracker.isInterruptible) then
			colors = DHUDColorizeTools:getColorTableForId(DHUDColorizeTools.COLOR_ID_TYPE_CASTBAR_CHANNEL + self.unitColorId);
		else
			colors = DHUDColorizeTools:getColorTableForId(DHUDColorizeTools.COLOR_ID_TYPE_CASTBAR_LOCKED_CHANNEL + self.unitColorId);
		end
	else
		if (self.currentDataTracker.isInterruptible) then
			colors = DHUDColorizeTools:getColorTableForId(DHUDColorizeTools.COLOR_ID_TYPE_CASTBAR_CAST + self.unitColorId);
		else
			colors = DHUDColorizeTools:getColorTableForId(DHUDColorizeTools.COLOR_ID_TYPE_CASTBAR_LOCKED_CAST + self.unitColorId);
		end
	end
	-- colorize
	return DHUDColorizeTools:colorizePercentUsingTable(valueHeight, colors);
end

--- Get current cast time progress
function DHUDCastBarManager:getCurrentCastTime()
	return self.currentDataTracker:getTimeProgress();
end

--- current data tracker data changed
function DHUDCastBarManager:onDataChange(e)
	-- check if atleast one cast was used
	if (not self.isExists) then
		if (self.currentDataTracker.hasCasted) then
			self.isExists = true;
			DHUDGUIManager:onSlotExistanceStateChanged();
		end
	end
	-- update text
	self.group[DHUDGUI.CASTBAR_GROUP_INDEX_CASTTIME].textField:DSetText(self.textFormatTimeFunction());
	self.group[DHUDGUI.CASTBAR_GROUP_INDEX_DELAY].textField:DSetText(self.textFormatDelayFunction());
	self.group[DHUDGUI.CASTBAR_GROUP_INDEX_SPELLNAME].textField:DSetText(self.textFormatSpellNameFunction());
	-- update icon
	local icon = self.group[DHUDGUI.CASTBAR_GROUP_INDEX_ICON];
	icon:SetNormalTexture(self.currentDataTracker.spellTexture);
	if (self.currentDataTracker.isInterruptible) then
		icon.border:Hide();
	else
		icon.border:Show();
	end
	-- update animation state
	if (self.currentDataTracker.isCasting) then
		self.helper:startCastBarAnimation(self.currentDataTracker.timeTotal);
	else
		local finishState = self.currentDataTracker.finishState;
		if (finishState == DHUDSpellCastTracker.SPELL_FINISH_STATE_SUCCEDED) then
			self.helper:flashAndFadeOut();
		elseif (finishState == DHUDSpellCastTracker.SPELL_FINISH_STATE_INTERRUPTED) then
			self.helper:holdAndFadeOut();
		else -- unknown state or unit is not casting
			self.helper:hideCastBar();
		end
	end
end

--- current data tracker timers changed
function DHUDCastBarManager:onDataTimersChange(e)
	-- update time text
	self.group[DHUDGUI.CASTBAR_GROUP_INDEX_CASTTIME].textField:DSetText(self.textFormatTimeFunction());
end

--- new data tracker has been set for this slot, update if neccesary
function DHUDCastBarManager:onDataTrackerChange(e)
	-- switch by unit type
	if (self.currentDataTracker.trackUnitId == "player") then
		self.unitColorId = DHUDColorizeTools.COLOR_ID_UNIT_SELF;
		self:setTextFormatParamsForVariable("unitTexts_player_castTime", self.FUNCTIONS_MAP_CASTINFO, "textFormatTimeFunction");
		self:setTextFormatParamsForVariable("unitTexts_player_castDelay", self.FUNCTIONS_MAP_CASTINFO, "textFormatDelayFunction");
		self:setTextFormatParamsForVariable("unitTexts_player_castSpellName", self.FUNCTIONS_MAP_CASTINFO, "textFormatSpellNameFunction");
	else
		self.unitColorId = DHUDColorizeTools.COLOR_ID_UNIT_TARGET;
		self:setTextFormatParamsForVariable("unitTexts_target_castTime", self.FUNCTIONS_MAP_CASTINFO, "textFormatTimeFunction");
		self:setTextFormatParamsForVariable("unitTexts_target_castDelay", self.FUNCTIONS_MAP_CASTINFO, "textFormatDelayFunction");
		self:setTextFormatParamsForVariable("unitTexts_target_castSpellName", self.FUNCTIONS_MAP_CASTINFO, "textFormatSpellNameFunction");
	end
end

--- new unit has been selected by data tracker
function DHUDCastBarManager:onDataUnitChange(e)
	-- until unit has cast bar background should be hidden, if unit has no bar in this slot, notify gui manager
	self.isExists = false;
	DHUDGUIManager:onSlotExistanceStateChanged();
end

--- current data tracker existance changed, check currentDataTracker variable for existance
function DHUDCastBarManager:onExistanceChange()
	-- no data to visualize
	if (self.currentDataTracker == nil) then
		self.helper:hideCastBar();
	end
	-- notify gui manager
	self.isExists = false;
	DHUDGUIManager:onSlotExistanceStateChanged();
end

--- Initialize cast bar manager
-- @param groupName name of the group to use
-- @param settingName name of the setting that holds data trackers list
function DHUDCastBarManager:init(groupName, settingName)
	self.group = DHUDGUI.frameGroups[groupName];
	self.helper = self.group.helper;
	-- initialize helper
	self.helper:init(self.colorizeCastBar, self.getCurrentCastTime, self);
	-- initialize setting name
	self:setDataTrackerListSetting(settingName);
	-- track color settings change
	self:trackColorSettingsChanges();
end

--- Return true if this slot shows some data, false otherwise
function DHUDCastBarManager:getIsExists()
	return self.isExists;
end

-----------------
-- GUI Manager --
-----------------

--- Class to control graphical user interface
DHUDGUIManager = {
	-- defines if gui is in regenerating state, required to change alpha
	isRegenerating		= false,
	-- defines if player is in combat
	isInCombat			= false,
	-- defines if player turned auto-attack on
	isAttacking			= false,
	-- defines if player is dead
	isDead				= false,
	-- defines if player has target selected
	hasTarget			= false,
	-- manager of the left inner big bar
	leftBigBar1			= nil,
	-- manager of the left outer big bar
	leftBigBar2			= nil,
	-- manager of the left inner small bar
	leftSmallBar1		= nil,
	-- manager of the right inner big bar
	rightBigBar1		= nil,
	-- manager of the right outer big bar
	rightBigBar2		= nil,
	-- manager of the left inner small bar
	rightSmallBar1		= nil,
	-- list with bar managers
	barManagers			= nil,
	-- manager of the left inner big cast bar
	leftBigCastBar1		= nil,
	-- manager of the left outer big cast bar
	leftBigCastBar2		= nil,
	-- manager of the right inner big cast bar
	rightBigCastBar1	= nil,
	-- manager of the right outer big cast bar
	rightBigCastBar2	= nil,
	-- list with cast bar managers
	castBarManagers		= nil,
	-- manager of left outer side info
	leftOuterSideInfo	= nil,
	-- manager of left inner side info
	leftInnerSideInfo	= nil,
	-- manager of right outer side info
	rightOuterSideInfo	= nil,
	-- manager of right inner side info
	rightInnerSideInfo	= nil,
	-- list with side info managers
	sideManagers = nil,
	-- manager of top unit info
	centerUnitInfo1		= nil,
	-- manager of bottom unit info
	centerUnitInfo2		= nil,
	-- list with unit info managers
	unitInfoManagers = nil,
	-- manager of left rectangles
	leftRectangles = nil,
	-- manager of left rectangles
	rightRectangles = nil,
	-- list with rectangle frame managers
	rectangleManagers = nil,
	-- manager for icons
	icons				= nil,
	-- current alpha type
	alphaType = 0,
	-- alpha type for situation when player in combat
	ALPHA_TYPE_INCOMBAT	= 1,
	-- alpha type for situation when player is out of combat, but has target
	ALPHA_TYPE_HASTARGET = 2,
	-- alpha type for situation when player is out of combat, without target, but resources are regenerating
	ALPHA_TYPE_REGENERATING = 3,
	-- alpha type for situation when player is out of combat and no other condition is met
	ALPHA_TYPE_OTHER	= 4,
	-- values of alpha for different alpha types, readed from settings
	ALPHA_VALUES = { },
}

--- Initialize DHUD gui manager, providing data to frames
function DHUDGUIManager:init()
	DHUDGuiBarManager:STATIC_init();
	DHUDUnitInfoManager:STATIC_init();
	DHUDSideInfoManager:STATIC_init();
	DHUDCastBarManager:STATIC_init();
	-- create bar managers
	self.leftBigBar1 = DHUDGuiBarManager:new();
	self.leftBigBar2 = DHUDGuiBarManager:new();
	self.leftSmallBar1 = DHUDGuiBarManager:new();
	self.rightBigBar1 = DHUDGuiBarManager:new();
	self.rightBigBar2 = DHUDGuiBarManager:new();
	self.rightSmallBar1 = DHUDGuiBarManager:new();
	self.barManagers = { self.leftBigBar1, self.leftBigBar2, self.leftSmallBar1, self.rightBigBar1, self.rightBigBar2, self.rightSmallBar1 };
	-- create cast bar managers
	self.leftBigCastBar1 = DHUDCastBarManager:new();
	self.leftBigCastBar2 = DHUDCastBarManager:new();
	self.rightBigCastBar1 = DHUDCastBarManager:new();
	self.rightBigCastBar2 = DHUDCastBarManager:new();
	self.castBarManagers = { self.leftBigCastBar1, self.leftBigCastBar2, self.rightBigCastBar1, self.rightBigCastBar2 };
	-- create side info managers
	self.leftOuterSideInfo = DHUDSideInfoManager:new();
	self.leftInnerSideInfo = DHUDSideInfoManager:new();
	self.rightOuterSideInfo = DHUDSideInfoManager:new();
	self.rightInnerSideInfo = DHUDSideInfoManager:new();
	self.sideManagers = { self.leftOuterSideInfo, self.leftInnerSideInfo, self.rightOuterSideInfo, self.rightInnerSideInfo };
	-- create unit info managers
	self.centerUnitInfo1 = DHUDUnitInfoManager:new();
	self.centerUnitInfo2 = DHUDUnitInfoManager:new();
	self.unitInfoManagers = { self.centerUnitInfo1, self.centerUnitInfo2 };
	-- create rectangle frame managers
	self.leftRectangles = DHUDSpellRectanglesManager:new();
	self.rightRectangles = DHUDSpellRectanglesManager:new();
	self.rectangleManagers = { self.leftRectangles, self.rightRectangles };
	-- create icons manager
	self.icons = DHUDIconsManager:new();
	-- track alpha settings
	self:processAlphaSetting(self.ALPHA_TYPE_INCOMBAT, "alpha_combat");
	self:processAlphaSetting(self.ALPHA_TYPE_HASTARGET, "alpha_hasTarget");
	self:processAlphaSetting(self.ALPHA_TYPE_REGENERATING, "alpha_regen");
	self:processAlphaSetting(self.ALPHA_TYPE_OTHER, "alpha_outOfCombat");
	-- track values required to change alpha and visibility
	DHUDDataTrackers.helper:addEventListener(DHUDDataTrackerHelperEvent.EVENT_COMBAT_STATE_CHANGED, self, self.onCombatState);
	DHUDDataTrackers.helper:addEventListener(DHUDDataTrackerHelperEvent.EVENT_TARGET_UPDATED, self, self.onTargetUpdated);
	DHUDDataTrackers.helper:addEventListener(DHUDDataTrackerHelperEvent.EVENT_ATTACK_STATE_CHANGED, self, self.onAttackState);
	DHUDDataTrackers.helper:addEventListener(DHUDDataTrackerHelperEvent.EVENT_DEATH_STATE_CHANGED, self, self.onDeathState);
	self:onAttackState(nil);
	self:onCombatState(nil);
	self:onTargetUpdated(nil);
	self:onDeathState(nil);
	-- init slot managers
	self.leftBigBar1:init("leftBigBar1", "framesData_leftBigBar1");
	self.leftBigBar2:init("leftBigBar2", "framesData_leftBigBar2");
	self.leftSmallBar1:init("leftSmallBar1", "framesData_leftSmallBar1");
	self.rightBigBar1:init("rightBigBar1", "framesData_rightBigBar1");
	self.rightBigBar2:init("rightBigBar2", "framesData_rightBigBar2");
	self.rightSmallBar1:init("rightSmallBar1", "framesData_rightSmallBar1");
	self.leftBigCastBar1:init("leftBigCastBar1", "framesData_leftBigCastBar1");
	self.leftBigCastBar2:init("leftBigCastBar2", "framesData_leftBigCastBar2");
	self.rightBigCastBar1:init("rightBigCastBar1", "framesData_rightBigCastBar1");
	self.rightBigCastBar2:init("rightBigCastBar2", "framesData_rightBigCastBar2");
	self.leftOuterSideInfo:init("runesBigLeft", "spellCirclesBigLeft", "comboPointsBigLeft", "framesData_leftOuterSideInfo");
	self.leftInnerSideInfo:init("runesSmallLeft", "spellCirclesSmallLeft", "comboPointsSmallLeft", "framesData_leftInnerSideInfo");
	self.rightOuterSideInfo:init("runesBigRight", "spellCirclesBigRight", "comboPointsBigRight", "framesData_rightOuterSideInfo");
	self.rightInnerSideInfo:init("runesSmallRight", "spellCirclesSmallRight", "comboPointsSmallRight", "framesData_rightInnerSideInfo");
	self.centerUnitInfo1:init("DHUD_Center_TextInfo1", "framesData_centerUnitInfo1");
	self.centerUnitInfo2:init("DHUD_Center_TextInfo2", "framesData_centerUnitInfo2");
	self.leftRectangles:init("spellRectanglesLeft", "framesData_leftRectangles");
	self.rightRectangles:init("spellRectanglesRight", "framesData_rightRectangles");
	self.icons:init("DHUD_Icon_SelfUnitIconPvP", "DHUD_Icon_SelfUnitIconState", "DHUD_Icon_TargetEliteDragon", "targetIcons");
end

--- Shows tooltip for circle frame specified
-- @param circleFrame circle frame to show tooltip for
function DHUDGUIManager:showSpellCircleTooltip(circleFrame)
	-- find group of spellcircle frame
	for i, v in ipairs(self.sideManagers) do
		if (MCIndexOfValueInTable(v.spellCirclesGroup, circleFrame) >= 0) then
			v:showSpellCircleTooltip(circleFrame);
			return;
		end
	end
end

--- Shows tooltip for rectangle frame specified
-- @param circleFrame rectangle frame to show tooltip for
function DHUDGUIManager:showSpellRectangleTooltip(rectangleFrame)
	-- find group of spellrectangle frame
	for i, v in ipairs(self.rectangleManagers) do
		if (MCIndexOfValueInTable(v.group, rectangleFrame) >= 0) then
			v:showSpellRectangleTooltip(rectangleFrame);
			return;
		end
	end
end

--- Shows unit info dropdown
-- @param frame frame that was clicked
function DHUDGUIManager:toggleUnitTextDropdown(frame)
	-- find group of spellrectangle frame
	for i, v in ipairs(self.unitInfoManagers) do
		if (v.textFrame == frame) then
			v:toggleUnitTextDropdown(frame);
			return;
		end
	end
end

--- update gui alpha according to situation
function DHUDGUIManager:updateAlpha()
	local newAlphaType = self.ALPHA_TYPE_OTHER;
	if (self.isInCombat or self.isAttacking) then
		newAlphaType = self.ALPHA_TYPE_INCOMBAT;
	elseif (self.hasTarget) then
		newAlphaType = self.ALPHA_TYPE_HASTARGET;
	elseif (self.isRegenerating) then
		newAlphaType = self.ALPHA_TYPE_REGENERATING;
	end
	if (self.alphaType == newAlphaType) then
		return;
	end
	self.alphaType = newAlphaType;
	local alpha = self.ALPHA_VALUES[self.alphaType];
	DHUDGUI:changeAlpha(alpha);
end

--- one of gui slots has changed regeneration state
function DHUDGUIManager:onSlotRegenerationStateChanged()
	local before = self.isRegenerating;
	self.isRegenerating = false;
	-- check bar managers
	for i, v in ipairs(self.barManagers) do
		self.isRegenerating = v:getTrackedUnitId() == "player" and v:getIsRegenerating();
		--print("bar unit " .. MCTableToString(v:getTrackedUnitId()) .. ", isRegen " .. MCTableToString(v:getIsRegenerating()));
		if (self.isRegenerating) then
			break;
		end
	end
	-- check side managers
	if (not self.isRegenerating) then
		for i, v in ipairs(self.sideManagers) do
			self.isRegenerating = v:getTrackedUnitId() == "player" and v:getIsRegenerating();
			--print("bar unit " .. MCTableToString(v:getTrackedUnitId()) .. ", isRegen " .. MCTableToString(v:getIsRegenerating()));
			if (self.isRegenerating) then
				break;
			end
		end
	end
	-- check cast bar managers
	if (not self.isRegenerating) then
		for i, v in ipairs(self.castBarManagers) do
			self.isRegenerating = v:getTrackedUnitId() == "player" and v:getIsRegenerating();
			--print("bar unit " .. MCTableToString(v:getTrackedUnitId()) .. ", isRegen " .. MCTableToString(v:getIsRegenerating()));
			if (self.isRegenerating) then
				break;
			end
		end
	end
	--print("set self.isRegenerating " .. MCTableToString(self.isRegenerating));
	if (before ~= self.isRegenerating) then
		self:updateAlpha();
	end
end

--- combat state changed, update alpha
function DHUDGUIManager:onCombatState(e)
	self.isInCombat = DHUDDataTrackers.helper.isInCombat;
	self:updateAlpha();
end

--- combat state changed, update alpha
function DHUDGUIManager:onAttackState(e)
	self.isAttacking = DHUDDataTrackers.helper.isAttacking;
	self:updateAlpha();
end

--- death state changed, hide or show some frames
function DHUDGUIManager:onDeathState(e)
	self.isDead = DHUDDataTrackers.helper.isDead;
	-- player is dead hide bar text frames and side info frames
	if (self.isDead) then
		-- get list of frames with player information
		local list = { };
		-- add bars text
		for i, v in ipairs(self.barManagers) do
			if (v:getTrackedUnitId() == "player") then
				table.insert(list, v.textField.frame);
			end
		end
		-- add side info frames
		for i, v in ipairs(self.sideManagers) do
			if (v:getTrackedUnitId() == "player") then
				table.insert(list, v.currentGroup);
			end
		end
		DHUDGUI:hideFramesWhenDead(list);
	else
		DHUDGUI:showFramesWhenAlive();
	end
end

--- combat state changed, update alpha
function DHUDGUIManager:onTargetUpdated(e)
	local before = self.hasTarget;
	self.hasTarget = DHUDDataTrackers.helper.isTargetAvailable;
	if (before ~= self.hasTarget) then
		self:updateAlpha();
	end
end

--- Process setting value and listen to setting changes
-- @param alphaType internal type of alpha from class consts
-- @param alphaSettingName name of the setting in Settings table
function DHUDGUIManager:processAlphaSetting(alphaType, alphaSettingName)
	local functionOnSettingChange = function(self, e)
		self.ALPHA_VALUES[alphaType] = DHUDSettings:getValue(alphaSettingName);
		if (self.alphaType == alphaType) then
			self.alphaType = 0;
			self:updateAlpha();
		end
	end
	DHUDSettings:addEventListener(DHUDSettingsEvent.EVENT_SPECIFIC_SETTING_CHANGED_PREFIX .. alphaSettingName, self, functionOnSettingChange);
	functionOnSettingChange(self, nil);
end

--- one of gui slots has changed existance state
function DHUDGUIManager:onSlotExistanceStateChanged()
	local backgroundLeft = 0;
	backgroundLeft = bit.bor(backgroundLeft, (self.leftBigBar1:getIsExists() or self.leftBigCastBar1:getIsExists()) and DHUDGUI.BACKGROUND_BAR_BIG1 or 0);
	backgroundLeft = bit.bor(backgroundLeft, (self.leftBigBar2:getIsExists() or self.leftBigCastBar2:getIsExists()) and DHUDGUI.BACKGROUND_BAR_BIG2 or 0);
	local backgroundRight = 0;
	backgroundRight = bit.bor(backgroundRight, (self.rightBigBar1:getIsExists() or self.rightBigCastBar1:getIsExists()) and DHUDGUI.BACKGROUND_BAR_BIG1 or 0);
	backgroundRight = bit.bor(backgroundRight, (self.rightBigBar2:getIsExists() or self.rightBigCastBar2:getIsExists()) and DHUDGUI.BACKGROUND_BAR_BIG2 or 0);
	-- update background
	DHUDGUI:changeBarsBackground(backgroundLeft, backgroundRight);
end