local addonName, addonTable = ...
local L = addonTable.L

-- Lua
local _G = getfenv(0)
local math = _G.math
local string = _G.string
local table = _G.table
local hooksecurefunc = _G.hooksecurefunc
-- local issecurevariable = _G.issecurevariable
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
local PLAYER_NAME = _G.UnitName("player")
local HONOR_TEMPLATE = "%s |TInterface\\Icons\\PVPCurrency-Honor-%s:0|t"
local TITLE_DE_TEMPLATE = "%s |cff00ff00%s|r|TInterface\\Buttons\\UI-GroupLoot-DE-Up:0:0:0:0:32:32:0:32:0:31|t"
local TITLE_GREED_TEMPLATE = "%s |cff00ff00%s|r|TInterface\\Buttons\\UI-GroupLoot-Coin-Up:0:0:0:0:32:32:0:32:0:31|t"
local TITLE_NEED_TEMPLATE = "%s |cff00ff00%s|r|TInterface\\Buttons\\UI-GroupLoot-Dice-Up:0:0:0:0:32:32:0:32:0:31|t"
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

-- local secure_vars ={
-- 	common_loot = {
-- 		LOOT_ITEM_SELF = {
-- 			is_secure = true,
-- 			tainted_by = ""
-- 		},
-- 		LOOT_ITEM_PUSHED_SELF = {
-- 			is_secure = true,
-- 			tainted_by = ""
-- 		},
-- 		LOOT_ITEM_SELF_MULTIPLE = {
-- 			is_secure = true,
-- 			tainted_by = ""
-- 		},
-- 		LOOT_ITEM_PUSHED_SELF_MULTIPLE = {
-- 			is_secure = true,
-- 			tainted_by = ""
-- 		},
-- 	},
-- 	currency = {
-- 		CURRENCY_GAINED = {
-- 			is_secure = true,
-- 			tainted_by = ""
-- 		},
-- 		CURRENCY_GAINED_MULTIPLE = {
-- 			is_secure = true,
-- 			tainted_by = ""
-- 		},
-- 	},
-- }

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
	version = "",
	growth_direction = "DOWN",
	point = {"TOPLEFT", "UIParent", "TOPLEFT", 24, -12},
	max_active_toasts = 12,
	sfx_enabled = true,
	fadeout_delay = 2.8,
	scale = 1,
	colored_names_enabled = false,
	type = {
		achievement = {
			enabled = true,
			dnd = false,
		},
		archaeology = {
			enabled = true,
			dnd = false,
		},
		recipe = {
			enabled = true,
			dnd = false,
		},
		garrison_6_0 = {
			enabled = false,
			dnd = true,
		},
		garrison_7_0 = {
			enabled = true,
			dnd = true,
		},
		instance = { -- dungeons
			enabled = true,
			dnd = false,
		},
		loot_special = { -- personal loot, store item delivery, legendaries
			enabled = true,
			dnd = false,
			threshold = 1,
		},
		loot_common = {
			enabled = true,
			dnd = false,
			threshold = 1,
		},
		loot_currency = {
			enabled = true,
			dnd = false,
		},
		world = { -- world quest, invasion
			enabled = true,
			dnd = false,
		},
		transmog = {
			enabled = true,
			dnd = false,
		},
	}
}

local F = {} -- F for Functions
_G[addonName] = {
	[1] = F,
}

----------------
-- DISPATCHER --
----------------

local dispatcher = _G.CreateFrame("Frame")
dispatcher:SetScript("OnEvent", function(self, event, ...)
	self[event](self, ...)
end)

------------
-- ANCHOR --
------------

local function GetScreenQuadrant(frame)
	local x, y = frame:GetCenter()

	if not (x and y) then
		return "UNKNOWN"
	end

	local screenWidth = _G.UIParent:GetRight()
	local screenHeight = _G.UIParent:GetTop()
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

local anchorFrame = _G.CreateFrame("Frame", "LSToastAnchor", _G.UIParent)
anchorFrame:SetClampedToScreen(true)
anchorFrame:SetClampRectInsets(-24, 12, 12, -12)
anchorFrame:SetToplevel(true)
anchorFrame:RegisterForDrag("LeftButton")
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
	self:SetSize(234 * CFG.scale, 58 * CFG.scale)
	self:SetPoint(unpack(CFG.point))
end
anchorFrame.StartDrag = function(self)
	self:StartMoving()
end
anchorFrame.StopDrag = function(self)
	self:StopMovingOrSizing()

	local anchor = "UIParent"
	local p, rP, x, y = CalculatePosition(self)

	self:ClearAllPoints()
	self:SetPoint(p, anchor, rP, x, y)

	CFG.point = {p, anchor, rP, x, y}
end
anchorFrame:SetScript("OnDragStart", anchorFrame.StartDrag)
anchorFrame:SetScript("OnDragStop", anchorFrame.StopDrag)

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

-----------
-- UTILS --
-----------

local function ParseLink(link)
	if not link or link == "[]" or link == "" then
		return
	end

	local name
	link, name = string.match(link, "|H(.+)|h%[(.+)%]|h")
	local linkTable = {string.split(":", link)}

	if linkTable[1] ~= "item" then
		return link, linkTable[1], name
	end

	if linkTable[12] ~= "" then
		linkTable[12] = ""

		table.remove(linkTable, 15 + (tonumber(linkTable[14]) or 0))
	end

	return table.concat(linkTable, ":"), linkTable[1], name
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

	for _, v in pairs (CFG.type) do
		if v.dnd then
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
	toast.Border:SetVertexColor(1, 1, 1)
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

	if toast.RankBG then
		toast.RankBG:Hide()
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
		local quadrant = GetScreenQuadrant(self)
		local p, rP, x, y = "TOPLEFT", "BOTTOMRIGHT", -2, 2

		if quadrant == "BOTTOMLEFT" or quadrant == "BOTTOM" then
			p, rP, x, y = "BOTTOMLEFT", "TOPRIGHT", -2, -2
		elseif quadrant == "TOPRIGHT" or quadrant == "RIGHT" then
			p, rP, x, y = "TOPRIGHT", "BOTTOMLEFT", 2, 2
		elseif quadrant == "BOTTOMRIGHT" then
			p, rP, x, y = "BOTTOMRIGHT", "TOPLEFT", 2, -2
		end

		if self.type == "item" then
			_G.GameTooltip:SetOwner(self, "ANCHOR_NONE")
			_G.GameTooltip:SetPoint(p, self, rP, x, y)
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
					_G.GarrisonShipyardFollowerTooltip:SetPoint(p, self, rP, x, y)
				else
					_G.GarrisonFollowerTooltip:ClearAllPoints()
					_G.GarrisonFollowerTooltip:SetPoint(p, self, rP, x, y)
				end
			end
		elseif self.type == "ability" then
			_G.GameTooltip:SetOwner(self, "ANCHOR_NONE")
			_G.GameTooltip:SetPoint(p, self, rP, x, y)
			_G.GameTooltip:SetSpellByID(self.id)
			_G.GameTooltip:Show()
		end
	elseif self.link then
		local quadrant = GetScreenQuadrant(self)
		local p, rP, x, y = "TOPLEFT", "BOTTOMRIGHT", -2, 2

		if quadrant == "BOTTOMLEFT" or quadrant == "BOTTOM" then
			p, rP, x, y = "BOTTOMLEFT", "TOPRIGHT", -2, -2
		elseif quadrant == "TOPRIGHT" or quadrant == "RIGHT" then
			p, rP, x, y = "TOPRIGHT", "BOTTOMLEFT", 2, 2
		elseif quadrant == "BOTTOMRIGHT" then
			p, rP, x, y = "BOTTOMRIGHT", "TOPLEFT", 2, -2
		end

		if self.type == "item" then
			if string.find(self.link, "battlepet:") then
				local _, speciesID, level, breedQuality, maxHealth, power, speed = string.split(":", self.link)
				_G.GameTooltip:SetOwner(self, "ANCHOR_NONE")
				_G.GameTooltip:SetPoint(p, self, rP, x, y)
				_G.GameTooltip:Show()
				_G.BattlePetToolTip_Show(tonumber(speciesID), tonumber(level), tonumber(breedQuality), tonumber(maxHealth), tonumber(power), tonumber(speed))
			else
				_G.GameTooltip:SetOwner(self, "ANCHOR_NONE")
				_G.GameTooltip:SetPoint(p, self, rP, x, y)
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

			local rankBG = toast:CreateTexture(nil, "ARTWORK", nil, 1)
			rankBG:SetPoint("BOTTOMLEFT", toast.Icon, "BOTTOMLEFT", 2, 2)
			rankBG:SetPoint("BOTTOMRIGHT", toast.Icon, "BOTTOMRIGHT", -2, 2)
			rankBG:SetHeight(12)
			rankBG:SetColorTexture(0, 0, 0, 0.6)
			toast.RankBG = rankBG

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
		anchorFrame:StopDrag()
		anchorFrame:Disable()
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

do
	local function Toast_SetUp(achievementID, flag, isCriteria)
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

		SpawnToast(toast, CFG.type.achievement.dnd)
	end

	function dispatcher:ACHIEVEMENT_EARNED(achievementID, alreadyEarned)
		Toast_SetUp(achievementID, alreadyEarned)
	end

	function dispatcher:CRITERIA_EARNED(achievementID, criteriaString)
		Toast_SetUp(achievementID, criteriaString, true)
	end

	function dispatcher:EnableAchievementToasts()
		if CFG.type.achievement.enabled then
			self:RegisterEvent("ACHIEVEMENT_EARNED")
			self:RegisterEvent("CRITERIA_EARNED")
		end
	end

	function dispatcher:DisableAchievementToasts()
		self:UnregisterEvent("ACHIEVEMENT_EARNED")
		self:UnregisterEvent("CRITERIA_EARNED")
	end

	function dispatcher:TestAchievementToast()
		-- new, Shave and a Haircut
		Toast_SetUp(545, false)

		-- earned, Ten Hit Tunes
		Toast_SetUp(9828, true)
	end
end

-----------------
-- ARCHAEOLOGY --
-----------------

do
	local function Toast_SetUp(researchFieldID)
		local toast = GetToast("misc")
		local raceName, raceTexture	= _G.GetArchaeologyRaceInfoByID(researchFieldID)

		toast.Border:SetVertexColor(0.9, 0.4, 0.1)
		toast.Title:SetText(L["DIGSITE_COMPLETED"])
		toast.Text:SetText(raceName)
		toast.BG:SetTexture("Interface\\AddOns\\ls_Toasts\\media\\toast-bg-archaeology")
		toast.IconBorder:Hide()
		toast.Icon:SetPoint("TOPLEFT", 7, -3)
		toast.Icon:SetSize(76, 76)
		toast.Icon:SetTexture(raceTexture)
		toast.soundFile = "UI_DigsiteCompletion_Toast"

		SpawnToast(toast, CFG.type.archaeology.dnd)
	end

	function dispatcher:ARTIFACT_DIGSITE_COMPLETE(researchFieldID)
		Toast_SetUp(researchFieldID)
	end

	local function ArcheologyProgressBarAnimOut_OnFinished(self)
		self:GetParent():Hide()
	end

	function dispatcher:EnableArchaeologyToasts()
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

		if CFG.type.archaeology.enabled then
			dispatcher:RegisterEvent("ARTIFACT_DIGSITE_COMPLETE")
		end
	end

	function dispatcher:DisableArchaeologyToasts()
		dispatcher:UnregisterEvent("ARTIFACT_DIGSITE_COMPLETE")
	end

	function dispatcher:TestArchaeologyToast()
		dispatcher:ARTIFACT_DIGSITE_COMPLETE(408)
	end
end

--------------
-- GARRISON --
--------------

