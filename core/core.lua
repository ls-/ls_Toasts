local addonName, addonTable = ...
local C, L = addonTable.C, addonTable.L

-- Lua
local _G = getfenv(0)
local debugstack = _G.debugstack
local error = _G.error
local m_ceil = _G.math.ceil
local m_floor = _G.math.floor
local next = _G.next
local s_format = _G.string.format
local s_match = _G.string.match
local s_split = _G.string.split
local setmetatable = _G.setmetatable
local t_concat = _G.table.concat
local t_insert = _G.table.insert
local t_remove = _G.table.remove
local t_wipe = _G.table.wipe
local tonumber = _G.tonumber
local type = _G.type
local unpack = _G.unpack

-- Blizz
local C_Timer_NewTicker = _G.C_Timer.NewTicker
local CanDualWield = _G.CanDualWield
local CreateFrame = _G.CreateFrame
local GameTooltip_ShowCompareItem = _G.GameTooltip_ShowCompareItem
local GetContainerItemID = _G.GetContainerItemID
local GetContainerNumSlots = _G.GetContainerNumSlots
local GetCVarBool = _G.GetCVarBool
local GetDetailedItemLevelInfo = _G.GetDetailedItemLevelInfo
local GetInventoryItemID = _G.GetInventoryItemID
local GetInventoryItemLink = _G.GetInventoryItemLink
local GetItemInfo = _G.GetItemInfo
local InCombatLockdown = _G.InCombatLockdown
local IsLoggedIn = _G.IsLoggedIn
local IsModifiedClick = _G.IsModifiedClick
local IsUsableItem = _G.IsUsableItem
local Lerp = _G.Lerp
local PlaySound = _G.PlaySoundKitID or _G.PlaySound

-- Mine
local activeToasts = {}
local queuedToasts = {}
local createdToasts = {}

local textsToAnimate = {}

local _E, E = {}, {}
addonTable.E = E

setmetatable(E, {
	__index = function(_, k)
		return _E[k]
	end,
	__newindex = function(_, k, v)
		if type(v) ~= "function" then
			return
		end

		if k ~= "SkinToast" then
			if not _E[k] then
				_E[k] = v
			end
		else
			local name = debugstack(2, 2, 0):match("[Aa.]?[Dd.]?[Dd.]?[Oo.]?[Nn.][Ss.]?\\(.+)\\")

			if name then
				name = name:gsub("_", " "):gsub("[^%w%s]", "")
			else
				name = "Skin"..(_E:GetNumSkins() + 1)
			end

			_E:RegisterSkin(name, function(...) v(_, ...) end)
		end
	end,
})

_G[addonName] = {
	[1] = E,
	[2] = C,
	[3] = L,
}

------------
-- EVENTS --
------------

do
	local dispatcher = CreateFrame("Frame")
	local oneTimeEvents = {ADDON_LOADED = false, PLAYER_LOGIN = false}
	local registeredEvents = {}

	local function OnEvent(_, event, ...)
		for func in next, registeredEvents[event] do
			func(...)
		end

		if oneTimeEvents[event] == false then
			oneTimeEvents[event] = true
		end
	end

	dispatcher:SetScript("OnEvent", OnEvent)

	function E.RegisterEvent(_, event, func, unit1, unit2)
		if oneTimeEvents[event] then
			error(s_format("Failed to register for '%s' event, already fired!", event), 3)
		end

		if not func or type(func) ~= "function" then
			error(s_format("Failed to register for '%s' event, no handler!", event), 3)
		end

		if not registeredEvents[event] then
			registeredEvents[event] = {}

			if unit1 then
				dispatcher:RegisterUnitEvent(event, unit1, unit2)
			else
				dispatcher:RegisterEvent(event)
			end
		end

		registeredEvents[event][func] = true
	end

	function E.UnregisterEvent(_, event, func)
		local funcs = registeredEvents[event]

		if funcs and funcs[func] then
			funcs[func] = nil

			if not next(funcs) then
				registeredEvents[event] = nil

				dispatcher:UnregisterEvent(event)
			end
		end
	end
end

-------------
-- HELPERS --
-------------

local function FlushToastsCache()
	t_wipe(queuedToasts)

	for _ = 1, #activeToasts do
		activeToasts[1]:Click("RightButton")
	end

	t_wipe(createdToasts)
end

function E.SanitizeLink(_, link)
	if not link or link == "[]" or link == "" then
		return
	end

	local temp, name = s_match(link, "|H(.+)|h%[(.+)%]|h")
	link = temp or link

	local linkTable = {s_split(":", link)}

	if linkTable[1] ~= "item" then
		return link, link, linkTable[1], tonumber(linkTable[2]), name
	end

	if linkTable[12] ~= "" then
		linkTable[12] = ""

		t_remove(linkTable, 15 + (tonumber(linkTable[14]) or 0))
	end

	return t_concat(linkTable, ":"), link, linkTable[1], tonumber(linkTable[2]), name
end

