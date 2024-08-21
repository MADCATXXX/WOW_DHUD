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
local pvpHelper = DHUDPvPTrackingHelper;

-----------------------
-- Unit info tracker --
-----------------------
--- Base class to track unit spell castings, spells channeling and delays
DHUDUnitInfoTracker = MCCreateSubClass(DHUDDataTracker, {
	-- unit name
	name				= "",
	-- name of the guild
	guild				= "",
	-- defines unit type, from UNIT_TYPE_* enum
	unitType			= 0,
	-- defines friend unit type string, e.g. "Pet" / "NPC"
	friendUnitTypeString = "",
	-- defines unit relation, e.g. friendly, neutral, or hostile
	relation			= 0,
	-- defines if unit can be attacked
	canAttack			= false,
	-- unit level
	level				= 0,
	-- unit class name
	class				= "",
	-- unit english class name
	classEng			= "",
	-- race of the unit, e.g. night elf
	race				= "",
	-- unit specialization id
	specID				= 0,
	-- name of the specialization
	specName 			= "",
	-- texture of the specialization, empty for now
	specTexture			= "",
	-- unit specialization role (e.g. "TANK"), empty for now
	specRole			= "",
	-- defines unit elite type, e.g. golden dragon or silver dragon
	eliteType			= 0,
	-- type of the npc, e.g. critter
	npcType				= "",
	-- defines if player will receive credit for killing unit
	tagged				= true,
	-- defines if anyone can tag unit and receive credit for killing unit
	communityTagged		= true,
	-- defines number of raid icon on unit, 0 = no icon
	raidIcon			= 0,
	-- defines unit pvp faction, e.g. alliance or horde
	pvpFaction			= 0,
	-- defines if unit pvp faction differs from player
	isDifferentPvPFaction = false,
	-- defines inspect is ready for unitGUID, e.g. for GetInspectSpecialization function we need to call NotifyInspect and wait INSPECT_READY
	inspectReadyGUID	= "",
	-- defines unit pvp state
	pvpState			= 0,
	-- unit is player
	UNIT_TYPE_PLAYER	= 0,
	-- unit is pet
	UNIT_TYPE_PET		= 1,
	-- unit is an ally npc
	UNIT_TYPE_ALLY_NPC	= 2,
	-- unit is not any of the above
	UNIT_TYPE_CREATURE	= 3,
	-- unit faction is neutral
	UNIT_PVP_FACTION_NONE = 0,
	-- unit faction is alliance
	UNIT_PVP_FACTION_ALLIANCE = 1,
	-- unit faction is horde
	UNIT_PVP_FACTION_HORDE = 2,
	-- unit is not flagged for pvp
	UNIT_PVP_STATE_OFF = 0,
	-- unit is flagged for pvp
	UNIT_PVP_STATE_ON = 1,
	-- unit is flagged for pvp in arena
	UNIT_PVP_STATE_FFA = 2,
	-- unit is hostile to player
	UNIT_RELATION_HOSTILE = -1,
	-- unit is neutral to player
	UNIT_RELATION_NEUTRAL = 0,
	-- unit is friendly to player
	UNIT_RELATION_FRIENDLY = 1,
	-- unit is not elite
	UNIT_ELITE_TYPE_NONE	= 0,
	-- unit is minion and has low health amount
	UNIT_ELITE_TYPE_MINION	= 1,
	-- unit is rare, e.g. silver dragon in standard interface
	UNIT_ELITE_TYPE_RARE	= 2,
	-- unit is elite, e.g. golden dragon in standard interface
	UNIT_ELITE_TYPE_ELITE	= 3,
	-- unit is elite and rare, e.g. silver dragon in standard interface
	UNIT_ELITE_TYPE_RAREELITE	= 4,
	--  unit is boss and elite, e.g. golden dragon in standard interface
	UNIT_ELITE_TYPE_BOSS = 5,
	-- LIBRARY with specs info for friendly targets
	STATIC_LIB_INSPECT = { GetCachedInfo = function(guid) DHUDUnitInfoTracker:STATIC_INIT_INSPECT(); return DHUDUnitInfoTracker.STATIC_LIB_INSPECT.GetCachedInfo(guid); end },
})

--- Initialize inspect library if needed
function DHUDUnitInfoTracker:STATIC_INIT_INSPECT()
	DHUDUnitInfoTracker.STATIC_LIB_INSPECT = LibStub and LibStub:GetLibrary("LibGroupInSpecT-1.1", true);
	if (DHUDUnitInfoTracker.STATIC_LIB_INSPECT == nil) then
		DHUDUnitInfoTracker.STATIC_LIB_INSPECT = {};
		DHUDUnitInfoTracker.STATIC_LIB_INSPECT.GetCachedInfo = function(guid) return nil; end
	end
