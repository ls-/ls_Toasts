local _, addonTable = ...
local E, C = addonTable.E, addonTable.C

-- Lua
local _G = getfenv(0)
local next = _G.next
local type = _G.type
local unpack = _G.unpack

-- Mine
local LSM = LibStub("LibSharedMedia-3.0")
local skins = {}
local skinList = {}

local function mergeTable(src, dest)
	if type(dest) ~= "table" then
		dest = {}
	end

	for k, v in next, src do
		if type(v) == "table" then
			dest[k] = mergeTable(v, dest[k])
		else
			if dest[k] == nil then
				dest[k] = v
			end
		end
	end

	return dest
end

local function applySkin(toast)
	local data = skins[C.db.profile.skin] or skins["default"]
	local fontPath = LSM:Fetch("font", C.db.profile.font.name)
	local fontSize = C.db.profile.font.size

	-- .Border
	local border = toast.Border
	if type(data.border.texture) == "table" then
		border:SetColorTexture(unpack(data.border.texture))
	else
		border:SetTexture(data.border.texture)
	end
	border:SetVertexColor(unpack(data.border.color))
	border:SetSize(data.border.size)
	border:SetOffset(data.border.offset)

	-- .BG
	local bg = toast.BG
	bg:SetDesaturated(data.bg.desaturated)
	bg:SetTexture(data.bg.default)

	-- .Title
	local title = toast.Title
	title:SetFont(fontPath, fontSize, data.title.flags)
	title:SetVertexColor(unpack(data.title.color))
	title:SetJustifyH("CENTER")
	title:SetJustifyV("MIDDLE")
	title:SetWordWrap(false)
	title:SetShadowOffset(data.title.shadow and 1 or 0, data.title.shadow and -1 or 0)

	-- .Text
	local text = toast.Text
	text:SetFont(fontPath, fontSize, data.text.flags)
	text:SetVertexColor(unpack(data.text.color))
	text:SetJustifyH("CENTER")
	text:SetJustifyV("MIDDLE")
	text:SetWordWrap(false)
	text:SetShadowOffset(data.text.shadow and 1 or 0, data.text.shadow and -1 or 0)

	-- .Bonus
	toast.Bonus.isHidden = data.bonus.hidden

	-- .Dragon
	toast.Dragon.isHidden = data.dragon.hidden

	-- .Icon
	toast.Icon:SetTexCoord(unpack(data.icon.tex_coords))

	-- .IconBorder
	local iconBorder = toast.IconBorder
	if type(data.icon_border.texture) == "table" then
		iconBorder:SetColorTexture(unpack(data.icon_border.texture))
	else
		iconBorder:SetTexture(data.icon_border.texture)
	end
	iconBorder:SetVertexColor(unpack(data.icon_border.color))
	iconBorder:SetSize(data.icon_border.size)
	iconBorder:SetOffset(data.icon_border.offset)

	-- .IconHL
	local iconHL = toast.IconHL
	if not data.icon_highlight.hidden then
		if type(data.icon_highlight.texture) == "table" then
			iconHL:SetColorTexture(unpack(data.icon_highlight.texture))
		else
			iconHL:SetTexture(data.icon_highlight.texture)
		end
		iconHL:SetTexCoord(unpack(data.icon_highlight.tex_coords))
		iconHL.isHidden = false
	else
		iconHL.isHidden = true
	end

	-- .IconText1
	local iconText1 = toast.IconText1
	iconText1:SetFont(fontPath, fontSize, data.icon_text_1.flags)
	iconText1:SetVertexColor(unpack(data.icon_text_1.color))
	iconText1:SetPoint("BOTTOMRIGHT", 0, 1)
	iconText1:SetJustifyH("RIGHT")
	iconText1:SetShadowOffset(data.icon_text_1.shadow and 1 or 0, data.icon_text_1.shadow and -1 or 0)

	-- .IconText1
	local iconText2 = toast.IconText2
	iconText2:SetFont(fontPath, fontSize, data.icon_text_2.flags)
	iconText2:SetVertexColor(unpack(data.icon_text_2.color))
	iconText2:SetPoint("BOTTOMRIGHT", iconText1, "TOPRIGHT", 0, 2)
	iconText2:SetJustifyH("RIGHT")
	iconText2:SetShadowOffset(data.icon_text_2.shadow and 1 or 0, data.icon_text_2.shadow and -1 or 0)

	-- .Skull
	toast.Skull.isHidden = data.skull.hidden

	for i = 1, 5 do
		local slot = toast["Slot"..i]

		-- .Mask
		slot.Mask:SetTexture(data.slot.mask, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")

		-- .Border
		slot.Border:SetTexture(data.slot.texture)
		slot.Border:SetTexCoord(unpack(data.slot.tex_coords))
	end
end

local function resetSkin(toast)
	local data = skins[C.db.profile.skin] or skins["default"]

	-- .Border
	toast.Border:SetVertexColor(unpack(data.border.color))

	-- .BG
	-- local bg = toast.BG
	toast.BG:SetDesaturated(data.bg.desaturated)
	toast.BG:SetTexture(data.bg.default)

	-- .Title
	toast.Title:SetVertexColor(unpack(data.title.color))
	-- .Text
	toast.Text:SetVertexColor(unpack(data.text.color))

	-- .Icon
	toast.Icon:SetTexCoord(unpack(data.icon.tex_coords))

	-- .IconBorder
	toast.IconBorder:SetVertexColor(unpack(data.icon_border.color))

	-- .IconHL
	if not toast.IconHL.isHidden then
		toast.IconHL:SetTexCoord(unpack(data.icon_highlight.tex_coords))
	end

	-- .IconText1
	toast.IconText1:SetVertexColor(unpack(data.icon_text_1.color))

	-- .IconText1
	toast.IconText2:SetVertexColor(unpack(data.icon_text_2.color))
end

function E.RegisterSkin(_, id, data)
	if type(id) ~= "string" then
		error("invalid id", 2)
		return
	elseif skins[id] then
		error("id taken", 2)
		return
	elseif type(data) ~= "table" then
		error("invalid data", 2)
		return
	elseif type(data.name) ~= "string" then
		error("invalid name", 2)
		return
	end

	local template = data.template or "default"
	if id ~= "default" then
		if skins[template] then
			mergeTable(skins[template], data)
		else
			error("ivalid template ref", 2)
			return
		end
	end

	skins[id] = data
	skinList[id] = data.name
end

function E.GetSkin()
	return skins[C.db.profile.skin] or skins["default"]
end

function E.SetSkin(_, id)
	if type(id) ~= "string" then
		error("invalid id", 2)
		return
	elseif not skins[id] then
		error("no skin", 2)
		return
	end

	C.db.profile.skin = id

	-- reskin already created toasts here

	return true
end

function E.GetSkinList()
	return skinList
end

function E.ApplySkin(_, toast)
	applySkin(toast)
end

function E.ResetSkin(_, toast)
	resetSkin(toast)
end
