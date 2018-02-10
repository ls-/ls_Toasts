local _, addonTable = ...
local E, C = addonTable.E, addonTable.C

-- Lua
local _G = getfenv(0)

-- Mine
E:RegisterSkin("default", {
	name = "Default",
	border = {
		size = 16,
		offset = -6,
		texture = "Interface\\AddOns\\ls_Toasts\\assets\\toast-border",
		color = {1, 1, 1},
	},
	title = {
		font_object = "GameFontNormal",
		color = {1, 0.82, 0},
	},
	text = {
		font_object = "GameFontNormal",
		color = {1, 1, 1},
	},
	bonus = {
		hidden = false,
	},
	dragon = {
		hidden = false,
	},
	icon = {
		tex_coords = {4 / 64, 60 / 64, 4 / 64, 60 / 64},
	},
	icon_border = {
		size = 16,
		offset = -4,
		texture = "Interface\\AddOns\\ls_Toasts\\assets\\icon-border",
		color = {1, 1, 1},
	},
	icon_highlight = {
		texture = "Interface\\ContainerFrame\\UI-Icon-QuestBorder",
		tex_coords = {4 / 64, 60 / 64, 4 / 64, 60 / 64},
		hidden = false,
	},
	icon_text_1 = {
		font_object = "GameFontNormalOutline",
		color = {1, 1, 1}
	},
	icon_text_2 = {
		font_object = "GameFontNormalOutline",
		color = {1, 1, 1}
	},
	skull = {
		hidden = false,
	},
	slot = {
		mask = "Interface\\CHARACTERFRAME\\TempPortraitAlphaMaskSmall",
		texture = "Interface\\AddOns\\ls_Toasts\\assets\\slot-border",
		tex_coords = {28 / 128, 100 / 128, 28 / 128, 100 / 128},
	},
})
