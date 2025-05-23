local MinPanelWidth = 715;
local MinPanelHeight = 210;
local DefaultPanelWidth = MinPanelWidth;
local DefaultPanelHeight = 400;
local MaxEvents = 1000;

local DefaultFilter =
{
	{event="CONSOLE_MESSAGE", enabled=true},
	{event="GLOBAL_MOUSE_UP", enabled=true},
	{event="GLOBAL_MOUSE_DOWN", enabled=true},
	{event="PLAYER_STARTED_LOOKING", enabled=true},
	{event="PLAYER_STOPPED_LOOKING", enabled=true},
	{event="PLAYER_STARTED_TURNING", enabled=true},
	{event="PLAYER_STOPPED_TURNING", enabled=true},
	{event="PLAYER_STARTED_MOVING", enabled=true},
	{event="PLAYER_STOPPED_MOVING", enabled=true},
	{event="OBJECT_ENTERED_AOI", enabled=true},
	{event="OBJECT_LEFT_AOI", enabled=true},
	{event="SPELL_ACTIVATION_OVERLAY_HIDE", enabled=true},
	{event="MODIFIER_STATE_CHANGED", enabled=true},
	{event="IMGUI_RENDER_ENABLED", enabled=true},
};

local function GetDisplayEvent(elementData)
	return elementData.displayEvent or elementData.event;
end

local function ApplyAlternateState(frame, alternate)
	frame:SetAlternateOverlayShown(alternate);
end

EventTraceSavedVars =
{
	LogEventsWhenHidden = false,
	ShowArguments = true,
	ShowTimestamp = true,
	LogCREvents = true,
	Filters =
	{
		User = {},
	},
	Size =
	{
		Width = DefaultPanelWidth,
		Height = DefaultPanelHeight,
	},
};

EventTraceButtonBehaviorMixin = {};

function EventTraceButtonBehaviorMixin:OnEnter()
	self.MouseoverOverlay:Show();
end

function EventTraceButtonBehaviorMixin:OnLeave()
	self.MouseoverOverlay:Hide();
end

function EventTraceButtonBehaviorMixin:SetAlternateOverlayShown(alternate)
	self.Alternate:SetShown(alternate);
end

EventTraceScrollBoxButtonMixin = {};

function EventTraceScrollBoxButtonMixin:Flash()
	self.FlashOverlay.Anim:Play();
end

EventTracePanelMixin = CreateFromMixins(ToolWindowOwnerMixin);

function EventTracePanelMixin:OnSetDebugToolVisible(addonName, showTool)
	if addonName == "Blizzard_EventTrace" then
		self:SetShown(showTool);
	end
end

function EventTracePanelMixin:OnLoad()
	ButtonFrameTemplate_HidePortrait(self)

	self.isLoggingPaused = false;
	self.loadTime = GetTime();
	self.showingArguments = true;

	self.logDataProvider = CreateDataProvider();
	self.searchDataProvider = CreateDataProvider();
	self.searchDataProvider:RegisterCallback(DataProviderMixin.Event.OnSizeChanged, self.OnSearchDataProviderChanged, self);

	self.filterDataProvider = CreateDataProvider();
	self.filterDataProvider:SetSortComparator(function(lhs, rhs)
		return lhs.event < rhs.event;
	end);

	self.idCounter = CreateCounter();
	self.frameCounter = 0;
	local timer = CreateFrame("FRAME");
	timer:SetScript("OnUpdate", function(o, elapsed)
		self.frameCounter = self.frameCounter + 1;
	end);

	self:InitializeSubtitleBar();
	self:InitializeLog();
	self:InitializeFilter();
	self:InitializeOptions();

	self:RegisterAllEvents();

	self.TitleBar:Init(self);
	self.ResizeButton:Init(self, MinPanelWidth, MinPanelHeight);
	self:SetTitle(EVENTTRACE_HEADER);

	hooksecurefunc(EventRegistry, "TriggerEvent", function(registry, event, ...)
		EventTrace:LogCallbackRegistryEvent(registry, event, ...);
	end);

	self:UpdatePlaybackButton();

	EventRegistry:RegisterFrameEvent("SET_DEBUG_TOOL_VISIBLE");
	EventRegistry:RegisterCallback("SET_DEBUG_TOOL_VISIBLE", self.OnSetDebugToolVisible, self);
