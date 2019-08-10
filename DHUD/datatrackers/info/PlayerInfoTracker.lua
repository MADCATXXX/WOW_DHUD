--[[-----------------------------------------------------------------------------------
 Original Drathals HUD (c) 2006 by Markus Inger / Drathal / Silberklinge / Silbersegen
 DHUD for WotLK and later expansions (c) 2013 by MADCAT (EU-Гордунни, Мадкат)
 (http://eu.battle.net/wow/en/character/Гордунни/Мадкат/advanced)
---------------------------------------------------------------------------------------
 This file contains functions and classes to track data about unit resources, health,
 buffs and other information
 @author: MADCAT
-----------------------------------------------------------------------------------]]--

-- antitaint local "_" var
local _;
-- tracker helper
local trackingHelper = DHUDDataTrackingHelper;

-----------------------
-- Self info tracker --
-----------------------
--- Base class to track unit spell castings, spells channeling and delays
DHUDSelfInfoTracker = MCCreateSubClass(DHUDUnitInfoTracker, {
	-- defines if unit is resting in the inn (self only)
	isResting			= false,
	-- defines if unit is affecting combat (self only)
	isInCombat			= false,
})

--- Create new unit info tracker, unitId should be specified after constructor
function DHUDSelfInfoTracker:new()
	local o = self:defconstructor();
	o:constructor();
	return o;
end

--- Initialize health-points tracking
function DHUDSelfInfoTracker:init()
	local tracker = self;
	-- process unit name change event
	function self.eventsFrame:PLAYER_GUILD_UPDATE()
		tracker:updateGuildName();
	end
	-- init player only tracking
	self:initPlayerUnitId();
	-- call super
	DHUDUnitInfoTracker.init(self);
end

--- resting state has changed, update
function DHUDSelfInfoTracker:onRestingState(e)
	self.isResting = trackingHelper.isResting;
	self:processDataChanged();
end

--- combat state has changed, update
function DHUDSelfInfoTracker:onCombatState(e)
	self.isInCombat = trackingHelper.isInCombat;
	self:processDataChanged();
end

--- Start tracking data
function DHUDSelfInfoTracker:startTracking()
	-- listen to game events
	self.eventsFrame:RegisterEvent("PLAYER_GUILD_UPDATE");
	trackingHelper:addEventListener(DHUDDataTrackerHelperEvent.EVENT_RESTING_STATE_CHANGED, self, self.onRestingState);
	trackingHelper:addEventListener(DHUDDataTrackerHelperEvent.EVENT_COMBAT_STATE_CHANGED, self, self.onCombatState);
	-- call super
	DHUDUnitInfoTracker.startTracking(self);
end

--- Stop tracking data
function DHUDSelfInfoTracker:stopTracking()
	-- stop listening to game events
	self.eventsFrame:UnregisterEvent("PLAYER_GUILD_UPDATE");
	trackingHelper:removeEventListener(DHUDDataTrackerHelperEvent.EVENT_RESTING_STATE_CHANGED, self, self.onRestingState);
	trackingHelper:removeEventListener(DHUDDataTrackerHelperEvent.EVENT_COMBAT_STATE_CHANGED, self, self.onCombatState);
	-- call super
	DHUDUnitInfoTracker.stopTracking(self);
end

--- Update all data for current unitId
function DHUDSelfInfoTracker:updateData()
	self:onRestingState(nil);
	self:onCombatState(nil);
	-- call super
	DHUDUnitInfoTracker.updateData(self);
end
