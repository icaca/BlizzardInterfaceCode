local BACKGROUND_MODEL_ID = 5582785;
local IsFindingMatch = false;
local ShouldUseSavedPlaylistValue = true;

local PlunderstormLobbyEvents =
{
	"LOBBY_MATCHMAKER_PARTY_UPDATE",
	"BN_FRIEND_INVITE_ADDED",
	"NEW_MATCHMAKING_PARTY_INVITE",
};

local function ExitPlunderstormLobby()
	PlunderstormLobbyFrame.PlunderstormLobbyFriendsButton:DisableUntilNextUpdate();

    PlaySound(SOUNDKIT.GS_CHARACTER_SELECTION_EXIT);
    C_Login.DisconnectFromServer();
end

PlunderstormLobbyMixin = { };
function PlunderstormLobbyMixin:OnLoad()
	self:SetBackgroundModel(PlunderstormBackground);

	self:AddDynamicEventMethod(EventRegistry, "FriendsFrame.OnFriendsOnlineUpdated", self.OnFriendsOnlineUpdated);
	self:AddDynamicEventMethod(EventRegistry, "MatchmakingQueueType.PlayerUpdatedPartyList", self.OnPlayerUpdatedPartyList);

	self.NavBar:SetRealmsButtonEnabled(false);
	self.NavBar:SetCampsButtonEnabled(false);
end

function PlunderstormLobbyMixin:ChangeGameMode(newGameMode)
	assert(newGameMode);
	if C_GameRules.GetActiveGameMode() == newGameMode then
		return;
	end

	if newGameMode == Enum.GameMode.Plunderstorm then
		-- If we changed character order persist it
		CharacterSelect_SaveCharacterOrder();
		-- Swap to the Plunderstorm Realm
		C_RealmList.ConnectToEventRealm(GetCVar("plunderStormRealm")); --WOWLABSTODO: Should this CVar thing be hidden from lua?
		                                                                 --WOWLABSTODO: This returns false on failure, we should show an error message
	else
		-- Ensure we have auto realm select enabled
		CharacterSelect_SetAutoSwitchRealm(true);
		C_RealmList.ReconnectExceptCurrentRealm();

		-- Grab the RealmList again and allow the automatic system to select a realm for us
		C_RealmList.RequestChangeRealmList();
	end
end

function PlunderstormLobbyMixin:OnShow()
	CallbackRegistrantMixin.OnShow(self);

	C_AddOns.LoadAddOn("Blizzard_PlunderstormBasics");
	PlunderstormBasicsContainerFrame:SetParent(self);
	PlunderstormBasicsContainerFrame:ClearAllPoints();
	PlunderstormBasicsContainerFrame:SetPoint("TOPRIGHT", self, "TOPRIGHT", -46, -70);
	PlunderstormBasicsContainerFrame:SetBottomFrame(self.PlunderstormLobbyBackButton);

	C_AddOns.LoadAddOn("Blizzard_AccountStore");
	AccountStoreFrame:SetStoreFrontID(Constants.AccountStoreConsts.PlunderstormStoreFrontID);

	ChatFrame1:SetPoint("BOTTOMLEFT", 32, 60);
	ChatFrame1:Show();

	FrameUtil.RegisterFrameForEvents(self,PlunderstormLobbyEvents);
	self.PlunderstormBackground:SetSequence(0);
	self.PlunderstormBackground:SetCamera(0);

    GluePartyPoseFrame:Show();
	GluePartyPoseFrame:Init();

	if BNConnected() then
		local numInvites = BNGetNumFriendInvites() + C_WoWLabsMatchmaking.GetNumPartyInvites();
		self.PlunderstormLobbyFriendsButton.Flash.Anim:SetPlaying(numInvites > 0);
	end

	self:Update();

	local isFrontEndChatEnabled = C_GameRules.IsGameRuleActive(Enum.GameRule.FrontEndChat);
	GeneralDockManager:SetShown(isFrontEndChatEnabled);
	ChatFrame1:SetShown(isFrontEndChatEnabled);
