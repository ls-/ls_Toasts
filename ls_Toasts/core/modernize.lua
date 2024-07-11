local _, addonTable = ...
local E, P, C, D, L = addonTable.E, addonTable.P, addonTable.C, addonTable.D, addonTable.L

-- Lua
local _G = getfenv(0)

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
	end
end
