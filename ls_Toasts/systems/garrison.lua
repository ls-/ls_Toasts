local _, addonTable = ...
local E, L, C = addonTable.E, addonTable.L, addonTable.C

-- Lua
local _G = getfenv(0)
local pcall = _G.pcall
local s_split = _G.string.split
local select = _G.select
local tonumber = _G.tonumber

-- Mine
local PLAYER_CLASS = select(3, UnitClass("player"))

local typeToKey = {
	[Enum.GarrisonType.Type_6_0_Garrison] = "garrison_6_0",
	[Enum.GarrisonType.Type_7_0_Garrison] = "garrison_7_0",
	[Enum.GarrisonType.Type_8_0_Garrison] = "garrison_8_0",
	[Enum.GarrisonType.Type_9_0_Garrison] = "garrison_9_0",
}

local function getGarrisonTypeByFollowerType(followerTypeID)
	if followerTypeID == Enum.GarrisonFollowerType.FollowerType_9_0_GarrisonFollower then
		return Enum.GarrisonType.Type_9_0_Garrison
	elseif followerTypeID == Enum.GarrisonFollowerType.FollowerType_8_0_GarrisonFollower then
		return Enum.GarrisonType.Type_8_0_Garrison
	elseif followerTypeID == Enum.GarrisonFollowerType.FollowerType_7_0_GarrisonFollower then
		return Enum.GarrisonType.Type_7_0_Garrison
	elseif followerTypeID == Enum.GarrisonFollowerType.FollowerType_6_0_GarrisonFollower or followerTypeID == Enum.GarrisonFollowerType.FollowerType_6_0_Boat then
		return Enum.GarrisonType.Type_6_0_Garrison
	end
end

local function MissionToast_SetUp(event, garrisonType, missionID, isAdded)
	local missionInfo = C_Garrison.GetBasicMissionInfo(missionID)
	local rarity = missionInfo.isRare and 3 or 1
	local color = ITEM_QUALITY_COLORS[rarity]
	local toast = E:GetToast()

	if isAdded then
		toast.Title:SetText(L["GARRISON_MISSION_ADDED"])
	else
		toast.Title:SetText(L["GARRISON_MISSION_COMPLETED"])
	end

	if rarity >= C.db.profile.colors.threshold then
		if C.db.profile.colors.name then
			toast.Text:SetTextColor(color.r, color.g, color.b)
		end

		if C.db.profile.colors.border then
			toast.Border:SetVertexColor(color.r, color.g, color.b)
		end
	end

	toast.Text:SetText(missionInfo.name)
	toast.Icon:SetPoint("TOPLEFT", -1, 1)
	toast.Icon:SetSize(44, 44)
	toast.Icon:SetTexCoord(0, 1, 0, 1)
	toast.Icon:SetAtlas(missionInfo.typeAtlas, false)

	toast._data.event = event
	toast._data.mission_id = missionID
	toast._data.sound_file = C.db.profile.types[typeToKey[garrisonType]].sfx and 44294 -- SOUNDKIT.UI_GARRISON_TOAST_MISSION_COMPLETE

	toast:Spawn(C.db.profile.types[typeToKey[garrisonType]].anchor, C.db.profile.types[typeToKey[garrisonType]].dnd)
end

local function GARRISON_MISSION_FINISHED(followerTypeID, missionID)
	local garrisonType = getGarrisonTypeByFollowerType(followerTypeID)
	if not C.db.profile.types[typeToKey[garrisonType]].enabled then
		return
	end

	local _, instanceType = GetInstanceInfo()
	local validInstance = false

	if instanceType == "none" or C_Garrison.IsOnGarrisonMap() then
		validInstance = true
	end

	if validInstance then
		MissionToast_SetUp("GARRISON_MISSION_FINISHED", garrisonType, missionID)
	end
end

local function GARRISON_RANDOM_MISSION_ADDED(followerTypeID, missionID)
	local garrisonType = getGarrisonTypeByFollowerType(followerTypeID)
	if not C.db.profile.types[typeToKey[garrisonType]].enabled then
		return
	end

	MissionToast_SetUp("GARRISON_RANDOM_MISSION_ADDED", garrisonType, missionID, true)
end

------

