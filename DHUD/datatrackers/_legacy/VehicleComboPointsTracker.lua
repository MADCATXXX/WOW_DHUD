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

-----------------------------------------
-- Vehicle Combo-points Tracker --
-----------------------------------------
--- Class to track vehicle combopoints
DHUDVehicleComboPointsTracker = MCCreateSubClass(DHUDPowerTracker, {
	-- maximum of 5 combo-points
	amountMax			= 5,
	-- default maximum of 5 combo-points
	amountMaxDefault	= 5,
	-- default base of 0 combo-points
	amountBase			= 0,
})
		
--- Create new combo points tracker for player and vehicle
function DHUDVehicleComboPointsTracker:new()
	local o = self:defconstructor();
	o:constructor();
	return o;
end
		
--- Initialize combo-points tracking
function DHUDVehicleComboPointsTracker:init()
	local tracker = self;
	-- process combo point event
	function self.eventsFrame:UNIT_COMBO_POINTS()
		tracker:updateComboPoints();
	end
	-- init unit ids
	self:initVehicleOrNoneUnitId();
end

--- Start tracking data
function DHUDVehicleComboPointsTracker:startTracking()
	-- listen to game events
	self.eventsFrame:RegisterEvent("UNIT_COMBO_POINTS");
end

--- Stop tracking data
function DHUDVehicleComboPointsTracker:stopTracking()
	-- stop listening to game events
	self.eventsFrame:UnregisterEvent("UNIT_COMBO_POINTS");
end

--- Update combopoints data
function DHUDVehicleComboPointsTracker:updateComboPoints()
	self:setAmount(GetComboPoints(self.unitId, "target"));
end

--- Update all data for current unitId
function DHUDVehicleComboPointsTracker:updateData()
	self:updateComboPoints();
end
