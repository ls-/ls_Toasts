local _, addonTable = ...
local E, L, C = addonTable.E, addonTable.L, addonTable.C

-- Lua
local _G = getfenv(0)
local next = _G.next
local select = _G.select

-- Blizz
local C_Scenario = _G.C_Scenario
local C_TaskQuest = _G.C_TaskQuest
local C_Timer = _G.C_Timer

--[[ luacheck: globals
	GameTooltip GetItemInfo GetItemInfoInstant GetMoneyString GetNumQuestLogRewardCurrencies GetProfessionInfo
	GetQuestLogRewardCurrencyInfo GetQuestLogRewardMoney GetQuestLogRewardXP GetQuestTagInfo HaveQuestData
	HaveQuestRewardData QuestUtils_IsQuestWorldQuest UnitLevel

	LE_QUEST_TAG_TYPE_DUNGEON LE_QUEST_TAG_TYPE_PET_BATTLE LE_QUEST_TAG_TYPE_PROFESSION LE_QUEST_TAG_TYPE_PVP
	LE_QUEST_TAG_TYPE_RAID LE_SCENARIO_TYPE_LEGION_INVASION MAX_PLAYER_LEVEL WORLD_QUEST_QUALITY_COLORS
]]

-- Mine
local CURRENCY_TEMPLATE = "%s|T%s:0|t"

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
		elseif self._data.type == "currency" then
			GameTooltip:AddLine(L["YOU_RECEIVED"])
			GameTooltip:AddLine(CURRENCY_TEMPLATE:format(self._data.count, self._data.texture), 1, 1, 1)
		end

		GameTooltip:Show()
	end
end

local function Toast_SetUp(event, isUpdate, questID, name, moneyReward, xpReward, numCurrencyRewards, itemReward)
	local toast, isNew, isQueued = E:GetToast(nil, "quest_id", questID)
	if isUpdate and isNew then
		toast:Release()

		return
	end

	if isNew then
		local usedSlots = 0

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

		for i = 1, numCurrencyRewards or 0 do
			usedSlots = usedSlots + 1

			local slot = toast["Slot" .. usedSlots]
			if slot then
				local _, texture, count = GetQuestLogRewardCurrencyInfo(i, questID)
				texture = texture or "Interface\\Icons\\INV_Box_02"

				slot.Icon:SetTexture(texture)

				slot._data.type = "currency"
				slot._data.count = count
				slot._data.texture = texture

				slot:HookScript("OnEnter", Slot_OnEnter)
				slot:Show()
			end
		end

		local _, _, worldQuestType, rarity, _, tradeskillLineIndex = GetQuestTagInfo(questID)
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
			local color = WORLD_QUEST_QUALITY_COLORS[rarity] or WORLD_QUEST_QUALITY_COLORS[1]

			if C.db.profile.colors.border then
				toast.Border:SetVertexColor(color.r, color.g, color.b)
			end

			if C.db.profile.colors.icon_border then
				toast.IconBorder:SetVertexColor(color.r, color.g, color.b)
			end
		end

		toast:SetBackground("worldquest")
		toast.Title:SetText(L["WORLD_QUEST_COMPLETED"])
		toast.Text:SetText(name)
		toast.IconBorder:Show()

		toast._data.event = event
		toast._data.quest_id = questID
		toast._data.sound_file = C.db.profile.types.world.sfx and 73277 -- SOUNDKIT.UI_WORLDQUEST_COMPLETE
		toast._data.used_slots = usedSlots

		toast:Spawn(C.db.profile.types.world.anchor, C.db.profile.types.world.dnd)
	else
		if itemReward then
			toast._data.used_slots = toast._data.used_slots + 1
			local slot = toast["Slot" .. toast._data.used_slots]

			if slot then
				local _, _, _, _, texture = GetItemInfoInstant(itemReward)
				texture = texture or "Interface\\Icons\\INV_Box_02"

				slot.Icon:SetTexture(texture)

				slot._data.type = "item"
				slot._data.link = itemReward

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

local function QUEST_TURNED_IN(questID)
	if QuestUtils_IsQuestWorldQuest(questID) then
		if not HaveQuestRewardData(questID) then
			C_TaskQuest.RequestPreloadRewardData(questID)
			C_Timer.After(0.5, function() QUEST_TURNED_IN(questID) end)

			return
		end

		Toast_SetUp("QUEST_TURNED_IN", false, questID, C_TaskQuest.GetQuestInfoByQuestID(questID), GetQuestLogRewardMoney(questID), GetQuestLogRewardXP(questID), GetNumQuestLogRewardCurrencies(questID))
	end
end

local function QUEST_LOOT_RECEIVED(questID, itemLink)
	--- QUEST_LOOT_RECEIVED may fire before QUEST_TURNED_IN
	if not E:FindToast(nil, "quest_id", questID) then
		if not HaveQuestRewardData(questID) then
			C_TaskQuest.RequestPreloadRewardData(questID)
			C_Timer.After(0.5, function() QUEST_LOOT_RECEIVED(questID, itemLink) end)

			return
		end

		QUEST_TURNED_IN(questID)
	end

	Toast_SetUp("QUEST_LOOT_RECIEVED", true, questID, nil, nil, nil, nil, itemLink)
end

local function Enable()
	if C.db.profile.types.world.enabled then
		E:RegisterEvent("QUEST_TURNED_IN", QUEST_TURNED_IN)
		E:RegisterEvent("QUEST_LOOT_RECEIVED", QUEST_LOOT_RECEIVED)
	end
end

local function Disable()
	E:UnregisterEvent("QUEST_TURNED_IN")
	E:UnregisterEvent("QUEST_LOOT_RECEIVED")
end

local function Test()
	-- reward, Blood of Sargeras
	local _, link = GetItemInfo(124124)
	if link then
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
	anchor = 1,
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
