CVarCallbackRegistry:SetCVarCachable("colorblindMode");

local function Register()
	local category, layout = Settings.RegisterVerticalLayoutCategory(Settings.GetColorblindSettingsLabel());

	-- Enable Colorblind Mode
	Settings.SetupCVarCheckbox(category, "colorblindMode", USE_COLORBLIND_MODE, OPTION_TOOLTIP_USE_COLORBLIND_MODE);

	local colorblindSimulatorSetting = Settings.RegisterCVarSetting(category, "colorblindSimulator", Settings.VarType.Number, COLORBLIND_FILTER);

	-- Colorblind Filter
	do
		local function GetOptions()
			local container = Settings.CreateControlTextContainer();
			container:Add(0, COLORBLIND_OPTION_NONE);
			container:Add(1, COLORBLIND_OPTION_PROTANOPIA);
			container:Add(2, COLORBLIND_OPTION_DEUTERANOPIA);
			container:Add(3, COLORBLIND_OPTION_TRITANOPIA);
			return container:GetData();
		end

		local filterInitializer = Settings.CreateDropdown(category, colorblindSimulatorSetting, GetOptions, OPTION_TOOLTIP_COLORBLIND_FILTER);

		-- Adjust Strength
		local minValue, maxValue, step = 0, 1, .05;
		local options = Settings.CreateSliderOptions(minValue, maxValue, step);
		options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right, FormatPercentage);

		local _, strengthInitializer = Settings.SetupCVarSlider(category, "colorblindWeaknessFactor", options, ADJUST_COLORBLIND_STRENGTH, OPTION_TOOLTIP_ADJUST_COLORBLIND_STRENGTH);

		local function IsModifiable()
			return colorblindSimulatorSetting:GetValue() > 0;
		end
		strengthInitializer:SetParentInitializer(filterInitializer, IsModifiable);
	end

	-- Override Settings
	do
		ColorblindOverrides.CreateSettings(category, layout);
	end

	Settings.RegisterCategory(category, SETTING_GROUP_ACCESSIBILITY);
end

SettingsRegistrar:AddRegistrant(Register);
