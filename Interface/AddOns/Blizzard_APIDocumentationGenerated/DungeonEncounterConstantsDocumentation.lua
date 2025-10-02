local DungeonEncounterConstants =
{
	Tables =
	{
		{
			Name = "DungeonEncounterFlags",
			Type = "Enumeration",
			NumValues = 10,
			MinValue = 1,
			MaxValue = 512,
			Fields =
			{
				{ Name = "StickyNews", Type = "DungeonEncounterFlags", EnumValue = 1 },
				{ Name = "GuildNews", Type = "DungeonEncounterFlags", EnumValue = 2 },
				{ Name = "RaidLockPlayers", Type = "DungeonEncounterFlags", EnumValue = 4 },
				{ Name = "AutoEnd", Type = "DungeonEncounterFlags", EnumValue = 8 },
				{ Name = "Cosmetic", Type = "DungeonEncounterFlags", EnumValue = 16 },
				{ Name = "Unused", Type = "DungeonEncounterFlags", EnumValue = 32 },
				{ Name = "HideUntilCompleted", Type = "DungeonEncounterFlags", EnumValue = 64 },
				{ Name = "NoAutoStart", Type = "DungeonEncounterFlags", EnumValue = 128 },
				{ Name = "IgnoreSpawnLimit", Type = "DungeonEncounterFlags", EnumValue = 256 },
				{ Name = "DisableEncounterEvents", Type = "DungeonEncounterFlags", EnumValue = 512 },
			},
		},
		{
			Name = "DungeonEncounterTriggerType",
			Type = "Enumeration",
			NumValues = 5,
			MinValue = 0,
			MaxValue = 4,
			Fields =
			{
				{ Name = "Invalid", Type = "DungeonEncounterTriggerType", EnumValue = 0 },
				{ Name = "OnStart", Type = "DungeonEncounterTriggerType", EnumValue = 1 },
				{ Name = "OnComplete", Type = "DungeonEncounterTriggerType", EnumValue = 2 },
				{ Name = "OnEnd", Type = "DungeonEncounterTriggerType", EnumValue = 3 },
				{ Name = "PreviouslyCompleted", Type = "DungeonEncounterTriggerType", EnumValue = 4 },
			},
		},
		{
			Name = "DungeonEncounterXCreatureFlags",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 1,
			MaxValue = 4,
			Fields =
			{
				{ Name = "BossCreature", Type = "DungeonEncounterXCreatureFlags", EnumValue = 1 },
				{ Name = "DropLootImmediately", Type = "DungeonEncounterXCreatureFlags", EnumValue = 2 },
				{ Name = "DoNotDespawnOnSuccess", Type = "DungeonEncounterXCreatureFlags", EnumValue = 4 },
			},
		},
		{
			Name = "EncounterEventFlags",
			Type = "Enumeration",
			NumValues = 1,
			MinValue = 1,
			MaxValue = 1,
			Fields =
			{
				{ Name = "Disabled", Type = "EncounterEventFlags", EnumValue = 1 },
			},
		},
		{
			Name = "EncounterEventSeverity",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "Low", Type = "EncounterEventSeverity", EnumValue = 0 },
				{ Name = "Medium", Type = "EncounterEventSeverity", EnumValue = 1 },
				{ Name = "High", Type = "EncounterEventSeverity", EnumValue = 2 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(DungeonEncounterConstants);