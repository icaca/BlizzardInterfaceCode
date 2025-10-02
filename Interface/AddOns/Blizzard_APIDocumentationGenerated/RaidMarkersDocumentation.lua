local RaidMarkers =
{
	Name = "RaidMarkers",
	Type = "System",

	Functions =
	{
		{
			Name = "CanBeRaidTarget",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "target", Type = "UnitToken", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ClearRaidMarker",
			Type = "Function",
			HasRestrictions = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "raidMarkerIndex", Type = "luaIndex", Nilable = false, Default = MAX_RAID_MARKERS },
			},
		},
		{
			Name = "GetRaidTargetIndex",
			Type = "Function",
			SecretReturns = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "target", Type = "UnitToken", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "luaIndex", Nilable = true },
			},
		},
		{
			Name = "IsRaidMarkerActive",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "index", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "PlaceRaidMarker",
			Type = "Function",
			HasRestrictions = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "index", Type = "luaIndex", Nilable = false },
				{ Name = "token", Type = "cstring", Nilable = true },
			},
		},
		{
			Name = "SetRaidTarget",
			Type = "Function",
			HasRestrictions = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "target", Type = "UnitToken", Nilable = false },
				{ Name = "userIndex", Type = "luaIndex", Nilable = false },
			},
		},
	},

	Events =
	{
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(RaidMarkers);