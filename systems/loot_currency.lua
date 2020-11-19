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
local Enum = _G.Enum
local C_CurrencyInfo = _G.C_CurrencyInfo

--[[ luacheck: globals
	FormatLargeNumber GameTooltip

	ITEM_QUALITY_COLORS
]]

-- Mine
local NO_GAIN_SOURCE = Enum.CurrencySource.Last

-- https://wow.tools/dbc/?dbc=currencytypes&build=whatever
local BLACKLIST = {
	-- 41 (Test)
	[  22] = true, -- Birmingham Test Item 3
	-- 82 (Archaeology)
	[ 384] = true, -- Dwarf Archaeology Fragment
	[ 385] = true, -- Troll Archaeology Fragment
	[ 393] = true, -- Fossil Archaeology Fragment
	[ 394] = true, -- Night Elf Archaeology Fragment
	[ 397] = true, -- Orc Archaeology Fragment
	[ 398] = true, -- Draenei Archaeology Fragment
	[ 399] = true, -- Vrykul Archaeology Fragment
	[ 400] = true, -- Nerubian Archaeology Fragment
	[ 401] = true, -- Tol'vir Archaeology Fragment
	[ 676] = true, -- Pandaren Archaeology Fragment
	[ 677] = true, -- Mogu Archaeology Fragment
	[ 754] = true, -- Mantid Archaeology Fragment
	[ 821] = true, -- Draenor Clans Archaeology Fragment
	[ 828] = true, -- Ogre Archaeology Fragment
	[ 829] = true, -- Arakkoa Archaeology Fragment
	[ 830] = true, -- n/a
	[1172] = true, -- Highborne Archaeology Fragment
	[1173] = true, -- Highmountain Tauren Archaeology Fragment
	[1174] = true, -- Demonic Archaeology Fragment
	[1534] = true, -- Zandalari Archaeology Fragment
	[1535] = true, -- Drust Archaeology Fragment
	-- 89 (Meta)
	[ 483] = true, -- Conquest Arena Meta
	[ 484] = true, -- Conquest Rated BG Meta
	[ 692] = true, -- Conquest Random BG Meta
	-- 142 (Hidden)
	[ 395] = true, -- Justice Points
	[ 396] = true, -- Valor Points
	[1171] = true, -- Artifact Knowledge
	[1191] = true, -- Valor
	[1324] = true, -- Horde Qiraji Commendation
	[1325] = true, -- Alliance Qiraji Commendation
	[1347] = true, -- Legionfall Building - Personal Tracker - Mage Tower (Hidden)
	[1349] = true, -- Legionfall Building - Personal Tracker - Command Tower (Hidden)
	[1350] = true, -- Legionfall Building - Personal Tracker - Nether Tower (Hidden)
	[1501] = true, -- Writhing Essence
	[1506] = true, -- Argus Waystone
	-- [1540] = true, -- Wood
	-- [1541] = true, -- Iron
	-- [1559] = true, -- Essence of Storms
	[1579] = true, -- Champions of Azeroth
	[1592] = true, -- Order of Embers
	[1593] = true, -- Proudmoore Admiralty
	[1594] = true, -- Storm's Wake
	[1595] = true, -- Talanji's Expedition
	[1596] = true, -- Voldunai
	[1597] = true, -- Zandalari Empire
	[1598] = true, -- Tortollan Seekers
	[1599] = true, -- 7th Legion
	[1600] = true, -- Honorbound
	[1703] = true, -- PVP Season Rated Participation Currency
	[1705] = true, -- Warfronts - Personal Tracker - Iron in Chest (Hidden)
	[1714] = true, -- Warfronts - Personal Tracker - Wood in Chest (Hidden)
	[1722] = true, -- Azerite Ore
	[1723] = true, -- Lumber
	[1728] = true, -- Phantasma
	[1738] = true, -- Unshackled
	[1739] = true, -- Ankoan
	[1740] = true, -- Rustbolt Resistance (Hidden)
	[1742] = true, -- Rustbolt Resistance
	[1744] = true, -- Corrupted Memento
	[1745] = true, -- Nazjatar Ally - Neri Sharpfin
	[1746] = true, -- Nazjatar Ally - Vim Brineheart
	[1747] = true, -- Nazjatar Ally - Poen Gillbrack
	[1748] = true, -- Nazjatar Ally - Bladesman Inowari
	[1749] = true, -- Nazjatar Ally - Hunter Akana
	[1750] = true, -- Nazjatar Ally - Farseer Ori
	[1752] = true, -- Honeyback Hive
	[1757] = true, -- Uldum Accord
	[1758] = true, -- Rajani
	[1761] = true, -- Enemy Damage
	[1762] = true, -- Enemy Health
	[1763] = true, -- Deaths
	[1769] = true, -- Quest Experience (Standard, Hidden)
	[1794] = true, -- Atonement Anima
	[1804] = true, -- Ascended
	[1805] = true, -- Undying Army
	[1806] = true, -- Wild Hunt
	[1807] = true, -- Court of Harvesters
	[1808] = true, -- Channeled Anima
	[1837] = true, -- The Ember Court
	[1838] = true, -- The Countess
	[1839] = true, -- Rendle and Cudgelface
	[1840] = true, -- Stonehead
	[1841] = true, -- Cryptkeeper Kassir
	[1842] = true, -- Baroness Vashj
	[1843] = true, -- Plague Deviser Marileth
	[1844] = true, -- Grandmaster Vole
	[1845] = true, -- Alexandros Mograine
	[1846] = true, -- Sika
	[1847] = true, -- Kleia and Pelegos
	[1848] = true, -- Polemarch Adrestes
	[1849] = true, -- Mikanikos
	[1850] = true, -- Choofa
	[1851] = true, -- Droman Aliothe
	[1852] = true, -- Hunt-Captain Korayn
	[1853] = true, -- Lady Moonberry
	[1877] = true, -- Bonus Experience
	[1878] = true, -- Stitchmasters
	[1880] = true, -- Ve'nari
	-- 144 (Virtual)
	[1553] = true, -- Azerite
	[1585] = true, -- Account Wide Honor
	[1586] = true, -- Honor Level
}

