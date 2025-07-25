local FrameAPISimpleCheckout =
{
	Name = "FrameAPISimpleCheckout",
	Type = "ScriptObject",

	Functions =
	{
		{
			Name = "CancelOpenCheckout",
			Type = "Function",
			HasRestrictions = true,

			Arguments =
			{
			},
		},
		{
			Name = "ClearFocus",
			Type = "Function",

			Arguments =
			{
			},
		},
		{
			Name = "CloseCheckout",
			Type = "Function",
			HasRestrictions = true,

			Arguments =
			{
			},
		},
		{
			Name = "CopyExternalLink",
			Type = "Function",

			Arguments =
			{
			},
		},
		{
			Name = "OpenCheckout",
			Type = "Function",
			HasRestrictions = true,

			Arguments =
			{
				{ Name = "checkoutID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "wasOpened", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "OpenExternalLink",
			Type = "Function",

			Arguments =
			{
			},
		},
		{
			Name = "SetFocus",
			Type = "Function",

			Arguments =
			{
			},
		},
		{
			Name = "SetZoom",
			Type = "Function",
			HasRestrictions = true,

			Arguments =
			{
				{ Name = "zoomLevel", Type = "number", Nilable = false },
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

APIDocumentation:AddDocumentationTable(FrameAPISimpleCheckout);