---------------------------------------------------------------------------------
--- Garrison Follower Options				                                  ---
---------------------------------------------------------------------------------

-- These are follower options that depend on this AddOn being loaded, and so they can't be set in GarrisonBaseUtils.
GarrisonFollowerOptions[LE_FOLLOWER_TYPE_GARRISON_7_0].missionFollowerSortFunc =  GarrisonFollowerList_PrioritizeSpecializationAbilityMissionSort;
GarrisonFollowerOptions[LE_FOLLOWER_TYPE_GARRISON_7_0].missionFollowerInitSortFunc = GarrisonFollowerList_InitializePrioritizeSpecializationAbilityMissionSort;

---------------------------------------------------------------------------------
-- Order Hall Mission Frame
---------------------------------------------------------------------------------

OrderHallMission = { }

local function SetupMaterialFrame(materialFrame, currency, currencyTexture)
	materialFrame.currencyType = currency;
	materialFrame.Icon:SetTexture(currencyTexture);
	materialFrame.Icon:SetSize(18, 18);
	materialFrame.Icon:SetPoint("RIGHT", materialFrame, "RIGHT", -14, 0);
end

function OrderHallMission:OnLoadMainFrame()
	self.followerTypeID = LE_FOLLOWER_TYPE_GARRISON_7_0;

	local primaryCurrency, _ = C_Garrison.GetCurrencyTypes(LE_GARRISON_TYPE_7_0);
	local _, _, currencyTexture = GetCurrencyInfo(primaryCurrency);

	self.MissionTab.MissionPage.CostFrame.CostIcon:SetTexture(currencyTexture);
	self.MissionTab.MissionPage.CostFrame.CostIcon:SetSize(18, 18);
	self.MissionTab.MissionPage.CostFrame.Cost:SetPoint("RIGHT", self.MissionTab.MissionPage.CostFrame.CostIcon, "LEFT", -8, -1);

	SetupMaterialFrame(self.FollowerList.MaterialFrame, primaryCurrency, currencyTexture);
	SetupMaterialFrame(self.MissionTab.MissionList.MaterialFrame, primaryCurrency, currencyTexture);

	-- All of the summary text in the Complete Dialog is anchored to the ViewButton, so we
	-- just need to center ViewButton to move all of the related UI.
	self:GetCompleteDialog().BorderFrame.ViewButton:SetPoint("BOTTOM", 0, 88);

	GarrisonFollowerMission.OnLoadMainFrame(self);
	
	PanelTemplates_SetNumTabs(self, 3);

	self:SelectTab(self:DefaultTab());
end

function OrderHallMission:OnEventMainFrame(event, ...)
	if (event == "ADVENTURE_MAP_CLOSE") then
		self.CloseButton:Click();
	else
		GarrisonFollowerMission.OnEventMainFrame(self, event, ...);
	end
end

function OrderHallMission:DefaultTab()
	local playerLevel = UnitLevel("player");
	if (playerLevel < 110) then
		return 3;	-- Adventure Map
	else
		return 1;	-- Missions
	end
end

