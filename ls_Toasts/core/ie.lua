local addonName, addon = ...
local C, D, L = addon.C, addon.D, addon.L

-- Lua
local _G = getfenv(0)
local next = _G.next
local s_lower = _G.string.lower
local s_trim = _G.string.trim
local t_insert = _G.table.insert
local tonumber = _G.tonumber
local type = _G.type

-- Mine
do
	local PREFIX = s_lower(addonName:gsub("_", ""))
	local IMPORT_PATTERN = "^" .. PREFIX .. ":(%w+):(%d+):(.+)::$"

	function addon:Export(dataType)
		if not dataType or type(dataType) ~= "string" then return end

		local data = {}
		if dataType == "profile" then
			addon:CopyTable(C.db.profile, data)

			data.version = nil

			addon:DiffTable(data, D.profile)
		end

		if not next(data) then return end

		local serialized = C_EncodingUtil.SerializeCBOR(data)
		if not serialized then return end

		local compressed = C_EncodingUtil.CompressString(serialized, Enum.CompressionMethod.Deflate)
		if not compressed then return end

		local encoded = C_EncodingUtil.EncodeBase64(compressed)
		if not encoded then return end

		return PREFIX .. ":" .. dataType .. ":" .. addon.VER.number .. ":" .. encoded .. "::"
	end

	function addon:Import(data, isNew, newName)
		local dataType, version, encoded = data:match(IMPORT_PATTERN)
		if not (dataType or version or encoded) then return end

		local decoded = C_EncodingUtil.DecodeBase64(encoded)
		if not decoded then return end

		local decompressed = C_EncodingUtil.DecompressString(decoded, Enum.CompressionMethod.Deflate)
		if not decompressed then return end

		data = C_EncodingUtil.DeserializeCBOR(decompressed)

		data.version = tonumber(version)
		if data.version < addon.VER.number then
			addon:Modernize(data, "Imported Data", dataType)

			data.version = addon.VER.number
		end

		if dataType == "profile" then
			if not isNew then
				C.db:DeleteProfile("TEMP_PROFILE", true)

				C.db.profiles["TEMP_PROFILE"] = data

				C.db:CopyProfile("TEMP_PROFILE")
				C.db:DeleteProfile("TEMP_PROFILE")
			elseif newName then
				C.db.profiles[newName] = data
			end

			return true, data
		end
	end
end