end

function EventTracePanelMixin:OnShow()
	self:MoveToNewWindow(EVENTTRACE_HEADER, 1000, 600, 930, 300);

	self.Log.Events.ScrollBox:ScrollToEnd();

	if not self:IsLoggingEventsWhenHidden() then
		self:LogMessage(EVENTTRACE_LOG_START);
	end
end

function EventTracePanelMixin:OnHide()
	if not self:IsLoggingEventsWhenHidden() then
		self:LogMessage(EVENTTRACE_LOG_PAUSE_WHILE_HIDDEN);
	end
end

function EventTracePanelMixin:SaveVariables()
	EventTraceSavedVars.Filters.User = {};
	for index, elementData in self.filterDataProvider:Enumerate() do
		tinsert(EventTraceSavedVars.Filters.User, elementData);
	end

	local width, height = self:GetSize();
	EventTraceSavedVars.Size.Width = width;
	EventTraceSavedVars.Size.Height = height;

	EventTraceSavedVars.LogEventsWhenHidden = self:IsLoggingEventsWhenHidden();
	EventTraceSavedVars.ShowArguments = self:IsShowingArguments();
	EventTraceSavedVars.ShowTimestamp = self:IsShowingTimestamp();
	EventTraceSavedVars.LogCREvents = self:IsLoggingCREvents();
end

function EventTracePanelMixin:LoadVariables()
	for index, elementData in ipairs(EventTraceSavedVars.Filters.User) do
		self.filterDataProvider:Insert(elementData);
	end

	self:SetSize(EventTraceSavedVars.Size.Width, EventTraceSavedVars.Size.Height);

	self:SetLoggingEventsWhenHidden(EventTraceSavedVars.LogEventsWhenHidden);
	self:SetShowingArguments(EventTraceSavedVars.ShowArguments);
	self:SetShowingTimestamp(EventTraceSavedVars.ShowTimestamp);
	self:SetLoggingCREvents(EventTraceSavedVars.LogCREvents);
end

function EventTracePanelMixin:InitializeSubtitleBar()
	self.SubtitleBar.ViewLog.Label:SetText(EVENTTRACE_LOG_HEADER);
	self.SubtitleBar.ViewLog:SetScript("OnClick", function()
		self:ViewLog();
	end);

	self.SubtitleBar.ViewFilter.Label:SetText(EVENTTRACE_FILTER_HEADER);
	self.SubtitleBar.ViewFilter:SetScript("OnClick", function()
		self:ViewFilter();
	end);
end

function EventTracePanelMixin:UpdatePlaybackButton()
	self.Log.Bar.PlaybackButton.Label:SetText(self:IsLoggingPaused() and EVENTTRACE_BUTTON_PLAY or EVENTTRACE_BUTTON_PAUSE);
end

local function SetScrollBoxButtonAlternateState(scrollBox)
	local index = scrollBox:GetDataIndexBegin();
	scrollBox:ForEachFrame(function(button)
		button:SetAlternateOverlayShown(index % 2 == 1);
		index = index + 1;
	end);
end

function EventTracePanelMixin:DisplayEvents()
	self.Log.Bar.Label:SetText(EVENTTRACE_LOG_HEADER);
	self.Log.Events:Show();
	self.Log.Search:Hide();
end

function EventTracePanelMixin:DisplaySearch()
	self.Log.Search:Show();
	self.Log.Events:Hide();
end

function EventTracePanelMixin:OnSearchDataProviderChanged(hasSortComparator)
	local size = self.searchDataProvider:GetSize();
	local text = (EVENTTRACE_RESULTS):format(size);
	self.Log.Bar.Label:SetText(text);
end

function EventTracePanelMixin:TryAddToSearch(elementData, search)
	local s = search:upper()

	if string.len(s) > 0 and (string.find(tostring(elementData.id), s) or
		(elementData.event and string.find(elementData.event, s)) or
		(elementData.arguments and string.find((elementData.arguments):upper(), s)) or
		(elementData.message and string.find((elementData.message):upper(), s))) then
		local shallow = true;
		self.searchDataProvider:Insert(CopyTable(elementData, shallow));
		return true;
	end
	return false;
