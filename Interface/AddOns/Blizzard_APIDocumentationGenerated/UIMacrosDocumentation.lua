local UIMacros =
{
	Name = "UIMacros",
	Type = "System",
	Namespace = "C_Macro",

	Functions =
	{
		{
			Name = "GetMacroName",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "macroId", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "name", Type = "cstring", Nilable = true },
			},
		},
		{
			Name = "GetSelectedMacroIcon",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "macroId", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "textureNum", Type = "fileID", Nilable = false },
			},
		},
		{
			Name = "RunMacroText",
			Type = "Function",
			HasRestrictions = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "text", Type = "cstring", Nilable = false },
				{ Name = "button", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "SetMacroExecuteLineCallback",
			Type = "Function",
			HasRestrictions = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "cb", Type = "MacroExecuteLineCallback", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "UpdateMacros",
			Type = "Event",
			LiteralName = "UPDATE_MACROS",
		},
	},

	Tables =
	{
		{
			Name = "MacroExecuteLineCallback",
			Type = "CallbackType",

			Arguments =
			{
				{ Name = "macroLine", Type = "cstring", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(UIMacros);