do
	local function GetGarrisonTypeByFollowerType(followerTypeID)
		if followerTypeID == _G.LE_FOLLOWER_TYPE_GARRISON_7_0 then
			return _G.LE_GARRISON_TYPE_7_0
		elseif followerTypeID == _G.LE_FOLLOWER_TYPE_GARRISON_6_0 or followerTypeID == _G.LE_FOLLOWER_TYPE_SHIPYARD_6_2 then
			return _G.LE_GARRISON_TYPE_6_0
		end
	end

	local function MissionToast_SetUp(garrisonType, missionID, isAdded)
		local toast = GetToast("mission")
		local missionInfo = _G.C_Garrison.GetBasicMissionInfo(missionID)
		local color = missionInfo.isRare and _G.ITEM_QUALITY_COLORS[3] or _G.ITEM_QUALITY_COLORS[1]
		local level = missionInfo.iLevel == 0 and missionInfo.level or missionInfo.iLevel

		if isAdded then
			toast.Title:SetText(L["GARRISON_MISSION_ADDED"])
		else
			toast.Title:SetText(L["GARRISON_MISSION_COMPLETED"])
		end

		toast.Text:SetText(missionInfo.name)
		toast.Level:SetText(level)
		toast.Border:SetVertexColor(color.r, color.g, color.b)
		toast.Icon:SetAtlas(missionInfo.typeAtlas, false)
		toast.soundFile = "UI_Garrison_Toast_MissionComplete"
		toast.id = missionID

		if CFG.colored_names_enabled then
			toast.Text:SetTextColor(color.r, color.g, color.b)
		end

		SpawnToast(toast, garrisonType == _G.LE_GARRISON_TYPE_7_0 and CFG.type.garrison_7_0.dnd or CFG.type.garrison_6_0.dnd)
	end

	function dispatcher:GARRISON_MISSION_FINISHED(followerTypeID, missionID)
		local garrisonType = GetGarrisonTypeByFollowerType(followerTypeID)

		if (garrisonType == _G.LE_GARRISON_TYPE_7_0 and not CFG.type.garrison_7_0.enabled) or
			(garrisonType == _G.LE_GARRISON_TYPE_6_0 and not CFG.type.garrison_6_0.enabled) then
			return
		end

		local _, instanceType = _G.GetInstanceInfo()
		local validInstance = false

		if instanceType == "none" or _G.C_Garrison.IsOnGarrisonMap() then
			validInstance = true
		end

		if validInstance then
			MissionToast_SetUp(garrisonType, missionID)
		end
	end

	function dispatcher:GARRISON_RANDOM_MISSION_ADDED(followerTypeID, missionID)
		local garrisonType = GetGarrisonTypeByFollowerType(followerTypeID)

		if (garrisonType == _G.LE_GARRISON_TYPE_7_0 and not CFG.type.garrison_7_0.enabled) or
			(garrisonType == _G.LE_GARRISON_TYPE_6_0 and not CFG.type.garrison_6_0.enabled) then
			return
		end

		MissionToast_SetUp(garrisonType, missionID, true)
	end

	------

	local function FollowerToast_SetUp(garrisonType, followerTypeID, followerID, name, texPrefix, level, quality, isUpgraded)
		local followerInfo = _G.C_Garrison.GetFollowerInfo(followerID)
		local followerStrings = _G.GarrisonFollowerOptions[followerTypeID].strings
		local upgradeTexture = _G.LOOTUPGRADEFRAME_QUALITY_TEXTURES[quality] or _G.LOOTUPGRADEFRAME_QUALITY_TEXTURES[2]
		local color = _G.ITEM_QUALITY_COLORS[quality]
		local toast = GetToast("follower")

		if followerTypeID == _G.LE_FOLLOWER_TYPE_SHIPYARD_6_2 then
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

		SpawnToast(toast, garrisonType == _G.LE_GARRISON_TYPE_7_0 and CFG.type.garrison_7_0.dnd or CFG.type.garrison_6_0.dnd)
	end

	function dispatcher:GARRISON_FOLLOWER_ADDED(followerID, name, _, level, quality, isUpgraded, texPrefix, followerTypeID)
		local garrisonType = GetGarrisonTypeByFollowerType(followerTypeID)

		if (garrisonType == _G.LE_GARRISON_TYPE_7_0 and not CFG.type.garrison_7_0.enabled) or
			(garrisonType == _G.LE_GARRISON_TYPE_6_0 and not CFG.type.garrison_6_0.enabled) then
			return
		end

		FollowerToast_SetUp(garrisonType, followerTypeID, followerID, name, texPrefix, level, quality, isUpgraded)
	end

	------

	local function BuildingToast_SetUp(buildingName)
		local toast = GetToast("misc")

		toast.Title:SetText(L["GARRISON_NEW_BUILDING"])
		toast.Text:SetText(buildingName)
		toast.Icon:SetTexture("Interface\\Icons\\Garrison_Build")
		toast.soundFile = "UI_Garrison_Toast_BuildingComplete"

		SpawnToast(toast, CFG.type.garrison_6_0.dnd)
	end

	function dispatcher:GARRISON_BUILDING_ACTIVATABLE(buildingName)
		BuildingToast_SetUp(buildingName)
	end

	------

	local function TalentToast_SetUp(talentID)
		local talent = _G.C_Garrison.GetTalent(talentID)
		local toast = GetToast("misc")

		toast.Title:SetText(L["GARRISON_NEW_TALENT"])
		toast.Text:SetText(talent.name)
		toast.Icon:SetTexture(talent.icon)
		toast.soundFile = "UI_OrderHall_Talent_Ready_Toast"

		SpawnToast(toast, CFG.type.garrison_7_0.dnd)
	end

	function dispatcher:GARRISON_TALENT_COMPLETE(garrisonType)
		TalentToast_SetUp(_G.C_Garrison.GetCompleteTalent(garrisonType))
	end

	function dispatcher:EnableGarrisonToasts()
		if CFG.type.garrison_6_0.enabled or CFG.type.garrison_7_0.enabled then
			self:RegisterEvent("GARRISON_FOLLOWER_ADDED")
			self:RegisterEvent("GARRISON_MISSION_FINISHED")
			self:RegisterEvent("GARRISON_RANDOM_MISSION_ADDED")

			if CFG.type.garrison_6_0.enabled then
				self:RegisterEvent("GARRISON_BUILDING_ACTIVATABLE")
			end

			if CFG.type.garrison_7_0.enabled then
				self:RegisterEvent("GARRISON_TALENT_COMPLETE")
			end
		end
	end

	function dispatcher:DisableGarrisonToasts()
		if not CFG.type.garrison_6_0.enabled and not CFG.type.garrison_7_0.enabled then
			self:UnregisterEvent("GARRISON_FOLLOWER_ADDED")
			self:UnregisterEvent("GARRISON_MISSION_FINISHED")
			self:UnregisterEvent("GARRISON_RANDOM_MISSION_ADDED")
		end

		if not CFG.type.garrison_6_0.enabled then
			self:UnregisterEvent("GARRISON_BUILDING_ACTIVATABLE")
		end

		if not CFG.type.garrison_7_0.enabled then
			self:UnregisterEvent("GARRISON_TALENT_COMPLETE")
		end
	end

	function dispatcher:TestGarrisonToast()
		-- follower
		local followers = _G.C_Garrison.GetFollowers(_G.LE_FOLLOWER_TYPE_GARRISON_6_0)
		local follower = followers and followers[1] or nil

		if follower then
			FollowerToast_SetUp(_G.LE_GARRISON_TYPE_6_0, follower.followerTypeID, follower.followerID, follower.name, nil, follower.level, follower.quality, false)
		end

		-- ship
		followers = _G.C_Garrison.GetFollowers(_G.LE_FOLLOWER_TYPE_SHIPYARD_6_2)
		follower = followers and followers[1] or nil

		if follower then
			FollowerToast_SetUp(_G.LE_GARRISON_TYPE_6_0, follower.followerTypeID, follower.followerID, follower.name, follower.texPrefix, follower.level, follower.quality, false)
		end

		-- garrison mission
		local missions = _G.C_Garrison.GetAvailableMissions(_G.LE_FOLLOWER_TYPE_GARRISON_6_0)
		local missionID = missions and missions[1] and missions[1].missionID or nil

		if missionID then
			MissionToast_SetUp(_G.LE_GARRISON_TYPE_6_0, missionID)
		end

		-- shipyard mission
		missions = _G.C_Garrison.GetAvailableMissions(_G.LE_FOLLOWER_TYPE_SHIPYARD_6_2)
		missionID = missions and missions[1] and missions[1].missionID or nil

		if missionID then
			MissionToast_SetUp(_G.LE_GARRISON_TYPE_6_0, missionID)
		end

		-- building
		local buildings = _G.C_Garrison.GetBuildings(_G.LE_GARRISON_TYPE_6_0)
		local buildingID = buildings and buildings[1] and buildings[1].buildingID or nil

		if buildingID then
			BuildingToast_SetUp(select(2, _G.C_Garrison.GetBuildingInfo(buildingID)))
		end
	end

	function dispatcher:TestClassHallToast()
		-- champion
		local followers = _G.C_Garrison.GetFollowers(_G.LE_FOLLOWER_TYPE_GARRISON_7_0)
		local follower = followers and followers[1] or nil

		if follower then
			FollowerToast_SetUp(_G.LE_GARRISON_TYPE_7_0, follower.followerTypeID, follower.followerID, follower.name, nil, follower.level, follower.quality, false)
		end

		-- mission
		local missions = _G.C_Garrison.GetAvailableMissions(_G.LE_FOLLOWER_TYPE_GARRISON_7_0)
		local missionID = missions and missions[1] and missions[1].missionID or nil

		if missionID then
			MissionToast_SetUp(_G.LE_GARRISON_TYPE_7_0, missionID)
		end

		-- talent
		local talents = _G.C_Garrison.GetTalentTrees(_G.LE_GARRISON_TYPE_7_0, select(3, _G.UnitClass("player")))
		local talentID = talents and talents[1] and talents[1][1] and talents[1][1].id or nil

		if talentID then
			TalentToast_SetUp(talentID)
		end
	end
end

--------------
-- INSTANCE --
--------------

do
	local function Toast_SetUp(name, subtypeID, textureFilename, moneyReward, xpReward, numItemRewards, isScenario, isScenarioBonusComplete)
		local toast = GetToast("scenario")
		local usedRewards = 0

		if moneyReward and moneyReward > 0 then
			usedRewards = usedRewards + 1
			local reward = toast["Reward"..usedRewards]

			if reward then
				_G.SetPortraitToTexture(reward.Icon, "Interface\\Icons\\inv_misc_coin_02")
				reward.money = moneyReward
				reward:Show()
			end
		end

		if xpReward and xpReward > 0 and _G.UnitLevel("player") < _G.MAX_PLAYER_LEVEL then
			usedRewards = usedRewards + 1
			local reward = toast["Reward"..usedRewards]

			if reward then
				_G.SetPortraitToTexture(reward.Icon, "Interface\\Icons\\xp_icon")
				reward.xp = xpReward
				reward:Show()
			end
		end

		for i = 1, numItemRewards or 0 do
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
			if isScenarioBonusComplete then
				toast.Bonus:Show()
			end

			toast.Title:SetText(L["SCENARIO_COMPLETED"])
			toast.soundFile = "UI_Scenario_Ending"
		else
			if subtypeID == _G.LFG_SUBTYPEID_HEROIC then
				toast.Heroic:Show()
			end

			toast.Title:SetText(L["DUNGEON_COMPLETED"])
			toast.soundFile = "LFG_Rewards"
		end

		toast.Text:SetText(name)
		toast.BG:SetTexture("Interface\\AddOns\\ls_Toasts\\media\\toast-bg-dungeon")
		toast.Icon:SetTexture("Interface\\LFGFrame\\LFGIcon-"..textureFilename)
		toast.usedRewards = usedRewards

		SpawnToast(toast, CFG.type.instance.dnd)
	end

	function dispatcher:LFG_COMPLETION_REWARD()
		if _G.C_Scenario.IsInScenario() and not _G.C_Scenario.TreatScenarioAsDungeon() then
			local _, _, _, _, hasBonusStep, isBonusStepComplete, _, _, _, scenarioType = _G.C_Scenario.GetInfo();

			if scenarioType ~= _G.LE_SCENARIO_TYPE_LEGION_INVASION then
				local name, _, subtypeID, textureFilename, moneyBase, moneyVar, experienceBase, experienceVar, numStrangers, numItemRewards = _G.GetLFGCompletionReward()

				Toast_SetUp(name, subtypeID, textureFilename, moneyBase + moneyVar * numStrangers, experienceBase + experienceVar * numStrangers, numItemRewards, true, hasBonusStep and isBonusStepComplete)
			end
		else
			local name, _, subtypeID, textureFilename, moneyBase, moneyVar, experienceBase, experienceVar, numStrangers, numItemRewards = _G.GetLFGCompletionReward()

			Toast_SetUp(name, subtypeID, textureFilename, moneyBase + moneyVar * numStrangers, experienceBase + experienceVar * numStrangers, numItemRewards)
		end
	end

	function dispatcher:EnableInstanceToasts()
		if CFG.type.instance.enabled then
			dispatcher:RegisterEvent("LFG_COMPLETION_REWARD")
		end
	end

	function dispatcher:DisableInstanceToasts()
		dispatcher:UnregisterEvent("LFG_COMPLETION_REWARD")
	end

	function dispatcher:TestInstanceToast()
		-- dungeon, Wailing Caverns
		local name, _, subtypeID, _, _, _, _, _, _, _, textureFilename = _G.GetLFGDungeonInfo(1)

		if name then
			Toast_SetUp(name, subtypeID, textureFilename, 123456, 123456, 0)
		end

		-- scenario, Crypt of Forgotten Kings
		name, _, subtypeID, _, _, _, _, _, _, _, textureFilename = _G.GetLFGDungeonInfo(504)

		if name then
			Toast_SetUp(name, subtypeID, textureFilename, 123456, 123456, 0, true, true)
		end
	end
end

------------------
-- SPECIAL LOOT --
------------------

