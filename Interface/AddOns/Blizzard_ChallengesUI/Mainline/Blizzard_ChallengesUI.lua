local NUM_REWARDS_PER_MEDAL = 2;
local MAXIMUM_REWARDS_LEVEL = 15;
local MAX_PER_ROW = 9;

local CHEST_STATE_WALL_OF_TEXT = 1;
local CHEST_STATE_INCOMPLETE = 2;
local CHEST_STATE_COMPLETE = 3;
local CHEST_STATE_COLLECT = 4;

local SHADOWLANDS_FIRST_SEASON = 5;

local function CreateFrames(self, array, num, template)
	while (#self[array] < num) do
		local frame = CreateFrame("Frame", nil, self, template);
	end

	for i = num + 1, #self[array] do
		self[array][i]:Hide();
	end
end

local function ReanchorFrames(frames, anchorPoint, anchor, relativePoint, width, spacing, distance)
	local num = #frames;
	local numButtons = math.min(MAX_PER_ROW, num);
	local fullWidth = (width * numButtons) + (spacing * (numButtons - 1));
	local halfWidth = fullWidth / 2;

	local numRows = math.floor((num + MAX_PER_ROW - 1) / MAX_PER_ROW) - 1;
	local fullDistance = numRows * frames[1]:GetHeight() + (numRows + 1) * distance;

	-- First frame
	frames[1]:ClearAllPoints();
	frames[1]:SetPoint(anchorPoint, anchor, relativePoint, -halfWidth, fullDistance);

	-- first row
	for i = 2, math.min(MAX_PER_ROW, #frames) do
		frames[i]:SetPoint("LEFT", frames[i-1], "RIGHT", spacing, 0);
	end

	-- n-rows after
	if (num > MAX_PER_ROW) then
		local currentExtraRow = 0;
		local finished = false;
		repeat
			local setFirst = false;
			for i = (MAX_PER_ROW + (MAX_PER_ROW * currentExtraRow)) + 1, (MAX_PER_ROW + (MAX_PER_ROW * currentExtraRow)) + MAX_PER_ROW do
				if (not frames[i]) then
					finished = true;
					break;
				end
				if (not setFirst) then
					frames[i]:SetPoint("TOPLEFT", frames[i - (MAX_PER_ROW + (MAX_PER_ROW * currentExtraRow))], "BOTTOMLEFT", 0, -distance);
					setFirst = true;
				else
					frames[i]:SetPoint("LEFT", frames[i-1], "RIGHT", spacing, 0);
				end
			end
			currentExtraRow = currentExtraRow + 1;
		until finished;
	end
end

local function LineUpFrames(frames, anchorPoint, anchor, relativePoint, width)
	local num = #frames;

	local distanceBetween = 2;
	local spacingWidth = distanceBetween * num;
	local widthRemaining = width - spacingWidth;

	local halfWidth = width / 2;

	local calculateWidth = widthRemaining / num;

	-- First frame
	frames[1]:ClearAllPoints();
	if(frames[1].Icon) then
		frames[1].Icon:SetSize(calculateWidth, calculateWidth);
	end
	frames[1]:SetSize(calculateWidth, calculateWidth);
	frames[1]:SetPoint(anchorPoint, anchor, relativePoint, -halfWidth, 5);

	for i = 2, #frames do
		if(frames[i].Icon) then
			frames[i].Icon:SetSize(calculateWidth, calculateWidth);
		end
		frames[i].Icon:SetSize(calculateWidth, calculateWidth);
		frames[i]:SetSize(calculateWidth, calculateWidth);
		frames[i]:SetPoint("LEFT", frames[i-1], "RIGHT", distanceBetween, 0);
	end

end

ChallengesFrameMixin = {};

function ChallengesFrameMixin:OnLoad()
	-- events
	self:RegisterEvent("CHALLENGE_MODE_MAPS_UPDATE");
	self:RegisterEvent("CHALLENGE_MODE_MEMBER_INFO_UPDATED");
	self:RegisterEvent("CHALLENGE_MODE_LEADERS_UPDATE");
	self:RegisterEvent("CHALLENGE_MODE_COMPLETED");
	self:RegisterEvent("CHALLENGE_MODE_RESET");

	self.leadersAvailable = false;
	self.maps = C_ChallengeMode.GetMapTable();
end

function ChallengesFrameMixin:OnEvent(event)
	if (event == "CHALLENGE_MODE_RESET") then
		StaticPopup_Hide("RESURRECT");
		StaticPopup_Hide("RESURRECT_NO_SICKNESS");
		StaticPopup_Hide("RESURRECT_NO_TIMER");
	else
		if (event == "CHALLENGE_MODE_LEADERS_UPDATE") then
			self.leadersAvailable = true;
		end
		self:Update();
	end
end

function ChallengesFrameMixin:OnShow()
	self:RegisterEvent("BAG_UPDATE");
	self:RegisterEvent("WEEKLY_REWARDS_UPDATE");
	self:RegisterEvent("MYTHIC_PLUS_CURRENT_AFFIX_UPDATE");

	PVEFrame:SetPortraitToAsset("Interface\\Icons\\achievement_bg_wineos_underxminutes");

	self:UpdateTitle();

	C_MythicPlus.RequestCurrentAffixes();
	C_MythicPlus.RequestMapInfo();
	for i = 1, #self.maps do
		C_ChallengeMode.RequestLeaders(self.maps[i]);
	end

	self:Update();
end

function ChallengesFrameMixin:OnHide()
	self:UnregisterEvent("BAG_UPDATE");
	self:UnregisterEvent("WEEKLY_REWARDS_UPDATE");
	self:UnregisterEvent("MYTHIC_PLUS_CURRENT_AFFIX_UPDATE");
end

function ChallengesFrameMixin:Update()
	local sortedMaps = {};

	for i = 1, #self.maps do
		local inTimeInfo, overtimeInfo = C_MythicPlus.GetSeasonBestForMap(self.maps[i]);
		local level = 0;
		local dungeonScore = 0;
		if(inTimeInfo and overtimeInfo) then
			local inTimeScoreIsBetter = inTimeInfo.dungeonScore > overtimeInfo.dungeonScore;
			level = inTimeScoreIsBetter and inTimeInfo.level or overtimeInfo.level;
			dungeonScore = inTimeScoreIsBetter and inTimeInfo.dungeonScore or overtimeInfo.dungeonScore;
		elseif(inTimeInfo or overtimeInfo) then
			level = inTimeInfo and inTimeInfo.level or overtimeInfo.level;
			dungeonScore = inTimeInfo and inTimeInfo.dungeonScore or overtimeInfo.dungeonScore;
		end
		local name = C_ChallengeMode.GetMapUIInfo(self.maps[i]);
		tinsert(sortedMaps, { id = self.maps[i], level = level, dungeonScore = dungeonScore, name = name});
	end

	table.sort(sortedMaps,
	function(a, b)
		if(b.dungeonScore ~= a.dungeonScore) then
			return a.dungeonScore > b.dungeonScore;
		else
			return strcmputf8i(a.name, b.name) > 0;
		end
	end);

	local hasWeeklyRun = false;
	local weeklySortedMaps = {};
	for i = 1, #self.maps do
		local _, weeklyLevel = C_MythicPlus.GetWeeklyBestForMap(self.maps[i])
		if (not weeklyLevel) then
			weeklyLevel = 0;
		else
			hasWeeklyRun = true;
		end
		tinsert(weeklySortedMaps, { id = self.maps[i], weeklyLevel = weeklyLevel});
	end

	table.sort(weeklySortedMaps, function(a, b) return a.weeklyLevel > b.weeklyLevel end);

	local frameWidth = self.WeeklyInfo:GetWidth()

	local num = #sortedMaps;

	CreateFrames(self, "DungeonIcons", num, "ChallengesDungeonIconFrameTemplate");
	LineUpFrames(self.DungeonIcons, "BOTTOMLEFT", self, "BOTTOM", frameWidth);

	for i = 1, #sortedMaps do
		local frame = self.DungeonIcons[i];
		frame:SetUp(sortedMaps[i], i == 1);
		frame:Show();

		if (i == 1) then
			self.WeeklyInfo.Child.SeasonBest:ClearAllPoints();
			self.WeeklyInfo.Child.SeasonBest:SetPoint("TOPLEFT", self.DungeonIcons[i], "TOPLEFT", 5, 15);
		end
	end

	local _, _, _, _, backgroundTexture = C_ChallengeMode.GetMapUIInfo(sortedMaps[1].id);
	if (backgroundTexture ~= 0) then
		self.Background:SetTexture(backgroundTexture);
	end

	self.WeeklyInfo:SetUp(hasWeeklyRun, sortedMaps[1]);

	local chestFrame = self.WeeklyInfo.Child.WeeklyChest;
	local bestMapID = weeklySortedMaps[1].id;
	local dungeonScore = C_ChallengeMode.GetOverallDungeonScore();
	local chestState = chestFrame:Update(bestMapID, dungeonScore);
	chestFrame:SetShown(chestState ~= CHEST_STATE_WALL_OF_TEXT);
	local color = C_ChallengeMode.GetDungeonScoreRarityColor(dungeonScore);
	if(color) then
		self.WeeklyInfo.Child.DungeonScoreInfo.Score:SetVertexColor(color.r, color.g, color.b);
	end
	self.WeeklyInfo.Child.DungeonScoreInfo.Score:SetText(dungeonScore);
	self.WeeklyInfo.Child.DungeonScoreInfo:SetShown(chestFrame:IsShown());

	if chestState == CHEST_STATE_COLLECT then
		self.WeeklyInfo.Child.ThisWeekLabel:Hide();
		self.WeeklyInfo.Child.Description:Hide();
	elseif chestState == CHEST_STATE_COMPLETE then
		self.WeeklyInfo.Child.ThisWeekLabel:Show();
		self.WeeklyInfo.Child.Description:Hide();
	elseif chestState == CHEST_STATE_INCOMPLETE then
		self.WeeklyInfo.Child.ThisWeekLabel:Show();
		self.WeeklyInfo.Child.Description:Hide();
	else
		self.WeeklyInfo.Child.ThisWeekLabel:Hide();
		self.WeeklyInfo.Child.Description:Show();
		if sortedMaps[1].level == 0 and not C_MythicPlus.GetOwnedKeystoneLevel() then
			self.WeeklyInfo:HideAffixes();
		end
	end

	local lastSeasonNumber = tonumber(GetCVar("newMythicPlusSeason"));
	local currentSeason = C_MythicPlus.GetCurrentSeason();
	if (currentSeason and lastSeasonNumber < currentSeason) then
		local noticeFrame = self.SeasonChangeNoticeFrame;
		if (currentSeason == SHADOWLANDS_FIRST_SEASON) then
			noticeFrame.SeasonDescription:SetText(MYTHIC_PLUS_FIRST_SEASON);
			noticeFrame.SeasonDescription2:SetText(nil);
			noticeFrame.SeasonDescription3:SetPoint("TOP", noticeFrame.SeasonDescription, "BOTTOM", 0, -14);
		else
			noticeFrame.SeasonDescription:SetText(MYTHIC_PLUS_SEASON_DESC1);
			noticeFrame.SeasonDescription2:SetText(MYTHIC_PLUS_SEASON_DESC2);
			noticeFrame.SeasonDescription3:SetPoint("TOP", noticeFrame.SeasonDescription2, "BOTTOM", 0, -14);
		end
		noticeFrame.Affix:Hide();
		local affixes = C_MythicPlus.GetCurrentAffixes();
		if (affixes) then
			for i, affix in ipairs(affixes) do
				if(affix.seasonID == currentSeason) then
					noticeFrame.Affix:SetUp(affix.id);
					local affixName = C_ChallengeMode.GetAffixInfo(affix.id);
					noticeFrame.SeasonDescription3:SetText(MYTHIC_PLUS_SEASON_DESC3:format(affixName));
					break;
				end
			end
		end
		self.SeasonChangeNoticeFrame:Show();
	end
end

function ChallengesFrameMixin:UpdateTitle()
	local currentDisplaySeason =  C_MythicPlus.GetCurrentUIDisplaySeason();
	if ( not currentDisplaySeason ) then
		PVEFrame:SetTitle(CHALLENGES);
		return;
	end

	local currExpID = GetExpansionLevel();
	local expName = _G["EXPANSION_NAME"..currExpID];
	local title = MYTHIC_DUNGEON_SEASON:format(expName, currentDisplaySeason);
	PVEFrame:SetTitle(title);
end

ChallengeModeWeeklyChestMixin = CreateFromMixins(WeeklyRewardMixin);

function ChallengeModeWeeklyChestMixin:Update(bestMapID, dungeonScore)
	local chestState = CHEST_STATE_WALL_OF_TEXT;

	local vaultIconState = "";
	if C_WeeklyRewards.HasAvailableRewards() then
		chestState = CHEST_STATE_COLLECT;

		vaultIconState = "collect";
		self.RunStatus:SetText(MYTHIC_PLUS_COLLECT_GREAT_VAULT);
		self.AnimTexture:Show();
		self.AnimTexture.Anim:Play();
	elseif self:HasUnlockedRewards(Enum.WeeklyRewardChestThresholdType.Activities) then
		chestState = CHEST_STATE_COMPLETE;

		vaultIconState = "complete";
		self.RunStatus:SetText(MYTHIC_PLUS_COMPLETE_MYTHIC_DUNGEONS);
		self.AnimTexture:Hide();
	elseif C_MythicPlus.GetOwnedKeystoneLevel() or (dungeonScore and dungeonScore > 0) then
		chestState = CHEST_STATE_INCOMPLETE;

		vaultIconState = "incomplete";
		self.RunStatus:SetText(MYTHIC_PLUS_COMPLETE_MYTHIC_DUNGEONS);
		self.AnimTexture:Hide();
	end

	local vaultIconAtlas = "gficon-chest-evergreen-greatvault-";
	if vaultIconState ~= "" then
		self.Icon:SetAtlas(vaultIconAtlas..vaultIconState, TextureKitConstants.UseAtlasSize);
		self.Highlight:SetAtlas(vaultIconAtlas..vaultIconState, TextureKitConstants.UseAtlasSize);
	end

	self.state = chestState;
	return chestState;
end

function ChallengeModeWeeklyChestMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip_SetTitle(GameTooltip, GREAT_VAULT_REWARDS);

	-- always direct players to great vault if there are rewards to be claimed
	if self.state == CHEST_STATE_COLLECT then
		GameTooltip_AddColoredLine(GameTooltip, GREAT_VAULT_REWARDS_WAITING, GREEN_FONT_COLOR);
		GameTooltip_AddBlankLineToTooltip(GameTooltip);
	end

	local lastCompletedActivityInfo, nextActivityInfo = WeeklyRewardsUtil.GetActivitiesProgress();
	if not lastCompletedActivityInfo then
		GameTooltip_AddNormalLine(GameTooltip, GREAT_VAULT_REWARDS_MYTHIC_INCOMPLETE);
	else
		if nextActivityInfo then
			local globalString = (lastCompletedActivityInfo.index == 1) and GREAT_VAULT_REWARDS_MYTHIC_COMPLETED_FIRST or GREAT_VAULT_REWARDS_MYTHIC_COMPLETED_SECOND;
			GameTooltip_AddNormalLine(GameTooltip, globalString:format(nextActivityInfo.threshold - nextActivityInfo.progress));
		else
			GameTooltip_AddNormalLine(GameTooltip, GREAT_VAULT_REWARDS_MYTHIC_COMPLETED_THIRD);
			GameTooltip_AddBlankLineToTooltip(GameTooltip);
			GameTooltip_AddColoredLine(GameTooltip, GREAT_VAULT_IMPROVE_REWARD, GREEN_FONT_COLOR);
			local level, count = WeeklyRewardsUtil.GetLowestLevelInTopDungeonRuns(lastCompletedActivityInfo.threshold);
			if level == WeeklyRewardsUtil.HeroicLevel then
				GameTooltip_AddNormalLine(GameTooltip, GREAT_VAULT_REWARDS_HEROIC_IMPROVE:format(count));
			else
				local nextLevel = WeeklyRewardsUtil.GetNextMythicLevel(level);
				GameTooltip_AddNormalLine(GameTooltip, GREAT_VAULT_REWARDS_MYTHIC_IMPROVE:format(count, nextLevel));
			end
		end
	end

	GameTooltip_AddInstructionLine(GameTooltip, WEEKLY_REWARDS_CLICK_TO_PREVIEW_INSTRUCTIONS);
	GameTooltip:Show();

	if self.AnimTexture.Anim:IsPlaying() then
		self.AnimTexture:Hide();
		self.AnimTexture.Anim:Stop();
	end
end

function ChallengeModeWeeklyChestMixin:OnLeave()
	GameTooltip_Hide();
	
	if C_WeeklyRewards.HasAvailableRewards() then
		self.AnimTexture:Show();
		self.AnimTexture.Anim:Play();
	end
end

ChallengeModeLegacyWeeklyChestMixin = {};

function ChallengeModeLegacyWeeklyChestMixin:Update(bestMapID)
	self.name = C_ChallengeMode.GetMapUIInfo(bestMapID);
	self.ownedKeystoneLevel = C_MythicPlus.GetOwnedKeystoneLevel();
	self.level, self.rewardLevel, self.nextRewardLevel, self.nextBestLevel = C_MythicPlus.GetWeeklyChestRewardLevel();

	local chestState = CHEST_STATE_WALL_OF_TEXT;

	if self.level > 0 then
		chestState = CHEST_STATE_COMPLETE;

		self:SetupChest(self.CompletedKeystoneChest);

		self.RunStatus:SetPoint("TOP", 0, 25);
		self.RunStatus:SetText(MYTHIC_PLUS_BEST_WEEKLY:format(self.name, self.level));
	elseif self.ownedKeystoneLevel then
		chestState = CHEST_STATE_INCOMPLETE;

		self.rewardLevel = C_MythicPlus.GetRewardLevelFromKeystoneLevel(self.ownedKeystoneLevel);
		self:SetupChest(self.MissingKeystoneChest);

		self.RunStatus:SetPoint("TOP", 0, 25);
		self.RunStatus:SetText(MYTHIC_PLUS_INCOMPLETE_WEEKLY_KEYSTONE);
	end

	return chestState;
end

function ChallengeModeLegacyWeeklyChestMixin:SetupChest(chestFrame)
	if (chestFrame == self.CollectChest) then
		self.MissingKeystoneChest:Hide();
		self.CompletedKeystoneChest:Hide();
		chestFrame.Anim:Play();
		chestFrame.SparkleRotation:Play();

		chestFrame:Show();
		chestFrame.Level:SetText(self.level);

		self.rewardTooltipText2 = nil;
		self.rewardTooltipText = MYTHIC_PLUS_WEEKLY_CHEST_REWARD:format(self.rewardLevel);

		if (self.level >= MAXIMUM_REWARDS_LEVEL) then
			chestFrame.Level:SetVertexColor(GREEN_FONT_COLOR:GetRGB());
		else
			chestFrame.Level:SetVertexColor(HIGHLIGHT_FONT_COLOR:GetRGB());
		end
	elseif (chestFrame == self.CompletedKeystoneChest) then
		self.MissingKeystoneChest:Hide();
		self.CollectChest:Hide();
		self.CollectChest.Anim:Stop();
		self.CollectChest.SparkleRotation:Stop();

		chestFrame:Show();

		chestFrame.Level:SetText(self.level);

		self.rewardTooltipText = MYTHIC_PLUS_WEEKLY_CHEST_REWARD:format(self.rewardLevel);

		if (self.level >= MAXIMUM_REWARDS_LEVEL) then
			self.rewardTooltipText2 = MYTHIC_PLUS_CHEST_LEVEL_ABOVE_15;
			chestFrame.Level:SetVertexColor(GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b);
		else
			--This is a special case, if two levels share the same item level reward, we want to show the next highest level!
			self.rewardTooltipText2 = MYTHIC_PLUS_CHEST_LEVEL_BELOW_15:format(self.nextBestLevel, self.nextRewardLevel);
			chestFrame.Level:SetVertexColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
		end
	elseif (chestFrame == self.MissingKeystoneChest) then
		self.CompletedKeystoneChest:Hide();
		self.CollectChest:Hide();
		self.CollectChest.Anim:Stop();
		self.CollectChest.SparkleRotation:Stop();
		chestFrame:Show();

		self.rewardTooltipText2 = nil;
		self.rewardTooltipText = MYTHIC_PLUS_MISSING_WEEKLY_CHEST_REWARD:format(self.ownedKeystoneLevel, self.rewardLevel);
	end
end

function ChallengeModeLegacyWeeklyChestMixin:OnEnter()
	GameTooltip:SetText(" ");
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT", -20, -15);
	if (self.level > 0) then
		GameTooltip_SetTitle(GameTooltip, MYTHIC_PLUS_CHEST_KEYSTONE_LEVEL:format(self.level), HIGHLIGHT_FONT_COLOR);
	elseif (self.ownedKeystoneLevel) then
		GameTooltip_SetTitle(GameTooltip, MYTHIC_PLUS_CHEST_KEYSTONE_LEVEL:format(self.ownedKeystoneLevel), HIGHLIGHT_FONT_COLOR);
	end
	if (self.rewardTooltipText) then
		GameTooltip_AddNormalLine(GameTooltip, self.rewardTooltipText, true);
	end
	if (self.rewardTooltipText2) then
		GameTooltip:AddLine(" ");
		GameTooltip_AddNormalLine(GameTooltip, self.rewardTooltipText2, true);
	end
	GameTooltip:Show();
end

ChallengesDungeonIconMixin = {};

function ChallengesDungeonIconMixin:SetUp(mapInfo, isFirst)
	self.mapID = mapInfo.id;

	local _, _, _, texture = C_ChallengeMode.GetMapUIInfo(mapInfo.id);

	if (texture == 0) then
		texture = "Interface\\Icons\\achievement_bg_wineos_underxminutes";
	end

	self.Icon:SetTexture(texture);
	self.Icon:SetDesaturated(mapInfo.level == 0);

	local _, overAllScore = C_MythicPlus.GetSeasonBestAffixScoreInfoForMap(mapInfo.id);
	local color;
	if(overAllScore) then
		color = C_ChallengeMode.GetSpecificDungeonOverallScoreRarityColor(overAllScore);
	end
	if(not color) then
		color = HIGHLIGHT_FONT_COLOR;
	end

	if (mapInfo.level > 0) then
		self.HighestLevel:SetText(mapInfo.level);
		self.HighestLevel:SetTextColor(color.r, color.g, color.b);
		self.HighestLevel:Show();
	else
		self.HighestLevel:Hide();
	end
end

local function AddAffixScoreToTooltip(affixInfo)
	GameTooltip_AddBlankLineToTooltip(GameTooltip);
	GameTooltip_AddNormalLine(GameTooltip, LFG_LIST_BEST_RUN);
	GameTooltip_AddColoredLine(GameTooltip, MYTHIC_PLUS_POWER_LEVEL:format(affixInfo.level), HIGHLIGHT_FONT_COLOR);

	local displayZeroHours = affixInfo.durationSec >= SECONDS_PER_HOUR;
	local durationText = SecondsToClock(affixInfo.durationSec, displayZeroHours);

	if affixInfo.overTime then
		local overtimeText = DUNGEON_SCORE_OVERTIME_TIME:format(durationText);
		GameTooltip_AddColoredLine(GameTooltip, overtimeText, LIGHTGRAY_FONT_COLOR);
	else
		GameTooltip_AddColoredLine(GameTooltip, durationText, HIGHLIGHT_FONT_COLOR);
	end
end

function ChallengesDungeonIconMixin:OnEnter()
	local name = C_ChallengeMode.GetMapUIInfo(self.mapID);
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetText(name, 1, 1, 1);

	local inTimeInfo, overtimeInfo = C_MythicPlus.GetSeasonBestForMap(self.mapID);
	local affixScores, overallScore = C_MythicPlus.GetSeasonBestAffixScoreInfoForMap(self.mapID);

	if overallScore and (inTimeInfo or overtimeInfo) then
		local color = C_ChallengeMode.GetSpecificDungeonOverallScoreRarityColor(overallScore) or HIGHLIGHT_FONT_COLOR;
		local overallText = DUNGEON_SCORE_TOTAL_SCORE:format(color:WrapTextInColorCode(overallScore));
		GameTooltip_AddNormalLine(GameTooltip, overallText, GREEN_FONT_COLOR);
	end

	if affixScores then
		local fastestAffixScore = TableUtil.FindMin(affixScores, function(affixScore)
			return affixScore.durationSec;
		end);

		if fastestAffixScore then
			AddAffixScoreToTooltip(fastestAffixScore);
		end
	end

	GameTooltip:Show();
end

ChallengesFrameWeeklyInfoMixin = {};

function ChallengesFrameWeeklyInfoMixin:SetUp(hasWeeklyRun, bestData)
	local affixes = C_MythicPlus.GetCurrentAffixes();
	if (affixes) then
		local affixesContainer = self.Child.AffixesContainer;
		for i, affix in ipairs(affixes) do
			local affixFrame;
			if affixesContainer.Affixes and i <= #affixesContainer.Affixes then
				affixFrame = affixesContainer.Affixes[i];
			else
				affixFrame = CreateFrame("Frame", nil, affixesContainer, "ChallengesKeystoneFrameAffixTemplate");
				affixFrame.layoutIndex = i;
				affixFrame.align = "center";
			end
			affixFrame:SetUp(affix.id);
		end

		affixesContainer:Layout();
		self:Show();
	end
end

function ChallengesFrameWeeklyInfoMixin:HideAffixes()
	local affixesContainer = self.Child.AffixesContainer;
	if (affixesContainer.Affixes) then
		for _, affixFrame in ipairs(affixesContainer.Affixes) do
			affixFrame:Hide();
		end
	end
end

ChallengesKeystoneFrameMixin = {};

function ChallengesKeystoneFrameMixin:OnLoad()
	self.baseStates = {};

	local regions = {self:GetRegions()};
	for i = 1, #regions do
		local r = regions[i];
		self.baseStates[r] = {
			["shown"] = r:IsShown(),
			["alpha"] = r:GetAlpha(),
		};
	end
end

function ChallengesKeystoneFrameMixin:OnShow()
	PlaySound(SOUNDKIT.UI_70_CHALLENGE_MODE_SOCKET_PAGE_OPEN);
	self:Reset();

	ItemButtonUtil.OpenAndFilterBags(self);
end

function ChallengesKeystoneFrameMixin:OnHide()
	if (not self.startedChallengeMode) then
		PlaySound(SOUNDKIT.UI_70_CHALLENGE_MODE_SOCKET_PAGE_CLOSE);
	end
	C_ChallengeMode.CloseKeystoneFrame();
	C_ChallengeMode.ClearKeystone();
	self:Reset();

	ItemButtonUtil.CloseFilteredBags(self);
end

function ChallengesKeystoneFrameMixin:Reset()
	self.KeystoneSlot:Reset();
	self.PulseAnim:Stop();
	self.InsertedAnim:Stop();
	self.RunesLargeAnim:Stop();
	self.RunesLargeRotateAnim:Stop();
	self.RunesSmallAnim:Stop();
	self.RunesSmallRotateAnim:Stop();
	self.StartButton:Disable();
	self.TimeLimit:Hide();
	self.DungeonName:Hide();

	for i = 1, #self.Affixes do
		self.Affixes[i]:Hide();
	end

	for k, v in pairs(self.baseStates) do
		k:SetShown(v.shown);
		k:SetAlpha(v.alpha);
	end

	self.startedChallengeMode = nil;
end

function ChallengesKeystoneFrameMixin:OnMouseUp()
	if (CursorHasItem()) then
		C_ChallengeMode.SlotKeystone();
	end
end

function ChallengesKeystoneFrameMixin:ShowKeystoneFrame()
	self:Show();
end

function ChallengesKeystoneFrameMixin:CreateAndPositionAffixes(num)
	local index = #self.Affixes + 1;
	local frameWidth, spacing, distance = 52, 4, -34;
	while (#self.Affixes < num) do
		local frame = CreateFrame("Frame", nil, self, "ChallengesKeystoneFrameAffixTemplate");
		local prev = self.Affixes[index - 1];
		frame:SetPoint("LEFT", prev, "RIGHT", spacing, 0);
		index = index + 1;
	end
	-- Figure out where to place the leftmost spell
	local frame = self.Affixes[1];
	frame:ClearAllPoints();
	if (num % 2 == 1) then
		local x = (num - 1) / 2;
		frame:SetPoint("TOPLEFT", self.Divider, "TOP", -((frameWidth / 2) + (frameWidth * x) + (spacing * x)), distance);
	else
		local x = num / 2;
		frame:SetPoint("TOPLEFT", self.Divider, "TOP", -((frameWidth * x) + (spacing * (x - 1)) + (spacing / 2)), distance);
	end

	for i = num + 1, #self.Affixes do
		self.Affixes[i]:Hide();
	end
end

function ChallengesKeystoneFrameMixin:OnKeystoneSlotted()
	PlaySound(SOUNDKIT.UI_70_CHALLENGE_MODE_SOCKET_PAGE_SOCKET);
	self.InsertedAnim:Play();
	self.RunesLargeAnim:Play();
	self.RunesSmallAnim:Play();
	self.RunesLargeRotateAnim:Play();
	self.RunesSmallRotateAnim:Play();
	self.InstructionBackground:Hide();
	self.Instructions:Hide();

	local mapID, affixes, powerLevel, charged = C_ChallengeMode.GetSlottedKeystoneInfo();
	if mapID ~= nil then
		local name, _, timeLimit = C_ChallengeMode.GetMapUIInfo(mapID);

		self.DungeonName:SetText(name);
		self.DungeonName:Show();
		self.TimeLimit:SetText(SecondsToTime(timeLimit, false, true));
		self.TimeLimit:Show();

		self.PowerLevel:SetText(CHALLENGE_MODE_POWER_LEVEL:format(powerLevel));
		self.PowerLevel:Show();

		local dmgPct, healthPct = C_ChallengeMode.GetPowerLevelDamageHealthMod(powerLevel);
		local highLevelKeyDamageHealthModifier = 0;

		if (powerLevel >= 3) then
			highLevelKeyDamageHealthModifier = 2;
			self:CreateAndPositionAffixes(highLevelKeyDamageHealthModifier + #affixes);
			self.Affixes[1]:SetUp({key = "dmg", pct = dmgPct});
			self.Affixes[2]:SetUp({key = "health", pct = healthPct});
		else
			self:CreateAndPositionAffixes(highLevelKeyDamageHealthModifier + #affixes);
		end

		for i = 1, #affixes do
			self.Affixes[i+highLevelKeyDamageHealthModifier]:SetUp(affixes[i]);
		end
	end
end

function ChallengesKeystoneFrameMixin:OnKeystoneRemoved()
	PlaySound(SOUNDKIT.UI_70_CHALLENGE_MODE_SOCKET_PAGE_REMOVE_KEYSTONE);
	self:Reset();
	self.StartButton:Disable();
end

function ChallengesKeystoneFrameMixin:StartChallengeMode()
	PlaySound(SOUNDKIT.UI_70_CHALLENGE_MODE_SOCKET_PAGE_ACTIVATE_BUTTON);
	C_ChallengeMode.StartChallengeMode();
	self.startedChallengeMode = true;
	self:Hide();
end

ChallengesKeystoneSlotMixin = {};

function ChallengesKeystoneSlotMixin:OnLoad()
	self:RegisterForDrag("LeftButton");
	self:RegisterEvent("CHALLENGE_MODE_KEYSTONE_SLOTTED");
end

function ChallengesKeystoneSlotMixin:OnEvent(event, ...)
	if (event == "CHALLENGE_MODE_KEYSTONE_SLOTTED") then
		local itemID= ...;

		local texture = select(10, C_Item.GetItemInfo(itemID));

		SetPortraitToTexture(self.Texture, texture);

		self:GetParent():OnKeystoneSlotted();
	end
end

function ChallengesKeystoneSlotMixin:OnEnter()
	if (C_ChallengeMode.HasSlottedKeystone()) then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip:SetSlottedKeystone();
		GameTooltip:Show();
	end
end

function ChallengesKeystoneSlotMixin:Reset()
	self.Texture:SetTexture(nil);
end

function ChallengesKeystoneSlotMixin:OnReceiveDrag()
	C_ChallengeMode.SlotKeystone();
end

function ChallengesKeystoneSlotMixin:OnDragStart()
	if (C_ChallengeMode.RemoveKeystone()) then
		self:GetParent():Reset();
	end
end

function ChallengesKeystoneSlotMixin:OnClick()
	if (CursorHasItem()) then
		C_ChallengeMode.SlotKeystone();
	end
end

ChallengesKeystoneFrameAffixMixin = {};

CHALLENGE_MODE_EXTRA_AFFIX_INFO = {
	["dmg"] = {
		name = CHALLENGE_MODE_ENEMY_EXTRA_DAMAGE,
		desc = CHALLENGE_MODE_ENEMY_EXTRA_DAMAGE_DESCRIPTION,
		texture = "Interface\\Icons\\Ability_DualWield",
	},
	["health"] = {
		name = CHALLENGE_MODE_ENEMY_EXTRA_HEALTH,
		desc = CHALLENGE_MODE_ENEMY_EXTRA_HEALTH_DESCRIPTION,
		texture = "Interface\\Icons\\Spell_Holy_SealOfSacrifice",
	},
};

function ChallengesKeystoneFrameAffixMixin:OnEnter()
	if (self.affixID or self.info) then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");

		local name, description;

		if (self.info) then
			local tbl = CHALLENGE_MODE_EXTRA_AFFIX_INFO[self.info.key];
			name = tbl.name;
			description = string.format(tbl.desc, self.info.pct);
		else
			name, description = C_ChallengeMode.GetAffixInfo(self.affixID);
		end

		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip:SetText(name, 1, 1, 1, 1, true);
		GameTooltip:AddLine(description, nil, nil, nil, true);
		GameTooltip:Show();
	end
end

function ChallengesKeystoneFrameAffixMixin:SetUp(affixInfo)
	if (type(affixInfo) == "table") then
		local info = affixInfo;

		SetPortraitToTexture(self.Portrait, CHALLENGE_MODE_EXTRA_AFFIX_INFO[info.key].texture);

		if (info.pct > 999) then
			self.Percent:SetFontObject("SystemFont_Shadow_Med1_Outline");
		else
			self.Percent:SetFontObject("SystemFont_Shadow_Large_Outline");
		end

		self.Percent:SetText(("+%d%%"):format(info.pct));
		self.Percent:Show();

		self.info = info;
	else
		local affixID = affixInfo;

		local _, _, filedataid = C_ChallengeMode.GetAffixInfo(affixID);

		SetPortraitToTexture(self.Portrait, filedataid);

		self.Percent:Hide();

		self.affixID = affixID;
	end

	self:Show();
end

ChallengeModeCompleteBannerMixin = {};

function ChallengeModeCompleteBannerMixin:OnLoad()
	self.timeToHold = 8;
	self.unitTokens = { "player", "party1", "party2", "party3", "party4" };
	self:RegisterEvent("CHALLENGE_MODE_COMPLETED");
end

function ChallengeModeCompleteBannerMixin:OnEvent(event, ...)
	if (event == "CHALLENGE_MODE_COMPLETED") then
		local info = C_ChallengeMode.GetChallengeCompletionInfo();

		if info and not info.practiceRun then
			TopBannerManager_Show(self, info);
		end
	end
end

function ChallengeModeCompleteBannerMixin:OnMouseDown(button)
	if (button == "RightButton") then
		self:StopBanner();
		TopBannerManager_BannerFinished(self);
	end
end

local timeFormatter = CreateFromMixins(SecondsFormatterMixin);
timeFormatter:Init(1, SecondsFormatter.Abbreviation.Truncate, false, true, true);

function ChallengeModeCompleteBannerMixin:PlayBanner(challengeCompletionInfo)
	local name, _, timeLimit = C_ChallengeMode.GetMapUIInfo(challengeCompletionInfo.mapChallengeModeID);

	self.Title:SetText(name);

	self.Level:SetText(challengeCompletionInfo.level);
	local lvlStr = tostring(challengeCompletionInfo.level);
	if (tonumber(lvlStr:sub(1,1)) == 1) then
		self.Level:SetPoint("CENTER", self.SkullCircle, -4, 0);
	else
	self.Level:SetPoint("CENTER", self.SkullCircle, 0, 0);
	end

	self.Level:Show();
	local timeRemaining = math.abs(timeLimit - (challengeCompletionInfo.time / 1000));
	local timeText = (challengeCompletionInfo.time / 1000) >= SECONDS_PER_HOUR and SecondsToClock(challengeCompletionInfo.time / 1000, true) or SecondsToClock(challengeCompletionInfo.time / 1000, false);

	if (challengeCompletionInfo.onTime) then
		self.DescriptionLineOne:SetText(CHALLENGE_MODE_COMPLETE_BEAT_TIMER);
		self.DescriptionLineTwo:SetFormattedText(CHALLENGE_MODE_COMPLETE_KEYSTONE_UPGRADED, challengeCompletionInfo.keystoneUpgradeLevels);
		PlaySound(SOUNDKIT.UI_70_CHALLENGE_MODE_KEYSTONE_UPGRADE);
		local chatPrintText;

		if (challengeCompletionInfo.isMapRecord) then
			chatPrintText = CHALLENGE_MODE_TIMED_DUNGEON_CHAT_LINK_RECORD:format(name, challengeCompletionInfo.level, timeText, timeFormatter:Format(timeRemaining, false, true))
		else
			chatPrintText = CHALLENGE_MODE_TIMED_DUNGEON_CHAT_LINK:format(name, challengeCompletionInfo.level, timeText, timeFormatter:Format(timeRemaining, false, true))
		end
		local info = ChatTypeInfo["SYSTEM"];
		DEFAULT_CHAT_FRAME:AddMessage(chatPrintText, info.r, info.g, info.b, info.id);
	else
		self.DescriptionLineOne:SetText(CHALLENGE_MODE_COMPLETE_TIME_EXPIRED);
		self.DescriptionLineTwo:SetText(CHALLENGE_MODE_COMPLETE_TRY_AGAIN);
		PlaySound(SOUNDKIT.UI_70_CHALLENGE_MODE_COMPLETE_NO_UPGRADE);

		local chatPrintText;
		if (challengeCompletionInfo.isMapRecord) then
			chatPrintText = CHALLENGE_MODE_TIMED_DUNGEON_CHAT_LINK_OVERTIME_RECORD:format(name, challengeCompletionInfo.level, timeText, timeFormatter:Format(timeRemaining, false, true))
		else
			chatPrintText = CHALLENGE_MODE_TIMED_DUNGEON_OVERTIME_CHAT_LINK:format(name, challengeCompletionInfo.level, timeText, timeFormatter:Format(timeRemaining, false, true))
		end
		local info = ChatTypeInfo["SYSTEM"];
		DEFAULT_CHAT_FRAME:AddMessage(chatPrintText, info.r, info.g, info.b, info.id);
	end
	if(challengeCompletionInfo.members and #challengeCompletionInfo.members >= 1) then
		local formatString = nil;
		for i, member in ipairs(challengeCompletionInfo.members) do
			if(member.name) then
				local _, classFilename = UnitClass(member.memberGUID);
				local classColor = classFilename and RAID_CLASS_COLORS[classFilename] or NORMAL_FONT_COLOR;
				local playerString = classColor:WrapTextInColorCode(member.name);
				if(not formatString) then
					formatString = playerString
				else
					formatString = formatString..PLAYER_LIST_DELIMITER..playerString;
				end
			end
		end
		if(formatString) then
			local chatString = DUNGEON_SCORE_INCREASE_PARTY_MEMBERS:format(formatString);
			local info = ChatTypeInfo["SYSTEM"];
			DEFAULT_CHAT_FRAME:AddMessage(chatString, info.r, info.g, info.b, info.id);
		end
	end

	local isOnlyRunThisSeason = #C_MythicPlus.GetRunHistory(true, true) <= 1;
	if (challengeCompletionInfo.isEligibleForScore and ((challengeCompletionInfo.oldOverallDungeonScore and challengeCompletionInfo.newOverallDungeonScore) or (isOnlyRunThisSeason))) then
		local gainedScore = challengeCompletionInfo.newOverallDungeonScore - challengeCompletionInfo.oldOverallDungeonScore;
		local color = C_ChallengeMode.GetDungeonScoreRarityColor(challengeCompletionInfo.newOverallDungeonScore);
		if (not color) then
			color = HIGHLIGHT_FONT_COLOR;
		end
		self.DescriptionLineThree:SetText(CHALLENGE_COMPLETE_DUNGEON_SCORE:format(color:WrapTextInColorCode(CHALLENGE_COMPLETE_DUNGEON_SCORE_FORMAT_TEXT:format(challengeCompletionInfo.newOverallDungeonScore, gainedScore))));

		local showChatMessage = gainedScore or isOnlyRunThisSeason;
		if(showChatMessage) then
			local chatString;
			if(challengeCompletionInfo.keystoneUpgradeLevels and challengeCompletionInfo.keystoneUpgradeLevels > 0) then
				chatString = CHALLENGE_MODE_TIMED_DUNGEON_SCORE_KEYSTONE_UPGRADE_CHAT_LINK:format(color:WrapTextInColorCode(challengeCompletionInfo.newOverallDungeonScore), gainedScore, challengeCompletionInfo.keystoneUpgradeLevels);
			else
				chatString = CHALLENGE_MODE_TIMED_DUNGEON_SCORE_CHAT_LINK:format(color:WrapTextInColorCode(challengeCompletionInfo.newOverallDungeonScore), gainedScore);
			end
			local info = ChatTypeInfo["SYSTEM"];
			DEFAULT_CHAT_FRAME:AddMessage(chatString, info.r, info.g, info.b, info.id);
		end
	end
	local sortedUnitTokens = self:GetSortedPartyMembers();

	self:Show();
	self.AnimIn:Play();

	self:CreateAndPositionPartyMembers(#sortedUnitTokens);
	for i = 1, #sortedUnitTokens do
		self.PartyMembers[i]:SetUp(sortedUnitTokens[i]);
	end

	self.AnimOutTimer = C_Timer.NewTimer(self.timeToHold, GenerateClosure(self.PerformAnimOut, self));
end

function ChallengeModeCompleteBannerMixin:StopBanner()
	if self.AnimOutTimer then
		self.AnimOutTimer:Cancel();
		self.AnimOutTimer = nil;
	end

	self.AnimIn:Stop();
	self:Hide();
end

function ChallengeModeCompleteBannerMixin:GetSortedPartyMembers()
	local unitRoleMap = {};

	local sortedUnitTokens = {};

	local noRole = Constants.LFG_ROLEConstants.LFG_ROLE_NO_ROLE;

	for i = 1, #self.unitTokens do
		if (UnitExists(self.unitTokens[i])) then
			local role = UnitGroupRolesAssignedEnum(self.unitTokens[i]);
			if (role == Enum.LFGRole.Damage or role == noRole) then
				if (not unitRoleMap[role]) then
					unitRoleMap[role] = {};
				end
				tinsert(unitRoleMap[role], self.unitTokens[i]);
			else
				unitRoleMap[role] = self.unitTokens[i];
			end
		end
	end

	if (unitRoleMap[Enum.LFGRole.Tank]) then
		tinsert(sortedUnitTokens, unitRoleMap[Enum.LFGRole.Tank]);
	end

	if (unitRoleMap[Enum.LFGRole.Healer]) then
		tinsert(sortedUnitTokens, unitRoleMap[Enum.LFGRole.Healer]);
	end

	if (unitRoleMap[Enum.LFGRole.Damage]) then
		for i = 1, #unitRoleMap[Enum.LFGRole.Damage] do
			tinsert(sortedUnitTokens, unitRoleMap[Enum.LFGRole.Damage][i]);
		end
	end

	if (unitRoleMap[noRole]) then
		for i = 1, #unitRoleMap[noRole] do
			tinsert(sortedUnitTokens, unitRoleMap[noRole][i]);
		end
	end

	return sortedUnitTokens;
end

function ChallengeModeCompleteBannerMixin:CreateAndPositionPartyMembers(num)
	local frameWidth, spacing, distance = 61, 22, -131;

	CreateFrames(self, "PartyMembers", num, "ChallengeModeBannerPartyMemberTemplate");
	ReanchorFrames(self.PartyMembers, "TOPLEFT", self.Title, "TOP", frameWidth, spacing, distance);
end

function ChallengeModeCompleteBannerMixin:PerformAnimOut()
	self.AnimOut:Play()
	for i = 1, #self.PartyMembers do
		if (self.PartyMembers[i]:IsShown()) then
			self.PartyMembers[i].AnimOut:Play();
		end
	end
end

function ChallengeModeCompleteBanner_OnAnimOutFinished(self)
	local banner = self:GetParent();
	banner:Hide();
	banner.BannerTop:SetAlpha(0);
	banner.BannerBottom:SetAlpha(0);
	banner.BannerMiddle:SetAlpha(0);
	banner.BottomFillagree:SetAlpha(0);
	banner.RightFillagree:SetAlpha(0);
	banner.LeftFillagree:SetAlpha(0);
	banner.Title:SetAlpha(0);
	TopBannerManager_BannerFinished();
end

ChallengeModeBannerPartyMemberMixin = {};

function ChallengeModeBannerPartyMemberMixin:SetUp(unitToken)
	SetPortraitTexture(self.Portrait, unitToken);

	local name = UnitName(unitToken);
	local _, classFileName = UnitClass(unitToken);

	local classColorStr = RAID_CLASS_COLORS[classFileName].colorStr;
	self.Name:SetText(("|c%s%s|r"):format(classColorStr, name));

	local role = UnitGroupRolesAssignedEnum(unitToken);
	if ( role == Enum.LFGRole.Tank or role == Enum.LFGRole.Healer or role == Enum.LFGRole.Damage ) then
		self.RoleIcon:SetAtlas(GetMicroIconForRoleEnum(role), TextureKitConstants.IgnoreAtlasSize);
		self.RoleIcon:Show();
	else
		self.RoleIcon:Hide();
	end

	self:SetAlpha(0);
	self:Show();
	self.AnimIn:Play();
end

function MythicPlusSeasonChangeNoticeOnCloseClick(self)
	self:GetParent():Hide();
	SetCVar("newMythicPlusSeason", C_MythicPlus.GetCurrentSeason());
	PlaySound(SOUNDKIT.UI_80_ISLANDS_TUTORIAL_CLOSE);
end

DungeonScoreInfoMixin = { };

function DungeonScoreInfoMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT", 0, 0);
	GameTooltip_SetTitle(GameTooltip, DUNGEON_SCORE);
	GameTooltip_AddNormalLine(GameTooltip, DUNGEON_SCORE_DESC);
	GameTooltip:Show();
end

function DungeonScoreInfoMixin:OnLeave()
	GameTooltip:Hide();
end

function DungeonScoreInfoMixin:OnClick()
	if( IsModifiedClick("CHATLINK")) then
		local dungeonScore = C_ChallengeMode.GetOverallDungeonScore();
		local link = GetDungeonScoreLink(dungeonScore, UnitName("player"));
		if not ChatEdit_InsertLink(link) then
			ChatFrame_OpenChat(link);
		end
	end
end
