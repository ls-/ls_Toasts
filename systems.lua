local _, addonTable = ...
local E, L, C = addonTable.E, addonTable.L, addonTable.C

-- Lua
local _G = getfenv(0)
local hooksecurefunc = _G.hooksecurefunc
local m_random = _G.math.random
local next = _G.next
local pcall = _G.pcall
local s_split = _G.string.split
local select = _G.select
local tonumber = _G.tonumber
local tostring = _G.tostring

-- Blizz
local AchievementFrame_LoadUI = _G.AchievementFrame_LoadUI
local BattlePetToolTip_Show = _G.BattlePetToolTip_Show
local C_Garrison_GetAvailableMissions = _G.C_Garrison.GetAvailableMissions
local C_Garrison_GetBasicMissionInfo = _G.C_Garrison.GetBasicMissionInfo
local C_Garrison_GetBuildingInfo = _G.C_Garrison.GetBuildingInfo
local C_Garrison_GetBuildings = _G.C_Garrison.GetBuildings
local C_Garrison_GetCompleteTalent = _G.C_Garrison.GetCompleteTalent
local C_Garrison_GetFollowerInfo = _G.C_Garrison.GetFollowerInfo
local C_Garrison_GetFollowerLink = _G.C_Garrison.GetFollowerLink
local C_Garrison_GetFollowerLinkByID = _G.C_Garrison.GetFollowerLinkByID
local C_Garrison_GetFollowers = _G.C_Garrison.GetFollowers
local C_Garrison_GetFollowerTypeByID = _G.C_Garrison.GetFollowerTypeByID
local C_Garrison_GetTalent = _G.C_Garrison.GetTalent
local C_Garrison_GetTalentTreeIDsByClassID = _G.C_Garrison.GetTalentTreeIDsByClassID
local C_Garrison_GetTalentTreeInfoForID = _G.C_Garrison.GetTalentTreeInfoForID
local C_Garrison_IsOnGarrisonMap = _G.C_Garrison.IsOnGarrisonMap
local C_MountJournal_GetMountInfoByID = _G.C_MountJournal.GetMountInfoByID
local C_PetJournal_GetPetInfoByIndex = _G.C_PetJournal.GetPetInfoByIndex
local C_PetJournal_GetPetInfoByPetID = _G.C_PetJournal.GetPetInfoByPetID
local C_PetJournal_GetPetInfoBySpeciesID = _G.C_PetJournal.GetPetInfoBySpeciesID
local C_PetJournal_GetPetStats = _G.C_PetJournal.GetPetStats
local C_Scenario_GetInfo = _G.C_Scenario.GetInfo
local C_Scenario_IsInScenario = _G.C_Scenario.IsInScenario
local C_Scenario_TreatScenarioAsDungeon = _G.C_Scenario.TreatScenarioAsDungeon
local C_TaskQuest_GetQuestInfoByQuestID = _G.C_TaskQuest.GetQuestInfoByQuestID
local C_TaskQuest_GetQuestsForPlayerByMapID = _G.C_TaskQuest.GetQuestsForPlayerByMapID
local C_Timer_After = _G.C_Timer.After
local C_ToyBox_GetToyInfo = _G.C_ToyBox.GetToyInfo
local C_TradeSkillUI_GetTradeSkillLineForRecipe = _G.C_TradeSkillUI.GetTradeSkillLineForRecipe
local C_TradeSkillUI_GetTradeSkillTexture = _G.C_TradeSkillUI.GetTradeSkillTexture
local C_TradeSkillUI_OpenTradeSkill = _G.C_TradeSkillUI.OpenTradeSkill
local C_TransmogCollection_GetAppearanceSourceInfo = _G.C_TransmogCollection.GetAppearanceSourceInfo
local C_TransmogCollection_GetAppearanceSources = _G.C_TransmogCollection.GetAppearanceSources
local C_TransmogCollection_GetCategoryAppearances = _G.C_TransmogCollection.GetCategoryAppearances
local C_TransmogCollection_GetSourceInfo = _G.C_TransmogCollection.GetSourceInfo
local CollectionsJournal_LoadUI = _G.CollectionsJournal_LoadUI
local GarrisonFollowerTooltip_Show = _G.GarrisonFollowerTooltip_Show
local GetAchievementInfo = _G.GetAchievementInfo
local GetArchaeologyRaceInfoByID = _G.GetArchaeologyRaceInfoByID
local GetCurrencyInfo = _G. GetCurrencyInfo
local GetCurrencyLink = _G.GetCurrencyLink
local GetInstanceInfo = _G.GetInstanceInfo
local GetItemInfo = _G.GetItemInfo
local GetItemInfoInstant = _G.GetItemInfoInstant
local GetLFGCompletionReward = _G.GetLFGCompletionReward
local GetLFGCompletionRewardItem = _G.GetLFGCompletionRewardItem
local GetLFGCompletionRewardItemLink = _G.GetLFGCompletionRewardItemLink
local GetLFGDungeonInfo = _G.GetLFGDungeonInfo
local GetMoney = _G.GetMoney
local GetMoneyString = _G.GetMoneyString
local GetNumQuestLogRewardCurrencies = _G.GetNumQuestLogRewardCurrencies
local GetProfessionInfo = _G.GetProfessionInfo
local GetQuestLogRewardCurrencyInfo = _G.GetQuestLogRewardCurrencyInfo
local GetQuestLogRewardMoney = _G.GetQuestLogRewardMoney
local GetQuestLogRewardXP = _G.GetQuestLogRewardXP
local GetQuestTagInfo = _G.GetQuestTagInfo
local GetSpellInfo = _G.GetSpellInfo
local GetSpellRank = _G.GetSpellRank
local GroupLootContainer_RemoveFrame = _G.GroupLootContainer_RemoveFrame
local HaveQuestData = _G.HaveQuestData
local OpenBag = _G.OpenBag
local QuestUtils_IsQuestWorldQuest = _G.QuestUtils_IsQuestWorldQuest
local SetCollectionsJournalShown = _G.SetCollectionsJournalShown
local SetPortraitToTexture = _G.SetPortraitToTexture
local ShowUIPanel = _G.ShowUIPanel
local TradeSkillFrame_LoadUI = _G.TradeSkillFrame_LoadUI
local UnitClass = _G.UnitClass
local UnitFactionGroup = _G.UnitFactionGroup
local UnitLevel = _G.UnitLevel
local UnitName = _G.UnitName

-- Mine
local PLAYER_NAME = UnitName("player")
local PLAYER_CLASS = select(3, UnitClass("player"))

-----------------
-- ACHIEVEMENT --
-----------------