do
	local function Toast_SetUp(link, quantity, rollType, roll, factionGroup, isItem, isMoney, isHonor, isPersonal, lessAwesome, isUpgraded, baseQuality, isLegendary, isStorePurchase)
		if isItem then
			if link then
				link = ParseLink(link)
				local name, _, quality, _, _, _, _, _, _, icon = _G.GetItemInfo(link)

				if quality >= CFG.type.loot_special.threshold and quality <= 5 then
					local toast = GetToast("item")
					local color = _G.ITEM_QUALITY_COLORS[quality] or _G.ITEM_QUALITY_COLORS[1]
					local title = L["YOU_WON"]
					local soundFile = 31578

					if rollType == _G.LOOT_ROLL_TYPE_NEED then
						title = TITLE_NEED_TEMPLATE:format(title, roll)
					elseif rollType == _G.LOOT_ROLL_TYPE_GREED then
						title = TITLE_GREED_TEMPLATE:format(title, roll)
					elseif rollType == _G.LOOT_ROLL_TYPE_DISENCHANT then
						title = TITLE_DE_TEMPLATE:format(title, roll)
					end

					if factionGroup then
						toast.BG:SetTexture("Interface\\AddOns\\ls_Toasts\\media\\toast-bg-"..factionGroup)
					end

					if isPersonal or lessAwesome then
						title = L["YOU_RECEIVED"]

						if lessAwesome then
							soundFile = 51402
						end
					end

					if isUpgraded then
						if baseQuality and baseQuality < quality then
							title = L["ITEM_UPGRADED_FORMAT"]:format(color.hex, _G["ITEM_QUALITY"..quality.."_DESC"])
						else
							title = L["ITEM_UPGRADED"]
						end

						soundFile = 51561

						local upgradeTexture = _G.LOOTUPGRADEFRAME_QUALITY_TEXTURES[quality] or _G.LOOTUPGRADEFRAME_QUALITY_TEXTURES[2]

						for i = 1, 5 do
							toast.Arrows["Arrow"..i]:SetAtlas(upgradeTexture.arrow, true)
						end

						toast.Arrows.requested = true

						toast.BG:SetTexture("Interface\\AddOns\\ls_Toasts\\media\\toast-bg-upgrade")
					end

					if isLegendary then
						title = L["ITEM_LEGENDARY"]
						soundFile = "UI_LegendaryLoot_Toast"

						toast.BG:SetTexture("Interface\\AddOns\\ls_Toasts\\media\\toast-bg-legendary")
						toast.Dragon:Show()
					end

					if isStorePurchase then
						title = L["BLIZZARD_STORE_PURCHASE_DELIVERED"]
						soundFile = "UI_igStore_PurchaseDelivered_Toast_01"

						toast.BG:SetTexture("Interface\\AddOns\\ls_Toasts\\media\\toast-bg-store")
					end

					toast.Title:SetText(title)
					toast.Text:SetText(name)
					toast.Count:SetText(quantity > 1 and quantity or "")
					toast.Border:SetVertexColor(color.r, color.g, color.b)
					toast.IconBorder:SetVertexColor(color.r, color.g, color.b)
					toast.Icon:SetTexture(icon)
					toast.UpgradeIcon:SetShown(IsItemAnUpgrade(link))
					toast.link = link
					toast.soundFile = soundFile

					if CFG.colored_names_enabled then
						toast.Text:SetTextColor(color.r, color.g, color.b)
					end

					SpawnToast(toast, CFG.type.loot_special.dnd)
				end
			end
		elseif isMoney then
			local toast = GetToast("misc")

			toast.Title:SetText(L["YOU_WON"])
			toast.Text:SetText(_G.GetMoneyString(quantity))
			toast.Border:SetVertexColor(0.9, 0.75, 0.26)
			toast.IconBorder:SetVertexColor(0.9, 0.75, 0.26)
			toast.Icon:SetTexture("Interface\\Icons\\INV_Misc_Coin_02")
			toast.soundFile = 31578

			SpawnToast(toast, CFG.type.loot_special.dnd)
		elseif isHonor then
			local toast = GetToast("misc")

			if factionGroup then
				toast.BG:SetTexture("Interface\\AddOns\\ls_Toasts\\media\\toast-bg-"..factionGroup)

				quantity = HONOR_TEMPLATE:format(quantity, factionGroup)
			else
				quantity = _G.MERCHANT_HONOR_POINTS:format(quantity)
			end

			toast.Title:SetText(L["YOU_RECEIVED"])
			toast.Text:SetText(quantity)
			toast.Icon:SetTexture("Interface\\Icons\\Achievement_LegionPVPTier4")
			toast.soundFile = 31578

			SpawnToast(toast, CFG.type.loot_special.dnd)
		end
	end

	local function BonusRollFrame_FinishedFading_Disabled(self)
		local frame = self:GetParent()

		_G.GroupLootContainer_RemoveFrame(_G.GroupLootContainer, frame)
	end

	local function BonusRollFrame_FinishedFading_Enabled(self)
		local frame = self:GetParent()

		Toast_SetUp(frame.rewardLink, frame.rewardQuantity, nil, nil, nil, frame.rewardType == "item", frame.rewardType == "money")
		_G.GroupLootContainer_RemoveFrame(_G.GroupLootContainer, frame)
	end

	function dispatcher:LOOT_ITEM_ROLL_WON(link, quantity, rollType, roll, isUpgraded)
		Toast_SetUp(link, quantity, rollType, roll, nil, true, nil, nil, nil, nil, isUpgraded)
	end

	function dispatcher:SHOW_LOOT_TOAST(typeID, link, quantity, _, _, isPersonal, _, lessAwesome, isUpgraded)
		local factionGroup = _G.UnitFactionGroup("player")
		factionGroup = (typeID == "honor" and factionGroup ~= "Neutral") and factionGroup or nil

		Toast_SetUp(link, quantity, nil, nil, factionGroup, typeID == "item", typeID == "money", typeID == "honor", isPersonal, lessAwesome, isUpgraded)
	end

	function dispatcher:SHOW_LOOT_TOAST_UPGRADE(link, quantity, _, _, baseQuality)
		Toast_SetUp(link, quantity, nil, nil, nil, true, nil, nil, nil, nil, true, baseQuality)
	end

	function dispatcher:SHOW_PVP_FACTION_LOOT_TOAST(typeID, link, quantity, _, _, isPersonal, lessAwesome)
		local factionGroup = _G.UnitFactionGroup("player")
		factionGroup = factionGroup ~= "Neutral" and factionGroup or nil

		Toast_SetUp(link, quantity, nil, nil, factionGroup, typeID == "item", typeID == "money", typeID == "honor", isPersonal, lessAwesome)
	end

	function dispatcher:SHOW_RATED_PVP_REWARD_TOAST(typeID, link, quantity, _, _, isPersonal, lessAwesome)
		local factionGroup = _G.UnitFactionGroup("player")
		factionGroup = factionGroup ~= "Neutral" and factionGroup or nil

		Toast_SetUp(link, quantity, nil, nil, factionGroup, typeID == "item", typeID == "money", typeID == "honor", isPersonal, lessAwesome)
	end

	function dispatcher:SHOW_LOOT_TOAST_LEGENDARY_LOOTED(link)
		Toast_SetUp(link, 1, nil, nil, nil, true, nil, nil, nil, nil, nil, nil, true)
	end

	function dispatcher:STORE_PRODUCT_DELIVERED(_, _, _, payloadID)
		local _, link = _G.GetItemInfo(payloadID)

		if link then
			Toast_SetUp(link, 1, nil, nil, nil, true, nil, nil, nil, nil, nil, nil, nil, true)
		else
			return _G.C_Timer.After(0.25, function() self:STORE_PRODUCT_DELIVERED(nil, nil, nil, payloadID) end)
		end
	end

	function dispatcher:EnableSpecialLootToasts()
		if CFG.type.loot_special.enabled then
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

	function dispatcher:DisableSpecialLootToasts()
		dispatcher:UnregisterEvent("LOOT_ITEM_ROLL_WON")
		dispatcher:UnregisterEvent("SHOW_LOOT_TOAST")
		dispatcher:UnregisterEvent("SHOW_LOOT_TOAST_LEGENDARY_LOOTED")
		dispatcher:UnregisterEvent("SHOW_LOOT_TOAST_UPGRADE")
		dispatcher:UnregisterEvent("SHOW_PVP_FACTION_LOOT_TOAST")
		dispatcher:UnregisterEvent("SHOW_RATED_PVP_REWARD_TOAST")
		dispatcher:UnregisterEvent("STORE_PRODUCT_DELIVERED")

		_G.BonusRollFrame.FinishRollAnim:SetScript("OnFinished", BonusRollFrame_FinishedFading_Disabled)
	end

	function dispatcher:TestSpecialLootToast()
		-- money
		Toast_SetUp(nil, 12345678, nil, nil, nil, nil, true)

		-- honour
		local factionGroup = _G.UnitFactionGroup("player")
		factionGroup = factionGroup ~= "Neutral" and factionGroup or "Horde"

		Toast_SetUp(nil, 1250, nil, nil, factionGroup, nil, nil, true)

		-- roll won, Tunic of the Underworld
		local _, link = _G.GetItemInfo(134439)

		if link then
			Toast_SetUp(link, 1, 1, 64, nil, true)
		end

		-- pvp, Fearless Gladiator's Dreadplate Girdle
		_, link = _G.GetItemInfo(142679)

		if link then
			Toast_SetUp(link, 1, nil, nil, factionGroup, true)
		end

		-- titanforged, Bonespeaker Bracers
		_, link = _G.GetItemInfo("item:134222::::::::110:63::36:4:3432:41:1527:3337:::")

		if link then
			Toast_SetUp(link, 1, nil, nil, nil, true, nil, nil, nil, nil, true)
		end

		-- upgraded from uncommon to epic, Nightsfall Brestplate
		_, link = _G.GetItemInfo("item:139055::::::::110:70::36:3:3432:1507:3336:::")

		if link then
			Toast_SetUp(link, 1, nil, nil, nil, true, nil, nil, nil, nil, true, 2)
		end
		-- legendary, Sephuz's Secret
		_, link = _G.GetItemInfo(132452)

		if link then
			Toast_SetUp(link, 1, nil, nil, nil, true, nil, nil, nil, nil, nil, nil, true)
		end

		-- store, Pouch of Enduring Wisdom
		_, link = _G.GetItemInfo(105911)

		if link then
			Toast_SetUp(link, 1, nil, nil, nil, true, nil, nil, nil, nil, nil, nil, nil, true)
		end
	end
end

-----------------
-- COMMON LOOT --
-----------------

do
	local function Toast_SetUp(link, quantity)
		if not GetToastToUpdate(link, "item") then
			local name, quality, icon, _

			if string.find(link, "battlepet:") then
				local _, speciesID, _, breedQuality, _ = string.split(":", link)
				name, icon = _G.C_PetJournal.GetPetInfoBySpeciesID(speciesID)
				quality = tonumber(breedQuality)
			else
				name, _, quality, _, _, _, _, _, _, icon = _G.GetItemInfo(link)
			end

			if quality >= CFG.type.loot_common.threshold and quality <= 4 then
				local toast = GetToast("item")
				local color = _G.ITEM_QUALITY_COLORS[quality or 4]

				toast.Title:SetText(L["YOU_RECEIVED"])
				toast.Text:SetText(name)
				toast.Count:SetText(quantity > 1 and quantity or "")
				toast.Border:SetVertexColor(color.r, color.g, color.b)
				toast.IconBorder:SetVertexColor(color.r, color.g, color.b)
				toast.Icon:SetTexture(icon)
				toast.link = link
				toast.chat = true

				if CFG.colored_names_enabled then
					toast.Text:SetTextColor(color.r, color.g, color.b)
				end

				SpawnToast(toast, CFG.type.loot_common.dnd)
			end
		end
	end

	local LOOT_ITEM_PATTERN
	local LOOT_ITEM_PUSHED_PATTERN
	local LOOT_ITEM_MULTIPLE_PATTERN
	local LOOT_ITEM_PUSHED_MULTIPLE_PATTERN

	function dispatcher:CHAT_MSG_LOOT(message, _, _, _, target)
		if target ~= PLAYER_NAME then
			return
		end

		local link, quantity = message:match(LOOT_ITEM_MULTIPLE_PATTERN)

		if not link then
			link, quantity = message:match(LOOT_ITEM_PUSHED_MULTIPLE_PATTERN)

			if not link then
				quantity, link = 1, message:match(LOOT_ITEM_PATTERN)

				if not link then
					quantity, link = 1, message:match(LOOT_ITEM_PUSHED_PATTERN)

					if not link then
						return
					end
				end
			end
		end

		link = ParseLink(link)
		quantity = tonumber(quantity) or 0

		_G.C_Timer.After(0.125, function() Toast_SetUp(link, quantity) end)
	end

	function dispatcher:EnableCommonLootToasts()
		-- local tainted = 0

		-- for k, v in pairs(secure_vars.common_loot) do
		-- 	local isSecure, name = issecurevariable(k)

		-- 	v.is_secure = isSecure
		-- 	v.tainted_by = name

		-- 	if not isSecure then
		-- 		tainted = tainted + 1
		-- 	end
		-- end

		-- -- Do not enable common loot toasts if required vars are tainted
		-- if tainted > 0 then
		-- 	CFG.type.loot_common.enabled = false
		-- else
		LOOT_ITEM_PATTERN = _G.LOOT_ITEM_SELF:gsub("%%s", "(.+)"):gsub("^", "^")
		LOOT_ITEM_PUSHED_PATTERN = _G.LOOT_ITEM_PUSHED_SELF:gsub("%%s", "(.+)"):gsub("^", "^")
		LOOT_ITEM_MULTIPLE_PATTERN = _G.LOOT_ITEM_SELF_MULTIPLE:gsub("%%s", "(.+)"):gsub("%%d", "(%%d+)"):gsub("^", "^")
		LOOT_ITEM_PUSHED_MULTIPLE_PATTERN = _G.LOOT_ITEM_PUSHED_SELF_MULTIPLE:gsub("%%s", "(.+)"):gsub("%%d", "(%%d+)"):gsub("^", "^")
		-- end

		if CFG.type.loot_common.enabled then
			self:RegisterEvent("CHAT_MSG_LOOT")
		end
	end

	function dispatcher:DisableCommonLootToasts()
		self:UnregisterEvent("CHAT_MSG_LOOT")
	end

	function dispatcher:TestCommonLootToast()
		-- item, Chaos Crystal
		local _, link = _G.GetItemInfo(124442)

		if link then
			Toast_SetUp(link, 44)
		end

		-- battlepet, Anubisath Idol
		Toast_SetUp("battlepet:1155:25:3:1725:276:244:0000000000000000", 1)
	end
