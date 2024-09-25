local _, addonTable = ...
local E, L, C = addonTable.E, addonTable.L, addonTable.C

-- Lua
local _G = getfenv(0)

-- Mine
local FACTION_ACHIEVEMENTS = {
	[ 4912] = true, -- Guild Level 25 (Alliance)
	[ 5014] = true, -- Guild Northrend Dungeon Hero (Alliance)
	[ 5031] = true, -- Horde Slayer (Alliance)
	[ 5110] = true, -- Heroic: Trial of the Champion Guild Run (Horde)
	[ 5111] = true, -- Heroic: Trial of the Champion Guild Run (Alliance)
	[ 5124] = true, -- Guild Northrend Dungeon Hero (Horde)
	[ 5126] = true, -- Dungeon Diplomat (Alliance)
	[ 5128] = true, -- Classic Battles (Horde)
	[ 5129] = true, -- Ambassadors (Alliance)
	[ 5130] = true, -- Diplomacy (Alliance)
	[ 5131] = true, -- Classic Battles (Alliance)
	[ 5145] = true, -- Dungeon Diplomat (Horde)
	[ 5151] = true, -- Classy Humans (Alliance)
	[ 5152] = true, -- Stay Classy (Alliance)
	[ 5153] = true, -- Classy Night Elves (Alliance)
	[ 5154] = true, -- Classy Gnomes (Alliance)
	[ 5155] = true, -- Classy Dwarves (Alliance)
	[ 5156] = true, -- Classy Draenei (Alliance)
	[ 5157] = true, -- Classy Worgen (Alliance)
	[ 5158] = true, -- Stay Classy (Horde)
	[ 5160] = true, -- Classy Orcs (Horde)
	[ 5161] = true, -- Classy Tauren (Horde)
	[ 5162] = true, -- Classy Trolls (Horde)
	[ 5163] = true, -- Classy Blood Elves (Horde)
	[ 5164] = true, -- Classy Undead (Horde)
	[ 5165] = true, -- Classy Goblins (Horde)
	[ 5167] = true, -- Orc Slayer (Alliance)
	[ 5168] = true, -- Tauren Slayer (Alliance)
	[ 5169] = true, -- Undead Slayer (Alliance)
	[ 5170] = true, -- Troll Slayer (Alliance)
	[ 5171] = true, -- Blood Elf Slayer (Alliance)
	[ 5172] = true, -- Goblin Slayer (Alliance)
	[ 5173] = true, -- Human Slayer (Horde)
	[ 5174] = true, -- Night Elf Slayer (Horde)
	[ 5175] = true, -- Dwarf Slayer (Horde)
	[ 5176] = true, -- Gnome Slayer (Horde)
	[ 5177] = true, -- Draenei Slayer (Horde)
	[ 5178] = true, -- Worgen Slayer (Horde)
	[ 5179] = true, -- Alliance Slayer (Horde)
	[ 5194] = true, -- City Attacker (Horde)
	[ 5195] = true, -- City Attacker (Alliance)
	[ 5432] = true, -- Guild Commanders (Alliance)
	[ 5433] = true, -- Guild Champions (Horde)
	[ 5434] = true, -- Guild Marshals (Alliance)
	[ 5435] = true, -- Guild Generals (Horde)
	[ 5436] = true, -- Guild Field Marshals (Alliance)
	[ 5437] = true, -- Guild Warlords (Horde)
	[ 5438] = true, -- Guild Grand Marshals (Alliance)
	[ 5439] = true, -- Guild High Warlords (Horde)
	[ 5440] = true, -- Guild Battlemasters (Horde)
	[ 5441] = true, -- Guild Battlemasters (Alliance)
	[ 5492] = true, -- Guild Level 25 (Horde)
	[ 5812] = true, -- United Nations (Alliance)
	[ 5892] = true, -- United Nations (Horde)
	[ 6532] = true, -- Pandaren Slayer (Alliance)
	[ 6533] = true, -- Pandaren Slayer (Horde)
	[ 6624] = true, -- Classy Pandaren (Alliance)
	[ 6625] = true, -- Classy Pandaren (Horde)
	[ 6644] = true, -- Pandaren Embassy (Alliance)
	[ 6664] = true, -- Pandaren Embassy (Horde)
	[ 7448] = true, -- Scenario Roundup (Alliance)
	[ 7449] = true, -- Scenario Roundup (Horde)
	[ 7843] = true, -- Diplomacy (Horde)
	[ 7844] = true, -- Ambassadors (Horde)
	[13319] = true, -- Battle of Dazar'alor Guild Run (Horde)
	[13320] = true, -- Battle of Dazar'alor Guild Run (Alliance)
}

