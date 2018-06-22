local _, addonTable = ...
local E, L, C = addonTable.E, addonTable.L, addonTable.C

-- Lua
local _G = getfenv(0)
local next = _G.next
local pcall = _G.pcall
local select = _G.select

-- Blizz
local C_Scenario = _G.C_Scenario
local C_TaskQuest = _G.C_TaskQuest

-- Mine
local CURRENCY_TEMPLATE = "%s|T%s:0|t"

local function Slot_OnEnter(self)
	local data = self._data

	if data then
		if data.type == "item" then
			GameTooltip:SetHyperlink(data.link)
		elseif data.type == "xp" then
			GameTooltip:AddLine(L["YOU_RECEIVED"])
			GameTooltip:AddLine(L["XP_FORMAT"]:format(data.count), 1, 1, 1)
		elseif data.type == "money" then
			GameTooltip:AddLine(L["YOU_RECEIVED"])
			GameTooltip:AddLine(GetMoneyString(data.count), 1, 1, 1)
		elseif data.type == "currency" then
			GameTooltip:AddLine(L["YOU_RECEIVED"])
			GameTooltip:AddLine(CURRENCY_TEMPLATE:format(data.count, data.texture))
		end

		GameTooltip:Show()
	end
end

local function Toast_SetUp(event, isUpdate, questID, name, moneyReward, xpReward, numCurrencyRewards, itemReward, isInvasion, isInvasionBonusComplete)
	local toast, isNew, isQueued = E:GetToast(nil, "quest_id", questID)

	if isUpdate and isNew then
		toast:Recycle()

		return
	end

	-- local scenarioName, _, _, _, hasBonusStep, isBonusStepComplete, _, xp, money, _, areaName = C_Scenario.GetInfo()
	-- local scenarioName, _, _, _, hasBonusStep, isBonusStepComplete, _, xp, money, _, areaName =
	-- "Invasion: Azshara", 0, 0, 0, false, false, true, 12345, 12345, 4, "Azshara"

	if isNew then
		local usedSlots = 0
		local soundFile

		if moneyReward and moneyReward > 0 then
			usedSlots = usedSlots + 1
			local slot = toast["Slot"..usedSlots]

			if slot then
				slot.Icon:SetTexture("Interface\\Icons\\inv_misc_coin_02")

				slot._data = {
					type = "money",
					count = moneyReward,
				}

				slot:HookScript("OnEnter", Slot_OnEnter)
				slot:Show()
			end
		end

		if xpReward and xpReward > 0 and UnitLevel("player") < MAX_PLAYER_LEVEL then
			usedSlots = usedSlots + 1
			local slot = toast["Slot"..usedSlots]

			if slot then
				slot.Icon:SetTexture("Interface\\Icons\\xp_icon")

				slot._data = {
					type = "xp",
					count = xpReward,
				}

				slot:HookScript("OnEnter", Slot_OnEnter)
				slot:Show()
			end
		end

		for i = 1, numCurrencyRewards or 0 do
			usedSlots = usedSlots + 1
			local slot = toast["Slot"..usedSlots]

			if slot then
				local _, texture, count = GetQuestLogRewardCurrencyInfo(i, questID)
				texture = texture or "Interface\\Icons\\INV_Box_02"

				slot.Icon:SetTexture(texture)

				slot._data = {
					type = "currency",
					count = count,
					texture = texture,
				}

				slot:HookScript("OnEnter", Slot_OnEnter)
				slot:Show()
			end
		end

		if isInvasion then
			if isInvasionBonusComplete and not toast.Bonus.isHidden then
				toast.Bonus:Show()
			end

			if C.db.profile.colors.border then
				toast.Border:SetVertexColor(60 / 255, 255 / 255, 38 / 255) -- fel green #3cff26
			end

			if C.db.profile.colors.icon_border then
				toast.IconBorder:SetVertexColor(60 / 255, 255 / 255, 38 / 255) -- fel green #3cff26
			end

			toast:SetBackground("legion")
			toast.Title:SetText(L["SCENARIO_INVASION_COMPLETED"])
			toast.Icon:SetTexture("Interface\\Icons\\Ability_Warlock_DemonicPower")

			soundFile = 31754 -- SOUNDKIT.UI_SCENARIO_ENDING
		else
			local _, _, worldQuestType, rarity, _, tradeskillLineIndex = GetQuestTagInfo(questID)
			local color = WORLD_QUEST_QUALITY_COLORS[rarity] or WORLD_QUEST_QUALITY_COLORS[1]

			if worldQuestType == LE_QUEST_TAG_TYPE_PVP then
				toast.Icon:SetTexture("Interface\\Icons\\achievement_arena_2v2_1")
			elseif worldQuestType == LE_QUEST_TAG_TYPE_PET_BATTLE then
				toast.Icon:SetTexture("Interface\\Icons\\INV_Pet_BattlePetTraining")
			elseif worldQuestType == LE_QUEST_TAG_TYPE_PROFESSION and tradeskillLineIndex then
				toast.Icon:SetTexture(select(2, GetProfessionInfo(tradeskillLineIndex)))
			elseif worldQuestType == LE_QUEST_TAG_TYPE_DUNGEON or worldQuestType == LE_QUEST_TAG_TYPE_RAID then
				toast.Icon:SetTexture("Interface\\Icons\\INV_Misc_Bone_Skull_02")
			else
				toast.Icon:SetTexture("Interface\\Icons\\Achievement_Quests_Completed_TwilightHighlands")
			end

			if rarity >= C.db.profile.colors.threshold then
				if C.db.profile.colors.border then
					toast.Border:SetVertexColor(color.r, color.g, color.b)
				end

				if C.db.profile.colors.icon_border then
					toast.IconBorder:SetVertexColor(color.r, color.g, color.b)
				end
			end

			toast:SetBackground("worldquest")
			toast.Title:SetText(L["WORLD_QUEST_COMPLETED"])

			soundFile = 73277 -- SOUNDKIT.UI_WORLDQUEST_COMPLETE
		end

		toast.Text:SetText(name)
		toast.IconBorder:Show()

		toast._data = {
			event = event,
			quest_id = questID,
			used_slots = usedSlots,
		}

		if C.db.profile.types.world.sfx then
			toast._data.sound_file = soundFile
		end

		toast:Spawn(C.db.profile.types.world.dnd)
	else
		if itemReward then
			toast._data.used_slots = toast._data.used_slots + 1
			local slot = toast["Slot"..toast._data.used_slots]

			if slot then
				local _, _, _, _, texture = GetItemInfoInstant(itemReward)
				texture = texture or "Interface\\Icons\\INV_Box_02"

				slot.Icon:SetTexture(texture)

				slot._data = {
					type = "item",
					link = itemReward,
				}

				slot:HookScript("OnEnter", Slot_OnEnter)
				slot:Show()
			end
		end

		if not isQueued then
			toast.AnimOut:Stop()
			toast.AnimOut:Play()
		end
	end