end

--- Create new unit info tracker, unitId should be specified after constructor
function DHUDUnitInfoTracker:new()
	local o = self:defconstructor();
	o:constructor();
	return o;
end

--- Initialize health-points tracking
function DHUDUnitInfoTracker:init()
	local tracker = self;
	-- process unit name change event
	function self.eventsFrame:UNIT_NAME_UPDATE(unitId)
		if (tracker.unitId ~= unitId) then
			return;
		end
		tracker:updateUnitName();
	end
	-- process unit faction change event
	function self.eventsFrame:UNIT_FACTION(unitId)
		if (tracker.unitId ~= unitId) then
			return;
		end
		tracker:updateRelation();
		tracker:updateTagging();
		tracker:updatePvPInfo();
	end
	-- process unit classification change event
	function self.eventsFrame:UNIT_CLASSIFICATION_CHANGED(unitId)
		if (tracker.unitId ~= unitId) then
			return;
		end
		tracker:updateEliteType();
	end
	-- process unit level change event
	function self.eventsFrame:UNIT_LEVEL(unitId)
		if (tracker.unitId ~= unitId) then
			return;
		end
		tracker:updateLevel();
	end
	-- process unit specialization (not only player) change event
	function self.eventsFrame:PLAYER_SPECIALIZATION_CHANGED(unitId)
		tracker:updateSpecialization();
	end
	-- process raid target icon change event
	function self.eventsFrame:RAID_TARGET_UPDATE(unitId)
		tracker:updateRaidIcon();
	end
end

--- Update name of the unit
function DHUDUnitInfoTracker:updateUnitName()
	self.name = UnitName(self.unitId);
	self:processDataChanged();
end

--- Update guild name of the unit
function DHUDUnitInfoTracker:updateGuildName()
	self.guild = GetGuildInfo(self.unitId);
	self:processDataChanged();
end

--- update information about unit type
function DHUDUnitInfoTracker:updateUnitType()
	self.unitType = self.UNIT_TYPE_CREATURE;
	self.friendUnitTypeString = "";
	if (UnitIsPlayer(self.unitId)) then
		self.unitType = self.UNIT_TYPE_PLAYER;
	elseif (not self.canAttack) then
		if (UnitPlayerControlled(self.unitId) == 1) then
			self.friendUnitTypeString = "Pet";
			self.unitType = self.UNIT_TYPE_PET;
		else
			self.friendUnitTypeString = "NPC";
			self.unitType = self.UNIT_TYPE_ALLY_NPC;
		end
	end
	self:processDataChanged();
end

--- update unit relation info
function DHUDUnitInfoTracker:updateRelation()
	local reaction = UnitReaction("player", self.unitId) or 4;
	if (reaction < 4) then
		self.relation = self.UNIT_RELATION_HOSTILE;
	elseif (reaction > 4) then
		self.relation = self.UNIT_RELATION_FRIENDLY;
	else
		self.relation = self.UNIT_RELATION_NEUTRAL;
	end
	self.canAttack = UnitCanAttack("player", self.unitId) == true;
	self:processDataChanged();
end

--- update unit level information
function DHUDUnitInfoTracker:updateLevel()
	self.level = UnitLevel(self.unitId);
	self:processDataChanged();
end

--- update unit class information
function DHUDUnitInfoTracker:updateClass()
	self.class, self.classEng = UnitClass(self.unitId);
	self:processDataChanged();
end

--- update unit race information
function DHUDUnitInfoTracker:updateRace()
	self.race = UnitRace(self.unitId);
	self:processDataChanged();
end

--- update unit spec information
function DHUDUnitInfoTracker:updateSpecialization()
	self.specName = self.class;
	self.specRole = "";
	self.specTexture = "";
	self.specID = 0;
	if ((MCVanilla ~= 0 and MCVanilla < 5) or self.unitType ~= self.UNIT_TYPE_PLAYER) then
		return; -- no specializations before MoP, or not player
	end
	local guid = trackingHelper.guids[self.unitId];
	local zone = trackingHelper.zoneType;
	local specName;
	if (zone == "pvp" or (zone == "arena" and self.canAttack)) then -- battleground
		local info = pvpHelper:getSpecInfoByGUID(guid);
		if (info ~= nil) then
			self.specName = info.specName;
			self.specTexture = info.specIcon;
			self.specID = info.specID;
			self.specRole = info.role;
		end
	else
		-- only friend group inspect if user has library from another addon
		local info = self.STATIC_LIB_INSPECT:GetCachedInfo(guid);
		if (info ~= nil) then
			self.specID = info.global_spec_id;
			self.specTexture = info.spec_icon;
			self.specRole = info.spec_role;
			self.specName = info.spec_name_localized;
		end
		--[[if (self.inspectReadyGUID ~= guid) then
			self.spec = GetInspectSpecialization(self.unitId); NotifyInspect(self.unitId);...
		end]]--
	end
	self:processDataChanged();
