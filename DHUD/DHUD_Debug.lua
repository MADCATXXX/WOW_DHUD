--[[-----------------------------------------------------------------------------------
 Original Drathals HUD (c) 2006 by Markus Inger / Drathal / Silberklinge / Silbersegen
 DHUD for WotLK and later expansions (c) 2013 by MADCAT (EU-Гордунни, Мадкат)
 (http://eu.battle.net/wow/en/character/гордунни/Мадкат/advanced)
---------------------------------------------------------------------------------------
 This file contains debug functions and is not used in game
 @author: MADCAT
-----------------------------------------------------------------------------------]]--

--- Class for debugging other objects and their functions
DHUDDebug = {
	-- value to be read by event listeners using self indexing
	debugSelf			= "debugValue",
	-- function pointer to current debug destructor
	currentDebugDestructor = nil,
	-- list of functions for slash commands handling
	slashCommandFunctions = {},
}

--- Change print function, that is used for debugging
--[[local print = function(e)
	_G["DHUD"]:print(e);
end]]--

------------------------------------
-- Event Dispatcher Debug Section --
------------------------------------

--- function for event dispatcher debugging
function DHUDDebug:onTestEventDispatcherHelloEvent(e)
	print("HelloEvent, event type: " .. e.type .. ", self debug var: " .. self.debugSelf);
end

--- function for event dispatcher debugging
function DHUDDebug:onTestEventDispatcherWorldEvent(e)
	print("WorldEvent, event type: " .. e.type .. ", self debug var: " .. self.debugSelf);
end

--- function for event dispatcher debugging
function DHUDDebug:onTestEventDispatcherDataEvent(e)
	print("DataEvent, event type: " .. e.type .. ", data: " .. e.data .. ", self debug var: " .. self.debugSelf);
	e:stopImmediatePropagation(); -- this should prevent DataEvent2
end

--- function for event dispatcher debugging
function DHUDDebug:onTestEventDispatcherDataEvent2(e)
	print("DataEvent2, event type: " .. e.type .. ", data: " .. e.data .. ", self debug var: " .. self.debugSelf);
end

--- function for event dispatcher debugging
function DHUDDebug:testEventDispatcher()
	print("testEventDispatcher - begin");
	local eventDispatcher = MADCATEventDispatcher:new();
	local eventHello = MADCATEvent:new("hello");
	local eventWorld = MADCATEvent:new("world");
	local dataEvent = MADCATDataEvent:new("data", 3);
	-- add listeners
	eventDispatcher:addEventListener("hello", self, self.onTestEventDispatcherHelloEvent);
	eventDispatcher:addEventListener("world", self, self.onTestEventDispatcherWorldEvent);
	eventDispatcher:addEventListener("data", self, self.onTestEventDispatcherDataEvent);
	eventDispatcher:addEventListener("data", self, self.onTestEventDispatcherDataEvent2);
	-- dispatch some events
	eventDispatcher:dispatchEvent(eventHello);
	eventDispatcher:dispatchEvent(eventHello);
	eventDispatcher:dispatchEvent(eventWorld);
	-- remove listeners
	eventDispatcher:removeEventListener("hello", self, self.onTestEventDispatcherHelloEvent);
	eventDispatcher:removeEventListener("world", self, self.onTestEventDispatcherWorldEvent);
	-- dispatch some events
	eventDispatcher:dispatchEvent(eventWorld);
	eventDispatcher:dispatchEvent(eventHello);
	eventDispatcher:dispatchEvent(dataEvent);
	-- remove last listener
	eventDispatcher:removeEventListener("data", self, self.onTestEventDispatcherDataEvent);
	eventDispatcher:removeEventListener("data", self, self.onTestEventDispatcherDataEvent2);
	-- return destructor
	print("testEventDispatcher - end");
	return nil;
end

-------------------------------
-- Data tracker Combo Points --
-------------------------------

--- function for data trackers debugging
function DHUDDebug:onDataComboPointsChange(e)
	print("combo points: " .. e.tracker.amount .. ", amountExtra: " .. e.tracker.amountExtra .. ", isStored: " .. (e.tracker.isStoredAmount and "true" or "false"));
end

--- function to debug data tracker combo points
function DHUDDebug:testDataComboPoints()
	print("testDataComboPoints - begin");
	local cpTrack = DHUDDataTrackers.ALL.selfComboPoints;
	cpTrack:addEventListener(DHUDDataTrackerEvent.EVENT_DATA_CHANGED, self, self.onDataComboPointsChange);
	-- return destructor
	return self.testDataComboPointsDestructor;
end

--- function to stop debugging data tracker combo points
function DHUDDebug:testDataComboPointsDestructor()
	print("testDataComboPoints - end");
	local cpTrack = DHUDDataTrackers.ALL.selfComboPoints;
	cpTrack:removeEventListener(DHUDDataTrackerEvent.EVENT_DATA_CHANGED, self, self.onDataComboPointsChange);
end

-------------------------------
-- Data tracker Player Health --
-------------------------------

--- function for data trackers debugging
function DHUDDebug:onDataPlayerHealthChange(e)
	print("player health: " .. e.tracker.amount .. ", amountExtra: " .. e.tracker.amountExtra .. ", amountHealIncoming: " .. e.tracker.amountHealIncoming .. ", amountHealAbsorb: " .. e.tracker.amountHealAbsorb);
end

--- function to debug data tracker player health
function DHUDDebug:testDataPlayerHealth()
	print("testDataPlayerHealth - begin");
	local selfHealth = DHUDDataTrackers.ALL.selfHealth;
	selfHealth:addEventListener(DHUDDataTrackerEvent.EVENT_DATA_CHANGED, self, self.onDataPlayerHealthChange);
	-- return destructor
	return self.testDataPlayerHealthDestructor;
end

--- function to stop debugging data tracker player health
function DHUDDebug:testDataPlayerHealthDestructor()
	print("testDataPlayerHealth - end");
	local selfHealth = DHUDDataTrackers.ALL.selfHealth;
	selfHealth:removeEventListener(DHUDDataTrackerEvent.EVENT_DATA_CHANGED, self, self.onDataPlayerHealthChange);
end

-------------------------------
-- Data tracker Player Health --
-------------------------------

--- function for data trackers debugging
function DHUDDebug:onDataTargetHealthChange(e)
	print("target health: " .. e.tracker.amount .. ", amountExtra: " .. e.tracker.amountExtra .. ", amountHealIncoming: " .. e.tracker.amountHealIncoming .. ", amountHealAbsorb: " .. e.tracker.amountHealAbsorb);
end

--- function to debug data tracker target health
function DHUDDebug:testDataTargetHealth()
	print("testDataTargetHealth - begin");
	local targetHealth = DHUDDataTrackers.ALL.targetHealth;
	targetHealth:addEventListener(DHUDDataTrackerEvent.EVENT_DATA_CHANGED, self, self.onDataTargetHealthChange);
	-- return destructor
	return self.testDataTargetHealthDestructor;
end

--- function to stop debugging data tracker target health
function DHUDDebug:testDataTargetHealthDestructor()
	print("testDataTargetHealth - end");
	local targetHealth = DHUDDataTrackers.ALL.targetHealth;
	targetHealth:removeEventListener(DHUDDataTrackerEvent.EVENT_DATA_CHANGED, self, self.onDataTargetHealthChange);
end

-------------------------------
-- Data tracker Player Power --
-------------------------------

--- function for data trackers debugging
function DHUDDebug:onDataPlayerPowerChange(e)
	print("player power: " .. e.tracker.amount .. ", amountMax: " .. e.tracker.amountMax .. ", isRegenerating: " .. (e.tracker.isRegenerating and "true" or "false") .. ", amountBase: " .. e.tracker.amountBase);
end

--- function to debug data tracker combo points
function DHUDDebug:testDataPlayerPower()
	print("testDataPlayerPower - begin");
	local selfPower = DHUDDataTrackers.ALL.selfPower;
	selfPower:addEventListener(DHUDDataTrackerEvent.EVENT_DATA_CHANGED, self, self.onDataPlayerPowerChange);
	-- return destructor
	return self.testDataPlayerPowerDestructor;
end

--- function to stop debugging data tracker combo points
function DHUDDebug:testDataPlayerPowerDestructor()
	print("testDataPlayerPower - end");
	local selfPower = DHUDDataTrackers.ALL.selfPower;
	selfPower:removeEventListener(DHUDDataTrackerEvent.EVENT_DATA_CHANGED, self, self.onDataPlayerPowerChange);
end


-------------------------------
-- Data tracker Player Auras --
-------------------------------

--- function for data trackers debugging
function DHUDDebug:onDataPlayerAurasChange(e)
	local timers = e.tracker.timers;
	local text = "player auras: ";
	for i, v in ipairs(timers) do
		text = text .. v[6] .. "(" .. v[2] .. "), ";
	end
	print(text);
end

--- function for data trackers debugging
function DHUDDebug:onDataPlayerAurasTimerUpdate(e)
	--print("player auras timers updated, first timer time: " .. e.tracker.timers[1][2]);
end

--- function to debug data tracker player auras
function DHUDDebug:testDataPlayerAuras()
	print("testDataPlayerAuras - begin");
	local selfAuras = DHUDDataTrackers.ALL.selfAuras;
	selfAuras:addEventListener(DHUDDataTrackerEvent.EVENT_DATA_CHANGED, self, self.onDataPlayerAurasChange);
	selfAuras:addEventListener(DHUDDataTrackerEvent.EVENT_DATA_TIMERS_UPDATED, self, self.onDataPlayerAurasTimerUpdate);
	-- return destructor
	return self.testDataPlayerAurasDestructor;
end

--- function to stop debugging data tracker combo points
function DHUDDebug:testDataPlayerAurasDestructor()
	print("testDataPlayerAuras - end");
	local selfAuras = DHUDDataTrackers.ALL.selfAuras;
	selfAuras:removeEventListener(DHUDDataTrackerEvent.EVENT_DATA_CHANGED, self, self.onDataPlayerAurasChange);
	selfAuras:removeEventListener(DHUDDataTrackerEvent.EVENT_DATA_TIMERS_UPDATED, self, self.onDataPlayerAurasTimerUpdate);
end

-----------------------------------
-- Data tracker Player Cooldowns --
-----------------------------------

--- function for data trackers debugging
function DHUDDebug:onDataPlayerCooldownsChange(e)
	local timers = e.tracker.timers;
	local text = "player cooldowns: ";
	for i, v in ipairs(timers) do
		text = text .. v[6] .. "(" .. v[2] .. "), ";
	end
	print(text);
end

--- function for data trackers debugging
function DHUDDebug:onDataPlayerCooldownsTimerUpdate(e)
	--print("player cooldowns timers updated, first timer time: " .. e.tracker.timers[1][2]);
end

--- function to debug data tracker player auras
function DHUDDebug:testDataPlayerCooldowns()
	print("testDataPlayerCooldowns - begin");
	local selfCooldowns = DHUDDataTrackers.ALL.selfCooldowns;
	selfCooldowns:addEventListener(DHUDDataTrackerEvent.EVENT_DATA_CHANGED, self, self.onDataPlayerCooldownsChange);
	selfCooldowns:addEventListener(DHUDDataTrackerEvent.EVENT_DATA_TIMERS_UPDATED, self, self.onDataPlayerCooldownsTimerUpdate);
	-- return destructor
	return self.testDataPlayerCooldownsDestructor;
end

--- function to stop debugging data tracker combo points
function DHUDDebug:testDataPlayerCooldownsDestructor()
	print("testDataPlayerCooldowns - end");
	local selfCooldowns = DHUDDataTrackers.ALL.selfCooldowns;
	selfCooldowns:removeEventListener(DHUDDataTrackerEvent.EVENT_DATA_CHANGED, self, self.onDataPlayerCooldownsChange);
	selfCooldowns:removeEventListener(DHUDDataTrackerEvent.EVENT_DATA_TIMERS_UPDATED, self, self.onDataPlayerCooldownsTimerUpdate);
end

------------------------------
-- Data tracker Target Info --
------------------------------

--- function for data trackers debugging
function DHUDDebug:onDataTargetInfoChange(e)
	local tracker = e.tracker;
	local text = "target info: name " .. MCTableToString(tracker.name) .. ", guild " .. MCTableToString(tracker.guild) .. ", isPlayer " .. MCTableToString(tracker.isPlayer) .. ", relation " .. MCTableToString(tracker.relation) .. ", level " .. MCTableToString(tracker.level)
		.. ", class " .. MCTableToString(tracker.class) .. ", spec " .. MCTableToString(tracker.spec) .. ", specTexture " .. MCTableToString(tracker.specTexture) .. ", specRole " .. MCTableToString(tracker.specRole) .. ", eliteType " .. MCTableToString(tracker.eliteType)
		.. ", npcType " .. MCTableToString(tracker.npcType) .. ", tagged " .. MCTableToString(tracker.tagged) .. ", communityTagged " .. MCTableToString(tracker.communityTagged) .. ", raidIcon " .. MCTableToString(tracker.raidIcon)
		.. ", pvpFaction " .. MCTableToString(tracker.pvpFaction) .. ", pvpState " .. MCTableToString(tracker.pvpState);
	print(text);
end

--- function to debug data tracker player auras
function DHUDDebug:testDataTargetInfo()
	print("testDataTargetInfo - begin");
	local targetInfo = DHUDDataTrackers.ALL.targetInfo;
	targetInfo:addEventListener(DHUDDataTrackerEvent.EVENT_DATA_CHANGED, self, self.onDataTargetInfoChange);
	-- return destructor
	return self.testDataTargetInfoDestructor;
end

--- function to stop debugging data tracker combo points
function DHUDDebug:testDataTargetInfoDestructor()
	print("testDataTargetInfo - end");
	local targetInfo = DHUDDataTrackers.ALL.targetInfo;
	targetInfo:removeEventListener(DHUDDataTrackerEvent.EVENT_DATA_CHANGED, self, self.onDataTargetInfoChange);
end

------------------------------
-- Data tracker Target Info --
------------------------------

--- function for data trackers debugging
function DHUDDebug:onDataPlayerInfoChange(e)
	local tracker = DHUDDataTrackers.ALL.selfInfo;
	local text = "player info: name " .. MCTableToString(tracker.name) .. ", guild " .. MCTableToString(tracker.guild) .. ", isPlayer " .. MCTableToString(tracker.isPlayer) .. ", relation " .. MCTableToString(tracker.relation) .. ", level " .. MCTableToString(tracker.level)
		.. ", class " .. MCTableToString(tracker.class) .. ", spec " .. MCTableToString(tracker.spec) .. ", specTexture " .. MCTableToString(tracker.specTexture) .. ", specRole " .. MCTableToString(tracker.specRole) .. ", eliteType " .. MCTableToString(tracker.eliteType)
		.. ", npcType " .. MCTableToString(tracker.npcType) .. ", tagged " .. MCTableToString(tracker.tagged) .. ", communityTagged " .. MCTableToString(tracker.communityTagged) .. ", raidIcon " .. MCTableToString(tracker.raidIcon)
		.. ", pvpFaction " .. MCTableToString(tracker.pvpFaction) .. ", pvpState " .. MCTableToString(tracker.pvpState)
		.. ", isInCombat " .. MCTableToString(tracker.isInCombat) .. ", isResting " .. MCTableToString(tracker.isResting);
	print(text);
end

--- function to debug data tracker player auras
function DHUDDebug:testDataPlayerInfo()
	print("testDataPlayerInfo - begin");
	local selfInfo = DHUDDataTrackers.ALL.selfInfo;
	selfInfo:addEventListener(DHUDDataTrackerEvent.EVENT_DATA_CHANGED, self, self.onDataPlayerInfoChange);
	self:onDataPlayerInfoChange(nil);
	-- return destructor
	return self.testDataTargetInfoDestructor;
end

--- function to stop debugging data tracker combo points
function DHUDDebug:testDataPlayerInfoDestructor()
	print("testDataPlayerInfo - end");
	local selfInfo = DHUDDataTrackers.ALL.selfInfo;
	selfInfo:removeEventListener(DHUDDataTrackerEvent.EVENT_DATA_CHANGED, self, self.onDataPlayerInfoChange);
end

----------------------
-- GUI Ellipse Math --
----------------------

--- function for ellipse math debugging
function DHUDDebug:testEllipseMath()
	print("testEllipseMath - begin");
	local elementRadius = 13;
	-- calculate outer circle positions, should return simmilar positions like hardcoded positions of DHUD_PlayerBuffX in old code around 8 values
	print("outer circle positions for elements:");
	DHUDEllipseMath:setDefaultEllipse();
	DHUDEllipseMath:adjustRadiusX(DHUDEllipseMath.HUD_BAR_WIDTH + elementRadius);
	local angleStep = DHUDEllipseMath:calculateAngleStep(elementRadius);
	local numFit = DHUDEllipseMath:calculateNumElementsFit(elementRadius);
	local angle = -DHUDEllipseMath.angleArc + angleStep / 2;
	for i = 1, numFit do
		local x, y = DHUDEllipseMath:calculatePositionInAddonCoordinates(angle);
		print("element " .. i .. " position: " .. x .. ", " .. y .. " (angle "  .. angle .. ")");
		angle = angle + angleStep;
	end
	-- calculate inner circle positions, should return simmilar positions like hardcoded positions of DHUD_TargetDeBuffX in old code around 6 values
	print("inner circle position for elements:");
	DHUDEllipseMath:setDefaultEllipse();
	DHUDEllipseMath:adjustRadiusX(-DHUDEllipseMath.HUD_BAR_WIDTH - elementRadius);
	angleStep = DHUDEllipseMath:calculateAngleStep(elementRadius);
	numFit = DHUDEllipseMath:calculateNumElementsFit(elementRadius);
	angle = -DHUDEllipseMath.angleArc + angleStep / 2;
	for i = 1, numFit do
		local x, y = DHUDEllipseMath:calculatePositionInAddonCoordinates(angle);
		print("element " .. i .. " position: " .. x .. ", " .. y .. " (angle "  .. angle .. ")");
		angle = angle + angleStep;
	end
	-- return destructor
	print("testEllipseMath - end");
	return nil;
end

--- function for ellipse math debugging
-- @param name of the frame
function DHUDDebug:testEllipseMathDrawCurrentEllipseArc(name)
	local lineRadius = 1;
	numFit = DHUDEllipseMath:calculateNumElementsFit(lineRadius);
	angleStep = DHUDEllipseMath:calculateAngleStep(lineRadius);
	angle = -DHUDEllipseMath.angleArc + angleStep / 2;
	for i = 1, numFit do
		local x, y = DHUDEllipseMath:calculatePositionInAddonCoordinates(angle);
		local frame = DHUDGUI:createTextureFrame(name .. i, "DHUD_UIParent", "CENTER", "CENTER", 0, 0, 2, 2, "OverlaySpellCircle", false);
		DHUDGUI:drawFrameBackdrop(frame, 1, 0, 0, 1);
		frame:SetFrameStrata("HIGH");
		frame:SetPoint("CENTER", "DHUD_UIParent", "CENTER", -x, y);
		angle = angle + angleStep;
	end
end

--- function for ellipse math debugging
function DHUDDebug:testEllipseMathDraw()
	print("testEllipseMathDraw - begin");
	print("draw Ellipse arc between 2 big bars");
	DHUDEllipseMath:setDefaultEllipse();
	self:testEllipseMathDrawCurrentEllipseArc("testEllipseMathDraw1_");
	print("draw Ellipse arc between at outer big bar");
	DHUDEllipseMath:adjustRadiusX(DHUDEllipseMath.HUD_BAR_WIDTH);
	self:testEllipseMathDrawCurrentEllipseArc("testEllipseMathDraw2_");
	print("draw Ellipse arc for spell circles at outer big bar");
	DHUDEllipseMath:adjustRadiusX(13.6);
	self:testEllipseMathDrawCurrentEllipseArc("testEllipseMathDraw3_");
	print("draw Ellipse arc at inner big bar");
	DHUDEllipseMath:setDefaultEllipse();
	DHUDEllipseMath:adjustRadiusX(-DHUDEllipseMath.HUD_BAR_WIDTH);
	self:testEllipseMathDrawCurrentEllipseArc("testEllipseMathDraw4_");
	print("draw Ellipse arc at inner small bar");
	DHUDEllipseMath:adjustRadiusX(-DHUDEllipseMath.HUD_SMALLBAR_WIDTH);
	self:testEllipseMathDrawCurrentEllipseArc("testEllipseMathDraw5_");
	print("draw Ellipse arc for spell circles at inner small bar");
	DHUDEllipseMath:adjustRadiusX(-13.6);
	self:testEllipseMathDrawCurrentEllipseArc("testEllipseMathDraw5_");
	-- return destructor
	print("testEllipseMathDraw - end");
	return nil;
end

--------------------
-- GUI Text tools --
--------------------

--- function for text tools debugging
function DHUDDebug:testTextTools()
	print("testTextTools - begin");
	-- time format
	print("Time format tests:");
	local times = { 0.7, 12, 100, 7200, 90000 };
	for i, v in ipairs(times) do
		print(v .. " -> " .. DHUDTextTools:formatTime(v));
	end
	-- number format
	print("Number format tests (limit to 5 digits):");
	local numbers = { 100500, 222000212, 2020002122, 2000, 7000, 1, 0 };
	for i, v in ipairs(numbers) do
		print(v .. " -> " .. DHUDTextTools:formatNumber(v, 5));
	end
	-- number format
	print("User data format tests (<value> = \"result\", <value(10)> = \"result10\"):");
	local tableFuncs = { 
		value = function(self, arg, ...)
			if (... ~= nil) then
				--print("local arguments: " .. MCTableToString({...}));
				return arg .. select(1, ...);
			end
			return arg;
		end,
	};
	local format = "hello <value> world";
	print(format .. " -> " .. DHUDTextTools:parseDataFormatToFunction(format, tableFuncs, "result")());
	format = "<value> hello <nonexistent> <value(12, 11)> <na> world <value(13, 25)> <value>";
	print(format .. " -> " .. DHUDTextTools:parseDataFormatToFunction(format, tableFuncs, "result")());
	-- return destructor
	print("testTextTools - end");
	return nil;
end

---------------------
-- GUI Color tools --
---------------------

--- function for color tools debugging
function DHUDDebug:testColorTools()
	print("testColorTools - begin");
	-- hex to color
	print("Hex to color tests:");
	local hex = "80ffaa";
	local rgb = DHUDColorizeTools:hexToColor(hex);
	print("Hex " .. hex .. " -> (" .. rgb[1] .. ", " .. rgb[2] .. ", " .. rgb[3] .. ")");
	-- color to hex
	print("Color to hex tests:");
	rgb = { 0.5, 0.33, 0.75 };
	hex = DHUDColorizeTools:colorToHex(rgb);
	print("RGB (" .. rgb[1] .. ", " .. rgb[2] .. ", " .. rgb[3] .. ") -> " .. hex);
	-- return destructor
	print("testColorTools - end");
	return nil;
end

-------------------
-- Settings test --
-------------------

--- function for settings debugging
function DHUDDebug:onSettingsSettingChange(e)
	print("Specific setting changed, setting name: " .. e.setting);
end

--- function for settings debugging
function DHUDDebug:onSettingsGroupChange(e)
	print("Specific setting group changed, setting name: " .. e.setting);
end

--- function for settings debugging
function DHUDDebug:testSettings()
	print("testSettings - begin");
	-- hex to color
	print("Listening to events: specific setting = scale_main, group setting = scale");
	DHUDSettings:addEventListener(DHUDSettingsEvent.EVENT_SPECIFIC_SETTING_CHANGED_PREFIX .. "scale_main", self, self.onSettingsSettingChange);
	DHUDSettings:addEventListener(DHUDSettingsEvent.EVENT_SPECIFIC_GROUP_SETTING_CHANGED_PREFIX .. "scale", self, self.onSettingsGroupChange);
	-- get setting
	print("Get scale_main setting: " .. MCTableToString(DHUDSettings:getValue("scale_main")));
	-- set setting
	print("Setting scale_main setting to 100500...");
	DHUDSettings:setValue("scale_main", 100500);
	-- print contents
	print("Printing contents of setting tables...");
	print(DHUDSettings:printSettingTableToString("settings", DHUDSettings.settings));
	print(DHUDSettings:printSettingTableToString("savedVars", DHUD_SAVED_VARS_TEMP));
	-- read value
	print("Get scale_main setting: " .. MCTableToString(DHUDSettings:getValue("scale_main")));
	-- return destructor
	print("testSettings - end");
	DHUDSettings:removeEventListener(DHUDSettingsEvent.EVENT_SPECIFIC_SETTING_CHANGED_PREFIX .. "scale_main", self, self.onSettingsSettingChange);
	DHUDSettings:removeEventListener(DHUDSettingsEvent.EVENT_SPECIFIC_GROUP_SETTING_CHANGED_PREFIX .. "scale", self, self.onSettingsGroupChange);
	return nil;
end

-------------------------------------------------
-- Functions to start/stop debugging something --
-------------------------------------------------

--- Start debugging something
-- @param funcPointer function to start debugging, pass nil to stop debugging
function DHUDDebug:debug(funcPointer)
	local wasDebugging = false;
	-- check current debugging function
	if (self.currentDebugDestructor ~= nil) then
		self.currentDebugDestructor(self);
		self.currentDebugDestructor = nil;
		wasDebugging = true;
	end
	-- save new debugging function
	if (funcPointer) then
		self.currentDebugDestructor = funcPointer(self);
	else
		if (wasDebugging) then
			print("debug - stop debugging");
		else
			print("debug - not debugging");
		end
	end
end

----------------------------------
-- Debug slash commands handler --
----------------------------------

--- Initialize slash commands handling
function DHUDDebug:SlashCommandHandlerInit()
	-- set functions
	self.slashCommandFunctions["lib_ed"] = self.testEventDispatcher;
	self.slashCommandFunctions["dt_cp"] = self.testDataComboPoints;
	self.slashCommandFunctions["dt_pa"] = self.testDataPlayerAuras;
	self.slashCommandFunctions["dt_pc"] = self.testDataPlayerCooldowns;
	self.slashCommandFunctions["dt_ph"] = self.testDataPlayerHealth;
	self.slashCommandFunctions["dt_th"] = self.testDataTargetHealth;
	self.slashCommandFunctions["dt_pp"] = self.testDataPlayerPower;
	self.slashCommandFunctions["dt_ti"] = self.testDataTargetInfo;
	self.slashCommandFunctions["dt_pi"] = self.testDataPlayerInfo;
	self.slashCommandFunctions["gui_em"] = self.testEllipseMath;
	self.slashCommandFunctions["gui_tt"] = self.testTextTools;
	self.slashCommandFunctions["gui_emdraw"] = self.testEllipseMathDraw;
	self.slashCommandFunctions["gui_ct"] = self.testColorTools;
	self.slashCommandFunctions["set_test"] = self.testSettings;
	self.slashCommandFunctions["stop"] = false;
end

--- Handler for commands passed from chat using "/dhud"
-- @param name function quick name to start debugging
function DHUDDebug:SlashCommandHandler(name)
	if (name == nil) then
		name = "";
	end
	local funcPointer = self.slashCommandFunctions[name];
	if (funcPointer ~= nil) then
		self:debug(funcPointer);
	else
		print("requested debug function not found, available functions:");
		for i,v in pairs(self.slashCommandFunctions) do
			print(i);
		end
	end
end

