local SimpleStatusBarAPI =
{
	Name = "SimpleStatusBarAPI",
	Type = "ScriptObject",

	Functions =
	{
		{
			Name = "GetFillStyle",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "fillStyle", Type = "StatusBarFillStyle", Nilable = false },
			},
		},
		{
			Name = "GetMinMaxValues",
			Type = "Function",
			SecretReturnsForAspect = { Enum.SecretAspect.BarValue },

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "minValue", Type = "number", Nilable = false },
				{ Name = "maxValue", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetOrientation",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "orientation", Type = "Orientation", Nilable = false },
			},
		},
		{
			Name = "GetReverseFill",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "isReverseFill", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetRotatesTexture",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "rotatesTexture", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetStatusBarColor",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "colorR", Type = "number", Nilable = false },
				{ Name = "colorG", Type = "number", Nilable = false },
				{ Name = "colorB", Type = "number", Nilable = false },
				{ Name = "colorA", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetStatusBarDesaturation",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "desaturation", Type = "normalizedValue", Nilable = false },
			},
		},
		{
			Name = "GetStatusBarTexture",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "texture", Type = "SimpleTexture", Nilable = false },
			},
		},
		{
			Name = "GetValue",
			Type = "Function",
			SecretReturnsForAspect = { Enum.SecretAspect.BarValue },

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "value", Type = "number", Nilable = false },
			},
		},
		{
			Name = "IsStatusBarDesaturated",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "desaturated", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetColorFill",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "colorR", Type = "number", Nilable = false },
				{ Name = "colorG", Type = "number", Nilable = false },
				{ Name = "colorB", Type = "number", Nilable = false },
				{ Name = "a", Type = "SingleColorValue", Nilable = true },
			},
		},
		{
			Name = "SetFillStyle",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "fillStyle", Type = "StatusBarFillStyle", Nilable = false },
			},
		},
		{
			Name = "SetMinMaxValues",
			Type = "Function",
			SecretArgumentsAddAspect = { Enum.SecretAspect.BarValue },
			SecretArguments = "AllowedWhenTainted",

			Arguments =
			{
				{ Name = "minValue", Type = "number", Nilable = false },
				{ Name = "maxValue", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetOrientation",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "orientation", Type = "Orientation", Nilable = false },
			},
		},
		{
			Name = "SetReverseFill",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "isReverseFill", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetRotatesTexture",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "rotatesTexture", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetStatusBarColor",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "colorR", Type = "number", Nilable = false },
				{ Name = "colorG", Type = "number", Nilable = false },
				{ Name = "colorB", Type = "number", Nilable = false },
				{ Name = "a", Type = "SingleColorValue", Nilable = true },
			},
		},
		{
			Name = "SetStatusBarDesaturated",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "desaturated", Type = "bool", Nilable = false, Default = false },
			},
		},
		{
			Name = "SetStatusBarDesaturation",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "desaturation", Type = "normalizedValue", Nilable = false },
			},
		},
		{
			Name = "SetStatusBarTexture",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "asset", Type = "TextureAsset", Nilable = false },
			},

			Returns =
			{
				{ Name = "success", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetValue",
			Type = "Function",
			SecretArgumentsAddAspect = { Enum.SecretAspect.BarValue },
			SecretArguments = "AllowedWhenTainted",

			Arguments =
			{
				{ Name = "value", Type = "number", Nilable = false },
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

APIDocumentation:AddDocumentationTable(SimpleStatusBarAPI);