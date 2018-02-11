local _, addonTable = ...
local E, C = addonTable.E, addonTable.C

-- Lua
local _G = getfenv(0)
local m_ceil = _G.math.ceil
local m_floor = _G.math.floor
local next = _G.next
local t_insert = _G.table.insert
local t_remove = _G.table.remove
local t_wipe = _G.table.wipe

-- Blizz
local Lerp = _G.Lerp

-- Mine
local activeToasts = {}
local createdToasts = {}
local queuedToasts = {}
local toasts = {}

local ARROWS_CFG = {
	[1] = {delay = 0,	x = 0},
	[2] = {delay = 0.1,	x = -8},
	[3] = {delay = 0.2,	x = 16},
	[4] = {delay = 0.3,	x = 8},
	[5] = {delay = 0.4,	x = -16},
}

-- Border
local sections = {"TOPLEFT", "TOPRIGHT", "BOTTOMLEFT", "BOTTOMRIGHT", "TOP", "BOTTOM", "LEFT", "RIGHT"}

local function border_SetOffset(self, offset)
	self.offset = offset
	self.TOPLEFT:SetPoint("BOTTOMRIGHT", self.parent, "TOPLEFT", -offset, offset)
	self.TOPRIGHT:SetPoint("BOTTOMLEFT", self.parent, "TOPRIGHT", offset, offset)
	self.BOTTOMLEFT:SetPoint("TOPRIGHT", self.parent, "BOTTOMLEFT", -offset, -offset)
	self.BOTTOMRIGHT:SetPoint("TOPLEFT", self.parent, "BOTTOMRIGHT", offset, -offset)
end

local function border_SetTexture(self, texture)
	self.calcTile = true

	for i, v in next, sections do
		if i > 4 then
			self[v]:SetTexture(texture, "REPEAT", "REPEAT")
		else
			self[v]:SetTexture(texture)
		end
	end
end

local function border_SetColorTexture(self, r, g, b, a)
	self.calcTile = false

	for _, v in next, sections do
		self[v]:SetColorTexture(r, g, b, a)
	end
end

local function border_SetSize(self, size)
	if size < 1 then
		size = 1
	end

	self.size = size
	self.TOPLEFT:SetSize(size, size)
	self.TOPRIGHT:SetSize(size, size)
	self.BOTTOMLEFT:SetSize(size, size)
	self.BOTTOMRIGHT:SetSize(size, size)
	self.TOP:SetHeight(size)
	self.BOTTOM:SetHeight(size)
	self.LEFT:SetWidth(size)
	self.RIGHT:SetWidth(size)

	if self.calcTile then
		local tile = (self.parent:GetWidth() + 2 * self.offset) / size
		self.TOP:SetTexCoord(0.25, tile, 0.375, tile, 0.25, 0, 0.375, 0)
		self.BOTTOM:SetTexCoord(0.375, tile, 0.5, tile, 0.375, 0, 0.5, 0)
		self.LEFT:SetTexCoord(0, 0.125, 0, tile)
		self.RIGHT:SetTexCoord(0.125, 0.25, 0, tile)
	end
end

local function border_Hide(self)
	for _, v in next, sections do
		self[v]:Hide()
	end
end

local function border_Show(self)
	for _, v in next, sections do
		self[v]:Show()
	end
end

local function border_SetVertexColor(self, r, g, b, a)
	for _, v in next, sections do
		self[v]:SetVertexColor(r, g, b, a)
	end
end

