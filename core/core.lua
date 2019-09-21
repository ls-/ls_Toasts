local addonName, addonTable = ...
local C, L = addonTable.C, addonTable.L

-- Lua
local _G = getfenv(0)
local error = _G.error
local geterrorhandler = _G.geterrorhandler
local next = _G.next
local s_format = _G.string.format
local s_match = _G.string.match
local s_split = _G.string.split
local t_concat = _G.table.concat
local t_remove = _G.table.remove
local tonumber = _G.tonumber
local type = _G.type
local xpcall = _G.xpcall

-- Blizz
local C_MountJournal = _G.C_MountJournal
local C_PetJournal = _G.C_PetJournal

--[[ luacheck: globals
	CreateFrame DressUpBattlePet DressUpMount DressUpVisual GetContainerItemID GetContainerNumSlots
	GetDetailedItemLevelInfo GetItemInfo IsDressableItem LibStub UIParent

	INVSLOT_BACK INVSLOT_CHEST INVSLOT_FEET INVSLOT_FINGER1 INVSLOT_FINGER2 INVSLOT_HAND
	INVSLOT_HEAD INVSLOT_LEGS INVSLOT_MAINHAND INVSLOT_NECK INVSLOT_OFFHAND INVSLOT_RANGED
	INVSLOT_SHOULDER INVSLOT_TRINKET1 INVSLOT_TRINKET2 INVSLOT_WAIST INVSLOT_WRIST NUM_BAG_SLOTS
]]

-- Mine
local E, P = {}, {}
addonTable.E, addonTable.P = E, P

_G[addonName] = {
	[1] = E,
	[2] = C,
	[3] = L,
}

do
	local oneTimeEvents = {ADDON_LOADED = false, PLAYER_LOGIN = false}
	local registeredEvents = {}

	local dispatcher = CreateFrame("Frame")
	dispatcher:SetScript("OnEvent", function(_, event, ...)
		for func in next, registeredEvents[event] do
			func(...)
		end

		if oneTimeEvents[event] == false then
			oneTimeEvents[event] = true
		end
	end)

	function E:RegisterEvent(event, func, unit1, unit2)
		if oneTimeEvents[event] then
			error(s_format("Failed to register for '%s' event, already fired!", event), 3)
		end

		if not func or type(func) ~= "function" then
			error(s_format("Failed to register for '%s' event, no handler!", event), 3)
		end

		if not registeredEvents[event] then
			registeredEvents[event] = {}

			if unit1 then
				P:Call(dispatcher.RegisterEvent, dispatcher, event, unit1, unit2)
			else
				P:Call(dispatcher.RegisterEvent, dispatcher, event)
			end
		end

		registeredEvents[event][func] = true
	end

	function E:UnregisterEvent(event, func)
		local funcs = registeredEvents[event]

		if funcs and funcs[func] then
			funcs[func] = nil

			if not next(funcs) then
				registeredEvents[event] = nil

				P:Call(dispatcher.UnregisterEvent, dispatcher, event)
			end
		end
	end
end

function P:UpdateTable(src, dest)
	if type(dest) ~= "table" then
		dest = {}
	end

	for k, v in next, src do
		if type(v) == "table" then
			dest[k] = self:UpdateTable(v, dest[k])
		else
			if dest[k] == nil then
				dest[k] = v
			end
		end
	end

	return dest
end

do
	local function errorHandler(err)
		return geterrorhandler()(err)
	end

	function P:Call(func, ...)
		return xpcall(func, errorHandler, ...)
	end
end

-- Libs
P.CallbackHandler = LibStub("CallbackHandler-1.0"):New(E)

-------------
-- HELPERS --
-------------

function E:SanitizeLink(link)
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

function E:GetScreenQuadrant(frame)
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

	function E:GetItemLevel(itemLink)
		local _, _, _, _, _, _, _, _, itemEquipLoc, _, _, itemClassID, itemSubClassID = GetItemInfo(itemLink)

		-- 3:11 is artefact relic
		if (itemClassID == 3 and itemSubClassID == 11) or slots[itemEquipLoc] then
			return GetDetailedItemLevelInfo(itemLink) or 0
		end

		return 0
	end
end

function E:SearchBagsForItemID(itemID)
	for i = 0, NUM_BAG_SLOTS do
		for j = 1, GetContainerNumSlots(i) do
			if GetContainerItemID(i, j) == itemID then
				return i, j
			end
		end
	end

	return -1, -1
end

function E:DressUpLink(link)
	if not link then
		return
	end

	-- item
	if IsDressableItem(link) then
		if DressUpVisual(link) then
			return
		end
	end

	-- battle pet
	local creatureID, displayID, speciesID

	local linkType, linkID, _ = s_split(":", link)
	if linkType == "item" then
		_, _, _, creatureID, _, _, _, _, _, _, _, displayID, speciesID = C_PetJournal.GetPetInfoByItemID(tonumber(linkID))
	elseif linkType == "battlepet" then
		speciesID = tonumber(linkID)
		_, _, _, creatureID, _, _, _, _, _, _, _, displayID = C_PetJournal.GetPetInfoBySpeciesID(speciesID)
	end

	if creatureID and displayID and speciesID then
		if DressUpBattlePet(creatureID, displayID, speciesID) then
			return
		end
	end

	-- mount
	local mountID

	linkType, linkID = s_split(":", link)
	if linkType == "item" then
		mountID = C_MountJournal.GetMountFromItem(tonumber(linkID))
	elseif linkType == "spell" then
		mountID = C_MountJournal.GetMountFromSpell(tonumber(linkID))
	end

	if mountID then
		DressUpMount(mountID)
	end
end