local function FollowerToast_OnEnter(self)
	if self._data.follower_id then
		local isOK, link = pcall(C_Garrison.GetFollowerLink, self._data.follower_id)
		if not isOK then
			isOK, link = pcall(C_Garrison.GetFollowerLinkByID, self._data.follower_id)
		end

		if isOK and link then
			-- colour code, link type, ...
			local _, _, garrisonFollowerID, quality, level, itemLevel, ability1, ability2, ability3, ability4, trait1, trait2, trait3, trait4, spec1 = s_split(":", link)
			garrisonFollowerID = tonumber(garrisonFollowerID)

			local data = {
				garrisonFollowerID = garrisonFollowerID,
				followerTypeID = C_Garrison.GetFollowerTypeByID(garrisonFollowerID),
				collected = false,
				hyperlink = false,
				name = C_Garrison.GetFollowerNameByID(garrisonFollowerID),
				spec = C_Garrison.GetFollowerClassSpecByID(garrisonFollowerID),
				portraitIconID = C_Garrison.GetFollowerPortraitIconIDByID(garrisonFollowerID),
				quality = tonumber(quality),
				level = tonumber(level),
				xp = 0,
				levelxp = 0,
				iLevel = tonumber(itemLevel),
				spec1 = tonumber(spec1),
				ability1 = tonumber(ability1),
				ability2 = tonumber(ability2),
				ability3 = tonumber(ability3),
				ability4 = tonumber(ability4),
				trait1 = tonumber(trait1),
				trait2 = tonumber(trait2),
				trait3 = tonumber(trait3),
				trait4 = tonumber(trait4),
				isTroop = C_Garrison.GetFollowerIsTroop(garrisonFollowerID),
			}

			local tooltip
			if data.followerTypeID == Enum.GarrisonFollowerType.FollowerType_6_0_Boat then
				tooltip = GarrisonShipyardFollowerTooltip
				GarrisonFollowerTooltipTemplate_SetShipyardFollower(tooltip, data)
			else
				tooltip = GarrisonFollowerTooltip
				GarrisonFollowerTooltipTemplate_SetGarrisonFollower(tooltip, data)
			end

			tooltip:Show()
			tooltip:ClearAllPoints()
			tooltip:SetPoint(GameTooltip:GetPoint())
		end
	end
end

local function FollowerToast_SetUp(event, garrisonType, followerTypeID, followerID, name, textureKit, level, quality, isUpgraded)
	local followerInfo = C_Garrison.GetFollowerInfo(followerID)
	local followerStrings = GarrisonFollowerOptions[followerTypeID].strings
	local upgradeTexture = LOOTUPGRADEFRAME_QUALITY_TEXTURES[quality] or LOOTUPGRADEFRAME_QUALITY_TEXTURES[2]
	local color = ITEM_QUALITY_COLORS[quality]
	local toast = E:GetToast()

	if followerTypeID == Enum.GarrisonFollowerType.FollowerType_6_0_Boat then
		toast.Icon:SetPoint("TOPLEFT", -2, -1)
		toast.Icon:SetSize(46, 40)
		toast.Icon:SetTexCoord(0, 1, 0, 1)
		toast.Icon:SetAtlas(textureKit .. "-Portrait", false)
	else
		local portrait
		if followerInfo.portraitIconID and followerInfo.portraitIconID ~= 0 then
			portrait = followerInfo.portraitIconID
		else
			portrait = "Interface\\Garrison\\Portraits\\FollowerPortrait_NoPortrait"
		end

		toast.Icon:SetTexture(portrait)
		toast.Icon:SetTexCoord(0, 1, 0, 1)
		toast.IconText1:SetText(level)
	end

	if isUpgraded then
		toast:SetBackground("upgrade")
		toast.Title:SetText(followerStrings.FOLLOWER_ADDED_UPGRADED_TOAST)

		for i = 1, 5 do
			toast["Arrow" .. i]:SetAtlas(upgradeTexture.arrow, true)
		end
	else
		toast.Title:SetText(followerStrings.FOLLOWER_ADDED_TOAST)
	end

	if quality >= C.db.profile.colors.threshold then
		if C.db.profile.colors.name then
			toast.Text:SetTextColor(color.r, color.g, color.b)
		end

		if C.db.profile.colors.border then
			toast.Border:SetVertexColor(color.r, color.g, color.b)
		end
	end

	toast.Text:SetText(name)

	toast._data.event = event
	toast._data.follower_id = followerID
	toast._data.show_arrows = isUpgraded
	toast._data.sound_file = C.db.profile.types[typeToKey[garrisonType]].sfx and 44296 -- SOUNDKIT.UI_GARRISON_TOAST_FOLLOWER_GAINED

	if C.db.profile.types[typeToKey[garrisonType]].tooltip then
		toast:HookScript("OnEnter", FollowerToast_OnEnter)
	end

	toast:Spawn(C.db.profile.types[typeToKey[garrisonType]].anchor, C.db.profile.types[typeToKey[garrisonType]].dnd)
