----------------------------------------------------------------------------------
-- CatalogShopMixin
----------------------------------------------------------------------------------
CatalogShopMixin = {};
function CatalogShopMixin.GetBaseProductInfo(productID)
	if productID == CHARACTER_TRANSFER_FACTION_BUNDLE_PRODUCT_ID then
		-- TODO fix this C_StoreSecure call
		return C_StoreSecure.GetProductInfo(CHARACTER_TRANSFER_PRODUCT_ID);
	elseif productID == GUILD_TRANSFER_FACTION_BUNDLE_PRODUCT_ID then
		-- TODO fix this C_StoreSecure call
		return C_StoreSecure.GetProductInfo(GUILD_TRANSFER_PRODUCT_ID);
	end
end

function CatalogShopMixin.GetBundleProductInfo(productID)
	if productID == CHARACTER_TRANSFER_PRODUCT_ID then
		-- TODO fix this C_StoreSecure call
		return C_StoreSecure.GetProductInfo(CHARACTER_TRANSFER_FACTION_BUNDLE_PRODUCT_ID);
	elseif productID == GUILD_TRANSFER_PRODUCT_ID then
		-- TODO fix this C_StoreSecure call
		return C_StoreSecure.GetProductInfo(GUILD_TRANSFER_FACTION_BUNDLE_PRODUCT_ID);
	end
end

----------------------------------------------------------------------------------
function CatalogShopMixin:OnLoad_CatalogShop()
	self:RegisterEvent("CATALOG_SHOP_DATA_REFRESH");
	self:RegisterEvent("CATALOG_SHOP_REBUILD_SCROLL_BOX");
	self:RegisterEvent("CATALOG_SHOP_FETCH_SUCCESS");
	self:RegisterEvent("CATALOG_SHOP_FETCH_FAILURE");
	self:RegisterEvent("CATALOG_SHOP_SPECIFIC_PRODUCT_REFRESH");
	self:RegisterEvent("CATALOG_SHOP_PURCHASE_SUCCESS");
	self:RegisterEvent("UI_SCALE_CHANGED");
	self:RegisterEvent("PRODUCT_DISTRIBUTIONS_UPDATED");
	self:RegisterEvent("STORE_PURCHASE_ERROR");
	self:RegisterEvent("CATALOG_SHOP_RESULT_ERROR");
	self:RegisterEvent("STORE_ORDER_INITIATION_FAILED");
	self:RegisterEvent("AUTH_CHALLENGE_FINISHED");
	self:RegisterEvent("TOKEN_MARKET_PRICE_UPDATED");
	self:RegisterEvent("TOKEN_STATUS_CHANGED");
	self:RegisterEvent("STORE_BOOST_AUTO_CONSUMED");
	self:RegisterEvent("STORE_REFRESH");
	self:RegisterEvent("UI_MODEL_SCENE_INFO_UPDATED");
	self:RegisterEvent("CATALOG_SHOP_OPEN_SIMPLE_CHECKOUT");
	self:RegisterEvent("UPDATE_EXPANSION_LEVEL");
	self:RegisterEvent("TRIAL_STATUS_UPDATE");
	self:RegisterEvent("SIMPLE_CHECKOUT_CLOSED");
	self:RegisterEvent("SUBSCRIPTION_CHANGED_KICK_IMMINENT");
	self:RegisterEvent("LOGIN_STATE_CHANGED");
	self:RegisterEvent("CATALOG_SHOP_PMT_IMAGE_DOWNLOADED")
	-- RNM: Removed becuase this was no longer used in Shop 2.0 
	-- self:RegisterEvent("DYNAMIC_BUNDLE_PRICE_UPDATED");
	self:InitVariables();
	EventRegistry:RegisterCallback("CatalogShop.OnProductSelected", self.OnProductSelected, self);
	EventRegistry:RegisterCallback("CatalogShop.OnNoProductsSelected", self.OnNoProductsSelected, self);
	EventRegistry:RegisterCallback("CatalogShop.OnCategorySelected", self.OnCategorySelected, self);

	self:SetPortraitToAsset("Interface\\Icons\\UI_Shop");
	self:SetTitle(BLIZZARD_STORE);

	if ( C_Glue.IsOnGlueScreen() ) then
		self:SetFrameStrata("FULLSCREEN_DIALOG");
		-- block keys
		self:EnableKeyboard(true);
		self:SetScript("OnKeyDown",
			function(self, key)
				if ( key == "ESCAPE" ) then
					CatalogShopFrame:SetAttribute("action", "EscapePressed");
				end
			end
		);
	end

	-- solve this later
	self:SetPoint("CENTER", nil, "CENTER", 0, 20); --Intentionally not anchored to UIParent.

	self.categoryIDs = C_CatalogShop.GetAvailableCategoryIDs();

	self.onCloseCallback = function()
		self:Hide(); 
		return false;
	end;

	self.tooltip = CatalogShopTooltip;
	if C_Glue.IsOnGlueScreen() then
		self.tooltip:SetParent(GlueParent);
	else
		self.tooltip:SetParent(UIParent);
	end
	self.tooltip:SetFrameStrata("TOOLTIP");

	self.JustFinishedOrdering = false;
	self.JustOrderedBoost = false;
	self.justPurchasedProductID = nil;
	local useNativeForm = true;
	self:SetUseNativeForm(useNativeForm);

	self.HeaderFrame:Init(self.categoryIDs);
	self.ProductContainerFrame:Init();
	self.ProductDetailsContainerFrame:Init();
	self.ModelSceneContainerFrame:Init();

	self.HeaderFrame.SearchBox:SetScript("OnTextChanged", GenerateClosure(self.OnSearchTextChanged, self));
