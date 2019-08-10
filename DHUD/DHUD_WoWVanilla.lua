--[[-----------------------------------------------------------------------------------
 Original Drathals HUD (c) 2006 by Markus Inger / Drathal / Silberklinge / Silbersegen
 DHUD for WotLK and later expansions (c) 2013 by MADCAT (EU-Гордунни, Мадкат)
 (http://eu.battle.net/wow/en/character/гордунни/Мадкат/advanced)
---------------------------------------------------------------------------------------
 This file contains code to support vanilla api changes
 and is not used in retail game
 @author: MADCAT
-----------------------------------------------------------------------------------]]--

-- variable that describes build type (vanilla/retail)
MCVanilla = true;

-- determine if running from WoW Vanilla (1.13.2)
if (select(4, GetBuildInfo()) >= 20000) then
	MCVanilla = false;
	return;
end

----------------------------------------------
-- add api that is not supported by vanilla --
----------------------------------------------
function GetSpecialization() -- there was no specialization, talents can be used on any tree
	return 1;
end
function GetNumSpecializations() -- there was no specialization, talents can be used on any tree
	return 3;
end
function GetSpecializationRole(spec) -- there was no specialization, talents can be used on any tree
	return "TANK";
end
function UnitGetTotalAbsorbs(unit) -- Can be emulated if needed, e.g. check if target has Power Word: Shield
	return 0;
end
function UnitGetTotalHealAbsorbs(unit) -- no such thing in classic
	return 0;
end
function UnitGetIncomingHeals(unit) -- no incoming heals, I don't think it's possible to check it
	return 0;
end
function GetNumFlyouts() -- spell book multi items, no such thing in classic
	return 0;
end
function UnitHasVehicleUI(unit) -- no vehicles
	return false;
end
function UnitCastingInfo(unit)
	if (unit == "player") then
		return CastingInfo();
	end
	return nil; -- not casting
end
function UnitChannelInfo(unit)
	if (unit == "player") then
		return ChannelInfo();
	end
	return nil; -- not casting
end
SpellActivationOverlayFrame = CreateFrame("Frame"); -- there was no such frame, all calls can be ignored
-------------------------------------------------------------------------------------
-- rewrite event frame function, since WoW API throws exceptions on missing events --
-------------------------------------------------------------------------------------
MCBlizzardEventExcludes = {
	["UNIT_ENTERED_VEHICLE"] = 1, ["UNIT_EXITED_VEHICLE"] = 1, ["VEHICLE_PASSENGERS_CHANGED"] = 1, ["UPDATE_VEHICLE_ACTIONBAR"] = 1,
	["PLAYER_SPECIALIZATION_CHANGED"] = 1,
	["PET_BATTLE_OPENING_START"] = 1, ["PET_BATTLE_CLOSE"] = 1,
	["SPELL_ACTIVATION_OVERLAY_SHOW"] = 1,
	["UNIT_HEAL_PREDICTION"] = 1, ["UNIT_ABSORB_AMOUNT_CHANGED"] = 1, ["UNIT_HEAL_ABSORB_AMOUNT_CHANGED"] = 1,
	["UNIT_SPELLCAST_INTERRUPTIBLE"] = 1, ["UNIT_SPELLCAST_NOT_INTERRUPTIBLE"] = 1,
};

--- Create blizzard event frame to listen to game events
-- @return blizzard event frame
function MCCreateBlizzEventFrame()
	local frame = CreateFrame("Frame");
	frame:SetScript("OnEvent", function (self, event, ...) local func = self[event]; if (func) then func(self, ...); end end);
	frame.RegisterEventBlizz = frame.RegisterEvent;
	frame.UnregisterEventBlizz = frame.UnregisterEvent;
	frame.RegisterEvent = function(self, eventName) -- do not register events that was not available, TODO: check if UNIT_ABSORB_AMOUNT_CHANGED should be emulated
		if (MCBlizzardEventExcludes[eventName] ~= 1) then
			frame:RegisterEventBlizz(eventName);
		end
	end
	frame.UnregisterEvent = function(self, eventName) -- do not register events that was not available
		if (MCBlizzardEventExcludes[eventName] ~= 1) then
			frame:UnregisterEventBlizz(eventName);
		end
	end
	return frame;
end
