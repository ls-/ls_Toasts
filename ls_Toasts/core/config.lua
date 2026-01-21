local addonName, addon = ...
local E, P, C, D, L = addon.E, addon.P, addon.C, addon.D, addon.L

-- Lua
local _G = getfenv(0)
local m_floor = _G.math.floor
local m_random = _G.math.random
local next = _G.next
local s_format = _G.string.format
local type = _G.type

-- Mine

-- move these elsehwere
local CL_LINK = "https://github.com/ls-/ls_Toasts/blob/master/CHANGELOG.md"
local CURSE_LINK = "https://www.curseforge.com/wow/addons/ls-toasts"
local DISCORD_LINK = "https://discord.gg/7QcJgQkDYD"
local GITHUB_LINK = "https://github.com/ls-/ls_Toasts"
local WAGO_LINK = "https://addons.wago.io/addons/ls-toasts"

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

local showLinkCopyPopup
do
	local function getStatusMessage()
		local num = m_random(1, 100)
		if num == 27 then
			return "The Cake is a Lie"
		else
			return L["LINK_COPY_SUCCESS"]
		end
	end

	local link = ""

	local popup = CreateFrame("Frame", nil, UIParent)
	popup:Hide()
	popup:SetPoint("CENTER", UIParent, "CENTER")
	popup:SetSize(384, 78)
	popup:EnableMouse(true)
	popup:SetFrameStrata("TOOLTIP")
	popup:SetFixedFrameStrata(true)
	popup:SetFrameLevel(100)
	popup:SetFixedFrameLevel(true)
	popup:EnableKeyboard(true)

	local border = CreateFrame("Frame", nil, popup, "DialogBorderTranslucentTemplate")
	border:SetAllPoints(popup)

	local editBox = CreateFrame("EditBox", nil, popup, "InputBoxTemplate")
	editBox:SetHeight(32)
	editBox:SetPoint("TOPLEFT", 22, -10)
	editBox:SetPoint("TOPRIGHT", -16, -10)
	editBox:EnableKeyboard(true)
	editBox:SetScript("OnChar", function(self)
		self:SetText(link)
		self:HighlightText()
	end)
	editBox:SetScript("OnMouseUp", function(self)
		self:HighlightText()
	end)
	editBox:SetScript("OnEscapePressed", function()
		popup:Hide()
	end)
	editBox:SetScript("OnEnterPressed", function()
		popup:Hide()
	end)
	editBox:SetScript("OnKeyUp", function(_, key)
		if IsControlKeyDown() and (key == "C" or key == "X") then
			ActionStatus:DisplayMessage(getStatusMessage())

			popup:Hide()
		end
	end)

	local button = CreateFrame("Button", nil, popup, "UIPanelButtonNoTooltipTemplate")
	button:SetText(_G.CLOSE)
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

