local _, addonTable = ...
local E, C = addonTable.E, addonTable.C

-- Lua
local _G = getfenv(0)

E:RegisterSkin("beautycase", {
	name = "Beautycase",
	leaves = {
		points = {
			{x = -4, y = 18}, -- topleft
			{x = 12, y = 12}, -- topright
			{y = -14}, -- bottomright
		},
	},
	border = {
		offset = -4,
		texture = "Interface\\AddOns\\ls_Toasts\\assets\\toast-border-beautycase",
	},
})

E:RegisterSkin("beautycase-legacy", {
	name = "Beautycase (Legacy)",
	template = "beautycase",
	bg = {
		default = {
			color = {1, 1, 1},
			texture = "Interface\\AddOns\\ls_Toasts\\assets\\legacy\\toast-bg-default",
			tex_coords = {1 / 256, 225 / 256, 1 / 64, 49 / 64},
			tile = false,
		},
		legendary = {
			color = {1, 1, 1},
			texture = "Interface\\AddOns\\ls_Toasts\\assets\\legacy\\toast-bg-legendary",
			tex_coords = {1 / 256, 225 / 256, 1 / 64, 49 / 64},
			tile = false,
		},
	},
})

E:RegisterSkin("beautycase-no-art", {
	name = "Beautycase (No Artwork)",
	template = "beautycase",
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

E:RegisterSkin("beautycase-twotone", {
	name = "Beautycase (Two Tone)",
	template = "beautycase",
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