end

--------------
-- CURRENCY --
--------------

do
	local function Toast_SetUp(link, quantity)
		local toast, isQueued = GetToastToUpdate(link, "item")
		local isUpdated = true

		if not toast then
			toast = GetToast("item")
			isUpdated = false
		end

		if not isUpdated then
			local name, _, icon, _, _, _, _, quality = _G.GetCurrencyInfo(link)
			local color = _G.ITEM_QUALITY_COLORS[quality] or _G.ITEM_QUALITY_COLORS[1]

			toast.Title:SetText(L["YOU_RECEIVED"])
			toast.Text:SetText(name)
			toast.Count:SetText(quantity > 1 and quantity or "")
			toast.Border:SetVertexColor(color.r, color.g, color.b)
			toast.IconBorder:SetVertexColor(color.r, color.g, color.b)
			toast.Icon:SetTexture(icon)
			toast.itemCount = quantity
			toast.link = link
			toast.soundFile = 31578

			if CFG.colored_names_enabled then
				toast.Text:SetTextColor(color.r, color.g, color.b)
			end

			SpawnToast(toast, CFG.type.loot_currency.dnd)
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

	local CURRENCY_GAINED_PATTERN
	local CURRENCY_GAINED_MULTIPLE_PATTERN

	function dispatcher:CHAT_MSG_CURRENCY(message)
		local link, quantity = message:match(CURRENCY_GAINED_MULTIPLE_PATTERN)

		if not link then
			quantity, link = 1, message:match(CURRENCY_GAINED_PATTERN)

			if not link then
				return
			end
		end

		link = ParseLink(link)
		quantity = tonumber(quantity) or 0

		Toast_SetUp(link, quantity)
	end

	function dispatcher:EnableCurrencyLootToasts()
	-- 	local tainted = 0

	-- 	for k, v in pairs(secure_vars.currency) do
	-- 		local isSecure, name = issecurevariable(k)

	-- 		v.is_secure = isSecure
	-- 		v.tainted_by = name

	-- 		if not isSecure then
	-- 			tainted = tainted + 1
	-- 		end
	-- 	end

	-- 	-- Do not enable currency toasts if required vars are tainted
	-- 	if tainted > 0 then
	-- 		CFG.type.loot_currency.enabled = false
	-- 	else
		CURRENCY_GAINED_PATTERN = _G.CURRENCY_GAINED:gsub("%%s", "(.+)"):gsub("^", "^")
		CURRENCY_GAINED_MULTIPLE_PATTERN = _G.CURRENCY_GAINED_MULTIPLE:gsub("%%s", "(.+)"):gsub("%%d", "(%%d+)"):gsub("^", "^")
	-- 	end

		if CFG.type.loot_currency.enabled then
			self:RegisterEvent("CHAT_MSG_CURRENCY")
		end
	end

	function dispatcher:DisableCurrencyLootToasts()
		self:UnregisterEvent("CHAT_MSG_CURRENCY")
	end

	function dispatcher:TestCurrencyToast()
		-- Order Resources
		local link, _ = _G.GetCurrencyLink(1220)

		if link then
			Toast_SetUp(link, math.random(300, 600))
		end
	end
end

------------
-- RECIPE --
------------

do
	local function Toast_SetUp(recipeID)
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
				toast.RankBG:SetShown(not not rank)
				toast.Icon:SetTexture(_G.C_TradeSkillUI.GetTradeSkillTexture(tradeSkillID))
				toast.soundFile = "UI_Professions_NewRecipeLearned_Toast"
				toast.id = recipeID

				SpawnToast(toast, CFG.type.recipe.dnd)
			end
		end
	end

	function dispatcher:NEW_RECIPE_LEARNED(recipeID)
		Toast_SetUp(recipeID)
	end

	function dispatcher:EnableRecipeToasts()
		if CFG.type.recipe.enabled then
			dispatcher:RegisterEvent("NEW_RECIPE_LEARNED")
		end
	end

	function dispatcher:DisableRecipeToasts()
		dispatcher:UnregisterEvent("NEW_RECIPE_LEARNED")
	end

	function dispatcher:TestRecipeToast()
		-- no rank, Elixir of Minor Defence
		Toast_SetUp(7183)

		-- rank 2, Word of Critical Strike
		Toast_SetUp(190992)
	end
end

-----------
-- WORLD --
-----------
do
	local function Toast_SetUp(questID, name, moneyReward, xpReward, numCurrencyRewards, isInvasion, isInvasionBonusComplete)
		if GetToastToUpdate(questID, "scenario") then
			return
		end

		local toast = GetToast("scenario")
		-- local scenarioName, _, _, _, hasBonusStep, isBonusStepComplete, _, xp, money, _, areaName = _G.C_Scenario.GetInfo()
		-- local scenarioName, _, _, _, hasBonusStep, isBonusStepComplete, _, xp, money, _, areaName =
			-- "Invasion: Azshara", 0, 0, 0, false, false, true, 12345, 12345, 4, "Azshara"
		local usedRewards = 0

		if moneyReward and moneyReward > 0 then
			usedRewards = usedRewards + 1
			local reward = toast["Reward"..usedRewards]

			if reward then
				_G.SetPortraitToTexture(reward.Icon, "Interface\\Icons\\inv_misc_coin_02")
				reward.money = moneyReward
				reward:Show()
			end
		end

		if xpReward and xpReward > 0 and _G.UnitLevel("player") < _G.MAX_PLAYER_LEVEL then
			usedRewards = usedRewards + 1
			local reward = toast["Reward"..usedRewards]

			if reward then
				_G.SetPortraitToTexture(reward.Icon, "Interface\\Icons\\xp_icon")
				reward.xp = xpReward
				reward:Show()
			end
		end

		for i = 1, numCurrencyRewards or 0 do
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

		if isInvasion then
			if isInvasionBonusComplete then
				toast.Bonus:Show()
			end

			toast.Title:SetText(L["SCENARIO_INVASION_COMPLETED"])
			toast.BG:SetTexture("Interface\\AddOns\\ls_Toasts\\media\\toast-bg-legion")
			toast.Icon:SetTexture("Interface\\Icons\\Ability_Warlock_DemonicPower")
			toast.Border:SetVertexColor(60 / 255, 255 / 255, 38 / 255) -- fel green #3cff26
			toast.IconBorder:SetVertexColor(60 / 255, 255 / 255, 38 / 255) -- fel green #3cff26
			toast.soundFile = "UI_Scenario_Ending"
		else
			local _, _, worldQuestType, rarity, _, tradeskillLineIndex = _G.GetQuestTagInfo(questID)
			local color = _G.WORLD_QUEST_QUALITY_COLORS[rarity] or _G.WORLD_QUEST_QUALITY_COLORS[1]

			if worldQuestType == _G.LE_QUEST_TAG_TYPE_PVP then
				toast.Icon:SetTexture("Interface\\Icons\\achievement_arena_2v2_1")
			elseif worldQuestType == _G.LE_QUEST_TAG_TYPE_PET_BATTLE then
				toast.Icon:SetTexture("Interface\\Icons\\INV_Pet_BattlePetTraining")
			elseif worldQuestType == _G.LE_QUEST_TAG_TYPE_PROFESSION and tradeskillLineIndex then
				toast.Icon:SetTexture(select(2, _G.GetProfessionInfo(tradeskillLineIndex)))
			elseif worldQuestType == _G.LE_QUEST_TAG_TYPE_DUNGEON or worldQuestType == _G.LE_QUEST_TAG_TYPE_RAID then
				toast.Icon:SetTexture("Interface\\Icons\\INV_Misc_Bone_Skull_02")
			else
				toast.Icon:SetTexture("Interface\\Icons\\Achievement_Quests_Completed_TwilightHighlands")
			end

			toast.Title:SetText(L["WORLD_QUEST_COMPLETED"])
			toast.BG:SetTexture("Interface\\AddOns\\ls_Toasts\\media\\toast-bg-worldquest")
			toast.Border:SetVertexColor(color.r, color.g, color.b)
			toast.IconBorder:SetVertexColor(color.r, color.g, color.b)
			toast.soundFile = "UI_WorldQuest_Complete"
		end

		toast.Text:SetText(name)
		toast.usedRewards = usedRewards
		toast.id = questID

		SpawnToast(toast, CFG.type.world.dnd)
	end

	function dispatcher:SCENARIO_COMPLETED(questID)
		local scenarioName, _, _, _, hasBonusStep, isBonusStepComplete, _, xp, money, scenarioType, areaName = _G.C_Scenario.GetInfo();

		if scenarioType == _G.LE_SCENARIO_TYPE_LEGION_INVASION then
			if questID then
				Toast_SetUp(questID, areaName or scenarioName, money, xp, nil, true, hasBonusStep and isBonusStepComplete)
			end
		end
	end

	function dispatcher:QUEST_TURNED_IN(questID)
		if _G.QuestUtils_IsQuestWorldQuest(questID) then
			Toast_SetUp(questID, _G.C_TaskQuest.GetQuestInfoByQuestID(questID), _G.GetQuestLogRewardMoney(questID), _G.GetQuestLogRewardXP(questID), _G.GetNumQuestLogRewardCurrencies(questID))
		end
	end

	function dispatcher:QUEST_LOOT_RECEIVED(questID, itemLink)
		--- QUEST_LOOT_RECEIVED may fire before QUEST_TURNED_IN
		if _G.QuestUtils_IsQuestWorldQuest(questID) then
			if not GetToastToUpdate(questID, "scenario") then
				Toast_SetUp(questID, _G.C_TaskQuest.GetQuestInfoByQuestID(questID), _G.GetQuestLogRewardMoney(questID), _G.GetQuestLogRewardXP(questID), _G.GetNumQuestLogRewardCurrencies(questID))
			end
		end

		UpdateToast(questID, "scenario", itemLink)
	end

	function dispatcher:EnableWorldToasts()
		if CFG.type.world.enabled then
			dispatcher:RegisterEvent("SCENARIO_COMPLETED")
			dispatcher:RegisterEvent("QUEST_TURNED_IN")
			dispatcher:RegisterEvent("QUEST_LOOT_RECEIVED")
		end
	end

	function dispatcher:DisableWorldToasts()
		dispatcher:UnregisterEvent("SCENARIO_COMPLETED")
		dispatcher:UnregisterEvent("QUEST_TURNED_IN")
		dispatcher:UnregisterEvent("QUEST_LOOT_RECEIVED")
	end

	function dispatcher:TestWorldToast()
		-- reward, Blood of Sargeras
		local _, link = _G.GetItemInfo(124124)

		if link then
			-- invasion
			Toast_SetUp(43301, "", 123456, 123456, nil, true)
			UpdateToast(43301, "scenario", link)

			-- world quest, may not work
			local quests = _G.C_TaskQuest.GetQuestsForPlayerByMapID(1014)

			if #quests == 0 then
				quests = _G.C_TaskQuest.GetQuestsForPlayerByMapID(1015)

				if #quests == 0 then
					quests = _G.C_TaskQuest.GetQuestsForPlayerByMapID(1017)

					if #quests == 0 then
						quests = _G.C_TaskQuest.GetQuestsForPlayerByMapID(1018)

						if #quests == 0 then
							quests = _G.C_TaskQuest.GetQuestsForPlayerByMapID(1021)

							if #quests == 0 then
								quests = _G.C_TaskQuest.GetQuestsForPlayerByMapID(1024)

								if #quests == 0 then
									quests = _G.C_TaskQuest.GetQuestsForPlayerByMapID(1033)

									if #quests == 0 then
										quests = _G.C_TaskQuest.GetQuestsForPlayerByMapID(1096)
									end
								end
							end
						end
					end
				end
			end

			for _, quest in pairs(quests) do
				if _G.HaveQuestData(quest.questId) then
					if _G.QuestUtils_IsQuestWorldQuest(quest.questId) then
						Toast_SetUp(quest.questId, _G.C_TaskQuest.GetQuestInfoByQuestID(quest.questId), 123456, 123456)
						UpdateToast(quest.questId, "scenario", link)

						return
					end
				end
			end
		end
	end
end

--------------
-- TRANSMOG --
--------------

