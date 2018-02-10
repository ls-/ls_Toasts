local _, addonTable = ...
local E, C = addonTable.E, addonTable.C

-- Lua
local _G = getfenv(0)
local next = _G.next
local t_insert = _G.table.insert
local t_remove = _G.table.remove

-- Mine
local function isDNDEnabled()
	for _, v in next, C.db.profile.types do
		if v.dnd then
			return true
		end
	end

	return false
end

local function hasNonDNDToast()
	local queuedToasts = E:GetQueuedToasts()

	for i, queuedToast in next, queuedToasts do
		if not queuedToast._data.dnd then
			-- I don't want to ruin non-DND toasts' order, k?
			t_insert(queuedToasts, 1, t_remove(queuedToasts, i))

			return true
		end
	end

	return false
end

function E.RefreshQueue()
	local activeToasts = E:GetActiveToasts()
	local queuedToasts = E:GetQueuedToasts()

	for i = 1, #activeToasts do
		local activeToast = activeToasts[i]
		activeToast:ClearAllPoints()

		if i == 1 then
			activeToast:SetPoint("TOPLEFT", E:GetAnchorFrame(), "TOPLEFT", 0, 0)
		else
			if C.db.profile.growth_direction == "DOWN" then
				activeToast:SetPoint("TOP", activeToasts[i - 1], "BOTTOM", 0, -14)
			elseif C.db.profile.growth_direction == "UP" then
				activeToast:SetPoint("BOTTOM", activeToasts[i - 1], "TOP", 0, 14)
			elseif C.db.profile.growth_direction == "LEFT" then
				activeToast:SetPoint("RIGHT", activeToasts[i - 1], "LEFT", -26, 0)
			elseif C.db.profile.growth_direction == "RIGHT" then
				activeToast:SetPoint("LEFT", activeToasts[i - 1], "RIGHT", 26, 0)
			end
		end
	end

	local queuedToast = t_remove(queuedToasts, 1)

	if queuedToast then
		if InCombatLockdown() and queuedToast._data.dnd then
			t_insert(queuedToasts, queuedToast)

			if hasNonDNDToast() then
				E:RefreshQueue()
			end
		else
			queuedToast:Spawn()
		end
	end
end

E:RegisterEvent("PLAYER_REGEN_ENABLED", function()
	if isDNDEnabled() and E:GetNumQueuedToasts() > 0 then
		for _ = 1, C.db.profile.max_active_toasts - E:GetNumActiveToasts() do
			E:RefreshQueue()
		end
	end
end)
