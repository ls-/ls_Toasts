local _, addon = ...
local C, D, LEM = addon.C, addon.D, addon.LibEditMode

-- Lua
local _G = getfenv(0)
local next = _G.next

-- Mine
do
	local DEFAULT_PRESET
	local defaultIndex = 0

	if C_EditMode.GetEditModeDefaultLayout then
		defaultIndex = C_EditMode.GetEditModeDefaultLayout()
	elseif Constants.EditModeLayoutConsts then
		defaultIndex = Constants.EditModeLayoutConsts.EditModeDefaultLayout
	end

	for k, v in next, Enum.EditModePresetLayouts do
		if v == defaultIndex then
			DEFAULT_PRESET = k
		end
	end

	function addon:GetActiveLayoutName()
		return LEM:GetActiveLayoutName() or DEFAULT_PRESET
	end
end

function addon:GetNumAnchorConfigs()
	local num = #C.db.profile.layouts[addon:GetActiveLayoutName()].anchors
	if num == 0 then
		num = 1
	end

	return num
end

function addon:GetAnchorConfigByID(id)
	return C.db.profile.layouts[addon:GetActiveLayoutName()].anchors[id]
end

function addon:AddAnchorConfigByID(id)
	local config = C.db.profile.layouts[addon:GetActiveLayoutName()].anchors[id]
	config.id = id
end

function addon:RemoveAnchorConfigByID(id)
	local layout = C.db.profile.layouts[addon:GetActiveLayoutName()]
	layout.anchors[id] = nil

	for name, anchorID in next, layout.types do
		if anchorID == id then
			layout.types[name] = 1
		end
	end
end

function addon:GetTypeConfigs()
	return C.db.profile.layouts[addon:GetActiveLayoutName()].types
end

function addon:GetAnchorIDForType(name)
	return C.db.profile.layouts[addon:GetActiveLayoutName()].types[name]
end

function addon:ResetAnchorPointByID(id)
	local config = C.db.profile.layouts[addon:GetActiveLayoutName()].anchors[id]
	config.point = {
		point = "TOPLEFT",
		x = 26,
		y = -14,
	}
end

local function rgb(...)
	return addon:CreateColor(...)
end

D.global = {
	colors = {
		addon = rgb(28, 211, 162), -- #1CD3A2 (Crayola Carribean Green)
	},
}

D.profile = {
	strata = "DIALOG",
	skin = "default",
	font = {
		-- name = nil,
		size = 12,
	},
	colors = {
		name = false,
		border = true,
		icon_border = true,
		threshold = 1,
	},
	types = {},
	layouts = {
		["*"] = {
			types = {
				["**"] = 1,
			},
			anchors = {
				["**"] = {
					id = 0,
					fadeout_delay = 2.8,
					growth_direction = "DOWN",
					growth_offset_x = 26,
					growth_offset_y = 14,
					max_active_toasts = 12,
					scale = 1,
					point = {
						point = "TOPLEFT",
						x = 26,
						y = -14,
					},
				},
			},
		},
	},
}