end

function CatalogShopMixin:InitVariables()
	self.FormatCurrencyStringShort = nil;
	self.FormatCurrencyStringLong = nil;

	self.ModelSceneData =
	{
		CurrentModelSceneData =
		{
			modelScene = nil,
			modelSceneID = nil,
			overrideModelSceneID = nil,
		},
		CurrentCardModelSceneData =
		{
			modelScene = nil,
			modelSceneID = nil,
			overrideModelSceneID = nil,
		},
	};

	self.CachedModelSceneOnMouseDownFunc = self.ModelSceneContainerFrame.MainModelScene.OnMouseDown;
	self.CachedModelSceneOnMouseUpFunc = self.ModelSceneContainerFrame.MainModelScene.OnMouseUp;
	self.CachedModelSceneOnMouseWheelFunc = self.ModelSceneContainerFrame.MainModelScene.OnMouseWheel;
end

function CatalogShopMixin:SetCurrentActor(actor)
	self.currentActor = actor;
end

function CatalogShopMixin:GetCurrentActor()
	return self.currentActor;
end

function CatalogShopMixin:SetCurrentModelSceneData(currentModelScene, currentModelSceneID, overrideModelSceneID)
	self.ModelSceneData.CurrentModelSceneData.modelScene = currentModelScene;
	self.ModelSceneData.CurrentModelSceneData.modelSceneID = currentModelSceneID;
	self.ModelSceneData.CurrentModelSceneData.overrideModelSceneID = overrideModelSceneID;
end

function CatalogShopMixin:GetCurrentModelSceneData()
	return self.ModelSceneData.CurrentModelSceneData;
end

function CatalogShopMixin:SetCurrentCardModelSceneData(currentModelScene, currentModelSceneID, overrideModelSceneID)
	self.ModelSceneData.CurrentCardModelSceneData.modelScene = currentModelScene;
	self.ModelSceneData.CurrentCardModelSceneData.modelSceneID = currentModelSceneID;
	self.ModelSceneData.CurrentCardModelSceneData.overrideModelSceneID = overrideModelSceneID;
end

function CatalogShopMixin:GetCurrentCardModelSceneData()
	return self.ModelSceneData.CurrentCardModelSceneData;
end

function CatalogShopMixin:FetchCurrentModelSceneData()
	return self.ModelSceneData;
end

function CatalogShopMixin:GetAppropriateTooltip()
	return self.tooltip;
end

function CatalogShopMixin:ShowTooltip(targetFrame, name, description, isToken)
	local tooltip = self:GetAppropriateTooltip();

	targetFrame = targetFrame or self;
	tooltip:SetOwner(targetFrame, "ANCHOR_BOTTOMLEFT", 0, 0);

	GameTooltip_AddNormalLine(tooltip, name);
	GameTooltip_AddBlankLineToTooltip(tooltip);
	GameTooltip_AddNormalLine(tooltip, description);

	tooltip:Show();
end

function CatalogShopMixin:HideTooltip()
	local tooltip = self:GetAppropriateTooltip();
	tooltip:Hide();
end

function CatalogShopMixin:HidePreviewFrames()
	self.WoWTokenContainerFrame:Hide();
	self.ToyContainerFrame:Hide();
	self.ModelSceneContainerFrame:Hide();
	self.ServicesContainerFrame:Hide();
	self.CrossGameContainerFrame:Hide();
end

function CatalogShopMixin:ShowLoadingScreen()
	if self.CatalogShopLoadingScreenFrame:IsShown() then
		return;
	end

	self.CatalogShopLoadingScreenFrame:Show();
	self.CatalogShopLoadingScreenFrame.Sign.StartLoad:Restart();
	self.CatalogShopLoadingScreenFrame.Sparkle.SparkleAnim:Restart();

	local shopGodRayTable = { effectID=186, offsetY=0, };
	self.CatalogShopLoadingScreenFrame.FxModelScene:AddDynamicEffect(shopGodRayTable, self);

	self.BackgroundContainer:Hide();
	self.ProductContainerFrame:Hide();
	self.HeaderFrame:Hide();
	self.CatalogShopDetailsFrame:Hide();
	self.ProductDetailsContainerFrame:Hide();
	self:HidePreviewFrames();
end

