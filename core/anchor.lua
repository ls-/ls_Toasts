local _, addonTable = ...
local E, C, D, L = addonTable.E, addonTable.C, addonTable.D, addonTable.L

-- Lua
local _G = getfenv(0)
local m_floor = _G.math.floor
local next = _G.next
local s_upper = _G.string.upper

--[[ luacheck: globals
	CreateFrame GameTooltip IsShiftKeyDown SquareButton_SetIcon UIParent
]]

-- Mine
local function calculatePosition(self)
	local selfCenterX, selfCenterY = self:GetCenter()
	local screenWidth = UIParent:GetRight()
	local screenHeight = UIParent:GetTop()
	local screenCenterX, screenCenterY = UIParent:GetCenter()
	local screenLeft = screenWidth / 3
	local screenRight = screenWidth * 2 / 3
	local p, x, y

	if selfCenterY >= screenCenterY then
		p = "TOP"
		y = self:GetTop() - screenHeight
	else
		p = "BOTTOM"
		y = self:GetBottom()
	end

	if selfCenterX >= screenRight then
		p = p .. "RIGHT"
		x = self:GetRight() - screenWidth
	elseif selfCenterX <= screenLeft then
		p = p .. "LEFT"
		x = self:GetLeft()
	else
		x = selfCenterX - screenCenterX
	end

	return p, p, m_floor(x + 0.5), m_floor(y + 0.5)
end

local anchorFrame = CreateFrame("Button", "LSToastAnchor", UIParent)
anchorFrame:RegisterForDrag("LeftButton")
anchorFrame:RegisterForClicks("LeftButtonUp")
anchorFrame:SetClampedToScreen(true)
anchorFrame:SetClampRectInsets(-4, 4, 4, -4)
anchorFrame:SetFlattensRenderLayers(true)
anchorFrame:SetFrameStrata("DIALOG")
anchorFrame:SetToplevel(true)
anchorFrame:Hide()

local texture = anchorFrame:CreateTexture(nil, "BACKGROUND")
texture:SetColorTexture(0.1, 0.1, 0.1, 0.9)
texture:SetAllPoints()
anchorFrame.BG = texture

local text = anchorFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
text:SetAllPoints()
text:SetJustifyH("CENTER")
text:SetJustifyV("MIDDLE")
text:SetText(L["ANCHOR"])
anchorFrame.Text = text

function anchorFrame:Toggle()
	if self:IsShown() then
		self:Hide()
	else
		self:Show()
	end
end

function anchorFrame:Refresh()
	self:SetMovable(true)
	self:ClearAllPoints()
	self:SetSize(224 * C.db.profile.scale, 48 * C.db.profile.scale)
	self:SetPoint(C.db.profile.point.p, "UIParent", C.db.profile.point.rP, C.db.profile.point.x, C.db.profile.point.y)
end

local function onEnter()
	local p, _, x, y = calculatePosition(anchorFrame)

	GameTooltip:SetOwner(anchorFrame, "ANCHOR_CURSOR")
	GameTooltip:AddLine(L["COORDS"])
	GameTooltip:AddLine("|cffffd100P:|r " .. p .. ", |cffffd100X:|r " .. x .. ", |cffffd100Y:|r " .. y, 1, 1, 1)
	GameTooltip:AddLine(" ")
	GameTooltip:AddLine(L["ANCHOR_RESET_DESC"])
	GameTooltip:Show()
end

local function onLeave()
	GameTooltip:Hide()
end

local function onUpdate(self, elapsed)
	self.elapsed = (self.elapsed or 0) + elapsed

	if self.elapsed > 0.1 then
		if GameTooltip:IsOwned(self) then
			onEnter(self)
		end

		self.elapsed = 0
	end
end

anchorFrame:SetScript("OnEnter", onEnter)
anchorFrame:SetScript("OnLeave", onLeave)

anchorFrame:SetScript("OnClick", function(self)
	if IsShiftKeyDown() then
		self:ClearAllPoints()
		self:SetPoint(D.profile.point.p, "UIParent", D.profile.point.rP, D.profile.point.x, D.profile.point.y)

		C.db.profile.point = {
			p = D.profile.point.p,
			rP = D.profile.point.rP,
			x = D.profile.point.x,
			y = D.profile.point.y,
		}
	end
end)

anchorFrame:SetScript("OnDragStart", function(self)
	self:StartMoving()
	self:SetScript("OnUpdate", onUpdate)
end)

anchorFrame:SetScript("OnDragStop", function(self)
	self:StopMovingOrSizing()
	self:SetScript("OnUpdate", nil)

	local p, rP, x, y = calculatePosition(self)

	self:ClearAllPoints()
	self:SetPoint(p, "UIParent", rP, x, y)

	C.db.profile.point = {p = p, rP = rP, x = x, y = y}
end)

local buttons = {
	Up = {
		point1 = {"TOPLEFT", "TOPLEFT", 12, 0},
		point2 = {"BOTTOMRIGHT", "TOPRIGHT", -12, -12},
		offset_x = 0,
		offset_y = 1,
	},
	Down = {
		point1 = {"BOTTOMLEFT", "BOTTOMLEFT", 12, 0},
		point2 = {"TOPRIGHT", "BOTTOMRIGHT", -12, 12},
		offset_x = 0,
		offset_y = -1,
	},
	Left = {
		point1 = {"TOPLEFT", "TOPLEFT", 0, -12},
		point2 = {"BOTTOMRIGHT", "BOTTOMLEFT", 12, 12},
		offset_x = -1,
		offset_y = 0,
	},
	Right = {
		point1 = {"TOPRIGHT", "TOPRIGHT", 0, -12},
		point2 = {"BOTTOMLEFT", "BOTTOMRIGHT", -12, 12},
		offset_x = 1,
		offset_y = 0,
	},
}

local function button_OnClick(self)
	local p, rP, x, y = calculatePosition(anchorFrame)

	anchorFrame:ClearAllPoints()
	anchorFrame:SetPoint(p, "UIParent", rP, x + self.offset_x, y + self.offset_y)

	p, rP, x, y = calculatePosition(anchorFrame)
	C.db.profile.point = {p = p, rP = rP, x = x, y = y}

	onEnter()
end

for dir, data in next, buttons do
	local button = CreateFrame("Button", "$parentButton" .. dir, anchorFrame, "UIPanelSquareButton")
	button:GetHighlightTexture():SetColorTexture(0.4, 0.4, 0.4, 0.8)
	button:GetNormalTexture():SetColorTexture(0.2, 0.2, 0.2, 0.8)
	button:GetPushedTexture():SetColorTexture(0.1, 0.1, 0.1, 0.8)
	button:SetFlattensRenderLayers(true)
	button:SetPoint(data.point1[1], anchorFrame, data.point1[2], data.point1[3], data.point1[4])
	button:SetPoint(data.point2[1], anchorFrame, data.point2[2], data.point2[3], data.point2[4])
	button:SetSize(0, 0)
	button:SetScript("OnClick", button_OnClick)
	button:SetScript("OnEnter", onEnter)
	button:SetScript("OnLeave", onLeave)

	button.offset_x = data.offset_x
	button.offset_y = data.offset_y

	SquareButton_SetIcon(button, s_upper(dir))
end

function E.GetAnchorFrame()
	return anchorFrame
end
