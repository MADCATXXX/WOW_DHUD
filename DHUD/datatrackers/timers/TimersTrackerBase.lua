--[[-----------------------------------------------------------------------------------
 Original Drathals HUD (c) 2006 by Markus Inger / Drathal / Silberklinge / Silbersegen
 DHUD for WotLK and later expansions (c) 2013 by MADCAT (EU-Гордунни, Мадкат)
 (http://eu.battle.net/wow/en/character/гордунни/Мадкат/advanced)
---------------------------------------------------------------------------------------
 This file contains functions and classes to track data about unit resources, health,
 buffs and other information
 @author: MADCAT
-----------------------------------------------------------------------------------]]--

-- antitaint local "_" var
local _;
-- tracker helper
local trackingHelper = DHUDDataTrackingHelper;

------------------------------------
-- Unit timers tracker base class --
------------------------------------

--- Base class for trackers of timers for player buffs and cooldowns
DHUDTimersTracker = MCCreateSubClass(DHUDDataTracker, {
	-- list with timers, that should be shown in GUI, each element is table with following data: { type, timeLeft, duration, id, tooltipId, name, stacks, texture, exists, iterating, sortOrder, grouped, groupData } (where type - type of the timer from class consts, id - spell or item id for tooltip)
	timers				= nil,
	-- table with tables of filtered timers, updated on each filterTimers function call
	filteredTimers		= nil,
	-- list with sources information, used to make mapping between blizzard infomation and internal timer tables, each value contains table with following data: { indexTimerBegin, numTimers, numToSkipMinusOne, timeUpdateAt }
	sources				= nil,
	-- found value from sources table
	sourceInfo			= nil,
	-- time at which timers was updated
	timeUpdatedAt		= 0,
	-- table with custom trackers, each key is timerGroupId, each value is array with customTracker implementation objects
	customTrackers		= nil,
	-- number of custom trackers for perfomance improvement
	customTrackersCount	= 0,
	-- table to describe inactive timer when timers are grouped using groupTimersByTime function
	GROUP_INACTIVE_TIMER = { },
})

--- Constructor of timers tracker
function DHUDTimersTracker:constructor()
	-- init tables
	self.timers = { };
	self.filteredTimers = { };
	self.sources = { };
	self.customTrackers = { };
	self.customTrackersCount = 0;
	-- custom events
	self.eventDataTimersChanged = DHUDDataTrackerEvent:new(DHUDDataTrackerEvent.EVENT_DATA_TIMERS_UPDATED, self);
	-- call super constructor
	DHUDDataTracker.constructor(self);
end

--- Time passed, update all timers
function DHUDTimersTracker:onUpdateTime()
	local timerMs = trackingHelper.timerMs;
	local timeUpdatedAt = self.timeUpdatedAt;
	local diff = timerMs - timeUpdatedAt;
	self.timeUpdatedAt = timerMs;
	-- already updated by data update
	if (diff == 0 or #self.timers == 0) then
		return;
	end
	-- iterate over timers
	for i, v in ipairs(self.timers) do
		-- update time left
		v[2] = v[2] - diff;
	end
	-- dispatch time update event
	self:dispatchEvent(self.eventDataTimersChanged);
end

--- Search for timer that is created for source index specified, and contains info about id specified (internal use only)
-- @param sourceIndex index of timer in source, e.g. index of buff
-- @param id id of the data, e.g. buff spell id
-- @return table with data about timer
function DHUDTimersTracker:findTimer(sourceIndex, id)
	--print("findTimerBegin");
	-- search at index specified
	local indexBegin = self.sourceInfo[1];
	local numTimers = self.sourceInfo[2];
	local numToSkipMinusOne = self.sourceInfo[3];
	local indexToCheck = indexBegin + sourceIndex + numToSkipMinusOne;
	local indexBounds = indexBegin + numTimers;
	--print("indexBegin " .. indexBegin .. ", numTimers " .. numTimers .. ", indexToCheck " .. indexToCheck);
	local timer = self.timers[indexToCheck];
	-- check timer at index
	if (indexToCheck < indexBounds and timer[4] == id and timer[10] ~= true) then
		timer[10] = true; -- set iterating flag
		--print("Timer " .. id .. ", sourceIndex " .. sourceIndex .. ", predictedIndex " ..  indexToCheck .. " was at predicted position");
		return timer;
	end
	--print("findTimer indexBounds " .. indexBounds .. ", indexBegin " .. indexBegin .. ", numTimers " .. numTimers .. ",#timers " .. #self.timers);
	-- perform full search
	local indexLast = indexBounds - 1;
	indexToCheck = indexToCheck - 1; -- start from previous since it's logical location if timer was removed
	-- apply bounds
	if (indexToCheck > indexLast) then
		indexToCheck = indexLast;
	elseif (indexToCheck < indexBegin) then
		indexToCheck = indexBegin;
	end
	-- iterate further after index to check
	for i = indexToCheck, indexLast, 1 do
		timer = self.timers[i];
		-- not already used?
		if (timer[10] ~= true) then
			-- check id
			if (timer[4] == id) then
				timer[10] = true; -- set iterating flag
				-- update number of timers to skip to increase next search speed
				self.sourceInfo[3] = i - indexBegin - sourceIndex;
				--print("Timer " .. id .. ", sourceIndex " .. sourceIndex .. ", predictedIndex " ..  indexToCheck .. ", currentIndex " .. i .. " was not predicted, predict offset is " .. self.sourceInfo[3]);
				return timer;
			end
		end
	end
	indexLast = indexToCheck - 1;
	-- iterate from indexBegin to index to check
	for i = indexBegin, indexLast, 1 do
		timer = self.timers[i];
		-- not already used?
		if (timer[10] ~= true) then
			-- check id
			if (timer[4] == id) then
				timer[10] = true; -- set iterating flag
				-- update number of timers to skip to increase next search speed
				self.sourceInfo[3] = i - indexBegin - sourceIndex;
				--print("Timer " .. id .. ", sourceIndex " .. sourceIndex .. ", predictedIndex " ..  indexToCheck .. ", currentIndex " .. i .. " was not predicted, predict offset is " .. self.sourceInfo[3]);
				return timer;
			end
		end
	end
	-- timer not found, create new { type, timeLeft, duration, id, tooltipId, name, stacks, texture, exists, iterating, sortOrder, grouped, groupData }
	timer = { 0, 0, 0, 0, 0, "", 0, "", true, true, 0 };
	--print("Timer " .. id .. ", sourceIndex " .. sourceIndex .. ", predictedIndex " ..  indexToCheck .. " was created at " .. indexBounds);
	table.insert(self.timers, indexBounds, timer);
	self.sourceInfo[2] = numTimers + 1;
	return timer;
end

--- Search for timer that is created for source, and contains info about id specified (internal use only), this functions always perform full table search
-- do not invoke this function twice if timer was returned once
-- @param id id of the data, e.g. buff spell id
-- @param createIfNone defines if timer should be created if not found
-- @param inUse defines if timer can already be in use
-- @return table with data about timer
function DHUDTimersTracker:findTimerByIdOnly(id, createIfNone, inUse)
	inUse = (inUse == nil) and false or inUse;
	local indexBegin = self.sourceInfo[1];
	local numTimers = self.sourceInfo[2];
	local indexLast = indexBegin + numTimers - 1;
	-- iterate over timers
	for i = indexBegin, indexLast, 1 do
		timer = self.timers[i];
		-- not already used?
		if (timer[10] == inUse) then
			-- check id
			if (timer[4] == id) then
				timer[10] = true; -- set iterating flag
				return timer;
			end
		end
	end
	-- timer not found, create new { type, timeLeft, duration, id, tooltipId, name, stacks, texture, exists, iterating, sortOrder, grouped, groupData } or return
	if (not createIfNone) then
		return nil;
	end
	timer = { 0, 0, 0, 0, 0, "", 0, "", true, true, 0 };
	--print("Timer " .. id .. ", sourceIndex " .. sourceIndex .. ", predictedIndex " ..  indexToCheck .. " was created at " .. indexBounds);
	table.insert(self.timers, indexLast + 1, timer);
	self.sourceInfo[2] = numTimers + 1;
	return timer;
end

--- Check if source contains timer with negative duration
-- @param sourceId id of the source
-- @return true if timers with negative duration are present
function DHUDTimersTracker:containsTimerWithNegativeDuration(sourceId)
	local sourceInfo = self.sources[sourceId];
	local indexBegin = sourceInfo[1];
	local numTimers = sourceInfo[2];
	local n = indexBegin + numTimers - 1;
	for i = indexBegin, n, 1 do
		if (self.timers[i][2] < 0) then
			return true;
		end
	end
	return false;
end

--- Function that should be invoked before iterating over findTimer (internal use only)
-- @param sourceId id of the source, number
function DHUDTimersTracker:findSourceTimersBegin(sourceId)
	--print("findSourceTimersBegin");
	local sourceInfo = self.sources[sourceId];
	-- source not found?
	if (sourceInfo == nil) then
		sourceInfo = { 1, 0, 0, 0 };
		self.sources[sourceId] = sourceInfo;
		-- correct start index if required
		local i = sourceId - 1;
		while (i >= 1) do
			if (self.sources[i] ~= nil) then
				sourceInfo[1] = self.sources[i][1] + self.sources[i][2];
				break;
			end
			i = i - 1;
		end
	end
	--print("findTimer begin source " .. sourceId);
	-- update numToSkipMinusOne
	sourceInfo[3] = -1;
	-- save found source info
	self.sourceInfo = sourceInfo;
end

--- Function that should be invoked after iterating over findTimer (internal use only)
-- @param sourceId id of the source, number
function DHUDTimersTracker:findSourceTimersEnd(sourceId)
	-- update custom data trackers before finishing
	if (self.customTrackersCount > 0) then
		self:updateCustomTrackersData(sourceId);
	end
	--print("findSourceTimersEnd");
	local sourceInfo = self.sources[sourceId];
	-- remove all timers that no longer exists in source
	local indexBegin = sourceInfo[1];
	local numTimers = sourceInfo[2];
	local i = indexBegin + numTimers - 1;
	while (i >= indexBegin) do
		local timer = self.timers[i];
		if (timer[10] == false) then
			timer[9] = false;
			table.remove(self.timers, i);
			numTimers = numTimers - 1;
		end
		timer[10] = false;
		i = i - 1;
	end
	-- save new count
	sourceInfo[2] = numTimers;
	-- save time updated
	sourceInfo[4] = trackingHelper.timerMs;
	-- update indexes for other sources
	i = sourceId + 1;
	indexBegin = indexBegin + numTimers;
	local numSources = #self.sources;
	while (i <= numSources) do
		sourceInfo = self.sources[i];
		sourceInfo[1] = indexBegin;
		indexBegin = indexBegin + sourceInfo[2];
		i = i + 1;
	end
	--print("findTimer end source " .. sourceId);
end

--- Updates timeUpdatedAt variable and timers for sources that wasn't updated, must be called after partial timers update
function DHUDTimersTracker:forceUpdateTimers()
	local timerMs = trackingHelper.timerMs;
	-- iterate over sources
	for i, v in ipairs(self.sources) do
		-- check if source timers are updated
		if (v[4] ~= timerMs) then
			-- update
			local indexBegin = v[1];
			local indexEnd = indexBegin + v[2] - 1;
			local diff = timerMs - v[4];
			-- iterate over timers
			for j = indexBegin, indexEnd, 1 do
				local timer = self.timers[j];
				-- update time left
				timer[2] = timer[2] - diff;
			end
		end
		v[4] = timerMs;
	end
	-- update time updated var, but don't dispatch time update event (not required)
	self.timeUpdatedAt = timerMs;
end

--- Group timers together that have identical timeleft, duration and don't have stacks, timers are grouped only once (internal use only)
-- excess timers won't be deleted but won't be filetered either
-- @param sourceId id of the source, number
-- @param funcSelf self parameter to be passed to function
-- @param func funcion that receives timers and should decide if they are aprotiate to be grouped
function DHUDTimersTracker:groupTimersByTime(sourceId, funcSelf, func)
	local sourceInfo = self.sources[sourceId];
	local firstTimer = sourceInfo[1];
	local lastTimer = firstTimer + sourceInfo[2] - 1;
	local timer, timer2;
	local timersGroup = { };
	-- iterate
	for i = firstTimer, lastTimer, 1 do
		timer = self.timers[i];
		-- timer is active?
		if (timer[10] == true) then
			-- timer was already attemted to be grouped?
			if (timer[12] == true) then
				-- timer was part of the group?
				if (timer[13] ~= nil) then
					-- update timer info, atleast type and stacks, use group info { type, stacks }
					if (timer[13] ~= self.GROUP_INACTIVE_TIMER) then
						timer[1] = timer[13][1]; -- type
						timer[7] = timer[13][2]; -- stacks
					end
				end
			else
				-- timer doesn't have stacks?
				if (timer[7] == 1) then
					-- clear timers group table
					for k, v in ipairs(timersGroup) do timersGroup[k]=nil; end
					-- iterate over other timers
					for j = i + 1, lastTimer, 1 do
						timer2 = self.timers[j];
						-- timer is active, not grouped and don't have stacks?
						if (timer2[10] == true and timer2[12] == nil and timer2[7] == 1) then
							-- check if timeleft and duration is the same
							if (timer[2] == timer2[2] and timer[3] == timer2[3]) then
								-- add to the table
								table.insert(timersGroup, timer2);
							end
						end
					end
					-- found group?
					local numTimersGroup = #timersGroup;
					if (numTimersGroup > 0) then
						-- add to the table first timer
						table.insert(timersGroup, 1, timer);
						numTimersGroup = numTimersGroup + 1;
						-- check back if it's valid group
						local mainTimer = func(funcSelf, timersGroup);
						-- update all timers
						for k, v in ipairs(timersGroup) do
							-- set attempted to be grouped flag
							v[12] = true;
						end
						-- check if we have main timer
						if (mainTimer ~= nil) then
							for k, v in ipairs(timersGroup) do
								if (v == mainTimer) then
									-- update group info { type, stacks }
									local groupInfo = { };
									groupInfo[1] = mainTimer[1];
									groupInfo[2] = numTimersGroup;
									v[13] = groupInfo; -- groupInfo
									v[7] = numTimersGroup; -- stacks
								else
									v[13] = self.GROUP_INACTIVE_TIMER;
								end
							end
						end
					end
				end
			end
		end
	end
end

--- Filter out timers using function specified
-- @param func funcion that desides if item is required or not, also returning sort order (invoked with data about timer, should return nil if timer is not required or number for timer sorting order)
-- @param cacheKey key to be used when storing results in cache, and at which will be stored sorting order for prioritizied spells
-- @param forceUpdate force existsing timers to be refiltered, use for data update only
-- @return table with sorted timers and boolean that defines if only time was changed
function DHUDTimersTracker:filterTimers(func, cacheKey, forceUpdate)
	local changed = false;
	-- find cached timers list
	local filtered = self.filteredTimers[cacheKey];
	if (filtered == nil) then
		filtered = { };
		self.filteredTimers[cacheKey] = filtered;
	end
	-- check current timers existance
	local i = #filtered;
	while (i >= 1) do
		local v = filtered[i];
		v[10] = true;
		-- timer no longer valid?
		if (v[9] == false) then
			table.remove(filtered, i);
			changed = true;
		end
		-- timer no longer filtered?
		if (forceUpdate) then
			v[11] = func(v);
			if (v[11] == nil) then
				table.remove(filtered, i);
				changed = true;
			elseif (v[11] < 1000) then
				v[cacheKey] = v[11];
			end
		end
		i = i - 1;
	end
	local currentNum = #filtered;
	-- check if new timers can be added
	for i, v in ipairs(self.timers) do
		-- already checked?
		if (v[10] == true) then
			v[10] = false;
		elseif (v[13] ~= self.GROUP_INACTIVE_TIMER) then
			local sortOrder = func(v);
			if (sortOrder ~= nil) then
				v[11] = sortOrder;
				table.insert(filtered, v);
				changed = true;
				if (v[11] < 1000) then
					v[cacheKey] = v[11];
				end
				--print("inserting " .. v[6] .. " to " .. cacheKey);
			end
		end
	end
	--[[local text = "";
	for i,v in ipairs(filtered) do
		text = text .. v[6] .. "(" .. v[11] .. "), ";
	end
	print("before sort " .. text);]]--
	-- sort the table if required
	if (changed) then
		-- update sort order for existing items
		i = currentNum;
		while (i >= 1) do
			local v = filtered[i];
			if (v[10]) then
				v[11] = func(v) or 0;
				if (v[11] < 1000) then
					v[cacheKey] = v[11];
				end
			end
			i = i - 1;
		end
		-- sort
		MCSortTableBySubValue(filtered, 11);
	end
	--[[text = cacheKey .. ": ";
	for i,v in ipairs(filtered) do
		text = text .. v[6] .. "(" .. v[11] .. "), ";
	end
	print("after sort " .. text);]]--
	return filtered, changed;
end

--- update custom trackers data for timers group specified
-- @param timersGroup timers group to be updated
function DHUDTimersTracker:updateCustomTrackersData(timersGroup)
	local customTrackersForGroup = self.customTrackers[timersGroup];
	if (customTrackersForGroup == nil) then
		return;
	end
	for i, v in ipairs(customTrackersForGroup) do
		v:updateTimers();
	end
end

--- process custom timer tracker data change
function DHUDTimersTracker:onUpdateCustomTracker(e)
	local timersGroup = e.timersGroup;
	-- iterate over timer group timers
	self:findSourceTimersBegin(timersGroup);
	local indexBegin = self.sourceInfo[1];
	local numTimers = self.sourceInfo[2];
	local indexLast = indexBegin + numTimers - 1;
	for i = indexBegin, indexLast, 1 do
		timer = self.timers[i];
		timer[10] = timer[1] ~= DHUDCustomTimerTracker.TIMER_TYPE_CUSTOM_CREATED; -- set iterating flag, for timer to be not deleted
	end
	self:findSourceTimersEnd(timersGroup); -- this will force an update
	self:processDataChanged();
end

--- add custom tracker for better timers tracking
-- @param customTracker custom tracker to use
-- @param timersGroup id of the timers group to be updated
function DHUDTimersTracker:addCustomTracker(customTracker, timersGroup)
	if (customTracker ~= nil) then
		local customTrackersForGroup = self.customTrackers[timersGroup];
		if (customTrackersForGroup == nil) then
			customTrackersForGroup = { };
			self.customTrackers[timersGroup] = customTrackersForGroup;
		end
		table.insert(customTrackersForGroup, customTracker);
		self.customTrackersCount = self.customTrackersCount + 1;
		customTracker:addEventListener(DHUDDataTrackerEvent.EVENT_DATA_CHANGED, self, self.onUpdateCustomTracker);
	end
end

--- remove custom tracker that allowed better timers tracking
-- @param customTracker custom tracker to use
-- @param timersGroup id of the timers group to be updated
function DHUDTimersTracker:removeCustomTracker(customTracker, timersGroup)
	if (customTracker ~= nil) then
		local customTrackersForGroup = self.customTrackers[timersGroup];
		if (customTrackersForGroup == nil) then
			return;
		end
		-- search for tracker
		for i, v in ipairs(customTrackersForGroup) do
			-- delete tracker
			if v == customTracker then
				table.remove(customTrackersForGroup, i);
				self.customTrackersCount = self.customTrackersCount - 1;
				break;
			end
		end
		customTracker:removeEventListener(DHUDDataTrackerEvent.EVENT_DATA_CHANGED, self, self.onUpdateCustomTracker);
	end
end

--- Compare function for table.sort, must return a boolean value specifying whether the first argument should be before the second argument in the sequence (not a class function, self is nil!)
-- @param a first argument
-- @param b second argument
-- @return return -1 if first parameter should be before second, or 1 if first parameter should be after
function DHUDTimersTracker.compareFilteredTimersForSort(a, b)
	return a[11] - b[11];
end

--- Start tracking data
function DHUDTimersTracker:startTracking()
	-- listen to game events
	trackingHelper:addEventListener(DHUDDataTrackerHelperEvent.EVENT_UPDATE, self, self.onUpdateTime);
end

--- Stop tracking data
function DHUDTimersTracker:stopTracking()
	-- stop listening to game events
	trackingHelper:removeEventListener(DHUDDataTrackerHelperEvent.EVENT_UPDATE, self, self.onUpdateTime);
end