end

function PlunderstormLobbyMixin:OnFriendsOnlineUpdated(numOnlineFriends)
	self.PlunderstormLobbyFriendsButton:SetFriendsOnline(numOnlineFriends);
end

function PlunderstormLobbyMixin:SetPlayerReady(ready)
	self.GameModeSettingsFrame:SetPlayerReady(ready);
end

function PlunderstormLobbyMixin:OnHide()
	CallbackRegistrantMixin.OnHide(self);
	FrameUtil.UnregisterFrameForEvents (self,PlunderstormLobbyEvents);

	FriendsFrame:Hide();

	if AccountStoreFrame and AccountStoreFrame:IsShown() then
		AccountStoreUtil.SetAccountStoreShown(false);
	end
end

function PlunderstormLobbyMixin:OnPlayerUpdatedPartyList()
	ShouldUseSavedPlaylistValue = false;
end

function PlunderstormLobbyMixin:OnEvent(event, ...)
	if event == "LOBBY_MATCHMAKER_PARTY_UPDATE" then
		if ShouldUseSavedPlaylistValue then 
			local success = C_WoWLabsMatchmaking.SetPartyPlaylistEntry(GetCVar("last_matchmaking_party_size"));
			ShouldUseSavedPlaylistValue = not success;
		else
			SetCVar("last_matchmaking_party_size", C_WoWLabsMatchmaking.GetPartyPlaylistEntry());
		end

		self:Update();

		if IsFindingMatch ~= C_WoWLabsMatchmaking.IsFindingMatch() then
			self.MatchmakingQueueFrame:ResetTimer();
		end
		IsFindingMatch = C_WoWLabsMatchmaking.IsFindingMatch();
	elseif ( event == "BN_FRIEND_INVITE_ADDED" or event == "NEW_MATCHMAKING_PARTY_INVITE" ) then
		self.PlunderstormLobbyFriendsButton.Flash.Anim:SetPlaying(true);
		local text = event == "BN_FRIEND_INVITE_ADDED" and TOAST_NEW_FRIEND_INVITE_WOWLABS or TOAST_NEW_PARTY_INVITE_WOWLABS;
		FriendsToastFrame.ToastText:SetText(text);
		if FriendsToastFrame.ToastIn:IsPlaying() then
			FriendsToastFrame.ToastIn:Stop();
		end
		FriendsToastFrame.ToastIn:Play();
	end
end

function PlunderstormLobbyMixin:Update()
	if C_WoWLabsMatchmaking.IsFastLogin() then
		self.MatchmakingQueueFrame:SetSquadSize(C_WoWLabsMatchmaking.GetPartyPlaylistEntry());
		self.MatchmakingQueueFrame.LeaveQueueButton:Disable();
		self.GameModeSettingsFrame:UpdateButtons();
		return;
	end

	if IsTrialAccount() or IsVeteranTrialAccount() then
		self.MatchmakingQueueFrame:Hide();
		self.GameModeSettingsFrame:Hide();
		self.SubNoticeFrame:Show();
		return;
	else
		self.SubNoticeFrame:Hide();
	end

	if C_WoWLabsMatchmaking.IsFindingMatch() then
		self.MatchmakingQueueFrame.LeaveQueueButton:Enable();
		self.GameModeSettingsFrame:Hide();
		self.MatchmakingQueueFrame:SetWaiting(false);
		self.MatchmakingQueueFrame:Show();
		self.MatchmakingQueueFrame:SetSquadSize(C_WoWLabsMatchmaking.GetPartyPlaylistEntry());
    else
		if C_WoWLabsMatchmaking.IsPlayerReady() and C_WoWLabsMatchmaking.IsPartyLeader() then
			self.GameModeSettingsFrame:Hide();
			self.MatchmakingQueueFrame:Show();
			self.MatchmakingQueueFrame:SetWaiting(true);
			self.MatchmakingQueueFrame.LeaveQueueButton:Enable();
		else
			self.GameModeSettingsFrame:Show();
			self.MatchmakingQueueFrame:Hide();
			self.MatchmakingQueueFrame.LeaveQueueButton:Disable();
		end
    end

	self.GameModeSettingsFrame:UpdateButtons();
