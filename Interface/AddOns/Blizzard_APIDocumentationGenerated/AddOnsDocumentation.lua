local AddOns =
{
	Name = "AddOns",
	Type = "System",
	Namespace = "C_AddOns",

	Functions =
	{
		{
			Name = "DisableAddOn",
			Type = "Function",

			Arguments =
			{
				{ Name = "name", Type = "uiAddon", Nilable = false },
				{ Name = "character", Type = "cstring", Nilable = false, Default = "0" },
			},
		},
		{
			Name = "DisableAllAddOns",
			Type = "Function",

			Arguments =
			{
				{ Name = "character", Type = "cstring", Nilable = true },
			},
		},
		{
			Name = "DoesAddOnExist",
			Type = "Function",

			Arguments =
			{
				{ Name = "name", Type = "uiAddon", Nilable = false },
			},

			Returns =
			{
				{ Name = "exists", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "DoesAddOnHaveLoadError",
			Type = "Function",

			Arguments =
			{
				{ Name = "name", Type = "uiAddon", Nilable = false },
			},

			Returns =
			{
				{ Name = "hadError", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "EnableAddOn",
			Type = "Function",

			Arguments =
			{
				{ Name = "name", Type = "uiAddon", Nilable = false },
				{ Name = "character", Type = "cstring", Nilable = false, Default = "0" },
			},
		},
		{
			Name = "EnableAllAddOns",
			Type = "Function",

			Arguments =
			{
				{ Name = "character", Type = "cstring", Nilable = true },
			},
		},
		{
			Name = "GetAddOnDependencies",
			Type = "Function",

			Arguments =
			{
				{ Name = "name", Type = "uiAddon", Nilable = false },
			},

			Returns =
			{
				{ Name = "deps", Type = "cstring", Nilable = false, StrideIndex = 1 },
			},
		},
		{
			Name = "GetAddOnEnableState",
			Type = "Function",

			Arguments =
			{
				{ Name = "name", Type = "uiAddon", Nilable = false },
				{ Name = "character", Type = "cstring", Nilable = false, Default = "0" },
			},

			Returns =
			{
				{ Name = "state", Type = "AddOnEnableState", Nilable = false },
			},
		},
		{
			Name = "GetAddOnInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "name", Type = "uiAddon", Nilable = false },
			},

			Returns =
			{
				{ Name = "name", Type = "cstring", Nilable = false },
				{ Name = "title", Type = "cstring", Nilable = false },
				{ Name = "notes", Type = "cstring", Nilable = false },
				{ Name = "loadable", Type = "bool", Nilable = false },
				{ Name = "reason", Type = "cstring", Nilable = false },
				{ Name = "security", Type = "cstring", Nilable = false },
				{ Name = "updateAvailable", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetAddOnInterfaceVersion",
			Type = "Function",

			Arguments =
			{
				{ Name = "name", Type = "uiAddon", Nilable = false },
			},

			Returns =
			{
				{ Name = "interfaceVersion", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetAddOnLocalTable",
			Type = "Function",
			Documentation = { "Returns the addon table (passed as the second argument of ... to files) for any addon that opts in through setting AllowAddOnTableAccess: 1 in the toc file. Insecure code cannot query addon tables from Blizzard addons." },

			Arguments =
			{
				{ Name = "name", Type = "uiAddon", Nilable = false },
			},

			Returns =
			{
				{ Name = "table", Type = "LuaValueVariant", Nilable = false },
			},
		},
		{
			Name = "GetAddOnMetadata",
			Type = "Function",

			Arguments =
			{
				{ Name = "name", Type = "uiAddon", Nilable = false },
				{ Name = "variable", Type = "cstring", Nilable = false },
			},

			Returns =
			{
				{ Name = "value", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "GetAddOnOptionalDependencies",
			Type = "Function",

			Arguments =
			{
				{ Name = "name", Type = "uiAddon", Nilable = false },
			},

			Returns =
			{
				{ Name = "deps", Type = "cstring", Nilable = false, StrideIndex = 1 },
			},
		},
		{
			Name = "GetNumAddOns",
			Type = "Function",

			Returns =
			{
				{ Name = "numAddOns", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetScriptsDisallowedForBeta",
			Type = "Function",

			Returns =
			{
				{ Name = "disallowed", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsAddOnDefaultEnabled",
			Type = "Function",

			Arguments =
			{
				{ Name = "name", Type = "uiAddon", Nilable = false },
			},

			Returns =
			{
				{ Name = "defaultEnabled", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsAddOnLoadOnDemand",
			Type = "Function",

			Arguments =
			{
				{ Name = "name", Type = "uiAddon", Nilable = false },
			},

			Returns =
			{
				{ Name = "loadOnDemand", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsAddOnLoadable",
			Type = "Function",

			Arguments =
			{
				{ Name = "name", Type = "uiAddon", Nilable = false },
				{ Name = "character", Type = "cstring", Nilable = false, Default = "0" },
				{ Name = "demandLoaded", Type = "bool", Nilable = false, Default = false },
			},

			Returns =
			{
				{ Name = "loadable", Type = "bool", Nilable = false },
				{ Name = "reason", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "IsAddOnLoaded",
			Type = "Function",

			Arguments =
			{
				{ Name = "name", Type = "uiAddon", Nilable = false },
			},

			Returns =
			{
				{ Name = "loadedOrLoading", Type = "bool", Nilable = false },
				{ Name = "loaded", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsAddonVersionCheckEnabled",
			Type = "Function",

			Returns =
			{
				{ Name = "isEnabled", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "LoadAddOn",
			Type = "Function",

			Arguments =
			{
				{ Name = "name", Type = "uiAddon", Nilable = false },
			},

			Returns =
			{
				{ Name = "loaded", Type = "bool", Nilable = true },
				{ Name = "value", Type = "string", Nilable = true },
			},
		},
		{
			Name = "ResetAddOns",
			Type = "Function",
		},
		{
			Name = "ResetDisabledAddOns",
			Type = "Function",
		},
		{
			Name = "SaveAddOns",
			Type = "Function",
		},
		{
			Name = "SetAddonVersionCheck",
			Type = "Function",

			Arguments =
			{
				{ Name = "enabled", Type = "bool", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "AddonLoaded",
			Type = "Event",
			LiteralName = "ADDON_LOADED",
			Payload =
			{
				{ Name = "addOnName", Type = "cstring", Nilable = false },
				{ Name = "containsBindings", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "AddonsUnloading",
			Type = "Event",
			LiteralName = "ADDONS_UNLOADING",
			Payload =
			{
				{ Name = "closingClient", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SavedVariablesTooLarge",
			Type = "Event",
			LiteralName = "SAVED_VARIABLES_TOO_LARGE",
			Payload =
			{
				{ Name = "addOnName", Type = "cstring", Nilable = false },
			},
		},
	},

	Tables =
	{
		{
			Name = "AddOnEnableState",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "None", Type = "AddOnEnableState", EnumValue = 0 },
				{ Name = "Some", Type = "AddOnEnableState", EnumValue = 1 },
				{ Name = "All", Type = "AddOnEnableState", EnumValue = 2 },
			},
		},
		{
			Name = "AddOnInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "name", Type = "cstring", Nilable = false },
				{ Name = "title", Type = "cstring", Nilable = false },
				{ Name = "notes", Type = "cstring", Nilable = false },
				{ Name = "loadable", Type = "bool", Nilable = false },
				{ Name = "reason", Type = "cstring", Nilable = false },
				{ Name = "security", Type = "cstring", Nilable = false },
				{ Name = "updateAvailable", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "AddOnLoadableInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "loadable", Type = "bool", Nilable = false },
				{ Name = "reason", Type = "cstring", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(AddOns);