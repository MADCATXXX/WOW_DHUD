--[[-----------------------------------------------------------------------------------
 Original Drathals HUD (c) 2006 by Markus Inger / Drathal / Silberklinge / Silbersegen
 DHUD for WotLK and later expansions (c) 2013 by MADCAT (EU-Гордунни, Мадкат)
 (http://eu.battle.net/wow/en/character/гордунни/Мадкат/advanced)
---------------------------------------------------------------------------------------
 This file contains API that can be used by weak auras or other addons
 This includes checks for cooldowns, gcds, enemy cooldowns, enemy diminishings,
 rogue improved garrote, etc... None of this code is executed unless user calls
 this from his command line/macro
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

--- Macro helper for ROGUES "Sap" range check macro (and rogue/druid search in stealth)
-- So that it selects the target only when enemy is in range
-- Macro code to use with this function (less than 256 symbols):
--[[
/script DHUDAPI:rogueSAPM1()
/targetenemy [noexists]
/script DHUDAPI:rogueSAPM2()
/cleartarget [actionbar:2]
/script ChangeActionBarPage(1)
/focus
/cast Sap
]]-- 
function DHUDAPI:rogueSAPM1()
	if UnitExists("target") then
		DHUDAPI.rogueSAPTargetExist = 1;
	else
		DHUDAPI.rogueSAPTargetExist = 0;
	end;
end
function DHUDAPI:rogueSAPM2()
	local sapName = trackingHelper:getSpellData(6770)[1];
	local localizedClass, englishClass = UnitClass("target");
	if (DHUDAPI.rogueSAPTargetExist == 0 and
		(C_Spell.IsSpellInRange(sapName) ~= true or
		(IsShiftKeyDown() and not(englishClass == "ROGUE" or englishClass == "DRUID")))) then
		ChangeActionBarPage(2); -- macro check this condition, see above
	end;
	--print("sap name " .. MCTableToString(sapName) .. ", targetExisted " .. DHUDAPI.rogueSAPTargetExist .. ", in range " .. MCTableToString(C_Spell.IsSpellInRange(sapName)) .. ", enemy class " .. MCTableToString(englishClass));
end

-------------------------------
-- Auction House API Section --
-------------------------------

--- Macro helper for Auction to buy commodity item under a certain price
-- @param itemsInfo array of info item, each item is { itemIdentifier, maxUnitPrice, maxTotalPrice? }
-- @param config config that can change some of the macro parameters, e.g. { debugMode = true, refreshThrottle = 0.5 }
-- macro itself:
--[[
/script DHUDAPI:auctionBuyCommodity({"Ore", "40g"}, { refreshThrottle = 0.5 })
/click [actionbar:6] MCAucSCP
/script ChangeActionBarPage(2)
]]-- click params are dependent on CVars, macro may need to specify mouse button, e.g. /click [actionbar:6] MCAucSCP LeftButton t
function DHUDAPI:auctionBuyCommodity(itemsInfo, config)
	DHUDAuctionHelper:auctionBuyCommodity(itemsInfo, config);
end

--- Macro helper for Auction to sell commodity items without right clicking on them
-- @param config config that can change some of the macro parameters, e.g. { debugMode = true, refreshThrottle = 0.5 }
-- macro itself:
--[[
/script DHUDAPI:auctionCommodityPlaceIntoAH()
]]--
function DHUDAPI:auctionCommodityPlaceIntoAH(config)
	DHUDAuctionHelper:auctionCommodityPlaceIntoAH(config);
end

--- Macro to open mail, e.g. click "Open All Mail" button
-- @param config config that defines how function should work
-- @return true if mail window was opened and no extra messages are required
function DHUDAPI:auctionOpenAllMail(config)
	return DHUDAuctionHelper:auctionOpenAllMail(config);
end