local function createBorder(self, drawLayer, drawSubLevel)
	local border = {
		calcTile = true,
		offset = 0,
		parent = self,
		size = 1,
	}

	for _, v in next, sections do
		border[v] = self:CreateTexture(nil, drawLayer or "OVERLAY", nil, drawSubLevel or 1)
	end

	border.TOPLEFT:SetTexCoord(0.5, 0.625, 0, 1)
	border.TOPRIGHT:SetTexCoord(0.625, 0.75, 0, 1)
	border.BOTTOMLEFT:SetTexCoord(0.75, 0.875, 0, 1)
	border.BOTTOMRIGHT:SetTexCoord(0.875, 1, 0, 1)

	border.TOP:SetPoint("TOPLEFT", border.TOPLEFT, "TOPRIGHT", 0, 0)
	border.TOP:SetPoint("TOPRIGHT", border.TOPRIGHT, "TOPLEFT", 0, 0)

	border.BOTTOM:SetPoint("BOTTOMLEFT", border.BOTTOMLEFT, "BOTTOMRIGHT", 0, 0)
	border.BOTTOM:SetPoint("BOTTOMRIGHT", border.BOTTOMRIGHT, "BOTTOMLEFT", 0, 0)

	border.LEFT:SetPoint("TOPLEFT", border.TOPLEFT, "BOTTOMLEFT", 0, 0)
	border.LEFT:SetPoint("BOTTOMLEFT", border.BOTTOMLEFT, "TOPLEFT", 0, 0)

	border.RIGHT:SetPoint("TOPRIGHT", border.TOPRIGHT, "BOTTOMRIGHT", 0, 0)
	border.RIGHT:SetPoint("BOTTOMRIGHT", border.BOTTOMRIGHT, "TOPRIGHT", 0, 0)

	border.Hide = border_Hide
	border.SetColorTexture = border_SetColorTexture
	border.SetOffset = border_SetOffset
	border.SetSize = border_SetSize
	border.SetTexture = border_SetTexture
	border.SetVertexColor = border_SetVertexColor
	border.Show = border_Show

	return border
end

-- Animated Text
local textsToAnimate = {}

C_Timer.NewTicker(0.05, function()
	for text, targetValue in next, textsToAnimate do
		local newValue

		text._elapsed = text._elapsed + 0.05

		if text._value >= targetValue then
			newValue = m_floor(Lerp(text._value, targetValue, text._elapsed / 0.6))
		else
			newValue = m_ceil(Lerp(text._value, targetValue, text._elapsed / 0.6))
		end

		if newValue == targetValue then
			textsToAnimate[text] = nil
		end

		text._value = newValue

		if text.PostSetAnimatedValue then
			text:PostSetAnimatedValue(newValue)
		else
			text:SetText(newValue)
		end
	end
end)

local function text_SetAnimatedValue(self, value, skip)
	if skip then
		self._value = value
		self._elapsed = 0

		if self.PostSetAnimatedValue then
			self:PostSetAnimatedValue(value)
		else
			self:SetText(value)
		end
	else
		self._value = self._value or 1
		self._elapsed = 0

		textsToAnimate[self] = value
	end
end

-- Slots
local function slot_OnEnter(self)
	self:GetParent().AnimOut:Stop()
	self:GetParent():SetAlpha(1)

	local quadrant = E:GetScreenQuadrant(self)
	local p, rP, x, y = "TOPLEFT", "BOTTOMRIGHT", -2, 2

	if quadrant == "BOTTOMLEFT" or quadrant == "BOTTOM" then
		p, rP, x, y = "BOTTOMLEFT", "TOPRIGHT", -2, -2
	elseif quadrant == "TOPRIGHT" or quadrant == "RIGHT" then
		p, rP, x, y = "TOPRIGHT", "BOTTOMLEFT", 2, 2
	elseif quadrant == "BOTTOMRIGHT" then
		p, rP, x, y = "BOTTOMRIGHT", "TOPLEFT", 2, -2
	end

	GameTooltip:Hide()
	GameTooltip:SetOwner(self, "ANCHOR_NONE")
	GameTooltip:SetPoint(p, self, rP, x, y)
end

local function slot_OnLeave(self)
	self:GetParent().AnimOut:Play()
	GameTooltip:Hide()
end

local function slot_OnHide(self)
	self._data = nil
end

-- Base Toast
local num = 0

local function getToastName()
	num = num + 1
	return "LSToast"..num
end

local function MODIFIER_STATE_CHANGED()
	if IsModifiedClick("COMPAREITEMS") or GetCVarBool("alwaysCompareItems") then
		GameTooltip_ShowCompareItem()
	else
		ShoppingTooltip1:Hide()
		ShoppingTooltip2:Hide()
	end
end

local function toast_OnShow(self)
	local soundFile = self._data.sound_file

	if soundFile and C.db.profile.sfx.enabled then
		PlaySound(soundFile)
	end

	self.AnimIn:Play()
	self.AnimOut:Play()
end

local function toast_OnClick(self, button)
	if button == "RightButton" then
		self:Recycle()
	end
end