end

function EventTracePanelMixin:InitializeLog()
	self.Log.Bar.Label:SetText(EVENTTRACE_LOG_HEADER);
	self.Log.Bar.MarkButton.Label:SetText(EVENTTRACE_BUTTON_MARKER);
	self.Log.Bar.MarkButton:SetScript("OnClick", function(button, buttonName)
		self:LogMessage(EVENTTRACE_MARKER);
	end);

	self.Log.Bar.PlaybackButton:SetScript("OnClick", function(button, buttonName)
		self:TogglePause();
	end);

	self.Log.Bar.DiscardAllButton.Label:SetText(EVENTTRACE_BUTTON_DISCARD_FILTER);
	self.Log.Bar.DiscardAllButton:SetScript("OnClick", function(button, buttonName)
		self.logDataProvider:Flush();
		self.searchDataProvider:Flush();
		self:LogMessage(EVENTTRACE_LOG_DISCARD);
	end);

	self.Log.Bar.SearchBox:HookScript("OnTextChanged", function(o)
		self.searchDataProvider:Flush();

		local text = self.Log.Bar.SearchBox:GetText();
		local empty = string.len(text) == 0;
		if empty then
			self:DisplayEvents();
		else
			self:DisplaySearch();
			local words = {};
			for word in string.gmatch(text:upper(), "([^, ]+)") do
			   tinsert(words, word);
			end

			for _, elementData in self.logDataProvider:Enumerate() do
				for _, word in ipairs(words) do
					if self:TryAddToSearch(elementData, word) then
						break;
					end
				end
			end

			local pendingSearch = self.pendingSearch;
			if pendingSearch then
				self.pendingSearch = nil;

				local found = self.Log.Search.ScrollBox:ScrollToElementDataByPredicate(function(elementData)
					return elementData.id == pendingSearch.id;
				end, ScrollBoxConstants.AlignCenter);

				if found then
					local button = self.Log.Search.ScrollBox:FindFrame(found);
					if button then
						button:Flash();
					end
				end
			elseif self.Log.Search.ScrollBox:HasScrollableExtent() then
				self.Log.Search.ScrollBox:ScrollToEnd();
			end
		end
	end);

	ScrollUtil.RegisterAlternateRowBehavior(self.Log.Events.ScrollBox, ApplyAlternateState);
	ScrollUtil.RegisterAlternateRowBehavior(self.Log.Search.ScrollBox, ApplyAlternateState);

	local function AddEventToFilter(scrollBox, elementData)
		local found = self.filterDataProvider:FindElementDataByPredicate(function(filterData)
			return filterData.event == elementData.event;
		end);
		if found then
			found.enabled = true;

			local button = scrollBox:FindFrame(elementData);
			if button then
				button:UpdateEnabledState();
			end
		else
			self.filterDataProvider:Insert({event = elementData.event:upper(), displayEvent = GetDisplayEvent(elementData), enabled = true});
		end
		self:RemoveEventFromDataProvider(self.logDataProvider, elementData.event);
		self:RemoveEventFromDataProvider(self.searchDataProvider, elementData.event);
	end

	do
		local function LocateInSearch(elementData, text)
			self.pendingSearch = elementData;
			self.Log.Bar.SearchBox:SetText(text);
		end

		local view = CreateScrollBoxListLinearView();
		view:SetElementFactory(function(factory, elementData)
			if elementData.event then
				factory("EventTraceLogEventButtonTemplate", function(button, elementData)
					button:Init(elementData, self:IsShowingArguments(), self:IsShowingTimestamp());

					button.HideButton:SetScript("OnMouseDown", function(button, buttonName)
						AddEventToFilter(self.Filter.ScrollBox, elementData);
					end);

					button:SetScript("OnClick", function(button, buttonName, down)
						if buttonName == "RightButton" then
							CopyToClipboard(elementData.event);
						end
					end);

					button:SetScript("OnDoubleClick", function(button, buttonName)
						if buttonName == "LeftButton" then
							LocateInSearch(elementData, elementData.event);
						end
					end);
				end);
			elseif elementData.message then
				factory("EventTraceLogMessageButtonTemplate", function(button, elementData)
					button:Init(elementData);

					button:SetScript("OnDoubleClick", function(button, buttonName)
						LocateInSearch(elementData, elementData.message);
					end);
				end);

			end
		end);

		local pad = 2;
		local spacing = 2;
		view:SetPadding(pad, pad, pad, pad, spacing);

		ScrollUtil.InitScrollBoxListWithScrollBar(self.Log.Events.ScrollBox, self.Log.Events.ScrollBar, view);

		self.Log.Events.ScrollBox:SetDataProvider(self.logDataProvider);
	end

	do
		local function LocateInLog(elementData)
			self.Log.Bar.SearchBox:SetText("");
			self:DisplayEvents();

			local found = self.Log.Events.ScrollBox:ScrollToElementDataByPredicate(function(data)
				return data.id == elementData.id;
			end, ScrollBoxConstants.AlignCenter);

			local button = found and self.Log.Events.ScrollBox:FindFrame(found);
			if button then
				button:Flash();
			end
		end

		local view = CreateScrollBoxListLinearView();
		view:SetElementFactory(function(factory, elementData)
			if elementData.event then
				factory("EventTraceLogEventButtonTemplate", function(button, elementData)
					button:Init(elementData, self:IsShowingArguments());

					button.HideButton:SetScript("OnMouseDown", function(button, buttonName)
						AddEventToFilter(self.Log.Search.ScrollBox, elementData);
					end);

					button:SetScript("OnClick", function(button, buttonName, down)
						if buttonName == "RightButton" then
							CopyToClipboard(elementData.event);
						end
					end);

					button:SetScript("OnDoubleClick", function(button, buttonName)
						if buttonName == "LeftButton" then
							LocateInLog(elementData);
						end
					end);
				end);
			elseif elementData.message then
				factory("EventTraceLogMessageButtonTemplate", function(button, elementData)
					button:Init(elementData);

					button:SetScript("OnDoubleClick", function(button, buttonName)
						LocateInLog(elementData);
					end);
				end);
			end
		end);

		local pad = 2;
		local spacing = 2;
		view:SetPadding(pad, pad, pad, pad, spacing);

		ScrollUtil.InitScrollBoxListWithScrollBar(self.Log.Search.ScrollBox, self.Log.Search.ScrollBar, view);

		self.Log.Search.ScrollBox:SetDataProvider(self.searchDataProvider);
	end