do
	local function Toast_OnClick(self)
		if self._data then
			if not AchievementFrame then
				AchievementFrame_LoadUI()
			end

			if AchievementFrame then
				ShowUIPanel(AchievementFrame)
				AchievementFrame_SelectAchievement(self._data.ach_id)
			end
		end
	end

	local function Toast_SetUp(event, achievementID, flag, isCriteria)
		local toast = E:GetToast()
		local _, name, points, _, _, _, _, _, _, icon = GetAchievementInfo(achievementID)

		if isCriteria then
			toast.Title:SetText(L["ACHIEVEMENT_PROGRESSED"])
			toast.Text:SetText(flag)

			toast.IconText1:SetText("")
		else
			toast.Title:SetText(L["ACHIEVEMENT_UNLOCKED"])
			toast.Text:SetText(name)

			if flag then
				toast.IconText1:SetText("")
			else
				if C.db.profile.colors.border then
					toast.Border:SetVertexColor(0.9, 0.75, 0.26)
				end

				if C.db.profile.colors.icon_border then
					toast.IconBorder:SetVertexColor(0.9, 0.75, 0.26)
				end

				toast.IconText1:SetText(points == 0 and "" or points)
			end
		end

		toast.Icon:SetTexture(icon)
		toast.IconBorder:Show()

		toast._data = {
			event = event,
			ach_id = achievementID,
		}

		toast:HookScript("OnClick", Toast_OnClick)
		toast:Spawn(C.db.profile.types.achievement.dnd)
	end

	local function ACHIEVEMENT_EARNED(achievementID, alreadyEarned)
		Toast_SetUp("ACHIEVEMENT_EARNED", achievementID, alreadyEarned)
	end

	local function CRITERIA_EARNED(achievementID, criteriaString)
		Toast_SetUp("CRITERIA_EARNED", achievementID, criteriaString, true)
	end

	local function Enable()
		if C.db.profile.types.achievement.enabled then
			E:RegisterEvent("ACHIEVEMENT_EARNED", ACHIEVEMENT_EARNED)
			E:RegisterEvent("CRITERIA_EARNED", CRITERIA_EARNED)
		end
	end

	local function Disable()
		E:UnregisterEvent("ACHIEVEMENT_EARNED", ACHIEVEMENT_EARNED)
		E:UnregisterEvent("CRITERIA_EARNED", CRITERIA_EARNED)
	end

	local function Test()
		-- new, Shave and a Haircut
		Toast_SetUp("ACHIEVEMENT_TEST", 545, false)

		-- earned, Ten Hit Tunes
		Toast_SetUp("ACHIEVEMENT_TEST", 9828, true)
	end

	E:RegisterOptions("achievement", {
		enabled = true,
		dnd = false,
	}, {
		name = L["TYPE_ACHIEVEMENT"],
		args = {
			enabled = {
				order = 1,
				type = "toggle",
				name = L["ENABLE"],
				get = function()
					return C.db.profile.types.achievement.enabled
				end,
				set = function(_, value)
					C.db.profile.types.achievement.enabled = value

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
				get = function()
					return C.db.profile.types.achievement.dnd
				end,
				set = function(_, value)
					C.db.profile.types.achievement.dnd = value

					if value then
						Enable()
					else
						Disable()
					end
				end
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

	E:RegisterSystem("achievement", Enable, Disable, Test)
end

-----------------
-- ARCHAEOLOGY --
-----------------

do
	local function Toast_SetUp(event, researchFieldID)
		local toast = E:GetToast()
		local raceName, raceTexture	= GetArchaeologyRaceInfoByID(researchFieldID)

		if C.db.profile.colors.border then
			toast.Border:SetVertexColor(0.9, 0.4, 0.1)
		end

		toast.Title:SetText(L["DIGSITE_COMPLETED"])
		toast.Text:SetText(raceName)
		toast.BG:SetTexture("Interface\\AddOns\\ls_Toasts\\media\\toast-bg-archaeology")
		toast.Icon:SetPoint("TOPLEFT", 7, -3)
		toast.Icon:SetSize(76, 76)
		toast.Icon:SetTexture(raceTexture)

		toast._data = {
			event = event,
			sound_file = 38326, -- SOUNDKIT.UI_DIG_SITE_COMPLETION_TOAST
		}

		toast:Spawn(C.db.profile.types.archaeology.dnd)
	end

	local function ARTIFACT_DIGSITE_COMPLETE(researchFieldID)
		Toast_SetUp("ARTIFACT_DIGSITE_COMPLETE", researchFieldID)
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
		end
	end

	local function Disable()
		E:UnregisterEvent("ARTIFACT_DIGSITE_COMPLETE", ARTIFACT_DIGSITE_COMPLETE)
	end

	local function Test()
		Toast_SetUp("ARCHAEOLOGY_TEST", 408)
	end

	E:RegisterOptions("archaeology", {
		enabled = true,
		dnd = false,
	}, {
		name = L["TYPE_ARCHAEOLOGY"],
		args = {
			enabled = {
				order = 1,
				type = "toggle",
				name = L["ENABLE"],
				get = function()
					return C.db.profile.types.archaeology.enabled
				end,
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
				get = function()
					return C.db.profile.types.archaeology.dnd
				end,
				set = function(_, value)
					C.db.profile.types.archaeology.dnd = value

					if value then
						Enable()
					else
						Disable()
					end
				end
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
end

-------------------------
-- MOUNTS, PETS & TOYS --
-------------------------

do
	local function Toast_OnClick(self)
		local data = self._data

		if data then
			if not CollectionsJournal then
				CollectionsJournal_LoadUI()
			end

			if CollectionsJournal then
				if data.is_mount then
					SetCollectionsJournalShown(true, COLLECTIONS_JOURNAL_TAB_INDEX_MOUNTS)
					MountJournal_SelectByMountID(data.collection_id)
				elseif data.is_pet then
					SetCollectionsJournalShown(true, COLLECTIONS_JOURNAL_TAB_INDEX_PETS)
					PetJournal_SelectPet(PetJournal, data.collection_id)
				elseif data.is_toy then
					SetCollectionsJournalShown(true, COLLECTIONS_JOURNAL_TAB_INDEX_TOYS)
					ToyBox_UpdatePages()

					local toyPage = ToyBox_FindPageForToyID(data.collection_id)

					if toyPage then
						ToyBox.PagingFrame:SetCurrentPage(toyPage)
					end
				end
			end
		end
	end

	local function PostSetAnimatedValue(self, value)
		self:SetText(value == 1 and "" or value)
	end

	local function Toast_SetUp(event, ID, isMount, isPet, isToy)
		local toast, isNew, isQueued = E:GetToast(event, "collection_id", ID)
		local color, name, icon, _

		if isNew then
			if isMount then
				name, _, icon = C_MountJournal_GetMountInfoByID(ID)
			elseif isPet then
				local customName, rarity
				_, _, _, _, rarity = C_PetJournal_GetPetStats(ID)
				_, customName, _, _, _, _, _, name, icon = C_PetJournal_GetPetInfoByPetID(ID)
				color = ITEM_QUALITY_COLORS[(rarity or 2) - 1]
				name = customName or name
			elseif isToy then
				_, name, icon = C_ToyBox_GetToyInfo(ID)
			end

			if not name then
				return toast:Recycle()
			end

			toast.IconText1.PostSetAnimatedValue = PostSetAnimatedValue

			if color and C.db.profile.colors.name then
				toast.Text:SetTextColor(color.r, color.g, color.b)
			end

			if color and C.db.profile.colors.border then
				toast.Border:SetVertexColor(color.r, color.g, color.b)
			end

			if color and C.db.profile.colors.icon_border then
				toast.IconBorder:SetVertexColor(color.r, color.g, color.b)
			end

			toast.Title:SetText(L["YOU_EARNED"])
			toast.Text:SetText(name)
			toast.BG:SetTexture("Interface\\AddOns\\ls_Toasts\\media\\toast-bg-collection")
			toast.Icon:SetTexture(icon)
			toast.IconBorder:Show()
			toast.IconText1:SetAnimatedValue(1, true)

			toast._data = {
				collection_id = ID,
				count = 1,
				event = event,
				is_mount = isMount,
				is_pet = isPet,
				is_toy = isToy,
				sound_file = 31578, -- SOUNDKIT.UI_EPICLOOT_TOAST
			}

			toast:HookScript("OnClick", Toast_OnClick)
			toast:Spawn(C.db.profile.types.collection.dnd)
		else
			if isQueued then
				toast._data.count = toast._data.count + 1
				toast.IconText1:SetAnimatedValue(toast._data.count, true)
			else
				toast._data.count = toast._data.count + 1
				toast.IconText1:SetAnimatedValue(toast._data.count)

				toast.IconText2:SetText("+1")
				toast.IconText2.Blink:Stop()
				toast.IconText2.Blink:Play()

				toast.AnimOut:Stop()
				toast.AnimOut:Play()
			end
		end
	end

	local function NEW_MOUNT_ADDED(mountID)
		Toast_SetUp("NEW_MOUNT_ADDED", mountID, true)
	end

	local function NEW_PET_ADDED(petID)
		Toast_SetUp("NEW_PET_ADDED", petID, nil, true)
	end

	local function TOYS_UPDATED(toyID, isNew)
		if toyID and isNew then
			Toast_SetUp("TOYS_UPDATED", toyID, nil, nil, true)
		end
	end

	local function Enable()
		if C.db.profile.types.collection.enabled then
			E:RegisterEvent("NEW_MOUNT_ADDED", NEW_MOUNT_ADDED)
			E:RegisterEvent("NEW_PET_ADDED", NEW_PET_ADDED)
			E:RegisterEvent("TOYS_UPDATED", TOYS_UPDATED)
		end
	end

	local function Disable()
		E:UnregisterEvent("NEW_MOUNT_ADDED", NEW_MOUNT_ADDED)
		E:UnregisterEvent("NEW_PET_ADDED", NEW_PET_ADDED)
		E:UnregisterEvent("TOYS_UPDATED", TOYS_UPDATED)
	end

	local function Test()
		-- Golden Gryphon
		Toast_SetUp("MOUNT_TEST", 129, true)

		-- Pet
		local petID = C_PetJournal_GetPetInfoByIndex(1)

		if petID then
			Toast_SetUp("PET_TEST", petID, nil, true)
		end

		-- Legion Pocket Portal
		Toast_SetUp("TOY_TEST", 130199, nil, nil, true)
	end

	E:RegisterOptions("collection", {
		enabled = true,
		dnd = false,
	}, {
		name = L["TYPE_COLLECTION"],
		args = {
			desc = {
				order = 1,
				type = "description",
				name = L["TYPE_COLLECTION_DESC"],
			},
			enabled = {
				order = 2,
				type = "toggle",
				name = L["ENABLE"],
				get = function()
					return C.db.profile.types.collection.enabled
				end,
				set = function(_, value)
					C.db.profile.types.collection.enabled = value

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
				get = function()
					return C.db.profile.types.collection.dnd
				end,
				set = function(_, value)
					C.db.profile.types.collection.dnd = value

					if value then
						Enable()
					else
						Disable()
					end
				end
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

	E:RegisterSystem("collection", Enable, Disable, Test)
end

--------------
-- INSTANCE --
--------------

do
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
			local slot = toast["Slot"..usedSlots]

			if slot then
				SetPortraitToTexture(slot.Icon, "Interface\\Icons\\inv_misc_coin_02")

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
				SetPortraitToTexture(slot.Icon, "Interface\\Icons\\xp_icon")

				slot._data = {
					type = "xp",
					count = xpReward,
				}

				slot:HookScript("OnEnter", Slot_OnEnter)
				slot:Show()
			end
		end

		for i = 1, numItemRewards or 0 do
			local link = GetLFGCompletionRewardItemLink(i)

			if link then
				usedSlots = usedSlots + 1
				local slot = toast["Slot"..usedSlots]

				if slot then
					local icon = GetLFGCompletionRewardItem(i)
					local isOK = pcall(SetPortraitToTexture, slot.Icon, icon)

					if not isOK then
						SetPortraitToTexture(slot.Icon, "Interface\\Icons\\INV_Box_02")
					end

					slot._data = {
						type = "item",
						link = link,
					}

					slot:HookScript("OnEnter", Slot_OnEnter)
					slot:Show()
				end
			end
		end

		if isScenario then
			if isScenarioBonusComplete then
				toast.Bonus:Show()
			end

			toast.Title:SetText(L["SCENARIO_COMPLETED"])

			soundFile = 31754 -- SOUNDKIT.UI_SCENARIO_ENDING
		else
			if subTypeID == LFG_SUBTYPEID_HEROIC then
				toast.Skull:Show()
			end

			toast.Title:SetText(L["DUNGEON_COMPLETED"])

			soundFile = 17316 -- SOUNDKIT.LFG_REWARDS
		end

		toast.Text:SetText(name)
		toast.BG:SetTexture("Interface\\AddOns\\ls_Toasts\\media\\toast-bg-dungeon")
		toast.Icon:SetTexture(textureFile or "Interface\\LFGFrame\\LFGIcon-Dungeon")
		toast.IconBorder:Show()

		toast._data = {
			event = event,
			sound_file = soundFile,
			used_slots = usedSlots,
		}

		toast:Spawn(C.db.profile.types.instance.dnd)
	end

	local function LFG_COMPLETION_REWARD()
		if C_Scenario_IsInScenario() and not C_Scenario_TreatScenarioAsDungeon() then
			local _, _, _, _, hasBonusStep, isBonusStepComplete, _, _, _, scenarioType = C_Scenario_GetInfo()

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
		dnd = false,
	}, {
		name = L["TYPE_DUNGEON"],
		args = {
			enabled = {
				order = 1,
				type = "toggle",
				name = L["ENABLE"],
				get = function()
					return C.db.profile.types.instance.enabled
				end,
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
				get = function()
					return C.db.profile.types.instance.dnd
				end,
				set = function(_, value)
					C.db.profile.types.instance.dnd = value

					if value then
						Enable()
					else
						Disable()
					end
				end
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
end

--------------
-- GARRISON --
--------------

do
	local function GetGarrisonTypeByFollowerType(followerTypeID)
		if followerTypeID == LE_FOLLOWER_TYPE_GARRISON_7_0 then
			return LE_GARRISON_TYPE_7_0
		elseif followerTypeID == LE_FOLLOWER_TYPE_GARRISON_6_0 or followerTypeID == LE_FOLLOWER_TYPE_SHIPYARD_6_2 then
			return LE_GARRISON_TYPE_6_0
		end
	end

	local function MissionToast_SetUp(event, garrisonType, missionID, isAdded)
		local missionInfo = C_Garrison_GetBasicMissionInfo(missionID)
		local color = missionInfo.isRare and ITEM_QUALITY_COLORS[3] or ITEM_QUALITY_COLORS[1]
		local level = missionInfo.iLevel == 0 and missionInfo.level or missionInfo.iLevel
		local toast = E:GetToast()

		if isAdded then
			toast.Title:SetText(L["GARRISON_MISSION_ADDED"])
		else
			toast.Title:SetText(L["GARRISON_MISSION_COMPLETED"])
		end

		if C.db.profile.colors.name then
			toast.Text:SetTextColor(color.r, color.g, color.b)
		end

		if C.db.profile.colors.border then
			toast.Border:SetVertexColor(color.r, color.g, color.b)
		end

		toast.Text:SetText(missionInfo.name)
		toast.Icon:SetAtlas(missionInfo.typeAtlas, false)
		toast.IconText1:SetText(level)

		toast._data = {
			event = event,
			mission_id = missionID,
			sound_file = 44294, -- SOUNDKIT.UI_GARRISON_TOAST_MISSION_COMPLETE
		}

		toast:Spawn(garrisonType == LE_GARRISON_TYPE_7_0 and C.db.profile.types.garrison_7_0.dnd or C.db.profile.types.garrison_6_0.dnd)
	end

	local function GARRISON_MISSION_FINISHED(followerTypeID, missionID)
		local garrisonType = GetGarrisonTypeByFollowerType(followerTypeID)

		if (garrisonType == LE_GARRISON_TYPE_7_0 and not C.db.profile.types.garrison_7_0.enabled)
			or (garrisonType == LE_GARRISON_TYPE_6_0 and not C.db.profile.types.garrison_6_0.enabled) then
			return
		end

		local _, instanceType = GetInstanceInfo()
		local validInstance = false

		if instanceType == "none" or C_Garrison_IsOnGarrisonMap() then
			validInstance = true
		end

		if validInstance then
			MissionToast_SetUp("GARRISON_MISSION_FINISHED", garrisonType, missionID)
		end
	end

	local function GARRISON_RANDOM_MISSION_ADDED(followerTypeID, missionID)
		local garrisonType = GetGarrisonTypeByFollowerType(followerTypeID)

		if (garrisonType == LE_GARRISON_TYPE_7_0 and not C.db.profile.types.garrison_7_0.enabled)
			or (garrisonType == LE_GARRISON_TYPE_6_0 and not C.db.profile.types.garrison_6_0.enabled) then
			return
		end

		MissionToast_SetUp("GARRISON_RANDOM_MISSION_ADDED", garrisonType, missionID, true)
	end

	------

	local function FollowerToast_OnEnter(self)
		if self._data then
			local isOK, link = pcall(C_Garrison_GetFollowerLink, self._data.follower_id)

			if not isOK then
				isOK, link = pcall(C_Garrison_GetFollowerLinkByID, self._data.follower_id)
			end

			if isOK and link then
				local _, garrisonFollowerID, quality, level, itemLevel, ability1, ability2, ability3, ability4, trait1, trait2, trait3, trait4, spec1 = s_split(":", link)
				local followerType = C_Garrison_GetFollowerTypeByID(tonumber(garrisonFollowerID))

				GarrisonFollowerTooltip_Show(tonumber(garrisonFollowerID), false, tonumber(quality), tonumber(level), 0, 0, tonumber(itemLevel), tonumber(spec1), tonumber(ability1), tonumber(ability2), tonumber(ability3), tonumber(ability4), tonumber(trait1), tonumber(trait2), tonumber(trait3), tonumber(trait4))

				if followerType == LE_FOLLOWER_TYPE_SHIPYARD_6_2 then
					GarrisonShipyardFollowerTooltip:ClearAllPoints()
					GarrisonShipyardFollowerTooltip:SetPoint(GameTooltip:GetPoint())
				else
					GarrisonFollowerTooltip:ClearAllPoints()
					GarrisonFollowerTooltip:SetPoint(GameTooltip:GetPoint())
				end
			end

		end
	end

	local function FollowerToast_SetUp(event, garrisonType, followerTypeID, followerID, name, texPrefix, level, quality, isUpgraded)
		local followerInfo = C_Garrison_GetFollowerInfo(followerID)
		local followerStrings = GarrisonFollowerOptions[followerTypeID].strings
		local upgradeTexture = LOOTUPGRADEFRAME_QUALITY_TEXTURES[quality] or LOOTUPGRADEFRAME_QUALITY_TEXTURES[2]
		local color = ITEM_QUALITY_COLORS[quality]
		local toast = E:GetToast()

		if followerTypeID == LE_FOLLOWER_TYPE_SHIPYARD_6_2 then
			toast.Icon:SetSize(84, 44)
			toast.Icon:SetAtlas(texPrefix.."-List", false)
			toast.IconText1:SetText("")
		else
			local portrait

			if followerInfo.portraitIconID and followerInfo.portraitIconID ~= 0 then
				portrait = followerInfo.portraitIconID
			else
				portrait = "Interface\\Garrison\\Portraits\\FollowerPortrait_NoPortrait"
			end

			toast.Icon:SetSize(44, 44)
			toast.Icon:SetTexture(portrait)
			toast.IconText1:SetText(level)
		end

		if isUpgraded then
			toast.Title:SetText(followerStrings.FOLLOWER_ADDED_UPGRADED_TOAST)
			toast.BG:SetTexture("Interface\\AddOns\\ls_Toasts\\media\\toast-bg-upgrade")

			for i = 1, 5 do
				toast["Arrow"..i]:SetAtlas(upgradeTexture.arrow, true)
			end
		else
			toast.Title:SetText(followerStrings.FOLLOWER_ADDED_TOAST)
		end

		if C.db.profile.colors.name then
			toast.Text:SetTextColor(color.r, color.g, color.b)
		end

		if C.db.profile.colors.border then
			toast.Border:SetVertexColor(color.r, color.g, color.b)
		end

		toast.Text:SetText(name)

		toast._data = {
			event = event,
			follower_id = followerID,
			show_arrows = isUpgraded,
			sound_file = 44296, -- SOUNDKIT.UI_GARRISON_TOAST_FOLLOWER_GAINED
		}

		toast:HookScript("OnEnter", FollowerToast_OnEnter)
		toast:Spawn(garrisonType == LE_GARRISON_TYPE_7_0 and C.db.profile.types.garrison_7_0.dnd or C.db.profile.types.garrison_6_0.dnd)
	end

	local function GARRISON_FOLLOWER_ADDED(followerID, name, _, level, quality, isUpgraded, texPrefix, followerTypeID)
		local garrisonType = GetGarrisonTypeByFollowerType(followerTypeID)

		if (garrisonType == LE_GARRISON_TYPE_7_0 and not C.db.profile.types.garrison_7_0.enabled)
			or (garrisonType == LE_GARRISON_TYPE_6_0 and not C.db.profile.types.garrison_6_0.enabled) then
			return
		end

		FollowerToast_SetUp("GARRISON_FOLLOWER_ADDED", garrisonType, followerTypeID, followerID, name, texPrefix, level, quality, isUpgraded)
	end

	------

	local function BuildingToast_SetUp(event, buildingName)
		local toast = E:GetToast()

		toast.Title:SetText(L["GARRISON_NEW_BUILDING"])
		toast.Text:SetText(buildingName)
		toast.Icon:SetTexture("Interface\\Icons\\Garrison_Build")
		toast.IconBorder:Show()

		toast._data = {
			event = event,
			sound_file = 44295, -- SOUNDKIT.UI_GARRISON_TOAST_BUILDING_COMPLETE
		}

		toast:Spawn(C.db.profile.types.garrison_6_0.dnd)
	end

	local function GARRISON_BUILDING_ACTIVATABLE(buildingName)
		BuildingToast_SetUp("GARRISON_BUILDING_ACTIVATABLE", buildingName)
	end

	------

	local function TalentToast_SetUp(event, talentID)
		local talent = C_Garrison_GetTalent(talentID)
		local toast = E:GetToast()

		toast.Title:SetText(L["GARRISON_NEW_TALENT"])
		toast.Text:SetText(talent.name)
		toast.Icon:SetTexture(talent.icon)
		toast.IconBorder:Show()

		toast._data = {
			event = event,
			sound_file = 73280, -- SOUNDKIT.UI_ORDERHALL_TALENT_READY_TOAST
			talend_id = talentID,
		}

		toast:Spawn(C.db.profile.types.garrison_7_0.dnd)
	end

	local function GARRISON_TALENT_COMPLETE(garrisonType, doAlert)
		if doAlert then
			TalentToast_SetUp("GARRISON_TALENT_COMPLETE", C_Garrison_GetCompleteTalent(garrisonType))
		end
	end

	local function Enable()
		if C.db.profile.types.garrison_6_0.enabled or C.db.profile.types.garrison_7_0.enabled then
			E:RegisterEvent("GARRISON_FOLLOWER_ADDED", GARRISON_FOLLOWER_ADDED)
			E:RegisterEvent("GARRISON_MISSION_FINISHED", GARRISON_MISSION_FINISHED)
			E:RegisterEvent("GARRISON_RANDOM_MISSION_ADDED", GARRISON_RANDOM_MISSION_ADDED)

			if C.db.profile.types.garrison_6_0.enabled then
				E:RegisterEvent("GARRISON_BUILDING_ACTIVATABLE", GARRISON_BUILDING_ACTIVATABLE)
			end

			if C.db.profile.types.garrison_7_0.enabled then
				E:RegisterEvent("GARRISON_TALENT_COMPLETE", GARRISON_TALENT_COMPLETE)
			end
		end
	end

	local function Disable()
		if not (C.db.profile.types.garrison_7_0.enabled and C.db.profile.types.garrison_6_0.enabled) then
			E:UnregisterEvent("GARRISON_FOLLOWER_ADDED", GARRISON_FOLLOWER_ADDED)
			E:UnregisterEvent("GARRISON_MISSION_FINISHED", GARRISON_MISSION_FINISHED)
			E:UnregisterEvent("GARRISON_RANDOM_MISSION_ADDED", GARRISON_RANDOM_MISSION_ADDED)
		end

		if not C.db.profile.types.garrison_6_0.enabled then
			E:UnregisterEvent("GARRISON_BUILDING_ACTIVATABLE", GARRISON_BUILDING_ACTIVATABLE)
		end

		if not C.db.profile.types.garrison_7_0.enabled then
			E:UnregisterEvent("GARRISON_TALENT_COMPLETE", GARRISON_TALENT_COMPLETE)
		end
	end

	local function TestGarrison()
		-- follower
		local followers = C_Garrison_GetFollowers(LE_FOLLOWER_TYPE_GARRISON_6_0)
		local follower = followers and followers[1] or nil

		if follower then
			FollowerToast_SetUp("GARRISON_FOLLOWER_TEST", LE_GARRISON_TYPE_6_0, follower.followerTypeID, follower.followerID, follower.name, nil, follower.level, follower.quality, false)
		end

		-- ship
		followers = C_Garrison_GetFollowers(LE_FOLLOWER_TYPE_SHIPYARD_6_2)
		follower = followers and followers[1] or nil

		if follower then
			FollowerToast_SetUp("GARRISON_FOLLOWER_TEST", LE_GARRISON_TYPE_6_0, follower.followerTypeID, follower.followerID, follower.name, follower.texPrefix, follower.level, follower.quality, false)
		end

		-- garrison mission
		local missions = C_Garrison_GetAvailableMissions(LE_FOLLOWER_TYPE_GARRISON_6_0)
		local missionID = missions and missions[1] and missions[1].missionID or nil

		if missionID then
			MissionToast_SetUp("GARRISON_MISSION_TEST", LE_GARRISON_TYPE_6_0, missionID)
		end

		-- shipyard mission
		missions = C_Garrison_GetAvailableMissions(LE_FOLLOWER_TYPE_SHIPYARD_6_2)
		missionID = missions and missions[1] and missions[1].missionID or nil

		if missionID then
			MissionToast_SetUp("GARRISON_MISSION_TEST", LE_GARRISON_TYPE_6_0, missionID)
		end

		-- building
		local buildings = C_Garrison_GetBuildings(LE_GARRISON_TYPE_6_0)
		local buildingID = buildings and buildings[1] and buildings[1].buildingID or nil

		if buildingID then
			BuildingToast_SetUp("GARRISON_BUILDING_TEST", select(2, C_Garrison_GetBuildingInfo(buildingID)))
		end
	end

	local function TestClassHall()
		-- champion
		local followers = C_Garrison_GetFollowers(LE_FOLLOWER_TYPE_GARRISON_7_0)
		local follower = followers and followers[1] or nil

		if follower then
			FollowerToast_SetUp("GARRISON_FOLLOWER_TEST", LE_GARRISON_TYPE_7_0, follower.followerTypeID, follower.followerID, follower.name, nil, follower.level, follower.quality, false)
		end

		-- mission
		local missions = C_Garrison_GetAvailableMissions(LE_FOLLOWER_TYPE_GARRISON_7_0)
		local missionID = missions and missions[1] and missions[1].missionID or nil

		if missionID then
			MissionToast_SetUp("GARRISON_MISSION_TEST", LE_GARRISON_TYPE_7_0, missionID)
		end

		-- talent
		local talentTreeIDs = C_Garrison_GetTalentTreeIDsByClassID(LE_GARRISON_TYPE_7_0, PLAYER_CLASS)
		local talentTreeID = talentTreeIDs and talentTreeIDs[1] or nil
		local tree, _

		if talentTreeID then
			_, _, tree = C_Garrison_GetTalentTreeInfoForID(LE_GARRISON_TYPE_7_0, talentTreeID)
		end

		local talentID = tree and tree[1] and tree[1][1] and tree[1][1].id or nil

		if talentID then
			TalentToast_SetUp("GARRISON_TALENT_TEST", talentID)
		end
	end

	E:RegisterOptions("garrison_6_0", {
		enabled = false,
		dnd = true,
	}, {
		name = L["TYPE_GARRISON"],
		args = {
			enabled = {
				order = 1,
				type = "toggle",
				name = L["ENABLE"],
				get = function()
					return C.db.profile.types.garrison_6_0.enabled
				end,
				set = function(_, value)
					C.db.profile.types.garrison_6_0.enabled = value

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
				get = function()
					return C.db.profile.types.garrison_6_0.dnd
				end,
				set = function(_, value)
					C.db.profile.types.garrison_6_0.dnd = value

					if value then
						Enable()
					else
						Disable()
					end
				end
			},
			test = {
				type = "execute",
				order = 99,
				width = "full",
				name = L["TEST"],
				func = TestGarrison,
			},
		},
	})

	E:RegisterOptions("garrison_7_0", {
		enabled = true,
		dnd = true,
	}, {
		name = L["TYPE_CLASS_HALL"],
		args = {
			enabled = {
				order = 1,
				type = "toggle",
				name = L["ENABLE"],
				get = function()
					return C.db.profile.types.garrison_7_0.enabled
				end,
				set = function(_, value)
					C.db.profile.types.garrison_7_0.enabled = value

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
				get = function()
					return C.db.profile.types.garrison_7_0.dnd
				end,
				set = function(_, value)
					C.db.profile.types.garrison_7_0.dnd = value

					if value then
						Enable()
					else
						Disable()
					end
				end
			},
			test = {
				type = "execute",
				order = 99,
				width = "full",
				name = L["TEST"],
				func = TestClassHall,
			},
		},
	})

	E:RegisterSystem("garrison_6_0", Enable, Disable, TestGarrison)
	E:RegisterSystem("garrison_7_0", Enable, Disable, TestClassHall)
end

-----------------
-- LOOT COMMON --
-----------------

do
	local function Toast_OnClick(self)
		if self._data then
			local slot = E:SearchBagsForItemID(self._data.item_id)

			if slot >= 0 then
				OpenBag(slot)
			end
		end
	end

	local function Toast_OnEnter(self)
		if self._data.tooltip_link:find("item") then
			GameTooltip:SetHyperlink(self._data.tooltip_link)
			GameTooltip:Show()
		elseif self._data.tooltip_link:find("battlepet") then
			local _, speciesID, level, breedQuality, maxHealth, power, speed = s_split(":", self._data.tooltip_link)
			BattlePetToolTip_Show(tonumber(speciesID), tonumber(level), tonumber(breedQuality), tonumber(maxHealth), tonumber(power), tonumber(speed))
		end
	end

	local function PostSetAnimatedValue(self, value)
		self:SetText(value == 1 and "" or value)
	end

	local function Toast_SetUp(event, link, quantity)
		local sanitizedLink, originalLink, linkType, itemID = E:SanitizeLink(link)
		local toast, isNew, isQueued

		-- Check if there's a toast for this item from another event
		toast, isQueued = E:FindToast(nil, "link", sanitizedLink)

		if toast then
			if toast._data.event ~= event then
				return
			end
		else
			toast, isNew, isQueued = E:GetToast()
		end

		if isNew then
			local name, quality, icon, _, classID, subClassID, bindType, isQuestItem

			if linkType == "battlepet" then
				local _, speciesID, _, breedQuality, _ = s_split(":", originalLink)
				name, icon = C_PetJournal_GetPetInfoBySpeciesID(speciesID)
				quality = tonumber(breedQuality)
			else
				name, _, quality, _, _, _, _, _, _, icon, _, classID, subClassID, bindType = GetItemInfo(originalLink)
				isQuestItem = bindType == 4 or (classID == 12 and subClassID == 0)
			end

			if (quality >= C.db.profile.types.loot_common.threshold and quality <= 5)
				or (C.db.profile.types.loot_common.quest and isQuestItem) then
				local color = ITEM_QUALITY_COLORS[quality] or ITEM_QUALITY_COLORS[1]

				toast.IconText1.PostSetAnimatedValue = PostSetAnimatedValue

				if C.db.profile.colors.name then
					name = color.hex..name.."|r"
				end

				if C.db.profile.types.loot_common.ilvl then
					local iLevel = E:GetItemLevel(originalLink)

					if iLevel > 0 then
						name = "["..color.hex..iLevel.."|r] "..name
					end
				end

				if C.db.profile.colors.border then
					toast.Border:SetVertexColor(color.r, color.g, color.b)
				end

				if C.db.profile.colors.icon_border then
					toast.IconBorder:SetVertexColor(color.r, color.g, color.b)
				end

				toast.Title:SetText(L["YOU_RECEIVED"])
				toast.Text:SetText(name)
				toast.Icon:SetTexture(icon)
				toast.IconBorder:Show()
				toast.IconHL:SetShown(isQuestItem)
				toast.IconText1:SetAnimatedValue(quantity, true)

				toast._data = {
					count = quantity,
					event = event,
					link = sanitizedLink,
					sound_file = 31578, -- SOUNDKIT.UI_EPICLOOT_TOAST
					tooltip_link = originalLink,
					item_id = itemID,
				}

				toast:HookScript("OnClick", Toast_OnClick)
				toast:HookScript("OnEnter", Toast_OnEnter)
				toast:Spawn(C.db.profile.types.loot_common.dnd)
			else
				toast:Recycle()
			end
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

	local LOOT_ITEM_PATTERN
	local LOOT_ITEM_PUSHED_PATTERN
	local LOOT_ITEM_MULTIPLE_PATTERN
	local LOOT_ITEM_PUSHED_MULTIPLE_PATTERN

	local function CHAT_MSG_LOOT(message, _, _, _, target)
		if target ~= PLAYER_NAME then
			return
		end

		local link, quantity = message:match(LOOT_ITEM_MULTIPLE_PATTERN)

		if not link then
			link, quantity = message:match(LOOT_ITEM_PUSHED_MULTIPLE_PATTERN)

			if not link then
				quantity, link = 1, message:match(LOOT_ITEM_PATTERN)

				if not link then
					quantity, link = 1, message:match(LOOT_ITEM_PUSHED_PATTERN)

					if not link then
						return
					end
				end
			end
		end

		C_Timer_After(0.125, function() Toast_SetUp("CHAT_MSG_LOOT", link, tonumber(quantity) or 0) end)
	end

	local function Enable()
		LOOT_ITEM_PATTERN = LOOT_ITEM_SELF:gsub("%%s", "(.+)"):gsub("^", "^")
		LOOT_ITEM_PUSHED_PATTERN = LOOT_ITEM_PUSHED_SELF:gsub("%%s", "(.+)"):gsub("^", "^")
		LOOT_ITEM_MULTIPLE_PATTERN = LOOT_ITEM_SELF_MULTIPLE:gsub("%%s", "(.+)"):gsub("%%d", "(%%d+)"):gsub("^", "^")
		LOOT_ITEM_PUSHED_MULTIPLE_PATTERN = LOOT_ITEM_PUSHED_SELF_MULTIPLE:gsub("%%s", "(.+)"):gsub("%%d", "(%%d+)"):gsub("^", "^")

		if C.db.profile.types.loot_common.enabled then
			E:RegisterEvent("CHAT_MSG_LOOT", CHAT_MSG_LOOT)
		end
	end

	local function Disable()
		E:UnregisterEvent("CHAT_MSG_LOOT", CHAT_MSG_LOOT)
	end

	local function Test()
		-- item, Chaos Crystal
		local _, link = GetItemInfo(124442)

		if link then
			Toast_SetUp("COMMON_LOOT_TEST", link, m_random(9, 99))
		end

		-- battlepet, Anubisath Idol
		Toast_SetUp("COMMON_LOOT_TEST", "battlepet:1155:25:3:1725:276:244:0000000000000000", 1)
	end

	E:RegisterOptions("loot_common", {
		enabled = true,
		dnd = false,
		threshold = 1,
		ilvl = true,
		quest = false,
	}, {
		name = L["TYPE_LOOT_COMMON"],
		args = {
			desc = {
				order = 1,
				type = "description",
				name = L["TYPE_LOOT_COMMON_DESC"],
			},
			enabled = {
				order = 2,
				type = "toggle",
				name = L["ENABLE"],
				get = function()
					return C.db.profile.types.loot_common.enabled
				end,
				set = function(_, value)
					C.db.profile.types.loot_common.enabled = value

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
				get = function()
					return C.db.profile.types.loot_common.dnd
				end,
				set = function(_, value)
					C.db.profile.types.loot_common.dnd = value

					if value then
						Enable()
					else
						Disable()
					end
				end
			},
			ilvl = {
				order = 4,
				type = "toggle",
				name = L["SHOW_ILVL"],
				desc = L["SHOW_ILVL_DESC"],
				get = function()
					return C.db.profile.types.loot_common.ilvl
				end,
				set = function(_, value)
					C.db.profile.types.loot_common.ilvl = value
				end
			},
			threshold = {
				order = 5,
				type = "select",
				name = L["LOOT_THRESHOLD"],
				values = {
					[1] = ITEM_QUALITY_COLORS[1].hex..ITEM_QUALITY1_DESC.."|r",
					[2] = ITEM_QUALITY_COLORS[2].hex..ITEM_QUALITY2_DESC.."|r",
					[3] = ITEM_QUALITY_COLORS[3].hex..ITEM_QUALITY3_DESC.."|r",
					[4] = ITEM_QUALITY_COLORS[4].hex..ITEM_QUALITY4_DESC.."|r",
				},
				get = function()
					return C.db.profile.types.loot_common.threshold
				end,
				set = function(_, value)
					 C.db.profile.types.loot_common.threshold = value
				end,
			},
			quest = {
				order = 6,
				type = "toggle",
				name = L["SHOW_QUEST_ITEMS"],
				desc = L["SHOW_QUEST_ITEMS_DESC"],
				get = function()
					return C.db.profile.types.loot_common.quest
				end,
				set = function(_, value)
					C.db.profile.types.loot_common.quest = value
				end
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

	E:RegisterSystem("loot_common", Enable, Disable, Test)
end

------------------
-- LOOT SPECIAL --
------------------

do
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

	local function Toast_SetUp(event, link, quantity, rollType, roll, factionGroup, isItem, isHonor, isPersonal, lessAwesome, isUpgraded, baseQuality, isLegendary, isStorePurchase)
		if isItem then
			if link then
				local sanitizedLink, originalLink, _, itemID = E:SanitizeLink(link)

				local toast, isNew, isQueued = E:GetToast(event, "link", sanitizedLink)

				if isNew then
					local name, _, quality, _, _, _, _, _, _, icon = GetItemInfo(originalLink)

					if quality >= C.db.profile.types.loot_special.threshold and quality <= 5 then
						local color = ITEM_QUALITY_COLORS[quality] or ITEM_QUALITY_COLORS[1]
						local title = L["YOU_WON"]
						local soundFile = 31578 -- SOUNDKIT.UI_EPICLOOT_TOAST

						toast.IconText1.PostSetAnimatedValue = PostSetAnimatedValue

						if factionGroup then
							toast.BG:SetTexture("Interface\\AddOns\\ls_Toasts\\media\\toast-bg-"..factionGroup)
						end

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

							local upgradeTexture = LOOTUPGRADEFRAME_QUALITY_TEXTURES[quality] or LOOTUPGRADEFRAME_QUALITY_TEXTURES[2]

							for i = 1, 5 do
								toast["Arrow"..i]:SetAtlas(upgradeTexture.arrow, true)
							end

							toast.BG:SetTexture("Interface\\AddOns\\ls_Toasts\\media\\toast-bg-upgrade")
						end

						if isLegendary then
							title = L["ITEM_LEGENDARY"]
							soundFile = 63971 -- SOUNDKIT.UI_LEGENDARY_LOOT_TOAST

							toast.BG:SetTexture("Interface\\AddOns\\ls_Toasts\\media\\toast-bg-legendary")
							toast.Dragon:Show()
						end

						if isStorePurchase then
							title = L["BLIZZARD_STORE_PURCHASE_DELIVERED"]
							soundFile = 39517 -- SOUNDKIT.UI_IG_STORE_PURCHASE_DELIVERED_TOAST_01

							toast.BG:SetTexture("Interface\\AddOns\\ls_Toasts\\media\\toast-bg-store")
						end

						if rollType == LOOT_ROLL_TYPE_NEED then
							title = TITLE_NEED_TEMPLATE:format(title, roll)
						elseif rollType == LOOT_ROLL_TYPE_GREED then
							title = TITLE_GREED_TEMPLATE:format(title, roll)
						elseif rollType == LOOT_ROLL_TYPE_DISENCHANT then
							title = TITLE_DE_TEMPLATE:format(title, roll)
						end

						if C.db.profile.colors.name then
							name = color.hex..name.."|r"
						end

						if C.db.profile.types.loot_special.ilvl then
							local iLevel = E:GetItemLevel(originalLink)

							if iLevel > 0 then
								name = "["..color.hex..iLevel.."|r] "..name
							end
						end

						if C.db.profile.colors.border then
							toast.Border:SetVertexColor(color.r, color.g, color.b)
						end

						if C.db.profile.colors.icon_border then
							toast.IconBorder:SetVertexColor(color.r, color.g, color.b)
						end

						toast.Title:SetText(title)
						toast.Text:SetText(name)
						toast.Icon:SetTexture(icon)
						toast.IconBorder:Show()
						toast.IconText1:SetAnimatedValue(quantity, true)
						toast.UpgradeIcon:SetShown(E:IsItemUpgrade(originalLink))

						toast._data = {
							count = quantity,
							event = event,
							item_id = itemID,
							link = sanitizedLink,
							show_arrows = isUpgraded,
							sound_file = soundFile,
							tooltip_link = originalLink,
						}

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
					toast.BG:SetTexture("Interface\\AddOns\\ls_Toasts\\media\\toast-bg-"..factionGroup)
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
					sound_file = 31578, -- SOUNDKIT.UI_EPICLOOT_TOAST
				}

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
			return C_Timer_After(0.25, function() STORE_PRODUCT_DELIVERED(nil, nil, nil, payloadID) end)
		end
	end

	local function BonusRollFrame_FinishedFading_Disabled(self)
		GroupLootContainer_RemoveFrame(GroupLootContainer, self:GetParent())
	end

	local function BonusRollFrame_FinishedFading_Enabled(self)
		local frame = self:GetParent()

		Toast_SetUp("LOOT_ITEM_BONUS_ROLL_WON", frame.rewardLink, frame.rewardQuantity, nil, nil, nil, frame.rewardType == "item" or frame.rewardType == "artifact_power")
		GroupLootContainer_RemoveFrame(GroupLootContainer, frame)
	end

	local function Enable()
		if C.db.profile.types.loot_special.enabled then
			E:RegisterEvent("LOOT_ITEM_ROLL_WON", LOOT_ITEM_ROLL_WON)
			E:RegisterEvent("SHOW_LOOT_TOAST", SHOW_LOOT_TOAST)
			E:RegisterEvent("SHOW_LOOT_TOAST_LEGENDARY_LOOTED", SHOW_LOOT_TOAST_LEGENDARY_LOOTED)
			E:RegisterEvent("SHOW_LOOT_TOAST_UPGRADE", SHOW_LOOT_TOAST_UPGRADE)
			E:RegisterEvent("SHOW_PVP_FACTION_LOOT_TOAST", SHOW_PVP_FACTION_LOOT_TOAST)
			E:RegisterEvent("SHOW_RATED_PVP_REWARD_TOAST", SHOW_RATED_PVP_REWARD_TOAST)
			E:RegisterEvent("STORE_PRODUCT_DELIVERED", STORE_PRODUCT_DELIVERED)

			BonusRollFrame.FinishRollAnim:SetScript("OnFinished", BonusRollFrame_FinishedFading_Enabled)
		else
			BonusRollFrame.FinishRollAnim:SetScript("OnFinished", BonusRollFrame_FinishedFading_Disabled)
		end
	end

	local function Disable()
		E:UnregisterEvent("LOOT_ITEM_ROLL_WON", LOOT_ITEM_ROLL_WON)
		E:UnregisterEvent("SHOW_LOOT_TOAST", SHOW_LOOT_TOAST)
		E:UnregisterEvent("SHOW_LOOT_TOAST_LEGENDARY_LOOTED", SHOW_LOOT_TOAST_LEGENDARY_LOOTED)
		E:UnregisterEvent("SHOW_LOOT_TOAST_UPGRADE", SHOW_LOOT_TOAST_UPGRADE)
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
		-- legendary, Sephuz's Secret
		_, link = GetItemInfo(132452)

		if link then
			Toast_SetUp("SPECIAL_LOOT_TEST", link, 1, nil, nil, nil, true, nil, nil, nil, nil, nil, true)
		end

		-- store, Pouch of Enduring Wisdom
		_, link = GetItemInfo(105911)

		if link then
			Toast_SetUp("SPECIAL_LOOT_TEST", link, 1, nil, nil, nil, true, nil, nil, nil, nil, nil, nil, true)
		end
	end

	E:RegisterOptions("loot_special", {
		enabled = true,
		dnd = false,
		threshold = 1,
		ilvl = true,
	}, {
		name = L["TYPE_LOOT_SPECIAL"],
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
				get = function()
					return C.db.profile.types.loot_special.enabled
				end,
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
				get = function()
					return C.db.profile.types.loot_special.dnd
				end,
				set = function(_, value)
					C.db.profile.types.loot_special.dnd = value

					if value then
						Enable()
					else
						Disable()
					end
				end
			},
			ilvl = {
				order = 4,
				type = "toggle",
				name = L["SHOW_ILVL"],
				desc = L["SHOW_ILVL_DESC"],
				get = function()
					return C.db.profile.types.loot_special.ilvl
				end,
				set = function(_, value)
					C.db.profile.types.loot_special.ilvl = value
				end
			},
			threshold = {
				order = 5,
				type = "select",
				name = L["LOOT_THRESHOLD"],
				values = {
					[1] = ITEM_QUALITY_COLORS[1].hex..ITEM_QUALITY1_DESC.."|r",
					[2] = ITEM_QUALITY_COLORS[2].hex..ITEM_QUALITY2_DESC.."|r",
					[3] = ITEM_QUALITY_COLORS[3].hex..ITEM_QUALITY3_DESC.."|r",
					[4] = ITEM_QUALITY_COLORS[4].hex..ITEM_QUALITY4_DESC.."|r",
					[5] = ITEM_QUALITY_COLORS[5].hex..ITEM_QUALITY5_DESC.."|r",
				},
				get = function()
					return C.db.profile.types.loot_special.threshold
				end,
				set = function(_, value)
					 C.db.profile.types.loot_special.threshold = value
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

	E:RegisterSystem("loot_special", Enable, Disable, Test)
end

-------------------
-- LOOT CURRENCY --
-------------------

do
	local function Toast_OnEnter(self)
		GameTooltip:SetHyperlink(self._data.tooltip_link)
		GameTooltip:Show()
	end

	local function Toast_SetUp(event, link, quantity)
		local sanitizedLink, originalLink = E:SanitizeLink(link)
		local toast, isNew, isQueued = E:GetToast(event, "link", sanitizedLink)

		if isNew then
			local name, _, icon, _, _, _, _, quality = GetCurrencyInfo(link)
			local color = ITEM_QUALITY_COLORS[quality] or ITEM_QUALITY_COLORS[1]

			if C.db.profile.colors.name then
				toast.Text:SetTextColor(color.r, color.g, color.b)
			end

			if C.db.profile.colors.border then
				toast.Border:SetVertexColor(color.r, color.g, color.b)
			end

			if C.db.profile.colors.icon_border then
				toast.IconBorder:SetVertexColor(color.r, color.g, color.b)
			end

			toast.Title:SetText(L["YOU_RECEIVED"])
			toast.Text:SetText(name)
			toast.Icon:SetTexture(icon)
			toast.IconBorder:Show()
			toast.IconText1:SetAnimatedValue(quantity, true)

			toast._data = {
				event = event,
				count = quantity,
				link = sanitizedLink,
				sound_file = 31578, -- SOUNDKIT.UI_EPICLOOT_TOAST
				tooltip_link = originalLink,
			}

			toast:HookScript("OnEnter", Toast_OnEnter)
			toast:Spawn(C.db.profile.types.loot_currency.dnd)
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

	local CURRENCY_GAINED_PATTERN
	local CURRENCY_GAINED_MULTIPLE_PATTERN

	local function CHAT_MSG_CURRENCY(message)
		local link, quantity = message:match(CURRENCY_GAINED_MULTIPLE_PATTERN)

		if not link then
			quantity, link = 1, message:match(CURRENCY_GAINED_PATTERN)

			if not link then
				return
			end
		end

		Toast_SetUp("CHAT_MSG_CURRENCY", link, tonumber(quantity) or 0)
	end

	local function Enable()
		CURRENCY_GAINED_PATTERN = CURRENCY_GAINED:gsub("%%s", "(.+)"):gsub("^", "^")
		CURRENCY_GAINED_MULTIPLE_PATTERN = CURRENCY_GAINED_MULTIPLE:gsub("%%s", "(.+)"):gsub("%%d", "(%%d+)"):gsub("^", "^")

		if C.db.profile.types.loot_currency.enabled then
			E:RegisterEvent("CHAT_MSG_CURRENCY", CHAT_MSG_CURRENCY)
		end
	end

	local function Disable()
		E:UnregisterEvent("CHAT_MSG_CURRENCY", CHAT_MSG_CURRENCY)
	end

	local function Test()
		-- Order Resources
		local link, _ = GetCurrencyLink(1220)

		if link then
			Toast_SetUp("LOOT_CURRENCY_TEST", link, m_random(300, 600))
		end
	end

	E:RegisterOptions("loot_currency", {
		enabled = true,
		dnd = false,
	}, {
		name = L["TYPE_LOOT_CURRENCY"],
		args = {
			enabled = {
				order = 1,
				type = "toggle",
				name = L["ENABLE"],
				get = function()
					return C.db.profile.types.loot_currency.enabled
				end,
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
				get = function()
					return C.db.profile.types.loot_currency.dnd
				end,
				set = function(_, value)
					C.db.profile.types.loot_currency.dnd = value

					if value then
						Enable()
					else
						Disable()
					end
				end
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
end

---------------
-- LOOT GOLD --
---------------

do
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
					sound_file = 865, -- SOUNDKIT.IG_BACKPACK_COIN_OK
				}

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
		threshold = 1,
	}, {
		name = L["TYPE_LOOT_GOLD"],
		args = {
			enabled = {
				order = 1,
				type = "toggle",
				name = L["ENABLE"],
				get = function()
					return C.db.profile.types.loot_gold.enabled
				end,
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
				get = function()
					return C.db.profile.types.loot_gold.dnd
				end,
				set = function(_, value)
					C.db.profile.types.loot_gold.dnd = value

					if value then
						Enable()
					else
						Disable()
					end
				end
			},
			threshold = {
				order = 3,
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
end

------------
-- RECIPE --
------------

do
	local function Toast_OnClick(self)
		if self._data then
			if not TradeSkillFrame then
				TradeSkillFrame_LoadUI()
			end

			if TradeSkillFrame then
				if C_TradeSkillUI_OpenTradeSkill(self._data.tradeskill_id) then
					TradeSkillFrame:SelectRecipe(self._data.recipe_id)
				end
			end
		end
	end

	local function Toast_OnEnter(self)
		if self._data then
			GameTooltip:SetSpellByID(self._data.recipe_id)
			GameTooltip:Show()
		end
	end

	local function Toast_SetUp(event, recipeID)
		local tradeSkillID = C_TradeSkillUI_GetTradeSkillLineForRecipe(recipeID)

		if tradeSkillID then
			local recipeName = GetSpellInfo(recipeID)

			if recipeName then
				local toast = E:GetToast()
				local rank = GetSpellRank(recipeID)
				local rankTexture = ""

				if rank == 1 then
					rankTexture = "|TInterface\\LootFrame\\toast-star:12:12:0:0:32:32:0:21:0:21|t"
				elseif rank == 2 then
					rankTexture = "|TInterface\\LootFrame\\toast-star-2:12:24:0:0:64:32:0:42:0:21|t"
				elseif rank == 3 then
					rankTexture = "|TInterface\\LootFrame\\toast-star-3:12:36:0:0:64:32:0:64:0:21|t"
				end

				toast.Title:SetText(rank and rank > 1 and L["RECIPE_UPGRADED"] or L["RECIPE_LEARNED"])
				toast.Text:SetText(recipeName)
				toast.BG:SetTexture("Interface\\AddOns\\ls_Toasts\\media\\toast-bg-recipe")
				toast.Icon:SetTexture(C_TradeSkillUI_GetTradeSkillTexture(tradeSkillID))
				toast.IconBorder:Show()
				toast.IconText1:SetText(rankTexture)
				toast.IconText1BG:SetShown(not not rank)

				toast._data = {
					event = event,
					recipe_id = recipeID,
					sound_file = 73919, -- SOUNDKIT.UI_PROFESSIONS_NEW_RECIPE_LEARNED_TOAST
					tradeskill_id = tradeSkillID,
				}

				toast:HookScript("OnClick", Toast_OnClick)
				toast:HookScript("OnEnter", Toast_OnEnter)
				toast:Spawn(C.db.profile.types.recipe.dnd)
			end
		end
	end

	local function NEW_RECIPE_LEARNED(recipeID)
		Toast_SetUp("NEW_RECIPE_LEARNED", recipeID)
	end

	local function Enable()
		if C.db.profile.types.recipe.enabled then
			E:RegisterEvent("NEW_RECIPE_LEARNED", NEW_RECIPE_LEARNED)
		end
	end

	local function Disable()
		E:UnregisterEvent("NEW_RECIPE_LEARNED", NEW_RECIPE_LEARNED)
	end

	local function Test()
		-- no rank, Elixir of Minor Defence
		Toast_SetUp("RECIPE_TEST", 7183)

		-- rank 2, Word of Critical Strike
		Toast_SetUp("RECIPE_TEST", 190992)
	end

	E:RegisterOptions("recipe", {
		enabled = true,
		dnd = false,
	}, {
		name = L["TYPE_RECIPE"],
		args = {
			enabled = {
				order = 1,
				type = "toggle",
				name = L["ENABLE"],
				get = function()
					return C.db.profile.types.recipe.enabled
				end,
				set = function(_, value)
					C.db.profile.types.recipe.enabled = value

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
				get = function()
					return C.db.profile.types.recipe.dnd
				end,
				set = function(_, value)
					C.db.profile.types.recipe.dnd = value

					if value then
						Enable()
					else
						Disable()
					end
				end
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

	E:RegisterSystem("recipe", Enable, Disable, Test)
end

--------------
-- TRANSMOG --
--------------

do
	local function Toast_OnClick(self)
		if self._data then
			if not CollectionsJournal then
				CollectionsJournal_LoadUI()
			end

			if CollectionsJournal then
				WardrobeCollectionFrame_OpenTransmogLink(self._data.link)
			end
		end
	end

	local function IsAppearanceKnown(sourceID)
		local data = C_TransmogCollection_GetSourceInfo(sourceID)
		local sources = C_TransmogCollection_GetAppearanceSources(data.visualID)

		if sources then
			for i = 1, #sources do
				if sources[i].isCollected and sourceID ~= sources[i].sourceID then
					return true
				end
			end
		else
			return nil
		end

		return false
	end

	local function Toast_SetUp(event, sourceID, isAdded, attempt)
		local _, _, _, icon, _, _, link = C_TransmogCollection_GetAppearanceSourceInfo(sourceID)
		local name
		link, _, _, _, name = E:SanitizeLink(link)

		if not link then
			return attempt < 4 and C_Timer_After(0.25, function() Toast_SetUp(event, sourceID, isAdded, attempt + 1) end)
		end

		local toast, isNew, isQueued = E:GetToast(nil, "source_id", sourceID)

		if isNew then
			if isAdded then
				toast.Title:SetText(L["TRANSMOG_ADDED"])
			else
				toast.Title:SetText(L["TRANSMOG_REMOVED"])
			end

			if C.db.profile.colors.border then
				toast.Border:SetVertexColor(1, 0.5, 1)
			end

			if C.db.profile.colors.icon_border then
				toast.IconBorder:SetVertexColor(1, 0.5, 1)
			end

			toast.Text:SetText(name)
			toast.BG:SetTexture("Interface\\AddOns\\ls_Toasts\\media\\toast-bg-transmog")
			toast.Icon:SetTexture(icon)
			toast.IconBorder:Show()

			toast._data = {
				event = event,
				link = link,
				sound_file = 38326, -- SOUNDKIT.UI_DIG_SITE_COMPLETION_TOAST
				source_id = sourceID,
			}

			toast:HookScript("OnClick", Toast_OnClick)
			toast:Spawn(C.db.profile.types.transmog.dnd)
		else
			if isAdded then
				toast.Title:SetText(L["TRANSMOG_ADDED"])
			else
				toast.Title:SetText(L["TRANSMOG_REMOVED"])
			end

			if not isQueued then
				toast.AnimOut:Stop()
				toast.AnimOut:Play()
			end
		end
	end

	local function TRANSMOG_COLLECTION_SOURCE_ADDED(sourceID, attempt)
		local isKnown = IsAppearanceKnown(sourceID)
		attempt = attempt or 1

		if attempt < 4 then
			if isKnown == false then
				Toast_SetUp("TRANSMOG_COLLECTION_SOURCE_ADDED", sourceID, true, 1)
			elseif isKnown == nil then
				C_Timer_After(0.25, function() TRANSMOG_COLLECTION_SOURCE_ADDED(sourceID, attempt + 1) end)
			end
		end
	end

	local function TRANSMOG_COLLECTION_SOURCE_REMOVED(sourceID, attempt)
		local isKnown = IsAppearanceKnown(sourceID, true)
		attempt = attempt or 1

		if attempt < 4 then
			if isKnown == false then
				Toast_SetUp("TRANSMOG_COLLECTION_SOURCE_REMOVED", sourceID, nil, 1)
			elseif isKnown == nil then
				C_Timer_After(0.25, function() TRANSMOG_COLLECTION_SOURCE_REMOVED(sourceID, attempt + 1) end)
			end
		end
	end

	local function Enable()
		if C.db.profile.types.transmog.enabled then
			E:RegisterEvent("TRANSMOG_COLLECTION_SOURCE_ADDED", TRANSMOG_COLLECTION_SOURCE_ADDED)
			E:RegisterEvent("TRANSMOG_COLLECTION_SOURCE_REMOVED", TRANSMOG_COLLECTION_SOURCE_REMOVED)
		end
	end

	local function Disable()
		E:UnregisterEvent("TRANSMOG_COLLECTION_SOURCE_ADDED", TRANSMOG_COLLECTION_SOURCE_ADDED)
		E:UnregisterEvent("TRANSMOG_COLLECTION_SOURCE_REMOVED", TRANSMOG_COLLECTION_SOURCE_REMOVED)
	end

	local function Test()
		local appearance = C_TransmogCollection_GetCategoryAppearances(1) and C_TransmogCollection_GetCategoryAppearances(1)[1]
		local source = C_TransmogCollection_GetAppearanceSources(appearance.visualID) and C_TransmogCollection_GetAppearanceSources(appearance.visualID)[1]

		-- added
		Toast_SetUp("TRANSMOG_TEST", source.sourceID, true, 1)

		-- removed
		C_Timer_After(2, function() Toast_SetUp("TRANSMOG_TEST", source.sourceID, nil, 1) end )
	end

	E:RegisterOptions("transmog", {
		enabled = true,
		dnd = false,
	}, {
		name = L["TYPE_TRANSMOG"],
		args = {
			enabled = {
				order = 1,
				type = "toggle",
				name = L["ENABLE"],
				get = function()
					return C.db.profile.types.transmog.enabled
				end,
				set = function(_, value)
					C.db.profile.types.transmog.enabled = value

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
				get = function()
					return C.db.profile.types.transmog.dnd
				end,
				set = function(_, value)
					C.db.profile.types.transmog.dnd = value

					if value then
						Enable()
					else
						Disable()
					end
				end
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

	E:RegisterSystem("transmog", Enable, Disable, Test)
end

-----------
-- WORLD --
-----------

do
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
					SetPortraitToTexture(slot.Icon, "Interface\\Icons\\inv_misc_coin_02")

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
					SetPortraitToTexture(slot.Icon, "Interface\\Icons\\xp_icon")

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
					local isOK = pcall(SetPortraitToTexture, slot.Icon, texture)

					if not isOK then
						SetPortraitToTexture(slot.Icon, "Interface\\Icons\\INV_Box_02")
					end

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
				if isInvasionBonusComplete then
					toast.Bonus:Show()
				end

				if C.db.profile.colors.border then
					toast.Border:SetVertexColor(60 / 255, 255 / 255, 38 / 255) -- fel green #3cff26
				end

				if C.db.profile.colors.icon_border then
					toast.IconBorder:SetVertexColor(60 / 255, 255 / 255, 38 / 255) -- fel green #3cff26
				end

				toast.Title:SetText(L["SCENARIO_INVASION_COMPLETED"])
				toast.BG:SetTexture("Interface\\AddOns\\ls_Toasts\\media\\toast-bg-legion")
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

				if C.db.profile.colors.border then
					toast.Border:SetVertexColor(color.r, color.g, color.b)
				end

				if C.db.profile.colors.icon_border then
					toast.IconBorder:SetVertexColor(color.r, color.g, color.b)
				end

				toast.Title:SetText(L["WORLD_QUEST_COMPLETED"])
				toast.BG:SetTexture("Interface\\AddOns\\ls_Toasts\\media\\toast-bg-worldquest")

				soundFile = 73277 -- SOUNDKIT.UI_WORLDQUEST_COMPLETE
			end

			toast.Text:SetText(name)
			toast.IconBorder:Show()

			toast._data = {
				event = event,
				quest_id = questID,
				sound_file = soundFile,
				used_slots = usedSlots,
			}

			toast:Spawn(C.db.profile.types.world.dnd)
		else
			if itemReward then
				toast._data.used_slots = toast._data.used_slots + 1
				local slot = toast["Slot"..toast._data.used_slots]

				if slot then
					local _, _, _, _, texture = GetItemInfoInstant(itemReward)
					local isOK = pcall(SetPortraitToTexture, slot.Icon, texture)

					if not isOK then
						SetPortraitToTexture(slot.Icon, "Interface\\Icons\\INV_Box_02")
					end

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
		local scenarioName, _, _, _, hasBonusStep, isBonusStepComplete, _, xp, money, scenarioType, areaName = C_Scenario_GetInfo()

		if scenarioType == LE_SCENARIO_TYPE_LEGION_INVASION then
			if questID then
				Toast_SetUp("SCENARIO_COMPLETED", false, questID, areaName or scenarioName, money, xp, nil, nil, true, hasBonusStep and isBonusStepComplete)
			end
		end
	end

	local function QUEST_TURNED_IN(questID)
		if QuestUtils_IsQuestWorldQuest(questID) then
			Toast_SetUp("QUEST_TURNED_IN", false, questID, C_TaskQuest_GetQuestInfoByQuestID(questID), GetQuestLogRewardMoney(questID), GetQuestLogRewardXP(questID), GetNumQuestLogRewardCurrencies(questID))
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
			local quests = C_TaskQuest_GetQuestsForPlayerByMapID(1014)

			if #quests == 0 then
				quests = C_TaskQuest_GetQuestsForPlayerByMapID(1015)

				if #quests == 0 then
					quests = C_TaskQuest_GetQuestsForPlayerByMapID(1017)

					if #quests == 0 then
						quests = C_TaskQuest_GetQuestsForPlayerByMapID(1018)

						if #quests == 0 then
							quests = C_TaskQuest_GetQuestsForPlayerByMapID(1021)

							if #quests == 0 then
								quests = C_TaskQuest_GetQuestsForPlayerByMapID(1024)

								if #quests == 0 then
									quests = C_TaskQuest_GetQuestsForPlayerByMapID(1033)

									if #quests == 0 then
										quests = C_TaskQuest_GetQuestsForPlayerByMapID(1096)
									end
								end
							end
						end
					end
				end
			end

			for _, quest in next, quests do
				if HaveQuestData(quest.questId) then
					if QuestUtils_IsQuestWorldQuest(quest.questId) then
						Toast_SetUp("WORLD_TEST", false, quest.questId, C_TaskQuest_GetQuestInfoByQuestID(quest.questId), 123456, 123456)
						Toast_SetUp("WORLD_TEST", true, quest.questId, "scenario", nil, nil, nil, link)

						return
					end
				end
			end
		end
	end

	E:RegisterOptions("world", {
		enabled = true,
		dnd = false,
	}, {
		name = L["TYPE_WORLD_QUEST"],
		args = {
			enabled = {
				order = 1,
				type = "toggle",
				name = L["ENABLE"],
				get = function()
					return C.db.profile.types.world.enabled
				end,
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
				get = function()
					return C.db.profile.types.world.dnd
				end,
				set = function(_, value)
					C.db.profile.types.world.dnd = value

					if value then
						Enable()
					else
						Disable()
					end
				end
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
end
