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
	text_bg = {
		hidden = false,
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
		default = {
			color = {1, 1, 1},
			texture = "Interface\\AddOns\\ls_Toasts\\assets\\toast-bg-default",
			tex_coords = {1 / 512, 449 / 512, 1 / 128, 97 / 128},
			tile = false,
		},
	},
})

E:RegisterSkin("default-legacy", {
	name = "Default (Legacy)",
	template = "default",
	bg = {
		alliance = {
			color = {1, 1, 1},
			texture = "Interface\\AddOns\\ls_Toasts\\assets\\legacy\\toast-bg-alliance",
			tex_coords = {1 / 256, 225 / 256, 1 / 64, 49 / 64},
			tile = false,
		},
		archaeology = {
			color = {1, 1, 1},
			texture = "Interface\\AddOns\\ls_Toasts\\assets\\legacy\\toast-bg-archaeology",
			tex_coords = {1 / 256, 225 / 256, 1 / 64, 49 / 64},
			tile = false,
		},
		azerite = {
			color = {1, 1, 1},
			texture = "Interface\\AddOns\\ls_Toasts\\assets\\legacy\\toast-bg-azerite",
			tex_coords = {1 / 256, 225 / 256, 1 / 64, 49 / 64},
			tile = false,
		},
		collection = {
			color = {1, 1, 1},
			texture = "Interface\\AddOns\\ls_Toasts\\assets\\legacy\\toast-bg-collection",
			tex_coords = {1 / 256, 225 / 256, 1 / 64, 49 / 64},
			tile = false,
		},
		default = {
			color = {1, 1, 1},
			texture = "Interface\\AddOns\\ls_Toasts\\assets\\legacy\\toast-bg-default",
			tex_coords = {1 / 256, 225 / 256, 1 / 64, 49 / 64},
			tile = false,
		},
		dungeon = {
			color = {1, 1, 1},
			texture = "Interface\\AddOns\\ls_Toasts\\assets\\legacy\\toast-bg-dungeon",
			tex_coords = {1 / 256, 225 / 256, 1 / 64, 49 / 64},
			tile = false,
		},
		horde = {
			color = {1, 1, 1},
			texture = "Interface\\AddOns\\ls_Toasts\\assets\\legacy\\toast-bg-horde",
			tex_coords = {1 / 256, 225 / 256, 1 / 64, 49 / 64},
			tile = false,
		},
		legendary = {
			color = {1, 1, 1},
			texture = "Interface\\AddOns\\ls_Toasts\\assets\\legacy\\toast-bg-legendary",
			tex_coords = {1 / 256, 225 / 256, 1 / 64, 49 / 64},
			tile = false,
		},
		legion = {
			color = {1, 1, 1},
			texture = "Interface\\AddOns\\ls_Toasts\\assets\\legacy\\toast-bg-legion",
			tex_coords = {1 / 256, 225 / 256, 1 / 64, 49 / 64},
			tile = false,
		},
		recipe = {
			color = {1, 1, 1},
			texture = "Interface\\AddOns\\ls_Toasts\\assets\\legacy\\toast-bg-recipe",
			tex_coords = {1 / 256, 225 / 256, 1 / 64, 49 / 64},
			tile = false,
		},
		store = {
			color = {1, 1, 1},
			texture = "Interface\\AddOns\\ls_Toasts\\assets\\legacy\\toast-bg-store",
			tex_coords = {1 / 256, 225 / 256, 1 / 64, 49 / 64},
			tile = false,
		},
		transmog = {
			color = {1, 1, 1},
			texture = "Interface\\AddOns\\ls_Toasts\\assets\\legacy\\toast-bg-transmog",
			tex_coords = {1 / 256, 225 / 256, 1 / 64, 49 / 64},
			tile = false,
		},
		upgrade = {
			color = {1, 1, 1},
			texture = "Interface\\AddOns\\ls_Toasts\\assets\\legacy\\toast-bg-upgrade",
			tex_coords = {1 / 256, 225 / 256, 1 / 64, 49 / 64},
			tile = false,
		},
		worldquest = {
			color = {1, 1, 1},
			texture = "Interface\\AddOns\\ls_Toasts\\assets\\legacy\\toast-bg-worldquest",
			tex_coords = {1 / 256, 225 / 256, 1 / 64, 49 / 64},
			tile = false,
		},
	},
})
