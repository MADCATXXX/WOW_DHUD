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
	if (type(itemsInfo) ~= "table" or #itemsInfo == 0) then
		DHUDMain:print("This macro call requires arguments to be passed, see code for example");
		return;
	end
	if (not AuctionHouseFrame:IsVisible()) then
		DHUDMain:print("Macro requires auction house to be opened");
		return false;
	end
	if (type(itemsInfo[1]) ~= "table") then -- allow to pass only 1 item
		itemsInfo = { itemsInfo };
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
	-- recalculate session time, it will be used by some of the throttle checks along with C_AuctionHouse.IsThrottledMessageSystemReady()
	if (DHUDAPI.aucCommoditySessionStartMs == nil or (trackingHelper.timerMs - DHUDAPI.aucCommoditySessionMs) > 60) then
		DHUDAPI.aucCommoditySessionStartMs = trackingHelper.timerMs;
	end
	DHUDAPI.aucCommoditySessionMs = trackingHelper.timerMs;
	-- check commodity screen open
	local nameFrame = AuctionHouseFrame.CommoditiesBuyFrame.BuyDisplay.ItemDisplay.Name;
	if (not nameFrame:IsVisible()) then
		if (not self:auctionCheckBrowseListForCommodity(itemsInfo, config)) then
			DHUDMain:print("This macro call requires commodity screen to be open or commodity to be displayed in favorites");
		end
		return;
	end
	local desiredItemName = nameFrame:GetText();
	if (desiredItemName:sub(1, 4) == "|cff") then
		desiredItemName = desiredItemName:sub(11, -3);
	end
	local desiredItemID = AuctionHouseFrame.CommoditiesBuyFrame:GetItemID();
	local maxPrice = 0;
	local maxTotalPrice = -1;
	for i, v in ipairs(itemsInfo) do
		local identifier = v[1];
		if ((type(identifier) == "string" and identifier == desiredItemName) or
			(type(identifier) == "number" and identifier == desiredItemID)) then
			maxPrice = v[2];
			if (type(maxPrice) == "string") then maxPrice = DHUDAPI:parsePriceString(maxPrice); end
			maxTotalPrice = v[3];
			if (type(maxTotalPrice) == "string") then maxTotalPrice = DHUDAPI:parsePriceString(maxTotalPrice); end
			if (maxPrice == nil) then
				maxPrice = -1;
			end
			if (maxTotalPrice == nil) then
				if (maxPrice > 0) then
					maxTotalPrice = maxPrice * 1000;
				else
					maxTotalPrice = 1000000000; -- 100 000 g in copper
				end
			end
			break;
		end
	end
	if (maxTotalPrice == -1) then
		DHUDMain:print("Auction opened for item " .. desiredItemName .. ", but macro call didn't pass this item as allowed: " .. MCTableToString(itemsInfo));
		return;
	end
	
	-- Check if commodity purchase is in progress and wait for it?
	if (DHUDAPI:auctionCheckCommodityInProgress(desiredItemID, maxPrice, maxTotalPrice, config)) then
		return;
	end
	DHUDAPI:auctionCheckCommodityUnderPriceAndStartPurchase(desiredItemID, maxPrice, maxTotalPrice, config);
	if (config.baitSell) then
		DHUDAPI:auctionCommodityBaitSellCheck(desiredItemID, maxPrice, config);
	end
end
function DHUDAPI:auctionCheckCommodityUnderPriceAndStartPurchase(desiredItemID, maxPrice, maxTotalPrice, config)
	local debugMode = config.debugMode;
	-- Check the number of results for the item
	local numResults = C_AuctionHouse.GetNumCommoditySearchResults(desiredItemID)
	if (numResults > 3) then
		-- recalculate maxPrice if it's not provided
		if (maxPrice == -1) then
			if (numResults > 10) then
				numResults = 10;
			end
			local totalQuantity = 0;
			for i = 1, numResults do
				totalQuantity = totalQuantity + C_AuctionHouse.GetCommoditySearchResultInfo(desiredItemID, i).quantity;
			end
			local medianQuantityPosition = totalQuantity / 2;
			local accumulatedQuantity = 0;
			for i = 1, numResults do
				local info = C_AuctionHouse.GetCommoditySearchResultInfo(desiredItemID, i);
				accumulatedQuantity = accumulatedQuantity + info.quantity;
				if (accumulatedQuantity >= medianQuantityPosition) then
					maxPrice = math.floor(info.unitPrice * 66 / 100);
					DHUDAPI.aucCommodityAutoMaxPriceValue = maxPrice;
					DHUDAPI.aucCommodityAutoMaxPriceId = desiredItemID;
					break
				end
			end
		end
		numResults = 3; -- don't need to iterate over everything, 3 rows is OK
	elseif (numResults == 0) then
		if (trackingHelper.timerMs - (DHUDAPI.aucCommodityRefreshAt or 0) < 2) then
			if (debugMode) then DHUDMain:print("Waiting for commodity screen refresh"); end
			return; -- waiting for refresh of auction, do nothing
		end
	end
	local playerMoney = GetMoney();
	local moneyThreshold = config.moneyThreshold or 100000000; -- 10 000g in copper
	if (playerMoney - maxTotalPrice < moneyThreshold) then
		maxTotalPrice = playerMoney - moneyThreshold; -- limit amount of money that can be used
	end
	local itemCountToBuy = 0;
	local requiredItemThreshold = 1;
	local expectedPrice = 0;
	for i = 1, numResults do
		local info = C_AuctionHouse.GetCommoditySearchResultInfo(desiredItemID, i);
		--print("info is " .. MCTableToString(info));
		if (info ~= nil and info.unitPrice <= maxPrice) then
			local remainMoneyToUse = maxTotalPrice - expectedPrice;
			local quantity = info.quantity;
			if (info.numOwnerItems > 0) then
				requiredItemThreshold = 0; -- can buy other player items at count of 1 if selling by self
				quantity = quantity - info.numOwnerItems; -- can't buy self placed items
			end
			if (quantity * info.unitPrice > remainMoneyToUse) then
				quantity = math.floor(remainMoneyToUse / info.unitPrice);
			end
			itemCountToBuy = itemCountToBuy + quantity;
			expectedPrice = expectedPrice + quantity * info.unitPrice;
		else
			break;
		end
	end
	if (itemCountToBuy > 0) then
		DHUDAPI.aucCommodityLastFoundMs = trackingHelper.timerMs;
	end
	if (itemCountToBuy > requiredItemThreshold) then
		if (itemCountToBuy > 30) then
			if (itemCountToBuy > 1400) then
				itemCountToBuy = math.floor(itemCountToBuy * 3 / 4); -- better chance to buy atleast something during competition
			else
				itemCountToBuy = itemCountToBuy - 1; -- offset that this single item may have been bought already
			end
		end
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
			DHUDAPI.aucCommodityStuckAt = nil;
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
		if (maxPrice == -1 and DHUDAPI.aucCommodityAutoMaxPriceId == desiredItemID) then
			maxPrice = DHUDAPI.aucCommodityAutoMaxPriceValue; -- load last calculated value if not provided
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
		-- check if buy button is disabled (e.g. auction house is stuck)
		local buyIsEnabled = AuctionHouseFrame.BuyDialog.BuyNowButton:IsEnabled();
		if (not buyIsEnabled) then
			if (debugMode) then DHUDMain:print("Auction house buy button is not enabled, check for stuck state..."); end
			if (DHUDAPI.aucCommodityStuckAt == nil) then
				DHUDAPI.aucCommodityStuckAt = trackingHelper.timerMs;
			end
			if (trackingHelper.timerMs - DHUDAPI.aucCommodityStuckAt > 30) then -- more than 30 seconds passed = close auction house
				DHUDMain:print("Auction house is stuck, please reopen it, consider binding interact key");
				MCAucSCP:SetAttribute("clickbutton", AuctionHouseFrameCloseButton);
			end
		else
			DHUDAPI.aucCommodityStuckAt = nil;
		end
	end
	if (startedPurchase ~= nil) then
		startedPurchase[1] = 0; -- mark as completed
	end
	-- confirm action
	ChangeActionBarPage(config.confirmPage or 6);
	return true;
end
function DHUDAPI:auctionCheckBrowseListForCommodity(itemsInfo, config)
	local itemListResultTextIsVisible = AuctionHouseFrame.BrowseResultsFrame.ItemList.ResultsText:IsVisible();
	local items = { AuctionHouseFrame.BrowseResultsFrame.ItemList.ScrollBox.ScrollTarget:GetChildren() };
	local itemToClick = nil;
	local itemClickIndex = 1000;
	for i, child in ipairs(items) do
		-- Each child in the scroll list should have a 'result' field, which contains the itemKey
		local itemKey = child.rowData and child.rowData.itemKey
		if itemKey then
			-- Get the item ID and info from the itemKey
			local itemID = itemKey.itemID
			local itemInfo = C_AuctionHouse.GetItemKeyInfo(itemKey)
			local itemName = itemInfo and itemInfo.itemName or "Unknown"
			
			-- check if we found correct item?
			for j, searchItem in ipairs(itemsInfo) do
				local identifier = searchItem[1];
				if ((type(identifier) == "string" and identifier == itemName) or
					(type(identifier) == "number" and identifier == itemID)) then
					if (j < itemClickIndex) then
						itemToClick = child;
						itemClickIndex = j;
					end
					break;
				end
			end
			--print("Item ID: " .. itemID .. ", Item Name: " .. itemName);
		end
	end
	-- process result
	if (itemToClick ~= nil) then
		DHUDMain:print("Opening commodity item info from the main browse list for item: " .. itemToClick.rowData.itemKey.itemID);
		itemToClick:Click();
		return true;
	elseif (#items == 0 or itemListResultTextIsVisible) then -- nothing found and no items present, try to reload favorites?
		if (DHUDAPI.aucCommodityWaitFavsAt == nil) then
			DHUDAPI.aucCommodityWaitFavsAt = trackingHelper.timerMs;
		end
		if (trackingHelper.timerMs - DHUDAPI.aucCommodityWaitFavsAt > 5) then -- more than 5 seconds passed = refresh favorites
			DHUDAPI.aucCommodityWaitFavsAt = trackingHelper.timerMs;
			DHUDMain:print("Auction house reloading favorites to check for commodity items there");
			MCAucSCP:SetAttribute("clickbutton", AuctionHouseFrame.SearchBar.FavoritesSearchButton);
			ChangeActionBarPage(config.confirmPage or 6);
			return true;
		end
	end
	return false;
end
function DHUDAPI:auctionCommodityBaitSellCheck(desiredItemID, maxPrice, config)
	local debugMode = config.debugMode;
	local foundTimeMs = DHUDAPI.aucCommodityLastFoundMs;
	local sellTimeMs = DHUDAPI.aucCommodityLastSellMs or 0;
	if (foundTimeMs == nil) then
		foundTimeMs = DHUDAPI.aucCommoditySessionStartMs;
	end
	local baitInterval = config.baitInterval or 15;
	-- this operation assumes some loss, don't want to do it often
	--print("found time pass " .. (trackingHelper.timerMs - foundTimeMs) .. ", sell " .. (trackingHelper.timerMs - sellTimeMs));
	if (trackingHelper.timerMs - foundTimeMs < baitInterval or trackingHelper.timerMs - sellTimeMs < baitInterval) then
		return;
	end
	DHUDAPI.aucCommodityLastSellMs = trackingHelper.timerMs;
	if (trackingHelper.timerMs - DHUDAPI.aucCommoditySessionStartMs > 180 or not C_AuctionHouse.IsThrottledMessageSystemReady()) then
		return; -- auction throttles requests pretty quickly, don't need to post anything during that period
	end
	-- search for item in inventory, can't do anything if it doesn't exist
	local itemBag, itemSlot;
	for bag = 0, 5 do
		local numSlots = C_Container.GetContainerNumSlots(bag);
		for slot = 1, numSlots do
			local itemInfo = C_Container.GetContainerItemInfo(bag, slot);
			if (itemInfo ~= nil and itemInfo.itemID == desiredItemID) then
				itemBag = bag;
				itemSlot = slot;
				break;
			end
		end
	end
	if (itemSlot == nil) then
		DHUDMain:print("Item not found in inventory: " .. desiredItemID);
		return;
	end
	if (maxPrice == -1 and DHUDAPI.aucCommodityAutoMaxPriceId == desiredItemID) then
		maxPrice = DHUDAPI.aucCommodityAutoMaxPriceValue; -- load last calculated value if not provided
	end
	maxPrice = math.floor(maxPrice / 100) * 100; -- copper not supported
	local itemLocation = ItemLocation:CreateFromBagAndSlot(itemBag, itemSlot);
	-- Create frame if not yet created
	if (not MCAucSecurePostCommodityButton) then
		--[[CreateFrame("Frame", "MCAucSecurePostCommodityFrame", AuctionHouseFrame, "AuctionHouseCommoditiesSellFrameTemplate");--MCAucSecurePostCommodityFrame.PostButton
		MCAucSecurePostCommodityFrame.GetQuantity = function() return 1; end;
		MCAucSecurePostCommodityFrame.GetDuration = function() return 1; end;
		MCAucSecurePostCommodityFrame.CanPostItem = function() return true; end;
		MCAucSecurePostCommodityFrame.GetUnitPrice = function() return maxPrice; end;
		MCAucSecurePostCommodityFrame.GetItem = function() return itemLocation; end;]]--
		CreateFrame("Button", "MCAucSecurePostCommodityButton", nil, "SecureActionButtonTemplate");
	end
	-- set price and item
	MCAucSecurePostCommodityButton:SetScript("OnClick", function(self, button, down)
		local pending = C_AuctionHouse.PostCommodity(itemLocation, 1, 1, maxPrice);
		DHUDMain:print("Item posted to Auction House from bag " .. itemBag .. ", slot " .. itemSlot .. " with max price " .. maxPrice .. ", is pending: " .. MCTableToString(pending));
	end);
	MCAucSCP:SetAttribute("clickbutton", MCAucSecurePostCommodityButton);
	DHUDMain:print("Posting commodity item: " .. desiredItemID .. " at price " .. (maxPrice / 10000) .. "g");
	-- confirm action
	ChangeActionBarPage(config.confirmPage or 6);
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

--[[
	CreateFrame("Frame", "MCAucSecurePostCommodityFrame");
	local postButton = CreateFrame("Button", "MCAucSecurePostCommodityButton", MCAucSecurePostCommodityFrame, "SecureActionButtonTemplate");
	local itemDisplay = CreateFrame("Button", nil, MCAucSecurePostCommodityFrame, "AuctionHouseItemDisplayTemplate");
	local quantityInput = CreateFrame("Frame", nil, MCAucSecurePostCommodityFrame, "AuctionHouseAlignedQuantityInputFrameTemplate");
	local priceInput = CreateFrame("Frame", nil, MCAucSecurePostCommodityFrame, "AuctionHouseAlignedPriceInputFrameTemplate");
	local deposit = CreateFrame("Frame", nil, MCAucSecurePostCommodityFrame, "AuctionHouseAlignedPriceDisplayTemplate");
	Mixin(MCAucSecurePostCommodityFrame, AuctionHouseCommoditiesSellFrameMixin);
	MCAucSecurePostCommodityFrame.MarkDirty = function() end;
	Mixin(MCAucSecurePostCommodityButton, AuctionHouseSellFramePostButtonMixin);
	Mixin(itemDisplay, AuctionHouseItemBuyItemDisplayMixin);
	MCAucSecurePostCommodityFrame.ItemDisplay = itemDisplay;
	--Mixin(quantityInput, AuctionHouseAlignedQuantityInputFrameMixin);
	MCAucSecurePostCommodityFrame.QuantityInput = quantityInput;
	MCAucSecurePostCommodityFrame.PriceInput = priceInput;
	MCAucSecurePostCommodityFrame.Deposit = deposit;
	MCAucSecurePostCommodityFrame.TotalPrice = deposit; -- same type
	MCAucSecurePostCommodityFrame.PostButton = postButton;
	MCAucSecurePostCommodity:SetScript("OnClick", function(self, button, down)
		local itemLocation = ItemLocation:CreateFromBagAndSlot(itemBag, itemSlot);
		C_AuctionHouse.PostCommodity(itemLocation, 1, 1, maxPrice);
		DHUDMain:print("Item posted to Auction House from bag " .. itemBag .. ", slot " .. itemSlot .. " with max price " .. maxPrice);
	end);
]]--
--MCAucSecurePostCommodity:SetAttribute("macrotext", string.format(
-- [[/run local itemLocation = ItemLocation:CreateFromBagAndSlot(%d, %d); C_AuctionHouse.PostCommodity(itemLocation, 1, 1, %d);]], itemBag, itemSlot, maxPrice));
--MCAucSecurePostCommodityFrame:SetItem(itemLocation, nil, false);