function CatalogShopMixin:HideLoadingScreen(fromError)
	if not self.CatalogShopLoadingScreenFrame:IsShown() then
		return;
	end
	self.CatalogShopLoadingScreenFrame:Hide();
	self.CatalogShopLoadingScreenFrame.FxModelScene:ClearEffects();

	if not fromError then
		self.BackgroundContainer:Show();
		self.ProductContainerFrame:Show();
		self.HeaderFrame:Show();
	end
end

function CatalogShopMixin:ShowUnavailableScreen()
	if self.CatalogShopUnavailableScreenFrame:IsShown() then
		return;
	end
	local fromError = true;
	self:HideLoadingScreen(fromError);

	self.ProductContainerFrame:Hide();
	self.ProductDetailsContainerFrame:Hide();
	self.CatalogShopDetailsFrame:Hide();
	self.CatalogShopUnavailableScreenFrame:Show();
end

function CatalogShopMixin:HideUnavailableScreen()
	self.CatalogShopUnavailableScreenFrame:Hide();

	self.BackgroundContainer:Show();
	self.ProductContainerFrame:Show();
	self.CatalogShopDetailsFrame:Show();
	self.HeaderFrame:Show();
end

function CatalogShopMixin:ShowAfterCheckout()
	self.ModelSceneContainerFrame:Show();
	self:SetAlpha(1);
end

function CatalogShopMixin:HideForCheckout()
	self.ModelSceneContainerFrame:Hide();
	self:SetAlpha(0);
end

function CatalogShopMixin:OnEvent_CatalogShop(event, ...)
	if event == "CATALOG_SHOP_DATA_REFRESH" then
		--... handle it
		self.categoryIDs = C_CatalogShop.GetAvailableCategoryIDs();
		self.HeaderFrame:SetCategories(self.categoryIDs);
	elseif event == "CATALOG_SHOP_REBUILD_SCROLL_BOX" then
		local resetSelection = false;
		self.ProductContainerFrame:UpdateProducts(resetSelection);
	elseif event == "CATALOG_SHOP_SPECIFIC_PRODUCT_REFRESH" then
		local productID = ...;
		if self.ProductContainerFrame:IsShown() then
			self.ProductContainerFrame:UpdateSpecificProduct(productID);
		elseif self.ProductDetailsContainerFrame:IsShown() then
			-- If the details frame is shown, update it with the specific product info
			self.ProductDetailsContainerFrame:UpdateSpecificProduct(productID);
		end
	elseif event =="CATALOG_SHOP_OPEN_SIMPLE_CHECKOUT" then
		--... handle it
	
	elseif event =="SIMPLE_CHECKOUT_CLOSED" then
		self:ShowAfterCheckout();

		if self.justPurchasedProductID then
			C_Timer.After(0.25, function ()
				EventRegistry:TriggerEvent("CatalogShop.CelebratePurchase", self.justPurchasedProductID);
				self.justPurchasedProductID = nil;
			end);
		end

	elseif event =="CATALOG_SHOP_FETCH_SUCCESS" then
		self:HideLoadingScreen();
		self:HideUnavailableScreen();
	elseif event =="CATALOG_SHOP_FETCH_FAILURE" then
		-- handle error
		self:HideLoadingScreen();
		self:ShowUnavailableScreen();

	elseif event =="CATALOG_SHOP_PURCHASE_SUCCESS" then
		local justPurchasedProductID = ...;

		if SimpleCheckout:IsShown() then
			-- Celebrate when the shop is shown again after the checkout window has been closed
			self.justPurchasedProductID = justPurchasedProductID;
		elseif self:IsShown() then
			EventRegistry:TriggerEvent("CatalogShop.CelebratePurchase", justPurchasedProductID);
		end
	elseif event == "CATALOG_SHOP_RESULT_ERROR" then
		-- TODO fix this C_StoreSecure call
		--self:ShowUnavailableScreen();
		local err, internalErr = C_CatalogShop.GetFailureInfo();
		self:OnError(err, true, internalErr);
	elseif ( event == "STORE_PURCHASE_ERROR" ) then
		-- TODO fix this C_StoreSecure call		
		--self:ShowUnavailableScreen();
		local err, internalErr = C_StoreSecure.GetFailureInfo();
		self:OnError(err, true, internalErr);
	elseif (event == "SUBSCRIPTION_CHANGED_KICK_IMMINENT") then
		if not SimpleCheckout:IsShown() then
			self:Hide();
			GlueDialog_Show("SUBSCRIPTION_CHANGED_KICK_WARNING");
		end
	elseif ( event == "TOKEN_MARKET_PRICE_UPDATED" ) then
		--local result = ...;
		--if (StoreFrame_GetSelectedCategoryID() == WOW_TOKEN_CATEGORY_ID) then
			--StoreFrame_SetCategory();
		--end
	elseif ( event == "TOKEN_STATUS_CHANGED" ) then
		--StoreFrame_CheckMarketPriceUpdates();
	elseif (event == "UI_SCALE_CHANGED") then
		FrameUtil.UpdateScaleForFitSpecific(self, self:GetWidth() + CatalogShopConstants.ScreenPadding.Horizontal, self:GetHeight() + CatalogShopConstants.ScreenPadding.Vertical);
	elseif (event == "CATALOG_SHOP_PMT_IMAGE_DOWNLOADED") then
		--	// Finish implementation when completing [WOW11-144188]
		--...handle it
	end
