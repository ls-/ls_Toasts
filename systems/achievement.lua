local _, addonTable = ...
local E, L, C = addonTable.E, addonTable.L, addonTable.C

-- Lua
local _G = getfenv(0)

--[[ luacheck: globals
	AchievementFrame AchievementFrame_LoadUI AchievementFrame_SelectAchievement FormatShortDate GameTooltip
	GetAchievementInfo InCombatLockdown ShowUIPanel
]]

-- Mine
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

local function Toast_SetUp(event, achievementID, flag, isCriteria)
	local toast = E:GetToast()
	local _, name, points, _, _, _, _, _, _, icon, _, isGuildAchievement = GetAchievementInfo(achievementID)

	if isCriteria then
		toast.Title:SetText(L["ACHIEVEMENT_PROGRESSED"])
		toast.Text:SetText(flag)

		toast.IconText1:SetText("")
	else
		toast.Title:SetText(isGuildAchievement and L["GUILD_ACHIEVEMENT_UNLOCKED"] or L["ACHIEVEMENT_UNLOCKED"])
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

	toast._data.event = event
	toast._data.ach_id = achievementID

	toast:HookScript("OnClick", Toast_OnClick)
	toast:HookScript("OnEnter", Toast_OnEnter)
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

	-- earned, Ten Hit Tunes
	Toast_SetUp("ACHIEVEMENT_TEST", 9828, true)

	-- guild, It All Adds Up
	Toast_SetUp("ACHIEVEMENT_TEST", 4913, false)
end

E:RegisterOptions("achievement", {
	enabled = true,
	anchor = 1,
	dnd = false,
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
			end
		},
		dnd = {
			order = 2,
			type = "toggle",
			name = L["DND"],
			desc = L["DND_TOOLTIP"],
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