local function toast_OnEnter(self)
	local quadrant = E:GetScreenQuadrant(self)
	local p, rP, x, y = "TOPLEFT", "BOTTOMRIGHT", -2, 2

	if quadrant == "BOTTOMLEFT" or quadrant == "BOTTOM" then
		p, rP, x, y = "BOTTOMLEFT", "TOPRIGHT", -2, -2
	elseif quadrant == "TOPRIGHT" or quadrant == "RIGHT" then
		p, rP, x, y = "TOPRIGHT", "BOTTOMLEFT", 2, 2
	elseif quadrant == "BOTTOMRIGHT" then
		p, rP, x, y = "BOTTOMRIGHT", "TOPLEFT", 2, -2
	end

	GameTooltip:Hide()
	GameTooltip:SetOwner(self, "ANCHOR_NONE")
	GameTooltip:SetPoint(p, self, rP, x, y)

	self.AnimOut:Stop()
	self:SetAlpha(1)

	E:RegisterEvent("MODIFIER_STATE_CHANGED", MODIFIER_STATE_CHANGED)
end

local function toast_OnLeave(self)
	BattlePetTooltip:Hide()
	GameTooltip:Hide()
	GarrisonFollowerTooltip:Hide()
	GarrisonShipyardFollowerTooltip:Hide()
	ShoppingTooltip1:Hide()
	ShoppingTooltip2:Hide()

	self.AnimOut:Play()

	E:UnregisterEvent("MODIFIER_STATE_CHANGED", MODIFIER_STATE_CHANGED)
end

local function toastAnimIn_OnFinished(self)
	local toast = self:GetParent()

	if toast._data.show_arrows then
		toast.AnimArrows:Play()

		toast._data.show_arrows = false
	end
end

local function toastAnimOut_OnFinished(self)
	self:GetParent():Recycle()
end