end

function CatalogShopMixin:IsLoading()
	-- TODO fix this C_StoreSecure call
	if ( not C_StoreSecure.HasProductList() ) then
		return true;
	end
	-- TODO fix this C_StoreSecure call
	if ( not C_StoreSecure.HasDistributionList() ) then
		return true;
	end
	-- can open the store UI while in queue, but in that state we don't ask for, nor need the purchase list
	-- TODO fix this C_StoreSecure call
	if ( not C_StoreSecure.HasPurchaseList() ) then
		if (C_Glue.IsOnGlueScreen()) then
			local _, _, wowConnectionState = C_Login.GetState();
			if ( wowConnectionState ~= LE_WOW_CONNECTION_STATE_IN_QUEUE ) then
				return true;
			end
		end
	end
	return false;
end

function CatalogShopMixin:OnShow()
	self:HideUnavailableScreen();
	self:ShowLoadingScreen();
	self:SetAttribute("isshown", true);

	if ( not C_Glue.IsOnGlueScreen() ) then
		CatalogShopOutbound.UpdateMicroButtons();
	else
		GlueParent_AddModalFrame(self);
	end
	FrameUtil.UpdateScaleForFitSpecific(self, self:GetWidth() + CatalogShopConstants.ScreenPadding.Horizontal, self:GetHeight() + CatalogShopConstants.ScreenPadding.Vertical);
	C_CatalogShop.OpenCatalogShopInteraction();
end

function CatalogShopMixin:OnHide()
	self:SetAttribute("isshown", false);

	if ( not C_Glue.IsOnGlueScreen() ) then
		CatalogShopOutbound.UpdateMicroButtons();
	else
		GlueParent_RemoveModalFrame(self);
		CatalogShopOutbound.UpdateDialogs();
	end

	local scrollBox = self.ProductContainerFrame.ProductsScrollBoxContainer.ScrollBox;
	if scrollBox then
		scrollBox:FlushDataProvider();
		self.ProductContainerFrame:SetSelectedProductInfo(nil);
	end

	scrollBox = self.ProductDetailsContainerFrame.DetailsProductContainerFrame.ProductsScrollBoxContainer.ScrollBox;
	if scrollBox then
		scrollBox:FlushDataProvider();
		self.ProductDetailsContainerFrame.DetailsProductContainerFrame:SetSelectedProductInfo(nil);
	end
	
	C_CatalogShop.CloseCatalogShopInteraction();
	SimpleCheckout:Hide();
	self:HidePreviewFrames();
	self.ProductDetailsContainerFrame:Hide();
	self.ForegroundContainer:Hide();
	self:SetCatalogShopLinkTag(nil);
	PlaySound(SOUNDKIT.CATALOG_SHOP_CLOSE_SHOP);
end

function CatalogShopMixin:GetUseNativeForm()
	return self.UseNativeForm;
end

function CatalogShopMixin:SetUseNativeForm(useNativeForm)
	self.UseNativeForm = useNativeForm;
end

function CatalogShopMixin:SetHideArmorSetting(playerArmorSetting)
	self.hidePlayerArmorSetting = playerArmorSetting;
end

function CatalogShopMixin:GetHideArmorSetting()
	return self.hidePlayerArmorSetting;
end

function CatalogShopMixin:GetCatalogShopLinkTag()
	return self.linkTag; -- ok to be nil
end

function CatalogShopMixin:SetCatalogShopLinkTag(linkTag)
	if self:IsShown() then
		self.HeaderFrame.CatalogShopNavBar:SelectCatorgyByLinkTag(linkTag);
		self.linkTag = nil;
	else
		self.linkTag = linkTag;
	end
end

