local _, addonTable = ...
local E, L, C = addonTable.E, addonTable.L, addonTable.C

-- Lua
local _G = getfenv(0)
local hooksecurefunc = _G.hooksecurefunc

-- Mine
local function Toast_SetUp(event, researchFieldID)
	local toast = E:GetToast()
	local raceName, raceTexture = GetArchaeologyRaceInfoByID(researchFieldID)

	if C.db.profile.colors.border then
		toast.Border:SetVertexColor(0.9, 0.4, 0.1)
	end

	toast:SetBackground("archaeology")
	toast.Title:SetText(L["DIGSITE_COMPLETED"])
	toast.Text:SetText(raceName)
	toast.Icon:SetPoint("TOPLEFT", 1, 3)
	toast.Icon:SetSize(40, 48)
	toast.Icon:SetTexture(raceTexture)
	toast.Icon:SetTexCoord(0 / 128, 74 / 128, 0 / 128, 88 / 128)

	toast._data = {
		event = event,
	}

	if C.db.profile.types.archaeology.sfx then
		toast._data.sound_file = 38326 -- SOUNDKIT.UI_DIG_SITE_COMPLETION_TOAST
	end

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
	Toast_SetUp("ARCHAEOLOGY_TEST", 2)
end

E:RegisterOptions("archaeology", {
	enabled = true,
	dnd = false,
	sfx = true,
}, {
	name = L["TYPE_ARCHAEOLOGY"],
	get = function(info)
		return C.db.profile.types.archaeology[info[#info]]
	end,
	set = function(info, value)
		C.db.profile.types.archaeology[info[#info]] = value
	end,
	args = {
		enabled = {
			order = 1,
			type = "toggle",
			name = L["ENABLE"],
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

E:RegisterSystem("archaeology", Enable, Disable, Test)
