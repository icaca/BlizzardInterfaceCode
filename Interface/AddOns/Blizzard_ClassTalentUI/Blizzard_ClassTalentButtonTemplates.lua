-- Art TODO: Replace use of SoulbindsNodes EffectIDs with ClassTalent-specific FX
local NODE_PURCHASE_FX_1 = 142;
local NODE_PURCHASE_FX_2 = 143;

ClassTalentButtonArtMixin = {};

function ClassTalentButtonArtMixin:OnShow()
	self.BorderSheen.Anim:Play();
end

function ClassTalentButtonArtMixin:OnHide()
	self.BorderSheen.Anim:Stop();
end

function ClassTalentButtonArtMixin:SetSelectableGlowDisabled(disabled)
	self.selectableGlowDisabled = disabled;
	self:UpdateSelectableGlow();
end

function ClassTalentButtonArtMixin:UpdateStateBorder(visualState)
	-- Overrides TalentButtonArtMixin.

	TalentButtonArtMixin.UpdateStateBorder(self, visualState);
	local sheenAlpha = ClassTalentUtil.GetSheenAlphaForVisualState(visualState);

	self.BorderSheen:SetAlpha(sheenAlpha);
	-- Hiding the sheen instead of stopping its anim so that it stays in sync with the other nodes
	self.BorderSheen:SetShown(sheenAlpha > 0);

	self:UpdateSelectableGlow();
end

function ClassTalentButtonArtMixin:UpdateGlow()
	-- Overrides TalentButtonArtMixin.

	TalentButtonArtMixin.UpdateGlow(self);

	self:UpdateSelectableGlow();
end

function ClassTalentButtonArtMixin:UpdateSelectableGlow()
	local isDoingStandardGlow = self.Glow and self.shouldGlow;
	local canDoSelectableGlow = not isDoingStandardGlow and not self.selectableGlowDisabled;

	local playSelectableGlow = canDoSelectableGlow and self.visualState == TalentButtonUtil.BaseVisualState.Selectable;
	self.SelectableGlow.Anim:SetPlaying(playSelectableGlow);
end


ClassTalentButtonBaseMixin = {};

function ClassTalentButtonBaseMixin:OnLoad()
	self.BorderSheenMask:SetAtlas(self.sheenMaskAtlas, TextureKitConstants.UseAtlasSize);
	self.SelectableGlow:SetAtlas(self.artSet.glow, TextureKitConstants.IgnoreAtlasSize);
end

function ClassTalentButtonBaseMixin:UpdateActionBarStatus()
	self.missingFromActionBar = not self:IsInspecting() and ClassTalentUtil.IsTalentMissingFromActionBars(self:GetNodeInfo(), self:GetSpellID());
end

function ClassTalentButtonBaseMixin:IsMissingFromActionBar()
	return self.missingFromActionBar;
end

function ClassTalentButtonBaseMixin:PlayPurchaseEffect(fxModelScene)
	fxModelScene:AddEffect(NODE_PURCHASE_FX_1, self, self);
	fxModelScene:AddEffect(NODE_PURCHASE_FX_2, self, self);
	if self.PurchaseVisuals and self.PurchaseVisuals.Anim then
		self.PurchaseVisuals.Anim:SetPlaying(true);
	end
end

function ClassTalentButtonBaseMixin:ResetPurchaseEffects()
	if self.PurchaseVisuals and self.PurchaseVisuals.Anim then
		self.PurchaseVisuals.Anim:SetPlaying(false);
	end
end

function ClassTalentButtonBaseMixin:OnRelease()
	-- Overrides TalentDisplayMixin.

	self:ResetPurchaseEffects();
	TalentDisplayMixin.OnRelease(self);
end


ClassTalentButtonSpendMixin = CreateFromMixins(TalentButtonSpendMixin, ClassTalentButtonBaseMixin);

function ClassTalentButtonSpendMixin:OnLoad()
	-- Overrides TalentButtonSpendMixin.

	TalentButtonSpendMixin.OnLoad(self);
	ClassTalentButtonBaseMixin.OnLoad(self);

	self.selectSound = SOUNDKIT.UI_CLASS_TALENT_NODE_SPEND;
	self.deselectSound = SOUNDKIT.UI_CLASS_TALENT_NODE_REFUND;
end

function ClassTalentButtonSpendMixin:UpdateEntryInfo(skipUpdate)
	-- Overrides TalentButtonSpendMixin.

	TalentButtonSpendMixin.UpdateEntryInfo(self, skipUpdate);
	
	if self.entryInfo and self.entryInfo.type == Enum.TraitNodeEntryType.SpendSquare then
		self.selectSound = SOUNDKIT.UI_CLASS_TALENT_NODE_SPEND_MAJOR;
	else
		self.selectSound = SOUNDKIT.UI_CLASS_TALENT_NODE_SPEND;
	end
end

function ClassTalentButtonSpendMixin:FullUpdate()
	-- Overrides TalentButtonSpendMixin.

	TalentButtonSpendMixin.FullUpdate(self);
	self:UpdateActionBarStatus();
end