end

local function SCENARIO_COMPLETED(questID)
	local scenarioName, _, _, _, hasBonusStep, isBonusStepComplete, _, xp, money, scenarioType, areaName = C_Scenario.GetInfo()

	if scenarioType == LE_SCENARIO_TYPE_LEGION_INVASION then
		if questID then
			Toast_SetUp("SCENARIO_COMPLETED", false, questID, areaName or scenarioName, money, xp, nil, nil, true, hasBonusStep and isBonusStepComplete)
		end
	end
end

local function QUEST_TURNED_IN(questID)
	if QuestUtils_IsQuestWorldQuest(questID) then
		Toast_SetUp("QUEST_TURNED_IN", false, questID, C_TaskQuest.GetQuestInfoByQuestID(questID), GetQuestLogRewardMoney(questID), GetQuestLogRewardXP(questID), GetNumQuestLogRewardCurrencies(questID))
	end
end

local function QUEST_LOOT_RECEIVED(questID, itemLink)
	--- QUEST_LOOT_RECEIVED may fire before QUEST_TURNED_IN
	if not E:FindToast(nil, "quest_id", questID) then
		QUEST_TURNED_IN(questID)
	end

	Toast_SetUp("QUEST_LOOT_RECIEVED", true, questID, nil, nil, nil, nil, itemLink)
end

local function Enable()
	if C.db.profile.types.world.enabled then
		E:RegisterEvent("SCENARIO_COMPLETED", SCENARIO_COMPLETED)
		E:RegisterEvent("QUEST_TURNED_IN", QUEST_TURNED_IN)
		E:RegisterEvent("QUEST_LOOT_RECEIVED", QUEST_LOOT_RECEIVED)
	end
end

local function Disable()
	E:UnregisterEvent("SCENARIO_COMPLETED")
	E:UnregisterEvent("QUEST_TURNED_IN")
	E:UnregisterEvent("QUEST_LOOT_RECEIVED")
end

local function Test()
	-- reward, Blood of Sargeras
	local _, link = GetItemInfo(124124)

	if link then
		-- invasion
		Toast_SetUp("WORLD_TEST", false, 43301, "Invasion!", 123456, 123456, nil, nil, true)
		Toast_SetUp("WORLD_TEST", true, 43301, nil, nil, nil, nil, link)

		-- world quest, may not work
		local quests = C_TaskQuest.GetQuestsForPlayerByMapID(1014)

		if not quests or #quests == 0 then
			quests = C_TaskQuest.GetQuestsForPlayerByMapID(1015)

			if not quests or #quests == 0 then
				quests = C_TaskQuest.GetQuestsForPlayerByMapID(1017)

				if not quests or #quests == 0 then
					quests = C_TaskQuest.GetQuestsForPlayerByMapID(1018)

					if not quests or #quests == 0 then
						quests = C_TaskQuest.GetQuestsForPlayerByMapID(1021)

						if not quests or #quests == 0 then
							quests = C_TaskQuest.GetQuestsForPlayerByMapID(1024)

							if not quests or #quests == 0 then
								quests = C_TaskQuest.GetQuestsForPlayerByMapID(1033)

								if not quests or #quests == 0 then
									quests = C_TaskQuest.GetQuestsForPlayerByMapID(1096)
								end
							end
						end
					end
				end
			end
		end

		if quests then
			for _, quest in next, quests do
				if HaveQuestData(quest.questId) then
					if QuestUtils_IsQuestWorldQuest(quest.questId) then
						Toast_SetUp("WORLD_TEST", false, quest.questId, C_TaskQuest.GetQuestInfoByQuestID(quest.questId), 123456, 123456)
						Toast_SetUp("WORLD_TEST", true, quest.questId, "scenario", nil, nil, nil, link)

						return
					end
				end
			end
		end
	end
end

E:RegisterOptions("world", {
	enabled = true,
	dnd = false,
	sfx = true,
}, {
	name = L["TYPE_WORLD_QUEST"],
	get = function(info)
		return C.db.profile.types.world[info[#info]]
	end,
	set = function(info, value)
		C.db.profile.types.world[info[#info]] = value
	end,
	args = {
		enabled = {
			order = 1,
			type = "toggle",
			name = L["ENABLE"],
			set = function(_, value)
				C.db.profile.types.world.enabled = value

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

E:RegisterSystem("world", Enable, Disable, Test)
