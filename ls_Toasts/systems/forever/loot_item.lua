local _, addon = ...
local E, L, C = addon.E, addon.L, addon.C

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
	if CACHED_LOOT_ITEM_CREATED ~= _G.LOOT_ITEM_CREATED_SELF then
		LOOT_ITEM_CREATED_PATTERN = _G.LOOT_ITEM_CREATED_SELF:gsub("%%s", "(.+)"):gsub("^", "^")
		CACHED_LOOT_ITEM_CREATED = _G.LOOT_ITEM_CREATED_SELF
	end

	if CACHED_LOOT_ITEM_CREATED_MULTIPLE ~= _G.LOOT_ITEM_CREATED_SELF_MULTIPLE then
		LOOT_ITEM_CREATED_MULTIPLE_PATTERN = _G.LOOT_ITEM_CREATED_SELF_MULTIPLE:gsub("%%s", "(.+)"):gsub("%%d", "(%%d+)"):gsub("^", "^")
		CACHED_LOOT_ITEM_CREATED_MULTIPLE = _G.LOOT_ITEM_CREATED_SELF_MULTIPLE
	end

	if CACHED_LOOT_ITEM ~= _G.LOOT_ITEM_SELF then
		LOOT_ITEM_PATTERN = _G.LOOT_ITEM_SELF:gsub("%%s", "(.+)"):gsub("^", "^")
		CACHED_LOOT_ITEM = _G.LOOT_ITEM_SELF
	end

	if CACHED_LOOT_ITEM_MULTIPLE ~= _G.LOOT_ITEM_SELF_MULTIPLE then
		LOOT_ITEM_MULTIPLE_PATTERN = _G.LOOT_ITEM_SELF_MULTIPLE:gsub("%%s", "(.+)"):gsub("%%d", "(%%d+)"):gsub("^", "^")
		CACHED_LOOT_ITEM_MULTIPLE = _G.LOOT_ITEM_SELF_MULTIPLE
	end

	if CACHED_LOOT_ITEM_PUSHED ~= _G.LOOT_ITEM_PUSHED_SELF then
		LOOT_ITEM_PUSHED_PATTERN = _G.LOOT_ITEM_PUSHED_SELF:gsub("%%s", "(.+)"):gsub("^", "^")
		CACHED_LOOT_ITEM_PUSHED = _G.LOOT_ITEM_PUSHED_SELF
	end

	if CACHED_LOOT_ITEM_PUSHED_MULTIPLE ~= _G.LOOT_ITEM_PUSHED_SELF_MULTIPLE then
		LOOT_ITEM_PUSHED_MULTIPLE_PATTERN = _G.LOOT_ITEM_PUSHED_SELF_MULTIPLE:gsub("%%s", "(.+)"):gsub("%%d", "(%%d+)"):gsub("^", "^")
		CACHED_LOOT_ITEM_PUSHED_MULTIPLE = _G.LOOT_ITEM_PUSHED_SELF_MULTIPLE
	end
end

local function delayedUpdatePatterns()
	C_Timer.After(0.1, updatePatterns)
end

local function Toast_OnClick(self)
	if self._data.link and IsModifiedClick("DRESSUP") then
		DressUpItemLink(self._data.link)
	elseif self._data.item_id then
		local slot = SearchBagsForItem(self._data.item_id)
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

local MAT_SUBCLASS_IDS = {
	[ 1] = true, -- Parts
	[ 5] = true, -- Cloth
	[ 6] = true, -- Leather
	[ 7] = true, -- Metal & Stone
	[ 8] = true, -- Meat
	[ 9] = true, -- Herb
	[10] = true, -- Elemental
	[11] = true, -- Other
	[12] = true, -- Enchanting
}

