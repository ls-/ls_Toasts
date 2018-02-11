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
})

E:RegisterSkin("elv-no-art", {
	name = "ElvUI (No Artwork)",
	template = "elv",
	bg = {
		alliance = {0.06, 0.06, 0.06, 0.8},
		archaeology = {0.06, 0.06, 0.06, 0.8},
		collection = {0.06, 0.06, 0.06, 0.8},
		default = {0.06, 0.06, 0.06, 0.8},
		dungeon = {0.06, 0.06, 0.06, 0.8},
		horde = {0.06, 0.06, 0.06, 0.8},
		legendary = {0.06, 0.06, 0.06, 0.8},
		legion = {0.06, 0.06, 0.06, 0.8},
		recipe = {0.06, 0.06, 0.06, 0.8},
		store = {0.06, 0.06, 0.06, 0.8},
		transmog = {0.06, 0.06, 0.06, 0.8},
		upgrade = {0.06, 0.06, 0.06, 0.8},
		worldquest = {0.06, 0.06, 0.06, 0.8},
	},
})