do
	local function IsAppearanceKnown(sourceID)
		local data = _G.C_TransmogCollection.GetSourceInfo(sourceID)
		local sources = _G.C_TransmogCollection.GetAppearanceSources(data.visualID)

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

	local function Toast_SetUp(sourceID, isAdded)
		local _, _, _, icon, _, _, transmogLink = _G.C_TransmogCollection.GetAppearanceSourceInfo(sourceID)
		local name
		transmogLink, _, name = ParseLink(transmogLink)

		if not transmogLink then
			return _G.C_Timer.After(0.25, function() Toast_SetUp(sourceID, isAdded) end)
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
		toast.id = sourceID
		toast.link = transmogLink
		toast.soundFile = "UI_DigsiteCompletion_Toast"

		SpawnToast(toast, CFG.type.transmog.dnd)
	end

	function dispatcher:TRANSMOG_COLLECTION_SOURCE_ADDED(sourceID)
		local isKnown = IsAppearanceKnown(sourceID)

		if isKnown == false then
			Toast_SetUp(sourceID, true)
		elseif isKnown == nil then
			_G.C_Timer.After(0.25, function() self:TRANSMOG_COLLECTION_SOURCE_ADDED(sourceID) end)
		end
	end

	function dispatcher:TRANSMOG_COLLECTION_SOURCE_REMOVED(sourceID)
		local isKnown = IsAppearanceKnown(sourceID)

		if isKnown == false then
			Toast_SetUp(sourceID)
		elseif isKnown == nil then
			_G.C_Timer.After(0.25, function() self:TRANSMOG_COLLECTION_SOURCE_REMOVED(sourceID) end)
		end
	end

	function dispatcher:EnableTransmogToasts()
		if CFG.type.transmog.enabled then
			dispatcher:RegisterEvent("TRANSMOG_COLLECTION_SOURCE_ADDED")
			dispatcher:RegisterEvent("TRANSMOG_COLLECTION_SOURCE_REMOVED")
		end
	end

	function dispatcher:DisableTransmogToasts()
		dispatcher:UnregisterEvent("TRANSMOG_COLLECTION_SOURCE_ADDED")
		dispatcher:UnregisterEvent("TRANSMOG_COLLECTION_SOURCE_REMOVED")
	end

	function dispatcher:TestTransmogToast()
		local appearance = _G.C_TransmogCollection.GetCategoryAppearances(1) and _G.C_TransmogCollection.GetCategoryAppearances(1)[1]
		local source = _G.C_TransmogCollection.GetAppearanceSources(appearance.visualID) and _G.C_TransmogCollection.GetAppearanceSources(appearance.visualID)[1]

		-- added
		Toast_SetUp(source.sourceID, true)

		-- removed
		Toast_SetUp(source.sourceID)
	end
end

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

local function ReplaceTable(src, dest)
	return CopyTable(src, table.wipe(dest))
end

local function DiffTable(src, dest)
	if type(dest) ~= "table" then
		return {}
	end

	if type(src) ~= "table" then
		return CopyTable(dest)
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

	return CopyTable(dest)
end

local panels = {}

local function RegisterControlForRefresh(parent, control)
	if not parent or not control then return end

	parent.controls = parent.controls or {}
	table.insert(parent.controls, control)
end

local function RefreshOptions(panel)
	for _, control in pairs(panel.controls) do
		if control.RefreshValue then
			control:RefreshValue()
		end
	end
end

local function RefreshAllOptions()
	anchorFrame:Refresh()

	for i = 1, #panels do
		panels[i]:refresh()
	end
end

local function ToggleToasts(value, state)
	if value == "achievement" then
		if state then
			dispatcher:EnableAchievementToasts()
		else
			dispatcher:DisableAchievementToasts()
		end
	elseif value == "archaeology" then
		if state then
			dispatcher:EnableArchaeologyToasts()
		else
			dispatcher:DisableArchaeologyToasts()
		end
	elseif value == "garrison_6_0" or value == "garrison_7_0" then
		if state then
			dispatcher:EnableGarrisonToasts()
		else
			dispatcher:DisableGarrisonToasts()
		end
	elseif value == "instance" then
		if state then
			dispatcher:EnableInstanceToasts()
		else
			dispatcher:DisableInstanceToasts()
		end
	elseif value == "loot_special" then
		if state then
			dispatcher:EnableSpecialLootToasts()
		else
			dispatcher:DisableSpecialLootToasts()
		end
	elseif value == "loot_common" then
		if state then
			dispatcher:EnableCommonLootToasts()
		else
			dispatcher:DisableCommonLootToasts()
		end
	elseif value == "loot_currency" then
		if state then
			dispatcher:EnableCurrencyLootToasts()
		else
			dispatcher:DisableCurrencyLootToasts()
		end
	elseif value == "recipe" then
		if state then
			dispatcher:EnableRecipeToasts()
		else
			dispatcher:DisableRecipeToasts()
		end
	elseif value == "world" then
		if state then
			dispatcher:EnableWorldToasts()
		else
			dispatcher:DisableWorldToasts()
		end
	elseif value == "transmog" then
		if state then
			dispatcher:EnableTransmogToasts()
		else
			dispatcher:DisableTransmogToasts()
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

local function CheckButton_RefreshValue(self)
	self:SetChecked(self:GetValue())
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

local function CreateConfigCheckButton(panel, params)
	params = params or {}

	local object = _G.CreateFrame("CheckButton", params.name, params.parent or panel, "InterfaceOptionsCheckButtonTemplate")
	object:SetHitRectInsets(0, 0, 0, 0)
	object.type = "Button"
	object.GetValue = params.get
	object.SetValue = params.set
	object.RefreshValue = CheckButton_RefreshValue
	object:SetScript("OnClick", params.click or CheckButton_OnClick)
	object.Text:SetText(params.text)

	if params.tooltip_text then
		object.tooltipText = params.tooltip_text
		object:SetScript("OnEnter", CheckButton_OnEnter)
		object:SetScript("OnLeave", CheckButton_OnLeave)
	end

	RegisterControlForRefresh(panel, object)

	return object
end

------

local function CreateConfigButton(panel, params)
	params = params or {}

	local object = _G.CreateFrame("Button", params.name, params.parent or panel, "UIPanelButtonTemplate")
	object.type = "Button"
	object:SetText(params.text)
	object:SetWidth(math.max(object:GetTextWidth() + 18, 70))
	object:SetScript("OnClick", params.func)

	return object
end

------

local function DropDownMenu_RefreshValue(self)
	_G.UIDropDownMenu_Initialize(self, self.initialize)
	_G.UIDropDownMenu_SetSelectedValue(self, self:GetValue())
end

local function CreateConfigDropDownMenu(panel, params)
	params = params or {}

	local object = _G.CreateFrame("Frame", params.name, params.parent or panel, "UIDropDownMenuTemplate")
	object.type = "DropDownMenu"
	object.SetValue = params.set
	object.GetValue = params.get
	object.RefreshValue = DropDownMenu_RefreshValue
	_G.UIDropDownMenu_Initialize(object, params.init)
	_G.UIDropDownMenu_SetWidth(object, params.width or 128)

	local text = object:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	text:SetPoint("BOTTOMLEFT", object, "TOPLEFT", 16, 3)
	text:SetJustifyH("LEFT")
	text:SetText(params.text)
	object.Label = text

	RegisterControlForRefresh(panel, object)

	return object
end

------

local function Slider_RefreshValue(self)
	local value = self:GetValue()

	self.value = value
	self:SetDisplayValue(value)
	self.CurrentValue:SetText(value)
end

local function Slider_OnValueChanged(self, value, userInput)
	if userInput then
		value = tonumber(string.format("%.1f", value))

		if value ~= self.value then
			self:SetValue(value)
			self:RefreshValue()
		end
	end
end

local function CreateConfigSlider(panel, params)
	params = params or {}

	local object = _G.CreateFrame("Slider", params.name, params.parent or panel, "OptionsSliderTemplate")
	object.type = "Slider"
	object:SetMinMaxValues(params.min, params.max)
	object:SetValueStep(params.step)
	object:SetObeyStepOnDrag(true)
	object.SetDisplayValue = object.SetValue -- default
	object.GetValue = params.get
	object.SetValue = params.set
	object.RefreshValue = Slider_RefreshValue
	object:SetScript("OnValueChanged", Slider_OnValueChanged)

	local text = _G[object:GetName().."Text"]
	text:SetText(params.text)
	text:SetVertexColor(1, 0.82, 0)
	object.Text = text

	local lowText = _G[object:GetName().."Low"]
	lowText:SetText(params.min)
	object.LowValue = lowText

	local curText = object:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	curText:SetPoint("TOP", object, "BOTTOM", 0, 3)
	object.CurrentValue = curText

	local highText = _G[object:GetName().."High"]
	highText:SetText(params.max)
	object.HighValue = highText

	RegisterControlForRefresh(panel, object)

	return object
end

------

local function CreateConfigDivider(panel, params)
	params = params or {}

	local object = panel:CreateTexture(nil, "ARTWORK")
	object:SetHeight(4)
	object:SetPoint("LEFT", 10, 0)
	object:SetPoint("RIGHT", -10, 0)
	object:SetTexture("Interface\\AchievementFrame\\UI-Achievement-RecentHeader")
	object:SetTexCoord(0, 1, 0.0625, 0.65625)
	object:SetAlpha(0.5)

	local label = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalMed2")
	label:SetWordWrap(false)
	label:SetPoint("LEFT", object, "LEFT", 12, 1)
	label:SetPoint("RIGHT", object, "RIGHT", -12, 1)
	label:SetText(params.text)
	object.Text = label

	return object
end

------

local function InfoButton_OnEnter(self)
	_G.HelpPlate_TooltipHide()

	if self.tooltipDir == "UP" then
		_G.HelpPlateTooltip.ArrowUP:Show()
		_G.HelpPlateTooltip.ArrowGlowUP:Show()
		_G.HelpPlateTooltip:SetPoint("BOTTOM", self, "TOP", 0, 10)
	elseif self.tooltipDir == "DOWN" then
		_G.HelpPlateTooltip.ArrowDOWN:Show()
		_G.HelpPlateTooltip.ArrowGlowDOWN:Show()
		_G.HelpPlateTooltip:SetPoint("TOP", self, "BOTTOM", 0, -10)
	elseif self.tooltipDir == "LEFT" then
		_G.HelpPlateTooltip.ArrowLEFT:Show()
		_G.HelpPlateTooltip.ArrowGlowLEFT:Show()
		_G.HelpPlateTooltip:SetPoint("RIGHT", self, "LEFT", -10, 0)
	elseif self.tooltipDir == "RIGHT" then
		_G.HelpPlateTooltip.ArrowRIGHT:Show()
		_G.HelpPlateTooltip.ArrowGlowRIGHT:Show()
		_G.HelpPlateTooltip:SetPoint("LEFT", self, "RIGHT", 10, 0)
	end

	_G.HelpPlateTooltip.Text:SetWidth(0)
	_G.HelpPlateTooltip.Text:SetText(self.toolTipText)

	_G.HelpPlateTooltip:SetWidth(_G.HelpPlateTooltip.Text:GetWidth() + 20)
	_G.HelpPlateTooltip:Show()
end

local function InfoButton_OnLeave()
	_G.HelpPlateTooltip:SetWidth(220)
	_G.HelpPlateTooltip.Text:SetWidth(200)
	_G.HelpPlate_TooltipHide()
end

local function CreateWarningPlate(panel, params)
	params = params or {}

	local object = _G.CreateFrame("Frame", params.name, params.parent or panel, "ThinBorderTemplate")
	object:EnableMouse(true)
	object:SetFrameLevel(1)
	object:SetFrameStrata("DIALOG")
	object:Show()
	object.RefreshValue = params.refresh

	for i = 1, #object.Textures do
		object.Textures[i]:SetVertexColor(1, 0.82, 0)
	end

	local texture = object:CreateTexture(nil, "BACKGROUND")
	texture:SetTexture("Interface\\AddOns\\ls_Toasts\\media\\warning-bg", true, true)
	texture:SetHorizTile(true)
	texture:SetVertTile(true)
	texture:SetAllPoints()
	texture:SetVertexColor(1, 0.82, 0, 0.5)

	local button = _G.CreateFrame("Button", "$parentInfoButton", object)
	button:SetSize(24, 24)
	button:SetScript("OnClick", params.click)
	button:SetScript("OnEnter", InfoButton_OnEnter)
	button:SetScript("OnLeave", InfoButton_OnLeave)
	button.toolTipText = params.tooltip_text
	button.tooltipDir = params.tooltip_dir or "UP"
	button:SetPoint("CENTER", object, "CENTER", 0, 0)
	object.Button = button

	button:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight", "ADD")

	texture = button:CreateTexture(nil, "ARTWORK")
	texture:SetAllPoints()
	texture:SetTexture("Interface\\COMMON\\help-i")
	texture:SetTexCoord(13 / 64, 51 / 64, 13 / 64, 51 / 64)
	texture:SetBlendMode("BLEND")

	RegisterControlForRefresh(panel, object)

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

