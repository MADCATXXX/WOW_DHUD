--[[-----------------------------------------------------------------------------------
 Original Drathals HUD (c) 2006 by Markus Inger / Drathal / Silberklinge / Silbersegen
 DHUD for WotLK and later expansions (c) 2013 by MADCAT (EU-Гордунни, Мадкат)
 (http://eu.battle.net/wow/en/character/гордунни/Мадкат/advanced)
---------------------------------------------------------------------------------------
 This file contains debug functions to debug other addons (non related to DHUD)
 Some of the addons like Bejeweled (by PopCap Games) are no longer supported, but were
 Obfuscated in order to not see their source code. This file can be used to reveal code.
 File is not included in TOC by default and should be manually used by skilled engineers
 Code should be included before debugged addon, addons are loaded alpabetically, in
 Some cases it's required to rename this addon to something else
 If you require assistance with code beautifying contact me and I might help
 @author: MADCAT
-----------------------------------------------------------------------------------]]--

-- table to which debug messages should be output
local debugMsgTable = {};
-- index of last output message
local indexSavedVar = 1;

--- Function to output debug message, print and default chat frame are not recommended as their maximum message count is low
-- instead it's better to create table in saved variabled of debugged addon, e.g. add following line to debugged addon toc:
-- ## SavedVariables: MySavedVariablesTable
-- This table can then be read via Notepad++ which is a lot better than analyzing game chat
-- Sometime it's required to manually erase table content in saved variables file before running another debug cycle
-- @param msg message to be analyzed
function MCDebugLog(msg)
	debugMsgTable[indexSavedVar] = msg;
	indexSavedVar = indexSavedVar + 1;
	--print(msg);
	--DEFAULT_CHAT_FRAME:AddMessage(msg);
end

--------------------------------------
-- Deobfuscation protection removal --
--------------------------------------

--- [[[ save original functions to local variables ]]]
local origGetFenv = getfenv;
local origSetFenv = setfenv;
local origGetMetaTable = getmetatable;
local origSetMetaTable = setmetatable;
local origRawGet = rawget;
local origRawSet = rawset;
local origCoroutineCreate = coroutine.create;
local origCoroutineWrap = coroutine.wrap;
local origPcall = pcall;
local origXPcall = xpcall;
local origCollectGarbage = collectgarbage;
local origError = error;
local origToString = tostring;
local origStringFormat = string.format;
local origStringFind = string.find;
local origStringSub = string.sub;
local origPrint = print;
local origLoad = load;
local origLoadString = loadstring;
local origGlobalFenv = getfenv(0);
local origGlobalG = _G;
local origErrorHandler = geterrorhandler();

--- [[[ variables to store proxied functions ]]]
local proxyGetFenv = nil;
local proxySetFenv = nil;
local proxyGetMetaTable = nil;
local proxySetMetaTable = nil;
local proxyRawGet = nil;
local proxyRawSet = nil;
local proxyCoroutineCreate = nil;
local proxyCoroutineWrap = nil;
local proxyPcall = nil;
local proxyXPcall = nil;
local proxyCollectGarbage = nil;
local proxyToString = nil;
local proxyStringFormat = nil;
local proxyStringSub = nil;
local proxyLoadString = nil;

-- list with functions implementations for which proxy was enabled
local proxyListProfixed = {};
-- list with original functions for which proxy was enabled
local proxyListOrig = {};
-- list with errors that should be generated for this API by default lua implementation
local proxyListErrors = {};

--- Function to get environment of specified function
-- This function can be used by addon deobfuscate protection to check if stack were modified and there is additional function that is being used as a proxy
-- e.g. it calls pcall with some checkFunction, it can than check proxyGetFenv(2) to check if there was no proxy by checking that this function returns table that was set before
-- @see example below: checkStack, callCheckStack, checkStackDemo
-- @param f function reference or number, where 1 - current calling function, 2 - function one step up on the stack, etc...
-- @return environment of the given function
proxyGetFenv = function(f)
	local env = origGetFenv(f);
	if (env ~= origGlobalFenv or (f ~= nil and f ~= 0)) then
		-- no implementation here as it wasn't required for addons that were analyzed, contact me if you require assistance to update this code
		MCDebugLog("proxyGetFenv " .. MCTableToString(f) .. ", env " .. MCSTableToString(env ~= origGlobalFenv and env or "globalFenv"));
	end
	return env;
end

--- Example how can deobfuscate protection check that stack was modified and it should deny further deobfuscation
local checkStack = function()
	local r = nil;
	origPrint("checkStack ");
	r = origGetFenv(1);
	origPrint("checkStack1 " .. MCSTableToString(r ~= origGlobalFenv and r or "globalFenv"));
	r = origGetFenv(2);
	origPrint("checkStack2 " .. MCSTableToString(r ~= origGlobalFenv and r or "globalFenv"));
	r = origGetFenv(3);
	origPrint("checkStack3 " .. MCSTableToString(r ~= origGlobalFenv and r or "globalFenv"));
	r = origGetFenv(4);
	origPrint("checkStack4 " .. MCSTableToString(r ~= origGlobalFenv and r or "globalFenv"));
end
--- function that can call check stack
local callCheckStack = function()
	pcall(checkStack);
end
--- Function to demo that stack trace can be checked for modification
local checkStackDemo = function()
	pcall = origPcall;
	local tblEnv1 = { ["pcall"] = pcall };
	origSetFenv(callCheckStack, tblEnv1);
	callCheckStack();
	pcall = proxyPcall;
	local tblEnv2 = { ["pcall"] = pcall };
	origSetFenv(callCheckStack, tblEnv2);
	callCheckStack();
end

--- Function to set environment of specified function
-- this function mainly used by deobfuscate protection to check if function is a "C" language function
-- To check for "C" function you provide function pointer and it should give error that can be found below
-- So when we receive one of our proxied functions - we should generate this error
-- @param f function reference or number, where 1 - current calling function, 2 - function one step up on the stack, etc...
-- @param env table to be used for Global lookup for non local variables in this function
-- @return function for which method was called (can also be used to check stack trace)
proxySetFenv = function(f, env)
	for i = 1, #proxyListProfixed do
		local proxy = proxyListProfixed[i];
		if (f == proxy) then
			MCDebugLog("proxySetFenv error check");
			origError("'setfenv' cannot change environment of given object");
			return;
		end
	end
	MCDebugLog("proxySetFenv " .. MCTableToString(f) .. ", " .. MCSTableToString(env ~= origGlobalFenv and env or "globalFenv"));
	return origSetFenv(f, env);
end

--- Function to proxy getmetatable method, sometimes it's good to know if some metatables hiding something
-- Generally deobfuscate protection uses it in following way
-- local a = a * (setmetatable(tbl, {__mul = function(tb1, tb2) return tb2; end}) * 5);
-- in this case result is just "5a"
-- @param tbl table for which metatable should be returned
-- @return metatable for the given table
proxyGetMetaTable = function(tbl)
	local res = origGetMetaTable(tbl);
	MCDebugLog("proxyGetMetaTable " .. MCSTableToString(tbl) .. " -> " .. MCSTableToString(res));
	return res;
end

--- Function to proxy setmetatable method, sometimes it's good to know if some metatables hiding something
-- @param tbl table for which metatable should be set
-- @param mtbl metatable to be set
-- @return parameter that was passed as "tbl" argument
proxySetMetaTable = function(tbl,mtbl)
	MCDebugLog("proxySetMetaTable " .. MCSTableToString(tbl) .. " -> " .. MCSTableToString(mtbl));
	return origSetMetaTable(tbl,mtbl);
end

--- Function to proxy rawget method, wasn't usefull for me
-- @param tbl table for which key should be read
-- @param key key to read
-- @return value at the specified key without calling metatable functions
proxyRawGet = function(tbl,key)
	local res = origRawGet(tbl, key);
	MCDebugLog("proxyRawGet " .. MCSTableToString(key) .. " -> " .. MCSTableToString(res));
	return res;
end

--- Function to proxy rawset method, wasn't usefull for me
-- @param tbl table for which metatable should be set
-- @param key key to read
proxyRawSet = function(tbl,key,value)
	MCDebugLog("proxyRawSet " .. MCSTableToString(key) .. " -> " .. MCSTableToString(value));
	return origRawSet(tbl, key, value);
end

--- Function to proxy coroutine.create method, which creates thread object
-- this function mainly used by deobfuscate protection to check if function is a "C" language function
-- To check for "C" function you provide function pointer and it should give error that can be found below
-- So when we receive one of our proxied functions - we should generate this error
-- @param f function for which thread should be created
-- @return thread if error was not generated
proxyCoroutineCreate = function(f)
	for i = 1, #proxyListProfixed do
		local proxy = proxyListProfixed[i];
		if (f == proxy) then
			MCDebugLog("proxy coroutine.create error check");
			origError("bad argument #1 to '?' (Lua function expected)");
			return;
		end
	end
	return origCoroutineCreate(f);
end

--- Function to proxy coroutine.wrap method, same as above but returns pointer to "thread.resume" function
-- this function mainly used by deobfuscate protection to check if function is a "C" language function
-- To check for "C" function you provide function pointer and it should give error that can be found below
-- So when we receive one of our proxied functions - we should generate this error
-- @param f function for which thread should be created
-- @return thread.resume function if error was not generated
proxyCoroutineWrap = function(f)
	for i = 1, #proxyListProfixed do
		local proxy = proxyListProfixed[i];
		if (f == proxy) then
			MCDebugLog("proxy coroutine.wrap error check");
			origError("bad argument #1 to '?' (Lua function expected)");
			return;
		end
	end
	return origCoroutineWrap(f);
end

--- Function to proxy pcall method, which is equalient to "try { } catch (e) { }" in other languages
-- This function mainly used by deobfuscate protection to check for errors that it expects to be generated
-- E.g. it can be used that function is a "C" function, it can also be used to check if code was beautified
-- Often obfuscated addons contain one large line of code that can be megabytes in size, If you try to beautify
-- It will detect it and stop in infinite loop, so we should also reduce line numbers inside of errors to reasonable
-- values
-- @param f function to be called
-- @param ... arguments to be passed to function
-- @return status of the function call and (error if not successfull or function return value)
proxyPcall = function (f, ...)
	--[[local errorHandler = geterrorhandler();
	if (origErrorHandler ~= errorHandler) then
		MCDebugLog("errorHandler changed");
	end]]
	--MCDebugLog("pcall " .. MCTableToString(f) .. ", args: " .. MCTableToString({...}));
	local indexProxy = -1;
	for i = 1, #proxyListProfixed do
		local proxy = proxyListProfixed[i];
		if (f == proxy) then
			indexProxy = i;
			MCDebugLog("proxy pcall check proxy " .. i);
			break;
		end
	end
	local status, err = origPcall(f, ...);
	if (not status) then
		if (indexProxy >= 1) then
			MCDebugLog("pcall error before patch: " .. MCTableToString(err));
			local override = proxyListErrors[indexProxy];
			if (#override > 0) then
				err = override;
			end
		end
		--Interface/AddOns/MyAddon/MyAddon.lua:1
		local indexInterface = origStringFind(err, "Interface", 1, true);
		if (indexInterface == 1) then
			MCDebugLog("pcall before line num patch: " .. MCTableToString(err));
			local indexColon = origStringFind(err, ":", 1, true);
			if (indexColon == nil) then
				indexColon = 0;
			end;
			local indexSpace = origStringFind(err, ": ", indexColon + 1, true);
			if (indexSpace == nil) then
				indexSpace = 0;
			end;
			-- Decrease line number in error message, so that obfuscator doesn't crash us
			if (indexColon > indexInterface and indexSpace > indexColon) then
				--local numStr = origStringSub(err, indexColon + 1, indexSpace - 1);
				err = origStringSub(err, 1, indexColon) .. "1" .. origStringSub(err, indexSpace);
			end
		end
		MCDebugLog("pcall error: " .. MCTableToString(err));
	end
	return status, err;
end

--- Function to proxy xpcall method, which is equalient to "try { } catch (e) { }", same as above
-- Wasn't used in addons that were debugged, so code is not finished for this one
-- @param f function to be called (no arguments will be passed)
-- @param ferr function to process error message
-- @return status of the function call and (error if not successfull or function return value)
proxyXPcall = function (f, ferr)
	local proxyErrHandle = function(msg)
		MCDebugLog("xpcall error1 " .. MCTableToString(err));
		ferr(msg);
	end
	local status, err, ret = origXPcall(f, proxyErrHandle);
	if (not status) then
		--MCDebugLog("xpcall error2 " .. MCTableToString(err));
	end
	return status, err, ret;
end

--- Function to proxy collectgarbage method, to delete all garbage that is not being referenced anymore
-- Can be used along with weak tables to check if function pointers are deleted
-- Wasn't used in addons that were debugged, so code is not finished for this one
-- @param opt options to collect garbage, e.g. "collect", "stop", "restart", "count", "step", "setpause", "setstepmul"
-- @param ferr function to process error message
-- @return status of the function call and (error if not successfull or function return value)
proxyCollectGarbage = function(opt, ...)
	MCDebugLog("collect garbage " .. MCSTableToString(opt));
	return origCollectGarbage(opt, ...);
end

--- Function to proxy tostring method
-- Can be used to check string addresses of function, usually C function will have small difference between them in address
-- Proxied lua function will differ in address by huge amount
-- Wasn't used in addons that were debugged, so code is not finished for this one
-- WoW client doesn't like if we change value of this function (code will become tainted), but can still be used to debug non Blizzard code
-- @param val any value to be converted to string
-- @return string value
proxyToString = function(val)
	if (type(val) == "function") then
		for i = 1, #proxyListProfixed do
			local proxy = proxyListProfixed[i];
			if (val == proxy) then
				MCDebugLog("proxyToString hook func address " .. i);
				return origToString(proxyListOrig[i]);
			end
		end
	end
	return origToString(val);
end

--- Function to proxy string.format method, which is equilent to "printf("%d", num)" formatting
-- @param fmt format to be used for string
-- @param ... arguments to be passed to format function
-- @return formatted string
proxyStringFormat = function(fmt, ...)
	MCDebugLog("fmt " .. fmt .. ", args " .. MCSTableToString({...}));
	return origStringFormat(fmt, ...);
end

--- Function to proxy string.sub method, which is equilent to "substring" in other languages
-- Usefull string names can be hidden behind this one (this will strip some long string out of garbage)
-- Another string hiding method is concatenation by one chars via byte code, but this one you should find and print yourself
-- By default binary garbage is not written to log
-- @param s string to substring
-- @param i starting index of substitution
-- @param j ending index of substitution
-- @return substring that was generated
proxyStringSub = function(s, i, j)
	local res = origStringSub(s, i, j);
	local isBinary = false;
	for i = 1, #res do
		if (string.byte(res, i) < 32) then
			isBinary = true;
			break;
		end
	end
	if (not isBinary) then
		MCDebugLog("stringSub: " .. res);
	end
	return res;
end

-- length of the code for which we should call custom return
local proxyLoadStringHugeFuncLength = 200000;
-- function to be returned as custom return
local proxyLoadStringHugeFuncRef = nil;

--- Function to proxy loadstring method, which is equilent to "eval" in other languages
-- Deobfucate protection can try to hide second virtual byte machine behind first one or even use 3 or more
-- Generally we should beautify only the last virtual machine, all othe virtual machines are useless (but they may provide args to further machines)
-- Please note that printed function content will be escaped, you need to replace \" with ", and \\ with \, etc...
-- @param code code to be loaded as function
-- @return function reference that should be executed manually
proxyLoadString = function(code)
	MCDebugLog("loadstring " .. MCSTableToString(code));
	if (type(code) == "string" and #code > proxyLoadStringHugeFuncLength and proxyLoadStringHugeFuncRef ~= nil) then
		-- this code can be used if you want to beautify this function first and it depends on the first one
		MCDebugLog("loadstring hack func ref " .. MCTableToString(proxyLoadStringHugeFuncRef));
		return proxyLoadStringHugeFuncRef;
	end
	local f, err = origLoadString(code);
	if (f ~= nil) then
		MCDebugLog("loadstring addr " .. MCTableToString(f));
	else
		MCDebugLog("loadstring err " .. MCTableToString(err));
	end
	return f, err;
end

--- Function to redirect all errors to debug log (to be analyzed later)
local MCErrorPrinter = function(msg)
	MCDebugLog("error happened " .. msg);
end

----------------------------------
-- Licensing protection removal --
----------------------------------

--- [[[ save original functions to local variables ]]]
local origBNInfo = BNGetInfo;
local origGetServerTime = GetServerTime;
local origTimerAfter = C_Timer.After;

--- [[[ variables to store proxied functions ]]]
local proxyBNInfo = nil;
local proxyServerTime = nil;
local proxyTimerAfter = nil;

--- Proxy to BNGetInfo, function returns user battleTag
-- Function can be used as license to specified player
-- But sometimes returns nil and can alienate players that are using license correctly
-- @return battle tag info, https://wowpedia.fandom.com/wiki/API_BNGetInfo
proxyBNInfo = function()
	local presenceID, battleTag, toonID, currentBroadcast, bnetAFK, bnetDND, isRIDEnabled = origBNInfo();
	MCDebugLog("origBNInfo " .. MCTableToString({presenceID, battleTag, toonID, currentBroadcast, bnetAFK, bnetDND, isRIDEnabled}));
	presenceID = nil;
	if (battleTag == nil) then
		--battleTag = "MYTAG#9999";
	end
	if (toonID == nil) then
		toonID = 1;
	end
	return presenceID, battleTag, toonID, currentBroadcast, bnetAFK, bnetDND, isRIDEnabled;
end

--- Proxy to GetServerTime, function returns server time, which can be different from local one (e.g. user tries to move it's own time)
-- Function can be used as licensing per month business model
-- @return unix time, number of seconds from year 1970
proxyServerTime = function()
	local res = origGetServerTime();
	MCDebugLog("origGetServerTime " .. res);
	return res;
end

--- Proxy to C_Timer.After, function executes function after some time
-- can be used to ignore to not schedule some game functions
-- Wasn't usefull in my case
-- @param delay delay in ms
-- @param func function to be executed after delay
proxyTimerAfter = function(delay, func)
	MCDebugLog("proxyTimerAfter " .. delay .. ", func " .. MCTableToString(func) .. ", unchanged " .. MCTableToString(proxyTimerAfter == C_Timer.After));
	origTimerAfter(delay, func);
end

--------------------
-- Frame proxying --
--------------------

--- [[[ save original functions to local variables ]]]
local origCreateFrame = CreateFrame;
local origGetFramesRegisteredForEvent = GetFramesRegisteredForEvent;

--- [[[ variables to store proxied functions ]]]
local proxyCreateFrame = nil;
local proxyGetFramesRegisteredForEvent = nil;

--- Frame to fake event capabilites that can be used to research addon behavior with frames
DHUDFakeFrame = MCCreateClass{
	-- id of the frame
	id = nil,
	-- number of time elapsed
	elapsed = 0,
	-- callback for onEvent
	onEvent = nil,
	-- callback for onUpdate
	onUpdate = nil,
	-- frame for event propogation
	eventFrame = nil,
	-- frame for update propogation
	updateFrame = nil,
	-- frame for attribute propogation
	attrFrame = nil,
	-- last id that is incremented
	FAKE_FRAME_LAST_ID = 1,
}

--- Create new fake frame
-- @param type type of the event
function DHUDFakeFrame:new()
	local o = self:defconstructor();
	o:constructor();
	return o;
end

--- Constructor of fake frame
function DHUDFakeFrame:constructor()
	self.id = DHUDFakeFrame.FAKE_FRAME_LAST_ID;
	DHUDFakeFrame.FAKE_FRAME_LAST_ID = DHUDFakeFrame.FAKE_FRAME_LAST_ID + 1;
end

--- [[[ functions proxy calls that should be printed in log ]]]
function DHUDFakeFrame:SetAttribute(name, val)
	MCDebugLog("DH SetAttribute " .. MCSTableToString({name, val}) .. ", id " .. self.id);
	if (self.attrFrame == nil) then
		self.attrFrame = origCreateFrame("Frame");
	end
	self.attrFrame:SetAttribute(name, val);
end
function DHUDFakeFrame:GetAttribute(prefix, name, suffix)
	local res = self.attrFrame:GetAttribute(prefix, name, suffix);
	MCDebugLog("DH GetAttribute " .. MCSTableToString({prefix, name, suffix, res}) .. ", id " .. self.id);
	return res;
end
function DHUDFakeFrame:SetScript(name, func)
	MCDebugLog("DH SetScript " .. MCSTableToString({name, func}) .. ", id " .. self.id);
	if (name == "OnEvent") then
		self.onEvent = func;
		MCDeInitFrameProxying(); -- comment this if not required
	elseif (name == "OnUpdate") then
		self.onUpdate = func;
		if (self.updateFrame == nil) then
			local that = self;
			local frame = origCreateFrame("Frame");
			frame:SetScript("OnUpdate", function (self, elapsed, ...)
				that.elapsed = that.elapsed + elapsed;
				if (that.elapsed <= 1) then
					return;
				end
				that.elapsed = 0;
				MCDebugLog("DH Propogating Update, id " .. that.id);
				local func = that.onUpdate; if (func) then func(that, elapsed, ...); end
			end);
			self.updateFrame = frame;
		end
	end
end
function DHUDFakeFrame:Hide()
	MCDebugLog("DH Hide, id " .. self.id);
end
function DHUDFakeFrame:Show()
	MCDebugLog("DH Show, id " .. self.id);
end
function DHUDFakeFrame:GetFrameRef(name)
	MCDebugLog("DH GetFrameRef " .. MCSTableToString(name) .. ", id " .. self.id);
end
function DHUDFakeFrame:SetFrameRef(name, frm)
	MCDebugLog("DH SetFrameRef " .. MCSTableToString({name, frm}) .. ", id " .. self.id);
end
function DHUDFakeFrame:UnregisterAllEvents()
	MCDebugLog("DH UnregisterAllEvents, id " .. self.id);
end
function DHUDFakeFrame:UnregisterEvent(name)
	MCDebugLog("DH UnregisterEvent " .. MCSTableToString({name}) .. ", id " .. self.id);
end
function DHUDFakeFrame:RegisterEvent(name)
	MCDebugLog("DH RegisterEvent " .. MCSTableToString({name}) .. ", id " .. self.id);
	if (self.eventFrame == nil) then
		local that = self;
		local frame = origCreateFrame("Frame");
		frame:SetScript("OnEvent", function (self, event, ...)
			MCDebugLog("DH Propogating " .. MCSTableToString(event) .. ", id " .. that.id);
			local func = that.onEvent; if (func) then func(that, event, ...); end
		end);
		self.eventFrame = frame;
	end
	self.eventFrame:RegisterEvent(name);
end
function DHUDFakeFrame:ClearAllPoints()
end
function DHUDFakeFrame:SetDrawEdge()
end
function DHUDFakeFrame:SetParent()
end
function DHUDFakeFrame:SetCooldown(start, duration, modRate)
	MCDebugLog("DH SetCooldown " .. MCSTableToString({start, duration, modRate}) .. ", id " .. self.id);
end
function DHUDFakeFrame:Clear()
	MCDebugLog("DH Clear, id " .. self.id);
end

--- Search for non implemented function key, if you see, need to add implementation
-- @param key key to search
function DHUDFakeFrame:searchKey(key)
	MCDebugLog("DH Frame UnknownKey " .. MCSTableToString({key}));
	return nil;
end
setmetatable(DHUDFakeFrame, {__index = DHUDFakeFrame.searchKey});

--- Proxy to CreateFrame, function that creates visible or invisible frame that can be used for event listening
-- @param param1 type of the frame, e.g. "Frame" or "Button"
-- @param param2 name of the frame in global namespace, it can be referenced from it if not nil
-- @param param3 parent of the frame, e.g. UIParent or nil or something else
-- @param param4 secure templates for frame to implement some secure actions, e.g. "SecureActionButtonTemplate"
-- @param param5 Id of the frame
-- @return frame that was created
proxyCreateFrame = function(param1, param2, param3, param4, param5)
	if (param3 ~= nil) then
		return origCreateFrame(param1, param2, param3, param4, param5);
	end
	local fake = DHUDFakeFrame:new();
	MCDebugLog("DH createFrame " .. MCSTableToString({param1, param2, param3, param4, param5}) .. ", id " .. fake.id);
	return fake;
end

--- Proxy to GetFramesRegisteredForEvent, function returns table with frames that are registered for specified event
-- The result can be used to unsubscribe some previous events from some functionality
-- @param name name of the event, e.g. "PLAYER_LOGOUT"
-- @return list with frames that are registered for event
proxyGetFramesRegisteredForEvent = function(name)
	local frame, frame2, frame3 = origGetFramesRegisteredForEvent(name);
	MCDebugLog("DH GetFramesRegisteredForEvent " .. MCSTableToString(name) .. " -> " .. MCSTableToString(#{frame, frame2, frame3}));
	local fakeFrameToReturn = proxyCreateFrame();
	return fakeFrameToReturn;
end

--- Example code how results of GetFramesRegisteredForEvent can be used to UnregisterEvent calls
-- e.g. call unregisterEventExample("PLAYER_LOGOUT", GetFramesRegisteredForEvent("PLAYER_LOGOUT"))
-- @param event event to be unsubscribed
-- @param widget frame to unsubscribe
local function unregisterEventExample(event, widget, ...)
	if widget then
		widget:UnregisterEvent(event)
		return unregisterEventExample(event, ...)
	end
end

-----------
-- Usage --
-----------

--- Function to setup logging to saved variables, to be read later
-- @param tableName name of the table that should contain logs, it will be erased!
function MCDebugSetupLogs(tableName)
	local tbl = _G[tableName];
	if (tbl ~= nil) then
		local count = #tbl
		for i=count,1,-1 do tbl[i]=nil; end
		_G[tableName] = nil;
	end
	debugMsgTable = {};
	_G[tableName] = debugMsgTable;
end

--- Function to print existing logs to chat, may freeze client if there is many of them
function MCDebugPrintLogs()
	print("printing " .. #debugMsgTable .. " messages");
	for i, v in ipairs(debugMsgTable) do
		print(v);
	end
end

--- Function to setup deobfuscation removal, that was seen above
-- higher levels than 1 will provide more debug info but will prevent addon from functioning correctly (due to tainting Blizzard code)
-- @param level amount of function to be deobfucated, 1 = basic, 2 = extended, etc...
function MCInitDeobfucatorProtectionRemoval(level)
	MCDebugLog("Setup deobfuscation removal with level " .. MCSTableToString(level));
	seterrorhandler(MCErrorPrinter);
	proxyListProfixed = {};
	proxyListOrig = {};
	proxyListErrors = {};
	-- getfenv
	getfenv = proxyGetFenv;
	table.insert(proxyListProfixed, proxyGetFenv);
	table.insert(proxyListOrig, origGetFenv);
	table.insert(proxyListErrors, "");
	-- setfenv
	setfenv = proxySetFenv;
	table.insert(proxyListProfixed, proxySetFenv);
	table.insert(proxyListOrig, origSetFenv);
	table.insert(proxyListErrors, "'setfenv' cannot change environment of given object");
	-- getmetatable
	getmetatable = proxyGetMetaTable;
	table.insert(proxyListProfixed, proxyGetMetaTable);
	table.insert(proxyListOrig, origGetMetaTable);
	table.insert(proxyListErrors, "");
	-- setmetatable
	setmetatable = proxySetMetaTable;
	table.insert(proxyListProfixed, proxySetMetaTable);
	table.insert(proxyListOrig, origSetMetaTable);
	table.insert(proxyListErrors, "");
	-- rawget
	rawget = proxyRawGet;
	table.insert(proxyListProfixed, proxyRawGet);
	table.insert(proxyListOrig, origRawGet);
	table.insert(proxyListErrors, "");
	-- rawset
	rawset = proxyRawSet;
	table.insert(proxyListProfixed, proxyRawSet);
	table.insert(proxyListOrig, origRawSet);
	table.insert(proxyListErrors, "");
	-- coroutine.create
	coroutine.create = proxyCoroutineCreate;
	table.insert(proxyListProfixed, proxyCoroutineCreate);
	table.insert(proxyListOrig, origCoroutineCreate);
	table.insert(proxyListErrors, "bad argument #1 to '?' (Lua function expected)");
	-- coroutine.wrap
	coroutine.wrap = proxyCoroutineWrap;
	table.insert(proxyListProfixed, proxyCoroutineWrap);
	table.insert(proxyListOrig, origCoroutineWrap);
	table.insert(proxyListErrors, "bad argument #1 to '?' (Lua function expected)");
	-- pcall
	pcall = proxyPcall;
	table.insert(proxyListProfixed, proxyPcall);
	table.insert(proxyListOrig, origPcall);
	table.insert(proxyListErrors, "");
	-- loadstring
	loadstring = proxyLoadString;
	table.insert(proxyListProfixed, proxyLoadString);
	table.insert(proxyListOrig, origLoadString);
	table.insert(proxyListErrors, "bad argument #1 to '?' (string expected, got table)");
	if (level < 2) then
		return;
	end
	-- string.sub
	string.sub = proxyStringSub;
	table.insert(proxyListProfixed, proxyStringSub);
	table.insert(proxyListOrig, origStringSub);
	table.insert(proxyListErrors, "");
	if (level < 3) then
		return;
	end
	-- xpcall
	xpcall = proxyXPcall;
	table.insert(proxyListProfixed, proxyXPcall);
	table.insert(proxyListOrig, origXPcall);
	table.insert(proxyListErrors, "");
	-- collectgarbage
	collectgarbage = proxyCollectGarbage;
	table.insert(proxyListProfixed, proxyCollectGarbage);
	table.insert(proxyListOrig, origCollectGarbage);
	table.insert(proxyListErrors, "");
	-- tostring
	tostring = proxyToString;
	table.insert(proxyListProfixed, proxyToString);
	table.insert(proxyListOrig, origToString);
	table.insert(proxyListErrors, "");
end

--- Function to restore original functions after calling "MCInitDeobfucatorProtectionRemoval"
function MCDeInitDeobfucatorProtectionRemoval()
	MCDebugLog("Stopping deobfuscation removal");
	seterrorhandler(origErrorHandler);
	getfenv = origGetFenv;
	setfenv = origSetFenv;
	getmetatable = origGetMetaTable;
	setmetatable = origSetMetaTable;
	rawget = origRawGet;
	rawset = origRawSet;
	coroutine.create = origCoroutineCreate;
	coroutine.wrap = origCoroutineWrap;
	pcall = origPcall;
	loadstring = origLoadString;
	string.sub = origStringSub;
	xpcall = origXPcall;
	collectgarbage = origCollectGarbage;
	tostring = origToString;
end

--- Function to setup deobfuscation removal, that was seen above
-- @param level amount of function to be deobfucated, 1 = basic, 2 = extended, etc...
function MCInitLicenseProtectionRemoval(level)
	MCDebugLog("Setup license protection removal with level " .. MCSTableToString(level));
	BNGetInfo = proxyBNInfo;
	GetServerTime = proxyServerTime;
	if (level < 2) then
		return;
	end
	C_Timer.After = proxyTimerAfter;
end

--- Function to restore original functions after calling "MCInitLicenseProtectionRemoval"
function MCDeInitLicenseProtectionRemoval()
	MCDebugLog("Stopping license protection removal");
	BNGetInfo = origBNInfo;
	GetServerTime = origGetServerTime;
	C_Timer.After = origTimerAfter;
end

--- Function to setup frame proxying to see code behavior
function MCInitFrameProxying()
	MCDebugLog("Setup frame proxying");
	CreateFrame = proxyCreateFrame;
	GetFramesRegisteredForEvent = proxyGetFramesRegisteredForEvent;
end

--- Function to stop frame proxying, once debugging is complete
function MCDeInitFrameProxying()
	MCDebugLog("Stop frame proxying");
	CreateFrame = origCreateFrame;
	GetFramesRegisteredForEvent = origGetFramesRegisteredForEvent;
end

--- Example of how code should be used
function MCExampleUsage()
	MCDebugSetupLogs("MySavedVariablesTable");
	MCInitDeobfucatorProtectionRemoval(2);
	MCInitLicenseProtectionRemoval(1);
	MCInitFrameProxying();
end
