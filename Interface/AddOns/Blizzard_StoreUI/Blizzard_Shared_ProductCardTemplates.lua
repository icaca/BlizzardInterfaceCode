
local BATTLEPAY_SPLASH_BANNER_TEXT_FEATURED = 0;
local BATTLEPAY_SPLASH_BANNER_TEXT_DISCOUNT = 1;
local BATTLEPAY_SPLASH_BANNER_TEXT_NEW = 2;

local SEE_YOU_LATER_BUNDLE_PRODUCT_ID = 488;

local DEFAULT_ICON_NAME = "Interface\\Icons\\INV_Misc_Note_02";

local function GetFaqNydusLink(entryInfo)
	local currencyInfo = StoreFrame_CurrencyInfo();
	if not currencyInfo then
		return nil;
	end

	-- Check for VAS FAQ link
	local vasServiceType = C_StoreSecure.GetVasServiceType(entryInfo.productID);
	if vasServiceType and currencyInfo.vasDisclaimerData and currencyInfo.vasDisclaimerData[vasServiceType] and currencyInfo.vasDisclaimerData[vasServiceType].disclaimer then
		local text = currencyInfo.vasDisclaimerData[vasServiceType].disclaimer;
		return LinkUtil.ExtractNydusLink(text);
	end

	-- Check for boost FAQ link
	local productDecorator = entryInfo.sharedData.productDecorator;
	if productDecorator and productDecorator == Enum.BattlepayProductDecorator.Boost and currencyInfo.boostDisclaimerText then
		local text = currencyInfo.boostDisclaimerText;
		return LinkUtil.ExtractNydusLink(text);
	end

	return nil;
end

--------------------------------------------------
-- DEFAULT STORE CARD MIXIN
StoreCardMixin = {};
function StoreCardMixin:OnLoad()
	self.ProductName:SetSpacing(3);
	self.CurrentPrice:SetTextColor(1.0, 0.82, 0);
	self:Layout();

	-- the caching of NormalPrice's anchor HAS to be done after Layout
	self.basePoint = { self.NormalPrice:GetPoint(1) };
end

function StoreCardMixin:OnShow()
	self:UpdateState();
end

function StoreCardMixin:OnEnter()
	local entryInfo = self:GetEntryInfo();
	local productDecorator = entryInfo.sharedData.productDecorator;
	local canBuyHere = self:CanBuyHere(entryInfo);
	if canBuyHere then
		self.HighlightTexture:SetShown(StoreFrame_GetSelectedEntryID() ~= self:GetID());
		self:UpdateMagnifier();
	end
	self:ShowTooltip();

	local enableHighlight = self:GetID() ~= StoreFrame_GetSelectedEntryID() and canBuyHere;
	self.HighlightTexture:SetAlpha(enableHighlight and 1 or 0);
end

function StoreCardMixin:OnLeave()
	self.HighlightTexture:Hide();
	self.Magnifier:Hide();
	StoreTooltip:Hide();
end

function StoreCardMixin:OnClick()
	local entryInfo = self:GetEntryInfo();
	if not self:CanBuyHere(entryInfo) then
		return;
	end

	if IsShiftKeyDown() then
		local vasFaqUrl = GetFaqNydusLink(entryInfo);
		if vasFaqUrl then
			GetURLIndexAndLoadURL(self, vasFaqUrl);
			return;
		end
	end

	if not StoreProductCard_CheckShowStorePreviewOnClick(self) then
		StoreFrame_SetSelectedEntryID(self:GetID());
		StoreProductCard_UpdateAllStates();

		StoreFrame_UpdateBuyButton();
		PlaySound(SOUNDKIT.UI_IG_STORE_PAGE_NAV_BUTTON);
	end
end

function StoreCardMixin:OnMouseDown(...)
	self.ModelScene:OnMouseDown(...);
end

function StoreCardMixin:OnMouseUp(...)
	self.ModelScene:OnMouseUp(...);
end

function StoreCardMixin:IsRestrictedVASProduct(entryInfo)
	return entryInfo.sharedData.productDecorator == Enum.BattlepayProductDecorator.VasService and not C_Glue.IsOnGlueScreen();
end

function StoreCardMixin:CanBuyHere(entryInfo)
	if self:IsRestrictedVASProduct(entryInfo) then
		return false;
	end

	return entryInfo.sharedData.buyableHere;
end