do
	local header_proto = {}

	do
		function header_proto:OnHyperlinkClick(hyperlink)
			showLinkCopyPopup(hyperlink)
		end
	end

	local function createHeader(parent, text)
		local header = Mixin(CreateFrame("Frame", nil, parent, "InlineHyperlinkFrameTemplate"), header_proto)
		header:SetHeight(50)
		header:SetScript("OnHyperlinkClick", header.OnHyperlinkClick)

		local title = header:CreateFontString(nil, "ARTWORK", "GameFontHighlightHuge")
		title:SetPoint("TOPLEFT", 7, -22)
		title:SetText(text)

		local divider = header:CreateTexture(nil, "ARTWORK")
		divider:SetAtlas("Options_HorizontalDivider", true)
		divider:SetPoint("TOP", 0, -50)

		return header
	end

	local button_proto = {}

	do
		function button_proto:OnEnter()
			self.Icon:SetScale(1.1)

			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			GameTooltip:AddLine(self.tooltip)
			GameTooltip:Show()
		end

		function button_proto:OnLeave()
			self.Icon:SetScale(1)

			GameTooltip:Hide()
		end

		function button_proto:OnClick()
			showLinkCopyPopup(self.link)
		end
	end

	local container_proto = {
		numChildren = 0,
	}

	do
		function container_proto:AddButton(texture, tooltip, link)
			self.numChildren = self.numChildren + 1
			self.spacing = m_floor(580 / (self.numChildren + 1))

			local button = Mixin(CreateFrame("Button", nil, self), button_proto)
			button:SetSize(64, 64)
			button:SetScript("OnEnter", button.OnEnter)
			button:SetScript("OnLeave", button.OnLeave)
			button:SetScript("OnClick", button.OnClick)
			button.layoutIndex = self.numChildren

			local icon = button:CreateTexture(nil, "ARTWORK")
			icon:SetPoint("CENTER")
			icon:SetSize(48, 48)
			icon:SetTexture(texture)
			button.Icon = icon

			button.tooltip = tooltip
			button.link = link
		end
	end

	function addon:CreateBlizzConfig()
		local panel = CreateFrame("Frame", "LSToastsConfigPanel")
		panel:Hide()

		local versionText = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
		versionText:SetPoint("TOPRIGHT", -2, 4)
		versionText:SetTextColor(0.4, 0.4, 0.4)
		versionText:SetText(E.VER.string)

		-- UIPanelButtonTemplate
		local configButton = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
		configButton:SetText(_G.ADVANCED_OPTIONS)
		configButton:SetWidth(configButton:GetTextWidth() + 18)
		configButton:SetPoint("TOPRIGHT", -36, -16)
		configButton:SetScript("OnClick", function()
			addon:OpenAceConfig()
		end)

		local supportHeader = createHeader(panel, L["SUPPORT_FEEDBACK"])
		supportHeader:SetPoint("TOPLEFT")
		supportHeader:SetPoint("TOPRIGHT")

		local supportContainer = Mixin(CreateFrame("Frame", nil, panel, "HorizontalLayoutFrame"), container_proto)
		supportContainer:SetPoint("TOP", supportHeader, "BOTTOM", 0, -4)

		supportContainer:AddButton("Interface\\AddOns\\ls_Toasts\\assets\\discord-64", L["DISCORD"], DISCORD_LINK)
		supportContainer:AddButton("Interface\\AddOns\\ls_Toasts\\assets\\github-64", L["GITHUB"], GITHUB_LINK)

		local downloadHeader = createHeader(panel, L["DOWNLOADS"])
		downloadHeader:SetPoint("TOP", supportContainer, "BOTTOM", 0, 8)
		downloadHeader:SetPoint("LEFT")
		downloadHeader:SetPoint("RIGHT")

		local downloadContainer = Mixin(CreateFrame("Frame", nil, panel, "HorizontalLayoutFrame"), container_proto)
		downloadContainer:SetPoint("TOP", downloadHeader, "BOTTOM", 0, -4)

		-- downloadContainer:AddButton("Interface\\AddOns\\ls_Toasts\\assets\\mmoui-64", L["WOWINTERFACE"])
		downloadContainer:AddButton("Interface\\AddOns\\ls_Toasts\\assets\\curseforge-64", L["CURSEFORGE"], CURSE_LINK)
		downloadContainer:AddButton("Interface\\AddOns\\ls_Toasts\\assets\\wago-64", L["WAGO"], WAGO_LINK)

		local changelogHeader = createHeader(panel, s_format("%s |H%s|h[|c%s%s|r]|h",  L["CHANGELOG"], CL_LINK, D.global.colors.addon:GetHex(), L["CHANGELOG_FULL"]))
		changelogHeader:SetPoint("TOP", downloadContainer, "BOTTOM", 0, 8)
		changelogHeader:SetPoint("LEFT")
		changelogHeader:SetPoint("RIGHT")

		-- recreation of "ScrollingFontTemplate"
		local changelog = Mixin(CreateFrame("Frame", nil, panel), ScrollingFontMixin)
		changelog:SetPoint("TOPLEFT", changelogHeader, "BOTTOMLEFT", 6, -8)
		changelog:SetPoint("BOTTOMRIGHT", changelogHeader, "BOTTOMRIGHT", -38, -192)
		changelog:SetScript("OnSizeChanged", changelog.OnSizeChanged)
		changelog.fontName = "GameFontHighlight"

		local border = CreateFrame("Frame", nil, changelog, "FloatingBorderedFrame")
		border:SetPoint("TOPLEFT")
		border:SetPoint("BOTTOMRIGHT", 20, 0)
		border:SetUsingParentLevel(true)

		for _, region in next, {border:GetRegions()} do
			region:SetVertexColor(0, 0, 0, 0.3)
		end

		local scrollBox = CreateFrame("Frame", nil, changelog, "WowScrollBox")
		scrollBox:SetAllPoints()
		changelog.ScrollBox = scrollBox

		local fontStringContainer = CreateFrame("Frame", nil, scrollBox)
		fontStringContainer:SetHeight(1)
		fontStringContainer.scrollable = true
		scrollBox.FontStringContainer = fontStringContainer

		local fontString = fontStringContainer:CreateFontString(nil, "ARTWORK")
		fontString:SetPoint("TOPLEFT")
		fontString:SetNonSpaceWrap(true)
		fontString:SetJustifyH("LEFT")
		fontString:SetJustifyV("TOP")
		fontStringContainer.FontString = fontString

		local scrollBar = CreateFrame("EventFrame", nil, panel, "MinimalScrollBar")
		scrollBar:SetPoint("TOPLEFT", scrollBox, "TOPRIGHT", 6, 0)
		scrollBar:SetPoint("BOTTOMLEFT", scrollBox, "BOTTOMRIGHT", 6, -3)
		scrollBar:SetHideIfUnscrollable(true)
		changelog.ScrollBar = scrollBar

		ScrollUtil.RegisterScrollBoxWithScrollBar(scrollBox, scrollBar)

		changelog:OnLoad()
		changelog:SetText(E.CHANGELOG)

		supportContainer:MarkDirty()

		local category = Settings.RegisterCanvasLayoutCategory(panel, L["LS_TOASTS"])

		Settings.RegisterAddOnCategory(category)

		function addon:OpenBlizzConfig()
			Settings.OpenToCategory(category:GetID())
		end
	end
end


function addon:CreateAceConfig()
	C.options = {
		type = "group",
		name = s_format("%s |cffcacaca(%s)|r", L["LS_TOASTS"], E.VER.string),
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
						},
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
								end,
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
		},
	}

	LibStub("AceConfig-3.0"):RegisterOptionsTable(addonName, C.options)
	LibStub("AceConfigDialog-3.0"):SetDefaultSize(addonName, 1024, 768)

	C.options.args.profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(C.db, true)
	C.options.args.profiles.order = 100
	C.options.args.profiles.desc = nil

	function addon:OpenAceConfig()
		if not InCombatLockdown() then
			HideUIPanel(SettingsPanel)
		end

		LibStub("AceConfigDialog-3.0"):Open(addonName)
	end
end
