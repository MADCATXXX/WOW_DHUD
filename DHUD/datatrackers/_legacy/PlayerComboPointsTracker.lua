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

---------------------------------
-- Player Combo-points Tracker --
---------------------------------
--- Class to track players combopoints
DHUDPlayerComboPointsTracker = MCCreateSubClass(DHUDSpecificPowerTracker, {
	-- maximum of 5 combo-points
	amountMax			= 5,
	-- default maximum of 5 combo-points
	amountMaxDefault	= 5,
	-- default base of 0 combo-points
	amountBase			= 0,
	-- spell id of the rogue buff for bonus combo-points
	SPELLID_ROGUE_ANTICIPATION = 115189,
})
		
--- Create new combo points tracker for player and vehicle
function DHUDPlayerComboPointsTracker:new()
	local o = self:defconstructor();
	o:constructor();
	return o;
end
		
--- Initialize combo-points tracking
function DHUDPlayerComboPointsTracker:init()
	local tracker = self;
	-- call super
	DHUDSpecificPowerTracker.init(self);
	-- set unit power type
	self:setResourceType(4, "COMBO_POINTS");
	-- combopoints available only for druid and rogue
	if (trackingHelper.playerClass == "ROGUE" or trackingHelper.playerClass == "DRUID") then
		self:initPlayerNotInVehicleOrNoneUnitId();
	end
	-- process aura changing and data update for rogues
	--[[if (trackingHelper.playerClass == "ROGUE") then
		function self.eventsFrame:UNIT_AURA(unitId)
			if (unitId == tracker.unitId) then
				tracker:updateRogueAnticipation();
			end
		end
		--- Update all data for current unitId
		function self:updateData()
			self:updateRogueAnticipation();
			-- call super
			DHUDSpecificPowerTracker.updateData(self);
		end
	end]]--
end

--- Start tracking data
function DHUDPlayerComboPointsTracker:startTracking()
	-- listen to game events
	--[[if (trackingHelper.playerClass == "ROGUE") then
		self.eventsFrame:RegisterEvent("UNIT_AURA");
	end]]--
	-- call super
	DHUDSpecificPowerTracker.startTracking(self);
end

--- Stop tracking data
function DHUDPlayerComboPointsTracker:stopTracking()
	-- stop listening to game events
	--[[if (trackingHelper.playerClass == "ROGUE") then
		self.eventsFrame:UnregisterEvent("UNIT_AURA");
	end]]--
	-- call super
	DHUDSpecificPowerTracker.stopTracking(self);
end

--- Update number of rogue anticipation stacks
function DHUDPlayerComboPointsTracker:updateRogueAnticipation()
	-- add anticipation for rogues
	if (self.amountExtra > 0 or self.amount >= self.amountMax) then
		local buffcount;
		_, _, buffcount = UnitBuff(self.unitId, trackingHelper:getSpellName(self.SPELLID_ROGUE_ANTICIPATION));
		if (buffcount) then
			self:setAmountExtra(buffcount);
		else
			self:setAmountExtra(0);
		end
	end
end
