local _, addon = ...
local E, L, C = addon.E, addon.L, addon.C

-- Lua
local _G = getfenv(0)
local m_abs = _G.math.abs
local m_floor = _G.math.floor
local m_random = _G.math.random
local next = _G.next
local t_insert = _G.table.insert
local t_sort = _G.table.sort
local t_wipe = _G.table.wipe
local tonumber = _G.tonumber
local tostring = _G.tostring

-- Mine
local BLACKLIST = {
	[3468] = true, -- Rank Points
	[3473] = true, -- Renown - PvP Rank
	[3485] = true, -- Renown - Legacy Rank
	[3498] = true, -- [DNT] Class Talent Reset
	[3499] = true, -- [DNT] Legacy Talent Reset
}

local MULT = {}

local function Toast_OnEnter(self)
	if self._data.tooltip_link then
		addon.Tooltip:ShowHyperlink(self._data.tooltip_link)
	end
end

local function PostSetAnimatedValue(self, value)
	self:SetText(value == 1 and "" or FormatLargeNumber(m_abs(value)))
end

local function Toast_SetUp(event, id, quantity)
	local link = "currency:" .. id
	local toast, isNew, isQueued = E:GetToast(event, "link", link)
	if isNew then
		if C.db.profile.types.loot_currency.filters[id] and m_abs(quantity) < C.db.profile.types.loot_currency.filters[id] then
			toast:Recycle()

			return
		end

		local info = C_CurrencyInfo.GetCurrencyInfoFromLink(link)
		if info then
			local color = ITEM_QUALITY_COLORS[info.quality] or ITEM_QUALITY_COLORS[1]

			toast.IconText1.PostSetAnimatedValue = PostSetAnimatedValue

			if info.quality >= C.db.profile.colors.threshold then
				if C.db.profile.colors.name then
					toast.Text:SetTextColor(color.r, color.g, color.b)
				end

				if C.db.profile.colors.border then
					toast.Border:SetVertexColor(color.r, color.g, color.b)
				end

				if C.db.profile.colors.icon_border then
					toast.IconBorder:SetVertexColor(color.r, color.g, color.b)
				end
			end

			toast.Title:SetText(quantity > 0 and L["YOU_RECEIVED"] or L["YOU_LOST_RED"])
			toast.Text:SetText(info.name)
			toast.Icon:SetTexture(info.iconFileID)
			toast.IconBorder:Show()
			toast.IconText1:SetAnimatedValue(quantity, true)

			toast._data.count = quantity
			toast._data.event = event
			toast._data.link = link
			toast._data.sound_file = C.db.profile.types.loot_currency.sfx and 31578 -- SOUNDKIT.UI_EPICLOOT_TOAST
			toast._data.vfx = C.db.profile.types.loot_currency.vfx
			toast._data.tooltip_link = link

			if C.db.profile.types.loot_currency.tooltip then
				toast:HookScript("OnEnter", Toast_OnEnter)
			end

			toast:Spawn(addon:GetAnchorIDForType("loot_currency"), C.db.profile.types.loot_currency.dnd)
		else
			toast:Recycle()
		end
	else
		toast._data.count = toast._data.count + quantity
		toast.Title:SetText(toast._data.count > 0 and L["YOU_RECEIVED"] or L["YOU_LOST_RED"])

		if isQueued then
			toast.IconText1:SetAnimatedValue(toast._data.count, true)
		else
			toast.IconText1:SetAnimatedValue(toast._data.count)

			toast.IconText2:SetText(quantity)
			toast.IconText2.Blink:Stop()
			toast.IconText2.Blink:Play()

			toast.AnimOut:Stop()
			toast.AnimOut:Play()
		end
	end
end

local function CURRENCY_DISPLAY_UPDATE(id, _, quantity)
	if not id or BLACKLIST[id] or C.db.profile.types.loot_currency.filters[id] == -1 then
		return
	end

	if not quantity or (not C.db.profile.types.loot_currency.track_loss and quantity < 0) then
		return
	end

	quantity = m_floor(quantity * (MULT[id] or 1))
	if m_abs(quantity) < 1 then
		return
	end

	Toast_SetUp("CURRENCY_DISPLAY_UPDATE", id, quantity)
end

local listSize = 0
local newID

local function validateThreshold(_, value)
	value = tonumber(value) or 0
	return value >= -1
end