function StoreCardMixin:InitMagnifier()
	-- override this in your mixin to determine how the magnifier is initialized, if needed
	self.Magnifier:Hide();
end

function StoreCardMixin:UpdateMagnifier()
	self.Magnifier:SetShown(self:ShouldShowMagnifyingGlass());
end

function StoreCardMixin:ShouldShowMagnifyingGlass()
	local entryInfo = self:GetEntryInfo();
	return entryInfo and #entryInfo.sharedData.cards > 0;
end

function StoreCardMixin:GetTooltipOffsets()
	local rightPos = self:GetRight();
	local rightDist = GetScreenWidth() - rightPos;

	local point;
	local rpoint;
	local x;
	local y = self:GetTop();

	if rightDist < StoreTooltip:GetWidth() then
		x = self:GetLeft() + 4;
		point = "LEFT";
		rpoint = "BOTTOMRIGHT";
	else
		x = self:GetRight() - 4;
		point = "RIGHT";
		rpoint = "BOTTOMLEFT"
	end

	return x, y, point, rpoint;
end

function StoreCardMixin:ShouldAddDiscountInformationToTooltip(entryInfo)
	return false;
end

function StoreCardMixin:GetEntryInfo(entryID)
	if entryID then
		return C_StoreSecure.GetEntryInfo(entryID);
	else
		return C_StoreSecure.GetEntryInfo(self:GetID());
	end
end

function StoreCardMixin:ShouldAddBundleInformationToTooltip(entryInfo)
	-- For now, we're not displaying this part of the tooltip.
	if not entryInfo then
		return false;
	end
	return #entryInfo.sharedData.deliverables > 0 and C_StoreSecure.IsDynamicBundle(entryInfo.productID);
end

function StoreCardMixin:AppendBundleInformationToTooltipDescription(entryInfo, tooltipDescription)
	if self:ShouldAddBundleInformationToTooltip(entryInfo) then
		tooltipDescription = tooltipDescription..BLIZZARD_STORE_BUNDLE_TOOLTIP_HEADER;
		for i, deliverableInfo in ipairs(entryInfo.sharedData.deliverables) do
			if deliverableInfo.owned then
				tooltipDescription = tooltipDescription..BLIZZARD_STORE_BUNDLE_TOOLTIP_OWNED_DELIVERABLE:format(deliverableInfo.name);
			else
				tooltipDescription = tooltipDescription..BLIZZARD_STORE_BUNDLE_TOOLTIP_UNOWNED_DELIVERABLE:format(deliverableInfo.name);
			end
		end
	end

	return tooltipDescription;
end

function StoreCardMixin:GetTooltipDescription()
	local entryInfo = self:GetEntryInfo();
	local description = self.productTooltipDescription or entryInfo.sharedData.description or "";

	description = self:AppendBundleInformationToTooltipDescription(entryInfo, description);

	if self:ShouldAddDiscountInformationToTooltip(entryInfo) then
		local discounted, discountPercentage, discountDollars, discountCents = StoreFrame_GetDiscountInformation(entryInfo.sharedData);
		if discounted then
			if description then
				description = description..(BLIZZARD_STORE_BUNDLE_DISCOUNT_TOOLTIP_ADDENDUM:format(discountPercentage, StoreFrame_CurrencyFormatShort(discountDollars, discountCents)));
			else
				description = BLIZZARD_STORE_BUNDLE_DISCOUNT_TOOLTIP_REPLACEMENT:format(discountPercentage, StoreFrame_CurrencyFormatShort(discountDollars, discountCents));
			end
		end
	end

	if self:CanBuyHere(entryInfo) then
		-- Check if we have a FAQ URL
		if GetFaqNydusLink(entryInfo) then
			description = description.."\n\n"..BLIZZARD_STORE_CLICK_TO_OPEN_FAQ;
		end
	else
		description = BLIZZARD_STORE_LOG_OUT_TO_PURCHASE_THIS_PRODUCT;
	end

	return strtrim(description, "\n\r"); -- Ensure we don't end the description with a new line.
end

