-- Inbound files need to load under the global environment
SwapToGlobalEnvironment();

--All of these functions should be safe to call by tainted code. They should only communicate with secure code via SetAttribute and GetAttribute.
function StoreFrame_SetShown(shown, contextKey)
	local wasShown = StoreFrame_IsShown();
	local contextKeyString = contextKey and tostring(contextKey) or nil;
	if shown then
		StoreFrame:SetAttribute("contextkey", contextKeyString);
	end
	-- Notify the store that shown was toggled
	if wasShown ~= shown then
		C_StorePublic.EventStoreUISetShown(shown, contextKeyString);
	end
	StoreFrame:SetAttribute("action", shown and "Show" or "Hide");
end

function StoreFrame_IsShown()
	return StoreFrame:GetAttribute("isshown");
end

function StoreFrame_EscapePressed()
	StoreFrame:SetAttribute("action", "EscapePressed");
	return StoreFrame:GetAttribute("escaperesult");
end

function StoreFrame_PreviewFrameIsShown(isShown)
	StoreFrame:SetAttribute("previewframeshown", isShown);
end

function StoreFrame_CheckForFree(event)
	StoreFrame:SetAttribute("checkforfree", event);
end

function StoreFrame_SetTokenCategory()
	StoreFrame:SetAttribute("settokencategory");
end

function StoreFrame_OpenGamesCategory()
	StoreFrame:SetAttribute("opengamescategory");
end

function StoreFrame_SetGamesCategory()
	StoreFrame:SetAttribute("setgamescategory");
end

function StoreFrame_SetServicesCategory()
	StoreFrame:SetAttribute("setservicescategory");
end

function StoreFrame_SelectBoost(boostType, reason, guid)
	local data = {};
	data.boostType = boostType;
	data.reason = reason;
	data.guid = guid;
	StoreFrame:SetAttribute("selectboost", data);
end

function StoreFrame_SelectSubscriptionProduct()
	StoreFrame:SetAttribute("selectsubscription", true);
end

function StoreFrame_SelectGameTimeProduct()
	StoreFrame:SetAttribute("selectgametime", true);
end

if (InGlue()) then
	function StoreFrame_GetVASErrorMessage(guid, errorList)
		local data = {};
		data.guid = guid;
		data.errors = errorList;
		data.realmName = GetServerName();
		StoreFrame:SetAttribute("getvaserrormessage", data);
		return StoreFrame:GetAttribute("vaserrormessageresult");
	end

	function StoreFrame_IsVASTransferProduct(productID)
		StoreFrame:SetAttribute("isvastransferproduct", productID);
		return StoreFrame:GetAttribute("isvastransferproductresult");
	end
end