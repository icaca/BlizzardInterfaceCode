function DebugTooltip_OnLoad(self)
	SharedTooltip_OnLoad(self);
	self:SetFrameLevel(self:GetFrameLevel() + 2);
end

function FrameStackTooltip_OnDisplaySizeChanged(self)
	local height = GetScreenHeight();
	if (height > 768) then
		self:SetScale(768/height);
	else
		self:SetScale(1);
	end
end

function FrameStackTooltip_IsFramestackEnabled()
	return GetCVarBool("fstack_enabled");
end

function FrameStackTooltip_IsShowHiddenEnabled()
	return GetCVarBool("fstack_showhidden");
end

function FrameStackTooltip_IsHighlightEnabled()
	return GetCVarBool("fstack_showhighlight");
end

function FrameStackTooltip_IsShowRegionsEnabled()
	return GetCVarBool("fstack_showregions");
end

function FrameStackTooltip_IsShowAnchorsEnabled()
	return GetCVarBool("fstack_showanchors");
end

function FrameStackTooltip_OnFramestackVisibilityUpdated(self)
	local show = FrameStackTooltip_IsFramestackEnabled();

	--[[Since these properties impact the contents displayed on the framestack,
	toggle the framestack off and then on to reinitialize it.--]]
	FrameStackTooltip_Hide(self);

	if ( show ) then
		local showHidden = FrameStackTooltip_IsShowHiddenEnabled();
		local showRegions = FrameStackTooltip_IsShowRegionsEnabled();
		local showAnchors = FrameStackTooltip_IsShowAnchorsEnabled();

		FrameStackTooltip_Show(self, showHidden, showRegions, showAnchors);
	end
end

function FrameStackTooltip_OnLoad(self)
	Mixin(self, CallbackRegistryMixin);
	Mixin(self, TextureInfoGeneratorMixin);
	CallbackRegistryMixin.OnLoad(self);
	self:GenerateCallbackEvents({ "FrameStackOnHighlightFrameChanged", "FrameStackOnShow", "FrameStackOnHide", "FrameStackOnTooltipCleared" });

	DebugTooltip_OnLoad(self);
	self.nextUpdate = 0;

	FrameStackTooltip_OnDisplaySizeChanged(self);
	self:RegisterEvent("DISPLAY_SIZE_CHANGED");
	self:RegisterEvent("FRAMESTACK_VISIBILITY_UPDATED");

	self.commandKeys =
	{
		KeyCommand_Create(function() FrameStackTooltip_ChangeHighlight(self, 1); end, KeyCommand.RUN_ON_DOWN, KeyCommand_CreateKey("LALT")),
		KeyCommand_Create(function() FrameStackTooltip_ChangeHighlight(self, -1); end, KeyCommand.RUN_ON_DOWN, KeyCommand_CreateKey("RALT")),
		KeyCommand_Create(function() FrameStackTooltip_InspectTable(self); end, KeyCommand.RUN_ON_UP, KeyCommand_CreateKey("CTRL")),
		KeyCommand_Create(function() FrameStackTooltip_ToggleTextureInformation(self); end, KeyCommand.RUN_ON_DOWN, KeyCommand_CreateKey("SHIFT")),
		KeyCommand_Create(function() FrameStackTooltip_HandleFrameCommand(self); end, KeyCommand.RUN_ON_DOWN, KeyCommand_CreateKey("CTRL", "C")),
	};
end

function FrameStackTooltip_ChangeHighlight(self, direction)
	self.highlightIndexChanged = direction;
	self.shouldSetFSObj = true;
end

function FrameStackTooltip_InspectTable(self)
	if self.highlightFrame then
		if DebugInspectionTool then
			local useExistingFrame = nil;
			local pollingOff = nil;
			local fallbackName = nil;
			local view = DebugInspectionToolViewEnum.Hierarchy;
			DebugInspectionTool:OpenObject(self.highlightFrame, useExistingFrame, pollingOff, fallbackName, view);
		else
			TableAttributeDisplay:InspectTable(self.highlightFrame);
			TableAttributeDisplay:Show();
		end
	end
end

function FrameStackTooltip_ToggleTextureInformation(self)
	self.showTextureInfo = not self.showTextureInfo;
end

function FrameStackTooltip_HandleFrameCommand(self)
	self:HandleTextureCommand(self.currentAssets);
end

