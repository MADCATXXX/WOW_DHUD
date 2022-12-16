--[[-----------------------------------------------------------------------------------
 Original Drathals HUD (c) 2006 by Markus Inger / Drathal / Silberklinge / Silbersegen
 DHUD for WotLK and later expansions (c) 2013 by MADCAT (EU-Гордунни, Мадкат)
 (http://eu.battle.net/wow/en/character/гордунни/Мадкат/advanced)
---------------------------------------------------------------------------------------
 This file contains object that will show Power data on Side slot, e.g. Combo Points
 Timers, Runes, etc...
 @author: MADCAT
-----------------------------------------------------------------------------------]]--

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
	-- index of colored charged combopoint
	comboPointsChargeColorIndexes = nil,
	-- defines if player short debuffs should be colorized
	STATIC_colorizePlayerShortDebuffs = false,
	-- defines if player cooldowns lock should be colorized
	STATIC_colorizePlayerCooldownsLock = false,
	-- defines if player short auras should be animated at 30% left
	STATIC_animatePriorityAurasAtEnd = false,
	-- defines if player short auras should be animated at disappear
	STATIC_animatePriorityAurasDisappear = false,
	-- variable name for animation info of timers
	timerAnimationVarName = nil,
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
	-- All shown timers are player guardians
	TIMER_TYPE_PLAYER_GUARDIANS = 3,
	-- All shown auras will be unspecified
	TIMER_TYPE_OTHER = 3,
	-- default combo-point colors
	COMBO_POINT_COLOR_DEFAULT = { "ComboCircleRed", "ComboCircleRed", "ComboCircleRed", "ComboCircleOrange", "ComboCircleGreen", "ComboCirclePurple", "ComboCirclePurple", "ComboCirclePurple", "ComboCircleCyan", "ComboCircleJadeGreen" },
	-- paladin holy power combo-point colors
	COMBO_POINT_COLOR_PALADIN_HOLY_POWER = { "ComboCircleRed", "ComboCircleOrange", "ComboCircleGreen", "ComboCircleGreen", "ComboCircleGreen" },
	-- priest shadow orbs combo-point colors
	--COMBO_POINT_COLOR_PRIEST_SHADOW_ORBS = { "ComboCirclePurple", "ComboCirclePurple", "ComboCirclePurple" },
	-- priest shadow orbs combo-point colors
	COMBO_POINT_COLOR_MAGE_ARCANE_CHARGES = { "ComboCircleCyan", "ComboCircleCyan", "ComboCircleCyan", "ComboCircleCyan" },
	-- warlock soul shards combo-point colors
	COMBO_POINT_COLOR_WARLOCK_SOUL_SHARDS = { "ComboCirclePurple", "ComboCirclePurple", "ComboCirclePurple", "ComboCirclePurple", "ComboCirclePurple" },
	-- monk chi combo-point colors
	COMBO_POINT_COLOR_MONK_CHI = { "ComboCircleJadeGreen", "ComboCircleJadeGreen", "ComboCircleJadeGreen", "ComboCircleJadeGreen", "ComboCircleJadeGreen" },
	-- evoker essence combo-point colors
	COMBO_POINT_COLOR_EVOKER_ESSENCE = { "ComboCircleCyan", "ComboCircleCyan", "ComboCircleCyan", "ComboCircleCyan", "ComboCircleCyan" },
	-- list with rune type to texture name
	RUNES_TYPE_TO_TEXTURE_NAME = {
		[1] = "BlizzardDeathKnightRuneBlood",
		[2] = "BlizzardDeathKnightRuneFrost",
		[3] = "BlizzardDeathKnightRuneUnholy",
		[4] = "BlizzardDeathKnightRuneDeath",
	},
})

--- colorize player debuffs setting has changed
function DHUDSideInfoManager:STATIC_onColorizePlayerDebuffsSettingChange(e)
	self.STATIC_colorizePlayerShortDebuffs = DHUDSettings:getValue("shortAurasOptions_colorizePlayerDebuffs");
end

--- colorize player cooldowns lock setting has changed
function DHUDSideInfoManager:STATIC_onColorizePlayerCooldownsLockSettingChange(e)
	self.STATIC_colorizePlayerCooldownsLock = DHUDSettings:getValue("shortAurasOptions_colorizeCooldownsLock");
end

