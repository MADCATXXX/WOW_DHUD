--[[-----------------------------------------------------------------------------------
 Original Drathals HUD (c) 2006 by Markus Inger / Drathal / Silberklinge / Silbersegen
 DHUD for WotLK and later expansions (c) 2013 by MADCAT (EU-Гордунни, Мадкат)
 (http://eu.battle.net/wow/en/character/гордунни/Мадкат/advanced)
---------------------------------------------------------------------------------------
 This file contains code to support vanilla api changes
 and is not used in retail game
 @author: MADCAT
-----------------------------------------------------------------------------------]]--

-- build version from Game API
local buildNum = select(4, GetBuildInfo());

-- variable that describes build type (vanilla/retail)
MCVanilla = math.floor(buildNum / 10000);

-- determine if running from WoW Vanilla (1.13.2) or Burning Crusade classic/WotLK classic/Cataclysm classic
if (buildNum >= 50000) then
	MCVanilla = 0;
	return;
end

----------------------------------------------
-- add api that is not supported by vanilla --
----------------------------------------------
-- override Cataclysm API
if (MCVanilla < 5) then -- less than Pandaria
	if (GetSpecialization == nil) then
		GetSpecialization = function() -- there was no specialization, talents can be used on any tree
			return 1;
		end
	end
	if (GetNumSpecializations == nil) then
		GetNumSpecializations = function() -- there was no specialization, talents can be used on any tree
			return 3;
		end
	end
	if (GetSpecializationRole == nil) then
		GetSpecializationRole = function(spec) -- there was no specialization, talents can be used on any tree
			return "TANK";
		end
	end
	if (GetArenaOpponentSpec == nil) then
		GetArenaOpponentSpec = function(unit)
			return nil; -- there was no specialization, talents can be used on any tree
		end
	end
	if (UnitGetTotalAbsorbs == nil) then
		UnitGetTotalAbsorbs = function(unit) -- Can be emulated if needed, e.g. check if target has Power Word: Shield
			return 0;
		end
	end
	if (UnitGetTotalHealAbsorbs == nil) then
		UnitGetTotalHealAbsorbs = function(unit) -- no such thing in classic
			return 0;
		end
	end
	if (GetUnitTotalModifiedMaxHealthPercent == nil) then
		GetUnitTotalModifiedMaxHealthPercent = function(unit) -- no such thing in classic
			return 0;
		end
	end
	if (GetNumFlyouts == nil) then
		GetNumFlyouts = function() -- spell book multi items, no such thing in classic
			return 0;
		end
	end
	if (GetUnitChargedPowerPoints == nil) then
		GetUnitChargedPowerPoints = function(unit)
			return nil; -- combo points not charged (should return array with charged combo-points)
		end
	end
	if (TargetFrame_OpenMenu == nil) then
		TargetFrame_OpenMenu = function(frame)
			local menu, raidId;
			-- check if enemy
			if (UnitIsEnemy("target", "player")) then
				menu = "TARGET";
			else
				-- check if self
				if (UnitIsUnit("target", "player")) then
					menu = "SELF";
				-- check if vehicle
				elseif (UnitIsUnit("target", "vehicle")) then
					menu = "VEHICLE";
				-- check if pet
				elseif (UnitIsUnit("target", "pet")) then
					menu = "PET";
				-- check if player
				elseif (UnitIsPlayer("target")) then
					-- check if raid player
					raidId = UnitInRaid("target");
					if (raidId) then
						menu = "RAID_PLAYER";
					-- check if party player
					elseif (UnitInParty("target")) then
						menu = "PARTY";
					-- unit is player
					else
						menu = "PLAYER";
					end
				else
					-- unit is other target
					menu = "TARGET";
				end
			end
			UnitPopup_ShowMenu(frame, menu, "target", nil, raidId);
		end
	end
	if (UnitPopup_OpenMenu == nil) then
		UnitPopup_OpenMenu = function(which, contextData)
			UnitPopup_ShowMenu(contextData.frame, which, contextData.unit);
		end
	end
	if (SpellActivationOverlayFrame == nil) then
		SpellActivationOverlayFrame = CreateFrame("Frame"); -- there was no such frame, all calls can be ignored
	end
	
	if (Enum == nil) then
		Enum = {};
	end
	if (C_Spell == nil) then
		C_Spell = {};
	end
	if (C_Spell.GetSpellInfo == nil) then
		C_Spell.GetSpellInfo = function(spellId)
			local spell = {};
			local oldSpell = { GetSpellInfo(spellId) };
			spell.name = oldSpell[1];
			spell.rank = oldSpell[2];
			spell.iconID = oldSpell[3];
			spell.castTime = oldSpell[4];
			spell.minRange = oldSpell[5];
			spell.maxRange = oldSpell[6];
			spell.spellID = oldSpell[7];
			return spell;
		end
	end
	if (C_Spell.IsSpellPassive == nil) then
		C_Spell.IsSpellPassive = function(spellId)
			return IsPassiveSpell(spellId);
		end
	end
	if (C_Spell.GetSpellCharges == nil) then
		C_Spell.GetSpellCharges = function(spellId)
			local chargeInfo = {};
			local oldCharge = { GetSpellCharges(spellId) };
			chargeInfo.currentCharges = oldCharge[1];
			chargeInfo.maxCharges = oldCharge[2];
			chargeInfo.cooldownStartTime = oldCharge[3];
			chargeInfo.cooldownDuration = oldCharge[4];
			chargeInfo.chargeModRate = oldCharge[5];
			return chargeInfo;
		end
	end
	if (C_Spell.GetSpellCooldown == nil) then
		C_Spell.GetSpellCooldown = function(spellId)
			local cdInfo = {};
			local oldInfo = { GetSpellCooldown(spellId) };
			cdInfo.startTime = oldInfo[1];
			cdInfo.duration = oldInfo[2];
			cdInfo.isEnabled = oldInfo[3];
			cdInfo.modRate = oldInfo[4];
			return cdInfo;
		end
	end
	if (C_Spell.IsSpellInRange == nil) then
		C_Spell.IsSpellInRange = function(spellId, unit)
			local inRange = IsSpellInRange(spellId, unit);
			return inRange and (inRange == 1);
		end
	end
	
	if (Enum.SpellBookSpellBank == nil) then
		Enum.SpellBookSpellBank = { Player = 0, Pet = 1 };
	end
	if (C_SpellBook == nil) then
		C_SpellBook = {};
	end
	if (C_SpellBook.GetNumSpellBookSkillLines == nil) then
		C_SpellBook.GetNumSpellBookSkillLines = function()
			return GetNumSpellTabs();
		end
	end
	if (C_SpellBook.GetSpellBookSkillLineInfo == nil) then
		C_SpellBook.GetSpellBookSkillLineInfo = function(index)
			local skillLineInfo = {};
			local oldBookName, olbBookTexture, oldBookOffset, oldBookNumSpells = GetSpellTabInfo(index);
			skillLineInfo.name = oldBookName;
			skillLineInfo.iconID = olbBookTexture;
			skillLineInfo.itemIndexOffset = oldBookOffset;
			skillLineInfo.numSpellBookItems = oldBookNumSpells;
			return skillLineInfo;
		end
	end
	if (C_SpellBook.GetSpellBookItemInfo == nil) then
		C_SpellBook.GetSpellBookItemInfo = function(index, spellBookType)
			local bookItemInfo = {};
			local oldSpellType, oldSpellId = GetSpellBookItemInfo(index, spellBookType);
			bookItemInfo.itemType = oldSpellType;
			bookItemInfo.actionID = oldSpellId;
			return bookItemInfo;
		end
	end
	if (C_SpellBook.HasPetSpells == nil) then
		C_SpellBook.HasPetSpells = function()
			return HasPetSpells();
		end
	end
	if (C_SpellBook.GetSpellBookItemAutoCast == nil) then
		C_SpellBook.GetSpellBookItemAutoCast = function(index, spellBookType)
			return GetSpellAutocast(index, spellBookType);
		end
	end
	if (C_SpellBook.GetSpellBookItemName == nil) then
		C_SpellBook.GetSpellBookItemName = function(index, spellBookType)
			return GetSpellBookItemName(index, spellBookType);
		end
	end
	if (C_SpellBook.GetSpellBookItemCooldown == nil) then
		C_SpellBook.GetSpellBookItemCooldown = function(index, spellBookType)
			local itemCd = {};
			local oldStartTime, oldDuration, oldEnable = GetSpellCooldown(index, spellBookType);
			itemCd.startTime = oldSpellType;
			itemCd.duration = oldSpellId;
			itemCd.enable = oldEnable;
			return itemCd;
		end
	end
	
	if (C_Auras == nil) then
		C_Auras = {};
	end
	if (C_Auras.GetBuffDataByIndex == nil) then
		C_Auras.GetBuffDataByIndex = function(unit, index, filter)
			local auraData = {};
			local name, icon, count, debuffType, duration, expirationTime, unitCaster, canPurge, consolidate, spellId, canBeCastByPlayer, isCastByBoss, isCastByPlayer, nameplateShowAll, timeMod = UnitBuff(unit, index, filter);
			if (timeMod == nil) then timeMod = 1; end;
			auraData.name = name;
			auraData.icon = icon;
			auraData.applications = count;
			auraData.dispelName = debuffType;
			auraData.duration = duration;
			auraData.expirationTime = expirationTime;
			auraData.sourceUnit = unitCaster;
			auraData.isStealable = canPurge;
			auraData.nameplateShowPersonal = consolidate;
			auraData.spellId = spellId;
			auraData.canApplyAura = canBeCastByPlayer;
			auraData.isBossAura = isCastByBoss;
			auraData.isFromPlayerOrPlayerPet = isCastByPlayer;
			auraData.nameplateShowAll = nameplateShowAll;
			auraData.timeMod = timeMod;
			return auraData;
		end
	end
	if (C_Auras.GetDebuffDataByIndex == nil) then
		C_Auras.GetDebuffDataByIndex = function(unit, index, filter)
			local auraData = {};
			local name, icon, count, debuffType, duration, expirationTime, unitCaster, canPurge, consolidate, spellId, canBeCastByPlayer, isCastByBoss, isCastByPlayer, nameplateShowAll, timeMod = UnitDebuff(unit, index, filter);
			if (timeMod == nil) then timeMod = 1; end;
			auraData.name = name;
			auraData.icon = icon;
			auraData.applications = count;
			auraData.dispelName = debuffType;
			auraData.duration = duration;
			auraData.expirationTime = expirationTime;
			auraData.sourceUnit = unitCaster;
			auraData.isStealable = canPurge;
			auraData.nameplateShowPersonal = consolidate;
			auraData.spellId = spellId;
			auraData.canApplyAura = canBeCastByPlayer;
			auraData.isBossAura = isCastByBoss;
			auraData.isFromPlayerOrPlayerPet = isCastByPlayer;
			auraData.nameplateShowAll = nameplateShowAll;
			auraData.timeMod = timeMod;
			return auraData;
		end
	end
	
	if (C_AddOns == nil) then
		C_AddOns = {};
	end
	if (C_AddOns.GetAddOnMetadata == nil) then
		C_AddOns.GetAddOnMetadata = function(name, field)
			return GetAddOnMetadata(name, field);
		end
	end
	if (C_AddOns.LoadAddOn == nil) then
		C_AddOns.LoadAddOn = function(name)
			return LoadAddOn(name);
		end
	end
	
	if (C_PvP == nil) then
		C_PvP = {};
	end
	if (C_PvP.GetScoreInfoByPlayerGuid == nil) then
		C_PvP.GetScoreInfoByPlayerGuid = function(guid)
			return nil;
		end
	end
end

-- override WOTLK and TBC API
if (MCVanilla < 4) then -- less than Cata
	if (UnitGetIncomingHeals == nil) then
		UnitGetIncomingHeals = function(unit) -- no incoming heals, I don't think it's possible to check it
			return 0;
		end
	end
end

-- override some Vanilla API
if (MCVanilla < 3) then -- less than WoTLK
	--UnitHasVehicleUI = function(unit) return false; end -- no vehicles, but function is now included as part of Vanilla
	if (UnitCastingInfo == nil) then
		UnitCastingInfo = function(unit)
			if (unit == "player") then
				return CastingInfo();
			end
			return nil; -- not casting
		end
	end
	if (UnitChannelInfo == nil) then
		UnitChannelInfo = function(unit)
			if (unit == "player") then
				return ChannelInfo();
			end
			return nil; -- not casting
		end
	end
end
-------------------------------------------------------------------------------------
-- rewrite event frame function, since WoW API throws exceptions on missing events --
-------------------------------------------------------------------------------------
MCBlizzardEventExcludes = { };
if (MCVanilla < 5) then -- less than Pandaria
	MCBlizzardEventExcludes["PET_SPECIALIZATION_CHANGED"] = 1;
	MCBlizzardEventExcludes["UNIT_ABSORB_AMOUNT_CHANGED"] = 1;
	MCBlizzardEventExcludes["UNIT_HEAL_ABSORB_AMOUNT_CHANGED"] = 1;
	MCBlizzardEventExcludes["UNIT_SPELLCAST_EMPOWER_START"] = 1;
	MCBlizzardEventExcludes["UNIT_SPELLCAST_EMPOWER_UPDATE"] = 1;
	MCBlizzardEventExcludes["UNIT_SPELLCAST_EMPOWER_STOP"] = 1;
	MCBlizzardEventExcludes["ARENA_PREP_OPPONENT_SPECIALIZATIONS"] = 1;
	MCBlizzardEventExcludes["UNIT_MAX_HEALTH_MODIFIERS_CHANGED"] = 1;
end
if (MCVanilla < 4) then -- less than Cataclysm
	MCBlizzardEventExcludes["PLAYER_SPECIALIZATION_CHANGED"] = 1;
	MCBlizzardEventExcludes["PET_BATTLE_OPENING_START"] = 1;
	MCBlizzardEventExcludes["PET_BATTLE_CLOSE"] = 1;
	MCBlizzardEventExcludes["SPELL_ACTIVATION_OVERLAY_SHOW"] = 1;
	MCBlizzardEventExcludes["UNIT_HEAL_PREDICTION"] = 1;
	MCBlizzardEventExcludes["UNIT_SPELLCAST_INTERRUPTIBLE"] = 1;
	MCBlizzardEventExcludes["UNIT_SPELLCAST_NOT_INTERRUPTIBLE"] = 1;
	MCBlizzardEventExcludes["UNIT_POWER_POINT_CHARGE"] = 1;
	MCBlizzardEventExcludes["PLAYER_SOFT_ENEMY_CHANGED"] = 1;
	MCBlizzardEventExcludes["PLAYER_SOFT_FRIEND_CHANGED"] = 1;
end
if (MCVanilla < 3) then -- less than WoTLK
	MCBlizzardEventExcludes["PLAYER_TALENT_UPDATE"] = 1;
	MCBlizzardEventExcludes["UNIT_ENTERED_VEHICLE"] = 1;
	MCBlizzardEventExcludes["UNIT_EXITED_VEHICLE"] = 1;
	MCBlizzardEventExcludes["VEHICLE_PASSENGERS_CHANGED"] = 1;
	MCBlizzardEventExcludes["UPDATE_VEHICLE_ACTIONBAR"] = 1;
end

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

-------------------------------------------------------------------------------------
-- Blizzard API emulation --
-------------------------------------------------------------------------------------

--- Class to track info to make some Blizzard API return "release" class info
MCVanillaAPIEmulation = MCCreateClass({
	-- guid of the player
	playerGUID = nil,
	-- guid of the target
	targetGUID = nil,
	-- difference between combat log timestamp and GetTime func result
	timeDiffCombatTimeGetTime = 0,
	-- events frame for generic events, e.g. track guid, etc...
	generalEventsFrame = nil,
	-- defines if unit aura interface should be emulated by Vanilla-Release integrator
	emulateUnitAura = false,
	-- defines maximum number of targets to track for unit aura duration
	UNIT_AURA_TRACK_TIME_MAX_TARGETS = 5,
	-- table with last cast time info (key - spell name, value - time at which last cast time cast was made, and GUID to whom it was applied)
	unitAuraCastTimeInfo = { },
	-- table with duration info (key - spell name, value - maximum duration of the spell)
	unitAuraDurationInfo = { },
	-- combat log frame that receives info to make emulation happen
	unitAuraCombatLogFrame = nil,
})

--- Initialize API emulation
function MCVanillaAPIEmulation:staticInit()
	-- general info
	MCVanillaAPIEmulation.playerGUID = UnitGUID("player");
	MCVanillaAPIEmulation.generalEventsFrame = MCCreateBlizzEventFrame();
	MCVanillaAPIEmulation.timeDiffCombatTimeGetTime = time() - GetTime(); -- result is not that good, difference is quite big (~3 sec)
	--print("Initial Spell diff time is " .. MCTableToString(MCVanillaAPIEmulation.timeDiffCombatTimeGetTime));
	function MCVanillaAPIEmulation.generalEventsFrame:COMBAT_LOG_EVENT_UNFILTERED()
		local timestamp, event, hideCaster, sourceGUID, sourceName, sourceFlags, sourceFlags2, destGUID, destName, destFlags, destFlags2, ex1, ex2, ex3, ex4, ex5 = CombatLogGetCurrentEventInfo();
		--print("Combat log event " .. MCTableToString(event) .. ", timestamp " .. MCTableToString(timestamp));
		MCVanillaAPIEmulation.timeDiffCombatTimeGetTime = timestamp - GetTime(); -- need to do only once
		--print("Spell diff time is " .. MCTableToString(MCVanillaAPIEmulation.timeDiffCombatTimeGetTime));
		-- no point in listening to combat log any further
		MCVanillaAPIEmulation.generalEventsFrame:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
	end
	-- target guid change tracking
	function MCVanillaAPIEmulation.generalEventsFrame:PLAYER_TARGET_CHANGED()
		local isTargetAvailable = UnitExists("target");
		MCVanillaAPIEmulation.targetGUID = isTargetAvailable and UnitGUID("target") or "";
	end
	-- unit aura emulate init
	MCVanillaAPIEmulation.unitAuraCombatLogFrame = MCCreateBlizzCombatEventFrame();
	function MCVanillaAPIEmulation.unitAuraCombatLogFrame:SPELL_AURA_APPLIED(timestamp, hideCaster, sourceGUID, sourceName, sourceFlags, sourceFlags2, destGUID, destName, destFlags, destFlags2, spellId, spellName, spellSchool, extraSpellID, extraSpellName, extraSchool)
		if (sourceGUID ~= MCVanillaAPIEmulation.playerGUID) then
			return;
		end
		--print("Spell applied " .. MCTableToString(spellName) .. ", timestamp " .. MCTableToString(timestamp));
		--MCVanillaAPIEmulation.timeDiffCombatTimeGetTime = timestamp - GetTime(); -- need to do only once
		--print("Spell diff time is " .. MCTableToString(MCVanillaAPIEmulation.timeDiffCombatTimeGetTime));
		MCVanillaAPIEmulation:saveUnitAuraApplyTime(spellName, destGUID, timestamp);
	end
	function MCVanillaAPIEmulation.unitAuraCombatLogFrame:SPELL_AURA_REFRESH(timestamp, hideCaster, sourceGUID, sourceName, sourceFlags, sourceFlags2, destGUID, destName, destFlags, destFlags2, spellId, spellName, spellSchool, extraSpellID, extraSpellName, extraSchool)
		if (sourceGUID ~= MCVanillaAPIEmulation.playerGUID) then
			return;
		end
		--print("Spell refresh " .. MCTableToString(spellName) .. ", timestamp " .. MCTableToString(timestamp));
		MCVanillaAPIEmulation:calculateUnitAuraDurationMaxOnAuraRemove(spellName, destGUID, timestamp);
		MCVanillaAPIEmulation:saveUnitAuraApplyTime(spellName, destGUID, timestamp);
	end
	function MCVanillaAPIEmulation.unitAuraCombatLogFrame:SPELL_AURA_REMOVED(timestamp, hideCaster, sourceGUID, sourceName, sourceFlags, sourceFlags2, destGUID, destName, destFlags, destFlags2, spellId, spellName, spellSchool, extraSpellID, extraSpellName, extraSchool)
		if (sourceGUID ~= MCVanillaAPIEmulation.playerGUID) then
			return;
		end
		--print("Spell removed " .. MCTableToString(spellName) .. ", timestamp " .. MCTableToString(timestamp));
		MCVanillaAPIEmulation:calculateUnitAuraDurationMaxOnAuraRemove(spellName, destGUID, timestamp);
	end
end
-- initialize emulation from start
MCVanillaAPIEmulation:staticInit();

--- Function that switches general info emulation (such as target guid)
-- @param track defines if tracking should be made
function MCVanillaAPIEmulation:switchGeneralInfoTracking(track)
	if (track == true) then
		self.generalEventsFrame:RegisterEvent("PLAYER_TARGET_CHANGED");
		self.generalEventsFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
	else
		self.generalEventsFrame:UnregisterEvent("PLAYER_TARGET_CHANGED");
		self.generalEventsFrame:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
	end
end

--- Save time at which aura was applied by player, and to which target it was applied
-- @param spellName name of the spell (for purpose of this tracking spell name are used, as spellId is always 0 in classic)
-- @param targetGUID target to which aura is applied (info is tracked up to UNIT_AURA_TRACK_TIME_MAX_TARGETS number of targets)
-- @param timestamp timestamp to be saved as aura apply time
function MCVanillaAPIEmulation:saveUnitAuraApplyTime(spellName, targetGUID, timestamp)
	local castTimeInfo = self.unitAuraCastTimeInfo[spellName];
	if (castTimeInfo == nil) then
		castTimeInfo = { };
		for i = 1, self.UNIT_AURA_TRACK_TIME_MAX_TARGETS do
			table.insert(castTimeInfo, ""); -- guid
			table.insert(castTimeInfo, 0); -- timestamp
		end
		self.unitAuraCastTimeInfo[spellName] = castTimeInfo;
		self.unitAuraDurationInfo[spellName] = 1.0;
	end
	-- check if guid already present or find oldest
	local oldestIndex = 1;
	local oldestTime = castTimeInfo[2];
	for i = 1, self.UNIT_AURA_TRACK_TIME_MAX_TARGETS do
		local exGuid = castTimeInfo[i * 2 - 1]; -- guid
		if (exGuid == targetGUID) then
			castTimeInfo[i * 2] = timestamp;
			return;
		end
		local exTime = castTimeInfo[i * 2]; -- timestamp
		if (exTime < oldestTime) then
			oldestIndex = i;
			oldestTime = exTime;
		end
	end
	-- replace guid and timestamp
	castTimeInfo[oldestIndex * 2 - 1] = targetGUID;
	castTimeInfo[oldestIndex * 2] = timestamp;
end

--- Get time at which aura was applied by player
-- @param spellName name of the spell (for purpose of this tracking spell name are used, as spellId is always 0 in classic)
-- @param targetGUID target to which aura was applied (info is tracked up to UNIT_AURA_TRACK_TIME_MAX_TARGETS number of targets)
-- @return timestamp at which aura was applied or 0 if none
function MCVanillaAPIEmulation:getUnitAuraApplyTime(spellName, targetGUID)
	local castTimeInfo = self.unitAuraCastTimeInfo[spellName];
	if (castTimeInfo ~= nil) then
		for i = 1, self.UNIT_AURA_TRACK_TIME_MAX_TARGETS do
			local exGuid = castTimeInfo[i * 2 - 1]; -- guid
			if (exGuid == targetGUID) then
				return castTimeInfo[i * 2]; -- timestamp
			end
		end
	end
	return 0;
end

--- Update unit aura duration on remove event
-- @param spellName name of the spell (for purpose of this tracking spell name are used, as spellId is always 0 in classic)
-- @param targetGUID target to which aura was applied (info is tracked up to UNIT_AURA_TRACK_TIME_MAX_TARGETS number of targets)
-- @param timestamp timestamp at which aura was removed
function MCVanillaAPIEmulation:calculateUnitAuraDurationMaxOnAuraRemove(spellName, targetGUID, timestamp)
	local applyTime = self:getUnitAuraApplyTime(spellName, targetGUID);
	if (applyTime == 0) then
		return;
	end
	local duration = timestamp - applyTime;
	--print("Spell duration " .. MCTableToString(spellName) .. " is " .. MCTableToString(duration));
	local exDuration = self.unitAuraDurationInfo[spellName];
	if (exDuration == nil or duration > exDuration) then
		self.unitAuraDurationInfo[spellName] = duration;
	end
end

--- Get unit aura duration based on combat log info
-- @param spellName name of the spell (for purpose of this tracking spell name are used, as spellId is always 0 in classic)
-- @return duration of the aura (based on player info)
function MCVanillaAPIEmulation:getUnitAuraDurationTime(spellName)
	local castDurationInfo = self.unitAuraDurationInfo[spellName];
	if (castDurationInfo ~= nil) then
		return castDurationInfo;
	end
	return 0;
end

-- save reference to original blizzard UnitDebuff/UnitBuff functions
local BlizzUnitDebuff = UnitDebuff;
local BlizzUnitBuff = UnitBuff;

--- Unit debuff emulation with duration and time left
-- @param unit unit to query (only "target" is emulated)
-- @param index index of aura to be returned
-- @return same info as UnitDebuff blizzard function
function MCEmulateUnitDebuff(unit, index)
	if (unit ~= "target") then
		return BlizzUnitDebuff(unit, index);
	end
	local result = { BlizzUnitDebuff(unit, index) };
	local unitCaster = result[7];
	if (unitCaster == "player") then
		local spellName = result[1];
		--local spellId = result[10];
		local calculatedDuration = MCVanillaAPIEmulation:getUnitAuraDurationTime(spellName);
		if (calculatedDuration ~= 0) then
			result[5] = calculatedDuration;
			--print("Updating spell duration on aura " .. MCTableToString(spellName) .. ", duration " .. MCTableToString(calculatedDuration));
			local applyTime = MCVanillaAPIEmulation:getUnitAuraApplyTime(spellName, MCVanillaAPIEmulation.targetGUID);
			if (applyTime ~= 0) then
				result[6] = applyTime + calculatedDuration - MCVanillaAPIEmulation.timeDiffCombatTimeGetTime;
				--print("Updating spell expiration on aura " .. MCTableToString(spellName) .. ", expiration " .. MCTableToString(applyTime + calculatedDuration) .. ", current time " .. MCTableToString(GetTime()));
			end
		end
	end
	return unpack(result);
end
--- Unit buff emulation with duration and time left
-- @param unit unit to query (only "target" is emulated)
-- @param index index of aura to be returned
-- @return same info as UnitBuff blizzard function
function MCEmulateUnitBuff(unit, index)
	if (unit ~= "target") then
		return BlizzUnitBuff(unit, index);
	end
	local result = { BlizzUnitBuff(unit, index) };
	local unitCaster = result[7];
	if (unitCaster == "player") then
		local spellName = result[1];
		--local spellId = result[10];
		local calculatedDuration = MCVanillaAPIEmulation:getUnitAuraDurationTime(spellName);
		if (calculatedDuration ~= 0) then
			result[5] = calculatedDuration;
			--print("Updating spell duration on aura " .. MCTableToString(spellName) .. ", duration " .. MCTableToString(calculatedDuration));
			local applyTime = MCVanillaAPIEmulation:getUnitAuraApplyTime(spellName, MCVanillaAPIEmulation.targetGUID);
			if (applyTime ~= 0) then
				result[6] = applyTime + calculatedDuration - MCVanillaAPIEmulation.timeDiffCombatTimeGetTime;
				--print("Updating spell expiration on aura " .. MCTableToString(spellName) .. ", expiration " .. MCTableToString(applyTime + calculatedDuration) .. ", current time " .. MCTableToString(GetTime()));
			end
		end
	end
	return unpack(result);
end

--- Switch Aura target emulation ON/OFF
-- @param emulate defines if emulation of aura API is required
function MCVanillaAPIEmulation:switchUnitAuraEmulation(emulate)
	if (self.emulateUnitAura == emulate) then
		return;
	end
	self.emulateUnitAura = emulate;
	if (emulate == true) then
		self:switchGeneralInfoTracking(true);
		self.unitAuraCombatLogFrame:RegisterEvent("SPELL_AURA_APPLIED");
		self.unitAuraCombatLogFrame:RegisterEvent("SPELL_AURA_REFRESH");
		self.unitAuraCombatLogFrame:RegisterEvent("SPELL_AURA_REMOVED");
		UnitDebuff = MCEmulateUnitDebuff;
	else
		self:switchGeneralInfoTracking(false);
		self.unitAuraCombatLogFrame:UnregisterEvent("SPELL_AURA_APPLIED");
		self.unitAuraCombatLogFrame:UnregisterEvent("SPELL_AURA_REFRESH");
		self.unitAuraCombatLogFrame:UnregisterEvent("SPELL_AURA_REMOVED");
		UnitDebuff = BlizzUnitDebuff;
	end
end
-- testing code
if (MCVanilla < 3) then -- less than WoTLK
	MCVanillaAPIEmulation:switchUnitAuraEmulation(true);
end
