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
})

E:RegisterSkin("elv-no-art", {
	name = "ElvUI (No Artwork)",
	template = "elv",
	dragon = {
		hidden = true,
	},
	icon_highlight = {
		hidden = true,
	},
	bg = {
		alliance = {
			texture = {0.06, 0.06, 0.06, 0.8},
		},
		archaeology = {
			texture = {0.06, 0.06, 0.06, 0.8},
		},
		collection = {
			texture = {0.06, 0.06, 0.06, 0.8},
		},
		default = {
			texture = {0.06, 0.06, 0.06, 0.8},
		},
		dungeon = {
			texture = {0.06, 0.06, 0.06, 0.8},
		},
		horde = {
			texture = {0.06, 0.06, 0.06, 0.8},
		},
		legendary = {
			texture = {0.06, 0.06, 0.06, 0.8},
		},
		legion = {
			texture = {0.06, 0.06, 0.06, 0.8},
		},
		recipe = {
			texture = {0.06, 0.06, 0.06, 0.8},
		},
		store = {
			texture = {0.06, 0.06, 0.06, 0.8},
		},
		transmog = {
			texture = {0.06, 0.06, 0.06, 0.8},
		},
		upgrade = {
			texture = {0.06, 0.06, 0.06, 0.8},
		},
		worldquest = {
			texture = {0.06, 0.06, 0.06, 0.8},
		},
	},
})