--- animate priority auras at 30% setting has changed
function DHUDSideInfoManager:STATIC_onAnimatePriorityAurasAtEndSettingChange(e)
	self.STATIC_animatePriorityAurasAtEnd = DHUDSettings:getValue("shortAurasOptions_animatePriorityAurasAtEnd");
	self:changeSpellCircleAnimationFunction();
end

--- colorize priority auras at disappear setting has changed
function DHUDSideInfoManager:STATIC_onAnimatePriorityAurasDisappearSettingChange(e)
	self.STATIC_animatePriorityAurasDisappear = DHUDSettings:getValue("shortAurasOptions_animatePriorityAurasDisappear");
	self:changeSpellCircleAnimationFunction();
end

--- Initialize DHUDGuiBarManager static values
function DHUDSideInfoManager:STATIC_init()
	-- listen to settings change events
	DHUDSettings:addEventListener(DHUDSettingsEvent.EVENT_SPECIFIC_SETTING_CHANGED_PREFIX .. "shortAurasOptions_colorizePlayerDebuffs", self, self.STATIC_onColorizePlayerDebuffsSettingChange);
	DHUDSettings:addEventListener(DHUDSettingsEvent.EVENT_SPECIFIC_SETTING_CHANGED_PREFIX .. "shortAurasOptions_colorizeCooldownsLock", self, self.STATIC_onColorizePlayerCooldownsLockSettingChange);
	DHUDSettings:addEventListener(DHUDSettingsEvent.EVENT_SPECIFIC_SETTING_CHANGED_PREFIX .. "shortAurasOptions_animatePriorityAurasAtEnd", self, self.STATIC_onAnimatePriorityAurasAtEndSettingChange);
	DHUDSettings:addEventListener(DHUDSettingsEvent.EVENT_SPECIFIC_SETTING_CHANGED_PREFIX .. "shortAurasOptions_animatePriorityAurasDisappear", self, self.STATIC_onAnimatePriorityAurasDisappearSettingChange);
	self:STATIC_onColorizePlayerDebuffsSettingChange(nil);
	self:STATIC_onColorizePlayerCooldownsLockSettingChange(nil);
	self:STATIC_onAnimatePriorityAurasAtEndSettingChange(nil);
	self:STATIC_onAnimatePriorityAurasDisappearSettingChange(nil);
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
	self.comboPointsChargeColorIndexes = { };
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

--- Data trackers list setting has been changed, read it
function DHUDSideInfoManager:onDataTrackersSettingChange(e)
	-- update gui var name
	self.timerAnimationVarName = "gui" .. (dataTrackersListSettingName or "");
	-- call super
	DHUDGuiSlotManager.onDataTrackersSettingChange(self, e);
end

--- Change color of single combo-point to specified one
-- @param comboPointIndex index of combo-point to be updated
-- @param colorName name of the color to be used for combo-point
function DHUDSideInfoManager:changeSingleComboPointColor(comboPointIndex, colorName)
	local comboFrame = self.currentGroup[comboPointIndex];
	-- get texture path and crop info
	local path, x0, x1, y0, y1 = unpack(DHUDGUI.textures[colorName]);
	-- get texture
	local texture = comboFrame.texture;
	-- set texture and coordinates
	texture:SetTexture(path);
	texture:SetTexCoord(x0, x1, y0, y1); -- parameters: minX, maxX, minY, maxY
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
		self:changeSingleComboPointColor(i, v);
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
			self:changeSingleComboPointColor(comboIndex, self.comboPointsColorTable[i]);
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
		elseif (bit.band(type, DHUDCooldownsTracker.TIMER_TYPE_MASK_PETSPELL) ~= 0) then
			GameTooltip:SetSpellByID(data[5]);
		elseif (bit.band(type, DHUDCooldownsTracker.TIMER_TYPE_MASK_ITEM) ~= 0) then
			GameTooltip:SetInventoryItem(self.currentDataTracker.unitId, data[5]);
		end
	elseif (self.currentDataTracker:isInstanceOf(DHUDGuardiansTracker)) then
		GameTooltip:SetTotem(data[5]);
	end
end

