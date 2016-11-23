local addonName, addonTable = ...
local L = addonTable.L

-- Lua
local _G = _G
local math = _G.math
local string = _G.string
local table = _G.table
local hooksecurefunc = _G.hooksecurefunc
local next = _G.next
local pairs = _G.pairs
local pcall = _G.pcall
local print = _G.print
local select = _G.select
local tonumber = _G.tonumber
local type = _G.type
local unpack = _G.unpack

-- Blizz
local Lerp = _G.Lerp

-- Mine
local INLINE_NEED = "|TInterface\\Buttons\\UI-GroupLoot-Dice-Up:0:0:0:0:32:32:0:32:0:31|t"
local INLINE_GREED = "|TInterface\\Buttons\\UI-GroupLoot-Coin-Up:0:0:0:0:32:32:0:32:0:31|t"
local INLINE_DE = "|TInterface\\Buttons\\UI-GroupLoot-DE-Up:0:0:0:0:32:32:0:32:0:31|t"
local abilityToasts = {}
local achievementToasts = {}
local activeToasts = {}
local followerToasts = {}
local itemToasts = {}
local miscToasts = {}
local missonToasts = {}
local queuedToasts = {}
local scenarioToasts = {}
local textsToAnimate = {}
local toastCounter = 0

local EQUIP_SLOTS = {
	["INVTYPE_HEAD"] = {_G.INVSLOT_HEAD},
	["INVTYPE_NECK"] = {_G.INVSLOT_NECK},
	["INVTYPE_SHOULDER"] = {_G.INVSLOT_SHOULDER},
	["INVTYPE_CHEST"] = {_G.INVSLOT_CHEST},
	["INVTYPE_ROBE"] = {_G.INVSLOT_CHEST},
	["INVTYPE_WAIST"] = {_G.INVSLOT_WAIST},
	["INVTYPE_LEGS"] = {_G.INVSLOT_LEGS},
	["INVTYPE_FEET"] = {_G.INVSLOT_FEET},
	["INVTYPE_WRIST"] = {_G.INVSLOT_WRIST},
	["INVTYPE_HAND"] = {_G.INVSLOT_HAND},
	["INVTYPE_FINGER"] = {_G.INVSLOT_FINGER1, _G.INVSLOT_FINGER2},
	["INVTYPE_TRINKET"] = {_G.INVSLOT_TRINKET1, _G.INVSLOT_TRINKET1},
	["INVTYPE_CLOAK"] = {_G.INVSLOT_BACK},
	["INVTYPE_WEAPON"] = {_G.INVSLOT_MAINHAND, _G.INVSLOT_OFFHAND},
	["INVTYPE_2HWEAPON"] = {_G.INVSLOT_MAINHAND},
	["INVTYPE_WEAPONMAINHAND"] = {_G.INVSLOT_MAINHAND},
	["INVTYPE_HOLDABLE"] = {_G.INVSLOT_OFFHAND},
	["INVTYPE_SHIELD"] = {_G.INVSLOT_OFFHAND},
	["INVTYPE_WEAPONOFFHAND"] = {_G.INVSLOT_OFFHAND},
	["INVTYPE_RANGED"] = {_G.INVSLOT_RANGED},
	["INVTYPE_RANGEDRIGHT"] = {_G.INVSLOT_RANGED},
	["INVTYPE_RELIC"] = {_G.INVSLOT_RANGED},
	["INVTYPE_THROWN"] = {_G.INVSLOT_RANGED},
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
}

------------
-- CONFIG --
------------

local CFG = {}
local DEFAULTS = {
	growth_direction = "DOWN",
	point = {"TOPLEFT", "UIParent", "TOPLEFT", 24, -12},
	max_active_toasts = 12,
	sfx_enabled = true,
	fadeout_delay = 2.8,
	scale = 1,
	colored_names_enabled = false,
	dnd = {
		achievement = false,
		archaeology = false,
		recipe = false,
		garrison_6_0 = false,
		garrison_7_0 = true,
		instance = false, -- dungeon completion
		loot_special = false, -- includes blizz store items
		loot_common = false,
		loot_currency = false,
		world = false, -- world quest, invasion completion
		transmog = false,
	},
	achievement_enabled = true,
	archaeology_enabled = true,
	garrison_6_0_enabled = false,
	garrison_7_0_enabled = true,
	instance_enabled = true,
	loot_special_enabled = true,
	loot_common_enabled = false,
	loot_common_quality_threshold = 1,
	loot_currency_enabled = true,
	recipe_enabled = true,
	world_enabled = true,
	transmog_enabled = true,
}

------------
-- PUBLIC --
------------

local F = {} -- F for Functions
local PUBLIC = {
	[1] = F,
	[2] = CFG
}

_G[addonName] = PUBLIC

-- This function can be overridden by other addons
-- For toasts' structures, see definitions of CreateBaseToastButton and GetToast functions

function F:SkinToast() end

-- Parameters:
-- 	toast
-- 	toastType	- types: "item", "mission", "follower", "achievement", "ability", "scenario", "misc"

-- Import:
-- 	local toast_F = unpack(ls_Toasts)
-- 	function toast_F:SkinToast(toast, toastType) --[[body]] end

----------------
-- DISPATCHER --
----------------

local function EventHandler(self, event, ...)
	self[event](self, ...)
end

local dispatcher = _G.CreateFrame("Frame")
dispatcher:SetScript("OnEvent", EventHandler)

------------
-- ANCHOR --
------------

local function CalculatePosition(self)
	local selfCenterX, selfCenterY = self:GetCenter()
	local screenWidth = _G.UIParent:GetRight()
	local screenHeight = _G.UIParent:GetTop()
	local screenCenterX, screenCenterY = _G.UIParent:GetCenter()
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

	return p, p, math.floor(x + 0.5), math.floor(y + 0.5)
end

local function Anchor_OnDragStart(self)
	self:StartMoving()
end

local function Anchor_OnDragStop(self)
	self:StopMovingOrSizing()

	local anchor = "UIParent"
	local p, rP, x, y = CalculatePosition(self)

	self:ClearAllPoints()
	self:SetPoint(p, anchor, rP, x, y)

	CFG.point = {p, anchor, rP, x, y}
end

local anchorFrame = _G.CreateFrame("Frame", "LSToastAnchor", _G.UIParent)
anchorFrame:SetClampedToScreen(true)
anchorFrame:SetClampRectInsets(-24, 12, 12, -12)
anchorFrame:SetToplevel(true)
anchorFrame:RegisterForDrag("LeftButton")
anchorFrame:SetScript("OnDragStart", Anchor_OnDragStart)
anchorFrame:SetScript("OnDragStop", Anchor_OnDragStop)

do
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
end

local function Anchor_Enable()
	anchorFrame:EnableMouse(true)
	anchorFrame.BG:Show()
	anchorFrame.Text:Show()
end

local function Anchor_Disable()
	anchorFrame:EnableMouse(false)
	anchorFrame.BG:Hide()
	anchorFrame.Text:Hide()
end

-----------
-- UTILS --
-----------

local function FixItemLink(itemLink)
	itemLink = string.match(itemLink, "|H(.+)|h.+|h")
	local linkTable = {string.split(":", itemLink)}

	if linkTable[1] ~= "item" then
		return itemLink
	end

	if linkTable[12] ~= "" then
		linkTable[12] = ""

		table.remove(linkTable, 15 + (tonumber(linkTable[14]) or 0))
	end

	return table.concat(linkTable, ":")
end

local function DumpToasts()
	if #activeToasts > 0 then
		print("|cffffd200=== TOAST DUMP ===|r")
	end

	for _, toast in pairs(activeToasts) do
		print("|cff00ccff"..toast.type.." toast info:|r", "\nid:", toast.id, "\nlink:", toast.link, "\nchat event:", toast.chat)
	end
end

-- TODO: Remove it, when it's implemented by Blizzard
local function IsItemAnUpgrade(itemLink)
	if not _G.IsUsableItem(itemLink) then return false end

	local _, _, _, _, _, _, _, _, itemEquipLoc = _G.GetItemInfo(itemLink)
	local itemLevel = _G.GetDetailedItemLevelInfo(itemLink)
	local slot1, slot2 = unpack(EQUIP_SLOTS[itemEquipLoc] or {})

	if slot1 then
		local itemLinkInSlot1 = _G.GetInventoryItemLink("player", slot1)

		if itemLinkInSlot1 then
			local itemLevelInSlot1 = _G.GetDetailedItemLevelInfo(itemLinkInSlot1)

			if itemLevel > itemLevelInSlot1 then
				return true
			end
		else
			-- Make sure that slot is empty
			if not _G.GetInventoryItemID("player", slot1) then
				return true
			end
		end
	end

	if slot2 then
		local isSlot2Equippable = itemEquipLoc ~= "INVTYPE_WEAPON" and true or _G.CanDualWield()

		if isSlot2Equippable then
			local itemLinkInSlot2 = _G.GetInventoryItemLink("player", slot2)

			if itemLinkInSlot2 then
				local itemLevelInSlot2 = _G.GetDetailedItemLevelInfo(itemLinkInSlot2)

				if itemLevel > itemLevelInSlot2 then
					return true
				end
			else
				-- Make sure that slot is empty
				if not _G.GetInventoryItemID("player", slot2) then
					return true
				end
			end
		end
	end

	return false
end

--------------------
-- TEXT ANIMATION --
--------------------

local function ProcessAnimatedText()
	for text, targetValue in pairs(textsToAnimate) do
		local newValue

		if text._value >= targetValue then
			newValue = math.floor(Lerp(text._value, targetValue, 0.25))
		else
			newValue = math.ceil(Lerp(text._value, targetValue, 0.25))
		end

		if newValue == targetValue then
			text._value = nil
			textsToAnimate[text] = nil
		end

		text:SetText(newValue)
		text._value = newValue
	end
end

local function SetAnimatedText(self, value)
	self._value = tonumber(self:GetText()) or 1
	textsToAnimate[self] = value
end

_G.C_Timer.NewTicker(0.05, ProcessAnimatedText)

----------
-- MAIN --
----------

local function IsDNDEnabled()
	local counter = 0

	for k in pairs (CFG.dnd) do
		if k then
			counter = counter + 1
		end
	end

	return counter > 0
end

local function HasNonDNDToast()
	for i, queuedToast in pairs(queuedToasts) do
		if not queuedToast.dnd then
			-- I don't want to ruin non-DND toasts' order, k?
			table.insert(queuedToasts, 1, table.remove(queuedToasts, i))

			return true
		end
	end

	return false
end

