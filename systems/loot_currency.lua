local _, addonTable = ...
local E, L, C = addonTable.E, addonTable.L, addonTable.C

-- Lua
local _G = getfenv(0)
local m_abs = _G.math.abs
local m_random = _G.math.random
local next = _G.next
local t_insert = _G.table.insert
local t_sort = _G.table.sort
local t_wipe = _G.table.wipe
local tonumber = _G.tonumber
local tostring = _G.tostring

-- Blizz
local C_CurrencyInfo = _G.C_CurrencyInfo

-- Mine
local currencies = {}
local listSize = 0

local function populateCurrencyLists()
	C.db.profile.types.loot_currency.filters[1792] = nil
	listSize = GetCurrencyListSize()
	if listSize > 0 then
		local _, isHeader, count, id

		for i = 1, listSize do
			_, isHeader, _, _, _, count, _, _, _, _, _, id = GetCurrencyListInfo(i)
			if not isHeader and id then
				if not C.db.profile.types.loot_currency.filters[id] then
					C.db.profile.types.loot_currency.filters[id] = 0 -- disabled by default
				end

				currencies[id] = count
			end
		end
	end
end

local function Toast_OnEnter(self)
	if self._data.tooltip_link then
		GameTooltip:SetHyperlink(self._data.tooltip_link)
		GameTooltip:Show()
	end
end

local function PostSetAnimatedValue(self, value)
	self:SetText(value == 1 and "" or FormatLargeNumber(m_abs(value)))
end

local function Toast_SetUp(event, id, quantity)
	local toast, isNew, isQueued = E:GetToast(event, "id", id)
	if isNew then
		if quantity > 0 and quantity < C.db.profile.types.loot_currency.filters[id] then
			toast:Recycle()

			return
		end

		local info = C_CurrencyInfo.GetBasicCurrencyInfo(id)
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

			toast.Title:SetText(quantity >= 0 and L["YOU_RECEIVED"] or L["YOU_LOST_RED"])
			toast.Text:SetText(info.name)
			toast.Icon:SetTexture(info.icon)
			toast.IconBorder:Show()
			toast.IconText1:SetAnimatedValue(quantity, true)

			toast._data.count = quantity
			toast._data.event = event
			toast._data.id = id
			toast._data.sound_file = C.db.profile.types.loot_currency.sfx and "Interface\\AddOns\\ls_Toasts\\assets\\ui-common-loot-toast.OGG"
			toast._data.tooltip_link = "currency:" .. id

			toast:HookScript("OnEnter", Toast_OnEnter)
			toast:Spawn(C.db.profile.types.loot_currency.anchor, C.db.profile.types.loot_currency.dnd)
		else
			toast:Recycle()
		end
	else
		toast._data.count = toast._data.count + quantity
		toast.Title:SetText(toast._data.count >= 0 and L["YOU_RECEIVED"] or L["YOU_LOST_RED"])

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

local function CURRENCY_DISPLAY_UPDATE(id, cur)
	if not id then
		return
	end

	if not currencies[id] then
		populateCurrencyLists()

		if not currencies[id] then
			return
		end
	end

	if C.db.profile.types.loot_currency.filters[id] == -1 then
		currencies[id] = cur

		return
	end

	local quantity = cur - currencies[id]
	currencies[id] = cur


	if not C.db.profile.types.loot_currency.track_loss and quantity < 0 then
		return
	end

	Toast_SetUp("CURRENCY_DISPLAY_UPDATE", id, quantity)
end

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
	if GetCurrencyListSize() == listSize then
		return
	end

	populateCurrencyLists()
	updateFilterOptions()
end

local function Enable()
	if C.db.profile.types.loot_currency.enabled then
		E:RegisterEvent("CURRENCY_DISPLAY_UPDATE", CURRENCY_DISPLAY_UPDATE)
		E:RegisterEvent("CURRENCY_DISPLAY_UPDATE", updateFilters)

		populateCurrencyLists()
		updateFilterOptions()
	end
end

local function Disable()
	E:UnregisterEvent("CURRENCY_DISPLAY_UPDATE", CURRENCY_DISPLAY_UPDATE)
	E:UnregisterEvent("CURRENCY_DISPLAY_UPDATE", updateFilters)
end

local function Test()
	-- Emblem of Heroism
	if not C.db.profile.types.loot_currency.filters[101] then
		C.db.profile.types.loot_currency.filters[101] = 0

		updateFilterOptions()
	end

	Toast_SetUp("LOOT_CURRENCY_TEST", 101, m_random(-250, 250))
end

E:RegisterOptions("loot_currency", {
	enabled = true,
	anchor = 1,
	dnd = false,
	sfx = true,
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
			desc = L["DND_TOOLTIP"],
		},
		sfx = {
			order = 3,
			type = "toggle",
			name = L["SFX"],
		},
		track_loss = {
			order = 4,
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
							return not not C_CurrencyInfo.GetBasicCurrencyInfo(value)
						else
							return true
						end
					end,
					set = function(_, value)
						value = tonumber(value)
						if value and C_CurrencyInfo.GetBasicCurrencyInfo(value) then
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
						return not newID or C.db.profile.types.loot_currency.filters[newID]
					end,
					func = function()
						C.db.profile.types.loot_currency.filters[newID] = 0 -- disabled by default
						newID = nil

						updateFilterOptions()
					end
				},
			},
		},
	},
	plugins = {
		filters = {},
	},
})

E:RegisterSystem("loot_currency", Enable, Disable, Test)
