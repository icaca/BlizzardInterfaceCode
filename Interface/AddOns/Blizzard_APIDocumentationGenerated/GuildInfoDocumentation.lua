local GuildInfo =
{
	Name = "GuildInfo",
	Type = "System",
	Namespace = "C_GuildInfo",

	Functions =
	{
		{
			Name = "AreGuildEventsEnabled",
			Type = "Function",

			Returns =
			{
				{ Name = "enabled", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "CanEditOfficerNote",
			Type = "Function",

			Returns =
			{
				{ Name = "canEditOfficerNote", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "CanSpeakInGuildChat",
			Type = "Function",

			Returns =
			{
				{ Name = "canSpeakInGuildChat", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "CanViewOfficerNote",
			Type = "Function",

			Returns =
			{
				{ Name = "canViewOfficerNote", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "Demote",
			Type = "Function",

			Arguments =
			{
				{ Name = "name", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "Disband",
			Type = "Function",
		},
		{
			Name = "GetGuildNewsInfo",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "index", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "newsInfo", Type = "GuildNewsInfo", Nilable = false },
			},
		},
		{
			Name = "GetGuildRankOrder",
			Type = "Function",

			Arguments =
			{
				{ Name = "guid", Type = "WOWGUID", Nilable = false },
			},

			Returns =
			{
				{ Name = "rankOrder", Type = "luaIndex", Nilable = false },
			},
		},
		{
			Name = "GetGuildTabardInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = true },
			},

			Returns =
			{
				{ Name = "tabardInfo", Type = "GuildTabardInfo", Nilable = true },
			},
		},
		{
			Name = "GuildControlGetRankFlags",
			Type = "Function",

			Arguments =
			{
				{ Name = "rankOrder", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "permissions", Type = "table", InnerType = "bool", Nilable = false },
			},
		},
		{
			Name = "GuildRoster",
			Type = "Function",
		},
		{
			Name = "Invite",
			Type = "Function",

			Arguments =
			{
				{ Name = "name", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "IsEncounterGuildNewsEnabled",
			Type = "Function",

			Returns =
			{
				{ Name = "enabled", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsGuildOfficer",
			Type = "Function",

			Returns =
			{
				{ Name = "isOfficer", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsGuildRankAssignmentAllowed",
			Type = "Function",

			Arguments =
			{
				{ Name = "guid", Type = "WOWGUID", Nilable = false },
				{ Name = "rankOrder", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "isGuildRankAssignmentAllowed", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsGuildReputationEnabled",
			Type = "Function",

			Returns =
			{
				{ Name = "enabled", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "Leave",
			Type = "Function",
		},
		{
			Name = "MemberExistsByName",
			Type = "Function",

			Arguments =
			{
				{ Name = "name", Type = "cstring", Nilable = false },
			},

			Returns =
			{
				{ Name = "exists", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "Promote",
			Type = "Function",

			Arguments =
			{
				{ Name = "name", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "QueryGuildMemberRecipes",
			Type = "Function",

			Arguments =
			{
				{ Name = "guildMemberGUID", Type = "WOWGUID", Nilable = false },
				{ Name = "skillLineID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "QueryGuildMembersForRecipe",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "skillLineID", Type = "number", Nilable = false },
				{ Name = "recipeSpellID", Type = "number", Nilable = false },
				{ Name = "recipeLevel", Type = "luaIndex", Nilable = true },
			},

			Returns =
			{
				{ Name = "updatedRecipeSpellID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "RemoveFromGuild",
			Type = "Function",
			HasRestrictions = true,

			Arguments =
			{
				{ Name = "guid", Type = "WOWGUID", Nilable = false },
			},
		},
		{
			Name = "RequestGuildRename",
			Type = "Function",
			HasRestrictions = true,

			Arguments =
			{
				{ Name = "desiredName", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "RequestGuildRenameRefund",
			Type = "Function",
			HasRestrictions = true,
		},
		{
			Name = "RequestRenameNameCheck",
			Type = "Function",

			Arguments =
			{
				{ Name = "desiredName", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "RequestRenameStatus",
			Type = "Function",

			Returns =
			{
				{ Name = "ableToRequest", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetGuildRankOrder",
			Type = "Function",
			HasRestrictions = true,

			Arguments =
			{
				{ Name = "guid", Type = "WOWGUID", Nilable = false },
				{ Name = "rankOrder", Type = "luaIndex", Nilable = false },
			},
		},
		{
			Name = "SetLeader",
			Type = "Function",

			Arguments =
			{
				{ Name = "name", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "SetMOTD",
			Type = "Function",

			Arguments =
			{
				{ Name = "motd", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "SetNote",
			Type = "Function",
			HasRestrictions = true,

			Arguments =
			{
				{ Name = "guid", Type = "WOWGUID", Nilable = false },
				{ Name = "note", Type = "cstring", Nilable = false },
				{ Name = "isPublic", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "Uninvite",
			Type = "Function",

			Arguments =
			{
				{ Name = "name", Type = "cstring", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "CloseTabardFrame",
			Type = "Event",
			LiteralName = "CLOSE_TABARD_FRAME",
		},
		{
			Name = "DisableDeclineGuildInvite",
			Type = "Event",
			LiteralName = "DISABLE_DECLINE_GUILD_INVITE",
		},
		{
			Name = "EnableDeclineGuildInvite",
			Type = "Event",
			LiteralName = "ENABLE_DECLINE_GUILD_INVITE",
		},
		{
			Name = "GuildChallengeCompleted",
			Type = "Event",
			LiteralName = "GUILD_CHALLENGE_COMPLETED",
			Payload =
			{
				{ Name = "challengeType", Type = "number", Nilable = false },
				{ Name = "currentCount", Type = "number", Nilable = false },
				{ Name = "maxCount", Type = "number", Nilable = false },
				{ Name = "goldAwarded", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GuildChallengeUpdated",
			Type = "Event",
			LiteralName = "GUILD_CHALLENGE_UPDATED",
		},
		{
			Name = "GuildEventLogUpdate",
			Type = "Event",
			LiteralName = "GUILD_EVENT_LOG_UPDATE",
		},
		{
			Name = "GuildInviteCancel",
			Type = "Event",
			LiteralName = "GUILD_INVITE_CANCEL",
		},
		{
			Name = "GuildInviteRequest",
			Type = "Event",
			LiteralName = "GUILD_INVITE_REQUEST",
			Payload =
			{
				{ Name = "inviter", Type = "cstring", Nilable = false },
				{ Name = "guildName", Type = "cstring", Nilable = false },
				{ Name = "guildAchievementPoints", Type = "number", Nilable = false },
				{ Name = "oldGuildName", Type = "cstring", Nilable = false },
				{ Name = "isNewGuild", Type = "bool", Nilable = true },
				{ Name = "tabardInfo", Type = "GuildTabardInfo", Nilable = true },
			},
		},
		{
			Name = "GuildMotd",
			Type = "Event",
			LiteralName = "GUILD_MOTD",
			Payload =
			{
				{ Name = "motdText", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "GuildNewsUpdate",
			Type = "Event",
			LiteralName = "GUILD_NEWS_UPDATE",
		},
		{
			Name = "GuildPartyStateUpdated",
			Type = "Event",
			LiteralName = "GUILD_PARTY_STATE_UPDATED",
			Payload =
			{
				{ Name = "inGuildParty", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GuildRanksUpdate",
			Type = "Event",
			LiteralName = "GUILD_RANKS_UPDATE",
		},
		{
			Name = "GuildRecipeKnownByMembers",
			Type = "Event",
			LiteralName = "GUILD_RECIPE_KNOWN_BY_MEMBERS",
		},
		{
			Name = "GuildRegistrarClosed",
			Type = "Event",
			LiteralName = "GUILD_REGISTRAR_CLOSED",
		},
		{
			Name = "GuildRegistrarShow",
			Type = "Event",
			LiteralName = "GUILD_REGISTRAR_SHOW",
		},
		{
			Name = "GuildRenameNameCheck",
			Type = "Event",
			LiteralName = "GUILD_RENAME_NAME_CHECK",
			Payload =
			{
				{ Name = "desiredName", Type = "cstring", Nilable = false },
				{ Name = "status", Type = "GuildErrorType", Nilable = false },
				{ Name = "nameErrorToken", Type = "cstring", Nilable = true },
			},
		},
		{
			Name = "GuildRenameRefundResult",
			Type = "Event",
			LiteralName = "GUILD_RENAME_REFUND_RESULT",
			Payload =
			{
				{ Name = "guildName", Type = "cstring", Nilable = false },
				{ Name = "status", Type = "GuildErrorType", Nilable = false },
			},
		},
		{
			Name = "GuildRenameRequired",
			Type = "Event",
			LiteralName = "GUILD_RENAME_REQUIRED",
			Payload =
			{
				{ Name = "flagSet", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GuildRenameStatusUpdate",
			Type = "Event",
			LiteralName = "GUILD_RENAME_STATUS_UPDATE",
			Payload =
			{
				{ Name = "status", Type = "GuildRenameStatus", Nilable = false },
			},
		},
		{
			Name = "GuildRewardsList",
			Type = "Event",
			LiteralName = "GUILD_REWARDS_LIST",
		},
		{
			Name = "GuildRewardsListUpdate",
			Type = "Event",
			LiteralName = "GUILD_REWARDS_LIST_UPDATE",
		},
		{
			Name = "GuildRosterUpdate",
			Type = "Event",
			LiteralName = "GUILD_ROSTER_UPDATE",
			Payload =
			{
				{ Name = "canRequestRosterUpdate", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GuildTradeskillUpdate",
			Type = "Event",
			LiteralName = "GUILD_TRADESKILL_UPDATE",
		},
		{
			Name = "GuildtabardUpdate",
			Type = "Event",
			LiteralName = "GUILDTABARD_UPDATE",
		},
		{
			Name = "OpenTabardFrame",
			Type = "Event",
			LiteralName = "OPEN_TABARD_FRAME",
		},
		{
			Name = "PlayerGuildUpdate",
			Type = "Event",
			LiteralName = "PLAYER_GUILD_UPDATE",
			Payload =
			{
				{ Name = "unitTarget", Type = "UnitToken", Nilable = false },
			},
		},
		{
			Name = "RequestedGuildRenameResult",
			Type = "Event",
			LiteralName = "REQUESTED_GUILD_RENAME_RESULT",
			Payload =
			{
				{ Name = "newName", Type = "cstring", Nilable = false },
				{ Name = "status", Type = "GuildErrorType", Nilable = false },
			},
		},
		{
			Name = "RequiredGuildRenameResult",
			Type = "Event",
			LiteralName = "REQUIRED_GUILD_RENAME_RESULT",
			Payload =
			{
				{ Name = "success", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "TabardCansaveChanged",
			Type = "Event",
			LiteralName = "TABARD_CANSAVE_CHANGED",
		},
		{
			Name = "TabardSavePending",
			Type = "Event",
			LiteralName = "TABARD_SAVE_PENDING",
		},
		{
			Name = "UnitGuildLevel",
			Type = "Event",
			LiteralName = "UNIT_GUILD_LEVEL",
			Payload =
			{
				{ Name = "newLevel", Type = "number", Nilable = false },
			},
		},
	},

	Tables =
	{
		{
			Name = "GuildNewsInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "isSticky", Type = "bool", Nilable = false },
				{ Name = "isHeader", Type = "bool", Nilable = false },
				{ Name = "newsType", Type = "number", Nilable = false },
				{ Name = "whoText", Type = "string", Nilable = true },
				{ Name = "whatText", Type = "string", Nilable = true },
				{ Name = "newsDataID", Type = "number", Nilable = false },
				{ Name = "data", Type = "table", InnerType = "number", Nilable = false },
				{ Name = "weekday", Type = "number", Nilable = false },
				{ Name = "day", Type = "number", Nilable = false },
				{ Name = "month", Type = "number", Nilable = false },
				{ Name = "year", Type = "number", Nilable = false },
				{ Name = "guildMembersPresent", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GuildRenameStatus",
			Type = "Structure",
			Fields =
			{
				{ Name = "isNameChangeEnabled", Type = "bool", Nilable = false },
				{ Name = "isPlayerGuildMaster", Type = "bool", Nilable = false },
				{ Name = "refundEligibleEndTime", Type = "time_t", Nilable = false },
				{ Name = "nextRenameTime", Type = "time_t", Nilable = false },
				{ Name = "renamePrice", Type = "WOWMONEY", Nilable = false },
				{ Name = "refundAmount", Type = "WOWMONEY", Nilable = false },
				{ Name = "currentGuildMoney", Type = "WOWMONEY", Nilable = false },
				{ Name = "result", Type = "GuildErrorType", Nilable = false },
				{ Name = "oldGuildName", Type = "cstring", Nilable = false },
				{ Name = "reservedName", Type = "cstring", Nilable = false },
				{ Name = "reservedNameExpirationTime", Type = "time_t", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(GuildInfo);