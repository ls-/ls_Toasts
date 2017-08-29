local addonName, addonTable = ...
local E, L, C, D = addonTable.E, addonTable.L, addonTable.C, addonTable.D

-- Lua
local _G = getfenv(0)
local hooksecurefunc = _G.hooksecurefunc
local next = _G.next
local tonumber = _G.tonumber
local type = _G.type

-- Blizz
local CreateFrame = _G.CreateFrame
local GetAddOnMetadata = _G.GetAddOnMetadata
local InCombatLockdown = _G.InCombatLockdown
local InterfaceOptions_AddCategory = _G.InterfaceOptions_AddCategory
local InterfaceOptionsFrame_Show = _G.InterfaceOptionsFrame_Show

-- Mine
local LibStub = _G.LibStub
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

E:RegisterEvent("ADDON_LOADED", function(arg1)
	if arg1 ~= addonName then
		return
	end

	local function CopyTable(src, dest)
		if type(dest) ~= "table" then
			dest = {}
		end

		for k, v in next, src do
			if type(v) == "table" then
				dest[k] = CopyTable(v, dest[k])
			else
				dest[k] = v
			end
		end

		return dest
	end

	local function UpdateAll()
		E:UpdateDB()
		E:DisableAllSystems()
		E:EnableAllSystems()
	end

	C.db = LibStub("AceDB-3.0"):New("LS_TOASTS_GLOBAL_CONFIG", D, true)
	C.db:RegisterCallback("OnProfileChanged", UpdateAll)
	C.db:RegisterCallback("OnProfileCopied", UpdateAll)
	C.db:RegisterCallback("OnProfileReset", UpdateAll)

	C.db:RegisterCallback("OnProfileShutdown", function()
		C.db.profile.version = VER
	end)

	C.db:RegisterCallback("OnDatabaseShutdown", function()
		C.db.profile.version = VER
	end)

	-- converter
	local profile = C.db:GetCurrentProfile()

	if LS_TOASTS_CFG_GLOBAL then
		for name, data in next, LS_TOASTS_CFG_GLOBAL do
			if type(data) == "table" then
				if data.sfx_enabled ~= nil then
					data.sfx = {
						enabled = data.sfx_enabled
					}
					data.sfx_enabled = nil
				end

				if data.colored_names_enabled ~= nil then
					data.colors = {
						enabled = data.colored_names_enabled
					}

					data.colored_names_enabled = nil
				end

				if data.type then
					data.types = data.type
					data.type = nil
				end

				-- Do not convert point
				data.point = nil
				data.version = nil

				-- Ignore stuff from REALLY old configs
				data.achievement_enabled = nil
				data.archaeology_enabled = nil
				data.garrison_6_0_enabled = nil
				data.garrison_7_0_enabled = nil
				data.instance_enabled = nil
				data.loot_common_enabled = nil
				data.loot_common_quality_threshold = nil
				data.loot_currency_enabled = nil
				data.loot_special_enabled = nil
				data.recipe_enabled = nil
				data.transmog_enabled = nil
				data.world_enabled = nil
				data.dnd = nil

				if name == profile then
					CopyTable(data, C.db.profile)
				else
					if not LS_TOASTS_GLOBAL_CONFIG.profiles then
						LS_TOASTS_GLOBAL_CONFIG.profiles = {}
					elseif not LS_TOASTS_GLOBAL_CONFIG.profiles[name] then
						LS_TOASTS_GLOBAL_CONFIG.profiles[name] = {}
					end

					CopyTable(data, LS_TOASTS_GLOBAL_CONFIG.profiles[name])
				end
			end

			LS_TOASTS_CFG_GLOBAL[name] = nil
		end

		LS_TOASTS_CFG_GLOBAL = nil
	end

	-- cleanup
	LS_TOASTS_CFG = nil

	-- jic old stuff was accidentally copied
	if LS_TOASTS_GLOBAL_CONFIG and LS_TOASTS_GLOBAL_CONFIG.profiles then
		for _, data in next, LS_TOASTS_GLOBAL_CONFIG.profiles do
			data.achievement_enabled = nil
			data.archaeology_enabled = nil
			data.garrison_6_0_enabled = nil
			data.garrison_7_0_enabled = nil
			data.instance_enabled = nil
			data.loot_common_enabled = nil
			data.loot_common_quality_threshold = nil
			data.loot_currency_enabled = nil
			data.loot_special_enabled = nil
			data.recipe_enabled = nil
			data.transmog_enabled = nil
			data.world_enabled = nil
			data.dnd = nil
		end
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
					sfx = {
						order = 1,
						type = "toggle",
						name = L["ENABLE_SOUND"],
						get = function()
							return C.db.profile.sfx.enabled
						end,
						set = function(_, value)
							C.db.profile.sfx.enabled = value
						end
					},
					strata = {
						order = 2,
						type = "select",
						name = L["STRATA"],
						values = STRATAS,
						get = function()
							return STRATA_INDICES[C.db.profile.strata]
						end,
						set = function(_, value)
							value = STRATAS[value]
							C.db.profile.strata = value

							E:UpdateStrata(value)
						end,
					},
					skin = {
						order = 3,
						type = "select",
						name = L["SKIN"],
						values = E.GetAllSkins,
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

							E:UpdateScale(value)
						end,
					},
					delay = {
						order = 12,
						type = "range",
						name = L["FADE_OUT_DELAY"],
						min = 0.8, max = 6, step = 0.4,
						get = function()
							return C.db.profile.fadeout_delay
						end,
						set = function(_, value)
							C.db.profile.fadeout_delay = value

							E:UpdateFadeOutDelay(value)
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
						}
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