function ClassTalentButtonSpendMixin:AddTooltipInstructions(tooltip)
	-- Overrides TalentButtonSpendMixin.

	if self.missingFromActionBar then
		GameTooltip:AddLine(TALENT_BUTTON_TOOLTIP_NOT_ON_ACTION_BAR, LIGHTBLUE_FONT_COLOR.r, LIGHTBLUE_FONT_COLOR.g, LIGHTBLUE_FONT_COLOR.b);
	end
	TalentButtonSpendMixin.AddTooltipInstructions(self, tooltip);
end

function ClassTalentButtonSpendMixin:ResetDynamic()
	-- Overrides TalentButtonSpendMixin.

	TalentButtonSpendMixin.ResetDynamic(self);
	self:ResetPurchaseEffects();
end


ClassTalentButtonSelectMixin = CreateFromMixins(TalentButtonSelectMixin, ClassTalentButtonBaseMixin);

function ClassTalentButtonSelectMixin:OnLoad()
	-- Overrides TalentButtonSelectMixin.

	TalentButtonSelectMixin.OnLoad(self);
	ClassTalentButtonBaseMixin.OnLoad(self);

	self.selectSound = SOUNDKIT.UI_CLASS_TALENT_NODE_SPEND;
	self.deselectSound = SOUNDKIT.UI_CLASS_TALENT_NODE_REFUND;
end

function ClassTalentButtonSelectMixin:UpdateEntryInfo(skipUpdate)
	-- Overrides TalentButtonSelectMixin.

	TalentButtonSelectMixin.UpdateEntryInfo(self, skipUpdate);
	
	if self.entryInfo and self.entryInfo.type == Enum.TraitNodeEntryType.SpendSquare then
		self.selectSound = SOUNDKIT.UI_CLASS_TALENT_NODE_SPEND_MAJOR;
	else
		self.selectSound = SOUNDKIT.UI_CLASS_TALENT_NODE_SPEND;
	end
end

function ClassTalentButtonSelectMixin:FullUpdate()
	-- Overrides TalentButtonSelectMixin.

	TalentButtonSelectMixin.FullUpdate(self);
	self:UpdateActionBarStatus();
end

function ClassTalentButtonSelectMixin:ResetDynamic()
	-- Overrides TalentButtonSelectMixin.

	TalentButtonSelectMixin.ResetDynamic(self);
	self:ResetPurchaseEffects();
end


ClassTalentButtonSplitSelectMixin = CreateFromMixins(TalentButtonSplitSelectMixin, ClassTalentButtonBaseMixin);

function ClassTalentButtonSplitSelectMixin:OnLoad()
	-- Overrides TalentButtonSplitSelectMixin.

	TalentButtonSplitSelectMixin.OnLoad(self);
	ClassTalentButtonBaseMixin.OnLoad(self);

	self.selectSound = SOUNDKIT.UI_CLASS_TALENT_NODE_SPEND_MAJOR;
	self.deselectSound = SOUNDKIT.UI_CLASS_TALENT_NODE_REFUND;
end

function ClassTalentButtonSplitSelectMixin:FullUpdate()
	-- Overrides TalentButtonSplitSelectMixin.

	TalentButtonSplitSelectMixin.FullUpdate(self);
	self:UpdateActionBarStatus();
end

function ClassTalentButtonSplitSelectMixin:ResetDynamic()
	-- Overrides TalentButtonSplitSelectMixin.

	TalentButtonSplitSelectMixin.ResetDynamic(self);
	self:ResetPurchaseEffects();
end


ClassTalentSelectionChoiceMixin = CreateFromMixins(TalentSelectionChoiceMixin);

function ClassTalentSelectionChoiceMixin:OnLoad()
	-- Overrides TalentButtonArtMixin.

	TalentButtonArtMixin.OnLoad(self);
	self.BorderSheenMask:SetAtlas(self.sheenMaskAtlas, TextureKitConstants.UseAtlasSize);
	self.SelectableGlow:SetAtlas(self.artSet.glow, TextureKitConstants.IgnoreAtlasSize);
end

function ClassTalentSelectionChoiceMixin:SetSelectionInfo(entryInfo, canSelectChoice, isCurrentSelection, selectionIndex)
	-- Overrides TalentSelectionChoiceMixin.

	TalentSelectionChoiceMixin.SetSelectionInfo(self, entryInfo, canSelectChoice, isCurrentSelection, selectionIndex);

	local entryID = self:GetEntryID();
	local nodeInfo = self:GetNodeInfo();
	local talentFrame = self:GetTalentFrame();

	self.missingFromActionBar = ClassTalentUtil.IsEntryTalentMissingFromActionBars(entryID, nodeInfo, self:GetSpellID());

	self:SetSearchMatchType(nodeInfo and talentFrame:GetSearchMatchTypeForEntry(nodeInfo.ID, entryID) or nil);
	self:SetGlowing(talentFrame:IsHighlightedStarterBuildEntry(entryID));
end

function ClassTalentSelectionChoiceMixin:AddTooltipInstructions(tooltip)
	if self.missingFromActionBar then
		GameTooltip:AddLine(TALENT_BUTTON_TOOLTIP_NOT_ON_ACTION_BAR, LIGHTBLUE_FONT_COLOR.r, LIGHTBLUE_FONT_COLOR.g, LIGHTBLUE_FONT_COLOR.b);
	end

	TalentSelectionChoiceMixin.AddTooltipInstructions(self, tooltip);
end