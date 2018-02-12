local _, addonTable = ...

-- Mine
local C, D = {}, {}
addonTable.C, addonTable.D = C, D

D.profile = {
	max_active_toasts = 12,
	scale = 1,
	strata = "DIALOG",
	fadeout_delay = 2.8,
	growth_direction = "DOWN",
	skin = "default",
	font = {
		-- name = nil,
		size = 12,
	},
	colors = {
		name = false,
		border = true,
		icon_border = true,
		threshold = 1,
	},
	point = {
		p = "TOPLEFT",
		rP = "TOPLEFT",
		x = 26,
		y = -14,
	},
	types = {},
}
