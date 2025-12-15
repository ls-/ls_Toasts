local _, addonTable = ...
local E, L, C = addonTable.E, addonTable.L, addonTable.C

-- Lua
local _G = getfenv(0)
local m_random = _G.math.random
local next = _G.next
local s_split = _G.string.split
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

-- a cutdown and always available version of Professions.GetChatIconMarkupForQuality
local function getIconForQuality(quality)
	return CreateAtlasMarkupWithAtlasSize("professions-chaticon-quality-tier" .. quality, 0, 1, nil, nil, nil, 0.5);
end

local function Toast_OnClick(self)
	if self._data.link and IsModifiedClick("DRESSUP") then
		DressUpLink(self._data.link)
	elseif self._data.item_id then
		local slot = SearchBagsForItem(self._data.item_id)
		if slot >= 0 then
			OpenBag(slot)
		end
	end
end

local function Toast_OnEnter(self)
	if self._data.tooltip_link then
		if self._data.tooltip_link:find("item") then
			GameTooltip:SetHyperlink(self._data.tooltip_link)
			GameTooltip:Show()
		elseif self._data.tooltip_link:find("battlepet") then
			local _, speciesID, level, breedQuality, maxHealth, power, speed = s_split(":", self._data.tooltip_link)
			BattlePetToolTip_Show(tonumber(speciesID), tonumber(level), tonumber(breedQuality), tonumber(maxHealth), tonumber(power), tonumber(speed))
		end
	end
end

local function PostSetAnimatedValue(self, value)
	self:SetText(value == 1 and "" or value)
end

local function Toast_SetUp(event, link, quantity)
	local sanitizedLink, originalLink, linkType, itemID = E:SanitizeLink(link)
	local toast, isNew, isQueued

	-- Check if there's a toast for this item from another event
	toast, isQueued = E:FindToast(nil, "item_id", itemID)
	if toast then
		if toast._data.event ~= event then
			return
		end
	else
		toast, isNew, isQueued = E:GetToast(event, "link", sanitizedLink)
	end

	if isNew then
		local name, quality, equipLoc, icon, _, classID, subClassID, bindType, expansionID, isQuestItem, isLegacyEquipment

		if linkType == "battlepet" then
			local _, speciesID, _, breedQuality, _ = s_split(":", originalLink)
			name, icon = C_PetJournal.GetPetInfoBySpeciesID(speciesID)
			quality = tonumber(breedQuality)
		else
			name, _, quality, _, _, _, _, _, equipLoc, icon, _, classID, subClassID, bindType, expansionID = C_Item.GetItemInfo(originalLink)
			isQuestItem = bindType == 4 or (classID == 12 and subClassID == 0)
			isLegacyEquipment = ((equipLoc and equipLoc ~= "INVTYPE_NON_EQUIP_IGNORE") or (classID == 3 and subClassID == 11))
				and (expansionID or 0) < GetExpansionLevel() -- legacy gear and relics
		end

		if not name
		or (isLegacyEquipment and not C.db.profile.types.loot_common.legacy_equipment)
		or C.db.profile.types.loot_common.filters[itemID] == false then
			toast:Release()

			return
		end

		if not ((quality and quality >= C.db.profile.types.loot_common.threshold and quality <= 5)
		or (isQuestItem and C.db.profile.types.loot_common.quest)
		or C.db.profile.types.loot_common.filters[itemID]) then
			toast:Release()

			return
		end

		local color = ITEM_QUALITY_COLORS[quality] or ITEM_QUALITY_COLORS[1]
		local title = L["YOU_RECEIVED"]
		local soundFile = 31578 -- SOUNDKIT.UI_EPICLOOT_TOAST

		toast.IconText1.PostSetAnimatedValue = PostSetAnimatedValue

		if quality >= C.db.profile.colors.threshold then
			if C.db.profile.colors.name then
				name = color.hex .. name .. "|r"
			end

			if C.db.profile.colors.border then
				toast.Border:SetVertexColor(color.r, color.g, color.b)
			end

			if C.db.profile.colors.icon_border then
				toast.IconBorder:SetVertexColor(color.r, color.g, color.b)
			end
		end

		if C.db.profile.types.loot_common.ilvl then
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

		local reagentQuality = C_TradeSkillUI.GetItemReagentQualityByItemInfo(originalLink)
		if not reagentQuality then
			reagentQuality = C_TradeSkillUI.GetItemCraftedQualityByItemInfo(originalLink)
		end

		if reagentQuality then
			reagentQuality = getIconForQuality(reagentQuality)
			if reagentQuality then
				toast.IconText3:SetText(reagentQuality)
				toast.IconText3BG:Show()
			end
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
		toast._data.sound_file = C.db.profile.types.loot_common.sfx and soundFile
		toast._data.vfx = C.db.profile.types.loot_common.vfx
		toast._data.tooltip_link = originalLink

		if C.db.profile.types.loot_common.tooltip then
			toast:HookScript("OnEnter", Toast_OnEnter)
		end

		toast:HookScript("OnClick", Toast_OnClick)
		toast:Spawn(C.db.profile.types.loot_common.anchor, C.db.profile.types.loot_common.dnd)
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
	if guid ~= PLAYER_GUID then
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

	C_Timer.After(0.3, function() Toast_SetUp("CHAT_MSG_LOOT", link, tonumber(quantity) or 0) end)