--- Function to colorize target short auras timer
-- @param timer timer info to colorize
-- @return table with color
function DHUDSideInfoManager:colorizeTargetShortAurasTimer(timer)
	local t;
	if (bit.band(timer[1], DHUDAurasTracker.TIMER_TYPE_MASK_IS_CAST_BY_PLAYER) ~= 0) then
		t = DHUDColorizeTools.cache_targetShortAuras_appliedByPlayer;
	elseif (bit.band(timer[1], DHUDAurasTracker.TIMER_TYPE_MASK_DEBUFF) ~= 0) then
		t = DHUDColorizeTools.cache_targetShortAuras_debuff;
	else
		t = DHUDColorizeTools.cache_targetShortAuras_buff;
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
				t = DHUDColorizeTools.cache_selfShortAuras_debuffMagic;
			elseif (bit.band(timer[1], DHUDAurasTracker.TIMER_TYPE_MASK_IS_POISON) ~= 0) then
				t = DHUDColorizeTools.cache_selfShortAuras_debuffPoison;
			elseif (bit.band(timer[1], DHUDAurasTracker.TIMER_TYPE_MASK_IS_CURSE) ~= 0) then
				t = DHUDColorizeTools.cache_selfShortAuras_debuffCurse;
			elseif (bit.band(timer[1], DHUDAurasTracker.TIMER_TYPE_MASK_IS_DISEASE) ~= 0) then
				t = DHUDColorizeTools.cache_selfShortAuras_debuffDisease;
			else
				t = DHUDColorizeTools.cache_selfShortAuras_debuff;
			end
		else
			t = DHUDColorizeTools.cache_selfShortAuras_debuff;
		end
	else
		t = DHUDColorizeTools.cache_selfShortAuras_buff;
	end
	return DHUDColorizeTools:colorizePercentUsingTable(timer[2] / timer[3], t);
end

--- Function to colorize player cooldown timer
-- @param timer timer info to colorize
-- @return table with color
function DHUDSideInfoManager:colorizePlayerCooldownsTimer(timer)
	local t;
	if (bit.band(timer[1], DHUDCooldownsTracker.TIMER_TYPE_MASK_ITEM) ~= 0) then
		t = DHUDColorizeTools.cache_selfCooldowns_item;
	else
		if (bit.band(timer[1], DHUDCooldownsTracker.TIMER_TYPE_MASK_SCHOOLLOCK) ~= 0) then
			if (self.STATIC_colorizePlayerCooldownsLock) then
				local school = self.currentDataTracker.schoolLockType;
				return DHUDColorizeTools:colorizeBySpellSchool(school);
			else
				t = DHUDColorizeTools.cache_selfCooldowns_spell;
			end
		else
			t = DHUDColorizeTools.cache_selfCooldowns_spell;
		end
	end
	return DHUDColorizeTools:colorizePercentUsingTable(timer[2] / timer[3], t);
end

--- Function to colorize player guardian timer
-- @param timer timer info to colorize
-- @return table with color
function DHUDSideInfoManager:colorizePlayerGuardiansTimer(timer)
	local t;
	if (bit.band(timer[1], DHUDGuardiansTracker.TIMER_TYPE_MASK_ACTIVE) ~= 0) then
		t = DHUDColorizeTools:getColorTableForId(DHUDColorizeTools.COLOR_ID_UNIT_SELF + DHUDColorizeTools.COLOR_ID_TYPE_GUARDIAN_ACTIVE);
	else
		t = DHUDColorizeTools:getColorTableForId(DHUDColorizeTools.COLOR_ID_UNIT_SELF + DHUDColorizeTools.COLOR_ID_TYPE_GUARDIAN_PASSIVE);
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

--- Function to clear spell circle animation
-- @param spellCircleFrame frame to be updated
function DHUDSideInfoManager:clearSpellCircleAnimation(spellCircleFrame)
	if (spellCircleFrame.animatedBySideInfo) then
		local scale = DHUDGUI.scale[DHUDGUI.SCALE_SPELL_CIRCLES];
		spellCircleFrame:SetAlpha(1);
		spellCircleFrame:SetScale(scale);
		spellCircleFrame:SetPoint("CENTER", "DHUD_UIParent", "CENTER", spellCircleFrame.circlePositionX / scale, spellCircleFrame.circlePositionY / scale);
		spellCircleFrame.animatedBySideInfo = false;
	end
end