function CatalogShopMixin:OnAttributeChanged(name, value)
	--Note - Setting attributes is how the external UI should communicate with this frame. That way their taint won't be spread to this code.
	if ( name == "action" ) then
		if ( value == "Show" ) then
			self:Show();
		elseif ( value == "Hide" ) then
			self:Hide();
		elseif ( value == "EscapePressed" ) then
			local handled = false;
			if ( self:IsShown() ) then
				if ( self.CatalogShopErrorFrame:IsShown() or StoreConfirmationFrame:IsShown() ) then
					--We eat the click, but don't close anything. Make them explicitly press "Cancel".
					handled = true;
				else
					self:Hide();
					handled = true;
				end
			end
			self:SetAttribute("escaperesult", handled);
		end
	elseif ( name == "selectsubscription" ) then
		self:SetCatalogShopLinkTag(CatalogShopConstants.CategoryLinks.Subscriptions);
	elseif ( name == "selectgametime" ) then
		-- legacy - game time is now subscriptions
		self:SetCatalogShopLinkTag(CatalogShopConstants.CategoryLinks.Subscriptions);
	elseif ( name == "settokencategory" ) then
		-- the WoW Token is in the Services Category
		self:SetCatalogShopLinkTag(CatalogShopConstants.CategoryLinks.Services);
	elseif ( name == "checkforfree" ) then
		-- legacy - this is no longer used
		--assertsafe(false, "ASSERT - for Cash Shop 2.0 this is a no-op.  If you get this error, contact the Shop Team Engineers.");
	elseif ( name == "opengamescategory" ) then
		self:Show();
		self:SetCatalogShopLinkTag(CatalogShopConstants.CategoryLinks.GameUpgrades);
	elseif ( name == "setgamescategory" ) then
		self:SetCatalogShopLinkTag(CatalogShopConstants.CategoryLinks.GameUpgrades);
	elseif ( name == "setservicescategory" ) then
		self:SetCatalogShopLinkTag(CatalogShopConstants.CategoryLinks.Services);
	elseif ( name == "selectboost") then
		self:SetCatalogShopLinkTag(CatalogShopConstants.CategoryLinks.Services);
	end
end

function CatalogShopMixin:Leave()
	--... handle leaving
	self:Hide();
end

function CatalogShopMixin:IsProductCompletelyOwned(productInfo)
	-- TODO: convert this check
	return false;--entryInfo.sharedData.eligibility == Enum.PurchaseEligibility.Owned;
end

function CatalogShopMixin:ShowError(title, desc, urlIndex, needsAck)
	self.CatalogShopErrorFrame:ShowError(title, desc, urlIndex, needsAck);
end

function CatalogShopMixin:OnError(errorID, needsAck, internalErr)
	local title, msg, link = ErrorLookupInterface.GetErrorMessage(errorID);

	if ( IsGMClient() and not HideGMOnly() ) then
		self:ShowError(title.." ("..internalErr..")", msg, link, needsAck);
	else
		self:ShowError(title, msg, link, needsAck);
	end
end

function CatalogShopMixin:SetAlert(title, desc)
	self.Notice.Title:SetText(title);
	self.Notice.Description:SetText(desc);
	self.Notice:Show();

	if ( StoreConfirmationFrame ) then
		StoreConfirmationFrame:Raise(); --Make sure the confirmation is above this alert frame.
	end
end

function CatalogShopMixin:HideAlert()
	self.Notice:Hide();
end

function CatalogShopMixin:PurchaseProduct()
	local productInfo = self:GetSelectedProductInfo();

	local completelyOwned = self:IsProductCompletelyOwned(productInfo);
	if completelyOwned then
		self:OnError(Enum.StoreError.AlreadyOwned, false, "FakeOwned");
	elseif C_CatalogShop.PurchaseProduct(productInfo.catalogShopProductID) then
		-- TODO - fix this
	--else
		-- TODO - fix this
		--if (productInfo and productInfo.sharedData.productDecorator == Enum.BattlepayProductDecorator.Expansion) then
			--self:OnError(Enum.StoreError.AlreadyOwned, false, "Expansion");
		--end
	end
end

function CatalogShopMixin:HideProductDetails()
	-- clear the product we had selected for the details frame
	self.ProductDetailsContainerFrame.DetailsProductContainerFrame:SetSelectedProductInfo(nil);
	local productInfo = self.ProductContainerFrame:GetSelectedProductInfo();
	local showDetails = false;
	self:ToggleProductDetails(showDetails, productInfo);
end

function CatalogShopMixin:ShowProductDetails()
	local productInfo = self:GetSelectedProductInfo();
	-- Dont show details if nothing is selected
	if not productInfo then
		return
	end
	local showDetails = true;
	self:ToggleProductDetails(showDetails, productInfo);
end

function CatalogShopMixin:AcceptError()
	if ( self.CatalogShopErrorFrame:ErrorNeedsAck() ) then
		-- TODO fix this C_StoreSecure call
		C_StoreSecure.AckFailure();
	end
	StoreFrame.CatalogShopErrorFrame:Hide();
	PlaySound(SOUNDKIT.CATALOG_SHOP_SELECT_GENERIC_UI_BUTTON);
end

function CatalogShopMixin:WebsiteError()
end

function CatalogShopMixin:OnProductSelected(data)
	-- Background texture fills the whole window and is behind everything
	local backgroundTexture = data and data.backgroundTexture or nil;
	if backgroundTexture and backgroundTexture ~= "" then
		self.BackgroundContainer:SetBackgroundTexture(backgroundTexture);
	else
		self.BackgroundContainer:SetBackgroundTexture(CatalogShopConstants.Default.PreviewBackgroundTexture);
	end

	-- Foreground texture fills the whole window and is in front of the background texture
	local foregroundTexture = data and data.foregroundTexture or nil;
	if foregroundTexture and foregroundTexture ~= "" then
		self.ForegroundContainer.Foreground:SetAtlas(foregroundTexture);
		self.ForegroundContainer:Show();
	else
		self.ForegroundContainer:Hide();
	end

	-- Show the right side details frame if our product container frame is shown OR if the selected product is a bundle (enables purchase and details)
	local selectedProductInfo = CatalogShopFrame:GetSelectedProductInfo();
	self.CatalogShopDetailsFrame:SetShown(self.ProductContainerFrame:IsShown() or (selectedProductInfo and selectedProductInfo.isBundle));
