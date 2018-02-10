local _, addonTable = ...
local E, C, L = addonTable.E, addonTable.C, addonTable.L

-- Lua
local _G = getfenv(0)
local m_floor = _G.math.floor

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
		p = p.."RIGHT"
		x = self:GetRight() - screenWidth
	elseif selfCenterX <= screenLeft then
		p = p.."LEFT"
		x = self:GetLeft()
	else
		x = selfCenterX - screenCenterX
	end

	return p, p, m_floor(x + 0.5), m_floor(y + 0.5)
end

local anchorFrame = CreateFrame("Frame", "LSToastAnchor", UIParent)
anchorFrame:SetClampedToScreen(true)
anchorFrame:SetClampRectInsets(-26, 14, 14, -14)
anchorFrame:SetToplevel(true)
anchorFrame:RegisterForDrag("LeftButton")
anchorFrame:SetFrameStrata("DIALOG")

local texture = anchorFrame:CreateTexture(nil, "BACKGROUND")
texture:SetColorTexture(0.1, 0.1, 0.1, 0.9)
texture:SetAllPoints()
texture:Hide()
anchorFrame.BG = texture

local text = anchorFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
text:SetAllPoints()
text:SetJustifyH("CENTER")
text:SetJustifyV("MIDDLE")
text:SetText(L["ANCHOR"])
text:Hide()
anchorFrame.Text = text

anchorFrame.Enable = function(self)
	self:EnableMouse(true)
	self.BG:Show()
	self.Text:Show()
end

anchorFrame.Disable = function(self)
	self:EnableMouse(false)
	self.BG:Hide()
	self.Text:Hide()
end

anchorFrame.Toggle = function(self)
	if self:IsMouseEnabled() then
		self:Disable()
	else
		self:Enable()
	end
end

anchorFrame.Refresh = function(self)
	self:SetMovable(true)
	self:ClearAllPoints()
	self:SetSize(224 * C.db.profile.scale, 48 * C.db.profile.scale)
	self:SetPoint(C.db.profile.point.p, "UIParent", C.db.profile.point.rP, C.db.profile.point.x, C.db.profile.point.y)
end

anchorFrame.StartDrag = function(self)
	self:StartMoving()
end

anchorFrame.StopDrag = function(self)
	self:StopMovingOrSizing()

	local p, rP, x, y = calculatePosition(self)

	self:ClearAllPoints()
	self:SetPoint(p, "UIParent", rP, x, y)

	C.db.profile.point = {p = p, rP = rP, x = x, y = y}
end

anchorFrame:SetScript("OnDragStart", anchorFrame.StartDrag)
anchorFrame:SetScript("OnDragStop", anchorFrame.StopDrag)

function E.GetAnchorFrame()
	return anchorFrame
end
