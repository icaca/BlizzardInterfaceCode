local blueBarAtlas = "UI-HUD-ExperienceBar-Fill-Reputation-Faction-Blue";
local barAtlases =
{
	"UI-HUD-ExperienceBar-Fill-Reputation-Faction-Red",
	"UI-HUD-ExperienceBar-Fill-Reputation-Faction-Red",
	"UI-HUD-ExperienceBar-Fill-Reputation-Faction-Orange",
	"UI-HUD-ExperienceBar-Fill-Reputation-Faction-Yellow",
	"UI-HUD-ExperienceBar-Fill-Reputation-Faction-Green",
	"UI-HUD-ExperienceBar-Fill-Reputation-Faction-Green",
	"UI-HUD-ExperienceBar-Fill-Reputation-Faction-Green",
	"UI-HUD-ExperienceBar-Fill-Reputation-Faction-Green",
};

local blueGainFlareAtlas = "UI-HUD-ExperienceBar-Flare-Rested-2x-Flipbook";
local gainFlareAtlases =
{
	"UI-HUD-ExperienceBar-Flare-Faction-Orange-2x-Flipbook",
	"UI-HUD-ExperienceBar-Flare-Faction-Orange-2x-Flipbook",
	"UI-HUD-ExperienceBar-Flare-Faction-Orange-2x-Flipbook",
	"UI-HUD-ExperienceBar-Flare-ArtifactPower-2x-Flipbook",
	"UI-HUD-ExperienceBar-Flare-Reputation-2x-Flipbook",
	"UI-HUD-ExperienceBar-Flare-Reputation-2x-Flipbook",
	"UI-HUD-ExperienceBar-Flare-Reputation-2x-Flipbook",
	"UI-HUD-ExperienceBar-Flare-Reputation-2x-Flipbook",
};

local blueLevelUpAtlas = "UI-HUD-ExperienceBar-Fill-Rested-2x-Flipbook";
local levelUpAtlases =
{
	"UI-HUD-ExperienceBar-Fill-Honor-2x-Flipbook",
	"UI-HUD-ExperienceBar-Fill-Honor-2x-Flipbook",
	"UI-HUD-ExperienceBar-Fill-Honor-2x-Flipbook",
	"UI-HUD-ExperienceBar-Fill-ArtifactPower-2x-Flipbook",
	"UI-HUD-ExperienceBar-Fill-Reputation-2x-Flipbook",
	"UI-HUD-ExperienceBar-Fill-Reputation-2x-Flipbook",
	"UI-HUD-ExperienceBar-Fill-Reputation-2x-Flipbook",
	"UI-HUD-ExperienceBar-Fill-Reputation-2x-Flipbook",
};

ReputationStatusBarMixin = {};

function ReputationStatusBarMixin:UpdateCurrentText()
	local maxLevel = self:GetMaxLevel();
	if maxLevel and self.StatusBar.level and self.StatusBar.level >= maxLevel then
		self:SetBarText(self.name);
	else
		self:SetBarText(self.name:format(self.value, self.max));
	end
end