end

function CatalogShopMixin:OnNoProductsSelected()
	self.BackgroundContainer:SetBackgroundTexture(CatalogShopConstants.NoResults.BackgroundTexture);
	self:HidePreviewFrames();
	self.CatalogShopDetailsFrame:Hide();
end

function CatalogShopMixin:OnCategorySelected(categoryID)
	-- Close the details frame if it's open
	local showDetailsFrame = false;
	local productInfo = nil;
	self:ToggleProductDetails(showDetailsFrame, productInfo);

	self.ProductContainerFrame:OnCategorySelected(categoryID);
end

function CatalogShopMixin:ToggleProductDetails(showDetails, productInfo)
	self.ProductContainerFrame:SetShown(not showDetails);
	self.ProductDetailsContainerFrame:SetShown(showDetails);
	self.CatalogShopDetailsFrame:SetShown(not showDetails);
	self.CatalogShopDetailsFrame.ButtonContainer:SetShown(not showDetails);
	if showDetails then
		self.ProductDetailsContainerFrame:UpdateProductInfo(productInfo);
	end
	self.CatalogShopDetailsFrame:MarkDirty();
end

local RED_TEXT_SECONDS_THRESHOLD = 3600;
function CatalogShopMixin:FormatTimeLeft(secondsRemaining, formatter)
	local color = (secondsRemaining > RED_TEXT_SECONDS_THRESHOLD) and WHITE_FONT_COLOR or RED_FONT_COLOR;
	local text = formatter:Format(secondsRemaining);
	return color:WrapTextInColorCode(text);
end

function CatalogShopMixin:GetProductInfo(productID)
	local productInfo = C_CatalogShop.GetProductInfo(productID)
	if not productInfo then
		return nil;
	end

	local productDisplayInfo = C_CatalogShop.GetCatalogShopProductDisplayInfo(productInfo.catalogShopProductID);
	if not productDisplayInfo then
		error("CatalogShopMixin:GetProductInfo : product display info not found!")
		return productInfo;
	end
		
	local defaultPreviewModelSceneID = productDisplayInfo.defaultPreviewModelSceneID;
	local overridePreviewModelSceneID = productDisplayInfo.overridePreviewModelSceneID or nil;
	local defaultCardModelSceneID = productDisplayInfo.defaultCardModelSceneID;
	local overrideCardModelSceneID = productDisplayInfo.overrideCardModelSceneID or nil;
	local defaultWideCardModelSceneID = productDisplayInfo.defaultWideCardModelSceneID;
	local overrideWideCardModelSceneID = productDisplayInfo.overrideWideCardModelSceneID or nil;

	-- get preview scene display data
	productInfo.sceneDisplayData = CatalogShopUtil.TranslateProductInfoToProductDisplayData(productDisplayInfo, defaultPreviewModelSceneID, overridePreviewModelSceneID);

	-- get small card display data - should always be here
	productInfo.cardDisplayData = CatalogShopUtil.TranslateProductInfoToProductDisplayData(productDisplayInfo, defaultCardModelSceneID, overrideCardModelSceneID);

	-- get wide card display data if set
	if defaultWideCardModelSceneID then
		productInfo.wideCardDisplayData = CatalogShopUtil.TranslateProductInfoToProductDisplayData(productDisplayInfo, defaultWideCardModelSceneID, overrideWideCardModelSceneID);
	end
				
	-- get bundle children display data
	if productDisplayInfo.productType == CatalogShopConstants.ProductType.Bundle then
		local childrenProductData = C_CatalogShop.GetProductIDsForBundle(productID);
		if productInfo.sceneDisplayData then
			productInfo.sceneDisplayData.bundleChildrenDisplayData = {};
		end
		if productInfo.cardDisplayData then
			productInfo.cardDisplayData.bundleChildrenDisplayData = {};
		end
		if productInfo.wideCardDisplayData then
			productInfo.wideCardDisplayData.bundleChildrenDisplayData = {};
		end
		for _, childData in ipairs(childrenProductData) do
			local childProductDisplayInfo = C_CatalogShop.GetCatalogShopProductDisplayInfo(childData.childProductID)
			-- If this product has an otherProductGameType then we can't use this product in our model scene (it's from another game)
			if childProductDisplayInfo.otherProductGameType == nil then
				if productInfo.sceneDisplayData then
					local childProductData = CatalogShopUtil.TranslateProductInfoToProductDisplayData(childProductDisplayInfo, defaultPreviewModelSceneID, overridePreviewModelSceneID)
					childProductData.displayOrder = childData.displayOrder or 999;
					-- Special case for bundle children (reminder a product could be in a bundle AND not in a bundle in the storefront)
					-- We don't want to adjust the model scene's camera based on child data, so we are nilling it out of our childProductData
					childProductData.cameraDisplayData = nil;
					table.insert(productInfo.sceneDisplayData.bundleChildrenDisplayData, childProductData);
				end
				if productInfo.cardDisplayData then
					local childProductData = CatalogShopUtil.TranslateProductInfoToProductDisplayData(childProductDisplayInfo, defaultCardModelSceneID, overrideCardModelSceneID)
					childProductData.displayOrder = childData.displayOrder or 999;
					-- Special case for bundle children (reminder a product could be in a bundle AND not in a bundle in the storefront)
					-- We don't want to adjust the model scene's camera based on child data, so we are nilling it out of our childProductData
					childProductData.cameraDisplayData = nil;
					table.insert(productInfo.cardDisplayData.bundleChildrenDisplayData, childProductData);
				end
				if productInfo.wideCardDisplayData then
					local childProductData = CatalogShopUtil.TranslateProductInfoToProductDisplayData(childProductDisplayInfo, defaultWideCardModelSceneID, overrideWideCardModelSceneID)
					childProductData.displayOrder = childData.displayOrder or 999;
					-- Special case for bundle children (reminder a product could be in a bundle AND not in a bundle in the storefront)
					-- We don't want to adjust the model scene's camera based on child data, so we are nilling it out of our childProductData
					childProductData.cameraDisplayData = nil;
					table.insert(productInfo.wideCardDisplayData.bundleChildrenDisplayData, childProductData);
				end
			end
		end
	end

	return productInfo;