function FrameStackTooltip_OnEvent(self, event, ...)
	if ( event == "DISPLAY_SIZE_CHANGED" ) then
		FrameStackTooltip_OnDisplaySizeChanged(self);
	elseif ( event == "FRAMESTACK_VISIBILITY_UPDATED" ) then
		FrameStackTooltip_OnFramestackVisibilityUpdated(self);
	end
end

function FrameStackTooltip_OnTooltipSetFrameStack(self, highlightFrame)
	self.highlightFrame = highlightFrame;

	if self.highlightFrame and self.showTextureInfo then
		local textureInfo, assets = self:CheckFormatTextureInfo(self.highlightFrame);
		if textureInfo then
			self:AddLine(textureInfo);
			self.currentAssets = assets;
		end
	end

	if self.shouldSetFSObj then
		fsobj = self.highlightFrame; -- luacheck: ignore 111 (setting non-standard global variable)
		self.shouldSetFSObj = nil;

		self:TriggerEvent(self.Event.FrameStackOnHighlightFrameChanged, fsobj);
	end

	if fsobj then
		self:AddLine(("\nfsobj = %s"):format(fsobj:GetDebugName()));
	end
end

function FrameStackTooltip_Show(self, showHidden, showRegions, showAnchors)
	self:SetOwner(UIParent, "ANCHOR_NONE");
	self:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -(CONTAINER_OFFSET_X or 0) - 13, (CONTAINER_OFFSET_Y or 0));
	self.default = 1;
	self.showRegions = showRegions;
	self.showHidden = showHidden;
	self.showAnchors = showAnchors;
	self:SetFrameStack(showHidden, showRegions);
end

function FrameStackTooltip_Hide(self)
	self:Hide();
	FrameStackHighlight:Hide();
end

local function FrameStack_SetCVarEnabled(enabled)
	SetCVar("fstack_enabled", enabled);
end

function FrameStackTooltip_ToggleDefaults()
	local tooltip = FrameStackTooltip;
	if ( tooltip:IsVisible() ) then
		FrameStackTooltip_Hide(tooltip);
		FrameStack_SetCVarEnabled(false);
	else
		local showHidden = FrameStackTooltip_IsShowHiddenEnabled();
		local showRegions = FrameStackTooltip_IsShowRegionsEnabled();
		local showAnchors = FrameStackTooltip_IsShowAnchorsEnabled();
		FrameStackTooltip_Show(tooltip, showHidden, showRegions, showAnchors);
		FrameStack_SetCVarEnabled(true);
	end
end

function FrameStackTooltip_Toggle(showHidden, showRegions, showAnchors)
	local tooltip = FrameStackTooltip;

	if ( tooltip:IsVisible() ) then
		FrameStackTooltip_Hide(tooltip);
		FrameStack_SetCVarEnabled(false);
	else
		FrameStackTooltip_Show(tooltip, showHidden, showRegions, showAnchors);
		FrameStack_SetCVarEnabled(true);
	end
end

local function AnchorHighlight(frame, highlight, relativePoint)
	highlight:ClearAllPoints();
	highlight:SetAllPoints(frame);
	highlight:Show();

	if highlight.AnchorPoint then
		if relativePoint then
			highlight.AnchorPoint:ClearAllPoints();
			highlight.AnchorPoint:SetPoint("CENTER", highlight, relativePoint);
			highlight.AnchorPoint:Show();
		else
			highlight.AnchorPoint:Hide();
		end
	end
end

AnchorHighlightMixin = {};

