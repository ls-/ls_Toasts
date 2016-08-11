-- Lua
local _G = _G
local tonumber, unpack, pairs, select, type, next = tonumber, unpack, pairs, select, type, next
local tremove, tinsert, twipe = table.remove, table.insert, table.wipe
local strformat, strsplit = string.format, string.split
local mfloor = math.floor

-- Mine
local INLINE_NEED = "|TInterface\\Buttons\\UI-GroupLoot-Dice-Up:0:0:0:0:32:32:0:32:0:31|t"
local INLINE_GREED = "|TInterface\\Buttons\\UI-GroupLoot-Coin-Up:0:0:0:0:32:32:0:32:0:31|t"
local INLINE_DE = "|TInterface\\Buttons\\UI-GroupLoot-DE-Up:0:0:0:0:32:32:0:32:0:31|t"
local itemToasts = {}
local missonToasts = {}
local followerToasts = {}
local achievementToasts = {}
local abilityToasts = {}
local scenarioToasts = {}
local miscToasts = {}
local activeToasts = {}
local queuedToasts = {}
local toastCounter = 0

------------
-- CONFIG --
------------

local CFG
local DEFAULTS = {
	growth_direction = "DOWN",
	point = {"TOPLEFT", "UIParent", "TOPLEFT", 24, -12},
	max_active_toasts = 12,
	sfx_enabled = true,
	fadeout_delay = 2.8,
	scale = 1,
	dnd = {
		achievement = false,
		archaeology = false,
		recipe = false,
		garrison = true,
		instance = false, -- dungeon completion
		loot = false, -- includes blizz store items
		world = false, -- world quest, invasion completion
	},
	achievement_enabled = true,
	archaeology_enabled = true,
	garrison_enabled = true,
	instance_enabled = true,
	loot_enabled = true,
	recipe_enabled = true,
	world_enabled = true,
}

----------------
-- DISPATCHER --
----------------

local function EventHandler(self, event, ...)
	self[event](self, ...)
end

local dispatcher = _G.CreateFrame("Frame")
dispatcher:SetScript("OnEvent", EventHandler)

------------
-- ANCHOR --
------------

local function CalculatePosition(self)
	local selfCenterX, selfCenterY = self:GetCenter()
	local screenWidth = mfloor(_G.UIParent:GetRight() + 0.5)
	local screenHeight = mfloor(_G.UIParent:GetTop() + 0.5)
	local p, rP, x, y

	if selfCenterX and selfCenterY then
		selfCenterX, selfCenterY = mfloor(selfCenterX + 0.5), mfloor(selfCenterY + 0.5)

		if selfCenterX >= screenWidth / 2 then
			-- RIGHT
			x = mfloor(self:GetRight() + 0.5) - screenWidth

			if selfCenterY >= screenHeight / 2 then
				-- TOP
				p  = "TOPRIGHT"
				rP  = "TOPRIGHT"
				y = mfloor(self:GetTop() + 0.5) - screenHeight
			else
				-- BOTTOM
				p  = "BOTTOMRIGHT"
				rP  = "BOTTOMRIGHT"
				y = mfloor(self:GetBottom() + 0.5)
			end
		else
			-- LEFT
			x = mfloor(self:GetLeft() + 0.5)

			if selfCenterY >= screenHeight / 2 then
				-- TOP
				p  = "TOPLEFT"
				rP  = "TOPLEFT"
				y = mfloor(self:GetTop() + 0.5) - screenHeight
			else
				-- BOTTOM
				p  = "BOTTOMLEFT"
				rP  = "BOTTOMLEFT"
				y = mfloor(self:GetBottom() + 0.5)
			end
		end
	end

	return p, rP, x, y
end

local function Anchor_OnDragStart(self)
	self:StartMoving()
end

local function Anchor_OnDragStop(self)
	self:StopMovingOrSizing()

	local anchor = "UIParent"
	local p, rP, x, y = CalculatePosition(self)

	self:ClearAllPoints()
	self:SetPoint(p, anchor, rP, x, y)

	CFG.point = {p, anchor, rP, x, y}
end

local anchorFrame = _G.CreateFrame("Frame", "LSToastAnchor", _G.UIParent)
anchorFrame:SetSize(234, 58)
anchorFrame:SetClampedToScreen(true)
anchorFrame:SetClampRectInsets(-24, 12, 12, -12)
anchorFrame:SetMovable(true)
anchorFrame:SetToplevel(true)
anchorFrame:RegisterForDrag("LeftButton")
anchorFrame:SetScript("OnDragStart", Anchor_OnDragStart)
anchorFrame:SetScript("OnDragStop", Anchor_OnDragStop)

do
	local texture = anchorFrame:CreateTexture(nil, "BACKGROUND")
	texture:SetColorTexture(0.1, 0.1, 0.1, 0.9)
	texture:SetAllPoints()
	texture:Hide()
	anchorFrame.BG = texture

	local text = anchorFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	text:SetAllPoints()
	text:SetJustifyH("CENTER")
	text:SetJustifyV("MIDDLE")
	text:SetText("Toast Anchor")
	text:Hide()
	anchorFrame.Text = text
end

local function Anchor_Enable()
	anchorFrame:EnableMouse(true)
	anchorFrame.BG:Show()
	anchorFrame.Text:Show()
end

local function Anchor_Disable()
	anchorFrame:EnableMouse(false)
	anchorFrame.BG:Hide()
	anchorFrame.Text:Hide()
end

----------
-- MAIN --
----------

local function IsDNDEnabled()
	local counter = 0

	for k in pairs (CFG.dnd) do
		if k then
			counter = counter + 1
		end
	end

	return counter > 0
end

local function HasNonDNDToast()
	for i, queuedToast in pairs(queuedToasts) do
		if not queuedToast.dnd then
			-- XXX: I don't want to ruin non-DND toasts' order, k?
			tinsert(queuedToasts, 1, tremove(queuedToasts, i))

			return true
		end
	end

	return false
end

