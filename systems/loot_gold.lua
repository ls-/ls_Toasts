local _, addonTable = ...
local E, L, C = addonTable.E, addonTable.L, addonTable.C

-- Lua
local _G = getfenv(0)
local m_random = _G.math.random
local tonumber = _G.tonumber
local tostring = _G.tostring

-- Mine
local old

local function PostSetAnimatedValue(self, value)
	self:SetText(GetMoneyString(value))
end

local function Toast_SetUp(event, quantity)
	local toast, isNew, isQueued = E:GetToast(nil, "event", event)

	if isNew then
		if quantity >= C.db.profile.types.loot_gold.threshold then
			toast.Text.PostSetAnimatedValue = PostSetAnimatedValue

			if C.db.profile.colors.border then
				toast.Border:SetVertexColor(0.9, 0.75, 0.26)
			end

			if C.db.profile.colors.icon_border then
				toast.IconBorder:SetVertexColor(0.9, 0.75, 0.26)
			end

			toast.Title:SetText(L["YOU_RECEIVED"])
			toast.Text:SetAnimatedValue(quantity, true)
			toast.Icon:SetTexture("Interface\\Icons\\INV_Misc_Coin_02")
			toast.IconBorder:Show()

			toast._data = {
				event = event,
				count = quantity,
			}

			if C.db.profile.types.loot_gold.sfx then
				toast._data.sound_file = 865 -- SOUNDKIT.IG_BACKPACK_COIN_OK
			end

			toast:Spawn(C.db.profile.types.loot_gold.dnd)
		else
			toast:Recycle()
		end
	else
		if isQueued then
			toast._data.count = toast._data.count + quantity
			toast.Text:SetAnimatedValue(toast._data.count, true)
		else
			toast._data.count = toast._data.count + quantity
			toast.Text:SetAnimatedValue(toast._data.count)

			toast.AnimOut:Stop()
			toast.AnimOut:Play()
		end
	end
end


local function PLAYER_MONEY()
	local cur = GetMoney()

	if cur - old > 0 then
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
	Toast_SetUp("LOOT_GOLD_TEST", m_random(C.db.profile.types.loot_gold.threshold + 1, C.db.profile.types.loot_gold.threshold * 2))
end

E:RegisterOptions("loot_gold", {
	enabled = true,
	dnd = false,
	sfx = true,
	threshold = 1,
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
		threshold = {
			order = 4,
			type = "input",
			name = L["COPPER_THRESHOLD"],
			desc = L["COPPER_THRESHOLD_DESC"],
			get = function()
				return tostring(C.db.profile.types.loot_gold.threshold)
			end,
			set = function(_, value)
				value = tonumber(value)
					C.db.profile.types.loot_gold.threshold = value >= 1 and value or 1
			end,
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
