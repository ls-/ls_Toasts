local _, addonTable = ...
local E, C = addonTable.E, addonTable.C

-- Lua
local _G = getfenv(0)
local error = _G.error
local next = _G.next
local s_format = _G.string.format
local type = _G.type
local unpack = _G.unpack

--[[ luacheck: globals
	LibStub
]]

-- Mine
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

function E.RegisterSkin(_, id, data)
	if type(id) ~= "string" then
		error(s_format("Invalid argument #1 to 'RegisterSkin' method, expected a string, got a '%s'", type(id)), 2)
		return
	elseif skins[id] then
		error(s_format("Invalid argument #1 to 'RegisterSkin' method, '%s' id is already taken", id), 2)
		return
	elseif type(data) ~= "table" then
		error(s_format("Invalid argument #2 to 'RegisterSkin' method, expected a table, got a '%s'", type(data)), 2)
		return
	elseif type(data.name) ~= "string" then
		error(s_format("Invalid skin name, expected a string, got a '%s'", type(data.name)), 2)
		return
	end

	local template = data.template or "default"
	if id ~= "default" then
		if skins[template] then
			mergeTable(skins[template], data)
		else
			error(s_format("Invalid template reference, skin '%s' doesn't exist", template), 2)
			return
		end
	end

	skins[id] = data
	skinList[id] = data.name
end

function E.CheckResetDefaultSkin()
	if not skins[C.db.profile.skin] then
		C.db.profile.skin = "default"
	end
end

function E.GetSkinList()
	return skinList
end

function E.GetSkin()
	return skins[C.db.profile.skin] or skins["default"]
end

function E.SetSkin(_, id)
	if type(id) ~= "string" then
		error(s_format("Invalid argument to 'SetSkin' method, expected a string, got a '%s'", type(id)), 2)
		return
	elseif not skins[id] then
		error(s_format("Invalid skin reference, skin '%s' doesn't exist", id), 2)
		return
	end

	C.db.profile.skin = id

	for _, toast in next, E:GetToasts() do
		E:ApplySkin(toast)
	end

	return true
end