local function SpawnToast(toast, isDND)
	if not toast then return end

	if #activeToasts >= CFG.max_active_toasts or (_G.InCombatLockdown() and isDND) then
		if _G.InCombatLockdown() and isDND then
			toast.dnd = true
		end

		tinsert(queuedToasts, toast)

		return false
	end

	if #activeToasts > 0 then
		if CFG.growth_direction == "DOWN" then
			toast:SetPoint("TOP", activeToasts[#activeToasts], "BOTTOM", 0, -4)
		else
			toast:SetPoint("BOTTOM", activeToasts[#activeToasts], "TOP", 0, 4)
		end
	else
		toast:SetPoint("TOPLEFT", anchorFrame, "TOPLEFT", 0, 0)
	end

	tinsert(activeToasts, toast)

	toast:Show()

	return true
end

local function RefreshToasts()
	for i = 1, #activeToasts do
		local activeToast = activeToasts[i]

		activeToast:ClearAllPoints()

		if i == 1 then
			activeToast:SetPoint("TOPLEFT", anchorFrame, "TOPLEFT", 0, 0)
		else
			if CFG.growth_direction == "DOWN" then
				activeToast:SetPoint("TOP", activeToasts[i - 1], "BOTTOM", 0, -4)
			else
				activeToast:SetPoint("BOTTOM", activeToasts[i - 1], "TOP", 0, 4)
			end
		end
	end

	local queuedToast = tremove(queuedToasts, 1)

	if queuedToast then
		if _G.InCombatLockdown() and queuedToast.dnd then
			tinsert(queuedToasts, queuedToast)

			if HasNonDNDToast() then
				RefreshToasts()
			end
		else
			SpawnToast(queuedToast)
		end
	end
end

local function RecycleToast(toast)
	for i, activeToast in pairs(activeToasts) do
		if toast == activeToast then
			tremove(activeToasts, i)

			if toast.type == "item" then
				tinsert(itemToasts, toast)
			elseif toast.type == "mission" then
				tinsert(missonToasts, toast)
			elseif toast.type == "follower" then
				tinsert(followerToasts, toast)
			elseif toast.type == "achievement" then
				tinsert(achievementToasts, toast)
			elseif toast.type == "ability" then
				tinsert(abilityToasts, toast)
			elseif toast.type == "scenario" then
				tinsert(scenarioToasts, toast)
			elseif toast.type == "misc" then
				tinsert(miscToasts, toast)
			end

			toast:Hide()
		end
	end

	RefreshToasts()
end

local function GetToastToUpdate(id, toastType)
	for _, toast in pairs(activeToasts) do
		if id == toast.id and toastType == toast.type then
			return toast, false
		end
	end

	for _, toast in pairs(queuedToasts) do
		if id == toast.id and toastType == toast.type then
			return toast, true
		end
	end

	return
end

local function UpdateToast(id, toastType, itemLink)
	local toast, isQueued = GetToastToUpdate(id, toastType)

	if toast then
		toast.usedRewards = toast.usedRewards + 1
		local reward = toast["Reward"..toast.usedRewards]

		if reward then
			local _, _, _, _, texture = _G.GetItemInfoInstant(itemLink)

			_G.SetPortraitToTexture(reward.Icon, texture)
			reward.item = itemLink
			reward:Show()
		end

		if not isQueued then
			toast.AnimOut:Stop()
			toast.AnimOut:Play()
		end
	end
end

local function ToastButton_OnShow(self)
	local soundFile = self.soundFile

	if CFG.sfx_enabled and soundFile then
		if type(soundFile) == "number" then
			_G.PlaySoundKitID(soundFile)
		elseif type(soundFile) == "string" then
			_G.PlaySound(soundFile)
		end
	end

	self.AnimIn:Play()
	self.AnimOut:Play()
end

local function ToastButton_OnHide(self)
	self.id = nil
	self.dnd = nil
	self.link = nil
	self.soundFile = nil
	self.usedRewards = nil
	self:ClearAllPoints()
	self.BG:SetTexture("Interface\\AddOns\\ls_Toasts\\media\\toast-bg-default")
	self.Icon:SetPoint("TOPLEFT", 7, -7)
	self.Icon:SetSize(44, 44)
	self.Title:SetText("")
	self.Text:SetText("")
	self.TextBG:SetVertexColor(0, 0, 0)
	self.AnimIn:Stop()
	self.AnimOut:Stop()

	if self.IconBorder then
		self.IconBorder:Show()
		self.IconBorder:SetVertexColor(1, 1, 1)
	end

	if self.Count then
		self.Count:SetText("")
	end

	if self.Dragon then
		self.Dragon:Hide()
	end

	if self.Level then
		self.Level:SetText("")
	end

	if self.Points then
		self.Points:SetText("")
	end

	if self.Rank then
		self.Rank:SetText("")
	end

	if self.IconText then
		self.IconText:SetText("")
	end

	if self.Bonus then
		self.Bonus:Hide()
	end

	if self.Heroic then
		self.Heroic:Hide()
	end

	if self.Arrows then
		self.Arrows.Anim:Stop()
	end

	if self.Reward1 then
		for i = 1, 5 do
			self["Reward"..i]:Hide()
		end
	end
end

local function ToastButton_OnClick(self, button)
	if button == "RightButton" then
		RecycleToast(self)
	elseif button == "LeftButton" then
		if self.id then
			if self.type == "achievement" then
				_G.ShowUIPanel(_G.AchievementFrame)
				_G.AchievementFrame_SelectAchievement(self.id)
			elseif self.type == "follower" then
				if not _G.GarrisonLandingPage then
					_G.Garrison_LoadUI()
				end

				_G.ShowGarrisonLandingPage(_G.GarrisonFollowerOptions[_G.C_Garrison.GetFollowerInfo(self.id).followerTypeID].garrisonType)
			end
		end
	end
end

local function ToastButton_OnEnter(self)
	if self.id then
		if self.type == "item" then
			_G.GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT", -2, 2)
			_G.GameTooltip:SetItemByID(self.id)
			_G.GameTooltip:Show()
		elseif self.type == "follower" then
			local link = _G.C_Garrison.GetFollowerLink(self.id)

			if link then
				local _, garrisonFollowerID, quality, level, itemLevel, ability1, ability2, ability3, ability4, trait1, trait2, trait3, trait4, spec1 = strsplit(":", link)
				local followerType = _G.C_Garrison.GetFollowerTypeByID(tonumber(garrisonFollowerID))
				_G.GarrisonFollowerTooltip_Show(tonumber(garrisonFollowerID), false, tonumber(quality), tonumber(level), 0, 0, tonumber(itemLevel), tonumber(spec1), tonumber(ability1), tonumber(ability2), tonumber(ability3), tonumber(ability4), tonumber(trait1), tonumber(trait2), tonumber(trait3), tonumber(trait4))

				if followerType == _G.LE_FOLLOWER_TYPE_SHIPYARD_6_2 then
					_G.GarrisonShipyardFollowerTooltip:ClearAllPoints()
					_G.GarrisonShipyardFollowerTooltip:SetPoint("TOPLEFT", self, "BOTTOMRIGHT", -2, 2)
				else
					_G.GarrisonFollowerTooltip:ClearAllPoints()
					_G.GarrisonFollowerTooltip:SetPoint("TOPLEFT", self, "BOTTOMRIGHT", -2, 2)
				end
			end
		elseif self.type == "ability" then
			_G.GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT", -2, 2)
			_G.GameTooltip:SetSpellByID(self.id)
			_G.GameTooltip:Show()
		end
	elseif self.link then
		if self.type == "item" then
			_G.GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT", -2, 2)
			_G.GameTooltip:SetHyperlink(self.link)
			_G.GameTooltip:Show()
		end
	end

	self.AnimOut:Stop()
end

local function ToastButton_OnLeave(self)
	_G.GameTooltip:Hide()
	_G.GarrisonFollowerTooltip:Hide()
	_G.GarrisonShipyardFollowerTooltip:Hide()

	self.AnimOut:Play()
end

local function ToastButtonAnimIn_OnStop(self)
	local frame = self:GetParent()

	if frame.Arrows then
		frame.Arrows.requested = false
	end
end

local function ToastButtonAnimIn_OnFinished(self)
	local frame = self:GetParent()

	if frame.Arrows and frame.Arrows.requested then
		--- XXX: Parent translation anims affect child's translation anims
		_G.C_Timer.After(0.1, function() frame.Arrows.Anim:Play() end)

		frame.Arrows.requested = false
	end
end

local function ToastButtonAnimOut_OnFinished(self)
	RecycleToast(self:GetParent())
end

local function CreateBaseToastButton()
	toastCounter = toastCounter + 1

	local toast = _G.CreateFrame("Button", "LSToast"..toastCounter, _G.UIParent)
	toast:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	toast:Hide()
	toast:SetScript("OnShow", ToastButton_OnShow)
	toast:SetScript("OnHide", ToastButton_OnHide)
	toast:SetScript("OnClick", ToastButton_OnClick)
	toast:SetScript("OnEnter", ToastButton_OnEnter)
	toast:SetScript("OnLeave", ToastButton_OnLeave)
	toast:SetSize(234, 58)
	toast:SetScale(CFG.scale)
	toast:SetFrameStrata("DIALOG")

	local bg = toast:CreateTexture(nil, "BACKGROUND", nil, 0)
	bg:SetPoint("TOPLEFT", 5, -5)
	bg:SetPoint("BOTTOMRIGHT", -5, 5)
	bg:SetTexture("Interface\\AddOns\\ls_Toasts\\media\\toast-bg-default")
	bg:SetTexCoord(1 / 256, 225 / 256, 1 / 64, 49 / 64)
	toast.BG = bg

	local border = toast:CreateTexture(nil, "BACKGROUND", nil, 1)
	border:SetAllPoints()
	border:SetTexture("Interface\\AddOns\\ls_Toasts\\media\\toast-border")
	border:SetTexCoord(1 / 256, 235 / 256, 1 / 64, 59 / 64)
	toast.Border = border

	local icon = toast:CreateTexture(nil, "BACKGROUND", nil, 2)
	icon:SetPoint("TOPLEFT", 7, -7)
	icon:SetSize(44, 44)
	toast.Icon = icon

	local title = toast:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	title:SetPoint("TOPLEFT", 55, -12)
	title:SetWidth(170)
	title:SetJustifyH("CENTER")
	title:SetWordWrap(false)
	title:SetText("Toast Title")
	toast.Title = title

	local text = toast:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
	text:SetPoint("BOTTOMLEFT", 55, 12)
	text:SetWidth(170)
	text:SetJustifyH("CENTER")
	text:SetWordWrap(false)
	text:SetText(toast:GetDebugName())
	toast.Text = text

	local textBG = toast:CreateTexture(nil, "BACKGROUND", nil, 2)
	textBG:SetSize(174, 44)
	textBG:SetPoint("BOTTOMLEFT", 53, 7)
	textBG:SetTexture("Interface\\AddOns\\ls_Toasts\\media\\toast-text-bg")
	textBG:SetTexCoord(1 / 256, 175 / 256, 1 / 64, 45 / 64)
	textBG:SetVertexColor(0, 0, 0)
	toast.TextBG = textBG

	local glow = toast:CreateTexture(nil, "OVERLAY", nil, 2)
	glow:SetSize(310, 148)
	glow:SetPoint("CENTER")
	glow:SetTexture("Interface\\AchievementFrame\\UI-Achievement-Alert-Glow")
	glow:SetTexCoord(0, 0.78125, 0, 0.66796875)
	glow:SetBlendMode("ADD")
	glow:SetAlpha(0)
	toast.Glow = glow

	local shine = toast:CreateTexture(nil, "OVERLAY", nil, 1)
	shine:SetSize(67, 54)
	shine:SetPoint("BOTTOMLEFT", 0, 2)
	shine:SetTexture("Interface\\AchievementFrame\\UI-Achievement-Alert-Glow")
	shine:SetTexCoord(400 / 512, 467 / 512, 11 / 256, 65 / 256)
	shine:SetBlendMode("ADD")
	shine:SetAlpha(0)
	toast.Shine = shine

	local animIn = toast:CreateAnimationGroup()
	animIn:SetScript("OnStop", ToastButtonAnimIn_OnStop)
	animIn:SetScript("OnFinished", ToastButtonAnimIn_OnFinished)
	toast.AnimIn = animIn

	local anim1 = animIn:CreateAnimation("Alpha")
	anim1:SetChildKey("Glow")
	anim1:SetOrder(1)
	anim1:SetFromAlpha(0)
	anim1:SetToAlpha(1)
	anim1:SetDuration(0.2)

	local anim2 = animIn:CreateAnimation("Alpha")
	anim2:SetChildKey("Glow")
	anim2:SetOrder(2)
	anim2:SetFromAlpha(1)
	anim2:SetToAlpha(0)
	anim2:SetDuration(0.5)

	local anim3 = animIn:CreateAnimation("Alpha")
	anim3:SetChildKey("Shine")
	anim3:SetOrder(1)
	anim3:SetFromAlpha(0)
	anim3:SetToAlpha(1)
	anim3:SetDuration(0.2)

	local anim4 = animIn:CreateAnimation("Translation")
	anim4:SetChildKey("Shine")
	anim4:SetOrder(2)
	anim4:SetOffset(168, 0)
	anim4:SetDuration(0.85)

	local anim5 = animIn:CreateAnimation("Alpha")
	anim5:SetChildKey("Shine")
	anim5:SetOrder(2)
	anim5:SetFromAlpha(1)
	anim5:SetToAlpha(0)
	anim5:SetStartDelay(0.35)
	anim5:SetDuration(0.5)

	local animOut = toast:CreateAnimationGroup()
	animOut:SetScript("OnFinished", ToastButtonAnimOut_OnFinished)
	toast.AnimOut = animOut

	anim1 = animOut:CreateAnimation("Alpha")
	anim1:SetOrder(1)
	anim1:SetFromAlpha(1)
	anim1:SetToAlpha(0)
	anim1:SetStartDelay(CFG.fadeout_delay)
	anim1:SetDuration(1.2)
	animOut.Anim1 = anim1

	return toast
end

local ARROW_CFG = {
	[1] = {startDelay1 = 0.9, startDelay2 = 1.2, point = {"TOP", "$parent", "CENTER", 8, 0}},
	[2] = {startDelay1 = 1.0, startDelay2 = 1.3, point = {"CENTER", "$parentArrow1", 16, 0}},
	[3] = {startDelay1 = 1.1, startDelay2 = 1.4, point = {"CENTER", "$parentArrow1", -16, 0}},
	[4] = {startDelay1 = 1.3, startDelay2 = 1.6, point = {"CENTER", "$parentArrow1", 5, 0}},
	[5] = {startDelay1 = 1.5, startDelay2 = 1.8, point = {"CENTER", "$parentArrow1", -12, 0}},
}

local function ShowArrows(self)
	self:GetParent():Show()
end

local function HideArrows(self)
	self:GetParent():Hide()
end

local function CreateUpdateArrowsAnim(parent)
	local frame = _G.CreateFrame("Frame", "$parentUpgradeArrows", parent)
	frame:SetSize(48, 48)
	frame:Hide()

	local ag = frame:CreateAnimationGroup()
	ag:SetScript("OnPlay", ShowArrows)
	ag:SetScript("OnFinished", HideArrows)
	ag:SetScript("OnStop", HideArrows)
	frame.Anim = ag

	for i = 1, 5 do
		frame["Arrow"..i] = frame:CreateTexture("$parentArrow"..i, "ARTWORK", "LootUpgradeFrame_ArrowTemplate")
		frame["Arrow"..i]:ClearAllPoints()
		frame["Arrow"..i]:SetPoint(unpack(ARROW_CFG[i].point))

		local anim = ag:CreateAnimation("Alpha")
		anim:SetChildKey("Arrow"..i)
		anim:SetDuration(0)
		anim:SetOrder(1)
		anim:SetFromAlpha(1)
		anim:SetToAlpha(0)

		anim = ag:CreateAnimation("Alpha")
		anim:SetChildKey("Arrow"..i)
		anim:SetStartDelay(ARROW_CFG[i].startDelay1)
		anim:SetSmoothing("IN")
		anim:SetDuration(0.2)
		anim:SetOrder(2)
		anim:SetFromAlpha(0)
		anim:SetToAlpha(1)

		anim = ag:CreateAnimation("Alpha")
		anim:SetChildKey("Arrow"..i)
		anim:SetStartDelay(ARROW_CFG[i].startDelay2)
		anim:SetSmoothing("OUT")
		anim:SetDuration(0.2)
		anim:SetOrder(2)
		anim:SetFromAlpha(1)
		anim:SetToAlpha(0)

		anim = ag:CreateAnimation("Translation")
		anim:SetChildKey("Arrow"..i)
		anim:SetStartDelay(ARROW_CFG[i].startDelay1)
		anim:SetDuration(0.5)
		anim:SetOrder(2)
		anim:SetOffset(0, 60)

		anim = ag:CreateAnimation("Alpha")
		anim:SetChildKey("Arrow"..i)
		anim:SetDuration(0)
		anim:SetOrder(3)
		anim:SetFromAlpha(1)
		anim:SetToAlpha(0)
	end

	return frame
end

local function Reward_OnEnter(self)
	self:GetParent().AnimOut:Stop()

	_G.GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT")

	if self.rewardID then
		_G.GameTooltip:SetLFGCompletionReward(self.rewardID)
	elseif self.xp then
		_G.GameTooltip:AddLine(_G.YOU_RECEIVED)
		_G.GameTooltip:AddLine(strformat(_G.BONUS_OBJECTIVE_EXPERIENCE_FORMAT, self.xp), 1, 1, 1)
	elseif self.money then
		_G.GameTooltip:AddLine(_G.YOU_RECEIVED)
		_G.GameTooltip:AddLine(_G.GetMoneyString(self.money), 1, 1, 1)
	elseif self.item then
		_G.GameTooltip:SetHyperlink(self.item)
	elseif self.currency then
		_G.GameTooltip:SetQuestLogCurrency("reward", self.currency, self:GetParent().id)
	end

	_G.GameTooltip:Show()
end

local function Reward_OnLeave(self)
	self:GetParent().AnimOut:Play()
	_G.GameTooltip:Hide()
end

local function Reward_OnHide(self)
	self.rewardID = nil
	self.currency = nil
	self.money = nil
	self.item = nil
	self.xp = nil
end

local function CreateToastReward(parent, index)
	local reward = _G.CreateFrame("Frame", "$parent"..index, parent)
	reward:SetSize(30, 30)
	reward:SetScript("OnEnter", Reward_OnEnter)
	reward:SetScript("OnLeave", Reward_OnLeave)
	reward:SetScript("OnHide", Reward_OnHide)
	reward:Hide()
	parent["Reward"..index] = reward

	local icon = reward:CreateTexture(nil, "BACKGROUND")
	icon:SetPoint("TOPLEFT", 5, -4)
	icon:SetPoint("BOTTOMRIGHT", -7, 8)
	reward.Icon = icon

	local border = reward:CreateTexture(nil, "BORDER")
	border:SetAllPoints()
	border:SetTexture("Interface\\LFGFrame\\UI-LFG-ICON-REWARDRING")
	border:SetTexCoord(0 / 64, 40 / 64, 0 / 64, 40 / 64)

	return reward
end

local function GetToast(toastType)
	local toast

	if toastType == "item" then
		toast = tremove(itemToasts, 1)

		if not toast then
			toast = CreateBaseToastButton()

			local arrows = CreateUpdateArrowsAnim(toast)
			arrows:SetPoint("TOPLEFT", -5, 5)
			toast.Arrows = arrows

			local iconBorder = toast:CreateTexture(nil, "ARTWORK", nil, 2)
			iconBorder:SetPoint("TOPLEFT", 7, -7)
			iconBorder:SetSize(44, 44)
			iconBorder:SetTexture("Interface\\AddOns\\ls_Toasts\\media\\toast-icon-border")
			iconBorder:SetTexCoord(1 / 64, 45 / 64, 1 / 64, 45 / 64)
			toast.IconBorder = iconBorder

			local count = toast:CreateFontString(nil, "ARTWORK", "GameFontHighlightOutline")
			count:SetPoint("BOTTOMRIGHT", toast.Icon, "BOTTOMRIGHT", 0, 2)
			count:SetJustifyH("RIGHT")
			toast.Count = count

			local dragon = toast:CreateTexture(nil, "OVERLAY", nil, 0)
			dragon:SetPoint("TOPLEFT", -23, 13)
			dragon:SetSize(88, 88)
			dragon:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Gold-Dragon")
			dragon:SetVertexColor(250 / 255, 200 / 255, 0 / 255)
			dragon:Hide()
			toast.Dragon = dragon

			toast.type = "item"
		end
	elseif toastType == "mission" then
		toast = tremove(missonToasts, 1)

		if not toast then
			toast = CreateBaseToastButton()

			local level = toast:CreateFontString(nil, "ARTWORK", "GameFontHighlightOutline")
			level:SetPoint("BOTTOMRIGHT", toast.Icon, "BOTTOMRIGHT", 0, 2)
			level:SetJustifyH("RIGHT")
			toast.Level = level

			toast.type = "mission"
		end
	elseif toastType == "follower" then
		toast = tremove(followerToasts, 1)

		if not toast then
			toast = CreateBaseToastButton()

			local arrows = CreateUpdateArrowsAnim(toast)
			arrows:SetPoint("TOPLEFT", -5, 5)
			toast.Arrows = arrows

			local level = toast:CreateFontString(nil, "ARTWORK", "GameFontHighlightOutline")
			level:SetPoint("BOTTOMRIGHT", toast.Icon, "BOTTOMRIGHT", 0, 2)
			level:SetJustifyH("RIGHT")
			toast.Level = level

			toast.type = "follower"
		end
	elseif toastType == "achievement" then
		toast = tremove(achievementToasts, 1)

		if not toast then
			toast = CreateBaseToastButton()

			local iconBorder = toast:CreateTexture(nil, "ARTWORK", nil, 2)
			iconBorder:SetPoint("TOPLEFT", 7, -7)
			iconBorder:SetSize(44, 44)
			iconBorder:SetTexture("Interface\\AddOns\\ls_Toasts\\media\\toast-icon-border")
			iconBorder:SetTexCoord(1 / 64, 45 / 64, 1 / 64, 45 / 64)
			toast.IconBorder = iconBorder

			local points = toast:CreateFontString(nil, "ARTWORK", "GameFontHighlightOutline")
			points:SetPoint("BOTTOMRIGHT", toast.Icon, "BOTTOMRIGHT", 0, 2)
			points:SetJustifyH("RIGHT")
			toast.Points = points

			toast.type = "achievement"
		end
	elseif toastType == "ability" then
		toast = tremove(abilityToasts, 1)

		if not toast then
			toast = CreateBaseToastButton()

			local iconBorder = toast:CreateTexture(nil, "ARTWORK", nil, 2)
			iconBorder:SetPoint("TOPLEFT", 7, -7)
			iconBorder:SetSize(44, 44)
			iconBorder:SetTexture("Interface\\AddOns\\ls_Toasts\\media\\toast-icon-border")
			iconBorder:SetTexCoord(1 / 64, 45 / 64, 1 / 64, 45 / 64)
			toast.IconBorder = iconBorder

			local rank = toast:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
			rank:SetPoint("BOTTOMRIGHT", toast.Icon, "BOTTOMRIGHT", -2, 2)
			rank:SetJustifyH("RIGHT")
			toast.Rank = rank

			toast.type = "ability"
		end
	elseif toastType == "scenario" then
		toast = tremove(scenarioToasts, 1)

		if not toast then
			toast = CreateBaseToastButton()

			local iconBorder = toast:CreateTexture(nil, "ARTWORK", nil, 2)
			iconBorder:SetPoint("TOPLEFT", 7, -7)
			iconBorder:SetSize(44, 44)
			iconBorder:SetTexture("Interface\\AddOns\\ls_Toasts\\media\\toast-icon-border")
			iconBorder:SetTexCoord(1 / 64, 45 / 64, 1 / 64, 45 / 64)
			toast.IconBorder = iconBorder

			for i = 1, 5 do
				local reward = CreateToastReward(toast, i)

				if i == 1 then
					reward:SetPoint("TOPRIGHT", -2, 10)
				else
					reward:SetPoint("RIGHT", toast["Reward"..(i - 1)], "LEFT", -2 , 0)
				end
			end

			local bonus = toast:CreateTexture(nil, "ARTWORK")
			bonus:SetAtlas("Bonus-ToastBanner", true)
			bonus:SetPoint("TOPRIGHT", -4, 0)
			bonus:Hide()
			toast.Bonus = bonus

			local heroic = toast:CreateTexture(nil, "ARTWORK", nil, 2)
			heroic:SetSize(16, 20)
			heroic:SetTexture("Interface\\LFGFrame\\UI-LFG-ICON-HEROIC")
			heroic:SetTexCoord(0 / 32, 16 / 32, 0 / 32, 20 / 32)
			heroic:SetPoint("BOTTOMRIGHT", toast.Icon, "BOTTOMRIGHT", -2, 0)
			heroic:Hide()
			toast.Heroic = heroic

			toast.type = "scenario"
		end
	elseif toastType == "misc" then
		toast = tremove(miscToasts, 1)

		if not toast then
			toast = CreateBaseToastButton()

			local iconBorder = toast:CreateTexture(nil, "ARTWORK", nil, 2)
			iconBorder:SetPoint("TOPLEFT", 7, -7)
			iconBorder:SetSize(44, 44)
			iconBorder:SetTexture("Interface\\AddOns\\ls_Toasts\\media\\toast-icon-border")
			iconBorder:SetTexCoord(1 / 64, 45 / 64, 1 / 64, 45 / 64)
			toast.IconBorder = iconBorder

			local text = toast:CreateFontString(nil, "ARTWORK", "GameFontHighlightOutline")
			text:SetPoint("BOTTOMRIGHT", toast.Icon, "BOTTOMRIGHT", 0, 2)
			text:SetJustifyH("RIGHT")
			toast.IconText = text

			toast.type = "misc"
		end
	end

	return toast
end

------------------
-- ANCHOR HIDER --
------------------

function dispatcher:PLAYER_REGEN_DISABLED()
	if anchorFrame:IsMouseEnabled() then
		Anchor_OnDragStop(anchorFrame)
		Anchor_Disable()
	end
end

dispatcher:RegisterEvent("PLAYER_REGEN_DISABLED")

---------
-- DND --
---------

function dispatcher:PLAYER_REGEN_ENABLED()
	if IsDNDEnabled() and #queuedToasts > 0 then
		for i = 1, CFG.max_active_toasts - #activeToasts do
			RefreshToasts()
		end
	end
end

dispatcher:RegisterEvent("PLAYER_REGEN_ENABLED")

-----------------
-- ACHIEVEMENT --
-----------------

local function AchievementToast_SetUp(achievementID, flag, isCriteria)
	local toast = GetToast("achievement")
	local _, name, points, _, _, _, _, _, _, icon, _, isGuildAch = _G.GetAchievementInfo(achievementID)

	if isCriteria then
		toast.Title:SetText(_G.ACHIEVEMENT_PROGRESSED)
		toast.Text:SetText(flag)

		toast.Border:SetVertexColor(1, 1, 1)
		toast.IconBorder:SetVertexColor(1, 1, 1)
		toast.Points:SetText("")
	else
		toast.Title:SetText(_G.ACHIEVEMENT_UNLOCKED)
		toast.Text:SetText(name)

		-- alreadyEarned
		if flag then
			toast.Border:SetVertexColor(1, 1, 1)
			toast.IconBorder:SetVertexColor(1, 1, 1)
			toast.Points:SetText("")
		else
			toast.Border:SetVertexColor(0.9, 0.75, 0.26)
			toast.IconBorder:SetVertexColor(0.9, 0.75, 0.26)
			toast.Points:SetText(points == 0 and "" or points)
		end
	end

	toast.Icon:SetTexture(icon)
	toast.id = achievementID

	SpawnToast(toast, CFG.dnd.achievement)
end

function dispatcher:ACHIEVEMENT_EARNED(...)
	local achievementID, alreadyEarned = ...

	AchievementToast_SetUp(achievementID, alreadyEarned, nil)

end

function dispatcher:CRITERIA_EARNED(...)
	local achievementID, criteriaString = ...

	AchievementToast_SetUp(achievementID, criteriaString, true)
end

local function EnableAchievementToasts()
	_G.AlertFrame:UnregisterEvent("ACHIEVEMENT_EARNED")
	_G.AlertFrame:UnregisterEvent("CRITERIA_EARNED")

	if CFG.achievement_enabled then
		if not _G.AchievementFrame then
			_G.AchievementFrame_LoadUI()
		end

		dispatcher:RegisterEvent("ACHIEVEMENT_EARNED")
		dispatcher:RegisterEvent("CRITERIA_EARNED")
	end
end

local function DisableAchievementToasts()
	dispatcher:UnregisterEvent("ACHIEVEMENT_EARNED")
	dispatcher:UnregisterEvent("CRITERIA_EARNED")
end

-----------------
-- ARCHAEOLOGY --
-----------------

function dispatcher:ARTIFACT_DIGSITE_COMPLETE(...)
	local researchFieldID = ...
	local raceName, raceTexture	= _G.GetArchaeologyRaceInfoByID(researchFieldID)
	local toast = GetToast("misc")

	toast.Border:SetVertexColor(0.9, 0.4, 0.1)
	toast.Title:SetText(_G.ARCHAEOLOGY_DIGSITE_COMPLETE_TOAST_FRAME_TITLE)
	toast.Text:SetText(raceName)
	toast.BG:SetTexture("Interface\\AddOns\\ls_Toasts\\media\\toast-bg-archaeology")
	toast.IconBorder:Hide()
	toast.Icon:SetPoint("TOPLEFT", 7, -3)
	toast.Icon:SetSize(76, 76)
	toast.Icon:SetTexture(raceTexture)

	toast.soundFile = "UI_DigsiteCompletion_Toast"

	SpawnToast(toast, CFG.dnd.archaeology)
end

local function ArcheologyProgressBarAnimOut_OnFinished(self)
	self:GetParent():Hide()
end

local function EnableArchaeologyToasts()
	if not _G.ArchaeologyFrame then
		_G.UIParentLoadAddOn("Blizzard_ArchaeologyUI")
	end

	_G.ArcheologyDigsiteProgressBar.AnimOutAndTriggerToast:SetScript("OnFinished", ArcheologyProgressBarAnimOut_OnFinished)

	if CFG.archaeology_enabled then
		dispatcher:RegisterEvent("ARTIFACT_DIGSITE_COMPLETE")
	end
end

local function DisableArchaeologyToasts()
	dispatcher:UnregisterEvent("ARTIFACT_DIGSITE_COMPLETE")
end

--------------
-- GARRISON --
--------------

local function GarrisonMissionToast_SetUp(missionID, isShipyard, isAdded)
	local toast = GetToast("mission")
	local missionInfo = _G.C_Garrison.GetBasicMissionInfo(missionID)
	local color = missionInfo.isRare and _G.ITEM_QUALITY_COLORS[3] or _G.ITEM_QUALITY_COLORS[1]
	local level = missionInfo.iLevel == 0 and missionInfo.level or missionInfo.iLevel

	if isAdded then
		toast.Title:SetText(_G.GARRISON_MISSION_ADDED_TOAST1)
	else
		toast.Title:SetText(_G.GARRISON_MISSION_COMPLETE)
	end

	toast.Text:SetText(missionInfo.name)
	toast.Level:SetText(level)
	toast.Border:SetVertexColor(color.r, color.g, color.b)
	toast.Icon:SetAtlas(missionInfo.typeAtlas, false)
	toast.soundFile = "UI_Garrison_Toast_MissionComplete"
	toast.id = missionID

	SpawnToast(toast, CFG.dnd.garrison)
end

function dispatcher:GARRISON_BUILDING_ACTIVATABLE(...)
	local buildingName = ...
	local toast = GetToast("misc")

	toast.Title:SetText(_G.GARRISON_UPDATE)
	toast.Text:SetText(buildingName)
	toast.Icon:SetTexture("Interface\\Icons\\Garrison_Build")
	toast.soundFile = "UI_Garrison_Toast_BuildingComplete"

	SpawnToast(toast, CFG.dnd.garrison)
end

function dispatcher:GARRISON_FOLLOWER_ADDED(...)
	local followerID, name, class, level, quality, isUpgraded, texPrefix, followerType = ...
	local followerInfo = _G.C_Garrison.GetFollowerInfo(followerID)
	local followerStrings = _G.GarrisonFollowerOptions[followerType].strings
	local upgradeTexture = _G.LOOTUPGRADEFRAME_QUALITY_TEXTURES[quality] or _G.LOOTUPGRADEFRAME_QUALITY_TEXTURES[2]
	local color = _G.ITEM_QUALITY_COLORS[quality]
	local toast = GetToast("follower")

	if followerType == _G.LE_FOLLOWER_TYPE_SHIPYARD_6_2 then
		toast.Icon:SetSize(84, 44)
		toast.Icon:SetAtlas(texPrefix.."-List", false)
		toast.Level:SetText("")
	else
		local portrait

		if followerInfo.portraitIconID and followerInfo.portraitIconID ~= 0 then
			portrait = followerInfo.portraitIconID
		else
			portrait = "Interface\\Garrison\\Portraits\\FollowerPortrait_NoPortrait"
		end

		toast.Level:SetText(level)
		toast.Icon:SetSize(44, 44)
		toast.Icon:SetTexture(portrait)
	end

	if isUpgraded then
		toast.Title:SetText(followerStrings.FOLLOWER_ADDED_UPGRADED_TOAST)
		toast.BG:SetTexture("Interface\\AddOns\\ls_Toasts\\media\\toast-bg-upgrade")

		for i = 1, 5 do
			toast.Arrows["Arrow"..i]:SetAtlas(upgradeTexture.arrow, true)
		end

		toast.Arrows.requested = true
	else
		toast.Title:SetText(followerStrings.FOLLOWER_ADDED_TOAST)
	end

	toast.Text:SetText(name)
	toast.Border:SetVertexColor(color.r, color.g, color.b)
	toast.id = followerID

	SpawnToast(toast, CFG.dnd.garrison)
end

function dispatcher:GARRISON_MISSION_FINISHED(...)
	local validInstance = false
	local _, instanceType = _G.GetInstanceInfo()

	if instanceType == "none" or _G.C_Garrison.IsOnGarrisonMap() then
		validInstance = true
	end

	if validInstance then
		local followerTypeID, missionID = ...

		GarrisonMissionToast_SetUp(missionID, followerTypeID == _G.LE_FOLLOWER_TYPE_SHIPYARD_6_2)
	end
end

function dispatcher:GARRISON_RANDOM_MISSION_ADDED(...)
	local followerTypeID, missionID = ...

	GarrisonMissionToast_SetUp(missionID, followerTypeID == _G.LE_FOLLOWER_TYPE_SHIPYARD_6_2, true)
end

function dispatcher:GARRISON_TALENT_COMPLETE(...)
	local garrisonType = ...
    local talentID = _G.C_Garrison.GetCompleteTalent(garrisonType)
    local talent = _G.C_Garrison.GetTalent(talentID)
    local toast = GetToast("misc")

	toast.Title:SetText(_G.GARRISON_TALENT_ORDER_ADVANCEMENT)
	toast.Text:SetText(talent.name)
	toast.Icon:SetTexture(talent.icon)
	toast.soundFile = "UI_OrderHall_Talent_Ready_Toast"

	SpawnToast(toast, CFG.dnd.garrison)
end

local function EnableGarrisonToasts()
	_G.AlertFrame:UnregisterEvent("GARRISON_BUILDING_ACTIVATABLE")
	_G.AlertFrame:UnregisterEvent("GARRISON_FOLLOWER_ADDED")
	_G.AlertFrame:UnregisterEvent("GARRISON_MISSION_FINISHED")
	_G.AlertFrame:UnregisterEvent("GARRISON_RANDOM_MISSION_ADDED")
	_G.AlertFrame:UnregisterEvent("GARRISON_TALENT_COMPLETE")

	if CFG.garrison_enabled then
		dispatcher:RegisterEvent("GARRISON_BUILDING_ACTIVATABLE")
		dispatcher:RegisterEvent("GARRISON_FOLLOWER_ADDED")
		dispatcher:RegisterEvent("GARRISON_MISSION_FINISHED")
		dispatcher:RegisterEvent("GARRISON_RANDOM_MISSION_ADDED")
		dispatcher:RegisterEvent("GARRISON_TALENT_COMPLETE")
	end
end

local function DisableGarrisonToasts()
	dispatcher:UnregisterEvent("GARRISON_BUILDING_ACTIVATABLE")
	dispatcher:UnregisterEvent("GARRISON_FOLLOWER_ADDED")
	dispatcher:UnregisterEvent("GARRISON_MISSION_FINISHED")
	dispatcher:UnregisterEvent("GARRISON_RANDOM_MISSION_ADDED")
	dispatcher:UnregisterEvent("GARRISON_TALENT_COMPLETE")
end

--------------
-- INSTANCE --
--------------

local function LFGToast_SetUp(isScenario)
	local toast = GetToast("scenario")
	local name, typeID, subtypeID, textureFilename, moneyBase, moneyVar, experienceBase, experienceVar, numStrangers, numRewards = _G.GetLFGCompletionReward()
	-- local name, typeID, subtypeID, textureFilename, moneyBase, moneyVar, experienceBase, experienceVar, numStrangers, numRewards =
		-- "The Vortex Pinnacle", 1, 2, "THEVORTEXPINNACLE", 308000, 0, 0, 0, 0, 0
	local money = moneyBase + moneyVar * numStrangers
	local xp = experienceBase + experienceVar * numStrangers
	local title = _G.DUNGEON_COMPLETED
	local usedRewards = 0

	if money > 0 then
		usedRewards = usedRewards + 1
		local reward = toast["Reward"..usedRewards]

		if reward then
			_G.SetPortraitToTexture(reward.Icon, "Interface\\Icons\\inv_misc_coin_02")
			reward.money = money
			reward:Show()
		end
	end

	if xp > 0 and _G.UnitLevel("player") < _G.MAX_PLAYER_LEVEL then
		usedRewards = usedRewards + 1
		local reward = toast["Reward"..usedRewards]

		if reward then
			_G.SetPortraitToTexture(reward.Icon, "Interface\\Icons\\xp_icon")
			reward.xp = xp
			reward:Show()
		end
	end

	for i = 1, numRewards do
		usedRewards = usedRewards + 1
		local reward = toast["Reward"..usedRewards]

		if reward then
			local icon = _G.GetLFGCompletionRewardItem(i)

			_G.SetPortraitToTexture(reward.Icon, icon)
			reward.rewardID = i
			reward:Show()

			usedRewards = i
		end
	end

	if isScenario then
		local _, _, _, _, hasBonusStep, isBonusStepComplete = _G.C_Scenario.GetInfo()

		if hasBonusStep and isBonusStepComplete then
			toast.Bonus:Show()
		end

		title = _G.SCENARIO_COMPLETED
	end

	if subtypeID == _G.LFG_SUBTYPEID_HEROIC then
		toast.Heroic:Show()
	end

	toast.Title:SetText(title)
	toast.Text:SetText(name)
	toast.BG:SetTexture("Interface\\AddOns\\ls_Toasts\\media\\toast-bg-dungeon")
	toast.Icon:SetTexture("Interface\\LFGFrame\\LFGIcon-"..textureFilename)
	toast.usedRewards = usedRewards

	if isScenario then
		toast.soundFile = "UI_Scenario_Ending"
	else
		toast.soundFile = "LFG_Rewards"
	end

	SpawnToast(toast, CFG.dnd.instance)
end

function dispatcher:LFG_COMPLETION_REWARD(...)
	if _G.C_Scenario.IsInScenario() and not _G.C_Scenario.TreatScenarioAsDungeon() then

		if select(10, _G.C_Scenario.GetInfo()) ~= _G.LE_SCENARIO_TYPE_LEGION_INVASION then
			LFGToast_SetUp(true)
		end
	else
		LFGToast_SetUp()
	end
end

local function EnableInstanceToasts()
	_G.AlertFrame:UnregisterEvent("LFG_COMPLETION_REWARD")

	if CFG.instance_enabled then
		dispatcher:RegisterEvent("LFG_COMPLETION_REWARD")
	end
end

local function DisableInstanceToasts()
	dispatcher:UnregisterEvent("LFG_COMPLETION_REWARD")
end

----------
-- LOOT --
----------

local function LootWonToast_Setup(itemLink, quantity, rollType, roll, showFaction, isItem, isCurrency, isMoney, lessAwesome, isUpgraded, isPersonal)
	local toast

	if isCurrency or isItem then
		if itemLink then
			toast = GetToast("item")
			local title = _G.YOU_WON_LABEL
			local name, icon, quality, _

			if isCurrency then
				name, _, icon, _, _, _, _, quality = _G.GetCurrencyInfo(itemLink)
			else
				name, _, quality, _, _, _, _, _, _, icon = _G.GetItemInfo(itemLink)
			end

			if isPersonal or lessAwesome or isCurrency then
				title = _G.YOU_RECEIVED_LABEL
			end

			if isUpgraded then
				title = _G.ITEM_UPGRADED_LABEL
				local upgradeTexture = _G.LOOTUPGRADEFRAME_QUALITY_TEXTURES[quality or 2]

				for i = 1, 5 do
					toast.Arrows["Arrow"..i]:SetAtlas(upgradeTexture.arrow, true)
				end

				toast.Arrows.requested = true

				toast.BG:SetTexture("Interface\\AddOns\\ls_Toasts\\media\\toast-bg-upgrade")
			end

			if rollType == _G.LOOT_ROLL_TYPE_NEED then
				title = title.." |cff00ff00"..roll.."|r"..INLINE_NEED
			elseif rollType == _G.LOOT_ROLL_TYPE_GREED then
				title = title.." |cff00ff00"..roll.."|r"..INLINE_GREED
			elseif rollType == _G.LOOT_ROLL_TYPE_DISENCHANT then
				title = title.." |cff00ff00"..roll.."|r"..INLINE_DE
			end

			if showFaction then
				-- local factionGroup = "Horde"
				local factionGroup = _G.UnitFactionGroup("player")

				toast.BG:SetTexture("Interface\\AddOns\\ls_Toasts\\media\\toast-bg-"..factionGroup)
			end

			local color = _G.ITEM_QUALITY_COLORS[quality or 1]

			toast.Title:SetText(title)
			toast.Text:SetText(name)
			toast.Count:SetText(quantity > 1 and quantity or "")
			toast.Border:SetVertexColor(color.r, color.g, color.b)
			toast.IconBorder:SetVertexColor(color.r, color.g, color.b)
			toast.Icon:SetTexture(icon)
			toast.link = itemLink

			if lessAwesome then
				toast.soundFile = 51402
			elseif isUpgraded then
				toast.soundFile = 51561
			else
				toast.soundFile = 31578
			end
		end
	elseif isMoney then
		toast = GetToast("misc")

		toast.Border:SetVertexColor(0.9, 0.75, 0.26)
		toast.IconBorder:SetVertexColor(0.9, 0.75, 0.26)
		toast.Title:SetText(_G.YOU_WON_LABEL)
		toast.Text:SetText(_G.GetMoneyString(quantity))
		toast.Icon:SetTexture("Interface\\Icons\\INV_Misc_Coin_02")
		toast.soundFile = 31578
	end

	SpawnToast(toast, CFG.dnd.loot)
end

local function BonusRollFrame_FinishedFading_Disabled(self)
	local frame = self:GetParent()

	_G.GroupLootContainer_RemoveFrame(_G.GroupLootContainer, frame)
end

local function BonusRollFrame_FinishedFading_Enabled(self)
	local frame = self:GetParent()

	LootWonToast_Setup(frame.rewardLink, frame.rewardQuantity, nil, nil, nil, frame.rewardType == "item" , nil, frame.rewardType == "money")
	_G.GroupLootContainer_RemoveFrame(_G.GroupLootContainer, frame)
end

function dispatcher:LOOT_ITEM_ROLL_WON(...)
	local itemLink, quantity, rollType, roll, isUpgraded = ...

	LootWonToast_Setup(itemLink, quantity, rollType, roll, nil, true, nil, nil, nil, isUpgraded)
end

function dispatcher:SHOW_LOOT_TOAST(...)
	local typeID, itemLink, quantity, specID, sex, isPersonal, lootSource, lessAwesome, isUpgraded = ...

	LootWonToast_Setup(itemLink, quantity, nil, nil, nil, typeID == "item", typeID == "currency", typeID == "money", lessAwesome, isUpgraded, isPersonal)
end

function dispatcher:SHOW_LOOT_TOAST_LEGENDARY_LOOTED(...)
	local itemLink = ...

	if itemLink then
		local toast = GetToast("item")
		local name, _, quality, _, _, _, _, _, _, icon = _G.GetItemInfo(itemLink)
		local color = _G.ITEM_QUALITY_COLORS[quality or 1]

		toast.Title:SetText(_G.LEGENDARY_ITEM_LOOT_LABEL)
		toast.Text:SetText(name)
		toast.BG:SetTexture("Interface\\AddOns\\ls_Toasts\\media\\toast-bg-legendary")
		toast.Border:SetVertexColor(color.r, color.g, color.b)
		toast.IconBorder:SetVertexColor(color.r, color.g, color.b)
		toast.Count:SetText("")
		toast.Icon:SetTexture(icon)
		toast.Dragon:Show()
		toast.link = itemLink

		SpawnToast(toast, CFG.dnd.loot)
	end
end

function dispatcher:SHOW_LOOT_TOAST_UPGRADE(...)
	local itemLink, quantity, specID, sex, baseQuality, isPersonal, lessAwesome = ...

	if itemLink then
		local toast = GetToast("item")
		local name, _, quality, _, _, _, _, _, _, icon = _G.GetItemInfo(itemLink)
		local upgradeTexture = _G.LOOTUPGRADEFRAME_QUALITY_TEXTURES[quality or 2]
		local color = _G.ITEM_QUALITY_COLORS[quality or 1]

		toast.Title:SetText(color.hex..strformat(_G.LOOTUPGRADEFRAME_TITLE, _G["ITEM_QUALITY"..quality.."_DESC"]).."|r")
		toast.Text:SetText(name)
		toast.Count:SetText(quantity > 1 and quantity or "")
		toast.BG:SetTexture("Interface\\AddOns\\ls_Toasts\\media\\toast-bg-upgrade")
		toast.Border:SetVertexColor(color.r, color.g, color.b)
		toast.IconBorder:SetVertexColor(color.r, color.g, color.b)
		toast.Icon:SetTexture(icon)
		toast.link = itemLink

		for i = 1, 5 do
			toast.Arrows["Arrow"..i]:SetAtlas(upgradeTexture.arrow, true)
		end

		toast.Arrows.requested = true

		SpawnToast(toast, CFG.dnd.loot)
	end
end

function dispatcher:SHOW_PVP_FACTION_LOOT_TOAST(...)
	local typeID, itemLink, quantity, specID, sex, isPersonal, lessAwesome = ...

	LootWonToast_Setup(itemLink, quantity, nil, nil, true, typeID == "item", typeID == "currency", typeID == "money", lessAwesome, nil, isPersonal)
end

function dispatcher:STORE_PRODUCT_DELIVERED(...)
	local type, icon, name, payloadID = ...
	local _, _, quality =  _G.GetItemInfo(payloadID)
	local color = _G.ITEM_QUALITY_COLORS[quality or 4]
	local toast = GetToast("item")

	toast.Title:SetText(_G.BLIZZARD_STORE_PURCHASE_COMPLETE)
	toast.Text:SetText(name)
	toast.BG:SetTexture("Interface\\AddOns\\ls_Toasts\\media\\toast-bg-store")
	toast.Border:SetVertexColor(color.r, color.g, color.b)
	toast.IconBorder:SetVertexColor(color.r, color.g, color.b)
	toast.Icon:SetTexture(icon)
	toast.id = payloadID

	SpawnToast(toast, CFG.dnd.loot)
end

local function EnableLootToasts()
	_G.AlertFrame:UnregisterEvent("LOOT_ITEM_ROLL_WON")
	_G.AlertFrame:UnregisterEvent("SHOW_LOOT_TOAST")
	_G.AlertFrame:UnregisterEvent("SHOW_LOOT_TOAST_LEGENDARY_LOOTED")
	_G.AlertFrame:UnregisterEvent("SHOW_LOOT_TOAST_UPGRADE")
	_G.AlertFrame:UnregisterEvent("SHOW_PVP_FACTION_LOOT_TOAST")
	_G.AlertFrame:UnregisterEvent("STORE_PRODUCT_DELIVERED")

	if CFG.loot_enabled then
		dispatcher:RegisterEvent("LOOT_ITEM_ROLL_WON")
		dispatcher:RegisterEvent("SHOW_LOOT_TOAST")
		dispatcher:RegisterEvent("SHOW_LOOT_TOAST_LEGENDARY_LOOTED")
		dispatcher:RegisterEvent("SHOW_LOOT_TOAST_UPGRADE")
		dispatcher:RegisterEvent("SHOW_PVP_FACTION_LOOT_TOAST")
		dispatcher:RegisterEvent("STORE_PRODUCT_DELIVERED")

		_G.BonusRollFrame.FinishRollAnim:SetScript("OnFinished", BonusRollFrame_FinishedFading_Enabled)
	else
		_G.BonusRollFrame.FinishRollAnim:SetScript("OnFinished", BonusRollFrame_FinishedFading_Disabled)
	end
end

local function DisableLootToasts()
	dispatcher:UnregisterEvent("LOOT_ITEM_ROLL_WON")
	dispatcher:UnregisterEvent("SHOW_LOOT_TOAST")
	dispatcher:UnregisterEvent("SHOW_LOOT_TOAST_LEGENDARY_LOOTED")
	dispatcher:UnregisterEvent("SHOW_LOOT_TOAST_UPGRADE")
	dispatcher:UnregisterEvent("SHOW_PVP_FACTION_LOOT_TOAST")
	dispatcher:UnregisterEvent("STORE_PRODUCT_DELIVERED")

	_G.BonusRollFrame.FinishRollAnim:SetScript("OnFinished", BonusRollFrame_FinishedFading_Disabled)
end

------------
-- RECIPE --
------------

function dispatcher:NEW_RECIPE_LEARNED(...)
	local recipeID = ...
	local tradeSkillID, skillLineName = _G.C_TradeSkillUI.GetTradeSkillLineForRecipe(recipeID)

	if tradeSkillID then
		local recipeName = _G.GetSpellInfo(recipeID)

		if recipeName then
			local toast = GetToast("ability")
			local rank = _G.GetSpellRank(recipeID)
			local rankTexture = ""

			if rank == 1 then
				rankTexture = "|TInterface\\LootFrame\\toast-star:12:12:0:0:32:32:0:21:0:21|t"
			elseif rank == 2 then
				rankTexture = "|TInterface\\LootFrame\\toast-star-2:12:24:0:0:64:32:0:42:0:21|t"
			elseif rank == 3 then
				rankTexture = "|TInterface\\LootFrame\\toast-star-3:12:36:0:0:64:32:0:64:0:21|t"
			end

			toast.Title:SetText(rank and rank > 1 and _G.UPGRADED_RECIPE_LEARNED_TITLE or _G.NEW_RECIPE_LEARNED_TITLE)
			toast.Text:SetText(recipeName)
			toast.BG:SetTexture("Interface\\AddOns\\ls_Toasts\\media\\toast-bg-recipe")
			toast.Rank:SetText(rankTexture)
			toast.Icon:SetTexture(_G.C_TradeSkillUI.GetTradeSkillTexture(tradeSkillID))
			toast.soundFile = "UI_Professions_NewRecipeLearned_Toast"
			toast.id = recipeID

			SpawnToast(toast, CFG.dnd.recipe)
		end
	end
end

local function EnableRecipeToasts()
	_G.AlertFrame:UnregisterEvent("NEW_RECIPE_LEARNED")

	if CFG.recipe_enabled then
		dispatcher:RegisterEvent("NEW_RECIPE_LEARNED")
	end
end

local function DisableRecipeToasts()
	dispatcher:UnregisterEvent("NEW_RECIPE_LEARNED")
end

-----------
-- WORLD --
-----------

local function InvasionToast_SetUp(questID)
	-- XXX: To avoid possible spam
	if GetToastToUpdate(questID, "scenario") then
		return
	end

	local toast = GetToast("scenario")
	local scenarioName, _, _, _, hasBonusStep, isBonusStepComplete, _, xp, money, _, areaName = _G.C_Scenario.GetInfo()
	-- local scenarioName, _, _, _, hasBonusStep, isBonusStepComplete, _, xp, money, _, areaName =
		-- "Invasion: Azshara", 0, 0, 0, false, false, true, 12345, 12345, 4, "Azshara"
	local usedRewards = 0

	if money > 0 then
		usedRewards = usedRewards + 1
		local reward = toast["Reward"..usedRewards]

		if reward then
			_G.SetPortraitToTexture(reward.Icon, "Interface\\Icons\\inv_misc_coin_02")
			reward.money = money
			reward:Show()
		end
	end

	if xp > 0 and _G.UnitLevel("player") < _G.MAX_PLAYER_LEVEL then
		usedRewards = usedRewards + 1
		local reward = toast["Reward"..usedRewards]

		if reward then
			_G.SetPortraitToTexture(reward.Icon, "Interface\\Icons\\xp_icon")
			reward.xp = xp
			reward:Show()
		end
	end

	if hasBonusStep and isBonusStepComplete then
		toast.Bonus:Show()
	end

	toast.Title:SetText(_G.SCENARIO_INVASION_COMPLETE)
	toast.Text:SetText(areaName or scenarioName)
	toast.BG:SetTexture("Interface\\AddOns\\ls_Toasts\\media\\toast-bg-legion")
	toast.Icon:SetTexture("Interface\\Icons\\Ability_Warlock_DemonicPower")
	toast.Border:SetVertexColor(60 / 255, 255 / 255, 38 / 255) -- fel green #3cff26
	toast.IconBorder:SetVertexColor(60 / 255, 255 / 255, 38 / 255) -- fel green #3cff26
	toast.usedRewards = usedRewards
	toast.soundFile = "UI_Scenario_Ending"
	toast.id = questID

	SpawnToast(toast, CFG.dnd.world)
end

local function WorldQuestToast_SetUp(questID)
	-- XXX: To avoid possible spam
	if GetToastToUpdate(questID, "scenario") then
		return
	end

	local toast = GetToast("scenario")
	local isInArea, isOnMap, numObjectives, taskName, displayAsObjective = _G.GetTaskInfo(questID)
	local tagID, tagName, worldQuestType, rarity, isElite, tradeskillLineIndex = _G.GetQuestTagInfo(questID)
	local color = _G.WORLD_QUEST_QUALITY_COLORS[rarity]
	local money = _G.GetQuestLogRewardMoney(questID)
	local xp = _G.GetQuestLogRewardXP(questID)
	local usedRewards = 0
	local icon = "Interface\\Icons\\Achievement_Quests_Completed_TwilightHighlands"

	if money > 0 then
		usedRewards = usedRewards + 1
		local reward = toast["Reward"..usedRewards]

		if reward then
			_G.SetPortraitToTexture(reward.Icon, "Interface\\Icons\\inv_misc_coin_02")
			reward.money = money
			reward:Show()
		end
	end

	if xp > 0 and _G.UnitLevel("player") < _G.MAX_PLAYER_LEVEL then
		usedRewards = usedRewards + 1
		local reward = toast["Reward"..usedRewards]

		if reward then
			_G.SetPortraitToTexture(reward.Icon, "Interface\\Icons\\xp_icon")
			reward.xp = xp
			reward:Show()
		end
	end

	for i = 1, _G.GetNumQuestLogRewardCurrencies(questID) do
		usedRewards = usedRewards + 1
		local reward = toast["Reward"..usedRewards]

		if reward then
			local _, texture = _G.GetQuestLogRewardCurrencyInfo(i, questID)

			_G.SetPortraitToTexture(reward.Icon, texture)
			reward.currency = i
			reward:Show()
		end
	end

	if worldQuestType == _G.LE_QUEST_TAG_TYPE_PVP then
		icon = "Interface\\Icons\\achievement_arena_2v2_1"
	elseif worldQuestType == _G.LE_QUEST_TAG_TYPE_PET_BATTLE then
		icon = "Interface\\Icons\\INV_Pet_BattlePetTraining"
	elseif worldQuestType == _G.LE_QUEST_TAG_TYPE_PROFESSION and tradeskillLineIndex then
		icon = _G.C_TradeSkillUI.GetTradeSkillTexture(select(7, _G.GetProfessionInfo(tradeskillLineIndex)))
	elseif worldQuestType == _G.LE_QUEST_TAG_TYPE_DUNGEON then
		icon = "Interface\\Icons\\INV_Misc_Bone_Skull_02"
	end

	toast.Title:SetText(_G.WORLD_QUEST_COMPLETE)
	toast.Text:SetText(taskName)
	toast.BG:SetTexture("Interface\\AddOns\\ls_Toasts\\media\\toast-bg-worldquest")
	toast.Icon:SetTexture(icon)
	toast.Border:SetVertexColor(color.r, color.g, color.b)
	toast.IconBorder:SetVertexColor(color.r, color.g, color.b)
	toast.usedRewards = usedRewards
	toast.id = questID

	toast.soundFile = "UI_WorldQuest_Complete"

	SpawnToast(toast, CFG.dnd.world)
end

function dispatcher:SCENARIO_COMPLETED(...)
	if select(10, _G.C_Scenario.GetInfo()) == _G.LE_SCENARIO_TYPE_LEGION_INVASION then
		local questID = ...

		if questID then
			InvasionToast_SetUp(questID)
		end
	end
end

function dispatcher:QUEST_TURNED_IN(...)
	local questID = ...

	if _G.QuestMapFrame_IsQuestWorldQuest(questID) then
		WorldQuestToast_SetUp(questID)
	end
end

function dispatcher:QUEST_LOOT_RECEIVED(...)
	local questID, itemLink = ...

	--- XXX: QUEST_LOOT_RECEIVED may fire before QUEST_TURNED_IN
	if _G.QuestMapFrame_IsQuestWorldQuest(questID) then
		if not GetToastToUpdate(questID, "scenario") then
			WorldQuestToast_SetUp(questID)
		end
	end

	UpdateToast(questID, "scenario", itemLink)
end

local function EnableWorldToasts()
	_G.AlertFrame:UnregisterEvent("SCENARIO_COMPLETED")
	_G.AlertFrame:UnregisterEvent("QUEST_LOOT_RECEIVED")
	_G.AlertFrame:UnregisterEvent("QUEST_TURNED_IN")

	if CFG.world_enabled then
		dispatcher:RegisterEvent("SCENARIO_COMPLETED")
		dispatcher:RegisterEvent("QUEST_TURNED_IN")
		dispatcher:RegisterEvent("QUEST_LOOT_RECEIVED")
	end
end

local function DisableWorldToasts()
	dispatcher:UnregisterEvent("SCENARIO_COMPLETED")
	dispatcher:UnregisterEvent("QUEST_TURNED_IN")
	dispatcher:UnregisterEvent("QUEST_LOOT_RECEIVED")
end

-----------
-- TESTS --
-----------

local function SpawnTestGarrisonToast()
	-- follower
	local followers = _G.C_Garrison.GetFollowers(1)
	local follower = followers and followers[1]

	if follower then
		dispatcher:GARRISON_FOLLOWER_ADDED(follower.followerID, follower.name, follower.className, follower.level, follower.quality, false, nil, follower.followerTypeID)
	end

	-- ship
	followers = _G.C_Garrison.GetFollowers(2)
	follower = followers and followers[1]

	if follower then
		dispatcher:GARRISON_FOLLOWER_ADDED(follower.followerID, follower.name, follower.className, follower.level, follower.quality, false, follower.texPrefix, follower.followerTypeID)
	end

	-- champion
	followers = _G.C_Garrison.GetFollowers(4)
	follower = followers and followers[1]

	if follower then
		dispatcher:GARRISON_FOLLOWER_ADDED(follower.followerID, follower.name, follower.className, follower.level, follower.quality, false, nil, follower.followerTypeID)
	end

	-- garrison mission
	local missions = _G.C_Garrison.GetAvailableMissions(1)
	local id = missions and (missions[1] and missions[1].missionID or nil) or nil

	if id then
		dispatcher:GARRISON_MISSION_FINISHED(1, id)
	end

	-- shipyard mission
	missions = _G.C_Garrison.GetAvailableMissions(2)
	id = missions and (missions[1] and missions[1].missionID or nil) or nil

	if id then
		dispatcher:GARRISON_MISSION_FINISHED(2, id)
	end

	-- order hall mission
	missions = _G.C_Garrison.GetAvailableMissions(4)
	id = missions and (missions[1] and missions[1].missionID or nil) or nil

	if id then
		dispatcher:GARRISON_MISSION_FINISHED(4, id)
	end

	-- garrison building
	dispatcher:GARRISON_BUILDING_ACTIVATABLE("Storehouse")
end

local function SpawnTestAchievementToast()
	-- new
	dispatcher:ACHIEVEMENT_EARNED(545, false)

	-- already earned
	dispatcher:ACHIEVEMENT_EARNED(9828, true)
end

local function SpawnTestRecipeToast()
	dispatcher:NEW_RECIPE_LEARNED(7183)
end

local function SpawnTestArchaeologyToast()
	dispatcher:ARTIFACT_DIGSITE_COMPLETE(408)
end

local function SpawnTestStoreToast()
	dispatcher:STORE_PRODUCT_DELIVERED(1, 915544, "Pouch of Enduring Wisdom", 105911)
end

local function SpawnTestWorldEventToast()
	-- invasion in Azshara
	local _, link = _G.GetItemInfo(139049)

	if link then
		InvasionToast_SetUp(43301)
		UpdateToast(43301, "scenario", link)
	end

	-- world quests, have to be in zone to get info
	local mapAreaID = _G.GetCurrentMapAreaID();
	local taskInfo = _G.C_TaskQuest.GetQuestsForPlayerByMapID(mapAreaID)

	for i, info in pairs(taskInfo) do
		local questID = info.questId

		if _G.QuestMapFrame_IsQuestWorldQuest(questID) and _G.HaveQuestData(questID) then
			local numRewards = _G.GetNumQuestLogRewards(questID)

			if numRewards > 0 then
				for i = 1, numRewards do
					local itemName, itemTexture, quantity, quality, isUsable, itemID = _G.GetQuestLogRewardInfo(i, questID)

					if itemID then
						local _, itemLink = _G.GetItemInfo(itemID)

						if itemLink then
							dispatcher:QUEST_LOOT_RECEIVED(questID, itemLink)

							return
						end
					end
				end
			end
		end
	end
end

local function SpawnTestLootToast()
	-- currency
	local link, _ = _G.GetCurrencyLink(824)

	if link then
		dispatcher:SHOW_LOOT_TOAST("currency", link, 500, 0, 2, true, 10, false, false)
	end

	-- money
	dispatcher:SHOW_LOOT_TOAST("money", nil, 12345678, 0, 2, false, 0, false, false)

	-- legendary
	_, link = _G.GetItemInfo(132452)

	if link then
		dispatcher:SHOW_LOOT_TOAST_LEGENDARY_LOOTED(link)
	end

	_, link = _G.GetItemInfo(140715)

	-- faction
	if link then
		dispatcher:SHOW_PVP_FACTION_LOOT_TOAST("item", link, 1)
	end

	-- roll won
	if link then
		dispatcher:LOOT_ITEM_ROLL_WON(link, 1, 1, 58, false)
	end

	_, link = _G.GetItemInfo("|cffa335ee|Hitem:121641::::::::110:70:512:11:2:664:1737:108:::|h[Radiant Charm of Elune]|h|r")

	-- upgrade
	if link then
		dispatcher:SHOW_LOOT_TOAST_UPGRADE(link, 1)
	end
end

-----------
-- DEBUG --
-----------

-- local function SpawnTestToast()
-- 	if not _G.DevTools_Dump then
-- 		_G.UIParentLoadAddOn("Blizzard_DebugTools")
-- 	end

-- 	SpawnTestGarrisonToast()

-- 	SpawnTestAchievementToast()

-- 	SpawnTestRecipeToast()

-- 	SpawnTestArchaeologyToast()

-- 	SpawnTestStoreToast()

-- 	SpawnTestLootToast()

-- 	SpawnTestWorldEventToast()
-- end

-- _G.SLASH_LSADDTOAST1 = "/lstoasttest"
-- _G.SlashCmdList["LSADDTOAST"] = SpawnTestToast

--------------------
-- IN-GAME CONFIG --
--------------------

local function CopyTable(src, dest)
	if type(dest) ~= "table" then
		dest = {}
	end

	for k, v in pairs(src) do
		if type(v) == "table" then
			dest[k] = CopyTable(v, dest[k])
		elseif type(v) ~= type(dest[k]) then
			dest[k] = v
		end
	end

	return dest
end

local function DiffTable(src , dest)
	if type(dest) ~= "table" then
		return {}
	end

	if type(src) ~= "table" then
		return dest
	end

	for k, v in pairs(dest) do
		if type(v) == "table" then
			if not next(DiffTable(src[k], v)) then
				dest[k] = nil
			end
		elseif v == src[k] then
			dest[k] = nil
		end
	end

	return dest
end

local function SetConfigValue(valuePath, value)
	local temp = {strsplit(".", valuePath)}
	local t = CFG

	if #temp > 0 then
		for i = 1, #temp - 1 do
			t = t[temp[i]]
		end

		t[temp[#temp]] = value
	end
end

local function GetConfigValue(valuePath)
	local temp = {strsplit(".", valuePath)}
	local t = CFG

	if #temp > 0 then
		for i = 1, #temp do
			t = t[temp[i]]
		end

		return t
	end
end

local function RegisterControlForRefresh(parent, control)
	if not parent or not control then
		return
	end

	parent.controls = parent.controls or {}
	tinsert(parent.controls, control)
end

local function OptionsPanelRefresh(panel)
	for _, control in pairs(panel.controls) do
		if control.RefreshValue then
			control:RefreshValue()
		end
	end
end

local function AnchorFrame_Toggle()
	if anchorFrame:IsMouseEnabled() then
		Anchor_Disable()
	else
		Anchor_Enable()
	end
end

local function ToggleToasts(value, state)
	if value == "achievement_enabled" then
		if state then
			EnableAchievementToasts()
		else
			DisableAchievementToasts()
		end
	elseif value == "archaeology_enabled" then
		if state then
			EnableArchaeologyToasts()
		else
			DisableArchaeologyToasts()
		end
	elseif value == "garrison_enabled" then
		if state then
			EnableGarrisonToasts()
		else
			DisableGarrisonToasts()
		end
	elseif value == "instance_enabled" then
		if state then
			EnableInstanceToasts()
		else
			DisableInstanceToasts()
		end
	elseif value == "loot_enabled" then
		if state then
			EnableLootToasts()
		else
			DisableLootToasts()
		end
	elseif value == "recipe_enabled" then
		if state then
			EnableRecipeToasts()
		else
			DisableRecipeToasts()
		end
	elseif value == "world_enabled" then
		if state then
			EnableWorldToasts()
		else
			DisableWorldToasts()
		end
	end
end

local function UpdateFadeOutDelay(delay)
	for _, toast in pairs(queuedToasts) do
		toast.AnimOut.Anim1:SetStartDelay(delay)
	end

	for i = 1, #activeToasts do
		RecycleToast(activeToasts[1])
	end

	for _, toast in pairs(abilityToasts) do
		toast.AnimOut.Anim1:SetStartDelay(delay)
	end

	for _, toast in pairs(achievementToasts) do
		toast.AnimOut.Anim1:SetStartDelay(delay)
	end

	for _, toast in pairs(followerToasts) do
		toast.AnimOut.Anim1:SetStartDelay(delay)
	end

	for _, toast in pairs(itemToasts) do
		toast.AnimOut.Anim1:SetStartDelay(delay)
	end

	for _, toast in pairs(miscToasts) do
		toast.AnimOut.Anim1:SetStartDelay(delay)
	end

	for _, toast in pairs(missonToasts) do
		toast.AnimOut.Anim1:SetStartDelay(delay)
	end

	for _, toast in pairs(scenarioToasts) do
		toast.AnimOut.Anim1:SetStartDelay(delay)
	end
end

local function UpdateScale(scale)
	for _, toast in pairs(queuedToasts) do
		toast:SetScale(scale)
	end

	anchorFrame:SetScale(CFG.scale)

	for i = 1, #activeToasts do
		RecycleToast(activeToasts[1])
	end

	for _, toast in pairs(abilityToasts) do
		toast:SetScale(scale)
	end

	for _, toast in pairs(achievementToasts) do
		toast:SetScale(scale)
	end

	for _, toast in pairs(followerToasts) do
		toast:SetScale(scale)
	end

	for _, toast in pairs(itemToasts) do
		toast:SetScale(scale)
	end

	for _, toast in pairs(miscToasts) do
		toast:SetScale(scale)
	end

	for _, toast in pairs(missonToasts) do
		toast:SetScale(scale)
	end

	for _, toast in pairs(scenarioToasts) do
		toast:SetScale(scale)
	end
end

------

local function CheckButton_SetValue(self, value)
	self:SetChecked(value)
	SetConfigValue(self.watchedValue, value)
end

local function CheckButton_RefreshValue(self)
	self:SetChecked(GetConfigValue(self.watchedValue))
end

local function CheckButton_OnClick(self)
	self:SetValue(self:GetChecked())
end

local function CheckButton_OnEnter(self)
	_G.GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	_G.GameTooltip:SetText(self.tooltipText, nil, nil, nil, nil, true)
	_G.GameTooltip:Show()
end

local function CheckButton_OnLeave(self)
	_G.GameTooltip:Hide()
end

local function CreateConfigCheckButton(parent, name, text, tooltiptext)
	local object = _G.CreateFrame("CheckButton", "$parent"..name, parent, "InterfaceOptionsCheckButtonTemplate")
	object:SetHitRectInsets(0, 0, 0, 0)
	object.type = "Button"
	object.SetValue = CheckButton_SetValue
	object.RefreshValue = CheckButton_RefreshValue
	object:SetScript("OnClick", CheckButton_OnClick)
	object.Text:SetText(text)

	if tooltiptext then
		object.tooltipText = tooltiptext
		object:SetScript("OnEnter", CheckButton_OnEnter)
		object:SetScript("OnLeave", CheckButton_OnLeave)
	end

	RegisterControlForRefresh(parent, object)

	return object
end

------

local function CreateConfigButton(parent, name, text, func)
	local object = _G.CreateFrame("Button", "$parent"..name, parent, "UIPanelButtonTemplate")
	object.type = "Button"
	object:SetText(text)
	object:SetWidth(object:GetTextWidth() + 18)
	object:SetScript("OnClick", func)

	return object
end

------

local function DropDownMenu_SetValue(self, value)
	self.value = value
	_G.UIDropDownMenu_SetSelectedValue(self, value)
	SetConfigValue(self.watchedValue, value)
end

local function DropDownMenu_RefreshValue(self)
	_G.UIDropDownMenu_Initialize(self, self.initialize)
	self.value = GetConfigValue(self.watchedValue)
	_G.UIDropDownMenu_SetSelectedValue(self, self.value)
end

local function CreateConfigDropDown(parent, name, text, func)
	local object = _G.CreateFrame("Frame", "$parent"..name, parent, "UIDropDownMenuTemplate")
	object.type = "DropDownMenu"
	object.SetValue = DropDownMenu_SetValue
	object.RefreshValue = DropDownMenu_RefreshValue
	_G.UIDropDownMenu_Initialize(object, func)

	local label = object:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	label:SetPoint("BOTTOMLEFT", object, "TOPLEFT", 16, 3)
	label:SetJustifyH("LEFT")
	label:SetText(text)
	object.Text = label

	RegisterControlForRefresh(parent, object)

	return object
end

------

local function Slider_SetValue(self, value)
	self.value = value
	self:SetDisplayValue(value)
	self.CurrentValue:SetText(value)
	SetConfigValue(self.watchedValue, value)
end

local function Slider_RefreshValue(self)
	self:SetDisplayValue(GetConfigValue(self.watchedValue))
	self.CurrentValue:SetText(GetConfigValue(self.watchedValue))
end

local function Slider_OnValueChanged(self, value, userInput)
	if userInput then
		value = tonumber(strformat("%.1f", value))

		if value ~= GetConfigValue(self.watchedValue) then
			self:SetValue(value)
		end
	end
end

local function CreateConfigSlider(parent, name, text, stepValue, minValue, maxValue)
	local object = _G.CreateFrame("Slider", "$parent"..name, parent, "OptionsSliderTemplate")
	object:SetMinMaxValues(minValue, maxValue)
	object:SetValueStep(stepValue)
	object:SetObeyStepOnDrag(true)
	object.SetDisplayValue = object.SetValue -- default
	object.SetValue = Slider_SetValue
	object.RefreshValue = Slider_RefreshValue
	object:SetScript("OnValueChanged", Slider_OnValueChanged)

	local label = _G[object:GetName().."Text"]
	label:SetText(text)
	label:SetVertexColor(1, 0.82, 0)
	object.Text = label

	local lowText = _G[object:GetName().."Low"]
	lowText:SetText(minValue)
	object.LowValue = lowText

	local curText = object:CreateFontString("$parentCurrent", "ARTWORK", "GameFontHighlightSmall")
	curText:SetPoint("TOP", object, "BOTTOM", 0, 3)
	object.CurrentValue = curText

	local highText = _G[object:GetName().."High"]
	highText:SetText(maxValue)
	object.HighValue = highText

	RegisterControlForRefresh(parent, object)

	return object
end

------

local function CreateConfigDivider(parent, text)
	local object = parent:CreateTexture(nil, "ARTWORK")
	object:SetHeight(4)
	object:SetPoint("LEFT", 10, 0)
	object:SetPoint("RIGHT", -10, 0)
	object:SetTexture("Interface\\AchievementFrame\\UI-Achievement-RecentHeader")
	object:SetTexCoord(0, 1, 0.0625, 0.65625)
	object:SetAlpha(0.5)

	local label = parent:CreateFontString(nil, "ARTWORK", "GameFontNormalMed2")
	label:SetWordWrap(false)
	label:SetPoint("LEFT", object, "LEFT", 12, 1)
	label:SetPoint("RIGHT", object, "RIGHT", -12, 1)
	label:SetText(text)
	object.Text = label

	return object
end

------

local function CheckButton_OnClickHook(self)
	ToggleToasts(self.watchedValue, self:GetChecked())
end

local function CreateToastConfigLine(parent, cfg)
	local name = parent:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
	name:SetPoint(unpack(cfg.point))
	name:SetWidth(234)
	name:SetJustifyH("LEFT")
	name:SetText(cfg.name)

	local enabledCB = CreateConfigCheckButton(parent, cfg.name.."Toggle")
	enabledCB:SetPoint("LEFT", name, "RIGHT", 44, 0)
	enabledCB:HookScript("OnClick", CheckButton_OnClickHook)
	enabledCB.watchedValue = cfg.enabled

	RegisterControlForRefresh(parent:GetParent(), enabledCB)

	local dndCB = CreateConfigCheckButton(parent, cfg.name.."DNDToggle", nil, "Toasts in DND mode won't be displayed in combat, but will be queued up in the system instead. Once you leave combat, they'll start popping up.")
	dndCB:SetPoint("LEFT", enabledCB, "RIGHT", 32, 0)
	dndCB.watchedValue = cfg.dnd

	RegisterControlForRefresh(parent:GetParent(), dndCB)

	if cfg.testFunc then
		local testB = CreateConfigButton(parent, cfg.name.."TestButton", "Test", cfg.testFunc)
		testB:SetPoint("LEFT", dndCB, "RIGHT", 32, 0)
	end
end

------

local function GrowthDirectionDropDownMenu_OnClick(self)
	self.owner:SetValue(self.value)
end

local function GrowthDirectionDropDownMenu_Initialize(self, ...)
	local info = _G.UIDropDownMenu_CreateInfo()

	info.text = "Up"
	info.func = GrowthDirectionDropDownMenu_OnClick
	info.value = "UP"
	info.owner = self
	info.checked = nil
	_G.UIDropDownMenu_AddButton(info)

	info.text = "Down"
	info.func = GrowthDirectionDropDownMenu_OnClick
	info.value = "DOWN"
	info.owner = self
	info.checked = nil
	_G.UIDropDownMenu_AddButton(info)
end

------

local function DelaySlider_OnValueChanged(self, value, userInput)
	if userInput then
		value = tonumber(strformat("%.1f", value))

		if value ~= GetConfigValue(self.watchedValue) then
			self:SetValue(value)

			UpdateFadeOutDelay(value)
		end
	end
end

------

local function ScaleSlider_OnValueChanged(self, value, userInput)
	if userInput then
		value = tonumber(strformat("%.1f", value))

		if value ~= GetConfigValue(self.watchedValue) then
			self:SetValue(value)

			UpdateScale(value)
		end
	end
end

------

local function SaveDefaultTemplate()
	if _G.LS_TOASTS_CFG_GLOBAL["Default"] then
		twipe(_G.LS_TOASTS_CFG_GLOBAL["Default"])
	else
		_G.LS_TOASTS_CFG_GLOBAL["Default"] = {}
	end

	CopyTable(CFG, _G.LS_TOASTS_CFG_GLOBAL["Default"])
end

------

local function CreateConfigPanel()
	local panel = _G.CreateFrame("Frame", "LSToastsConfigPanel", _G.InterfaceOptionsFramePanelContainer)
	panel.name = "|cff1a9fc0ls:|r Toasts"
	panel:Hide()

	local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
	title:SetPoint("TOPLEFT", 16, -16)
	title:SetJustifyH("LEFT")
	title:SetJustifyV("TOP")
	title:SetText(_G.GENERAL_LABEL)

	local subtext = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	subtext:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
	subtext:SetPoint("RIGHT", -16, 0)
	subtext:SetHeight(32)
	subtext:SetJustifyH("LEFT")
	subtext:SetJustifyV("TOP")
	subtext:SetNonSpaceWrap(true)
	subtext:SetMaxLines(3)
	subtext:SetText("Thome thettings, duh... |cffffd200They are saved per character.|r")

	local acnhorButton = CreateConfigButton(panel, "AnchorToggle", "Anchor Frame", AnchorFrame_Toggle)
	acnhorButton:SetPoint("TOPLEFT", subtext, "BOTTOMLEFT", 0, -8)

	local soundToggle = CreateConfigCheckButton(panel, "SFXToggle", _G.ENABLE_SOUND)
	soundToggle:SetPoint("LEFT", acnhorButton, "RIGHT", 32, 0)
	soundToggle.watchedValue = "sfx_enabled"

	local divider = CreateConfigDivider(panel, "Appearance")
	divider:SetPoint("TOP", soundToggle, "BOTTOM", 0, -10)

	local numSlider = CreateConfigSlider(panel, "NumSlider", "Number of Toasts", 1, 1, 20)
	numSlider:SetPoint("TOPLEFT", divider, "BOTTOMLEFT", 16, -24)
	numSlider.watchedValue = "max_active_toasts"

	local delaySlider = CreateConfigSlider(panel, "FadeOutSlider", "Fade Out Delay", 0.4, 0.8, 6.0)
	delaySlider:SetPoint("LEFT", numSlider, "RIGHT", 69, 0)
	delaySlider:SetScript("OnValueChanged", DelaySlider_OnValueChanged)
	delaySlider.watchedValue = "fadeout_delay"

	local scaleSlider = CreateConfigSlider(panel, "ScaleSlider", "Scale", 0.1, 0.75, 2)
	scaleSlider:SetPoint("LEFT", delaySlider, "RIGHT", 69, 0)
	scaleSlider:SetScript("OnValueChanged", ScaleSlider_OnValueChanged)
	scaleSlider.watchedValue = "scale"

	local growthDropdown = CreateConfigDropDown(panel, "DirectionDropDown", "Growth Direction", GrowthDirectionDropDownMenu_Initialize)
	growthDropdown:SetPoint("TOPLEFT", numSlider, "BOTTOMLEFT", -13, -32)
	growthDropdown.watchedValue = "growth_direction"

	divider = CreateConfigDivider(panel, "Toasts")
	divider:SetPoint("TOP", growthDropdown, "BOTTOM", 0, -10)

	local toastSettings = _G.CreateFrame("Frame", "$parentToastSettings", panel)
	toastSettings:SetPoint("TOPLEFT", divider, "BOTTOMLEFT", 6, -32)
	toastSettings:SetSize(441, 167)

	local bg = toastSettings:CreateTexture(nil, "BACKGROUND")
	bg:SetAllPoints()
	bg:SetColorTexture(0.3, 0.3, 0.3, 0.3)

	title = toastSettings:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	title:SetPoint("BOTTOMLEFT", toastSettings, "TOPLEFT", 0, 4)
	title:SetText("Type")

	title = toastSettings:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	title:SetPoint("BOTTOMLEFT", toastSettings, "TOPLEFT", 272, 4)
	title:SetText("Enable")

	title = toastSettings:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	title:SetPoint("BOTTOMLEFT", toastSettings, "TOPLEFT", 336, 4)
	title:SetText("DND")

	local layout = {
		[1] = {name = "Achievement", point = {"TOPLEFT", toastSettings, "TOPLEFT", 2, -5}, enabled = "achievement_enabled", dnd = "dnd.achievement", testFunc = SpawnTestAchievementToast},
		[2] = {name = "Archaeology", point = {"TOPLEFT", toastSettings, "TOPLEFT", 2, -29}, enabled = "archaeology_enabled", dnd = "dnd.archaeology", testFunc = SpawnTestArchaeologyToast},
		[3] = {name = "Garrison", point = {"TOPLEFT", toastSettings, "TOPLEFT", 2, -53}, enabled = "garrison_enabled", dnd = "dnd.garrison", testFunc = SpawnTestGarrisonToast},
		[4] = {name = "Dungeon", point = {"TOPLEFT", toastSettings, "TOPLEFT", 2, -77}, enabled = "instance_enabled", dnd = "dnd.instance"},
		[5] = {name = "Loot", point = {"TOPLEFT", toastSettings, "TOPLEFT", 2, -101}, enabled = "loot_enabled", dnd = "dnd.loot", testFunc = SpawnTestLootToast},
		[6] = {name = "Recipe", point = {"TOPLEFT", toastSettings, "TOPLEFT", 2, -125}, enabled = "recipe_enabled", dnd = "dnd.recipe", testFunc = SpawnTestRecipeToast},
		[7] = {name = "World Quest", point = {"TOPLEFT", toastSettings, "TOPLEFT", 2, -149}, enabled = "world_enabled", dnd = "dnd.world", testFunc = SpawnTestWorldEventToast},
	}

	for i = 1, 7 do
		CreateToastConfigLine(toastSettings, layout[i])
	end

	divider = CreateConfigDivider(panel, "Settings Transfer")
	divider:SetPoint("TOP", toastSettings, "BOTTOM", 0, -10)

	subtext = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	subtext:SetPoint("TOPLEFT", divider, "BOTTOMLEFT", 6, -8)
	subtext:SetPoint("RIGHT", -16, 0)
	subtext:SetHeight(44)
	subtext:SetJustifyH("LEFT")
	subtext:SetJustifyV("TOP")
	subtext:SetNonSpaceWrap(true)
	subtext:SetMaxLines(4)
	subtext:SetText("|cffff2020Experimental!|r To save current settings as a default preset click the button below. This feature may be quite handy, if you use more or less same layout on many characters. This way you'll need to tweak fewer things. |cffffd200Please note that there can be only 1 preset. Hitting this button on a different character will overwrite existing template.|r")

	local saveDefaults = CreateConfigButton(panel, "SaveDefaultsButton", "Save Settings", SaveDefaultTemplate)
	saveDefaults:SetPoint("TOPLEFT", subtext, "BOTTOMLEFT", 0, -8)

	panel.okay = function() end
	panel.cancel = function() end
	panel.refresh = OptionsPanelRefresh
	panel.default = function() end

	_G.InterfaceOptions_AddCategory(panel)
end

-------------
-- LOADING --
-------------

function dispatcher:ADDON_LOADED(arg)
	if arg ~= "ls_Toasts" then return end

	if not _G.LS_TOASTS_CFG_GLOBAL then
		_G.LS_TOASTS_CFG_GLOBAL = {}
	end

	if _G.LS_TOASTS_CFG_GLOBAL["Default"] then
		CopyTable(DEFAULTS, _G.LS_TOASTS_CFG_GLOBAL["Default"])

		CFG = CopyTable(_G.LS_TOASTS_CFG_GLOBAL["Default"], _G.LS_TOASTS_CFG)
	else
		CFG = CopyTable(DEFAULTS, _G.LS_TOASTS_CFG)
	end

	dispatcher:RegisterEvent("PLAYER_LOGIN")
	dispatcher:RegisterEvent("PLAYER_LOGOUT")
	dispatcher:UnregisterEvent("ADDON_LOADED")
end

function dispatcher:PLAYER_LOGIN()
	anchorFrame:SetPoint(unpack(CFG.point))
	anchorFrame:SetScale(CFG.scale)

	EnableAchievementToasts()
	EnableArchaeologyToasts()
	EnableGarrisonToasts()
	EnableInstanceToasts()
	EnableLootToasts()
	EnableRecipeToasts()
	EnableWorldToasts()
	CreateConfigPanel()
end

function dispatcher:PLAYER_LOGOUT()
	if _G.LS_TOASTS_CFG_GLOBAL["Default"] then
		_G.LS_TOASTS_CFG = DiffTable(_G.LS_TOASTS_CFG_GLOBAL["Default"], CFG)
	else
		_G.LS_TOASTS_CFG = DiffTable(DEFAULTS, CFG)
	end
end

dispatcher:RegisterEvent("ADDON_LOADED")