end

local function GARRISON_FOLLOWER_ADDED(followerID, name, _, level, quality, isUpgraded, textureKit, followerTypeID)
	local garrisonType = getGarrisonTypeByFollowerType(followerTypeID)
	if not C.db.profile.types[typeToKey[garrisonType]].enabled then
		return
	end

	FollowerToast_SetUp("GARRISON_FOLLOWER_ADDED", garrisonType, followerTypeID, followerID, name, textureKit, level, quality, isUpgraded)
end

------

local function BuildingToast_SetUp(event, buildingName)
	local toast = E:GetToast()

	toast.Title:SetText(L["GARRISON_NEW_BUILDING"])
	toast.Text:SetText(buildingName)
	toast.Icon:SetTexture("Interface\\Icons\\Garrison_Build")
	toast.IconBorder:Show()

	toast._data.event = event
	toast._data.sound_file = C.db.profile.types.garrison_6_0.sfx and 44295 -- SOUNDKIT.UI_GARRISON_TOAST_BUILDING_COMPLETE

	toast:Spawn(C.db.profile.types.garrison_6_0.anchor, C.db.profile.types.garrison_6_0.dnd)
end

local function GARRISON_BUILDING_ACTIVATABLE(buildingName)
	BuildingToast_SetUp("GARRISON_BUILDING_ACTIVATABLE", buildingName)
end

------

local garrTypeToTalentText = {
	[Enum.GarrisonType.Type_7_0_Garrison] = L["GARRISON_NEW_TALENT"],
	[Enum.GarrisonType.Type_8_0_Garrison] = L["GARRISON_NEW_TALENT"],
	[Enum.GarrisonType.Type_9_0_Garrison] = L["COVENANT_NEW_TALENT"],
}

local treeIDToTalentText = {
	[474] = L["CYPHER_NEW_TALENT"] -- 9.2 Cypher Talents tree
}

local function TalentToast_OnEnter(self)
	if self._data.talend_id then
		local talent = C_Garrison.GetTalentInfo(self._data.talend_id)
		GameTooltip:AddLine(talent.name, 1, 1, 1)
		GameTooltip:AddLine(talent.description, nil, nil, nil, true)
		GameTooltip:Show()
	end
end

local function TalentToast_SetUp(event, garrisonType, talentID)
	local talent = C_Garrison.GetTalentInfo(talentID)
	local toast = E:GetToast()

	toast.Title:SetText(treeIDToTalentText[talent.treeID] or garrTypeToTalentText[garrisonType])
	toast.Text:SetText(talent.name)
	toast.Icon:SetTexture(talent.icon)
	toast.IconBorder:Show()

	toast._data.event = event
	toast._data.talend_id = talentID
	toast._data.sound_file = C.db.profile.types[typeToKey[garrisonType]].sfx and 73280 -- SOUNDKIT.UI_ORDERHALL_TALENT_READY_TOAST

	if C.db.profile.types[typeToKey[garrisonType]].tooltip then
		toast:HookScript("OnEnter", TalentToast_OnEnter)
	end

	toast:Spawn(C.db.profile.types[typeToKey[garrisonType]].anchor, C.db.profile.types[typeToKey[garrisonType]].dnd)
end

local function GARRISON_TALENT_COMPLETE(garrisonType, doAlert)
	if not C.db.profile.types[typeToKey[garrisonType]].enabled then
		return
	end

	if doAlert then
		TalentToast_SetUp("GARRISON_TALENT_COMPLETE", garrisonType, C_Garrison.GetCompleteTalent(garrisonType))
	end
