local SpellActivationOverlay =
{
	Name = "SpellActivationOverlay",
	Type = "System",
	Namespace = "C_SpellActivationOverlay",

	Functions =
	{
		{
			Name = "IsSpellOverlayed",
			Type = "Function",

			Arguments =
			{
				{ Name = "spellID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "isSpellOverlayed", Type = "bool", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "SpellActivationOverlayGlowHide",
			Type = "Event",
			LiteralName = "SPELL_ACTIVATION_OVERLAY_GLOW_HIDE",
			Payload =
			{
				{ Name = "spellID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SpellActivationOverlayGlowShow",
			Type = "Event",
			LiteralName = "SPELL_ACTIVATION_OVERLAY_GLOW_SHOW",
			Payload =
			{
				{ Name = "spellID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SpellActivationOverlayHide",
			Type = "Event",
			LiteralName = "SPELL_ACTIVATION_OVERLAY_HIDE",
			Payload =
			{
				{ Name = "spellID", Type = "number", Nilable = true },
			},
		},
		{
			Name = "SpellActivationOverlayShow",
			Type = "Event",
			LiteralName = "SPELL_ACTIVATION_OVERLAY_SHOW",
			Payload =
			{
				{ Name = "spellID", Type = "number", Nilable = false },
				{ Name = "overlayFileDataID", Type = "number", Nilable = false },
				{ Name = "locationType", Type = "ScreenLocationType", Nilable = false },
				{ Name = "scale", Type = "number", Nilable = false },
				{ Name = "r", Type = "number", Nilable = false },
				{ Name = "g", Type = "number", Nilable = false },
				{ Name = "b", Type = "number", Nilable = false },
			},
		},
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(SpellActivationOverlay);