local addonName, addonTable = ...
local E, L, C, D = addonTable.E, addonTable.L, addonTable.C, addonTable.D

-- Lua
local _G = getfenv(0)
local hooksecurefunc = _G.hooksecurefunc
local next = _G.next
local tonumber = _G.tonumber

-- Mine
local VER = tonumber(GetAddOnMetadata(addonName, "Version"):gsub("%D", ""), nil)

local STRATAS = {
	[1] = "BACKGROUND",
	[2] = "LOW",
	[3] = "MEDIUM",
	[4] = "HIGH",
	[5] = "DIALOG",
}

local STRATA_INDICES ={
	BACKGROUND = 1,
	LOW = 2,
	MEDIUM = 3,
	HIGH = 4,
	DIALOG = 5,
}

local BLACKLISTED_EVENTS = {
	ACHIEVEMENT_EARNED = true,
	AZERITE_EMPOWERED_ITEM_LOOTED = true,
	CRITERIA_EARNED = true,
	GARRISON_BUILDING_ACTIVATABLE = true,
	GARRISON_FOLLOWER_ADDED = true,
	GARRISON_MISSION_FINISHED = true,
	GARRISON_RANDOM_MISSION_ADDED = true,
	GARRISON_TALENT_COMPLETE = true,
	LFG_COMPLETION_REWARD = true,
	LOOT_ITEM_ROLL_WON = true,
	NEW_MOUNT_ADDED = true,
	NEW_PET_ADDED = true,
	NEW_RECIPE_LEARNED = true,
	QUEST_LOOT_RECEIVED = true,
	QUEST_TURNED_IN = true,
	SCENARIO_COMPLETED = true,
	SHOW_LOOT_TOAST = true,
	SHOW_LOOT_TOAST_LEGENDARY_LOOTED = true,
	SHOW_LOOT_TOAST_UPGRADE = true,
	SHOW_PVP_FACTION_LOOT_TOAST = true,
	SHOW_RATED_PVP_REWARD_TOAST = true,
	STORE_PRODUCT_DELIVERED = true,
	TOYS_UPDATED = true,
}

local function updateCallback()
	E:UpdateDB()
	E:DisableAllSystems()
	E:EnableAllSystems()
end