end

local newID
local isAllowed = true
local pendingItemIDs = {}
local handleItemInfo, updateFilterOptions

local function allowGetter(info)
	return C.db.profile.types.loot_common.filters[tonumber(info[#info - 1])]
end

local function allowSetter(info)
	C.db.profile.types.loot_common.filters[tonumber(info[#info - 1])] = true
end

local function blockGetter(info)
	return not C.db.profile.types.loot_common.filters[tonumber(info[#info - 1])]
end

local function blockSetter(info)
	C.db.profile.types.loot_common.filters[tonumber(info[#info - 1])] = false
end

local function removeFilter(info)
	C.db.profile.types.loot_common.filters[tonumber(info[#info - 1])] = nil

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
	if not C.db.profile.types.loot_common.enabled then
		return
	end

	local options = t_wipe(C.options.args.types.args.loot_common.plugins.filters)
	local nameToIndex = {}
	local name, quaility, icon, color, _

	for id in next, C.db.profile.types.loot_common.filters do
		if not C_Item.GetItemInfoInstant(id) then
			-- remove invalid IDs, some people do stuff...
			C.db.profile.types.loot_common.filters[id] = nil
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

	for id in next, C.db.profile.types.loot_common.filters do
		if not pendingItemIDs[id] then
			name, _, quaility, _, _, _, _, _, _, icon = C_Item.GetItemInfo(id)
			color = ITEM_QUALITY_COLORS[quaility] or ITEM_QUALITY_COLORS[1]

			options[tostring(id)] = {
				order = nameToIndex[name] + 110,
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

	if C.db.profile.types.loot_common.enabled then
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
	-- item, Chaos Crystal
	local _, link = C_Item.GetItemInfo(124442)
	if link then
		Toast_SetUp("COMMON_LOOT_TEST", link, m_random(9, 99))
	end

	-- item, Hochenblume, Rank 3
	_, link = C_Item.GetItemInfo(191462)
	if link then
		Toast_SetUp("COMMON_LOOT_TEST", link, m_random(9, 99))
	end

	-- relic, Apocron's Energy Core
	Toast_SetUp("COMMON_LOOT_TEST", "item:147760::::::::70:64::3:1:3524:1:28:624:::::", 1)

	-- Obsidian Seared Facesmasher, Rank 5
	Toast_SetUp("COMMON_LOOT_TEST", "item:190513:6643:::::::70:263::13:6:8836:8840:8902:8802:8846:8793:7:28:2164:29:40:30:36:38:8:40:185:45:198046:46:194566:::::", 1)

	-- battlepet, Anubisath Idol
	Toast_SetUp("COMMON_LOOT_TEST", "battlepet:1155:25:3:1725:276:244:0000000000000000", 1)
end

E:RegisterOptions("loot_common", {
	enabled = true,
	anchor = 1,
	dnd = false,
	sfx = true,
	vfx = true,
	tooltip = true,
	ilvl = true,
	legacy_equipment = true,
	quest = false,
	threshold = 1,
	filters = {},
}, {
	name = L["TYPE_LOOT_COMMON"],
	get = function(info)
		return C.db.profile.types.loot_common[info[#info]]
	end,
	set = function(info, value)
		C.db.profile.types.loot_common[info[#info]] = value
	end,
	args = {
		desc = {
			order = 1,
			type = "description",
			name = L["TYPE_LOOT_COMMON_DESC"],
		},
		enabled = {
			order = 2,
			type = "toggle",
			name = L["ENABLE"],
			set = function(_, value)
				C.db.profile.types.loot_common.enabled = value

				if value then
					Enable()
				else
					Disable()
				end
			end,
		},
		dnd = {
			order = 3,
			type = "toggle",
			name = L["DND"],
			desc = L["DND_TOOLTIP"],
		},
		sfx = {
			order = 4,
			type = "toggle",
			name = L["SFX"],
		},
		vfx = {
			order = 5,
			type = "toggle",
			name = L["VFX"],
		},
		tooltip = {
			order = 6,
			type = "toggle",
			name = L["TOOLTIPS"],
		},
		ilvl = {
			order = 7,
			type = "toggle",
			name = L["ILVL"],
		},
		legacy_equipment = {
			order = 9,
			type = "toggle",
			name = L["LEGACY_EQUIPMENT"],
			desc = L["LEGACY_EQUIPMENT_DESC"],
		},
		test = {
			type = "execute",
			order = 99,
			width = "full",
			name = L["TEST"],
			func = Test,
		},
		spacer_1 = {
			order = 100,
			type = "description",
			name = " ",
		},
		threshold = {
			order = 101,
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
		filters = {
			order = 102,
			type = "group",
			name = " ",
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
			},
		},
		new = {
			order = 103,
			type = "group",
			name = L["NEW"],
			args = {
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
					order = 5,
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
					order = 6,
					name = L["ADD"],
					width = "relative",
					relWidth = 0.5,
					disabled = function()
						return not newID or C.db.profile.types.loot_common.filters[newID]
					end,
					func = function()
						C.db.profile.types.loot_common.filters[newID] = isAllowed
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

E:RegisterSystem("loot_common", Enable, Disable, Test)
