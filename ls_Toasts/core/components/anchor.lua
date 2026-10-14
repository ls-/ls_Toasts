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

-- Mine
local anchors = {}
local activeAnchors = {}
local options = {}

local costructAnchor
do
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
		anchor:Hide()

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
					args = {},
				}

				if index ~= 1 then
					options[index].args.spacer_2 = {
						order = 9998,
						type = "description",
						name = " ",
					}
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