function StoreCardMixin:ShowTooltip()
	if not self.Description then
		local x, y, point, rpoint = self:GetTooltipOffsets();
		if point == "LEFT" then
			point = "BOTTOMRIGHT";
			rpoint = "TOPLEFT";
			x = 4;
		else
			point = "BOTTOMLEFT";
			rpoint = "TOPRIGHT";
			x = -4;
		end
		StoreTooltip:ClearAllPoints();
		StoreTooltip:SetPoint(point, self, rpoint, x, 0);

		local entryInfo = self:GetEntryInfo();
		local description = self:GetTooltipDescription();
		local name = entryInfo.sharedData.name:gsub("|n", " ");
		if not self:CanBuyHere(entryInfo) then
			name = "";
		end

		StoreTooltip_Show(name, description, entryInfo.sharedData.productDecorator == Enum.BattlepayProductDecorator.WoWToken);
	end
end

function StoreCardMixin:UpdateState()
	if (not self:IsShown()) then
		return;
	end
	local cardEntryID = self:GetID();
	local selectedEntryID = StoreFrame_GetSelectedEntryID();
	local isShown = (cardEntryID ~= 0) and cardEntryID == selectedEntryID;
	self.SelectedTexture:SetShown(isShown);
end

function StoreCardMixin:Layout()
	-- the StoreCardMixin should never be instantiated, rather your new ProductCard should mix this in.
	-- and you will need to provide your own custom Layout function.
	assert(false, "StoreCardMixin:Layout MUST be overwritten.");
end

function StoreCardMixin:GetCurrencyFormat(currencyInfo)
	return currencyInfo.formatShort;
end

function StoreCardMixin:SetDiscountText(discountPercentage)
	self.DiscountText:SetWidth(50);
	self.DiscountText:SetText(BLIZZARD_STORE_DISCOUNT_TEXT_FORMAT:format(discountPercentage));
end

function StoreCardMixin:ShouldEnableBuyButton(entryInfo)
	local owned = StoreFrame_IsCompletelyOwned(entryInfo) or StoreFrame_IsPartiallyOwned(entryInfo);
	local buyableHere = entryInfo.sharedData.buyableHere;
	return buyableHere and not owned;
end

function StoreCardMixin:UpdateBannerText(discounted, discountPercentage, displayInfo)
end

function StoreCardMixin:SetDefaultCardTexture()
	--override this in other product cards
end

function StoreCardMixin:SetCardTexture(entryInfo)
	if entryInfo.sharedData.overrideBackground then
		self.Card:SetAtlas(entryInfo.sharedData.overrideBackground, true);
		self.Card:SetTexCoord(0, 1, 0, 1);
	else
		self:SetDefaultCardTexture();
	end
end

function StoreCardMixin:UpdateDiscount(currencyInfo, entryInfo, currencyFormat)
	local discounted, discountPercentage = StoreFrame_GetDiscountInformation(entryInfo.sharedData);

	local completelyOwned = StoreFrame_IsCompletelyOwned(entryInfo);
	if completelyOwned then
		self.Checkmark:Show();
	elseif discountPercentage and entryInfo.productID ~= SEE_YOU_LATER_BUNDLE_PRODUCT_ID then
		self:SetDiscountText(discountPercentage);
		if StoreFrame_HasPriceData(entryInfo.productID) then
			local stringWidth = self.DiscountText:GetStringWidth();
			self.DiscountLeft:SetPoint("RIGHT", self.DiscountRight, "LEFT", -stringWidth, 0);
			self.DiscountMiddle:Show();
			self.DiscountLeft:Show();
			self.DiscountRight:Show();
			self.DiscountText:Show();
		end
	end
	self:UpdateBannerText(discounted, discountPercentage, entryInfo.sharedData);
end

function StoreCardMixin:UpdatePricing(currencyInfo, entryInfo, currencyFormat)
	local discounted, discountPercentage = StoreFrame_GetDiscountInformation(entryInfo.sharedData);

	self.CurrentPrice:SetText(StoreFrame_GetProductPriceText(entryInfo, currencyFormat));
	self.NormalPrice:SetText(currencyFormat(entryInfo.sharedData.normalDollars, entryInfo.sharedData.normalCents));

	if bit.band(entryInfo.sharedData.flags, Enum.BattlepayDisplayFlags.HiddenPrice) == Enum.BattlepayDisplayFlags.HiddenPrice then
		self.NormalPrice:Hide();
		self.SalePrice:Hide();
		self.Strikethrough:Hide();
		self.CurrentPrice:Hide();
	elseif discounted then
		self:ShowDiscount(StoreFrame_GetProductPriceText(entryInfo, currencyFormat));
	else
		self.NormalPrice:Hide();
		self.SalePrice:Hide();
		self.Strikethrough:Hide();
		self.CurrentPrice:Show();
	end