local MULT = {
	[ 944] = 0.01, -- Artifact Fragment
	[1602] = 0.01, -- Conquest
}

local function Toast_OnEnter(self)
	if self._data.tooltip_link then
		GameTooltip:SetHyperlink(self._data.tooltip_link)
		GameTooltip:Show()
	end
end

local function PostSetAnimatedValue(self, value)
	self:SetText(value == 1 and "" or FormatLargeNumber(m_abs(value)))
end

local function Toast_SetUp(event, id, quantity, isGain)
	local link = "currency:" .. id
	local toast, isNew, isQueued = E:GetToast(event, "link", link)
	if isNew then
		if C.db.profile.types.loot_currency.filters[id] and quantity < C.db.profile.types.loot_currency.filters[id] then
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

			toast.Title:SetText(isGain and L["YOU_RECEIVED"] or L["YOU_LOST_RED"])
			toast.Text:SetText(info.name)
			toast.Icon:SetTexture(info.iconFileID)
			toast.IconBorder:Show()
			toast.IconText1:SetAnimatedValue(quantity, true)

			toast._data.count = quantity * (isGain and 1 or -1)
			toast._data.event = event
			toast._data.link = link
			toast._data.sound_file = C.db.profile.types.loot_currency.sfx and 31578 -- SOUNDKIT.UI_EPICLOOT_TOAST
			toast._data.tooltip_link = link

			toast:HookScript("OnEnter", Toast_OnEnter)
			toast:Spawn(C.db.profile.types.loot_currency.anchor, C.db.profile.types.loot_currency.dnd)
		else
			toast:Recycle()
		end
	else
		toast._data.count = toast._data.count + quantity * (isGain and 1 or -1)
		toast.Title:SetText(toast._data.count > 0 and L["YOU_RECEIVED"] or L["YOU_LOST_RED"])

		if isQueued then
			toast.IconText1:SetAnimatedValue(toast._data.count, true)
		else
			toast.IconText1:SetAnimatedValue(toast._data.count)

			toast.IconText2:SetText((isGain and "+" or "-") .. quantity)
			toast.IconText2.Blink:Stop()
			toast.IconText2.Blink:Play()

			toast.AnimOut:Stop()
			toast.AnimOut:Play()
		end
	end
end

local function CURRENCY_DISPLAY_UPDATE(id, _, quantity, gainSource)
	if not id or BLACKLIST[id] or C.db.profile.types.loot_currency.filters[id] == -1 then
		return
	end

	if not C.db.profile.types.loot_currency.track_loss and gainSource == NO_GAIN_SOURCE then
		return
	end

	quantity = quantity * (MULT[id] or 1)
	if quantity < 1 then
		return
	end

	Toast_SetUp("CURRENCY_DISPLAY_UPDATE", id, quantity, gainSource ~= NO_GAIN_SOURCE)
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

local function Enable()
	if C.db.profile.types.loot_currency.enabled then
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
	-- Order Resources
	Toast_SetUp("LOOT_CURRENCY_TEST", 1220, m_random(300, 600), (NO_GAIN_SOURCE * m_random(0, 1)) == NO_GAIN_SOURCE)
end

E:RegisterOptions("loot_currency", {
	enabled = true,
	anchor = 1,
	dnd = false,
	sfx = true,
	track_loss = false,
	filters = {
		[1792] = 25,
	},
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
