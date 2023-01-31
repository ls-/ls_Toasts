local _, addonTable = ...
local E, L, C = addonTable.E, addonTable.L, addonTable.C

-- Lua
local _G = getfenv(0)
local tonumber = _G.tonumber

-- Blizz
local C_Timer = _G.C_Timer

--[[ luacheck: globals
	DressUpVisual GameTooltip GetItemInfo IsDressableItem IsModifiedClick OpenBag UnitGUID UnitName

	ITEM_QUALITY_COLORS ITEM_QUALITY1_DESC ITEM_QUALITY2_DESC ITEM_QUALITY3_DESC ITEM_QUALITY4_DESC
	LOOT_ITEM_CREATED_SELF LOOT_ITEM_CREATED_SELF_MULTIPLE LOOT_ITEM_PUSHED_SELF LOOT_ITEM_PUSHED_SELF_MULTIPLE
	LOOT_ITEM_SELF LOOT_ITEM_SELF_MULTIPLE
]]

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

local function dressUp(link)
	if not link then
		return
	end

	-- item
	if IsDressableItem(link) then
		if DressUpVisual(link) then
			return
		end
	end
end

local function Toast_OnClick(self)
	if self._data.link and IsModifiedClick("DRESSUP") then
		dressUp(self._data.link)
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
		local isQuestItem = bindType == 4 or (classID == 12 and subClassID == 0)

		if name and ((quality and quality >= C.db.profile.types.loot_items.threshold and quality <= 5)
			or (C.db.profile.types.loot_items.quest and isQuestItem)) then
			local color = ITEM_QUALITY_COLORS[quality] or ITEM_QUALITY_COLORS[1]
			local title = L["YOU_RECEIVED"]
			local soundFile = "Interface\\AddOns\\ls_Toasts\\assets\\ui-common-loot-toast.OGG"

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

local function Enable()
	updatePatterns()

	if C.db.profile.types.loot_items.enabled then
		E:RegisterEvent("CHAT_MSG_LOOT", CHAT_MSG_LOOT)
		E:RegisterEvent("PLAYER_ENTERING_WORLD", delayedUpdatePatterns)
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
	quest = false,
	threshold = 1,
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
		quest = {
			order = 6,
			type = "toggle",
			name = L["SHOW_QUEST_ITEMS"],
			desc = L["SHOW_QUEST_ITEMS_DESC"],
		},
		test = {
			type = "execute",
			order = 99,
			width = "full",
			name = L["TEST"],
			func = Test,
		},
	},
})

E:RegisterSystem("loot_items", Enable, Disable, Test)
