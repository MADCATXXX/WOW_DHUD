--[[-----------------------------------------------------------------------------------
 Original Drathals HUD (c) 2006 by Markus Inger / Drathal / Silberklinge / Silbersegen
 DHUD for WotLK and later expansions (c) 2013 by MADCAT (EU-Гордунни, Мадкат)
 (http://eu.battle.net/wow/en/character/гордунни/Мадкат/advanced)
---------------------------------------------------------------------------------------
 This file code to help animate power / health bars
 @author: MADCAT
-----------------------------------------------------------------------------------]]--

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
	-- defines if cast bar helper is processing updates to make animation
	processingUpdates = false,
	-- defines if bars should be animated
	STATIC_animate		= true,
	-- height percent change over 1 second for fast animation speed
	ANIMATION_SPEED_FAST = 1.0,
	-- height percent change over 1 second for slow animation speed
	ANIMATION_SPEED_SLOW = 0.25,
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
	-- do not automatically listen to game events, event listener will be added only if required (otherwise to many calls are reducing performance)
	self.processingUpdates = false;
end

--- Subscribe or Unsubscribe from Frequent updates, Performance optimization as it requires a lot of time
-- @param updatesRequired defines if updates are required (either isAnimating are not nil/false)
function DHUDGUIBarAnimationHelper:setUpdatesRequired(updatesRequired)
	if (self.processingUpdates == updatesRequired) then
		return;
	end
	self.processingUpdates = updatesRequired;
	--print("power bar animates requred: " ..  MCTableToString(updatesRequired));
	if (updatesRequired) then
		DHUDDataTrackers.helper:addEventListener(DHUDDataTrackerHelperEvent.EVENT_UPDATE_FREQUENT, self, self.onUpdateTime);
	else
		DHUDDataTrackers.helper:removeEventListener(DHUDDataTrackerHelperEvent.EVENT_UPDATE_FREQUENT, self, self.onUpdateTime);
	end
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
	-- special case for nil color (do not show bar)
	if (colors == nil) then
		heightBegin = 0;
		heightEnd = 0;
		colors = DHUDColorizeTools.colors_default[1];
	end
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
	self.timeUpdatedAt = DHUDDataTrackers.helper.timerMs - 0.016;
	-- animate
	self.isAnimating = true;
	self:setUpdatesRequired(true);
	-- update on timer
	self:onUpdateTime(nil);
end

--- Set bar visibility to false and end any pending animations
function DHUDGUIBarAnimationHelper:hideBar()
	-- stop animation
	self.isAnimating = false;
	self:setUpdatesRequired(false);
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
	self.timeUpdatedAt = timerMs;
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
			--print("still animating at " .. i .. ", end " .. MCTableToString(v) .. " != current " ..  MCTableToString(self.stateCurrentAnimation[i]));
			self.isAnimating = true;
			break;
		end
	end
	if (not self.isAnimating) then
		self:setUpdatesRequired(false);
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
			self:updateBarHeightAndColor(index, heightBegin, heightEnd, self.colorizeFunction(self.colorizeFunctionSelf, self.stateValuesInfo[i][1], heightBegin / self.significantHeightCurrentAnimation, heightEnd / self.significantHeightCurrentAnimation));
			heightBegin = heightEnd;
			index = index + 1;
		end
	end
end
