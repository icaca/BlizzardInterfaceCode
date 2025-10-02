local HousingCleanupModeUI =
{
	Name = "HousingCleanupModeUI",
	Type = "System",
	Namespace = "C_HousingCleanupMode",

	Functions =
	{
		{
			Name = "DeleteDecor",
			Type = "Function",
		},
		{
			Name = "GetHoveredDecorInfo",
			Type = "Function",

			Returns =
			{
				{ Name = "info", Type = "HousingDecorInstanceInfo", Nilable = true },
			},
		},
		{
			Name = "IsHoveringDecor",
			Type = "Function",

			Returns =
			{
				{ Name = "isHoveringDecor", Type = "bool", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "HousingCleanupModeHoveredTargetChanged",
			Type = "Event",
			LiteralName = "HOUSING_CLEANUP_MODE_HOVERED_TARGET_CHANGED",
			Payload =
			{
				{ Name = "hasHoveredTarget", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "HousingCleanupModeTargetSelected",
			Type = "Event",
			LiteralName = "HOUSING_CLEANUP_MODE_TARGET_SELECTED",
		},
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(HousingCleanupModeUI);