function OrderHallMission:SetupTabs()
	local tabList = { };
	local validTabs = { };
	local defaultTab;
	-- If we don't have any followers, hide followers and missions tabs
	if (C_Garrison.GetNumFollowers(self.followerTypeID) > 0) then
		table.insert(tabList, 1);
		table.insert(tabList, 2);
		validTabs[1] = true;
		validTabs[2] = true;
		defaultTab = 1;
	end

	-- If we have completed all sandbox choice quests, hide the adventure map
	if ((#tabList == 0) or C_Garrison.ShouldShowMapTab(GarrisonFollowerOptions[self.followerTypeID].garrisonType)) then
		table.insert(tabList, 3);
		validTabs[3] = true;
		defaultTab = 3;
	end

	self.Tab1:Hide();
	self.Tab2:Hide();
	self.Tab3:Hide();

	-- don't show any tabs if there's only 1
	if (#tabList > 1) then
		local tab = self["Tab"..tabList[1]];
		local prevTab = tab;
		tab:ClearAllPoints();
		tab:SetPoint("BOTTOMLEFT", self, 11, -42);
		tab:Show();

		for i = 2, #tabList do
			tab = self["Tab"..tabList[i]];
			tab:ClearAllPoints();
			tab:SetPoint("LEFT", prevTab, "RIGHT", -5, 0);
			tab:Show();
			prevTab = tab;
		end
	end

	-- If the selected tab is not a valid one, switch to the default
	local selectedTab = PanelTemplates_GetSelectedTab(self);
	if (not validTabs[selectedTab]) then
		self:SelectTab(defaultTab);
	end
end

function OrderHallMission:OnShowMainFrame()
	GarrisonFollowerMission.OnShowMainFrame(self);
	AdventureMapMixin.OnShow(self.MapTab);

	self.abilityCountersForMechanicTypes = C_Garrison.GetFollowerAbilityCountersForMechanicTypes(self.followerTypeID);

	self:RegisterEvent("ADVENTURE_MAP_CLOSE");
	self:SetupTabs();
end

function OrderHallMission:OnHideMainFrame()
	GarrisonFollowerMission.OnHideMainFrame(self);
	AdventureMapMixin.OnHide(self.MapTab);

	self.abilityCountersForMechanicTypes = nil;

	self:UnregisterEvent("ADVENTURE_MAP_CLOSE");
end

function OrderHallMission:EscapePressed()
	if self:GetMissionPage() and self:GetMissionPage():IsVisible() then
		self:GetMissionPage().CloseButton:Click();
		return true;
	end

	return false;
end

function OrderHallMission:SelectTab(id)
	if (self:GetMissionPage():IsShown()) then
		self:GetMissionPage().CloseButton:Click();
	end
	GarrisonFollowerMission.SelectTab(self, id);
	if (id == 1) then
		self.TitleText:SetText(ORDER_HALL_MISSIONS);
		self.FollowerList:Hide();
		self.MapTab:Hide();
	elseif (id == 2) then
		self.TitleText:SetText(ORDER_HALL_FOLLOWERS);
		self.MapTab:Hide();
	else
		self.TitleText:SetText(ADVENTURE_MAP_TITLE);
		self.FollowerList:Hide();
		self.MapTab:Show();
	end
end


function OrderHallMission:GetMissionPage()
	if (self.MissionTab.isZoneSupport) then
		return self.MissionTab.ZoneSupportMissionPage;
	else
		return self.MissionTab.MissionPage;
	end
end


function OrderHallMission:OnClickMission(missionInfo)
	self.MissionTab.isZoneSupport = missionInfo.isZoneSupport;
	return GarrisonFollowerMission.OnClickMission(self, missionInfo);
end

function OrderHallMission:ShowMissionStage(missionInfo)
	if (not self.MissionTab.isZoneSupport) then
		GarrisonFollowerMission.ShowMissionStage(self, missionInfo);
	end
end

function OrderHallMission:ShowMission(missionInfo)
	if (missionInfo.isZoneSupport) then
		self:GetMissionPage().missionInfo = missionInfo;
		self:UpdateMissionData(self:GetMissionPage());
	else
		GarrisonFollowerMission.ShowMission(self, missionInfo);
	end
end

function OrderHallMission:UpdateCostFrame(missionPage, amount)
	if (not missionPage.missionInfo.isZoneSupport) then
		GarrisonMission.UpdateCostFrame(self, missionPage, amount);
	end
end

function OrderHallMission:UpdateZoneSupportMissionData(missionPage)
	local texture;
	local spellID;
	local timeText
	if (missionPage.Followers[1] and missionPage.Followers[1].info) then
		spellID = missionPage.Followers[1].info.zoneSupportSpellID;
		local _, _, spellTexture = GetSpellInfo(spellID);
		texture = spellTexture;
	end

	local totalTimeString = C_Garrison.GetPartyMissionInfo(missionPage.missionInfo.missionID);
	missionPage.MissionTime:SetFormattedText(GARRISON_MISSION_TIME_TOTAL, totalTimeString);

	missionPage.ZoneSupport.iconTexture:SetTexture(texture);
	missionPage.ZoneSupport:SetShown(texture ~= nil);
	missionPage.ZoneSupport.spellID = spellID;

	missionPage:UpdatePortraitPulse();
	missionPage:UpdateEmptyString();

	self:UpdateStartButton(missionPage);
end

function OrderHallMission:UpdateMissionData(missionPage)
	if (missionPage.missionInfo.isZoneSupport) then
		self:UpdateZoneSupportMissionData(missionPage);
	else
		GarrisonFollowerMission.UpdateMissionData(self, missionPage);
	end
end

function OrderHallMission:OnSetEnemy(enemyFrame, enemyInfo)

	-- Display the enemy's mechanic ability icon

	local _, mechanic = next(enemyInfo.mechanics);


	if (mechanic and mechanic.ability and mechanic.ability.icon) then
		enemyFrame.mechanicEffectIcon = mechanic.ability.icon;
	else
		enemyFrame.mechanicEffectIcon = nil;
	end

	enemyFrame.MechanicEffect.Icon:SetTexture(enemyFrame.mechanicEffectIcon);
	enemyFrame.name = enemyInfo.name;
		
	
	if (mechanic and mechanic.ability) then
		enemyFrame.mechanicName = mechanic.name;
		enemyFrame.mechanicAbilityName = mechanic.ability.name;
		enemyFrame.mechanicEffectDescription = mechanic.ability.description;
	else
		enemyFrame.mechanicName = nil;
		enemyFrame.mechanicAbilityName = nil;
		enemyFrame.mechanicEffectDescription = nil;
	end
end

function OrderHallMission:OnSetEnemyMechanic(enemyFrame, mechanicFrame, mechanicID)
	local counterAbility = self.abilityCountersForMechanicTypes[mechanicID];
	mechanicFrame.counterAbility = counterAbility;
	enemyFrame.counterAbility = counterAbility;
	if (counterAbility and counterAbility.icon) then
		mechanicFrame.Icon:SetTexture(counterAbility.icon);
	end
end



function OrderHallMission:SetEnemies(frame, enemies, numFollowers, mechanicYOffset)
	GarrisonFollowerMission.SetEnemies(self, frame, enemies, numFollowers, mechanicYOffset or -32);
end


function OrderHallMission:SetupCompleteDialog()
	local completeDialog = self:GetCompleteDialog();
	if (completeDialog) then

		completeDialog.BorderFrame.Model.Title:SetText(ORDERHALL_MISSION_REPORT);

		local _, className = UnitClass("player");

		completeDialog.BorderFrame.Stage.LocBack:SetAtlas("legionmission-complete-background-"..className);
		completeDialog.BorderFrame.Stage.LocBack:SetTexCoord(0, 1, 0, 1);
		completeDialog.BorderFrame.Stage.LocMid:Hide();
		completeDialog.BorderFrame.Stage.LocFore:Hide();
	end
end

---------------------------------------------------------------------------------
-- Order Hall Mission Page
---------------------------------------------------------------------------------
OrderHallFollowerMissionPageMixin = { }

function OrderHallFollowerMissionPageMixin:SetCounters(followers, enemies, missionID)
	GarrisonFollowerMissionPageMixin.SetCounters(self, followers, enemies, missionID);

	-- Draw an X over mechanic effect, if the mechanic has been countered.
	for i = 1, #enemies do
		local enemyFrame = enemies[i];
		local mechanicFrame = enemyFrame.Mechanics[1];
		if ( mechanicFrame ) then
			if ( mechanicFrame.hasCounter ) then
				if ( not enemyFrame.MechanicEffect.CrossLeft:IsShown() ) then
					enemyFrame.MechanicEffect.CrossLeft:SetAlpha(1);
					enemyFrame.MechanicEffect.CrossRight:SetAlpha(1);
					enemyFrame.MechanicEffect.CrossLeft:Show();
					enemyFrame.MechanicEffect.CrossRight:Show();
					enemyFrame.MechanicEffect.Countered:Play();
				end
			else
				enemyFrame.MechanicEffect.CrossLeft:Hide();
				enemyFrame.MechanicEffect.CrossRight:Hide();
			end
		end
	end
end


---------------------------------------------------------------------------------
-- Order Hall Mission Page Enemy Frame
---------------------------------------------------------------------------------
OrderHallMissionPageEnemyMixin = { }

function OrderHallMissionPageEnemyMixin:OnEnter()
	if (self.mechanicName and self.mechanicAbilityName) then
		GameTooltip:SetOwner(self, "ANCHOR_NONE");
		GameTooltip:SetPoint("TOPLEFT", self, "BOTTOMRIGHT", 0, 0);
		GameTooltip:AddLine(self.name, 1, 1, 1);
		GameTooltip:AddLine(self.mechanicName, 0.698, 0.941, 1);
		GameTooltip:AddLine(" ");
		local str;
		if (self.mechanicEffectIcon) then
			str = "|T"..self.mechanicEffectIcon..":0:0:0:0|t "
		else
			str = "";
		end
		str = str..self.mechanicAbilityName;
		GameTooltip:AddLine(str, 1, 1, 1);
		GameTooltip:AddLine(self.mechanicEffectDescription, nil, nil, nil, true);
		GameTooltip:Show();
	end
end

function OrderHallMissionPageEnemyMixin:OnLeave()
	GameTooltip_Hide();
end




---------------------------------------------------------------------------------
-- Order Hall Adventure Map
---------------------------------------------------------------------------------
OrderHallMissionAdventureMapMixin = { }

function AdventureMapMixin:SetupTitle()
end

function OrderHallMissionAdventureMapMixin:EvaluateLockReasons()
	if next(self.lockReasons) then
		self:GetParent().GarrCorners:EnableMouse(true);
	else
		self:GetParent().GarrCorners:EnableMouse(false);
	end
end

-- Don't call C_AdventureMap.Close here because we may be simply switching tabs. We call that method in OrderHallMission:OnHide() instead.
function OrderHallMissionAdventureMapMixin:OnShow()
end

function OrderHallMissionAdventureMapMixin:OnHide()
end

function OrderHallMissionAdventureMapMixin:OnLoad()
	AdventureMapMixin.OnLoad(self);
	self.ScrollContainer:SetScalingMode("SCALING_MODE_LINEAR");
end

function OrderHallMissionAdventureMapMixin:UpdateMissions()

end

function OrderHallMissionAdventureMapMixin:Update()

end

---------------------------------------------------------------------------------
-- Order Hall Follower Page
---------------------------------------------------------------------------------

OrderHallFollowerTabMixin = { }

function OrderHallFollowerTabMixin:IsSpecializationAbility(followerInfo, ability)
	return ability.isSpecialization;
end

function OrderHallFollowerTabMixin:IsEquipmentAbility(followerInfo, ability)
	return ability.isTrait;
end

function OrderHallFollowerTabMixin:UpdateValidSpellHighlightOnEquipmentFrame(equipmentFrame, followerID, followerInfo)
	local ability = equipmentFrame.ability;
	if ( followerInfo and followerInfo.isCollected 
		and followerInfo.status ~= GARRISON_FOLLOWER_WORKING and followerInfo.status ~= GARRISON_FOLLOWER_ON_MISSION 
		and ability and SpellCanTargetGarrisonFollowerAbility(followerID, ability.id) ) then
		equipmentFrame.ValidSpellHighlight:Show();
	else
		equipmentFrame.ValidSpellHighlight:Hide();
	end
end

function OrderHallFollowerTabMixin:UpdateValidSpellHighlight(followerID, followerInfo, hideCounters)
	GarrisonFollowerTabMixin.UpdateValidSpellHighlight(self, followerID, followerInfo, hideCounters);
	for i=1, #self.AbilitiesFrame.Equipment do
		self:UpdateValidSpellHighlightOnEquipmentFrame(self.AbilitiesFrame.Equipment[i], followerID, followerInfo, true);
	end

end


function OrderHallFollowerTabMixin:ShowFollower(followerID, followerList)

	local lastUpdate = self.lastUpdate;
	local followerInfo = C_Garrison.GetFollowerInfo(followerID);

	if (followerInfo) then
		self.followerID = followerID;
		self.NoFollowersLabel:Hide();
		self.PortraitFrame:Show();
		self.Model:SetAlpha(0);
		GarrisonMission_SetFollowerModel(self.Model, followerInfo.followerID, followerInfo.displayID);
		if (followerInfo.displayHeight) then
			self.Model:SetHeightFactor(followerInfo.displayHeight);
		end
		if (followerInfo.displayScale) then
			self.Model:InitializeCamera(followerInfo.displayScale);
		end		
	else
		self.followerID = nil;
		self.NoFollowersLabel:Show();
		followerInfo = { };
		followerInfo.quality = 1;
		followerInfo.abilities = { };
		self.PortraitFrame:Hide();
		self.Model:ClearModel();
	end

	GarrisonFollowerPageModelUpgrade_Update(self.Model.UpgradeFrame);
	local missionFrame = self:GetParent();

	missionFrame:SetFollowerPortrait(self.PortraitFrame, followerInfo);
	self.Name:SetText(followerInfo.name);
	local color = ITEM_QUALITY_COLORS[followerInfo.quality];	
	self.Name:SetVertexColor(color.r, color.g, color.b);
	if (followerInfo.isTroop) then
		self.DurabilityFrame:Show();
		self.ClassSpec:Hide();
		self.DurabilityFrame:SetDurability(followerInfo.durability, followerInfo.maxDurability);
	else
		self.ClassSpec:Show();
		self.DurabilityFrame:Hide();
		self.ClassSpec:SetText(followerInfo.className);
	end
	self.Class:SetAtlas(followerInfo.classAtlas);

	self.XPLabel:Hide();
	self.XPBar:Hide();
	self.XPText:Hide();
	self.XPText:SetText("");
	self.ItemWeapon:Hide();
	self.ItemArmor:Hide();
	self.ItemAverageLevel.Level:Hide();
	self.Source:Hide();


	GarrisonTruncationFrame_Check(self.Name);

	if ( ENABLE_COLORBLIND_MODE == "1" ) then
		self.QualityFrame:Show();
		self.QualityFrame.Text:SetText(_G["ITEM_QUALITY"..followerInfo.quality.."_DESC"]);
	else
		self.QualityFrame:Hide();
	end

	if (not followerInfo.abilities) then
		followerInfo.abilities = C_Garrison.GetFollowerAbilities(followerID);
	end
	local lastAbilityAnchor, lastSpecializationAnchor;
	local numCounters = 0;
	local numAbilities = 0;
	local numEquipment = 0;

	for i=1, #followerInfo.abilities do
		local ability = followerInfo.abilities[i];

		local abilityFrame;
		if (self:IsEquipmentAbility(followerInfo, ability)) then
			numEquipment = numEquipment + 1;
			abilityFrame = self.AbilitiesFrame.Equipment[numEquipment];
		else
			numAbilities = numAbilities + 1;
			abilityFrame = self.AbilitiesFrame.Abilities[numAbilities];
		
			if ( not abilityFrame ) then
				abilityFrame = CreateFrame("Frame", nil, self.AbilitiesFrame, "GarrisonFollowerPageAbilityTemplate");
				--abilityFrame.hideCounters = true;
				self.AbilitiesFrame.Abilities[numAbilities] = abilityFrame;
			end
		end

		abilityFrame.followerTypeID = followerInfo.followerTypeID;
		abilityFrame.isSpecialization = self:IsSpecializationAbility(followerInfo, ability);

		if ( self:IsEquipmentAbility(followerInfo, ability) ) then
			abilityFrame.abilityID = ability.id;
			abilityFrame.followerTypeID = followerInfo.followerTypeID
			if (ability.icon) then
				abilityFrame.Icon:SetTexture(ability.icon);
				abilityFrame.Icon:Show();
				if (not hideCounters) then
					for id, counter in pairs(ability.counters) do
						equipment.Counter.Icon:SetTexture(counter.icon);
						equipment.Counter.tooltip = counter.name;
						equipment.Counter.mainFrame = mainFrame;
						equipment.Counter.info = counter;
						equipment.Counter:Show();
							
						break;
					end
				end
					
				if (followerInfo.isCollected and GarrisonFollowerAbilities_IsNew(lastUpdate, followerID, ability.id, GARRISON_FOLLOWER_ABILITY_TYPE_ABILITY)) then
					abilityFrame.EquipAnim:Play();
				else
					GarrisonShipEquipment_StopAnimations(abilityFrame);
				end
			else
				abilityFrame.Icon:Hide();
			end
		else
			if ( followerInfo.isCollected and GarrisonFollowerAbilities_IsNew(lastUpdate, followerInfo.followerID, ability.id, GARRISON_FOLLOWER_ABILITY_TYPE_TRAIT) ) then			
				if ( ability.temporary ) then
					abilityFrame.LargeAbilityFeedbackGlowAnim:Play();
					PlaySoundKitID(51324);
				else
					abilityFrame.IconButton.Icon:SetAlpha(0);
					abilityFrame.IconButton.OldIcon:SetAlpha(1);
					abilityFrame.AbilityOverwriteAnim:Play();		
				end
			else
				GarrisonFollowerPageAbility_StopAnimations(abilityFrame);
			end
			abilityFrame.Name:SetText(ability.name);
			abilityFrame.IconButton.Icon:SetTexture(ability.icon);
			abilityFrame.IconButton.abilityID = ability.id;
			abilityFrame.ability = ability;

		    local hasCounters = false;
		    if ( ability.counters and not ability.isTrait and not self.isLandingPage and not GarrisonFollowerOptions[followerInfo.followerTypeID].hideCountersInAbilityFrame ) then
			    for id, counter in pairs(ability.counters) do
				    numCounters = numCounters + 1;
				    local counterFrame = self.AbilitiesFrame.Counters[numCounters];
				    if ( not counterFrame ) then
					    counterFrame = CreateFrame("Frame", nil, self.AbilitiesFrame, "GarrisonMissionMechanicTemplate");
					    self.AbilitiesFrame.Counters[numCounters] = counterFrame;
				    end
				    counterFrame.mainFrame = self:GetParent();
				    counterFrame.Icon:SetTexture(counter.icon);
				    counterFrame.tooltip = counter.name;
				    counterFrame:ClearAllPoints();
				    if ( hasCounters ) then			
					    counterFrame:SetPoint("LEFT", self.AbilitiesFrame.Counters[numCounters - 1], "RIGHT", 10, 0);
				    else
					    counterFrame:SetPoint("LEFT", abilityFrame.CounterString, "RIGHT", 2, -2);
				    end
				    counterFrame:Show();
				    counterFrame.info = counter;
				    counterFrame.followerTypeID = followerInfo.followerTypeID;
				    hasCounters = true;
			    end
			end
			if ( hasCounters ) then
				abilityFrame.CounterString:Show();
			else
				abilityFrame.CounterString:Hide();
			end

			if ( self.isLandingPage ) then
				abilityFrame.Category:SetText("");
				abilityFrame.Name:SetFontObject("GameFontHighlightMed2");
				abilityFrame.Name:ClearAllPoints();
				abilityFrame.Name:SetPoint("LEFT", abilityFrame.IconButton, "RIGHT", 8, 0);
				abilityFrame.Name:SetWidth(150);
			else
				local categoryText = "";
				if ( ability.isTrait ) then
					if ( ability.temporary ) then
						categoryText = GARRISON_TEMPORARY_CATEGORY_FORMAT:format(ability.category or "");
					else
						categoryText = ability.category or "";
					end
				end
				abilityFrame.Category:SetText(categoryText);
				abilityFrame.Name:SetFontObject("GameFontNormalLarge2");
				abilityFrame.Name:ClearAllPoints();
				if (hasCounters) then
					abilityFrame.Name:SetPoint("TOPLEFT", abilityFrame.IconButton, "TOPRIGHT", 8, 0);
				else
					abilityFrame.Name:SetPoint("LEFT", abilityFrame.IconButton, "RIGHT", 8, 0);
				end
				abilityFrame.Name:SetWidth(240);
			end
		end

		-- anchor ability
		if ( abilityFrame.isSpecialization ) then
			lastSpecializationAnchor = GarrisonFollowerPage_AnchorAbility(abilityFrame, lastSpecializationAnchor, self.AbilitiesFrame.SpecializationLabel, self.isLandingPage);
		elseif ( not ability.isTrait ) then
			lastAbilityAnchor = GarrisonFollowerPage_AnchorAbility(abilityFrame, lastAbilityAnchor, self.AbilitiesFrame.AbilitiesText, self.isLandingPage);
		end
		abilityFrame:Show();
	end
	followerList:UpdateValidSpellHighlight(followerID, followerInfo);

	-- Specialization Ability
	self.AbilitiesFrame.SpecializationLabel:SetShown(lastSpecializationAnchor ~= nil);

	-- Abilities
	self.AbilitiesFrame.AbilitiesText:SetShown( lastAbilityAnchor ~= nil);
	self.AbilitiesFrame.EquipmentSlotsLabel:SetShown( numEquipment > 0 );
	for i = numAbilities + 1, #self.AbilitiesFrame.Abilities do
		self.AbilitiesFrame.Abilities[i]:Hide();
	end
	for i = numCounters + 1, #self.AbilitiesFrame.Counters do
		self.AbilitiesFrame.Counters[i]:Hide();
	end

	-- Equipment
	for i = numEquipment + 1, #self.AbilitiesFrame.Equipment do
		self.AbilitiesFrame.Equipment[i]:Hide();
	end

	-- Zone Support
	local zoneSupportSpellIDs = { C_Garrison.GetFollowerZoneSupportAbilities(followerID) };
	local hasZoneSupport = #zoneSupportSpellIDs ~= 0;

	for i = 1, #zoneSupportSpellIDs do
		local _, _, texture = GetSpellInfo(zoneSupportSpellIDs[i]);
		self.AbilitiesFrame.ZoneSupport[i]:Show();
		self.AbilitiesFrame.ZoneSupport[i].iconTexture:SetTexture(texture);
		self.AbilitiesFrame.ZoneSupport[i].spellID = zoneSupportSpellIDs[i];
		self.AbilitiesFrame.ZoneSupport[i].followerID = followerID;
	end
	self.AbilitiesFrame.ZoneSupportLabel:SetShown(hasZoneSupport);
	self.AbilitiesFrame.ZoneSupportDescriptionLabel:SetShown(hasZoneSupport);

	for i = #zoneSupportSpellIDs + 1, #self.AbilitiesFrame.ZoneSupport do
		self.AbilitiesFrame.ZoneSupport[i]:Hide();
	end

	self.lastUpdate = self:IsShown() and GetTime() or nil;
end


---------------------------------------------------------------------------------
-- Zone Support Button
---------------------------------------------------------------------------------
OrderHallFollowerZoneSupportMixin = { }

function OrderHallFollowerZoneSupportMixin:OnEnter()
	if ( self.spellID ) then
		GameTooltip:SetOwner(self);
		GameTooltip:SetSpellByID(self.spellID);
		GameTooltip:Show();
	end
end

function OrderHallFollowerZoneSupportMixin:OnLeave()
	GameTooltip:Hide();
end

OrderHallFollowerEquipmentMixin = { }
function OrderHallFollowerEquipmentMixin:OnEnter()
	if (self.abilityID) then
		ShowGarrisonFollowerAbilityTooltip(self, self.abilityID, LE_FOLLOWER_TYPE_SHIPYARD_6_2);
	end
end

function OrderHallFollowerEquipmentMixin:OnLeave()
	HideGarrisonFollowerAbilityTooltip();
end

---------------------------------------------------------------------------------
-- Zone Support Page
---------------------------------------------------------------------------------

ZoneSupportMissionPageMixin = { }
function ZoneSupportMissionPageMixin:UpdateEmptyString()
	if ( C_Garrison.GetNumFollowersOnMission(self.missionInfo.missionID) == 0 ) then
		self.ZoneSupportDescriptionLabel:SetText(self.missionInfo.description);
	else
		self.ZoneSupportDescriptionLabel:SetText(ORDER_HALL_ZONE_SUPPORT_DESCRIPTION_IN_ZONE);
	end
end

function ZoneSupportMissionPageMixin:UpdateFollowerModel(info)
end

function ZoneSupportMissionPageMixin:SetFollowerListSortFuncsForMission()
	local mainFrame = self:GetParent():GetParent();
	mainFrame.FollowerList:SetSortFuncs(GarrisonFollowerList_DefaultSort, GarrisonFollowerList_InitializeDefaultSort);
end

---------------------------------------------------------------------------------
-- Order Hall Mission list
---------------------------------------------------------------------------------

OrderHallMissionListMixin = { }

function OrderHallMissionListMixin:UpdateCombatAllyMission()
	if (self.combatAllyMission) then
		self:SetHeight(440);
	else
		self:SetHeight(565);
	end
	self.CombatAllyUI:SetMission(self.combatAllyMission);
end

OrderHallCombatAllyMixin = { }

function OrderHallCombatAllyMixin:SetMission(missionInfo)
	self.missionInfo = missionInfo;
	if (missionInfo) then
		self.Available:SetShown(not missionInfo.inProgress);
		self.InProgress:SetShown(missionInfo.inProgress);
		if (missionInfo.inProgress) then
			local followerInfo = C_Garrison.GetFollowerInfo(missionInfo.followers[1]);
			self.InProgress.PortraitFrame:SetupPortrait(followerInfo);
			self.InProgress.Name:SetText(followerInfo.name);

			local name, _, texture = GetSpellInfo(followerInfo.zoneSupportSpellID);

			self.InProgress.ZoneSupport.iconTexture:SetTexture(texture);
			self.InProgress.ZoneSupport.spellID = followerInfo.zoneSupportSpellID;
			self.InProgress.ZoneSupportName:SetText(name or "");
		end
		self:Show();
	else
		self:Hide();
	end
end

function OrderHallCombatAllyMixin:GetMissionFrame()
	return self:GetParent():GetParent():GetParent();
end

function OrderHallCombatAllyMixin:GetMissionList()
	return self:GetParent();
end

--- Utility functions

function GarrisonFollowerFilter_MustHaveZoneSupport(followerInfo) 
	return followerInfo.isCollected and followerInfo.zoneSupportSpellID ~= nil; 
end
