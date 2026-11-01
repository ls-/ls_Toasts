local _, addon = ...
local E, P, C, D, L, LEM = addon.E, addon.P, addon.C, addon.D, addon.L, addon.LibEditMode
addon.Anchor = {}

-- Lua
local _G = getfenv(0)
local m_floor = _G.math.floor
local next = _G.next
local s_format = _G.string.format
local t_insert = _G.table.insert
local tonumber = _G.tonumber
local tostring = _G.tostring
local unpack = _G.unpack
local type = _G.type
local m_random = _G.math.random

-- Mine
local anchors = {}
local activeAnchors = {}
local options = {}

local costructAnchor
do
	local constructDummyToast
	do
		local icons = {
			"Interface\\ICONS\\Spell_Misc_EmotionAfraid",
			"Interface\\ICONS\\Spell_Misc_EmotionAngry",
			"Interface\\ICONS\\Spell_Misc_EmotionHappy",
			"Interface\\ICONS\\Spell_Misc_EmotionSad",
		}

		local function dummyToastOnShow(self)
			local config = addon:GetAnchorConfigByID(self:GetID())

			self:SetScale(config.scale)

			local skin = P:GetSkin(C.db.profile.skin)
			local fontPath = LibStub("LibSharedMedia-3.0"):Fetch("font", C.db.profile.font.name)
			local fontSize = C.db.profile.font.size

			-- .BG
			local bg = self.BG
			if type(skin.bg.default.texture) == "table" then
				bg:SetColorTexture(unpack(skin.bg.default.texture))
				bg:SetHorizTile(false)
				bg:SetVertTile(false)
				bg:SetTexCoord(1, 0, 1, 0)
			else
				if skin.bg.default.tile then
					bg:SetTexture(skin.bg.default.texture, "REPEAT", "REPEAT")
					bg:SetHorizTile(true)
					bg:SetVertTile(true)
					bg:SetTexCoord(1, 0, 1, 0)
				else
					bg:SetTexture(skin.bg.default.texture)
					bg:SetHorizTile(false)
					bg:SetVertTile(false)
					bg:SetTexCoord(unpack(skin.bg.default.tex_coords))
				end
			end

			bg:SetVertexColor(unpack(skin.bg.default.color))

			-- .Border
			local border = self.Border
			border:SetTexture(skin.border.texture)
			border:SetVertexColor(unpack(skin.border.color))
			border:SetSize(skin.border.size)
			border:SetOffset(skin.border.offset)

			-- .Title
			local title = self.Title
			title:SetFont(fontPath, fontSize, skin.title.flags)
			title:SetVertexColor(unpack(skin.title.color))
			title:SetJustifyH("CENTER")
			title:SetJustifyV("MIDDLE")
			title:SetWordWrap(false)
			title:SetShadowOffset(skin.title.shadow and 1 or 0, skin.title.shadow and -1 or 0)

			-- .Text
			local text = self.Text
			text:SetFont(fontPath, fontSize, skin.text.flags)
			text:SetVertexColor(unpack(skin.text.color))
			text:SetJustifyH("CENTER")
			text:SetJustifyV("MIDDLE")
			text:SetWordWrap(true)
			text:SetShadowOffset(skin.text.shadow and 1 or 0, skin.text.shadow and -1 or 0)

			-- .TextBG
			local textBG = self.TextBG
			textBG:SetShown(not skin.text_bg.hidden)
			textBG.isHidden = skin.text_bg.hidden

			-- .Icon
			self.Icon:SetTexCoord(unpack(skin.icon.tex_coords))

			-- .IconBorder
			local iconBorder = self.IconBorder
			iconBorder:SetTexture(skin.icon_border.texture)
			iconBorder:SetVertexColor(unpack(skin.icon_border.color))
			iconBorder:SetSize(skin.icon_border.size)
			iconBorder:SetOffset(skin.icon_border.offset)

			self.Title:SetText("You Broke!")
			self.Text:SetText("Something, Probably /jk")
			self.Icon:SetTexture(icons[m_random(1, 4)])
			self.IconBorder:Show()
		end

		function constructDummyToast(anchor, anchorID)
			local toast = CreateFrame("Button", "$parentDummyToast", anchor)
			toast:SetID(anchorID)
			toast:SetFlattensRenderLayers(true)
			toast:SetSize(224, 48)
			toast:SetPoint("TOPLEFT", anchor, "TOPLEFT", 0, 0)
			toast:SetScript("OnShow", dummyToastOnShow)
			toast:Hide()

			local bg = toast:CreateTexture(nil, "BACKGROUND", nil, -8)
			bg:SetAllPoints()
			toast.BG = bg

			local border = addon.Border:Create(toast, "BACKGROUND", 1)
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
			toast.Text = text

			local textBG = toast:CreateTexture(nil, "BACKGROUND", nil, 1)
			textBG:SetPoint("TOPLEFT", 50, -2)
			textBG:SetPoint("BOTTOMRIGHT", -2, 2)
			textBG:SetTexture("Interface\\AddOns\\ls_Toasts\\assets\\text-bg")
			textBG:SetTexCoord(1 / 256, 173 / 256, 1 / 64, 45 / 64)
			textBG:SetVertexColor(0, 0, 0)
			toast.TextBG = textBG

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

			local iconBorder = addon.Border:Create(iconParent, "BACKGROUND", 5)
			toast.IconBorder = iconBorder

			return toast
		end
	end

	local function anchorOnSizeChanged(self)
		if self.isEditing then
			local config = addon:GetAnchorConfigByID(self:GetID())

			self.DummyToast:SetScale(config.scale)
		end
	end

	local function onPositionChanged(anchor, layoutName, point, x, y)
		C.db.profile.layouts[layoutName].anchors[anchor:GetID()].point.point = point
		C.db.profile.layouts[layoutName].anchors[anchor:GetID()].point.x = x
		C.db.profile.layouts[layoutName].anchors[anchor:GetID()].point.y = y
	end

	local function floatFormatter(value)
		return s_format("%.1f", value)
	end

	function costructAnchor(index)
		local anchor = CreateFrame("Button", "LSToastAnchor" .. index, UIParent)
		anchor:SetID(index)
		anchor:SetClampedToScreen(true)
		anchor:SetClampRectInsets(-4, 4, 4, -4)
		anchor:SetScript("OnSizeChanged", anchorOnSizeChanged)
		anchor:Hide()

		anchor.DummyToast = constructDummyToast(anchor, index)

		LEM:AddFrame(anchor, onPositionChanged, D.profile.layouts["*"].anchors["**"].point, L["ANCHOR_FRAME_#"]:format(index))

		LEM:AddFrameSettings(anchor, {
			{
				name = L["TOAST_NUM"],
				desc = L["DEFAULT_VALUE"]:format(D.profile.layouts["*"].anchors["**"].max_active_toasts),
				kind = LEM.SettingType.Slider,
				default = D.profile.layouts["*"].anchors["**"].max_active_toasts,
				get = function(layoutName)
					return C.db.profile.layouts[layoutName].anchors[index].max_active_toasts
				end,
				set = function(layoutName, value)
					if C.db.profile.layouts[layoutName].anchors[index].max_active_toasts ~= value then
						C.db.profile.layouts[layoutName].anchors[index].max_active_toasts = value
					end
				end,
				minValue = 1,
				maxValue = 20,
				valueStep = 1,
			},
			{
				name = _G.HUD_EDIT_MODE_SETTING_BAGS_SIZE,
				desc = L["DEFAULT_VALUE"]:format(D.profile.layouts["*"].anchors["**"].scale),
				kind = LEM.SettingType.Slider,
				default = D.profile.layouts["*"].anchors["**"].scale,
				get = function(layoutName)
					return C.db.profile.layouts[layoutName].anchors[index].scale
				end,
				set = function(layoutName, value)
					if C.db.profile.layouts[layoutName].anchors[index].scale ~= value then
						C.db.profile.layouts[layoutName].anchors[index].scale = m_floor((value + 0.005) * 100) / 100

						P:UpdateScale(index)
					end
				end,
				minValue = 0.5,
				maxValue = 2,
				valueStep = 0.01,
				formatter = FormatPercentageRounded,
			},
			{
				name = L["FADE_OUT_DELAY"],
				desc = L["DEFAULT_VALUE"]:format(D.profile.layouts["*"].anchors["**"].fadeout_delay),
				kind = LEM.SettingType.Slider,
				default = D.profile.layouts["*"].anchors["**"].fadeout_delay,
				get = function(layoutName)
					return C.db.profile.layouts[layoutName].anchors[index].fadeout_delay
				end,
				set = function(layoutName, value)
					if C.db.profile.layouts[layoutName].anchors[index].fadeout_delay ~= value then
						C.db.profile.layouts[layoutName].anchors[index].fadeout_delay = m_floor((value + 0.05) * 10) / 10

						P:UpdateFadeOutDelay(index)
					end
				end,
				minValue = 0.8,
				maxValue = 30,
				valueStep = 0.1,
				formatter = floatFormatter,
			},
			{
				name = L["GROWTH"],
				kind = LEM.SettingType.Divider,
			},
			{
				name = _G.HUD_EDIT_MODE_SETTING_BAGS_DIRECTION,
				kind = LEM.SettingType.Dropdown,
				default = D.profile.layouts["*"].anchors["**"].growth_direction,
				get = function(layoutName)
					return C.db.profile.layouts[layoutName].anchors[index].growth_direction
				end,
				set = function(layoutName, value)
					if C.db.profile.layouts[layoutName].anchors[index].growth_direction ~= value then
						C.db.profile.layouts[layoutName].anchors[index].growth_direction = value

						P:RefreshQueues()
					end
				end,
				values = {
					{
						isRadio = true,
						text = _G.HUD_EDIT_MODE_SETTING_BAGS_DIRECTION_UP,
						value = "UP",
					},
					{
						isRadio = true,
						text = _G.HUD_EDIT_MODE_SETTING_BAGS_DIRECTION_DOWN,
						value = "DOWN",
					},
					{
						isRadio = true,
						text = _G.HUD_EDIT_MODE_SETTING_BAGS_DIRECTION_LEFT,
						value = "LEFT",
					},
					{
						isRadio = true,
						text = _G.HUD_EDIT_MODE_SETTING_BAGS_DIRECTION_RIGHT,
						value = "RIGHT",
					},
				},
			},
			{
				name = L["OFFSET_X"],
				desc = L["DEFAULT_VALUE"]:format(D.profile.layouts["*"].anchors["**"].growth_offset_x),
				kind = LEM.SettingType.Slider,
				default = D.profile.layouts["*"].anchors["**"].growth_offset_x,
				get = function(layoutName)
					return C.db.profile.layouts[layoutName].anchors[index].growth_offset_x
				end,
				set = function(layoutName, value)
					if C.db.profile.layouts[layoutName].anchors[index].growth_offset_x ~= value then
						C.db.profile.layouts[layoutName].anchors[index].growth_offset_x = value

						P:RefreshQueues()
					end
				end,
				minValue = 4,
				maxValue = 48,
				valueStep = 1,
			},
			{
				name = L["OFFSET_Y"],
				desc = L["DEFAULT_VALUE"]:format(D.profile.layouts["*"].anchors["**"].growth_offset_y),
				kind = LEM.SettingType.Slider,
				default = D.profile.layouts["*"].anchors["**"].growth_offset_y,
				get = function(layoutName)
					return C.db.profile.layouts[layoutName].anchors[index].growth_offset_y
				end,
				set = function(layoutName, value)
					if C.db.profile.layouts[layoutName].anchors[index].growth_offset_y ~= value then
						C.db.profile.layouts[layoutName].anchors[index].growth_offset_y = value

						P:RefreshQueues()
					end
				end,
				minValue = 4,
				maxValue = 48,
				valueStep = 1,
			},
		})

		LEM:RegisterCallback("enter", function()
			if not activeAnchors[index] then return end

			anchor.isEditing = true
			anchor.DummyToast:Show()
		end)

		LEM:RegisterCallback("exit", function()
			if not activeAnchors[index] then return end

			anchor.isEditing = false
			anchor.DummyToast:Hide()
		end)

		t_insert(anchors, index, anchor)

		return anchor
	end
