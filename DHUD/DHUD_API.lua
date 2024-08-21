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

--- Macro helper for Auction to buy commodity item under a certain price
-- @param itemsInfo array of info item, each item is { itemIdentifier, maxUnitPrice, maxTotalPrice? }
-- @param config config that can change some of the macro parameters, e.g. { debugMode = true, refreshThrottle = 0.5 }
-- macro itself:
--[[
/script DHUDAPI:auctionBuyCommodity({"Ore", "40g"}, { refreshThrottle = 0.5 })
/click [actionbar:6] MCAucSCP
/script ChangeActionBarPage(2)
]]--
function DHUDAPI:auctionBuyCommodity(itemsInfo, config)
	local nameFrame = AuctionHouseFrame.CommoditiesBuyFrame.BuyDisplay.ItemDisplay.Name;
	if ((not nameFrame:IsVisible()) or type(itemsInfo) ~= "table" or #itemsInfo == 0) then
		DHUDMain:print("This macro call requires commodity screen to be open and argument to be passed");
		return;
	end
	local desiredItemName = nameFrame:GetText();
	if (desiredItemName:sub(1, 4) == "|cff") then
		desiredItemName = desiredItemName:sub(11, -3);
	end
	local desiredItemID = AuctionHouseFrame.CommoditiesBuyFrame:GetItemID();
	local maxPrice = 0;
	local maxTotalPrice = -1;
	if (type(itemsInfo[1]) ~= "table") then -- allow to pass only 1 item
		itemsInfo = { itemsInfo };
	end
	for i, v in ipairs(itemsInfo) do
		local identifier = v[1];
		if ((type(identifier) == "string" and identifier == desiredItemName) or
			(type(identifier) == "number" and identifier == desiredItemID)) then
			maxPrice = v[2];
			if (type(maxPrice) == "string") then maxPrice = DHUDAPI:parsePriceString(maxPrice); end
			maxTotalPrice = v[3];
			if (type(maxTotalPrice) == "string") then maxTotalPrice = DHUDAPI:parsePriceString(maxTotalPrice); end
			if (maxTotalPrice == nil) then
				maxTotalPrice = maxPrice * 1000;
			end
			break;
		end
	end
	if (maxTotalPrice == -1) then
		DHUDMain:print("Auction opened for item " .. desiredItemName .. ", but macro call didn't pass this item as allowed: " .. MCTableToString(itemsInfo));
		return;
	end
	
	-- Create frame if not yet created
	if (not MCAucSCP) then
		CreateFrame("Button", "MCAucDummy");
		local f = CreateFrame("Button", "MCAucSCP", nil, "SecureActionButtonTemplate");
		f:SetAttribute("type", "click");
		f:SetAttribute("clickbutton", MCAucDummy); -- dummy object
	end
	
	-- Provide default config if needed
	if (config == nil) then
		config = {};
	end
	
	-- Check if commodity purchase is in progress and wait for it?
	if (DHUDAPI:auctionCheckCommodityInProgress(desiredItemID, maxPrice, maxTotalPrice, config)) then
		return;
	end
	DHUDAPI:auctionCheckCommodityUnderPriceAndStartPurchase(desiredItemID, maxPrice, maxTotalPrice, config);
end
function DHUDAPI:auctionCheckCommodityUnderPriceAndStartPurchase(desiredItemID, maxPrice, maxTotalPrice, config)
	local debugMode = config.debugMode;
	-- Check the number of results for the item
	local numResults = C_AuctionHouse.GetNumCommoditySearchResults(desiredItemID)
	if (numResults > 3) then -- don't need to iterate over everything, 3 rows is OK
		numResults = 3;
	elseif (numResults == 0) then
		if (trackingHelper.timerMs - (DHUDAPI.aucCommodityRefreshAt or 0) < 2) then
			if (debugMode) then DHUDMain:print("Waiting for commodity screen refresh"); end
			return; -- waiting for refresh of auction, do nothing
		end
	end
	local itemCountToBuy = 0;
	local expectedPrice = 0;
	for i = 1, numResults do
		local info = C_AuctionHouse.GetCommoditySearchResultInfo(desiredItemID, i)
		--print("info is " .. MCTableToString(info));
		if (info ~= nil and info.unitPrice <= maxPrice) then
			local remainMoneyToUse = maxTotalPrice - expectedPrice;
			local quantity = info.quantity;
			if (quantity * info.unitPrice > remainMoneyToUse) then
				quantity = math.floor(remainMoneyToUse / info.unitPrice);
			end
			itemCountToBuy = itemCountToBuy + quantity;
			expectedPrice = expectedPrice + quantity * info.unitPrice;
		else
			break;
		end
	end
	if (itemCountToBuy > 1) then
		local firstItem, secondItem = AuctionHouseFrame.CommoditiesBuyFrame.ItemList.ScrollBox.ScrollTarget:GetChildren();
		if (firstItem ~= nil) then
			firstItem:Click();
			AuctionHouseFrame.CommoditiesBuyFrame.BuyDisplay.QuantityInput.InputBox:SetText(itemCountToBuy);
			AuctionHouseFrame:TriggerEvent(AuctionHouseFrameMixin.Event.CommoditiesQuantitySelectionChanged, itemCountToBuy);
			local totalGoldCount = 0;
			if (AuctionHouseFrame.CommoditiesBuyFrame.BuyDisplay.TotalPrice.MoneyDisplayFrame.GoldDisplay.Text:IsVisible()) then
				totalGoldCount = tonumber(AuctionHouseFrame.CommoditiesBuyFrame.BuyDisplay.TotalPrice.MoneyDisplayFrame.GoldDisplay.Text:GetText());
			end
			if (totalGoldCount < maxTotalPrice / 10000) then
				if (debugMode) then DHUDMain:print("Going to purchase " .. itemCountToBuy .. " items at total gold price: " .. totalGoldCount .. ", item ID: " .. desiredItemID); end
			else
				if (debugMode) then DHUDMain:print("Price no longer valid for " .. itemCountToBuy .. " items at total gold price: " .. totalGoldCount); end
				return;
			end
		else
			if (debugMode) then DHUDMain:print("Commodity scrollbox no children, check code"); end
			return;
		end
		-- executes StartCommoditiesPurchase
		MCAucSCP:SetAttribute("clickbutton", AuctionHouseFrame.CommoditiesBuyFrame.BuyDisplay.BuyButton);
		DHUDAPI.aucCommodityStartedPurchase = { trackingHelper.timerMs, itemCountToBuy };
	else
		if (trackingHelper.timerMs - (DHUDAPI.aucCommodityRefreshAt or 0) < (config.refreshThrottle or 0.1)) then
			if (debugMode) then DHUDMain:print("Commodity refresh throttle"); end
			return;
		end
		-- refresh auctions, calls C_AuctionHouse.SendSearchQuery(itemKey, {}, false)
		MCAucSCP:SetAttribute("clickbutton", AuctionHouseFrame.CommoditiesBuyFrame.ItemList.RefreshFrame.RefreshButton);
		DHUDAPI.aucCommodityRefreshAt = trackingHelper.timerMs;
		if (debugMode) then DHUDMain:print("Refreshing auctions"); end
	end
	-- confirm action
	ChangeActionBarPage(config.confirmPage or 6);
	
	--local itemKey = C_AuctionHouse.MakeItemKey(desiredItemID)
	--print("itemKey " .. MCTableToString(itemKey));
end
function DHUDAPI:auctionCheckCommodityInProgress(desiredItemID, maxPrice, maxTotalPrice, config)
	local debugMode = config.debugMode;
	local buyDialog = AuctionHouseFrame.BuyDialog;
	local startedPurchase = DHUDAPI.aucCommodityStartedPurchase;
	if (not buyDialog:IsVisible()) then -- dialog not present
		if (startedPurchase == nil) then -- not started purchase - continue
			return false;
		end
		if (startedPurchase[1] == 0) then -- transaction was completed previously, continue
			DHUDAPI.aucCommodityStartedPurchase = nil;
			return false;
		end
		if (trackingHelper.timerMs - startedPurchase[1] > 5) then -- more than 5 seconds passed = cancel
			DHUDAPI.aucCommodityStartedPurchase = nil;
			if (debugMode) then DHUDMain:print("Buy screen timed out"); end
		else
			if (debugMode) then DHUDMain:print("Waiting for auction buy screen"); end
		end
		return true;
	end
	-- check for errors
	if (AuctionHouseFrame.BuyDialog.OkayButton:IsVisible()) then
		-- item no longer available - close window
		MCAucSCP:SetAttribute("clickbutton", AuctionHouseFrame.BuyDialog.OkayButton);
		if (debugMode) then DHUDMain:print("Closing error screen"); end
	else
		if (startedPurchase == nil) then
			if (debugMode) then DHUDMain:print("Waiting for transaction end, close manually if stuck"); end
			return true;
		end
		-- check final price, it can increase
		local quantity = startedPurchase[2];
		local totalGoldCount = tonumber(AuctionHouseFrame.BuyDialog.PriceFrame.GoldDisplay.Text:GetText());
		if (totalGoldCount < maxTotalPrice / 10000 and totalGoldCount / quantity < maxPrice / 10000) then
			MCAucSCP:SetAttribute("clickbutton", AuctionHouseFrame.BuyDialog.BuyNowButton);
			local pricePerItem = math.floor(100 * totalGoldCount / quantity) / 100
			if (debugMode or startedPurchase[1] ~= 0) then
				DHUDMain:print("Confirm purchase " .. quantity .. " items at gold price: " .. pricePerItem .. ", total gold price: " .. totalGoldCount .. ", item ID: " .. desiredItemID);
			end
		else
			MCAucSCP:SetAttribute("clickbutton", AuctionHouseFrame.BuyDialog.CancelButton);
			if (debugMode) then DHUDMain:print("Canceling purchase " .. quantity .. " items at total gold price: " .. totalGoldCount); end
		end
	end
	if (startedPurchase ~= nil) then
		startedPurchase[1] = 0; -- mark as completed
	end
	-- confirm action
	ChangeActionBarPage(config.confirmPage or 6);
	return true;
end

--- Parse price string, e.g. 40g 25s to copper amount
-- @param str price string to Parse
-- @return amount of copper encoded in the string
function DHUDAPI:parsePriceString(str)
	local totalCopper = 0;

	-- Remove any spaces to simplify matching
	str = str:gsub("%s+", "");

	-- Match gold, silver, and copper amounts
	local gold = tonumber(str:match("(%d+)g")) or 0;
	local silver = tonumber(str:match("(%d+)s")) or 0;
	local copper = tonumber(str:match("(%d+)c")) or 0;

	-- Convert everything to copper (1g = 10000c, 1s = 100c)
	totalCopper = (gold * 10000) + (silver * 100) + copper;

	return totalCopper;
end