end

function PlunderstormLobbyMixin:SetBackgroundModel(model)
	model:SetModel(BACKGROUND_MODEL_ID, true);
	model:SetCamera(0);
	model:SetSequence(0);
end

function PlunderstormLobbyMixin:OnKeyDown(key)
    if key == "ESCAPE" then
        if GlueParent_IsSecondaryScreenOpen("options") then
            GlueParent_CloseSecondaryScreen();
        elseif C_Login.IsLauncherLogin() then
            GlueMenuFrameUtil.ToggleMenu();
		elseif GlobalGlueContextMenu_IsShown() then
			GlobalGlueContextMenu_Release();
        elseif GlueMenuFrame:IsShown() then
            GlueMenuFrameUtil.HideMenu()
        else
            self:OnExit();
        end
	elseif key == "ENTER" then
		ChatFrame_OpenChat();
    end
end

function PlunderstormLobbyMixin:OnExit()
	ExitPlunderstormLobby();
end

PlunderstormBackgroundMixin = { };
function PlunderstormBackgroundMixin:OnLoad()
	SetWorldFrameStrata(self);
end

PlunderstormCustomizeCharacterButtonMixin = { };
function PlunderstormCustomizeCharacterButtonMixin:CustomizeCharacter(characterType)
    if (CharacterSelect_IsAccountLocked()) then
        return;
    end

    C_CharacterCreation.SetCharacterCreateType(characterType);
    CharacterSelect_SelectCharacter(CharacterSelect.createIndex);
end

function PlunderstormCustomizeCharacterButtonMixin:OnClick()
	CharacterSelectUtil.CreateNewCharacter(Enum.CharacterCreateType.Normal);
end


PlunderstormLobbyBackButtonButtonMixin = { };
function PlunderstormLobbyBackButtonButtonMixin:OnClick()
	ExitPlunderstormLobby();
end


PlunderstormLobbyMenuButtonMixin = { };
function PlunderstormLobbyMenuButtonMixin:OnClick()
	GlueMenuFrameUtil.ToggleMenu();
end


PlunderstormLobbyFriendButtonMixin = { };

function PlunderstormLobbyFriendButtonMixin:OnLoad()
	self:DisableUntilNextUpdate();
end

function PlunderstormLobbyFriendButtonMixin:OnClick()
	FriendsFrame:SetShown(not FriendsFrame:IsShown())
	self.Flash.Anim:SetPlaying(false);
end

function PlunderstormLobbyFriendButtonMixin:OnMouseDown()
	self.NormalTexture:SetPoint("CENTER", 2, -2);
	self.HighlightTexture:SetPoint("CENTER", 2, -2);
	self.FriendsOnline:SetPoint("BOTTOM", 2, 5);
end

function PlunderstormLobbyFriendButtonMixin:OnMouseUp()
	self.NormalTexture:SetPoint("CENTER",0, 0);
	self.HighlightTexture:SetPoint("CENTER", 0, 0);
	self.FriendsOnline:SetPoint("BOTTOM", 0, 7);
end

function PlunderstormLobbyFriendButtonMixin:SetFriendsOnline(numOnlineFriends)
	self:Enable();
	self.FriendsOnline:SetText(numOnlineFriends);
end

function PlunderstormLobbyFriendButtonMixin:DisableUntilNextUpdate()
	self:Disable();
	self.FriendsOnline:SetText("");
end

WoWLabsSubscribeButtonMixin = {};
function WoWLabsSubscribeButtonMixin:OnClick()
	PlaySound(SOUNDKIT.GS_LOGIN_NEW_ACCOUNT);
	LoadURLIndex(22);
end