local function CreateToastConfigLine(panel, params)
	params = params or {}

	local object = _G.CreateFrame("Frame", params.name, params.parent or panel)
	object:SetHeight(33)
	object:SetPoint("LEFT", panel, "LEFT", 16, 0)
	object:SetPoint("RIGHT", panel, "RIGHT", -16, 0)

	local texture = object:CreateTexture(nil, "BACKGROUND", nil, -8)
	texture:SetAllPoints()
	object.BG = texture

	local name = object:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
	name:SetPoint("TOPLEFT", object, "TOPLEFT", 6, 0)
	name:SetHeight(33)
	name:SetJustifyV("MIDDLE")
	name:SetText(params.text)

	if params.warning_refresh then
		local warning = CreateWarningPlate(panel, {
			name = "$parentWarningPlate",
			frame_level = object:GetFrameLevel() + 4,
			tooltip_text = params.warning_tooltip_text,
			tooltip_dir = params.warning_tooltip_dir,
			refresh = params.warning_refresh
		})
		warning:SetAllPoints(object)
	end

	if params.dropdown then
		local settings = _G.CreateFrame("Button", "$parentSettingsButton", object)
		settings:SetSize(22, 22)
		settings:SetPoint("LEFT", name, "RIGHT", 0, 0)
		settings:SetScript("OnEnter", SettingsButton_OnEnter)
		settings:SetScript("OnLeave", SettingsButton_OnLeave)
		settings:SetScript("OnClick", SettingsButton_OnClick)
		settings.DropDown = params.dropdown

		texture = settings:CreateTexture(nil, "ARTWORK")
		texture:SetTexture("Interface\\WorldMap\\GEAR_64GREY")
		texture:SetAlpha(0.5)
		texture:SetPoint("TOPLEFT", 1, -1)
		texture:SetPoint("BOTTOMRIGHT", -1, 1)
		settings.Icon = texture
	end

	local toastToggle = CreateConfigCheckButton(panel, {
		parent = object,
		name = "$parentToggle",
		tooltip_text = params.toast_tooltip,
		get = params.toast_get,
		set = params.toast_set,
	})
	toastToggle:SetPoint("TOPLEFT", object, "TOPLEFT", 320, -4)

	local dndToggle = CreateConfigCheckButton(panel, {
		parent = object,
		name = "$parentDNDToggle",
		tooltip_text = L["DND_TOOLTIP"],
		get = params.dnd_get,
		set = params.dnd_set,
	})
	dndToggle:SetPoint("LEFT", toastToggle, "RIGHT", 96, 0)

	if params.test_func then
		local testButton = CreateConfigButton(panel, {
			parent = object,
			name = "$parentTestButton",
			text = L["TEST"],
			func = params.test_func
		})
		testButton:SetPoint("TOPRIGHT", object, "TOPRIGHT", -6, -5)
	end

	return object
end

------

local function CreateConfigDialog(panel, params)
	local object = _G.CreateFrame("Frame", params.name, panel)
	object:SetPoint("CENTER")
	object:SetFrameStrata("DIALOG")
	object:Hide()
	object:SetScript("OnShow", params.on_show)
	object:SetScript("OnHide", params.on_hide)

	object:SetBackdrop({
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
		edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
		tile = true,
		tileSize = 32,
		edgeSize = 32,
		insets = { left = 11, right = 12, top = 12, bottom = 11 }
	})

	local cover = _G.CreateFrame("Frame", nil, object)
	cover:SetFrameLevel(object:GetFrameLevel())
	cover:EnableMouse(true)
	cover:SetAllPoints(panel)

	local texture = cover:CreateTexture(nil, "BACKGROUND", nil, -7)
	texture:SetPoint("TOPLEFT", 2, -2)
	texture:SetPoint("BOTTOMRIGHT", -2, 2)
	texture:SetColorTexture(0, 0, 0, 0.4)

	return object
end

------

local function DropDown_Close()
	_G.CloseDropDownMenus()
end

local function LootDropDown_SetLootThreshold(_, key, quality)
	CFG.type[key].threshold = quality
end

local function LootDropDown_Initialize(self)
	local info = _G.UIDropDownMenu_CreateInfo()

	info.text = _G.LOOT_THRESHOLD
	info.isTitle = 1
	info.notCheckable = true
	_G.UIDropDownMenu_AddButton(info)
	table.wipe(info)

	for i = 1, (self.key == "loot_special" and 5 or 4) do
		info.text = _G.ITEM_QUALITY_COLORS[i].hex.._G["ITEM_QUALITY"..i.."_DESC"].."|r"
		info.checked = i == CFG.type[self.key].threshold
		info.arg1 = self.key
		info.arg2 = i
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

local function CreateProfile(name, base)
	if not name then
		return false, "no_name"
	elseif name and _G.LS_TOASTS_CFG_GLOBAL[name] then
		return false, "name_taken"
	end

	_G.LS_TOASTS_CFG_GLOBAL[_G.LS_TOASTS_CFG.profile] = DiffTable(DEFAULTS, CFG)

	_G.LS_TOASTS_CFG.profile = name

	if base and type(base) == "table" then
		_G.LS_TOASTS_CFG_GLOBAL[name] = CopyTable(base)
	elseif base and type(base) == "string" and _G.LS_TOASTS_CFG_GLOBAL[base] then
		_G.LS_TOASTS_CFG_GLOBAL[name] = CopyTable(_G.LS_TOASTS_CFG_GLOBAL[base])
	else
		_G.LS_TOASTS_CFG_GLOBAL[name] = CopyTable(DEFAULTS)
	end

	ReplaceTable(CopyTable(DEFAULTS, _G.LS_TOASTS_CFG_GLOBAL[name]), CFG)

	RefreshAllOptions()

	return true
end

local function DeleteProfile(name)
	if not name then
		return false, "no_name"
	elseif name and name == "Default" then
		return false, "default"
	end

	_G.LS_TOASTS_CFG_GLOBAL[name] = nil

	_G.LS_TOASTS_CFG.profile = "Default"

	ReplaceTable(CopyTable(DEFAULTS, _G.LS_TOASTS_CFG_GLOBAL.Default), CFG)

	RefreshAllOptions()

	return true
end

local function SetProfile(name)
	if not name then
		return false, "no_name"
	elseif name and not _G.LS_TOASTS_CFG_GLOBAL[name] then
		return false, "missing"
	elseif name and  name == _G.LS_TOASTS_CFG.profile then
		return false, "current"
	end

	_G.LS_TOASTS_CFG_GLOBAL[_G.LS_TOASTS_CFG.profile] = DiffTable(DEFAULTS, CFG)

	_G.LS_TOASTS_CFG.profile = name

	ReplaceTable(CopyTable(DEFAULTS, _G.LS_TOASTS_CFG_GLOBAL[_G.LS_TOASTS_CFG.profile]), CFG)

	RefreshAllOptions()

	return true
end

local function ResetProfile(name)
	if not name then
		return false, "no_name"
	elseif name and not _G.LS_TOASTS_CFG_GLOBAL[name] then
		return false, "missing"
	end

	_G.LS_TOASTS_CFG_GLOBAL[name] = CopyTable(DEFAULTS)

	ReplaceTable(CopyTable(DEFAULTS, _G.LS_TOASTS_CFG_GLOBAL[name]), CFG)

	RefreshAllOptions()

	return true
end

local function ProfileDropDownButton_OnClick(self)
	self.owner:SetValue(self.value)
end

------

