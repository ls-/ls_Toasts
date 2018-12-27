local _, addonTable = ...
local E, L, C = addonTable.E, addonTable.L, addonTable.C

-- Lua
local _G = getfenv(0)
local m_random = _G.math.random
local s_lower = _G.string.lower
local s_split = _G.string.split
local tonumber = _G.tonumber

-- Blizz
local C_Timer = _G.C_Timer

-- Mine
local TITLE_DE_TEMPLATE = "%s|cff00ff00%s|r|TInterface\\Buttons\\UI-GroupLoot-DE-Up:0:0:0:0:32:32:0:32:0:31|t"
local TITLE_GREED_TEMPLATE = "%s|cff00ff00%s|r|TInterface\\Buttons\\UI-GroupLoot-Coin-Up:0:0:0:0:32:32:0:32:0:31|t"
local TITLE_NEED_TEMPLATE = "%s|cff00ff00%s|r|TInterface\\Buttons\\UI-GroupLoot-Dice-Up:0:0:0:0:32:32:0:32:0:31|t"

local function Toast_OnClick(self)
	if self._data then
		local slot = E:SearchBagsForItemID(self._data.item_id)

		if slot >= 0 then
			OpenBag(slot)
		end
	end
end

local function Toast_OnEnter(self)
	if self._data then
		if self._data.tooltip_link:find("item") then
			GameTooltip:SetHyperlink(self._data.tooltip_link)
			GameTooltip:Show()
		elseif self._data.tooltip_link:find("battlepet") then
			local _, speciesID, level, breedQuality, maxHealth, power, speed = s_split(":", self._data.tooltip_link)
			BattlePetToolTip_Show(tonumber(speciesID), tonumber(level), tonumber(breedQuality), tonumber(maxHealth), tonumber(power), tonumber(speed))
		end
	end
end

local function PostSetAnimatedValue(self, value)
	self:SetText(value == 1 and "" or value)
end

