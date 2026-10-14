local _, addon = ...
local E, P, C, D, L = addon.E, addon.P, addon.C, addon.D, addon.L

-- Lua
local _G = getfenv(0)
local next = _G.next

-- Mine
function P:Modernize(data, name, key)
	if not data.version then return end

	if key == "profile" then
		-- ->80100.03
		if data.version < 8010003 then
			if data.fadeout_delay then
				data.anchors[1].fadeout_delay = data.fadeout_delay
				data.fadeout_delay = nil
			end

			if data.growth_direction then
				data.anchors[1].growth_direction = data.growth_direction
				data.growth_direction = nil
			end

			if data.max_active_toasts then
				data.anchors[1].max_active_toasts = data.max_active_toasts
				data.max_active_toasts = nil
			end

			if data.scale then
				data.anchors[1].scale = data.scale
				data.scale = nil
			end

			if data.point then
				data.anchors[1].point.p = data.point.p
				data.anchors[1].point.rP = data.point.rP
				data.anchors[1].point.x = data.point.x
				data.anchors[1].point.y = data.point.y
				data.point = nil
			end

			data.version = 8010003
		end

		-- ->80100.05
		if data.version < 8010005 then
			data.point = nil
			data.version = 8010005
		end

		-- ->110002.03
		if data.version < 11000203 then
			if data.types and data.types.achievement then
				data.types.achievement.filter_guild = nil
			end

			data.version = 11000203
		end

		-- ->120100.01
		if data.version < 12010001 then
			if data.types and data.types.archaeology then
				data.types.archaeology.tooltip = nil
			end

			data.version = 12010001
		end

		-- ->120105.01
		if data.version < 12010501 then
			local temp = {
				types = {},
				anchors = {},
			}

			if data.types then
				for k, v in next, data.types do
					temp.types[k] = v.anchor

					v.anchor = nil
				end
			end

			if data.anchors then
				for k, v in next, data.anchors do
					if v.point then
						v.point.point = v.point.p or v.point.rP

						v.point.p = nil
						v.point.rP = nil
					end

					temp.anchors[k] = addon:CopyTable(v)
					temp.anchors[k].id = k
				end

				if not temp.anchors[1] then
					temp.anchors[1] = {
						id = 1,
					}
				end

				data.anchors = nil
			end

			if not data.layouts then
				data.layouts = {
					Classic = {},
					Modern = {},
				}
			end

			for _, layout in next, data.layouts do
				addon:CopyTable(temp, layout)
			end

			data.version = 12010501
		end
	end
end