end

function EventTracePanelMixin:InitializeFilter()
	self.Filter.Bar.Label:SetText(EVENTTRACE_FILTER_HEADER);

	local function SetEventsEnabled(enabled)
		for index, elementData in self.filterDataProvider:Enumerate() do
			elementData.enabled = enabled;
		end

		self.Filter.ScrollBox:ForEachFrame(function(button)
			button:UpdateEnabledState();
		end);
	end

	local function InitializeCheckButton(button, text, enable)
		button.Label:SetText(text);
		button:SetScript("OnClick", function(button, buttonName)
			SetEventsEnabled(enable);
		end);
	end

	InitializeCheckButton(self.Filter.Bar.CheckAllButton, EVENTTRACE_BUTTON_ENABLE_FILTERS, true);
	InitializeCheckButton(self.Filter.Bar.UncheckAllButton, EVENTTRACE_BUTTON_DISABLE_FILTERS, false);

	self.Filter.Bar.DiscardAllButton.Label:SetText(EVENTTRACE_BUTTON_DISCARD_FILTER);
	self.Filter.Bar.DiscardAllButton:SetScript("OnClick", function(button, buttonName)
		self.filterDataProvider:Flush();
	end);

	ScrollUtil.RegisterAlternateRowBehavior(self.Filter.ScrollBox, ApplyAlternateState);

	local function RemoveEventFromFilter(elementData)
		self.filterDataProvider:Remove(elementData);
	end

	local view = CreateScrollBoxListLinearView();
	view:SetElementInitializer("EventTraceFilterButtonTemplate", function(button, elementData)
		button:Init(elementData, RemoveEventFromFilter);
	end);

	local pad = 2;
	local spacing = 2;
	view:SetPadding(pad, pad, pad, pad, spacing);

	ScrollUtil.InitScrollBoxListWithScrollBar(self.Filter.ScrollBox, self.Filter.ScrollBar, view);

	self.Filter.ScrollBox:SetDataProvider(self.filterDataProvider);
