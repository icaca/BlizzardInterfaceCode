function CheckAddVASErrorString(errorTable, errorString, requirementPassed)
	if not requirementPassed then
		table.insert(errorTable, errorString);
	end
end

function CheckAddVASErrorCode(errorTable, errorCode, requirementPassed)
	CheckAddVASErrorString(errorTable, VASErrorData_GetMessage(errorCode), requirementPassed);
end

function IsVASAssignmentValid(storeError, vasPurchaseResult, characterGUID)
	if storeError == 0 and vasPurchaseResult == 0 then
		return true;
	end

	local msgTable = {};

	if vasPurchaseResult ~= 0 then
		local character = C_StoreSecure.GetCharacterInfoByGUID(characterGUID);
		local msg = VASErrorData_GetMessage(vasPurchaseResult, character);
		table.insert(msgTable, msg);
	end

	if storeError ~= 0 then
		local _, msg = StoreErrorData_GetMessage(storeError);
		table.insert(msgTable, msg);
	end

	return false, table.concat(msgTable, "\n");
end

VASReviewChoicesBlockBase = {
	AutoAdvance = false,
	Back = true,
	Next = false,
	Finish = true,
	HiddenStep = true,
	SkipOnRewind = true,
};

function VASReviewChoicesBlockBase:Initialize(results, wasFromRewind)

end

function VASReviewChoicesBlockBase:GetResult()
	return {};
end

function VASReviewChoicesBlockBase:IsFinished()
	return true;
end

VASAssignConfirmationBlockBase = { 
	AutoAdvance = true,
	Back = false,
	Next = false,
	Finish = false,
	HiddenStep = true,
	SkipOnRewind = true,
};

function VASAssignConfirmationBlockBase:Initialize(results, wasFromRewind)
	self.results = results;
	self:ClearWarningState();
	self.isInitialized = true;
end

-- Override
function VASAssignConfirmationBlockBase:RequestForResults(results, isValidationOnly)
end

function VASAssignConfirmationBlockBase:IsFinished()
	if not self.isInitialized then
		return false;
	end

	local warningState = self:CheckFinishConfirmation();
	if warningState == "accepted" then
		local isValidationOnly = false;
		self:RequestForResults(self.results, isValidationOnly);
		self:ClearWarningState();
		self.isInitialized = false;

		return true;
	elseif warningState == "declined" then
		CharSelectServicesFlowFrame.CloseButton:Show();
		CharacterServicesMaster.flow:RequestRewind();
		self.warningState = "rewind";
	elseif warningState == "unseen" then
		CharSelectServicesFlowFrame.CloseButton:Hide();
	end

	return false;
end

function VASAssignConfirmationBlockBase:GetResult()
	return {};
end

function VASAssignConfirmationBlockBase:SetWarningAccepted(accepted)
	if accepted == true then
		self.warningState = "accepted";
	elseif accepted == false then
		self.warningState = "declined";
	else
		self.warningState = nil;
	end

	if accepted ~= nil then
		CharacterServicesMaster_Update();
	end
end

function VASAssignConfirmationBlockBase:ClearWarningState()
	self:SetWarningAccepted(nil);
end

function VASAssignConfirmationBlockBase:GetWarningState()
	return self.warningState or "unseen";
end

function VASAssignConfirmationBlockBase:CheckFinishConfirmation()
	local warningState = self:GetWarningState();
	if warningState == "unseen" then
		CharacterServicesFlow_ShowFinishConfirmation(self, self.dialogText, self.dialogAcceptLabel, self.dialogCancelLabel);
	end

	return warningState;
end

VASCharacterSelectBlockBase = {
	Back = false,
	Next = false,
	Finish = false,
	AutoAdvance = true,
};

function VASCharacterSelectBlockBase:Initialize(results, wasFromRewind)
	self.results = nil;
	self:SetResultsShown(false);

	local fromInitialize = not wasFromRewind;
	self:CheckEnable(fromInitialize);

	CharSelectServicesFlowFrame:ClearErrorMessage();
end

function VASCharacterSelectBlockBase:CheckEnable(fromInitialize)
	-- This is called by the event handler for getting the valid characters for a VAS product.
	local currentRealmAddress = select(5, GetServerName());
	local isGuildVAS = false;
	local characters = C_StoreSecure.GetCharactersForRealm(currentRealmAddress, isGuildVAS);

	-- This is only valid if something doesn't end up changing which characters can be selected during this process (this is potentially subject to issues from rewinding the flow)
	if #characters > 0 then
		self:ShowCharacterSelector(fromInitialize);
	end
end

-- Override
function VASCharacterSelectBlockBase:GetServiceInfoByCharacterID(characterID)
	--[[
	Should return a table with:
		isEligible 			bool : enable the character button (this will show the arrow indicator next to the character)
		playerguid			guid
		requiresLogin		bool, optional : display dialog error that character must be logged in
		hasBonus			bool, optional : enable the bonus icon, the bonus icon communicates some custom state
		checkAutoSelect		bool, optional : save block result if playerguid matches CharacterUpgradeFlow:GetAutoSelectGuid
		checkErrors			bool, optional : set up handlers for the tooltip to handle errors
		errors				table, optional: errors for the tooltip
		checkTrialBoost		bool, optional : evaluate isTrialBoost
		isTrialBoost		bool, optional : sets CharacterUpgradeFlow:SetTrialBoostGuid with the playerguid
	--]]
