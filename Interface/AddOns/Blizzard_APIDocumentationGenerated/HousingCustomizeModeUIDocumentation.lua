local HousingCustomizeModeUI =
{
	Name = "HousingCustomizeModeUI",
	Type = "System",
	Namespace = "C_HousingCustomizeMode",

	Functions =
	{
		{
			Name = "ApplyDyeToSelectedDecor",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "dyeSlotID", Type = "number", Nilable = false },
				{ Name = "dyeColorID", Type = "number", Nilable = true },
			},
		},
		{
			Name = "ApplyThemeToRoom",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "themeSetID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "ApplyThemeToSelectedRoomComponent",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "themeSetID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "ApplyWallpaperToAllWalls",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "wallpaperFileDataID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "ApplyWallpaperToSelectedRoomComponent",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "wallpaperFileDataID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "CancelActiveEditing",
			Type = "Function",
		},
		{
			Name = "ClearDyesForSelectedDecor",
			Type = "Function",
		},
		{
			Name = "ClearTargetRoomComponent",
			Type = "Function",
		},
		{
			Name = "CommitDyesForSelectedDecor",
			Type = "Function",

			Returns =
			{
				{ Name = "hasChanges", Type = "bool", Nilable = false },
			},
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
			Name = "GetHoveredRoomComponentInfo",
			Type = "Function",

			Returns =
			{
				{ Name = "info", Type = "HousingRoomComponentInstanceInfo", Nilable = true },
			},
		},
		{
			Name = "GetNumDyesToRemoveOnSelectedDecor",
			Type = "Function",

			Returns =
			{
				{ Name = "numDyesToRemove", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetNumDyesToSpendOnSelectedDecor",
			Type = "Function",

			Returns =
			{
				{ Name = "numDyesToSpend", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetPreviewDyesOnSelectedDecor",
			Type = "Function",

			Returns =
			{
				{ Name = "previewDyes", Type = "table", InnerType = "number", Nilable = false },
			},
		},
		{
			Name = "GetRecentlyUsedDyes",
			Type = "Function",

			Returns =
			{
				{ Name = "recentDyes", Type = "table", InnerType = "number", Nilable = false },
			},
		},
		{
			Name = "GetRecentlyUsedThemeSets",
			Type = "Function",

			Returns =
			{
				{ Name = "recentThemeSets", Type = "table", InnerType = "number", Nilable = false },
			},
		},
		{
			Name = "GetRecentlyUsedWallpapers",
			Type = "Function",

			Returns =
			{
				{ Name = "recentWallpapers", Type = "table", InnerType = "number", Nilable = false },
			},
		},
		{
			Name = "GetSelectedDecorInfo",
			Type = "Function",

			Returns =
			{
				{ Name = "info", Type = "HousingDecorInstanceInfo", Nilable = true },
			},
		},
		{
			Name = "GetSelectedRoomComponentInfo",
			Type = "Function",

			Returns =
			{
				{ Name = "info", Type = "HousingRoomComponentInstanceInfo", Nilable = true },
			},
		},
		{
			Name = "GetThemeSetInfo",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "themeSetID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "name", Type = "string", Nilable = true },
			},
		},
		{
			Name = "GetWallpapersForRoomComponentType",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "type", Type = "HousingRoomComponentType", Nilable = false },
			},

			Returns =
			{
				{ Name = "availableWallpapers", Type = "table", InnerType = "RoomComponentWallpaper", Nilable = false },
			},
		},
		{
			Name = "IsDecorSelected",
			Type = "Function",

			Returns =
			{
				{ Name = "hasSelectedDecor", Type = "bool", Nilable = false },
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
		{
			Name = "IsHoveringRoomComponent",
			Type = "Function",

			Returns =
			{
				{ Name = "isHovering", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsRoomComponentSelected",
			Type = "Function",

			Returns =
			{
				{ Name = "hasSelectedComponent", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetRoomComponentCeilingType",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "roomGUID", Type = "WOWGUID", Nilable = false },
				{ Name = "componentID", Type = "number", Nilable = false },
				{ Name = "ceilingType", Type = "HousingRoomComponentCeilingType", Nilable = false },
			},
		},
		{
			Name = "SetRoomComponentDoorType",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "roomGUID", Type = "WOWGUID", Nilable = false },
				{ Name = "componentID", Type = "number", Nilable = false },
				{ Name = "newDoortype", Type = "HousingRoomComponentDoorType", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "HousingCustomizeModeHoveredTargetChanged",
			Type = "Event",
			LiteralName = "HOUSING_CUSTOMIZE_MODE_HOVERED_TARGET_CHANGED",
			Payload =
			{
				{ Name = "hasHoveredTarget", Type = "bool", Nilable = false },
				{ Name = "targetType", Type = "HousingCustomizeModeTargetType", Nilable = false },
			},
		},
		{
			Name = "HousingCustomizeModeSelectedTargetChanged",
			Type = "Event",
			LiteralName = "HOUSING_CUSTOMIZE_MODE_SELECTED_TARGET_CHANGED",
			Payload =
			{
				{ Name = "hasSelectedTarget", Type = "bool", Nilable = false },
				{ Name = "targetType", Type = "HousingCustomizeModeTargetType", Nilable = false },
			},
		},
		{
			Name = "HousingDecorCustomizationChanged",
			Type = "Event",
			LiteralName = "HOUSING_DECOR_CUSTOMIZATION_CHANGED",
			Payload =
			{
				{ Name = "decorGUID", Type = "WOWGUID", Nilable = false },
			},
		},
		{
			Name = "HousingDecorDyeFailure",
			Type = "Event",
			LiteralName = "HOUSING_DECOR_DYE_FAILURE",
			Payload =
			{
				{ Name = "decorGUID", Type = "WOWGUID", Nilable = false },
				{ Name = "housingResult", Type = "HousingResult", Nilable = false },
			},
		},
		{
			Name = "HousingRoomComponentCustomizationChanged",
			Type = "Event",
			LiteralName = "HOUSING_ROOM_COMPONENT_CUSTOMIZATION_CHANGED",
			Payload =
			{
				{ Name = "roomGUID", Type = "WOWGUID", Nilable = false },
				{ Name = "componentID", Type = "number", Nilable = false },
			},
		},
	},

	Tables =
	{
		{
			Name = "HousingCustomizeModeTargetType",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "None", Type = "HousingCustomizeModeTargetType", EnumValue = 0 },
				{ Name = "Decor", Type = "HousingCustomizeModeTargetType", EnumValue = 1 },
				{ Name = "RoomComponent", Type = "HousingCustomizeModeTargetType", EnumValue = 2 },
			},
		},
		{
			Name = "HousingRoomComponentInstanceInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "roomGUID", Type = "WOWGUID", Nilable = false },
				{ Name = "type", Type = "HousingRoomComponentType", Nilable = false },
				{ Name = "componentID", Type = "number", Nilable = false },
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "canBeCustomized", Type = "bool", Nilable = false },
				{ Name = "currentThemeSet", Type = "number", Nilable = true },
				{ Name = "availableThemeSets", Type = "table", InnerType = "number", Nilable = false },
				{ Name = "currentWallpaper", Type = "number", Nilable = true },
				{ Name = "ceilingType", Type = "HousingRoomComponentCeilingType", Nilable = false },
				{ Name = "doorType", Type = "HousingRoomComponentDoorType", Nilable = false },
			},
		},
		{
			Name = "RoomComponentWallpaper",
			Type = "Structure",
			Fields =
			{
				{ Name = "name", Type = "cstring", Nilable = false },
				{ Name = "fileDataID", Type = "number", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(HousingCustomizeModeUI);