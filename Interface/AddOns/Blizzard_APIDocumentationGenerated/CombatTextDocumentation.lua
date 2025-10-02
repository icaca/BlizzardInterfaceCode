local CombatText =
{
	Name = "CombatText",
	Type = "System",
	Namespace = "C_CombatText",

	Functions =
	{
		{
			Name = "GetActiveUnit",
			Type = "Function",

			Returns =
			{
				{ Name = "unitTarget", Type = "string", Nilable = true },
			},
		},
		{
			Name = "GetCurrentEventInfo",
			Type = "Function",
			SecretReturns = true,

			Returns =
			{
			},
		},
		{
			Name = "SetActiveUnit",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "unitToken", Type = "UnitToken", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "CombatTextUpdate",
			Type = "Event",
			LiteralName = "COMBAT_TEXT_UPDATE",
			Payload =
			{
				{ Name = "combatTextType", Type = "cstring", Nilable = false },
			},
		},
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(CombatText);