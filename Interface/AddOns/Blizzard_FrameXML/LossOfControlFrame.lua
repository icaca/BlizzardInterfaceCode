--[[
Howdy!
Classic MoP also uses this so please be mindful when editting :)
]]

-- can't scale text with animations, use raid warning scaling
local abilityNameTimings = {
	["RAID_NOTICE_MIN_HEIGHT"] = 22.0,
	["RAID_NOTICE_MAX_HEIGHT"] = 32.0,
	["RAID_NOTICE_SCALE_UP_TIME"] = 0.1,
	["RAID_NOTICE_SCALE_DOWN_TIME"] = 0.2,
}
local timeLeftTimings = {
	["RAID_NOTICE_MIN_HEIGHT"] = 20.0,
	["RAID_NOTICE_MAX_HEIGHT"] = 28.0,
	["RAID_NOTICE_SCALE_UP_TIME"] = 0.1,
	["RAID_NOTICE_SCALE_DOWN_TIME"] = 0.2,
}

local TEXT_OVERRIDE = {
	[33786] = LOSS_OF_CONTROL_DISPLAY_CYCLONE,
	[113506] = LOSS_OF_CONTROL_DISPLAY_CYCLONE,
	[209753] = LOSS_OF_CONTROL_DISPLAY_CYCLONE,
}

local TIME_LEFT_FRAME_WIDTH = 200;
LOSS_OF_CONTROL_TIME_OFFSET = 6;

local ALERT_FADE_DELAY = 1;
local ALERT_FADE_TIME = 0.5;

local DISPLAY_TYPE_FULL = 2;
local DISPLAY_TYPE_ALERT = 1;
local DISPLAY_TYPE_NONE = 0;

LOSS_OF_CONTROL_ACTIVE_INDEX = 1;

LossOfControlMixin = {};

function LossOfControlMixin:OnLoad()
	self:RegisterEvent("CVAR_UPDATE");
	self:RegisterEvent("VARIABLES_LOADED");
	-- figure out some string widths - our base width is for under 10 seconds which should be almost all loss of control durations
	self.TimeLeft.baseNumberWidth = self.TimeLeft.NumberText:GetStringWidth() + LOSS_OF_CONTROL_TIME_OFFSET;
	self.TimeLeft.secondsWidth = self.TimeLeft.SecondsText:GetStringWidth();

	self.Anim:SetScript("OnFinished", function()
		if (self.Cooldown:GetCooldownDuration() > 0) then
			self.Cooldown:Show();
		end
	end);
end

function LossOfControlMixin:OnEvent(event, ...)
	if ( event == "LOSS_OF_CONTROL_UPDATE" ) then
		self:UpdateDisplay(false);
	elseif ( event == "LOSS_OF_CONTROL_ADDED" ) then
		local unitToken, eventIndex = ...;
		local data = C_LossOfControl.GetActiveLossOfControlData(eventIndex);
		local timeRemaining = data.timeRemaining;
		local priority = data.priority;
		if ( data.displayType == DISPLAY_TYPE_ALERT ) then
			-- only display an alert type if there's nothing up or it has higher priority. If same priority, it needs to have longer time remaining
			if ( not self:IsShown() or priority > self.priority or ( priority == self.priority and timeRemaining and ( not self.TimeLeft.timeRemaining or timeRemaining > self.TimeLeft.timeRemaining ) ) ) then
				self:SetUpDisplay(true, data);
			end
			return;
		end
		if ( eventIndex == LOSS_OF_CONTROL_ACTIVE_INDEX ) then
			self.fadeDelayTime = nil;
			self.fadeTime = nil;
			self:SetUpDisplay(true);
		end
	elseif ( event == "CVAR_UPDATE" ) then
		local cvar, value = ...;
		if ( cvar == "lossOfControl" ) then
			if ( value == "1" ) then
				self:RegisterUnitEvent("LOSS_OF_CONTROL_UPDATE", "player");
				self:RegisterUnitEvent("LOSS_OF_CONTROL_ADDED", "player");
			else
				self:UnregisterEvent("LOSS_OF_CONTROL_UPDATE");
				self:UnregisterEvent("LOSS_OF_CONTROL_ADDED");
				self:Hide();
			end
		end
	elseif ( event == "VARIABLES_LOADED" ) then
		if ( GetCVarBool("lossOfControl" ) ) then
			self:RegisterUnitEvent("LOSS_OF_CONTROL_UPDATE", "player");
			self:RegisterUnitEvent("LOSS_OF_CONTROL_ADDED", "player");
		end
	end
end

function LossOfControlMixin:OnUpdate(elapsed)
	RaidNotice_UpdateSlot(self.AbilityName, abilityNameTimings, elapsed);
	RaidNotice_UpdateSlot(self.TimeLeft.NumberText, timeLeftTimings, elapsed);
	RaidNotice_UpdateSlot(self.TimeLeft.SecondsText, timeLeftTimings, elapsed);

	-- handle alert fade timing
	if(self.fadeDelayTime) then
		self.fadeDelayTime = self.fadeDelayTime - elapsed;
		if(self.fadeDelayTime < 0) then
			self.fadeDelayTime = nil;
		end
	end

	if(self.fadeTime and not self.fadeDelayTime) then
		self.fadeTime = self.fadeTime - elapsed;
		self:SetAlpha(Saturate(self.fadeTime / ALERT_FADE_TIME));
		if(self.fadeTime < 0) then
			self:Hide();
		else
			-- no need to do any other work
			return;
		end
	else
		self:SetAlpha(1.0);
	end
	self:UpdateDisplay();