--- Function to clear spell circle animation
-- @param spellCircleFrame frame to be updated
-- @param timer timer with information about spell circle
function DHUDSideInfoManager:updateSpellCircleAnimationDisappear(spellCircleFrame, timer)
	local guiData = timer[self.timerAnimationVarName];
	-- check for vars init
	if (guiData[4] == 0) then
		guiData[4] = spellCircleFrame:GetAlpha();
	end
	local scale = DHUDGUI.scale[DHUDGUI.SCALE_SPELL_CIRCLES];
	-- update according to time left
	local percent = (1 - timer[2] / 1);
	if (percent > 1) then -- do not try to animate further
		percent = 1;
	end
	local alpha = 0.1 + guiData[4] * (1 - percent);
	if (alpha > 1) then alpha = 1; end
	spellCircleFrame.animatedBySideInfo = true;
	spellCircleFrame:SetAlpha(alpha);
	local newScale = scale * (1 + 0.5 * percent);
	spellCircleFrame:SetScale(newScale);
	spellCircleFrame:SetPoint("CENTER", "DHUD_UIParent", "CENTER", spellCircleFrame.circlePositionX / newScale, spellCircleFrame.circlePositionY / newScale);
end

--- Function to clear spell circle animation
-- @param spellCircleFrame frame to be updated
-- @param timer timer with information about spell circle
function DHUDSideInfoManager:updateSpellCircleAnimationAtEnd(spellCircleFrame, timer)
	local guiData = timer[self.timerAnimationVarName];
	local timerMs = DHUDDataTrackers.helper.timerMs;
	-- check for vars init
	if (guiData[1] == 0) then
		self:clearSpellCircleAnimation(spellCircleFrame);
		guiData[1] = timerMs;
		guiData[2] = 0;
		guiData[3] = true;
	end
	local timeDiff = timerMs - guiData[1];
	guiData[1] = timerMs;
	-- update percent
	guiData[2] = guiData[2] + timeDiff / 0.5;
	-- change direction
	if (guiData[2] > 1) then
		guiData[2] = math.fmod(guiData[2], 1);
		guiData[3] = not guiData[3];
	end
	-- update according to percent
	spellCircleFrame.animatedBySideInfo = true;
	local newAlpha = 0.5 + (guiData[3] and (0.5 * (1 - guiData[2])) or (0.5 * guiData[2]));
	spellCircleFrame:SetAlpha(newAlpha);
	guiData[4] = newAlpha;
end

--- Function to update spell circle animation, code of this function is changed based on settings changeSpellCircleAnimationFunction
-- @param spellCircleFrame frame to be updated
-- @param timer timer with information about spell circle
function DHUDSideInfoManager:updateSpellCircleAnimationFull(spellCircleFrame, timer)
	
end

--- Change spell circle animation function according to current settings
function DHUDSideInfoManager:changeSpellCircleAnimationFunction()
	if (self.STATIC_animatePriorityAurasAtEnd or self.STATIC_animatePriorityAurasDisappear) then 
		function self:updateSpellCircleAnimation(spellCircleFrame, timer)
			self:clearSpellCircleAnimation(spellCircleFrame);
			-- check for priority
			if (timer[self.dataTrackersListSettingName] ~= nil) then
				local timerMs = DHUDDataTrackers.helper.timerMs;
				--print("duration of " .. timer[6] .. " is " .. timer[3] .. " timeLeft " .. timer[2]);
				-- read animation data
				local guiData = timer[self.timerAnimationVarName];
				if (guiData == nil) then
					guiData = { 0, 0, true, 0 }; -- timeUpdatedAt, animPercentStep, endAnimDirectionDown, disappearAnimAlphaStart
					timer[self.timerAnimationVarName] = guiData;
					--print("create data for " .. MCTableToString(timer));
				end
				-- timers with duration of 0 doesn't need to be animated
				if (timer[3] == 0) then
					return;
				end
				-- animate disappear
				if ((timer[2] <= 1) and self.STATIC_animatePriorityAurasDisappear) then
					if (timer[14] ~= true) then
						self:updateSpellCircleAnimationDisappear(spellCircleFrame, timer);
						return;
					end
				end
				-- animate blinking
				if ((timer[2] <= timer[3] * 0.3) and self.STATIC_animatePriorityAurasAtEnd) then
					self:updateSpellCircleAnimationAtEnd(spellCircleFrame, timer);
					return;
				end
			end
		end
	else
		function self:updateSpellCircleAnimation(spellCircleFrame, timer)
			self:clearSpellCircleAnimation(spellCircleFrame);
		end
	end
end

