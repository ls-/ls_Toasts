local _, addonTable = ...
local E, L, C = addonTable.E, addonTable.L, addonTable.C

-- Lua
local _G = getfenv(0)
local hooksecurefunc = _G.hooksecurefunc
local m_abs = _G.math.abs
local m_random = _G.math.random

--[[ luacheck: globals
	ArchaeologyFrame ArcheologyDigsiteProgressBar FormatLargeNumber GameTooltip GetArchaeologyRaceInfoByID
	GetCurrencyInfo
]]

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
	toast._data.sound_file = C.db.profile.types.archaeology.sfx and 38326 -- SOUNDKIT.UI_DIG_SITE_COMPLETION_TOAST

	toast:Spawn(C.db.profile.types.archaeology.anchor, C.db.profile.types.archaeology.dnd)
end

local function ARTIFACT_DIGSITE_COMPLETE(researchFieldID)
	DigsiteToast_SetUp("ARTIFACT_DIGSITE_COMPLETE", researchFieldID)
end

------
local NO_GAIN_SOURCE = 38

-- https://wow.tools/dbc/?dbc=currencytypes&build=whatever
local WHITELIST = {
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

local function FragmentToast_SetUp(event, link, quantity)
	local toast, isNew, isQueued = E:GetToast(event, "link", link)
	if isNew then
		local name, _, icon = GetCurrencyInfo(link)
		if name then
			toast.IconText1.PostSetAnimatedValue = PostSetAnimatedValue

			if C.db.profile.colors.border then
				toast.Border:SetVertexColor(0.9, 0.4, 0.1)
			end

			if C.db.profile.colors.icon_border then
				toast.IconBorder:SetVertexColor(0.9, 0.4, 0.1)
			end

			toast.Title:SetText(L["YOU_RECEIVED"])
			toast.Text:SetText(name)
			toast.Icon:SetTexture(icon)
			toast.IconBorder:Show()
			toast.IconText1:SetAnimatedValue(quantity, true)

			toast._data.count = quantity
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

local function CURRENCY_DISPLAY_UPDATE(id, _, quantity, gainSource)
	if not (id and WHITELIST[id]) or gainSource == NO_GAIN_SOURCE then
		return
	end

	FragmentToast_SetUp("CURRENCY_DISPLAY_UPDATE", "currency:" .. id, quantity)
end

local function Enable()
	if not ArchaeologyFrame then
		local hooked = false

		hooksecurefunc("ArchaeologyFrame_LoadUI", function()
			if not hooked then
				ArcheologyDigsiteProgressBar.AnimOutAndTriggerToast:SetScript("OnFinished", function(self)
					self:GetParent():Hide()
				end)

				hooked = true
			end
		end)
	else
		ArcheologyDigsiteProgressBar.AnimOutAndTriggerToast:SetScript("OnFinished", function(self)
			self:GetParent():Hide()
		end)
	end

	if C.db.profile.types.archaeology.enabled then
		E:RegisterEvent("ARTIFACT_DIGSITE_COMPLETE", ARTIFACT_DIGSITE_COMPLETE)
		E:RegisterEvent("CURRENCY_DISPLAY_UPDATE", CURRENCY_DISPLAY_UPDATE)
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