end

local function Enable()
	if C.db.profile.types.garrison_9_0.enabled or C.db.profile.types.garrison_8_0.enabled or C.db.profile.types.garrison_7_0.enabled or C.db.profile.types.garrison_6_0.enabled then
		E:RegisterEvent("GARRISON_FOLLOWER_ADDED", GARRISON_FOLLOWER_ADDED)
		E:RegisterEvent("GARRISON_MISSION_FINISHED", GARRISON_MISSION_FINISHED)
		E:RegisterEvent("GARRISON_RANDOM_MISSION_ADDED", GARRISON_RANDOM_MISSION_ADDED)

		if C.db.profile.types.garrison_6_0.enabled then
			E:RegisterEvent("GARRISON_BUILDING_ACTIVATABLE", GARRISON_BUILDING_ACTIVATABLE)
		end

		if C.db.profile.types.garrison_9_0.enabled or C.db.profile.types.garrison_8_0.enabled or C.db.profile.types.garrison_7_0.enabled then
			E:RegisterEvent("GARRISON_TALENT_COMPLETE", GARRISON_TALENT_COMPLETE)
		end
	end
end

local function Disable()
	if not (C.db.profile.types.garrison_9_0.enabled and C.db.profile.types.garrison_8_0.enabled and C.db.profile.types.garrison_7_0.enabled and C.db.profile.types.garrison_6_0.enabled) then
		E:UnregisterEvent("GARRISON_FOLLOWER_ADDED", GARRISON_FOLLOWER_ADDED)
		E:UnregisterEvent("GARRISON_MISSION_FINISHED", GARRISON_MISSION_FINISHED)
		E:UnregisterEvent("GARRISON_RANDOM_MISSION_ADDED", GARRISON_RANDOM_MISSION_ADDED)
	end

	if not C.db.profile.types.garrison_6_0.enabled then
		E:UnregisterEvent("GARRISON_BUILDING_ACTIVATABLE", GARRISON_BUILDING_ACTIVATABLE)
	end

	if not (C.db.profile.types.garrison_9_0.enabled and C.db.profile.types.garrison_8_0.enabled and C.db.profile.types.garrison_7_0.enabled) then
		E:UnregisterEvent("GARRISON_TALENT_COMPLETE", GARRISON_TALENT_COMPLETE)
	end
end

local function TestGarrison()
	-- follower
	local followers = C_Garrison.GetFollowers(Enum.GarrisonFollowerType.FollowerType_6_0_GarrisonFollower)
	local follower = followers and followers[1] or nil
	if follower then
		FollowerToast_SetUp("GARRISON_FOLLOWER_TEST", Enum.GarrisonType.Type_6_0_Garrison, follower.followerTypeID, follower.followerID, follower.name, nil, follower.level, follower.quality, false)
	end

	-- ship
	followers = C_Garrison.GetFollowers(Enum.GarrisonFollowerType.FollowerType_6_0_Boat)
	follower = followers and followers[1] or nil
	if follower then
		FollowerToast_SetUp("GARRISON_FOLLOWER_TEST", Enum.GarrisonType.Type_6_0_Garrison, follower.followerTypeID, follower.followerID, follower.name, follower.textureKit, follower.level, follower.quality, false)
	end

	-- garrison mission
	local missions = C_Garrison.GetAvailableMissions(Enum.GarrisonFollowerType.FollowerType_6_0_GarrisonFollower)
	local missionID = missions and missions[1] and missions[1].missionID or nil
	if missionID then
		MissionToast_SetUp("GARRISON_MISSION_TEST", Enum.GarrisonType.Type_6_0_Garrison, missionID)
	end

	-- shipyard mission
	missions = C_Garrison.GetAvailableMissions(Enum.GarrisonFollowerType.FollowerType_6_0_Boat)
	missionID = missions and missions[1] and missions[1].missionID or nil
	if missionID then
		MissionToast_SetUp("GARRISON_MISSION_TEST", Enum.GarrisonType.Type_6_0_Garrison, missionID)
	end

	-- building
	local buildings = C_Garrison.GetBuildings(Enum.GarrisonType.Type_6_0_Garrison)
	local buildingID = buildings and buildings[1] and buildings[1].buildingID or nil
	if buildingID then
		BuildingToast_SetUp("GARRISON_BUILDING_TEST", select(2, C_Garrison.GetBuildingInfo(buildingID)))
	end
