local _, addonTable = ...
local E, L, C = addonTable.E, addonTable.L, addonTable.C

-- Lua
local _G = getfenv(0)
local hooksecurefunc = _G.hooksecurefunc

-- Blizz
local GetArchaeologyRaceInfoByID = _G.GetArchaeologyRaceInfoByID

-- Mine
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
