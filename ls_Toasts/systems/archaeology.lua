local _, addonTable = ...
local E, L, C = addonTable.E, addonTable.L, addonTable.C

-- Lua
local _G = getfenv(0)
local m_abs = _G.math.abs
local m_random = _G.math.random
local next = _G.next

-- Mine
local function DigsiteToast_SetUp(event, researchFieldID)
	local toast = E:GetToast()
	local raceName, raceTexture = GetArchaeologyRaceInfoByID(researchFieldID)

	if C.db.profile.colors.border then
		toast.Border:SetVertexColor(0.9, 0.4, 0.1)
	end

	toast:SetBackground("archaeology")
	toast.Title:SetText(L["DIGSITE_COMPLETED"])
	toast.Text:SetText(raceName)
	toast.Icon:SetPoint("TOPLEFT", 1, 3)
	toast.Icon:SetSize(40, 48)
	toast.Icon:SetTexture(raceTexture)
	toast.Icon:SetTexCoord(0 / 128, 74 / 128, 0 / 128, 88 / 128)

	toast._data.event = event
	toast._data.sound_file = C.db.profile.types.archaeology.sfx and "Interface\\AddOns\\ls_Toasts\\assets\\ui-digsite-completion-toast.OGG"

	toast:Spawn(C.db.profile.types.archaeology.anchor, C.db.profile.types.archaeology.dnd)
end

local function ARTIFACT_DIGSITE_COMPLETE(researchFieldID)
	DigsiteToast_SetUp("ARTIFACT_DIGSITE_COMPLETE", researchFieldID)
end

------
-- https://wago.tools/db2/CurrencyTypes?build=4.4.0.54737&filter%5BCategoryID%5D=82
-- 82 (Archaeology)
local WHITELIST = {
	[384] = true, -- Dwarf Archaeology Fragment
	[385] = true, -- Troll Archaeology Fragment
	[393] = true, -- Fossil Archaeology Fragment
	[394] = true, -- Night Elf Archaeology Fragment
	[397] = true, -- Orc Archaeology Fragment
	[398] = true, -- Draenei Archaeology Fragment
	[399] = true, -- Vrykul Archaeology Fragment
	[400] = true, -- Nerubian Archaeology Fragment
	[401] = true, -- Tol'vir Archaeology Fragment
}

local fragments = {}

local function populateFramgentsList()
	for id in next, WHITELIST do
		local info = C_CurrencyInfo.GetCurrencyInfo(id)
		if info then
			fragments[id] = info.quantity
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

local function FragmentToast_SetUp(event, link, quantity)
	local toast, isNew, isQueued = E:GetToast(event, "link", link)
	if isNew then
		local info = C_CurrencyInfo.GetCurrencyInfoFromLink(link)
		if info then
			toast.IconText1.PostSetAnimatedValue = PostSetAnimatedValue

			if C.db.profile.colors.border then
				toast.Border:SetVertexColor(0.9, 0.4, 0.1)
			end

			if C.db.profile.colors.icon_border then
				toast.IconBorder:SetVertexColor(0.9, 0.4, 0.1)
			end

			toast.Title:SetText(L["YOU_RECEIVED"])
			toast.Text:SetText(info.name)
			toast.Icon:SetTexture(info.iconFileID)
			toast.IconBorder:Show()
			toast.IconText1:SetAnimatedValue(quantity, true)

			toast._data.count = quantity
			toast._data.event = event
			toast._data.link = link
			toast._data.sound_file = C.db.profile.types.loot_currency.sfx and "Interface\\AddOns\\ls_Toasts\\assets\\ui-common-loot-toast.OGG"
			toast._data.tooltip_link = link

			toast:HookScript("OnEnter", Toast_OnEnter)
			toast:Spawn(C.db.profile.types.loot_currency.anchor, C.db.profile.types.loot_currency.dnd)
		else
			toast:Recycle()
		end
	else
		toast._data.count = toast._data.count + quantity

		if isQueued then
			toast.IconText1:SetAnimatedValue(toast._data.count, true)
		else
			toast.IconText1:SetAnimatedValue(toast._data.count)

			toast.IconText2:SetText("+" .. quantity)
			toast.IconText2.Blink:Stop()
			toast.IconText2.Blink:Play()

			toast.AnimOut:Stop()
			toast.AnimOut:Play()
		end
	end
end

local function CURRENCY_DISPLAY_UPDATE(id, cur)
	if not (id and fragments[id]) then
		return
	end

	local quantity = cur - fragments[id]
	fragments[id] = cur

	FragmentToast_SetUp("CURRENCY_DISPLAY_UPDATE", "currency:" .. id, quantity)
end

local function Enable()
	if C.db.profile.types.archaeology.enabled then
		E:RegisterEvent("ARTIFACT_DIGSITE_COMPLETE", ARTIFACT_DIGSITE_COMPLETE)
		E:RegisterEvent("CURRENCY_DISPLAY_UPDATE", CURRENCY_DISPLAY_UPDATE)

		populateFramgentsList()
	end
end

local function Disable()
	E:UnregisterEvent("ARTIFACT_DIGSITE_COMPLETE", ARTIFACT_DIGSITE_COMPLETE)
	E:UnregisterEvent("CURRENCY_DISPLAY_UPDATE", CURRENCY_DISPLAY_UPDATE)
end

local function Test()
	-- Night Elf Archaeology Fragment
	FragmentToast_SetUp("ARCHAEOLOGY_TEST", "currency:" .. 394, m_random(4, 8))

	-- Night Elf
	DigsiteToast_SetUp("ARCHAEOLOGY_TEST", 4)
end

E:RegisterOptions("archaeology", {
	enabled = true,
	anchor = 1,
	dnd = false,
	sfx = true,
}, {
	name = L["TYPE_ARCHAEOLOGY"],
	get = function(info)
		return C.db.profile.types.archaeology[info[#info]]
	end,
	set = function(info, value)
		C.db.profile.types.archaeology[info[#info]] = value
	end,
	args = {
		enabled = {
			order = 1,
			type = "toggle",
			name = L["ENABLE"],
			set = function(_, value)
				C.db.profile.types.archaeology.enabled = value

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

E:RegisterSystem("archaeology", Enable, Disable, Test)