local function Toast_SetUp(event, link, quantity, rollType, roll, factionGroup, isItem, isHonor, isPersonal, lessAwesome, isUpgraded, baseQuality, isLegendary, isStorePurchase, isAzerite)
	if isItem then
		if link then
			local sanitizedLink, originalLink, _, itemID = E:SanitizeLink(link)
			local toast, isNew, isQueued = E:GetToast(event, "link", sanitizedLink)

			if isNew then
				local name, _, quality, _, _, _, _, _, _, icon = GetItemInfo(originalLink)

				if name and (quality and quality >= C.db.profile.types.loot_special.threshold and quality <= 5) then
					local color = ITEM_QUALITY_COLORS[quality] or ITEM_QUALITY_COLORS[1]
					local title = L["YOU_WON"]
					local soundFile = 31578 -- SOUNDKIT.UI_EPICLOOT_TOAST
					local bgTexture

					toast.IconText1.PostSetAnimatedValue = PostSetAnimatedValue

					if isPersonal or lessAwesome then
						title = L["YOU_RECEIVED"]

						if lessAwesome then
							soundFile = 51402 -- SOUNDKIT.UI_RAID_LOOT_TOAST_LESSER_ITEM_WON
						end
					end

					if isUpgraded then
						if baseQuality and baseQuality < quality then
							title = L["ITEM_UPGRADED_FORMAT"]:format(color.hex, _G["ITEM_QUALITY"..quality.."_DESC"])
						else
							title = L["ITEM_UPGRADED"]
						end

						soundFile = 51561 -- SOUNDKIT.UI_WARFORGED_ITEM_LOOT_TOAST
						bgTexture = "upgrade"

						local upgradeTexture = LOOTUPGRADEFRAME_QUALITY_TEXTURES[quality] or LOOTUPGRADEFRAME_QUALITY_TEXTURES[2]

						for i = 1, 5 do
							toast["Arrow"..i]:SetAtlas(upgradeTexture.arrow, true)
						end
					end

					if factionGroup then
						bgTexture = s_lower(factionGroup)
					end

					if isLegendary then
						title = L["ITEM_LEGENDARY"]
						soundFile = 63971 -- SOUNDKIT.UI_LEGENDARY_LOOT_TOAST
						bgTexture = "legendary"

						if not toast.Dragon.isHidden then
							toast.Dragon:Show()
						end
					end

					if isStorePurchase then
						title = L["BLIZZARD_STORE_PURCHASE_DELIVERED"]
						soundFile = 39517 -- SOUNDKIT.UI_IG_STORE_PURCHASE_DELIVERED_TOAST_01
						bgTexture = "store"
					end

					if isAzerite then
						title = L["ITEM_AZERITE_EMPOWERED"]
						soundFile = 118238 -- SOUNDKIT.UI_AZERITE_EMPOWERED_ITEM_LOOT_TOAST
						bgTexture = "azerite"
					end

					if rollType == LOOT_ROLL_TYPE_NEED then
						title = TITLE_NEED_TEMPLATE:format(title, roll)
					elseif rollType == LOOT_ROLL_TYPE_GREED then
						title = TITLE_GREED_TEMPLATE:format(title, roll)
					elseif rollType == LOOT_ROLL_TYPE_DISENCHANT then
						title = TITLE_DE_TEMPLATE:format(title, roll)
					end

					if quality >= C.db.profile.colors.threshold then
						if C.db.profile.colors.name then
							name = color.hex..name.."|r"
						end

						if C.db.profile.colors.border then
							toast.Border:SetVertexColor(color.r, color.g, color.b)
						end

						if C.db.profile.colors.icon_border then
							toast.IconBorder:SetVertexColor(color.r, color.g, color.b)
						end
					end

					if C.db.profile.types.loot_special.ilvl then
						local iLevel = E:GetItemLevel(originalLink)

						if iLevel > 0 then
							name = "["..color.hex..iLevel.."|r] "..name
						end
					end

					if bgTexture then
						toast:SetBackground(bgTexture)
					end

					toast.Title:SetText(title)
					toast.Text:SetText(name)
					toast.Icon:SetTexture(icon)
					toast.IconBorder:Show()
					toast.IconText1:SetAnimatedValue(quantity, true)

					toast._data = {
						count = quantity,
						event = event,
						item_id = itemID,
						link = sanitizedLink,
						show_arrows = isUpgraded,
						tooltip_link = originalLink,
					}

					if C.db.profile.types.loot_special.sfx then
						toast._data.sound_file = soundFile
					end

					toast:HookScript("OnClick", Toast_OnClick)
					toast:HookScript("OnEnter", Toast_OnEnter)
					toast:Spawn(C.db.profile.types.loot_special.dnd)
				else
					toast:Recycle()
				end
			else
				if rollType then
					if rollType == LOOT_ROLL_TYPE_NEED then
						toast.Title:SetFormattedText(TITLE_NEED_TEMPLATE, L["YOU_WON"], roll)
					elseif rollType == LOOT_ROLL_TYPE_GREED then
						toast.Title:SetFormattedText(TITLE_GREED_TEMPLATE, L["YOU_WON"], roll)
					elseif rollType == LOOT_ROLL_TYPE_DISENCHANT then
						toast.Title:SetFormattedText(TITLE_DE_TEMPLATE, L["YOU_WON"], roll)
					end
				end

				if isQueued then
					toast._data.count = toast._data.count + quantity
					toast.IconText1:SetAnimatedValue(toast._data.count, true)
				else
					toast._data.count = toast._data.count + quantity
					toast.IconText1:SetAnimatedValue(toast._data.count)

					toast.IconText2:SetText("+"..quantity)
					toast.IconText2.Blink:Stop()
					toast.IconText2.Blink:Play()

					toast.AnimOut:Stop()
					toast.AnimOut:Play()
				end
			end
		end
	elseif isHonor then
		local toast, isNew, isQueued = E:GetToast(event, "is_honor", true)

		if isNew then
			if factionGroup then
				toast:SetBackground(s_lower(factionGroup))
			end

			toast.Title:SetText(L["YOU_RECEIVED"])
			toast.Text:SetText(L["HONOR_POINTS"])
			toast.Icon:SetTexture("Interface\\Icons\\Achievement_LegionPVPTier4")
			toast.IconBorder:Show()
			toast.IconText1:SetAnimatedValue(quantity, true)

			toast._data = {
				count = quantity,
				event = event,
				is_honor = true,
			}

			if C.db.profile.types.loot_special.sfx then
				toast._data.sound_file = 31578 -- SOUNDKIT.UI_EPICLOOT_TOAST
			end

			toast:Spawn(C.db.profile.types.loot_special.dnd)
		else
			if isQueued then
				toast._data.count = toast._data.count + quantity
				toast.IconText1:SetAnimatedValue(toast._data.count, true)
			else
				toast._data.count = toast._data.count + quantity
				toast.IconText1:SetAnimatedValue(toast._data.count)

				toast.IconText2:SetText("+"..quantity)
				toast.IconText2.Blink:Stop()
				toast.IconText2.Blink:Play()

				toast.AnimOut:Stop()
				toast.AnimOut:Play()
			end
		end
	end
