local _, addonTable = ...
local E, C = addonTable.E, addonTable.C

-- Lua
local _G = getfenv(0)

-- Mine
E:RegisterSkin("default", {
	name = "Default",
	border = {
		color = {1, 1, 1},
		offset = -6,
		size = 16,
		texture = "Interface\\AddOns\\ls_Toasts\\assets\\toast-border",
	},
	title = {
		color = {1, 0.82, 0},
		flags = "",
		shadow = true,
	},
	text = {
		color = {1, 1, 1},
		flags = "",
		shadow = true,
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
		color = {1, 1, 1},
		offset = -4,
		size = 16,
		texture = "Interface\\AddOns\\ls_Toasts\\assets\\icon-border",
	},
	icon_highlight = {
		hidden = false,
		tex_coords = {4 / 64, 60 / 64, 4 / 64, 60 / 64},
		texture = "Interface\\ContainerFrame\\UI-Icon-QuestBorder",
	},
	icon_text_1 = {
		color = {1, 1, 1},
		flags = "THINOUTLINE",
		shadow = false,
	},
	icon_text_2 = {
		color = {1, 1, 1},
		flags = "THINOUTLINE",
		shadow = false,
	},
	skull = {
		hidden = false,
	},
	slot = {
		tex_coords = {4 / 64, 60 / 64, 4 / 64, 60 / 64}
	},
	slot_border = {
		color = {1, 1, 1},
		offset = -4,
		size = 16,
		texture = "Interface\\AddOns\\ls_Toasts\\assets\\icon-border",
	},
	glow = {
		color = {1, 1, 1},
		texture = "Interface\\AchievementFrame\\UI-Achievement-Alert-Glow",
		tex_coords = {5 / 512, 395 / 512, 5 / 256, 167 / 256},
		size = {318, 152},
		point = {
			p = "CENTER",
			rP = "CENTER",
			x = 0,
			y = 0,
		},
	},
	shine = {
		color = {1, 1, 1},
		texture = "Interface\\AchievementFrame\\UI-Achievement-Alert-Glow",
		tex_coords = {403 / 512, 465 / 512, 14 / 256, 62 / 256},
		size = {66, 52},
		point = {
			p = "BOTTOMLEFT",
			rP = "BOTTOMLEFT",
			x = 0,
			y = -2,
		},
	},
	bg = {
		alliance = {
			texture = "Interface\\AddOns\\ls_Toasts\\assets\\toast-bg-alliance",
		},
		archaeology = {
			texture = "Interface\\AddOns\\ls_Toasts\\assets\\toast-bg-archaeology",
		},
		azerite = {
			texture = "Interface\\AddOns\\ls_Toasts\\assets\\toast-bg-azerite",
		},
		collection = {
			texture = "Interface\\AddOns\\ls_Toasts\\assets\\toast-bg-collection",
		},
		default = {
			texture = "Interface\\AddOns\\ls_Toasts\\assets\\toast-bg-default",
		},
		dungeon = {
			texture = "Interface\\AddOns\\ls_Toasts\\assets\\toast-bg-dungeon",
		},
		horde = {
			texture = "Interface\\AddOns\\ls_Toasts\\assets\\toast-bg-horde",
		},
		legendary = {
			texture = "Interface\\AddOns\\ls_Toasts\\assets\\toast-bg-legendary",
		},
		legion = {
			texture = "Interface\\AddOns\\ls_Toasts\\assets\\toast-bg-legion",
		},
		recipe = {
			texture = "Interface\\AddOns\\ls_Toasts\\assets\\toast-bg-recipe",
		},
		store = {
			texture = "Interface\\AddOns\\ls_Toasts\\assets\\toast-bg-store",
		},
		transmog = {
			texture = "Interface\\AddOns\\ls_Toasts\\assets\\toast-bg-transmog",
		},
		upgrade = {
			texture = "Interface\\AddOns\\ls_Toasts\\assets\\toast-bg-upgrade",
		},
		worldquest = {
			texture = "Interface\\AddOns\\ls_Toasts\\assets\\toast-bg-worldquest",
		},
	},
})