end

function StoreCardMixin:UpdateBuyButton(currencyInfo, entryInfo, currencyFormat)
end

function StoreCardMixin:UpdateModel(entryInfo, forceModelUpdate)
	if self:ShouldShowModel(entryInfo) then
		local showShadows = self:ShouldModelShowShadows();
		StoreProductCard_ShowModel(self, entryInfo, showShadows, forceModelUpdate);
	else
		StoreProductCard_HideModel(self);
	end
end

function StoreCardMixin:SetCardOwned(owned)

	if owned then
		self.ModelScene:SetDesaturation(0.8);
		self.Card:SetDesaturation(0.8);
		self.Card:SetAlpha(0.5);
		self.Icon:SetDesaturation(0.8);
		self.Icon:SetAlpha(0.5);
		self.ProductName:SetAlpha(0.5);
	else
		self.ModelScene:SetDesaturation(0);
		self.Card:SetDesaturation(0);
		self.Card:SetAlpha(1);
		self.Icon:SetDesaturation(0);
		self.Icon:SetAlpha(1);
		self.ProductName:SetAlpha(1);
	end
end

function StoreCardMixin:SetDisabledOverlayShown(showDisabledOverlay)
	--disabled overlay is currently only used by small cards
	self.DisabledOverlay:SetShown(false);
end

function StoreCardMixin:ShowDiscount(discountText)
	self.SalePrice:SetText(discountText);
	self.NormalPrice:SetTextColor(0.8, 0.66, 0);

	self.CurrentPrice:Hide();
	self.NormalPrice:Show();
	self.SalePrice:Show();
	self.Strikethrough:Show();
end

function StoreCardMixin:SetupWoWToken(entryInfo)
end

function StoreCardMixin:SetupDescription(entryInfo)
end

function StoreCardMixin:SetDisclaimerText(entryInfo)
end

function StoreCardMixin:ShouldModelShowShadows()
	return true;
end

function StoreCardMixin:SetStyle(entryInfo)
end

function StoreCardMixin:ShouldShowIcon(entryInfo)
	local showAnyModel = self:ShouldShowModel(entryInfo);
	local tryToShowTexture = not showAnyModel or bit.band(entryInfo.sharedData.flags, Enum.BattlepayDisplayFlags.CardAlwaysShowsTexture) == Enum.BattlepayDisplayFlags.CardAlwaysShowsTexture;

	return tryToShowTexture;
end

function StoreCardMixin:ShouldShowModel(entryInfo)
	local hasAnyCard = #entryInfo.sharedData.cards > 0;
	local allowShowingModel = bit.band(entryInfo.sharedData.flags, Enum.BattlepayDisplayFlags.CardDoesNotShowModel) ~= Enum.BattlepayDisplayFlags.CardDoesNotShowModel;
	local showAnyModel = allowShowingModel and hasAnyCard;

	return showAnyModel;
end

function StoreCardMixin:GetDefaultIconName()
	return DEFAULT_ICON_NAME;
end

