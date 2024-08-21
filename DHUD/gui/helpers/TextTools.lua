--[[-----------------------------------------------------------------------------------
 Original Drathals HUD (c) 2006 by Markus Inger / Drathal / Silberklinge / Silbersegen
 DHUD for WotLK and later expansions (c) 2013 by MADCAT (EU-Гордунни, Мадкат)
 (http://eu.battle.net/wow/en/character/гордунни/Мадкат/advanced)
---------------------------------------------------------------------------------------
 This file contains text formatting tools
 @author: MADCAT
-----------------------------------------------------------------------------------]]--

----------------
-- Text tools --
----------------

--- Class to make text changes
DHUDTextTools = {
	-- number to use as boundary to showing milliSeconds
	milliSecondsBound = 10,
	-- number of maximum allowed digits
	numberDigitsLimit = 5,
	-- Not a Number string to be used to compare number to "NaN" value, LUA doesn't have built in isNaN function
	NAN_STRING = tostring((-1)^0.5),
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
	-- check for NaN to not cause crash, sometimes API can give "NaN" as function results
	if (tostring(number) == self.NAN_STRING) then
		return "NaN";
	end
	limit = limit or self.numberDigitsLimit;
	numberRef = numberRef or number;
	local numChars = floor(log10(abs(numberRef)) + 1); -- +1 for digit below
	if (numChars <= limit) then
		return format('%d', number);
	end
	-- 0 should be present as 0
	if (number == 0) then
		return "0";
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

--- Remove server name from full player name
-- @param name full name with server name
-- @return short name without server name
function DHUDTextTools:getShortPlayerName(name)
	local indexS, indexE = strfind(name, "%-", 1); -- search for "-"
	-- special word found?
	if (indexS ~= nil) then
		name = strsub(name, 1, indexS - 1);
	end
	return name;
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
	local textFormatLength = textFormat:len();
	local indexStrBegin = 1; -- index of text to substring from before "<word>"
	local indexS = 0; -- index at which "<word>" found
	local indexE = 0; -- index at which "<word>" found
	local indexLocalArgsS = 0; -- index at which "(123, 22)" found in "<word>"
	local indexLocalArgsE = 0; -- index at which "(123, 22)" found in "<word>"
	local indexColor = 0; -- index at which "color" is found inside special keyword
	local sizeArrays = 0; -- size of the created arrays
	local arrayFunctions = { }; -- array for functions to execute
	local arrayResults = { }; -- array for functions results
	local subString = "";
	local colorFuncName = "";
	local colorFuncIndex = 0;
	local specialWord = "";
	local isInQuotes = false;
	local specialArgs = nil;
	local specialFunc = nil;
	while (true) do
		--indexS, indexE = strfind(textFormat, "<.->", indexE + 1); -- doesn't process quotes correctly
		indexS = nil; -- search for "<word>"
		for i = indexE + 1, textFormatLength do
			local symbol = textFormat:byte(i);
			if (symbol == 34) then isInQuotes = not isInQuotes;
			elseif (isInQuotes) then isInQuotes = true; -- do nothing
			elseif (symbol == 60 and indexS == nil) then indexS = i; -- <
			elseif (symbol == 62) then indexE = i; break; end; -- >
		end
		-- no more special words found, end search
		if (indexS == nil or indexS > indexE) then
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
		-- check if it's color function, optimize performance as needed
		indexColor = strfind(specialWord, "color");
		if (indexColor ~= nil and specialFunc ~= nil) then
			sizeArrays = #arrayFunctions;
			--print("isColor function " .. specialWord .. " " .. indexColor .. " num " .. #arrayFunctions);
			if (indexColor == 1) then -- colorize start
				colorFuncName = specialWord;
				colorFuncIndex = sizeArrays;
			elseif (colorFuncName ~= "color" and colorFuncName ~= "color_amount" and (sizeArrays - colorFuncIndex) == 2) then -- try to optimize it
				local funcColorStart = arrayFunctions[sizeArrays - 2];
				local funcAmount = arrayFunctions[sizeArrays - 1];
				local funcColorStop = specialFunc;
				table.remove(arrayFunctions, sizeArrays);
				table.remove(arrayFunctions, sizeArrays - 1);
				table.remove(arrayFunctions, sizeArrays - 2);
				table.remove(arrayResults, sizeArrays);
				table.remove(arrayResults, sizeArrays - 1);
				table.remove(arrayResults, sizeArrays - 2);
				-- create single function that checks amount
				--print("optimizing color function " .. colorFuncName);
				specialFunc = function(self, arg)
					local innerText = funcAmount(self, arg);
					if (innerText == "") then
						return "";
					end
					return funcColorStart(self, arg) .. innerText .. funcColorStop(self, arg);
				end
				table.insert(arrayFunctions, specialFunc);
				table.insert(arrayResults, "");
			end
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