end

function CatalogShopMixin:GetSelectedProductInfo()
	return self.ProductContainerFrame:GetSelectedProductInfo();
end

function CatalogShopMixin:GetCurrencyInfo()
	-- TODO fix this C_StoreSecure call
	local currencyInfo = C_StoreSecure.GetCurrencyInfo();
	local info = {};
	if currencyInfo then
		local currencyRegion = currencyInfo.sharedData.regionID;
		self.FormatCurrencyStringShort = currencyInfo.sharedData.formatShort;
		self.FormatCurrencyStringLong = currencyInfo.sharedData.formatLong;
		info = currencySpecific[currencyRegion] or currencySpecific[REGION_US];
		if currencyInfo.sharedData.licenseAcceptText ~= "" then
			info.licenseAcceptText = currencyInfo.sharedData.licenseAcceptText;
		end;
		info.requireLicenseAccept = currencyInfo.sharedData.requireLicenseAccept;
		info.browseHasStar = currencyInfo.sharedData.browseHasStar;
		info.hideBrowseNotice = currencyInfo.sharedData.hideBrowseNotice;
		if info.hideBrowseNotice then
			info.browseNotice = ""
		end
		info.hideConfirmationBrowseNotice = currencyInfo.sharedData.hideConfirmationBrowseNotice;
	end
	
	return info;
end

function CatalogShopMixin:ShowPurchaseSent()
	self.PurchaseSentFrame.Title:SetText(BLIZZARD_STORE_PURCHASE_SENT);
	self.PurchaseSentFrame.OkayButton:SetText(OKAY);

	self.PurchaseSentFrame:Show();

	if ( StoreConfirmationFrame ) then
		StoreConfirmationFrame:Raise();
	end
end

function CatalogShopMixin:HidePurchaseSent()
	self.JustFinishedOrdering = false;
	self.PurchaseSentFrame:Hide();
end

function CatalogShopMixin:HasFreeBagSlots()
	for i = BACKPACK_CONTAINER, NUM_BAG_SLOTS do
		local freeSlots, bagFamily = C_Container.GetContainerNumFreeSlots(i);
		if ( freeSlots > 0 and bagFamily == 0 ) then
			return true;
		end
	end
	return false;
end


function CatalogShopMixin:OnSearchTextChanged(editBox, userInput)
	SearchBoxTemplate_OnTextChanged(self.HeaderFrame.SearchBox);

	local initializing = (self.searchText == nil);

	local text = editBox:GetText();
	if text == self.searchText then
		return;
	end

	self.searchText = text;

	if initializing then
		return;
	end

	local resetSelection = text and string.len(text) > 0 or false;
	self.ProductContainerFrame:UpdateProducts(resetSelection);
end

function CatalogShopMixin:ClearSearchBox()
	self.HeaderFrame.SearchBox:SetText("");
end

----------------------------------------------------------------------------------
-- CatalogShopProductDetailsFrameMixin
----------------------------------------------------------------------------------
CatalogShopProductDetailsFrameMixin = {};
function CatalogShopProductDetailsFrameMixin:OnLoad()
	EventRegistry:RegisterCallback("CatalogShopModel.OnProductSelectedAfterModel", self.SetDetailsFrameProductInfo, self);
	EventRegistry:RegisterCallback("CatalogShopModel.OnProductSelectEarlyOut", self.SetDetailsFrameProductInfo, self);
	EventRegistry:RegisterCallback("CatalogShop.OnProductInfoChanged", self.OnProductInfoChanged, self);
	EventRegistry:RegisterCallback("CatalogShop.OnBundleChildSelected", self.SetDetailsFrameProductInfo, self);
	self.currentProductInfo = nil;