function E.GetScreenQuadrant(_, frame)
	local x, y = frame:GetCenter()

	if not (x and y) then
		return "UNKNOWN"
	end

	local screenWidth = UIParent:GetRight()
	local screenHeight = UIParent:GetTop()
	local screenLeft = screenWidth / 3
	local screenRight = screenWidth * 2 / 3

	if y >= screenHeight * 2 / 3 then
		if x <= screenLeft then
			return "TOPLEFT"
		elseif x >= screenRight then
			return "TOPRIGHT"
		else
			return "TOP"
		end
	elseif y <= screenHeight / 3 then
		if x <= screenLeft then
			return "BOTTOMLEFT"
		elseif x >= screenRight then
			return "BOTTOMRIGHT"
		else
			return "BOTTOM"
		end
	else
		if x <= screenLeft then
			return "LEFT"
		elseif x >= screenRight then
			return "RIGHT"
		else
			return "CENTER"
		end
	end
end

do
	local slots = {
		["INVTYPE_HEAD"] = {INVSLOT_HEAD},
		["INVTYPE_NECK"] = {INVSLOT_NECK},
		["INVTYPE_SHOULDER"] = {INVSLOT_SHOULDER},
		["INVTYPE_CHEST"] = {INVSLOT_CHEST},
		["INVTYPE_ROBE"] = {INVSLOT_CHEST},
		["INVTYPE_WAIST"] = {INVSLOT_WAIST},
		["INVTYPE_LEGS"] = {INVSLOT_LEGS},
		["INVTYPE_FEET"] = {INVSLOT_FEET},
		["INVTYPE_WRIST"] = {INVSLOT_WRIST},
		["INVTYPE_HAND"] = {INVSLOT_HAND},
		["INVTYPE_FINGER"] = {INVSLOT_FINGER1, INVSLOT_FINGER2},
		["INVTYPE_TRINKET"] = {INVSLOT_TRINKET1, INVSLOT_TRINKET2},
		["INVTYPE_CLOAK"] = {INVSLOT_BACK},
		["INVTYPE_WEAPON"] = {INVSLOT_MAINHAND, INVSLOT_OFFHAND},
		["INVTYPE_2HWEAPON"] = {INVSLOT_MAINHAND},
		["INVTYPE_WEAPONMAINHAND"] = {INVSLOT_MAINHAND},
		["INVTYPE_HOLDABLE"] = {INVSLOT_OFFHAND},
		["INVTYPE_SHIELD"] = {INVSLOT_OFFHAND},
		["INVTYPE_WEAPONOFFHAND"] = {INVSLOT_OFFHAND},
		["INVTYPE_RANGED"] = {INVSLOT_RANGED},
		["INVTYPE_RANGEDRIGHT"] = {INVSLOT_RANGED},
		["INVTYPE_RELIC"] = {INVSLOT_RANGED},
		["INVTYPE_THROWN"] = {INVSLOT_RANGED},
	}

	-- TODO: Remove it, when it's re-enabled by Blizzard
	function E.IsItemUpgrade(_, itemLink)
		if not IsUsableItem(itemLink) then
			return false
		end

		local _, _, _, _, _, _, _, _, itemEquipLoc = GetItemInfo(itemLink)
		local itemLevel = GetDetailedItemLevelInfo(itemLink)
		local slot1, slot2 = unpack(slots[itemEquipLoc] or {})

		if itemLevel then
			if slot1 then
				local itemLinkInSlot1 = GetInventoryItemLink("player", slot1)

				if itemLinkInSlot1 then
					local itemLevelInSlot1 = GetDetailedItemLevelInfo(itemLinkInSlot1)

					if itemLevelInSlot1 and itemLevel > itemLevelInSlot1 then
						return true
					end
				else
					-- Make sure that slot is empty
					if not GetInventoryItemID("player", slot1) then
						return true
					end
				end
			end

			if slot2 then
				local isSlot2Equippable = itemEquipLoc ~= "INVTYPE_WEAPON" and true or CanDualWield()

				if isSlot2Equippable then
					local itemLinkInSlot2 = GetInventoryItemLink("player", slot2)

					if itemLinkInSlot2 then
						local itemLevelInSlot2 = GetDetailedItemLevelInfo(itemLinkInSlot2)

						if itemLevelInSlot2 and itemLevel > itemLevelInSlot2 then
							return true
						end
					else
						-- Make sure that slot is empty
						if not GetInventoryItemID("player", slot2) then
							return true
						end
					end
				end
			end
		end

		return false
	end

	function E.GetItemLevel(_, itemLink)
		local _, _, _, _, _, _, _, _, itemEquipLoc, _, _, itemClassID, itemSubClassID = GetItemInfo(itemLink)

		-- 3:11 is artefact relic
		if (itemClassID == 3 and itemSubClassID == 11) or slots[itemEquipLoc] then
			return GetDetailedItemLevelInfo(itemLink) or 0
		end

		return 0
	end
end

function E.SearchBagsForItemID(_, itemID)
	for i = 0, NUM_BAG_SLOTS do
		for j = 1, GetContainerNumSlots(i) do
			if GetContainerItemID(i, j) == itemID then
				return i, j
			end
		end
	end

	return -1, -1
end

------------
-- ANCHOR --
------------

local anchorFrame = CreateFrame("Frame", nil, UIParent)
anchorFrame:SetClampedToScreen(true)
anchorFrame:SetClampRectInsets(-24, 12, 12, -12)
anchorFrame:SetToplevel(true)
anchorFrame:RegisterForDrag("LeftButton")
anchorFrame:SetFrameStrata("DIALOG")

