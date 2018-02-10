local _, addonTable = ...
local E, C = addonTable.E, addonTable.C

-- Lua
local _G = getfenv(0)
local setmetatable = _G.setmetatable
local type = _G.type
local unpack = _G.unpack

-- Mine
local skins = {}
local skinList = {}

local function skinToast(toast)
	local data = skins[C.db.profile.skin] or skins["default"]

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

	-- .Title
	local title = toast.Title
	title:SetFontObject(data.title.font_object)
	title:SetVertexColor(unpack(data.title.color))
	title:SetJustifyH("CENTER")
	title:SetJustifyV("MIDDLE")
	title:SetWordWrap(false)

	-- .Text
	local text = toast.Text
	text:SetFontObject(data.text.font_object)
	text:SetVertexColor(unpack(data.text.color))
	text:SetJustifyH("CENTER")
	text:SetJustifyV("MIDDLE")
	text:SetWordWrap(false)

	-- .Bonus
	local bonus = toast.Bonus
	bonus.isHidden = data.bonus.hidden

	-- .Dragon
	local dragon = toast.Dragon
	dragon.isHidden = data.dragon.hidden

	-- .Icon
	local icon = toast.Icon
	icon:SetTexCoord(unpack(data.icon.tex_coords))

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
	iconText1:SetFontObject(data.icon_text_1.font_object)
	iconText1:SetVertexColor(unpack(data.icon_text_1.color))
	iconText1:SetPoint("BOTTOMRIGHT", 0, 1)
	iconText1:SetJustifyH("RIGHT")

	-- .IconText1
	local iconText2 = toast.IconText2
	iconText2:SetFontObject(data.icon_text_2.font_object)
	iconText2:SetVertexColor(unpack(data.icon_text_2.color))
	iconText2:SetPoint("BOTTOMRIGHT", iconText1, "TOPRIGHT", 0, 2)
	iconText2:SetJustifyH("RIGHT")

	-- .Skull
	local skull = toast.Skull
	skull.isHidden = data.skull.hidden

	for i = 1, 5 do
		local slot = toast["Slot"..i]

		-- .Mask
		slot.Mask:SetTexture(data.slot.mask, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")

		-- .Border
		slot.Border:SetTexture(data.slot.texture)
		slot.Border:SetTexCoord(unpack(data.slot.tex_coords))
	end
end

local function resetToast(toast)
	local data = skins[C.db.profile.skin] or skins["default"]

	-- .Border
	-- local border = toast.Border
	toast.Border:SetVertexColor(unpack(data.border.color))

		-- .Title
	-- local title = toast.Title
	toast.Title:SetVertexColor(unpack(data.title.color))
	-- .Text
	-- local text = toast.Text
	toast.Text:SetVertexColor(unpack(data.text.color))

	-- .Icon
	-- local icon = toast.Icon
	toast.Icon:SetTexCoord(unpack(data.icon.tex_coords))

	-- .IconBorder
	-- local iconBorder = toast.IconBorder
	toast.IconBorder:SetVertexColor(unpack(data.icon_border.color))

	-- .IconHL
	-- local iconHL = toast.IconHL
	if not toast.IconHL.isHidden then
		toast.IconHL:SetTexCoord(unpack(data.icon_highlight.tex_coords))
	end

	-- .IconText1
	-- local iconText1 = toast.IconText1
	toast.IconText1:SetVertexColor(unpack(data.icon_text_1.color))

	-- .IconText1
	-- local iconText2 = toast.IconText2
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
			setmetatable(data, {__index = skins[template]})
		else
			error("ivalid template ref", 2)
			return
		end
	end

	skins[id] = data
	skinList[id] = data.name
end

function E.SetSkin(_, id)
	if type(id) ~= "string" then
		error("invalid id", 2)
		return
	elseif skins[id] then
		error("no skin", 2)
		return
	end

	C.db.profile.skin = id

	-- E:FlushToastsCache()

	return true
end

function E.GetSkinList()
	return skinList
end

function E.ApplySkin(_, toast)
	skinToast(toast)
end

function E.ResetSkin(_, toast)
	resetToast(toast)
end
