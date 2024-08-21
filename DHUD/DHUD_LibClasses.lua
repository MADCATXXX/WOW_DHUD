--[[-----------------------------------------------------------------------------------
 Original Drathals HUD (c) 2006 by Markus Inger / Drathal / Silberklinge / Silbersegen
 DHUD for WotLK and later expansions (c) 2013 by MADCAT (EU-Гордунни, Мадкат)
 (http://eu.battle.net/wow/en/character/Гордунни/Мадкат/advanced)
---------------------------------------------------------------------------------------
 This file contains helper classes such as EventDispatcher
 @author: MADCAT
-----------------------------------------------------------------------------------]]--

-------------------
-- Class helpers --
-------------------

--- Create new class, it can be subclassed later
-- @param fields table with fields of the class
function MCCreateClass(fields)
	-- create class table
	local c = fields or {};

	-- prepare `c' to be the metatable of its instances
	c.__index = c;
        
	-- define a default constructor for this new class
	function c:defconstructor(o)
		o = o or {};
		setmetatable(o, c);
		return o;
	end

	-- define instance check function for this new class
	function c:isInstanceOf(class)
		local baseClass = self;
		while (baseClass ~= nil) do
			if (baseClass == class) then
				return true;
			end
			baseClass = getmetatable(baseClass);
		end
		return false;
	end
    
	-- return new class
	return c;
end

--- Create new class that subclasses another class
-- @param parent parent class
-- @param fields table with additional fields of the class
function MCCreateSubClass(parent, fields)
	-- create class table
	local c = MCCreateClass(fields);
	
	-- set search function
	setmetatable(c, parent);

	-- return new class
	return c;
end

--------------------------
-- Blizzard event frame --
--------------------------

--- Create blizzard event frame to listen to game events
-- @return blizzard event frame
function MCCreateBlizzEventFrame()
	local frame = CreateFrame("Frame");
	frame:SetScript("OnEvent", function (self, event, ...) local func = self[event]; if (func) then func(self, ...); end end);
	return frame;
end

--- Base class for blizzard combat event frame
MCCombatEventFrame = MCCreateClass{
	-- frame to listen to combat log events
	STATIC_combatLogFrame			= nil,
}

--- initialize static vars for combat event frame
function MCCombatEventFrame:STATIC_init()
	if (self.STATIC_combatLogFrame ~= nil) then
		return;
	end
	--- create blizzard frame to listen to combat log events
	local combatLogFrame = CreateFrame("Frame");
	combatLogFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
	-- create listeners
	combatLogFrame.listeners = { };
	-- process event
	-- (self, blizz_event, timestamp, event, hideCaster, sourceGUID, sourceName, sourceFlags, sourceFlags2, destGUID, destName, destFlags, destFlags2, ...)
	combatLogFrame:SetScript("OnEvent", function (self, eventNameConst)
		local timestamp, event, hideCaster, sourceGUID, sourceName, sourceFlags, sourceFlags2, destGUID, destName, destFlags, destFlags2, ex1, ex2, ex3, ex4, ex5 = CombatLogGetCurrentEventInfo();
		local subListeners = self.listeners[event];
		if (subListeners ~= nil) then
			for i, v in ipairs(subListeners) do
				local func = v[event];
				if (func) then func(v, timestamp, hideCaster, sourceGUID, sourceName, sourceFlags, sourceFlags2, destGUID, destName, destFlags, destFlags2, ex1, ex2, ex3, ex4, ex5); end
			end
		end
	end);
	-- save
	self.STATIC_combatLogFrame = combatLogFrame;
end

--- Create new combat event frame
function MCCombatEventFrame:new()
	local o = self:defconstructor();
	return o;
end

--- Register for new combat log event type
-- @param eventName name of the event to be notified about
function MCCombatEventFrame:RegisterEvent(eventName)
	local combatLogFrame = self.STATIC_combatLogFrame;
	-- find sublisteners
	local subListeners = combatLogFrame.listeners[eventName];
	if (subListeners == nil) then
		subListeners = { };
		combatLogFrame.listeners[eventName] = subListeners;
	end
	-- add sublistener
	table.insert(subListeners, self);
end

--- Unregister from combat log event type
-- @param eventName name of the event to be notified about
function MCCombatEventFrame:UnregisterEvent(eventName)
	local combatLogFrame = self.STATIC_combatLogFrame;
	-- find sublisteners
	local subListeners = combatLogFrame.listeners[eventName];
	if (subListeners == nil) then
		return;
	end
	-- search for listener
	for i, v in ipairs(subListeners) do
		-- delete listener
		if (v == self) then
			table.remove(subListeners, i);
			break;
		end
	end
end

--- Create blizzard combat event frame to listen to game combat events
-- @return blizzard event frame
function MCCreateBlizzCombatEventFrame()
	MCCombatEventFrame:STATIC_init();
	return MCCombatEventFrame:new();
end

-----------------
-- Table utils --
-----------------

--- Create a copy of the table specified, all subtables will also be copied!
-- @param t table to be copied
-- @return copied table
function MCCreateTableDeepCopy(t)
	if (type(t) ~= "table") then
		return t;
	end
	-- copy table
	local copy = { };
	for i, v in pairs(t) do
		copy[i] = MCCreateTableDeepCopy(v);
	end
	-- set same base class
	setmetatable(copy, getmetatable(t));
	return copy;
end

--- Create a copy of the table specified, subtables will not be copied
-- @param t table to be copied
-- @return copied table
function MCCreateTableCopy(t)
	if (type(t) ~= "table") then
		return t;
	end
	-- copy table
	local copy = { };
	for i, v in pairs(t) do
		copy[i] = v;
	end
	return copy;
end

--- Resize list to new length
-- @param t list to resize
-- @param size new size of the array
-- @param default default value if size is greater than current
-- @return resized array
function MCResizeTable(t, size, default)
	local currentSize = #t;
	if (currentSize > size) then
		for i = size + 1, currentSize, 1 do
			t[i] = nil;
		end
	elseif (currentSize < size) then
		for i = currentSize + 1, size, 1 do
			t[i] = default;
		end
	end
	return t;
end

--- Find key at which value is located in table specified
-- @param t table to search in
-- @param value value to find
-- @return key or nil if not found
function MCFindValueInTable(t, value)
	for i, v in pairs(t) do
		if (v == value) then
			return i;
		end
	end
	return nil;
end

--- Find index at which value is located in table specified
-- @param t table to search in
-- @param value value to find
-- @return key or nil if not found
function MCIndexOfValueInTable(t, value)
	for i, v in ipairs(t) do
		if (v == value) then
			return i;
		end
	end
	return -1;
end

--- Find index at which value is located in table specified
-- @param t table to search in
-- @param value value to find
-- @return key or nil if not found
function MCLastIndexOfValueInTable(t, value)
	local n = #t;
	for i = n, 1, -1 do
		if (t[i] == value) then
			return i;
		end
	end
	return -1;
end

--- Find key at which subValue is located in table specified
-- @param t table to search in
-- @param subValueName name of the subvalue to be searched
-- @param subValue subValue to find
-- @return key or nil if not found
function MCFindSubValueInTable(t, subValueName, subValue)
	for i, v in pairs(t) do
		if (v[subValueName] == subValue) then
			return i;
		end
	end
	return nil;
end

--- Compare two tables by values
-- @param t1 table one to comapre
-- @param t2 table two to compare
-- @return true if tables are identical, false otherwise
function MCCompareTables(t1, t2)
	if (t1 == t2) then
		return true;
	end
	if ("table" ~= type(t1) or "table" ~= type(t2)) then
		return false;
	end
	for k, v in pairs(t1) do
		if (not MCCompareTables(v, t2[k])) then
			return false;
		end
	end
	return true;
end

--- Sort table using function, table.sort makes excess exchanges when items order is the same
-- @param t table to sort
-- @param func function that will sort table, comparison function should take two arguments to compare, Given the elements A and B, negative return value specifies that A appears before B in the sorted sequence, return value of 0 specifies that A and B have the same sort order, positive return value specifies that A appears after B in the sorted sequence. should return -1 if first parameter should be before second, or 1 if first parameter should be after
function MCSortTableByFunc(t, func)
	local n = #t;
	local tmp;
	local swapped;
	for j = 1, n - 1, 1 do
		swapped = false;
		for i = 1, n - j, 1 do
			local res = func(t[i], t[i + 1]);
			if (res > 0) then
				swapped = true;
				tmp = t[i];
				t[i] = t[i + 1];
				t[i + 1] = tmp;
			end
			i = i + 1;
		end
		if (not swapped) then
			return;
		end
		j = j + 1;
	end
end

--- Sort table using table subvalue, table.sort makes excess exchanges when items order is the same
-- @param t table to sort
-- @param varName name of the variable with sorting order, the more is variable the later will be item
function MCSortTableBySubValue(t, varName)
	local n = #t;
	local tmp;
	local swapped;
	for j = 1, n - 1, 1 do
		swapped = false;
		for i = 1, n - j, 1 do
			local res = t[i][varName] - t[i + 1][varName];
			if (res > 0) then
				swapped = true;
				tmp = t[i];
				t[i] = t[i + 1];
				t[i + 1] = tmp;
			end
			i = i + 1;
		end
		if (not swapped) then
			return;
		end
		j = j + 1;
	end
end

--- Convert value from table to string
-- @param v value to convert
-- @return string
local MCTableValToStr = function(v)
	-- print string in quotes
	if "string" == type(v) then
		v = string.gsub(v, "\n", "\\n");
		if string.match(string.gsub(v,"[^'\"]",""), '^"+$') then
			return "'" .. v .. "'";
		end
		return '"' .. string.gsub(v, '"', '\\"') .. '"';
	else
		return "table" == type(v) and MCTableToString(v) or tostring(v);
	end
end
local MCSTableValToStr = function(v)
	if "string" == type(v) then
		v = string.gsub(v, "\n", "\\n");
		if string.match(string.gsub(v,"[^'\"]",""), '^"+$') then
			return "'" .. v .. "'";
		end
		return '"' .. string.gsub(v, '"', '\\"') .. '"';
	else
		return "table" == type(v) and MCSTableToString(v) or tostring(v);
	end
end

--- Convert key from table to string
-- @param k key to convert
-- @return string
local MCTableKeyToStr = function(k)
	if "string" == type(k) and string.match(k, "^[_%a][_%a%d]*$") then
		return k;
	else
		return "[" .. MCTableValToStr(k) .. "]";
	end
end
local MCSTableKeyToStr = function(k)
	if "string" == type(k) and string.match(k, "^[_%a][_%a%d]*$") then
		return k;
	else
		return "[" .. MCSTableValToStr(k) .. "]";
	end
end

--- Print table contents as string
-- @param tbl table to print contents from
-- @return string with contents
function MCTableToString(tbl)
	-- check if we received table
	if ("table" ~= type(tbl)) then
		return tostring(tbl);
	end
	-- create vars
	local result, done = {}, {};
	-- iterate over number keys
	for k, v in ipairs(tbl) do
		table.insert(result, MCTableValToStr(v));
		done[k] = true;
	end
	-- iterate over dictionary keys
	for k, v in pairs(tbl) do
		if not done[k] then
			table.insert(result, MCTableKeyToStr(k) .. "=" .. MCTableValToStr(v));
		end
	end
	-- return
	return "{" .. table.concat(result, ",") .. "}";
end

-- list with tables that were already iterated by "MCSTableToString" function
local MCSTableToStringList = nil;
-- maximum number of tables to be saved in array (infinite recursion protection)
local MCSTableToStringLimit = 100;

--- Print table contents as string (Safe version with recursion protection, but may be a bit slower)
-- @param tbl table to print contents from
-- @return string with contents
function MCSTableToString(tbl)
	if ("table" ~= type(tbl)) then
		return tostring(tbl);
	end
	local needToInitTable = MCSTableToStringList == nil;
	if (needToInitTable) then
		MCSTableToStringList = { tbl };
	else
		if (tbl == _G) then
			return "_G";
		end
		local numTableIters = #MCSTableToStringList;
		if (numTableIters >= MCSTableToStringLimit) then
			return "limit" .. numTableIters;
		end
		for i = 1, numTableIters do
			if (MCSTableToStringList[i] == tbl) then
				return "recursion"..i;
			end
		end
		table.insert(MCSTableToStringList, tbl);
	end
	local result, done = {}, {};
	for k, v in ipairs(tbl) do
		table.insert(result, MCSTableValToStr(v));
		done[k] = true;
	end
	for k, v in pairs(tbl) do
		if not done[k] then
			table.insert(result, MCSTableKeyToStr(k) .. "=" .. MCSTableValToStr(v));
		end
	end
	if (needToInitTable) then
		MCSTableToStringList = nil;
	end
	return "{" .. table.concat(result, ",") .. "}";
end

--- Print string contents as hex
-- @param str string to print contents from
-- @return hex formatted string
function MCStringToHex(str)
   return (str:gsub(".", function(char) return string.format("%02x ", char:byte()) end))
end

------------------------
-- bitwise operations --
------------------------

--- Class to make bitwise operations. Required since bitwise operations that are provided by WoW API return incorrect results on some operating systems (e.g. Mac: bit.band(7, bit.bnot(24)) = 0 instead of 7)
-- this class may perform slower than C++ implementation, but doesn't return incorrect results ( http://eu.battle.net/wow/en/forum/topic/7714092436 )
mcbit = {
}

--- Computes the bitwise 'not' of it's argument
-- @param a number to invert
-- @return the inverted value
function mcbit.bnot(a)
	local inverted = 4294967295 - a;
	return inverted;
end

--- Computes the bitwise 'and' of it's arguments. More than two arguments are allowed
-- @param a number one for 'and' operation
-- @param b number two for 'and' operation
-- @return the and'ed value
function mcbit.band(a, b, ...)
	if (a < 0) then a = a + 4294967296;	end
	if (b < 0) then	b = b + 4294967296;	end
	-- calculate
	local result = 0;
	for i = 1, 32, 1 do
		result = result + result;
		if (a > 2147483647 and b > 2147483647) then
			result = result + 1;
		end
		a = a + a;
		if (a > 4294967295) then a = a - 4294967296; end
		b = b + b;
		if (b > 4294967295) then b = b - 4294967296; end
		--print("result " .. result .. ", a " .. a .. ", b " .. b);
	end
	-- process additional params
	if (... ~= nil) then
		local n = select("#", ...);
		for i = 1, n, 1 do
			result = mcbit.band(result, select(i, ...));
		end
	end
	return result;
end

--- Computes the bitwise 'or' of it's arguments. More than two arguments are allowed
-- @param a number one for 'or' operation
-- @param b number two for 'or' operation
-- @return the or'ed value
function mcbit.bor(a, b, ...)
	if (a < 0) then a = a + 4294967296;	end
	if (b < 0) then	b = b + 4294967296;	end
	-- calculate
	local result = 0;
	for i = 1, 32, 1 do
		result = result + result;
		if (a > 2147483647 or b > 2147483647) then
			result = result + 1;
		end
		a = a + a;
		if (a > 4294967295) then a = a - 4294967296; end
		b = b + b;
		if (b > 4294967295) then b = b - 4294967296; end
		--print("result " .. result .. ", a " .. a .. ", b " .. b);
	end
	-- process additional params
	if (... ~= nil) then
		local n = select("#", ...);
		for i = 1, n, 1 do
			result = mcbit.bor(result, select(i, ...));
		end
	end
	return result;
end

--- Computes the bitwise 'xor' of it's arguments. More than two arguments are allowed
-- @param a number one for 'xor' operation
-- @param b number two for 'xor' operation
-- @return the and'ed value
function mcbit.bxor(a, b, ...)
	if (a < 0) then a = a + 4294967296;	end
	if (b < 0) then	b = b + 4294967296;	end
	-- calculate
	local result = 0;
	for i = 1, 32, 1 do
		result = result + result;
		if (a > 2147483647) then
			if (b <= 2147483647) then
				result = result + 1;
			end
		else
			if (b > 2147483647) then
				result = result + 1;
			end
		end
		a = a + a;
		if (a > 4294967295) then a = a - 4294967296; end
		b = b + b;
		if (b > 4294967295) then b = b - 4294967296; end
		--print("result " .. result .. ", a " .. a .. ", b " .. b);
	end
	-- process additional params
	if (... ~= nil) then
		local n = select("#", ...);
		for i = 1, n, 1 do
			result = mcbit.bxor(result, select(i, ...));
		end
	end
	return result;
end

--- Computes 'a' shifted to the left 'b' places
-- @param a number to shift
-- @param b shift amount
-- @return the shifted value
function mcbit.lshift(a, b)
	local shifted = a * (2 ^ b);
	return shifted;
end

--- Computes 'a' shifted to the right 'b' places
-- @param a number to shift
-- @param b shift amount
-- @return the shifted value
function mcbit.rshift(a, b)
	local shifted = floor(a / (2 ^ b));
	return shifted;
end

----------------------
-- Event dispatcher --
----------------------

--- Base class for events
MADCATEvent = MCCreateClass{
	-- type of the event
	type				= "",
	-- event listeners collection that is dispatching this event
	dispatchedBy		= nil,
}

--- Create new event
-- @param type type of the event
function MADCATEvent:new(type)
	local o = self:defconstructor();
	o:constructor(type);
	return o;
end

--- Constructor of event, must be called from subclasses
-- @param type type of the event
function MADCATEvent:constructor(type)
	self.type = type;
end

--- Cancels current dispatching process
function MADCATEvent:stopImmediatePropagation()
	if (self.dispatchedBy ~= nil) then
		self.dispatchedBy:stopPropagation();
	end
end

--- Base class for events with data, subclasses MADCATEvent
MADCATDataEvent = MCCreateSubClass(MADCATEvent, {
	-- data relevant to the occured event
	data				= nil,
})

--- Create new data event
-- @param type type of the event
-- @param data data associated with event
function MADCATDataEvent:new(type, data)
	local o = self:defconstructor();
	o:constructor(type, data);
	return o;
end

--- Constructor of data event, must be called from subclasses
-- @param type type of the event
-- @param data data associated with event
function MADCATDataEvent:constructor(type, data)
	self.data = data;
	-- call super constructor
	MADCATEvent.constructor(self, type);
end

--- Class for event listeners
MADCATEventListener = MCCreateClass{
	-- pointer to object
	objectPointer		= nil,
	-- function pointer
	functionPointer		= nil,
}

--- Create new event listener
-- @param objectPointer pointer to object (required to pass self to functions)
-- @param functionPointer pointer to function
function MADCATEventListener:new(objectPointer, functionPointer)
	local o = self:defconstructor();
	o.objectPointer = objectPointer;
	o.functionPointer = functionPointer;
	return o;
end

--- Event listeners collection class, holds array with event listeners, not for external use
MADCATEventListenerCollection = MCCreateClass{
	-- list will all listeners
	listeners			= nil,
	-- list will listeners, that should receive event in current iteration
	listenersDispatchTo = nil,
	-- iterator to notify listeners
	iteratorPropagate	= 0,
	-- number of listeners at the begining of propogation
	listenersTotal		= 0,
}

--- Create new event listeners collection
function MADCATEventListenerCollection:new()
	local o = self:defconstructor();
	o.listeners = {};
	o.listenersDispatchTo = {};
	o.iteratorPropagate = -1;
	return o;
end

--- Add new event listener, if the listener is added during event propagation - it will be invoked on next event propogation
-- @param listenerObject listener object (required to pass self to functions)
-- @param listenerFunction listener function
function MADCATEventListenerCollection:addEventListener(listenerObject, listenerFunction)
	-- is propagating?
	if (self.iteratorPropagate > 0 and #self.listenersDispatchTo == 0) then
		self.iteratorPropagate = self.iteratorPropagate + 1;
		while self.iteratorPropagate <= self.listenersTotal do
			table.insert(self.listenersDispatchTo, self.listeners[iteratorPropagate]);
			self.iteratorPropagate = self.iteratorPropagate + 1;
		end
	end
	-- add listener
	local listener = MADCATEventListener:new(listenerObject, listenerFunction);
	table.insert(self.listeners, listener);
end

--- Remove event listener
-- @param listenerObject listener object
-- @param listenerFunction listener function
function MADCATEventListenerCollection:removeEventListener(listenerObject, listenerFunction)
	-- is propagating?
	if (self.iteratorPropagate > 0 and #self.listenersDispatchTo == 0) then
		self.iteratorPropagate = self.iteratorPropagate + 1;
		while self.iteratorPropagate <= self.listenersTotal do
			table.insert(self.listenersDispatchTo, self.listeners[iteratorPropagate]);
			self.iteratorPropagate = self.iteratorPropagate + 1;
		end
	end
	-- search for listener
	for i, v in ipairs(self.listeners) do
		-- delete listener
		if v.objectPointer == listenerObject and v.functionPointer == listenerFunction then
			table.remove(self.listeners, i);
			break;
		end
	end
end

--- Propagate event to all listeners
-- @param e event to propagate
function MADCATEventListenerCollection:propagate(e)
	--print("EventListenerCollection propagating event " .. e.type);
	e.dispatchedBy = self;
	self.iteratorPropagate = 1;
	self.listenersTotal = #self.listeners;
	local listener = nil;
	while self.iteratorPropagate <= self.listenersTotal do
		-- propagate
		listener = self.listeners[self.iteratorPropagate];
		listener.functionPointer(listener.objectPointer, e);
		self.iteratorPropagate = self.iteratorPropagate + 1;
	end
	-- listeners changed during propagation?
	if #self.listenersDispatchTo > 0 then
		if self.listenersTotal > 0 then
			self.iteratorPropagate = 1;
			self.listenersTotal = #self.listenersDispatchTo;
			while self.iteratorPropagate <= self.listenersTotal do
				-- propagate
				listener = self.listenersDispatchTo[self.iteratorPropagate];
				listener.functionPointer(listener.objectPointer, e);
				self.iteratorPropagate = self.iteratorPropagate + 1;
			end
		end
		-- clear listenersDispatchTo
		for k, v in ipairs(self.listenersDispatchTo) do self.listenersDispatchTo[k]=nil; end
	end
	iteratorPropagate = -1;
end

--- Sop propogation of current event
function MADCATEventListenerCollection:stopPropagation()
	--print("EventListenerCollection stop propagation");
	self.listenersTotal = 0;
end

--- Gen number of event listeners in collection
-- @return number of event listeners in collection
function MADCATEventListenerCollection:numberOfEventListeners()
	return table.getn(self.listeners);
end

--- Remove all event listeners from collection
function MADCATEventListenerCollection:removeAllEventListeners()
	-- set size to 0
	for k, v in ipairs(self.listeners) do self.listeners[k]=nil; end
	self.listenersTotal = 0;
end

--- Event dispatcher class to dispatch events
MADCATEventDispatcher = MCCreateClass{
	-- map with event listeners collections
	listeners			= nil,
}

--- Create new event dispatcher
function MADCATEventDispatcher:new()
	local o = self:defconstructor();
	o:constructor();
	return o;
end

--- Constructor of event dispatcher, must be called from subclasses
function MADCATEventDispatcher:constructor()
	self.listeners = {};
end

--- Add event listener for event specified, if listener is being added during dispatching process it won't be invoked during this process
-- @param eventType type of the event
-- @param listenerObject listener object (required to pass self to functions)
-- @param listenerFunction listener function
function MADCATEventDispatcher:addEventListener(eventType, listenerObject, listenerFunction)
	--print("EventDispatcher adding listener to event dispatcher for event " .. eventType);
	-- search for collection
	local collection = self.listeners[eventType];
	-- collection doesn't exist
	if (collection == nil) then
		collection = MADCATEventListenerCollection:new();
		self.listeners[eventType] = collection;
	end
	collection:addEventListener(listenerObject, listenerFunction);
end

--- Remove event listener for event specified
-- @param eventType type of the event
-- @param listenerObject listener object
-- @param listenerFunction listener function
function MADCATEventDispatcher:removeEventListener(eventType, listenerObject, listenerFunction)
	--print("EventDispatcher removing listener from event dispatcher for event " .. eventType);
	-- search for collection
	local collection = self.listeners[eventType];
	-- collection doesn't exist
	if (collection == nil) then
		return;
	end
	collection:removeEventListener(listenerObject, listenerFunction);
end

--- Dispatch event to all listeners
-- @param event event to dispatch
function MADCATEventDispatcher:dispatchEvent(e)
	--print("EventDispatcher dispatching event " .. e.type);
	-- search for collection
	local collection = self.listeners[e.type];
	-- collection doesn't exist
	if (collection == nil) then
		return;
	end
	collection:propagate(e);
end

--- Get number of event listeners for event type specified
-- @param eventType type of the event
-- @return number of event listeners for event type specified
function MADCATEventDispatcher:numberOfEventListeners(eventType)
	-- search for collection
	local collection = self.listeners[eventType];
	-- collection doesn't exist
	if (collection == nil) then
		return 0;
	end
	return collection:numberOfEventListeners();
end

--- Get number of event listeners for all event types
-- @return number of event listeners for all event types
function MADCATEventDispatcher:numberOfAllEventListeners()
	local count = 0;
	for i, v in pairs(self.listeners) do
		count = count + v:numberOfEventListeners();
	end
	return count;
end

--- Remove all event listeners
function MADCATEventDispatcher:removeAllEventListeners()
	for i, v in pairs(self.listeners) do
		v:removeAllEventListeners();
	end
end