end

local function AZERITE_EMPOWERED_ITEM_LOOTED(link)
	Toast_SetUp("AZERITE_EMPOWERED_ITEM_LOOTED", link, 1, nil, nil, nil, true, nil, nil, nil, nil, nil, nil, nil, true)
end

local function LOOT_ITEM_ROLL_WON(link, quantity, rollType, roll, isUpgraded)
	Toast_SetUp("LOOT_ITEM_ROLL_WON", link, quantity, rollType, roll, nil, true, nil, nil, nil, isUpgraded)
end

local function SHOW_LOOT_TOAST(typeID, link, quantity, _, _, isPersonal, _, lessAwesome, isUpgraded)
	local factionGroup = UnitFactionGroup("player")
	factionGroup = (typeID == "honor" and factionGroup ~= "Neutral") and factionGroup or nil

	Toast_SetUp("SHOW_LOOT_TOAST", link, quantity, nil, nil, factionGroup, typeID == "item", typeID == "honor", isPersonal, lessAwesome, isUpgraded)
end

local function SHOW_LOOT_TOAST_UPGRADE(link, quantity, _, _, baseQuality)
	Toast_SetUp("SHOW_LOOT_TOAST_UPGRADE", link, quantity, nil, nil, nil, true, nil, nil, nil, true, baseQuality)
end

local function SHOW_PVP_FACTION_LOOT_TOAST(typeID, link, quantity, _, _, isPersonal, lessAwesome)
	local factionGroup = UnitFactionGroup("player")
	factionGroup = factionGroup ~= "Neutral" and factionGroup or nil

	Toast_SetUp("SHOW_PVP_FACTION_LOOT_TOAST", link, quantity, nil, nil, factionGroup, typeID == "item", typeID == "honor", isPersonal, lessAwesome)
end

local function SHOW_RATED_PVP_REWARD_TOAST(typeID, link, quantity, _, _, isPersonal, lessAwesome)
	local factionGroup = UnitFactionGroup("player")
	factionGroup = factionGroup ~= "Neutral" and factionGroup or nil

	Toast_SetUp("SHOW_RATED_PVP_REWARD_TOAST", link, quantity, nil, nil, factionGroup, typeID == "item", typeID == "honor", isPersonal, lessAwesome)
end

local function SHOW_LOOT_TOAST_LEGENDARY_LOOTED(link)
	Toast_SetUp("SHOW_LOOT_TOAST_LEGENDARY_LOOTED", link, 1, nil, nil, nil, true, nil, nil, nil, nil, nil, true)
end