function E.ApplySkin(_, toast)
	local skin = skins[C.db.profile.skin] or skins["default"]
	local fontPath = LibStub("LibSharedMedia-3.0"):Fetch("font", C.db.profile.font.name)
	local fontSize = C.db.profile.font.size

	-- .Border
	local border = toast.Border
	border:SetTexture(skin.border.texture)
	border:SetVertexColor(unpack(skin.border.color))
	border:SetSize(skin.border.size)
	border:SetOffset(skin.border.offset)

	-- .BG
	toast:SetBackground("default")

	-- .Title
	local title = toast.Title
	title:SetFont(fontPath, fontSize, skin.title.flags)
	title:SetVertexColor(unpack(skin.title.color))
	title:SetJustifyH("CENTER")
	title:SetJustifyV("MIDDLE")
	title:SetWordWrap(false)
	title:SetShadowOffset(skin.title.shadow and 1 or 0, skin.title.shadow and -1 or 0)

	-- .Text
	local text = toast.Text
	text:SetFont(fontPath, fontSize, skin.text.flags)
	text:SetVertexColor(unpack(skin.text.color))
	text:SetJustifyH("CENTER")
	text:SetJustifyV("MIDDLE")
	text:SetWordWrap(false)
	text:SetShadowOffset(skin.text.shadow and 1 or 0, skin.text.shadow and -1 or 0)

	-- .TextBG
	local textBG = toast.TextBG
	textBG:SetShown(not skin.text_bg.hidden)
	textBG.isHidden = skin.text_bg.hidden

	-- .Bonus
	toast.Bonus.isHidden = skin.bonus.hidden

	-- .Dragon
	toast.Dragon.isHidden = skin.dragon.hidden

	-- .Icon
	toast.Icon:SetTexCoord(unpack(skin.icon.tex_coords))

	-- .IconBorder
	local iconBorder = toast.IconBorder
	iconBorder:SetTexture(skin.icon_border.texture)
	iconBorder:SetVertexColor(unpack(skin.icon_border.color))
	iconBorder:SetSize(skin.icon_border.size)
	iconBorder:SetOffset(skin.icon_border.offset)

	-- .IconHL
	local iconHL = toast.IconHL
	if not skin.icon_highlight.hidden then
		if type(skin.icon_highlight.texture) == "table" then
			iconHL:SetColorTexture(unpack(skin.icon_highlight.texture))
			iconHL:SetTexCoord(1, 0, 1, 0)
		else
			iconHL:SetTexture(skin.icon_highlight.texture)
			iconHL:SetTexCoord(unpack(skin.icon_highlight.tex_coords))
		end
		iconHL.isHidden = false
	else
		iconHL.isHidden = true
	end

	-- .IconText1
	local iconText1 = toast.IconText1
	iconText1:SetFont(fontPath, fontSize, skin.icon_text_1.flags)
	iconText1:SetVertexColor(unpack(skin.icon_text_1.color))
	iconText1:SetPoint("BOTTOMRIGHT", 0, 1)
	iconText1:SetJustifyH("RIGHT")
	iconText1:SetShadowOffset(skin.icon_text_1.shadow and 1 or 0, skin.icon_text_1.shadow and -1 or 0)

	-- .IconText1
	local iconText2 = toast.IconText2
	iconText2:SetFont(fontPath, fontSize, skin.icon_text_2.flags)
	iconText2:SetVertexColor(unpack(skin.icon_text_2.color))
	iconText2:SetPoint("BOTTOMRIGHT", iconText1, "TOPRIGHT", 0, 2)
	iconText2:SetJustifyH("RIGHT")
	iconText2:SetShadowOffset(skin.icon_text_2.shadow and 1 or 0, skin.icon_text_2.shadow and -1 or 0)

	-- .Skull
	toast.Skull.isHidden = skin.skull.hidden

	for i = 1, 5 do
		local slot = toast["Slot" .. i]

		-- .Icon
		slot.Icon:SetTexCoord(unpack(skin.slot.tex_coords))

		-- .Border
		local slotBorder = slot.Border
		slotBorder:SetTexture(skin.slot_border.texture)
		slotBorder:SetVertexColor(unpack(skin.slot_border.color))
		slotBorder:SetSize(skin.slot_border.size)
		slotBorder:SetOffset(skin.slot_border.offset)
	end

	-- .Glow
	local glow = toast.Glow
	glow:SetSize(unpack(skin.glow.size))
	glow:SetPoint(skin.glow.point.p, toast, skin.glow.point.rP, skin.glow.point.x, skin.glow.point.y)
	if type(skin.glow.texture) == "table" then
		glow:SetColorTexture(unpack(skin.glow.texture))
		glow:SetTexCoord(1, 0, 1 ,0)
	else
		glow:SetTexture(skin.glow.texture)
		glow:SetTexCoord(unpack(skin.glow.tex_coords))
	end
	glow:SetVertexColor(unpack(skin.glow.color))

	-- .Shine
	local shine = toast.Shine
	shine:SetSize(unpack(skin.shine.size))
	shine:SetPoint(skin.shine.point.p, toast, skin.shine.point.rP, skin.shine.point.x, skin.shine.point.y)
	if type(skin.shine.texture) == "table" then
		shine:SetColorTexture(unpack(skin.shine.texture))
		shine:SetTexCoord(1, 0, 1 ,0)
	else
		shine:SetTexture(skin.shine.texture)
		shine:SetTexCoord(unpack(skin.shine.tex_coords))
	end
	shine:SetVertexColor(unpack(skin.shine.color))

	toast.AnimIn.Anim5:SetOffset(224 - skin.shine.size[1], 0)
end

function E.ResetSkin(_, toast)
	local skin = skins[C.db.profile.skin] or skins["default"]

	-- .Border
	toast.Border:SetVertexColor(unpack(skin.border.color))

	-- .BG
	toast:SetBackground("default")

	-- .Title
	toast.Title:SetVertexColor(unpack(skin.title.color))
	-- .Text
	toast.Text:SetVertexColor(unpack(skin.text.color))

	-- .Icon
	toast.Icon:SetTexCoord(unpack(skin.icon.tex_coords))

	-- .IconBorder
	toast.IconBorder:SetVertexColor(unpack(skin.icon_border.color))

	-- .IconText1
	toast.IconText1:SetVertexColor(unpack(skin.icon_text_1.color))

	-- .IconText1
	toast.IconText2:SetVertexColor(unpack(skin.icon_text_2.color))

	-- .Glow
	toast.Glow:SetVertexColor(unpack(skin.glow.color))

	-- .Shine
	toast.Shine:SetVertexColor(unpack(skin.shine.color))
end