local function PopulateConfigPanels()
	-- General Panel
	local panel = panels[1]

	local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
	title:SetPoint("TOPLEFT", 16, -16)
	title:SetJustifyH("LEFT")
	title:SetJustifyV("TOP")
	title:SetText(L["SETTINGS_GENERAL_LABEL"])

	local profileTag = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
	profileTag:SetPoint("LEFT", title, "RIGHT", 2, 0)
	profileTag:SetJustifyH("LEFT")
	profileTag:SetJustifyV("TOP")
	profileTag.RefreshValue = function(self)
		self:SetFormattedText("[|cffffffff%s|r]", _G.LS_TOASTS_CFG.profile)
	end

	RegisterControlForRefresh(panel, profileTag)

	local subtext = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	subtext:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
	subtext:SetPoint("RIGHT", -16, 0)
	subtext:SetHeight(44)
	subtext:SetJustifyH("LEFT")
	subtext:SetJustifyV("TOP")
	subtext:SetNonSpaceWrap(true)
	subtext:SetMaxLines(4)
	subtext:SetText(L["SETTINGS_GENERAL_DESC"])

	local acnhorButton = CreateConfigButton(panel, {
		name = "$parentAnchorToggle",
		text = L["ANCHOR_FRAME"],
		func = function() anchorFrame:Toggle() end,
	})
	acnhorButton:SetPoint("TOPLEFT", subtext, "BOTTOMLEFT", 0, -8)

	local soundToggle = CreateConfigCheckButton(panel, {
		name = "$parentSFXToggle",
		text = L["ENABLE_SOUND"],
		get = function() return CFG.sfx_enabled end,
		set = function(_, value)
			CFG.sfx_enabled = value
		end,
	})
	soundToggle:SetPoint("LEFT", acnhorButton, "RIGHT", 32, 0)

	local divider = CreateConfigDivider(panel, {
		text = L["APPEARANCE_TITLE"]
	})
	divider:SetPoint("TOP", soundToggle, "BOTTOM", 0, -10)

	local numSlider = CreateConfigSlider(panel, {
		name = "$parentNumSlider",
		text = L["TOAST_NUM"],
		min = 1,
		max = 20,
		step = 1,
		get = function() return CFG.max_active_toasts end,
		set = function(_, value)
			CFG.max_active_toasts = value
		end,
	})
	numSlider:SetPoint("TOPLEFT", divider, "BOTTOMLEFT", 16, -24)

	local delaySlider = CreateConfigSlider(panel, {
		name = "$parentFadeOutSlider",
		text = L["FADE_OUT_DELAY"],
		min = 0.8,
		max = 6,
		step = 0.4,
		get = function() return CFG.fadeout_delay end,
		set = function(_, value)
			CFG.fadeout_delay = value

			UpdateFadeOutDelay(value)
		end,
	})
	delaySlider:SetPoint("LEFT", numSlider, "RIGHT", 69, 0)

	local scaleSlider = CreateConfigSlider(panel, {
		name = "$parentScaleSlider",
		text = L["SCALE"],
		min = 0.8,
		max = 2,
		step = 0.1,
		get = function() return CFG.scale end,
		set = function(_, value)
			CFG.scale = value

			UpdateScale(value)
		end,
	})
	scaleSlider:SetPoint("LEFT", delaySlider, "RIGHT", 69, 0)

	local growthDropdown = CreateConfigDropDownMenu(panel, {
		name = "$parentDirectionDropDown",
		text = L["GROWTH_DIR"],
		init = function(self)
			local info = _G.UIDropDownMenu_CreateInfo()

			info.text = L["GROWTH_DIR_UP"]
			info.func = function(button) self:SetValue(button.value) end
			info.value = "UP"
			info.owner = self
			info.checked = nil
			_G.UIDropDownMenu_AddButton(info)

			info.text = L["GROWTH_DIR_DOWN"]
			info.value = "DOWN"
			info.checked = nil
			_G.UIDropDownMenu_AddButton(info)

			info.text = L["GROWTH_DIR_LEFT"]
			info.value = "LEFT"
			info.checked = nil
			_G.UIDropDownMenu_AddButton(info)

			info.text = L["GROWTH_DIR_RIGHT"]
			info.value = "RIGHT"
			info.checked = nil
			_G.UIDropDownMenu_AddButton(info)
		end,
		get = function() return CFG.growth_direction end,
		set = function(self, value)
			_G.UIDropDownMenu_SetSelectedValue(self, value)

			CFG.growth_direction = value
		end
	})
	growthDropdown:SetPoint("TOPLEFT", numSlider, "BOTTOMLEFT", -13, -32)

	local colorToggle = CreateConfigCheckButton(panel, {
		name = "$parentNameColorToggle",
		text = L["COLORS"],
		tooltip_text = L["COLORS_TOOLTIP"],
		get = function() return CFG.colored_names_enabled end,
		set = function(_, value)
			CFG.colored_names_enabled = value
		end,
	})
	colorToggle:SetPoint("TOPLEFT", delaySlider, "BOTTOMLEFT", -3, -32)

	divider = CreateConfigDivider(panel, {
		text = L["PROFILES_TITLE"]
	})
	divider:SetPoint("TOP", growthDropdown, "BOTTOM", 0, -10)

	local createProfileDialog = CreateConfigDialog(panel, {
		name = "$parentNewProfileDialog",
		on_show = function(self)
			self.OkayButton:Disable()
			self.EditBox:SetFocus()
		end,
		on_hide = function(self)
			self.EditBox:SetText("")
			self:Hide()
		end,
	})
	createProfileDialog:SetSize(384, 160)

	local header = createProfileDialog:CreateFontString(nil, "ARTWORK", "GameFontNormalMed2")
	header:SetHeight(18)
	header:SetPoint("TOP", 0, -14)
	header:SetPoint("LEFT", 14, 0)
	header:SetPoint("RIGHT", -14, 0)
	header:SetJustifyH("CENTER")
	header:SetJustifyV("MIDDLE")
	header:SetText(L["PROFILE_CREATE_NEW"])
	createProfileDialog.Header = header

	local editbox = _G.CreateFrame("EditBox", nil, createProfileDialog, "InputBoxTemplate")
	editbox:SetSize(256, 32)
	editbox:SetPoint("TOP", header, "BOTTOM", 0, -2)
	editbox:SetAutoFocus(false)
	editbox:SetMaxLetters(31)
	editbox:SetScript("OnTextChanged", function(self, isUserInput)
		if isUserInput then
			local name = self:GetText()
			name = string.trim(name)
			name = string.gsub(name, "[,\\%^%$%(%)%%%.%[%]%*%+%?]", "")

			if name == "" or _G.LS_TOASTS_CFG_GLOBAL[name] then
				createProfileDialog.OkayButton:Disable()
			else
				createProfileDialog.OkayButton:Enable()
			end
		end
	end)
	editbox:SetScript("OnEnterPressed", function()
		createProfileDialog.OkayButton:Click()
	end)
	createProfileDialog.EditBox = editbox

	header = createProfileDialog:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	header:SetHeight(16)
	header:SetPoint("TOP", editbox, "BOTTOM", 0, -2)
	header:SetPoint("LEFT", 14, 0)
	header:SetPoint("RIGHT", -14, 0)
	header:SetJustifyH("CENTER")
	header:SetJustifyV("MIDDLE")
	header:SetText(L["PROFILE_COPY_FROM"])
	createProfileDialog.Header = header

	local profileSelector = CreateConfigDropDownMenu(panel, {
		parent = createProfileDialog,
		name = "$parentSelectorDropDown",
		init = function(self)
			local info = _G.UIDropDownMenu_CreateInfo()

			for k in pairs(_G.LS_TOASTS_CFG_GLOBAL) do
				info.text = k
				info.func = ProfileDropDownButton_OnClick
				info.value = k
				info.owner = self
				info.checked = nil
				_G.UIDropDownMenu_AddButton(info)
			end

			_G.UIDropDownMenu_SetSelectedValue(self, "Default")
		end,
		get = function(self)
			return _G.UIDropDownMenu_GetSelectedValue(self)
		end,
		set = function(self, value)
			_G.UIDropDownMenu_SetSelectedValue(self, value)
		end
	})
	profileSelector:SetPoint("TOP", header, "BOTTOM", 0, -2)
	createProfileDialog.DropDown = profileSelector

	local okayButton = CreateConfigButton(panel, {
		parent = createProfileDialog,
		text = L["OKAY"],
		func = function()
			local name = editbox:GetText()
			name = string.trim(name)
			name = string.gsub(name, "[,\\%^%$%(%)%%%.%[%]%*%+%?]", "")

			if name ~= "" and not _G.LS_TOASTS_CFG_GLOBAL[name] then
				editbox:SetText("")
				editbox:ClearFocus()

				CreateProfile(name, profileSelector:GetValue())

				createProfileDialog:Hide()
			end
		end,
	})
	okayButton:SetWidth(116)
	okayButton:SetPoint("BOTTOMRIGHT", createProfileDialog, "BOTTOM", -6, 14)
	createProfileDialog.OkayButton = okayButton

	local cancelButton = CreateConfigButton(panel, {
		parent = createProfileDialog,
		text = L["CANCEL"],
		func = function()
			editbox:SetText("")
			editbox:ClearFocus()

			createProfileDialog:Hide()
		end
	})
	cancelButton:SetWidth(116)
	cancelButton:SetPoint("BOTTOMLEFT", createProfileDialog, "BOTTOM", 6, 14)
	createProfileDialog.CancelButton = cancelButton

	local deleteProfileDialog = CreateConfigDialog(panel, {
		name = "$parentDeleteProfileDialog",
		on_show = function(self)
			self.Header:SetFormattedText(L["PROFILE_DELETE_CONFIRM"], self.profile)
		end,
		on_hide = function(self)
			self:Hide()
		end,
	})
	deleteProfileDialog:SetSize(384, 96)

	header = deleteProfileDialog:CreateFontString(nil, "ARTWORK", "GameFontNormalMed2")
	header:SetHeight(36)
	header:SetPoint("TOP", 0, -14)
	header:SetPoint("LEFT", 14, 0)
	header:SetPoint("RIGHT", -14, 0)
	header:SetJustifyH("CENTER")
	header:SetJustifyV("MIDDLE")
	deleteProfileDialog.Header = header

	okayButton = CreateConfigButton(panel, {
		parent = deleteProfileDialog,
		text = L["OKAY"],
		func = function()
			DeleteProfile(deleteProfileDialog.profile)

			deleteProfileDialog:Hide()
		end,
	})
	okayButton:SetWidth(116)
	okayButton:SetPoint("BOTTOMRIGHT", deleteProfileDialog, "BOTTOM", -6, 14)
	deleteProfileDialog.OkayButton = okayButton

	cancelButton = CreateConfigButton(panel, {
		parent = deleteProfileDialog,
		text = L["CANCEL"],
		func = function()
			deleteProfileDialog:Hide()
		end
	})
	cancelButton:SetWidth(116)
	cancelButton:SetPoint("BOTTOMLEFT", deleteProfileDialog, "BOTTOM", 6, 14)
	deleteProfileDialog.CancelButton = cancelButton

	local resetProfileDialog = CreateConfigDialog(panel, {
		name = "$parentResetProfileDialog",
		on_show = function(self)
			self.Header:SetFormattedText(L["PROFILE_RESET_CONFIRM"], self.profile)
		end,
		on_hide = function(self)
			self:Hide()
		end,
	})
	resetProfileDialog:SetSize(384, 96)

	header = resetProfileDialog:CreateFontString(nil, "ARTWORK", "GameFontNormalMed2")
	header:SetHeight(36)
	header:SetPoint("TOP", 0, -14)
	header:SetPoint("LEFT", 14, 0)
	header:SetPoint("RIGHT", -14, 0)
	header:SetJustifyH("CENTER")
	header:SetJustifyV("MIDDLE")
	resetProfileDialog.Header = header

	okayButton = CreateConfigButton(panel, {
		parent = resetProfileDialog,
		text = L["OKAY"],
		func = function()
			ResetProfile(resetProfileDialog.profile)

			resetProfileDialog:Hide()
		end,
	})
	okayButton:SetWidth(116)
	okayButton:SetPoint("BOTTOMRIGHT", resetProfileDialog, "BOTTOM", -6, 14)
	resetProfileDialog.OkayButton = okayButton

	cancelButton = CreateConfigButton(panel, {
		parent = resetProfileDialog,
		text = L["CANCEL"],
		func = function()
			resetProfileDialog:Hide()
		end
	})
	cancelButton:SetWidth(116)
	cancelButton:SetPoint("BOTTOMLEFT", resetProfileDialog, "BOTTOM", 6, 14)
	resetProfileDialog.CancelButton = cancelButton

	local profileDropdown = CreateConfigDropDownMenu(panel, {
		name = "$parentProfileDropDown",
		text = L["PROFILE"],
		init = function(self)
			local info = _G.UIDropDownMenu_CreateInfo()

			for k in pairs(_G.LS_TOASTS_CFG_GLOBAL) do
				info.text = k
				info.func = ProfileDropDownButton_OnClick
				info.value = k
				info.owner = self
				info.checked = nil
				_G.UIDropDownMenu_AddButton(info)
			end

			info.text = "New Profile"
			info.func = function()
				createProfileDialog:Show()
			end
			info.value = nil
			info.checked = nil
			info.owner = self
			info.notCheckable = true
			_G.UIDropDownMenu_AddButton(info)
		end,
		get = function() return _G.LS_TOASTS_CFG.profile end,
		set = function(self, value)
			_G.UIDropDownMenu_SetSelectedValue(self, value)

			SetProfile(value)
		end
	})
	profileDropdown:SetPoint("TOPLEFT", divider, "BOTTOMLEFT", 3, -24)

	local deleteProfileButton = CreateConfigButton(panel, {
		text = L["DELETE"],
		func = function()
			local name = profileDropdown:GetValue()

			if name and name ~= "Default" then
				_G.CloseDropDownMenus()

				deleteProfileDialog.profile = name
				deleteProfileDialog:Show()
			end
		end
	})
	deleteProfileButton:SetPoint("TOPRIGHT", profileDropdown, "BOTTOMRIGHT", -16, 2)

	local resetProfileButton = CreateConfigButton(panel, {
		text = L["RESET"],
		func = function()
			local name = profileDropdown:GetValue()

			if name then
				_G.CloseDropDownMenus()

				resetProfileDialog.profile = name
				resetProfileDialog:Show()
			end
		end
	})
	resetProfileButton:SetPoint("RIGHT", deleteProfileButton, "LEFT", -4, 0)

	panel.refresh = RefreshOptions

	-- Toast Types Panel
	panel = _G.CreateFrame("Frame", "LSToastsTypesConfigPanel", _G.InterfaceOptionsFramePanelContainer)
	panel.name = L["SETTINGS_TYPE_LABEL"]
	panel.parent = L["LS_TOASTS"]
	panel:Hide()
	table.insert(panels, panel)

	local reloadButton = CreateConfigButton(panel, {
		name = "$parentReloadUIButton",
		text = L["RELOADUI"],
		func = function() _G.ReloadUI() end
		})
	reloadButton:SetPoint("TOPRIGHT", -16, -16)

	title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
	title:SetPoint("TOPLEFT", 16, -16)
	title:SetJustifyH("LEFT")
	title:SetJustifyV("TOP")
	title:SetText(L["SETTINGS_TYPE_LABEL"])

	profileTag = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
	profileTag:SetPoint("LEFT", title, "RIGHT", 2, 0)
	profileTag:SetJustifyH("LEFT")
	profileTag:SetJustifyV("TOP")
	profileTag.RefreshValue = function(self)
		self:SetFormattedText("[|cffffffff%s|r]", _G.LS_TOASTS_CFG.profile)
	end

	RegisterControlForRefresh(panel, profileTag)

	subtext = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	subtext:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
	subtext:SetPoint("RIGHT", -16, 0)
	subtext:SetHeight(32)
	subtext:SetJustifyH("LEFT")
	subtext:SetJustifyV("TOP")
	subtext:SetNonSpaceWrap(true)
	subtext:SetMaxLines(3)
	subtext:SetText(L["SETTINGS_TYPE_DESC"])

	local lootSpecialDropDown = _G.CreateFrame("Frame", "$parentLootSpecialDropDown", panel, "UIDropDownMenuTemplate")
	lootSpecialDropDown.displayMode = "MENU"
	lootSpecialDropDown.point = "TOPLEFT"
	lootSpecialDropDown.relativePoint = "BOTTOMRIGHT"
	lootSpecialDropDown.key = "loot_special"
	_G.UIDropDownMenu_Initialize(lootSpecialDropDown, LootDropDown_Initialize)

	local lootCommonDropDown = _G.CreateFrame("Frame", "$parentLootCommonDropDown", panel, "UIDropDownMenuTemplate")
	lootCommonDropDown.displayMode = "MENU"
	lootCommonDropDown.point = "TOPLEFT"
	lootCommonDropDown.relativePoint = "BOTTOMRIGHT"
	lootCommonDropDown.key = "loot_common"
	_G.UIDropDownMenu_Initialize(lootCommonDropDown, LootDropDown_Initialize)

	local layout = {
		[1] = {
			name = "$parentAchievement",
			text = L["TYPE_ACHIEVEMENT"],
			toast_get = function() return CFG.type.achievement.enabled end,
			toast_set = function(_, value)
				CFG.type.achievement.enabled = value

				ToggleToasts("achievement", value)
			end,
			dnd_get = function() return CFG.type.achievement.dnd end,
			dnd_set = function(_, value) CFG.type.achievement.dnd = value end,
			test_func = dispatcher.TestAchievementToast,
		},
		[2] = {
			name = "$parentArchaeology",
			text = L["TYPE_ARCHAEOLOGY"],
			toast_get = function() return CFG.type.archaeology.enabled end,
			toast_set = function(_, value)
				CFG.type.archaeology.enabled = value

				ToggleToasts("archaeology", value)
			end,
			dnd_get = function() return CFG.type.archaeology.dnd end,
			dnd_set = function(_, value) CFG.type.archaeology.dnd = value end,
			test_func = dispatcher.TestArchaeologyToast,
		},
		[3] = {
			name = "$parentGarrison",
			text = L["TYPE_GARRISON"],
			toast_get = function() return CFG.type.garrison_6_0.enabled end,
			toast_set = function(_, value)
				CFG.type.garrison_6_0.enabled = value

				ToggleToasts("garrison_6_0", value)
			end,
			dnd_get = function() return CFG.type.garrison_6_0.dnd end,
			dnd_set = function(_, value) CFG.type.garrison_6_0.dnd = value end,
			test_func = dispatcher.TestGarrisonToast,
		},
		[4] = {
			name = "$parentClassHall",
			text = L["TYPE_CLASS_HALL"],
			toast_get = function() return CFG.type.garrison_7_0.enabled end,
			toast_set = function(_, value)
				CFG.type.garrison_7_0.enabled = value

				ToggleToasts("garrison_7_0", value)
			end,
			dnd_get = function() return CFG.type.garrison_7_0.dnd end,
			dnd_set = function(_, value) CFG.type.garrison_7_0.dnd = value end,
			test_func = dispatcher.TestClassHallToast,
		},
		[5] = {
			name = "$parentDungeon",
			text = L["TYPE_DUNGEON"],
			toast_get = function() return CFG.type.instance.enabled end,
			toast_set = function(_, value)
				CFG.type.instance.enabled = value

				ToggleToasts("instance", value)
			end,
			dnd_get = function() return CFG.type.instance.dnd end,
			dnd_set = function(_, value) CFG.type.instance.dnd = value end,
			test_func = dispatcher.TestInstanceToast,
		},
		[6] = {
			name = "$parentLootSpecial",
			text = L["TYPE_LOOT_SPECIAL"],
			toast_tooltip = L["TYPE_LOOT_SPECIAL_TOOLTIP"],
			toast_get = function() return CFG.type.loot_special.enabled end,
			toast_set = function(_, value)
				CFG.type.loot_special.enabled = value

				ToggleToasts("loot_special", value)
			end,
			dnd_get = function() return CFG.type.loot_special.dnd end,
			dnd_set = function(_, value) CFG.type.loot_special.dnd = value end,
			dropdown = lootSpecialDropDown,
			test_func = dispatcher.TestSpecialLootToast,
		},
		[7] = {
			name = "$parentLootCommon",
			text = L["TYPE_LOOT_COMMON"],
			toast_tooltip = L["TYPE_LOOT_COMMON_TOOLTIP"],
			toast_get = function() return CFG.type.loot_common.enabled end,
			toast_set = function(_, value)
				CFG.type.loot_common.enabled = value

				ToggleToasts("loot_common", value)
			end,
			dnd_get = function() return CFG.type.loot_common.dnd end,
			dnd_set = function(_, value) CFG.type.loot_common.dnd = value end,
			dropdown = lootCommonDropDown,
			-- warning_refresh = function(self)
			-- 	local tainted = 0
			-- 	local text = ""..L["TAINT_HEADER"]

			-- 	for k, v in pairs(secure_vars.common_loot) do
			-- 		if not v.is_secure then
			-- 			tainted = tainted + 1

			-- 			text = text..L["TAINT_LINE"]:format(k, v.tainted_by)
			-- 		end
			-- 	end

			-- 	if tainted > 0 then
			-- 		self.Button.toolTipText = text
			-- 		self:Show()
			-- 	else
			-- 		self:Hide()
			-- 	end
			-- end,
			test_func = dispatcher.TestCommonLootToast,
		},
		[8] = {
			name = "$parentLootCurrency",
			text = L["TYPE_LOOT_CURRENCY"],
			toast_get = function() return CFG.type.loot_currency.enabled end,
			toast_set = function(_, value)
				CFG.type.loot_currency.enabled = value

				ToggleToasts("loot_currency", value)
			end,
			dnd_get = function() return CFG.type.loot_currency.dnd end,
			dnd_set = function(_, value) CFG.type.loot_currency.dnd = value end,
			test_func = dispatcher.TestCurrencyToast,
			-- warning_refresh = function(self)
			-- 	local tainted = 0
			-- 	local text = ""..L["TAINT_HEADER"]

			-- 	for k, v in pairs(secure_vars.currency) do
			-- 		if not v.is_secure then
			-- 			tainted = tainted + 1

			-- 			text = text..L["TAINT_LINE"]:format(k, v.tainted_by)
			-- 		end
			-- 	end

			-- 	if tainted > 0 then
			-- 		self.Button.toolTipText = text
			-- 		self:Show()
			-- 	else
			-- 		self:Hide()
			-- 	end
			-- end
		},
		[9] = {
			name = "$parentRecipe",
			text = L["TYPE_RECIPE"],
			toast_get = function() return CFG.type.recipe.enabled end,
			toast_set = function(_, value)
				CFG.type.recipe.enabled = value

				ToggleToasts("recipe", value)
			end,
			dnd_get = function() return CFG.type.recipe.dnd end,
			dnd_set = function(_, value) CFG.type.recipe.dnd = value end,
			test_func = dispatcher.TestRecipeToast,
		},
		[10] = {
			name = "$parentWorldQuest",
			text = L["TYPE_WORLD_QUEST"],
			toast_get = function() return CFG.type.world.enabled end,
			toast_set = function(_, value)
				CFG.type.world.enabled = value

				ToggleToasts("world", value)
			end,
			dnd_get = function() return CFG.type.world.dnd end,
			dnd_set = function(_, value) CFG.type.world.dnd = value end,
			test_func = dispatcher.TestWorldToast,
		},
		[11] = {
			name = "$parentTransmog",
			text = L["TYPE_TRANSMOG"],
			toast_get = function() return CFG.type.transmog.enabled end,
			toast_set = function(_, value)
				CFG.type.transmog.enabled = value

				ToggleToasts("transmog", value)
			end,
			dnd_get = function() return CFG.type.transmog.dnd end,
			dnd_set = function(_, value) CFG.type.transmog.dnd = value end,
			test_func = dispatcher.TestTransmogToast,
		},
	}

	local lines = {}

	for i = 1, #layout do
		lines[i] = CreateToastConfigLine(panel, layout[i])
	end

	for i = 1, #lines do
		if i == 1 then
			lines[i]:SetPoint("TOP", subtext, "BOTTOM", 0, -18)
		else
			lines[i]:SetPoint("TOP", lines[i - 1], "BOTTOM", 0, -2)
		end

		if i % 2 == 0 then
			lines[i].BG:SetColorTexture(0.3, 0.3, 0.3, 0.3)
		else
			lines[i].BG:SetColorTexture(0.6, 0.6, 0.6, 0.3)
		end
	end

	title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	title:SetPoint("BOTTOMLEFT", lines[1], "TOPLEFT", 6, 4)
	title:SetText(L["TYPE"])

	title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	title:SetWidth(64)
	title:SetJustifyH("CENTER")
	title:SetPoint("BOTTOM", lines[1], "TOPLEFT", 333, 4)
	title:SetText(L["ENABLE"])

	title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	title:SetWidth(64)
	title:SetJustifyH("CENTER")
	title:SetPoint("BOTTOM", lines[1], "TOPLEFT", 455, 4)
	title:SetText(L["DND"])

	panel.refresh = RefreshOptions

	_G.InterfaceOptions_AddCategory(panel, true)
	_G.InterfaceAddOnsList_Update()
	_G.InterfaceOptionsOptionsFrame_RefreshAddOns()
