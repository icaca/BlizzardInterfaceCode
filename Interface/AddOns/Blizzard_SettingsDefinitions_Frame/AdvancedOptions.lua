local function Register()
	-- Advanced settings do not apply to non-standard game modes for now.
	if not C_GameRules.IsStandard() then
		return;
	end

	local category, layout = Settings.RegisterVerticalLayoutCategory(ADVANCED_OPTIONS_LABEL);
	Settings.ADVANCED_OPTIONS_CATEGORY_ID = category:GetID();

	-- Order set in GameplaySettingsGroup.lua
	category:SetOrder(CUSTOM_GAMEPLAY_SETTINGS_ORDER[ADVANCED_OPTIONS_LABEL]);

	-- Mirrored from Keybindings Panel
	if Settings.ClickCastInitializer then
		layout:AddMirroredInitializer(Settings.ClickCastInitializer);
	end

	-- Mirrored from Keybindings Panel
	if Settings.QuickKeybindInitializer then
		layout:AddMirroredInitializer(Settings.QuickKeybindInitializer);
	end

	-- Assisted Combat
	InterfaceOverrides.RunSettingsCallback(function()
		layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(ASSISTED_COMBAT_LABEL));
	end);

	-- Assisted Rotation
	InterfaceOverrides.RunSettingsCallback(function()
		local tooltipFn = function()
			local isAvailable, failureReason = C_AssistedCombat.IsAvailable();
			if isAvailable then
				return ASSISTED_COMBAT_ROTATION_ACTION_BUTTON_HELPTIP;
			else
				return format("%s|n|n%s", ASSISTED_COMBAT_ROTATION_ACTION_BUTTON_HELPTIP, failureReason);
			end
		end

		local function OnButtonClick()
			SetCVarBitfield("closedInfoFramesAccountWide", LE_FRAME_TUTORIAL_ACCOUNT_ASSISTED_COMBAT_ROTATION_DRAG_SPELL, false);
			local skipTransitionBackToOpeningPanel = true;
			SettingsPanel:Close(skipTransitionBackToOpeningPanel);
			PlayerSpellsUtil.ToggleSpellBookFrame();
		end

		local addSearchTags = false;
		local initializer = CreateSettingsButtonInitializer(ASSISTED_COMBAT_ROTATION, ASSISTED_COMBAT_ROTATION_VIEW_SPELLBOOK, OnButtonClick, tooltipFn, addSearchTags, "ASSISTED_COMBAT_ROTATION");
		initializer:AddModifyPredicate(C_AssistedCombat.IsAvailable);
		initializer:SetKioskProtected();
		layout:AddInitializer(initializer);
	end);

	-- Assisted Highlight
	InterfaceOverrides.RunSettingsCallback(function()
		local tooltipFn = function()
			local isAvailable, failureReason = C_AssistedCombat.IsAvailable();
			if isAvailable then
				return OPTION_TOOLTIP_ASSISTED_COMBAT_HIGHLIGHT;
			else
				return format("%s|n|n%s", OPTION_TOOLTIP_ASSISTED_COMBAT_HIGHLIGHT, failureReason);
			end
		end
		local setting, initializer = Settings.SetupCVarCheckbox(category, "assistedCombatHighlight", ASSISTED_COMBAT_HIGHLIGHT_LABEL, tooltipFn);
		initializer:AddModifyPredicate(C_AssistedCombat.IsAvailable);

		local onClickFn = function(checked)
			if checked and not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_ASSISTED_HIGHLIGHT_ENABLED_POPUP) then
				local systemPrefix = "SETTINGS";
				local notificationType = "ASSISTED_HIGHLIGHT";
				StaticPopup_ShowNotification(systemPrefix, notificationType, ASSISTED_COMBAT_HIGHLIGHT_DIALOG_WARNING);
				local OnSettingsPanelHide = function()
					EventRegistry:UnregisterCallback("SettingsPanel.OnHide", notificationType);
					StaticPopup_HideNotification(systemPrefix, notificationType);
				end
				EventRegistry:RegisterCallback("SettingsPanel.OnHide", OnSettingsPanelHide, notificationType);
				SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_ASSISTED_HIGHLIGHT_ENABLED_POPUP, true);
			end
			return false;
		end
		initializer:SetSettingIntercept(onClickFn);
	end);

	-- Combat Warnings
	InterfaceOverrides.RunSettingsCallback(function()
		layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(COMBAT_WARNINGS_LABEL));
	end);

	-- Enable Encounter Timeline
	InterfaceOverrides.RunSettingsCallback(function()
		local function GenerateTooltipText()
			local isAvailable, failureReason = C_EncounterTimeline.IsTimelineSupported();
			if isAvailable then
				return COMBAT_WARNINGS_ENABLE_ENCOUNTER_TIMELINE_TOOLTIP;
			else
				return string.format("%s|n|n%s", COMBAT_WARNINGS_ENABLE_ENCOUNTER_TIMELINE_TOOLTIP, failureReason);
			end
		end

		local setting, initializer = Settings.SetupCVarCheckbox(category, "encounterTimelineEnabled", COMBAT_WARNINGS_ENABLE_ENCOUNTER_TIMELINE_LABEL, GenerateTooltipText);
		initializer:AddModifyPredicate(C_EncounterTimeline.IsTimelineSupported);
	end);

	-- Cooldown Viewer
	InterfaceOverrides.RunSettingsCallback(function()
		layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(COOLDOWN_VIEWER_LABEL));
	end);

	InterfaceOverrides.RunSettingsCallback(function()
		local addSearchTags = false;

		-- Cooldown Viewer enable checkbox
		local function TooltipFn()
			local isAvailable, failureReason = C_CooldownViewer.IsCooldownViewerAvailable();
			if isAvailable then
				return ENABLE_COOLDOWN_VIEWER_TOOLTIP;
			else
				return format("%s|n|n%s", ENABLE_COOLDOWN_VIEWER_TOOLTIP, failureReason);
			end
		end

		Settings.SetupCVarCheckbox(category, "cooldownViewerEnabled", ENABLE_COOLDOWN_VIEWER, TooltipFn);

		local function ShowDesiredPanelFromSettingsPanel(panel)
			local skipTransitionBackToOpeningPanel = true;
			SettingsPanel:Close(skipTransitionBackToOpeningPanel);
			ShowUIPanel(panel);
		end

		-- Open Edit Mode
		local function OpenEditMode()
			ShowDesiredPanelFromSettingsPanel(EditModeManagerFrame);
		end
		local editModeInitializer = CreateSettingsButtonInitializer("", COOLDOWN_VIEWER_OPTIONS_OPEN_EDIT_MODE, OpenEditMode, nil, addSearchTags);
		layout:AddInitializer(editModeInitializer);

		-- Open Cooldown Manager
		local function OpenCooldownManager()
			ShowDesiredPanelFromSettingsPanel(CooldownViewerSettings);
		end

		local managerInitializer = CreateSettingsButtonInitializer("", HUD_EDIT_MODE_COOLDOWN_VIEWER_SETTINGS, OpenCooldownManager, nil, addSearchTags, "ADVANCED_COOLDOWN_SETTINGS");
		layout:AddInitializer(managerInitializer);
	end);

	Settings.RegisterCategory(category, SETTING_GROUP_GAMEPLAY);
end

SettingsRegistrar:AddRegistrant(Register);
