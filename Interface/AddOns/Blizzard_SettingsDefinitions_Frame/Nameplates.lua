local PreviewIconDataProvider = nil;

NamePlatePreviewMixin = { };

function NamePlatePreviewMixin:OnShow()
	if NamePlateDriverFrame and not self.UnitFrame then
		-- Use the player unit as the base for the Preview NamePlate since it's a known and well defined entity.
		self.explicitUnitToken = "player";

		-- Use the enemy options for the Preview NamePlate since most nameplate settings adjust display for enemy units.
		self.explicitEnemyFrameOptions = true;

		NamePlateDriverFrame:RegisterScriptNamePlate(self, NamePlateConstants.PREVIEW_UNIT_TOKEN);
		NamePlateDriverFrame:OnEvent("NAME_PLATE_CREATED", self);
		NamePlateDriverFrame:OnEvent("NAME_PLATE_UNIT_ADDED", NamePlateConstants.PREVIEW_UNIT_TOKEN);

		-- Set an explicit threat state so changes to the nameplateThreatDisplay option can be observed.
		local threatStateRed = 3;
		self.UnitFrame.explicitThreatSituation = threatStateRed;
		self.UnitFrame.forceAggroFlash = true;

		self.UnitFrame.UpdateNameOverride = function(self)
			self.name:SetText(UNIT_NAMEPLATES_TARGET_NAME_PREVIEW);
			self.name:SetShown(not self:IsSimplified());

			if CVarCallbackRegistry:GetCVarNumberOrDefault("nameplateStyle") == Enum.NamePlateStyle.Legacy then
				self.name:SetVertexColor(1.0, 0.0, 0.0);
			else
				self.name:SetVertexColor(1.0, 1.0, 1.0);
			end

			return true;
		end;

		NamePlateDriverFrame:UpdateNamePlateOptions();

		if not PreviewIconDataProvider then
			local spellIconsOnly = true;
			PreviewIconDataProvider = CreateAndInitFromMixin(IconDataProviderMixin, IconDataProviderExtraType.Spellbook, spellIconsOnly);
		end

		self.previewIconTexture = PreviewIconDataProvider:GetRandomIcon();

		-- Force the Preview NamePlate to show auras so changes to the related CVars (nameplateEnemyNpcAuraDisplay, nameplateEnemyPlayerAuraDisplay) can be observed.
		self.UnitFrame.AurasFrame.explicitAurasFrameShown = true;

		-- Force the Preview NamePlate to behave as a player or npc so changes to the related CVars (nameplateEnemyNpcAuraDisplay, nameplateEnemyPlayerAuraDisplay) can be observed.
		self.UnitFrame.AurasFrame.explicitPlayerAurasSetting = false;

		-- Prevent real UNIT_AURA events from affecting the display of explicit auras.
		self.UnitFrame.AurasFrame:SetActive(false);

		-- Create some dummy auras so the player can see results of changing the CVar.
		self.UnitFrame.AurasFrame.explicitAuraList = TableUtil.CreatePriorityTable(AuraUtil.DefaultAuraCompare, TableUtil.Constants.AssociativePriorityTable);
		self.UnitFrame.AurasFrame.explicitAuraList[1] = { auraInstanceID = 1, sourceUnit = "player", applications = 1, expirationTime = 0, duration = 10, icon = PreviewIconDataProvider:GetRandomIcon()};
		self.UnitFrame.AurasFrame.explicitAuraList[2] = { auraInstanceID = 2, sourceUnit = "player", applications = 1, expirationTime = 0, duration = 10, icon = PreviewIconDataProvider:GetRandomIcon()};
		self.UnitFrame.AurasFrame.explicitAuraList[3] = { auraInstanceID = 3, sourceUnit = "player", applications = 1, expirationTime = 0, duration = 10, icon = PreviewIconDataProvider:GetRandomIcon()};
		self.UnitFrame.AurasFrame.explicitAuraList[4] = { auraInstanceID = 4, sourceUnit = "player", applications = 1, expirationTime = 0, duration = 10, icon = PreviewIconDataProvider:GetRandomIcon()};
		self.UnitFrame.AurasFrame.explicitAuraList[5] = { auraInstanceID = 5, sourceUnit = "player", applications = 1, expirationTime = 0, duration = 10, icon = PreviewIconDataProvider:GetRandomIcon()};
		self.UnitFrame.AurasFrame.explicitAuraList[6] = { auraInstanceID = 6, sourceUnit = "player", applications = 1, expirationTime = 0, duration = 10, icon = PreviewIconDataProvider:GetRandomIcon()};
		
		self.UnitFrame.AurasFrame:RefreshExplicitAuras();
	end
end

function NamePlatePreviewMixin:OnHide()
	if self.UnitFrame then
		self:HidePreviewNamePlateCastBar();

		self.explicitUnitToken = nil;
		self.explicitEnemyFrameOptions = nil;
		self.UnitFrame.explicitThreatSituation = nil;
		self.UnitFrame.forceAggroFlash = nil;
		self.UnitFrame:SetExplicitValues({});
		self.UnitFrame.AurasFrame.explicitAuraList = nil;
		self.UnitFrame.UpdateNameOverride = nil;

		NamePlateDriverFrame:OnEvent("NAME_PLATE_UNIT_REMOVED", NamePlateConstants.PREVIEW_UNIT_TOKEN);
		NamePlateDriverFrame:UnregisterScriptNamePlate(NamePlateConstants.PREVIEW_UNIT_TOKEN);
	end
end

function NamePlatePreviewMixin:ShowPreviewNamePlateCastBar()
	local unitFrame = self.UnitFrame;
	if not unitFrame then
		return;
	end

	local castData = {
		barType = "standard",
		iconTexture = self.previewIconTexture,
		spellName = UNIT_NAMEPLATES_SPELL_NAME_PREVIEW,
		targetName = UNIT_NAMEPLATES_TARGET_NAME_PREVIEW,
		isImportantSpell = true,
		isSpellTarget = true,
		castTime = 3.0,
	};
	unitFrame.castBar:SimulateCast(castData);
end

function NamePlatePreviewMixin:HidePreviewNamePlateCastBar()
	local unitFrame = self.UnitFrame;
	if not unitFrame then
		return;
	end

	local castBar = unitFrame.castBar;
	castBar:UpdateShownState(false);
end