local function Toast_SetUp(event, link, quantity)
	local sanitizedLink, originalLink, _, itemID = E:SanitizeLink(link)
	local toast, isNew, isQueued = E:GetToast(event, "link", sanitizedLink)
	if isNew then
		local name, _, quality, _, _, _, _, _, _, icon, _, classID, subClassID, bindType = C_Item.GetItemInfo(originalLink)
		local isMaterial = classID == 7 and MAT_SUBCLASS_IDS[subClassID]
		local isQuestItem = bindType == 4 or (classID == 12 and subClassID == 0)

		if not name or C.db.profile.types.loot_item.filters[itemID] == false then
			toast:Release()

			return
		end

		if not ((quality and quality >= C.db.profile.types.loot_item.threshold and quality <= 5)
		or (isMaterial and C.db.profile.types.loot_item.material)
		or (isQuestItem and C.db.profile.types.loot_item.quest)
		or C.db.profile.types.loot_item.filters[itemID]) then
			toast:Release()

			return
		end

		local color = ITEM_QUALITY_COLORS[quality] or ITEM_QUALITY_COLORS[1]
		local title = L["YOU_RECEIVED"]
		local soundFile = 31578 -- SOUNDKIT.UI_EPICLOOT_TOAST

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

		if C.db.profile.types.loot_item.ilvl then
			local iLevel = E:GetItemLevel(originalLink)

			if iLevel > 0 then
				name = "[" .. color.hex .. iLevel .. "|r] " .. name
			end
		end

		if quality == 5 then
			title = L["ITEM_LEGENDARY"]
			soundFile = 63971 -- SOUNDKIT.UI_LEGENDARY_LOOT_TOAST

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
		toast._data.sound_file = C.db.profile.types.loot_item.sfx and soundFile
		toast._data.vfx = C.db.profile.types.loot_item.vfx
		toast._data.tooltip_link = originalLink

		if C.db.profile.types.loot_item.tooltip then
			toast:HookScript("OnEnter", Toast_OnEnter)
		end

		toast:HookScript("OnClick", Toast_OnClick)
		toast:Spawn(addon:GetAnchorIDForType("loot_item"), C.db.profile.types.loot_item.dnd)
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

local function CHAT_MSG_LOOT(message, _, _, _, _, _, _, _, _, _, _, guid)
	if guid and guid ~= PLAYER_GUID then
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
local isAllowed = true
local pendingItemIDs = {}
local handleItemInfo, updateFilterOptions

