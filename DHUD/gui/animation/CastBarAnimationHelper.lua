--[[-----------------------------------------------------------------------------------
 Original Drathals HUD (c) 2006 by Markus Inger / Drathal / Silberklinge / Silbersegen
 DHUD for WotLK and later expansions (c) 2013 by MADCAT (EU-Гордунни, Мадкат)
 (http://eu.battle.net/wow/en/character/гордунни/Мадкат/advanced)
---------------------------------------------------------------------------------------
 This file contains code to help animate casting bar
 @author: MADCAT
-----------------------------------------------------------------------------------]]--

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
	-- defines if cast bar helper is processing updates to make animation
	processingUpdates = false,
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
	-- do not automatically listen to game events, event listener will be added only if required (otherwise to many calls are reducing performance)
	self.processingUpdates = false;
end

--- Subscribe or Unsubscribe from Frequent updates, Performance optimization as it requires a lot of time
-- @param updatesRequired defines if updates are required (either isAnimating, animateHold, animateFade or animateFlash are not nil/false)
function DHUDGUICastBarAnimationHelper:setUpdatesRequired(updatesRequired)
	if (self.processingUpdates == updatesRequired) then
		return;
	end
	self.processingUpdates = updatesRequired;
	if (updatesRequired) then
		DHUDDataTrackers.helper:addEventListener(DHUDDataTrackerHelperEvent.EVENT_UPDATE_FREQUENT, self, self.onUpdateTime);
	else
		DHUDDataTrackers.helper:removeEventListener(DHUDDataTrackerHelperEvent.EVENT_UPDATE_FREQUENT, self, self.onUpdateTime);
	end
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

--- External use function, updates position of empowered cast time
-- @param frame frame fro self group, that was already shown
-- @param height height of empowered position (as float value from 0 to 1)
-- @param colors color of empowered position
function DHUDGUICastBarAnimationHelper:updateCastBarEmpowerPosition(frame, height, colors)
	-- get texture
	local texture = frame.texture;
	-- read clipping info
	local pixelsHeight = self.clippingInformation[1];
	local pixelsFromTopPercent = self.clippingInformation[4];
	local pixelsFromBottomPercent = self.clippingInformation[5];
	local pixelsRealHeightPercent = self.clippingInformation[6];
	local textureX1 = self.clippingInformation[7];
	local textureX2 = self.clippingInformation[8];
	local parentFrame = self.clippingInformation[9];

	-- calculate height
	local textureHeight = pixelsRealHeightPercent * pixelsHeight * 0.005;
	if (textureHeight <= 0) then -- zero height will cause ui to malfunction
		textureHeight = 0.005;
	end

	-- calculate texture position
	local textureTop = 1 - pixelsFromTopPercent - (pixelsRealHeightPercent * (1 - height));
	local textureBottom = pixelsFromBottomPercent + (pixelsRealHeightPercent * (height - 0.005));
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
	self:setUpdatesRequired(true);
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
	self:setUpdatesRequired(false);
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
	self:setUpdatesRequired(true);
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
	self:setUpdatesRequired(true);
end

--- Time updated, update bars
function DHUDGUICastBarAnimationHelper:onUpdateTime(e)
	local timerMs = DHUDDataTrackers.helper.timerMs;
	local timeDiff = timerMs - self.timeUpdatedAt;
	if (timeDiff <= 0) then
		return;
	end
	self.timeUpdatedAt = timerMs;
	-- update cast bar height
	if (self.isAnimating == true) then
		local heightPercent = self.getValueFunction(self.functionsSelfVar) / self.valueTotal;
		if (heightPercent > 1) then
			heightPercent = 1;
		elseif (heightPercent < 0) then
			heightPercent = 0;
		end
		local heightPercentDisplay = self.STATIC_reverseCastingBar and (1 - heightPercent) or heightPercent;
		--print("heightPercentDisplay " .. heightPercentDisplay .. ", self.STATIC_reverseCastingBar " .. MCTableToString(self.STATIC_reverseCastingBar));
		self:updateCastBarHeightAndColor(heightPercentDisplay, self.colorizeFunction(self.functionsSelfVar, heightPercent));
	end
	-- update additional animations
	--print("check self.animateHold " .. MCTableToString(self.animateHold));
	if (self.animateHold ~= nil) then
		self.animateHold = self.animateHold - timeDiff;
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
		-- check for animation stop
		if (self.animateFade <= 0) then
			self.animateFade = nil;
			self:hideCastBar();
		else
			-- update alpha
			for i = 1, DHUDGUI.CASTBAR_GROUP_NUM_FRAMES, 1 do
				self.group[i]:SetAlpha(self.animateFade);
			end
		end
	end
end
