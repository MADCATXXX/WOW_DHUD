--[[-----------------------------------------------------------------------------------
 Original Drathals HUD (c) 2006 by Markus Inger / Drathal / Silberklinge / Silbersegen
 DHUD for WotLK and later expansions (c) 2013 by MADCAT (EU-Гордунни, Мадкат)
 (http://eu.battle.net/wow/en/character/гордунни/Мадкат/advanced)
---------------------------------------------------------------------------------------
 This file contains object that will show PowerBar data on PowerBar GUI slot
 @author: MADCAT
-----------------------------------------------------------------------------------]]--

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
	-- define if health shields should be visible in ui over maximum health
	STATIC_showHealthShieldOverMaxHealth = true,
	-- defines if health shields should be visible in ui
	STATIC_showHealthShield = true,
	-- defines if health heal absorb should be visible in ui
	STATIC_showHealthHealAbsorb = true,
	-- defines if health heal incoming should be visible in ui
	STATIC_showHealthHealIncoming = true,
	-- empty space for some powers
	VALUE_TYPE_POWER_NONE = 0,
	VALUE_INFO_POWER_NONE = { 0, 0 },
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
	local shieldStyle = DHUDSettings:getValue("healthBarOptions_showShields");
	self.STATIC_showHealthShieldOverMaxHealth = (shieldStyle == 2);
	self.STATIC_showHealthShield = shieldStyle ~= 0;
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
	table.insert(self.VALUES_INFO_RESOURCES, self.VALUE_INFO_POWER_NONE);
	table.insert(self.VALUES_INFO_RESOURCES, self.VALUE_INFO_POWER);
	table.insert(self.VALUES_INFO_CUSTOMDATA, self.VALUE_INFO_POWER_NONE);
	table.insert(self.VALUES_INFO_CUSTOMDATA, self.VALUE_INFO_POWER);
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
-- @param valueHeightBegin begin height of the value
-- @param valueHeightEnd end height of the value
function DHUDGuiBarManager:colorizeBar(valueType, valueHeightBegin, valueHeightEnd)
	local valueHeight = valueHeightEnd - valueHeightBegin;
	local colors;
	-- get colors table for health
	if (self.valuesInfo == self.VALUES_INFO_HEALTH) then
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
		else
			colors = DHUDColorizeTools.colors_default;
		end
	-- get colors table for power
	elseif (self.valuesInfo == self.VALUES_INFO_RESOURCES) then
		if (valueType == self.VALUE_TYPE_POWER) then
			colors = DHUDColorizeTools:getColorTableForPower(self.currentDataTracker.unitId, self.currentDataTracker.resourceType, self.currentDataTracker.resourceTypeString);
			-- update height
			if (self.currentDataTracker.amountMin ~= 0) then
				if (valueHeightBegin == 0.5) then
					valueHeight = valueHeightEnd;
				else
					valueHeight = valueHeightBegin;
				end
				--print("valueHeightEnd " .. valueHeightEnd .. ", valueHeightBegin " .. valueHeightBegin .. ", valueHeight " .. valueHeight);
			end
		elseif (valueType == self.VALUE_TYPE_POWER_NONE) then
			return nil;
		else
			colors = DHUDColorizeTools.colors_default;
		end
	-- get colors table for custom power
	elseif (self.valuesInfo == self.VALUES_INFO_CUSTOMDATA) then
		if (valueType == self.VALUE_TYPE_POWER) then
			colors = DHUDColorizeTools:getColorTableForId(self.currentDataTracker.resourceType + self.unitColorId);
			-- update height
			if (self.currentDataTracker.amountMin ~= 0) then
				if (valueHeightBegin == 0.5) then
					valueHeight = valueHeightEnd;
				else
					valueHeight = valueHeightBegin;
				end
				--print("valueHeightEnd " .. valueHeightEnd .. ", valueHeightBegin " .. valueHeightBegin .. ", valueHeight " .. valueHeight);
			end
		elseif (valueType == self.VALUE_TYPE_POWER_NONE) then
			return nil;
		else
			colors = DHUDColorizeTools.colors_default;
		end
	-- unknown colors
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
	--local valueMax = this.currentDataTracker.amountMax;
	local value = this.currentDataTracker.amount * 100 / this.currentDataTracker.amountMax;
	local valueFloor = math.floor(value);
	if (prefix ~= nil) then
		if (value > 0) then
			return prefix .. (precision and DHUDTextTools:formatNumberWithPrecision(value, precision) or DHUDTextTools:formatNumber(valueFloor, nil, valueFloor));
		end
		return "";
	end
	return (precision and DHUDTextTools:formatNumberWithPrecision(value, precision) or DHUDTextTools:formatNumber(valueFloor, nil, valueFloor));
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
	--print("colorizeHealth " .. MCTableToString(this:colorizeBar(this.VALUE_TYPE_HEALTH, 0, value)) .. ", value " .. MCTableToString(value));
	return DHUDColorizeTools:colorToColorizeString(this:colorizeBar(this.VALUE_TYPE_HEALTH, 0, value));
end

--- Create text that will colorize text after it in amount color
-- @param this reference to this bar manager (self is nil)
-- @return text to be shown in gui
function DHUDGuiBarManager:createTextColorizeAmountPowerStart(this)
	local valueMin = this.currentDataTracker.amountMin;
	if (valueMin == 0) then
		return DHUDColorizeTools:colorToColorizeString(this:colorizeBar(this.VALUE_TYPE_POWER, 0, 1));
	else
		local value = this.currentDataTracker.amount;
		if (value > 0) then
			return DHUDColorizeTools:colorToColorizeString(this:colorizeBar(this.VALUE_TYPE_POWER, 0.5, 1));
		elseif (value == 0) then
			return DHUDColorizeTools:colorToColorizeString(this:colorizeBar(this.VALUE_TYPE_POWER, 0.5, 0.5));
		else
			return DHUDColorizeTools:colorToColorizeString(this:colorizeBar(this.VALUE_TYPE_POWER, 0, 0.5));
		end
	end
end

--- Create text that will colorize text after it in amount health shield color
-- @param this reference to this bar manager (self is nil)
-- @return text to be shown in gui
function DHUDGuiBarManager:createTextColorizeAmountHealthShieldStart(this)
	local value = this:getHealthShield() / this.currentDataTracker.amountMax;
	--print("colorizeShield " .. MCTableToString(this:colorizeBar(this.VALUE_TYPE_HEALTH_SHIELD, 0, value)));
	return DHUDColorizeTools:colorToColorizeString(this:colorizeBar(this.VALUE_TYPE_HEALTH_SHIELD, 0, value));
end

--- Create text that will colorize text after it in amount health shield color
-- @param this reference to this bar manager (self is nil)
-- @return text to be shown in gui
function DHUDGuiBarManager:createTextColorizeAmountHealthHealAbsorbStart(this)
	local value = this:getHealthHealAbsorb() / this.currentDataTracker.amountMax;
	--print("colorizeAbsorbHeal " .. MCTableToString(this:colorizeBar(this.VALUE_TYPE_HEALTH_ABSORB, 0, value)));
	return DHUDColorizeTools:colorToColorizeString(this:colorizeBar(this.VALUE_TYPE_HEALTH_ABSORB, 0, value));
end

--- Create text that will colorize text after it in amount health shield color
-- @param this reference to this bar manager (self is nil)
-- @return text to be shown in gui
function DHUDGuiBarManager:createTextColorizeAmountHealthHealIncomingStart(this)
	local value = this:getHealthHealIncoming() / this.currentDataTracker.amountMax;
	--print("colorizeIncomingHeal " .. MCTableToString(this:colorizeBar(this.VALUE_TYPE_HEALTH_HEAL_INCOMMING, 0, value)));
	return DHUDColorizeTools:colorToColorizeString(this:colorizeBar(this.VALUE_TYPE_HEALTH_HEAL_INCOMMING, 0, value));
end

--- Get health shield amount if settings allow this
function DHUDGuiBarManager:getHealthShield()
	return self.STATIC_showHealthShield and self.currentDataTracker.amountExtra or 0;
end

--- Get health shield max amount if settings allow this
function DHUDGuiBarManager:getHealthShieldMax()
	return self.STATIC_showHealthShield and self.currentDataTracker.amountExtraMax or 0;
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
	-- calculate amount total plus shield
	local amountTotalPlusShield = amountTotal;
	local amountShieldMax = self:getHealthShieldMax();
	if (amount + amountShieldMax > amountTotal) then
		amountTotalPlusShield = amount + amountShieldMax;
		-- shields are not shown over max hp, but we reserve 5% of bar height to display shield
		if (not self.STATIC_showHealthShieldOverMaxHealth) then
			if (amount <= amountTotal * 0.95) then
				amountTotalPlusShield = amountTotal;
			else
				amountTotalPlusShield = min(amountTotalPlusShield, amount + amountTotal * 0.05);
			end
		end
	end
	-- shield can't go over total health plus total shield
	if (amountShield + amount > amountTotalPlusShield) then
		amountShield = amountTotalPlusShield - amount;
	end
	-- update heights
	self.valuesHeight[1] = amountNonAbsorbed / amountTotalPlusShield;
	self.valuesHeight[2] = absorbed / amountTotalPlusShield;
	self.valuesHeight[3] = amountShield / amountTotalPlusShield;
	self.valuesHeight[4] = amountHeal / amountTotalPlusShield;
	-- significant height
	local heightSignificant = amountTotal / amountTotalPlusShield;
	-- update gui
	self.helper:updateBar(self.valuesInfo, self.valuesHeight, heightSignificant);
	-- update text
	--print("update text " .. MCTableToString(DHUDSettings:getValue(self.textFormatSettingName)));
	self.textField:DSetText(self.textFormatFunction());
end

--- Function to update power on bar and in the text
function DHUDGuiBarManager:updatePower()
	-- amount total
	local amountTotal = self.currentDataTracker.amountMax;
	local amountMin = self.currentDataTracker.amountMin;
	local amount = self.currentDataTracker.amount;
	-- update heights
	if (amountMin == 0) then
		self.valuesHeight[1] = 0;
		self.valuesHeight[2] = (amount - amountMin) / (amountTotal - amountMin);
	else
		if (amount >= 0) then
			self.valuesHeight[1] = -amountMin / (amountTotal - amountMin);
			self.valuesHeight[2] = amount / (amountTotal - amountMin);
		else
			self.valuesHeight[1] = (amount - amountMin) / (amountTotal - amountMin);
			self.valuesHeight[2] = -amount / (amountTotal - amountMin);
		end
		--print("amount " .. MCTableToString(amount - amountMin) .. ", max " .. MCTableToString(amountTotal - amountMin));
		--print("self.valueHeight " .. MCTableToString(self.valuesHeight));
	end
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
		if (not self.currentDataTracker.resourceTypeIsCustom) then
			self.valuesInfo = self.VALUES_INFO_RESOURCES;
		else
			self.valuesInfo = self.VALUES_INFO_CUSTOMDATA;
		end
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