function StoreCardMixin:ShowIcon(displayData)
	local icon = displayData.texture or self:GetDefaultIconName();
	local overrideTexture = displayData.overrideTexture;
	local useSquareBorder = bit.band(displayData.flags, Enum.BattlepayDisplayFlags.UseSquareIconBorder) == Enum.BattlepayDisplayFlags.UseSquareIconBorder;
	local useIconBorderWithOverrideTexture = bit.band(displayData.flags, Enum.BattlepayDisplayFlags.UseIconBorderWithOverrideTexture) == Enum.BattlepayDisplayFlags.UseIconBorderWithOverrideTexture;
	local iconItemQuantity = displayData.itemQuantity;

	self.IconBorder:Show();
	self.Icon:Show();
	self.ItemQuantity:Hide();
	self.ItemQuantityCircle:Hide();

	self.Icon:ClearAllPoints();
	self.Icon:SetPoint("CENTER", self, "TOP", 0, -68);

	if overrideTexture then
		self.Icon:SetAtlas(overrideTexture, true);
	else
		self.Icon:SetSize(62, 62);

		if useSquareBorder then
			self.Icon:SetTexture(icon);
		else
			SetPortraitToTexture(self.Icon, icon);
		end
	end

	if (not overrideTexture) or useIconBorderWithOverrideTexture then
		if useSquareBorder then -- square icon borders use atlases
			self.IconBorder:SetAtlas("collections-itemborder-collected");
			self.IconBorder:SetTexCoord(0, 1, 0, 1);
			self.IconBorder:SetSize(80, 81);
			self.IconBorder:ClearAllPoints();
			self.IconBorder:SetPoint("CENTER", self.Icon, "CENTER", 0, -3);
		else -- round icon borders use textures
			if iconItemQuantity and iconItemQuantity ~= 0 then
				self.ItemQuantityCircle:Show();
				self.ItemQuantityCircle:ClearAllPoints();
				self.ItemQuantityCircle:SetPoint("CENTER", self.Icon, "CENTER", 29, -28);

				self.ItemQuantity:Show();
				self.ItemQuantity:ClearAllPoints();
				self.ItemQuantity:SetText(iconItemQuantity);
				if iconItemQuantity == 1 then
					self.ItemQuantity:SetPoint("CENTER", self.ItemQuantityCircle, "CENTER", -1, 3);
				else
					self.ItemQuantity:SetPoint("CENTER", self.ItemQuantityCircle, "CENTER", 0, 3);
				end
			end

			self.IconBorder:ClearAllPoints();
			self.IconBorder:SetAtlas("tokens-frame-regular", true);
			self.IconBorder:SetPoint("CENTER", self.Icon, "CENTER", 0, -3);
		end
		self.IconBorder:Show();
	else
		self.IconBorder:Hide();
	end

	if self.GlowSpin and not overrideTexture then
		self.GlowSpin.SpinAnim:Play();
		self.GlowSpin:Show();
	elseif self.GlowSpin then
		self.GlowSpin.SpinAnim:Stop();
		self.GlowSpin:Hide();
	end

	if self.GlowPulse and not overrideTexture then
		self.GlowPulse.PulseAnim:Play();
		self.GlowPulse:Show();
	elseif self.GlowPulse then
		self.GlowPulse.PulseAnim:Stop();
		self.GlowPulse:Hide();
	end
end

function StoreCardMixin:HideIcon()
	self.Icon:Hide();
	self.IconBorder:Hide();
	self.ItemQuantityCircle:Hide();
	self.ItemQuantity:Hide();
	self.GlowSpin:Hide();
	self.GlowSpin.SpinAnim:Stop();
	self.GlowPulse:Hide();
	self.GlowPulse.PulseAnim:Stop();

	self.Card:Show();
end

function StoreCardMixin:UpdateCard(entryID, forceModelUpdate)
	local entryInfo = self:GetEntryInfo(entryID);
	if entryInfo.sharedData.tooltip and entryInfo.sharedData.tooltip ~= "" then
		self.productTooltipTitle = entryInfo.sharedData.name;
		self.productTooltipDescription = entryInfo.sharedData.tooltip;
	else
		self.productTooltipTitle = nil;
		self.productTooltipDescription = nil;
	end

	self.DiscountMiddle:Hide();
	self.DiscountLeft:Hide();
	self.DiscountRight:Hide();
	self.DiscountText:Hide();
	self.Checkmark:Hide();

	local currencyInfo = StoreFrame_CurrencyInfo();
	if not currencyInfo then
		self:Hide();
		return;
	end

	if entryInfo.sharedData.productDecorator == Enum.BattlepayProductDecorator.Boost then
		self.UpgradeArrow:Show();
		self.boostType = entryInfo.sharedData.boostType;
	else
		self.UpgradeArrow:Hide();
		self.boostType = nil;
	end

	local currencyFormat = self:GetCurrencyFormat(currencyInfo);
	self:UpdateDiscount(currencyInfo, entryInfo, currencyFormat);
	self:UpdatePricing(currencyInfo, entryInfo, currencyFormat);
	self:UpdateBuyButton(currencyInfo, entryInfo, currencyFormat);

	self.ProductName:SetText(entryInfo.sharedData.name);
	if entryInfo.sharedData.overrideTextColor then
		self.ProductName:SetTextColor(entryInfo.sharedData.overrideTextColor.r, entryInfo.sharedData.overrideTextColor.g, entryInfo.sharedData.overrideTextColor.b);
	else
		self.ProductName:SetTextColor(1, 1, 1);
	end

	self:SetCardTexture(entryInfo);
	self:SetStyle(entryInfo);
	self:SetupWoWToken(entryInfo);
	self:SetupDescription(entryInfo);
	self:SetDisclaimerText(entryInfo);

	self:UpdateModel(entryInfo, forceModelUpdate);

	if self:ShouldShowIcon(entryInfo) then
		self:ShowIcon(entryInfo.sharedData);
	else
		self:HideIcon();
	end

	self:SetID(entryID);
	self:UpdateState();
	self:InitMagnifier();

	if not self:IsShown() and self.SplashBanner and self.SplashBanner:IsShown() then
		self.BannerFadeIn.FadeAnim:Play();
		self.BannerFadeIn:Show();
	end

	local completelyOwned = StoreFrame_IsCompletelyOwned(entryInfo);
	if completelyOwned and StoreFrame_DoesProductGroupShowOwnedAsDisabled(StoreFrame_GetSelectedCategoryID()) then
		self:Disable();
		self:SetCardOwned(true);
		self.Checkmark:Hide();
	else
		self:Enable();
		self:SetCardOwned(false);
		self.Checkmark:SetShown(completelyOwned);
	end

	local cannotBuyHere = not self:CanBuyHere(entryInfo);
	local disabled = not self:IsEnabled();

	-- If the only reason we can't buy this product is that we're in-world, redirect to the glue shop.
	if not disabled and cannotBuyHere then
		self.disabledTooltip = BLIZZARD_STORE_LOG_OUT_TO_PURCHASE_THIS_PRODUCT;
	else
		self.disabledTooltip = nil;
	end

	local disabledOverlayShouldBeShown = disabled or cannotBuyHere;
	self:SetDisabledOverlayShown(disabledOverlayShouldBeShown);
