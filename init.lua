local addonName, addonTable = ...
local E, P, C, D, L = addonTable.E, addonTable.P, addonTable.C, addonTable.D, addonTable.L

-- Lua
local _G = getfenv(0)
local hooksecurefunc = _G.hooksecurefunc
local next = _G.next
local print = _G.print
local tonumber = _G.tonumber

--[[ luacheck: globals
	AlertFrame CreateFrame GetAddOnMetadata InCombatLockdown InterfaceOptions_AddCategory
	InterfaceOptionsFrame_Show InterfaceOptionsFramePanelContainer SlashCmdList

	ITEM_QUALITY_COLORS ITEM_QUALITY1_DESC ITEM_QUALITY2_DESC ITEM_QUALITY3_DESC ITEM_QUALITY4_DESC
	ITEM_QUALITY5_DESC LS_TOASTS_CFG LS_TOASTS_CFG_GLOBAL SLASH_LSTOASTS1 SLASH_LSTOASTS2
]]

-- Mine
E.VER = tonumber(GetAddOnMetadata(addonName, "Version"):gsub("%D", ""), nil)

local STRATAS = {
	[1] = "BACKGROUND",
	[2] = "LOW",
	[3] = "MEDIUM",
	[4] = "HIGH",
	[5] = "DIALOG",
}

local STRATA_INDICES ={
	["BACKGROUND"] = 1,
	["LOW"] = 2,
	["MEDIUM"] = 3,
	["HIGH"] = 4,
	["DIALOG"] = 5,
}

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
	["NEW_TOY_ADDED"] = true,
	["QUEST_LOOT_RECEIVED"] = true,
	["QUEST_TURNED_IN"] = true,
	["RAF_ENTITLEMENT_DELIVERED"] = true,
	["SCENARIO_COMPLETED"] = true,
	["SHOW_LOOT_TOAST"] = true,
	["SHOW_LOOT_TOAST_LEGENDARY_LOOTED"] = true,
	["SHOW_LOOT_TOAST_UPGRADE"] = true,
	["SHOW_PVP_FACTION_LOOT_TOAST"] = true,
	["SHOW_RATED_PVP_REWARD_TOAST"] = true,
}

local function updateCallback()
	P:UpdateAnchors()
	P:UpdateDB()
	P:FlushQueue()
	P:DisableAllSystems()
	P:EnableAllSystems()
end

local function shutdownCallback()
	C.db.profile.version = E.VER
end

