local addonName, addonTable = ...
local E, P, C, D, L = addonTable.E, addonTable.P, addonTable.C, addonTable.D, addonTable.L

-- Lua
local _G = getfenv(0)
local hooksecurefunc = _G.hooksecurefunc
local next = _G.next
local print = _G.print
local tonumber = _G.tonumber

-- Mine
E.VER = {}
E.VER.string = C_AddOns.GetAddOnMetadata(addonName, "Version")
E.VER.number = tonumber(E.VER.string:gsub("%D", ""), nil)

local BLACKLISTED_EVENTS = {
	["ACHIEVEMENT_EARNED"] = true,
	["AZERITE_EMPOWERED_ITEM_LOOTED"] = true,
	["CRITERIA_EARNED"] = true,
	["ENTITLEMENT_DELIVERED"] = true,
	["GARRISON_BUILDING_ACTIVATABLE"] = true,
	["GARRISON_FOLLOWER_ADDED"] = true,
	["GARRISON_MISSION_FINISHED"] = true,
	["GARRISON_RANDOM_MISSION_ADDED"] = true,
	["GARRISON_TALENT_COMPLETE"] = true,
	["LFG_COMPLETION_REWARD"] = true,
	["LOOT_ITEM_ROLL_WON"] = true,
	["NEW_MOUNT_ADDED"] = true,
	["NEW_PET_ADDED"] = true,
	["NEW_RECIPE_LEARNED"] = true,
	["NEW_RUNEFORGE_POWER_ADDED"] = true,
	["NEW_TOY_ADDED"] = true,
	["NEW_WARBAND_SCENE_ADDED"] = true,
	["PERKS_ACTIVITY_COMPLETED"] = true,
	["PERKS_PROGRAM_CURRENCY_AWARDED"] = true,
	["QUEST_LOOT_RECEIVED"] = true,
	["QUEST_TURNED_IN"] = true,
	["RAF_ENTITLEMENT_DELIVERED"] = true,
	["REQUESTED_GUILD_RENAME_RESULT"] = true,
	["SCENARIO_COMPLETED"] = true,
	["SHOW_LOOT_TOAST"] = true,
	["SHOW_LOOT_TOAST_LEGENDARY_LOOTED"] = true,
	["SHOW_LOOT_TOAST_UPGRADE"] = true,
	["SHOW_PVP_FACTION_LOOT_TOAST"] = true,
	["SHOW_RATED_PVP_REWARD_TOAST"] = true,
	["SKILL_LINE_SPECS_UNLOCKED"] = true,
	["TRANSMOG_COLLECTION_SOURCE_ADDED"] = true,
	["TRANSMOG_COSMETIC_COLLECTION_SOURCE_ADDED"] = true,
}

local function updateCallback()
	P:UpdateAnchors()
	P:UpdateDB()
	P:FlushQueue()
	P:DisableAllSystems()
	P:EnableAllSystems()
end

local function shutdownCallback()
	C.db.profile.version = E.VER.number
end

E:RegisterEvent("ADDON_LOADED", function(arg1)
	if arg1 ~= addonName then return end

	-- very old, but keep it jic
	LS_TOASTS_CFG = nil
	LS_TOASTS_CFG_GLOBAL = nil

	if LS_TOASTS_GLOBAL_CONFIG then
		if LS_TOASTS_GLOBAL_CONFIG.profiles then
			for profile, data in next, LS_TOASTS_GLOBAL_CONFIG.profiles do
				P:Modernize(data, profile, "profile")
			end
		end
	end

	C.db = LibStub("AceDB-3.0"):New("LS_TOASTS_GLOBAL_CONFIG", D, true)
	C.db:RegisterCallback("OnProfileChanged", updateCallback)
	C.db:RegisterCallback("OnProfileCopied", updateCallback)
	C.db:RegisterCallback("OnProfileReset", updateCallback)
	C.db:RegisterCallback("OnProfileShutdown", shutdownCallback)
	C.db:RegisterCallback("OnDatabaseShutdown", shutdownCallback)

	for event in next, BLACKLISTED_EVENTS do
		P:Call(AlertFrame.UnregisterEvent, AlertFrame, event)
	end

	hooksecurefunc(AlertFrame, "RegisterEvent", function(self, event)
		if event and BLACKLISTED_EVENTS[event] then
			P:Call(self.UnregisterEvent, self, event)
		end
	end)

	E:RegisterEvent("PLAYER_LOGIN", function()
		P:CreateConfig()
		P:UpdateAnchors()
		P:UpdateDB()
		P:UpdateOptions()
		P:EnableAllSystems()

		local panel = CreateFrame("Frame", "LSTConfigPanel")
		panel:Hide()

		local button = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
		button:SetText(L["OPEN_CONFIG"])
		button:SetWidth(button:GetTextWidth() + 18)
		button:SetPoint("TOPLEFT", 16, -16)
		button:SetScript("OnClick", function()
			if not InCombatLockdown() then
				HideUIPanel(SettingsPanel)

				LibStub("AceConfigDialog-3.0"):Open(addonName)
			end
		end)

		Settings.RegisterAddOnCategory(Settings.RegisterCanvasLayoutCategory(panel, L["LS_TOASTS"]))

		AddonCompartmentFrame:RegisterAddon({
			text = L["LS_TOASTS"],
			icon = "Interface\\AddOns\\ls_Toasts\\assets\\logo-32",
			func = function()
				if not InCombatLockdown() then
					LibStub("AceConfigDialog-3.0"):Open(addonName)
				end
			end,
		})

		E:RegisterEvent("PLAYER_REGEN_DISABLED", function()
			LibStub("AceConfigDialog-3.0"):Close(addonName)
		end)

		SLASH_LSTOASTS1 = "/lstoasts"
		SLASH_LSTOASTS2 = "/lst"
		SlashCmdList["LSTOASTS"] = function(msg)
			if msg == "" then
				if not InCombatLockdown() then
					LibStub("AceConfigDialog-3.0"):Open(addonName)
				end
			elseif msg == "test" then
				P:TestAllSystems()
			elseif msg == "flush" then
				P:FlushQueue()
			elseif msg == "dump" then
				print("|cffdc4436Queued Toasts|r:")
				for anchorID, queued in next, P:GetQueuedToasts() do
					print("  |cff2eac34Anchor Frame|r:", anchorID)
					for _, toast in next, queued do
						print("    |cff267dce" .. toast:GetDebugName() .. "|r:")
						for k, v in next, toast._data do
							print("      |cfff6c442" .. k .. "|r:", v)
						end
					end
				end

				print("|cffdc4436Active Toasts|r:")
				for anchorID, active in next, P:GetActiveToasts() do
					print("  |cff2eac34Anchor Frame|r:", anchorID)
					for _, toast in next, active do
						print("    |cff267dce" .. toast:GetDebugName() .. "|r:")
						for k, v in next, toast._data do
							print("      |cfff6c442" .. k .. "|r:", v)
						end
					end
				end
			end
		end
	end)
end)