end
--------------------------------------------------


--------------------------------------------------
-- The Store Product Card's actual ITEM
function StoreProductCardItem_OnEnter(self)
	local card = self:GetParent();
	card:OnEnter();

	local entryInfo = card:GetEntryInfo()
	local x, y, point, rpoint = card:GetTooltipOffsets();

	if entryInfo.sharedData.itemID and not C_Glue.IsOnGlueScreen() then
		self.hasItemTooltip = true;
		StoreTooltip:Hide();
		StoreOutbound.SetItemTooltip(entryInfo.sharedData.itemID, x, y, rpoint);
	end
end

function StoreProductCardItem_OnLeave(self)
	local card = self:GetParent();
	card:OnLeave();

	-- No product associated with this card
	if (not card:IsShown()) then return end;

	if ( card.SelectedTexture ) then
		local cardEntryID = card:GetID() == 0;
		local selectedEntryID = StoreFrame_GetSelectedEntryID();
		local isShown = (cardEntryID ~= 0) and cardEntryID == selectedEntryID;
		card.SelectedTexture:SetShown(isShown);
	end

	if self.hasItemTooltip then
		StoreOutbound.ClearItemTooltip();
		self.hasItemTooltip = false;
	end
end
--------------------------------------------------

function ProductCardBuyButton_OnClick(self)
	local parent = self:GetParent();
	local entryID = parent:GetID();
	StoreFrame_BeginPurchase(entryID);
	PlaySound(SOUNDKIT.UI_IG_STORE_BUY_BUTTON);
end

function ProductCardBuyButton_OnEnter(self)
	local parent = self:GetParent();
	parent:OnEnter();
end

function ProductCardBuyButton_OnLeave(self)
	local parent = self:GetParent();
	parent:OnLeave();
end

function StoreProductCardCheckmark_OnEnter(self)
	local card = self:GetParent();
	card:OnEnter();

	local x, y, point, rpoint = card:GetTooltipOffsets();
	if (point == "LEFT") then
		point = "BOTTOMRIGHT";
		rpoint = "TOPLEFT";
		x = 4;
	else
		point = "BOTTOMLEFT";
		rpoint ="TOPRIGHT";
		x = -4;
	end
	StoreTooltip:ClearAllPoints();
	StoreTooltip:SetPoint(point, self, rpoint, x, 0);
	StoreTooltip_Show(BLIZZARD_STORE_YOU_ALREADY_OWN_THIS);
end

function StoreProductCardCheckmark_OnLeave(self)
	if not self:GetParent():IsMouseOver() then
		local card = self:GetParent();
		card:OnLeave();
	end
	StoreTooltip:Hide();
end

function StoreCardDetail_SetLayerAboveModelScene(self)
	--Every card has a model scene now
	local modelScene = self:GetParent().ModelScene;
	self:SetFrameLevel(modelScene:GetFrameLevel() + 1);
end