local function STORE_PRODUCT_DELIVERED(_, _, _, payloadID)
	local _, link = GetItemInfo(payloadID)

	if link then
		Toast_SetUp("STORE_PRODUCT_DELIVERED", link, 1, nil, nil, nil, true, nil, nil, nil, nil, nil, nil, true)
	else
		return C_Timer.After(0.25, function() STORE_PRODUCT_DELIVERED(nil, nil, nil, payloadID) end)
	end
end

local function BonusRollFrame_FinishedFading_Disabled(self)
	GroupLootContainer_RemoveFrame(GroupLootContainer, self:GetParent())
end

local function BonusRollFrame_FinishedFading_Enabled(self)
	local frame = self:GetParent()

	if frame.rewardType == "item" or frame.rewardType == "artifact_power" then
		Toast_SetUp("LOOT_ITEM_BONUS_ROLL_WON", frame.rewardLink, frame.rewardQuantity, nil, nil, nil, true)
	end

	GroupLootContainer_RemoveFrame(GroupLootContainer, frame)
end

local function Enable()
	if C.db.profile.types.loot_special.enabled then
		E:RegisterEvent("AZERITE_EMPOWERED_ITEM_LOOTED", AZERITE_EMPOWERED_ITEM_LOOTED)
		E:RegisterEvent("LOOT_ITEM_ROLL_WON", LOOT_ITEM_ROLL_WON)
		E:RegisterEvent("SHOW_LOOT_TOAST_LEGENDARY_LOOTED", SHOW_LOOT_TOAST_LEGENDARY_LOOTED)
		E:RegisterEvent("SHOW_LOOT_TOAST_UPGRADE", SHOW_LOOT_TOAST_UPGRADE)
		E:RegisterEvent("SHOW_LOOT_TOAST", SHOW_LOOT_TOAST)
		E:RegisterEvent("SHOW_PVP_FACTION_LOOT_TOAST", SHOW_PVP_FACTION_LOOT_TOAST)
		E:RegisterEvent("SHOW_RATED_PVP_REWARD_TOAST", SHOW_RATED_PVP_REWARD_TOAST)
		E:RegisterEvent("STORE_PRODUCT_DELIVERED", STORE_PRODUCT_DELIVERED)

		BonusRollFrame.FinishRollAnim:SetScript("OnFinished", BonusRollFrame_FinishedFading_Enabled)
	else
		BonusRollFrame.FinishRollAnim:SetScript("OnFinished", BonusRollFrame_FinishedFading_Disabled)
	end
end

local function Disable()
	E:UnregisterEvent("AZERITE_EMPOWERED_ITEM_LOOTED", AZERITE_EMPOWERED_ITEM_LOOTED)
	E:UnregisterEvent("LOOT_ITEM_ROLL_WON", LOOT_ITEM_ROLL_WON)
	E:UnregisterEvent("SHOW_LOOT_TOAST_LEGENDARY_LOOTED", SHOW_LOOT_TOAST_LEGENDARY_LOOTED)
	E:UnregisterEvent("SHOW_LOOT_TOAST_UPGRADE", SHOW_LOOT_TOAST_UPGRADE)
	E:UnregisterEvent("SHOW_LOOT_TOAST", SHOW_LOOT_TOAST)
	E:UnregisterEvent("SHOW_PVP_FACTION_LOOT_TOAST", SHOW_PVP_FACTION_LOOT_TOAST)
	E:UnregisterEvent("SHOW_RATED_PVP_REWARD_TOAST", SHOW_RATED_PVP_REWARD_TOAST)
	E:UnregisterEvent("STORE_PRODUCT_DELIVERED", STORE_PRODUCT_DELIVERED)

	BonusRollFrame.FinishRollAnim:SetScript("OnFinished", BonusRollFrame_FinishedFading_Disabled)
end

