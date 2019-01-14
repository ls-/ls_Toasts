local _, addonTable = ...
local E, C, P = addonTable.E, addonTable.C, addonTable.P

-- Lua
local _G = getfenv(0)
local next = _G.next
local t_insert = _G.table.insert
local t_remove = _G.table.remove
local t_sort = _G.table.sort

--[[ luacheck: globals
	InCombatLockdown
]]

-- Mine
local activeToasts = {}
local queuedToasts = {}

function P:RefreshQueues()
	for anchorID, queued in next, queuedToasts do
		local active = activeToasts[anchorID]
		local config = C.db.profile.anchors[anchorID]

		if #active < config.max_active_toasts then
			for _ = 1, config.max_active_toasts - #active do
				if not queued[1] then
					break
				end

				if not InCombatLockdown() or not queued[1]._data.dnd then
					t_insert(active, t_remove(queued, 1))
				end
			end
		end

		for i = 1, #active do
			active[i]:ClearAllPoints()

			if i == 1 then
				active[i]:SetPoint("TOPLEFT", P:GetAnchor(anchorID), "TOPLEFT", 0, 0)
			else
				if config.growth_direction == "DOWN" then
					active[i]:SetPoint("TOP", active[i - 1], "BOTTOM", 0, -14)
				elseif config.growth_direction == "UP" then
					active[i]:SetPoint("BOTTOM", active[i - 1], "TOP", 0, 14)
				elseif config.growth_direction == "LEFT" then
					active[i]:SetPoint("RIGHT", active[i - 1], "LEFT", -26, 0)
				elseif config.growth_direction == "RIGHT" then
					active[i]:SetPoint("LEFT", active[i - 1], "RIGHT", 26, 0)
				end
			end

			active[i]:Show()
		end
	end
end

local function sortFunc(a, b)
	if a._data.dnd == b._data.dnd then
		return a._data.order < b._data.order
	elseif not a._data.dnd and b._data.dnd then
		return true
	elseif a._data.dnd and not b._data.dnd then
		return false
	end
end

function P:Queue(toast, anchorID)
	if not queuedToasts[anchorID] then
		queuedToasts[anchorID] = {}
	end

	if not activeToasts[anchorID] then
		activeToasts[anchorID] = {}
	end

	t_insert(queuedToasts[anchorID], toast)
	t_sort(queuedToasts[anchorID], sortFunc)

	self:RefreshQueues()
end

function P:Dequeue(toast, anchorID)
	for i, queuedToast in next, queuedToasts[anchorID] do
		if toast == queuedToast then
			t_remove(queuedToasts[anchorID], i)

			break
		end
	end

	for i, activeToast in next, activeToasts[anchorID] do
		if toast == activeToast then
			t_remove(activeToasts[anchorID], i)

			self:RefreshQueues()

			break
		end
	end
end

function P:GetActiveToasts(anchorID)
	return anchorID and activeToasts[anchorID] or activeToasts
end

function P:GetQueuedToasts(anchorID)
	return anchorID and queuedToasts[anchorID] or queuedToasts
end

E:RegisterEvent("PLAYER_REGEN_ENABLED", P.RefreshQueues)
