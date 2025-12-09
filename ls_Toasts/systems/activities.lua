local _, addonTable = ...
local E, L, C = addonTable.E, addonTable.L, addonTable.C

-- Lua
local _G = getfenv(0)

-- Mine
local function Toast_OnClick(self)
	if self._data.activity_id and not InCombatLockdown() then
		if not EncounterJournal then
			EncounterJournal_LoadUI()
		end

		if EncounterJournal then
			MonthlyActivitiesFrame_OpenFrameToActivity(self._data.activity_id)
		end
	end
end

local function Toast_SetUp(event, perksActivityID)
	local info = C_PerksActivities.GetPerksActivityInfo(perksActivityID)
	if info and info.activityName ~= "" then
		local toast = E:GetToast()

		toast.Title:SetText(L["ACTIVITIES_PROGRESSED"])
		toast.Text:SetText(info.activityName)
		toast.Icon:SetAtlas("activities-toast-icon")
		toast.IconText1:SetText(info.thresholdContributionAmount)
		toast.IconBorder:Show()

		toast._data.event = event
		toast._data.activity_id = perksActivityID
		toast._data.sound_file = C.db.profile.types.activities.sfx and 219929 -- SOUNDKIT.TRADING_POST_UI_COMPLETED_ACTIVITY_TOAST
		toast._data.vfx = C.db.profile.types.activities.vfx

		toast:HookScript("OnClick", Toast_OnClick)
		toast:Spawn(C.db.profile.types.activities.anchor, C.db.profile.types.activities.dnd)
	end
end

local function PERKS_ACTIVITY_COMPLETED(perksActivityID)
	Toast_SetUp("PERKS_ACTIVITY_COMPLETED", perksActivityID)
end

local function Enable()
	if C.db.profile.types.activities.enabled then
		E:RegisterEvent("PERKS_ACTIVITY_COMPLETED", PERKS_ACTIVITY_COMPLETED)
	end
end

local function Disable()
	E:UnregisterEvent("PERKS_ACTIVITY_COMPLETED", PERKS_ACTIVITY_COMPLETED)
end

local function Test()
	-- Show Some Love to the Trading Post
	Toast_SetUp("ACTIVITIES_TEST", 144)
end

E:RegisterOptions("activities", {
	enabled = true,
	anchor = 1,
	dnd = false,
	sfx = true,
	vfx = true,
}, {
	name = L["TYPE_ACTIVITIES"],
	get = function(info)
		return C.db.profile.types.activities[info[#info]]
	end,
	set = function(info, value)
		C.db.profile.types.activities[info[#info]] = value
	end,
	args = {
		enabled = {
			order = 1,
			type = "toggle",
			name = L["ENABLE"],
			set = function(_, value)
				C.db.profile.types.activities.enabled = value

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
		vfx = {
			order = 4,
			type = "toggle",
			name = L["VFX"],
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

E:RegisterSystem("activities", Enable, Disable, Test)
