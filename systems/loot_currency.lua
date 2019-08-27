local _, addonTable = ...
local E, L, C = addonTable.E, addonTable.L, addonTable.C

-- Lua
local _G = getfenv(0)
local m_abs = _G.math.abs
local m_random = _G.math.random

--[[ luacheck: globals
	FormatLargeNumber GameTooltip GetCurrencyInfo

	ITEM_QUALITY_COLORS
]]

-- Mine
local NO_GAIN_SOURCE = 38

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
	-- [1602] = true, -- Conquest
	[1703] = true, -- BFA Season Rated Participation Currency
	[1705] = true, -- Warfronts - Personal Tracker - Iron in Chest (Hidden)
	[1714] = true, -- Warfronts - Personal Tracker - Wood in Chest (Hidden)
	[1722] = true, -- Azerite Ore
	[1723] = true, -- Lumber
	[1738] = true, -- Unshackled
	[1739] = true, -- Ankoan
	[1740] = true, -- Rustbolt Resistance (Hidden)
	[1742] = true, -- Rustbolt Resistance
	[1745] = true, -- Nazjatar Ally - Neri Sharpfin
	[1746] = true, -- Nazjatar Ally - Vim Brineheart
	[1747] = true, -- Nazjatar Ally - Poen Gillbrack
	[1748] = true, -- Nazjatar Ally - Bladesman Inowari
	[1749] = true, -- Nazjatar Ally - Hunter Akana
	[1750] = true, -- Nazjatar Ally - Farseer Ori
	[1752] = true, -- Honeyback Hive
	-- 144 (Virtual)
	[1553] = true, -- Azerite
	[1585] = true, -- Honor
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

local function Toast_SetUp(event, link, quantity, isGain)
	local toast, isNew, isQueued = E:GetToast(event, "link", link)
	if isNew then
		local name, _, icon, _, _, _, _, quality = GetCurrencyInfo(link)
		if name then
			local color = ITEM_QUALITY_COLORS[quality] or ITEM_QUALITY_COLORS[1]

			toast.IconText1.PostSetAnimatedValue = PostSetAnimatedValue

			if quality >= C.db.profile.colors.threshold then
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
			toast.Text:SetText(name)
			toast.Icon:SetTexture(icon)
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
	if not id or BLACKLIST[id] then
		return
	end

	if not C.db.profile.types.loot_currency.track_loss and gainSource == NO_GAIN_SOURCE then
		return
	end

	quantity = quantity * (MULT[id] or 1)
	if quantity < 1 then
		return
	end

	Toast_SetUp("CURRENCY_DISPLAY_UPDATE", "currency:" .. id, quantity, gainSource ~= NO_GAIN_SOURCE)
end

local function Enable()
	if C.db.profile.types.loot_currency.enabled then
		E:RegisterEvent("CURRENCY_DISPLAY_UPDATE", CURRENCY_DISPLAY_UPDATE)
	end
end

local function Disable()
	E:UnregisterEvent("CURRENCY_DISPLAY_UPDATE", CURRENCY_DISPLAY_UPDATE)
end

local function Test()
	-- Order Resources
	Toast_SetUp("LOOT_CURRENCY_TEST", "currency:" .. 1220, m_random(300, 600), m_random(38, 39) == NO_GAIN_SOURCE)
end

E:RegisterOptions("loot_currency", {
	enabled = true,
	anchor = 1,
	dnd = false,
	sfx = true,
	track_loss = false,
}, {
	name = L["TYPE_LOOT_CURRENCY"],
	get = function(info)
		return C.db.profile.types.loot_currency[info[#info]]
	end,
	set = function(info, value)
		C.db.profile.types.loot_currency[info[#info]] = value
	end,
	args = {
		enabled = {
			order = 1,
			type = "toggle",
			name = L["ENABLE"],
			set = function(_, value)
				C.db.profile.types.loot_currency.enabled = value

				if value then
					Enable()
				else
					Disable()
				end
			end
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
			order = 99,
			width = "full",
			name = L["TEST"],
			func = Test,
		},
	},
})

E:RegisterSystem("loot_currency", Enable, Disable, Test)
