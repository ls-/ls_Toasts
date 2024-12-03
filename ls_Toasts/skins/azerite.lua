local _, addonTable = ...
local E, C = addonTable.E, addonTable.C

-- Lua
local _G = getfenv(0)

-- Mine
E:RegisterSkin("azerite", {
	name = "AzeriteUI",
	border = {
		offset = -16,
		size = 32,
		texture = "Interface\\AddOns\\ls_Toasts\\assets\\toast-border-azerite",
	},
	icon_border = {
		offset = -8,
		size = 16,
		texture = "Interface\\AddOns\\ls_Toasts\\assets\\icon-border-azerite",
	},
})

E:RegisterSkin("azerite-no-art", {
	name = "AzeriteUI (No Artwork)",
	template = "azerite",
	text_bg = {
		hidden = true,
	},
	leaves = {
		hidden = true,
	},
	dragon = {
		hidden = true,
	},
	icon_highlight = {
		hidden = true,
	},
	bg = {
		default = {
			texture = {0.06, 0.06, 0.06, 0.8},
		},
	},
})

E:RegisterSkin("azerite-legacy", {
	name = "AzeriteUI (Legacy)",
	template = "default-legacy",
	border = {
		offset = -16,
		size = 32,
		texture = "Interface\\AddOns\\ls_Toasts\\assets\\toast-border-azerite",
	},
	icon_border = {
		offset = -8,
		size = 16,
		texture = "Interface\\AddOns\\ls_Toasts\\assets\\icon-border-azerite",
	},
})

E:RegisterSkin("azerite-twotone", {
	name = "AzeriteUI (Two Tone)",
	template = "azerite",
	title = {
		color = {0.15, 0.15, 0.15},
	},
	text_bg = {
		hidden = true,
	},
	bg = {
		default = {
			texture = "Interface\\AddOns\\ls_Toasts\\assets\\toast-bg-default-as",
		},
	},
})