function NamePlatePreviewMixin:SetExplicitValues(explicitValues)
	self.UnitFrame:SetExplicitValues(explicitValues);
end

function NamePlatePreviewMixin:OnNamePlateInfoChanged()
	local explicitValues = {
		classification = "elite";
	};
	self:SetExplicitValues(explicitValues);
end

function NamePlatePreviewMixin:OnNamePlateThreatDisplayChanged()
	local explicitValues = {
		isFriend = false;
	};
	self:SetExplicitValues(explicitValues);
end

function NamePlatePreviewMixin:ToggleEnemyNPCAuraDisplay()
	local explicitValues = {
		isPlayer = false,
		isFriend = false,
	};
	self:SetExplicitValues(explicitValues);
end

function NamePlatePreviewMixin:ToggleEnemyPlayerAuraDisplay()
	local explicitValues = {
		isPlayer = true,
		isFriend = false,
	};
	self:SetExplicitValues(explicitValues);
end

function NamePlatePreviewMixin:ToggleFriendlyPlayerAuraDisplay()
	local explicitValues = {
		isPlayer = true,
		isFriend = true,
	};
	self:SetExplicitValues(explicitValues);
end

function NamePlatePreviewMixin:ToggleSimplifiedType(simplifiedType)
	local simplifiedTypeSet = CVarCallbackRegistry:GetCVarBitfieldIndex("nameplateSimplifiedTypes", simplifiedType);
	if simplifiedTypeSet ~= true then
		return;
	end

	local explicitValues = {};

	if simplifiedType == Enum.NamePlateSimplifiedType.Minion then
		explicitValues.isMinion = true;
	elseif simplifiedType == Enum.NamePlateSimplifiedType.MinusMob then
		explicitValues.isMinusMob = true;
	elseif simplifiedType == Enum.NamePlateSimplifiedType.FriendlyPlayer then
		explicitValues.isPlayer = true;
		explicitValues.isFriend = true;
	elseif simplifiedType == Enum.NamePlateSimplifiedType.FriendlyNpc then
		explicitValues.isPlayer = false;
		explicitValues.isFriend = true;
	end

	self:SetExplicitValues(explicitValues);
end

local function GetPreviewNamePlate()
	if not NamePlateDriverFrame then
		return nil;
	end

	return NamePlateDriverFrame:GetNamePlateForUnit(NamePlateConstants.PREVIEW_UNIT_TOKEN);
end

local function ShowPreviewNamePlateCastBar()
	local namePlate = GetPreviewNamePlate();
	if not namePlate then
		return;
	end

	namePlate:ShowPreviewNamePlateCastBar();
end

local function SetPreviewNamePlateExplicitValues(explicitValues)
	local namePlate = GetPreviewNamePlate();
	if not namePlate then
		return;
	end

	namePlate:SetExplicitValues(explicitValues);
end

local function OnPreviewNamePlateInfoChanged()
	local namePlate = GetPreviewNamePlate();
	if not namePlate then
		return;
	end

	namePlate:OnNamePlateInfoChanged();
end

local function OnPreviewNamePlateThreatDisplayChanged()
	local namePlate = GetPreviewNamePlate();
	if not namePlate then
		return;
	end

	namePlate:OnNamePlateThreatDisplayChanged();
end

local function TogglePreviewNamePlateEnemyNPCAuraDisplay()
	local namePlate = GetPreviewNamePlate();
	if not namePlate then
		return;
	end

	namePlate:ToggleEnemyNPCAuraDisplay();
end

local function TogglePreviewNamePlateEnemyPlayerAuraDisplay()
	local namePlate = GetPreviewNamePlate();
	if not namePlate then
		return;
	end

	namePlate:ToggleEnemyPlayerAuraDisplay();
end

local function TogglePreviewNamePlateFriendlyPlayerAuraDisplay()
	local namePlate = GetPreviewNamePlate();
	if not namePlate then
		return;
	end

	namePlate:ToggleFriendlyPlayerAuraDisplay();
end

local function TogglePreviewNamePlateSimplifiedType(simplifiedType)
	local namePlate = GetPreviewNamePlate();
	if not namePlate then
		return;
	end

	namePlate:ToggleSimplifiedType(simplifiedType);
end

