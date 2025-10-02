local CombatLog =
{
	Name = "CombatLog",
	Type = "System",
	Namespace = "C_CombatLog",

	Functions =
	{
		{
			Name = "AddEventFilter",
			Type = "Function",
			HasRestrictions = true,
		},
		{
			Name = "ApplyFilterSettings",
			Type = "Function",
			HasRestrictions = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "filterSettings", Type = "LuaValueVariant", Nilable = false },
			},
		},
		{
			Name = "AreFilteredEventsEnabled",
			Type = "Function",

			Returns =
			{
				{ Name = "enabled", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ClearEntries",
			Type = "Function",
		},
		{
			Name = "ClearEventFilters",
			Type = "Function",
			HasRestrictions = true,
		},
		{
			Name = "DoesObjectMatchFilter",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "mask", Type = "CombatLogObject", Nilable = false },
				{ Name = "flags", Type = "CombatLogObject", Nilable = false },
			},

			Returns =
			{
				{ Name = "matches", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetCurrentEntryInfo",
			Type = "Function",
			HasRestrictions = true,

			Returns =
			{
			},
		},
		{
			Name = "GetCurrentEventInfo",
			Type = "Function",
			HasRestrictions = true,

			Returns =
			{
			},
		},
		{
			Name = "GetEntryCount",
			Type = "Function",
			HasRestrictions = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "ignoreFilter", Type = "bool", Nilable = false, Default = false },
			},

			Returns =
			{
				{ Name = "count", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetEntryRetentionTime",
			Type = "Function",

			Returns =
			{
				{ Name = "retentionTime", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetMessageLimit",
			Type = "Function",

			Returns =
			{
				{ Name = "messageLimit", Type = "number", Nilable = false },
			},
		},
		{
			Name = "IsCombatLogRestricted",
			Type = "Function",

			Returns =
			{
				{ Name = "restricted", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "RefilterEntries",
			Type = "Function",
		},
		{
			Name = "SeekToNewestEntry",
			Type = "Function",
			HasRestrictions = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "ignoreFilter", Type = "bool", Nilable = false, Default = false },
			},

			Returns =
			{
				{ Name = "isValidEntry", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SeekToPreviousEntry",
			Type = "Function",
			HasRestrictions = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "ignoreFilter", Type = "bool", Nilable = false, Default = false },
			},

			Returns =
			{
				{ Name = "isValidEntry", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetEntryRetentionTime",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "retentionTime", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetFilteredEventsEnabled",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "enabled", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetMessageLimit",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "messageLimit", Type = "number", Nilable = false },
			},
		},
		{
			Name = "ShouldShowCurrentEntry",
			Type = "Function",
			HasRestrictions = true,

			Returns =
			{
				{ Name = "shouldShow", Type = "bool", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "CombatLogEntriesCleared",
			Type = "Event",
			LiteralName = "COMBAT_LOG_ENTRIES_CLEARED",
		},
		{
			Name = "CombatLogEvent",
			Type = "Event",
			LiteralName = "COMBAT_LOG_EVENT",
		},
		{
			Name = "CombatLogEventUnfiltered",
			Type = "Event",
			LiteralName = "COMBAT_LOG_EVENT_UNFILTERED",
		},
		{
			Name = "CombatLogMessageLimitChanged",
			Type = "Event",
			LiteralName = "COMBAT_LOG_MESSAGE_LIMIT_CHANGED",
			Payload =
			{
				{ Name = "messageLimit", Type = "number", Nilable = false },
			},
		},
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(CombatLog);