local function toast_Spawn(self, isDND)
	if #activeToasts >= C.db.profile.max_active_toasts or (InCombatLockdown() and isDND) then
		if InCombatLockdown() and isDND then
			self._data.dnd = true
		end

		t_insert(queuedToasts, self)

		return
	end

	if #activeToasts > 0 then
		if C.db.profile.growth_direction == "DOWN" then
			self:SetPoint("TOP", activeToasts[#activeToasts], "BOTTOM", 0, -14)
		elseif C.db.profile.growth_direction == "UP" then
			self:SetPoint("BOTTOM", activeToasts[#activeToasts], "TOP", 0, 14)
		elseif C.db.profile.growth_direction == "LEFT" then
			self:SetPoint("RIGHT", activeToasts[#activeToasts], "LEFT", -26, 0)
		elseif C.db.profile.growth_direction == "RIGHT" then
			self:SetPoint("LEFT", activeToasts[#activeToasts], "RIGHT", 26, 0)
		end
	else
		self:SetPoint("TOPLEFT", E:GetAnchorFrame(), "TOPLEFT", 0, 0)
	end

	t_insert(activeToasts, self)

	self:Show()
end

local function toast_Recycle(self)
	self:ClearAllPoints()
	self:SetAlpha(1)
	self:Hide()

	self:SetScript("OnClick", toast_OnClick)
	self:SetScript("OnEnter", toast_OnEnter)

	self._data = nil
	self.AnimArrows:Stop()
	self.AnimIn:Stop()
	self.AnimOut:Stop()
	self.Bonus:Hide()
	self.Dragon:Hide()
	self.Icon:ClearAllPoints()
	self.Icon:SetPoint("TOPLEFT", 0, 0)
	self.Icon:SetSize(42, 42)
	self.IconBorder:Hide()
	self.IconHL:Hide()
	self.IconText1:SetText("")
	self.IconText1.PostSetAnimatedValue = nil
	self.IconText1BG:Hide()
	self.IconText2:SetText("")
	self.IconText2.Blink:Stop()
	self.IconText2.PostSetAnimatedValue = nil
	self.Skull:Hide()
	self.Text:SetText("")
	self.Text.PostSetAnimatedValue = nil
	self.Title:SetText("")

	E:ResetSkin(self)

	for i = 1, 5 do
		self["Slot"..i]:Hide()
		self["Slot"..i]:SetScript("OnEnter", slot_OnEnter)
		self["Slot"..i]._data = nil
	end

	for i = 1, 5 do
		self["Arrow"..i]:SetAlpha(0)
	end

	for i, activeToast in next, activeToasts do
		if self == activeToast then
			t_remove(activeToasts, i)
		end
	end

	-- jic something goes wrong
	for i, queuedToast in next, queuedToasts do
		if self == queuedToast then
			t_remove(queuedToasts, i)
		end
	end

	t_insert(createdToasts, self)

	E:RefreshQueue()
end

local function ConstructToast()
	local toast = CreateFrame("Button", getToastName(), UIParent)
	toast:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	toast:Hide()
	toast:SetScript("OnShow", toast_OnShow)
	toast:SetScript("OnClick", toast_OnClick)
	toast:SetScript("OnEnter", toast_OnEnter)
	toast:SetScript("OnLeave", toast_OnLeave)
	toast:SetSize(224, 48)
	toast:SetScale(C.db.profile.scale)
	toast:SetFrameStrata(C.db.profile.strata)

	local bg = toast:CreateTexture(nil, "BACKGROUND", nil, -8)
	bg:SetAllPoints()
	-- bg:SetTexture("Interface\\AddOns\\ls_Toasts\\assets\\toast-bg-default")
	bg:SetTexCoord(1 / 256, 225 / 256, 1 / 64, 49 / 64)
	toast.BG = bg

	local border = createBorder(toast, "BACKGROUND", 1)
	-- border:SetTexture("Interface\\AddOns\\ls_Toasts\\assets\\toast-border")
	-- border:SetSize(16)
	-- border:SetOffset(-6)
	toast.Border = border

	local title = toast:CreateFontString(nil, "ARTWORK")
	-- local title = toast:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	title:SetPoint("TOPLEFT", 50, -2)
	title:SetPoint("BOTTOMRIGHT", toast, "TOPRIGHT", -2, -22)
	-- title:SetJustifyH("CENTER")
	-- title:SetJustifyV("MIDDLE")
	-- title:SetWordWrap(false)
	toast.Title = title

	local text = toast:CreateFontString(nil, "ARTWORK")
	-- local text = toast:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
	text:SetPoint("BOTTOMLEFT", 50, 2)
	text:SetPoint("TOPRIGHT", toast, "BOTTOMRIGHT", -2, 22)
	-- text:SetJustifyH("CENTER")
	-- text:SetJustifyV("MIDDLE")
	-- text:SetWordWrap(false)
	text.SetAnimatedValue = text_SetAnimatedValue
	toast.Text = text

	local textBG = toast:CreateTexture(nil, "BACKGROUND", nil, 1)
	textBG:SetPoint("TOPLEFT", 50, -2)
	textBG:SetPoint("BOTTOMRIGHT", -2, 2)
	textBG:SetTexture("Interface\\AddOns\\ls_Toasts\\assets\\toast-text-bg")
	textBG:SetTexCoord(1 / 256, 175 / 256, 1 / 64, 45 / 64)
	textBG:SetVertexColor(0, 0, 0)
	toast.TextBG = textBG

	local bonus = toast:CreateTexture(nil, "BACKGROUND", nil, -7)
	bonus:SetAtlas("Bonus-ToastBanner", true)
	bonus:SetPoint("TOPRIGHT", 0, 4)
	bonus:Hide()
	toast.Bonus = bonus

	local iconParent = CreateFrame("Frame", nil, toast)
	iconParent:SetFrameLevel(toast:GetFrameLevel() + 1)
	iconParent:SetSize(42, 42)
	iconParent:SetPoint("TOPLEFT", 3, -3)
	toast.IconParent = iconParent

	local icon = iconParent:CreateTexture(nil, "BACKGROUND", nil, 2)
	-- icon:SetTexCoord(0.0625, 0.9375, 0.0625, 0.9375)
	icon:SetPoint("TOPLEFT", 0, 0)
	icon:SetSize(42, 42)
	toast.Icon = icon

	local iconHL = iconParent:CreateTexture(nil, "BACKGROUND", nil, 3)
	iconHL:SetAllPoints()
	-- iconHL:SetTexture("Interface\\ContainerFrame\\UI-Icon-QuestBorder")
	-- iconHL:SetTexCoord(0.0625, 0.9375, 0.0625, 0.9375)
	iconHL:Hide()
	toast.IconHL = iconHL

	local iconBorder = createBorder(iconParent, "BACKGROUND", 5)
	-- iconBorder:SetTexture("Interface\\AddOns\\ls_Toasts\\assets\\icon-border")
	-- iconBorder:SetSize(16)
	-- iconBorder:SetOffset(-4)
	iconBorder:Hide()
	toast.IconBorder = iconBorder

	local dragon = iconParent:CreateTexture(nil, "BACKGROUND", nil, 6)
	dragon:SetPoint("TOPLEFT", toast, "TOPLEFT", -25, 16)
	dragon:SetSize(83, 83)
	dragon:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Gold-Dragon")
	dragon:SetDesaturated(true)
	dragon:SetVertexColor(1, 0.625, 0)
	dragon:Hide()
	toast.Dragon = dragon

	local iconText1 = iconParent:CreateFontString(nil, "ARTWORK")
	-- local iconText1 = iconParent:CreateFontString(nil, "ARTWORK", "GameFontHighlightOutline")
	-- iconText1:SetPoint("BOTTOMRIGHT", 0, 1)
	-- iconText1:SetJustifyH("RIGHT")
	iconText1.SetAnimatedValue = text_SetAnimatedValue
	toast.IconText1 = iconText1

	local iconText1BG = iconParent:CreateTexture(nil, "BACKGROUND", nil, 4)
	iconText1BG:SetPoint("LEFT", 0, 0)
	iconText1BG:SetPoint("TOP", iconText1, "TOP", 0, 1)
	iconText1BG:SetPoint("BOTTOMRIGHT", 0, 0)
	iconText1BG:SetColorTexture(0, 0, 0, 0.6)
	iconText1BG:Hide()
	toast.IconText1BG = iconText1BG

	local iconText2 = iconParent:CreateFontString(nil, "ARTWORK")
	-- local iconText2 = iconParent:CreateFontString(nil, "ARTWORK", "GameFontHighlightOutline")
	-- iconText2:SetPoint("BOTTOMRIGHT", iconText1, "TOPRIGHT", 0, 2)
	-- iconText2:SetJustifyH("RIGHT")
	iconText2:SetAlpha(0)
	iconText2.SetAnimatedValue = text_SetAnimatedValue
	toast.IconText2 = iconText2

	-- .IconText2.Blink
	do
		local ag = toast:CreateAnimationGroup()
		ag:SetToFinalAlpha(true)
		iconText2.Blink = ag

		local anim = ag:CreateAnimation("Alpha")
		anim:SetChildKey("IconText2")
		anim:SetOrder(1)
		anim:SetFromAlpha(1)
		anim:SetToAlpha(0)
		anim:SetDuration(0)

		anim:SetChildKey("IconText2")
		anim:SetOrder(2)
		anim:SetFromAlpha(0)
		anim:SetToAlpha(1)
		anim:SetDuration(0.2)

		anim = ag:CreateAnimation("Alpha")
		anim:SetChildKey("IconText2")
		anim:SetOrder(3)
		anim:SetFromAlpha(1)
		anim:SetToAlpha(0)
		anim:SetStartDelay(0.4)
		anim:SetDuration(0.4)
	end

	local skull = iconParent:CreateTexture(nil, "ARTWORK", nil, 2)
	skull:SetSize(16, 20)
	skull:SetTexture("Interface\\LFGFrame\\UI-LFG-ICON-HEROIC")
	skull:SetTexCoord(0 / 32, 16 / 32, 0 / 32, 20 / 32)
	skull:SetPoint("TOPRIGHT", -2, -2)
	skull:Hide()
	toast.Skull = skull

	-- .AnimArrows
	do
		local ag = toast:CreateAnimationGroup()
		ag:SetToFinalAlpha(true)
		toast.AnimArrows = ag

		for i = 1, 5 do
			local arrow = iconParent:CreateTexture(nil, "ARTWORK", "LootUpgradeFrame_ArrowTemplate")
			arrow:ClearAllPoints()
			arrow:SetPoint("CENTER", iconParent, "BOTTOM", ARROWS_CFG[i].x, 0)
			arrow:SetAlpha(0)
			toast["Arrow"..i] = arrow

			local anim = ag:CreateAnimation("Alpha")
			anim:SetChildKey("Arrow"..i)
			anim:SetOrder(1)
			anim:SetFromAlpha(1)
			anim:SetToAlpha(0)
			anim:SetDuration(0)

			anim = ag:CreateAnimation("Alpha")
			anim:SetChildKey("Arrow"..i)
			anim:SetSmoothing("IN")
			anim:SetOrder(2)
			anim:SetFromAlpha(0)
			anim:SetToAlpha(1)
			anim:SetStartDelay(ARROWS_CFG[i].delay)
			anim:SetDuration(0.25)

			anim = ag:CreateAnimation("Alpha")
			anim:SetChildKey("Arrow"..i)
			anim:SetSmoothing("OUT")
			anim:SetOrder(2)
			anim:SetFromAlpha(1)
			anim:SetToAlpha(0)
			anim:SetStartDelay(ARROWS_CFG[i].delay + 0.25)
			anim:SetDuration(0.25)

			anim = ag:CreateAnimation("Translation")
			anim:SetChildKey("Arrow"..i)
			anim:SetOrder(2)
			anim:SetOffset(0, 60)
			anim:SetStartDelay(ARROWS_CFG[i].delay)
			anim:SetDuration(0.5)

			anim = ag:CreateAnimation("Alpha")
			anim:SetChildKey("Arrow"..i)
			anim:SetDuration(0)
			anim:SetOrder(3)
			anim:SetFromAlpha(1)
			anim:SetToAlpha(0)
		end
	end

	local glowParent = CreateFrame("Frame", nil, toast)
	glowParent:SetFrameLevel(toast:GetFrameLevel() + 2)
	glowParent:SetAllPoints()

	local glow = glowParent:CreateTexture(nil, "OVERLAY", nil, 2)
	glow:SetSize(318, 152)
	glow:SetPoint("CENTER")
	glow:SetTexture("Interface\\AchievementFrame\\UI-Achievement-Alert-Glow")
	glow:SetTexCoord(5 / 512, 395 / 512, 5 / 256, 167 / 256)
	glow:SetBlendMode("ADD")
	glow:SetAlpha(0)
	toast.Glow = glow

	local shine = glowParent:CreateTexture(nil, "OVERLAY", nil, 1)
	shine:SetSize(66, 52)
	shine:SetPoint("BOTTOMLEFT", 0, -2)
	shine:SetTexture("Interface\\AchievementFrame\\UI-Achievement-Alert-Glow")
	shine:SetTexCoord(403 / 512, 465 / 512, 14 / 256, 62 / 256)
	shine:SetBlendMode("ADD")
	shine:SetAlpha(0)
	toast.Shine = shine

	-- .AnimIn, .AnimOut
	do
		local ag = toast:CreateAnimationGroup()
		ag:SetScript("OnFinished", toastAnimIn_OnFinished)
		ag:SetToFinalAlpha(true)
		toast.AnimIn = ag

		local anim = ag:CreateAnimation("Alpha")
		anim:SetOrder(1)
		anim:SetFromAlpha(0)
		anim:SetToAlpha(1)
		anim:SetDuration(0)

		anim = ag:CreateAnimation("Alpha")
		anim:SetChildKey("Glow")
		anim:SetOrder(2)
		anim:SetFromAlpha(0)
		anim:SetToAlpha(1)
		anim:SetDuration(0.2)

		anim = ag:CreateAnimation("Alpha")
		anim:SetChildKey("Glow")
		anim:SetOrder(3)
		anim:SetFromAlpha(1)
		anim:SetToAlpha(0)
		anim:SetDuration(0.5)

		anim = ag:CreateAnimation("Alpha")
		anim:SetChildKey("Shine")
		anim:SetOrder(2)
		anim:SetFromAlpha(0)
		anim:SetToAlpha(1)
		anim:SetDuration(0.2)

		anim = ag:CreateAnimation("Translation")
		anim:SetChildKey("Shine")
		anim:SetOrder(3)
		anim:SetOffset(168, 0)
		anim:SetDuration(0.85)

		anim = ag:CreateAnimation("Alpha")
		anim:SetChildKey("Shine")
		anim:SetOrder(3)
		anim:SetFromAlpha(1)
		anim:SetToAlpha(0)
		anim:SetStartDelay(0.35)
		anim:SetDuration(0.5)

		ag = toast:CreateAnimationGroup()
		ag:SetScript("OnFinished", toastAnimOut_OnFinished)
		toast.AnimOut = ag

		anim = ag:CreateAnimation("Alpha")
		anim:SetOrder(1)
		anim:SetFromAlpha(1)
		anim:SetToAlpha(0)
		anim:SetStartDelay(C.db.profile.fadeout_delay)
		anim:SetDuration(1.2)
		ag.Anim = anim
	end

	-- .Slot1, .Slot2, .Slot3, .Slot4, .Slot5
	for i = 1, 5 do
		local slot = CreateFrame("Frame", nil, toast)
		slot:SetSize(32, 32)
		slot:SetScript("OnEnter", slot_OnEnter)
		slot:SetScript("OnLeave", slot_OnLeave)
		slot:SetScript("OnHide", slot_OnHide)
		slot:SetFrameLevel(toast:GetFrameLevel() + 3)
		slot:Hide()
		toast["Slot"..i] = slot

		local sMask = slot:CreateMaskTexture()
		-- sMask:SetTexture("Interface\\CHARACTERFRAME\\TempPortraitAlphaMaskSmall", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
		sMask:SetPoint("TOPLEFT", 6, -6)
		sMask:SetPoint("BOTTOMRIGHT", -6, 6)
		slot.Mask = sMask

		local sIcon = slot:CreateTexture(nil, "BACKGROUND")
		sIcon:SetPoint("TOPLEFT", 5, -5)
		sIcon:SetPoint("BOTTOMRIGHT", -5, 5)
		sIcon:AddMaskTexture(sMask)
		slot.Icon = sIcon

		local sBorder = slot:CreateTexture(nil, "BORDER")
		sBorder:SetAllPoints()
		-- sBorder:SetTexture("Interface\\AddOns\\ls_Toasts\\assets\\slot-border")
		-- sBorder:SetTexCoord(28 / 128, 100 / 128, 28 / 128, 100 / 128)
		slot.Border = sBorder

		if i == 1 then
			slot:SetPoint("TOPRIGHT", -2, 16)
		else
			slot:SetPoint("RIGHT", toast["Slot"..(i - 1)], "LEFT", -2 , 0)
		end
	end

	toast.Recycle = toast_Recycle
	toast.Spawn = toast_Spawn

	E:ApplySkin(toast)

	t_insert(toasts, toast)

	return toast
end

function E.FindToast(_, toastEvent, dataType, dataValue)
	if dataType and dataValue then
		for _, t in next, activeToasts do
			if (not toastEvent or toastEvent == t._data.event)
				and (t._data[dataType] == dataValue) then
				return t
			end
		end

		for _, t in next, queuedToasts do
			if (not toastEvent or toastEvent == t._data.event)
				and (t._data[dataType] == dataValue) then
				return t, true
			end
		end
	end
end

function E.GetToast(_, toastEvent, dataType, dataValue)
	local toast, isQueued = E:FindToast(toastEvent, dataType, dataValue)
	local isNew

	if not toast then
		toast = t_remove(createdToasts, 1)

		if not toast then
			toast = ConstructToast()
		end

		isNew = true
	end

	return toast, isNew, isQueued
end

function E.FlushToastsCache()
	t_wipe(queuedToasts)

	for _ = 1, #activeToasts do
		activeToasts[1]:Click("RightButton")
	end

	t_wipe(createdToasts)
end

function E.GetQueuedToasts()
	return queuedToasts
end

function E.GetNumQueuedToasts()
	return #queuedToasts
end

function E.GetActiveToasts()
	return activeToasts
end

function E.GetNumActiveToasts()
	return #activeToasts
end

function E.GetCreatedToasts()
	return createdToasts
end

function E.GetToasts()
	return toasts
end

function E.UpdateScale()
	local scale = C.db.profile.scale

	E:GetAnchorFrame():SetSize(224 * scale, 48 * scale)

	for _, toast in next, toasts do
		toast:SetScale(scale)
	end
end

function E.UpdateFadeOutDelay()
	local delay = C.db.profile.fadeout_delay

	for _, toast in next, toasts do
		toast.AnimOut.Anim:SetStartDelay(delay)
	end
end

function E.UpdateStrata()
	local strata = C.db.profile.strata

	for _, toast in next, toasts do
		toast:SetFrameStrata(strata)
	end
end

function E.UpdateFont()
	local skin = E:GetSkin()
	local fontPath = E:GetLSM():Fetch("font", C.db.profile.font.name)
	local fontSize = C.db.profile.font.size

	for _, toast in next, toasts do
		-- .Title
		toast.Title:SetFont(fontPath, fontSize, skin.title.flags)

		-- .Text
		toast.Text:SetFont(fontPath, fontSize, skin.text.flags)

		-- .IconText1
		toast.IconText1:SetFont(fontPath, fontSize, skin.icon_text_1.flags)

		-- .IconText2
		toast.IconText2:SetFont(fontPath, fontSize, skin.icon_text_2.flags)
	end
end
