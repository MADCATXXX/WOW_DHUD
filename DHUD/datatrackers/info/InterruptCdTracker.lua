--[[-----------------------------------------------------------------------------------
 Original Drathals HUD (c) 2006 by Markus Inger / Drathal / Silberklinge / Silbersegen
 DHUD for WotLK and later expansions (c) 2013 by MADCAT (EU-Гордунни, Мадкат)
 (http://eu.battle.net/wow/en/character/Гордунни/Мадкат/advanced)
---------------------------------------------------------------------------------------
 This file contains functions and classes to track data about unit player interrupt cooldown
 @author: MADCAT
-----------------------------------------------------------------------------------]]--

-- antitaint local "_" var
local _;
-- tracker helper
local trackingHelper = DHUDDataTrackingHelper;

---------------------------------
-- Player interrupt cd tracker --
---------------------------------
--- Base class to track unit spell castings, spells channeling and delays
DHUDInterruptCdTracker = MCCreateSubClass(DHUDDataTracker, {
	-- defines if player interrupt is on cd or not
	isInterruptOnCd					= false,
	-- defines interrupt cooldown info that is used to check for interrupt cooldown
	lastInterruptCooldownTimer		= nil,
	-- defines time on which last interrupt cooldown was scheduled to end
	lastCooldownEndsOnMs			= 0,
	-- kick cooldown id for current class - table/int
	STATIC_KICK_SPELL_IDS_CURRENT	= 0,
	-- defines if STATIC_KICK_SPELL_IDS_CURRENT is a table
	STATIC_KICK_SPELL_IDS_IS_TABLE	= false,
	-- defines if STATIC_KICK_SPELL_IDS_CURRENT contains ids for pets
	STATIC_KICK_SPELL_CHECK_PET		= false,
	-- kick cooldown ids to be checked for every class
	STATIC_KICK_SPELL_IDS_BY_CLASS	= {
		["ROGUE"] = 1766, ["MAGE"] = 2139, ["WARRIOR"] = 6552, ["PRIEST"] = 15487,
		["DEATHKNIGHT"] = 47528, ["SHAMAN"] = 57994, ["DRUID"] = {106839, 78675},
		["PALADIN"] = 96231--[[, 31935}]], ["MONK"] = 116705, ["WARLOCK"] = {19647, 132409},
		["HUNTER"] = {147362, 187707}, ["DEMONHUNTER"] = 183752, ["EVOKER"] = 351338,
	},
})

--- initialize static data for spell cast tracker, player class won't change
function DHUDInterruptCdTracker:STATIC_init()
	local charclass = trackingHelper.playerClass;
	DHUDInterruptCdTracker.STATIC_KICK_SPELL_IDS_CURRENT = DHUDInterruptCdTracker.STATIC_KICK_SPELL_IDS_BY_CLASS[charclass] or 0;
	DHUDInterruptCdTracker.STATIC_KICK_SPELL_IDS_IS_TABLE = type(DHUDInterruptCdTracker.STATIC_KICK_SPELL_IDS_CURRENT) == "table";
	DHUDInterruptCdTracker.STATIC_KICK_SPELL_CHECK_PET = charclass == "WARLOCK";
end

--- Create new spell cast tracker, unitId should be specified after constructor
function DHUDInterruptCdTracker:new()
	local o = self:defconstructor();
	o:constructor();
	return o;
end

--- Initialize health-points tracking
function DHUDInterruptCdTracker:init()
	local tracker = self;
end

-- process interrupt cooldown change
function DHUDInterruptCdTracker:updateInterruptCd(e)
	local lastInterruptCooldownTimer = nil;
	local lastCooldownEndsOnMs = 0;
	if (DHUDInterruptCdTracker.STATIC_KICK_SPELL_IDS_IS_TABLE) then
		for i, v in ipairs(DHUDInterruptCdTracker.STATIC_KICK_SPELL_IDS_CURRENT) do
			lastInterruptCooldownTimer = self.cooldownsTracker:findTimerForPublicRead(DHUDInterruptCdTracker.STATIC_KICK_SPELL_IDS_CURRENT, 0);
			if (lastInterruptCooldownTimer == nil and DHUDInterruptCdTracker.STATIC_KICK_SPELL_CHECK_PET) then
				lastInterruptCooldownTimer = self.cooldownsTracker:findTimerForPublicRead(DHUDInterruptCdTracker.STATIC_KICK_SPELL_IDS_CURRENT, DHUDCooldownsTracker.TIMER_GROUP_ID_PET_CDS);
			end
			if (lastInterruptCooldownTimer ~= nil and lastInterruptCooldownTimer[2] > 0) then
				break;
			end
		end
	else
		lastInterruptCooldownTimer = self.cooldownsTracker:findTimerForPublicRead(DHUDInterruptCdTracker.STATIC_KICK_SPELL_IDS_CURRENT, 0);
	end
	local isInterruptOnCd = lastInterruptCooldownTimer ~= nil and lastInterruptCooldownTimer[2] > 0;
	if (isInterruptOnCd) then
		lastCooldownEndsOnMs = trackingHelper.timerMs + lastInterruptCooldownTimer[2];
	else
		lastInterruptCooldownTimer = nil;
	end
	if (self.lastInterruptCooldownTimer ~= lastInterruptCooldownTimer or (lastCooldownEndsOnMs - self.lastCooldownEndsOnMs) <= -1.0) then
		self.lastCooldownEndsOnMs = lastCooldownEndsOnMs;
		self.lastInterruptCooldownTimer = lastInterruptCooldownTimer;
		self.isInterruptOnCd = isInterruptOnCd;
		--print("interrupt on cd " .. MCTableToString(lastInterruptCooldownTimer) .. " timerMs " .. trackingHelper.timerMs .. " cooldown end on " .. lastCooldownEndsOnMs);
		-- dispatch event
		self:processDataChangedInstant();
	end
end

--- Get interrupt cooldown of current interrupt spell
function DHUDInterruptCdTracker:getInterruptCooldown()
	if (self.lastInterruptCooldownTimer ~= nil) then
		return self.lastInterruptCooldownTimer[2];
	end
	return 0;
end

--- Start tracking data
function DHUDInterruptCdTracker:startTracking()
	if (self.cooldownsTracker ~= nil) then
		self.cooldownsTracker:addEventListener(DHUDDataTrackerEvent.EVENT_DATA_CHANGED, self, self.updateInterruptCd);
	end
end

--- Stop tracking data
function DHUDInterruptCdTracker:stopTracking()
	if (self.cooldownsTracker ~= nil) then
		self.cooldownsTracker:removeEventListener(DHUDDataTrackerEvent.EVENT_DATA_CHANGED, self, self.updateInterruptCd);
	end
end

--- Update all data for current unitId
function DHUDInterruptCdTracker:updateData()
	self:updateInterruptCd();
end

--- Attach cooldowns tracker to track cooldown inside this tracker
function DHUDInterruptCdTracker:attachCooldownsTracker(cooldownsTracker)
	-- remove listener from old tracker
	if (self.cooldownsTracker ~= nil) then
		self.cooldownsTracker:removeEventListener(DHUDDataTrackerEvent.EVENT_DATA_CHANGED, self, self.updateInterruptCd);
		self.isInterruptOnCd = false;
	end
	self.cooldownsTracker = cooldownsTracker;
	-- add listener to new tracker
	if (cooldownsTracker ~= nil and self.isTracking) then
		self.cooldownsTracker:addEventListener(DHUDDataTrackerEvent.EVENT_DATA_CHANGED, self, self.updateInterruptCd);
		self:updateInterruptCd();
	end
end