local function Register()
	local category, layout = Settings.RegisterVerticalLayoutCategory(NAMEPLATE_OPTIONS_LABEL);
	Settings.NAMEPLATE_OPTIONS_CATEGORY_ID = category:GetID();

	-- Order set in GameplaySettingsGroup.lua
	category:SetOrder(CUSTOM_GAMEPLAY_SETTINGS_ORDER[NAMEPLATE_OPTIONS_LABEL]);

	Settings.RegisterCategory(category, SETTING_GROUP_GAMEPLAY);

	-- Names
	InterfaceOverrides.RunSettingsCallback(function()
		layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(NAMES_LABEL));
	end);

	-- My name
	InterfaceOverrides.RunSettingsCallback(function()
		Settings.SetupCVarCheckbox(category, "UnitNameOwn", UNIT_NAME_OWN, OPTION_TOOLTIP_UNIT_NAME_OWN);
	end);

	-- NPC Names
	InterfaceOverrides.RunSettingsCallback(function()
		local function GetValue()
			if GetCVarBool("UnitNameNPC") then
				return 4;
			else
				local specialNPCName = GetCVarBool("UnitNameFriendlySpecialNPCName");
				local hostileNPCName = GetCVarBool("UnitNameHostleNPC");
				local specialAndHostile = specialNPCName and hostileNPCName;
				if specialAndHostile and GetCVarBool("UnitNameInteractiveNPC") then
					return 3;
				elseif specialAndHostile then
					return 2;
				elseif specialNPCName then
					return 1;
				end
			end
			
			return 5;
		end
		
		local function SetValue(value)
			if value == 1 then
				SetCVar("UnitNameFriendlySpecialNPCName", "1");
				SetCVar("UnitNameNPC", "0");
				SetCVar("UnitNameHostleNPC", "0");
				SetCVar("UnitNameInteractiveNPC", "0");
				SetCVar("ShowQuestUnitCircles", "0");
			elseif value == 2 then
				SetCVar("UnitNameFriendlySpecialNPCName", "1");
				SetCVar("UnitNameHostleNPC", "1");
				SetCVar("UnitNameInteractiveNPC", "0");
				SetCVar("UnitNameNPC", "0");
				SetCVar("ShowQuestUnitCircles", "1");
			elseif value == 3 then
				SetCVar("UnitNameFriendlySpecialNPCName", "1");
				SetCVar("UnitNameHostleNPC", "1");
				SetCVar("UnitNameInteractiveNPC", "1");
				SetCVar("UnitNameNPC", "0");
				SetCVar("ShowQuestUnitCircles", "1");
			elseif value == 4 then
				SetCVar("UnitNameFriendlySpecialNPCName", "0");
				SetCVar("UnitNameHostleNPC", "0");
				SetCVar("UnitNameInteractiveNPC", "0");
				SetCVar("UnitNameNPC", "1");
				SetCVar("ShowQuestUnitCircles", "1");
			else
				SetCVar("UnitNameFriendlySpecialNPCName", "0");
				SetCVar("UnitNameHostleNPC", "0");
				SetCVar("UnitNameInteractiveNPC", "0");
				SetCVar("UnitNameNPC", "0");
				SetCVar("ShowQuestUnitCircles", "1");
			end
		end

		local function GetOptions()
			local container = Settings.CreateControlTextContainer();
			container:Add(1, NPC_NAMES_DROPDOWN_TRACKED, NPC_NAMES_DROPDOWN_TRACKED_TOOLTIP);
			container:Add(2, NPC_NAMES_DROPDOWN_HOSTILE, NPC_NAMES_DROPDOWN_HOSTILE_TOOLTIP);
			container:Add(3, NPC_NAMES_DROPDOWN_INTERACTIVE, NPC_NAMES_DROPDOWN_INTERACTIVE_TOOLTIP);
			container:Add(4, NPC_NAMES_DROPDOWN_ALL, NPC_NAMES_DROPDOWN_ALL_TOOLTIP);
			container:Add(5, NPC_NAMES_DROPDOWN_NONE, NPC_NAMES_DROPDOWN_NONE_TOOLTIP);
			return container:GetData();
		end

		local defaultValue = 2;
		local setting = Settings.RegisterProxySetting(category, "PROXY_NPC_NAMES",
			Settings.VarType.Number, SHOW_NPC_NAMES, defaultValue, GetValue, SetValue);
		Settings.CreateDropdown(category, setting, GetOptions, OPTION_TOOLTIP_NPC_NAMES_DROPDOWN);
	end);

	-- Critters and Companions
	InterfaceOverrides.RunSettingsCallback(function()
		Settings.SetupCVarCheckbox(category, "UnitNameNonCombatCreatureName", UNIT_NAME_NONCOMBAT_CREATURE, OPTION_TOOLTIP_UNIT_NAME_NONCOMBAT_CREATURE);
	end);

	-- Friendly Players
	InterfaceOverrides.RunSettingsCallback(function()
		local friendlyPlayerNameSetting, friendlyPlayerNameInitializer = Settings.SetupCVarCheckbox(category, "UnitNameFriendlyPlayerName", UNIT_NAME_FRIENDLY, OPTION_TOOLTIP_UNIT_NAME_FRIENDLY);

		-- Minions
		local setting, initializer = Settings.SetupCVarCheckbox(category, "UnitNameFriendlyMinionName", UNIT_NAME_FRIENDLY_MINIONS, OPTION_TOOLTIP_UNIT_NAME_FRIENDLY_MINIONS);
		initializer:Indent();
		initializer:SetParentInitializer(friendlyPlayerNameInitializer);
	end);
	
	-- Enemy Players
	InterfaceOverrides.RunSettingsCallback(function()
		local enemyPlayerNameSetting, enemyPlayerNameInitializer = Settings.SetupCVarCheckbox(category, "UnitNameEnemyPlayerName", UNIT_NAME_ENEMY, OPTION_TOOLTIP_UNIT_NAME_ENEMY);

		-- Minions
		local setting, initializer = Settings.SetupCVarCheckbox(category, "UnitNameEnemyMinionName", UNIT_NAME_ENEMY_MINIONS, OPTION_TOOLTIP_UNIT_NAME_ENEMY_MINIONS);
		initializer:Indent();
		initializer:SetParentInitializer(enemyPlayerNameInitializer);
	end);

	-- NamePlates
	layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(NAMEPLATES_LABEL));

	-- Needed but unused for all dropdowns with checkboxes.
	local function GetValue()
		return true;
	end

	-- Needed but unused for all dropdowns with checkboxes.
	local function SetValue(value)

	end

	-- Always Show NamePlates
	InterfaceOverrides.RunSettingsCallback(function()
		Settings.SetupCVarCheckbox(category, "nameplateShowAll", UNIT_NAMEPLATES_AUTOMODE, OPTION_TOOLTIP_UNIT_NAMEPLATES_AUTOMODE);
	end);

		-- Enemy Units
	InterfaceOverrides.RunSettingsCallback(function()
		local enemyTooltip = Settings.WrapTooltipWithBinding(OPTION_TOOLTIP_UNIT_NAMEPLATES_SHOW_ENEMIES, "NAMEPLATES");
		local enemyUnitSetting, enemyUnitInitializer = Settings.SetupCVarCheckbox(category, "nameplateShowEnemies", UNIT_NAMEPLATES_SHOW_ENEMIES, enemyTooltip);

		-- Minions
		do
			local setting, initializer = Settings.SetupCVarCheckbox(category, "nameplateShowEnemyMinions", UNIT_NAMEPLATES_SHOW_ENEMY_MINIONS, OPTION_TOOLTIP_UNIT_NAMEPLATES_SHOW_ENEMY_MINIONS);
			initializer:Indent();
			initializer:SetParentInitializer(enemyUnitInitializer);
		end

		-- Minor
		do
			local setting, initializer = Settings.SetupCVarCheckbox(category, "nameplateShowEnemyMinus", UNIT_NAMEPLATES_SHOW_ENEMY_MINUS, OPTION_TOOLTIP_UNIT_NAMEPLATES_SHOW_ENEMY_MINUS);
			initializer:Indent();
			initializer:SetParentInitializer(enemyUnitInitializer);
		end
	end);

	-- Friendly player nameplates
	InterfaceOverrides.RunSettingsCallback(function()
		local friendlyTooltip = Settings.WrapTooltipWithBinding(OPTION_TOOLTIP_UNIT_NAMEPLATES_SHOW_FRIENDS, "FRIENDNAMEPLATES");
		local friendUnitSetting, friendUnitInitializer = Settings.SetupCVarCheckbox(category, "nameplateShowFriendlyPlayers", UNIT_NAMEPLATES_SHOW_FRIENDS, friendlyTooltip);

		-- Minions
		local setting, initializer = Settings.SetupCVarCheckbox(category, "nameplateShowFriendlyPlayerMinions", UNIT_NAMEPLATES_SHOW_FRIENDLY_MINIONS, OPTION_TOOLTIP_UNIT_NAMEPLATES_SHOW_FRIENDLY_MINIONS);
		initializer:Indent();
		initializer:SetParentInitializer(friendUnitInitializer);
	end);

	-- Friendly Npc nameplates
	InterfaceOverrides.RunSettingsCallback(function()
		Settings.SetupCVarCheckbox(category, "nameplateShowFriendlyNpcs", UNIT_NAMEPLATES_SHOW_FRIENDLY_NPCS, UNIT_NAMEPLATES_SHOW_FRIENDLY_NPCS_TOOLTIP);
	end);

	-- Offscreen NamePlates
	InterfaceOverrides.RunSettingsCallback(function()
		Settings.SetupCVarCheckbox(category, "nameplateShowOffscreen", UNIT_NAMEPLATES_SHOW_OFFSCREEN, UNIT_NAMEPLATES_SHOW_OFFSCREEN_TOOLTIP);
	end);

	-- Stacking NamePlates
	local namePlateStackingTypesCVar = "nameplateStackingTypes";
	if C_CVar.GetCVar(namePlateStackingTypesCVar) then
		local function IsEnemyChecked()
			return GetCVarBitfield(namePlateStackingTypesCVar, Enum.NamePlateStackType.Enemy);
		end

		local function IsFriendlyChecked()
			return GetCVarBitfield(namePlateStackingTypesCVar, Enum.NamePlateStackType.Friendly);
		end

		local function ToggleChecked(value)
			local bitIsSet = GetCVarBitfield(namePlateStackingTypesCVar, value.value);
			SetCVarBitfield(namePlateStackingTypesCVar, value.value, not bitIsSet);
		end

		local function GetOptions()
			local container = Settings.CreateControlTextContainer();
			container:AddCheckbox(Enum.NamePlateStackType.Enemy, UNIT_NAMEPLATES_STACK_ENEMY_UNITS, UNIT_NAMEPLATES_STACK_ENEMY_UNITS_TOOLTIP, IsEnemyChecked, ToggleChecked);
			container:AddCheckbox(Enum.NamePlateStackType.Friendly, UNIT_NAMEPLATES_STACK_FRIENDLY_UNITS, UNIT_NAMEPLATES_STACK_FRIENDLY_UNITS_TOOLTIP, IsFriendlyChecked, ToggleChecked);

			return container:GetData();
		end

		local function GetSelectionText(selections)
			if #selections == 0 then
				return UNIT_NAMEPLATES_STACK_NONE;
			end

			-- Returning nil to use default behavior in DropdownSelectionTextMixin:UpdateToMenuSelections.
			return nil;
		end

		local setting = Settings.RegisterProxySetting(category, "UNIT_NAMEPLATES_ENABLE_STACKING", Settings.VarType.Number, UNIT_NAMEPLATES_ENABLE_STACKING, 0, GetValue, SetValue);
		local initializer = Settings.CreateDropdown(category, setting, GetOptions, UNIT_NAMEPLATES_ENABLE_STACKING_TOOLTIP);
		initializer.hideSteppers = true
		initializer.getSelectionTextFunc = GetSelectionText;
		initializer.OnHide = OnDropdownHidden;
	end

	-- NamePlate Preview
	do
		local data = { };
		local initializer = Settings.CreatePanelInitializer("NamePlatePreviewTemplate", data);
		layout:AddInitializer(initializer);
	end

	-- NamePlate Size
	do
		local setting = Settings.RegisterCVarSetting(category, "nameplateSize", Settings.VarType.Number, UNIT_NAMEPLATES_GLOBAL_SCALE);

		local minValue, maxValue, step = Enum.NamePlateSize.Small, Enum.NamePlateSize.Huge, 1;
		local options = Settings.CreateSliderOptions(minValue, maxValue, step);
		options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right);

		Settings.CreateSlider(category, setting, options, UNIT_NAMEPLATES_GLOBAL_SCALE_TOOLTIP);
	end

	-- Debuff Scale
	do
		local setting = Settings.RegisterCVarSetting(category, "nameplateAuraScale", Settings.VarType.Number, UNIT_NAMEPLATES_DEBUFF_SCALE);

		local minValue, maxValue, step = 0.7, 1.4, 0.1;
		local options = Settings.CreateSliderOptions(minValue, maxValue, step);
		options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right, FormatPercentageRounded);

		Settings.CreateSlider(category, setting, options, UNIT_NAMEPLATES_DEBUFF_SCALE_TOOLTIP);
	end

	-- NamePlate Style
	if C_CVar.GetCVar("nameplateStyle") then
		local function GetOptions()
			local container = Settings.CreateControlTextContainer();
			container:Add(Enum.NamePlateStyle.Default, UNIT_NAMEPLATES_STYLE_DEFAULT);
			container:Add(Enum.NamePlateStyle.Legacy, UNIT_NAMEPLATES_STYLE_LEGACY);
			container:Add(Enum.NamePlateStyle.Thin, UNIT_NAMEPLATES_STYLE_THIN);
			container:Add(Enum.NamePlateStyle.Block, UNIT_NAMEPLATES_STYLE_BLOCK);
			container:Add(Enum.NamePlateStyle.CastFocus, UNIT_NAMEPLATES_STYLE_CAST_FOCUS);
			return container:GetData();
		end

		Settings.SetupCVarDropdown(category, "nameplateStyle", Settings.VarType.Number, GetOptions, UNIT_NAMEPLATES_STYLE, UNIT_NAMEPLATES_STYLE_TOOLTIP);
	end
	Settings.SetOnValueChangedCallback("nameplateStyle", function()
		ShowPreviewNamePlateCastBar();
	end);

	-- Used to clear all explicit values used by interacting with an individual setting any time a dropdown is closed/hidden.
	local function OnDropdownHidden()
		local explicitValues = {};
		SetPreviewNamePlateExplicitValues(explicitValues);
	end

	local nameplateInfoDisplayCVar = "nameplateInfoDisplay";
	if C_CVar.GetCVar(nameplateInfoDisplayCVar) then
		local function IsCurrentHealthPercentChecked()
			return GetCVarBitfield(nameplateInfoDisplayCVar, Enum.NamePlateInfoDisplay.CurrentHealthPercent);
		end

		local function IsCurrentHealthValueChecked()
			return GetCVarBitfield(nameplateInfoDisplayCVar, Enum.NamePlateInfoDisplay.CurrentHealthValue);
		end

		local function IsRarityIconChecked()
			return GetCVarBitfield(nameplateInfoDisplayCVar, Enum.NamePlateInfoDisplay.RarityIcon);
		end

		local function ToggleChecked(value)
			local bitIsSet = GetCVarBitfield(nameplateInfoDisplayCVar, value.value);
			SetCVarBitfield(nameplateInfoDisplayCVar, value.value, not bitIsSet);

			OnPreviewNamePlateInfoChanged();
		end

		local function GetOptions()
			local container = Settings.CreateControlTextContainer();
			container:AddCheckbox(Enum.NamePlateInfoDisplay.CurrentHealthPercent, UNIT_NAMEPLATES_INFO_DISPLAY_CURRENT_HEALTH_PERCENT, UNIT_NAMEPLATES_INFO_DISPLAY_CURRENT_HEALTH_PERCENT_TOOLTIP, IsCurrentHealthPercentChecked, ToggleChecked);
			container:AddCheckbox(Enum.NamePlateInfoDisplay.CurrentHealthValue, UNIT_NAMEPLATES_INFO_DISPLAY_CURRENT_HEALTH_VALUE, UNIT_NAMEPLATES_INFO_DISPLAY_CURRENT_HEALTH_VALUE_TOOLTIP, IsCurrentHealthValueChecked, ToggleChecked);
			container:AddCheckbox(Enum.NamePlateInfoDisplay.RarityIcon, UNIT_NAMEPLATES_INFO_DISPLAY_RARITY_ICON, UNIT_NAMEPLATES_INFO_DISPLAY_RARITY_ICON_TOOLTIP, IsRarityIconChecked, ToggleChecked);

			return container:GetData();
		end

		local function OnDropdownShow()
			OnPreviewNamePlateInfoChanged();
		end

		local function GetSelectionText(selections)
			if #selections == 0 then
				return UNIT_NAMEPLATES_INFO_DISPLAY_NONE;
			end

			-- Returning nil to use default behavior in DropdownSelectionTextMixin:UpdateToMenuSelections.
			return nil;
		end

		local setting = Settings.RegisterProxySetting(category, "UNIT_NAMEPLATES_INFO_DISPLAY", Settings.VarType.Number, UNIT_NAMEPLATES_INFO_DISPLAY, defaultValue, GetValue, SetValue);
		local initializer = Settings.CreateDropdown(category, setting, GetOptions, UNIT_NAMEPLATES_INFO_DISPLAY_TOOLTIP);
		initializer.hideSteppers = true
		initializer.getSelectionTextFunc = GetSelectionText;
		initializer.OnShow = OnDropdownShow;
		initializer.OnHide = OnDropdownHidden;
	end

	local nameplateCastBarDisplayCVar = "nameplateCastBarDisplay";
	if C_CVar.GetCVar(nameplateCastBarDisplayCVar) then
		local function IsSpellNameChecked()
			return GetCVarBitfield(nameplateCastBarDisplayCVar, Enum.NamePlateCastBarDisplay.SpellName);
		end

		local function IsSpellIconChecked()
			return GetCVarBitfield(nameplateCastBarDisplayCVar, Enum.NamePlateCastBarDisplay.SpellIcon);
		end

		local function IsSpellTargetChecked()
			return GetCVarBitfield(nameplateCastBarDisplayCVar, Enum.NamePlateCastBarDisplay.SpellTarget);
		end

		local function IsHighlightImportantCastsChecked()
			return GetCVarBitfield(nameplateCastBarDisplayCVar, Enum.NamePlateCastBarDisplay.HighlightImportantCasts);
		end

		local function IsHighlightWhenCastTargetChecked()
			return GetCVarBitfield(nameplateCastBarDisplayCVar, Enum.NamePlateCastBarDisplay.HighlightWhenCastTarget);
		end

		local function ToggleChecked(value)
			local bitIsSet = GetCVarBitfield(nameplateCastBarDisplayCVar, value.value);
			SetCVarBitfield(nameplateCastBarDisplayCVar, value.value, not bitIsSet);

			ShowPreviewNamePlateCastBar();
		end

		local function GetOptions()
			local container = Settings.CreateControlTextContainer();
			container:AddCheckbox(Enum.NamePlateCastBarDisplay.SpellName, UNIT_NAMEPLATES_CAST_BAR_DISPLAY_SPELL_NAME, UNIT_NAMEPLATES_CAST_BAR_DISPLAY_SPELL_NAME_TOOLTIP, IsSpellNameChecked, ToggleChecked);
			container:AddCheckbox(Enum.NamePlateCastBarDisplay.SpellIcon, UNIT_NAMEPLATES_CAST_BAR_DISPLAY_SPELL_ICON, UNIT_NAMEPLATES_CAST_BAR_DISPLAY_SPELL_ICON_TOOLTIP, IsSpellIconChecked, ToggleChecked);
			container:AddCheckbox(Enum.NamePlateCastBarDisplay.SpellTarget, UNIT_NAMEPLATES_CAST_BAR_DISPLAY_SPELL_TARGET, UNIT_NAMEPLATES_CAST_BAR_DISPLAY_SPELL_TARGET_TOOLTIP, IsSpellTargetChecked, ToggleChecked);
			container:AddCheckbox(Enum.NamePlateCastBarDisplay.HighlightImportantCasts, UNIT_NAMEPLATES_CAST_BAR_DISPLAY_HIGHLIGHT_IMPORTANT_CASTS, UNIT_NAMEPLATES_CAST_BAR_DISPLAY_HIGHLIGHT_IMPORTANT_CASTS_TOOLTIP, IsHighlightImportantCastsChecked, ToggleChecked);
			container:AddCheckbox(Enum.NamePlateCastBarDisplay.HighlightWhenCastTarget, UNIT_NAMEPLATES_CAST_BAR_DISPLAY_HIGHLIGHT_WHEN_CAST_TARGET, UNIT_NAMEPLATES_CAST_BAR_DISPLAY_HIGHLIGHT_WHEN_CAST_TARGET_TOOLTIP, IsHighlightWhenCastTargetChecked, ToggleChecked);

			return container:GetData();
		end

		local function OnDropdownShow()
			ShowPreviewNamePlateCastBar();
		end

		local function GetSelectionText(selections)
			if #selections == 0 then
				return UNIT_NAMEPLATES_CAST_BAR_DISPLAY_NONE;
			end

			-- Returning nil to use default behavior in DropdownSelectionTextMixin:UpdateToMenuSelections.
			return nil;
		end

		local setting = Settings.RegisterProxySetting(category, "UNIT_NAMEPLATES_CAST_BAR_DISPLAY", Settings.VarType.Number, UNIT_NAMEPLATES_CAST_BAR_DISPLAY, defaultValue, GetValue, SetValue);
		local initializer = Settings.CreateDropdown(category, setting, GetOptions, UNIT_NAMEPLATES_CAST_BAR_DISPLAY_TOOLTIP);
		initializer.hideSteppers = true
		initializer.getSelectionTextFunc = GetSelectionText;
		initializer.OnShow = OnDropdownShow;
		initializer.OnHide = OnDropdownHidden;
	end

	local nameplateThreatDisplayCVar = "nameplateThreatDisplay";
	if C_CVar.GetCVar(nameplateThreatDisplayCVar) then
		local function IsFlashChecked()
			return GetCVarBitfield(nameplateThreatDisplayCVar, Enum.NamePlateThreatDisplay.Progressive);
		end

		local function IsProgressiveChecked()
			return GetCVarBitfield(nameplateThreatDisplayCVar, Enum.NamePlateThreatDisplay.Flash);
		end

		local function ToggleChecked(value)
			local bitIsSet = GetCVarBitfield(nameplateThreatDisplayCVar, value.value);
			SetCVarBitfield(nameplateThreatDisplayCVar, value.value, not bitIsSet);
		end

		local function GetOptions()
			local container = Settings.CreateControlTextContainer();
			container:AddCheckbox(Enum.NamePlateThreatDisplay.Progressive, UNIT_NAMEPLATES_THREAT_DISPLAY_PROGRESSIVE, UNIT_NAMEPLATES_THREAT_DISPLAY_PROGRESSIVE_TOOLTIP, IsFlashChecked, ToggleChecked);
			container:AddCheckbox(Enum.NamePlateThreatDisplay.Flash, UNIT_NAMEPLATES_THREAT_DISPLAY_FLASH, UNIT_NAMEPLATES_THREAT_DISPLAY_FLASH_TOOLTIP, IsProgressiveChecked, ToggleChecked);

			return container:GetData();
		end

		local function OnDropdownShow()
			OnPreviewNamePlateThreatDisplayChanged();
		end

		local function GetSelectionText(selections)
			if #selections == 0 then
				return UNIT_NAMEPLATES_THREAT_DISPLAY_NONE;
			end

			-- Returning nil to use default behavior in DropdownSelectionTextMixin:UpdateToMenuSelections.
			return nil;
		end

		local setting = Settings.RegisterProxySetting(category, "UNIT_NAMEPLATES_THREAT_DISPLAY", Settings.VarType.Number, UNIT_NAMEPLATES_THREAT_DISPLAY, defaultValue, GetValue, SetValue);
		local initializer = Settings.CreateDropdown(category, setting, GetOptions, UNIT_NAMEPLATES_THREAT_DISPLAY_TOOLTIP);
		initializer.hideSteppers = true
		initializer.getSelectionTextFunc = GetSelectionText;
		initializer.OnShow = OnDropdownShow;
		initializer.OnHide = OnDropdownHidden;
	end

	local nameplateEnemyNpcAuraDisplayCVar = "nameplateEnemyNpcAuraDisplay";
	if C_CVar.GetCVar(nameplateEnemyNpcAuraDisplayCVar) then
		local function IsBuffsChecked()
			return GetCVarBitfield(nameplateEnemyNpcAuraDisplayCVar, Enum.NamePlateEnemyNpcAuraDisplay.Buffs);
		end

		local function IsDebuffsChecked()
			return GetCVarBitfield(nameplateEnemyNpcAuraDisplayCVar, Enum.NamePlateEnemyNpcAuraDisplay.Debuffs);
		end

		local function IsCrowdControlChecked()
			return GetCVarBitfield(nameplateEnemyNpcAuraDisplayCVar, Enum.NamePlateEnemyNpcAuraDisplay.CrowdControl);
		end

		local function ToggleChecked(value)
			local bitIsSet = GetCVarBitfield(nameplateEnemyNpcAuraDisplayCVar, value.value);
			SetCVarBitfield(nameplateEnemyNpcAuraDisplayCVar, value.value, not bitIsSet);

			TogglePreviewNamePlateEnemyNPCAuraDisplay();
		end

		local function GetOptions()
			local container = Settings.CreateControlTextContainer();
			container:AddCheckbox(Enum.NamePlateEnemyNpcAuraDisplay.Buffs, UNIT_NAMEPLATES_ENEMY_NPC_AURA_DISPLAY_BUFFS, UNIT_NAMEPLATES_ENEMY_NPC_AURA_DISPLAY_BUFFS_TOOLTIP, IsBuffsChecked, ToggleChecked);
			container:AddCheckbox(Enum.NamePlateEnemyNpcAuraDisplay.Debuffs, UNIT_NAMEPLATES_ENEMY_NPC_AURA_DISPLAY_DEBUFFS, UNIT_NAMEPLATES_ENEMY_NPC_AURA_DISPLAY_DEBUFFS_TOOLTIP, IsDebuffsChecked, ToggleChecked);
			container:AddCheckbox(Enum.NamePlateEnemyNpcAuraDisplay.CrowdControl, UNIT_NAMEPLATES_ENEMY_NPC_AURA_DISPLAY_CROWD_CONTROL, UNIT_NAMEPLATES_ENEMY_NPC_AURA_DISPLAY_CROWD_CONTROL_TOOLTIP, IsCrowdControlChecked, ToggleChecked);

			return container:GetData();
		end

		local function OnDropdownShow()
			TogglePreviewNamePlateEnemyNPCAuraDisplay();
		end

		local function GetSelectionText(selections)
			if #selections == 0 then
				return UNIT_NAMEPLATES_ENEMY_NPC_AURA_DISPLAY_NONE;
			end

			-- Returning nil to use default behavior in DropdownSelectionTextMixin:UpdateToMenuSelections.
			return nil;
		end

		local setting = Settings.RegisterProxySetting(category, "UNIT_NAMEPLATES_ENEMY_NPC_AURA_DISPLAY", Settings.VarType.Number, UNIT_NAMEPLATES_ENEMY_NPC_AURA_DISPLAY, defaultValue, GetValue, SetValue);
		local initializer = Settings.CreateDropdown(category, setting, GetOptions, UNIT_NAMEPLATES_ENEMY_NPC_AURA_DISPLAY_TOOLTIP);
		initializer.hideSteppers = true
		initializer.getSelectionTextFunc = GetSelectionText;
		initializer.OnShow = OnDropdownShow;
		initializer.OnHide = OnDropdownHidden;
	end

	local nameplateEnemyPlayerAuraDisplayCVar = "nameplateEnemyPlayerAuraDisplay";
	if C_CVar.GetCVar(nameplateEnemyPlayerAuraDisplayCVar) then
		local function IsBuffsChecked()
			return GetCVarBitfield(nameplateEnemyPlayerAuraDisplayCVar, Enum.NamePlateEnemyPlayerAuraDisplay.Buffs);
		end

		local function IsDebuffsChecked()
			return GetCVarBitfield(nameplateEnemyPlayerAuraDisplayCVar, Enum.NamePlateEnemyPlayerAuraDisplay.Debuffs);
		end

		local function IsLossOfControlChecked()
			return GetCVarBitfield(nameplateEnemyPlayerAuraDisplayCVar, Enum.NamePlateEnemyPlayerAuraDisplay.LossOfControl);
		end

		local function ToggleChecked(value)
			local bitIsSet = GetCVarBitfield(nameplateEnemyPlayerAuraDisplayCVar, value.value);
			SetCVarBitfield(nameplateEnemyPlayerAuraDisplayCVar, value.value, not bitIsSet);

			TogglePreviewNamePlateEnemyPlayerAuraDisplay();
		end

		local function GetOptions()
			local container = Settings.CreateControlTextContainer();
			container:AddCheckbox(Enum.NamePlateEnemyPlayerAuraDisplay.Buffs, UNIT_NAMEPLATES_ENEMY_PLAYER_AURA_DISPLAY_BUFFS, UNIT_NAMEPLATES_ENEMY_PLAYER_AURA_DISPLAY_BUFFS_TOOLTIP, IsBuffsChecked, ToggleChecked);
			container:AddCheckbox(Enum.NamePlateEnemyPlayerAuraDisplay.Debuffs, UNIT_NAMEPLATES_ENEMY_PLAYER_AURA_DISPLAY_DEBUFFS, UNIT_NAMEPLATES_ENEMY_PLAYER_AURA_DISPLAY_DEBUFFS_TOOLTIP, IsDebuffsChecked, ToggleChecked);
			container:AddCheckbox(Enum.NamePlateEnemyPlayerAuraDisplay.LossOfControl, UNIT_NAMEPLATES_ENEMY_PLAYER_AURA_DISPLAY_BIG_DEBUFF, UNIT_NAMEPLATES_ENEMY_PLAYER_AURA_DISPLAY_BIG_DEBUFF_TOOLTIP, IsLossOfControlChecked, ToggleChecked);

			return container:GetData();
		end

		local function OnDropdownShow()
			TogglePreviewNamePlateEnemyPlayerAuraDisplay();
		end

		local function GetSelectionText(selections)
			if #selections == 0 then
				return UNIT_NAMEPLATES_ENEMY_PLAYER_AURA_DISPLAY_NONE;
			end

			-- Returning nil to use default behavior in DropdownSelectionTextMixin:UpdateToMenuSelections.
			return nil;
		end

		local setting = Settings.RegisterProxySetting(category, "UNIT_NAMEPLATES_ENEMY_PLAYER_AURA_DISPLAY", Settings.VarType.Number, UNIT_NAMEPLATES_ENEMY_PLAYER_AURA_DISPLAY, defaultValue, GetValue, SetValue);
		local initializer = Settings.CreateDropdown(category, setting, GetOptions, UNIT_NAMEPLATES_ENEMY_PLAYER_AURA_DISPLAY_TOOLTIP);
		initializer.hideSteppers = true
		initializer.getSelectionTextFunc = GetSelectionText;
		initializer.OnShow = OnDropdownShow;
		initializer.OnHide = OnDropdownHidden;
	end

	local nameplateFriendlyPlayerAuraDisplayCVar = "nameplateFriendlyPlayerAuraDisplay";
	if C_CVar.GetCVar(nameplateFriendlyPlayerAuraDisplayCVar) then
		local function IsBuffsChecked()
			return GetCVarBitfield(nameplateFriendlyPlayerAuraDisplayCVar, Enum.NamePlateFriendlyPlayerAuraDisplay.Buffs);
		end

		local function IsDebuffsChecked()
			return GetCVarBitfield(nameplateFriendlyPlayerAuraDisplayCVar, Enum.NamePlateFriendlyPlayerAuraDisplay.Debuffs);
		end

		local function IsLossOfControlChecked()
			return GetCVarBitfield(nameplateFriendlyPlayerAuraDisplayCVar, Enum.NamePlateFriendlyPlayerAuraDisplay.LossOfControl);
		end

		local function ToggleChecked(value)
			local bitIsSet = GetCVarBitfield(nameplateFriendlyPlayerAuraDisplayCVar, value.value);
			SetCVarBitfield(nameplateFriendlyPlayerAuraDisplayCVar, value.value, not bitIsSet);

			TogglePreviewNamePlateFriendlyPlayerAuraDisplay();
		end

		local function GetOptions()
			local container = Settings.CreateControlTextContainer();
			container:AddCheckbox(Enum.NamePlateFriendlyPlayerAuraDisplay.Buffs, UNIT_NAMEPLATES_FRIENDLY_PLAYER_AURA_DISPLAY_BUFFS, UNIT_NAMEPLATES_FRIENDLY_PLAYER_AURA_DISPLAY_BUFFS_TOOLTIP, IsBuffsChecked, ToggleChecked);
			container:AddCheckbox(Enum.NamePlateFriendlyPlayerAuraDisplay.Debuffs, UNIT_NAMEPLATES_FRIENDLY_PLAYER_AURA_DISPLAY_DEBUFFS, UNIT_NAMEPLATES_FRIENDLY_PLAYER_AURA_DISPLAY_DEBUFFS_TOOLTIP, IsDebuffsChecked, ToggleChecked);
			container:AddCheckbox(Enum.NamePlateFriendlyPlayerAuraDisplay.LossOfControl, UNIT_NAMEPLATES_FRIENDLY_PLAYER_AURA_DISPLAY_BIG_DEBUFF, UNIT_NAMEPLATES_FRIENDLY_PLAYER_AURA_DISPLAY_BIG_DEBUFF_TOOLTIP, IsLossOfControlChecked, ToggleChecked);

			return container:GetData();
		end

		local function OnDropdownShow()
			TogglePreviewNamePlateFriendlyPlayerAuraDisplay();
		end

		local function GetSelectionText(selections)
			if #selections == 0 then
				return UNIT_NAMEPLATES_FRIENDLY_PLAYER_AURA_DISPLAY_NONE;
			end

			-- Returning nil to use default behavior in DropdownSelectionTextMixin:UpdateToMenuSelections.
			return nil;
		end

		local setting = Settings.RegisterProxySetting(category, "UNIT_NAMEPLATES_FRIENDLY_PLAYER_AURA_DISPLAY", Settings.VarType.Number, UNIT_NAMEPLATES_FRIENDLY_PLAYER_AURA_DISPLAY, defaultValue, GetValue, SetValue);
		local initializer = Settings.CreateDropdown(category, setting, GetOptions, UNIT_NAMEPLATES_FRIENDLY_PLAYER_AURA_DISPLAY_TOOLTIP);
		initializer.hideSteppers = true
		initializer.getSelectionTextFunc = GetSelectionText;
		initializer.OnShow = OnDropdownShow;
		initializer.OnHide = OnDropdownHidden;
	end

	-- NamePlate Debuff Padding
	do
		local setting = Settings.RegisterCVarSetting(category, "nameplateDebuffPadding", Settings.VarType.Number, UNIT_NAMEPLATES_DEBUFF_PADDING);

		local minValue, maxValue, step = 0, 50, 1;
		local options = Settings.CreateSliderOptions(minValue, maxValue, step);
		options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right);

		Settings.CreateSlider(category, setting, options, UNIT_NAMEPLATES_DEBUFF_PADDING_TOOLTIP);
	end

	local nameplatesSimplifiedTypesCVar = "nameplateSimplifiedTypes";
	if C_CVar.GetCVar(nameplatesSimplifiedTypesCVar) then
		local function IsMinionChecked()
			return GetCVarBitfield(nameplatesSimplifiedTypesCVar, Enum.NamePlateSimplifiedType.Minion);
		end

		local function IsMinusMobChecked()
			return GetCVarBitfield(nameplatesSimplifiedTypesCVar, Enum.NamePlateSimplifiedType.MinusMob);
		end

		local function IsFriendlyPlayerChecked()
			return GetCVarBitfield(nameplatesSimplifiedTypesCVar, Enum.NamePlateSimplifiedType.FriendlyPlayer);
		end

		local function IsFriendlyNpcChecked()
			return GetCVarBitfield(nameplatesSimplifiedTypesCVar, Enum.NamePlateSimplifiedType.FriendlyNpc);
		end

		local function ToggleChecked(value)
			local bitIsSet = GetCVarBitfield(nameplatesSimplifiedTypesCVar, value.value);
			SetCVarBitfield(nameplatesSimplifiedTypesCVar, value.value, not bitIsSet);

			TogglePreviewNamePlateSimplifiedType(value.value);
		end

		local function GetOptions()
			local container = Settings.CreateControlTextContainer();
			container:AddCheckbox(Enum.NamePlateSimplifiedType.Minion, UNIT_NAMEPLATES_SIMPLIFIED_MINIONS, UNIT_NAMEPLATES_SIMPLIFIED_MINIONS_TOOLTIP, IsMinionChecked, ToggleChecked);
			container:AddCheckbox(Enum.NamePlateSimplifiedType.MinusMob, UNIT_NAMEPLATES_SIMPLIFIED_MINUS_MOBS, UNIT_NAMEPLATES_SIMPLIFIED_MINUS_MOBS_TOOLTIP, IsMinusMobChecked, ToggleChecked);
			container:AddCheckbox(Enum.NamePlateSimplifiedType.FriendlyPlayer, UNIT_NAMEPLATES_SIMPLIFIED_FRIENDLY_PLAYERS, UNIT_NAMEPLATES_SIMPLIFIED_FRIENDLY_PLAYERS_TOOLTIP, IsFriendlyPlayerChecked, ToggleChecked);
			container:AddCheckbox(Enum.NamePlateSimplifiedType.FriendlyNpc, UNIT_NAMEPLATES_SIMPLIFIED_FRIENDLY_NPCS, UNIT_NAMEPLATES_SIMPLIFIED_FRIENDLY_NPCS_TOOLTIP, IsFriendlyNpcChecked, ToggleChecked);

			return container:GetData();
		end

		local function GetSelectionText(selections)
			if #selections == 0 then
				return UNIT_NAMEPLATES_SIMPLIFIED_NONE;
			end

			-- Returning nil to use default behavior in DropdownSelectionTextMixin:UpdateToMenuSelections.
			return nil;
		end

		local setting = Settings.RegisterProxySetting(category, "UNIT_NAMEPLATES_SIMPLIFIED",
			Settings.VarType.Number, UNIT_NAMEPLATES_SIMPLIFIED, defaultValue, GetValue, SetValue);
		local initializer = Settings.CreateDropdown(category, setting, GetOptions, UNIT_NAMEPLATES_SIMPLIFIED_TOOLTIP);
		initializer.hideSteppers = true
		initializer.getSelectionTextFunc = GetSelectionText;
	end
end

SettingsRegistrar:AddRegistrant(Register);