local function Toast_OnClick(self)
	if self._data.ach_id and not InCombatLockdown() then
		if not AchievementFrame then
			AchievementFrame_LoadUI()
		end

		if AchievementFrame then
			ShowUIPanel(AchievementFrame)
			AchievementFrame_SelectAchievement(self._data.ach_id)
		end
	end
end

local function Toast_OnEnter(self)
	if self._data.ach_id then
		local _, name, _, _, month, day, year, description = GetAchievementInfo(self._data.ach_id)
		if name then
			if day and day > 0 then
				GameTooltip:AddDoubleLine(name, FormatShortDate(day, month, year), nil, nil, nil, 0.5, 0.5, 0.5)
			else
				GameTooltip:AddLine(name)
			end

			if description then
				GameTooltip:AddLine(description, 1, 1, 1, true)
			end
		end

		GameTooltip:Show()
	end
end

local function Toast_SetUp(event, achievementID, eventArg, isCriteria) -- eventArg is alreadyEarned or criteriaString
	local _, name, points, _, _, _, _, _, _, icon, _, isGuildAchievement = GetAchievementInfo(achievementID)
	if isGuildAchievement and FACTION_ACHIEVEMENTS[achievementID] and C.db.profile.types.achievement.filter_guild then
		return
	end

	local toast = E:GetToast()

	if isCriteria then
		toast.Title:SetText(L["ACHIEVEMENT_PROGRESSED"])
		toast.Text:SetText(eventArg)

		toast.IconText1:SetText("")
	else
		toast.Title:SetText(isGuildAchievement and L["GUILD_ACHIEVEMENT_UNLOCKED"] or L["ACHIEVEMENT_UNLOCKED"])
		toast.Text:SetText(name)

		if not toast:ShouldHideLeaves() then
			toast:ShowLeaves()
		end

		if eventArg then
			toast.IconText1:SetText("")
		else
			if C.db.profile.colors.border then
				toast.Border:SetVertexColor(1, 0.675, 0.125) -- ACHIEVEMENT_GOLD_BORDER_COLOR
				toast:SetLeavesVertexColor(1, 0.675, 0.125)
			end

			if C.db.profile.colors.icon_border then
				toast.IconBorder:SetVertexColor(1, 0.675, 0.125)
			end

			toast.IconText1:SetText(points == 0 and "" or points)
		end
	end

	toast.Icon:SetTexture(icon)
	toast.IconBorder:Show()

	toast._data.event = event
	toast._data.ach_id = achievementID

	if C.db.profile.types.achievement.tooltip then
		toast:HookScript("OnEnter", Toast_OnEnter)
	end

	toast:HookScript("OnClick", Toast_OnClick)
	toast:Spawn(C.db.profile.types.achievement.anchor, C.db.profile.types.achievement.dnd)
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

	-- earned, Reach Level 10
	Toast_SetUp("ACHIEVEMENT_TEST", 6, true)

	-- guild, Everyone Needs a Logo
	Toast_SetUp("ACHIEVEMENT_TEST", 5362)
end

E:RegisterOptions("achievement", {
	enabled = true,
	anchor = 1,
	dnd = false,
	tooltip = true,
	filter_guild = false,
}, {
	name = L["TYPE_ACHIEVEMENT"],
	get = function(info)
		return C.db.profile.types.achievement[info[#info]]
	end,
	set = function(info, value)
		C.db.profile.types.achievement[info[#info]] = value
	end,
	args = {
		enabled = {
			order = 1,
			type = "toggle",
			name = L["ENABLE"],
			set = function(_, value)
				C.db.profile.types.achievement.enabled = value

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
		tooltip = {
			order = 3,
			type = "toggle",
			name = L["TOOLTIPS"],
		},
		filter_guild = {
			order = 4,
			type = "toggle",
			name = L["FILTER_GUILD_ACHIEVEMENTS"],
			desc = L["FILTER_GUILD_ACHIEVEMENTS_DESC"],
			width = 1.25,
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
