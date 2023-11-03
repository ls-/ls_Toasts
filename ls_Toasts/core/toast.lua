local _, addonTable = ...
local E, P, C, D, L = addonTable.E, addonTable.P, addonTable.C, addonTable.D, addonTable.L

-- Lua
local _G = getfenv(0)
local m_ceil = _G.math.ceil
local m_floor = _G.math.floor
local next = _G.next
local t_insert = _G.table.insert
local t_remove = _G.table.remove
local t_wipe = _G.table.wipe
local type = _G.type
local unpack = _G.unpack

-- Mine
local freeToasts = {}
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
	if type(texture) == "table" then
		self.calcTile = false

		for _, v in next, sections do
			self[v]:SetColorTexture(unpack(texture))
		end
	else
		self.calcTile = true

		for i, v in next, sections do
			if i > 4 then
				self[v]:SetTexture(texture, "REPEAT", "REPEAT")
			else
				self[v]:SetTexture(texture)
			end
		end
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
		local tile = (self.parent:GetWidth() + 2 * self.offset) / 16
		self.TOP:SetTexCoord(0.25, tile, 0.375, tile, 0.25, 0, 0.375, 0)
		self.BOTTOM:SetTexCoord(0.375, tile, 0.5, tile, 0.375, 0, 0.5, 0)

		tile = (self.parent:GetHeight() + 2 * self.offset) / 16
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
		border[v]:SetTexelSnappingBias(0)
		border[v]:SetSnapToPixelGrid(false)
	end

	border.TOPLEFT:SetTexCoord(0.5, 0.625, 0, 1)
	border.TOPLEFT:SetPoint("BOTTOMRIGHT", self, "TOPLEFT", 0, 0)

	border.TOPRIGHT:SetTexCoord(0.625, 0.75, 0, 1)
	border.TOPRIGHT:SetPoint("BOTTOMLEFT", self, "TOPRIGHT", 0, 0)

	border.BOTTOMLEFT:SetTexCoord(0.75, 0.875, 0, 1)
	border.BOTTOMLEFT:SetPoint("TOPRIGHT", self, "BOTTOMLEFT", 0, 0)

	border.BOTTOMRIGHT:SetTexCoord(0.875, 1, 0, 1)
	border.BOTTOMRIGHT:SetPoint("TOPLEFT", self, "BOTTOMRIGHT", 0, 0)

	border.TOP:SetPoint("TOPLEFT", border.TOPLEFT, "TOPRIGHT", 0, 0)
	border.TOP:SetPoint("TOPRIGHT", border.TOPRIGHT, "TOPLEFT", 0, 0)

	border.BOTTOM:SetPoint("BOTTOMLEFT", border.BOTTOMLEFT, "BOTTOMRIGHT", 0, 0)
	border.BOTTOM:SetPoint("BOTTOMRIGHT", border.BOTTOMRIGHT, "BOTTOMLEFT", 0, 0)

	border.LEFT:SetPoint("TOPLEFT", border.TOPLEFT, "BOTTOMLEFT", 0, 0)
	border.LEFT:SetPoint("BOTTOMLEFT", border.BOTTOMLEFT, "TOPLEFT", 0, 0)

	border.RIGHT:SetPoint("TOPRIGHT", border.TOPRIGHT, "BOTTOMRIGHT", 0, 0)
	border.RIGHT:SetPoint("BOTTOMRIGHT", border.BOTTOMRIGHT, "TOPRIGHT", 0, 0)

	border.Hide = border_Hide
	border.SetOffset = border_SetOffset
	border.SetSize = border_SetSize
	border.SetTexture = border_SetTexture
	border.SetVertexColor = border_SetVertexColor
	border.Show = border_Show

	return border
end

-- Animated Text
local textsToAnimate = {}

local function lerp(v1, v2, perc)
	return v1 + (v2 - v1) * perc
end