end

function LossOfControlMixin:OnHide()
	self.fadeTime = nil;
	self.fadeDelayTime = nil;
	self.priority = nil;
end

function LossOfControlMixin:SetUpDisplay(animate, data)
	if ( not data ) then
		data = C_LossOfControl.GetActiveLossOfControlData(LOSS_OF_CONTROL_ACTIVE_INDEX);
	end
	
	local locType = data.locType;
	local spellID = data.spellID;
	local text = data.displayText;
	local iconTexture = data.iconTexture;
	local startTime = data.startTime;
	local timeRemaining = data.timeRemaining;
	local duration = data.duration;
	local lockoutSchool = data.lockoutSchool;
	local priority = data.priority;
	local displayType = data.displayType;

	if ( text and displayType ~= DISPLAY_TYPE_NONE ) then
		-- ability name
		text = TEXT_OVERRIDE[spellID] or text;
		if ( locType == "SCHOOL_INTERRUPT" ) then
			-- Replace text with school-specific lockout text
			if(lockoutSchool and lockoutSchool ~= 0) then
				text = string.format(LOSS_OF_CONTROL_DISPLAY_INTERRUPT_SCHOOL, C_Spell.GetSchoolString(lockoutSchool));
			end
		end
		self.AbilityName:SetText(text);
		-- icon
		self.Icon:SetTexture(iconTexture);
		-- time
		local timeLeftFrame = self.TimeLeft;
		if ( displayType == DISPLAY_TYPE_ALERT ) then
			timeRemaining = duration;
			CooldownFrame_Clear(self.Cooldown);
		elseif ( not startTime ) then
			CooldownFrame_Clear(self.Cooldown);
		else
			CooldownFrame_Set(self.Cooldown, startTime, duration, true);
		end
		self:SetTime(timeRemaining);
		-- align stuff
		local abilityWidth = self.AbilityName:GetWidth();
		local longestTextWidth = max(abilityWidth, (timeLeftFrame.numberWidth + timeLeftFrame.secondsWidth));
		local xOffset = (abilityWidth - longestTextWidth) / 2 + 27;
		self.AbilityName:SetPoint("CENTER", xOffset, 11);
		self.Icon:SetPoint("CENTER", -((6 + longestTextWidth) / 2), 0);
		-- left-align the TimeLeft frame with the ability name using a center anchor (will need center for "animating" via frame scaling - NYI)
		xOffset = xOffset + (TIME_LEFT_FRAME_WIDTH - abilityWidth) / 2;
		timeLeftFrame:SetPoint("CENTER", xOffset, -12);
		-- show
		if ( animate ) then
			if ( displayType == DISPLAY_TYPE_ALERT ) then
				self.fadeDelayTime = ALERT_FADE_DELAY;
				self.fadeTime = ALERT_FADE_TIME;
			end
			self.Anim:Stop();
			self.AbilityName.scrollTime = 0;
			self.TimeLeft.NumberText.scrollTime = 0;
			self.TimeLeft.SecondsText.scrollTime = 0;
			self.Cooldown:Hide();
			self.Anim:Play();
			PlaySound(SOUNDKIT.UI_LOSS_OF_CONTROL_START);
		end
		self.priority = priority;
		self.spellID = spellID;
		self.startTime = startTime;
		self:Show();
	end
end

function LossOfControlMixin:UpdateDisplay()
	-- if displaying an alert, wait for it to go away on its own
	if ( self.fadeTime ) then
		return;
	end

	local data = C_LossOfControl.GetActiveLossOfControlData(LOSS_OF_CONTROL_ACTIVE_INDEX);
	if ( data and data.displayText and data.displayType == DISPLAY_TYPE_FULL ) then
		if ( data.spellID ~= self.spellID or data.startTime ~= self.startTime ) then
			self:SetUpDisplay(false, data);
		end
		if ( not self.Anim:IsPlaying() and data.startTime ) then
			CooldownFrame_Set(self.Cooldown, data.startTime, data.duration, true, true);
		end
		self:SetTime(data.timeRemaining);
	else
		self:Hide();
	end
end

function LossOfControlMixin:SetTime(timeRemaining)
	local timeLeft = self.TimeLeft;
	
	if timeRemaining then
		if ( timeRemaining >= 10 ) then
			timeLeft.NumberText:SetFormattedText("%d", timeRemaining);
		elseif (timeRemaining < 9.95) then -- From 9.95 to 9.99 it will print 10.0 instead of 9.9
			timeLeft.NumberText:SetFormattedText("%.1F", timeRemaining);
		end
		timeLeft:Show();
		timeLeft.timeRemaining = timeRemaining;
		timeLeft.numberWidth = timeLeft.NumberText:GetStringWidth() + LOSS_OF_CONTROL_TIME_OFFSET;
	else
		timeLeft:Hide();
		timeLeft.numberWidth = 0;
	end
end

