--[[-----------------------------------------------------------------------------------
 Original Drathals HUD (c) 2006 by Markus Inger / Drathal / Silberklinge / Silbersegen
 DHUD for WotLK and later expansions (c) 2013 by MADCAT (EU-Гордунни, Мадкат)
 (http://eu.battle.net/wow/en/character/гордунни/Мадкат/advanced)
---------------------------------------------------------------------------------------
 This file contains API that can be used by weak auras or other addons
 This includes checks for cooldowns, gcds, enemy cooldowns, enemy diminishings,
 rogue improved garrote, etc...
 @author: MADCAT
-----------------------------------------------------------------------------------]]--

-- antitaint local "_" var
local _;
-- tracker helper
local trackingHelper = DHUDDataTrackingHelper;

--- Class to provide simple functions for certain checks
DHUDAPI = {
}

-----------------------
-- Rogue API Section --
-----------------------

--- function for event dispatcher debugging
-- @param unitId id of the unit, e.g. "target" (not GUID)
function DHUDAPI:rogueIsGarroteDebuffImproved(unitId)
	if (trackingHelper.playerClass ~= "ROGUE") then
		return false;
	end
	local tracker = DHUDDataTrackers.ROGUE.selfAssasinationGarrote;
	if (tracker == nil) then
		return false;
	end
	local guidToCheck = nil;
	if (unitId == "target") then
		guidToCheck = trackingHelper.guids[unitId];
	else
		guidToCheck = UnitGUID(guidToCheck);
	end
	return tracker:isGarroteDebuffImproved(guidToCheck);
end
