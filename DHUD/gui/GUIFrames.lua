--[[-----------------------------------------------------------------------------------
 Original Drathals HUD (c) 2006 by Markus Inger / Drathal / Silberklinge / Silbersegen
 DHUD for WotLK and later expansions (c) 2013 by MADCAT (EU-Гордунни, Мадкат)
 (http://eu.battle.net/wow/en/character/гордунни/Мадкат/advanced)
---------------------------------------------------------------------------------------
 This file contains functions that create GUI Frames, also listens to events that
 modify look of this GUI Frames. Data to be displayed is not managed here
 @author: MADCAT
-----------------------------------------------------------------------------------]]--

---------
-- GUI --
---------

--- Class to create and change graphical user interface
DHUDGUI = {
	-- current bar texture
	barsTexture	= 2,
	-- defines if bars background texture should be shown
	backgroundTexture = true,
	-- distance between bars divided by two, this number holds bar offset from center, so distance is two times higher
	barsDistanceDiv2 = 0,
	-- mask with conditions to enable mouse in gui frames
	mouseEnableConditionsMask = 0,
	-- list with information about textures
	textures = {
		-- path to background with 0 big bars and 0 small
		["BackgroundBars0B0S"] = {"Interface\\AddOns\\DHUD\\art\\bg_0", 0, 1, 0, 1 },
		-- path to background with 1 big inner bar and 0 small
		["BackgroundBars1BI0S"] = {"Interface\\AddOns\\DHUD\\art\\bg_1", 0, 1, 0, 1 },
		-- path to background with 1 big inner bar and 1 small inner
		["BackgroundBars1BI1SI"] = {"Interface\\AddOns\\DHUD\\art\\bg_1p", 0, 1, 0, 1 },
		-- path to background with 2 big bars and 0 small
		["BackgroundBars1BO0S"] = {"Interface\\AddOns\\DHUD\\art\\bg_2", 0, 1, 0, 1 },
		-- path to background with 2 big bars and 0 small
		["BackgroundBars2B0S"] = {"Interface\\AddOns\\DHUD\\art\\bg_21", 0, 1, 0, 1 },
		-- path to background with 2 big bars and 1 small inner
		["BackgroundBars2B1SI"] = {"Interface\\AddOns\\DHUD\\art\\bg_21p", 0, 1, 0, 1 },
		-- path to background with 2 big bars and 2 small
		["BackgroundBars2B2S"] = {"Interface\\AddOns\\DHUD\\art\\bg_21pp", 0, 1, 0, 1 },
		-- path prefix to first big bar texture
		["TexturePrefixBarB1"] = { "Interface\\AddOns\\DHUD\\art\\1", 0, 1, 0, 1 },
		-- path prefix to second big bar texture
		["TexturePrefixBarB2"] = { "Interface\\AddOns\\DHUD\\art\\2", 0, 1, 0, 1 },
		-- path prefix to first small bar texture
		["TexturePrefixBarS1"] = { "Interface\\AddOns\\DHUD\\art\\p1", 0, 1, 0, 1 },
		-- path prefix to second small bar texture
		["TexturePrefixBarS2"] = { "Interface\\AddOns\\DHUD\\art\\p2", 0, 1, 0, 1 },
		-- path to texture with inner casting bar
		["CastingBarB1"] = { "Interface\\AddOns\\DHUD\\art\\cb", 0, 1, 0, 1 },
		-- path to texture with inner casting bar flash animation
		["CastFlashBarB1"] = { "Interface\\AddOns\\DHUD\\art\\cbh", 0, 1, 0, 1 },
		-- path to texture with inner casting bar filled (for empower positions)
		["CastFillBarB1"] = { "Interface\\AddOns\\DHUD\\art\\cbe", 0, 1, 0, 1 },
		-- path to texture with outer casting bar
		["CastingBarB2"] = { "Interface\\AddOns\\DHUD\\art\\ecb", 0, 1, 0, 1 },
		-- path to texture with outer casting bar flash animation
		["CastFlashBarB2"] = { "Interface\\AddOns\\DHUD\\art\\ecbh", 0, 1, 0, 1 },
		-- path to texture with outer casting bar filled (for empower positions)
		["CastFillBarB2"] = { "Interface\\AddOns\\DHUD\\art\\ecbe", 0, 1, 0, 1 },
		-- overlay that is drawn over spell circles
		["OverlaySpellCircle"] = { "Interface\\AddOns\\DHUD\\art\\serenity0", 0, 1, 0, 1 },
		-- path to texture with red combo circle
		["ComboCircleRed"] = { "Interface\\AddOns\\DHUD\\art\\c1", 0, 1, 0, 1 },
		-- path to texture with red combo circle
		["ComboCircleJadeGreen"] = { "Interface\\AddOns\\DHUD\\art\\c2", 0, 1, 0, 1 },
		-- path to texture with red combo circle
		["ComboCircleCyan"] = { "Interface\\AddOns\\DHUD\\art\\c3", 0, 1, 0, 1 },
		-- path to texture with red combo circle
		["ComboCircleOrange"] = { "Interface\\AddOns\\DHUD\\art\\c4", 0, 1, 0, 1 },
		-- path to texture with red combo circle
		["ComboCircleGreen"] = { "Interface\\AddOns\\DHUD\\art\\c5", 0, 1, 0, 1 },
		-- path to texture with red combo circle
		["ComboCirclePurple"] = { "Interface\\AddOns\\DHUD\\art\\c6", 0, 1, 0, 1 },
		-- path to texture with golden dragon for hud
		["TargetEliteDragon"] = { "Interface\\AddOns\\DHUD\\art\\elite", 0, 1, 0, 1 },
		-- path to texture with silver dragon for hud
		["TargetRareDragon"] = { "Interface\\AddOns\\DHUD\\art\\rare", 0, 1, 0, 1 },
		-- blizzard cast bar icon shield (http://wowprogramming.com/BlizzArt/Interface/CastingBar/UI-CastingBar-Arena-Shield.png), icon inside is 20x20, border is 38x44
		["BlizzardCastBarIconShield"] = { "Interface\\CastingBar\\UI-CastingBar-Arena-Shield", 0.015625, 0.609375, 0.1875, 0.875 },
		-- blizzard horde pvp flag
		["BlizzardPvPHorde"] = { "Interface\\TargetingFrame\\UI-PVP-Horde", 0.6, 0, 0, 0.6 },
		-- blizzard alliance pvp flag
		["BlizzardPvPAlliance"] = { "Interface\\TargetingFrame\\UI-PVP-Alliance", 0, 0.6, 0, 0.6 },
		-- blizzard arena pvp flag
		["BlizzardPvPArena"] = { "Interface\\TargetingFrame\\UI-PVP-FFA", 0, 0.6, 0, 0.6 },
		-- blizzard raid icon with index 1
		["BlizzardRaidIcon1"] = { "Interface\\TargetingFrame\\UI-RaidTargetingIcons", 0, 0.25, 0, 0.25 },
		-- blizzard raid icon with index 2
		["BlizzardRaidIcon2"] = { "Interface\\TargetingFrame\\UI-RaidTargetingIcons", 0.25, 0.50, 0, 0.25 },
		-- blizzard raid icon with index 3
		["BlizzardRaidIcon3"] = { "Interface\\TargetingFrame\\UI-RaidTargetingIcons", 0.50, 0.75, 0, 0.25 },
		-- blizzard raid icon with index 4
		["BlizzardRaidIcon4"] = { "Interface\\TargetingFrame\\UI-RaidTargetingIcons", 0.75, 1, 0, 0.25 },
		-- blizzard raid icon with index 5
		["BlizzardRaidIcon5"] = { "Interface\\TargetingFrame\\UI-RaidTargetingIcons", 0, 0.25, 0.25, 0.50 },
		-- blizzard raid icon with index 6
		["BlizzardRaidIcon6"] = { "Interface\\TargetingFrame\\UI-RaidTargetingIcons", 0.25, 0.50, 0.25, 0.50 },
		-- blizzard raid icon with index 7
		["BlizzardRaidIcon7"] = { "Interface\\TargetingFrame\\UI-RaidTargetingIcons", 0.50, 0.75, 0.25, 0.50 },
		-- blizzard raid icon with index 8
		["BlizzardRaidIcon8"] = { "Interface\\TargetingFrame\\UI-RaidTargetingIcons", 0.75, 1, 0.25, 0.50 },
		-- blizzard resting icon
		["BlizzardPlayerResting"] = { "Interface\\CharacterFrame\\UI-StateIcon", 0.0625, 0.4475, 0.0625, 0.4375 },
		-- blizzard inCombat icon
		["BlizzardPlayerInCombat"] = { "Interface\\CharacterFrame\\UI-StateIcon", 0.5625, 0.9375, 0.0625, 0.4375 },
		-- blizzard party leaded icon
		["BlizzardPlayerLeader"] = { "Interface\\GroupFrame\\UI-Group-LeaderIcon", 0, 1, 0, 1 },
		-- blizzard party master looter icon
		["BlizzardPlayerLooter"] = { "Interface\\GroupFrame\\UI-Group-MasterLooter", 0, 1, 0, 1 },
		-- blizzard specialization role "TANK" icon (http://wowprogramming.com/BlizzArt/Interface/LFGFRAME/UI-LFG-ICON-PORTRAITROLES.png), (http://wowprogramming.com/BlizzArt/Interface/LFGFRAME/UI-LFG-ICON-ROLES.png)
		["BlizzardSpecializationRoleTank"] = { "Interface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES", 0, 0.5, 0.5, 1 },
		-- blizzard specialization role "DAMAGER" icon
		["BlizzardSpecializationRoleDamager"] = { "Interface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES", 0.5, 1, 0.5, 1 },
		-- blizzard specialization role "HEALER" icon
		["BlizzardSpecializationRoleHealer"] = { "Interface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES", 0.5, 1, 0, 0.5 },
		-- blizzard specialization role "GUIDE" icon (for party groups only)
		["BlizzardSpecializationRoleGuide"] = { "Interface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES", 0, 0.5, 0, 0.5 },
		-- blizzard death-knight rune "Blood"
		["BlizzardDeathKnightRuneBlood"] = { "Interface\\PlayerFrame\\UI-PlayerFrame-Deathknight-Blood", 0, 1, 0, 1 },
		-- blizzard death-knight rune "Frost"
		["BlizzardDeathKnightRuneFrost"] = { "Interface\\PlayerFrame\\UI-PlayerFrame-Deathknight-Frost", 0, 1, 0, 1 },
		-- blizzard death-knight rune "Unholy"
		["BlizzardDeathKnightRuneUnholy"] = { "Interface\\PlayerFrame\\UI-PlayerFrame-Deathknight-Unholy", 0, 1, 0, 1 },
		-- blizzard death-knight rune "Death"
		["BlizzardDeathKnightRuneDeath"] = { "Interface\\PlayerFrame\\UI-PlayerFrame-Deathknight-SingleRune", 0, 1, 0, 1 }, -- UI-PlayerFrame-Deathknight-Death
		-- blizzard rectangle border texture
		["BlizzardOverlayRectangleBorder"] = { "Interface\\Buttons\\UI-Debuff-Border", 0, 1, 0, 1 },
	},
	-- list with fonts information
	fonts = {
		-- default font for all text fields if not specified
		["default"] = GetLocale() == "ruRU" and "Fonts\\FRIZQT___CYR.TTF" or "Fonts\\FRIZQT__.TTF",
		-- font to be used for text fields that display numbers
		["numeric"] = "Interface\\AddOns\\DHUD\\art\\Number.TTF",
	},
	-- list with clipping information about textures, required to change height correctly, each value contains following info: { pixelsHeight, pixelsFromTop, pixelsFromBottom
	clipping = {
		-- information about height of the big inner bar
		["TexturePrefixBarB1"]   = { 256, 11, 11 },
		-- information about height of the big outter bar
        ["TexturePrefixBarB2"]   = { 256, 5, 5 },
		-- information about height of the small inner bar
        ["TexturePrefixBarS1"]  = { 256, 128, 20 },
		-- information about height of the small outer bar
        ["TexturePrefixBarS2"]  = { 256, 128, 20 },
		-- information about height of inner casting bar
		["CastingBarB1"]  = { 256, 11, 11 },
		-- information about height of inner casting bar flash animation
		["CastFlashBarB1"] = { 256, 11, 11 },
		-- information about height of inner casting bar filled (for empower positions)
		["CastFillBarB1"] = { 256, 11, 11 },
		-- information about height of outer casting bar
		["CastingBarB2"]  = { 256, 5, 5 },
		-- information about height of outer casting bar flash animation
		["CastFlashBarB2"]  = { 256, 5, 5 },
		-- information about height of outer casting bar filled (for empower positions)
		["CastFillBarB2"]  = { 256, 5, 5 },
	},
	-- relative information of some frames, required when changing height of bars
	positions = {
		-- left bars are positioned at the same position as background
		["leftBars"] = { "DHUD_Left_BarsBackground", "BOTTOM", "BOTTOM", 0, 0, 128, 256 },
		-- right bars are positioned at the same position as background
		["rightBars"] = { "DHUD_Right_BarsBackground", "BOTTOM", "BOTTOM", 0, 0, 128, 256 },
		-- left cast bars are positioned at the same position as background
		["leftCastBars"] = { "DHUD_Left_BarsBackground", "BOTTOM", "BOTTOM", 0, 0, 128, 256 },
		-- right cast bars are positioned at the same position as background
		["rightCastBars"] = { "DHUD_Right_BarsBackground", "BOTTOM", "BOTTOM", 0, 0, 128, 256 },
	},
	-- list with dropdown menu references, filled by createFrames function
	dropdownMenus = {
	},
	-- list with frame references, filled by createFrames function
	frames = {
	},
	-- list with frame groups, each group contain references of it's frames, filled by createFrames function
	frameGroups = {
	},
	-- current scale of hud elements, ids for this table will be generated automatically if not specified
	scale		= {
	},
	-- list with function that are required to be executed when some of the scale settings changes
	scaleNotifyList = {
	},
	-- defines scale of the hud in whole
	SCALE_MAIN	= 1,
	-- defines scale of spell circles
	SCALE_SPELL_CIRCLES	= 2,
	-- defines scale of spell rectangles
	SCALE_SPELL_RECTANGLES = 3,
	-- defines scale of the resource frames
	SCALE_RESOURCES = 4,
	-- current scale of fonts, ids for this table will be generated automatically if not specified
	fontSizes = {
	},
	-- current font outlines, ids for this table will be generated automatically if not specified
	fontOutlines = {
	},
	-- current frames alpha
	framesAlpha	= 1,
	-- frame visible due to ui logic
	FRAME_VISIBLE_REASON_UI = 1,
	-- frame visible due to being enabled in settings
	FRAME_VISIBLE_REASON_ENABLED = 2,
	-- frame visible due to alpha value greater than zero
	FRAME_VISIBLE_REASON_ALPHA = 4,
	-- frame visible due to player being alive
	FRAME_VISIBLE_REASON_ALIVE = 8,
	-- frame visible due to all visibility factors
	FRAME_VISIBLE_REASON_ALL = 15,
	-- background texture mask for left bars
	backgroundLeft = 0,
	-- background texture mask for right bars
	backgroundRight = 0,
	-- number to be passed to changeBarsBackground function if inner big bar should be shown
	BACKGROUND_BAR_BIG1 = 1,
	-- number to be passed to changeBarsBackground function if outer big bar should be shown
	BACKGROUND_BAR_BIG2 = 2,
	-- number to be passed to changeBarsBackground function if inner small bar should be shown
	BACKGROUND_BAR_SMALL1 = 4,
	-- number to be passed to changeBarsBackground function if outer small bar should be shown
	BACKGROUND_BAR_SMALL2 = 8,
	-- flags for font to change it's outline
	FONT_OUTLINES = { "", "OUTLINE", "THICKOUTLINE" },
	-- index of cast bar frame in cast bar group
	CASTBAR_GROUP_INDEX_CAST_INDICATION = 1,
	-- index of cast flash animation in cast bar group
	CASTBAR_GROUP_INDEX_FLASH = 2,
	-- index of spell icon in cast bar group
	CASTBAR_GROUP_INDEX_ICON = 3,
	-- index of spell name in cast bar group
	CASTBAR_GROUP_INDEX_SPELLNAME = 4,
	-- index of cast time in cast bar group
	CASTBAR_GROUP_INDEX_CASTTIME = 5,
	-- index of delay in cast bar group
	CASTBAR_GROUP_INDEX_DELAY = 6,
	-- number of total frames in cast bar group
	CASTBAR_GROUP_NUM_FRAMES = 6,
	-- index for empower placement #1, next values will be increased by 1
	CASTBAR_GROUP_INDEX_EMPOWER1 = 7,
}

--- Draws backdrop on frame specified, good for debugging purposes
-- @param frame frame to draw backdrop on
-- @param r amount of red color
-- @param g amount of green color
-- @param b amount of blue color
-- @param a alpha of the backdrop
function DHUDGUI:drawFrameBackdrop(frame, r, g, b, a)
	frame:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", tile = true, tileSize = 32, insets = { left = 0, right = 0, top = 0, bottom = 0 }});
	if not(r) then
		r = 0; g = 0; b = 0; a = 0.2;
	end
    frame:SetBackdropColor(r, g, b, a);
end

--- Create frame with parameters specified
-- @param name name of the frame, variable with this name will be created in global namespace, it will also be used in local frames table
-- @param parentName name of the parent frame, this frame will be inserted to parent container
-- @param relativePointThis relative point of frame to be used as attach point
-- @param relativePointParent relative point of parent frame to be used as attach point
-- @param offsetX horizontal offset from attach point
-- @param offsetY vertical offset from attach point
-- @param width width of the frame
-- @param height height of the frame
-- @param frameStrata frame layer to be used (one of the following: BACKGROUND, LOW, MEDIUM, HIGH, DIALOG, FULLSCREEN, FULLSCREEN_DIALOG, TOOLTIP), BACKGROUND is default
-- @param frameType type of the frame to create, default is "Frame"
-- @return created frame
function DHUDGUI:createFrame(name, parentName, relativePointThis, relativePointParent, offsetX, offsetY, width, height, frameStrata, frameType)
	-- default layer
	frameStrata = frameStrata or "BACKGROUND";
	-- default type
	frameType = frameType or "Frame";
	local frame = CreateFrame(frameType, name, _G[parentName]);
	frame:SetPoint(relativePointThis, parentName, relativePointParent, offsetX, offsetY);
	frame:SetWidth(width);
	frame:SetHeight(height);
	frame:EnableMouse(false);
	-- save relative point information, it will be used for offset settings
	frame.relativeInfo = { relativePointThis, parentName, relativePointParent, offsetX, offsetY };
	-- update frame strata and level, if you set your frameStrata to "BACKGROUND" it will be blocked from receiving mouse events unless you set frameLevel to 1 or more
	-- Possible values are, from lowest to highest, 'higher' being layered on top of the 'lower' ones at runtime.
	frame:SetFrameStrata(frameStrata);
	--frame:SetFrameLevel(0);
	-- save to table
	self.frames[name] = frame;
	-- update show and hide functions, and set visibility according to current alpha
	frame.DShow = DHUDGUI.showFrame;
	frame.DHide = DHUDGUI.hideFrame;
	frame.visibleReason = self.FRAME_VISIBLE_REASON_ALL;
	if (self.framesAlpha <= 0) then
		frame:DHide(self.FRAME_VISIBLE_REASON_ALPHA);
	end
	-- debug
	--self:drawFrameBackdrop(frame, 0, 0, 0, 0.2);
	return frame;
end

--- Show frame with reason (do not use it manually, as it's not part of this class!)
-- @param self reference to frame!
-- @param reason reason to show
function DHUDGUI.showFrame(self, reason)
	reason = reason or DHUDGUI.FRAME_VISIBLE_REASON_UI;
	self.visibleReason = bit.bor(self.visibleReason, reason);
	if (self.visibleReason == DHUDGUI.FRAME_VISIBLE_REASON_ALL) then
		self.Show(self); -- call super
	end
	--print("frame " .. self:GetName() .. " show reason " .. reason .. " total " .. self.visibleReason);
end
		
--- Hide frame with reason (do not use it manually, as it's not part of this class!)
-- @param self reference to frame!
-- @param reason reason to show
function DHUDGUI.hideFrame(self, reason)
	reason = reason or DHUDGUI.FRAME_VISIBLE_REASON_UI;
	self.visibleReason = bit.band(self.visibleReason, mcbit.bnot(reason)); -- changed 'bnot' to self lib function as it causes errors on Mac OS X
	-- frame visible reason is not DHUDGUI.FRAME_VISIBLE_REASON_ALL
	self.Hide(self); -- call super
	--print("frame " .. self:GetName() .. " hide reason " .. reason .. " total " .. self.visibleReason);
end

-- Create texture frame with parameters specified
-- @param name name of the frame, variable with this name will be created in global namespace, it will also be used in local frames table
-- @param parentName name of the parent frame, this frame will be inserted to parent container
-- @param relativePointThis relative point of frame to be used as attach point
-- @param relativePointParent relative point of parent frame to be used as attach point
-- @param offsetX horizontal offset from attach point
-- @param offsetY vertical offset from attach point
-- @param width width of the frame
-- @param height height of the frame
-- @param textureName name of the texture from local textures table
-- @param textureMirror if true then this frame will be mirrored around vertical line
-- @param textureLayer layer to be set for texture (one of the following: BACKGROUND, BORDER, ARTWORK, OVERLAY, HIGHLIGHT), BACKGROUND is default
-- @return created frame and texture
function DHUDGUI:createTextureFrame(name, parentName, relativePointThis, relativePointParent, offsetX, offsetY, width, height, textureName, textureMirror, textureLayer)
	-- default layer
	textureLayer = textureLayer or "BACKGROUND";
	-- create frame
	local frame = self:createFrame(name, parentName, relativePointThis, relativePointParent, offsetX, offsetY, width, height);
	-- get texture path and crop info
	local path, x0, x1, y0, y1 = unpack(self.textures[textureName]);
	-- apply mirror effect if required
	if (textureMirror) then
		local xTmp = x0;
		x0 = x1;
		x1 = xTmp;
	end
	-- create texture
	local texture = frame:CreateTexture(name .. "_texture", textureLayer);
	texture:SetTexture(path);
	-- required to map texture size to frame width
	texture:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0);
	texture:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0);
	-- set coordinates
	texture:SetTexCoord(x0, x1, y0, y1); -- parameters: minX, maxX, minY, maxY
	frame.texture = texture; -- save reference to frame local variable
	texture.frame = frame; -- save reference to texture local variable
	--self:drawFrameBackdrop(frame, 0, 1, 0, 0.3);
	return frame, texture;
end

-- Create bar frame with parameters specified
-- @param name name of the frame, variable with this name will be created in global namespace, it will also be used in local frames table
-- @param parentName name of the parent frame, this frame will be inserted to parent container
-- @param relativePointThis relative point of frame to be used as attach point
-- @param relativePointParent relative point of parent frame to be used as attach point
-- @param offsetX horizontal offset from attach point
-- @param offsetY vertical offset from attach point
-- @param width width of the frame
-- @param height height of the frame
-- @param textureName name of the texture from local textures table
-- @param textureMirror if true then this frame will be mirrored around vertical line
-- @return created frame and texture
function DHUDGUI:createBarFrame(name, parentName, relativePointThis, relativePointParent, offsetX, offsetY, width, height, textureName, textureMirror)
	-- create frame
	local frame, texture = self:createTextureFrame(name, parentName, relativePointThis, relativePointParent, offsetX, offsetY, width, height, textureName, textureMirror);
	-- update texture
	texture.pathPrefix = self.textures[textureName][1]; -- save path prefix to texture local variable
	texture:SetTexture(texture.pathPrefix .. self.barsTexture);
	-- set points
	texture:ClearAllPoints();
	texture:SetPoint("CENTER", frame, "CENTER", 0, 0);
	--self:drawFrameBackdrop(frame, 0, 1, 0, 0.1);
	return frame, texture;
end

-- Create bar frame with parameters specified
-- @param type type of the cast bar frame
-- @param name name of the frames, variable with this name will be created in global namespace, it will also be used in local frames table
-- @param parentName name of the parent frame, this frame will be inserted to parent container
-- @param relativePointThis relative point of frame to be used as attach point
-- @param relativePointParent relative point of parent frame to be used as attach point
-- @param offsetX horizontal offset from attach point
-- @param offsetY vertical offset from attach point
-- @param width width of the frame
-- @param height height of the frame
-- @param textureName name of the texture from local textures table
-- @param textureMirror if true then this frame will be mirrored around vertical line
-- @return created frame and texture
function DHUDGUI:createCastBarFrame(name, parentName, relativePointThis, relativePointParent, offsetX, offsetY, width, height, textureName, textureMirror)
	-- create frame
	local frame, texture = self:createTextureFrame(name, parentName, relativePointThis, relativePointParent, offsetX, offsetY, width, height, textureName, textureMirror, "BORDER");
	-- set points
	texture:ClearAllPoints();
	texture:SetPoint("CENTER", frame, "CENTER", 0, 0);
	--self:drawFrameBackdrop(frame, 0, 1, 0, 0.1);
	return frame, texture;
end

-- Create bar frame with parameters specified
-- @param type type of the cast bar frame
-- @param name name of the frames, variable with this name will be created in global namespace, it will also be used in local frames table
-- @param parentName name of the parent frame, this frame will be inserted to parent container
-- @param relativePointThis relative point of frame to be used as attach point
-- @param relativePointParent relative point of parent frame to be used as attach point
-- @param offsetX horizontal offset from attach point
-- @param offsetY vertical offset from attach point
-- @param width width of the frame
-- @param height height of the frame
-- @return created frame and texture
function DHUDGUI:createCastBarIconFrame(name, parentName, relativePointThis, relativePointParent, offsetX, offsetY, width, height)
	-- create frame
	frame = self:createFrame(name, parentName, relativePointThis, relativePointParent, offsetX, offsetY, width, height, nil, "Button");
	-- create border texture
	local texturePath, x0, x1, y0, y1 = unpack(self.textures["BlizzardCastBarIconShield"]); -- icon 20x20, total dimensions 38x44
	local texture = frame:CreateTexture(name .. "_border", "ARTWORK", nil, 7);
	local scaleX = width / 20;
	local scaleY = height / 20;
	texture:SetTexture(texturePath);
	texture:SetVertexColor(1.0, 1.0, 1.0);
	texture:SetPoint("TOPLEFT", frame, "TOPLEFT", -9 * scaleX, 8 * scaleY);
	texture:SetWidth(38 * scaleX);
	texture:SetHeight(44 * scaleY);
	texture:SetTexCoord(x0, x1, y0, y1);
	frame.border = texture;
	-- set normal texture
	frame:SetNormalTexture("Interface\\Icons\\Ability_Druid_TravelForm");
	return frame;
end

-- Create text font string with parameters specified
-- @param frame frame for which font string is required
-- @param variableName name of the variable to be used in frame to save reference to this text field
-- @param relativePointThis relative point of font string to be used as attach point
-- @param relativePointParent relative point of frame to be used as attach point
-- @param offsetX horizontal offset from attach point
-- @param offsetY vertical offset from attach point
-- @param width width of the frame, pass nil for auto-resize
-- @param height height of the frame
-- @param alignH align to use along horizontal axis
-- @param alignV align to use along vertical axis
-- @param fontType type of the font to use in text field, default is used if not specified
-- @param fontLayer layer to be set for text (one of the following: BACKGROUND, BORDER, ARTWORK, OVERLAY, HIGHLIGHT), ARTWORK is default
-- @return created textField
function DHUDGUI:createTextFontString(frame, variableName, relativePointThis, relativePointParent, offsetX, offsetY, width, height, alignH, alignV, fontType, fontLayer)
	-- default font
	fontType = fontType or "default";
	-- default layer
	fontLayer = fontLayer or "ARTWORK";
	-- read autoresize
	local autoresize = (width == nil);
	width = width or 200;
	-- create text
	local textField = frame:CreateFontString(frame:GetName() .. "_" .. variableName, fontLayer);
	local fontName = self.fonts[fontType];
	textField.fontName = fontName; -- required since GetFont won't return the font that was set (SetFont function is now asynchronous, moreover their order is now not dependent)
	textField:SetFont(fontName, 10, "");
	textField:SetFontObject(GameFontHighlightSmall);
	textField:SetJustifyH(alignH);
	textField:SetJustifyV(alignV);
	textField:SetWidth(width);
	textField:SetHeight(height);
	textField:SetPoint(relativePointThis, frame, relativePointParent, offsetX, offsetY);
	
	frame[variableName] = textField; -- save reference to frame local variable
	textField.frame = frame; -- save reference to textField local variable
	-- update set text function
	if (autoresize) then
		textField.DSetText = DHUDGUI.setTextToTextFrameAndUpdateWidth;
	else
		textField.DSetText = textField.SetText;
	end
	-- debug
	--textField:DSetText(frame:GetName());
	return textField;
end

-- Create text frame with parameters specified
-- @param name name of the frame, variable with this name will be created in global namespace, it will also be used in local frames table
-- @param parentName name of the parent frame, this frame will be inserted to parent container
-- @param relativePointThis relative point of frame to be used as attach point
-- @param relativePointParent relative point of parent frame to be used as attach point
-- @param offsetX horizontal offset from attach point
-- @param offsetY vertical offset from attach point
-- @param width width of the frame, pass nil for auto-resize
-- @param height height of the frame
-- @param alignH align to use along horizontal axis
-- @param alignV align to use along vertical axis
-- @param fontType type of the font to use in text field, default is used if not specified
-- @param fontLayer layer to be set for text (one of the following: BACKGROUND, BORDER, ARTWORK, OVERLAY, HIGHLIGHT), ARTWORK is default
-- @return created frame and textField
function DHUDGUI:createTextFrame(name, parentName, relativePointThis, relativePointParent, offsetX, offsetY, width, height, alignH, alignV, fontType, fontLayer)
	-- read autoresize
	local autoresize = (width == nil);
	-- create frame
	local frame = self:createFrame(name, parentName, relativePointThis, relativePointParent, offsetX, offsetY, width or 200, height);
	frame.resizeWithTextField = autoresize;
	-- create text
	local textField = self:createTextFontString(frame, "textField", "CENTER", "CENTER", 0, 0, width, height, alignH, alignV, fontType, fontLayer);
	-- debug
	--self:drawFrameBackdrop(frame, 0, 0, 1, 0.5);
	return frame, textField;
end

-- Create unit text frame with parameters specified
-- @param name name of the frame, variable with this name will be created in global namespace, it will also be used in local frames table
-- @param parentName name of the parent frame, this frame will be inserted to parent container
-- @param relativePointThis relative point of frame to be used as attach point
-- @param relativePointParent relative point of parent frame to be used as attach point
-- @param offsetX horizontal offset from attach point
-- @param offsetY vertical offset from attach point
-- @param width width of the frame, pass nil for auto-resize
-- @param height height of the frame
-- @param alignH align to use along horizontal axis
-- @param alignV align to use along vertical axis
-- @param fontType type of the font to use in text field, default is used if not specified
-- @param fontLayer layer to be set for text (one of the following: BACKGROUND, BORDER, ARTWORK, OVERLAY, HIGHLIGHT), ARTWORK is default
-- @return created frame and textField
function DHUDGUI:createUnitTextFrame(name, parentName, relativePointThis, relativePointParent, offsetX, offsetY, width, height, alignH, alignV, fontType, fontLayer)
	-- read autoresize
	local autoresize = (width == nil);
	-- create frame
	local frame = self:createFrame(name, parentName, relativePointThis, relativePointParent, offsetX, offsetY, width or 200, height, nil, "Button");
	frame.resizeWithTextField = autoresize;
	-- create text
	local textField = self:createTextFontString(frame, "textField", "CENTER", "CENTER", 0, 0, width, height, alignH, alignV, fontType, fontLayer);
	-- listen to mouse events, mouse will be enabled during runtime if enabled in settings and target is eligable for dropdown menu
	frame:EnableMouse(false);
	frame:RegisterForClicks("RightButtonUp");
	frame:SetScript("OnClick", function(frame, arg1)
		-- toggle dropdown
		DHUDGUIManager:toggleUnitTextDropdown(frame);
	end);
	-- debug
	--self:drawFrameBackdrop(frame, 0, 0, 1, 0.5);
	return frame, textfield;
end

--- Create spell circle near bar
-- @param name name of the frame
-- @return frame created
function DHUDGUI:createSpellCircleFrame(name)
	-- create frame
	frame = self:createFrame(name, "DHUD_UIParent", "CENTER", "CENTER", 0, 0, 26, 26, nil, "Button");
	-- create border texture
	local texturePath = unpack(self.textures["OverlaySpellCircle"]);
	local texture = frame:CreateTexture(name .. "_border", "ARTWORK", nil, 7);
	texture:SetTexture(texturePath);
	texture:SetVertexColor(1.0, 1.0, 1.0);
	texture:SetPoint("TOPLEFT", frame, "TOPLEFT", -7.5, 7.5);
	texture:SetHeight(26 * 1.6);
	texture:SetWidth(26 * 1.6);
	texture:SetTexCoord(0, 1, 0, 1);
	texture:SetBlendMode("BLEND");
	frame.border = texture;
	-- set normal texture
	frame:SetNormalTexture("Interface\\Icons\\Ability_Druid_TravelForm");
	-- time left text
	local textField1 = self:createTextFontString(frame, "textFieldTime", "CENTER", "CENTER", 0, 0, 26 * 2, 26, "CENTER", "CENTER", "default", "OVERLAY");
	-- stack text
	local textField2 = self:createTextFontString(frame, "textFieldCount", "BOTTOMRIGHT", "BOTTOMRIGHT", 10, -5, 26, 26, "RIGHT", "BOTTOM", "default", "OVERLAY");
	-- listen to mouse events, mouse will be enabled during runtime if enabled in settings
	frame:EnableMouse(false);
	frame:SetScript("OnEnter", function(frame)
		GameTooltip:SetOwner(frame, "ANCHOR_BOTTOMRIGHT");
		-- update using data
		DHUDGUIManager:showSpellCircleTooltip(frame);
	end);
	frame:SetScript("OnLeave", function(frame)
		GameTooltip:Hide();
	end);
	return frame;
end

function DHUDGUI:createSpellCircleOverlayFrame(name)

end

--- Create spell rectangle frame near bottom text
-- @param name name of the frame
-- @param parentName name of the parent frame, this frame will be inserted to parent container (should be bottom textField)
-- @param relativePointThis relative point of frame to be used as attach point
-- @param relativePointParent relative point of parent frame to be used as attach point
-- @return frame created
function DHUDGUI:createSpellRectangleFrame(name, parentName, relativePointThis, relativePointParent)
	-- create frame
	frame = self:createFrame(name, parentName, relativePointThis, relativePointParent, 0, 0, 20, 20, nil, "Button");
	-- create border texture
	local texturePath = unpack(self.textures["BlizzardOverlayRectangleBorder"]);
	local texture = frame:CreateTexture(name .. "_border", "ARTWORK", nil, 7);
	texture:SetTexture(texturePath);
	texture:SetVertexColor(1.0, 1.0, 1.0);
	texture:SetPoint("CENTER", frame, "CENTER", 0, 0);
	texture:SetHeight(20);
	texture:SetWidth(20);
	texture:SetTexCoord(0, 1, 0, 1);
	frame.border = texture;
	-- set normal texture
	frame:SetNormalTexture("Interface\\Icons\\Ability_Druid_TravelForm");
	-- time left text
	local textField1 = self:createTextFontString(frame, "textFieldTime", "CENTER", "CENTER", 0, 0, 20 * 2, 20, "CENTER", "CENTER", "default", "OVERLAY");
	-- stack text
	local textField2 = self:createTextFontString(frame, "textFieldCount", "BOTTOMRIGHT", "BOTTOMRIGHT", 3, -3, 20, 20, "RIGHT", "BOTTOM", "default", "OVERLAY");
	-- listen to mouse events, mouse will be enabled during runtime if enabled in settings
	frame:EnableMouse(false);
	frame:SetScript("OnEnter", function(frame)
		GameTooltip:SetOwner(frame, "ANCHOR_BOTTOMRIGHT");
		-- update using data
		DHUDGUIManager:showSpellRectangleTooltip(frame);
	end);
	frame:SetScript("OnLeave", function(frame)
		GameTooltip:Hide();
	end);
	return frame;
end

--- Create combo point frame near bar
-- @param name name of the frame
-- @return frame created
function DHUDGUI:createComboPointFrame(name)
	-- create frame
	local frame = self:createTextureFrame(name, "DHUD_UIParent", "CENTER", "CENTER", 0, 0, 20, 20, "ComboCircleRed", false);
	return frame;
end

--- Create rune frame near bar
-- @param name name of the frame
-- @return frame created
function DHUDGUI:createRuneFrame(name)
	-- create frame
	local frame, texture = self:createTextureFrame(name, "DHUD_UIParent", "CENTER", "CENTER", 0, 0, 30, 30, "BlizzardDeathKnightRuneDeath", false);
	-- create text
	local textField1 = self:createTextFontString(frame, "textFieldTime", "CENTER", "CENTER", 0, 0, 30 * 2, 30, "CENTER", "CENTER", "default", "OVERLAY");
	return frame;
end

--- Create icon frame near frame specified
-- @param name name of the frame
-- @param parentName name of the parent frame, this frame will be inserted to parent container
-- @param relativePointThis relative point of frame to be used as attach point
-- @param relativePointParent relative point of parent frame to be used as attach point
-- @param offsetX horizontal offset from attach point
-- @param offsetY vertical offset from attach point
-- @param width width of the frame
-- @param height height of the frame
-- @param textureName name of the texture from local textures table
-- @return frame created
function DHUDGUI:createIconFrame(name, parentName, relativePointThis, relativePointParent, offsetX, offsetY, width, height, textureName)
	-- create frame
	local frame, texture = self:createTextureFrame(name, parentName, relativePointThis, relativePointParent, offsetX, offsetY, width, height, textureName);
	return frame;
end

--- Create drop down menu frame with parameters specified
-- @param name name of the frame, variable with this name will be created in global namespace, it will also be used in local dropdownMenus table
-- @param onInit function that will be invoked when drop down menu is invoked, this function should call UnitPopup_ShowMenu with correct arguments
-- @return created frame
function DHUDGUI:createDropDownMenu(name, onInit)
	local frame = CreateFrame("Frame", name, UIParent, "UIDropDownMenuTemplate");
	frame:Hide();
	frame:SetPoint("TOP", 0, 0);
	frame:SetWidth(160);
	frame:SetHeight(160);
	-- initialize dropdown only after showing frame to reduce tainting issues with blizzard code
	frame:SetScript("OnShow", function(frame)
		-- clear on show function
		frame:SetScript("OnShow", nil);
		-- initialize
		UIDropDownMenu_Initialize(frame, function(frame)
			onInit(frame);
		end, "MENU");
	end);
	-- save to table
	self.dropdownMenus[name] = frame;
	return frame;
end

--- Toggle dropdown menu specified, argument list is the same as blizzard one (do not use it manually, as it's not part of this class!)
function DHUDGUI.ToggleDropDownMenu(level, value, dropDownFrame, anchorName, xOffset, yOffset, menuList, button, autoHideDelay)
	dropDownFrame:Show();
	ToggleDropDownMenu(level, value, dropDownFrame, anchorName, xOffset, yOffset, menuList, button, autoHideDelay);
end

--- Initialize player dropdown list (do not use it manually, as it's not part of this class!)
-- @param frame reference to dropdown frame
function DHUDGUI.initDropDownMenuPlayer(frame)
	UnitPopup_ShowMenu(frame, "SELF", "player");
end

--- Initialize target dropdown list (do not use it manually, as it's not part of this class!)
-- @param frame reference to dropdown frame
function DHUDGUI.initDropDownMenuTarget(frame)
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

--- Set text to text field, updating text field width and it's frame (do not use it manually, as it's not part of this class!)
-- @param self reference to textField!
-- @param text text to set
function DHUDGUI.setTextToTextFrameAndUpdateWidth(self, text)
	-- set temprorary width to maximum
	self:SetWidth(1000);
	-- set text
	self.SetText(self, text); -- call super
	-- get real width
	local w = self:GetStringWidth();
	-- update
	self:SetWidth(w);
	if (self.frame.resizeWithTextField == true) then
		self.frame:SetWidth(w);
	end
end

--- Create group of frames and save it
-- @param groupName name of the group, it will be saved in local frameGroups table
-- @param ... list of frames in group
-- @return created frame group
function DHUDGUI:createFrameGroup(groupName, ...)
	-- save
	local group = { };
	self.frameGroups[groupName] = group;
	-- push
	self:pushFramesToGroup(group, ...);
	return group;
end

--- Push frames to group
-- @param group group, to which frames should be pushed
-- @param ... list of frames in group
function DHUDGUI:pushFramesToGroup(group, ...)
	-- get references instead of names
	local n = select("#", ...);
	for i = 1, n do
		table.insert(group, self.frames[select(i, ...)]);
	end
end

--- Create group that will fill itself automatically
-- @param groupName name of the group, it will be saved in local frameGroups table
-- @param createFrameFunction function, that will be invoked when frame doesn't exist
-- @param limit maximum number of frames to prevent situation when creating them has no point (e.g. don't need 9999 spell circles to be shown to player)
-- @param ... if not nil, than all created frames will also be pushed to groups specified
-- @return created frame group
function DHUDGUI:createDynamicFrameGroup(groupName, createFrameFunction, limit, ...)
	local group = { };
	local pushToGroups = { ... };
	-- add dynamic index function
	local dynamicIndexTable = { };
	dynamicIndexTable.__index = function(list, key)
		if (type(key) ~= "number") then
			return nil;
		end
		if (key > limit) then
			return group[limit];
		end
		local frame, onCreate = createFrameFunction(DHUDGUI, key);
		group[key] = frame;
		group.framesShown = key;
		-- check onCreate function
		if (onCreate ~= nil) then
			onCreate(DHUDGUI, frame);
		end
		-- notify group
		if (group.onDynamicFrameCreated ~= nil) then
			group.onDynamicFrameCreated(DHUDGUI, frame);
		end
		-- also add frame to another nondynamic group?
		if (#pushToGroups > 0) then
			for i, v in ipairs(pushToGroups) do
				table.insert(v, frame);
				-- notify group
				if (v.onDynamicFrameCreated ~= nil) then
					v.onDynamicFrameCreated(DHUDGUI, frame);
				end
			end
		end
		return frame;
	end
	setmetatable(group, dynamicIndexTable);
	-- add "set frames visible" function
	group.framesShown = 0;
	function group:setFramesShown(framesShown)
		if (self.framesShown == framesShown) then
			return;
		end
		-- show new frames
		for i = self.framesShown + 1, framesShown, 1 do
			self[i]:DShow();
		end
		-- hide old frames
		for i = self.framesShown, framesShown + 1, -1 do
			self[i]:DHide();
		end
		-- save var
		self.framesShown = framesShown;
	end
	-- save
	self.frameGroups[groupName] = group;
	return group;
end

--- Create group that will fill itself automatically, but frames are specific to index
-- @param groupName name of the group, it will be saved in local frameGroups table
-- @param createFrameFunction function, that will be invoked when frame doesn't exist
-- @param pushToGroupsMap if not nil, than all created frames will also be pushed to groups specified, this argument is a map with following format { index = { groupList }, index2 = { groupList2 } }
-- @return created frame group
function DHUDGUI:createDynamicFrameGroupWithCustomIndexes(groupName, createFrameFunction, pushToGroupsMap)
	local group = { };
	-- add dynamic index function
	local dynamicIndexTable = { };
	dynamicIndexTable.__index = function(list, key)
		if (type(key) ~= "number") then
			return nil;
		end
		local frame = createFrameFunction(DHUDGUI, key);
		group[key] = frame;
		-- notify group
		if (group.onDynamicFrameCreated ~= nil) then
			group.onDynamicFrameCreated(DHUDGUI, frame);
		end
		-- also add frame to another nondynamic group?
		if (pushToGroupsMap ~= nil) then
			local pushToGroups = pushToGroupsMap[key];
			if (pushToGroups ~= nil) then
				for i, v in ipairs(pushToGroups) do
					table.insert(v, frame);
					-- notify group
					if (v.onDynamicFrameCreated ~= nil) then
						v.onDynamicFrameCreated(DHUDGUI, frame);
					end
				end
			end
		end
		return frame;
	end
	setmetatable(group, dynamicIndexTable);
	-- save
	self.frameGroups[groupName] = group;
	return group;
end

--- Create left big inner bar
-- @param index index of frame
-- @return frame created
function DHUDGUI:createBarFrameBigInnerLeft(index)
	local relative = self.positions["leftBars"];
	local frame = self:createBarFrame("DHUD_Left_BarBig1_" .. index, relative[1], relative[2], relative[3], relative[4], relative[5], relative[6], relative[7], "TexturePrefixBarB1");
	return frame;
end

--- Create left big outer bar
-- @param index index of frame
-- @return frame created
function DHUDGUI:createBarFrameBigOuterLeft(index)
	local relative = self.positions["leftBars"];
	local frame = self:createBarFrame("DHUD_Left_BarBig2_" .. index, relative[1], relative[2], relative[3], relative[4], relative[5], relative[6], relative[7], "TexturePrefixBarB2");
	return frame;
end

--- Create left small inner bar
-- @param index index of frame
-- @return frame created
function DHUDGUI:createBarFrameSmallInnerLeft(index)
	local relative = self.positions["leftBars"];
	local frame = self:createBarFrame("DHUD_Left_BarSmall1_" .. index, relative[1], relative[2], relative[3], relative[4], relative[5], relative[6], relative[7], "TexturePrefixBarS1");
	return frame;
end

--- Create left small outer bar
-- @param index index of frame
-- @return frame created
function DHUDGUI:createBarFrameSmallOuterLeft(index)
	local relative = self.positions["leftBars"];
	local frame = self:createBarFrame("DHUD_Left_BarSmall2_" .. index, relative[1], relative[2], relative[3], relative[4], relative[5], relative[6], relative[7], "TexturePrefixBarS2");
	return frame;
end

--- Create right big inner bar
-- @param index index of frame
-- @return frame created
function DHUDGUI:createBarFrameBigInnerRight(index)
	local relative = self.positions["rightBars"];
	local frame = self:createBarFrame("DHUD_Right_BarBig1_" .. index, relative[1], relative[2], relative[3], relative[4], relative[5], relative[6], relative[7], "TexturePrefixBarB1", true);
	return frame;
end

--- Create right bit outer bar
-- @param index index of frame
-- @return frame created
function DHUDGUI:createBarFrameBigOuterRight(index)
	local relative = self.positions["rightBars"];
	local frame = self:createBarFrame("DHUD_Right_BarBig2_" .. index, relative[1], relative[2], relative[3], relative[4], relative[5], relative[6], relative[7], "TexturePrefixBarB2", true);
	return frame;
end

--- Create right small inner bar
-- @param index index of frame
-- @return frame created
function DHUDGUI:createBarFrameSmallInnerRight(index)
	local relative = self.positions["rightBars"];
	local frame = self:createBarFrame("DHUD_Right_BarSmall1_" .. index, relative[1], relative[2], relative[3], relative[4], relative[5], relative[6], relative[7], "TexturePrefixBarS1", true);
	return frame;
end

--- Create right small outer bar
-- @param index index of frame
-- @return frame created
function DHUDGUI:createBarFrameSmallOuterRight(index)
	local relative = self.positions["rightBars"];
	local frame = self:createBarFrame("DHUD_Right_BarSmall2_" .. index, relative[1], relative[2], relative[3], relative[4], relative[5], relative[6], relative[7], "TexturePrefixBarS2", true);
	return frame;
end

--- Create left big inner cast bar
-- @param index index of frame
-- @return frame created
function DHUDGUI:createCastBarFrameBigInnerLeft(index)
	local relative = self.positions["leftCastBars"];
	local frame;
	if (index == self.CASTBAR_GROUP_INDEX_CAST_INDICATION) then
		frame = self:createCastBarFrame("DHUD_Left_CastBarBig1", relative[1], relative[2], relative[3], relative[4], relative[5], relative[6], relative[7], "CastingBarB1");
	elseif (index == self.CASTBAR_GROUP_INDEX_FLASH) then
		frame = self:createCastBarFrame("DHUD_Left_CastBarFlashBig1", relative[1], relative[2], relative[3], relative[4], relative[5], relative[6], relative[7], "CastFlashBarB1");
	elseif (index == self.CASTBAR_GROUP_INDEX_ICON) then
		frame = self:createCastBarIconFrame("DHUD_Left_CastBarIconBig1", "DHUD_Left_BarsBackground", "BOTTOM", "BOTTOM", 60, 275, 30, 30);
	elseif (index == self.CASTBAR_GROUP_INDEX_SPELLNAME) then
		frame = self:createTextFrame("DHUD_Left_CastBarSpellTextBig1", "DHUD_Left_BarsBackground", "LEFT", "BOTTOM", 79, 290, nil, 14, "LEFT", "CENTER");
	elseif (index == self.CASTBAR_GROUP_INDEX_CASTTIME) then
		frame = self:createTextFrame("DHUD_Left_CastBarTimeTextBig1", "DHUD_Left_BarsBackground", "LEFT", "BOTTOM", 30, 252, 100, 14, "LEFT", "CENTER");
	elseif (index == self.CASTBAR_GROUP_INDEX_DELAY) then
		frame = self:createTextFrame("DHUD_Left_CastBarDelayTextBig1", "DHUD_Left_BarsBackground", "LEFT", "BOTTOM", 30, 266, 100, 14, "LEFT", "CENTER");
	elseif (index >= self.CASTBAR_GROUP_INDEX_EMPOWER1) then
		frame = self:createCastBarFrame("DHUD_Left_CastBarEmpower1_" .. (index - self.CASTBAR_GROUP_INDEX_EMPOWER1 + 1), relative[1], relative[2], relative[3], relative[4], relative[5], relative[6], relative[7], "CastFillBarB1");
	end
	return frame;
end

--- Create left big outer cast bar
-- @param index index of frame
-- @return frame created
function DHUDGUI:createCastBarFrameBigOuterLeft(index)
	local relative = self.positions["leftCastBars"];
	local frame;
	if (index == self.CASTBAR_GROUP_INDEX_CAST_INDICATION) then
		frame = self:createCastBarFrame("DHUD_Left_CastBarBig2", relative[1], relative[2], relative[3], relative[4], relative[5], relative[6], relative[7], "CastingBarB2");
	elseif (index == self.CASTBAR_GROUP_INDEX_FLASH) then
		frame = self:createCastBarFrame("DHUD_Left_CastBarFlashBig2", relative[1], relative[2], relative[3], relative[4], relative[5], relative[6], relative[7], "CastFlashBarB2");
	elseif (index == self.CASTBAR_GROUP_INDEX_ICON) then
		frame = self:createCastBarIconFrame("DHUD_Left_CastBarIconBig2", "DHUD_Left_BarsBackground", "BOTTOM", "BOTTOM", 25, 285, 30, 30);
	elseif (index == self.CASTBAR_GROUP_INDEX_SPELLNAME) then
		frame = self:createTextFrame("DHUD_Left_CastBarSpellTextBig2", "DHUD_Left_BarsBackground", "RIGHT", "BOTTOM", 5, 300, nil, 14, "RIGHT", "CENTER");
	elseif (index == self.CASTBAR_GROUP_INDEX_CASTTIME) then
		frame = self:createTextFrame("DHUD_Left_CastBarTimeTextBig2", "DHUD_Left_BarsBackground", "RIGHT", "BOTTOM", 25, 262, 100, 14, "RIGHT", "CENTER");
	elseif (index == self.CASTBAR_GROUP_INDEX_DELAY) then
		frame = self:createTextFrame("DHUD_Left_CastBarDelayTextBig2", "DHUD_Left_BarsBackground", "RIGHT", "BOTTOM", 25, 276, 100, 14, "RIGHT", "CENTER");
	elseif (index >= self.CASTBAR_GROUP_INDEX_EMPOWER1) then
		frame = self:createCastBarFrame("DHUD_Left_CastBarEmpower2_" .. (index - self.CASTBAR_GROUP_INDEX_EMPOWER1 + 1), relative[1], relative[2], relative[3], relative[4], relative[5], relative[6], relative[7], "CastFillBarB2");
	end
	return frame;
end

--- Create right big inner cast bar
-- @param index index of frame
-- @return frame created
function DHUDGUI:createCastBarFrameBigInnerRight(index)
	local relative = self.positions["rightCastBars"];
	local frame;
	if (index == self.CASTBAR_GROUP_INDEX_CAST_INDICATION) then
		frame = self:createCastBarFrame("DHUD_Right_CastBarBig1", relative[1], relative[2], relative[3], relative[4], relative[5], relative[6], relative[7], "CastingBarB1", true);
	elseif (index == self.CASTBAR_GROUP_INDEX_FLASH) then
		frame = self:createCastBarFrame("DHUD_Right_CastBarFlashBig1", relative[1], relative[2], relative[3], relative[4], relative[5], relative[6], relative[7], "CastFlashBarB1", true);
	elseif (index == self.CASTBAR_GROUP_INDEX_ICON) then
		frame = self:createCastBarIconFrame("DHUD_Right_CastBarIconBig1", "DHUD_Right_BarsBackground", "BOTTOM", "BOTTOM", -60, 275, 30, 30);
	elseif (index == self.CASTBAR_GROUP_INDEX_SPELLNAME) then
		frame = self:createTextFrame("DHUD_Right_CastBarSpellTextBig1", "DHUD_Right_BarsBackground", "RIGHT", "BOTTOM", -79, 290, nil, 14, "RIGHT", "CENTER");
	elseif (index == self.CASTBAR_GROUP_INDEX_CASTTIME) then
		frame = self:createTextFrame("DHUD_Right_CastBarTimeTextBig1", "DHUD_Right_BarsBackground", "RIGHT", "BOTTOM", -30, 252, 100, 14, "RIGHT", "CENTER");
	elseif (index == self.CASTBAR_GROUP_INDEX_DELAY) then
		frame = self:createTextFrame("DHUD_Right_CastBarDelayTextBig1", "DHUD_Right_BarsBackground", "RIGHT", "BOTTOM", -30, 266, 100, 14, "RIGHT", "CENTER");
	elseif (index >= self.CASTBAR_GROUP_INDEX_EMPOWER1) then
		frame = self:createCastBarFrame("DHUD_Right_CastBarEmpower1_" .. (index - self.CASTBAR_GROUP_INDEX_EMPOWER1 + 1), relative[1], relative[2], relative[3], relative[4], relative[5], relative[6], relative[7], "CastFillBarB1", true);
	end
	return frame;
end

--- Create right big outer cast bar
-- @param index index of frame
-- @return frame created
function DHUDGUI:createCastBarFrameBigOuterRight(index)
	local relative = self.positions["rightCastBars"];
	local frame;
	if (index == self.CASTBAR_GROUP_INDEX_CAST_INDICATION) then
		frame = self:createCastBarFrame("DHUD_Right_CastBarBig2", relative[1], relative[2], relative[3], relative[4], relative[5], relative[6], relative[7], "CastingBarB2", true);
	elseif (index == self.CASTBAR_GROUP_INDEX_FLASH) then
		frame = self:createCastBarFrame("DHUD_Right_CastBarFlashBig2", relative[1], relative[2], relative[3], relative[4], relative[5], relative[6], relative[7], "CastFlashBarB2", true);
	elseif (index == self.CASTBAR_GROUP_INDEX_ICON) then
		frame = self:createCastBarIconFrame("DHUD_Right_CastBarIconBig2", "DHUD_Right_BarsBackground", "BOTTOM", "BOTTOM", -25, 285, 30, 30);
	elseif (index == self.CASTBAR_GROUP_INDEX_SPELLNAME) then
		frame = self:createTextFrame("DHUD_Right_CastBarSpellTextBig2", "DHUD_Right_BarsBackground", "LEFT", "BOTTOM", -5, 300, nil, 14, "LEFT", "CENTER");
	elseif (index == self.CASTBAR_GROUP_INDEX_CASTTIME) then
		frame = self:createTextFrame("DHUD_Right_CastBarTimeTextBig2", "DHUD_Right_BarsBackground", "LEFT", "BOTTOM", -25, 262, 100, 14, "LEFT", "CENTER");
	elseif (index == self.CASTBAR_GROUP_INDEX_DELAY) then
		frame = self:createTextFrame("DHUD_Right_CastBarDelayTextBig2", "DHUD_Right_BarsBackground", "LEFT", "BOTTOM", -25, 276, 100, 14, "LEFT", "CENTER");
	elseif (index >= self.CASTBAR_GROUP_INDEX_EMPOWER1) then
		frame = self:createCastBarFrame("DHUD_Right_CastBarEmpower2_" .. (index - self.CASTBAR_GROUP_INDEX_EMPOWER1 + 1), relative[1], relative[2], relative[3], relative[4], relative[5], relative[6], relative[7], "CastFillBarB2", true);
	end
	return frame;
end

--- Helper function to reduce amount of code for reposition functions
-- @param group group to reposition
-- @param frame frame to reposition if any
function DHUDGUI:repositionProcessParams(group, frame)
	local indexBegin = 1;
	local indexEnd = #group;
	if (frame ~= nil) then
		indexBegin = MCLastIndexOfValueInTable(group, frame);
		indexEnd = indexBegin;
	end
	return group, indexBegin, indexEnd;
end

--- Create unit icon near unit info text
-- @param index index of frame
-- @return frame created
function DHUDGUI:createTargetUnitInfoIconCenter(index)
	local frame = self:createIconFrame("DHUD_Icon_TargetUnitIcon" .. index, "DHUD_Center_TextInfo1", "BOTTOM", "TOP", 0, 0, 25, 25, "BlizzardRaidIcon1");
	return frame, self.repositionUnitInfoIconCenter;
end

--- Reposition unit icon near unit info text
-- @param frame reference to frame that should be repositioned, otherwise all elements are repositioned
function DHUDGUI:repositionTargetUnitInfoIconCenter(frame)
	local group = self.frameGroups.targetIcons;
	self:distributeRectangleFramesAlongWidth(group, 1,  group.framesShown, 25, 1, 0, "DHUD_Center_TextInfo1", "BOTTOM", "TOP");
end

--- Reposition unit icon near unit info text
-- @param frame reference to frame that should be repositioned, otherwise all elements are repositioned
function DHUDGUI:repositionTargetUnitInfoStateIcons(frame)
	if (position == "CENTER") then
		group.reposition = self.repositionTargetUnitInfoIconCenter();
		group.reposition(DHUDGUI);
	end
end

--- Reposition self pvp status icon near bar
-- @param position string with required position id (either "LEFT" or "RIGHT")
function DHUDGUI:repositionSelfUnitPvPIcon(position)
	local frame = self.frames["DHUD_Icon_SelfUnitIconPvP"];
	if (position == "LEFT") then
		frame:SetPoint("TOP", "DHUD_Left_BarsBackground", "TOP", 50, -15);
	elseif (position == "RIGHT") then
		frame:SetPoint("TOP", "DHUD_Right_BarsBackground", "TOP", -50, -15);
	end
end

--- Reposition self pvp status icon near bar
-- @param position string with required position id (either "LEFT" or "RIGHT")
function DHUDGUI:repositionSelfUnitStateIcon(position)
	local frame = self.frames["DHUD_Icon_SelfUnitIconState"];
	if (position == "LEFT") then
		frame:SetPoint("TOP", "DHUD_Left_BarsBackground", "TOP", 42, 12);
	elseif (position == "RIGHT") then
		frame:SetPoint("TOP", "DHUD_Right_BarsBackground", "TOP", -42, 12);
	end
end

--- Reposition self pvp status icon near bar
-- @param position string with required position id (either "LEFT" or "RIGHT")
function DHUDGUI:repositionTargetUnitEliteIcon(position)
	local frame = self.frames["DHUD_Icon_TargetEliteDragon"];
	if (position == "LEFT") then
		frame:SetPoint("TOP", "DHUD_Left_BarsBackground", "TOP", 18, 20);
		frame.texture:SetTexCoord(0, 1, 0, 1);
	elseif (position == "RIGHT") then
		frame:SetPoint("TOP", "DHUD_Right_BarsBackground", "TOP", -18, 20);
		frame.texture:SetTexCoord(1, 0, 0, 1);
	end
end

--- Create spell circle near left big bar
-- @param index index of frame
-- @return frame created
function DHUDGUI:createSpellCircleFrameBigLeft(index)
	local frame = self:createSpellCircleFrame("DHUD_Left_SpellCircleBig" .. index);
	return frame, self.repositionSpellCircleFramesBigLeft;
end

--- Reposition spell circles around left big bar
-- @param frame reference to frame that should be repositioned, otherwise all elements are repositioned
function DHUDGUI:repositionSpellCircleFramesBigLeft(frame)
	local group, indexBegin, indexEnd = self:repositionProcessParams(self.frameGroups.spellCirclesBigLeft, frame);
	self:repositionCircleFramesAroundHud(group, indexBegin, indexEnd, 16, self.scale[self.SCALE_SPELL_CIRCLES], DHUDEllipseMath.HUD_BAR_WIDTH + 2, 0, true);
end

--- Create spell circle near right big bar
-- @param index index of frame
-- @return frame created
function DHUDGUI:createSpellCircleFrameBigRight(index)
	local frame = self:createSpellCircleFrame("DHUD_Right_SpellCircleBig" .. index);
	return frame, self.repositionSpellCircleFramesBigRight;
end

--- Reposition spell circles around right big bar
-- @param frame reference to frame that should be repositioned, otherwise all elements are repositioned
function DHUDGUI:repositionSpellCircleFramesBigRight(frame)
	local group, indexBegin, indexEnd = self:repositionProcessParams(self.frameGroups.spellCirclesBigRight, frame);
	self:repositionCircleFramesAroundHud(group, indexBegin, indexEnd, 16, self.scale[self.SCALE_SPELL_CIRCLES], DHUDEllipseMath.HUD_BAR_WIDTH + 2, 0, false);
end

--- Create spell circle near left big bar
-- @param index index of frame
-- @return frame created
function DHUDGUI:createSpellCircleFrameSmallLeft(index)
	local frame = self:createSpellCircleFrame("DHUD_Left_SpellCircleSmall" .. index);
	return frame, self.repositionSpellCircleFramesSmallLeft;
end

--- Reposition spell circles around left small bar
-- @param frame reference to frame that should be repositioned, otherwise all elements are repositioned
function DHUDGUI:repositionSpellCircleFramesSmallLeft(frame)
	local group, indexBegin, indexEnd = self:repositionProcessParams(self.frameGroups.spellCirclesSmallLeft, frame);
	local hasSmallBar = bit.band(self.backgroundLeft, self.BACKGROUND_BAR_SMALL1) ~= 0;
	self:repositionCircleFramesAroundHud(group, indexBegin, indexEnd, 16, self.scale[self.SCALE_SPELL_CIRCLES], -2, -DHUDEllipseMath.HUD_BAR_WIDTH - DHUDEllipseMath.HUD_SMALLBAR_WIDTH - (hasSmallBar and 3 or 0), true);
end

--- Create spell circle near right small bar
-- @param index index of frame
-- @return frame created
function DHUDGUI:createSpellCircleFrameSmallRight(index)
	local frame = self:createSpellCircleFrame("DHUD_Right_SpellCircleSmall" .. index);
	return frame, self.repositionSpellCircleFramesSmallRight;
end

--- Reposition spell circles around right small bar
-- @param frame reference to frame that should be repositioned, otherwise all elements are repositioned
function DHUDGUI:repositionSpellCircleFramesSmallRight(frame)
	local group, indexBegin, indexEnd = self:repositionProcessParams(self.frameGroups.spellCirclesSmallRight, frame);
	local hasSmallBar = bit.band(self.backgroundRight, self.BACKGROUND_BAR_SMALL1) ~= 0;
	self:repositionCircleFramesAroundHud(group, indexBegin, indexEnd, 16, self.scale[self.SCALE_SPELL_CIRCLES], -2, -DHUDEllipseMath.HUD_BAR_WIDTH - DHUDEllipseMath.HUD_SMALLBAR_WIDTH - (hasSmallBar and 3 or 0), false);
end

--- Create left spell rectangle near bottom text
-- @param index index of frame
-- @return frame created
function DHUDGUI:createSpellRectangleFrameLeft(index)
	local frame = self:createSpellRectangleFrame("DHUD_Left_SpellRectangle" .. index, "DHUD_Center_TextInfo1", "TOPRIGHT", "TOPLEFT");
	return frame, self.repositionSpellRectangleFramesLeft;
end

--- Reposition left spell rectangles around bottom text
-- @param frame reference to frame that should be repositioned, otherwise all elements are repositioned
function DHUDGUI:repositionSpellRectangleFramesLeft(frame)
	local group, indexBegin, indexEnd = self:repositionProcessParams(self.frameGroups.spellRectanglesLeft, frame);
	self:repositionRectangleFramesAroundFrame(group, indexBegin, indexEnd, 20, 20, self.scale[self.SCALE_SPELL_RECTANGLES], 8, 1, 10, true, "DHUD_Center_TextInfo1", "TOPRIGHT", "TOPLEFT");
end

--- Create left spell rectangle near bottom text
-- @param index index of frame
-- @return frame created
function DHUDGUI:createSpellRectangleFrameRight(index)
	local frame = self:createSpellRectangleFrame("DHUD_Right_SpellRectangle" .. index, "DHUD_Center_TextInfo1", "TOPLEFT", "TOPRIGHT");
	return frame, self.repositionSpellRectangleFramesRight;
end

--- Reposition left spell rectangles around bottom text
-- @param frame reference to frame that should be repositioned, otherwise all elements are repositioned
function DHUDGUI:repositionSpellRectangleFramesRight(frame)
	local group, indexBegin, indexEnd = self:repositionProcessParams(self.frameGroups.spellRectanglesRight, frame);
	self:repositionRectangleFramesAroundFrame(group, indexBegin, indexEnd, 20, 20, self.scale[self.SCALE_SPELL_RECTANGLES], 8, 1, 5, false, "DHUD_Center_TextInfo1", "TOPLEFT", "TOPRIGHT");
end

--- Create combo point frame near left big bar
-- @param index index of frame
-- @return frame created
function DHUDGUI:createComboPointFrameBigLeft(index)
	local frame = self:createComboPointFrame("DHUD_Left_ComboPointBig" .. index);
	return frame, self.repositionComboPointFramesBigLeft;
end

--- Create combo point frame near left big bar
-- @param index index of frame
-- @return frame created
function DHUDGUI:repositionComboPointFramesBigLeft(frame)
	local group, indexBegin, indexEnd = self:repositionProcessParams(self.frameGroups.comboPointsBigLeft, frame);
	self:repositionCircleFramesAroundHud(group, indexBegin, indexEnd, 10, self.scale[self.SCALE_RESOURCES], DHUDEllipseMath.HUD_BAR_WIDTH + 2, 0, true, 0);
end

--- Create combo point frame near right big bar
-- @param index index of frame
-- @return frame created
function DHUDGUI:createComboPointFrameBigRight(index)
	local frame = self:createComboPointFrame("DHUD_Right_ComboPointBig" .. index);
	return frame, self.repositionComboPointFramesBigRight;
end

--- Create combo point frame right left big bar
-- @param index index of frame
-- @return frame created
function DHUDGUI:repositionComboPointFramesBigRight(frame)
	local group, indexBegin, indexEnd = self:repositionProcessParams(self.frameGroups.comboPointsBigRight, frame);
	self:repositionCircleFramesAroundHud(group, indexBegin, indexEnd, 10, self.scale[self.SCALE_RESOURCES], DHUDEllipseMath.HUD_BAR_WIDTH + 2, 0, false, 0);
end

--- Create combo point frame near left small bar
-- @param index index of frame
-- @return frame created
function DHUDGUI:createComboPointFrameSmallLeft(index)
	local frame = self:createComboPointFrame("DHUD_Left_ComboPointSmall" .. index);
	return frame, self.repositionComboPointFramesSmallLeft;
end

--- Create combo point frame near left small bar
-- @param index index of frame
-- @return frame created
function DHUDGUI:repositionComboPointFramesSmallLeft(frame)
	local group, indexBegin, indexEnd = self:repositionProcessParams(self.frameGroups.comboPointsSmallLeft, frame);
	local hasSmallBar = bit.band(self.backgroundLeft, self.BACKGROUND_BAR_SMALL1) ~= 0;
	self:repositionCircleFramesAroundHud(group, indexBegin, indexEnd, 10, self.scale[self.SCALE_RESOURCES], -2, -DHUDEllipseMath.HUD_BAR_WIDTH - DHUDEllipseMath.HUD_SMALLBAR_WIDTH, true, 0);
end

--- Create combo point frame near right small bar
-- @param index index of frame
-- @return frame created
function DHUDGUI:createComboPointFrameSmallRight(index)
	local frame = self:createComboPointFrame("DHUD_Right_ComboPointSmall" .. index);
	return frame, self.repositionComboPointFramesSmallRight;
end

--- Create combo point frame near right small bar
-- @param index index of frame
-- @return frame created
function DHUDGUI:repositionComboPointFramesSmallRight(frame)
	local group, indexBegin, indexEnd = self:repositionProcessParams(self.frameGroups.comboPointsSmallRight, frame);
	local hasSmallBar = bit.band(self.backgroundRight, self.BACKGROUND_BAR_SMALL1) ~= 0;
	self:repositionCircleFramesAroundHud(group, indexBegin, indexEnd, 10, self.scale[self.SCALE_RESOURCES], -2, -DHUDEllipseMath.HUD_BAR_WIDTH - DHUDEllipseMath.HUD_SMALLBAR_WIDTH, false, 0);
end

--- Create rune frame near left big bar
-- @param index index of frame
-- @return frame created
function DHUDGUI:createRuneFrameBigLeft(index)
	local frame = self:createRuneFrame("DHUD_Left_RuneBig" .. index);
	return frame, self.repositionRuneFramesBigLeft;
end

--- Create rune frame near left big bar
-- @param index index of frame
-- @return frame created
function DHUDGUI:repositionRuneFramesBigLeft(frame)
	local group, indexBegin, indexEnd = self:repositionProcessParams(self.frameGroups.runesBigLeft, frame);
	self:repositionCircleFramesAroundHud(group, indexBegin, indexEnd, 15, self.scale[self.SCALE_RESOURCES], DHUDEllipseMath.HUD_BAR_WIDTH + 2, 0, true, 0);
end

--- Create rune frame near right big bar
-- @param index index of frame
-- @return frame created
function DHUDGUI:createRuneFrameBigRight(index)
	local frame = self:createRuneFrame("DHUD_Right_RuneBig" .. index);
	return frame, self.repositionRuneFramesBigRight;
end

--- Create rune frame near right big bar
-- @param index index of frame
-- @return frame created
function DHUDGUI:repositionRuneFramesBigRight(frame)
	local group, indexBegin, indexEnd = self:repositionProcessParams(self.frameGroups.runesBigRight, frame);
	self:repositionCircleFramesAroundHud(group, indexBegin, indexEnd, 15, self.scale[self.SCALE_RESOURCES], DHUDEllipseMath.HUD_BAR_WIDTH + 2, 0, false, 0);
end

--- Create rune frame near left small bar
-- @param index index of frame
-- @return frame created
function DHUDGUI:createRuneFrameSmallLeft(index)
	local frame = self:createRuneFrame("DHUD_Left_RuneSmall" .. index);
	return frame, self.repositionRuneFramesSmallLeft;
end

--- Create rune frame near left small bar
-- @param index index of frame
-- @return frame created
function DHUDGUI:repositionRuneFramesSmallLeft(frame)
	local group, indexBegin, indexEnd = self:repositionProcessParams(self.frameGroups.runesSmallLeft, frame);
	local hasSmallBar = bit.band(self.backgroundLeft, self.BACKGROUND_BAR_SMALL1) ~= 0;
	self:repositionCircleFramesAroundHud(group, indexBegin, indexEnd, 15, self.scale[self.SCALE_RESOURCES], -2, -DHUDEllipseMath.HUD_BAR_WIDTH - DHUDEllipseMath.HUD_SMALLBAR_WIDTH, true, 0);
end

--- Create rune frame near right small bar
-- @param index index of frame
-- @return frame created
function DHUDGUI:createRuneFrameSmallRight(index)
	local frame = self:createRuneFrame("DHUD_Right_RuneSmall" .. index);
	return frame, self.repositionRuneFramesSmallRight;
end

--- Create rune frame near right small bar
-- @param index index of frame
-- @return frame created
function DHUDGUI:repositionRuneFramesSmallRight(frame)
	local group, indexBegin, indexEnd = self:repositionProcessParams(self.frameGroups.runesSmallRight, frame);
	local hasSmallBar = bit.band(self.backgroundRight, self.BACKGROUND_BAR_SMALL1) ~= 0;
	self:repositionCircleFramesAroundHud(group, indexBegin, indexEnd, 15, self.scale[self.SCALE_RESOURCES], -2, -DHUDEllipseMath.HUD_BAR_WIDTH - DHUDEllipseMath.HUD_SMALLBAR_WIDTH, false, 0);
end

--- Reposition spell circles around all bars
function DHUDGUI:repositionSpellCircleFramesAll()
	self:repositionSpellCircleFramesBigLeft();
	self:repositionSpellCircleFramesSmallLeft();
	self:repositionSpellCircleFramesBigRight();
	self:repositionSpellCircleFramesSmallRight();
end

--- Reposition spell rectangles around all bars
function DHUDGUI:repositionSpellRectangeFramesAll()
	self:repositionSpellRectangleFramesLeft();
	self:repositionSpellRectangleFramesRight();
end

--- Reposition resources around all bars
function DHUDGUI:repositionResourceFramesAll()
	self:repositionComboPointFramesAll();
	self:repositionRuneFramesAll();
end

--- Reposition all circle frames around all bars
function DHUDGUI:repositionCircleFramesAll()
	self:repositionResourceFramesAll();
	self:repositionSpellCircleFramesAll();
end

--- Reposition combo points around all bars
function DHUDGUI:repositionComboPointFramesAll()
	self:repositionComboPointFramesBigLeft();
	self:repositionComboPointFramesBigRight();
	self:repositionComboPointFramesSmallLeft();
	self:repositionComboPointFramesSmallRight();
end

--- Reposition runes around all bars
function DHUDGUI:repositionRuneFramesAll()
	self:repositionRuneFramesBigLeft();
	self:repositionRuneFramesBigRight();
	self:repositionRuneFramesSmallLeft();
	self:repositionRuneFramesSmallRight();
end

--- Reposition circle frames around left small bar
function DHUDGUI:repositionCircleFramesSmallLeft()
	self:repositionSpellCircleFramesSmallLeft();
	self:repositionComboPointFramesSmallLeft();
	self:repositionRuneFramesSmallLeft();
end

--- Reposition circle frames around left small bar
function DHUDGUI:repositionCircleFramesSmallRight()
	self:repositionSpellCircleFramesSmallRight();
	self:repositionComboPointFramesSmallRight();
	self:repositionRuneFramesSmallRight();
end

--- Reposition circle frames around bar
-- @param group group group with frames to reposition
-- @param indexBegin index of first frame in group to reposition
-- @param indexEnd index of last frame in group to reposition
-- @param elementRadius radius of circle frame
-- @param scale scale of the frame, required to place at correct position as wow changes position of the frame with scale
-- @param baseOffset offset of first circles from HUD base ellipse (this offset will be used to calculate numFit and arcHeight vars)
-- @param additionalOffset additional offset of first circles from HUD base ellipse
-- @param mirrorPosition mirror position acros y-axis?
-- @param angleOffset if not nil then first frame will be position angle will be offset by amount specified
function DHUDGUI:repositionCircleFramesAroundHud(group, indexBegin, indexEnd, elementRadius, scale, baseOffset, additionalOffset, mirrorPosition, angleOffset)
	-- noting to do
	if (indexEnd < 1) then
		return;
	end
	local angleDistributeSpace = (angleOffset == nil);
	angleOffset = angleOffset or 0;
	local mirrorSign = mirrorPosition and -1 or 1;
	-- calculate offset sign
	local offsetSign = 1;
	if (baseOffset < 0) then
		offsetSign = -1;
	end
	-- recalc size
	elementRadius = elementRadius * scale;
	-- calculate position
	local x, y;
	local framesOffsetX = self.barsDistanceDiv2;
	local angle;
	DHUDEllipseMath:setDefaultEllipse();
	DHUDEllipseMath:adjustRadiusX(baseOffset + (elementRadius) * offsetSign);
	local numFit = DHUDEllipseMath:calculateNumElementsFit(elementRadius);
	local arcHeight = DHUDEllipseMath:calculateArcHeight();
	DHUDEllipseMath:adjustRadiusX(additionalOffset);
	local offset = elementRadius * 2 * offsetSign;
	local angleBegin;
	local angleStep;
	local numFitted = 0;
	local index = indexBegin;
	-- check if we can fit atleast one element
	if (numFit <= 0) then
		return; -- no point to continue
	end
	-- iterate
	while (true) do
		numFitted = numFitted + numFit;
		-- counted until index begin?
		if (numFitted >= index) then
			angleStep = DHUDEllipseMath:calculateAngleStep(elementRadius);
			angleBegin = DHUDEllipseMath:calculateAngleBegin(elementRadius, arcHeight, angleDistributeSpace) + angleOffset;
			while (true) do
				-- calculate angle for index
				angle = angleBegin + angleStep * (index - (numFitted - numFit) - 0.5); -- -1 since index start from 0; +0.5 for half of the radius of first element
				x, y = DHUDEllipseMath:calculatePositionInAddonCoordinates(angle);
				x = x + framesOffsetX;
				-- set position
				--print("frame " .. index .. " angle " .. angle .. " set to " .. MCTableToString(x) .. ", " .. MCTableToString(y));
				group[index].circlePositionX = mirrorSign * x;
				group[index].circlePositionY = y;
				group[index]:SetPoint("CENTER", "DHUD_UIParent", "CENTER", mirrorSign * x / scale, y / scale);
				-- increase index
				index = index + 1;
				-- check for iteration end
				if (index > indexEnd) then
					return;
				elseif (index > numFitted) then
					break;
				end
			end
		end
		-- adjust radius
		DHUDEllipseMath:adjustRadiusX(offset);
	end
end

--- Reposition rectangle frames around frame specified
-- @param group group group with frames to reposition
-- @param indexBegin index of first frame in group to reposition
-- @param indexEnd index of last frame in group to reposition
-- @param elementWidth width of rectangle frames
-- @param elementHeight height of rectangle frames
-- @param scale scale of the frame, required to place at correct position as wow changes position of the frame with scale
-- @param numFitWidth number of frames to be fit in width
-- @param offset offset between elements (space)
-- @param offsetFirstX offset for first frame, x - axis
-- @param toTheLeft position frames to the left?
-- @param parentName name of the parent frame, this frame will be inserted to parent container (should be bottom textField)
-- @param relativePointThis relative point of frame to be used as attach point
-- @param relativePointParent relative point of parent frame to be used as attach point
function DHUDGUI:repositionRectangleFramesAroundFrame(group, indexBegin, indexEnd, elementWidth, elementHeight, scale, numFitWidth, offset, offsetFirstX, toTheLeft, parentName, relativePointThis, relativePointParent)
	-- noting to do
	if (indexEnd < 1) then
		return;
	end
	local positionSign = toTheLeft and -1 or 1;
	-- recalc size
	elementWidth = elementWidth * scale;
	elementHeight = elementHeight * scale;
	-- calculate position
	local x, y;
	local numFitted = 0;
	local index = indexBegin;
	local iterationX = 0;
	local iterationY = 0;
	-- check if we can fit atleast one element
	if (numFitWidth <= 0) then
		return; -- no point to continue
	end
	-- iterate
	while (true) do
		numFitted = numFitted + numFitWidth;
		-- counted until index begin?
		if (numFitted >= index) then
			while (true) do
				-- calculate position
				iterationX = index - (numFitted - numFitWidth) - 1;
				x = (offsetFirstX + (offset + elementWidth) * iterationX);
				y = -(elementWidth + offset) * iterationY;
				-- set position
				--print("frame " .. index .. " angle " .. angle .. " set to " .. x .. ", " .. y);
				group[index]:SetPoint(relativePointThis, parentName, relativePointParent, positionSign * x / scale, y / scale);
				-- increase index
				index = index + 1;
				-- check for iteration end
				if (index > indexEnd) then
					return;
				elseif (index > numFitted) then
					break;
				end
			end
		end
		-- adjust y
		iterationY = iterationY + 1;
	end
end

--- Distribute rectangle frames along target width
-- @param group group group with frames to reposition
-- @param indexBegin index of first frame in group to reposition
-- @param indexEnd index of last frame in group to reposition
-- @param elementWidth width of rectangle frames
-- @param offset offset between elements (space)
-- @param offsetFirstY offset for first frame, y - axis
-- @param parentName name of the parent frame, this frame will be inserted to parent container (should be bottom textField)
-- @param relativePointThis relative point of frame to be used as attach point
-- @param relativePointParent relative point of parent frame to be used as attach point
function DHUDGUI:distributeRectangleFramesAlongWidth(group, indexBegin, indexEnd, elementWidth, offset, offsetFirstY, parentName, relativePointThis, relativePointParent)
	-- noting to do
	if (indexEnd < 1) then
		return;
	end
	-- calculate position
	local x;
	local y = offsetFirstY;
	local numFrames = indexEnd - indexBegin + 1;
	local targetWidth = numFrames * elementWidth + (numFrames - 1) * offset;
	local xBegin = -targetWidth / 2 + elementWidth / 2; -- added element width since relative point is center
	local index;
	-- check if we can fit atleast one element
	if (numFrames <= 0) then
		return; -- no point to continue
	end
	-- iterate
	for i = indexBegin, indexEnd, 1 do
		-- calculate position
		index = i - indexBegin;
		x = xBegin + (elementWidth + offset) * index;
		-- set position
		--print("frame " .. index .. " set to " .. x .. ", " .. y);
		group[i]:SetPoint(relativePointThis, parentName, relativePointParent, x, y);
	end
end

--- Change texture of all bars to texture specified
-- @param textureId id of the new texture (from 1 to 5, bounds are set by DHUDSettings class)
function DHUDGUI:changeBarsTextures(textureId)
	if (self.barsTexture == textureId) then
		return;
	end
	self.barsTexture = textureId;
	local texture;
	for i, v in pairs(self.frameGroups.bars) do
		texture = v.texture;
		texture:SetTexture(texture.pathPrefix .. textureId);
	end
end

--- process texture mask to texture name
-- @param mask mask to process
-- @return name of the texture
function DHUDGUI:processBackgroundBarsMaskToTextureName(mask)
	if (bit.band(mask, self.BACKGROUND_BAR_BIG2) ~= 0) then
		if (bit.band(mask, self.BACKGROUND_BAR_SMALL2) ~= 0) then
			return "BackgroundBars2B2S";
		end
		if (bit.band(mask, self.BACKGROUND_BAR_SMALL1) ~= 0) then
			return "BackgroundBars2B1SI";
		end
		if (bit.band(mask, self.BACKGROUND_BAR_BIG1) ~= 0) then
			return "BackgroundBars2B0S";
		end
		return "BackgroundBars1BO0S";
	elseif (bit.band(mask, self.BACKGROUND_BAR_BIG1) ~= 0) then
		if (bit.band(mask, self.BACKGROUND_BAR_SMALL2) ~= 0) then
			return "BackgroundBars2B2S";
		end
		if (bit.band(mask, self.BACKGROUND_BAR_SMALL1) ~= 0) then
			return "BackgroundBars1BI1SI";
		end
		return "BackgroundBars1BI0S";
	elseif (bit.band(mask, self.BACKGROUND_BAR_SMALL1) ~= 0) then
		if (bit.band(mask, self.BACKGROUND_BAR_SMALL2) ~= 0) then
			return "BackgroundBars2B2S";
		end
		return "BackgroundBars1BI1SI";
	elseif (bit.band(mask, self.BACKGROUND_BAR_SMALL2) ~= 0) then
		return "BackgroundBars2B2S";
	end
	return "BackgroundBars0B0S";
end

--- Change background textures to be shown only under bars specified by mask
-- @param leftBarsMask mask of bars that should be shown on the left
-- @param rightBarsMask mask of bars that should be shown on the right
function DHUDGUI:changeBarsBackground(leftBarsMask, rightBarsMask)
	if (self.backgroundLeft == leftBarsMask and self.backgroundRight == rightBarsMask) then
		return;
	end
	-- get texture params
	local textureNameLeft = self.backgroundTexture and self:processBackgroundBarsMaskToTextureName(leftBarsMask) or "BackgroundBars0B0S";
	local textureNameRight = self.backgroundTexture and self:processBackgroundBarsMaskToTextureName(rightBarsMask) or "BackgroundBars0B0S";
	-- update texture on the left
	local path, x0, x1, y0, y1 = unpack(self.textures[textureNameLeft]);
	local frame = self.frames["DHUD_Left_BarsBackground"];
	local texture = frame.texture;
	if (texture:GetTexture() ~= path) then
		texture:SetTexture(path);
		texture:SetTexCoord(x0, x1, y0, y1);
	end
	-- update texture on the right
	path, x0, x1, y0, y1 = unpack(self.textures[textureNameRight]);
	frame = self.frames["DHUD_Right_BarsBackground"];
	texture = frame.texture;
	if (texture:GetTexture() ~= path) then
		texture:SetTexture(path);
		texture:SetTexCoord(x1, x0, y0, y1);
	end
	-- check if reposition required around inner bars
	local repositionLeft = bit.band(self.backgroundLeft, self.BACKGROUND_BAR_SMALL1) ~= bit.band(leftBarsMask, self.BACKGROUND_BAR_SMALL1);
	local repositionRight = bit.band(self.backgroundRight, self.BACKGROUND_BAR_SMALL1) ~= bit.band(rightBarsMask, self.BACKGROUND_BAR_SMALL1);
	-- save
	self.backgroundLeft = leftBarsMask;
	self.backgroundRight = rightBarsMask;
	-- reposition frames if required
	if (repositionLeft) then
		self:repositionCircleFramesSmallLeft();
	end
	if (repositionRight) then
		self:repositionCircleFramesSmallRight();
	end
end

--- Changes alpha of the frames
-- @param alpha new frames alpha
function DHUDGUI:changeAlpha(alpha)
	if (self.framesAlpha == alpha) then
		return;
	end
	local before = self.framesAlpha;
	-- save alpha
	self.framesAlpha = alpha;
	-- set alpha textures alpha
	local alphaFrames = self.frameGroups.alphaFrames;
	for i, v in ipairs(alphaFrames) do
		v.texture:SetAlpha(alpha);
	end
	-- hide all frames if alpha == 0
	if (alpha <= 0) then
		for k, v in pairs(self.frames) do
			v:DHide(self.FRAME_VISIBLE_REASON_ALPHA);
		end
	end
	-- show frames if alpha become greater than 0
	if (before <= 0 and alpha > 0) then
		for k, v in pairs(self.frames) do
			v:DShow(self.FRAME_VISIBLE_REASON_ALPHA);
		end
	end
end

--- Created new frame that should use alpha setting
-- @param frame reference to created frame
function DHUDGUI:onAlphaFrameCreated(frame)
	frame.texture:SetAlpha(self.framesAlpha);
	-- frames will be hidden in createFrame func if required
end

--- Hide frames when player becomes dead, only player information frames should be hidden when dead
-- @param list list with frames and groups to hide when dead
function DHUDGUI:hideFramesWhenDead(list)
	for i, v in ipairs(list) do
		-- determine if it's table or frame
		if (v.GetName == nil) then
			for i2, v2 in ipairs(v) do
				v2:DHide(self.FRAME_VISIBLE_REASON_ALIVE);
			end
		else
			v:DHide(self.FRAME_VISIBLE_REASON_ALIVE);
		end
	end
end

--- Show frames that were hidden after player become dead, only player information frames should be hidden when dead
function DHUDGUI:showFramesWhenAlive()
	for k, v in pairs(self.frames) do
		v:DShow(self.FRAME_VISIBLE_REASON_ALIVE);
	end
end

--- Process setting, that contains frame scaling and listen to it's changes
-- @param settingName name of the setting
-- @param settingId id of the setting inside class table, pass nil for automatic generation
-- @param notifyFunction function to invoke when value changes if any
-- @param group group with frames to scale by this setting, this will override group onDynamicFrameCreated function! (create different group if you don't want this to happen)
-- @param ... list of frames to be scaled by this setting
function DHUDGUI:processFrameScaleSetting(settingName, settingId, notifyFunction, group, ...)
	local frames = { ... };
	settingId = settingId or (#self.scale + 1);
	-- create notify list
	self.scaleNotifyList[settingId] = { };
	if (notifyFunction ~= nil) then
		table.insert(self.scaleNotifyList[settingId], notifyFunction);
	end
	-- create function
	local functionOnSettingChange = function(self, e)
		local scale = DHUDSettings:getValue(settingName);
		self.scale[settingId] = scale;
		-- iterate over group frames
		if (group ~= nil) then
			for i, v in ipairs(group) do
				v:SetScale(scale);
			end
		end
		-- iterate over specified frames
		for i, v in ipairs(frames) do
			v:SetScale(scale);
		end
		-- iterate over notify functions
		local notify = self.scaleNotifyList[settingId];
		for i, v in ipairs(notify) do
			v(self, nil);
		end
	end
	-- override group function
	if (group ~= nil) then
		local onCreateCurrent = group.onDynamicFrameCreated;
		group.onDynamicFrameCreated = function(self, frame)
			if (onCreateCurrent ~= nil) then
				onCreateCurrent(self, frame);
			end
			local scale = self.scale[settingId];
			frame:SetScale(scale);
		end
	end
	-- listen
	DHUDSettings:addEventListener(DHUDSettingsEvent.EVENT_SPECIFIC_SETTING_CHANGED_PREFIX .. settingName, self, functionOnSettingChange);
	functionOnSettingChange(self, nil);
end

--- Process setting, that contains frame font size and listen to it's changes
-- @param settingName name of the setting
-- @param settingId id of the setting inside class table, pass nil for automatic generation
-- @param scaledWithSettingId defines id of the scale setting that should be considered when calculating real font size (pass nil for none)
-- @param variableName name of the variable that holds text field inside frame
-- @param group group with frames to scale by this setting, this will override group onDynamicFrameCreated function! (create different group if you don't want this to happen)
-- @param ... list of frames to be scaled by this setting
function DHUDGUI:processFrameFontSizeSetting(settingName, settingId, scaledWithSettingId, variableName, group, ...)
	local frames = { ... };
	variableName = variableName or "textField";
	settingId = settingId or (#self.fontSizes + 1);
	-- create function
	local functionOnSettingChange = function(self, e)
		local fontSize = DHUDSettings:getValue(settingName);
		self.fontSizes[settingId] = fontSize;
		local realFontSize = fontSize / self.scale[self.SCALE_MAIN];
		--print("settingName " .. settingName .. ", fontSize: " .. fontSize .. ", SCALE_MAIN: " .. self.scale[self.SCALE_MAIN]);
		if (scaledWithSettingId ~= nil) then
			realFontSize = realFontSize / self.scale[scaledWithSettingId];
		end
		local fontName, cFontSize, fontFlags;
		-- iterate over group frames
		if (group ~= nil) then
			for i, v in ipairs(group) do
				v = v[variableName];
				if (v ~= nil) then
					fontName, cFontSize, fontFlags = v:GetFont();
					fontName = v.fontName;
					v:SetFont(fontName, realFontSize, fontFlags);
					v:DSetText(v:GetText()); -- required to resize textFields
				end
			end
		end
		-- iterate over specified frames
		for i, v in ipairs(frames) do
			v = v[variableName];
			if (v ~= nil) then
				fontName, cFontSize, fontFlags = v:GetFont();
				fontName = v.fontName;
				--print("for frame " .. v:GetName() .. " setting font to " .. fontName .. ", text size to " .. realFontSize .. " (previous " .. cFontSize .. ")");
				v:SetFont(fontName, realFontSize, fontFlags);
				v:DSetText(v:GetText()); -- required to resize textFields
			end
		end
	end
	-- override group function
	if (group ~= nil) then
		local onCreateCurrent = group.onDynamicFrameCreated;
		group.onDynamicFrameCreated = function(self, frame)
			if (onCreateCurrent ~= nil) then
				onCreateCurrent(self, frame);
			end
			frame = frame[variableName];
			if (frame ~= nil) then
				local fontSize = self.fontSizes[settingId];
				local realFontSize = fontSize / self.scale[self.SCALE_MAIN];
				if (scaledWithSettingId ~= nil) then
					realFontSize = realFontSize / self.scale[scaledWithSettingId];
				end
				local fontName, cFontSize, fontFlags = frame:GetFont();
				fontName = frame.fontName;
				frame:SetFont(fontName, realFontSize, fontFlags);
				frame:DSetText(frame:GetText()); -- required to resize textFields
			end
		end
	end
	-- push function to scale notify list as it's dependent on hud scale
	table.insert(self.scaleNotifyList[self.SCALE_MAIN], functionOnSettingChange);
	if (scaledWithSettingId ~= nil) then
		table.insert(self.scaleNotifyList[scaledWithSettingId], functionOnSettingChange);
	end
	-- listen
	DHUDSettings:addEventListener(DHUDSettingsEvent.EVENT_SPECIFIC_SETTING_CHANGED_PREFIX .. settingName, self, functionOnSettingChange);
	functionOnSettingChange(self, nil);
end

--- Process setting, that contains frame font outline and listen to it's changes
-- @param settingName name of the setting
-- @param settingId id of the setting inside class table, pass nil for automatic generation
-- @param variableName name of the variable that holds text field inside frame
-- @param group group with frames to scale by this setting, this will override group onDynamicFrameCreated function! (create different group if you don't want this to happen)
-- @param ... list of frames to be scaled by this setting
function DHUDGUI:processFrameFontOutlineSetting(settingName, settingId, variableName, group, ...)
	local frames = { ... };
	variableName = variableName or "textField";
	settingId = settingId or (#self.fontOutlines + 1);
	-- create function
	local functionOnSettingChange = function(self, e)
		local fontOutline = DHUDSettings:getValue(settingName);
		self.fontOutlines[settingId] = fontOutline;
		local fontFlags = self.FONT_OUTLINES[fontOutline + 1];
		local fontName, fontSize, cFontFlags;
		-- iterate over group frames
		if (group ~= nil) then
			for i, v in ipairs(group) do
				v = v[variableName];
				if (v ~= nil) then
					fontName, fontSize, cFontFlags = v:GetFont();
					fontName = v.fontName;
					v:SetFont(fontName, fontSize, fontFlags);
				end
			end
		end
		-- iterate over specified frames
		for i, v in ipairs(frames) do
			v = v[variableName];
			if (v ~= nil) then
				fontName, fontSize, cFontFlags = v:GetFont();
				v:SetFont(fontName, fontSize, fontFlags);
			end
		end
	end
	-- override group function
	if (group ~= nil) then
		local onCreateCurrent = group.onDynamicFrameCreated;
		group.onDynamicFrameCreated = function(self, frame)
			if (onCreateCurrent ~= nil) then
				onCreateCurrent(self, frame);
			end
			frame = frame[variableName];
			if (frame ~= nil) then
				local fontOutline = self.fontOutlines[settingId];
				local fontFlags = self.FONT_OUTLINES[fontOutline + 1];
				local fontName, fontSize, cFontFlags = frame:GetFont();
				fontName = frame.fontName;
				frame:SetFont(fontName, fontSize, fontFlags);
			end
		end
	end
	-- listen
	DHUDSettings:addEventListener(DHUDSettingsEvent.EVENT_SPECIFIC_SETTING_CHANGED_PREFIX .. settingName, self, functionOnSettingChange);
	functionOnSettingChange(self, nil);
end

--- Process setting, that contains frame position id and listen to it's changes
-- @param settingName name of the setting
-- @param ... list of functions to invoke
function DHUDGUI:processFramePositionIdSetting(settingName, ...)
	local functions = { ... };
	-- create function
	local functionOnSettingChange = function(self, e)
		local position = DHUDSettings:getValue(settingName);
		-- iterate over specified functions
		for i, v in ipairs(functions) do
			v(self, position);
		end
	end
	-- listen
	DHUDSettings:addEventListener(DHUDSettingsEvent.EVENT_SPECIFIC_SETTING_CHANGED_PREFIX .. settingName, self, functionOnSettingChange);
	functionOnSettingChange(self, nil);
end

--- Process setting, that contains frame offset and listen to it's changes
-- @param settingName name of the setting
-- @param frame frame to change offset for
function DHUDGUI:processFrameOffsetSetting(settingName, frame)
	-- create function
	local functionOnSettingChange = function(self, e)
		local offset = DHUDSettings:getValue(settingName);
		local frameRelativeInfo = frame.relativeInfo;
		-- update frame position
		frame:SetPoint(frameRelativeInfo[1], frameRelativeInfo[2], frameRelativeInfo[3], frameRelativeInfo[4] + offset[1], frameRelativeInfo[5] + offset[2]);
	end
	-- listen
	DHUDSettings:addEventListener(DHUDSettingsEvent.EVENT_SPECIFIC_SETTING_CHANGED_PREFIX .. settingName, self, functionOnSettingChange);
	functionOnSettingChange(self, nil);
end

--- Process setting, that contains frames horizontal distance and listen to it's changes
-- @param settingName name of the setting
-- @param frameLeft left frame to change distance from
-- @param frameRight right frame to change distance to
-- @param saveToVarName if not nil, then setting will also be saved to var specified
-- @param onChange function that should be invoked once setting is changed
function DHUDGUI:processFrameHDistanceSetting(settingName, frameLeft, frameRight, saveToVarName, onChange)
	-- create function
	local functionOnSettingChange = function(self, e)
		local distance = DHUDSettings:getValue(settingName);
		local frameLeftRelativeInfo = frameLeft.relativeInfo;
		local frameRightRelativeInfo = frameRight.relativeInfo;
		-- update frame position
		frameLeft:SetPoint(frameLeftRelativeInfo[1], frameLeftRelativeInfo[2], frameLeftRelativeInfo[3], frameLeftRelativeInfo[4] - distance, frameLeftRelativeInfo[5]);
		frameRight:SetPoint(frameRightRelativeInfo[1], frameRightRelativeInfo[2], frameRightRelativeInfo[3], frameRightRelativeInfo[4] + distance, frameRightRelativeInfo[5]);
		-- update var if any
		if (saveToVarName ~= nil) then
			self[saveToVarName] = distance;
		end
		-- invoke update func if any
		if (onChange ~= nil) then
			onChange(self);
		end
	end
	-- listen
	DHUDSettings:addEventListener(DHUDSettingsEvent.EVENT_SPECIFIC_SETTING_CHANGED_PREFIX .. settingName, self, functionOnSettingChange);
	functionOnSettingChange(self, nil);
end

--- Process setting, that contains conditions for mouse enabling and listen to it's changes
-- @param settingName name of the setting
-- @param saveToVarName if not nil, then setting will also be saved to var specified
-- @param frames list with frames that should be affected by this setting
-- @param groups list with groups that should be affected by this setting
function DHUDGUI:processMouseConditionsMaskSetting(settingName, saveToVarName, frames, groups)
	-- create custom mouse enabled function for every frame
	for i, v in ipairs(frames) do
		v.mouseEnabledByConditions = false;
		v.mouseEnabledByData = true;
		function v:SetMouseEnabledByConditions(enabled)
			self.mouseEnabledByConditions = enabled;
			self:EnableMouse(self.mouseEnabledByConditions and self.mouseEnabledByData);
		end
		function v:SetMouseEnabledByData(enabled)
			self.mouseEnabledByData = enabled;
			self:EnableMouse(self.mouseEnabledByConditions and self.mouseEnabledByData);
		end
	end
	for j, g in ipairs(groups) do
		for i, v in ipairs(g) do
			v.mouseEnabledByConditions = false;
			v.mouseEnabledByData = true;
			function v:SetMouseEnabledByConditions(enabled)
				self.mouseEnabledByConditions = enabled;
				self:EnableMouse(self.mouseEnabledByConditions and self.mouseEnabledByData);
			end
			function v:SetMouseEnabledByData(enabled)
				self.mouseEnabledByData = enabled;
				self:EnableMouse(self.mouseEnabledByConditions and self.mouseEnabledByData);
			end
		end
	end
	-- override group functions
	for j, g in ipairs(groups) do
		local onCreateCurrent = g.onDynamicFrameCreated;
		g.onDynamicFrameCreated = function(self, frame)
			if (onCreateCurrent ~= nil) then
				onCreateCurrent(self, frame);
			end
			-- create custom mouse enabled function
			frame.mouseEnabledByConditions = false;
			frame.mouseEnabledByData = true;
			function frame:SetMouseEnabledByConditions(enabled)
				self.mouseEnabledByConditions = enabled;
				self:EnableMouse(self.mouseEnabledByConditions and self.mouseEnabledByData);
			end
			function frame:SetMouseEnabledByData(enabled)
				self.mouseEnabledByData = enabled;
				self:EnableMouse(self.mouseEnabledByConditions and self.mouseEnabledByData);
			end
			-- update mouse enabled
			local currentConditions = DHUDDataTrackers.helper.modifierKeysMask;
			local requiredConditions = self[saveToVarName];
			local mouseEnabledByConditions = bit.band(currentConditions, requiredConditions) == requiredConditions;
			frame:SetMouseEnabledByConditions(mouseEnabledByConditions);
		end
	end
	-- create condition listening function
	local functionOnConditionsChange = function(self, e)
		local currentConditions = DHUDDataTrackers.helper.modifierKeysMask;
		local requiredConditions = self[saveToVarName];
		local mouseEnabledByConditions = bit.band(currentConditions, requiredConditions) == requiredConditions;
		-- iterate over specified frames
		for i, v in ipairs(frames) do
			v:SetMouseEnabledByConditions(mouseEnabledByConditions);
		end
		-- iterate over group frames
		for j, g in ipairs(groups) do
			for i, v in ipairs(g) do
				v:SetMouseEnabledByConditions(mouseEnabledByConditions);
			end
		end
	end
	-- create function
	local functionOnSettingChange = function(self, e)
		local mask = DHUDSettings:getValue(settingName);
		-- update var if any
		if (saveToVarName ~= nil) then
			self[saveToVarName] = mask;
		end
		-- invoke change conditions function
		functionOnConditionsChange(self, nil);
	end
	-- listen
	DHUDDataTrackers.helper:addEventListener(DHUDDataTrackerHelperEvent.EVENT_MODIFIER_KEYS_STATE_CHANGED, self, functionOnConditionsChange);
	DHUDSettings:addEventListener(DHUDSettingsEvent.EVENT_SPECIFIC_SETTING_CHANGED_PREFIX .. settingName, self, functionOnSettingChange);
	functionOnSettingChange(self, nil);
end

--- textures setting has changed, update gui
function DHUDGUI:onTexturesSetting(e)
	self:changeBarsTextures(DHUDSettings:getValue("textures_barTexture"));
end

--- textures setting has changed, update gui
function DHUDGUI:onBackgroundTextureSetting(e)
	local before = self.backgroundTexture;
	self.backgroundTexture = DHUDSettings:getValue("textures_barBackground");
	if (before ~= self.backgroundTexture) then
		-- force update
		local leftBarsMask = self.backgroundLeft;
		local rightBarsMask = self.backgroundRight;
		self.backgroundLeft = -1;
		self.backgroundRight = -1;
		DHUDGUI:changeBarsBackground(leftBarsMask, rightBarsMask);
	end
end

--- Create most of the static frames, that aren't going to change
function DHUDGUI:createFrames()
	local group, frame;
	-- create container for all frames
	self:createFrame("DHUD_UIParent", "UIParent", "CENTER", "CENTER", 0, 0, 512, 256);
	-- create bars background
	self:createTextureFrame("DHUD_Left_BarsBackground", "DHUD_UIParent", "LEFT", "LEFT", 0, 0, 128, 256, "BackgroundBars0B0S");
	self:createTextureFrame("DHUD_Right_BarsBackground", "DHUD_UIParent", "RIGHT", "RIGHT", 0, 0, 128, 256, "BackgroundBars0B0S", true);
	-- create alpha group
	group = self:createFrameGroup("alphaFrames", "DHUD_Left_BarsBackground", "DHUD_Right_BarsBackground");
	group.onDynamicFrameCreated = self.onAlphaFrameCreated;
	-- create bars group
	self:createFrameGroup("bars");
	-- create left big inner bar
	group = self:createDynamicFrameGroup("leftBigBar1", self.createBarFrameBigInnerLeft, 10, self.frameGroups.bars, self.frameGroups.alphaFrames);
	frame = self:createTextFrame("DHUD_Left_TextBig1", "DHUD_Left_BarsBackground", "LEFT", "BOTTOM", 95 - 50, 2 + 7, 200, 14, "LEFT", "CENTER", "numeric");
	group["text"] = frame;
	group["helper"] = DHUDGUIBarAnimationHelper:new(group, "TexturePrefixBarB1", "leftBars");
	-- create left big outer bar
	group = self:createDynamicFrameGroup("leftBigBar2", self.createBarFrameBigOuterLeft, 10, self.frameGroups.bars, self.frameGroups.alphaFrames);
	frame = self:createTextFrame("DHUD_Left_TextBig2", "DHUD_Left_BarsBackground", "LEFT", "BOTTOM", 80 - 50, -16 + 7, 200, 14, "LEFT", "CENTER", "numeric");
	group["text"] = frame;
	group["helper"] = DHUDGUIBarAnimationHelper:new(group, "TexturePrefixBarB2", "leftBars");
	-- create left small inner bar
	group = self:createDynamicFrameGroup("leftSmallBar1", self.createBarFrameSmallInnerLeft, 10, self.frameGroups.bars, self.frameGroups.alphaFrames);
	frame = self:createTextFrame("DHUD_Left_TextSmall1", "DHUD_Left_BarsBackground", "LEFT", "BOTTOM", 110 - 50, 19 + 7, 200, 14, "LEFT", "CENTER", "numeric");
	group["text"] = frame;
	group["helper"] = DHUDGUIBarAnimationHelper:new(group, "TexturePrefixBarS1", "leftBars");
	-- create left small outer bar
	group = self:createDynamicFrameGroup("leftSmallBar2", self.createBarFrameSmallOuterLeft, 10, self.frameGroups.bars, self.frameGroups.alphaFrames);
	frame = self:createTextFrame("DHUD_Left_TextSmall2", "DHUD_Left_BarsBackground", "LEFT", "BOTTOM", 120 - 50, 34 + 7, 200, 14, "LEFT", "CENTER", "numeric");
	group["text"] = frame;
	group["helper"] = DHUDGUIBarAnimationHelper:new(group, "TexturePrefixBarS2", "leftBars");
	-- create left big inner bar
	group = self:createDynamicFrameGroup("rightBigBar1", self.createBarFrameBigInnerRight, 10, self.frameGroups.bars, self.frameGroups.alphaFrames);
	frame = self:createTextFrame("DHUD_Right_TextBig1", "DHUD_Right_BarsBackground", "RIGHT", "BOTTOM", -95 + 50, 2 + 7, 200, 14, "RIGHT", "CENTER", "numeric");
	group["text"] = frame;
	group["helper"] = DHUDGUIBarAnimationHelper:new(group, "TexturePrefixBarB1", "rightBars");
	-- create left big outer bar
	group = self:createDynamicFrameGroup("rightBigBar2", self.createBarFrameBigOuterRight, 10, self.frameGroups.bars, self.frameGroups.alphaFrames);
	frame = self:createTextFrame("DHUD_Right_TextBig2", "DHUD_Right_BarsBackground", "RIGHT", "BOTTOM", -80 + 50, -16 + 7, 200, 14, "RIGHT", "CENTER", "numeric");
	group["text"] = frame;
	group["helper"] = DHUDGUIBarAnimationHelper:new(group, "TexturePrefixBarB2", "rightBars");
	-- create right small inner bar
	group = self:createDynamicFrameGroup("rightSmallBar1", self.createBarFrameSmallInnerRight, 10, self.frameGroups.bars, self.frameGroups.alphaFrames);
	frame = self:createTextFrame("DHUD_Right_TextSmall1", "DHUD_Right_BarsBackground", "RIGHT", "BOTTOM", -110 + 50, 19 + 7, 200, 14, "RIGHT", "CENTER", "numeric");
	group["text"] = frame;
	group["helper"] = DHUDGUIBarAnimationHelper:new(group, "TexturePrefixBarS1", "rightBars");
	-- create right small outer bar
	group = self:createDynamicFrameGroup("rightSmallBar2", self.createBarFrameSmallOuterRight, 10, self.frameGroups.bars, self.frameGroups.alphaFrames);
	frame = self:createTextFrame("DHUD_Right_TextSmall2", "DHUD_Right_BarsBackground", "RIGHT", "BOTTOM", -120 + 50, 34 + 7, 200, 14, "RIGHT", "CENTER", "numeric");
	group["text"] = frame;
	group["helper"] = DHUDGUIBarAnimationHelper:new(group, "TexturePrefixBarS2", "rightBars");
	-- create target info text
	frame = self:createUnitTextFrame("DHUD_Center_TextInfo1", "DHUD_UIParent", "BOTTOM", "BOTTOM", 0, -45, nil, 14, "CENTER", "CENTER");
	-- create target2 info text
	frame = self:createUnitTextFrame("DHUD_Center_TextInfo2", "DHUD_Center_TextInfo1", "BOTTOM", "BOTTOM", 0, -20, nil, 14, "CENTER", "CENTER");
	-- create spell circles group
	self:createFrameGroup("spellCircles");
	-- create buff circles
	self:createDynamicFrameGroup("spellCirclesBigLeft", self.createSpellCircleFrameBigLeft, 40, self.frameGroups.spellCircles);
	self:createDynamicFrameGroup("spellCirclesSmallLeft", self.createSpellCircleFrameSmallLeft, 20, self.frameGroups.spellCircles);
	self:createDynamicFrameGroup("spellCirclesBigRight", self.createSpellCircleFrameBigRight, 40, self.frameGroups.spellCircles);
	self:createDynamicFrameGroup("spellCirclesSmallRight", self.createSpellCircleFrameSmallRight, 20, self.frameGroups.spellCircles);
	-- create spell rectangles group
	self:createFrameGroup("spellRectangles");
	-- create buff rectangles
	self:createDynamicFrameGroup("spellRectanglesLeft", self.createSpellRectangleFrameLeft, 64, self.frameGroups.spellRectangles);
	self:createDynamicFrameGroup("spellRectanglesRight", self.createSpellRectangleFrameRight, 64, self.frameGroups.spellRectangles);
	-- create resources group
	self:createFrameGroup("resources");
	-- create combo-points
	self:createDynamicFrameGroup("comboPointsBigLeft", self.createComboPointFrameBigLeft, 10, self.frameGroups.resources);
	self:createDynamicFrameGroup("comboPointsBigRight", self.createComboPointFrameBigRight, 10, self.frameGroups.resources);
	self:createDynamicFrameGroup("comboPointsSmallLeft", self.createComboPointFrameSmallLeft, 10, self.frameGroups.resources);
	self:createDynamicFrameGroup("comboPointsSmallRight", self.createComboPointFrameSmallRight, 10, self.frameGroups.resources);
	-- create runes
	self:createDynamicFrameGroup("runesBigLeft", self.createRuneFrameBigLeft, 6, self.frameGroups.resources);
	self:createDynamicFrameGroup("runesBigRight", self.createRuneFrameBigRight, 6, self.frameGroups.resources);
	self:createDynamicFrameGroup("runesSmallLeft", self.createRuneFrameSmallLeft, 6, self.frameGroups.resources);
	self:createDynamicFrameGroup("runesSmallRight", self.createRuneFrameSmallRight, 6, self.frameGroups.resources);
	-- create group with target icons
	group = self:createDynamicFrameGroup("targetIcons", self.createTargetUnitInfoIconCenter, 10);
	group.reposition = self.repositionTargetUnitInfoIconCenter;
	-- create self icons
	self:createIconFrame("DHUD_Icon_SelfUnitIconPvP", "DHUD_Left_BarsBackground", "TOP", "TOP", 50, -15, 25, 25, "BlizzardRaidIcon1");
	self:createIconFrame("DHUD_Icon_SelfUnitIconState", "DHUD_Left_BarsBackground", "TOP", "TOP", 42, 12, 25, 25, "BlizzardRaidIcon1");
	-- create dragon icon
	self:createIconFrame("DHUD_Icon_TargetEliteDragon", "DHUD_Left_BarsBackground", "TOP", "TOP", 18, 20, 64, 64, "TargetEliteDragon");
	-- all icons should use current alpha
	self:pushFramesToGroup(self.frameGroups.alphaFrames, "DHUD_Icon_SelfUnitIconPvP", "DHUD_Icon_SelfUnitIconState", "DHUD_Icon_TargetEliteDragon");
	-- create dropdowns
	self:createDropDownMenu("DHUD_DropDown_PlayerMenu", self.initDropDownMenuPlayer);
	self:createDropDownMenu("DHUD_DropDown_TargetMenu", self.initDropDownMenuTarget);
	-- create cast delay and cast time groups
	self:createFrameGroup("castDelay");
	self:createFrameGroup("castTime");
	self:createFrameGroup("castSpellName");
	-- create cast bars
	local pushToGroupsMap = { };
	pushToGroupsMap[self.CASTBAR_GROUP_INDEX_CAST_INDICATION] = { self.frameGroups.alphaFrames };
	pushToGroupsMap[self.CASTBAR_GROUP_INDEX_FLASH] = { self.frameGroups.alphaFrames };
	pushToGroupsMap[self.CASTBAR_GROUP_INDEX_SPELLNAME] = { self.frameGroups.castSpellName };
	pushToGroupsMap[self.CASTBAR_GROUP_INDEX_CASTTIME] = { self.frameGroups.castTime };
	pushToGroupsMap[self.CASTBAR_GROUP_INDEX_DELAY] = { self.frameGroups.castDelay };
	group = self:createDynamicFrameGroupWithCustomIndexes("leftBigCastBar1", self.createCastBarFrameBigInnerLeft, pushToGroupsMap);
	group["helper"] = DHUDGUICastBarAnimationHelper:new(group, "CastingBarB1", "leftCastBars");
	group = self:createDynamicFrameGroupWithCustomIndexes("leftBigCastBar2", self.createCastBarFrameBigOuterLeft, pushToGroupsMap);
	group["helper"] = DHUDGUICastBarAnimationHelper:new(group, "CastingBarB2", "leftCastBars");
	group = self:createDynamicFrameGroupWithCustomIndexes("rightBigCastBar1", self.createCastBarFrameBigInnerRight, pushToGroupsMap);
	group["helper"] = DHUDGUICastBarAnimationHelper:new(group, "CastingBarB1", "rightCastBars");
	group = self:createDynamicFrameGroupWithCustomIndexes("rightBigCastBar2", self.createCastBarFrameBigOuterRight, pushToGroupsMap);
	group["helper"] = DHUDGUICastBarAnimationHelper:new(group, "CastingBarB2", "rightCastBars");
end

--- Initialize DHUD gui, creating all frames
function DHUDGUI:init()
	-- create frames and groups
	self:createFrames();
	-- init text tools
	DHUDTextTools:init();
	-- init color tools
	DHUDColorizeTools:init()
	-- init animation helper
	DHUDGUIBarAnimationHelper:STATIC_init()
	DHUDGUICastBarAnimationHelper:STATIC_init();
	-- initialize textures settings track
	DHUDSettings:addEventListener(DHUDSettingsEvent.EVENT_SPECIFIC_SETTING_CHANGED_PREFIX .. "textures_barTexture", self, self.onTexturesSetting);
	DHUDSettings:addEventListener(DHUDSettingsEvent.EVENT_SPECIFIC_SETTING_CHANGED_PREFIX .. "textures_barBackground", self, self.onBackgroundTextureSetting);
	self:onTexturesSetting(nil);
	self:onBackgroundTextureSetting(nil);
	-- initialize icon positions track
	self:processFramePositionIdSetting("framesData_iconPositions_dragon", self.repositionTargetUnitEliteIcon);
	self:processFramePositionIdSetting("framesData_iconPositions_selfState", self.repositionSelfUnitPvPIcon, self.repositionSelfUnitStateIcon);
	self:processFramePositionIdSetting("framesData_iconPositions_targetState", self.repositionTargetUnitInfoStateIcons);
	-- initialize scale settings track
	self:processFrameScaleSetting("scale_main", self.SCALE_MAIN, nil, nil, self.frames["DHUD_UIParent"]);
	self:processFrameScaleSetting("scale_spellCircles", self.SCALE_SPELL_CIRCLES, self.repositionSpellCircleFramesAll, self.frameGroups.spellCircles, nil);
	self:processFrameScaleSetting("scale_spellRectangles", self.SCALE_SPELL_RECTANGLES, self.repositionSpellRectangeFramesAll, self.frameGroups.spellRectangles, nil);
	self:processFrameScaleSetting("scale_resource", self.SCALE_RESOURCES, self.repositionResourceFramesAll, self.frameGroups.resources, nil);
	-- initialize fontSize setting track
	self:processFrameFontSizeSetting("scale_leftBigBar1", nil, nil, nil, nil, self.frames["DHUD_Left_TextBig1"]);
	self:processFrameFontSizeSetting("scale_leftBigBar2", nil, nil, nil, nil, self.frames["DHUD_Left_TextBig2"]);
	self:processFrameFontSizeSetting("scale_leftSmallBar1", nil, nil, nil, nil, self.frames["DHUD_Left_TextSmall1"]);
	self:processFrameFontSizeSetting("scale_leftSmallBar2", nil, nil, nil, nil, self.frames["DHUD_Left_TextSmall2"]);
	self:processFrameFontSizeSetting("scale_rightBigBar1", nil, nil, nil, nil, self.frames["DHUD_Right_TextBig1"]);
	self:processFrameFontSizeSetting("scale_rightBigBar2", nil, nil, nil, nil, self.frames["DHUD_Right_TextBig2"]);
	self:processFrameFontSizeSetting("scale_rightSmallBar1", nil, nil, nil, nil, self.frames["DHUD_Right_TextSmall1"]);
	self:processFrameFontSizeSetting("scale_rightSmallBar2", nil, nil, nil, nil, self.frames["DHUD_Right_TextSmall2"]);
	self:processFrameFontSizeSetting("scale_targetInfo1", nil, nil, nil, nil, self.frames["DHUD_Center_TextInfo1"]);
	self:processFrameFontSizeSetting("scale_targetInfo2", nil, nil, nil, nil, self.frames["DHUD_Center_TextInfo2"]);
	self:processFrameFontSizeSetting("scale_spellCirclesTime", nil, nil, "textFieldTime", self.frameGroups["spellCircles"], nil);
	self:processFrameFontSizeSetting("scale_spellCirclesStacks", nil, nil, "textFieldCount", self.frameGroups["spellCircles"], nil);
	self:processFrameFontSizeSetting("scale_spellRectanglesTime", nil, nil, "textFieldTime", self.frameGroups["spellRectangles"], nil);
	self:processFrameFontSizeSetting("scale_spellRectanglesStacks", nil, nil, "textFieldCount", self.frameGroups["spellRectangles"], nil);
	self:processFrameFontSizeSetting("scale_resourceTime", nil, nil, "textFieldTime", self.frameGroups["resources"], nil);
	self:processFrameFontSizeSetting("scale_castBarsTime", nil, nil, nil, self.frameGroups["castTime"], nil);
	self:processFrameFontSizeSetting("scale_castBarsDelay", nil, nil, nil, self.frameGroups["castDelay"], nil);
	self:processFrameFontSizeSetting("scale_castBarsSpell", nil, nil, nil, self.frameGroups["castSpellName"], nil);
	-- initialize fontOutline setting track
	self:processFrameFontOutlineSetting("outlines_leftBigBar1", nil, nil, nil, self.frames["DHUD_Left_TextBig1"]);
	self:processFrameFontOutlineSetting("outlines_leftBigBar2", nil, nil, nil, self.frames["DHUD_Left_TextBig2"]);
	self:processFrameFontOutlineSetting("outlines_leftSmallBar1", nil, nil, nil, self.frames["DHUD_Left_TextSmall1"]);
	self:processFrameFontOutlineSetting("outlines_leftSmallBar2", nil, nil, nil, self.frames["DHUD_Left_TextSmall2"]);
	self:processFrameFontOutlineSetting("outlines_rightBigBar1", nil, nil, nil, self.frames["DHUD_Right_TextBig1"]);
	self:processFrameFontOutlineSetting("outlines_rightBigBar2", nil, nil, nil, self.frames["DHUD_Right_TextBig2"]);
	self:processFrameFontOutlineSetting("outlines_rightSmallBar1", nil, nil, nil, self.frames["DHUD_Right_TextSmall1"]);
	self:processFrameFontOutlineSetting("outlines_rightSmallBar2", nil, nil, nil, self.frames["DHUD_Right_TextSmall2"]);
	self:processFrameFontOutlineSetting("outlines_targetInfo1", nil, nil, nil, self.frames["DHUD_Center_TextInfo1"]);
	self:processFrameFontOutlineSetting("outlines_targetInfo2", nil, nil, nil, self.frames["DHUD_Center_TextInfo2"]);
	self:processFrameFontOutlineSetting("outlines_spellCirclesTime", nil, "textFieldTime", self.frameGroups["spellCircles"], nil);
	self:processFrameFontOutlineSetting("outlines_spellCirclesStacks", nil, "textFieldCount", self.frameGroups["spellCircles"], nil);
	self:processFrameFontOutlineSetting("outlines_spellRectanglesTime", nil, "textFieldTime", self.frameGroups["spellRectangles"], nil);
	self:processFrameFontOutlineSetting("outlines_spellRectanglesStacks", nil, "textFieldCount", self.frameGroups["spellRectangles"], nil);
	self:processFrameFontOutlineSetting("outlines_resourceTime", nil, "textFieldTime", self.frameGroups["resources"], nil);
	self:processFrameFontOutlineSetting("outlines_castBarsTime", nil, nil, self.frameGroups["castTime"], nil);
	self:processFrameFontOutlineSetting("outlines_castBarsDelay", nil, nil, self.frameGroups["castDelay"], nil);
	self:processFrameFontOutlineSetting("outlines_castBarsSpell", nil, nil, self.frameGroups["castSpellName"], nil);
	-- initialize offset setting track
	self:processFrameOffsetSetting("offsets_hud", self.frames["DHUD_UIParent"]);
	self:processFrameOffsetSetting("offsets_targetInfo", self.frames["DHUD_Center_TextInfo1"]);
	self:processFrameOffsetSetting("offsets_targetInfo2", self.frames["DHUD_Center_TextInfo2"]);
	self:processFrameOffsetSetting("offsets_leftBigBar1", self.frames["DHUD_Left_TextBig1"]);
	self:processFrameOffsetSetting("offsets_leftBigBar2", self.frames["DHUD_Left_TextBig2"]);
	self:processFrameOffsetSetting("offsets_leftSmallBar1", self.frames["DHUD_Left_TextSmall1"]);
	self:processFrameOffsetSetting("offsets_leftSmallBar2", self.frames["DHUD_Left_TextSmall2"]);
	self:processFrameOffsetSetting("offsets_rightBigBar1", self.frames["DHUD_Right_TextBig1"]);
	self:processFrameOffsetSetting("offsets_rightBigBar2", self.frames["DHUD_Right_TextBig2"]);
	self:processFrameOffsetSetting("offsets_rightSmallBar1", self.frames["DHUD_Right_TextSmall1"]);
	self:processFrameOffsetSetting("offsets_rightSmallBar2", self.frames["DHUD_Right_TextSmall2"]);
	self:processFrameHDistanceSetting("offsets_barDistance", self.frames["DHUD_Left_BarsBackground"], self.frames["DHUD_Right_BarsBackground"], "barsDistanceDiv2", self.repositionCircleFramesAll);
	-- initialize mouse condition setting track
	self:processMouseConditionsMaskSetting("misc_mouseConditionsMask", "mouseEnableConditionsMask", { self.frames["DHUD_Center_TextInfo1"], self.frames["DHUD_Center_TextInfo2"] }, { self.frameGroups["spellCircles"], self.frameGroups["spellRectangles"] } );
	-- initialize gui manager
	DHUDGUIManager:init();
	-- debug
	--[[for i = 1, 80 do
		local frame = self.frameGroups.leftBigCastBar1[i];
		frame = self.frameGroups.leftBigCastBar2[i];
		frame = self.frameGroups.rightBigCastBar1[i];
		frame = self.frameGroups.rightBigCastBar2[i];
	end]]--
end