end

function CatalogShopProductDetailsFrameMixin:SetDetailsFrameProductInfo(productInfo)
	if productInfo == self:GetDetailsFrameProductInfo() then
		return;
	end
	self.currentProductInfo = productInfo;
	self:UpdateState();
end

function CatalogShopProductDetailsFrameMixin:GetDetailsFrameProductInfo()
	return self.currentProductInfo;
end

function CatalogShopProductDetailsFrameMixin:UpdateState()
	CatalogShopFrame:HideLoadingScreen();
	CatalogShopFrame.CatalogShopDetailsFrame:SetShown(true);

	local selectedProductInfo = self:GetDetailsFrameProductInfo();
	local displayInfo = C_CatalogShop.GetCatalogShopProductDisplayInfo(selectedProductInfo.catalogShopProductID);
	-- update state based on product info

	self.ProductName:SetText(selectedProductInfo.name);

	local descriptionStr = CatalogShopUtil.GetDescriptionText(selectedProductInfo);
	if (descriptionStr == "") then
		self.ProductDescription:SetShown(false);
	else
		self.ProductDescription:SetShown(true);
		self.ProductDescription:SetText(descriptionStr);
	end

	local productTypeStr = CatalogShopUtil.GetTypeText(selectedProductInfo);
	if (productTypeStr) then
		self.ProductType:SetShown(true);
		self.ProductType:SetText(productTypeStr);
	else
		self.ProductType:SetShown(false);
	end

	local isBundleChild = selectedProductInfo.isBundleChild;
	self.LegalDisclaimerText:SetShown(not isBundleChild);

	local function onHyperlinkClicked(frame, link, text, button)
		C_CatalogShop.OnLegalDisclaimerClicked(selectedProductInfo.catalogShopProductID);
	end
	self:SetScript("OnHyperlinkClick", onHyperlinkClicked);

	local isTokenOnGlues = (C_Glue.IsOnGlueScreen() and displayInfo.productType == CatalogShopConstants.ProductType.Token);
	local isPurchasable = (not isTokenOnGlues and not selectedProductInfo.isFullyOwned);

	self.ButtonContainer.PurchaseButton:SetText(selectedProductInfo.price);
	self.ButtonContainer.PurchaseButton:SetEnabled(isPurchasable);

	-- Adjust for the text field explaining you need to be logged in to buy a token
	self.ButtonContainer.NoPriceInGlues:SetShown(isTokenOnGlues);
	if isTokenOnGlues then
		self.ButtonContainer:SetSize(320, 80);
	else
		self.ButtonContainer:SetSize(320, 50);
	end

	self:MarkDirty();
end

-- This function is called when the main frame's product changes, and we want to verify that we're being told to be set to that frame's product only in this function.
-- This may read a bit confusing but it's because elements outside this heirarchy affect the CatalogShopFrame's seleted product and this function reacts to events fired
-- by anyone so extra guards are necessary
function CatalogShopProductDetailsFrameMixin:OnProductInfoChanged(productInfo)
	local selectedProductInfo = CatalogShopFrame:GetSelectedProductInfo();

	-- if the catalog shop frame's selected product was changed, update ourself
	if productInfo and selectedProductInfo and (productInfo.catalogShopProductID == selectedProductInfo.catalogShopProductID) then
		self:SetDetailsFrameProductInfo(productInfo);
	end
end


----------------------------------------------------------------------------------
-- BackgroundContainerMixin
----------------------------------------------------------------------------------
BackgroundContainerMixin = {};
function BackgroundContainerMixin:OnLoad()
	self.Background_1:SetAlpha(1);
	self.Background_2:SetAlpha(0);

	self.currentBackground = self.Background_1;
	self.nextBackground = self.Background_2;
	self.nextFadeIn = self.FadeInBackground_2;

	self.FadeInBackground_1:SetScript("OnFinished", function()
		self.currentBackground = self.Background_1;
		self.nextBackground = self.Background_2;
		self.nextFadeIn = self.FadeInBackground_2;
	end);

	self.FadeInBackground_2:SetScript("OnFinished", function()
		self.currentBackground = self.Background_2;
		self.nextBackground = self.Background_1;
		self.nextFadeIn = self.FadeInBackground_1;
	end);
end

function BackgroundContainerMixin:SetBackgroundTexture(backgroundAtlas)
	if backgroundAtlas then
		self.currentBackground:SetDrawLayer("BACKGROUND", 1);
		self.nextBackground:SetDrawLayer("BACKGROUND", 2);
		self.nextBackground:SetAtlas(backgroundAtlas);
		self.nextFadeIn:Play();
	end
end
