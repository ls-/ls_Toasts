local _, addon = ...

-- Mine
local C, D = {}, {}
addon.C, addon.D = C, D

local function rgb(...)
	return addon:CreateColor(...)
end

D.global = {
	colors = {
		addon = rgb(28, 211, 162), -- #1CD3A2 (Crayola Carribean Green)
	},
}

D.profile = {
	strata = "DIALOG",
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
	types = {},
	anchors = {
		[1] = {
			fadeout_delay = 2.8,
			growth_direction = "DOWN",
			growth_offset_x = 26,
			growth_offset_y = 14,
			max_active_toasts = 12,
			scale = 1,
			point = {
				p = "TOPLEFT",
				rP = "TOPLEFT",
				x = 26,
				y = -14,
			},
		},
	},
}
