local _, addonTable = ...
local E, L, C = addonTable.E, addonTable.L, addonTable.C

-- Lua
local _G = getfenv(0)
local next = _G.next
local t_insert = _G.table.insert
local t_sort = _G.table.sort
local t_wipe = _G.table.wipe
local tonumber = _G.tonumber
local tostring = _G.tostring

-- Mine
local PLAYER_GUID = UnitGUID("player")
local PLAYER_NAME = UnitName("player")

local CACHED_LOOT_ITEM_CREATED
local CACHED_LOOT_ITEM_CREATED_MULTIPLE
local CACHED_LOOT_ITEM
local CACHED_LOOT_ITEM_MULTIPLE
local CACHED_LOOT_ITEM_PUSHED
local CACHED_LOOT_ITEM_PUSHED_MULTIPLE

local LOOT_ITEM_CREATED_PATTERN
local LOOT_ITEM_CREATED_MULTIPLE_PATTERN
local LOOT_ITEM_PATTERN
local LOOT_ITEM_MULTIPLE_PATTERN
local LOOT_ITEM_PUSHED_PATTERN
local LOOT_ITEM_PUSHED_MULTIPLE_PATTERN

local function updatePatterns()
	if CACHED_LOOT_ITEM_CREATED ~= LOOT_ITEM_CREATED_SELF then
		LOOT_ITEM_CREATED_PATTERN = LOOT_ITEM_CREATED_SELF:gsub("%%s", "(.+)"):gsub("^", "^")
		CACHED_LOOT_ITEM_CREATED = LOOT_ITEM_CREATED_SELF
	end

	if CACHED_LOOT_ITEM_CREATED_MULTIPLE ~= LOOT_ITEM_CREATED_SELF_MULTIPLE then
		LOOT_ITEM_CREATED_MULTIPLE_PATTERN = LOOT_ITEM_CREATED_SELF_MULTIPLE:gsub("%%s", "(.+)"):gsub("%%d", "(%%d+)"):gsub("^", "^")
		CACHED_LOOT_ITEM_CREATED_MULTIPLE = LOOT_ITEM_CREATED_SELF_MULTIPLE
	end

	if CACHED_LOOT_ITEM ~= LOOT_ITEM_SELF then
		LOOT_ITEM_PATTERN = LOOT_ITEM_SELF:gsub("%%s", "(.+)"):gsub("^", "^")
		CACHED_LOOT_ITEM = LOOT_ITEM_SELF
	end

	if CACHED_LOOT_ITEM_MULTIPLE ~= LOOT_ITEM_SELF_MULTIPLE then
		LOOT_ITEM_MULTIPLE_PATTERN = LOOT_ITEM_SELF_MULTIPLE:gsub("%%s", "(.+)"):gsub("%%d", "(%%d+)"):gsub("^", "^")
		CACHED_LOOT_ITEM_MULTIPLE = LOOT_ITEM_SELF_MULTIPLE
	end

	if CACHED_LOOT_ITEM_PUSHED ~= LOOT_ITEM_PUSHED_SELF then
		LOOT_ITEM_PUSHED_PATTERN = LOOT_ITEM_PUSHED_SELF:gsub("%%s", "(.+)"):gsub("^", "^")
		CACHED_LOOT_ITEM_PUSHED = LOOT_ITEM_PUSHED_SELF
	end

	if CACHED_LOOT_ITEM_PUSHED_MULTIPLE ~= LOOT_ITEM_PUSHED_SELF_MULTIPLE then
		LOOT_ITEM_PUSHED_MULTIPLE_PATTERN = LOOT_ITEM_PUSHED_SELF_MULTIPLE:gsub("%%s", "(.+)"):gsub("%%d", "(%%d+)"):gsub("^", "^")
		CACHED_LOOT_ITEM_PUSHED_MULTIPLE = LOOT_ITEM_PUSHED_SELF_MULTIPLE
	end

end

local function delayedUpdatePatterns()
	C_Timer.After(0.1, updatePatterns)
end

local function Toast_OnClick(self)
	if self._data.link and IsModifiedClick("DRESSUP") then
		DressUpItemLink(self._data.link)
	elseif self._data.item_id then
		local slot = E:SearchBagsForItemID(self._data.item_id)
		if slot >= 0 then
			OpenBag(slot)
		end
	end