E:RegisterEvent("ADDON_LOADED", function(arg1)
	if arg1 ~= addonName then
		return
	end

	C.db = LibStub("AceDB-3.0"):New("LS_TOASTS_GLOBAL_CONFIG", D, true)
	C.db:RegisterCallback("OnProfileChanged", updateCallback)
	C.db:RegisterCallback("OnProfileCopied", updateCallback)
	C.db:RegisterCallback("OnProfileReset", updateCallback)
	C.db:RegisterCallback("OnProfileShutdown", shutdownCallback)
	C.db:RegisterCallback("OnDatabaseShutdown", shutdownCallback)

	-- cleanup
	LS_TOASTS_CFG = nil
	LS_TOASTS_CFG_GLOBAL = nil

	-- ->80100.03
	if not C.db.profile.version or C.db.profile.version < 8010003 then
		if C.db.profile.fadeout_delay then
			C.db.profile.anchors[1].fadeout_delay = C.db.profile.fadeout_delay
			C.db.profile.fadeout_delay = nil
		end

		if C.db.profile.growth_direction then
			C.db.profile.anchors[1].growth_direction = C.db.profile.growth_direction
			C.db.profile.growth_direction = nil
		end

		if C.db.profile.max_active_toasts then
			C.db.profile.anchors[1].max_active_toasts = C.db.profile.max_active_toasts
			C.db.profile.max_active_toasts = nil
		end

		if C.db.profile.scale then
			C.db.profile.anchors[1].scale = C.db.profile.scale
			C.db.profile.scale = nil
		end

		if C.db.profile.point then
			C.db.profile.anchors[1].point.p = C.db.profile.point.p
			C.db.profile.anchors[1].point.rP = C.db.profile.point.rP
			C.db.profile.anchors[1].point.x = C.db.profile.point.x
			C.db.profile.anchors[1].point.y = C.db.profile.point.y
			C.db.profile.point = nil
		end
	end

	-- ->80100.05
	if not C.db.profile.version or C.db.profile.version < 8010005 then
		C.db.profile.point = nil
	end

	C.options = {
		type = "group",
		name = L["LS_TOASTS"],
		args = {
			toggle_anchors = {
				order = 1,
				type = "execute",
				name = L["TOGGLE_ANCHORS"],
				func = P.ToggleAnchors,
			},
			test_all = {
				order = 2,
				type = "execute",
				name = L["TEST_ALL"],
				func = P.TestAllSystems,
			},
			flush_queue = {
				order = 3,
				type = "execute",
				name = L["FLUSH_QUEUE"],
				func = function() P:FlushQueue() end,
			},
			general = {
				order = 10,
				type = "group",
				name = L["GENERAL"],
				args = {
					strata = {
						order = 1,
						type = "select",
						name = L["STRATA"],
						values = STRATAS,
						get = function()
							return STRATA_INDICES[C.db.profile.strata]
						end,
						set = function(_, value)
							value = STRATAS[value]
							C.db.profile.strata = value

							P:UpdateStrata()
						end,
					},
					skin = {
						order = 2,
						type = "select",
						name = L["SKIN"],
						values = P.GetSkinList,
						get = function()
							return C.db.profile.skin
						end,
						set = function(_, value)
							C.db.profile.skin = value

							P:UpdateSkin()
						end,
					},
					spacer1 = {
						order = 9,
						type = "description",
						name = "",
					},
					colors = {
						order = 20,
						type = "group",
						guiInline = true,
						name = L["COLORS"],
						get = function(info)
							return C.db.profile.colors[info[#info]]
						end,
						set = function(info, value)
							C.db.profile.colors[info[#info]] = value
						end,
						args = {
							name = {
								order = 1,
								type = "toggle",
								name = L["NAME"],
							},
							border = {
								order = 2,
								type = "toggle",
								name = L["BORDER"],
							},
							icon_border = {
								order = 3,
								type = "toggle",
								name = L["ICON_BORDER"],
							},
							threshold = {
								order = 4,
								type = "select",
								name = L["RARITY_THRESHOLD"],
								values = {
									[1] = ITEM_QUALITY_COLORS[1].hex .. ITEM_QUALITY1_DESC .. "|r",
									[2] = ITEM_QUALITY_COLORS[2].hex .. ITEM_QUALITY2_DESC .. "|r",
									[3] = ITEM_QUALITY_COLORS[3].hex .. ITEM_QUALITY3_DESC .. "|r",
									[4] = ITEM_QUALITY_COLORS[4].hex .. ITEM_QUALITY4_DESC .. "|r",
									[5] = ITEM_QUALITY_COLORS[5].hex .. ITEM_QUALITY5_DESC .. "|r",
								},
							},
						}
					},
					font = {
						order = 21,
						type = "group",
						guiInline = true,
						name = L["FONTS"],
						args = {
							name = {
								order = 1,
								type = "select",
								name = L["NAME"],
								dialogControl = "LSM30_Font",
								values = LibStub("LibSharedMedia-3.0"):HashTable("font"),
								get = function()
									return LibStub("LibSharedMedia-3.0"):IsValid("font", C.db.profile.font.name) and C.db.profile.font.name or LibStub("LibSharedMedia-3.0"):GetDefault("font")
								end,
								set = function(_, value)
									C.db.profile.font.name = value

									P:UpdateFont()
								end
							},
							size = {
								order = 2,
								type = "range",
								name = L["SIZE"],
								min = 10, max = 20, step = 1,
								get = function()
									return C.db.profile.font.size
								end,
								set = function(_, value)
									C.db.profile.font.size = value

									P:UpdateFont()
								end,
							},
						},
					},
				},
			},
			anchors = {
				order = 20,
				type = "group",
				name = L["ANCHOR_FRAMES"],
				args = {
					add = {
						order = 1,
						name = L["ADD"],
						type = "execute",
						width = "full",
						func = function()
							local index = #C.db.profile.anchors + 1
							P:AddAnchor(index)
							P:GetAnchor(index):Refresh()
							P:UpdateAnchorsOptions()
						end,
					},
					spacer_1 = {
						order = 2,
						type = "description",
						name = " ",
					},
				},
			},
			types = {
				order = 30,
				type = "group",
				name = L["TOAST_TYPES"],
				childGroups = "tab",
				args = {},
			},
		},
	}

	LibStub("AceConfig-3.0"):RegisterOptionsTable(addonName, C.options)
	LibStub("AceConfigDialog-3.0"):SetDefaultSize(addonName, 1024, 768)

	C.options.args.profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(C.db, true)
	C.options.args.profiles.order = 100
	C.options.args.profiles.desc = nil

	for event in next, BLACKLISTED_EVENTS do
		P:Call(AlertFrame.UnregisterEvent, AlertFrame, event)
	end

	hooksecurefunc(AlertFrame, "RegisterEvent", function(self, event)
		if event and BLACKLISTED_EVENTS[event] then
			P:Call(self.UnregisterEvent, self, event)
		end
	end)

	E:RegisterEvent("PLAYER_LOGIN", function()
		P:UpdateAnchors()
		P:UpdateDB()
		P:UpdateOptions()
		P:EnableAllSystems()

		local panel = CreateFrame("Frame", "LSTConfigPanel", InterfaceOptionsFramePanelContainer)
		panel.name = L["LS_TOASTS"]
		panel:Hide()

		local button = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
		button:SetText(L["OPEN_CONFIG"])
		button:SetWidth(button:GetTextWidth() + 18)
		button:SetPoint("TOPLEFT", 16, -16)
		button:SetScript("OnClick", function()
			if not InCombatLockdown() then
				InterfaceOptionsFrame_Show()

				LibStub("AceConfigDialog-3.0"):Open(addonName)
			end
		end)

		InterfaceOptions_AddCategory(panel, true)

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