local function allowGetter(info)
	return C.db.profile.types.loot_item.filters[tonumber(info[#info - 1])]
end

local function allowSetter(info)
	C.db.profile.types.loot_item.filters[tonumber(info[#info - 1])] = true
end

local function blockGetter(info)
	return not C.db.profile.types.loot_item.filters[tonumber(info[#info - 1])]
end

local function blockSetter(info)
	C.db.profile.types.loot_item.filters[tonumber(info[#info - 1])] = false
end

local function removeFilter(info)
	C.db.profile.types.loot_item.filters[tonumber(info[#info - 1])] = nil

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
	if not C.db.profile.types.loot_item.enabled then
		return
	end

	local options = t_wipe(C.options.args.types.args.loot_item.plugins.filters)
	local nameToIndex = {}
	local name, quaility, icon, color, _

	for id in next, C.db.profile.types.loot_item.filters do
		if not C_Item.GetItemInfoInstant(id) then
			-- remove invalid IDs, some people do stuff...
			C.db.profile.types.loot_item.filters[id] = nil
		else
			name = C_Item.GetItemInfo(id)
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

	for id in next, C.db.profile.types.loot_item.filters do
		if not pendingItemIDs[id] then
			name, _, quaility, _, _, _, _, _, _, icon = C_Item.GetItemInfo(id)
			color = ITEM_QUALITY_COLORS[quaility] or ITEM_QUALITY_COLORS[1]

			options[tostring(id)] = {
				order = nameToIndex[name] + 20,
				type = "group",
				name = ("|T%s:0:0:0:0:64:64:4:60:4:60|t %s%s|r"):format(icon, color.hex, name),
				args = {
					allow = {
						type = "toggle",
						order = 2,
						name = L["ALLOW"],
						get = allowGetter,
						set = allowSetter,
					},
					block = {
						type = "toggle",
						order = 2,
						name = L["BLOCK"],
						get = blockGetter,
						set = blockSetter,
					},
					spacer_1 = {
						order = 3,
						type = "description",
						name = "",
					},
					delete = {
						type = "execute",
						order = 4,
						name = L["DELETE"],
						width = "full",
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

	if C.db.profile.types.loot_item.enabled then
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
	local _, link = C_Item.GetItemInfo(6948)
	if link then
		Toast_SetUp("COMMON_LOOT_TEST", link, 1)
	end

	-- common, quest, Mallet of Zul'Farrak
	_, link = C_Item.GetItemInfo(9240)
	if link then
		Toast_SetUp("COMMON_LOOT_TEST", link, 1)
	end

	-- rare, material, Small Glowing Shard
	_, link = C_Item.GetItemInfo(11138)
	if link then
		Toast_SetUp("COMMON_LOOT_TEST", link, 1)
	end

	-- uncommon, Chromatic Sword
	_, link = C_Item.GetItemInfo(1604)
	if link then
		Toast_SetUp("COMMON_LOOT_TEST", link, 1)
	end

	-- rare, Arcanite Reaper
	_, link = C_Item.GetItemInfo(12784)
	if link then
		Toast_SetUp("COMMON_LOOT_TEST", link, 1)
	end

	-- legendary, Atiesh, Greatstaff of the Guardian
	_, link = C_Item.GetItemInfo(22589)
	if link then
		Toast_SetUp("COMMON_LOOT_TEST", link, 1)
	end
end

E:RegisterOptions("loot_item", {
	enabled = true,
	dnd = false,
	sfx = true,
	vfx = true,
	tooltip = true,
	ilvl = true,
	material = false,
	quest = false,
	threshold = 1,
	filters = {},
}, {
	name = L["TYPE_LOOT_ITEM"],
	disabled = function(info)
		if info[#info] == "loot_item" then
			return false
		else
			return not C.db.profile.types.loot_item.enabled
		end
	end,
	get = function(info)
		return C.db.profile.types.loot_item[info[#info]]
	end,
	set = function(info, value)
		C.db.profile.types.loot_item[info[#info]] = value
	end,
	args = {
		enabled = {
			order = 1,
			type = "toggle",
			name = L["ENABLE"],
			disabled = false,
			set = function(_, value)
				C.db.profile.types.loot_item.enabled = value

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
			desc = L["DND_DESC"],
		},
		sfx = {
			order = 3,
			type = "toggle",
			name = L["SFX"],
		},
		vfx = {
			order = 4,
			type = "toggle",
			name = L["VFX"],
		},
		tooltip = {
			order = 5,
			type = "toggle",
			name = L["TOOLTIPS"],
		},
		ilvl = {
			order = 6,
			type = "toggle",
			name = L["ILVL"],
		},
		test = {
			type = "execute",
			order = 19,
			width = "full",
			name = L["TEST"],
			func = Test,
		},
		spacer_1 = {
			order = 20,
			type = "description",
			name = " ",
		},
		threshold = {
			order = 21,
			type = "select",
			name = L["LOOT_THRESHOLD"],
			values = {
				[0] = ITEM_QUALITY_COLORS[0].hex .. _G.ITEM_QUALITY0_DESC .. "|r",
				[1] = ITEM_QUALITY_COLORS[1].hex .. _G.ITEM_QUALITY1_DESC .. "|r",
				[2] = ITEM_QUALITY_COLORS[2].hex .. _G.ITEM_QUALITY2_DESC .. "|r",
				[3] = ITEM_QUALITY_COLORS[3].hex .. _G.ITEM_QUALITY3_DESC .. "|r",
				[4] = ITEM_QUALITY_COLORS[4].hex .. _G.ITEM_QUALITY4_DESC .. "|r",
			},
		},
		filters = {
			order = 22,
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
				material = {
					order = 5,
					type = "toggle",
					name = L["MATERIALS"],
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
				allow = {
					type = "toggle",
					order = 2,
					name = L["ALLOW"],
					get = function()
						return isAllowed
					end,
					set = function()
						isAllowed = true
					end,
				},
				block = {
					type = "toggle",
					order = 2,
					name = L["BLOCK"],
					get = function()
						return not isAllowed
					end,
					set = function()
						isAllowed = false
					end,
				},
				spacer_1 = {
					order = 3,
					type = "description",
					name = "",
				},
				id = {
					order = 4,
					type = "input",
					name = L["ID"],
					dialogControl = "LSPreviewBoxItem",
					width = "relative",
					relWidth = 0.5,
					validate = function(_, value)
						value = tonumber(value)
						if value then
							return not not C_Item.GetItemInfoInstant(value)
						else
							return true
						end
					end,
					set = function(_, value)
						value = tonumber(value)
						if value and C_Item.GetItemInfoInstant(value) then
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
					order = 5,
					name = L["ADD"],
					width = "relative",
					relWidth = 0.5,
					disabled = function()
						return not newID or C.db.profile.types.loot_item.filters[newID]
					end,
					func = function()
						C.db.profile.types.loot_item.filters[newID] = isAllowed
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

E:RegisterSystem("loot_item", Enable, Disable, Test)
