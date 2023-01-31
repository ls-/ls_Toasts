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