end

local addAnchor
do
	local function delete(info)
		addon:RemoveAnchorConfigByID(tonumber(info[#info - 1]))
		addon:UpdateLayoutSettings()
		addon.Anchor:UpdateOptions()
	end

	local function resetPosition(info)
		addon:ResetAnchorPointByID(tonumber(info[#info - 1]))
		addon:UpdateLayoutSettings()
	end

	local function getAnchorForType(info)
		return addon:GetAnchorIDForType(info[#info]) == tonumber(info[#info - 1])
	end

	local function setAnchorForType(info)
		addon:GetTypeConfigs()[info[#info]] = tonumber(info[#info - 1])
	end

	function addAnchor(index)
		if not activeAnchors[index] then
			-- while a pool could be used here, it's rarely used, so it's not worth it
			activeAnchors[index] = anchors[index] or costructAnchor(index)

			P:SetUpQueues(index)

			if not options[index] then
				options[index] = {
					order = 9 + index,
					type = "group",
					name = L["ANCHOR_FRAME_#"]:format(index),
					inline = true,
					get = getAnchorForType,
					set = setAnchorForType,
					args = {
						spacer_1 = {
							order = 9996,
							type = "description",
							name = " ",
						},
						reset = {
							order = 9997,
							name = _G.HUD_EDIT_MODE_RESET_POSITION,
							type = "execute",
							width = "full",
							func = resetPosition,
						},
					},
				}

				if index ~= 1 then
					options[index].args.delete = {
						order = 9999,
						name = L["DELETE"],
						type = "execute",
						width = "full",
						func = delete,
					}
				end
			end

			C.options.args.anchors.args[tostring(index)] = options[index]
		end
	end
end

local function removeAnchor(index)
	if index ~= 1 and activeAnchors[index] then

		activeAnchors[index]:Hide()
		activeAnchors[index].DummyToast:Hide()
		activeAnchors[index] = nil

		C.options.args.anchors.args[tostring(index)] = nil
	end
end

local function layoutCallback(layoutName)
	-- AceDB takes care of layout table duplication
	local layout = C.db.profile.layouts[layoutName]
	local numAnchorConfigs = addon:GetNumAnchorConfigs()

	P:FlushQueue()

	for i = 1, numAnchorConfigs do
		addAnchor(i)
	end

	for i = numAnchorConfigs + 1, #anchors do
		removeAnchor(i)
	end

	for _, anchor in next, activeAnchors do
		local id = anchor:GetID()
		local config = layout.anchors[id]

		-- it's here because of the anchor #1 whose config isn't created via AddAnchorConfigByID, instead of
		-- overcomplicating things I'll just reassign ids here
		config.id = id

		anchor:SetSize(224 * config.scale, 48 * config.scale)
		anchor:ClearAllPoints()
		anchor:SetPoint(config.point.point, config.point.x, config.point.y)
		anchor:SetShown(LEM.isEditing)
	end
end

LEM:RegisterCallback("layout", layoutCallback)

LEM:RegisterCallback("enter", function()
	for _, anchor in next, activeAnchors do
		anchor:Show()
	end
end)

LEM:RegisterCallback("exit", function()
	for _, anchor in next, activeAnchors do
		anchor:Hide()
	end
end)

LEM:RegisterCallback("create", function(newLayoutName, _, sourceLayoutName)
	if sourceLayoutName then
		addon:CopyTable(C.db.profile.layouts[sourceLayoutName], C.db.profile.layouts[newLayoutName])
	end
end)

LEM:RegisterCallback("delete", function(oldLayoutName)
	C.db.profile.layouts[oldLayoutName] = nil
end)

LEM:RegisterCallback("rename", function(oldLayoutName, newLayoutName)
	addon:CopyTable(C.db.profile.layouts[oldLayoutName], C.db.profile.layouts[newLayoutName])

	C.db.profile.layouts[oldLayoutName] = nil
end)

function addon:UpdateLayoutSettings()
	layoutCallback(LEM:GetActiveLayoutName())
end

function addon.Anchor:Get(index)
	return activeAnchors[index]
end

function addon.Anchor:UpdateOptions()
	for index = 1, addon:GetNumAnchorConfigs() do
		index = tostring(index)

		for type in next, C.db.profile.types do
			if C.options.args.types.args[type] and C.options.args.anchors.args[index] and not C.options.args.anchors.args[index].args[type] then
				C.options.args.anchors.args[index].args[type] = {
					order = C.options.args.types.args[type].order,
					type = "toggle",
					name = C.options.args.types.args[type].name,
				}
			end
		end
	end
end