end

function EventTracePanelMixin:InitializeOptions()
	self.SubtitleBar.OptionsDropdown:SetText(EVENTTRACE_OPTIONS);
	self.SubtitleBar.OptionsDropdown:SetupMenu(function(dropdown, rootDescription)
		rootDescription:SetTag("MENU_EVENT_TRACE_FILTER");

		rootDescription:CreateButton(EVENTTRACE_APPLY_DEFAULT_FILTER, function()
			self.filterDataProvider:Flush();
			for index, elementData in ipairs(DefaultFilter) do
				self.filterDataProvider:Insert(CopyTable(elementData));
			end
		end);

		rootDescription:CreateDivider();

		do
			local function IsSelected()
				return self:IsLoggingEventsWhenHidden();
			end

			local function SetSelected()
				self:SetLoggingEventsWhenHidden(not self:IsLoggingEventsWhenHidden());
			end

			rootDescription:CreateCheckbox(EVENTTRACE_LOG_WHEN_HIDDEN, IsSelected, SetSelected);
		end

		do
			local function IsSelected()
				return self:IsShowingArguments();
			end

			local function SetSelected()
				self:SetShowingArguments(not self:IsShowingArguments());
			end

			rootDescription:CreateCheckbox(EVENTTRACE_SHOW_ARGUMENTS, IsSelected, SetSelected);
		end

		do
			local function IsSelected()
				return self:IsShowingTimestamp();
			end

			local function SetSelected()
				self:SetShowingTimestamp(not self:IsShowingTimestamp());
			end

			rootDescription:CreateCheckbox(EVENTTRACE_SHOW_TIMESTAMP, IsSelected, SetSelected);
		end

		do
			local function IsSelected()
				return self:IsLoggingCREvents();
			end

			local function SetSelected()
				self:SetLoggingCREvents(not self:IsLoggingCREvents());
			end

			rootDescription:CreateCheckbox(EVENTTRACE_LOG_CR_EVENTS, IsSelected, SetSelected);
		end
	end);
end

function EventTracePanelMixin:IsLoggingEventsWhenHidden()
	return self.logEventsWhenHidden;
end

function EventTracePanelMixin:SetLoggingEventsWhenHidden(logEventsWhenHidden)
	self.logEventsWhenHidden = logEventsWhenHidden;
end

function EventTracePanelMixin:IsShowingArguments()
	return self.showingArguments;
end

function EventTracePanelMixin:SetShowingArguments(show)
	self.showingArguments = show;

	self:UpdateLogScrollBoxes(function(frame)
		frame:OnShowArgumentsChanged(frame:GetElementData(), show);
	end);
end

function EventTracePanelMixin:SetShowingTimestamp(show)
	self.showingTimestamp = show;

	self:UpdateLogScrollBoxes(function(frame)
		frame:OnShowTimestampChanged(frame:GetElementData(), show);
	end);
end

function EventTracePanelMixin:UpdateLogScrollBoxes(func)
	self.Log.Events.ScrollBox:ForEachFrame(func);
	self.Log.Search.ScrollBox:ForEachFrame(func);
end

function EventTracePanelMixin:IsShowingTimestamp()
	return self.showingTimestamp;
end

function EventTracePanelMixin:IsLoggingCREvents()
	return self.loggingCREvents;
end

function EventTracePanelMixin:SetLoggingCREvents(logging)
	self.loggingCREvents = logging;
end

function EventTracePanelMixin:ViewLog()
	self.Log:Show();
	self.Filter:Hide();
end

function EventTracePanelMixin:ViewFilter()
	self.Log.Bar.SearchBox:SetText("");
	self.Log:Hide();
	self.Filter:Show();
end

function EventTracePanelMixin:ProcessChatCommand(msg)
	if msg then
		local words = string.gmatch(msg, "([^ ]+)");
		for word in words do -- luacheck: ignore 512 (loop is executed at most once)
			local Mark = "MARK";
			if string.upper(word) == Mark then
				local index = string.find(msg, word);
				self:LogMessage(string.sub(msg, index + string.len(Mark)));
				return true;
			end

			break;
		end
	end
	return false;