end

local function TestClassHall()
	-- champion
	local followers = C_Garrison.GetFollowers(Enum.GarrisonFollowerType.FollowerType_7_0_GarrisonFollower)
	local follower = followers and followers[1] or nil
	if follower then
		FollowerToast_SetUp("GARRISON_FOLLOWER_TEST", Enum.GarrisonType.Type_7_0_Garrison, follower.followerTypeID, follower.followerID, follower.name, nil, follower.level, follower.quality, false)
	end

	-- mission
	local missions = C_Garrison.GetAvailableMissions(Enum.GarrisonFollowerType.FollowerType_7_0_GarrisonFollower)
	local missionID = missions and missions[1] and missions[1].missionID or nil
	if missionID then
		MissionToast_SetUp("GARRISON_MISSION_TEST", Enum.GarrisonType.Type_7_0_Garrison, missionID)
	end

	-- talent
	local talentTreeIDs = C_Garrison.GetTalentTreeIDsByClassID(Enum.GarrisonType.Type_7_0_Garrison, PLAYER_CLASS)
	if talentTreeIDs and talentTreeIDs[1] then
		local treeInfo = C_Garrison.GetTalentTreeInfo(talentTreeIDs[1])
		if treeInfo and treeInfo.talents and treeInfo.talents[1] then
			TalentToast_SetUp("GARRISON_TALENT_TEST", Enum.GarrisonType.Type_7_0_Garrison, treeInfo.talents[1].id)
		end
	end
end

local function TestWarEffort()
	-- champion
	local followers = C_Garrison.GetFollowers(Enum.GarrisonFollowerType.FollowerType_8_0_GarrisonFollower)
	local follower = followers and followers[1] or nil
	if follower then
		FollowerToast_SetUp("GARRISON_FOLLOWER_TEST", Enum.GarrisonType.Type_8_0_Garrison, follower.followerTypeID, follower.followerID, follower.name, nil, follower.level, follower.quality, false)
	end

	-- mission
	local missions = C_Garrison.GetAvailableMissions(Enum.GarrisonFollowerType.FollowerType_8_0_GarrisonFollower)
	local missionID = missions and missions[1] and missions[1].missionID or nil
	if missionID then
		MissionToast_SetUp("GARRISON_MISSION_TEST", Enum.GarrisonType.Type_8_0_Garrison, missionID)
	end

	-- talent
	local talentTreeIDs = C_Garrison.GetTalentTreeIDsByClassID(Enum.GarrisonType.Type_8_0_Garrison, PLAYER_CLASS)
	if talentTreeIDs and talentTreeIDs[1] then
		local treeInfo = C_Garrison.GetTalentTreeInfo(talentTreeIDs[1])
		if treeInfo and treeInfo.talents and treeInfo.talents[1] then
			TalentToast_SetUp("GARRISON_TALENT_TEST", Enum.GarrisonType.Type_8_0_Garrison, treeInfo.talents[1].id)
		end
	end
end

local function TestCovenant()
	-- champion
	local followers = C_Garrison.GetFollowers(Enum.GarrisonFollowerType.FollowerType_9_0_GarrisonFollower)
	local follower = followers and followers[1] or nil
	if follower then
		FollowerToast_SetUp("GARRISON_FOLLOWER_TEST", Enum.GarrisonType.Type_9_0_Garrison, follower.followerTypeID, follower.followerID, follower.name, nil, follower.level, follower.quality, false)
	end

	-- mission
	local missions = C_Garrison.GetAvailableMissions(Enum.GarrisonFollowerType.FollowerType_9_0_GarrisonFollower)
	local missionID = missions and missions[1] and missions[1].missionID or nil
	if missionID then
		MissionToast_SetUp("GARRISON_MISSION_TEST", Enum.GarrisonType.Type_9_0_Garrison, missionID)
	end

	-- talent, Revendreth - Expanding Potential
	local treeInfo = C_Garrison.GetTalentTreeInfo(326)
	if treeInfo and treeInfo.talents and treeInfo.talents[1] then
		TalentToast_SetUp("GARRISON_TALENT_TEST", Enum.GarrisonType.Type_9_0_Garrison, treeInfo.talents[1].id)
	end

	-- cypher talent, Metrial Understanding
	TalentToast_SetUp("GARRISON_TALENT_TEST", Enum.GarrisonType.Type_9_0_Garrison, 1901)
