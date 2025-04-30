--[[-----------------------------------------------------------------------------------
 Original Drathals HUD (c) 2006 by Markus Inger / Drathal / Silberklinge / Silbersegen
 DHUD for WotLK and later expansions (c) 2013 by MADCAT (EU-Гордунни, Мадкат)
 (http://eu.battle.net/wow/en/character/гордунни/Мадкат/advanced)
---------------------------------------------------------------------------------------
 This file contains API to help earn money with auction house, none of this code is
 executed unless user calls this from his command line/macro
 @author: MADCAT
-----------------------------------------------------------------------------------]]--

-- antitaint local "_" var
local _;
-- tracker helper
local trackingHelper = DHUDDataTrackingHelper;

--- Class to provide simple functions for certain checks
DHUDAuctionHelper = {
}

--- Macro helper for Auction to buy commodity item under a certain price
-- @param itemsInfo array of info item, each item is { itemIdentifier, maxUnitPrice, maxTotalPrice? }
-- @param config config that can change some of the macro parameters, e.g. { debugMode = true, refreshThrottle = 0.5 }
-- macro itself:
--[[
/script DHUDAuctionHelper:auctionBuyCommodity({"Ore", "40g"}, { refreshThrottle = 0.5 })
/click [actionbar:6] MCAucSCP
/script ChangeActionBarPage(2)
]]-- click params are dependent on CVars, macro may need to specify mouse button, e.g. /click [actionbar:6] MCAucSCP LeftButton t
function DHUDAuctionHelper:auctionBuyCommodity(itemsInfo, config)
	if (type(itemsInfo) ~= "table" or #itemsInfo == 0) then
		DHUDMain:print("This macro call requires arguments to be passed, see code for example");
		return;
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
	-- close any automatic popups if any
	if (self:auctionRemoveSplashPopups()) then
		return;
	end
	-- check auction house visible
	if (AuctionHouseFrame == nil or not AuctionHouseFrame:IsVisible()) then
		if (not self:auctionOpenAllMail(config)) then
			DHUDMain:print("Macro requires auction house to be opened");
		end
		return;
	end
	-- recalculate session time, it will be used by some of the throttle checks along with C_AuctionHouse.IsThrottledMessageSystemReady()
	if (DHUDAuctionHelper.aucCommoditySessionStartMs == nil or (trackingHelper.timerMs - DHUDAuctionHelper.aucCommoditySessionMs) > 60) then
		DHUDAuctionHelper.aucCommoditySessionStartMs = trackingHelper.timerMs;
	end
	DHUDAuctionHelper.aucCommoditySessionMs = trackingHelper.timerMs;
	-- check commodity screen open
	local nameFrame = AuctionHouseFrame.CommoditiesBuyFrame.BuyDisplay.ItemDisplay.Name;
	if (not nameFrame:IsVisible()) then
		if (not self:auctionCheckBrowseListForCommodity(itemsInfo, config)) then
			DHUDMain:print("This macro call requires commodity screen to be open or commodity to be displayed in favorites");
			if (DHUDAuctionHelper.aucCommodityStuckAt == nil or DHUDAuctionHelper.aucCommodityStuckAt < DHUDAuctionHelper.aucCommoditySessionStartMs) then
				DHUDAuctionHelper.aucCommodityStuckAt = trackingHelper.timerMs;
			end
			if (trackingHelper.timerMs - DHUDAuctionHelper.aucCommodityStuckAt > 30) then -- more than 30 seconds passed = close auction house
				DHUDAuctionHelper.aucCommodityStuckAt = nil;
				DHUDAuctionHelper.failCommoditySearchCloseCount = (DHUDAuctionHelper.failCommoditySearchCloseCount or 0) + 1;
				DHUDMain:print("Auction house is stuck, please reopen it, consider binding interact key, stuck count: " .. DHUDAuctionHelper.failCommoditySearchCloseCount);
				if (DHUDAuctionHelper.failCommoditySearchCloseCount < 5) then
					MCAucSCP:SetAttribute("clickbutton", AuctionHouseFrameCloseButton);
				else -- logout (but can't use macro /logout)
					local logoutBtn = DHUDAuctionHelper:findLogoutButton();
					MCAucSCP:SetAttribute("clickbutton", logoutBtn);
				end
				ChangeActionBarPage(config.confirmPage or 6);
			end
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
			if (type(maxPrice) == "string") then maxPrice = DHUDAuctionHelper:parsePriceString(maxPrice); end
			maxTotalPrice = v[3];
			if (type(maxTotalPrice) == "string") then maxTotalPrice = DHUDAuctionHelper:parsePriceString(maxTotalPrice); end
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
	if (DHUDAuctionHelper:auctionCheckCommodityInProgress(desiredItemID, maxPrice, maxTotalPrice, config)) then
		return;
	end
	DHUDAuctionHelper:auctionCheckCommodityUnderPriceAndStartPurchase(desiredItemID, maxPrice, maxTotalPrice, config);
	if (config.autoSell or config.baitSell) then
		DHUDAuctionHelper:auctionCommodityAutoAndBaitSellCheck(desiredItemID, maxPrice, config);
	end
end
function DHUDAuctionHelper:auctionCheckCommodityUnderPriceAndStartPurchase(desiredItemID, maxPrice, maxTotalPrice, config)
	local debugMode = config.debugMode;
	-- Check the number of results for the item
	local numResults = C_AuctionHouse.GetNumCommoditySearchResults(desiredItemID)
	if (numResults > 0) then
		if ((DHUDAuctionHelper.aucCommodityRefreshedAt or 0) < (DHUDAuctionHelper.aucCommodityRefreshAt or 0)) then
			DHUDAuctionHelper.aucCommodityRefreshedAt = trackingHelper.timerMs;
			DHUDAuctionHelper.aucCommodityLastRefreshTime = trackingHelper.timerMs - (DHUDAuctionHelper.aucCommodityRefreshAt or 0);
		end
	else
		if (trackingHelper.timerMs - (DHUDAuctionHelper.aucCommodityRefreshAt or 0) < 2) then
			if (debugMode) then DHUDMain:print("Waiting for commodity screen refresh"); end
			return; -- waiting for refresh of auction, do nothing
		end
	end
	-- recalculate maxPrice if it's not provided
	if (numResults > 3 and maxPrice < 0) then
		local maxPriceLimit = -maxPrice;
		local resultsToConsider = config.autoPriceResults or 10;
		if (numResults > resultsToConsider) then
			numResults = resultsToConsider;
		end
		local skipQuantity = 0;
		local nonSkipQuantity = 0;
		local i = 1
		while i <= numResults do
			local info = C_AuctionHouse.GetCommoditySearchResultInfo(desiredItemID, i);
			if (info.numOwnerItems > 0 and i <= 3) then
				numResults = numResults + 1;
				skipQuantity = skipQuantity + info.quantity;
			else
				nonSkipQuantity = nonSkipQuantity + info.quantity;
			end
			i = i + 1;
		end
		local medianQuantityPosition = skipQuantity + nonSkipQuantity / 2;
		local accumulatedQuantity = 0;
		for i = 1, numResults do
			local info = C_AuctionHouse.GetCommoditySearchResultInfo(desiredItemID, i);
			accumulatedQuantity = accumulatedQuantity + info.quantity;
			if (accumulatedQuantity >= medianQuantityPosition) then
				local medianPrice = info.unitPrice;
				local medianMultiplier1 = config.medianBuyMultiply;
				local medianMultiplier2 = config.medianBaitMultiply;
				if (medianMultiplier1 == nil or medianMultiplier2 == nil) then
					local medianMultiplier = medianPrice <= 40000 and 0 or medianPrice >= 95000 and 1 or (medianPrice - 40000) / 55000;
					medianMultiplier1 = 0.68 + medianMultiplier * 0.06; -- from 0.68 to 0.74 as max price to buy
					-- adjust medianMultiplier for bait sell based on market conditions (e.g. if bot snipes our items instantly)
					if (DHUDAuctionHelper.aucCommodityBaitHistory ~= nil and #DHUDAuctionHelper.aucCommodityBaitHistory > 2) then
						local lastBought = DHUDAuctionHelper.aucCommodityBaitHistory[#DHUDAuctionHelper.aucCommodityBaitHistory][2];
						local lastPriceSilver = DHUDAuctionHelper.aucCommodityBaitHistory[#DHUDAuctionHelper.aucCommodityBaitHistory][3];
						local baitOffsetStart = 1;
						if (lastBought >= 2 or (skipQuantity > 0 and lastPriceSilver <= medianPrice / 100)) then baitOffsetStart = 0; end
						local lastMultiplier = DHUDAuctionHelper.aucCommodityBaitHistory[#DHUDAuctionHelper.aucCommodityBaitHistory - baitOffsetStart][1];
						local positiveCount = 0;
						for i = 1, 2 do
							local itemsBought = DHUDAuctionHelper.aucCommodityBaitHistory[#DHUDAuctionHelper.aucCommodityBaitHistory - baitOffsetStart - i + 1][2];
							if (itemsBought >= 2) then -- buying 2 items on one bait is considered positive outcome
								positiveCount = positiveCount + 1;
							end
						end
						-- positive market behavior
						if (positiveCount == 2) then
							medianMultiplier = math.max(lastMultiplier - 0.15, 0); -- gradually reduce bait price
						elseif (positiveCount == 0) then -- negative market behavior
							medianMultiplier = math.min(lastMultiplier + 0.1, 1); -- gradually increase bait price
						else -- so-so market behavior - leave as is
							medianMultiplier = lastMultiplier;
						end
					end
					DHUDAuctionHelper.aucCommodityMedianMultiplier = medianMultiplier;
					medianMultiplier2 = 0.56 + medianMultiplier * 0.08; -- from 0.56 to 0.64 as bait sell price
					if (medianMultiplier2 > medianMultiplier1 * 0.95) then
						medianMultiplier2 = medianMultiplier1 * 0.95; -- bait sell value should be lower than maxPrice or we won't be buying things
					end
				end
				maxPrice = math.floor(info.unitPrice * medianMultiplier1);
				local limitEnabled = maxPriceLimit ~= 1;
				if (limitEnabled and maxPrice > maxPriceLimit) then
					maxPrice = maxPriceLimit;
				end
				local excessSellPrice = nil;
				if (config.autoSell) then
					DHUDAuctionHelper.aucCommodityAutoExcessSellIsBestPrice = maxPrice >= maxPriceLimit;
					if (maxPrice >= maxPriceLimit) then
						excessSellPrice = DHUDAuctionHelper:auctionCommodityCalculateAutoPrice(desiredItemID, numResults,
							config.requiredPercent or 0.02, config.requiredCount or 500, config.requiredCountMax or 4000, true);
					else
						excessSellPrice = DHUDAuctionHelper:auctionCommodityCalculateAutoPrice(desiredItemID, numResults,
							config.requiredPercent or 0.15, config.requiredCount or 1000, config.requiredCountMax or 15000, true);
					end
				end
				-- save a bit lower value for bait sell, so that in case price goes down we still buy it
				DHUDAuctionHelper.aucCommodityAutoMaxBuyPriceValue = maxPrice;
				DHUDAuctionHelper.aucCommodityAutoMaxSellPriceValue = math.floor((maxPrice / medianMultiplier1) * medianMultiplier2);
				DHUDAuctionHelper.aucCommodityAutoExcessSellPriceValue = excessSellPrice;
				DHUDAuctionHelper.aucCommodityAutoMaxPriceId = desiredItemID;
				if (trackingHelper.timerMs - (DHUDAuctionHelper.aucCommodityLastFoundMs or 0) > 15 and trackingHelper.timerMs - (DHUDAuctionHelper.aucCommodityAutoMaxPricePrintMs or 0) > 15) then
					DHUDAuctionHelper.aucCommodityAutoMaxPricePrintMs = trackingHelper.timerMs;
					DHUDMain:print("Max price to buy item calculated as " .. DHUDAuctionHelper:moneyToPriceString(maxPrice) ..
						", max price limit is " .. ((limitEnabled and "enabled at " .. DHUDAuctionHelper:moneyToPriceString(maxPriceLimit)) or "disabled, money loss can occur") ..
						", bait sell price " .. DHUDAuctionHelper:moneyToPriceString(DHUDAuctionHelper.aucCommodityAutoMaxSellPriceValue) ..
						", bait multiplier " .. MCTableToString(DHUDAuctionHelper.aucCommodityMedianMultiplier) ..
						", excess sell price " .. DHUDAuctionHelper:moneyToPriceString(excessSellPrice));
				end
				break
			end
		end
	end
	if (numResults > 3) then numResults = 3; end; -- don't need to iterate over everything, 3 rows is OK
	local playerMoney = GetMoney();
	local moneyThreshold = config.moneyThreshold or 100000000; -- 10 000g in copper
	if (playerMoney - maxTotalPrice < moneyThreshold) then
		maxTotalPrice = playerMoney - moneyThreshold; -- limit amount of money that can be used
		if (maxTotalPrice < maxPrice and trackingHelper.timerMs - (DHUDAuctionHelper.aucCommodityReachMoneyThresholdPrintMs or 0) > 15) then
			DHUDAuctionHelper.aucCommodityReachMoneyThresholdPrintMs = trackingHelper.timerMs;
			DHUDMain:print("Current money threshold of " .. DHUDAuctionHelper:moneyToPriceString(moneyThreshold) .. " already reached, change config.moneyThreshold if you want to continue...");
		end
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
	if (DHUDAuctionHelper.aucCommodityCancelRefresh == true) then
		DHUDAuctionHelper.aucCommodityCancelRefresh = nil;
		DHUDAuctionHelper.aucCommodityRefreshAt = nil;
		itemCountToBuy = 0;
	end
	if (itemCountToBuy > 0 or requiredItemThreshold == 0) then
		DHUDAuctionHelper.aucCommodityLastFoundMs = trackingHelper.timerMs;
		DHUDAuctionHelper.aucCommodityBuyWithBait = requiredItemThreshold == 0;
	end
	local countBuyThreshold = config.itemCountThreshold or (DHUDAuctionHelper.aucCommodityAutoExcessSellIsBestPrice and 40000 or 80000);
	if ((DHUDAuctionHelper.aucCommodityNumBoughtItems or 0) + itemCountToBuy > countBuyThreshold) then
		itemCountToBuy = countBuyThreshold - (DHUDAuctionHelper.aucCommodityNumBoughtItems or 0);
		if (itemCountToBuy <= 0) then
			if (debugMode or trackingHelper.timerMs - (DHUDAuctionHelper.aucCommodityReachCountThresholdPrintMs or 0) > 15) then
				DHUDAuctionHelper.aucCommodityReachCountThresholdPrintMs = trackingHelper.timerMs;
				DHUDMain:print("Current buy count threshold of " .. countBuyThreshold .. " already reached, change threshold or reload if you want to continue...");
			end
			return;
		end
	end
	if (itemCountToBuy > requiredItemThreshold) then
		if (itemCountToBuy > 1400) then
			itemCountToBuy = math.floor(itemCountToBuy * 3 / 4); -- better chance to buy atleast something during competition
		elseif (itemCountToBuy > 30 or requiredItemThreshold == 1) then
			itemCountToBuy = itemCountToBuy - 1; -- offset that this single item may have been bought already and/or leave one item for bait
		end
		local firstItem, secondItem = AuctionHouseFrame.CommoditiesBuyFrame.ItemList.ScrollBox.ScrollTarget:GetChildren();
		if (firstItem ~= nil) then
			firstItem:Click();
			AuctionHouseFrame.CommoditiesBuyFrame.BuyDisplay.QuantityInput.InputBox:SetText(itemCountToBuy);
			AuctionHouseFrame:TriggerEvent(AuctionHouseFrameMixin.Event.CommoditiesQuantitySelectionChanged, itemCountToBuy);
			local totalGoldCount = 0;
			if (AuctionHouseFrame.CommoditiesBuyFrame.BuyDisplay.TotalPrice.MoneyDisplayFrame.GoldDisplay.Text:IsVisible()) then
				totalGoldCount = DHUDAuctionHelper:goldAmountToNumber(AuctionHouseFrame.CommoditiesBuyFrame.BuyDisplay.TotalPrice.MoneyDisplayFrame.GoldDisplay.Text:GetText(),
																	AuctionHouseFrame.CommoditiesBuyFrame.BuyDisplay.TotalPrice.MoneyDisplayFrame.SilverDisplay.Text:GetText());
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
		DHUDAuctionHelper.aucCommodityStartedPurchase = { trackingHelper.timerMs, itemCountToBuy };
	else
		if (trackingHelper.timerMs - (DHUDAuctionHelper.aucCommodityRefreshAt or 0) < (config.refreshThrottle or 0.1)) then
			if (debugMode) then DHUDMain:print("Commodity refresh throttle"); end
			return;
		end
		-- refresh auctions, calls C_AuctionHouse.SendSearchQuery(itemKey, {}, false)
		MCAucSCP:SetAttribute("clickbutton", AuctionHouseFrame.CommoditiesBuyFrame.ItemList.RefreshFrame.RefreshButton);
		DHUDAuctionHelper.aucCommodityRefreshAt = trackingHelper.timerMs;
		if (debugMode) then DHUDMain:print("Refreshing auctions"); end
	end
	-- confirm action
	ChangeActionBarPage(config.confirmPage or 6);
	
	--local itemKey = C_AuctionHouse.MakeItemKey(desiredItemID)
	--print("itemKey " .. MCTableToString(itemKey));
end
function DHUDAuctionHelper:auctionCheckCommodityInProgress(desiredItemID, maxPrice, maxTotalPrice, config)
	local debugMode = config.debugMode;
	local buyDialog = AuctionHouseFrame.BuyDialog;
	local startedPurchase = DHUDAuctionHelper.aucCommodityStartedPurchase;
	if (not buyDialog:IsVisible()) then -- dialog not present
		if (startedPurchase == nil) then -- not started purchase - continue
			return false;
		end
		if (startedPurchase[1] == 0) then -- transaction was completed previously, continue
			DHUDAuctionHelper.aucCommodityStartedPurchase = nil;
			DHUDAuctionHelper.aucCommodityStuckAt = nil;
			return false;
		end
		if (trackingHelper.timerMs - startedPurchase[1] > 5) then -- more than 5 seconds passed = cancel
			DHUDAuctionHelper.aucCommodityStartedPurchase = nil;
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
		if (maxPrice < 0 and DHUDAuctionHelper.aucCommodityAutoMaxPriceId == desiredItemID) then
			maxPrice = DHUDAuctionHelper.aucCommodityAutoMaxBuyPriceValue; -- load last calculated value if not provided
		end
		-- check final price, it can increase
		local quantity = startedPurchase[2];
		local totalGoldCount = DHUDAuctionHelper:goldAmountToNumber(AuctionHouseFrame.BuyDialog.PriceFrame.GoldDisplay.Text:GetText(),
																	AuctionHouseFrame.BuyDialog.PriceFrame.SilverDisplay.Text:GetText());
		if (totalGoldCount < maxTotalPrice / 10000 and totalGoldCount / quantity < maxPrice / 10000) then
			MCAucSCP:SetAttribute("clickbutton", AuctionHouseFrame.BuyDialog.BuyNowButton);
			if (startedPurchase[1] ~= 0) then
				DHUDAuctionHelper.aucCommodityNumBoughtItems = (DHUDAuctionHelper.aucCommodityNumBoughtItems or 0) + quantity;
				if (DHUDAuctionHelper.aucCommodityBuyWithBait and DHUDAuctionHelper.aucCommodityBaitHistory ~= nil) then -- multiplier[0-1] and count of bought items
					local info = DHUDAuctionHelper.aucCommodityBaitHistory[#DHUDAuctionHelper.aucCommodityBaitHistory];
					info[2] = info[2] + quantity;
				end
			end
			if (debugMode or startedPurchase[1] ~= 0) then
				local pricePerItem = math.floor(100 * totalGoldCount / quantity) / 100;
				DHUDMain:print("Confirm purchase " .. quantity .. " items at gold price: " .. pricePerItem .. ", total gold price: " .. totalGoldCount .. ", item ID: " .. desiredItemID);
			end
		else
			MCAucSCP:SetAttribute("clickbutton", AuctionHouseFrame.BuyDialog.CancelButton);
			if (debugMode) then DHUDMain:print("Canceling purchase " .. quantity .. " items at total gold price: " .. totalGoldCount); end
			DHUDAuctionHelper.aucCommodityCancelRefresh = true;
		end
		-- check if buy button is disabled (e.g. auction house is stuck)
		local buyIsEnabled = AuctionHouseFrame.BuyDialog.BuyNowButton:IsEnabled();
		if (not buyIsEnabled) then
			if (debugMode) then DHUDMain:print("Auction house buy button is not enabled, check for stuck state..."); end
			if (DHUDAuctionHelper.aucCommodityStuckAt == nil or DHUDAuctionHelper.aucCommodityStuckAt < DHUDAuctionHelper.aucCommoditySessionStartMs) then
				DHUDAuctionHelper.aucCommodityStuckAt = trackingHelper.timerMs;
			end
			if (trackingHelper.timerMs - DHUDAuctionHelper.aucCommodityStuckAt > 30) then -- more than 30 seconds passed = close auction house
				DHUDMain:print("Auction house is stuck, please reopen it, consider binding interact key");
				MCAucSCP:SetAttribute("clickbutton", AuctionHouseFrameCloseButton);
			end
		else
			DHUDAuctionHelper.aucCommodityStuckAt = nil;
		end
	end
	if (startedPurchase ~= nil) then
		startedPurchase[1] = 0; -- mark as completed
	end
	-- confirm action
	ChangeActionBarPage(config.confirmPage or 6);
	return true;
end
function DHUDAuctionHelper:auctionCheckBrowseListForCommodity(itemsInfo, config)
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
		if (DHUDAuctionHelper.aucCommodityWaitFavsAt == nil) then
			DHUDAuctionHelper.aucCommodityWaitFavsAt = trackingHelper.timerMs;
		end
		if (trackingHelper.timerMs - DHUDAuctionHelper.aucCommodityWaitFavsAt > 5) then -- more than 5 seconds passed = refresh favorites
			DHUDAuctionHelper.aucCommodityWaitFavsAt = trackingHelper.timerMs;
			DHUDMain:print("Auction house reloading favorites to check for commodity items there");
			MCAucSCP:SetAttribute("clickbutton", AuctionHouseFrame.SearchBar.FavoritesSearchButton);
			ChangeActionBarPage(config.confirmPage or 6);
			return true;
		end
	end
	return false;
end
function DHUDAuctionHelper:auctionCommodityAutoAndBaitSellCheck(desiredItemID, maxPrice, config)
	local debugMode = config.debugMode;
	local baitSell = config.baitSell;
	local autoSell = config.autoSell;
	local sessionStartMs = DHUDAuctionHelper.aucCommoditySessionStartMs;
	local foundTimeMs = DHUDAuctionHelper.aucCommodityLastFoundMs or sessionStartMs;
	local sellTimeMs = DHUDAuctionHelper.aucCommodityLastSellMs or 0;
	local baitInterval = config.baitInterval or 15;
	-- this operation assumes some loss, don't want to do it often
	--print("found time pass " .. (trackingHelper.timerMs - foundTimeMs) .. ", sell " .. (trackingHelper.timerMs - sellTimeMs));
	if (trackingHelper.timerMs - foundTimeMs < baitInterval or trackingHelper.timerMs - sessionStartMs < baitInterval or
		trackingHelper.timerMs - sellTimeMs < baitInterval or not C_AuctionHouse.IsThrottledMessageSystemReady()) then
		return;
	end
	DHUDAuctionHelper.aucCommodityLastSellMs = trackingHelper.timerMs;
	local timeFromSessionStartMs = trackingHelper.timerMs - DHUDAuctionHelper.aucCommoditySessionStartMs;
	local timeLastRefreshMs = DHUDAuctionHelper.aucCommodityLastRefreshTime or 0;
	if (timeFromSessionStartMs > 230 or (timeFromSessionStartMs > 160 and timeLastRefreshMs >= 0.2)) then
		DHUDMain:print("Auto Sell Item skipped due to Throttling of AH, time since start " .. timeFromSessionStartMs .. ", time for refresh " .. timeLastRefreshMs .. "...");
		return; -- auction throttles requests pretty quickly, don't need to post anything during that period
	end
	-- search for item in inventory, can't do anything if it doesn't exist
	local itemBag, itemSlot;
	local itemStack = -1;
	local totalStack = 0;
	for bag = 0, 5 do
		local numSlots = C_Container.GetContainerNumSlots(bag);
		for slot = 1, numSlots do
			local itemInfo = C_Container.GetContainerItemInfo(bag, slot);
			if (itemInfo ~= nil and itemInfo.itemID == desiredItemID) then
				local stackCount = itemInfo.stackCount or 0;
				totalStack = totalStack + stackCount;
				if (stackCount > itemStack) then
					itemBag = bag;
					itemSlot = slot;
					itemStack = stackCount;
				end
				if (not autoSell) then
					break;
				end
			end
		end
	end
	if (itemSlot == nil) then
		DHUDMain:print("Item not found in inventory: " .. desiredItemID);
		return;
	end
	local quantity = 1;
	local autoSellInterval = config.excessInterval or (DHUDAuctionHelper.aucCommodityAutoExcessSellIsBestPrice and 60 or (totalStack > 32000) and 900 or 3600);
	local autoSellMaxCount = config.excessSellMaxCount or ((DHUDAuctionHelper.aucCommodityAutoExcessSellIsBestPrice or totalStack > 32000) and 60000 or 30000);
	if (autoSell and trackingHelper.timerMs - (DHUDAuctionHelper.aucCommodityLastExcessSellMs or 0) > autoSellInterval
		and (totalStack - itemStack) > (config.autoSellMinStack or 5000)
		and (DHUDAuctionHelper.aucCommodityLastExcessSellCount or 0) < autoSellMaxCount
		and DHUDAuctionHelper.aucCommodityAutoMaxPriceId == desiredItemID) then
		quantity = itemStack;
		maxPrice = DHUDAuctionHelper.aucCommodityAutoExcessSellPriceValue; -- load last calculated value
		DHUDAuctionHelper.aucCommodityLastExcessSellCount = (DHUDAuctionHelper.aucCommodityLastExcessSellCount or 0) + quantity;
		DHUDAuctionHelper.aucCommodityLastExcessSellMs = trackingHelper.timerMs;
	elseif (not baitSell) then
		return; -- bait sell is disabled and autosell check failed
	elseif (maxPrice < 0 and DHUDAuctionHelper.aucCommodityAutoMaxPriceId == desiredItemID) then
		maxPrice = DHUDAuctionHelper.aucCommodityAutoMaxSellPriceValue; -- load last calculated value if not provided
	end
	maxPrice = math.floor(maxPrice / 100) * 100; -- copper not supported
	local itemLocation = ItemLocation:CreateFromBagAndSlot(itemBag, itemSlot);
	-- Create frame if not yet created
	if (not MCAucSecurePostCommodityButton) then
		CreateFrame("Button", "MCAucSecurePostCommodityButton", nil, "SecureActionButtonTemplate");
	end
	-- set price and item
	MCAucSecurePostCommodityButton:SetScript("OnClick", function(self, button, down)
		local pending = C_AuctionHouse.PostCommodity(itemLocation, 1, quantity, maxPrice);
		DHUDMain:print(quantity .. " item(s) posted to Auction House from bag " .. itemBag .. ", slot " .. itemSlot .. " with price " .. DHUDAuctionHelper:moneyToPriceString(maxPrice) ..
			", is pending: " .. MCTableToString(pending));
		if (quantity == 1 and maxPrice <= DHUDAuctionHelper.aucCommodityAutoMaxSellPriceValue) then
			if (DHUDAuctionHelper.aucCommodityBaitHistory == nil) then DHUDAuctionHelper.aucCommodityBaitHistory = {}; end
			if (#DHUDAuctionHelper.aucCommodityBaitHistory > 20) then table.remove(DHUDAuctionHelper.aucCommodityBaitHistory, 1); end
			local info = { DHUDAuctionHelper.aucCommodityMedianMultiplier or 0, 0, maxPrice / 100 }; -- multiplier[0-1] and count of bought items, price in silver
			table.insert(DHUDAuctionHelper.aucCommodityBaitHistory, info);
		end
	end);
	MCAucSCP:SetAttribute("clickbutton", MCAucSecurePostCommodityButton);
	DHUDMain:print("Posting " .. quantity .. " commodity item(s): " .. desiredItemID .. " at price " .. DHUDAuctionHelper:moneyToPriceString(maxPrice));
	-- confirm action
	ChangeActionBarPage(config.confirmPage or 6);
end

--- Macro helper for Auction to sell commodity items without right clicking on them
-- @param config config that can change some of the macro parameters, e.g. { debugMode = true, refreshThrottle = 0.5 }
-- macro itself:
--[[
/script DHUDAuctionHelper:auctionCommodityPlaceIntoAH()
]]--
function DHUDAuctionHelper:auctionCommodityPlaceIntoAH(config)
	local cSFrame = AuctionHouseFrame.CommoditiesSellFrame;
	local iSFrame = AuctionHouseFrame.ItemSellFrame;
	local commodityVisible = cSFrame:IsVisible();
	local itemVisible = iSFrame:IsVisible();
	if (not commodityVisible and not itemVisible) then
		local sellTab = AuctionHouseFrameSellTab;
		if (sellTab:IsVisible()) then
			AuctionHouseFrameSellTab:Click();
			commodityVisible = cSFrame:IsVisible();
			itemVisible = iSFrame:IsVisible();
		end
		if (not commodityVisible and not itemVisible) then
			DHUDMain:print("This macro call requires commodity sell screen");
			return;
		end
	end
	-- Provide default config if needed
	if (config == nil) then
		config = {};
	end
	-- read params
	local positionGreaterThan = DHUDAuctionHelper.aucCommodityLastPlaceLocation or 0;
	local minimumItemsToRemain = config.minimumItems or 500;
	local itemIdToCount = {};
	local desiredItemID = nil;
	for bag = 0, 5 do
		local numSlots = C_Container.GetContainerNumSlots(bag);
		for slot = 1, numSlots do
			local itemInfo = C_Container.GetContainerItemInfo(bag, slot);
			local stackCount = itemInfo and itemInfo.stackCount or 0;
			-- Check if the item is a commodity (stackable item)
			if (stackCount > 1) then
				local itemID = itemInfo.itemID;
				local itemBound = itemInfo.isBound;
				local prevItemCount = itemIdToCount[itemID] or 0;
				local totalCount = prevItemCount + stackCount;
				itemIdToCount[itemID] = totalCount;
				local itemPlaceLocation = bag * 100 + slot;
				local itemLocation = ItemLocation:CreateFromBagAndSlot(bag, slot);
				local isCommodity = C_AuctionHouse.GetItemCommodityStatus(itemLocation);
				if (totalCount > minimumItemsToRemain and itemPlaceLocation > positionGreaterThan and isCommodity == 2 and not itemBound) then
					if (not commodityVisible) then
						AuctionHouseFrame:SetDisplayMode(AuctionHouseFrameDisplayMode.CommoditiesSell);
					end
					DHUDAuctionHelper.aucCommodityLastPlaceLocation = itemPlaceLocation;
					cSFrame:SetItem(itemLocation);
					if (prevItemCount < minimumItemsToRemain) then
						cSFrame.QuantityInput.InputBox:SetText(totalCount - minimumItemsToRemain);
					end
					DHUDMain:print("Preparing itemID: " .. itemID .. " to be sold, bag " .. bag .. ", slot " .. slot);
					desiredItemID = itemID;
					break;
				end
			end
		end
		if (desiredItemID ~= nil) then break; end;
	end
	if (desiredItemID == nil) then
		if (itemPlaceLocation == 0) then
			DHUDMain:print("No commodity items left");
		else
			DHUDMain:print("Commodity items iteration finished");
			DHUDAuctionHelper.aucCommodityLastPlaceLocation = 0;
		end
		return;
	end
	-- Create frame if not yet created
	if (not MCAucSellCommodityWaitRefresh) then
		CreateFrame("Frame", "MCAucSellCommodityWaitRefresh");
		hooksecurefunc(AuctionHouseFrame.CommoditiesSellFrame.PriceInput, "SetAmount", function(self, amount)
			if (amount <= 100) then return; end;
			DHUDAuctionHelper.aucCommoditySellFrameLastPrice = amount;
			local itemLoc = AuctionHouseFrame.CommoditiesSellFrame:GetItem();
			local id = itemLoc and C_Item.GetItemID(itemLoc);
			DHUDAuctionHelper.aucCommoditySellFrameLastId = id;
		end);
	end
	MCAucSellCommodityWaitRefresh:UnregisterEvent("COMMODITY_SEARCH_RESULTS_UPDATED");
	MCAucSellCommodityWaitRefresh:RegisterEvent("COMMODITY_SEARCH_RESULTS_UPDATED");
	MCAucSellCommodityWaitRefresh:SetScript("OnEvent", function() DHUDAuctionHelper:auctionCommodityUpdatePlacedItemPrice(desiredItemID, config); end);
end
function DHUDAuctionHelper:auctionCommodityUpdatePlacedItemPrice(desiredItemID, config)
	local checkResults = config.checkResults or 15;
	local numResults = C_AuctionHouse.GetNumCommoditySearchResults(desiredItemID);
	if numResults > checkResults then
		numResults = checkResults;
	elseif numResults == 0 then
		DHUDMain:print("Refresh triggered with empty result, waiting for another try");
		return;
	end
	if (not AuctionHouseFrame.CommoditiesSellFrame:IsVisible()) then
		MCAucSellCommodityWaitRefresh:UnregisterEvent("COMMODITY_SEARCH_RESULTS_UPDATED");
		return;
	end
	
	local requiredPrice, requiredIndex = DHUDAuctionHelper:auctionCommodityCalculateAutoPrice(desiredItemID, numResults,
		config.requiredPercent or 0.15, config.requiredCount or 1000, 500000);

	-- Set the most common price in the Auction House Sell UI
	if (requiredPrice ~= nil) then
		local children = { AuctionHouseFrame.CommoditiesSellList.ScrollBox.ScrollTarget:GetChildren() };
		if (children[requiredIndex] ~= nil) then
			children[requiredIndex]:Click();
		end
		AuctionHouseFrame.CommoditiesSellFrame.PriceInput:SetAmount(requiredPrice);
		DHUDMain:print("Price updated to: " .. requiredPrice .. " copper.");
	else
		DHUDMain:print("Can't determine optimal price, please enter manually");
	end
	MCAucSellCommodityWaitRefresh:UnregisterEvent("COMMODITY_SEARCH_RESULTS_UPDATED");
	-- auto refresh next item
	MCAucSellCommodityWaitRefresh:RegisterEvent("AUCTION_HOUSE_AUCTION_CREATED");
	MCAucSellCommodityWaitRefresh:RegisterEvent("COMMODITY_SEARCH_RESULTS_UPDATED");
	MCAucSellCommodityWaitRefresh:SetScript("OnEvent", function(self, event, auctionId)
		--print("here " .. MCTableToString(event) .. ", " .. MCTableToString(auctionId) .. ", " .. MCTableToString(AuctionHouseFrame.CommoditiesSellFrame:GetItem() == nil));
		if (event == "AUCTION_HOUSE_AUCTION_CREATED") then
			MCAucSellCommodityWaitRefresh:UnregisterEvent("AUCTION_HOUSE_AUCTION_CREATED");
			DHUDAuctionHelper.aucCommodityLastPostedId = DHUDAuctionHelper.aucCommoditySellFrameLastId;
			DHUDAuctionHelper.aucCommodityLastPostedPrice = DHUDAuctionHelper.aucCommoditySellFrameLastPrice;
			DHUDAuctionHelper.aucCommodityLastPostedTimeMs = trackingHelper.timerMs;
		elseif (event == "COMMODITY_SEARCH_RESULTS_UPDATED" and AuctionHouseFrame.CommoditiesSellFrame:GetItem() == nil) then
			MCAucSellCommodityWaitRefresh:UnregisterEvent("AUCTION_HOUSE_AUCTION_CREATED");
			MCAucSellCommodityWaitRefresh:UnregisterEvent("COMMODITY_SEARCH_RESULTS_UPDATED");
			DHUDAuctionHelper:auctionCommodityPlaceIntoAH(config);
		end
	end);
end
function DHUDAuctionHelper:auctionCommodityCalculateAutoPrice(desiredItemID, numResults, requiredPercent, requiredCountMin, requiredCountMax, skipRepeatOwnPrice)
	local totalCount = 0;
	local maxIndexOwn = 0;
	local maxPriceToCheck = 100000000; -- 10000 g
	if (DHUDAuctionHelper.aucCommodityLastPostedId == desiredItemID and trackingHelper.timerMs - DHUDAuctionHelper.aucCommodityLastPostedTimeMs < 30) then
		maxPriceToCheck = DHUDAuctionHelper.aucCommodityLastPostedPrice;
	end
	for i = 1, numResults do
		local info = C_AuctionHouse.GetCommoditySearchResultInfo(desiredItemID, i);
		totalCount = totalCount + info.quantity;
		if (info.numOwnerItems > 0) then
			maxIndexOwn = i;
			if (info.unitPrice >= maxPriceToCheck) then break; end;
		end
	end
	local currentCount = 0;
	local requiredCount = totalCount * requiredPercent;
	if (requiredCount < requiredCountMin) then requiredCount = requiredCountMin; elseif (requiredCount > requiredCountMax) then requiredCount = requiredCountMax; end;
	local requiredPrice = nil;
	local requiredIndex = 0;
	for i = 1, numResults do
		local info = C_AuctionHouse.GetCommoditySearchResultInfo(desiredItemID, i);
		currentCount = currentCount + info.quantity;
		if (currentCount > requiredCount) then
			requiredPrice = info.unitPrice;
			requiredIndex = i;
			if (i >= maxIndexOwn or skipRepeatOwnPrice == true or currentCount > requiredCountMax) then -- otherwise try to repeat our own price
				break;
			end
		end
	end
	return requiredPrice, requiredIndex
end
--- Macro to remove any popups that may appear at login
function DHUDAuctionHelper:auctionRemoveSplashPopups()
	local splashVisible = SplashFrame and SplashFrame:IsVisible() or false;
	if (splashVisible) then
		DHUDMain:print("Closing initial splash screen");
		MCAucSCP:SetAttribute("clickbutton", SplashFrame.BottomCloseButton);
		ChangeActionBarPage(config.confirmPage or 6);
	end
	return splashVisible;
end
--- Macro to open mail, e.g. click "Open All Mail" button
-- @param config config that defines how function should work
-- @return true if mail window was opened and no extra messages are required
function DHUDAuctionHelper:auctionOpenAllMail(config)
	local openMailIsVisble = config.disableMail ~= true and OpenAllMail ~= nil and OpenAllMail:IsVisible();
	if (openMailIsVisble and OpenAllMail:IsEnabled()) then
		MCAucSCP:SetAttribute("clickbutton", OpenAllMail);
		ChangeActionBarPage(config.confirmPage or 6);
	end
	return openMailIsVisble;
end

--- Parse price string, e.g. 40g 25s to copper amount
-- @param str price string to Parse
-- @return amount of copper as number that was encoded in the string
function DHUDAuctionHelper:parsePriceString(str)
	local totalCopper = 0;

	-- Remove any spaces to simplify matching
	str = str:gsub("%s+", "");
	
	-- Check for negative sign
	local isNegative = str:sub(1, 1) == "-";

	-- Match gold, silver, and copper amounts
	local gold = tonumber(str:match("(%d+)g")) or 0;
	local silver = tonumber(str:match("(%d+)s")) or 0;
	local copper = tonumber(str:match("(%d+)c")) or 0;

	-- Convert everything to copper (1g = 10000c, 1s = 100c)
	totalCopper = (gold * 10000) + (silver * 100) + copper;

	-- Apply negative sign if detected
	if isNegative then
		totalCopper = -totalCopper;
	end

	return totalCopper;
end

--- Convert money in copper to price string to be printed in logs
-- @param totalCopper amount of copper as number
-- @param ommitCopper default to true, defines if copper should not be printed in the result
-- @return price string to be printed
function DHUDAuctionHelper:moneyToPriceString(totalCopper, ommitCopper)
	if (totalCopper == nil) then return "nil"; end
	if (ommitCopper == nil) then ommitCopper = true; end

	-- Remove any spaces to simplify matching
	local goldAmount = math.floor(totalCopper / 10000);
	
	local silverAmount = math.floor((totalCopper - goldAmount * 10000) / 100);
	local silverString = (silverAmount >= 10) and silverAmount or "0" .. silverAmount;
	
	if (ommitCopper) then
		return goldAmount .. "g " .. silverString .. "s";
	else
		local copperAmount = totalCopper - goldAmount * 10000 - silverAmount * 100;
		local copperString = (copperAmount >= 10) and copperAmount or "0" .. copperAmount;
		return goldAmount .. "g " .. silverString .. "s " .. copperString .. "c";
	end
end

--- Convert money string that is printed by game to number, doesn't support fractional numbers, but supports various delimeters
-- @param goldString gold amount as string to be converted
-- @param silverString silver amount as string to be converted (used only if gold amount is nil)
-- @return gold amount as number
function DHUDAuctionHelper:goldAmountToNumber(goldString, silverString)
	-- Remove anything that isn't a digit or a leading minus sign
	local sanitizedG = tostring(goldString):gsub("[^%d%-]", "");
	local goldN = tonumber(sanitizedG);
	if (goldN == nil) then
		local sanitizedS = tostring(silverString):gsub("[^%d%-]", "");
		local silverN = tonumber(sanitizedS);
		if (silverN ~= nil) then
			goldN = 0;
		end
	end
	return goldN;
end

--- Search for logout button in main menu of the game
-- @return logout button or nil if not found
function DHUDAuctionHelper:findLogoutButton()
	ToggleGameMenu();
	ToggleGameMenu();
	local logoutButton = nil;
	for btn in GameMenuFrame.buttonPool:EnumerateActive() do
		if btn:GetText() == LOG_OUT then
			logoutButton = btn;
			break;
		end
	end
	return logoutButton;
end

