local _, addonTable = ...
local E, P, C, D, L = addonTable.E, addonTable.P, addonTable.C, addonTable.D, addonTable.L

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
		local config = C.db.profile.anchors[anchorID]
		if not config then return end

		local active = activeToasts[anchorID]

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
					active[i]:SetPoint("TOP", active[i - 1], "BOTTOM", 0, -config.growth_offset_y)
				elseif config.growth_direction == "UP" then
					active[i]:SetPoint("BOTTOM", active[i - 1], "TOP", 0, config.growth_offset_y)
				elseif config.growth_direction == "LEFT" then
					active[i]:SetPoint("RIGHT", active[i - 1], "LEFT", -config.growth_offset_x, 0)
				elseif config.growth_direction == "RIGHT" then
					active[i]:SetPoint("LEFT", active[i - 1], "RIGHT", config.growth_offset_x, 0)
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

local function flush(t)
	for _ = #t, 1, -1 do
		t_remove(t, 1):Release()
	end
end

function P:FlushQueue(anchorID)
	if anchorID then
		if queuedToasts[anchorID] then
			flush(queuedToasts[anchorID])
		end

		if activeToasts[anchorID] then
			flush(activeToasts[anchorID])
		end
	else
		for _, queued in next, queuedToasts do
			flush(queued)
		end

		for _, active in next, activeToasts do
			flush(active)
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
