local GameRules =
{
	Name = "GameRules",
	Type = "System",
	Namespace = "C_GameRules",

	Functions =
	{
		{
			Name = "AutoConnectToGameModeRealm",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "gameModeRecordID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "DoesGameModeHavePromo",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "gameModeRecordID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "hasPromo", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetActiveGameMode",
			Type = "Function",

			Returns =
			{
				{ Name = "gameMode", Type = "GameMode", Nilable = false },
			},
		},
		{
			Name = "GetCurrentEventRealmQueues",
			Type = "Function",

			Returns =
			{
				{ Name = "eventRealmQueues", Type = "EventRealmQueues", Nilable = false },
			},
		},
		{
			Name = "GetCurrentGameModeDisplayInfo",
			Type = "Function",

			Returns =
			{
				{ Name = "info", Type = "GameModeDisplayInfo", Nilable = true },
			},
		},
		{
			Name = "GetCurrentGameModeRecordID",
			Type = "Function",

			Returns =
			{
				{ Name = "gameModeRecordID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetDisplayedGameModeRecordIDAtIndex",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "displayIndex", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "gameModeRecordID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetGameModeDisplayInfoByRecordID",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "gameModeRecordID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "info", Type = "GameModeDisplayInfo", Nilable = true },
			},
		},
		{
			Name = "GetGameModeGlueScreenName",
			Type = "Function",

			Returns =
			{
				{ Name = "screenName", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "GetGameModePromoGlobalString",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "gameModeRecordID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "promoGlobalString", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "GetGameRuleAsFloat",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Returns the numeric value specified in the Game Rule, multiplied by 0.1 for every decimal place requested" },

			Arguments =
			{
				{ Name = "gameRule", Type = "GameRule", Nilable = false },
				{ Name = "decimalPlaces", Type = "number", Nilable = false, Default = 0 },
			},

			Returns =
			{
				{ Name = "value", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetGameRuleAsFrameStrata",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Returns the value specified in the Game Rule converted to a frame strata" },

			Arguments =
			{
				{ Name = "gameRule", Type = "GameRule", Nilable = false },
			},

			Returns =
			{
				{ Name = "frameStrata", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "GetNumDisplayedGameModes",
			Type = "Function",

			Returns =
			{
				{ Name = "numDisplayedGameModes", Type = "number", Nilable = false },
			},
		},
		{
			Name = "IsCharacterlessLoginActive",
			Type = "Function",

			Returns =
			{
				{ Name = "active", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsClassAllowedForGameMode",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "classID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "valid", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsGameModeEnabled",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "gameModeRecordID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "enabled", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsGameRuleActive",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "gameRule", Type = "GameRule", Nilable = false },
			},

			Returns =
			{
				{ Name = "isActive", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsMultiActionBarVisibilityForced",
			Type = "Function",

			Returns =
			{
				{ Name = "valid", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsPersonalResourceDisplayEnabled",
			Type = "Function",
			Documentation = { "Checks the game rule as well as nameplateShowSelf" },

			Returns =
			{
				{ Name = "isPersonalResourceDisplayEnabled", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsPlunderstorm",
			Type = "Function",

			Returns =
			{
				{ Name = "active", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsStandard",
			Type = "Function",

			Returns =
			{
				{ Name = "active", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsWoWHack",
			Type = "Function",

			Returns =
			{
				{ Name = "active", Type = "bool", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "ActiveGameModeUpdated",
			Type = "Event",
			LiteralName = "ACTIVE_GAME_MODE_UPDATED",
			Payload =
			{
				{ Name = "gameMode", Type = "GameMode", Nilable = false },
			},
		},
		{
			Name = "EventRealmQueuesUpdated",
			Type = "Event",
			LiteralName = "EVENT_REALM_QUEUES_UPDATED",
			Payload =
			{
				{ Name = "eventRealmQueues", Type = "EventRealmQueues", Nilable = false },
			},
		},
		{
			Name = "GameModeDisplayInfoUpdated",
			Type = "Event",
			LiteralName = "GAME_MODE_DISPLAY_INFO_UPDATED",
		},
		{
			Name = "GameModeDisplayModeToggleDisabled",
			Type = "Event",
			LiteralName = "GAME_MODE_DISPLAY_MODE_TOGGLE_DISABLED",
			Payload =
			{
				{ Name = "gameModeRecordID", Type = "number", Nilable = false },
				{ Name = "disabled", Type = "bool", Nilable = false },
			},
		},
	},

	Tables =
	{
		{
			Name = "GameModeDisplayInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "logo", Type = "fileID", Nilable = false },
				{ Name = "logoHeight", Type = "number", Nilable = false },
				{ Name = "logoVerticalOffset", Type = "number", Nilable = false },
				{ Name = "logoShrunkenHeight", Type = "number", Nilable = false },
				{ Name = "logoUsesDarkBackdrop", Type = "bool", Nilable = false },
				{ Name = "characterCreateExtraHeight", Type = "number", Nilable = false },
				{ Name = "characterCreateOuterBorder", Type = "fileID", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(GameRules);