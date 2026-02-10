local _, addon = ...
local C, D, L = addon.C, addon.D, addon.L
addon.Border = {}

-- Lua
local _G = getfenv(0)
local next = _G.next
local type = _G.type
local unpack = _G.unpack

-- Mine
local sections = {"TOPLEFT", "TOPRIGHT", "BOTTOMLEFT", "BOTTOMRIGHT", "TOP", "BOTTOM", "LEFT", "RIGHT"}
local objectToWidget = {}

local function onSizeChanged(self, w, h)
	local border = objectToWidget[self]
	local offset = border.offset

	local tile = (w + 2 * offset) / 16
	border.TOP:SetTexCoord(0.25, tile, 0.375, tile, 0.25, 0, 0.375, 0)
	border.BOTTOM:SetTexCoord(0.375, tile, 0.5, tile, 0.375, 0, 0.5, 0)

	tile = (h + 2 * offset) / 16
	border.LEFT:SetTexCoord(0, 0.125, 0, tile)
	border.RIGHT:SetTexCoord(0.125, 0.25, 0, tile)

	PixelUtil.SetPoint(border.TOPLEFT, "BOTTOMRIGHT", border.parent, "TOPLEFT", -offset, offset)
	PixelUtil.SetPoint(border.TOPRIGHT, "BOTTOMLEFT", border.parent, "TOPRIGHT", offset, offset)
	PixelUtil.SetPoint(border.BOTTOMLEFT, "TOPRIGHT", border.parent, "BOTTOMLEFT", -offset, -offset)
	PixelUtil.SetPoint(border.BOTTOMRIGHT, "TOPLEFT", border.parent, "BOTTOMRIGHT", offset, -offset)

	local size = border.__size
	if size then
		PixelUtil.SetSize(border.TOPLEFT, size, size)
		PixelUtil.SetSize(border.TOPRIGHT, size, size)
		PixelUtil.SetSize(border.BOTTOMLEFT, size, size)
		PixelUtil.SetSize(border.BOTTOMRIGHT, size, size)

		PixelUtil.SetHeight(border.TOP, size)
		PixelUtil.SetHeight(border.BOTTOM, size)

		PixelUtil.SetWidth(border.LEFT, size)
		PixelUtil.SetWidth(border.RIGHT, size)
	end
end

local border_proto = {}

function border_proto:SetOffset(offset)
	self.offset = offset
	PixelUtil.SetPoint(self.TOPLEFT, "BOTTOMRIGHT", self.parent, "TOPLEFT", -offset, offset)
	PixelUtil.SetPoint(self.TOPRIGHT, "BOTTOMLEFT", self.parent, "TOPRIGHT", offset, offset)
	PixelUtil.SetPoint(self.BOTTOMLEFT, "TOPRIGHT", self.parent, "BOTTOMLEFT", -offset, -offset)
	PixelUtil.SetPoint(self.BOTTOMRIGHT, "TOPLEFT", self.parent, "BOTTOMRIGHT", offset, -offset)
end

function border_proto:SetTexture(texture)
	if type(texture) == "table" then
		for _, v in next, sections do
			self[v]:SetColorTexture(unpack(texture))
		end
	else
		for i, v in next, sections do
			if i > 4 then
				self[v]:SetTexture(texture, "REPEAT", "REPEAT")
			else
				self[v]:SetTexture(texture)
			end
		end
	end
end

function border_proto:SetSize(size)
	self.__size = size
	onSizeChanged(self.parent, self.parent:GetWidth(), self.parent:GetHeight())
end

function border_proto:Hide()
	for _, v in next, sections do
		self[v]:Hide()
	end
end

function border_proto:Show()
	for _, v in next, sections do
		self[v]:Show()
	end
end

function border_proto:SetShown(isShown)
	for _, v in next, sections do
		self[v]:SetShown(isShown)
	end
end

function border_proto:GetVertexColor()
	return self.TOPLEFT:GetVertexColor()
end

function border_proto:SetVertexColor(r, g, b, a)
	for _, v in next, sections do
		self[v]:SetVertexColor(r, g, b, a)
	end
end

function border_proto:SetAlpha(a)
	for _, v in next, sections do
		self[v]:SetAlpha(a)
	end
end

function border_proto:GetDebugName()
	return self.parent:GetDebugName() .. "Border"
end

function addon.Border:Create(parent, drawLayer, drawSubLevel)
	local border = Mixin({parent = parent}, border_proto)

	for _, v in next, sections do
		border[v] = parent:CreateTexture(nil, drawLayer or "OVERLAY", nil, drawSubLevel or 1)
		border[v]:SetSnapToPixelGrid(false)
		border[v]:SetTexelSnappingBias(0)
	end

	border.TOPLEFT:SetTexCoord(0.5, 0.625, 0, 1)
	border.TOPRIGHT:SetTexCoord(0.625, 0.75, 0, 1)
	border.BOTTOMLEFT:SetTexCoord(0.75, 0.875, 0, 1)
	border.BOTTOMRIGHT:SetTexCoord(0.875, 1, 0, 1)

	PixelUtil.SetPoint(border.TOP, "TOPLEFT", border.TOPLEFT, "TOPRIGHT", 0, 0)
	PixelUtil.SetPoint(border.TOP, "TOPRIGHT", border.TOPRIGHT, "TOPLEFT", 0, 0)

	PixelUtil.SetPoint(border.BOTTOM, "BOTTOMLEFT", border.BOTTOMLEFT, "BOTTOMRIGHT", 0, 0)
	PixelUtil.SetPoint(border.BOTTOM, "BOTTOMRIGHT", border.BOTTOMRIGHT, "BOTTOMLEFT", 0, 0)

	PixelUtil.SetPoint(border.LEFT, "TOPLEFT", border.TOPLEFT, "BOTTOMLEFT", 0, 0)
	PixelUtil.SetPoint(border.LEFT, "BOTTOMLEFT", border.BOTTOMLEFT, "TOPLEFT", 0, 0)

	PixelUtil.SetPoint(border.RIGHT, "TOPRIGHT", border.TOPRIGHT, "BOTTOMRIGHT", 0, 0)
	PixelUtil.SetPoint(border.RIGHT, "BOTTOMRIGHT", border.BOTTOMRIGHT, "TOPRIGHT", 0, 0)

	parent:HookScript("OnSizeChanged", onSizeChanged)
	objectToWidget[parent] = border

	border:SetOffset(-8)
	border:SetSize(16)

	return border
end