end

function EventTracePanelMixin:IsLoggingPaused()
	return self.isLoggingPaused;
end

function EventTracePanelMixin:SetLoggingPaused(paused)
	self.isLoggingPaused = paused;

	self:LogMessage(paused and EVENTTRACE_LOG_PAUSE or EVENTTRACE_LOG_START);
	self:UpdatePlaybackButton();
end

function EventTracePanelMixin:CanLogEvent(event)
	return (self:IsShown() or self:IsLoggingEventsWhenHidden()) and not (self:IsLoggingPaused() or self:IsIgnoredEvent(event));
end

function EventTracePanelMixin:LogMessage(message)
	self:LogLine({message = message});
end

local function CreateEventElementData(event, ...)
	return {event = event, args = SafePack(...)};
end

function EventTracePanelMixin:LogEvent(event, ...)
	if not self:CanLogEvent(event) then
		return;
	end

	self:LogLine(CreateEventElementData(event, ...));
end

function EventTracePanelMixin:LogCallbackRegistryEvent(sender, event, ...)
	if not self:CanLogEvent(event) or not self:IsLoggingCREvents() then
		return;
	end

	local elementData = CreateEventElementData(event:upper(), ...);
	elementData.displayEvent = string.format("%s %s", event, DARKYELLOW_FONT_COLOR:WrapTextInColorCode("(CR)"));

	local senderStr = DARKYELLOW_FONT_COLOR:WrapTextInColorCode(("(CR: %s)"):format(sender.GetDebugName and sender:GetDebugName() or tostring(sender)));
	elementData.displayMessage = string.format("%s %s", event, senderStr);
	self:LogLine(elementData);
end

function EventTracePanelMixin:LogLine(elementData)
	local preInsertAtScrollEnd = self.Log.Events.ScrollBox:IsAtEnd();
	local preInsertScrollable = self.Log.Events.ScrollBox:HasScrollableExtent();

	local systemTimestamp, relativeTimestamp, eventDelta = self:GenerateTimestampData();
	elementData.id = self.idCounter();
	elementData.systemTimestamp = systemTimestamp;
	elementData.relativeTimestamp = relativeTimestamp;
	elementData.frameCounter = self.frameCounter;
	elementData.eventDelta = eventDelta;

	self.logDataProvider:Insert(elementData);
	self:TrimDataProvider(self.logDataProvider);

	self:TryAddToSearch(elementData, self.Log.Bar.SearchBox:GetText())
	self:TrimDataProvider(self.searchDataProvider);

	if not IsAltKeyDown() and (preInsertAtScrollEnd or (not preInsertScrollable and self.Log.Events.ScrollBox:HasScrollableExtent())) then
		self.Log.Events.ScrollBox:ScrollToEnd();
	end
end

function EventTracePanelMixin:OnEvent(event, ...)
	if event == "IMGUI_RENDER_ENABLED" then
		return;
	end

	if event == "ADDONS_UNLOADING" then
		self:SaveVariables();
		return;
	end

	if event == "ADDON_LOADED" then
		local addon = ...;
		if addon == "Blizzard_EventTrace" then
			self:LoadVariables();
			self:UnregisterEvent("ADDON_LOADED");
			self:Show();
		end
	end

	self:LogEvent(event, ...);
end

function EventTracePanelMixin:TogglePause()
	self:SetLoggingPaused(not self.isLoggingPaused);
end

local function CalculateEventDelta(oldTimestamp, oldFrameCounter, currentTimestamp, currentFrameCounter)
	if oldTimestamp ~= currentTimestamp then
		return ("(%.3fs, %d)"):format(currentTimestamp - oldTimestamp, currentFrameCounter - oldFrameCounter);
	end
	return nil;
end

function EventTracePanelMixin:GenerateTimestampData()
	local systemTimestamp = GetTime();
	local relativeTimestamp = systemTimestamp - self.loadTime;

	local eventDelta;
	local endElement = self.logDataProvider:Find(self.logDataProvider:GetSize());
	if endElement then
		eventDelta = CalculateEventDelta(endElement.relativeTimestamp, endElement.frameCounter, relativeTimestamp, self.frameCounter);
	end
	return systemTimestamp, relativeTimestamp, eventDelta;