end

local function Toast_OnEnter(self)
	if self._data.tooltip_link then
		GameTooltip:SetHyperlink(self._data.tooltip_link)
		GameTooltip:Show()
	end
end

local function PostSetAnimatedValue(self, value)
	self:SetText(value == 1 and "" or value)
end

local function Toast_SetUp(event, link, quantity)
	local sanitizedLink, originalLink, _, itemID = E:SanitizeLink(link)
	local toast, isNew, isQueued = E:GetToast(event, "link", sanitizedLink)
	if isNew then
		local name, _, quality, _, _, _, _, _, _, icon, _, classID, subClassID, bindType = GetItemInfo(originalLink)
		local isPet = classID == 15 and subClassID == 2
		local isQuestItem = bindType == 4 or (classID == 12 and subClassID == 0)

		if name and ((quality and quality >= C.db.profile.types.loot_items.threshold and quality <= 5)
			or (isPet and C.db.profile.types.loot_items.pet)
			or (isQuestItem and C.db.profile.types.loot_items.quest)
			or C.db.profile.types.loot_items.filters[itemID]) then
			local color = ITEM_QUALITY_COLORS[quality] or ITEM_QUALITY_COLORS[1]
			local title = L["YOU_RECEIVED"]
			local soundFile = "Interface\\AddOns\\ls_Toasts\\assets\\ui-common-loot-toast.OGG"

			toast.IconText1.PostSetAnimatedValue = PostSetAnimatedValue

			if C.db.profile.colors.name then
				name = color.hex .. name .. "|r"
			end

			if C.db.profile.colors.border then
				toast.Border:SetVertexColor(color.r, color.g, color.b)
			end

			if C.db.profile.colors.icon_border then
				toast.IconBorder:SetVertexColor(color.r, color.g, color.b)
			end

			if C.db.profile.types.loot_items.ilvl then
				local iLevel = E:GetItemLevel(originalLink)

				if iLevel > 0 then
					name = "[" .. color.hex .. iLevel .. "|r] " .. name
				end
			end

			if quality == 5 then
				title = L["ITEM_LEGENDARY"]
				soundFile = "Interface\\AddOns\\ls_Toasts\\assets\\ui-legendary-loot-toast.OGG"

				toast:SetBackground("legendary")

				if not toast.Dragon.isHidden then
					toast.Dragon:Show()
				end
			end

			if not toast.IconHL.isHidden then
				toast.IconHL:SetShown(isQuestItem)
			end

			toast.Title:SetText(title)
			toast.Text:SetText(name)
			toast.Icon:SetTexture(icon)
			toast.IconBorder:Show()
			toast.IconText1:SetAnimatedValue(quantity, true)

			toast._data.count = quantity
			toast._data.event = event
			toast._data.item_id = itemID
			toast._data.link = sanitizedLink
			toast._data.sound_file = C.db.profile.types.loot_items.sfx and soundFile
			toast._data.tooltip_link = originalLink

			toast:HookScript("OnClick", Toast_OnClick)
			toast:HookScript("OnEnter", Toast_OnEnter)
			toast:Spawn(C.db.profile.types.loot_items.anchor, C.db.profile.types.loot_items.dnd)
		else
			toast:Release()
		end
	else
		if isQueued then
			toast._data.count = toast._data.count + quantity
			toast.IconText1:SetAnimatedValue(toast._data.count, true)
		else
			toast._data.count = toast._data.count + quantity
			toast.IconText1:SetAnimatedValue(toast._data.count)

			toast.IconText2:SetText("+" .. quantity)
			toast.IconText2.Blink:Stop()
			toast.IconText2.Blink:Play()

			toast.AnimOut:Stop()
			toast.AnimOut:Play()
		end
	end
end