--- Function to update spell circle data
-- @param timers list with timers
function DHUDSideInfoManager:updateSpellCircles(timers)
	timers = timers or self.currentDataTracker:filterTimers(self.currentDataTrackerHelperFunction, self.dataTrackersListSettingName, true);
	self.currentGroup:setFramesShown(#timers);
	local numTimersWithTime = 0;
	-- update icons and times, { type, timeLeft, duration, id, tooltipId, name, stacks, texture, exists, iterating, sortOrder }
	for i, v in ipairs(timers) do
		local spellCircleFrame = self.currentGroup[i];
		spellCircleFrame.data = v;
		spellCircleFrame:SetNormalTexture(v[8]);
		-- colorize
		local color = self.timersColorizeFunc(self, v);
		spellCircleFrame.border:SetVertexColor(color[1], color[2], color[3]);
		-- update animation
		self:updateSpellCircleAnimation(spellCircleFrame, v);
		-- update text
		local time;
		local withTime = (v[2] >= 0);
		if (withTime) then
			numTimersWithTime = numTimersWithTime + 1;
			time = (DHUDColorizeTools:colorToColorizeString(color) .. DHUDTextTools:formatTime(v[2]) .. "|r");
		else
			time = "";
		end
		spellCircleFrame.textFieldTime:DSetText(time);
		local stackText = (v[7] > 1) and (DHUDColorizeTools:colorToColorizeString(color) .. ((v[13] ~= nil) and "&" or "") .. v[7] .. "|r") or "";
		spellCircleFrame.textFieldCount:DSetText(stackText);
	end
	self:setIsRegenerating(numTimersWithTime > 0); -- update regeneration since results are filtered
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
		-- update animation
		self:updateSpellCircleAnimation(spellCircleFrame, v);
		-- update text
		local time = (v[2] >= 0) and (DHUDColorizeTools:colorToColorizeString(color) .. DHUDTextTools:formatTime(v[2]) .. "|r") or "";
		spellCircleFrame.textFieldTime:DSetText(time);
	end
end

--- Function to update runes data
function DHUDSideInfoManager:updateRunes()
	local runesInfo = self.currentDataTracker.runes;
	local frame;
	for i, v in ipairs(runesInfo) do
		frame = self.currentGroup[i];
		-- change texture
		if (frame.runeType ~= v[1]) then
			frame.runeType = v[1];
			local texture = frame.texture;
			local textureName = self.RUNES_TYPE_TO_TEXTURE_NAME[v[1]];
			--print("TextureName " .. MCTableToString(textureName) .. ", v1 " .. MCTableToString(v));
			-- get texture path and update frame
			local path, x0, x1, y0, y1 = unpack(DHUDGUI.textures[textureName]);
			texture:SetTexture(path);
			texture:SetTexCoord(x0, x1, y0, y1);
		end
		-- update time left
		local time = (v[2] >= 0) and DHUDTextTools:formatTime(v[2]) or "";
		frame.textFieldTime:DSetText(time);
	end
end

--- Function to update runes time
function DHUDSideInfoManager:updateRunesTime()
	local runesInfo = self.currentDataTracker.runes;
	local frame;
	for i, v in ipairs(runesInfo) do
		frame = self.currentGroup[i];
		-- update time left
		local time = (v[2] >= 0) and DHUDTextTools:formatTime(v[2]) or "";
		frame.textFieldTime:DSetText(time);
	end
end

--- Function to update combo-points data
function DHUDSideInfoManager:updateComboPoints()
	local amount = self.currentDataTracker.amount;
	local amountExtra = self.currentDataTracker.amountExtra;
	local chargedIndexes = self.currentDataTracker.chargedPowerPointIndexes;
	local numChargedNow = chargedIndexes and #chargedIndexes or 0;
	local chargedHighest = self.currentDataTracker.chargedPowerPointMaxIndex or 0;
	local total = amount + amountExtra;
	-- update colors
	local amountForColors = amount > chargedHighest and amount or chargedHighest; -- need to show required amount of frames in order to highlight some combo-point
	if (amountForColors >= 5) then
		self:changeComboPointColorOrder(1, 5, 6, 10);
	else
		self:changeComboPointColorOrder(1, amountForColors, 6, 10);
	end
	self.currentGroup:setFramesShown(amountForColors + amountExtra);
	-- update alpha and preprocess charged combo-points if needed
	local prevChargeIndexes = self.comboPointsChargeColorIndexes;
	local numChargedPrev = #prevChargeIndexes;
	if (numChargedPrev > 0) then
		self.comboPointsAlpha = 0; -- force alpha override if charged combo-points were shown
	end
	local alpha = self.currentDataTracker.isStoredAmount and 0.5 or 1.0;
	self:changeComboPointsAlpha(alpha);
	-- change charged combo texture
	--print("gui charged combopoints " .. chargedIndex .. ", self value " .. prevChargeIndex);
	if (numChargedPrev > 0 or numChargedNow > 0) then -- combo coloring may be lost due to "changeComboPointColorOrder" function
		-- restore original color
		for i = numChargedPrev, 1, -1 do
			local index = prevChargeIndexes[i];
			self:changeSingleComboPointColor(index, self.comboPointsColorTable[index]);
			table.remove(prevChargeIndexes, i);
		end
		-- set cyan color for charge
		for i = 1, numChargedNow, 1 do
			local index = chargedIndexes[i];
			self:changeSingleComboPointColor(index, "ComboCircleCyan");
			table.insert(prevChargeIndexes, index);
		end
	end
	-- update alpha for charged combo-point if needed
	if (numChargedNow > 0 and total < chargedHighest) then
		for i = 1, chargedHighest do
			local comboFrame = self.currentGroup[i];
			local isCharged = false;
			for j = 1, numChargedNow, 1 do if (chargedIndexes[j] == i) then isCharged = true; break; end; end;
			local comboAlpha = i > total and (isCharged and 0.4 or 0) or 1;
			comboFrame:SetAlpha(self.comboPointsAlpha * comboAlpha);
		end
	end
end

--- Function to update general data that is displayed as combo-points
function DHUDSideInfoManager:updateComboPointsGeneral()
	local amount = floor(self.currentDataTracker.amount);
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
		if (self.currentDataTracker == DHUDDataTrackers.SHAMAN.selfTotems) then
			self.timersType = self.TIMER_TYPE_PLAYER_GUARDIANS;
			self.timersColorizeFunc = self.colorizePlayerGuardiansTimer;
		elseif (self.currentDataTracker == DHUDDataTrackers.ALL.selfCooldowns) then
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
		self.currentGroup:setFramesShown(6);
	-- changed to track combo-points like info
	else
		self.updateFuncTime = self.updateNilTime;
		self:setCurrentGroup(self.comboPointsGroup);
		-- switch by type
		if (self.currentDataTracker == DHUDDataTrackers.ALL.selfComboPoints or self.currentDataTracker == DHUDDataTrackers.ALL.vehicleComboPoints) then
			self.updateFunc = self.updateComboPoints;
			self:changeComboPointColors(self.COMBO_POINT_COLOR_DEFAULT);
		else
			self.updateFunc = self.updateComboPointsGeneral;
			if (self.currentDataTracker == DHUDDataTrackers.MONK.selfChi) then
				self:changeComboPointColors(self.COMBO_POINT_COLOR_MONK_CHI);
			elseif (self.currentDataTracker == DHUDDataTrackers.PALADIN.selfHolyPower) then
				self:changeComboPointColors(self.COMBO_POINT_COLOR_PALADIN_HOLY_POWER);
			--[[elseif (self.currentDataTracker == DHUDDataTrackers.PRIEST.selfShadowOrbs) then
				self:changeComboPointColors(self.COMBO_POINT_COLOR_PRIEST_SHADOW_ORBS);]]--
			elseif (self.currentDataTracker == DHUDDataTrackers.MAGE.selfArcaneCharges) then
				self:changeComboPointColors(self.COMBO_POINT_COLOR_MAGE_ARCANE_CHARGES);
			elseif (self.currentDataTracker == DHUDDataTrackers.WARLOCK.selfSoulShards) then
				self:changeComboPointColors(self.COMBO_POINT_COLOR_WARLOCK_SOUL_SHARDS);
			elseif (self.currentDataTracker == DHUDDataTrackers.EVOKER.selfEssence) then
				self:changeComboPointColors(self.COMBO_POINT_COLOR_EVOKER_ESSENCE);
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
	-- track animation settings change
	DHUDSettings:addEventListener(DHUDSettingsEvent.EVENT_SPECIFIC_SETTING_CHANGED_PREFIX .. "aurasOptions_animatePriorityAurasAtEnd", self, self.onCriticalSettingChange);
	DHUDSettings:addEventListener(DHUDSettingsEvent.EVENT_SPECIFIC_SETTING_CHANGED_PREFIX .. "aurasOptions_animatePriorityAurasDisappear", self, self.onCriticalSettingChange);
end

--- Show preview data
function DHUDSideInfoManager:showPreviewData()
	-- just show all ui elements
	local num = #self.currentGroup;
	self.currentGroup:setFramesShown(num);
end