end

------------
-- PUBLIC --
------------

-- F:SkinToast

-- Parameters:
-- 	toast
-- 	toastType	- types: "item", "mission", "follower", "achievement", "ability", "scenario", "misc"

-- Example:
-- 	local toast_F = ls_Toasts[1]
-- 	function toast_F:SkinToast(toast, toastType) --[[body]] end

-- This function can be and should be overridden by your addon
-- For toasts' structures, see definitions of CreateBaseToastButton and GetToast functions

function F:SkinToast() end

-- F:CreateProfile

-- Arguments:
-- 	name	- "string" - new profile's name
-- 	base	- "string" - if LS_TOASTS_CFG_GLOBAL[base] profile exists, it'll be used as a base for a new profile
--			- "table" - provided table will be used a base for a new profile
--			- "nil" - DEFAULTS table will be used as a base for a new profile

-- Returns:
-- created	- "boolean": true, false - if profile was successfully created
-- reason 	- "string": "no_name", "name_taken" - reason why profile wasn't created, nil otherwise

-- Example:
-- 	local toast_F = ls_Toasts[1]
-- 	local created, reason = toast_F:CreateProfile("test_profile")

function F:CreateProfile(name, base)
	return CreateProfile(name, base)
end

-- F:DeleteProfile

-- Arguments:
-- 	name	- "string" - profile's name you want to delete, can't be "Default"

-- Returns:
-- deleted	- "boolean": true, false - if profile was successfully deleted
-- reason 	- "string": "no_name", "default" - reason why profile wasn't deleted, nil otherwise

-- Example:
-- 	local toast_F = ls_Toasts[1]
-- 	local deleted, reason = toast_F:DeleteProfile("test_profile")

function F:DeleteProfile(name)
	return DeleteProfile(name)
end

-- F:SetProfile

-- Arguments:
-- 	name	- "string" - profile's name you want to activate

-- Returns:
-- set		- "boolean": true, false - if profile was successfully activated
-- reason 	- "string": "no_name", "missing", "current" - reason why profile wasn't activated, nil otherwise

-- Example:
-- 	local toast_F = ls_Toasts[1]
-- 	local set, reason = toast_F:SetProfile("test_profile")

function F:SetProfile(name)
	return SetProfile(name)
end

-- F:ResetProfile

-- Arguments:
-- 	name	- "string" - profile's name you want to reset

-- Returns:
-- reset	- "boolean": true, false - if profile was successfully reset
-- reason 	- "string": "no_name", "missing" - reason why profile wasn't reset, nil otherwise

-- Example:
-- 	local toast_F = ls_Toasts[1]
-- 	local reset, reason = toast_F:ResetProfile("test_profile")

function F:ResetProfile(name)
	return ResetProfile(name)
end

-------------
-- LOADING --
-------------

function dispatcher:ADDON_LOADED(arg)
	if arg ~= addonName then return end

	if not _G.LS_TOASTS_CFG then
		_G.LS_TOASTS_CFG = {
			profile = "Default"
		}
	else
		if not _G.LS_TOASTS_CFG.profile then
			_G.LS_TOASTS_CFG.profile = "Default"
		end
	end

	if not _G.LS_TOASTS_CFG_GLOBAL then
		_G.LS_TOASTS_CFG_GLOBAL = {
			["Default"] = CopyTable(DEFAULTS)
		}
	else
		if not _G.LS_TOASTS_CFG_GLOBAL.Default then
			_G.LS_TOASTS_CFG_GLOBAL.Default = CopyTable(DEFAULTS)
		end
	end

	if not _G.LS_TOASTS_CFG_GLOBAL[_G.LS_TOASTS_CFG.profile] then
		_G.LS_TOASTS_CFG.profile = "Default"
	end

	for k, v in pairs(_G.LS_TOASTS_CFG_GLOBAL) do
		if not v.version then
			_G.LS_TOASTS_CFG_GLOBAL[k] = CopyTable(DEFAULTS)
		end
	end

	ReplaceTable(CopyTable(DEFAULTS, _G.LS_TOASTS_CFG_GLOBAL[_G.LS_TOASTS_CFG.profile]), CFG)

	self:RegisterEvent("PLAYER_LOGIN")
	self:RegisterEvent("PLAYER_LOGOUT")
	self:UnregisterEvent("ADDON_LOADED")
end

function dispatcher:PLAYER_LOGIN()
	anchorFrame:Refresh()

	self:EnableAchievementToasts()
	self:EnableArchaeologyToasts()
	self:EnableGarrisonToasts()
	self:EnableInstanceToasts()
	self:EnableSpecialLootToasts()
	self:EnableCommonLootToasts()
	self:EnableCurrencyLootToasts()
	self:EnableRecipeToasts()
	self:EnableWorldToasts()
	self:EnableTransmogToasts()

	for event in pairs(BLACKLISTED_EVENTS) do
		_G.AlertFrame:UnregisterEvent(event)
	end

	hooksecurefunc(_G.AlertFrame, "RegisterEvent", function(self, event)
		if event and BLACKLISTED_EVENTS[event] then
			self:UnregisterEvent(event)
		end
	end)

	local panel = _G.CreateFrame("Frame", "LSToastsConfigPanel", _G.InterfaceOptionsFramePanelContainer)
	panel.name = L["LS_TOASTS"]
	panel:Hide()
	table.insert(panels, panel)

	local button = CreateConfigButton(panel, {
		name = "$parentEnabler",
		text = L["ENABLE"],
		func = function(self)
			self:ClearAllPoints()
			self:Hide()

			PopulateConfigPanels()
		end,
	})
	button:SetPoint("TOPLEFT", 16, -16)

	local reloadButton = CreateConfigButton(panel, {
		name = "$parentReloadUIButton",
		text = L["RELOADUI"],
		func = function() _G.ReloadUI() end
	})
	reloadButton:SetPoint("TOPRIGHT", -16, -16)

	_G.InterfaceOptions_AddCategory(panel, true)
	_G.InterfaceAddOnsList_Update()
	_G.InterfaceOptionsOptionsFrame_RefreshAddOns()

	_G.SLASH_LSTOASTS1 = "/lstoasts"
	_G.SlashCmdList["LSTOASTS"] = function(msg)
		if msg == "" then
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
	local VER = _G.GetAddOnMetadata(addonName, "Version")

	_G.LS_TOASTS_CFG_GLOBAL[_G.LS_TOASTS_CFG.profile] = DiffTable(DEFAULTS, CFG)
	_G.LS_TOASTS_CFG_GLOBAL[_G.LS_TOASTS_CFG.profile].version = VER

	for k, v in pairs(_G.LS_TOASTS_CFG_GLOBAL) do
		if k ~= _G.LS_TOASTS_CFG.profile then
			_G.LS_TOASTS_CFG_GLOBAL[k] = DiffTable(DEFAULTS, v)
			_G.LS_TOASTS_CFG_GLOBAL[k].version = VER
		end
	end
end

dispatcher:RegisterEvent("ADDON_LOADED")
