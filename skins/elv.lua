local _, addonTable = ...
local E, C = addonTable.E, addonTable.C

-- Lua
local _G = getfenv(0)

-- Mine
E:RegisterSkin("elv", {
	name = "ElvUI",
	border = {
		color = {0, 0, 0},
		offset = 0,
		size = 1,
		texture = {1, 1, 1, 1},
	},
	icon = {
		tex_coords = {5 / 64, 59 / 64, 5 / 64, 59 / 64},
	},
	icon_border = {
		color = {0, 0, 0},
		offset = 0,
		size = 1,
		texture = {1, 1, 1, 1},
	},
	slot = {
		tex_coords = {5 / 64, 59 / 64, 5 / 64, 59 / 64},
	},
	slot_border = {
		color = {0, 0, 0},
		offset = 0,
		size = 1,
		texture = {1, 1, 1, 1},
	},
	glow = {
		texture = {1, 1, 1, 1},
		size = {226, 50},
	},
	shine = {
		tex_coords = {403 / 512, 465 / 512, 15 / 256, 61 / 256},
		size = {67, 50},
		point = {
			y = -1,
		},
	},
})

E:RegisterSkin("elv-legacy", {
	name = "ElvUI (Legacy)",
	template = "elv",
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

E:RegisterSkin("elv-no-art", {
	name = "ElvUI (No Artwork)",
	template = "elv",
	text_bg = {
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