function AnchorHighlightMixin:RetrieveAnchorHighlight(pointIndex)
	if not self.AnchorHighlights then
		CreateFrame("FRAME", "FrameStackAnchorHighlightTemplate1", self, "FrameStackAnchorHighlightTemplate");
	end

	while pointIndex > #self.AnchorHighlights do
		CreateFrame("FRAME", "FrameStackAnchorHighlightTemplate"..(#self.AnchorHighlights + 1), self, "FrameStackAnchorHighlightTemplate");
	end

	return self.AnchorHighlights[pointIndex];
end

function AnchorHighlightMixin:HighlightFrame(baseFrame, showAnchors)
	AnchorHighlight(baseFrame, self);

	local pointIndex = 1;
	if (showAnchors and baseFrame.GetNumPoints and baseFrame.GetPoint) then -- TODO: Fix for lines
		while pointIndex <= baseFrame:GetNumPoints() do
			local _, anchorFrame, anchorRelativePoint = baseFrame:GetPoint(pointIndex);
			AnchorHighlight(anchorFrame, self:RetrieveAnchorHighlight(pointIndex), anchorRelativePoint);
			pointIndex = pointIndex + 1;
		end
	end

	while self.AnchorHighlights and self.AnchorHighlights[pointIndex] do
		self.AnchorHighlights[pointIndex]:Hide();
		pointIndex = pointIndex + 1;
	end
end

FRAMESTACK_UPDATE_TIME = .1

function FrameStackTooltip_OnUpdate(self)
	KeyCommand_Update(self.commandKeys);

	local now = GetTime();
	if now >= self.nextUpdate or self.highlightIndexChanged ~= 0 then
		self.nextUpdate = now + FRAMESTACK_UPDATE_TIME;
		self.highlightFrame = self:SetFrameStack(self.showHidden, self.showRegions, self.highlightIndexChanged);
		self.highlightIndexChanged = 0;
		if self.highlightFrame and FrameStackTooltip_IsHighlightEnabled() then
			FrameStackHighlight:HighlightFrame(self.highlightFrame, self.showAnchors);
		end
	end

end

function FrameStackTooltip_OnShow(self)
	local parent = self:GetParent() or UIParent;
	local ps = parent:GetEffectiveScale();
	local px, py = parent:GetCenter();
	px, py = px * ps, py * ps;
	local x, y = GetCursorPosition();
	self:ClearAllPoints();
	if (x > px) then
		if (y > py) then
			self:SetPoint("BOTTOMLEFT", parent, "BOTTOMLEFT", 20, 20);
		else
			self:SetPoint("TOPLEFT", parent, "TOPLEFT", 20, -20);
		end
	else
		if (y > py) then
			self:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -20, 20);
		else
			self:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -20, -20);
		end
	end

	self:TriggerEvent(self.Event.FrameStackOnShow);
end

function FrameStackTooltip_OnHide(self)
	self:TriggerEvent(self.Event.FrameStackOnHide);
end

function FrameStackTooltip_OnTooltipCleared(self)
	self:TriggerEvent(self.Event.FrameStackOnTooltipCleared);
end

FrameStackTooltip_OnEnter = FrameStackTooltip_OnShow;

local DebugHighlightColors = {
	CreateColor(0.1, 0.0, 0.0, 0.5),
	CreateColor(0.0, 0.1, 0.0, 0.5),
	CreateColor(0.0, 0.0, 0.1, 0.5),
	CreateColor(0.1, 0.1, 0.0, 0.5),
	CreateColor(0.1, 0.1, 0.1, 0.5),
};

local function GetDebugIdentifierLevel(debugIdentifierFrame)
	local debugIdentifierLevel = 1;
	local parent = debugIdentifierFrame:GetParent();
	while parent and parent.DebugHighlight ~= nil do
		debugIdentifierLevel = debugIdentifierLevel + 1;
		parent = parent:GetParent();
	end

	return debugIdentifierLevel;
end

function DebugIdentifierFrame_OnLoad(self)
	if self.DebugName then
		local debugNameText = string.gsub(self:GetDebugName(), "[.]", " ");
		self.DebugName:SetText(debugNameText);

		C_Timer.After(0.05, function ()
			local extraWidth = 10;
			while (self.DebugName:IsTruncated()) do
				self.DebugName:SetPoint("LEFT", -extraWidth, 0);
				self.DebugName:SetPoint("RIGHT", extraWidth, 0);
				extraWidth = extraWidth + 10;
			end
		end);
	end

	local debugIdentifierLevel = GetDebugIdentifierLevel(self);
	local debugHighlightColor = DebugHighlightColors[math.min(debugIdentifierLevel, #DebugHighlightColors)];
	self.DebugHighlight:SetColorTexture(debugHighlightColor:GetRGBA());
end

-- for checking that deprecated functions returns the same info as the original version
function CompareFunctionReturns(func1, func2, ...)
	local ret1 = { func1(...) };
	local ret2 = { func2(...) };
	local size = max(#ret1, #ret2);
	local allPassed = true;
	for i = 1, size do
		if ret1[i] == ret2[i] then
			print("["..i.."] pass");
		else
			print("["..i.."] "..RED_FONT_COLOR_CODE.."fail");
			print(ret1[i]);
			print(ret2[i]);
			allPassed = false;
		end
	end
	if allPassed then
		print("=== PASS ===");
	else
		print("=== " ..RED_FONT_COLOR_CODE.."FAIL"..FONT_COLOR_CODE_CLOSE.." ===");
	end
end