end

--- update unit classification information
function DHUDUnitInfoTracker:updateEliteType()
	local classification = UnitClassification(self.unitId);
	if (classification == "worldboss") then
		self.eliteType = self.UNIT_ELITE_TYPE_BOSS;
	elseif (classification == "rareelite") then
		self.eliteType = self.UNIT_ELITE_TYPE_RAREELITE;
	elseif (classification == "elite") then
		self.eliteType = self.UNIT_ELITE_TYPE_ELITE;
	elseif (classification == "rare") then
		self.eliteType = self.UNIT_ELITE_TYPE_RARE;
	elseif (classification == "minus") then
		self.eliteType = self.UNIT_ELITE_TYPE_MINION;
	else
		self.eliteType = self.UNIT_ELITE_TYPE_NONE;
	end
	self:processDataChanged();
end

--- update unit npc type information
function DHUDUnitInfoTracker:updateNpcType()
	self.npcType = UnitCreatureType(self.unitId);
	self:processDataChanged();
end

--- update unit tagging information
function DHUDUnitInfoTracker:updateTagging()
	self.tagged = not UnitIsTapDenied(self.unitId);
	self.communityTagged = false;
	--print("UnitIsTappedByAllThreatList(self.unitId) " .. MCTableToString(UnitIsTappedByAllThreatList(self.unitId)));
	self:processDataChanged();
end


--- update unit raid icon information
function DHUDUnitInfoTracker:updateRaidIcon()
	self.raidIcon = GetRaidTargetIndex(self.unitId);
	self:processDataChanged();
end

--- update unit pvp information
function DHUDUnitInfoTracker:updatePvPInfo()
	local faction = UnitFactionGroup(self.unitId);
	local playerFaction = UnitFactionGroup("player");
	if (faction == "Alliance") then
		self.pvpFaction = self.UNIT_PVP_FACTION_ALLIANCE;
	elseif (faction == "Horde") then
		self.pvpFaction = self.UNIT_PVP_FACTION_HORDE;
	else
		self.pvpFaction = self.UNIT_PVP_FACTION_NONE;
	end
	self.isDifferentPvPFaction = faction ~= playerFaction;
	local isPvP = UnitIsPVP(self.unitId);
	local isPvPFFA = UnitIsPVPFreeForAll(self.unitId);
	if (not isPvP) then
		self.pvpState = self.UNIT_PVP_STATE_OFF;
	elseif (isPvPFFA) then
		self.pvpState = self.UNIT_PVP_STATE_FFA;
	else
		self.pvpState = self.UNIT_PVP_STATE_ON;
	end
	self:processDataChanged();
end

--- Start tracking data
function DHUDUnitInfoTracker:startTracking()
	-- listen to game events
	self.eventsFrame:RegisterEvent("UNIT_NAME_UPDATE");
	self.eventsFrame:RegisterEvent("UNIT_FACTION");
	self.eventsFrame:RegisterEvent("UNIT_CLASSIFICATION_CHANGED");
	self.eventsFrame:RegisterEvent("UNIT_LEVEL");
	self.eventsFrame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED");
	self.eventsFrame:RegisterEvent("RAID_TARGET_UPDATE");
end

--- Stop tracking data
function DHUDUnitInfoTracker:stopTracking()
	-- stop listening to game events
	self.eventsFrame:UnregisterEvent("UNIT_NAME_UPDATE");
	self.eventsFrame:UnregisterEvent("UNIT_FACTION");
	self.eventsFrame:UnregisterEvent("UNIT_CLASSIFICATION_CHANGED");
	self.eventsFrame:UnregisterEvent("UNIT_LEVEL");
	self.eventsFrame:UnregisterEvent("PLAYER_SPECIALIZATION_CHANGED");
	self.eventsFrame:UnregisterEvent("RAID_TARGET_UPDATE");
end

--- Update all data for current unitId
function DHUDUnitInfoTracker:updateData()
	self:updateUnitName();
	self:updateGuildName();
	self:updateRelation();
	self:updateUnitType();
	self:updateLevel();
	self:updateClass();
	self:updateRace();
	self:updateSpecialization();
	self:updateEliteType();
	self:updateNpcType();
	self:updateTagging();
	self:updateRaidIcon();
	self:updatePvPInfo();
end