end

function EventTracePanelMixin:TrimDataProvider(dataProvider)
	local dataProviderSize = dataProvider:GetSize();
	if dataProviderSize > MaxEvents then
		local extra = 100;
		local overflow = dataProviderSize - MaxEvents;
		dataProvider:RemoveIndexRange(1, overflow + extra);
	end
end

function EventTracePanelMixin:IsIgnoredEvent(event)
	local e = event:upper();
	return self.filterDataProvider:ContainsByPredicate(function(elementData)
		return elementData.enabled and elementData.event == e;
	end);
end

function EventTracePanelMixin:RemoveEventFromDataProvider(dataProvider, event)
	local index = dataProvider:GetSize();
	while index >= 1 do
		local elementData = dataProvider:Find(index);
		if elementData.event == event then
			dataProvider:RemoveIndex(index);
		end
		index = index - 1;
	end
end

local function CreateClock(timestamp)
	local units = ConvertSecondsToUnits(timestamp);
	local seconds = units.seconds + units.milliseconds;
	if units.hours > 0 then
		return string.format("%.2d:%.2d:%06.3fs", units.hours, units.minutes, seconds);
	else
		return string.format("%.2d:%06.3fs", units.minutes, seconds);
	end
end

local ArgumentColors =
{
	["string"] = GREEN_FONT_COLOR,
	["number"] = ORANGE_FONT_COLOR,
	["boolean"] = BRIGHTBLUE_FONT_COLOR,
	["table"] = LIGHTYELLOW_FONT_COLOR,
	["nil"] = GRAY_FONT_COLOR,
};

local function GetArgumentColor(arg)
	return ArgumentColors[type(arg)] or HIGHLIGHT_FONT_COLOR;
end

local function FormatArgument(arg)
	local color = GetArgumentColor(arg);
	local t = type(arg);
	if t == "string" then
		return color:WrapTextInColorCode(string.format('"%s"', arg));
	elseif t == "nil" then
		return color:WrapTextInColorCode(t);
	end
	return color:WrapTextInColorCode(tostring(arg));
end

local function FormatLogID(elementData)
	return GRAY_FONT_COLOR:WrapTextInColorCode(string.format("[%.3d]", (elementData.id % MaxEvents)));
end

local function FormatLine(id, message)
	return string.format("%s %s", id, message);
end

EventTraceLogEventButtonMixin = {};

local function AddTooltipArguments(...)
	local count = select("#", ...);
	for index = 1, count do
		local arg = select(index, ...);
		GameTooltip_AddColoredDoubleLine(EventTraceTooltip, EVENTTRACE_ARG_FMT:format(index), FormatArgument(arg), HIGHLIGHT_FONT_COLOR, GetArgumentColor(arg));
	end
end

function EventTraceLogEventButtonMixin:OnLoad()
	self.HideButton:ClearAllPoints();
	self.HideButton:SetPoint("LEFT", self, "LEFT", 3, 0);
end

function EventTraceLogEventButtonMixin:OnEnter()
	EventTraceButtonBehaviorMixin.OnEnter(self);

	EventTraceTooltip:SetOwner(self, "ANCHOR_RIGHT");
	local elementData = self:GetElementData();
	GameTooltip_AddHighlightLine(EventTraceTooltip, GetDisplayEvent(elementData), HIGHLIGHT_FONT_COLOR);
	GameTooltip_AddColoredDoubleLine(EventTraceTooltip, EVENTTRACE_TIMESTAMP, elementData.systemTimestamp, HIGHLIGHT_FONT_COLOR, HIGHLIGHT_FONT_COLOR);

	AddTooltipArguments(SafeUnpack(elementData.args));

	EventTraceTooltip:Show();
end

function EventTraceLogEventButtonMixin:OnLeave()
	EventTraceButtonBehaviorMixin.OnLeave(self)

	EventTraceTooltip:Hide();
end

