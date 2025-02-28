local function GetSpellDisplayVisInfoData(widgetID, attachedUnit)
	local widgetInfo = C_UIWidgetManager.GetSpellDisplayVisualizationInfo(widgetID);
	if widgetInfo and widgetInfo.spellInfo.shownState ~= Enum.WidgetShownState.Hidden then
		widgetInfo.attachedUnit = attachedUnit;
		return widgetInfo;
	end
end

UIWidgetManager:RegisterWidgetVisTypeTemplate(Enum.UIWidgetVisualizationType.SpellDisplay, {frameType = "FRAME", frameTemplate = "UIWidgetTemplateSpellDisplay"}, GetSpellDisplayVisInfoData);

local colorBlindNumPipsByBorderColor = { 
	[Enum.SpellDisplayBorderColor.White] = 1,
	[Enum.SpellDisplayBorderColor.Orange] = 5,
	[Enum.SpellDisplayBorderColor.Purple] = 4,
	[Enum.SpellDisplayBorderColor.Green] = 2,
	[Enum.SpellDisplayBorderColor.Blue] = 3,
}

UIWidgetTemplateSpellDisplayMixin = CreateFromMixins(UIWidgetBaseTemplateMixin);

function UIWidgetTemplateSpellDisplayMixin:OnLoad()
	UIWidgetBaseTemplateMixin.OnLoad(self);
	self.rarityPipPool = CreateTexturePool(self, "OVERLAY", 7, "RarityPipTemplate");
end		

local function IsWorldLootObject(object)
	return object and C_WorldLootObject.IsWorldLootObject(object) or false;
end

function UIWidgetTemplateSpellDisplayMixin:Setup(widgetInfo, widgetContainer)
	self.hadSpellID = false;
	self.attachedUnit = widgetContainer.attachedUnit;

	UIWidgetBaseTemplateMixin.Setup(self, widgetInfo, widgetContainer);
	self.Spell:Setup(widgetContainer, widgetInfo.spellInfo, widgetInfo.widgetSizeSetting, widgetInfo.textureKit, widgetInfo.tooltipLoc);

	self:SetWidth(self.Spell:GetWidth());
	self:SetHeight(self.Spell:GetHeight() + 2);

	if widgetInfo.spellInfo.spellID ~= 0 then
		self.hadSpellID = true;
	end
	
	self:EnableMouse(true);
	self:SetMouseClickEnabled(true);
	self:SetScript("OnMouseDown", self.OnMouseDown);
	self:UpdateRarityPips(widgetInfo.spellInfo);

	if IsWorldLootObject(self.attachedUnit) then
		self.widgetInfo = widgetInfo;
		self.displayedWorldLootObject = self.attachedUnit;
		EventRegistry:TriggerEvent("WorldLootObject.ObjectShown", self.displayedWorldLootObject, self);
	end
end

function UIWidgetTemplateSpellDisplayMixin:UpdateRarityPips(spellInfo)
	self.rarityPipPool:ReleaseAll();
	self.RarityPipBackground:Hide(); 
	if not IsWorldLootObject(self.attachedUnit) or (spellInfo.iconDisplayType ~= Enum.SpellDisplayIconDisplayType.Buff) then 
		return; 
	end	

	local numPips = colorBlindNumPipsByBorderColor[spellInfo.borderColor]; 
	if(not numPips) then 
		return; 
	end 

	local lastPip = nil;
	for i = 1, numPips do 
		local pip = self.rarityPipPool:Acquire(); 
		if(not lastPip) then 
			pip:SetPoint("LEFT", self.RarityPipBackground, "LEFT", 3, -1); 
		else
			pip:SetPoint("LEFT", lastPip, "RIGHT", 3, 0);
		end 
		lastPip = pip; 
		pip:Show(); 
	end
	self.RarityPipBackground:Show(); 
end

function UIWidgetTemplateSpellDisplayMixin:OnReset()
	if self.displayedWorldLootObject then
		EventRegistry:TriggerEvent("WorldLootObject.ObjectHidden", self.displayedWorldLootObject, self);
		self.widgetInfo = nil;
		self.displayedWorldLootObject = nil;
	end

	UIWidgetBaseTemplateMixin.OnReset(self);
	self.Spell:OnReset();
end

function UIWidgetTemplateSpellDisplayMixin:SetFontStringColor(fontColor)
	self.Spell:SetOverrideNormalFontColor(fontColor);
end

function UIWidgetTemplateSpellDisplayMixin:OnUpdate()
	if not self.widgetID or self.hadSpellID == true then
		return;
	end

	C_UIWidgetManager.SetProcessingUnit(self.attachedUnit);
	local widgetInfo = C_UIWidgetManager.GetSpellDisplayVisualizationInfo(self.widgetID);

	if widgetInfo.spellInfo.spellID ~= 0 then
		self.Spell:Setup(widgetInfo, widgetInfo.spellInfo, widgetInfo.widgetSizeSetting, widgetInfo.textureKit, widgetInfo.tooltipLoc);
		self.hadSpellID = true;
	end
end

function UIWidgetTemplateSpellDisplayMixin:OnMouseDown(button)
	if IsWorldLootObject(self.attachedUnit) then
		if button =="RightButton" then 
			C_WorldLootObject.OnWorldLootObjectClick(self.attachedUnit, false);
		else
			C_WorldLootObject.OnWorldLootObjectClick(self.attachedUnit, true);
		end
	end
end

UIWidgetTemplateSpellDisplaySpellMixin = {}

-- Registered dynamically
function UIWidgetTemplateSpellDisplaySpellMixin:OnUpdate(dt)
	UIWidgetBaseSpellTemplateMixin.OnUpdate(self, dt);
	self:UpdateCursor();
end

function UIWidgetTemplateSpellDisplaySpellMixin:OnEnter()
	UIWidgetBaseSpellTemplateMixin.OnEnter(self);
	self:UpdateCursor();
	self:SetScript("OnUpdate", self.OnUpdate);
end

function UIWidgetTemplateSpellDisplaySpellMixin:OnLeave()
	UIWidgetBaseSpellTemplateMixin.OnLeave(self);
	if IsWorldLootObject(self:GetParent().attachedUnit) then
		ResetCursor();
	end

	self:SetScript("OnUpdate", nil);
end

function UIWidgetTemplateSpellDisplaySpellMixin:ShouldContinueOnUpdate()
	return UIWidgetBaseSpellTemplateMixin.ShouldContinueOnUpdate(self) or self:IsMouseOver();
end


function UIWidgetTemplateSpellDisplaySpellMixin:UpdateCursor()
	local attachedUnit = self:GetParent().attachedUnit;
	if IsWorldLootObject(attachedUnit) then
		SetCursor(C_WorldLootObject.IsWorldLootObjectInRange(attachedUnit) and "BUY_CURSOR" or "BUY_ERROR_CURSOR");
	end
end
