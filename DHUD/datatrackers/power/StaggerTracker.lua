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

-------------
-- Stagger --
-------------
--- Class to track players stagger
DHUDStaggerTracker = MCCreateSubClass(DHUDPowerTracker, {
	
})

--- Create new stagger tracker
function DHUDStaggerTracker:new()
	local o = self:defconstructor();
	o:constructor();
	return o;
end

--- Initialize stagger tracking
function DHUDStaggerTracker:init()
	local tracker = self;
	-- process units max health points change event
	function self.eventsFrame:UNIT_MAXHEALTH(unitId)
		if (tracker.unitId ~= unitId) then
			return;
		end
		tracker:updateHealthMax();
	end
	-- init unit ids
	self:initPlayerNotInVehicleOrNoneUnitId();
	-- change resource type
	self:setCustomResourceType(DHUDColorizeTools.COLOR_ID_TYPE_CUSTOM_STAGGER);
end

--- Game time updated, update unit power
function DHUDStaggerTracker:onUpdateTime()
	self:updateStagger();
end

--- Start tracking data
function DHUDStaggerTracker:startTracking()
	-- no game events currently, resource is updated by timer
	trackingHelper:addEventListener(DHUDDataTrackerHelperEvent.EVENT_UPDATE, self, self.onUpdateTime);
end

--- Stop tracking data
function DHUDStaggerTracker:stopTracking()
	-- no game events currently, resource is updated by timer
	trackingHelper:addEventListener(DHUDDataTrackerHelperEvent.EVENT_UPDATE, self, self.onUpdateTime);
end

--- Update stagger for unit
function DHUDStaggerTracker:updateStagger()
	self:setAmount(UnitStagger(self.unitId) or 0);
end

--- Update maximum stagger for unit
function DHUDStaggerTracker:updateHealthMax()
	self:setAmountMax(UnitHealthMax(self.unitId) or 0)
end

--- Update all data for current unitId
function DHUDStaggerTracker:updateData()
	self:updateStagger();
	self:updateHealthMax();
end

--- Start tracking amountMax data
function DHUDStaggerTracker:startTrackingAmountMax()
	self.eventsFrame:RegisterEvent("UNIT_MAXHEALTH");
end

--- Update maximum amount or resource
function DHUDStaggerTracker:updateAmountMax()
	self.eventsFrame:UNIT_MAXHEALTH(self.unitId);
end

--- Stop tracking amountMax data
function DHUDStaggerTracker:stopTrackingAmountMax()
	self.eventsFrame:UnregisterEvent("UNIT_MAXHEALTH");
end