local function AddLineArguments(...)
	local words = {};
	local count = select("#", ...);
	for index = 1, count do
		local arg = select(index, ...);
		table.insert(words, FormatArgument(arg));
	end

	local wordCount = #words;
	if wordCount == 0 then
		return "";
	elseif wordCount == 1 then
		return words[1];
	end
	return table.concat(words, ", ");
end

function EventTraceLogEventButtonMixin:Init(elementData, showArguments, showTimestamp)
	local id = FormatLogID(elementData);
	local message = elementData.displayMessage or elementData.event;
	elementData.lineWithoutArguments = FormatLine(id, message);

	elementData.arguments = AddLineArguments(SafeUnpack(elementData.args));
	elementData.formattedArguments = GREEN_FONT_COLOR:WrapTextInColorCode(elementData.arguments);
	self:SetLeftText(elementData, showArguments);

	local clock = CreateClock(elementData.relativeTimestamp);
	elementData.formattedTimestamp = string.format("%s %s", clock, elementData.eventDelta and elementData.eventDelta or "");
	self:SetRightText(elementData, showTimestamp);
end

function EventTraceLogEventButtonMixin:SetLeftText(elementData, showArguments)
	if showArguments then
		self.LeftLabel:SetText(string.format("%s %s", elementData.lineWithoutArguments, elementData.formattedArguments));
	else
		self.LeftLabel:SetText(elementData.lineWithoutArguments);
	end
end

function EventTraceLogEventButtonMixin:SetRightText(elementData, showTimestamp)
	if showTimestamp then
		self.RightLabel:SetText(GRAY_FONT_COLOR:WrapTextInColorCode(elementData.formattedTimestamp));
	else
		self.RightLabel:SetText("");
	end
end

function EventTraceLogEventButtonMixin:OnShowArgumentsChanged(elementData, showArguments)
	self:SetLeftText(elementData, showArguments);
end

function EventTraceLogEventButtonMixin:OnShowTimestampChanged(elementData, showTimestamp)
	self:SetRightText(elementData, showTimestamp);
end

EventTraceLogMessageButtonMixin = {};

function EventTraceLogMessageButtonMixin:Init(elementData)
	local id = FormatLogID(elementData);
	local message = ORANGE_FONT_COLOR:WrapTextInColorCode(string.format(EVENTTRACE_MESSAGE_FORMAT, elementData.message));
	elementData.lineWithoutArguments = FormatLine(id, message);

	self:SetLeftText(elementData);
end

function EventTraceLogMessageButtonMixin:SetLeftText(elementData)
	self.LeftLabel:SetText(elementData.lineWithoutArguments);
end

function EventTraceLogMessageButtonMixin:OnShowArgumentsChanged(elementData, showArguments)
	self:SetLeftText(elementData);
end

function EventTraceLogMessageButtonMixin:OnShowTimestampChanged(elementData, showTimestamp)
end

function EventTraceLogMessageButtonMixin:SetRightText(elementData)
end

EventTraceFilterButtonMixin = {};

function EventTraceFilterButtonMixin:Init(elementData, hideCb)
	self.Label:SetText(GetDisplayEvent(elementData));

	self:UpdateEnabledState();

	self.HideButton:SetScript("OnMouseDown", function(button, buttonName)
		hideCb(elementData);
	end);

	self.CheckButton:SetScript("OnClick", function(button, buttonName)
		self:ToggleEnabledState();
	end);
end

function EventTraceFilterButtonMixin:UpdateEnabledState()
	local elementData = self:GetElementData();
	self.CheckButton:SetChecked(elementData.enabled);
	self:SetAlpha(elementData.enabled and 1 or .7);
	self:DesaturateHierarchy(elementData.enabled and 0 or 1);
end

function EventTraceFilterButtonMixin:OnDoubleClick()
	self:ToggleEnabledState();
end

function EventTraceFilterButtonMixin:ToggleEnabledState()
	local elementData = self:GetElementData();
	elementData.enabled = not elementData.enabled;
	self:UpdateEnabledState();
end

if SlashCmdList then
	SlashCmdList["EVENTTRACE"] = function(msg)
		if not EventTrace:ProcessChatCommand(msg) then
			EventTrace:SetShown(not EventTrace:IsShown());
		end
	end
end