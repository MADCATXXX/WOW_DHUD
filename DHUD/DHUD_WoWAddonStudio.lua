--[[-----------------------------------------------------------------------------------
 Original Drathals HUD (c) 2006 by Markus Inger / Drathal / Silberklinge / Silbersegen
 DHUD for WotLK and later expansions (c) 2013 by MADCAT (EU-Гордунни, Мадкат)
 (http://eu.battle.net/wow/en/character/гордунни/Мадкат/advanced)
---------------------------------------------------------------------------------------
 This file contains code to support debugging in wow addon studio software
 and is not used in game
 @author: MADCAT
-----------------------------------------------------------------------------------]]--

-- determine if running from WoW addon studio (wowBench)
if (UnitAffectingCombat ~= nil) then
	return;
end

-----------------------------------------------
-- add api that is not supported by wowbench --
-----------------------------------------------
function UnitAffectingCombat(unitId)
	return false;
end
function GetSpecialization()
	return 1;
end
function GetNumSpecializations()
	return 3;
end
function GetSpecializationRole(spec)
	return "TANK";
end
function UnitCreatureType(unit)
	return "";
end
function UnitGUID(unit)
	return "";
end
function GetQuestDifficultyColor(level)
	return { 0, 0, 0 };
end
function UnitGetTotalAbsorbs(unit)
	return 0;
end
function UnitGetIncomingHeals(unit)
	return 0;
end
function UnitIsTappedByAllThreatList(unit)
	return 1;
end
function GetSpellInfo(spellId)
	--name, rank, icon, cost, isFunnel, powerType, castTime, minRange, maxRange
	return ("spellName" .. spellId), 0, "", "", false, 0, 1, 0, 10;
end
SpellActivationOverlayFrame = CreateFrame("Frame");
----------------------------------------
-- rewrite api that is causing errors --
----------------------------------------
function UnitLevel(unitId)
	return 85;
end
function UnitHealthMax(unitId)
	return 100;
end
function UnitHealth(unitId)
	return 100;
end
function UnitPowerType(unitId)
	return 0, "MANA", 0, 0, 1;
end
function GetActionCooldown(slotId)
	return 0, 0, false;
end
--------------------------------------------------------------------------------
-- rewrite event frame function, since work bench is using pretty old WoW API --
--------------------------------------------------------------------------------
function MCCreateBlizzEventFrame()
	local frame = CreateFrame("Frame"); -- no local vars, only globals like event, arg1, arg2, arg3
	frame:SetScript("OnEvent", function (self) local func = self[event]; if (func) then func(self, arg1, arg2, arg3); end end);
	return frame;
end