do
	local function displayActionStatusMessage(message)
		if ActionStatus_DisplayMessage then
			ActionStatus_DisplayMessage(message, true)
		else
			ActionStatus:DisplayMessage(message)
		end
	end

	function addon:CreateImportExport()
		local frame = CreateFrame("Frame", "LSToastsImportExport", UIParent, "DefaultPanelTemplate")
		frame:SetSize(384, 320)
		frame:SetPoint("CENTER", 0, 0)
		frame:SetFlattensRenderLayers(true)
		frame:SetFrameStrata("TOOLTIP")
		frame:SetTitle(L["ADDON_NAME"])
		frame:SetMovable(true)
		frame:EnableMouse(true)
		frame:RegisterForDrag("LeftButton")
		frame:SetScript("OnDragStart", frame.StartMoving)
		frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
		frame:Hide()

		t_insert(UISpecialFrames, frame:GetName())

		local closeButton = CreateFrame("Button", nil, frame, "UIPanelCloseButtonDefaultAnchors")
		frame.CloseButton = closeButton

		frame.Panels = {}
		frame.Tabs = {}

		-- import
		do
			local BAD_ICON = "common-icon-redx"
			local CLASH_ICON = "common-icon-checkmark-yellow"
			local NEW_ICON = "common-icon-checkmark"

			local cachedString = ""
			local isStringBad = true
			local cachedName = ""
			local isNameBad = false

			local panel = CreateFrame("Frame", "$parentPanel1", frame)
			panel:SetPoint("TOPLEFT", 5, -22)
			panel:SetPoint("BOTTOMRIGHT", 0, 4)
			panel:SetScript("OnShow", function()
				if isStringBad then
					panel.NewButton:SetControlChecked(true)
					panel.NewButton:SetControlChecked(false)
				end

				panel.ScrollFrame.EditBox:SetText(cachedString)
				panel.ScrollFrame.EditBox:SetFocus()

				panel.ImportButton:SetEnabled(not isNameBad and not isStringBad)
			end)
			panel:Hide()

			t_insert(frame.Panels, panel)

			local scrollFrame = CreateFrame("ScrollFrame", nil, panel, "InputScrollFrameTemplate")
			scrollFrame:SetPoint("TOPLEFT", 11, -9)
			scrollFrame:SetPoint("BOTTOMRIGHT", -10, 55)
			panel.ScrollFrame = scrollFrame

			scrollFrame.EditBox:SetMaxLetters(4096)
			scrollFrame.EditBox:SetWidth(scrollFrame:GetWidth() - 18)
			scrollFrame.EditBox:SetScript("OnTextChanged", function(self)
				cachedString = s_trim(self:GetText())
				isStringBad = cachedString == ""

				panel.ImportButton:SetEnabled(not isNameBad and not isStringBad)
			end)

			scrollFrame.CharCount:Hide()

			scrollFrame.ScrollBar:SetHideIfUnscrollable(false)
			scrollFrame.ScrollBar:SetHideTrackIfThumbExceedsTrack(true)
			scrollFrame.ScrollBar:SetPoint("TOPLEFT", scrollFrame, "TOPRIGHT", -12, -2)
			scrollFrame.ScrollBar:SetPoint("BOTTOMLEFT", scrollFrame, "BOTTOMRIGHT", -12, 2)
			scrollFrame.ScrollBar:Show()

			local newButton = CreateFrame("Frame", nil, panel, "ResizeCheckButtonTemplate")
			newButton:SetPoint("BOTTOMLEFT", 2, 22)
			newButton:SetLabelText(_G.NEW)
			newButton:SetCallback(function(isChecked)
				panel.NameEditBox:SetEnabled(isChecked)

				if isChecked then
					panel.NameEditBox:SetText("Imported Profile")
					panel.NameEditBox:SetTextColor(1, 1, 1)
					panel.NameEditBox:SetFocus()
				else
					panel.NameEditBox:SetText(C.db:GetCurrentProfile())
					panel.NameEditBox:SetTextColor(0.6, 0.6, 0.6)
					panel.NameEditBox:ClearFocus()
					panel.NameEditBox:RefreshIcon()
				end
			end)
			panel.NewButton = newButton

			newButton.labelFont = "GameFontHighlight"
			newButton.disabledLabelFont = "GameFontDisable"
			newButton:UpdateLabelFont()

			local nameEditBox = CreateFrame("EditBox", nil, panel, "InputBoxTemplate")
			nameEditBox:SetHeight(24)
			nameEditBox:SetPoint("LEFT", newButton, "LEFT", 96, 1)
			nameEditBox:SetPoint("RIGHT", panel, "RIGHT", -5, 0)
			nameEditBox:SetAutoFocus(false)
			nameEditBox:SetMaxLetters(24)
			nameEditBox:SetScript("OnTextChanged", function(self)
				cachedName = s_trim(self:GetText())
				local isBad = self:RefreshIcon(cachedName)
				if isBad ~= isNameBad then
					isNameBad = isBad

					panel.ImportButton:SetEnabled(not isNameBad and not isStringBad)
				end
			end)
			panel.NameEditBox = nameEditBox

			function nameEditBox:RefreshIcon(name)
				if not name then
					self.StateIcon:SetTexture(0)

					return
				end

				local isBad = name == ""
				if isBad then
					self.StateIcon:SetAtlas(BAD_ICON)
				else
					if C.db.profiles[name] then
						self.StateIcon:SetAtlas(CLASH_ICON)
					else
						self.StateIcon:SetAtlas(NEW_ICON)
					end
				end

				return isBad
			end

			local nameStateIcon = nameEditBox:CreateTexture(nil, "OVERLAY")
			nameStateIcon:SetSize(18, 18)
			nameStateIcon:SetPoint("RIGHT", -4, 0)
			nameEditBox.StateIcon = nameStateIcon

			local importButton = CreateFrame("Button", nil, panel, "UIPanelButtonNoTooltipTemplate")
			importButton:SetHeight(22)
			importButton:SetPoint("BOTTOMLEFT", 4, 2)
			importButton:SetPoint("BOTTOMRIGHT", -4, 2)
			importButton:SetText(L["IMPORT"])
			importButton:SetScript("OnClick", function()
				if cachedString ~= "" then
					local newName = nameEditBox:GetText()
					local isOK = addon:Import(cachedString, newButton.Button:GetChecked(), newName)
					if isOK then
						scrollFrame.EditBox:SetText("")
						nameEditBox:RefreshIcon(newName)

						LibStub("AceConfigDialog-3.0"):SelectGroup(addonName, "profiles")

						displayActionStatusMessage(_G.SUCCESS)
					else
						displayActionStatusMessage(_G.FAILED)
					end
				end
			end)
			panel.ImportButton = importButton

			local tab = CreateFrame("Button", "$parentTab1", frame, "FriendsFrameTabTemplate")
			tab:SetID(1)
			tab:SetText(L["IMPORT"])
			tab:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", 12, 2)
			tab:SetScript("OnClick", function()
				PanelTemplates_SetTab(frame, 1)

				frame.Panels[1]:Show()
				frame.Panels[2]:Hide()
			end)

			-- hardcode it because of classic vs retail diffs
			frame.Tabs[1] = tab

			-- classic specific adjustments
			if GetClientDisplayExpansionLevel() < 3 then
				scrollFrame:SetPoint("BOTTOMRIGHT", -12, 59)

				scrollFrame.EditBox:SetWidth(scrollFrame:GetWidth() - 26)

				scrollFrame.ScrollBar:ClearAllPoints()
				scrollFrame.ScrollBar:SetPoint("TOPRIGHT", scrollFrame, "TOPRIGHT", -1, 4)
				scrollFrame.ScrollBar:SetPoint("BOTTOMRIGHT", scrollFrame, "BOTTOMRIGHT", -1, -5)

				local scrollBarBG = scrollFrame.ScrollBar:GetRegions()
				scrollBarBG:SetPoint("TOPLEFT", 3, -3)
				scrollBarBG:SetPoint("BOTTOMRIGHT", 0, 3)

				newButton:SetPoint("BOTTOMLEFT", 2, 26)

				nameEditBox:SetPoint("RIGHT", panel, "RIGHT", -7, 0)

				importButton:SetPoint("BOTTOMLEFT", 4, 6)
				importButton:SetPoint("BOTTOMRIGHT", -4, 6)

				importButton:SetPoint("BOTTOMRIGHT", -6, 2)
			end
		end

		-- export
		do
			local cachedString = ""

			local panel = CreateFrame("Frame", "$parentPanel2", frame)
			panel:SetPoint("TOPLEFT", 5, -22)
			panel:SetPoint("BOTTOMRIGHT", 0, 4)
			panel:SetScript("OnShow", function()
				-- always regen it, maybe they changed profiles
				cachedString = addon:Export("profile")

				panel.ScrollFrame.EditBox:SetText(cachedString or "")
				panel.ScrollFrame.EditBox:SetFocus()
			end)
			panel:Hide()

			t_insert(frame.Panels, panel)

			local scrollFrame = CreateFrame("ScrollFrame", nil, panel, "InputScrollFrameTemplate")
			scrollFrame:SetPoint("TOPLEFT", 11, -9)
			scrollFrame:SetPoint("BOTTOMRIGHT", -10, 8)
			panel.ScrollFrame = scrollFrame

			scrollFrame.EditBox:SetMaxLetters(4096)
			scrollFrame.EditBox:SetWidth(scrollFrame:GetWidth() - 18)
			scrollFrame.EditBox:SetScript("OnTextChanged", function(self, isUserInput)
				if isUserInput then
					self:SetText(cachedString)
				end
			end)
			scrollFrame.EditBox:SetScript("OnUpdate", function(self)
				self:HighlightText()
			end)

			scrollFrame.CharCount:Hide()

			scrollFrame.ScrollBar:SetHideIfUnscrollable(false)
			scrollFrame.ScrollBar:SetHideTrackIfThumbExceedsTrack(true)
			scrollFrame.ScrollBar:SetPoint("TOPLEFT", scrollFrame, "TOPRIGHT", -12, -2)
			scrollFrame.ScrollBar:SetPoint("BOTTOMLEFT", scrollFrame, "BOTTOMRIGHT", -12, 2)
			scrollFrame.ScrollBar:Show()

			local tab = CreateFrame("Button", "$parentTab2", frame, "FriendsFrameTabTemplate")
			tab:SetID(2)
			tab:SetText(L["EXPORT"])
			tab:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", 12, 2)
			tab:SetScript("OnClick", function()
				PanelTemplates_SetTab(frame, 2)

				frame.Panels[1]:Hide()
				frame.Panels[2]:Show()
			end)

			-- hardcode it because of classic vs retail diffs
			frame.Tabs[2] = tab

			-- classic specific adjustments
			if GetClientDisplayExpansionLevel() < 3 then
				scrollFrame:SetPoint("BOTTOMRIGHT", -12, 12)

				scrollFrame.EditBox:SetWidth(scrollFrame:GetWidth() - 26)

				scrollFrame.ScrollBar:ClearAllPoints()
				scrollFrame.ScrollBar:SetPoint("TOPRIGHT", scrollFrame, "TOPRIGHT", -1, 4)
				scrollFrame.ScrollBar:SetPoint("BOTTOMRIGHT", scrollFrame, "BOTTOMRIGHT", -1, -5)

				local scrollBarBG = scrollFrame.ScrollBar:GetRegions()
				scrollBarBG:SetPoint("TOPLEFT", 3, -3)
				scrollBarBG:SetPoint("BOTTOMRIGHT", 0, 3)
			end
		end

		PanelTemplates_SetNumTabs(frame, 2)
		PanelTemplates_SetTab(frame, 1)

		-- classic specific adjustments
		if GetClientDisplayExpansionLevel() < 3 then
			frame.Bg:SetPoint("BOTTOMRIGHT", -2, 6)
			frame.NineSlice.RightEdge:SetPointsOffset(1, 0)

			frame.Tabs[1]:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", 12, 7)
			frame.Tabs[1]:SetFrameLevel(frame.NineSlice:GetFrameLevel() + 1)

			frame.Tabs[2]:SetPoint("TOPLEFT", frame.Tabs[1], "TOPRIGHT", -14, 0)
			frame.Tabs[2]:SetFrameLevel(frame.NineSlice:GetFrameLevel() + 1)
		end
	end

	function addon:OpenImportExport()
		LSToastsImportExport:Show()
		LSToastsImportExport.Panels[1]:Show()
	end
end
