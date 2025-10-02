local GameCursor =
{
	Name = "GameCursor",
	Type = "System",

	Functions =
	{
		{
			Name = "ClearCursor",
			Type = "Function",
		},
		{
			Name = "ClearCursorHoveredItem",
			Type = "Function",
		},
		{
			Name = "CursorHasItem",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "CursorHasMacro",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "CursorHasMoney",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "CursorHasSpell",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "DeleteCursorItem",
			Type = "Function",
			HasRestrictions = true,
		},
		{
			Name = "DropCursorMoney",
			Type = "Function",
			HasRestrictions = true,
		},
		{
			Name = "EquipCursorItem",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "slot", Type = "luaIndex", Nilable = false },
			},
		},
		{
			Name = "GetCursorInfo",
			Type = "Function",
		},
		{
			Name = "GetCursorMoney",
			Type = "Function",

			Returns =
			{
				{ Name = "amount", Type = "number", Nilable = false },
			},
		},
		{
			Name = "PickupPlayerMoney",
			Type = "Function",
			HasRestrictions = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "amount", Type = "WOWMONEY", Nilable = false },
			},
		},
		{
			Name = "ResetCursor",
			Type = "Function",
		},
		{
			Name = "SellCursorItem",
			Type = "Function",
		},
		{
			Name = "SetCursor",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "name", Type = "cstring", Nilable = true },
			},

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetCursorByMode",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "mode", Type = "Cursormode", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetCursorHoveredItem",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "item", Type = "ItemLocation", Mixin = "ItemLocationMixin", Nilable = false },
			},
		},
		{
			Name = "SetCursorHoveredItemTradeItem",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "enabled", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetCursorVirtualItem",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "itemInfo", Type = "ItemInfo", Nilable = false },
				{ Name = "cursorType", Type = "UICursorType", Nilable = false },
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

APIDocumentation:AddDocumentationTable(GameCursor);