local function setThreshold(info, value)
	value = tonumber(value)
	C.db.profile.types.loot_currency.filters[tonumber(info[#info - 1])] = value
end

local function getThreshold(info)
	return tostring(C.db.profile.types.loot_currency.filters[tonumber(info[#info - 1])])
end

local function populateFilters()
	listSize = C_CurrencyInfo.GetCurrencyListSize()
	if listSize > 0 then
		local info, link, id

		for i = 1, listSize do
			info = C_CurrencyInfo.GetCurrencyListInfo(i)
			if not info.isHeader then
				link = C_CurrencyInfo.GetCurrencyListLink(i)
				if link then
					id = tonumber(link:match("currency:(%d+)"))
					if id then
						if not C.db.profile.types.loot_currency.filters[id] then
							C.db.profile.types.loot_currency.filters[id] = 0 -- disabled by default
						end
					end
				end
			end
		end
	end
end

local function updateFilterOptions()
	if not C.db.profile.types.loot_currency.enabled then
		return
	end

	local options = t_wipe(C.options.args.types.args.loot_currency.plugins.filters)
	local nameToIndex = {}
	local info

	for id in next, C.db.profile.types.loot_currency.filters do
		info = C_CurrencyInfo.GetBasicCurrencyInfo(id)
		t_insert(nameToIndex, info.name)
	end

	t_sort(nameToIndex)

	for i = 1, #nameToIndex do
		nameToIndex[nameToIndex[i]] = i
	end

	for id in next, C.db.profile.types.loot_currency.filters do
		info = C_CurrencyInfo.GetBasicCurrencyInfo(id)

		options[tostring(id)] = {
			order = nameToIndex[info.name] + 10,
			type = "group",
			name = ("|T%s:0:0:0:0:64:64:4:60:4:60|t %s"):format(info.icon, info.name),
			args = {
				desc = {
					order = 1,
					type = "description",
					name = info.description,
				},
				threshold = {
					order = 2,
					type = "input",
					name = L["THRESHOLD"],
					desc = L["CURRENCY_THRESHOLD_DESC"],
					validate = validateThreshold,
					set = setThreshold,
					get = getThreshold,
				},
			},
		}
	end
end

-- Update filters and options when users discover new currencies
local function updateFilters()
	if C_CurrencyInfo.GetCurrencyListSize() == listSize then
		return
	end

	populateFilters()
	updateFilterOptions()
end

local function cleanUpFilters()
	for id in next, C.db.profile.types.loot_currency.filters do
		local info = C_CurrencyInfo.GetBasicCurrencyInfo(id)
		if not info then
			C.db.profile.types.loot_currency.filters[id] = nil
		end
	end
end

local function Enable()
	if C.db.profile.types.loot_currency.enabled then
		cleanUpFilters()

		E:RegisterEvent("CURRENCY_DISPLAY_UPDATE", CURRENCY_DISPLAY_UPDATE)
		E:RegisterEvent("CURRENCY_DISPLAY_UPDATE", updateFilters)

		populateFilters()
		updateFilterOptions()
	end
end

local function Disable()
	E:UnregisterEvent("CURRENCY_DISPLAY_UPDATE", CURRENCY_DISPLAY_UPDATE)
	E:UnregisterEvent("CURRENCY_DISPLAY_UPDATE", updateFilters)
end

local function Test()
	-- Merchant's Favor
	Toast_SetUp("LOOT_CURRENCY_TEST", 3402, m_random(-600, 600))
end

E:RegisterOptions("loot_currency", {
	enabled = true,
	dnd = false,
	sfx = true,
	vfx = true,
	tooltip = true,
	track_loss = false,
	filters = {},
}, {
	name = L["TYPE_LOOT_CURRENCY"],
	get = function(info)
		return C.db.profile.types.loot_currency[info[#info]]
	end,
	set = function(info, value)
		C.db.profile.types.loot_currency[info[#info]] = value
	end,
	disabled = function(info)
		if info[#info] == "loot_currency" then
			return false
		else
			return not C.db.profile.types.loot_currency.enabled
		end
	end,
	args = {
		enabled = {
			order = 1,
			type = "toggle",
			name = L["ENABLE"],
			disabled = false,
			set = function(_, value)
				C.db.profile.types.loot_currency.enabled = value

				if value then
					Enable()
				else
					Disable()
				end
			end,
		},
		dnd = {
			order = 2,
			type = "toggle",
			name = L["DND"],
			desc = L["DND_DESC"],
		},
		sfx = {
			order = 3,
			type = "toggle",
			name = L["SFX"],
		},
		vfx = {
			order = 4,
			type = "toggle",
			name = L["VFX"],
		},
		tooltip = {
			order = 5,
			type = "toggle",
			name = L["TOOLTIPS"],
		},
		track_loss = {
			order = 6,
			type = "toggle",
			name = L["TRACK_LOSS"],
		},
		test = {
			type = "execute",
			order = 7,
			width = "full",
			name = L["TEST"],
			func = Test,
		},
		spacer_1 = {
			order = 8,
			type = "description",
			name = " ",
		},
		header_1 = {
			order = 9,
			type = "description",
			name = "   |cffffd200".. L["FILTERS"] .. "|r",
			fontSize = "medium",
		},
		new = {
			order = 10,
			type = "group",
			name = L["NEW"],
			args = {
				desc = {
					order = 1,
					type = "description",
					name = L["NEW_CURRENCY_FILTER_DESC"],
				},
				id = {
					order = 2,
					type = "input",
					name = L["ID"],
					dialogControl = "LSPreviewBoxCurrency",
					validate = function(_, value)
						value = tonumber(value)
						if value then
							return not not C_CurrencyInfo.GetCurrencyLink(value, 0)
						else
							return true
						end
					end,
					set = function(_, value)
						value = tonumber(value)
						if value and C_CurrencyInfo.GetCurrencyLink(value, 0) then
							newID = value
						else
							newID = nil -- jic
						end
					end,
					get = function()
						return tostring(newID or "")
					end,
				},
				add = {
					type = "execute",
					order = 3,
					name = L["ADD"],
					disabled = function()
						return not newID or C.db.profile.types.loot_currency.filters[newID] or BLACKLIST[newID]
					end,
					func = function()
						C.db.profile.types.loot_currency.filters[newID] = 0 -- disabled by default
						newID = nil

						updateFilterOptions()
					end,
				},
			},
		},
	},
	plugins = {
		filters = {},
	},
}, function()
	for k, v in next, C.db.profile.types.loot_currency.filters do
		if v == 0 then
			C.db.profile.types.loot_currency.filters[k] = nil
		end
	end
end)

E:RegisterSystem("loot_currency", Enable, Disable, Test)