local function shutdownCallback()
	C.db.profile.version = VER
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

	-- ->70300.07
	if not C.db.profile.version or C.db.profile.version < 7030007 then
		C.db.profile.sfx = nil
	end

	C.options = {
		type = "group",
		name = L["LS_TOASTS"],
		disabled = function() return InCombatLockdown() end,
		args = {
			toggle_anchors = {
				order = 1,
				type = "execute",
				name = L["ANCHOR_FRAME"],
				func = function() E:GetAnchorFrame():Toggle() end,
			},
			test_all = {
				order = 2,
				type = "execute",
				name = L["TEST_ALL"],
				func = function() E:TestAllSystems() end,
			},
			general = {
				order = 3,
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

							E:UpdateStrata()
						end,
					},
					skin = {
						order = 2,
						type = "select",
						name = L["SKIN"],
						values = E.GetSkinList,
						get = function()
							return C.db.profile.skin
						end,
						set = function(_, value)
							E:SetSkin(value)
						end,
					},
					spacer1 = {
						order = 9,
						type = "description",
						name = "",
					},
					num = {
						order = 10,
						type = "range",
						name = L["TOAST_NUM"],
						min = 1, max = 20, step = 1,
						get = function()
							return C.db.profile.max_active_toasts
						end,
						set = function(_, value)
							C.db.profile.max_active_toasts = value
						end,
					},
					scale = {
						order = 11,
						type = "range",
						name = L["SCALE"],
						min = 0.8, max = 2, step = 0.1,
						get = function()
							return C.db.profile.scale
						end,
						set = function(_, value)
							C.db.profile.scale = value

							E:UpdateScale()
						end,
					},
					delay = {
						order = 12,
						type = "range",
						name = L["FADE_OUT_DELAY"],
						min = 0.8, max = 10, step = 0.4,
						get = function()
							return C.db.profile.fadeout_delay
						end,
						set = function(_, value)
							C.db.profile.fadeout_delay = value

							E:UpdateFadeOutDelay()
						end,
					},
					growth_dir = {
						order = 13,
						type = "select",
						name = L["GROWTH_DIR"],
						values = {
							UP = L["GROWTH_DIR_UP"],
							DOWN = L["GROWTH_DIR_DOWN"],
							LEFT = L["GROWTH_DIR_LEFT"],
							RIGHT = L["GROWTH_DIR_RIGHT"],
						},
						get = function()
							return C.db.profile.growth_direction
						end,
						set = function(_, value)
							C.db.profile.growth_direction = value

							E:RefreshQueue()
						end,
					},
					colors = {
						order = 20,
						type = "group",
						guiInline = true,
						name = L["COLORS"],
						args = {
							name = {
								order = 1,
								type = "toggle",
								name = L["NAME"],
								get = function()
									return C.db.profile.colors.name
								end,
								set = function(_, value)
									C.db.profile.colors.name = value
								end
							},
							border = {
								order = 2,
								type = "toggle",
								name = L["BORDER"],
								get = function()
									return C.db.profile.colors.border
								end,
								set = function(_, value)
									C.db.profile.colors.border = value
								end
							},
							icon_border = {
								order = 3,
								type = "toggle",
								name = L["ICON_BORDER"],
								get = function()
									return C.db.profile.colors.icon_border
								end,
								set = function(_, value)
									C.db.profile.colors.icon_border = value
								end
							},
							threshold = {
								order = 4,
								type = "select",
								name = L["RARITY_THRESHOLD"],
								values = {
									[1] = ITEM_QUALITY_COLORS[1].hex..ITEM_QUALITY1_DESC.."|r",
									[2] = ITEM_QUALITY_COLORS[2].hex..ITEM_QUALITY2_DESC.."|r",
									[3] = ITEM_QUALITY_COLORS[3].hex..ITEM_QUALITY3_DESC.."|r",
									[4] = ITEM_QUALITY_COLORS[4].hex..ITEM_QUALITY4_DESC.."|r",
									[5] = ITEM_QUALITY_COLORS[5].hex..ITEM_QUALITY5_DESC.."|r",
								},
								get = function()
									return C.db.profile.colors.threshold
								end,
								set = function(_, value)
									C.db.profile.colors.threshold = value
								end,
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
								values = AceGUIWidgetLSMlists.font,
								get = function()
									return LibStub("LibSharedMedia-3.0"):IsValid("font", C.db.profile.font.name) and C.db.profile.font.name or LibStub("LibSharedMedia-3.0"):GetDefault("font")
								end,
								set = function(_, value)
									C.db.profile.font.name = value

									E:UpdateFont()
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

									E:UpdateFont()
								end,
							},
						},
					},
				},
			},
			types = {
				order = 4,
				type = "group",
				name = L["SETTINGS_TYPE_LABEL"],
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
		AlertFrame:UnregisterEvent(event)
	end

	hooksecurefunc(AlertFrame, "RegisterEvent", function(self, event)
		if event and BLACKLISTED_EVENTS[event] then
			self:UnregisterEvent(event)
		end
	end)

	E:RegisterEvent("PLAYER_LOGIN", function()
		E:UpdateDB()
		E:UpdateOptions()
		E:GetAnchorFrame():Refresh()
		E:EnableAllSystems()
		E:CheckResetDefaultSkin()

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

		SLASH_LSTOASTS1 = "/lstoasts"
		SLASH_LSTOASTS2 = "/lst"
		SlashCmdList["LSTOASTS"] = function(msg)
			if msg == "" then
				if not InCombatLockdown() then
					LibStub("AceConfigDialog-3.0"):Open(addonName)
				end
			elseif msg == "test" then
				E:TestAllSystems()
			end
		end
	end)
end)
