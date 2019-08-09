local _, addonTable = ...
local E, L, C = addonTable.E, addonTable.L, addonTable.C

-- Lua
local _G = getfenv(0)
local m_abs = _G.math.abs
local m_random = _G.math.random

--[[ luacheck: globals
	GetMoney GetMoneyString
]]

-- Mine
local old

local function PostSetAnimatedValue(self, value)
	self:SetText(GetMoneyString(m_abs(value), true))
end

local function Toast_SetUp(event, quantity)
	local toast, isNew, isQueued = E:GetToast(nil, "event", event)
	if isNew then
		toast.Text.PostSetAnimatedValue = PostSetAnimatedValue

		if C.db.profile.colors.border then
			toast.Border:SetVertexColor(0.9, 0.75, 0.26)
		end

		if C.db.profile.colors.icon_border then
			toast.IconBorder:SetVertexColor(0.9, 0.75, 0.26)
		end

		if quantity > 0 then
			toast.Title:SetText(L["YOU_RECEIVED"])
			toast.Title:SetVertexColor(0.180392, 0.67451, 0.203922)
		else
			toast.Title:SetText(L["YOU_LOST"])
			toast.Title:SetVertexColor(0.862745, 0.266667, 0.211765)
		end

		toast.Text:SetAnimatedValue(quantity, true)
		toast.Icon:SetTexture("Interface\\Icons\\INV_Misc_Coin_02")
		toast.IconBorder:Show()

		toast._data.count = quantity
		toast._data.event = event
		toast._data.sound_file = C.db.profile.types.loot_gold.sfx and 865 -- SOUNDKIT.IG_BACKPACK_COIN_OK

		toast:Spawn(C.db.profile.types.loot_gold.anchor, C.db.profile.types.loot_gold.dnd)
	else
		toast._data.count = toast._data.count + quantity
		if toast._data.count > 0 then
			toast.Title:SetText(L["YOU_RECEIVED"])
			toast.Title:SetVertexColor(0.180392, 0.67451, 0.203922)
		else
			toast.Title:SetText(L["YOU_LOST"])
			toast.Title:SetVertexColor(0.862745, 0.266667, 0.211765)
		end

		if isQueued then
			toast.Text:SetAnimatedValue(toast._data.count, true)
		else
			toast.Text:SetAnimatedValue(toast._data.count)

			toast.AnimOut:Stop()
			toast.AnimOut:Play()
		end
	end
end


local function PLAYER_MONEY()
	local cur = GetMoney()

	if cur - old ~= 0 then
		Toast_SetUp("PLAYER_MONEY", cur - old)
	end

	old = cur
end

local function Enable()
	if C.db.profile.types.loot_gold.enabled then
		old = GetMoney()

		E:RegisterEvent("PLAYER_MONEY", PLAYER_MONEY)
	end
end

local function Disable()
	E:UnregisterEvent("PLAYER_MONEY", PLAYER_MONEY)
end

local function Test()
	Toast_SetUp("LOOT_GOLD_TEST", m_random(-100000, 100000))
end

E:RegisterOptions("loot_gold", {
	enabled = true,
	anchor = 1,
	dnd = false,
	sfx = true,
}, {
	name = L["TYPE_LOOT_GOLD"],
	get = function(info)
		return C.db.profile.types.loot_gold[info[#info]]
	end,
	set = function(info, value)
		C.db.profile.types.loot_gold[info[#info]] = value
	end,
	args = {
		enabled = {
			order = 1,
			type = "toggle",
			name = L["ENABLE"],
			set = function(_, value)
				C.db.profile.types.loot_gold.enabled = value

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

E:RegisterSystem("loot_gold", Enable, Disable, Test)
