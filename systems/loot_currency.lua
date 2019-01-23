local _, addonTable = ...
local E, L, C = addonTable.E, addonTable.L, addonTable.C

-- Lua
local _G = getfenv(0)
local m_random = _G.math.random
local tonumber = _G.tonumber

-- Blizz
local C_Timer = _G.C_Timer

--[[ luacheck: globals
	FormatLargeNumber GameTooltip GetCurrencyInfo GetCurrencyLink

	CURRENCY_GAINED CURRENCY_GAINED_MULTIPLE CURRENCY_GAINED_MULTIPLE_BONUS ITEM_QUALITY_COLORS
]]

-- Mine
local CACHED_CURRENCY_GAINED
local CACHED_CURRENCY_GAINED_MULTIPLE
local CACHED_CURRENCY_GAINED_MULTIPLE_BONUS

local CURRENCY_GAINED_PATTERN
local CURRENCY_GAINED_MULTIPLE_PATTERN
local CURRENCY_GAINED_MULTIPLE_BONUS_PATTERN

local function updatePatterns()
	if CACHED_CURRENCY_GAINED ~= CURRENCY_GAINED then
		CURRENCY_GAINED_PATTERN = CURRENCY_GAINED:gsub("%%s", "(.+)"):gsub("^", "^")
		CACHED_CURRENCY_GAINED = CURRENCY_GAINED
	end

	if CACHED_CURRENCY_GAINED_MULTIPLE ~= CURRENCY_GAINED_MULTIPLE then
		CURRENCY_GAINED_MULTIPLE_PATTERN = CURRENCY_GAINED_MULTIPLE:gsub("%%s", "(.+)"):gsub("%%d", "(%%d+)"):gsub("^", "^")
		CACHED_CURRENCY_GAINED_MULTIPLE = CURRENCY_GAINED_MULTIPLE
	end

	if CACHED_CURRENCY_GAINED_MULTIPLE_BONUS ~= CURRENCY_GAINED_MULTIPLE_BONUS then
		CURRENCY_GAINED_MULTIPLE_BONUS_PATTERN = CURRENCY_GAINED_MULTIPLE_BONUS:gsub("%%s", "(.+)"):gsub("%%d", "(%%d+)"):gsub("^", "^")
		CACHED_CURRENCY_GAINED_MULTIPLE_BONUS = CURRENCY_GAINED_MULTIPLE_BONUS
	end
end

local function delayedUpdatePatterns()
	C_Timer.After(0.1, updatePatterns)
end

local function Toast_OnEnter(self)
	if self._data.tooltip_link then
		GameTooltip:SetHyperlink(self._data.tooltip_link)
		GameTooltip:Show()
	end
end

local function PostSetAnimatedValue(self, value)
	self:SetText(value == 1 and "" or FormatLargeNumber(value))
end

local function Toast_SetUp(event, link, quantity)
	local sanitizedLink, originalLink = E:SanitizeLink(link)
	local toast, isNew, isQueued = E:GetToast(event, "link", sanitizedLink)
	if isNew then
		local name, _, icon, _, _, _, _, quality = GetCurrencyInfo(link)
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

		toast.Title:SetText(L["YOU_RECEIVED"])
		toast.Text:SetText(name)
		toast.Icon:SetTexture(icon)
		toast.IconBorder:Show()
		toast.IconText1:SetAnimatedValue(quantity, true)

		toast._data.count = quantity
		toast._data.event = event
		toast._data.link = sanitizedLink
		toast._data.sound_file = C.db.profile.types.loot_currency.sfx and 31578 -- SOUNDKIT.UI_EPICLOOT_TOAST
		toast._data.tooltip_link = originalLink

		toast:HookScript("OnEnter", Toast_OnEnter)
		toast:Spawn(C.db.profile.types.loot_currency.anchor, C.db.profile.types.loot_currency.dnd)
	else
		if isQueued then
			toast._data.count = toast._data.count + quantity
			toast.IconText1:SetAnimatedValue(toast._data.count, true)
		else
			toast._data.count = toast._data.count + quantity
			toast.IconText1:SetAnimatedValue(toast._data.count)

			toast.IconText2:SetText("+" .. quantity)
			toast.IconText2.Blink:Stop()
			toast.IconText2.Blink:Play()

			toast.AnimOut:Stop()
			toast.AnimOut:Play()
		end
	end
end

local function CHAT_MSG_CURRENCY(message)
	local link, quantity = message:match(CURRENCY_GAINED_MULTIPLE_PATTERN)
	if not link then
		link, quantity = message:match(CURRENCY_GAINED_MULTIPLE_BONUS_PATTERN)
		if not link then
			quantity, link = 1, message:match(CURRENCY_GAINED_PATTERN)
		end
	end

	if not link then
		return
	end

	Toast_SetUp("CHAT_MSG_CURRENCY", link, tonumber(quantity) or 0)
end

local function Enable()
	updatePatterns()

	if C.db.profile.types.loot_currency.enabled then
		E:RegisterEvent("CHAT_MSG_CURRENCY", CHAT_MSG_CURRENCY)
		E:RegisterEvent("PLAYER_ENTERING_WORLD", delayedUpdatePatterns)
	end
end

local function Disable()
	E:UnregisterEvent("CHAT_MSG_CURRENCY", CHAT_MSG_CURRENCY)
	E:UnregisterEvent("PLAYER_ENTERING_WORLD", delayedUpdatePatterns)
end

local function Test()
	-- Order Resources
	local link, _ = GetCurrencyLink(1220, 1)
	if link then
		Toast_SetUp("LOOT_CURRENCY_TEST", link, m_random(300, 600))
	end
end

E:RegisterOptions("loot_currency", {
	enabled = true,
	anchor = 1,
	dnd = false,
	sfx = true,
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