function ReputationStatusBarMixin:GetMaxLevel()
	local watchedFactionData = C_Reputation.GetWatchedFactionData();
	if not watchedFactionData or watchedFactionData.factionID == 0 then
		return nil;
	end

	local factionID = watchedFactionData.factionID;
	if C_Reputation.IsFactionParagonForCurrentPlayer(factionID) then
		return nil;
	end

	if C_Reputation.IsMajorFaction(factionID) then
		local renownLevelsInfo = C_MajorFactions.GetRenownLevels(factionID);
		return renownLevelsInfo[#renownLevelsInfo].level;
	end

	local reputationInfo = C_GossipInfo.GetFriendshipReputation(factionID);
	local friendshipID = reputationInfo.friendshipFactionID;
	if friendshipID > 0 then
		local repRankInfo = C_GossipInfo.GetFriendshipReputationRanks(factionID);
		return repRankInfo.maxLevel;
	end

	return MAX_REPUTATION_REACTION;
end

function ReputationStatusBarMixin:Update()
	local watchedFactionData = C_Reputation.GetWatchedFactionData();
	if not watchedFactionData or watchedFactionData.factionID == 0 then
		return;
	end

	local reactionLevel = watchedFactionData.reaction;
	local overrideUseBlueBar = false;

	local factionID = watchedFactionData.factionID;
	local isShowingNewFaction = self.factionID ~= factionID;
	if isShowingNewFaction then
		self.factionID = factionID;
		local reputationInfo = C_GossipInfo.GetFriendshipReputation(factionID);
		self.friendshipID = reputationInfo.friendshipFactionID;
	end

	-- do something different for friendships
	local level;
	local maxLevel = self:GetMaxLevel();

	local minBar, maxBar, value = watchedFactionData.currentReactionThreshold, watchedFactionData.nextReactionThreshold, watchedFactionData.currentStanding;
	if C_Reputation.IsFactionParagonForCurrentPlayer(factionID) then
		local currentValue, threshold, _, hasRewardPending = C_Reputation.GetFactionParagonInfo(factionID);
		minBar, maxBar  = 0, threshold;
		if currentValue and threshold then
			value = currentValue % threshold;
		end
		level = maxLevel;
		if hasRewardPending then
			value = value + threshold;
		end
		if C_Reputation.IsMajorFaction(factionID) then
			overrideUseBlueBar = true;
		end
	elseif C_Reputation.IsMajorFaction(factionID) then
		local majorFactionData = C_MajorFactions.GetMajorFactionData(factionID);
		minBar, maxBar = 0, majorFactionData.renownLevelThreshold;
		level = majorFactionData.renownLevel;
		overrideUseBlueBar = true;
	elseif self.friendshipID > 0 then
		local repInfo = C_GossipInfo.GetFriendshipReputation(factionID);
		local repRankInfo = C_GossipInfo.GetFriendshipReputationRanks(factionID);
		level = repRankInfo.currentLevel;
		if repInfo.nextThreshold then
			minBar, maxBar, value = repInfo.reactionThreshold, repInfo.nextThreshold, repInfo.standing;
		else
			-- max rank, make it look like a full bar
			minBar, maxBar, value = 0, 1, 1;
		end
		reactionLevel = 5; -- Friendships always use same
	else
		level = watchedFactionData.reaction;
	end

	local isCapped = (level and maxLevel) and level >= maxLevel;

	-- Normalize values
	maxBar = maxBar - minBar;
	value = value - minBar;
	if isCapped and maxBar == 0 then
		maxBar = 1;
		value = 1;
	end
	minBar = 0;

	self:SetBarValues(value, minBar, maxBar, level, maxLevel);

	local name = watchedFactionData.name;
	local needsAccountWideLabel = C_Reputation.IsAccountWideReputation(factionID);
	if needsAccountWideLabel then
		name = name .. " " .. REPUTATION_STATUS_BAR_LABEL_ACCOUNT_WIDE;
	end

	if isCapped then
		self:SetBarText(name);
	else
		name = name.." %d / %d";
		self:SetBarText(name:format(value, maxBar));
	end

	-- Update bar texture based on faction data.
	self:UpdateBarTextures(reactionLevel, overrideUseBlueBar);

	self.name = name;
	self.value = value;
	self.max = maxBar;

	-- When showing new faction, force status bar to update instantly
	if isShowingNewFaction then
		self.StatusBar:ProcessChangesInstantly();
	end
end

function ReputationStatusBarMixin:OnLoad()
	self:RegisterEvent("CVAR_UPDATE");
end

function ReputationStatusBarMixin:OnEvent(event, ...)
	if( event == "CVAR_UPDATE") then
		local cvar = ...;
		if( cvar == "xpBarText" ) then
			self:UpdateTextVisibility();
		end
	end
end

function ReputationStatusBarMixin:OnEnter()
	self:ShowText();
	self:UpdateCurrentText();
	ReputationParagonWatchBar_OnEnter(self);
end

function ReputationStatusBarMixin:OnShow()
	self:UpdateTextVisibility();
end

function ReputationStatusBarMixin:OnLeave()
	self:HideText();
	ReputationParagonWatchBar_OnLeave(self);
end
