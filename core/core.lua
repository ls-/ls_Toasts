local addonName, addonTable = ...
local C, L = addonTable.C, addonTable.L

-- Lua
local _G = getfenv(0)
local error = _G.error
local next = _G.next
local s_format = _G.string.format
local s_match = _G.string.match
local s_split = _G.string.split
local t_concat = _G.table.concat
local t_remove = _G.table.remove
local tonumber = _G.tonumber
local type = _G.type

-- Mine
local E = {}
addonTable.E = E

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
