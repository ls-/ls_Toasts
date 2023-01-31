local addonName, addonTable = ...
local E, P, C, D, L = addonTable.E, addonTable.P, addonTable.C, addonTable.D, addonTable.L

-- Lua
local _G = getfenv(0)
local hooksecurefunc = _G.hooksecurefunc
local next = _G.next
local print = _G.print
local s_format = _G.string.format
local tonumber = _G.tonumber

--[[ luacheck: globals
	AlertFrame CreateFrame GetAddOnMetadata InCombatLockdown InterfaceOptions_AddCategory
	InterfaceOptionsFrame_Show InterfaceOptionsFramePanelContainer LibStub SlashCmdList

	ITEM_QUALITY_COLORS ITEM_QUALITY1_DESC ITEM_QUALITY2_DESC ITEM_QUALITY3_DESC ITEM_QUALITY4_DESC
	ITEM_QUALITY5_DESC LS_TOASTS_CFG LS_TOASTS_CFG_GLOBAL SLASH_LSTOASTS1 SLASH_LSTOASTS2
]]

-- Mine
E.VER = {}
E.VER.string = GetAddOnMetadata(addonName, "Version")
E.VER.number = tonumber(E.VER.string:gsub("%D", ""), nil)

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
	["CRITERIA_EARNED"] = true,
	["LOOT_ITEM_ROLL_WON"] = true,
	["NEW_RECIPE_LEARNED"] = true,
	["QUEST_TURNED_IN"] = true,
	["STORE_PRODUCT_DELIVERED"] = true,
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

local showLinkCopyPopup
do
	local link = ""

	local popup = CreateFrame("Frame", nil, UIParent)
	popup:Hide()
	popup:SetPoint("CENTER", UIParent, "CENTER")
	popup:SetSize(320, 78)
	popup:EnableMouse(true)
	popup:SetFrameStrata("TOOLTIP")
	popup:SetFixedFrameStrata(true)
	popup:SetFrameLevel(100)
	popup:SetFixedFrameLevel(true)

	local border = CreateFrame("Frame", nil, popup, "DialogBorderTranslucentTemplate")
	border:SetAllPoints(popup)

	local editBox = CreateFrame("EditBox", nil, popup, "InputBoxTemplate")
	editBox:SetHeight(32)
	editBox:SetPoint("TOPLEFT", 22, -10)
	editBox:SetPoint("TOPRIGHT", -16, -10)
	editBox:SetScript("OnChar", function(self)
		self:SetText(link)
		self:HighlightText()
	end)
	editBox:SetScript("OnMouseUp", function(self)
		self:HighlightText()
	end)
	editBox:SetScript("OnEscapePressed", function(self)
		popup:Hide()
	end)

	local button = CreateFrame("Button", nil, popup, "UIPanelButtonNoTooltipTemplate")
	button:SetText(L["OKAY"])
	button:SetSize(90, 22)
	button:SetPoint("BOTTOM", 0, 16)
	button:SetScript("OnClick", function()
		popup:Hide()
	end)

	popup:SetScript("OnHide", function()
		link = ""
		editBox:SetText(link)
	end)
	popup:SetScript("OnShow", function()
		editBox:SetText(link)
		editBox:SetFocus()
		editBox:HighlightText()
	end)

	function showLinkCopyPopup(text)
		popup:Hide()
		link = text
		popup:Show()
	end
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

	-- ->11302.02
	if C.db.profile.version and C.db.profile.version < 1130202 then
		C.db.profile.types.loot_common = nil
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
									[0] = ITEM_QUALITY_COLORS[0].hex .. ITEM_QUALITY0_DESC .. "|r",
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
			-- profiles = {}, -- 100
			about = {
				order = 110,
				type = "group",
				name = "|cff1a9fc0" .. L["INFORMATION"] .. "|r",
				args = {
					desc = {
						order = 1,
						type = "description",
						name = s_format("|cffffd200%s v|r%s", L["LS_TOASTS"], E.VER.string),
						width = "full",
						fontSize = "medium",
					},
					spacer_1 = {
						order = 2,
						type = "description",
						name = " ",
						width = "full",
					},
					support = {
						order = 3,
						type = "group",
						name = L["SUPPORT"],
						inline = true,
						args = {
							discord = {
								order = 1,
								type = "execute",
								name = L["DISCORD"],
								func = function()
									showLinkCopyPopup("https://discord.gg/7QcJgQkDYD")
								end,
							},
							github = {
								order = 2,
								type = "execute",
								name = L["GITHUB"],
								func = function()
									showLinkCopyPopup("https://github.com/ls-/ls_Toasts/issues")
								end,
							},
						},
					},
					spacer_2 = {
						order = 4,
						type = "description",
						name = " ",
						width = "full",
					},
					downloads = {
						order = 5,
						type = "group",
						name = L["DOWNLOADS"],
						inline = true,
						args = {
							-- wowi = {
							-- 	order = 1,
							-- 	type = "execute",
							-- 	name = L["WOWINTERFACE"],
							-- 	func = function()
							-- 		showLinkCopyPopup("https://www.wowinterface.com/downloads/info24123.html")
							-- 	end,
							-- },
							cf = {
								order = 2,
								type = "execute",
								name = L["CURSEFORGE"],
								func = function()
									showLinkCopyPopup("https://www.curseforge.com/wow/addons/ls-toasts")
								end,
							},
							wago = {
								order = 3,
								type = "execute",
								name = L["WAGO"],
								func = function()
									showLinkCopyPopup("https://addons.wago.io/addons/ls-toasts")
								end,
							},
						},
					},
					spacer_3 = {
						order = 6,
						type = "description",
						name = " ",
						width = "full",
					},
					CHANGELOG = {
						order = 7,
						type = "group",
						name = L["CHANGELOG"],
						inline = true,
						args = {
							latest = {
								order = 1,
								type = "description",
								name = E.CHANGELOG,
								width = "full",
								fontSize = "medium",
							},
							spacer_1 = {
								order = 2,
								type = "description",
								name = " ",
								width = "full",
							},
							cf = {
								order = 3,
								type = "execute",
								name = L["CHANGELOG_FULL"],
								func = function()
									showLinkCopyPopup("https://github.com/ls-/ls_Toasts/blob/wotlk/master/CHANGELOG.md")
								end,
							},
						},
					},
				},
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
		P:UpdateAnchors()
		P:UpdateDB()
		P:UpdateOptions()
		P:EnableAllSystems()

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