do
	local function CalculatePosition(self)
		local selfCenterX, selfCenterY = self:GetCenter()
		local screenWidth = UIParent:GetRight()
		local screenHeight = UIParent:GetTop()
		local screenCenterX, screenCenterY = UIParent:GetCenter()
		local screenLeft = screenWidth / 3
		local screenRight = screenWidth * 2 / 3
		local p, x, y

		if selfCenterY >= screenCenterY then
			p = "TOP"
			y = self:GetTop() - screenHeight
		else
			p = "BOTTOM"
			y = self:GetBottom()
		end

		if selfCenterX >= screenRight then
			p = p.."RIGHT"
			x = self:GetRight() - screenWidth
		elseif selfCenterX <= screenLeft then
			p = p.."LEFT"
			x = self:GetLeft()
		else
			x = selfCenterX - screenCenterX
		end

		return p, p, m_floor(x + 0.5), m_floor(y + 0.5)
	end

	anchorFrame.Enable = function(self)
		self:EnableMouse(true)
		self.BG:Show()
		self.Text:Show()
	end

	anchorFrame.Disable = function(self)
		self:EnableMouse(false)
		self.BG:Hide()
		self.Text:Hide()
	end

	anchorFrame.Toggle = function(self)
		if self:IsMouseEnabled() then
			self:Disable()
		else
			self:Enable()
		end
	end

	anchorFrame.Refresh = function(self)
		self:SetMovable(true)
		self:ClearAllPoints()
		self:SetSize(234 * C.db.profile.scale, 58 * C.db.profile.scale)
		self:SetPoint(C.db.profile.point.p, "UIParent", C.db.profile.point.rP, C.db.profile.point.x, C.db.profile.point.y)
	end

	anchorFrame.StartDrag = function(self)
		self:StartMoving()
	end

	anchorFrame.StopDrag = function(self)
		self:StopMovingOrSizing()

		local p, rP, x, y = CalculatePosition(self)

		self:ClearAllPoints()
		self:SetPoint(p, "UIParent", rP, x, y)

		C.db.profile.point = {p = p, rP = rP, x = x, y = y}
	end

	anchorFrame:SetScript("OnDragStart", anchorFrame.StartDrag)
	anchorFrame:SetScript("OnDragStop", anchorFrame.StopDrag)

	local texture = anchorFrame:CreateTexture(nil, "BACKGROUND")
	texture:SetColorTexture(0.1, 0.1, 0.1, 0.9)
	texture:SetAllPoints()
	texture:Hide()
	anchorFrame.BG = texture

	local text = anchorFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	text:SetAllPoints()
	text:SetJustifyH("CENTER")
	text:SetJustifyV("MIDDLE")
	text:SetText(L["ANCHOR"])
	text:Hide()
	anchorFrame.Text = text

	function E.GetAnchorFrame()
		return anchorFrame
	end
end

-----------
-- QUEUE --
-----------

local function IsDNDEnabled()
	for _, v in next, C.db.profile.types do
		if v.dnd then
			return true
		end
	end

	return false
end

local function HasNonDNDToast()
	for i, queuedToast in next, queuedToasts do
		if not queuedToast._data.dnd then
			-- I don't want to ruin non-DND toasts' order, k?
			t_insert(queuedToasts, 1, t_remove(queuedToasts, i))

			return true
		end
	end

	return false
end

function E.RefreshQueue()
	for i = 1, #activeToasts do
		local activeToast = activeToasts[i]

		activeToast:ClearAllPoints()

		if i == 1 then
			activeToast:SetPoint("TOPLEFT", anchorFrame, "TOPLEFT", 0, 0)
		else
			if C.db.profile.growth_direction == "DOWN" then
				activeToast:SetPoint("TOP", activeToasts[i - 1], "BOTTOM", 0, -4)
			elseif C.db.profile.growth_direction == "UP" then
				activeToast:SetPoint("BOTTOM", activeToasts[i - 1], "TOP", 0, 4)
			elseif C.db.profile.growth_direction == "LEFT" then
				activeToast:SetPoint("RIGHT", activeToasts[i - 1], "LEFT", -8, 0)
			elseif C.db.profile.growth_direction == "RIGHT" then
				activeToast:SetPoint("LEFT", activeToasts[i - 1], "RIGHT", 8, 0)
			end
		end
	end

	local queuedToast = t_remove(queuedToasts, 1)

	if queuedToast then
		if InCombatLockdown() and queuedToast._data.dnd then
			t_insert(queuedToasts, queuedToast)

			if HasNonDNDToast() then
				E:RefreshQueue()
			end
		else
			queuedToast:Spawn()
		end
	end
end

E:RegisterEvent("PLAYER_REGEN_ENABLED", function()
	if IsDNDEnabled() and #queuedToasts > 0 then
		for _ = 1, C.db.profile.max_active_toasts - #activeToasts do
			E:RefreshQueue()
		end
	end
end)

-----------
-- TOAST --
-----------