local function CHAT_MSG_LOOT(message, _, _, _, name, _, _, _, _, _, _, guid)
	if guid and guid ~= PLAYER_GUID or name ~= PLAYER_NAME then
		return
	end

	local link, quantity = message:match(LOOT_ITEM_MULTIPLE_PATTERN)
	if not link then
		link, quantity = message:match(LOOT_ITEM_PUSHED_MULTIPLE_PATTERN)
		if not link then
			link, quantity = message:match(LOOT_ITEM_CREATED_MULTIPLE_PATTERN)
			if not link then
				quantity, link = 1, message:match(LOOT_ITEM_PATTERN)
				if not link then
					quantity, link = 1, message:match(LOOT_ITEM_PUSHED_PATTERN)
					if not link then
						quantity, link = 1, message:match(LOOT_ITEM_CREATED_PATTERN)
					end
				end
			end
		end
	end

	if not link then
		return
	end

	Toast_SetUp("CHAT_MSG_LOOT", link, tonumber(quantity) or 0)
end

local newID
local pendingItemIDs = {}
local handleItemInfo, updateFilterOptions

local function removeFilter(info)
	C.db.profile.types.loot_items.filters[tonumber(info[#info - 1])] = nil

	updateFilterOptions()
end

function handleItemInfo(id, isOk)
	if isOk then
		pendingItemIDs[id] = nil
	end

	if not next(pendingItemIDs) then
		updateFilterOptions()
	end
end

function updateFilterOptions()
	if not C.db.profile.types.loot_items.enabled then
		return
	end

	local options = t_wipe(C.options.args.types.args.loot_items.plugins.filters)
	local nameToIndex = {}
	local name, quaility, icon, color, _

	for id in next, C.db.profile.types.loot_items.filters do
		if not GetItemInfoInstant(id) then
			-- remove invalid IDs, some people do stuff...
			C.db.profile.types.loot_items.filters[id] = nil
		else
			name = GetItemInfo(id)
			if name then
				t_insert(nameToIndex, name)
			else
				pendingItemIDs[id] = true
			end
		end
	end

	t_sort(nameToIndex)

	for i = 1, #nameToIndex do
		nameToIndex[nameToIndex[i]] = i
	end

	for id in next, C.db.profile.types.loot_items.filters do
		if not pendingItemIDs[id] then
			name, _, quaility, _, _, _, _, _, _, icon = GetItemInfo(id)
			color = ITEM_QUALITY_COLORS[quaility] or ITEM_QUALITY_COLORS[1]

			options[tostring(id)] = {
				order = nameToIndex[name] + 20,
				type = "group",
				name = ("|T%s:0:0:0:0:64:64:4:60:4:60|t %s%s|r"):format(icon, color.hex, name),
				args = {
					delete = {
						type = "execute",
						order = 1,
						name = L["DELETE"],
						func = removeFilter,
					},
				},
			}
		end
	end

	if next(pendingItemIDs) then
		E:RegisterEvent("GET_ITEM_INFO_RECEIVED", handleItemInfo)
	else
		E:UnregisterEvent("GET_ITEM_INFO_RECEIVED", handleItemInfo)
	end
end

local function Enable()
	updatePatterns()

	if C.db.profile.types.loot_items.enabled then
		E:RegisterEvent("CHAT_MSG_LOOT", CHAT_MSG_LOOT)
		E:RegisterEvent("PLAYER_ENTERING_WORLD", delayedUpdatePatterns)

		updateFilterOptions()
	end
end

local function Disable()
	E:UnregisterEvent("CHAT_MSG_LOOT", CHAT_MSG_LOOT)
	E:UnregisterEvent("PLAYER_ENTERING_WORLD", delayedUpdatePatterns)
end

local function Test()
	-- common, Hearthstone
	local _, link = GetItemInfo(6948)
	if link then
		Toast_SetUp("COMMON_LOOT_TEST", link, 1)
	end

	-- common, pet, Tiny Crimson Whelpling
	_, link = GetItemInfo(8499)
	if link then
		Toast_SetUp("COMMON_LOOT_TEST", link, 1)
	end

	-- uncommon, Chromatic Sword
	_, link = GetItemInfo(1604)
	if link then
		Toast_SetUp("COMMON_LOOT_TEST", link, 1)
	end

	-- rare, Arcanite Reaper
	_, link = GetItemInfo(12784)
	if link then
		Toast_SetUp("COMMON_LOOT_TEST", link, 1)
	end

	-- epic, Corrupted Ashbringer
	_, link = GetItemInfo(22691)
	if link then
		Toast_SetUp("COMMON_LOOT_TEST", link, 1)
	end

	-- legendary, Atiesh, Greatstaff of the Guardian
	_, link = GetItemInfo(22589)
	if link then
		Toast_SetUp("COMMON_LOOT_TEST", link, 1)
	end
end

E:RegisterOptions("loot_items", {
	enabled = true,
	anchor = 1,
	dnd = false,
	sfx = true,
	ilvl = true,
	pet = false,
	quest = false,
	threshold = 1,
	filters = {},
}, {
	name = L["TYPE_LOOT_ITEMS"],
	get = function(info)
		return C.db.profile.types.loot_items[info[#info]]
	end,
	set = function(info, value)
		C.db.profile.types.loot_items[info[#info]] = value
	end,
	args = {
		enabled = {
			order = 1,
			type = "toggle",
			name = L["ENABLE"],
			set = function(_, value)
				C.db.profile.types.loot_items.enabled = value

				if value then
					Enable()
				else
					Disable()
				end
			end
		},
		dnd = {
			order = 2,
			type = "toggle",
			name = L["DND"],
			desc = L["DND_TOOLTIP"],
		},
		sfx = {
			order = 3,
			type = "toggle",
			name = L["SFX"],
		},
		ilvl = {
			order = 4,
			type = "toggle",
			name = L["SHOW_ILVL"],
			desc = L["SHOW_ILVL_DESC"],
		},
		threshold = {
			order = 5,
			type = "select",
			name = L["LOOT_THRESHOLD"],
			values = {
				[0] = ITEM_QUALITY_COLORS[0].hex .. ITEM_QUALITY0_DESC .. "|r",
				[1] = ITEM_QUALITY_COLORS[1].hex .. ITEM_QUALITY1_DESC .. "|r",
				[2] = ITEM_QUALITY_COLORS[2].hex .. ITEM_QUALITY2_DESC .. "|r",
				[3] = ITEM_QUALITY_COLORS[3].hex .. ITEM_QUALITY3_DESC .. "|r",
				[4] = ITEM_QUALITY_COLORS[4].hex .. ITEM_QUALITY4_DESC .. "|r",
			},
		},
		test = {
			type = "execute",
			order = 9,
			width = "full",
			name = L["TEST"],
			func = Test,
		},
		spacer_1 = {
			order = 10,
			type = "description",
			name = " ",
		},
		filters = {
			order = 11,
			type = "group",
			name = L["FILTERS"],
			inline = true,
			args = {
				desc = {
					order = 1,
					type = "description",
					name = L["ITEM_FILTERS_DESC"],
				},
				spacer_1 = {
					order = 2,
					type = "description",
					name = " ",
				},
				quest = {
					order = 3,
					type = "toggle",
					name = L["QUEST_ITEMS"],
				},
				pet = {
					order = 4,
					type = "toggle",
					name = L["PETS"],
				},
			},
		},
		new = {
			order = 12,
			type = "group",
			name = L["NEW"],
			args = {
				desc = {
					order = 1,
					type = "description",
					name = L["NEW_ITEM_FILTER_DESC"],
				},
				id = {
					order = 2,
					type = "input",
					name = L["ID"],
					dialogControl = "LSPreviewBoxItem",
					validate = function(_, value)
						value = tonumber(value)
						if value then
							return not not GetItemInfoInstant(value)
						else
							return true
						end
					end,
					set = function(_, value)
						value = tonumber(value)
						if value and GetItemInfoInstant(value) then
							newID = value
						else
							newID = nil -- jic
						end
					end,
					get = function()
						return tostring(newID or "")
					end,
				},
				add = {
					type = "execute",
					order = 3,
					name = L["ADD"],
					disabled = function()
						return not newID or C.db.profile.types.loot_items.filters[newID]
					end,
					func = function()
						C.db.profile.types.loot_items.filters[newID] = true
						newID = nil

						updateFilterOptions()
					end,
				},
			},
		},
	},
	plugins = {
		filters = {},
	},
})

E:RegisterSystem("loot_items", Enable, Disable, Test)
