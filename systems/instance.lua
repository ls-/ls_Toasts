local _, addonTable = ...
local E, L, C = addonTable.E, addonTable.L, addonTable.C

-- Lua
local _G = getfenv(0)

-- Blizz
local C_Scenario = _G.C_Scenario

--[[ luacheck: globals
	GameTooltip GetLFGCompletionReward GetLFGCompletionRewardItem GetLFGCompletionRewardItemLink GetLFGDungeonInfo
	GetMoneyString UnitLevel

	LE_SCENARIO_TYPE_LEGION_INVASION LFG_SUBTYPEID_HEROIC MAX_PLAYER_LEVEL
]]

-- Mine
local function Slot_OnEnter(self)
	if self._data.type then
		if self._data.type == "item" then
			GameTooltip:SetHyperlink(self._data.link)
		elseif self._data.type == "xp" then
			GameTooltip:AddLine(L["YOU_RECEIVED"])
			GameTooltip:AddLine(L["XP_FORMAT"]:format(self._data.count), 1, 1, 1)
		elseif self._data.type == "money" then
			GameTooltip:AddLine(L["YOU_RECEIVED"])
			GameTooltip:AddLine(GetMoneyString(self._data.count, true), 1, 1, 1)
		end

		GameTooltip:Show()
	end
end

local function Toast_SetUp(event, name, subTypeID, textureFile, moneyReward, xpReward, numItemRewards, isScenario, isScenarioBonusComplete)
	local toast = E:GetToast()
	local usedSlots = 0
	local soundFile

	if moneyReward and moneyReward > 0 then
		usedSlots = usedSlots + 1

		local slot = toast["Slot" .. usedSlots]
		if slot then
			slot.Icon:SetTexture("Interface\\Icons\\inv_misc_coin_02")

			slot._data.type = "money"
			slot._data.count = moneyReward

			slot:HookScript("OnEnter", Slot_OnEnter)
			slot:Show()
		end
	end

	if xpReward and xpReward > 0 and UnitLevel("player") < MAX_PLAYER_LEVEL then
		usedSlots = usedSlots + 1

		local slot = toast["Slot" .. usedSlots]
		if slot then
			slot.Icon:SetTexture("Interface\\Icons\\xp_icon")

			slot._data.type = "xp"
			slot._data.count = xpReward

			slot:HookScript("OnEnter", Slot_OnEnter)
			slot:Show()
		end
	end

	for i = 1, numItemRewards or 0 do
		local link = GetLFGCompletionRewardItemLink(i)
		if link then
			usedSlots = usedSlots + 1

			local slot = toast["Slot" .. usedSlots]
			if slot then
				local texture = GetLFGCompletionRewardItem(i)
				texture = texture or "Interface\\Icons\\INV_Box_02"

				slot.Icon:SetTexture(texture)

				slot._data.type = "item"
				slot._data.link = link

				slot:HookScript("OnEnter", Slot_OnEnter)
				slot:Show()
			end
		end
	end

	if isScenario then
		if isScenarioBonusComplete and not toast.Bonus.isHidden then
			toast.Bonus:Show()
		end

		toast.Title:SetText(L["SCENARIO_COMPLETED"])

		soundFile = 31754 -- SOUNDKIT.UI_SCENARIO_ENDING
	else
		if subTypeID == LFG_SUBTYPEID_HEROIC and not toast.Skull.isHidden then
			toast.Skull:Show()
		end

		toast.Title:SetText(L["DUNGEON_COMPLETED"])

		soundFile = 17316 -- SOUNDKIT.LFG_REWARDS
	end

	toast:SetBackground("dungeon")
	toast.Text:SetText(name)
	toast.Icon:SetTexture(textureFile or "Interface\\LFGFrame\\LFGIcon-Dungeon")
	toast.IconBorder:Show()

	toast._data.event = event
	toast._data.sound_file = C.db.profile.types.instance.sfx and soundFile
	toast._data.used_slots = usedSlots

	toast:Spawn(C.db.profile.types.instance.anchor, C.db.profile.types.instance.dnd)
end

local function LFG_COMPLETION_REWARD()
	if C_Scenario.IsInScenario() and not C_Scenario.TreatScenarioAsDungeon() then
		local _, _, _, _, hasBonusStep, isBonusStepComplete, _, _, _, scenarioType = C_Scenario.GetInfo()

		if scenarioType ~= LE_SCENARIO_TYPE_LEGION_INVASION then
			local name, _, subTypeID, textureFile, moneyBase, moneyVar, experienceBase, experienceVar, numStrangers, numItemRewards = GetLFGCompletionReward()

			Toast_SetUp("LFG_COMPLETION_REWARD", name, subTypeID, textureFile, moneyBase + moneyVar * numStrangers, experienceBase + experienceVar * numStrangers, numItemRewards, true, hasBonusStep and isBonusStepComplete)
		end
	else
		local name, _, subTypeID, textureFile, moneyBase, moneyVar, experienceBase, experienceVar, numStrangers, numItemRewards = GetLFGCompletionReward()

		Toast_SetUp("LFG_COMPLETION_REWARD", name, subTypeID, textureFile, moneyBase + moneyVar * numStrangers, experienceBase + experienceVar * numStrangers, numItemRewards)
	end
end

local function Enable()
	if C.db.profile.types.instance.enabled then
		E:RegisterEvent("LFG_COMPLETION_REWARD", LFG_COMPLETION_REWARD)
	end
end

local function Disable()
	E:UnregisterEvent("LFG_COMPLETION_REWARD", LFG_COMPLETION_REWARD)
end

local function Test()
	-- dungeon, Wailing Caverns
	local name, _, subTypeID = GetLFGDungeonInfo(1)
	if name then
		Toast_SetUp("INSTANCE_TEST", name, subTypeID, nil, 123456, 123456, 0)
	end

	-- scenario, Crypt of Forgotten Kings
	name, _, subTypeID = GetLFGDungeonInfo(504)
	if name then
		Toast_SetUp("INSTANCE_TEST", name, subTypeID, nil, 123456, 123456, 0, true, true)
	end
end

E:RegisterOptions("instance", {
	enabled = true,
	anchor = 1,
	dnd = false,
	sfx = true,
}, {
	name = L["TYPE_DUNGEON"],
	get = function(info)
		return C.db.profile.types.instance[info[#info]]
	end,
	set = function(info, value)
		C.db.profile.types.instance[info[#info]] = value
	end,
	args = {
		enabled = {
			order = 1,
			type = "toggle",
			name = L["ENABLE"],
			set = function(_, value)
				C.db.profile.types.instance.enabled = value

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

E:RegisterSystem("instance", Enable, Disable, Test)