-- E:GetToast(...)
do
	C_Timer_NewTicker(0.05, function()
		for text, targetValue in next, textsToAnimate do
			local newValue

			text._elapsed = text._elapsed + 0.05

			if text._value >= targetValue then
				newValue = m_floor(Lerp(text._value, targetValue, text._elapsed / 0.6))
			else
				newValue = m_ceil(Lerp(text._value, targetValue, text._elapsed / 0.6))
			end

			if newValue == targetValue then
				textsToAnimate[text] = nil
			end

			text._value = newValue

			if text.PostSetAnimatedValue then
				text:PostSetAnimatedValue(newValue)
			else
				text:SetText(newValue)
			end
		end
	end)

	local function SetAnimatedValue(self, value, skip)
		if skip then
			self._value = value
			self._elapsed = 0

			if self.PostSetAnimatedValue then
				self:PostSetAnimatedValue(value)
			else
				self:SetText(value)
			end
		else
			self._value = self._value or 1
			self._elapsed = 0

			textsToAnimate[self] = value
		end
	end

	-- Base Toast
	local function Toast_OnShow(self)
		local soundFile = self._data.sound_file

		if soundFile and C.db.profile.sfx.enabled then
			PlaySound(soundFile)
		end

		self.AnimIn:Play()
		self.AnimOut:Play()
	end

	local function Toast_OnClick(self, button)
		if button == "RightButton" then
			self:Recycle()
		end
	end

	local function MODIFIER_STATE_CHANGED()
		if IsModifiedClick("COMPAREITEMS") or GetCVarBool("alwaysCompareItems") then
			GameTooltip_ShowCompareItem()
		else
			ShoppingTooltip1:Hide()
			ShoppingTooltip2:Hide()
		end
	end

	local function Toast_OnEnter(self)
		local quadrant = E:GetScreenQuadrant(self)
		local p, rP, x, y = "TOPLEFT", "BOTTOMRIGHT", -2, 2

		if quadrant == "BOTTOMLEFT" or quadrant == "BOTTOM" then
			p, rP, x, y = "BOTTOMLEFT", "TOPRIGHT", -2, -2
		elseif quadrant == "TOPRIGHT" or quadrant == "RIGHT" then
			p, rP, x, y = "TOPRIGHT", "BOTTOMLEFT", 2, 2
		elseif quadrant == "BOTTOMRIGHT" then
			p, rP, x, y = "BOTTOMRIGHT", "TOPLEFT", 2, -2
		end

		GameTooltip:Hide()
		GameTooltip:SetOwner(self, "ANCHOR_NONE")
		GameTooltip:SetPoint(p, self, rP, x, y)

		self.AnimOut:Stop()

		E:RegisterEvent("MODIFIER_STATE_CHANGED", MODIFIER_STATE_CHANGED)
	end

	local function Toast_OnLeave(self)
		BattlePetTooltip:Hide()
		GameTooltip:Hide()
		GarrisonFollowerTooltip:Hide()
		GarrisonShipyardFollowerTooltip:Hide()
		ShoppingTooltip1:Hide()
		ShoppingTooltip2:Hide()

		self.AnimOut:Play()

		E:UnregisterEvent("MODIFIER_STATE_CHANGED", MODIFIER_STATE_CHANGED)
	end

	local function ToastAnimIn_OnPlay(self)
		local toast = self:GetParent()

		if toast._data.show_arrows then
			toast.AnimArrows:Play()

			toast._data.show_arrows = false
		end
	end

	local function ToastAnimOut_OnFinished(self)
		self:GetParent():Recycle()
	end

	-- Arrows
	local ARROWS_INFO = {
		[1] = {start_delay_1 = 0.9, start_delay_2 = 1.2, x = 0},
		[2] = {start_delay_1 = 1.0, start_delay_2 = 1.3, x = -8},
		[3] = {start_delay_1 = 1.1, start_delay_2 = 1.4, x = 16},
		[4] = {start_delay_1 = 1.2, start_delay_2 = 1.6, x = 8},
		[5] = {start_delay_1 = 1.4, start_delay_2 = 1.8, x = -16},
	}

	-- Slot Buttons
	local function Slot_OnEnter(self)
		self:GetParent().AnimOut:Stop()

		local quadrant = E:GetScreenQuadrant(self)
		local p, rP, x, y = "TOPLEFT", "BOTTOMRIGHT", -2, 2

		if quadrant == "BOTTOMLEFT" or quadrant == "BOTTOM" then
			p, rP, x, y = "BOTTOMLEFT", "TOPRIGHT", -2, -2
		elseif quadrant == "TOPRIGHT" or quadrant == "RIGHT" then
			p, rP, x, y = "TOPRIGHT", "BOTTOMLEFT", 2, 2
		elseif quadrant == "BOTTOMRIGHT" then
			p, rP, x, y = "BOTTOMRIGHT", "TOPLEFT", 2, -2
		end

		GameTooltip:Hide()
		GameTooltip:SetOwner(self, "ANCHOR_NONE")
		GameTooltip:SetPoint(p, self, rP, x, y)
	end

	local function Slot_OnLeave(self)
		self:GetParent().AnimOut:Play()
		GameTooltip:Hide()
	end

	local function Slot_OnHide(self)
		self._data = nil
	end

	-- Sends Toast to the Queue
	local function SpawnToast(self, isDND)
		if #activeToasts >= C.db.profile.max_active_toasts or (InCombatLockdown() and isDND) then
			if InCombatLockdown() and isDND then
				self._data.dnd = true
			end

			t_insert(queuedToasts, self)

			return
		end

		if #activeToasts > 0 then
			if C.db.profile.growth_direction == "DOWN" then
				self:SetPoint("TOP", activeToasts[#activeToasts], "BOTTOM", 0, -4)
			elseif C.db.profile.growth_direction == "UP" then
				self:SetPoint("BOTTOM", activeToasts[#activeToasts], "TOP", 0, 4)
			elseif C.db.profile.growth_direction == "LEFT" then
				self:SetPoint("RIGHT", activeToasts[#activeToasts], "LEFT", -8, 0)
			elseif C.db.profile.growth_direction == "RIGHT" then
				self:SetPoint("LEFT", activeToasts[#activeToasts], "RIGHT", 8, 0)
			end
		else
			self:SetPoint("TOPLEFT", anchorFrame, "TOPLEFT", 0, 0)
		end

		t_insert(activeToasts, self)

		E:GetSkinFunc()(self)

		self:Show()
	end

	local function RecycleToast(self)
		self:ClearAllPoints()
		self:Hide()

		self:SetScript("OnClick", Toast_OnClick)
		self:SetScript("OnEnter", Toast_OnEnter)

		self._data = nil
		self.AnimArrows:Stop()
		self.AnimIn:Stop()
		self.AnimOut:Stop()
		self.BG:SetTexture("Interface\\AddOns\\ls_Toasts\\media\\toast-bg-default")
		self.Bonus:Hide()
		self.Border:SetVertexColor(1, 1, 1)
		self.Dragon:Hide()
		self.Icon:SetPoint("TOPLEFT", 7, -7)
		self.Icon:SetSize(44, 44)
		self.IconBorder:Hide()
		self.IconBorder:SetVertexColor(1, 1, 1)
		self.IconHL:Hide()
		self.IconText1:SetText("")
		self.IconText1:SetTextColor(1, 1, 1)
		self.IconText1.PostSetAnimatedValue = nil
		self.IconText1BG:Hide()
		self.IconText2:SetText("")
		self.IconText2:SetTextColor(1, 1, 1)
		self.IconText2.Blink:Stop()
		self.IconText2.PostSetAnimatedValue = nil
		self.Skull:Hide()
		self.Text:SetText("")
		self.Text:SetTextColor(1, 1, 1)
		self.Text.PostSetAnimatedValue = nil
		self.TextBG:SetVertexColor(0, 0, 0)
		self.Title:SetText("")
		self.UpgradeIcon:Hide()

		for i = 1, 5 do
			self["Slot"..i]:Hide()
			self["Slot"..i]:SetScript("OnEnter", Slot_OnEnter)
		end

		for i = 1, 5 do
			self["Arrow"..i]:SetAlpha(0)
		end

		for i, activeToast in next, activeToasts do
			if self == activeToast then
				t_remove(activeToasts, i)
			end
		end

		-- jic something goes wrong
		for i, queuedToast in next, queuedToasts do
			if self == queuedToast then
				t_remove(queuedToasts, i)
			end
		end

		t_insert(createdToasts, self)

		E:RefreshQueue()
	end

	local function ConstructToast()
		local toast = CreateFrame("Button", nil, UIParent)
		toast:RegisterForClicks("LeftButtonUp", "RightButtonUp")
		toast:Hide()
		toast:SetScript("OnShow", Toast_OnShow)
		toast:SetScript("OnClick", Toast_OnClick)
		toast:SetScript("OnEnter", Toast_OnEnter)
		toast:SetScript("OnLeave", Toast_OnLeave)
		toast:SetSize(234, 58)
		toast:SetScale(C.db.profile.scale)
		toast:SetFrameStrata(C.db.profile.strata)

		local bg = toast:CreateTexture(nil, "BACKGROUND", nil, 0)
		bg:SetPoint("TOPLEFT", 5, -5)
		bg:SetPoint("BOTTOMRIGHT", -5, 5)
		bg:SetTexture("Interface\\AddOns\\ls_Toasts\\media\\toast-bg-default")
		bg:SetTexCoord(1 / 256, 225 / 256, 1 / 64, 49 / 64)
		toast.BG = bg

		local border = toast:CreateTexture(nil, "BACKGROUND", nil, 1)
		border:SetAllPoints()
		border:SetTexture("Interface\\AddOns\\ls_Toasts\\media\\toast-border")
		border:SetTexCoord(1 / 256, 235 / 256, 1 / 64, 59 / 64)
		toast.Border = border

		local icon = toast:CreateTexture(nil, "BACKGROUND", nil, 2)
		icon:SetPoint("TOPLEFT", 7, -7)
		icon:SetSize(44, 44)
		toast.Icon = icon

		local iconHL = toast:CreateTexture(nil, "BACKGROUND", nil, 3)
		iconHL:SetPoint("TOPLEFT", 7, -7)
		iconHL:SetSize(44, 44)
		iconHL:SetTexture("Interface\\ContainerFrame\\UI-Icon-QuestBorder")
		iconHL:Hide()
		toast.IconHL = iconHL

		local iconBorder = toast:CreateTexture(nil, "BACKGROUND", nil, 5)
		iconBorder:SetPoint("TOPLEFT", 7, -7)
		iconBorder:SetSize(44, 44)
		iconBorder:SetTexture("Interface\\AddOns\\ls_Toasts\\media\\toast-icon-border")
		iconBorder:SetTexCoord(1 / 64, 45 / 64, 1 / 64, 45 / 64)
		iconBorder:Hide()
		toast.IconBorder = iconBorder

		local iconText1 = toast:CreateFontString(nil, "ARTWORK", "GameFontHighlightOutline")
		iconText1:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", 0, 2)
		iconText1:SetJustifyH("RIGHT")
		iconText1.SetAnimatedValue = SetAnimatedValue
		toast.IconText1 = iconText1

		local iconText1BG = toast:CreateTexture(nil, "BACKGROUND", nil, 4)
		iconText1BG:SetPoint("BOTTOMLEFT", icon, "BOTTOMLEFT", 2, 2)
		iconText1BG:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", -2, 2)
		iconText1BG:SetHeight(12)
		iconText1BG:SetColorTexture(0, 0, 0, 0.6)
		iconText1BG:Hide()
		toast.IconText1BG = iconText1BG

		local iconText2 = toast:CreateFontString(nil, "ARTWORK", "GameFontHighlightOutline")
		iconText2:SetPoint("BOTTOMRIGHT", iconText1, "TOPRIGHT", 0, 2)
		iconText2:SetJustifyH("RIGHT")
		iconText2:SetAlpha(0)
		iconText2.SetAnimatedValue = SetAnimatedValue
		toast.IconText2 = iconText2

		do
			local ag = toast:CreateAnimationGroup()
			ag:SetToFinalAlpha(true)
			iconText2.Blink = ag

			local anim = ag:CreateAnimation("Alpha")
			anim:SetChildKey("IconText2")
			anim:SetOrder(1)
			anim:SetFromAlpha(0)
			anim:SetToAlpha(1)
			anim:SetDuration(0.2)

			anim = ag:CreateAnimation("Alpha")
			anim:SetChildKey("IconText2")
			anim:SetOrder(2)
			anim:SetFromAlpha(1)
			anim:SetToAlpha(0)
			anim:SetStartDelay(0.4)
			anim:SetDuration(0.4)
		end

		local skull = toast:CreateTexture(nil, "ARTWORK", nil, 2)
		skull:SetSize(16, 20)
		skull:SetTexture("Interface\\LFGFrame\\UI-LFG-ICON-HEROIC")
		skull:SetTexCoord(0 / 32, 16 / 32, 0 / 32, 20 / 32)
		skull:SetPoint("TOPRIGHT", icon, "TOPRIGHT", -2, -2)
		skull:Hide()
		toast.Skull = skull

		local upgradeIcon = toast:CreateTexture(nil, "ARTWORK", nil, 3)
		upgradeIcon:SetAtlas("bags-greenarrow", true)
		upgradeIcon:SetPoint("TOPLEFT", icon, "TOPLEFT", 2, -2)
		upgradeIcon:Hide()
		toast.UpgradeIcon = upgradeIcon

		do
			local ag = toast:CreateAnimationGroup()
			ag:SetToFinalAlpha(true)
			toast.AnimArrows = ag

			for i = 1, 5 do
				local config = ARROWS_INFO[i]

				local arrow = toast:CreateTexture(nil, "ARTWORK", "LootUpgradeFrame_ArrowTemplate")
				arrow:ClearAllPoints()
				arrow:SetPoint("TOP", icon, "CENTER", config.x, 0)
				toast["Arrow"..i] = arrow

				local anim = ag:CreateAnimation("Alpha")
				anim:SetChildKey("Arrow"..i)
				anim:SetDuration(0)
				anim:SetOrder(1)
				anim:SetFromAlpha(1)
				anim:SetToAlpha(0)

				anim = ag:CreateAnimation("Alpha")
				anim:SetChildKey("Arrow"..i)
				anim:SetStartDelay(config.start_delay_1)
				anim:SetSmoothing("IN")
				anim:SetDuration(0.2)
				anim:SetOrder(2)
				anim:SetFromAlpha(0)
				anim:SetToAlpha(1)

				anim = ag:CreateAnimation("Alpha")
				anim:SetChildKey("Arrow"..i)
				anim:SetStartDelay(config.start_delay_2)
				anim:SetSmoothing("OUT")
				anim:SetDuration(0.2)
				anim:SetOrder(2)
				anim:SetFromAlpha(1)
				anim:SetToAlpha(0)

				anim = ag:CreateAnimation("Translation")
				anim:SetChildKey("Arrow"..i)
				anim:SetStartDelay(config.start_delay_1)
				anim:SetDuration(0.5)
				anim:SetOrder(2)
				anim:SetOffset(0, 60)

				anim = ag:CreateAnimation("Alpha")
				anim:SetChildKey("Arrow"..i)
				anim:SetDuration(0)
				anim:SetOrder(3)
				anim:SetFromAlpha(1)
				anim:SetToAlpha(0)
			end
		end

		local title = toast:CreateFontString(nil, "ARTWORK", "GameFontNormal")
		title:SetPoint("TOPLEFT", 55, -12)
		title:SetWidth(170)
		title:SetJustifyH("CENTER")
		title:SetWordWrap(false)
		toast.Title = title

		local text = toast:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
		text:SetPoint("BOTTOMLEFT", 55, 12)
		text:SetWidth(170)
		text:SetJustifyH("CENTER")
		text:SetWordWrap(false)
		text:SetText(toast:GetDebugName())
		text.SetAnimatedValue = SetAnimatedValue
		toast.Text = text

		local textBG = toast:CreateTexture(nil, "BACKGROUND", nil, 2)
		textBG:SetSize(174, 44)
		textBG:SetPoint("BOTTOMLEFT", 53, 7)
		textBG:SetTexture("Interface\\AddOns\\ls_Toasts\\media\\toast-text-bg")
		textBG:SetTexCoord(1 / 256, 175 / 256, 1 / 64, 45 / 64)
		textBG:SetVertexColor(0, 0, 0)
		toast.TextBG = textBG

		local bonus = toast:CreateTexture(nil, "ARTWORK")
		bonus:SetAtlas("Bonus-ToastBanner", true)
		bonus:SetPoint("TOPRIGHT", -4, 0)
		bonus:Hide()
		toast.Bonus = bonus

		local dragon = toast:CreateTexture(nil, "OVERLAY", nil, 0)
		dragon:SetPoint("TOPLEFT", -23, 13)
		dragon:SetSize(88, 88)
		dragon:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Gold-Dragon")
		dragon:SetVertexColor(250 / 255, 200 / 255, 0 / 255)
		dragon:Hide()
		toast.Dragon = dragon

		for i = 1, 5 do
			local slot = CreateFrame("Frame", nil, toast)
			slot:SetSize(30, 30)
			slot:SetScript("OnEnter", Slot_OnEnter)
			slot:SetScript("OnLeave", Slot_OnLeave)
			slot:SetScript("OnHide", Slot_OnHide)
			slot:Hide()
			toast["Slot"..i] = slot

			local rIcon = slot:CreateTexture(nil, "BACKGROUND")
			rIcon:SetPoint("TOPLEFT", 5, -4)
			rIcon:SetPoint("BOTTOMRIGHT", -7, 8)
			slot.Icon = rIcon

			local rBorder = slot:CreateTexture(nil, "BORDER")
			rBorder:SetAllPoints()
			rBorder:SetTexture("Interface\\LFGFrame\\UI-LFG-ICON-REWARDRING")
			rBorder:SetTexCoord(0 / 64, 40 / 64, 0 / 64, 40 / 64)

			if i == 1 then
				slot:SetPoint("TOPRIGHT", -2, 10)
			else
				slot:SetPoint("RIGHT", toast["Slot"..(i - 1)], "LEFT", -2 , 0)
			end
		end

		local glow = toast:CreateTexture(nil, "OVERLAY", nil, 2)
		glow:SetSize(310, 148)
		glow:SetPoint("CENTER")
		glow:SetTexture("Interface\\AchievementFrame\\UI-Achievement-Alert-Glow")
		glow:SetTexCoord(0, 0.78125, 0, 0.66796875)
		glow:SetBlendMode("ADD")
		glow:SetAlpha(0)
		toast.Glow = glow

		local shine = toast:CreateTexture(nil, "OVERLAY", nil, 1)
		shine:SetSize(67, 54)
		shine:SetPoint("BOTTOMLEFT", 0, 2)
		shine:SetTexture("Interface\\AchievementFrame\\UI-Achievement-Alert-Glow")
		shine:SetTexCoord(400 / 512, 467 / 512, 11 / 256, 65 / 256)
		shine:SetBlendMode("ADD")
		shine:SetAlpha(0)
		toast.Shine = shine

		do
			local ag = toast:CreateAnimationGroup()
			ag:SetScript("OnPlay", ToastAnimIn_OnPlay)
			toast.AnimIn = ag

			local anim = ag:CreateAnimation("Alpha")
			anim:SetChildKey("Glow")
			anim:SetOrder(1)
			anim:SetFromAlpha(0)
			anim:SetToAlpha(1)
			anim:SetDuration(0.2)

			anim = ag:CreateAnimation("Alpha")
			anim:SetChildKey("Glow")
			anim:SetOrder(2)
			anim:SetFromAlpha(1)
			anim:SetToAlpha(0)
			anim:SetDuration(0.5)

			anim = ag:CreateAnimation("Alpha")
			anim:SetChildKey("Shine")
			anim:SetOrder(1)
			anim:SetFromAlpha(0)
			anim:SetToAlpha(1)
			anim:SetDuration(0.2)

			anim = ag:CreateAnimation("Translation")
			anim:SetChildKey("Shine")
			anim:SetOrder(2)
			anim:SetOffset(168, 0)
			anim:SetDuration(0.85)

			anim = ag:CreateAnimation("Alpha")
			anim:SetChildKey("Shine")
			anim:SetOrder(2)
			anim:SetFromAlpha(1)
			anim:SetToAlpha(0)
			anim:SetStartDelay(0.35)
			anim:SetDuration(0.5)

			ag = toast:CreateAnimationGroup()
			ag:SetScript("OnFinished", ToastAnimOut_OnFinished)
			toast.AnimOut = ag

			anim = ag:CreateAnimation("Alpha")
			anim:SetOrder(1)
			anim:SetFromAlpha(1)
			anim:SetToAlpha(0)
			anim:SetStartDelay(C.db.profile.fadeout_delay)
			anim:SetDuration(1.2)
			ag.Anim = anim
		end

		toast.Spawn = SpawnToast
		toast.Recycle = RecycleToast

		return toast
	end

	function E.FindToast(_, toastEvent, dataType, dataValue)
		if dataType and dataValue then
			for _, t in next, activeToasts do
				if (not toastEvent or toastEvent == t._data.event)
					and (t._data[dataType] == dataValue) then
					return t
				end
			end

			for _, t in next, queuedToasts do
				if (not toastEvent or toastEvent == t._data.event)
					and (t._data[dataType] == dataValue) then
					return t, true
				end
			end
		end
	end

	function E.GetToast(_, toastEvent, dataType, dataValue)
		local toast, isQueued = E:FindToast(toastEvent, dataType, dataValue)
		local isNew

		if not toast then
			toast = t_remove(createdToasts, 1)

			if not toast then
				toast = ConstructToast()
			end

			isNew = true
		end

		return toast, isNew, isQueued
	end
end

------------
-- SYSTEM --
------------

do
	local systems = {}

	local function dummy() end

	function E.RegisterSystem(_, name, enableFunc, disableFunc, testFunc)
		if not name then
			return false, "no_name"
		elseif systems[name] then
			return false, "name_taken"
		elseif not enableFunc then
			return false, "no_enabler"
		elseif not disableFunc then
			return false, "no_disabler"
		end

		systems[name] = {
			Enable = enableFunc,
			Disable = disableFunc,
			Test = testFunc or dummy,
			isEnabled = false,
		}

		return true
	end

	function E.EnableSystem(_, name)
		local system = systems[name]

		if system and not system.isEnabled then
			system:Enable()

			system.isEnabled = true
		end
	end

	function E.DisableSystem(_, name)
		local system = systems[name]

		if system and system.isEnabled then
			system:Disable()

			system.isEnabled = false
		end
	end

	function E.TestSystem(_, name)
		if systems[name] then
			systems[name]:Test()
		end
	end

	function E.EnableAllSystems()
		for _, system in next, systems do
			if not system.isEnabled then
				system:Enable()

				system.isEnabled = true
			end
		end
	end

	function E.DisableAllSystems()
		for _, system in next, systems do
			if system.isEnabled then
				system:Disable()

				system.isEnabled = false
			end
		end
	end

	function E.TestAllSystems()
		for _, system in next, systems do
				system:Test()
		end
	end
end

do
	local db = {} -- for profile switching
	local options = {}
	local order = 1

	local function UpdateTable(src, dest)
		if type(dest) ~= "table" then
			dest = {}
		end

		for k, v in next, src do
			if type(v) == "table" then
				dest[k] = UpdateTable(v, dest[k])
			else
				if dest[k] == nil then
					dest[k] = v
				end
			end
		end

		return dest
	end

	function E.RegisterOptions(_, name, dbTable, optionsTable)
		if not name then
			return false, "no_name"
		elseif db[name] then
			return false, "name_taken"
		elseif not dbTable then
			return false, "no_cfg_table"
		end

		db[name] = dbTable

		if IsLoggedIn() then
			C.db.profile.types[name] = {}

			UpdateTable(db[name], C.db.profile.types[name])
		end

		if optionsTable then
			options[name] = optionsTable
			options[name].guiInline = true
			options[name].order = order
			options[name].type = "group"

			order = order + 1

			if IsLoggedIn() then
				C.options.args.types.args[name] = {}

				UpdateTable(options[name], C.options.args.types.args[name])
			end
		end
	end

	function E.UpdateDB()
		UpdateTable(db, C.db.profile.types)
	end

	function E.UpdateOptions()
		UpdateTable(options, C.options.args.types.args)
	end
end

-----------
-- SKINS --
-----------

do
	local num = 1
	local skins = {
		Default = {
			func = function() end
		},
	}

	function E.RegisterSkin(_, name, func)
		if not name then
			return false, "no_name"
		elseif not func then
			return false, "no_func"
		elseif type(func) ~= "function" then
			return false, "func_invalid"
		elseif skins[name] then
			return false, "name_taken"
		elseif name == "handler" or name == "num" then
			return false, "name_prohibited"
		end

		num = num + 1

		skins[name] = {
			func = func
		}

		return true
	end

	function E.SetSkin(_, name)
		if not name then
			return false, "no_name"
		elseif not skins[name] then
			return false, "no_skin"
		elseif name == "handler" or name == "num" then
			return false, "invalid"
		end

		C.db.profile.skin = name

		FlushToastsCache()

		return true
	end

	function E.GetSkinFunc()
		return skins[C.db.profile.skin] and skins[C.db.profile.skin].func or  skins.Default.func
	end

	function E.GetNumSkins()
		return num
	end

	function E.GetAllSkins()
		local t = {}

		for k in next, skins do
			t[k] = k
		end

		return t
	end
end

--------------
-- SETTINGS --
--------------

function E.UpdateScale(_, value)
	anchorFrame:SetSize(234 * value, 58 * value)

	for _, toast in next, queuedToasts do
		toast:SetScale(value)
	end

	for _, toast in next, activeToasts do
		toast:SetScale(value)
	end

	for _, toast in next, createdToasts do
		toast:SetScale(value)
	end
end

function E.UpdateFadeOutDelay(_, value)
	for _, toast in next, queuedToasts do
		toast.AnimOut.Anim:SetStartDelay(value)
	end

	for _, toast in next, activeToasts do
		toast.AnimOut.Anim:SetStartDelay(value)
	end

	for _, toast in next, createdToasts do
		toast.AnimOut.Anim:SetStartDelay(value)
	end
end

function E.UpdateStrata(_, value)
	for _, toast in next, queuedToasts do
		toast:SetFrameStrata(value)
	end

	for _, toast in next, activeToasts do
		toast:SetFrameStrata(value)
	end

	for _, toast in next, createdToasts do
		toast:SetFrameStrata(value)
	end
end