local function SpawnToast(toast, isDND)
	if not toast then return end

	if #activeToasts >= CFG.max_active_toasts or (_G.InCombatLockdown() and isDND) then
		if _G.InCombatLockdown() and isDND then
			toast.dnd = true
		end

		table.insert(queuedToasts, toast)

		return false
	end

	if #activeToasts > 0 then
		if CFG.growth_direction == "DOWN" then
			toast:SetPoint("TOP", activeToasts[#activeToasts], "BOTTOM", 0, -4)
		elseif CFG.growth_direction == "UP" then
			toast:SetPoint("BOTTOM", activeToasts[#activeToasts], "TOP", 0, 4)
		elseif CFG.growth_direction == "LEFT" then
			toast:SetPoint("RIGHT", activeToasts[#activeToasts], "LEFT", -8, 0)
		elseif CFG.growth_direction == "RIGHT" then
			toast:SetPoint("LEFT", activeToasts[#activeToasts], "RIGHT", 8, 0)
		end
	else
		toast:SetPoint("TOPLEFT", anchorFrame, "TOPLEFT", 0, 0)
	end

	table.insert(activeToasts, toast)

	F:SkinToast(toast, toast.type)

	toast:Show()

	return true
end

local function RefreshToasts()
	for i = 1, #activeToasts do
		local activeToast = activeToasts[i]

		activeToast:ClearAllPoints()

		if i == 1 then
			activeToast:SetPoint("TOPLEFT", anchorFrame, "TOPLEFT", 0, 0)
		else
			if CFG.growth_direction == "DOWN" then
				activeToast:SetPoint("TOP", activeToasts[i - 1], "BOTTOM", 0, -4)
			elseif CFG.growth_direction == "UP" then
				activeToast:SetPoint("BOTTOM", activeToasts[i - 1], "TOP", 0, 4)
			elseif CFG.growth_direction == "LEFT" then
				activeToast:SetPoint("RIGHT", activeToasts[i - 1], "LEFT", -8, 0)
			elseif CFG.growth_direction == "RIGHT" then
				activeToast:SetPoint("LEFT", activeToasts[i - 1], "RIGHT", 8, 0)
			end
		end
	end

	local queuedToast = table.remove(queuedToasts, 1)

	if queuedToast then
		if _G.InCombatLockdown() and queuedToast.dnd then
			table.insert(queuedToasts, queuedToast)

			if HasNonDNDToast() then
				RefreshToasts()
			end
		else
			SpawnToast(queuedToast)
		end
	end
end

local function ResetToast(toast)
	toast.id = nil
	toast.dnd = nil
	toast.chat = nil
	toast.link = nil
	toast.itemCount = nil
	toast.soundFile = nil
	toast.usedRewards = nil
	toast:ClearAllPoints()
	toast:Hide()
	toast.BG:SetTexture("Interface\\AddOns\\ls_Toasts\\media\\toast-bg-default")
	toast.Icon:SetPoint("TOPLEFT", 7, -7)
	toast.Icon:SetSize(44, 44)
	toast.Title:SetText("")
	toast.Text:SetText("")
	toast.Text:SetTextColor(1, 1, 1)
	toast.TextBG:SetVertexColor(0, 0, 0)
	toast.AnimIn:Stop()
	toast.AnimOut:Stop()

	if toast.IconBorder then
		toast.IconBorder:Show()
		toast.IconBorder:SetVertexColor(1, 1, 1)
	end

	if toast.Count then
		toast.Count:SetText("")
	end

	if toast.Dragon then
		toast.Dragon:Hide()
	end

	if toast.UpgradeIcon then
		toast.UpgradeIcon:Hide()
	end

	if toast.Level then
		toast.Level:SetText("")
	end

	if toast.Points then
		toast.Points:SetText("")
	end

	if toast.Rank then
		toast.Rank:SetText("")
	end

	if toast.IconText then
		toast.IconText:SetText("")
	end

	if toast.Bonus then
		toast.Bonus:Hide()
	end

	if toast.Heroic then
		toast.Heroic:Hide()
	end

	if toast.Arrows then
		toast.Arrows.Anim:Stop()
	end

	if toast.Reward1 then
		for i = 1, 5 do
			toast["Reward"..i]:Hide()
		end
	end
end

local function RecycleToast(toast)
	for i, activeToast in pairs(activeToasts) do
		if toast == activeToast then
			table.remove(activeToasts, i)

			if toast.type == "item" then
				table.insert(itemToasts, toast)
			elseif toast.type == "mission" then
				table.insert(missonToasts, toast)
			elseif toast.type == "follower" then
				table.insert(followerToasts, toast)
			elseif toast.type == "achievement" then
				table.insert(achievementToasts, toast)
			elseif toast.type == "ability" then
				table.insert(abilityToasts, toast)
			elseif toast.type == "scenario" then
				table.insert(scenarioToasts, toast)
			elseif toast.type == "misc" then
				table.insert(miscToasts, toast)
			end

			ResetToast(toast)
		end
	end

	RefreshToasts()
end

local function GetToastToUpdate(id, toastType)
	for _, toast in pairs(activeToasts) do
		if not toast.chat and toastType == toast.type and (id == toast.id or id == toast.link) then
			return toast, false
		end
	end

	for _, toast in pairs(queuedToasts) do
		if not toast.chat and toastType == toast.type and (id == toast.id or id == toast.link) then
			return toast, true
		end
	end

	return
end

local function UpdateToast(id, toastType, itemLink)
	local toast, isQueued = GetToastToUpdate(id, toastType)

	if toast then
		toast.usedRewards = toast.usedRewards + 1
		local reward = toast["Reward"..toast.usedRewards]

		if reward then
			local _, _, _, _, texture = _G.GetItemInfoInstant(itemLink)
			local isOK = pcall(_G.SetPortraitToTexture, reward.Icon, texture)

			if not isOK then
				_G.SetPortraitToTexture(reward.Icon, "Interface\\Icons\\INV_Box_02")
			end

			reward.item = itemLink
			reward:Show()
		end

		if not isQueued then
			toast.AnimOut:Stop()
			toast.AnimOut:Play()
		end
	end
end

local function ToastButton_OnShow(self)
	local soundFile = self.soundFile

	if CFG.sfx_enabled and soundFile then
		if type(soundFile) == "number" then
			_G.PlaySoundKitID(soundFile)
		elseif type(soundFile) == "string" then
			_G.PlaySound(soundFile)
		end
	end

	self.AnimIn:Play()
	self.AnimOut:Play()
end

local function ToastButton_OnClick(self, button)
	if button == "RightButton" then
		RecycleToast(self)
	elseif button == "LeftButton" then
		if self.id then
			if self.type == "achievement" then
				if not _G.AchievementFrame then
					_G.AchievementFrame_LoadUI()
				end

				_G.ShowUIPanel(_G.AchievementFrame)
				_G.AchievementFrame_SelectAchievement(self.id)
			elseif self.type == "follower" then
				if not _G.GarrisonLandingPage then
					_G.Garrison_LoadUI()
				end

				if _G.GarrisonLandingPage then
					_G.ShowGarrisonLandingPage(_G.GarrisonFollowerOptions[_G.C_Garrison.GetFollowerInfo(self.id).followerTypeID].garrisonType)
				end
			elseif self.type == "misc" then
				if self.link then
					if string.sub(self.link, 1, 18) == "transmogappearance" then
						if not _G.CollectionsJournal then
							_G.CollectionsJournal_LoadUI()
						end

						if _G.CollectionsJournal then
							_G.WardrobeCollectionFrame_OpenTransmogLink(self.link)
						end
					end
				end
			end
		end
	end
end

local function ToastButton_OnEnter(self)
	if self.id then
		if self.type == "item" then
			_G.GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT", -2, 2)
			_G.GameTooltip:SetItemByID(self.id)
			_G.GameTooltip:Show()
		elseif self.type == "follower" then
			local isOK, link = pcall(_G.C_Garrison.GetFollowerLink, self.id)

			if not isOK then
				isOK, link = pcall(_G.C_Garrison.GetFollowerLinkByID, self.id)
			end

			if isOK and link then
				local _, garrisonFollowerID, quality, level, itemLevel, ability1, ability2, ability3, ability4, trait1, trait2, trait3, trait4, spec1 = string.split(":", link)
				local followerType = _G.C_Garrison.GetFollowerTypeByID(tonumber(garrisonFollowerID))
				_G.GarrisonFollowerTooltip_Show(tonumber(garrisonFollowerID), false, tonumber(quality), tonumber(level), 0, 0, tonumber(itemLevel), tonumber(spec1), tonumber(ability1), tonumber(ability2), tonumber(ability3), tonumber(ability4), tonumber(trait1), tonumber(trait2), tonumber(trait3), tonumber(trait4))

				if followerType == _G.LE_FOLLOWER_TYPE_SHIPYARD_6_2 then
					_G.GarrisonShipyardFollowerTooltip:ClearAllPoints()
					_G.GarrisonShipyardFollowerTooltip:SetPoint("TOPLEFT", self, "BOTTOMRIGHT", -2, 2)
				else
					_G.GarrisonFollowerTooltip:ClearAllPoints()
					_G.GarrisonFollowerTooltip:SetPoint("TOPLEFT", self, "BOTTOMRIGHT", -2, 2)
				end
			end
		elseif self.type == "ability" then
			_G.GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT", -2, 2)
			_G.GameTooltip:SetSpellByID(self.id)
			_G.GameTooltip:Show()
		end
	elseif self.link then
		if self.type == "item" then
			if string.find(self.link, "battlepet:") then
				local _, speciesID, level, breedQuality, maxHealth, power, speed = string.split(":", self.link)
				_G.GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT", -2, 2)
				_G.GameTooltip:Show()
				_G.BattlePetToolTip_Show(tonumber(speciesID), tonumber(level), tonumber(breedQuality), tonumber(maxHealth), tonumber(power), tonumber(speed))
			else
				_G.GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT", -2, 2)
				_G.GameTooltip:SetHyperlink(self.link)
				_G.GameTooltip:Show()
			end
		end
	end

	self.AnimOut:Stop()

	dispatcher:RegisterEvent("MODIFIER_STATE_CHANGED")
end

local function ToastButton_OnLeave(self)
	_G.GameTooltip:Hide()
	_G.GarrisonFollowerTooltip:Hide()
	_G.GarrisonShipyardFollowerTooltip:Hide()
	_G.BattlePetTooltip:Hide()

	self.AnimOut:Play()

	dispatcher:UnregisterEvent("MODIFIER_STATE_CHANGED")
end

function dispatcher:MODIFIER_STATE_CHANGED()
	if _G.IsModifiedClick("COMPAREITEMS") or _G.GetCVarBool("alwaysCompareItems") then
		_G.GameTooltip_ShowCompareItem()
	else
		_G.ShoppingTooltip1:Hide()
		_G.ShoppingTooltip2:Hide()
	end
end

local function ToastButtonAnimIn_OnStop(self)
	local frame = self:GetParent()

	if frame.Arrows then
		frame.Arrows.requested = false
	end
end

local function ToastButtonAnimIn_OnFinished(self)
	local frame = self:GetParent()

	if frame.Arrows and frame.Arrows.requested then
		--- XXX: Parent translation anims affect child's translation anims
		_G.C_Timer.After(0.1, function() frame.Arrows.Anim:Play() end)

		frame.Arrows.requested = false
	end
end

local function ToastButtonAnimOut_OnFinished(self)
	RecycleToast(self:GetParent())
end

local function CreateBaseToastButton()
	toastCounter = toastCounter + 1

	local toast = _G.CreateFrame("Button", "LSToast"..toastCounter, _G.UIParent)
	toast:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	toast:Hide()
	toast:SetScript("OnShow", ToastButton_OnShow)
	toast:SetScript("OnClick", ToastButton_OnClick)
	toast:SetScript("OnEnter", ToastButton_OnEnter)
	toast:SetScript("OnLeave", ToastButton_OnLeave)
	toast:SetSize(234, 58)
	toast:SetScale(CFG.scale)
	toast:SetFrameStrata("DIALOG")

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
	toast.Text = text

	local textBG = toast:CreateTexture(nil, "BACKGROUND", nil, 2)
	textBG:SetSize(174, 44)
	textBG:SetPoint("BOTTOMLEFT", 53, 7)
	textBG:SetTexture("Interface\\AddOns\\ls_Toasts\\media\\toast-text-bg")
	textBG:SetTexCoord(1 / 256, 175 / 256, 1 / 64, 45 / 64)
	textBG:SetVertexColor(0, 0, 0)
	toast.TextBG = textBG

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

	local animIn = toast:CreateAnimationGroup()
	animIn:SetScript("OnStop", ToastButtonAnimIn_OnStop)
	animIn:SetScript("OnFinished", ToastButtonAnimIn_OnFinished)
	toast.AnimIn = animIn

	local anim1 = animIn:CreateAnimation("Alpha")
	anim1:SetChildKey("Glow")
	anim1:SetOrder(1)
	anim1:SetFromAlpha(0)
	anim1:SetToAlpha(1)
	anim1:SetDuration(0.2)

	local anim2 = animIn:CreateAnimation("Alpha")
	anim2:SetChildKey("Glow")
	anim2:SetOrder(2)
	anim2:SetFromAlpha(1)
	anim2:SetToAlpha(0)
	anim2:SetDuration(0.5)

	local anim3 = animIn:CreateAnimation("Alpha")
	anim3:SetChildKey("Shine")
	anim3:SetOrder(1)
	anim3:SetFromAlpha(0)
	anim3:SetToAlpha(1)
	anim3:SetDuration(0.2)

	local anim4 = animIn:CreateAnimation("Translation")
	anim4:SetChildKey("Shine")
	anim4:SetOrder(2)
	anim4:SetOffset(168, 0)
	anim4:SetDuration(0.85)

	local anim5 = animIn:CreateAnimation("Alpha")
	anim5:SetChildKey("Shine")
	anim5:SetOrder(2)
	anim5:SetFromAlpha(1)
	anim5:SetToAlpha(0)
	anim5:SetStartDelay(0.35)
	anim5:SetDuration(0.5)

	local animOut = toast:CreateAnimationGroup()
	animOut:SetScript("OnFinished", ToastButtonAnimOut_OnFinished)
	toast.AnimOut = animOut

	anim1 = animOut:CreateAnimation("Alpha")
	anim1:SetOrder(1)
	anim1:SetFromAlpha(1)
	anim1:SetToAlpha(0)
	anim1:SetStartDelay(CFG.fadeout_delay)
	anim1:SetDuration(1.2)
	animOut.Anim1 = anim1

	return toast
end

local ARROW_CFG = {
	[1] = {startDelay1 = 0.9, startDelay2 = 1.2, point = {"TOP", "$parent", "CENTER", 8, 0}},
	[2] = {startDelay1 = 1.0, startDelay2 = 1.3, point = {"CENTER", "$parentArrow1", 16, 0}},
	[3] = {startDelay1 = 1.1, startDelay2 = 1.4, point = {"CENTER", "$parentArrow1", -16, 0}},
	[4] = {startDelay1 = 1.3, startDelay2 = 1.6, point = {"CENTER", "$parentArrow1", 5, 0}},
	[5] = {startDelay1 = 1.5, startDelay2 = 1.8, point = {"CENTER", "$parentArrow1", -12, 0}},
}

local function ShowArrows(self)
	self:GetParent():Show()
end

local function HideArrows(self)
	self:GetParent():Hide()
end

local function CreateUpdateArrowsAnim(parent)
	local frame = _G.CreateFrame("Frame", "$parentUpgradeArrows", parent)
	frame:SetSize(48, 48)
	frame:Hide()

	local ag = frame:CreateAnimationGroup()
	ag:SetScript("OnPlay", ShowArrows)
	ag:SetScript("OnFinished", HideArrows)
	ag:SetScript("OnStop", HideArrows)
	frame.Anim = ag

	for i = 1, 5 do
		frame["Arrow"..i] = frame:CreateTexture("$parentArrow"..i, "ARTWORK", "LootUpgradeFrame_ArrowTemplate")
		frame["Arrow"..i]:ClearAllPoints()
		frame["Arrow"..i]:SetPoint(unpack(ARROW_CFG[i].point))

		local anim = ag:CreateAnimation("Alpha")
		anim:SetChildKey("Arrow"..i)
		anim:SetDuration(0)
		anim:SetOrder(1)
		anim:SetFromAlpha(1)
		anim:SetToAlpha(0)

		anim = ag:CreateAnimation("Alpha")
		anim:SetChildKey("Arrow"..i)
		anim:SetStartDelay(ARROW_CFG[i].startDelay1)
		anim:SetSmoothing("IN")
		anim:SetDuration(0.2)
		anim:SetOrder(2)
		anim:SetFromAlpha(0)
		anim:SetToAlpha(1)

		anim = ag:CreateAnimation("Alpha")
		anim:SetChildKey("Arrow"..i)
		anim:SetStartDelay(ARROW_CFG[i].startDelay2)
		anim:SetSmoothing("OUT")
		anim:SetDuration(0.2)
		anim:SetOrder(2)
		anim:SetFromAlpha(1)
		anim:SetToAlpha(0)

		anim = ag:CreateAnimation("Translation")
		anim:SetChildKey("Arrow"..i)
		anim:SetStartDelay(ARROW_CFG[i].startDelay1)
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

	return frame
end

local function Reward_OnEnter(self)
	self:GetParent().AnimOut:Stop()

	_G.GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT")

	if self.item then
		_G.GameTooltip:SetHyperlink(self.item)
	elseif self.xp then
		_G.GameTooltip:AddLine(L["YOU_RECEIVED"])
		_G.GameTooltip:AddLine(string.format(L["XP_FORMAT"], self.xp), 1, 1, 1)
	elseif self.money then
		_G.GameTooltip:AddLine(L["YOU_RECEIVED"])
		_G.GameTooltip:AddLine(_G.GetMoneyString(self.money), 1, 1, 1)
	elseif self.currency then
		_G.GameTooltip:SetQuestLogCurrency("reward", self.currency, self:GetParent().id)
	end

	_G.GameTooltip:Show()
end

local function Reward_OnLeave(self)
	self:GetParent().AnimOut:Play()
	_G.GameTooltip:Hide()
end

local function Reward_OnHide(self)
	self.currency = nil
	self.money = nil
	self.item = nil
	self.xp = nil
end

local function CreateToastReward(parent, index)
	local reward = _G.CreateFrame("Frame", "$parent"..index, parent)
	reward:SetSize(30, 30)
	reward:SetScript("OnEnter", Reward_OnEnter)
	reward:SetScript("OnLeave", Reward_OnLeave)
	reward:SetScript("OnHide", Reward_OnHide)
	reward:Hide()
	parent["Reward"..index] = reward

	local icon = reward:CreateTexture(nil, "BACKGROUND")
	icon:SetPoint("TOPLEFT", 5, -4)
	icon:SetPoint("BOTTOMRIGHT", -7, 8)
	reward.Icon = icon

	local border = reward:CreateTexture(nil, "BORDER")
	border:SetAllPoints()
	border:SetTexture("Interface\\LFGFrame\\UI-LFG-ICON-REWARDRING")
	border:SetTexCoord(0 / 64, 40 / 64, 0 / 64, 40 / 64)

	return reward
end

local function GetToast(toastType)
	local toast

	if toastType == "item" then
		toast = table.remove(itemToasts, 1)

		if not toast then
			toast = CreateBaseToastButton()

			local arrows = CreateUpdateArrowsAnim(toast)
			arrows:SetPoint("TOPLEFT", -5, 5)
			toast.Arrows = arrows

			local iconBorder = toast:CreateTexture(nil, "ARTWORK", nil, 2)
			iconBorder:SetPoint("TOPLEFT", 7, -7)
			iconBorder:SetSize(44, 44)
			iconBorder:SetTexture("Interface\\AddOns\\ls_Toasts\\media\\toast-icon-border")
			iconBorder:SetTexCoord(1 / 64, 45 / 64, 1 / 64, 45 / 64)
			toast.IconBorder = iconBorder

			local count = toast:CreateFontString(nil, "ARTWORK", "GameFontHighlightOutline")
			count:SetPoint("BOTTOMRIGHT", toast.Icon, "BOTTOMRIGHT", 0, 2)
			count:SetJustifyH("RIGHT")
			count.SetAnimatedText = SetAnimatedText
			toast.Count = count

			local countUpdate = toast:CreateFontString(nil, "ARTWORK", "GameFontHighlightOutline")
			countUpdate:SetPoint("BOTTOMRIGHT", toast.Count, "TOPRIGHT", 0, 2)
			countUpdate:SetJustifyH("RIGHT")
			countUpdate:SetAlpha(0)
			toast.CountUpdate = countUpdate

			local upgradeIcon = toast:CreateTexture(nil, "ARTWORK", nil, 3)
			upgradeIcon:SetAtlas("bags-greenarrow", true)
			upgradeIcon:SetPoint("TOPLEFT", 4, -4)
			upgradeIcon:Hide()
			toast.UpgradeIcon = upgradeIcon

			local ag = toast:CreateAnimationGroup()
			toast.CountUpdateAnim = ag

			local anim1 = ag:CreateAnimation("Alpha")
			anim1:SetChildKey("CountUpdate")
			anim1:SetOrder(1)
			anim1:SetFromAlpha(0)
			anim1:SetToAlpha(1)
			anim1:SetDuration(0.2)

			local anim2 = ag:CreateAnimation("Alpha")
			anim2:SetChildKey("CountUpdate")
			anim2:SetOrder(2)
			anim2:SetFromAlpha(1)
			anim2:SetToAlpha(0)
			anim2:SetStartDelay(0.4)
			anim2:SetDuration(0.8)

			local dragon = toast:CreateTexture(nil, "OVERLAY", nil, 0)
			dragon:SetPoint("TOPLEFT", -23, 13)
			dragon:SetSize(88, 88)
			dragon:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Gold-Dragon")
			dragon:SetVertexColor(250 / 255, 200 / 255, 0 / 255)
			dragon:Hide()
			toast.Dragon = dragon

			toast.type = "item"
		end
	elseif toastType == "mission" then
		toast = table.remove(missonToasts, 1)

		if not toast then
			toast = CreateBaseToastButton()

			local level = toast:CreateFontString(nil, "ARTWORK", "GameFontHighlightOutline")
			level:SetPoint("BOTTOMRIGHT", toast.Icon, "BOTTOMRIGHT", 0, 2)
			level:SetJustifyH("RIGHT")
			toast.Level = level

			toast.type = "mission"
		end
	elseif toastType == "follower" then
		toast = table.remove(followerToasts, 1)

		if not toast then
			toast = CreateBaseToastButton()

			local arrows = CreateUpdateArrowsAnim(toast)
			arrows:SetPoint("TOPLEFT", -5, 5)
			toast.Arrows = arrows

			local level = toast:CreateFontString(nil, "ARTWORK", "GameFontHighlightOutline")
			level:SetPoint("BOTTOMRIGHT", toast.Icon, "BOTTOMRIGHT", 0, 2)
			level:SetJustifyH("RIGHT")
			toast.Level = level

			toast.type = "follower"
		end
	elseif toastType == "achievement" then
		toast = table.remove(achievementToasts, 1)

		if not toast then
			toast = CreateBaseToastButton()

			local iconBorder = toast:CreateTexture(nil, "ARTWORK", nil, 2)
			iconBorder:SetPoint("TOPLEFT", 7, -7)
			iconBorder:SetSize(44, 44)
			iconBorder:SetTexture("Interface\\AddOns\\ls_Toasts\\media\\toast-icon-border")
			iconBorder:SetTexCoord(1 / 64, 45 / 64, 1 / 64, 45 / 64)
			toast.IconBorder = iconBorder

			local points = toast:CreateFontString(nil, "ARTWORK", "GameFontHighlightOutline")
			points:SetPoint("BOTTOMRIGHT", toast.Icon, "BOTTOMRIGHT", 0, 2)
			points:SetJustifyH("RIGHT")
			toast.Points = points

			toast.type = "achievement"
		end
	elseif toastType == "ability" then
		toast = table.remove(abilityToasts, 1)

		if not toast then
			toast = CreateBaseToastButton()

			local iconBorder = toast:CreateTexture(nil, "ARTWORK", nil, 2)
			iconBorder:SetPoint("TOPLEFT", 7, -7)
			iconBorder:SetSize(44, 44)
			iconBorder:SetTexture("Interface\\AddOns\\ls_Toasts\\media\\toast-icon-border")
			iconBorder:SetTexCoord(1 / 64, 45 / 64, 1 / 64, 45 / 64)
			toast.IconBorder = iconBorder

			local rank = toast:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
			rank:SetPoint("BOTTOMRIGHT", toast.Icon, "BOTTOMRIGHT", -2, 2)
			rank:SetJustifyH("RIGHT")
			toast.Rank = rank

			toast.type = "ability"
		end
	elseif toastType == "scenario" then
		toast = table.remove(scenarioToasts, 1)

		if not toast then
			toast = CreateBaseToastButton()

			local iconBorder = toast:CreateTexture(nil, "ARTWORK", nil, 2)
			iconBorder:SetPoint("TOPLEFT", 7, -7)
			iconBorder:SetSize(44, 44)
			iconBorder:SetTexture("Interface\\AddOns\\ls_Toasts\\media\\toast-icon-border")
			iconBorder:SetTexCoord(1 / 64, 45 / 64, 1 / 64, 45 / 64)
			toast.IconBorder = iconBorder

			for i = 1, 5 do
				local reward = CreateToastReward(toast, i)

				if i == 1 then
					reward:SetPoint("TOPRIGHT", -2, 10)
				else
					reward:SetPoint("RIGHT", toast["Reward"..(i - 1)], "LEFT", -2 , 0)
				end
			end

			local bonus = toast:CreateTexture(nil, "ARTWORK")
			bonus:SetAtlas("Bonus-ToastBanner", true)
			bonus:SetPoint("TOPRIGHT", -4, 0)
			bonus:Hide()
			toast.Bonus = bonus

			local heroic = toast:CreateTexture(nil, "ARTWORK", nil, 2)
			heroic:SetSize(16, 20)
			heroic:SetTexture("Interface\\LFGFrame\\UI-LFG-ICON-HEROIC")
			heroic:SetTexCoord(0 / 32, 16 / 32, 0 / 32, 20 / 32)
			heroic:SetPoint("BOTTOMRIGHT", toast.Icon, "BOTTOMRIGHT", -2, 0)
			heroic:Hide()
			toast.Heroic = heroic

			toast.type = "scenario"
		end
	elseif toastType == "misc" then
		toast = table.remove(miscToasts, 1)

		if not toast then
			toast = CreateBaseToastButton()

			local iconBorder = toast:CreateTexture(nil, "ARTWORK", nil, 2)
			iconBorder:SetPoint("TOPLEFT", 7, -7)
			iconBorder:SetSize(44, 44)
			iconBorder:SetTexture("Interface\\AddOns\\ls_Toasts\\media\\toast-icon-border")
			iconBorder:SetTexCoord(1 / 64, 45 / 64, 1 / 64, 45 / 64)
			toast.IconBorder = iconBorder

			local text = toast:CreateFontString(nil, "ARTWORK", "GameFontHighlightOutline")
			text:SetPoint("BOTTOMRIGHT", toast.Icon, "BOTTOMRIGHT", 0, 2)
			text:SetJustifyH("RIGHT")
			toast.IconText = text

			toast.type = "misc"
		end
	end

	return toast
end

------------------
-- ANCHOR HIDER --
------------------

function dispatcher:PLAYER_REGEN_DISABLED()
	if anchorFrame:IsMouseEnabled() then
		Anchor_OnDragStop(anchorFrame)
		Anchor_Disable()
	end
end

dispatcher:RegisterEvent("PLAYER_REGEN_DISABLED")

---------
-- DND --
---------

function dispatcher:PLAYER_REGEN_ENABLED()
	if IsDNDEnabled() and #queuedToasts > 0 then
		for _ = 1, CFG.max_active_toasts - #activeToasts do
			RefreshToasts()
		end
	end
end

dispatcher:RegisterEvent("PLAYER_REGEN_ENABLED")

-----------------
-- ACHIEVEMENT --
-----------------

local function AchievementToast_SetUp(achievementID, flag, isCriteria)
	local toast = GetToast("achievement")
	local _, name, points, _, _, _, _, _, _, icon = _G.GetAchievementInfo(achievementID)

	if isCriteria then
		toast.Title:SetText(L["ACHIEVEMENT_PROGRESSED"])
		toast.Text:SetText(flag)

		toast.Border:SetVertexColor(1, 1, 1)
		toast.IconBorder:SetVertexColor(1, 1, 1)
		toast.Points:SetText("")
	else
		toast.Title:SetText(L["ACHIEVEMENT_UNLOCKED"])
		toast.Text:SetText(name)

		-- alreadyEarned
		if flag then
			toast.Border:SetVertexColor(1, 1, 1)
			toast.IconBorder:SetVertexColor(1, 1, 1)
			toast.Points:SetText("")
		else
			toast.Border:SetVertexColor(0.9, 0.75, 0.26)
			toast.IconBorder:SetVertexColor(0.9, 0.75, 0.26)
			toast.Points:SetText(points == 0 and "" or points)
		end
	end

	toast.Icon:SetTexture(icon)
	toast.id = achievementID

	SpawnToast(toast, CFG.dnd.achievement)
end

function dispatcher:ACHIEVEMENT_EARNED(...)
	local achievementID, alreadyEarned = ...

	AchievementToast_SetUp(achievementID, alreadyEarned, nil)

end

function dispatcher:CRITERIA_EARNED(...)
	local achievementID, criteriaString = ...

	AchievementToast_SetUp(achievementID, criteriaString, true)
end

local function EnableAchievementToasts()
	if CFG.achievement_enabled then
		dispatcher:RegisterEvent("ACHIEVEMENT_EARNED")
		dispatcher:RegisterEvent("CRITERIA_EARNED")
	end
end

local function DisableAchievementToasts()
	dispatcher:UnregisterEvent("ACHIEVEMENT_EARNED")
	dispatcher:UnregisterEvent("CRITERIA_EARNED")
end

-----------------
-- ARCHAEOLOGY --
-----------------

function dispatcher:ARTIFACT_DIGSITE_COMPLETE(...)
	local researchFieldID = ...
	local raceName, raceTexture	= _G.GetArchaeologyRaceInfoByID(researchFieldID)
	local toast = GetToast("misc")

	toast.Border:SetVertexColor(0.9, 0.4, 0.1)
	toast.Title:SetText(L["DIGSITE_COMPLETED"])
	toast.Text:SetText(raceName)
	toast.BG:SetTexture("Interface\\AddOns\\ls_Toasts\\media\\toast-bg-archaeology")
	toast.IconBorder:Hide()
	toast.Icon:SetPoint("TOPLEFT", 7, -3)
	toast.Icon:SetSize(76, 76)
	toast.Icon:SetTexture(raceTexture)
	toast.soundFile = "UI_DigsiteCompletion_Toast"

	SpawnToast(toast, CFG.dnd.archaeology)
end

local function ArcheologyProgressBarAnimOut_OnFinished(self)
	self:GetParent():Hide()
end

local function EnableArchaeologyToasts()
	if not _G.ArchaeologyFrame then
		local hooked = false

		hooksecurefunc("ArchaeologyFrame_LoadUI", function()
			if not hooked then
				_G.ArcheologyDigsiteProgressBar.AnimOutAndTriggerToast:SetScript("OnFinished", ArcheologyProgressBarAnimOut_OnFinished)

				hooked = true
			end
		end)
	else
		_G.ArcheologyDigsiteProgressBar.AnimOutAndTriggerToast:SetScript("OnFinished", ArcheologyProgressBarAnimOut_OnFinished)
	end

	if CFG.archaeology_enabled then
		dispatcher:RegisterEvent("ARTIFACT_DIGSITE_COMPLETE")
	end
end

local function DisableArchaeologyToasts()
	dispatcher:UnregisterEvent("ARTIFACT_DIGSITE_COMPLETE")
end

--------------
-- GARRISON --
--------------

local function GetGarrisonTypeByFollowerType(followerType)
	if followerType == _G.LE_FOLLOWER_TYPE_GARRISON_7_0 then
		return _G.LE_GARRISON_TYPE_7_0
	elseif followerType == _G.LE_FOLLOWER_TYPE_GARRISON_6_0 or followerType == _G.LE_FOLLOWER_TYPE_SHIPYARD_6_2 then
		return _G.LE_GARRISON_TYPE_6_0
	end
end

local function GarrisonMissionToast_SetUp(followerType, garrisonType, missionID, isAdded)
	local toast = GetToast("mission")
	local missionInfo = _G.C_Garrison.GetBasicMissionInfo(missionID)
	local color = missionInfo.isRare and _G.ITEM_QUALITY_COLORS[3] or _G.ITEM_QUALITY_COLORS[1]
	local level = missionInfo.iLevel == 0 and missionInfo.level or missionInfo.iLevel

	if isAdded then
		toast.Title:SetText(L["GARRISON_MISSION_ADDED"])
	else
		toast.Title:SetText(L["GARRISON_MISSION_COMPLETED"])
	end

	if CFG.colored_names_enabled then
		toast.Text:SetTextColor(color.r, color.g, color.b)
	end

	toast.Text:SetText(missionInfo.name)
	toast.Level:SetText(level)
	toast.Border:SetVertexColor(color.r, color.g, color.b)
	toast.Icon:SetAtlas(missionInfo.typeAtlas, false)
	toast.soundFile = "UI_Garrison_Toast_MissionComplete"
	toast.id = missionID

	SpawnToast(toast, garrisonType == _G.LE_GARRISON_TYPE_7_0 and CFG.dnd.garrison_7_0 or CFG.dnd.garrison_6_0)
end

function dispatcher:GARRISON_MISSION_FINISHED(...)
	local followerType, missionID = ...
	local garrisonType = GetGarrisonTypeByFollowerType(followerType)

	if (garrisonType == _G.LE_GARRISON_TYPE_7_0 and not CFG.garrison_7_0_enabled) or
		(garrisonType == _G.LE_GARRISON_TYPE_6_0 and not CFG.garrison_6_0_enabled) then
		return
	end

	local _, instanceType = _G.GetInstanceInfo()
	local validInstance = false

	if instanceType == "none" or _G.C_Garrison.IsOnGarrisonMap() then
		validInstance = true
	end

	if validInstance then
		GarrisonMissionToast_SetUp(followerType, garrisonType, missionID)
	end
end

function dispatcher:GARRISON_RANDOM_MISSION_ADDED(...)
	local followerType, missionID = ...
	local garrisonType = GetGarrisonTypeByFollowerType(followerType)

	if (garrisonType == _G.LE_GARRISON_TYPE_7_0 and not CFG.garrison_7_0_enabled) or
		(garrisonType == _G.LE_GARRISON_TYPE_6_0 and not CFG.garrison_6_0_enabled) then
		return
	end

	GarrisonMissionToast_SetUp(followerType, garrisonType, missionID, true)
end

local function GarrisonFollowerToast_SetUp(followerType, garrisonType, followerID, name, texPrefix, level, quality, isUpgraded)
	local toast = GetToast("follower")
	local followerInfo = _G.C_Garrison.GetFollowerInfo(followerID)
	local followerStrings = _G.GarrisonFollowerOptions[followerType].strings
	local upgradeTexture = _G.LOOTUPGRADEFRAME_QUALITY_TEXTURES[quality] or _G.LOOTUPGRADEFRAME_QUALITY_TEXTURES[2]
	local color = _G.ITEM_QUALITY_COLORS[quality]

	if followerType == _G.LE_FOLLOWER_TYPE_SHIPYARD_6_2 then
		toast.Icon:SetSize(84, 44)
		toast.Icon:SetAtlas(texPrefix.."-List", false)
		toast.Level:SetText("")
	else
		local portrait

		if followerInfo.portraitIconID and followerInfo.portraitIconID ~= 0 then
			portrait = followerInfo.portraitIconID
		else
			portrait = "Interface\\Garrison\\Portraits\\FollowerPortrait_NoPortrait"
		end

		toast.Icon:SetSize(44, 44)
		toast.Icon:SetTexture(portrait)
		toast.Level:SetText(level)
	end

	if isUpgraded then
		toast.Title:SetText(followerStrings.FOLLOWER_ADDED_UPGRADED_TOAST)
		toast.BG:SetTexture("Interface\\AddOns\\ls_Toasts\\media\\toast-bg-upgrade")

		for i = 1, 5 do
			toast.Arrows["Arrow"..i]:SetAtlas(upgradeTexture.arrow, true)
		end

		toast.Arrows.requested = true
	else
		toast.Title:SetText(followerStrings.FOLLOWER_ADDED_TOAST)
	end

	if CFG.colored_names_enabled then
		toast.Text:SetTextColor(color.r, color.g, color.b)
	end

	toast.Text:SetText(name)
	toast.Border:SetVertexColor(color.r, color.g, color.b)
	toast.soundFile = "UI_Garrison_Toast_FollowerGained"
	toast.id = followerID

	SpawnToast(toast, garrisonType == _G.LE_GARRISON_TYPE_7_0 and CFG.dnd.garrison_7_0 or CFG.dnd.garrison_6_0)
end

function dispatcher:GARRISON_FOLLOWER_ADDED(...)
	local followerID, name, _, level, quality, isUpgraded, texPrefix, followerType = ...
	local garrisonType = GetGarrisonTypeByFollowerType(followerType)

	if (garrisonType == _G.LE_GARRISON_TYPE_7_0 and not CFG.garrison_7_0_enabled) or
		(garrisonType == _G.LE_GARRISON_TYPE_6_0 and not CFG.garrison_6_0_enabled) then
		return
	end

	GarrisonFollowerToast_SetUp(followerType, garrisonType, followerID, name, texPrefix, level, quality, isUpgraded)
end

function dispatcher:GARRISON_BUILDING_ACTIVATABLE(...)
	local buildingName = ...
	local toast = GetToast("misc")

	toast.Title:SetText(L["GARRISON_NEW_BUILDING"])
	toast.Text:SetText(buildingName)
	toast.Icon:SetTexture("Interface\\Icons\\Garrison_Build")
	toast.soundFile = "UI_Garrison_Toast_BuildingComplete"

	SpawnToast(toast, CFG.dnd.garrison_6_0)
end

function dispatcher:GARRISON_TALENT_COMPLETE(...)
	local garrisonType = ...
	local talentID = _G.C_Garrison.GetCompleteTalent(garrisonType)
	local talent = _G.C_Garrison.GetTalent(talentID)
	local toast = GetToast("misc")

	toast.Title:SetText(L["GARRISON_NEW_TALENT"])
	toast.Text:SetText(talent.name)
	toast.Icon:SetTexture(talent.icon)
	toast.soundFile = "UI_OrderHall_Talent_Ready_Toast"

	SpawnToast(toast, CFG.dnd.garrison_7_0)
end

local function EnableGarrisonToasts()
	if CFG.garrison_6_0_enabled or CFG.garrison_7_0_enabled then
		dispatcher:RegisterEvent("GARRISON_FOLLOWER_ADDED")
		dispatcher:RegisterEvent("GARRISON_MISSION_FINISHED")
		dispatcher:RegisterEvent("GARRISON_RANDOM_MISSION_ADDED")

		if CFG.garrison_6_0_enabled then
			dispatcher:RegisterEvent("GARRISON_BUILDING_ACTIVATABLE")
		end

		if CFG.garrison_7_0_enabled then
			dispatcher:RegisterEvent("GARRISON_TALENT_COMPLETE")
		end
	end
end

local function DisableGarrisonToasts()
	if not CFG.garrison_6_0_enabled and not CFG.garrison_7_0_enabled then
		dispatcher:UnregisterEvent("GARRISON_FOLLOWER_ADDED")
		dispatcher:UnregisterEvent("GARRISON_MISSION_FINISHED")
		dispatcher:UnregisterEvent("GARRISON_RANDOM_MISSION_ADDED")
	end

	if not CFG.garrison_6_0_enabled then
		dispatcher:UnregisterEvent("GARRISON_BUILDING_ACTIVATABLE")
	end

	if not CFG.garrison_7_0_enabled then
		dispatcher:UnregisterEvent("GARRISON_TALENT_COMPLETE")
	end
end

--------------
-- INSTANCE --
--------------

local function LFGToast_SetUp(isScenario)
	local toast = GetToast("scenario")
	local name, _, subtypeID, textureFilename, moneyBase, moneyVar, experienceBase, experienceVar, numStrangers, numRewards = _G.GetLFGCompletionReward()
	-- local name, typeID, subtypeID, textureFilename, moneyBase, moneyVar, experienceBase, experienceVar, numStrangers, numRewards =
		-- "The Vortex Pinnacle", 1, 2, "THEVORTEXPINNACLE", 308000, 0, 0, 0, 0, 0
	local money = moneyBase + moneyVar * numStrangers
	local xp = experienceBase + experienceVar * numStrangers
	local title = L["DUNGEON_COMPLETED"]
	local usedRewards = 0

	if money > 0 then
		usedRewards = usedRewards + 1
		local reward = toast["Reward"..usedRewards]

		if reward then
			_G.SetPortraitToTexture(reward.Icon, "Interface\\Icons\\inv_misc_coin_02")
			reward.money = money
			reward:Show()
		end
	end

	if xp > 0 and _G.UnitLevel("player") < _G.MAX_PLAYER_LEVEL then
		usedRewards = usedRewards + 1
		local reward = toast["Reward"..usedRewards]

		if reward then
			_G.SetPortraitToTexture(reward.Icon, "Interface\\Icons\\xp_icon")
			reward.xp = xp
			reward:Show()
		end
	end

	for i = 1, numRewards do
		usedRewards = usedRewards + 1
		local reward = toast["Reward"..usedRewards]

		if reward then
			local icon = _G.GetLFGCompletionRewardItem(i)
			local isOK = pcall(_G.SetPortraitToTexture, reward.Icon, icon)

			if not isOK then
				_G.SetPortraitToTexture(reward.Icon, "Interface\\Icons\\INV_Box_02")
			end

			reward.item = _G.GetLFGCompletionRewardItemLink(i)
			reward:Show()

			usedRewards = i
		end
	end

	if isScenario then
		local _, _, _, _, hasBonusStep, isBonusStepComplete = _G.C_Scenario.GetInfo()

		if hasBonusStep and isBonusStepComplete then
			toast.Bonus:Show()
		end

		title = L["SCENARIO_COMPLETED"]
	end

	if subtypeID == _G.LFG_SUBTYPEID_HEROIC then
		toast.Heroic:Show()
	end

	toast.Title:SetText(title)
	toast.Text:SetText(name)
	toast.BG:SetTexture("Interface\\AddOns\\ls_Toasts\\media\\toast-bg-dungeon")
	toast.Icon:SetTexture("Interface\\LFGFrame\\LFGIcon-"..textureFilename)
	toast.usedRewards = usedRewards

	if isScenario then
		toast.soundFile = "UI_Scenario_Ending"
	else
		toast.soundFile = "LFG_Rewards"
	end

	SpawnToast(toast, CFG.dnd.instance)
end

function dispatcher:LFG_COMPLETION_REWARD()
	if _G.C_Scenario.IsInScenario() and not _G.C_Scenario.TreatScenarioAsDungeon() then

		if select(10, _G.C_Scenario.GetInfo()) ~= _G.LE_SCENARIO_TYPE_LEGION_INVASION then
			LFGToast_SetUp(true)
		end
	else
		LFGToast_SetUp()
	end
end

local function EnableInstanceToasts()
	if CFG.instance_enabled then
		dispatcher:RegisterEvent("LFG_COMPLETION_REWARD")
	end
end

local function DisableInstanceToasts()
	dispatcher:UnregisterEvent("LFG_COMPLETION_REWARD")
end

----------
-- LOOT --
----------

local function LootWonToast_Setup(itemLink, quantity, rollType, roll, showFaction, isItem, isMoney, lessAwesome, isUpgraded, isPersonal)
	local toast

	if isItem then
		if itemLink then
			toast = GetToast("item")
			itemLink = FixItemLink(itemLink)
			local title = L["YOU_WON"]
			local name, _, quality, _, _, _, _, _, _, icon = _G.GetItemInfo(itemLink)

			if isPersonal or lessAwesome then
				title = L["YOU_RECEIVED"]
			end

			if isUpgraded then
				title = L["ITEM_UPGRADED"]
				local upgradeTexture = _G.LOOTUPGRADEFRAME_QUALITY_TEXTURES[quality or 2]

				for i = 1, 5 do
					toast.Arrows["Arrow"..i]:SetAtlas(upgradeTexture.arrow, true)
				end

				toast.Arrows.requested = true

				toast.BG:SetTexture("Interface\\AddOns\\ls_Toasts\\media\\toast-bg-upgrade")
			end

			if rollType == _G.LOOT_ROLL_TYPE_NEED then
				title = title.." |cff00ff00"..roll.."|r"..INLINE_NEED
			elseif rollType == _G.LOOT_ROLL_TYPE_GREED then
				title = title.." |cff00ff00"..roll.."|r"..INLINE_GREED
			elseif rollType == _G.LOOT_ROLL_TYPE_DISENCHANT then
				title = title.." |cff00ff00"..roll.."|r"..INLINE_DE
			end

			if showFaction then
				-- local factionGroup = "Horde"
				local factionGroup = _G.UnitFactionGroup("player")

				toast.BG:SetTexture("Interface\\AddOns\\ls_Toasts\\media\\toast-bg-"..factionGroup)
			end

			local color = _G.ITEM_QUALITY_COLORS[quality or 1]

			if CFG.colored_names_enabled then
				toast.Text:SetTextColor(color.r, color.g, color.b)
			end

			toast.Title:SetText(title)
			toast.Text:SetText(name)
			toast.Count:SetText(quantity > 1 and quantity or "")
			toast.Border:SetVertexColor(color.r, color.g, color.b)
			toast.IconBorder:SetVertexColor(color.r, color.g, color.b)
			toast.Icon:SetTexture(icon)
			toast.UpgradeIcon:SetShown(IsItemAnUpgrade(itemLink))
			toast.link = itemLink

			if lessAwesome then
				toast.soundFile = 51402
			elseif isUpgraded then
				toast.soundFile = 51561
			else
				toast.soundFile = 31578
			end
		end
	elseif isMoney then
		toast = GetToast("misc")

		toast.Border:SetVertexColor(0.9, 0.75, 0.26)
		toast.IconBorder:SetVertexColor(0.9, 0.75, 0.26)
		toast.Title:SetText(L["YOU_WON"])
		toast.Text:SetText(_G.GetMoneyString(quantity))
		toast.Icon:SetTexture("Interface\\Icons\\INV_Misc_Coin_02")
		toast.soundFile = 31578
	end

	if toast then
		SpawnToast(toast, CFG.dnd.loot_special)
	end
end

local function BonusRollFrame_FinishedFading_Disabled(self)
	local frame = self:GetParent()

	_G.GroupLootContainer_RemoveFrame(_G.GroupLootContainer, frame)
end

local function BonusRollFrame_FinishedFading_Enabled(self)
	local frame = self:GetParent()

	LootWonToast_Setup(frame.rewardLink, frame.rewardQuantity, nil, nil, nil, frame.rewardType == "item", frame.rewardType == "money")
	_G.GroupLootContainer_RemoveFrame(_G.GroupLootContainer, frame)
end

function dispatcher:LOOT_ITEM_ROLL_WON(...)
	local itemLink, quantity, rollType, roll, isUpgraded = ...

	LootWonToast_Setup(itemLink, quantity, rollType, roll, nil, true, nil, nil, isUpgraded)
end

function dispatcher:SHOW_LOOT_TOAST(...)
	local typeID, itemLink, quantity, _, _, isPersonal, _, lessAwesome, isUpgraded = ...

	LootWonToast_Setup(itemLink, quantity, nil, nil, nil, typeID == "item", typeID == "money", lessAwesome, isUpgraded, isPersonal)
end

function dispatcher:SHOW_LOOT_TOAST_LEGENDARY_LOOTED(...)
	local itemLink = ...

	if itemLink then
		local toast = GetToast("item")
		itemLink = FixItemLink(itemLink)
		local name, _, quality, _, _, _, _, _, _, icon = _G.GetItemInfo(itemLink)
		local color = _G.ITEM_QUALITY_COLORS[quality or 1]

		if CFG.colored_names_enabled then
			toast.Text:SetTextColor(color.r, color.g, color.b)
		end

		toast.Title:SetText(L["ITEM_LEGENDARY"])
		toast.Text:SetText(name)
		toast.BG:SetTexture("Interface\\AddOns\\ls_Toasts\\media\\toast-bg-legendary")
		toast.Border:SetVertexColor(color.r, color.g, color.b)
		toast.IconBorder:SetVertexColor(color.r, color.g, color.b)
		toast.Count:SetText("")
		toast.Icon:SetTexture(icon)
		toast.UpgradeIcon:SetShown(IsItemAnUpgrade(itemLink))
		toast.Dragon:Show()
		toast.soundFile = "UI_LegendaryLoot_Toast"
		toast.link = itemLink

		SpawnToast(toast, CFG.dnd.loot_special)
	end
end

function dispatcher:SHOW_LOOT_TOAST_UPGRADE(...)
	local itemLink, quantity = ...

	if itemLink then
		local toast = GetToast("item")
		itemLink = FixItemLink(itemLink)
		local name, _, quality, _, _, _, _, _, _, icon = _G.GetItemInfo(itemLink)
		local upgradeTexture = _G.LOOTUPGRADEFRAME_QUALITY_TEXTURES[quality or 2]
		local color = _G.ITEM_QUALITY_COLORS[quality or 1]

		if CFG.colored_names_enabled then
			toast.Text:SetTextColor(color.r, color.g, color.b)
		end

		toast.Title:SetFormattedText(L["ITEM_UPGRADED_FORMAT"], color.hex, _G["ITEM_QUALITY"..quality.."_DESC"])
		toast.Text:SetText(name)
		toast.Count:SetText(quantity > 1 and quantity or "")
		toast.BG:SetTexture("Interface\\AddOns\\ls_Toasts\\media\\toast-bg-upgrade")
		toast.Border:SetVertexColor(color.r, color.g, color.b)
		toast.IconBorder:SetVertexColor(color.r, color.g, color.b)
		toast.Icon:SetTexture(icon)
		toast.UpgradeIcon:SetShown(IsItemAnUpgrade(itemLink))
		toast.soundFile = 51561
		toast.link = itemLink

		for i = 1, 5 do
			toast.Arrows["Arrow"..i]:SetAtlas(upgradeTexture.arrow, true)
		end

		toast.Arrows.requested = true

		SpawnToast(toast, CFG.dnd.loot_special)
	end
end

function dispatcher:SHOW_PVP_FACTION_LOOT_TOAST(...)
	local typeID, itemLink, quantity, _, _, isPersonal, lessAwesome = ...

	LootWonToast_Setup(itemLink, quantity, nil, nil, true, typeID == "item", typeID == "money", lessAwesome, nil, isPersonal)
end

function dispatcher:SHOW_RATED_PVP_REWARD_TOAST(...)
	local typeID, itemLink, quantity, _, _, isPersonal, lessAwesome = ...

	LootWonToast_Setup(itemLink, quantity, nil, nil, true, typeID == "item", typeID == "money", lessAwesome, nil, isPersonal)
end

function dispatcher:STORE_PRODUCT_DELIVERED(...)
	local _, icon, _, payloadID = ...
	local name, _, quality = _G.GetItemInfo(payloadID)
	local color = _G.ITEM_QUALITY_COLORS[quality or 4]
	local toast = GetToast("item")

	if CFG.colored_names_enabled then
		toast.Text:SetTextColor(color.r, color.g, color.b)
	end

	toast.Title:SetText(L["BLIZZARD_STORE_PURCHASE_DELIVERED"])
	toast.Text:SetText(name)
	toast.BG:SetTexture("Interface\\AddOns\\ls_Toasts\\media\\toast-bg-store")
	toast.Border:SetVertexColor(color.r, color.g, color.b)
	toast.IconBorder:SetVertexColor(color.r, color.g, color.b)
	toast.Icon:SetTexture(icon)
	toast.soundFile = "UI_igStore_PurchaseDelivered_Toast_01"
	toast.id = payloadID

	SpawnToast(toast, CFG.dnd.loot_special)
end

local function EnableSpecialLootToasts()
	if CFG.loot_special_enabled then
		dispatcher:RegisterEvent("LOOT_ITEM_ROLL_WON")
		dispatcher:RegisterEvent("SHOW_LOOT_TOAST")
		dispatcher:RegisterEvent("SHOW_LOOT_TOAST_LEGENDARY_LOOTED")
		dispatcher:RegisterEvent("SHOW_LOOT_TOAST_UPGRADE")
		dispatcher:RegisterEvent("SHOW_PVP_FACTION_LOOT_TOAST")
		dispatcher:RegisterEvent("SHOW_RATED_PVP_REWARD_TOAST")
		dispatcher:RegisterEvent("STORE_PRODUCT_DELIVERED")

		_G.BonusRollFrame.FinishRollAnim:SetScript("OnFinished", BonusRollFrame_FinishedFading_Enabled)
	else
		_G.BonusRollFrame.FinishRollAnim:SetScript("OnFinished", BonusRollFrame_FinishedFading_Disabled)
	end
end

local function DisableSpecialLootToasts()
	dispatcher:UnregisterEvent("LOOT_ITEM_ROLL_WON")
	dispatcher:UnregisterEvent("SHOW_LOOT_TOAST")
	dispatcher:UnregisterEvent("SHOW_LOOT_TOAST_LEGENDARY_LOOTED")
	dispatcher:UnregisterEvent("SHOW_LOOT_TOAST_UPGRADE")
	dispatcher:UnregisterEvent("SHOW_PVP_FACTION_LOOT_TOAST")
	dispatcher:UnregisterEvent("SHOW_RATED_PVP_REWARD_TOAST")
	dispatcher:UnregisterEvent("STORE_PRODUCT_DELIVERED")

	_G.BonusRollFrame.FinishRollAnim:SetScript("OnFinished", BonusRollFrame_FinishedFading_Disabled)
end

local LOOT_ITEM_PATTERN = (_G.LOOT_ITEM_SELF):gsub("%%s", "(.+)")
local LOOT_ITEM_PUSHED_PATTERN = (_G.LOOT_ITEM_PUSHED_SELF):gsub("%%s", "(.+)")
local LOOT_ITEM_MULTIPLE_PATTERN = (_G.LOOT_ITEM_SELF_MULTIPLE):gsub("%%s", "(.+)"):gsub("%%d", "(%%d+)")
local LOOT_ITEM_PUSHED_MULTIPLE_PATTERN = (_G.LOOT_ITEM_PUSHED_SELF_MULTIPLE):gsub("%%s", "(.+)"):gsub("%%d", "(%%d+)")

local function LootCommonToast_Setup(itemLink, quantity)
	itemLink = FixItemLink(itemLink)

	if not GetToastToUpdate(itemLink, "item") then
		local name, quality, icon, _

		if string.find(itemLink, "battlepet:") then
			local _, speciesID, _, breedQuality = string.split(":", itemLink)
			name, icon = _G.C_PetJournal.GetPetInfoBySpeciesID(speciesID)
			quality = tonumber(breedQuality)
		else
			name, _, quality, _, _, _, _, _, _, icon = _G.GetItemInfo(itemLink)
		end

		if quality >= CFG.loot_common_quality_threshold then
			local toast = GetToast("item")
			local color = _G.ITEM_QUALITY_COLORS[quality or 4]

			if CFG.colored_names_enabled then
				toast.Text:SetTextColor(color.r, color.g, color.b)
			end

			toast.Title:SetText(L["YOU_RECEIVED"])
			toast.Text:SetText(name)
			toast.Count:SetText(quantity > 1 and quantity or "")
			toast.Border:SetVertexColor(color.r, color.g, color.b)
			toast.IconBorder:SetVertexColor(color.r, color.g, color.b)
			toast.Icon:SetTexture(icon)
			toast.link = itemLink
			toast.chat = true

			SpawnToast(toast, CFG.dnd.loot_common)
		end
	end
end

function dispatcher:CHAT_MSG_LOOT(message)
	local itemLink, quantity = message:match(LOOT_ITEM_MULTIPLE_PATTERN)

	if not itemLink then
		itemLink, quantity = message:match(LOOT_ITEM_PUSHED_MULTIPLE_PATTERN)

		if not itemLink then
			quantity, itemLink = 1, message:match(LOOT_ITEM_PATTERN)

			if not itemLink then
				quantity, itemLink = 1, message:match(LOOT_ITEM_PUSHED_PATTERN)

				if not itemLink then
					return
				end
			end
		end
	end

	quantity = tonumber(quantity) or 0

	_G.C_Timer.After(0.125, function() LootCommonToast_Setup(itemLink, quantity) end)
end

local function EnableCommonLootToasts()
	if CFG.loot_common_enabled then
		dispatcher:RegisterEvent("CHAT_MSG_LOOT")
	end
end

local function DisableCommonLootToasts()
	dispatcher:UnregisterEvent("CHAT_MSG_LOOT")
end

local CURRENCY_GAINED_PATTERN = (_G.CURRENCY_GAINED):gsub("%%s", "(.+)")
local CURRENCY_GAINED_MULTIPLE_PATTERN = (_G.CURRENCY_GAINED_MULTIPLE):gsub("%%s", "(.+)"):gsub("%%d", "(%%d+)")

function dispatcher:CHAT_MSG_CURRENCY(message)
	local itemLink, quantity = message:match(CURRENCY_GAINED_MULTIPLE_PATTERN)

	if not itemLink then
		quantity, itemLink = 1, message:match(CURRENCY_GAINED_PATTERN)

		if not itemLink then
			return
		end
	end

	itemLink = string.match(itemLink, "|H(.+)|h.+|h")
	quantity = tonumber(quantity) or 0

	local toast, isQueued = GetToastToUpdate(itemLink, "item")
	local isUpdated = true

	if not toast then
		toast = GetToast("item")
		isUpdated = false
	end

	if not isUpdated then
		local name, _, icon, _, _, _, _, quality = _G.GetCurrencyInfo(itemLink)
		local color = _G.ITEM_QUALITY_COLORS[quality or 1]

		if CFG.colored_names_enabled then
			toast.Text:SetTextColor(color.r, color.g, color.b)
		end

		toast.Title:SetText(L["YOU_RECEIVED"])
		toast.Text:SetText(name)
		toast.Count:SetText(quantity > 1 and quantity or "")
		toast.Border:SetVertexColor(color.r, color.g, color.b)
		toast.IconBorder:SetVertexColor(color.r, color.g, color.b)
		toast.Icon:SetTexture(icon)
		toast.soundFile = 31578
		toast.itemCount = quantity
		toast.link = itemLink

		SpawnToast(toast, CFG.dnd.loot_currency)
	else
		if isQueued then
			toast.itemCount = toast.itemCount + quantity
			toast.Count:SetText(toast.itemCount)
		else
			toast.itemCount = toast.itemCount + quantity
			toast.Count:SetAnimatedText(toast.itemCount)

			toast.CountUpdate:SetText("+"..quantity)
			toast.CountUpdateAnim:Stop()
			toast.CountUpdateAnim:Play()

			toast.AnimOut:Stop()
			toast.AnimOut:Play()
		end
	end
end

local function EnableCurrencyLootToasts()
	if CFG.loot_currency_enabled then
		dispatcher:RegisterEvent("CHAT_MSG_CURRENCY")
	end
end

local function DisableCurrencyLootToasts()
	dispatcher:UnregisterEvent("CHAT_MSG_CURRENCY")
end

------------
-- RECIPE --
------------

function dispatcher:NEW_RECIPE_LEARNED(...)
	local recipeID = ...
	local tradeSkillID = _G.C_TradeSkillUI.GetTradeSkillLineForRecipe(recipeID)

	if tradeSkillID then
		local recipeName = _G.GetSpellInfo(recipeID)

		if recipeName then
			local toast = GetToast("ability")
			local rank = _G.GetSpellRank(recipeID)
			local rankTexture = ""

			if rank == 1 then
				rankTexture = "|TInterface\\LootFrame\\toast-star:12:12:0:0:32:32:0:21:0:21|t"
			elseif rank == 2 then
				rankTexture = "|TInterface\\LootFrame\\toast-star-2:12:24:0:0:64:32:0:42:0:21|t"
			elseif rank == 3 then
				rankTexture = "|TInterface\\LootFrame\\toast-star-3:12:36:0:0:64:32:0:64:0:21|t"
			end

			toast.Title:SetText(rank and rank > 1 and L["RECIPE_UPGRADED"] or L["RECIPE_LEARNED"])
			toast.Text:SetText(recipeName)
			toast.BG:SetTexture("Interface\\AddOns\\ls_Toasts\\media\\toast-bg-recipe")
			toast.Rank:SetText(rankTexture)
			toast.Icon:SetTexture(_G.C_TradeSkillUI.GetTradeSkillTexture(tradeSkillID))
			toast.soundFile = "UI_Professions_NewRecipeLearned_Toast"
			toast.id = recipeID

			SpawnToast(toast, CFG.dnd.recipe)
		end
	end
end

local function EnableRecipeToasts()
	if CFG.recipe_enabled then
		dispatcher:RegisterEvent("NEW_RECIPE_LEARNED")
	end
end

local function DisableRecipeToasts()
	dispatcher:UnregisterEvent("NEW_RECIPE_LEARNED")
end

-----------
-- WORLD --
-----------

local function InvasionToast_SetUp(questID)
	if GetToastToUpdate(questID, "scenario") then
		return
	end

	local toast = GetToast("scenario")
	local scenarioName, _, _, _, hasBonusStep, isBonusStepComplete, _, xp, money, _, areaName = _G.C_Scenario.GetInfo()
	-- local scenarioName, _, _, _, hasBonusStep, isBonusStepComplete, _, xp, money, _, areaName =
		-- "Invasion: Azshara", 0, 0, 0, false, false, true, 12345, 12345, 4, "Azshara"
	local usedRewards = 0

	if money > 0 then
		usedRewards = usedRewards + 1
		local reward = toast["Reward"..usedRewards]

		if reward then
			_G.SetPortraitToTexture(reward.Icon, "Interface\\Icons\\inv_misc_coin_02")
			reward.money = money
			reward:Show()
		end
	end

	if xp > 0 and _G.UnitLevel("player") < _G.MAX_PLAYER_LEVEL then
		usedRewards = usedRewards + 1
		local reward = toast["Reward"..usedRewards]

		if reward then
			_G.SetPortraitToTexture(reward.Icon, "Interface\\Icons\\xp_icon")
			reward.xp = xp
			reward:Show()
		end
	end

	if hasBonusStep and isBonusStepComplete then
		toast.Bonus:Show()
	end

	toast.Title:SetText(L["SCENARIO_INVASION_COMPLETED"])
	toast.Text:SetText(areaName or scenarioName)
	toast.BG:SetTexture("Interface\\AddOns\\ls_Toasts\\media\\toast-bg-legion")
	toast.Icon:SetTexture("Interface\\Icons\\Ability_Warlock_DemonicPower")
	toast.Border:SetVertexColor(60 / 255, 255 / 255, 38 / 255) -- fel green #3cff26
	toast.IconBorder:SetVertexColor(60 / 255, 255 / 255, 38 / 255) -- fel green #3cff26
	toast.usedRewards = usedRewards
	toast.soundFile = "UI_Scenario_Ending"
	toast.id = questID

	SpawnToast(toast, CFG.dnd.world)
end

local function WorldQuestToast_SetUp(questID)
	if GetToastToUpdate(questID, "scenario") then
		return
	end

	local toast = GetToast("scenario")
	local _, _, _, taskName = _G.GetTaskInfo(questID)
	local _, _, worldQuestType, rarity, _, tradeskillLineIndex = _G.GetQuestTagInfo(questID)
	local color = _G.WORLD_QUEST_QUALITY_COLORS[rarity] or _G.WORLD_QUEST_QUALITY_COLORS[1]
	local money = _G.GetQuestLogRewardMoney(questID)
	local xp = _G.GetQuestLogRewardXP(questID)
	local usedRewards = 0
	local icon = "Interface\\Icons\\Achievement_Quests_Completed_TwilightHighlands"

	if money > 0 then
		usedRewards = usedRewards + 1
		local reward = toast["Reward"..usedRewards]

		if reward then
			_G.SetPortraitToTexture(reward.Icon, "Interface\\Icons\\inv_misc_coin_02")
			reward.money = money
			reward:Show()
		end
	end

	if xp > 0 and _G.UnitLevel("player") < _G.MAX_PLAYER_LEVEL then
		usedRewards = usedRewards + 1
		local reward = toast["Reward"..usedRewards]

		if reward then
			_G.SetPortraitToTexture(reward.Icon, "Interface\\Icons\\xp_icon")
			reward.xp = xp
			reward:Show()
		end
	end

	for i = 1, _G.GetNumQuestLogRewardCurrencies(questID) do
		usedRewards = usedRewards + 1
		local reward = toast["Reward"..usedRewards]

		if reward then
			local _, texture = _G.GetQuestLogRewardCurrencyInfo(i, questID)
			local isOK = pcall(_G.SetPortraitToTexture, reward.Icon, texture)

			if not isOK then
				_G.SetPortraitToTexture(reward.Icon, "Interface\\Icons\\INV_Box_02")
			end

			reward.currency = i
			reward:Show()
		end
	end

	if worldQuestType == _G.LE_QUEST_TAG_TYPE_PVP then
		icon = "Interface\\Icons\\achievement_arena_2v2_1"
	elseif worldQuestType == _G.LE_QUEST_TAG_TYPE_PET_BATTLE then
		icon = "Interface\\Icons\\INV_Pet_BattlePetTraining"
	elseif worldQuestType == _G.LE_QUEST_TAG_TYPE_PROFESSION and tradeskillLineIndex then
		icon = _G.C_TradeSkillUI.GetTradeSkillTexture(select(7, _G.GetProfessionInfo(tradeskillLineIndex)))
	elseif worldQuestType == _G.LE_QUEST_TAG_TYPE_DUNGEON then
		icon = "Interface\\Icons\\INV_Misc_Bone_Skull_02"
	end

	if CFG.colored_names_enabled then
		toast.Text:SetTextColor(color.r, color.g, color.b)
	end

	toast.Title:SetText(L["WORLD_QUEST_COMPLETED"])
	toast.Text:SetText(taskName)
	toast.BG:SetTexture("Interface\\AddOns\\ls_Toasts\\media\\toast-bg-worldquest")
	toast.Icon:SetTexture(icon)
	toast.Border:SetVertexColor(color.r, color.g, color.b)
	toast.IconBorder:SetVertexColor(color.r, color.g, color.b)
	toast.usedRewards = usedRewards
	toast.soundFile = "UI_WorldQuest_Complete"
	toast.id = questID

	SpawnToast(toast, CFG.dnd.world)
end

function dispatcher:SCENARIO_COMPLETED(...)
	if select(10, _G.C_Scenario.GetInfo()) == _G.LE_SCENARIO_TYPE_LEGION_INVASION then
		local questID = ...

		if questID then
			InvasionToast_SetUp(questID)
		end
	end
end

function dispatcher:QUEST_TURNED_IN(...)
	local questID = ...

	if _G.QuestUtils_IsQuestWorldQuest(questID) then
		WorldQuestToast_SetUp(questID)
	end
end

function dispatcher:QUEST_LOOT_RECEIVED(...)
	local questID, itemLink = ...

	--- QUEST_LOOT_RECEIVED may fire before QUEST_TURNED_IN
	if _G.QuestUtils_IsQuestWorldQuest(questID) then
		if not GetToastToUpdate(questID, "scenario") then
			WorldQuestToast_SetUp(questID)
		end
	end

	UpdateToast(questID, "scenario", itemLink)
end

local function EnableWorldToasts()
	if CFG.world_enabled then
		dispatcher:RegisterEvent("SCENARIO_COMPLETED")
		dispatcher:RegisterEvent("QUEST_TURNED_IN")
		dispatcher:RegisterEvent("QUEST_LOOT_RECEIVED")
	end
end

local function DisableWorldToasts()
	dispatcher:UnregisterEvent("SCENARIO_COMPLETED")
	dispatcher:UnregisterEvent("QUEST_TURNED_IN")
	dispatcher:UnregisterEvent("QUEST_LOOT_RECEIVED")
end

--------------
-- TRANSMOG --
--------------

local function IsAppearanceKnown(sourceID)
	local data = _G.C_TransmogCollection.GetSourceInfo(sourceID)
	local sources = _G.C_TransmogCollection.GetAppearanceSources(data.appearanceID)

	if sources then
		for i = 1, #sources do
			if sources[i].isCollected and sourceID ~= sources[i].sourceID then
				return true
			end
		end
	else
		return nil
	end

	return false
end

local function TransmogToast_SetUp(sourceID, isAdded)
	local _, _, _, icon, _, _, transmogLink = _G.C_TransmogCollection.GetAppearanceSourceInfo(sourceID)
	local name
	transmogLink, name = string.match(transmogLink, "|H(.+)|h%[(.+)%]|h")

	if not transmogLink then
		return _G.C_Timer.After(0.25, function() TransmogToast_SetUp(sourceID, isAdded) end)
	end

	local toast = GetToast("misc")

	if isAdded then
		toast.Title:SetText(L["TRANSMOG_ADDED"])
	else
		toast.Title:SetText(L["TRANSMOG_REMOVED"])
	end

	toast.Text:SetText(name)
	toast.BG:SetTexture("Interface\\AddOns\\ls_Toasts\\media\\toast-bg-transmog")
	toast.Border:SetVertexColor(1, 128 / 255, 1)
	toast.IconBorder:SetVertexColor(1, 128 / 255, 1)
	toast.Icon:SetTexture(icon)
	toast.soundFile = "UI_DigsiteCompletion_Toast"
	toast.id = sourceID
	toast.link = transmogLink

	SpawnToast(toast, CFG.dnd.transmog)
end

function dispatcher:TRANSMOG_COLLECTION_SOURCE_ADDED(sourceID)
	local isKnown = IsAppearanceKnown(sourceID)

	if isKnown == false then
		TransmogToast_SetUp(sourceID, true)
	elseif isKnown == nil then
		_G.C_Timer.After(0.25, function() dispatcher:TRANSMOG_COLLECTION_SOURCE_ADDED(sourceID) end)
	end
end

function dispatcher:TRANSMOG_COLLECTION_SOURCE_REMOVED(sourceID)
	local isKnown = IsAppearanceKnown(sourceID)

	if isKnown == false then
		TransmogToast_SetUp(sourceID)
	elseif isKnown == nil then
		_G.C_Timer.After(0.25, function() dispatcher:TRANSMOG_COLLECTION_SOURCE_REMOVED(sourceID) end)
	end
end

local function EnableTransmogToasts()
	if CFG.transmog_enabled then
		dispatcher:RegisterEvent("TRANSMOG_COLLECTION_SOURCE_ADDED")
		dispatcher:RegisterEvent("TRANSMOG_COLLECTION_SOURCE_REMOVED")
	end
end

local function DisableTransmogToasts()
	dispatcher:UnregisterEvent("TRANSMOG_COLLECTION_SOURCE_ADDED")
	dispatcher:UnregisterEvent("TRANSMOG_COLLECTION_SOURCE_REMOVED")
end

-----------
-- TESTS --
-----------

local function SpawnTestGarrisonToast()
	-- follower
	local followers = _G.C_Garrison.GetFollowers(_G.LE_FOLLOWER_TYPE_GARRISON_6_0)
	local follower = followers and followers[1]

	if follower then
		GarrisonFollowerToast_SetUp(follower.followerTypeID, _G.LE_GARRISON_TYPE_6_0, follower.followerID, follower.name, nil, follower.level, follower.quality, false)
	end

	-- ship
	followers = _G.C_Garrison.GetFollowers(_G.LE_FOLLOWER_TYPE_SHIPYARD_6_2)
	follower = followers and followers[1]

	if follower then
		GarrisonFollowerToast_SetUp(follower.followerTypeID, _G.LE_GARRISON_TYPE_6_0, follower.followerID, follower.name, follower.texPrefix, follower.level, follower.quality, false)
	end

	-- garrison mission
	local missions = _G.C_Garrison.GetAvailableMissions(_G.LE_FOLLOWER_TYPE_GARRISON_6_0)
	local id = missions and (missions[1] and missions[1].missionID or nil) or nil

	if id then
		GarrisonMissionToast_SetUp(_G.LE_FOLLOWER_TYPE_GARRISON_6_0, _G.LE_GARRISON_TYPE_6_0, id)
	end

	-- shipyard mission
	missions = _G.C_Garrison.GetAvailableMissions(_G.LE_FOLLOWER_TYPE_SHIPYARD_6_2)
	id = missions and (missions[1] and missions[1].missionID or nil) or nil

	if id then
		GarrisonMissionToast_SetUp(_G.LE_FOLLOWER_TYPE_SHIPYARD_6_2, _G.LE_GARRISON_TYPE_6_0, id)
	end

	-- garrison building
	dispatcher:GARRISON_BUILDING_ACTIVATABLE("Storehouse")
end

local function SpawnTestClassHallToast()
	-- champion
	local followers = _G.C_Garrison.GetFollowers(_G.LE_FOLLOWER_TYPE_GARRISON_7_0)
	local follower = followers and followers[1]

	if follower then
		GarrisonFollowerToast_SetUp(follower.followerTypeID, _G.LE_GARRISON_TYPE_7_0, follower.followerID, follower.name, nil, follower.level, follower.quality, false)
	end

	-- order hall mission
	local missions = _G.C_Garrison.GetAvailableMissions(_G.LE_FOLLOWER_TYPE_GARRISON_7_0)
	local id = missions and (missions[1] and missions[1].missionID or nil) or nil

	if id then
		GarrisonMissionToast_SetUp(_G.LE_FOLLOWER_TYPE_GARRISON_7_0, _G.LE_GARRISON_TYPE_7_0, id)
	end
end

local function SpawnTestAchievementToast()
	-- new
	dispatcher:ACHIEVEMENT_EARNED(545, false)

	-- already earned
	dispatcher:ACHIEVEMENT_EARNED(9828, true)
end

local function SpawnTestRecipeToast()
	dispatcher:NEW_RECIPE_LEARNED(7183)
end

local function SpawnTestArchaeologyToast()
	dispatcher:ARTIFACT_DIGSITE_COMPLETE(408)
end

local function SpawnTestWorldEventToast()
	-- Work Order: Ancient Rejuvenation Potions
	local _, link = _G.GetItemInfo(124124)

	if link then
		WorldQuestToast_SetUp(41662)
		UpdateToast(41662, "scenario", link)
	else
		_G.C_Timer.After(0.25, SpawnTestWorldEventToast)
	end
end

local function SpawnTestLootToast()
	-- money
	dispatcher:SHOW_LOOT_TOAST("money", nil, 12345678, 0, 2, false, 0, false, false)

	-- legendary
	local _, link = _G.GetItemInfo(132452)

	if link then
		dispatcher:SHOW_LOOT_TOAST_LEGENDARY_LOOTED(link)
	end

	_, link = _G.GetItemInfo(140715)

	-- faction
	if link then
		dispatcher:SHOW_PVP_FACTION_LOOT_TOAST("item", link, 1)
	end

	-- roll won
	if link then
		dispatcher:LOOT_ITEM_ROLL_WON(link, 1, 1, 58, false)
	end

	_, link = _G.GetItemInfo("|cffa335ee|Hitem:121641::::::::110:70:512:11:2:664:1737:108:::|h[Radiant Charm of Elune]|h|r")

	-- upgrade
	if link then
		dispatcher:SHOW_LOOT_TOAST_UPGRADE(link, 1)
	end

	-- store
	dispatcher:STORE_PRODUCT_DELIVERED(1, 915544, "Pouch of Enduring Wisdom", 105911)
end

local function SpawnTestCurrencyToast()
	-- currency
	local link, _ = _G.GetCurrencyLink(824)

	if link then
		dispatcher:CHAT_MSG_CURRENCY(string.format(_G.CURRENCY_GAINED_MULTIPLE, link, math.random(300, 600)))
	end
end

local function SpawnTestTransmogToast()
	local appearance = _G.C_TransmogCollection.GetCategoryAppearances(1) and _G.C_TransmogCollection.GetCategoryAppearances(1)[1]
	local source = _G.C_TransmogCollection.GetAppearanceSources(appearance.visualID) and _G.C_TransmogCollection.GetAppearanceSources(appearance.visualID)[1]

	TransmogToast_SetUp(source.sourceID, true)
	TransmogToast_SetUp(source.sourceID)
end

-----------
-- DEBUG --
-----------

-- local function SpawnTestToast()
-- 	if not _G.DevTools_Dump then
-- 		_G.UIParentLoadAddOn("Blizzard_DebugTools")
-- 	end

-- 	SpawnTestGarrisonToast()

-- 	SpawnTestAchievementToast()

-- 	SpawnTestRecipeToast()

-- 	SpawnTestArchaeologyToast()

-- 	SpawnTestLootToast()

-- 	SpawnTestWorldEventToast()
-- end

-- _G.SLASH_LSADDTOAST1 = "/lstoasttest"
-- _G.SlashCmdList["LSADDTOAST"] = SpawnTestToast

--------------------
-- IN-GAME CONFIG --
--------------------

local function CopyTable(src, dest)
	if type(dest) ~= "table" then
		dest = {}
	end

	for k, v in pairs(src) do
		if type(v) == "table" then
			dest[k] = CopyTable(v, dest[k])
		elseif type(v) ~= type(dest[k]) then
			dest[k] = v
		end
	end

	return dest
end

local function DiffTable(src , dest)
	if type(dest) ~= "table" then
		return {}
	end

	if type(src) ~= "table" then
		return dest
	end

	for k, v in pairs(dest) do
		if type(v) == "table" then
			if not next(DiffTable(src[k], v)) then
				dest[k] = nil
			end
		elseif v == src[k] then
			dest[k] = nil
		end
	end

	return dest
end

local function SetConfigValue(valuePath, value)
	local temp = {string.split(".", valuePath)}
	local t = CFG

	if #temp > 0 then
		for i = 1, #temp - 1 do
			t = t[temp[i]]
		end

		t[temp[#temp]] = value
	end
end

local function GetConfigValue(valuePath)
	local temp = {string.split(".", valuePath)}
	local t = CFG

	if #temp > 0 then
		for i = 1, #temp do
			t = t[temp[i]]
		end

		return t
	end
end

local function RegisterControlForRefresh(parent, control)
	if not parent or not control then
		return
	end

	parent.controls = parent.controls or {}
	table.insert(parent.controls, control)
end

local function OptionsPanelRefresh(panel)
	for _, control in pairs(panel.controls) do
		if control.RefreshValue then
			control:RefreshValue()
		end
	end
end

local function AnchorFrame_Toggle()
	if anchorFrame:IsMouseEnabled() then
		Anchor_Disable()
	else
		Anchor_Enable()
	end
end

local function ToggleToasts(value, state)
	if value == "achievement_enabled" then
		if state then
			EnableAchievementToasts()
		else
			DisableAchievementToasts()
		end
	elseif value == "archaeology_enabled" then
		if state then
			EnableArchaeologyToasts()
		else
			DisableArchaeologyToasts()
		end
	elseif value == "garrison_6_0_enabled" or value == "garrison_7_0_enabled" then
		if state then
			EnableGarrisonToasts()
		else
			DisableGarrisonToasts()
		end
	elseif value == "instance_enabled" then
		if state then
			EnableInstanceToasts()
		else
			DisableInstanceToasts()
		end
	elseif value == "loot_special_enabled" then
		if state then
			EnableSpecialLootToasts()
		else
			DisableSpecialLootToasts()
		end
	elseif value == "loot_common_enabled" then
		if state then
			EnableCommonLootToasts()
		else
			DisableCommonLootToasts()
		end
	elseif value == "loot_currency_enabled" then
		if state then
			EnableCurrencyLootToasts()
		else
			DisableCurrencyLootToasts()
		end
	elseif value == "recipe_enabled" then
		if state then
			EnableRecipeToasts()
		else
			DisableRecipeToasts()
		end
	elseif value == "world_enabled" then
		if state then
			EnableWorldToasts()
		else
			DisableWorldToasts()
		end
	elseif value == "transmog_enabled" then
		if state then
			EnableTransmogToasts()
		else
			DisableTransmogToasts()
		end
	end
end

local function UpdateFadeOutDelay(delay)
	for _, toast in pairs(activeToasts) do
		toast.AnimOut.Anim1:SetStartDelay(delay)
	end

	for _, toast in pairs(queuedToasts) do
		toast.AnimOut.Anim1:SetStartDelay(delay)
	end

	for _, toast in pairs(abilityToasts) do
		toast.AnimOut.Anim1:SetStartDelay(delay)
	end

	for _, toast in pairs(achievementToasts) do
		toast.AnimOut.Anim1:SetStartDelay(delay)
	end

	for _, toast in pairs(followerToasts) do
		toast.AnimOut.Anim1:SetStartDelay(delay)
	end

	for _, toast in pairs(itemToasts) do
		toast.AnimOut.Anim1:SetStartDelay(delay)
	end

	for _, toast in pairs(miscToasts) do
		toast.AnimOut.Anim1:SetStartDelay(delay)
	end

	for _, toast in pairs(missonToasts) do
		toast.AnimOut.Anim1:SetStartDelay(delay)
	end

	for _, toast in pairs(scenarioToasts) do
		toast.AnimOut.Anim1:SetStartDelay(delay)
	end
end

local function UpdateScale(scale)
	anchorFrame:SetSize(234 * scale, 58 * scale)

	for _, toast in pairs(activeToasts) do
		toast:SetScale(scale)
	end

	for _, toast in pairs(queuedToasts) do
		toast:SetScale(scale)
	end

	for _, toast in pairs(abilityToasts) do
		toast:SetScale(scale)
	end

	for _, toast in pairs(achievementToasts) do
		toast:SetScale(scale)
	end

	for _, toast in pairs(followerToasts) do
		toast:SetScale(scale)
	end

	for _, toast in pairs(itemToasts) do
		toast:SetScale(scale)
	end

	for _, toast in pairs(miscToasts) do
		toast:SetScale(scale)
	end

	for _, toast in pairs(missonToasts) do
		toast:SetScale(scale)
	end

	for _, toast in pairs(scenarioToasts) do
		toast:SetScale(scale)
	end
end

------

local function CheckButton_SetValue(self, value)
	self:SetChecked(value)
	SetConfigValue(self.watchedValue, value)
end

local function CheckButton_RefreshValue(self)
	self:SetChecked(GetConfigValue(self.watchedValue))
end

local function CheckButton_OnClick(self)
	self:SetValue(self:GetChecked())
end

local function CheckButton_OnEnter(self)
	_G.GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	_G.GameTooltip:SetText(self.tooltipText, nil, nil, nil, nil, true)
	_G.GameTooltip:Show()
end

local function CheckButton_OnLeave()
	_G.GameTooltip:Hide()
end

local function CreateConfigCheckButton(parent, name, text, tooltiptext)
	local object = _G.CreateFrame("CheckButton", "$parent"..name, parent, "InterfaceOptionsCheckButtonTemplate")
	object:SetHitRectInsets(0, 0, 0, 0)
	object.type = "Button"
	object.SetValue = CheckButton_SetValue
	object.RefreshValue = CheckButton_RefreshValue
	object:SetScript("OnClick", CheckButton_OnClick)
	object.Text:SetText(text)

	if tooltiptext then
		object.tooltipText = tooltiptext
		object:SetScript("OnEnter", CheckButton_OnEnter)
		object:SetScript("OnLeave", CheckButton_OnLeave)
	end

	RegisterControlForRefresh(parent, object)

	return object
end

------

local function CreateConfigButton(parent, name, text, func)
	local object = _G.CreateFrame("Button", "$parent"..name, parent, "UIPanelButtonTemplate")
	object.type = "Button"
	object:SetText(text)
	object:SetWidth(object:GetTextWidth() + 18)
	object:SetScript("OnClick", func)

	return object
end

------

local function DropDownMenu_SetValue(self, value)
	self.value = value
	_G.UIDropDownMenu_SetSelectedValue(self, value)
	SetConfigValue(self.watchedValue, value)
end

local function DropDownMenu_RefreshValue(self)
	_G.UIDropDownMenu_Initialize(self, self.initialize)
	self.value = GetConfigValue(self.watchedValue)
	_G.UIDropDownMenu_SetSelectedValue(self, self.value)
end

local function CreateConfigDropDown(parent, name, text, func)
	local object = _G.CreateFrame("Frame", "$parent"..name, parent, "UIDropDownMenuTemplate")
	object.type = "DropDownMenu"
	object.SetValue = DropDownMenu_SetValue
	object.RefreshValue = DropDownMenu_RefreshValue
	_G.UIDropDownMenu_Initialize(object, func)

	local label = object:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	label:SetPoint("BOTTOMLEFT", object, "TOPLEFT", 16, 3)
	label:SetJustifyH("LEFT")
	label:SetText(text)
	object.Text = label

	RegisterControlForRefresh(parent, object)

	return object
end

------

local function Slider_SetValue(self, value)
	self.value = value
	self:SetDisplayValue(value)
	self.CurrentValue:SetText(value)
	SetConfigValue(self.watchedValue, value)
end

local function Slider_RefreshValue(self)
	self:SetDisplayValue(GetConfigValue(self.watchedValue))
	self.CurrentValue:SetText(GetConfigValue(self.watchedValue))
end

local function Slider_OnValueChanged(self, value, userInput)
	if userInput then
		value = tonumber(string.format("%.1f", value))

		if value ~= GetConfigValue(self.watchedValue) then
			self:SetValue(value)
		end
	end
end

local function CreateConfigSlider(parent, name, text, stepValue, minValue, maxValue)
	local object = _G.CreateFrame("Slider", "$parent"..name, parent, "OptionsSliderTemplate")
	object:SetMinMaxValues(minValue, maxValue)
	object:SetValueStep(stepValue)
	object:SetObeyStepOnDrag(true)
	object.SetDisplayValue = object.SetValue -- default
	object.SetValue = Slider_SetValue
	object.RefreshValue = Slider_RefreshValue
	object:SetScript("OnValueChanged", Slider_OnValueChanged)

	local label = _G[object:GetName().."Text"]
	label:SetText(text)
	label:SetVertexColor(1, 0.82, 0)
	object.Text = label

	local lowText = _G[object:GetName().."Low"]
	lowText:SetText(minValue)
	object.LowValue = lowText

	local curText = object:CreateFontString("$parentCurrent", "ARTWORK", "GameFontHighlightSmall")
	curText:SetPoint("TOP", object, "BOTTOM", 0, 3)
	object.CurrentValue = curText

	local highText = _G[object:GetName().."High"]
	highText:SetText(maxValue)
	object.HighValue = highText

	RegisterControlForRefresh(parent, object)

	return object
end

------

local function CreateConfigDivider(parent, text)
	local object = parent:CreateTexture(nil, "ARTWORK")
	object:SetHeight(4)
	object:SetPoint("LEFT", 10, 0)
	object:SetPoint("RIGHT", -10, 0)
	object:SetTexture("Interface\\AchievementFrame\\UI-Achievement-RecentHeader")
	object:SetTexCoord(0, 1, 0.0625, 0.65625)
	object:SetAlpha(0.5)

	local label = parent:CreateFontString(nil, "ARTWORK", "GameFontNormalMed2")
	label:SetWordWrap(false)
	label:SetPoint("LEFT", object, "LEFT", 12, 1)
	label:SetPoint("RIGHT", object, "RIGHT", -12, 1)
	label:SetText(text)
	object.Text = label

	return object
end

------

local function SettingsButton_OnEnter(self)
	self.Icon:SetAlpha(1)
end

local function SettingsButton_OnLeave(self)
	self.Icon:SetAlpha(0.5)
end

local function SettingsButton_OnClick(self)
	_G.ToggleDropDownMenu(nil, nil, self.DropDown, self, -2, 2, nil, nil, 10)
end

local function CheckButton_OnClickHook(self)
	ToggleToasts(self.watchedValue, self:GetChecked())
end

local function CreateToastConfigLine(parent, cfg, anchor)
	local holder = _G.CreateFrame("Frame", "$parent"..cfg.name.."Line", parent)
	holder:SetHeight(33)
	holder:SetPoint("TOP", anchor, "BOTTOM", 0, -2)
	holder:SetPoint("LEFT", parent, "LEFT", 16, 0)
	holder:SetPoint("RIGHT", parent, "RIGHT", -16, 0)

	local texture = holder:CreateTexture(nil, "BACKGROUND", nil, -8)
	texture:SetAllPoints()
	texture:SetColorTexture(0.3, 0.3, 0.3, 0.3)

	local name = holder:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
	name:SetPoint("TOPLEFT", holder, "TOPLEFT", 6, 0)
	name:SetHeight(33)
	name:SetJustifyV("MIDDLE")
	name:SetText(cfg.name)

	if cfg.dropdown then
		local settings = _G.CreateFrame("Button", "$parent"..cfg.name.."SettingsButton", holder)
		settings:SetSize(22, 22)
		settings:SetPoint("LEFT", name, "RIGHT", 0, 0)
		settings:SetScript("OnEnter", SettingsButton_OnEnter)
		settings:SetScript("OnLeave", SettingsButton_OnLeave)
		settings:SetScript("OnClick", SettingsButton_OnClick)
		settings.DropDown = cfg.dropdown

		local icon = settings:CreateTexture(nil, "ARTWORK")
		icon:SetTexture("Interface\\WorldMap\\GEAR_64GREY")
		icon:SetAlpha(0.5)
		icon:SetPoint("TOPLEFT", 1, -1)
		icon:SetPoint("BOTTOMRIGHT", -1, 1)
		settings.Icon = icon
	end

	local enabledCB = CreateConfigCheckButton(parent, cfg.name.."Toggle", nil, cfg.enable_tooltip)
	enabledCB:SetPoint("TOPLEFT", holder, "TOPLEFT", 320, -4)
	enabledCB:HookScript("OnClick", CheckButton_OnClickHook)
	enabledCB.watchedValue = cfg.enabled

	RegisterControlForRefresh(parent, enabledCB)

	local dndCB = CreateConfigCheckButton(parent, cfg.name.."DNDToggle", nil, L["DND_TOOLTIP"])
	dndCB:SetPoint("LEFT", enabledCB, "RIGHT", 96, 0)
	dndCB.watchedValue = cfg.dnd

	RegisterControlForRefresh(parent, dndCB)

	if cfg.testFunc then
		local testB = CreateConfigButton(parent, cfg.name.."TestButton", L["TEST"], cfg.testFunc)
		testB:SetPoint("TOPRIGHT", holder, "TOPRIGHT", -6, -5)
	end

	return holder
end

------

local function GrowthDirectionDropDownMenu_OnClick(self)
	self.owner:SetValue(self.value)
end

local function GrowthDirectionDropDownMenu_Initialize(self)
	local info = _G.UIDropDownMenu_CreateInfo()

	info.text = L["GROWTH_DIR_UP"]
	info.func = GrowthDirectionDropDownMenu_OnClick
	info.value = "UP"
	info.owner = self
	info.checked = nil
	_G.UIDropDownMenu_AddButton(info)

	info.text = L["GROWTH_DIR_DOWN"]
	info.func = GrowthDirectionDropDownMenu_OnClick
	info.value = "DOWN"
	info.owner = self
	info.checked = nil
	_G.UIDropDownMenu_AddButton(info)

	info.text = L["GROWTH_DIR_LEFT"]
	info.func = GrowthDirectionDropDownMenu_OnClick
	info.value = "LEFT"
	info.owner = self
	info.checked = nil
	_G.UIDropDownMenu_AddButton(info)

	info.text = L["GROWTH_DIR_RIGHT"]
	info.func = GrowthDirectionDropDownMenu_OnClick
	info.value = "RIGHT"
	info.owner = self
	info.checked = nil
	_G.UIDropDownMenu_AddButton(info)
end

------

local function DelaySlider_OnValueChanged(self, value, userInput)
	if userInput then
		value = tonumber(string.format("%.1f", value))

		if value ~= GetConfigValue(self.watchedValue) then
			self:SetValue(value)

			UpdateFadeOutDelay(value)
		end
	end
end

------

local function ScaleSlider_OnValueChanged(self, value, userInput)
	if userInput then
		value = tonumber(string.format("%.1f", value))

		if value ~= GetConfigValue(self.watchedValue) then
			self:SetValue(value)

			UpdateScale(value)
		end
	end
end

------

local function SaveDefaultTemplate()
	if _G.LS_TOASTS_CFG_GLOBAL["Default"] then
		table.wipe(_G.LS_TOASTS_CFG_GLOBAL["Default"])
	else
		_G.LS_TOASTS_CFG_GLOBAL["Default"] = {}
	end

	CopyTable(CFG, _G.LS_TOASTS_CFG_GLOBAL["Default"])
end

local function WipeDefaultTemplate()
	table.wipe(_G.LS_TOASTS_CFG_GLOBAL)
end

------

local function DropDown_Close()
	_G.CloseDropDownMenus()
end

local function LootDropDown_SetLootThreshold(_, quality)
	CFG.loot_common_quality_threshold = quality
end

local function LootDropDown_Initialize()
	local info = _G.UIDropDownMenu_CreateInfo()

	info.text = _G.LOOT_THRESHOLD
	info.isTitle = 1
	info.notCheckable = true
	_G.UIDropDownMenu_AddButton(info)
	table.wipe(info)

	for i = 1, 7 do
		info.text = _G.ITEM_QUALITY_COLORS[i].hex.._G["ITEM_QUALITY"..i.."_DESC"].."|r"
		info.checked = i == CFG.loot_common_quality_threshold
		info.arg1 = i
		info.func = LootDropDown_SetLootThreshold
		_G.UIDropDownMenu_AddButton(info)
		table.wipe(info)
	end

	info.text = _G.CLOSE
	info.func = DropDown_Close
	info.notCheckable = 1
	_G.UIDropDownMenu_AddButton(info)
end

------

local function CreateConfigPanel()
	-- General Panel
	local panel = _G.CreateFrame("Frame", "LSToastsConfigPanel", _G.InterfaceOptionsFramePanelContainer)
	panel.name = "|cff1a9fc0ls:|r Toasts"
	panel:Hide()

	local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
	title:SetPoint("TOPLEFT", 16, -16)
	title:SetJustifyH("LEFT")
	title:SetJustifyV("TOP")
	title:SetText(L["SETTINGS_GENERAL_LABEL"])

	local subtext = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	subtext:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
	subtext:SetPoint("RIGHT", -16, 0)
	subtext:SetHeight(44)
	subtext:SetJustifyH("LEFT")
	subtext:SetJustifyV("TOP")
	subtext:SetNonSpaceWrap(true)
	subtext:SetMaxLines(4)
	subtext:SetText(L["SETTINGS_GENERAL_DESC"])

	local acnhorButton = CreateConfigButton(panel, "AnchorToggle", L["ANCHOR_FRAME"], AnchorFrame_Toggle)
	acnhorButton:SetPoint("TOPLEFT", subtext, "BOTTOMLEFT", 0, -8)

	local soundToggle = CreateConfigCheckButton(panel, "SFXToggle", L["ENABLE_SOUND"])
	soundToggle:SetPoint("LEFT", acnhorButton, "RIGHT", 32, 0)
	soundToggle.watchedValue = "sfx_enabled"

	local divider = CreateConfigDivider(panel, L["APPEARANCE_TITLE"])
	divider:SetPoint("TOP", soundToggle, "BOTTOM", 0, -10)

	local numSlider = CreateConfigSlider(panel, "NumSlider", L["TOAST_NUM"], 1, 1, 20)
	numSlider:SetPoint("TOPLEFT", divider, "BOTTOMLEFT", 16, -24)
	numSlider.watchedValue = "max_active_toasts"

	local delaySlider = CreateConfigSlider(panel, "FadeOutSlider", L["FADE_OUT_DELAY"], 0.4, 0.8, 6.0)
	delaySlider:SetPoint("LEFT", numSlider, "RIGHT", 69, 0)
	delaySlider:SetScript("OnValueChanged", DelaySlider_OnValueChanged)
	delaySlider.watchedValue = "fadeout_delay"

	local scaleSlider = CreateConfigSlider(panel, "ScaleSlider", L["SCALE"], 0.1, 0.8, 2)
	scaleSlider:SetPoint("LEFT", delaySlider, "RIGHT", 69, 0)
	scaleSlider:SetScript("OnValueChanged", ScaleSlider_OnValueChanged)
	scaleSlider.watchedValue = "scale"

	local growthDropdown = CreateConfigDropDown(panel, "DirectionDropDown", L["GROWTH_DIR"], GrowthDirectionDropDownMenu_Initialize)
	growthDropdown:SetPoint("TOPLEFT", numSlider, "BOTTOMLEFT", -13, -32)
	growthDropdown.watchedValue = "growth_direction"

	local colorToggle = CreateConfigCheckButton(panel, "NameColorToggle", L["COLOURS"], L["COLOURS_TOOLTIP"])
	colorToggle:SetPoint("TOPLEFT", delaySlider, "BOTTOMLEFT", -3, -32)
	colorToggle.watchedValue = "colored_names_enabled"

	divider = CreateConfigDivider(panel, L["PROFILE_TITLE"])
	divider:SetPoint("TOP", growthDropdown, "BOTTOM", 0, -10)

	subtext = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	subtext:SetPoint("TOPLEFT", divider, "BOTTOMLEFT", 6, -8)
	subtext:SetPoint("RIGHT", -16, 0)
	subtext:SetHeight(44)
	subtext:SetJustifyH("LEFT")
	subtext:SetJustifyV("TOP")
	subtext:SetNonSpaceWrap(true)
	subtext:SetMaxLines(4)
	subtext:SetText(L["PROFILE_DESC"] )

	local saveDefaults = CreateConfigButton(panel, "SaveDefaultsButton", L["PROFILE_SAVE"], SaveDefaultTemplate)
	saveDefaults:SetPoint("TOPLEFT", subtext, "BOTTOMLEFT", 0, -8)

	local wipeDefaults = CreateConfigButton(panel, "WipeDefaultsButton", L["PROFILE_WIPE"], WipeDefaultTemplate)
	wipeDefaults:SetPoint("LEFT", saveDefaults, "RIGHT", 4, 0)

	panel.refresh = OptionsPanelRefresh

	_G.InterfaceOptions_AddCategory(panel, true)

	-- Toast Types Panel
	panel = _G.CreateFrame("Frame", "LSToastsTypesConfigPanel", _G.InterfaceOptionsFramePanelContainer)
	panel.name = L["SETTINGS_TYPE_LABEL"]
	panel.parent = "|cff1a9fc0ls:|r Toasts"
	panel:Hide()

	title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
	title:SetPoint("TOPLEFT", 16, -16)
	title:SetJustifyH("LEFT")
	title:SetJustifyV("TOP")
	title:SetText(L["SETTINGS_TYPE_LABEL"])

	subtext = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	subtext:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
	subtext:SetPoint("RIGHT", -16, 0)
	subtext:SetHeight(32)
	subtext:SetJustifyH("LEFT")
	subtext:SetJustifyV("TOP")
	subtext:SetNonSpaceWrap(true)
	subtext:SetMaxLines(3)
	subtext:SetText(L["SETTINGS_TYPE_DESC"])

	local lootDropDown = _G.CreateFrame("Frame", "$parentLootCommonDropDown", panel, "UIDropDownMenuTemplate")
	lootDropDown.displayMode = "MENU"
	lootDropDown.point = "TOPLEFT"
	lootDropDown.relativePoint = "BOTTOMRIGHT"
	_G.UIDropDownMenu_Initialize(lootDropDown, LootDropDown_Initialize)

	local layout = {
		[1] = {name = L["TYPE_ACHIEVEMENT"], enabled = "achievement_enabled", dnd = "dnd.achievement", testFunc = SpawnTestAchievementToast},
		[2] = {name = L["TYPE_ARCHAEOLOGY"], enabled = "archaeology_enabled", dnd = "dnd.archaeology", testFunc = SpawnTestArchaeologyToast},
		[3] = {name = L["TYPE_GARRISON"], enabled = "garrison_6_0_enabled", dnd = "dnd.garrison_6_0", testFunc = SpawnTestGarrisonToast},
		[4] = {name = L["TYPE_CLASS_HALL"], enabled = "garrison_7_0_enabled", dnd = "dnd.garrison_7_0", testFunc = SpawnTestClassHallToast},
		[5] = {name = L["TYPE_DUNGEON"], enabled = "instance_enabled", dnd = "dnd.instance"},
		[6] = {name = L["TYPE_LOOT_SPECIAL"], enabled = "loot_special_enabled", enable_tooltip = L["TYPE_LOOT_SPECIAL_TOOLTIP"], dnd = "dnd.loot_special", testFunc = SpawnTestLootToast},
		[7] = {name = L["TYPE_LOOT_COMMON"], enabled = "loot_common_enabled", enable_tooltip = L["TYPE_LOOT_COMMON_TOOLTIP"], dnd = "dnd.loot_common", dropdown = lootDropDown},
		[8] = {name = L["TYPE_LOOT_CURRENCY"], enabled = "loot_currency_enabled", dnd = "dnd.loot_currency", testFunc = SpawnTestCurrencyToast},
		[9] = {name = L["TYPE_RECIPE"], enabled = "recipe_enabled", dnd = "dnd.recipe", testFunc = SpawnTestRecipeToast},
		[10] = {name = L["TYPE_WORLD QUEST"], enabled = "world_enabled", dnd = "dnd.world", testFunc = SpawnTestWorldEventToast},
		[11] = {name = L["TYPE_TRANSMOG"], enabled = "transmog_enabled", dnd = "dnd.transmog", testFunc = SpawnTestTransmogToast},
	}

	local anchor = CreateToastConfigLine(panel, layout[1], subtext)
	anchor:SetPoint("TOP", subtext, "BOTTOM", 0, -18)

	title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	title:SetPoint("BOTTOMLEFT", anchor, "TOPLEFT", 6, 4)
	title:SetText(L["TYPE"])

	title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	title:SetWidth(64)
	title:SetJustifyH("CENTER")
	title:SetPoint("BOTTOM", anchor, "TOPLEFT", 333, 4)
	title:SetText(L["ENABLE"])

	title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	title:SetWidth(64)
	title:SetJustifyH("CENTER")
	title:SetPoint("BOTTOM", anchor, "TOPLEFT", 455, 4)
	title:SetText(L["DND"])

	for i = 2, #layout do
		anchor = CreateToastConfigLine(panel, layout[i], anchor)
	end

	panel.refresh = OptionsPanelRefresh

	_G.InterfaceOptions_AddCategory(panel, true)
end

-------------
-- LOADING --
-------------

function dispatcher:ADDON_LOADED(arg)
	if arg ~= addonName then return end

	if not _G.LS_TOASTS_CFG_GLOBAL then
		_G.LS_TOASTS_CFG_GLOBAL = {}
	end

	if _G.LS_TOASTS_CFG_GLOBAL["Default"] then
		CopyTable(DEFAULTS, _G.LS_TOASTS_CFG_GLOBAL["Default"])

		CopyTable(CopyTable(_G.LS_TOASTS_CFG_GLOBAL["Default"], _G.LS_TOASTS_CFG), CFG)
	else
		CopyTable(CopyTable(DEFAULTS, _G.LS_TOASTS_CFG), CFG)
	end

	if CFG.dnd.loot ~= nil then
		CFG.dnd.loot_special = CFG.dnd.loot
		CFG.dnd.loot = nil
	end

	if CFG.loot_enabled ~= nil then
		CFG.loot_special_enabled = CFG.loot_enabled
		CFG.loot_enabled = nil
	end

	if CFG.dnd.garrison ~= nil then
		CFG.dnd.garrison_6_0 = CFG.dnd.garrison
		CFG.dnd.garrison = nil
	end

	if CFG.garrison_enabled ~= nil then
		CFG.garrison_6_0_enabled = CFG.garrison_enabled
		CFG.garrison_enabled = nil
	end

	if _G.LS_TOASTS_CFG_GLOBAL["Default"] then
		_G.LS_TOASTS_CFG_GLOBAL["Default"].dnd.loot = nil
		_G.LS_TOASTS_CFG_GLOBAL["Default"].loot_enabled = nil
		_G.LS_TOASTS_CFG_GLOBAL["Default"].dnd.garrison = nil
		_G.LS_TOASTS_CFG_GLOBAL["Default"].garrison_enabled = nil
	end

	self:RegisterEvent("PLAYER_LOGIN")
	self:RegisterEvent("PLAYER_LOGOUT")
	self:UnregisterEvent("ADDON_LOADED")
end

function dispatcher:PLAYER_LOGIN()
	anchorFrame:SetMovable(true)
	anchorFrame:ClearAllPoints() -- NOTE: just do it
	anchorFrame:SetSize(234 * CFG.scale, 58 * CFG.scale)
	anchorFrame:SetPoint(unpack(CFG.point))

	EnableAchievementToasts()
	EnableArchaeologyToasts()
	EnableGarrisonToasts()
	EnableInstanceToasts()
	EnableSpecialLootToasts()
	EnableCommonLootToasts()
	EnableCurrencyLootToasts()
	EnableRecipeToasts()
	EnableWorldToasts()
	EnableTransmogToasts()

	for event in pairs(BLACKLISTED_EVENTS) do
		_G.AlertFrame:UnregisterEvent(event)
	end

	hooksecurefunc(_G.AlertFrame, "RegisterEvent", function(self, event)
		if event and BLACKLISTED_EVENTS[event] then
			self:UnregisterEvent(event)
		end
	end)

	_G.SLASH_LSTOASTS1 = "/lstoasts"
	_G.SlashCmdList["LSTOASTS"] = function(msg)
		if msg == "" then
			if not _G.LSToastsConfigPanel then
				CreateConfigPanel()
				_G.InterfaceOptionsFrame_OpenToCategory(_G.LSToastsConfigPanel)
			end

			if not _G.LSToastsConfigPanel:IsShown() then
				_G.InterfaceOptionsFrame_OpenToCategory(_G.LSToastsConfigPanel)
			else
				_G.InterfaceOptionsFrameOkay_OnClick(_G.InterfaceOptionsFrame)
			end
		elseif msg == "dump" then
			DumpToasts()
		end
	end
end

function dispatcher:PLAYER_LOGOUT()
	if _G.LS_TOASTS_CFG_GLOBAL["Default"] then
		_G.LS_TOASTS_CFG = DiffTable(_G.LS_TOASTS_CFG_GLOBAL["Default"], CFG)
	else
		_G.LS_TOASTS_CFG = DiffTable(DEFAULTS, CFG)
	end
end

dispatcher:RegisterEvent("ADDON_LOADED")