local function Test()
	-- honour
	local factionGroup = UnitFactionGroup("player")
	factionGroup = factionGroup ~= "Neutral" and factionGroup or "Horde"

	Toast_SetUp("SPECIAL_LOOT_TEST", nil, m_random(100, 400), nil, nil, factionGroup, nil, true)

	-- roll won, Tunic of the Underworld
	local _, link = GetItemInfo(134439)

	if link then
		Toast_SetUp("SPECIAL_LOOT_TEST", link, 1, 1, 64, nil, true)
	end

	-- pvp, Fearless Gladiator's Dreadplate Girdle
	_, link = GetItemInfo(142679)

	if link then
		Toast_SetUp("SPECIAL_LOOT_TEST", link, 1, nil, nil, factionGroup, true)
	end

	-- titanforged, Bonespeaker Bracers
	_, link = GetItemInfo("item:134222::::::::110:63::36:4:3432:41:1527:3337:::")

	if link then
		Toast_SetUp("SPECIAL_LOOT_TEST", link, 1, nil, nil, nil, true, nil, nil, nil, true)
	end

	-- upgraded from uncommon to epic, Nightsfall Brestplate
	_, link = GetItemInfo("item:139055::::::::110:70::36:3:3432:1507:3336:::")

	if link then
		Toast_SetUp("SPECIAL_LOOT_TEST", link, 1, nil, nil, nil, true, nil, nil, nil, true, 2)
	end

	-- legendary, Aman'Thul's Vision
	_, link = GetItemInfo("item:154172::::::::110:64:::1:3571:::")

	if link then
		Toast_SetUp("SPECIAL_LOOT_TEST", link, 1, nil, nil, nil, true, nil, nil, nil, nil, nil, true)
	end

	-- store, Pouch of Enduring Wisdom
	_, link = GetItemInfo(105911)

	if link then
		Toast_SetUp("SPECIAL_LOOT_TEST", link, 1, nil, nil, nil, true, nil, nil, nil, nil, nil, nil, true)
	end

	-- azerite, Vest of the Champion
	_, link = GetItemInfo("item:159906::::::::110:581::11::::")

	if link then
		Toast_SetUp("SPECIAL_LOOT_TEST", link, 1, nil, nil, nil, true, nil, nil, nil, nil, nil, nil, nil, true)
	end
end

E:RegisterOptions("loot_special", {
	enabled = true,
	dnd = false,
	sfx = true,
	ilvl = true,
	threshold = 1,
}, {
	name = L["TYPE_LOOT_SPECIAL"],
	get = function(info)
		return C.db.profile.types.loot_special[info[#info]]
	end,
	set = function(info, value)
		C.db.profile.types.loot_special[info[#info]] = value
	end,
	args = {
		desc = {
			order = 1,
			type = "description",
			name = L["TYPE_LOOT_SPECIAL_DESC"],
		},
		enabled = {
			order = 2,
			type = "toggle",
			name = L["ENABLE"],
			set = function(_, value)
				C.db.profile.types.loot_special.enabled = value

				if value then
					Enable()
				else
					Disable()
				end
			end
		},
		dnd = {
			order = 3,
			type = "toggle",
			name = L["DND"],
			desc = L["DND_TOOLTIP"],
		},
		sfx = {
			order = 3,
			type = "toggle",
			name = L["SFX"],
		},
		ilvl = {
			order = 5,
			type = "toggle",
			name = L["SHOW_ILVL"],
			desc = L["SHOW_ILVL_DESC"],
		},
		threshold = {
			order = 6,
			type = "select",
			name = L["LOOT_THRESHOLD"],
			values = {
				[1] = ITEM_QUALITY_COLORS[1].hex..ITEM_QUALITY1_DESC.."|r",
				[2] = ITEM_QUALITY_COLORS[2].hex..ITEM_QUALITY2_DESC.."|r",
				[3] = ITEM_QUALITY_COLORS[3].hex..ITEM_QUALITY3_DESC.."|r",
				[4] = ITEM_QUALITY_COLORS[4].hex..ITEM_QUALITY4_DESC.."|r",
				[5] = ITEM_QUALITY_COLORS[5].hex..ITEM_QUALITY5_DESC.."|r",
			},
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

E:RegisterSystem("loot_special", Enable, Disable, Test)