C_Timer.NewTicker(0.05, function()
	for text, targetValue in next, textsToAnimate do
		local newValue

		text._elapsed = text._elapsed + 0.05

		if text._value >= targetValue then
			newValue = m_floor(lerp(text._value, targetValue, text._elapsed / 0.6))
		else
			newValue = m_ceil(lerp(text._value, targetValue, text._elapsed / 0.6))
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
	t_wipe(self._data)
end

-- Base Toast
local function MODIFIER_STATE_CHANGED()
	if IsModifiedClick("COMPAREITEMS") or GetCVarBool("alwaysCompareItems") then
		GameTooltip_ShowCompareItem()
	else
		ShoppingTooltip1:Hide()
		ShoppingTooltip2:Hide()
	end
end

local function toast_OnShow(self)
	if self._data.sound_file then
		if type(self._data.sound_file) == "number" then
			PlaySound(self._data.sound_file)
		elseif type(self._data.sound_file) == "string" then
			PlaySoundFile(self._data.sound_file)
		end
	end

	self.AnimIn:Play()
	self.AnimOut:Play()
end

local function toast_OnClick(self, button)
	if button == "RightButton" then
		self:Release()
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
	GameTooltip:SetOwner(self, "ANCHOR_PRESERVE")
	GameTooltip:ClearAllPoints()
	GameTooltip:SetPoint(p, self, rP, x, y)

	self.AnimOut:Stop()
	self:SetAlpha(1)

	E:RegisterEvent("MODIFIER_STATE_CHANGED", MODIFIER_STATE_CHANGED)
end

local function toast_OnLeave(self)
	GameTooltip:Hide()
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
	self:GetParent():Release()
end

local order = 0
local function toast_Spawn(self, anchorID, isDND)
	order = order + 1

	self._data.anchor = anchorID
	self._data.dnd = isDND
	self._data.order = order

	self:SetScale(C.db.profile.anchors[anchorID].scale)
	self.AnimOut.Anim1:SetStartDelay(C.db.profile.anchors[anchorID].fadeout_delay)

	P:Queue(self, anchorID)

	P.CallbackHandler:Fire("ToastSpawned", self)
end

local function toast_Release(self)
	self:ClearAllPoints()
	self:SetAlpha(1)
	self:Hide()
	self:SetScript("OnClick", toast_OnClick)
	self:SetScript("OnEnter", toast_OnEnter)

	self.AnimArrows:Stop()
	self.AnimIn:Stop()
	self.AnimOut:Stop()
	self.Bonus:Hide()
	self:HideLeaves()
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
	self.IconText3:SetText("")
	self.IconText3.PostSetAnimatedValue = nil
	self.IconText3BG:Hide()
	self.Skull:Hide()
	self.Text:SetText("")
	self.Text.PostSetAnimatedValue = nil
	self.Title:SetText("")

	P:ResetSkin(self)

	for i = 1, 5 do
		self["Slot" .. i]:Hide()
		self["Slot" .. i]:SetScript("OnEnter", slot_OnEnter)
		t_wipe(self["Slot" .. i]._data)
	end

	for i = 1, 5 do
		self["Arrow" .. i]:SetAlpha(0)
	end

	-- a toast that's recycled before spawning
	if self._data.anchor then
		P:Dequeue(self, self._data.anchor)
	end

	t_wipe(self._data)
	t_insert(freeToasts, self)

	P.CallbackHandler:Fire("ToastReleased", self)
end

local function toast_SetBackground(self, id)
	local skin = P:GetSkin(C.db.profile.skin)

	if not skin.bg[id] then
		id = "default"
	end

	if type(skin.bg[id].texture) == "table" then
		self.BG:SetColorTexture(unpack(skin.bg[id].texture))
		self.BG:SetHorizTile(false)
		self.BG:SetVertTile(false)
		self.BG:SetTexCoord(1, 0, 1, 0)
	else
		if skin.bg[id].tile then
			self.BG:SetTexture(skin.bg[id].texture, "REPEAT", "REPEAT")
			self.BG:SetHorizTile(true)
			self.BG:SetVertTile(true)
			self.BG:SetTexCoord(1, 0, 1, 0)
		else
			self.BG:SetTexture(skin.bg[id].texture)
			self.BG:SetHorizTile(false)
			self.BG:SetVertTile(false)
			self.BG:SetTexCoord(unpack(skin.bg[id].tex_coords))
		end
	end

	self.BG:SetVertexColor(unpack(skin.bg[id].color))
end

local num = 0
local function constructToast()
	num = num + 1

	local toast = CreateFrame("Button", "LSToast" .. num, UIParent)
	toast:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	toast:SetFlattensRenderLayers(true)
	toast:SetFrameStrata(C.db.profile.strata)
	toast:SetSize(224, 48)
	toast:Hide()
	toast:SetScript("OnShow", toast_OnShow)
	toast:SetScript("OnClick", toast_OnClick)
	toast:SetScript("OnEnter", toast_OnEnter)
	toast:SetScript("OnLeave", toast_OnLeave)

	local bg = toast:CreateTexture(nil, "BACKGROUND", nil, -8)
	bg:SetAllPoints()
	toast.BG = bg

	local border = createBorder(toast, "BACKGROUND", 1)
	toast.Border = border

	local title = toast:CreateFontString(nil, "ARTWORK")
	title:SetPoint("TOPLEFT", 50, -2)
	title:SetPoint("TOPRIGHT", -2, -2)
	title:SetHeight(14)
	toast.Title = title

	local text = toast:CreateFontString(nil, "ARTWORK")
	text:SetPoint("BOTTOMLEFT", 50, 2)
	text:SetPoint("BOTTOMRIGHT", -2, 2)
	text:SetHeight(28)
	text:SetMaxLines(2)
	text.SetAnimatedValue = text_SetAnimatedValue
	toast.Text = text

	local textBG = toast:CreateTexture(nil, "BACKGROUND", nil, 1)
	textBG:SetPoint("TOPLEFT", 50, -2)
	textBG:SetPoint("BOTTOMRIGHT", -2, 2)
	textBG:SetTexture("Interface\\AddOns\\ls_Toasts\\assets\\text-bg")
	textBG:SetTexCoord(1 / 256, 173 / 256, 1 / 64, 45 / 64)
	textBG:SetVertexColor(0, 0, 0)
	toast.TextBG = textBG

	local bonus = toast:CreateTexture(nil, "BACKGROUND", nil, -7)
	bonus:SetAtlas("Bonus-ToastBanner", true)
	bonus:SetPoint("TOPRIGHT", 0, 4)
	bonus:Hide()
	toast.Bonus = bonus

	-- .Leaves
	do
		local leaves = {}
		toast.Leaves = leaves

		local leafTL = toast:CreateTexture(nil, "BACKGROUND", nil, 2)
		leafTL:SetTexture("Interface\\AddOns\\ls_Toasts\\assets\\toast-overlay-leaves")
		leafTL:SetTexCoord(1 / 512, 213 / 512, 1 / 128, 81 / 128)
		leafTL:SetSize(212 / 2, 80 / 2)
		leafTL:Hide()
		t_insert(leaves, leafTL)

		local leafTR = toast:CreateTexture(nil, "BACKGROUND", nil, 2)
		leafTR:SetTexture("Interface\\AddOns\\ls_Toasts\\assets\\toast-overlay-leaves")
		leafTR:SetTexCoord(213 / 512, 301 / 512, 1 / 128, 61 / 128)
		leafTR:SetSize(88 / 2, 60 / 2)
		leafTR:Hide()
		t_insert(leaves, leafTR)

		local leafBR = toast:CreateTexture(nil, "BACKGROUND", nil, 2)
		leafBR:SetTexture("Interface\\AddOns\\ls_Toasts\\assets\\toast-overlay-leaves")
		leafBR:SetTexCoord(301 / 512, 365 / 512, 1 / 128, 37 / 128)
		leafBR:SetSize(64 / 2, 36 / 2)
		leafBR:Hide()
		t_insert(leaves, leafBR)

		-- TODO: Rewrite toasts with mixin and object pools
		function toast:ShowLeaves()
			for i = 1, #self.Leaves do
				self.Leaves[i]:Show()
			end
		end

		function toast:HideLeaves()
			for i = 1, #self.Leaves do
				self.Leaves[i]:Hide()
			end
		end

		function toast:AreLeavesShown()
			return self.Leaves[1]:IsShown()
		end

		function toast:SetLeavesVertexColor(...)
			for i = 1, #self.Leaves do
				self.Leaves[i]:SetVertexColor(...)
			end
		end

		function toast:ShouldHideLeaves()
			return self.Leaves.isHidden
		end
	end

	local iconParent = CreateFrame("Frame", nil, toast)
	iconParent:SetFlattensRenderLayers(true)
	iconParent:SetFrameLevel(toast:GetFrameLevel() + 1)
	iconParent:SetPoint("TOPLEFT", 3, -3)
	iconParent:SetSize(42, 42)
	toast.IconParent = iconParent

	local icon = iconParent:CreateTexture(nil, "BACKGROUND", nil, 2)
	icon:SetPoint("TOPLEFT", 0, 0)
	icon:SetSize(42, 42)
	toast.Icon = icon

	local iconHL = iconParent:CreateTexture(nil, "BACKGROUND", nil, 3)
	iconHL:SetAllPoints()
	iconHL:Hide()
	toast.IconHL = iconHL

	local iconBorder = createBorder(iconParent, "BACKGROUND", 5)
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
	iconText1.SetAnimatedValue = text_SetAnimatedValue
	toast.IconText1 = iconText1

	local iconText1BG = iconParent:CreateTexture(nil, "BACKGROUND", nil, 4)
	iconText1BG:SetPoint("LEFT", 0, 0)
	iconText1BG:SetPoint("TOP", iconText1, "TOP", 0, 1)
	iconText1BG:SetPoint("BOTTOMRIGHT", 0, 0)
	iconText1BG:SetColorTexture(1, 1, 1, 1)
	iconText1BG:SetGradient("VERTICAL", {r = 0, g = 0, b = 0, a = 0.8}, {r = 0, g = 0, b = 0, a = 0})
	iconText1BG:Hide()
	toast.IconText1BG = iconText1BG

	local iconText2 = iconParent:CreateFontString(nil, "ARTWORK")
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

	local iconText3 = iconParent:CreateFontString(nil, "ARTWORK")
	iconText3.SetAnimatedValue = text_SetAnimatedValue
	toast.IconText3 = iconText3

	local iconText3BG = iconParent:CreateTexture(nil, "BACKGROUND", nil, 4)
	iconText3BG:SetPoint("LEFT", 0, 0)
	iconText3BG:SetPoint("BOTTOM", iconText3, "BOTTOM", 0, -1)
	iconText3BG:SetPoint("TOPRIGHT", 0, 0)
	iconText3BG:SetColorTexture(1, 1, 1, 1)
	iconText3BG:SetGradient("VERTICAL", {r = 0, g = 0, b = 0, a = 0}, {r = 0, g = 0, b = 0, a = 0.8})
	iconText3BG:Hide()
	toast.IconText3BG = iconText3BG

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
			toast["Arrow" .. i] = arrow

			local anim = ag:CreateAnimation("Alpha")
			anim:SetChildKey("Arrow" .. i)
			anim:SetOrder(1)
			anim:SetFromAlpha(1)
			anim:SetToAlpha(0)
			anim:SetDuration(0)

			anim = ag:CreateAnimation("Alpha")
			anim:SetChildKey("Arrow" .. i)
			anim:SetSmoothing("IN")
			anim:SetOrder(2)
			anim:SetFromAlpha(0)
			anim:SetToAlpha(1)
			anim:SetStartDelay(ARROWS_CFG[i].delay)
			anim:SetDuration(0.25)

			anim = ag:CreateAnimation("Alpha")
			anim:SetChildKey("Arrow" .. i)
			anim:SetSmoothing("OUT")
			anim:SetOrder(2)
			anim:SetFromAlpha(1)
			anim:SetToAlpha(0)
			anim:SetStartDelay(ARROWS_CFG[i].delay + 0.25)
			anim:SetDuration(0.25)

			anim = ag:CreateAnimation("Translation")
			anim:SetChildKey("Arrow" .. i)
			anim:SetOrder(2)
			anim:SetOffset(0, 60)
			anim:SetStartDelay(ARROWS_CFG[i].delay)
			anim:SetDuration(0.5)

			anim = ag:CreateAnimation("Alpha")
			anim:SetChildKey("Arrow" .. i)
			anim:SetDuration(0)
			anim:SetOrder(3)
			anim:SetFromAlpha(1)
			anim:SetToAlpha(0)
		end
	end

	local glowParent = CreateFrame("Frame", nil, toast)
	glowParent:SetFlattensRenderLayers(true)
	glowParent:SetFrameLevel(toast:GetFrameLevel() + 2)
	glowParent:SetAllPoints()

	local glow = glowParent:CreateTexture(nil, "OVERLAY", nil, 2)
	glow:SetBlendMode("ADD")
	glow:SetAlpha(0)
	toast.Glow = glow

	local shine = glowParent:CreateTexture(nil, "OVERLAY", nil, 1)
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
		ag.Anim1 = anim

		anim = ag:CreateAnimation("Alpha")
		anim:SetChildKey("Glow")
		anim:SetOrder(2)
		anim:SetFromAlpha(0)
		anim:SetToAlpha(1)
		anim:SetDuration(0.2)
		ag.Anim2 = anim

		anim = ag:CreateAnimation("Alpha")
		anim:SetChildKey("Glow")
		anim:SetOrder(3)
		anim:SetFromAlpha(1)
		anim:SetToAlpha(0)
		anim:SetDuration(0.5)
		ag.Anim3 = anim

		anim = ag:CreateAnimation("Alpha")
		anim:SetChildKey("Shine")
		anim:SetOrder(2)
		anim:SetFromAlpha(0)
		anim:SetToAlpha(1)
		anim:SetDuration(0.2)
		ag.Anim4 = anim

		anim = ag:CreateAnimation("Translation")
		anim:SetChildKey("Shine")
		anim:SetOrder(3)
		anim:SetDuration(0.85)
		ag.Anim5 = anim

		anim = ag:CreateAnimation("Alpha")
		anim:SetChildKey("Shine")
		anim:SetOrder(3)
		anim:SetFromAlpha(1)
		anim:SetToAlpha(0)
		anim:SetStartDelay(0.35)
		anim:SetDuration(0.5)
		ag.Anim6 = anim

		ag = toast:CreateAnimationGroup()
		ag:SetScript("OnFinished", toastAnimOut_OnFinished)
		toast.AnimOut = ag

		anim = ag:CreateAnimation("Alpha")
		anim:SetOrder(1)
		anim:SetFromAlpha(1)
		anim:SetToAlpha(0)
		anim:SetDuration(1.2)
		ag.Anim1 = anim
	end

	-- .Slot1, .Slot2, .Slot3, .Slot4, .Slot5
	for i = 1, 5 do
		local slot = CreateFrame("Frame", nil, toast)
		slot:SetFlattensRenderLayers(true)
		slot:SetFrameLevel(toast:GetFrameLevel() + 3)
		slot:SetSize(18, 18)
		slot:Hide()
		slot:SetScript("OnEnter", slot_OnEnter)
		slot:SetScript("OnLeave", slot_OnLeave)
		slot:SetScript("OnHide", slot_OnHide)
		toast["Slot" .. i] = slot

		local slotIcon = slot:CreateTexture(nil, "BACKGROUND", nil, 1)
		slotIcon:SetAllPoints()
		slot.Icon = slotIcon

		local slotBorder = createBorder(slot, "BACKGROUND", 2)
		slot.Border = slotBorder

		if i == 1 then
			slot:SetPoint("TOPRIGHT", -4, 9)
		else
			slot:SetPoint("RIGHT", toast["Slot" .. (i - 1)], "LEFT", -4 , 0)
		end

		slot._data = {}
	end

	toast._data = {}
	toast.Release = toast_Release
	toast.Recycle = toast_Release -- Deprecated
	toast.Spawn = toast_Spawn
	toast.SetBackground = toast_SetBackground

	P:SetSkin(toast, C.db.profile.skin)

	t_insert(toasts, toast)

	P.CallbackHandler:Fire("ToastCreated", toast)

	return toast
end

function E:FindToast(toastEvent, dataType, dataValue)
	if dataType and dataValue then
		for _, queuedToasts in next, P:GetQueuedToasts() do
			for _, t in next, queuedToasts do
				if (not toastEvent or toastEvent == t._data.event) and (t._data[dataType] == dataValue) then
					return t, true
				end
			end
		end

		for _, activeToasts in next, P:GetActiveToasts() do
			for _, t in next, activeToasts do
				if (not toastEvent or toastEvent == t._data.event) and (t._data[dataType] == dataValue) then
					return t
				end
			end
		end
	end
end

function E:GetToast(toastEvent, dataType, dataValue)
	local toast, isQueued = E:FindToast(toastEvent, dataType, dataValue)
	local isNew

	if not toast then
		toast = t_remove(freeToasts, 1)
		if not toast then
			toast = constructToast()
		end

		isNew = true
	end

	return toast, isNew, isQueued
end

function P:GetToasts()
	return toasts
end

function P:UpdateScale(anchorID)
	local scale = C.db.profile.anchors[anchorID].scale

	self:GetAnchor(anchorID):SetSize(224 * scale, 48 * scale)

	for _, toast in next, self:GetActiveToasts(anchorID) do
		toast:SetScale(scale)
	end

	for _, toast in next, self:GetQueuedToasts(anchorID) do
		toast:SetScale(scale)
	end
end

function P:UpdateFadeOutDelay(anchorID)
	local delay = C.db.profile.anchors[anchorID].fadeout_delay

	for _, toast in next, self:GetActiveToasts(anchorID) do
		toast.AnimOut.Anim1:SetStartDelay(delay)
	end

	for _, toast in next, self:GetQueuedToasts(anchorID) do
		toast.AnimOut.Anim1:SetStartDelay(delay)
	end
end

function P:UpdateStrata()
	local strata = C.db.profile.strata

	for _, toast in next, toasts do
		toast:SetFrameStrata(strata)
	end
end

function P:UpdateFont()
	local skin = self:GetSkin(C.db.profile.skin)
	local fontPath = LibStub("LibSharedMedia-3.0"):Fetch("font", C.db.profile.font.name)
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

function P:UpdateSkin()
	local id = C.db.profile.skin

	for _, toast in next, toasts do
		self:SetSkin(toast, id)
	end
end
