local _, addon = ...
local E, P, C, D, L, LEM = addon.E, addon.P, addon.C, addon.D, addon.L, addon.LibEditMode
addon.LayoutManager = {}

-- Lua
local _G = getfenv(0)
local next = _G.next
local s_format = _G.string.format
local t_insert = _G.table.insert
local t_wipe = _G.table.wipe

-- Mine
local defaultLayouts = {}

for name in next, Enum.EditModePresetLayouts do
	t_insert(defaultLayouts, name)
end

local function wipe(layoutName)
	local layout = C.db.profile.layouts[layoutName]
	for k in next, layout do
		t_wipe(layout[k])
	end
end

local function getLayoutList()
	local layouts = {}

	for k in next, C.db.profile.layouts do
		if k ~= "*" then
			layouts[k] = k
		end
	end

	layouts[LEM:GetActiveLayoutName()] = nil

	return layouts
end

local function list()
	return getLayoutList()
end

local function hasNoOtherLayouts()
	return not next(getLayoutList())
end

function addon.LayoutManager:GetOptionsTable(order)
	local optionsTable = {
		order = order,
		type = "group",
		name = L["LAYOUTS"],
		hidden = function()
			return not SettingsPanel:IsShown()
		end,
		args = {
			header = {
				order = 1,
				type = "description",
				name = L["LAYOUTS_DESC"],
				fontSize = "medium",
			},
			spacer_1 = {
				order = 10,
				type = "description",
				name = " ",
			},
			reset_desc = {
				order = 11,
				type = "description",
				name = L["RESET_LAYOUT_DESC"],
			},
			reset = {
				order = 12,
				type = "execute",
				name = function()
					return L["RESET_LAYOUT"]:format(LEM:GetActiveLayoutName())
				end,
				func = function()
					wipe(LEM:GetActiveLayoutName())

					addon:UpdateLayoutSettings()
				end,
				width = 2,
			},
			spacer_2 = {
				order = 20,
				type = "description",
				name = " ",
			},
			copy_desc = {
				order = 21,
				type = "description",
				name = L["COPY_LAYOUT_DESC"],
			},
			copy = {
				order = 22,
				type = "select",
				name = L["COPY"],
				get = false,
				set = function(_, value)
					local name = LEM:GetActiveLayoutName()
					wipe(name)

					addon:CopyTable(C.db.profile.layouts[value], C.db.profile.layouts[name])
					addon:UpdateLayoutSettings()
				end,
				values = list,
				disabled = hasNoOtherLayouts,
				width = 2,
			},
			spacer_3 = {
				order = 30,
				type = "description",
				name = " ",
			},
			delete_desc = {
				order = 31,
				type = "description",
				name = L["DELETE_LAYOUT_DESC"] ,
			},
			delete = {
				order = 32,
				type = "select",
				name = L["DELETE"],
				get = false,
				set = function(_, value)
					C.db.profile.layouts[value] = nil
				end,
				values = list,
				disabled = hasNoOtherLayouts,
				width = 2,
			},
			spacer_4 = {
				order = 40,
				type = "description",
				name = " ",
			},
			importexport = {
				order = 41,
				type = "execute",
				name = s_format("%s / %s", L["IMPORT"], L["EXPORT"]),
				func = addon.OpenImportExport,
				width = "full",
			},
		},
	}
	return optionsTable
end
