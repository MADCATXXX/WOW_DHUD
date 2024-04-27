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

--------------------
-- Trackers table --
--------------------

--- Table with data trackers
DHUDDataTrackers = {
	-- trackers that are used by any class
	ALL = {},
	fillAll = function(self, charclass)
		-- fill table with trackers
		local ALL = self.ALL;
		-------------------------
		-- Player Combo Points --
		-------------------------
		ALL.selfComboPoints = DHUDComboPointTracker:new();
		-- combopoints available only for druid and rogue
		if (trackingHelper.playerClass == "ROGUE" or trackingHelper.playerClass == "DRUID") then
			ALL.selfComboPoints:initPlayerNotInVehicleOrNoneUnitId();
		end
		ALL.selfComboPoints.updateFrequently = false;

		--------------------------
		-- Vehicle Combo Points --
		--------------------------
		ALL.vehicleComboPoints = DHUDSpecificPowerTracker:new();
		ALL.vehicleComboPoints:setResourceType(4, "COMBO_POINTS");
		ALL.vehicleComboPoints:initVehicleOrNoneUnitId();
		ALL.vehicleComboPoints.updateFrequently = false;

		---------------------------
		-- Player/Vehicle Health --
		---------------------------
		ALL.selfHealth = DHUDHealthTracker:new();
		ALL.selfHealth:initPlayerOrVehicleUnitId();
		
		------------------------------
		-- Player Health in Vehicle --
		------------------------------
		ALL.selfCharInVehicleHealth = DHUDHealthTracker:new();
		ALL.selfCharInVehicleHealth:initPlayerInVehicleOrNoneUnitId();

		-------------------
		-- Target Health --
		-------------------
		ALL.targetHealth = DHUDHealthTracker:new();
		ALL.targetHealth:initTargetUnitId();

		----------------
		-- Pet Health --
		----------------
		ALL.petHealth = DHUDHealthTracker:new();
		ALL.petHealth:initPetOrNoneUnitId();
		
		-----------------------
		-- Player Main Power --
		-----------------------
		ALL.selfPower = DHUDMainPowerTracker:new();
		ALL.selfPower:initPlayerOrVehicleUnitId();
		
		-----------------------
		-- Target Main Power --
		-----------------------
		ALL.targetPower = DHUDMainPowerTracker:new();
		ALL.targetPower:initTargetUnitId();

		-----------------------
		-- Target Main Power --
		-----------------------
		ALL.selfCharInVehiclePower = DHUDMainPowerTracker:new();
		ALL.selfCharInVehiclePower:initPlayerInVehicleOrNoneUnitId();
		
		--------------------
		-- Pet Main Power --
		--------------------
		ALL.petPower = DHUDMainPowerTracker:new();
		ALL.petPower:initPetOrNoneUnitId();

		----------------------
		-- Target cast info --
		----------------------
		ALL.targetCast = DHUDSpellCastTracker:new();
		ALL.targetCast:initTargetUnitId();
		
		-----------------
		-- Player Info --
		-----------------
		ALL.selfInfo = DHUDSelfInfoTracker:new();
		
		-----------------
		-- Target Info --
		-----------------
		ALL.targetInfo = DHUDUnitInfoTracker:new();
		ALL.targetInfo:initTargetUnitId();
		ALL.targetHealth:attachCreditTracker(ALL.targetInfo);
		
		---------------------------
		-- Target of Target Info --
		---------------------------
		ALL.targetOfTargetInfo = DHUDUnitInfoTracker:new();
		ALL.targetOfTargetInfo:initTargetOfTargetUnitId();

		---------------
		-- Vengeance --
		---------------
		--[[ALL.vengeanceInfo = DHUDAuraValueTracker:new();
		ALL.vengeanceInfo:initPlayerNotInVehicleOrNoneUnitId();
		ALL.vengeanceInfo:initPlayerSpecsOnly(trackingHelper:getTankSpecializations());
		ALL.vengeanceInfo:setAurasToTrack(158300); -- old vengeance 132365
		ALL.vengeanceInfo:setAmountMax(200); -- max value is in percent
		ALL.vengeanceInfo:setCustomResourceType(DHUDColorizeTools.COLOR_ID_TYPE_CUSTOM_VENGEANCE);]]--

		------------
		-- Threat --
		------------
		
		--------------------------
		-- Player/Vehicle Auras --
		--------------------------
		ALL.selfAuras = DHUDAurasTracker:new();
		ALL.selfAuras:initPlayerOrVehicleUnitId();

		------------------
		-- Target Auras --
		------------------
		ALL.targetAuras = DHUDAurasTracker:new();
		ALL.targetAuras:initTargetUnitId();

		-----------------------------
		-- Cooldowns, Trinket ICDs --
		-----------------------------
		ALL.selfCooldowns = DHUDCooldownsTracker:new();
		ALL.selfCooldowns:initPlayerOrVehicleUnitId();

		----------------------
		-- Player cast info --
		----------------------
		ALL.selfCast = DHUDSpellCastTracker:new();
		ALL.selfCast:initPlayerOrVehicleUnitId();
		ALL.selfCast:attachCooldownsTracker(ALL.selfCooldowns);

		---------------
		-- Range (?) --
		---------------
	end,
	-- trackers that are used by death knight
	DEATHKNIGHT = { },
	fillDEATHKNIGHT = function(self, charclass)
		-- fill table with trackers
		local DEATHKNIGHT = self.DEATHKNIGHT;
		
		-----------
		-- Runes --
		-----------
		DEATHKNIGHT.selfRunes = DHUDRunesTracker:new();
	end,
	-- trackers that are used by druid
	DRUID = { },
	fillDRUID = function(self, charclass)
		-- fill table with trackers
		local DRUID = self.DRUID;
		--------------------------------
		-- Mana in bear and cat forms --
		--------------------------------
		DRUID.selfMana = DHUDSpecificPowerTracker:new();
		DRUID.selfMana:setResourceType(0, "MANA");
		DRUID.selfMana:initPlayerNotInVehicleOrNoneUnitId();
		DRUID.selfMana:initTrackIfNotMain();
		
		------------------------------------
		-- Energy in bear and usual forms --
		------------------------------------
		DRUID.selfEnergy = DHUDSpecificPowerTracker:new();
		DRUID.selfEnergy:setResourceType(3, "ENERGY");
		DRUID.selfEnergy:initPlayerNotInVehicleOrNoneUnitId();
		DRUID.selfEnergy:initTrackIfNotMain();

		------------------------------
		-- Eclipse for moonkin form --
		------------------------------
		DRUID.selfEclipse = DHUDSpecificPowerTracker:new();
		DRUID.selfEclipse.canRegenerate = false;
		DRUID.selfEclipse:setResourceType(8, "ECLIPSE");
		DRUID.selfEclipse:initPlayerNotInVehicleOrNoneUnitId();
		DRUID.selfEclipse:initPlayerSpecsOnly(1);
		DRUID.selfEclipse.updateFrequently = false;

		-----------------------
		-- Destealth tracker --
		-----------------------
		DRUID.selfDeStealthTracker = DHUDSelfDeStealthTracker:new();
	end,
	-- trackers that are used by monk
	MONK = { },
	fillMONK = function(self, charclass)
		-- fill table with trackers
		local MONK = self.MONK;
		-------------------------------------
		-- Mana when not in serpent stance --
		-------------------------------------
		--[[MONK.selfMana = DHUDSpecificPowerTracker:new();
		MONK.selfMana:setResourceType(0, "MANA");
		MONK.selfMana:initPlayerSpecsOnly(2);
		MONK.selfMana:initPlayerNotInVehicleOrNoneUnitId();
		MONK.selfMana:initTrackIfNotMain();]]--
		
		-----------------------------------
		-- Energy when in serpent stance --
		-----------------------------------
		--[[MONK.selfEnergy = DHUDSpecificPowerTracker:new();
		MONK.selfEnergy:setResourceType(3, "ENERGY");
		MONK.selfEnergy:initPlayerNotInVehicleOrNoneUnitId();
		MONK.selfEnergy:initTrackIfNotMain();]]--

		---------
		-- Chi --
		---------
		MONK.selfChi = DHUDSpecificPowerTracker:new();
		MONK.selfChi:setResourceType(12, "CHI");
		MONK.selfChi:initPlayerSpecsOnly(3); -- dps spec only in legion
		MONK.selfChi:initPlayerNotInVehicleOrNoneUnitId();
		MONK.selfChi.updateFrequently = false;
		
		MONK.selfStagger = DHUDStaggerTracker:new();
	end,
	-- trackers that are used by warlock
	WARLOCK = { },
	fillWARLOCK = function(self, charclass)
		-- fill table with trackers
		local WARLOCK = self.WARLOCK;
		------------------
		-- Sould shards --
		------------------
		WARLOCK.selfSoulShards = DHUDSpecificPowerTracker:new();
		WARLOCK.selfSoulShards:setResourceType(7, "SOUL_SHARDS");
		WARLOCK.selfSoulShards:setAmountBasePercent(0.6);
		WARLOCK.selfSoulShards:initPlayerNotInVehicleOrNoneUnitId();
		WARLOCK.selfSoulShards.precision = 0;
	end,
	-- trackers that are used by paladin
	PALADIN = { },
	fillPALADIN = function(self, charclass)
		-- fill table with trackers
		local PALADIN = self.PALADIN;
		----------------
		-- Holy Power --
		----------------
		PALADIN.selfHolyPower = DHUDSpecificPowerTracker:new();
		PALADIN.selfHolyPower:setResourceType(9, "HOLY_POWER");
		PALADIN.selfHolyPower:initPlayerNotInVehicleOrNoneUnitId();
		PALADIN.selfHolyPower.updateFrequently = false;
	end,
	-- trackers that are used by priest
	PRIEST = { },
	fillPRIEST = function(self, charclass)
		-- fill table with trackers
		local PRIEST = self.PRIEST;
		-----------------
		-- Shadow orbs --
		-----------------
		--[[PRIEST.selfShadowOrbs = DHUDSpecificPowerTracker:new();
		PRIEST.selfShadowOrbs:setResourceType(13, "SHADOW_ORBS");
		PRIEST.selfShadowOrbs:initPlayerSpecsOnly(3);
		PRIEST.selfShadowOrbs:initPlayerNotInVehicleOrNoneUnitId();
		PRIEST.selfShadowOrbs.canRegenerate = false;
		PRIEST.selfShadowOrbs.updateFrequently = false;]]--
		------------------------------
		-- Mana when in shadow spec --
		------------------------------
		PRIEST.selfMana = DHUDSpecificPowerTracker:new();
		PRIEST.selfMana:setResourceType(0, "MANA");
		PRIEST.selfMana:initPlayerNotInVehicleOrNoneUnitId();
		PRIEST.selfMana:initTrackIfNotMain();
	end,
	-- trackers that are used by priest
	MAGE = { },
	fillMAGE = function(self, charclass)
		-- fill table with trackers
		local MAGE = self.MAGE;
		--------------------
		-- Arcane Charges --
		--------------------
		MAGE.selfArcaneCharges = DHUDSpecificPowerTracker:new();
		MAGE.selfArcaneCharges:setResourceType(16, "ARCANE_CHARGES");
		MAGE.selfArcaneCharges:initPlayerSpecsOnly(1);
		MAGE.selfArcaneCharges:initPlayerNotInVehicleOrNoneUnitId();
		MAGE.selfArcaneCharges.updateFrequently = false;
	end,
	-- trackers that are used by shaman
	SHAMAN = { },
	fillSHAMAN = function(self, charclass)
		-- fill table with trackers
		local SHAMAN = self.SHAMAN;
		---------------------------------------
		-- Mana for enhancment and elemental --
		---------------------------------------
		SHAMAN.selfMana = DHUDSpecificPowerTracker:new();
		SHAMAN.selfMana:setResourceType(0, "MANA");
		SHAMAN.selfMana:initPlayerNotInVehicleOrNoneUnitId();
		SHAMAN.selfMana:initTrackIfNotMain();

		------------
		-- Totems --
		------------
		SHAMAN.selfTotems = DHUDGuardiansTracker:new();
		SHAMAN.selfTotems:initPlayerNotInVehicleOrNoneUnitId();
	end,
	-- trackers that are used by rogue
	ROGUE = { },
	fillROGUE = function(self, charclass)
		-- fill table with trackers
		local ROGUE = self.ROGUE;

		--[[ROGUE.selfBanditsGuile = DHUDBanditsGuileTracker:new();]]--
		-----------------------
		-- Destealth tracker --
		-----------------------
		ROGUE.selfDeStealthTracker = DHUDSelfDeStealthTracker:new();
		----------------------------------
		-- Assasination garrote tracker --
		----------------------------------
		if (DHUDRogueAssasinationGarroteTracker ~= nil) then
			ROGUE.selfAssasinationGarrote = DHUDRogueAssasinationGarroteTracker:new();
		end
	end,
	-- trackers that are used by evoker
	EVOKER = { },
	fillEVOKER = function(self, charclass)
		-- fill table with trackers
		local EVOKER = self.EVOKER;

		-------------
		-- Essence --
		-------------
		EVOKER.selfEssence = DHUDSpecificPowerTracker:new();
		EVOKER.selfEssence:setResourceType(19, "ESSENCE");
		EVOKER.selfEssence:setAmountBasePercent(1);
		EVOKER.selfEssence:initPlayerNotInVehicleOrNoneUnitId();
		EVOKER.selfEssence.updateFrequently = false;
	end,
	-- reference to data helper
	helper = nil,
	-- create all trackers
	createTrackers = function(self)
		-- init tracking helper
		trackingHelper:init();
		self.helper = trackingHelper;
		local charclass = trackingHelper.playerClass;
		-- init trackers for any class
		self:fillAll(charclass);
		-- init trackers for specific class
		local fillClassSpecific = self["fill" .. charclass];
		if (fillClassSpecific ~= nil) then
			fillClassSpecific(self, charclass);
		end
		--print("DataTrackers inited for class: " .. charclass);
	end,
	-- initialize all trackers
	init = function(self)
		local charclass = trackingHelper.playerClass;
		-- init static class variables
		DHUDCustomTimerTracker:STATIC_init();
		-- init trackers
		for i, v in pairs(self.ALL) do
			v:init();
		end
		local classSpecific = self[charclass];
		if (classSpecific ~= nil) then
			for i, v in pairs(classSpecific) do
				v:init();
			end
		end
	end,
}
