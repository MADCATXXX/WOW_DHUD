--[[-----------------------------------------------------------------------------------
 Original Drathals HUD (c) 2006 by Markus Inger / Drathal / Silberklinge / Silbersegen
 DHUD for WotLK and later expansions (c) 2013 by MADCAT (EU-Гордунни, Мадкат)
 (http://eu.battle.net/wow/en/character/Гордунни/Мадкат/advanced)
---------------------------------------------------------------------------------------
 This file contains functions and classes to work with data that is required for pvp
 Instances such as battlegrounds/arenas, it's only loaded during arena/battleground match
 @author: MADCAT
-----------------------------------------------------------------------------------]]--

-- antitaint local "_" var
local _;
-- tracker helper
local trackingHelper = DHUDDataTrackingHelper;

-----------------------------------
-- Unit PvP tracker helper class --
-----------------------------------

--- Class to help track PVP information
DHUDPvPTrackerHelper = MCCreateSubClass(MADCATEventDispatcher, {
	-- frame that is listening to events
	eventsFrame			= nil,
	-- defines if currently in PvP instance and listening for events
	isPvPInstance		= false,
	-- defines if update to guids table is scheduled
	isScheduledGuidUpdate = false,
	-- information about specs on the arena and number of oponents on the arena (e.g. #arenaPlayersSpecsData)
	arenaPlayersSpecsData = {},
	-- table with arena guids, each arena unitId will point to guid and each guid will point back to arena unit index (integer)
	arenaGuids			= {},
})

--- Create pvp tracking helper
function DHUDPvPTrackerHelper:new()
	local o = self:defconstructor();
	o:constructor();
	return o;
end

--- Constructor of pvp tracker
function DHUDPvPTrackerHelper:constructor()
	-- events frame
	self.eventsFrame = MCCreateBlizzEventFrame();
	-- call super constructor
	MADCATEventDispatcher.constructor(self);
end

--- Initalize pvp tracker
function DHUDPvPTrackerHelper:init()
	local helper = self;
	trackingHelper:addEventListener(DHUDDataTrackerHelperEvent.EVENT_ENTERING_WORLD, self, self.onEnteringWorld);
	-- process event frame events
	function self.eventsFrame:ARENA_PREP_OPPONENT_SPECIALIZATIONS()
		helper:updateArenaSpecs();
		helper:updateArenaGuids();
	end
	function self.eventsFrame:UNIT_NAME_UPDATE()
		if (helper.isScheduledGuidUpdate ~= true) then
			helper:scheduleArenaGuidsUpdate();
		end
	end
	-- initialize
	self:onEnteringWorld(nil);
end

--- Entering world event, recheck if map is PvP
function DHUDPvPTrackerHelper:onEnteringWorld(e)
	local zone = trackingHelper.zoneType;
	if (zone == "arena" or zone == "pvp") then
		trackingHelper:getSpecsTable(); -- precache
		self:setIsPvPInstance(true);
		self:resetCache();
		self:updateArenaSpecs();
		self:updateArenaGuids();
	else
		self:setIsPvPInstance(false);
	end
end

--- Update events listening based on instance type
-- @param isPvP defines if currently in PVP instance
function DHUDPvPTrackerHelper:setIsPvPInstance(isPvP)
	if (self.isPvPInstance == isPvP) then
		return;
	end
	self.isPvPInstance = isPvP;
	if (isPvP) then
		self.eventsFrame:RegisterEvent("ARENA_PREP_OPPONENT_SPECIALIZATIONS");
		self.eventsFrame:RegisterEvent("UNIT_NAME_UPDATE");
	else
		self.eventsFrame:UnregisterEvent("ARENA_PREP_OPPONENT_SPECIALIZATIONS");
		self.eventsFrame:UnregisterEvent("UNIT_NAME_UPDATE");
	end
end

--- Function to schedule arena guids update
function DHUDPvPTrackerHelper:scheduleArenaGuidsUpdate()
	if (self.isScheduledGuidUpdate) then
		return;
	end
	self.isScheduledGuidUpdate = true;
	trackingHelper:addEventListener(DHUDDataTrackerHelperEvent.EVENT_UPDATE_FREQUENT, self, self.onUpdateArenaGuidsOnce);
end

--- Next frame event, update guids after unit names where added
function DHUDPvPTrackerHelper:onUpdateArenaGuidsOnce(e)
	trackingHelper:removeEventListener(DHUDDataTrackerHelperEvent.EVENT_UPDATE_FREQUENT, self, self.onUpdateArenaGuidsOnce);
	self:updateArenaGuids(false);
end

--- Reset cache on entering arena/battleground
function DHUDPvPTrackerHelper:resetCache()
	self.arenaPlayersSpecsData = {};
	self.arenaGuids = {};
end

--- Update arena oponent specs by iterating over them
function DHUDPvPTrackerHelper:updateArenaSpecs()
	if (trackingHelper.zoneType ~= "arena") then
		return;
	end
	local specsTable = trackingHelper:getSpecsTable();
	for i = 1, 15 do -- up to 15 enemies in the Arena Brawl
		local specID, gender = GetArenaOpponentSpec(i);
		if (specID == nil) then
			break; -- no more oponnents
		end
		local info = specsTable[specID];
		--print("specID " .. specID .. " info " .. MCTableToString(info));
		if (info ~= nil) then
			if (gender == 3 and info.specName ~= info.femaleSpecName) then
				local copy = MCCreateTableCopy(info);
				copy.specName = info.femaleSpecName;
				info = copy;
			end
			self.arenaPlayersSpecsData[i] = info;
		end
	end
	--print("arena specs " .. MCTableToString(self.arenaPlayersSpecsData));
end

--- Function to update arena guids when player is on arena or on battleground (some of the functions may refer to this table later)
function DHUDPvPTrackerHelper:updateArenaGuids()
	local guids = self.arenaGuids;
	if (trackingHelper.zoneType == "arena") then
		local failed = 0;
		local numOponents = #self.arenaPlayersSpecsData;
		for i = 1, numOponents do
			local unitID = "arena" .. i;
			local guid = UnitGUID(unitID);
			--print("UnitId " .. unitID .. " guid is " .. MCTableToString(guid));
			if (guid ~= nil) then
				guids[unitID] = guid;
				guids[guid] = i;
			end
		end
	end
end

--- Get index of arena opponent by it's guid
-- @param guid unit global identifier for which we need index
-- @return index of the unit on the arena (integer)
function DHUDPvPTrackerHelper:getArenaGuidIndex(guid)
	local index = self.arenaGuids[guid];
	if (index == nil) then
		--print("guid " .. MCTableToString(guid) .. " not found, rechecking...");
		if (#self.arenaPlayersSpecsData == 0) then
			self:updateArenaSpecs();
		end
		self:updateArenaGuids(); -- recheck, as Rogues/Druids/Mages can be hidden at the start
		index = self.arenaGuids[guid];
	end
	return index;
end

--- Function to update arena guids when player is on arena or on battleground (some of the functions may refer to this table later)
-- @param guid unit global identifier for which we need specs data
-- @return data about spec of the unit (e.g. { [specID], [role], [specName], [specIcon], [classTag] })
function DHUDPvPTrackerHelper:getSpecInfoByGUID(guid)
	local zone = trackingHelper.zoneType;
	if (zone == "pvp") then -- battleground
		local scoreInfo = C_PvP.GetScoreInfoByPlayerGuid(guid);
		if (scoreInfo ~= nil) then
			local specsTable = trackingHelper:getSpecsTable();
			local specName = scoreInfo.talentSpec;
			local info = specsTable[specName];
			if (info ~= nil) then
				if (info.specName ~= specName) then
					local copy = MCCreateTableCopy(info);
					copy.specName = specName;
					info = copy;
				end
				return info;
			end
		end
	elseif (zone == "arena") then
		local arenaIndex = self:getArenaGuidIndex(guid);
		if (arenaIndex ~= nil) then
			return self.arenaPlayersSpecsData[arenaIndex];
		end
	end
	return nil;
end

-- helper object
DHUDPvPTrackingHelper = DHUDPvPTrackerHelper:new();