end

function VASCharacterSelectBlockBase:ShowCharacterSelector(fromInitialize)
	CharacterServicesCharacterSelector:Show();
	local canShowArrow = not fromInitialize;
	CharacterServicesCharacterSelector:UpdateDisplay(self, canShowArrow);
end

function VASCharacterSelectBlockBase:OnHide()
	CharacterServicesCharacterSelector:ResetState(self:GetSelectedCharacterIndex());
end

-- Override
function VASCharacterSelectBlockBase:SetResultsShown(shown)

end

function VASCharacterSelectBlockBase:OnAdvance()
	CharacterSelectListUtil.SetScrollListInteractiveState(false);
	CharacterServicesCharacterSelector:Hide();
	self:SetResultsShown(true);

	local selectedCharacterGUID = self:GetSelectedCharacterGUID();
	local characterID;
	local selectedFrame = CharacterSelectCharacterFrame.ScrollBox:FindFrameByPredicate(function(frame, elementData)
		characterID = CharacterSelectListUtil.GetCharacterPositionData(selectedCharacterGUID, elementData);
		return characterID ~= nil;
	end);

	if selectedFrame then
		CharacterSelectListUtil.ForEachCharacterDo(function(frame)
			frame.InnerContent:SetEnabledState(frame.characterID == characterID);
		end);
	end
end

function VASCharacterSelectBlockBase:IsFinished(wasFromRewind)
	return self:GetResult().selectedCharacterGUID ~= nil;
end

function VASCharacterSelectBlockBase:SaveResultInfo(characterButton, guid)
	local index = CharacterSelectListUtil.GetIndexFromCharID(characterButton.characterID);
	self.results = { selectedCharacterGUID = guid, characterID = characterButton.characterID, characterIndex = index };
end

function VASCharacterSelectBlockBase:GetResult()
	return self.results or {};
end

function VASCharacterSelectBlockBase:GetSelectedCharacterIndex()
	return self:GetResult().characterIndex or CharacterSelect.selectedIndex;
end

function VASCharacterSelectBlockBase:GetSelectedCharacterGUID()
	return self:GetResult().selectedCharacterGUID;
end

function VASCharacterSelectBlockBase:FormatResult()
	local result = self:GetResult();
	if not result.selectedCharacterGUID then
		return "";
	end

	local basicInfo = GetBasicCharacterInfo(result.selectedCharacterGUID);
	if basicInfo.classFilename then
		local coloredName = NORMAL_FONT_COLOR:WrapTextInColorCode(basicInfo.name);

		local color = CreateColor(GetClassColor(basicInfo.classFilename));
		local coloredClassName = color:WrapTextInColorCode(basicInfo.className);

		return SELECT_CHARACTER_RESULTS_FORMAT:format(coloredName, basicInfo.experienceLevel, coloredClassName);
	else
		return "";
	end
end

VASChoiceVerificationBlockBase =
{
	Back = false,
	Next = false,
	Finish = false,
	HiddenStep = true,
	SkipOnRewind = true,
};

function VASChoiceVerificationBlockBase:Initialize(results, wasFromRewind)
	self.results = results; -- Store the results so we can use them when we get a response to the validation request.
	self.isAssignmentValid = false;

	if not wasFromRewind then
		EventRegistry:RegisterFrameEvent("ASSIGN_VAS_RESPONSE");
		EventRegistry:RegisterCallback("ASSIGN_VAS_RESPONSE", self.OnAssignVASResponse, self);

		local isValidationOnly = true;
		local hadError = self:RequestAssignVASForResults(results, isValidationOnly);
		if hadError then
			local msg = select(2, StoreErrorData_GetMessage(Enum.StoreError.Other));
			CharSelectServicesFlowFrame:SetErrorMessage(msg);
		end
	end
end

function VASChoiceVerificationBlockBase:OnAssignVASResponse(token, storeError, vasPurchaseResult)
	self:UnregisterHandlers();

	local errorMsg;
	self.isAssignmentValid, errorMsg = IsVASAssignmentValid(storeError, vasPurchaseResult, self.results.selectedCharacterGUID);

	if self.isAssignmentValid then
		CharacterServicesMaster_Advance();
	else
		CharSelectServicesFlowFrame:SetErrorMessage(errorMsg);
		CharacterServicesMaster_Update();
	end
end

function VASChoiceVerificationBlockBase:IsFinished()
	return self.isAssignmentValid;
end

function VASChoiceVerificationBlockBase:GetResult()
	-- Needs to return all results thus far? Or can this just return its own little block of sucess/failure?
	return { isAssignmentValid = self.isAssignmentValid };
end

function VASChoiceVerificationBlockBase:UnregisterHandlers()
	EventRegistry:UnregisterFrameEvent("ASSIGN_VAS_RESPONSE");
	EventRegistry:UnregisterCallback("ASSIGN_VAS_RESPONSE", self);
end

function VASChoiceVerificationBlockBase:OnRewind()
	self.isAssignmentValid = false;
	CharSelectServicesFlowFrame:ClearErrorMessage();
	self:UnregisterHandlers();
end

function VASChoiceVerificationBlockBase:OnHide()
	self:UnregisterHandlers();
end

function VASChoiceVerificationBlockBase:OnAdvance()
	self:UnregisterHandlers();
end

-- Override
function VASChoiceVerificationBlockBase:RequestAssignVASForResults(results, isValidationOnly)
end