end

E:RegisterOptions("garrison_6_0", {
	enabled = false,
	anchor = 1,
	dnd = true,
	sfx = true,
	tooltip = true,
}, {
	name = L["TYPE_GARRISON"],
	get = function(info)
		return C.db.profile.types.garrison_6_0[info[#info]]
	end,
	set = function(info, value)
		C.db.profile.types.garrison_6_0[info[#info]] = value
	end,
	args = {
		enabled = {
			order = 1,
			type = "toggle",
			name = L["ENABLE"],
			set = function(_, value)
				C.db.profile.types.garrison_6_0.enabled = value

				if value then
					Enable()
				else
					Disable()
				end
			end,
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
		tooltip = {
			order = 4,
			type = "toggle",
			name = L["TOOLTIPS"],
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
	anchor = 1,
	dnd = true,
	sfx = true,
	tooltip = true,
}, {
	name = L["TYPE_CLASS_HALL"],
	get = function(info)
		return C.db.profile.types.garrison_7_0[info[#info]]
	end,
	set = function(info, value)
		C.db.profile.types.garrison_7_0[info[#info]] = value
	end,
	args = {
		enabled = {
			order = 1,
			type = "toggle",
			name = L["ENABLE"],
			set = function(_, value)
				C.db.profile.types.garrison_7_0.enabled = value

				if value then
					Enable()
				else
					Disable()
				end
			end,
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
		tooltip = {
			order = 4,
			type = "toggle",
			name = L["TOOLTIPS"],
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

E:RegisterOptions("garrison_8_0", {
	enabled = true,
	anchor = 1,
	dnd = true,
	sfx = true,
	tooltip = true,
}, {
	name = L["TYPE_WAR_EFFORT"],
	get = function(info)
		return C.db.profile.types.garrison_8_0[info[#info]]
	end,
	set = function(info, value)
		C.db.profile.types.garrison_8_0[info[#info]] = value
	end,
	args = {
		enabled = {
			order = 1,
			type = "toggle",
			name = L["ENABLE"],
			set = function(_, value)
				C.db.profile.types.garrison_8_0.enabled = value

				if value then
					Enable()
				else
					Disable()
				end
			end,
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
		tooltip = {
			order = 4,
			type = "toggle",
			name = L["TOOLTIPS"],
		},
		test = {
			type = "execute",
			order = 99,
			width = "full",
			name = L["TEST"],
			func = TestWarEffort,
		},
	},
})

E:RegisterOptions("garrison_9_0", {
	enabled = true,
	anchor = 1,
	dnd = true,
	sfx = true,
	tooltip = true,
}, {
	name = L["TYPE_COVENANT"],
	get = function(info)
		return C.db.profile.types.garrison_9_0[info[#info]]
	end,
	set = function(info, value)
		C.db.profile.types.garrison_9_0[info[#info]] = value
	end,
	args = {
		enabled = {
			order = 1,
			type = "toggle",
			name = L["ENABLE"],
			set = function(_, value)
				C.db.profile.types.garrison_9_0.enabled = value

				if value then
					Enable()
				else
					Disable()
				end
			end,
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
		tooltip = {
			order = 4,
			type = "toggle",
			name = L["TOOLTIPS"],
		},
		test = {
			type = "execute",
			order = 99,
			width = "full",
			name = L["TEST"],
			func = TestCovenant,
		},
	},
})

E:RegisterSystem("garrison_6_0", Enable, Disable, TestGarrison)
E:RegisterSystem("garrison_7_0", Enable, Disable, TestClassHall)
E:RegisterSystem("garrison_8_0", Enable, Disable, TestWarEffort)
E:RegisterSystem("garrison_9_0", Enable, Disable, TestCovenant)
