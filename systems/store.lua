local _, addonTable = ...
local E, L, C = addonTable.E, addonTable.L, addonTable.C

-- Lua
local _G = getfenv(0)
local select = _G.select

-- Blizz
local C_MountJournal = _G.C_MountJournal
local C_PetJournal = _G.C_PetJournal
local C_Timer = _G.C_Timer
local Enum = _G.Enum

--[[ luacheck: globals
	BattlePetToolTip_Show CollectionsJournal CollectionsJournal_LoadUI DressUpBattlePet DressUpMount GameTooltip
	GetItemInfo GetItemInfoInstant InCombatLockdown IsModifiedClick MountJournal_SelectByMountID OpenBag PetJournal
	PetJournal_SelectPet SetCollectionsJournalShown ToyBox WardrobeCollectionFrame_OpenTransmogLink

	COLLECTIONS_JOURNAL_TAB_INDEX_APPEARANCES COLLECTIONS_JOURNAL_TAB_INDEX_MOUNTS COLLECTIONS_JOURNAL_TAB_INDEX_PETS
	COLLECTIONS_JOURNAL_TAB_INDEX_TOYS ITEM_QUALITY_COLORS
]]

-- Mine
local function Toast_OnClick(self)
	if IsModifiedClick("DRESSUP") then
		if self._data.link then
			E:DressUpLink(self._data.link)
		elseif self._data.entitlement_type == Enum.WoWEntitlementType.Mount then
			DressUpMount(self._data.entitlement_id)
		elseif self._data.entitlement_type == Enum.WoWEntitlementType.Battlepet then
			local speciesID, _, _, _, _, displayID, _, _, _, _, creatureID = C_PetJournal.GetPetInfoByPetID(self._data.entitlement_id)
			DressUpBattlePet(creatureID, displayID, speciesID)
		end
	elseif self._data.entitlement_id then
		if self._data.entitlement_type == Enum.WoWEntitlementType.Item then
			local slot = E:SearchBagsForItemID(self._data.entitlement_id)
			if slot >= 0 then
				OpenBag(slot)
			end
		elseif C.db.profile.types.store.left_click and not InCombatLockdown() then
			if not CollectionsJournal then
				CollectionsJournal_LoadUI()
			end

			if self._data.entitlement_type == Enum.WoWEntitlementType.Mount then
				SetCollectionsJournalShown(true, COLLECTIONS_JOURNAL_TAB_INDEX_MOUNTS)
				MountJournal_SelectByMountID(self._data.entitlement_id)
			elseif self._data.entitlement_type == Enum.WoWEntitlementType.Battlepet then
				SetCollectionsJournalShown(true, COLLECTIONS_JOURNAL_TAB_INDEX_PETS)
				PetJournal_SelectPet(PetJournal, self._data.entitlement_id)
			elseif self._data.entitlement_type == Enum.WoWEntitlementType.Toy then
				ToyBox.autoPageToCollectedToyID = self._data.entitlement_id
				SetCollectionsJournalShown(true, COLLECTIONS_JOURNAL_TAB_INDEX_TOYS)
			elseif self._data.entitlement_type == Enum.WoWEntitlementType.Appearance or self._data.entitlement_type == Enum.WoWEntitlementType.AppearanceSet or self._data.entitlement_type == Enum.WoWEntitlementType.Illusion then
				SetCollectionsJournalShown(true, COLLECTIONS_JOURNAL_TAB_INDEX_APPEARANCES)
				WardrobeCollectionFrame_OpenTransmogLink(self._data.link)
			end
		end
	end
end

local function Toast_OnEnter(self)
	if self._data.tooltip_link and self._data.tooltip_link:find("item") then
		GameTooltip:SetHyperlink(self._data.tooltip_link)
		GameTooltip:Show()
	end
end

local function Toast_SetUp(event, entitlementType, textureID, name, payloadID, payloadLink)
	local toast, quality, _

	if payloadLink then
		local sanitizedLink, originalLink = E:SanitizeLink(payloadLink)
		toast = E:GetToast(event, "link", sanitizedLink)
		_, _, quality = GetItemInfo(originalLink)

		toast._data.link = sanitizedLink
		toast._data.tooltip_link = originalLink
	else
		toast = E:GetToast()
	end

	if entitlementType == Enum.WoWEntitlementType.Appearance then
		toast._data.link = "transmogappearance:" .. payloadID
	elseif entitlementType == Enum.WoWEntitlementType.AppearanceSet then
		toast._data.link = "transmogset:" .. payloadID
	elseif entitlementType == Enum.WoWEntitlementType.Illusion then
		toast._data.link = "transmogillusion:" .. payloadID
	end

	quality = quality or 1
	if quality >= C.db.profile.colors.threshold then
		local color = ITEM_QUALITY_COLORS[quality]

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

	toast:SetBackground("store")
	toast.Title:SetText(event == "ENTITLEMENT_DELIVERED" and L["BLIZZARD_STORE_PURCHASE_DELIVERED"] or L["YOU_RECEIVED"])
	toast.Text:SetText(name)
	toast.Icon:SetTexture(textureID)
	toast.IconBorder:Show()

	toast._data.entitlement_id = payloadID
	toast._data.entitlement_type = entitlementType
	toast._data.event = event
	toast._data.sound_file = C.db.profile.types.store.sfx and 39517 -- SOUNDKIT.UI_IG_STORE_PURCHASE_DELIVERED_TOAST_01

	toast:HookScript("OnClick", Toast_OnClick)
	toast:HookScript("OnEnter", Toast_OnEnter)
	toast:Spawn(C.db.profile.types.store.anchor, C.db.profile.types.store.dnd)
end

local function getItemLink(itemID, textureID)
	if itemID then
		if select(5, GetItemInfoInstant(itemID)) == textureID then
			local _, link = GetItemInfo(itemID)
			if link then
				return link, false
			end

			return nil, true
		end
	end

	return nil, false
end

local function ENTITLEMENT_DELIVERED(entitlementType, textureID, name, payloadID)
	if entitlementType == Enum.WoWEntitlementType.Invalid then
		return
	end

	local link, tryAgain = getItemLink(payloadID, textureID)
	if tryAgain then
		return C_Timer.After(0.25, function() ENTITLEMENT_DELIVERED(entitlementType, textureID, name, payloadID) end)
	end

	Toast_SetUp("ENTITLEMENT_DELIVERED", entitlementType, textureID, name, payloadID, link)
end

local function RAF_ENTITLEMENT_DELIVERED(entitlementType, textureID, name, payloadID)
	if entitlementType == Enum.WoWEntitlementType.Invalid then
		return
	end

	local link, tryAgain = getItemLink(payloadID, textureID)
	if tryAgain then
		return C_Timer.After(0.25, function() RAF_ENTITLEMENT_DELIVERED(entitlementType, textureID, name, payloadID) end)
	end

	Toast_SetUp("RAF_ENTITLEMENT_DELIVERED", entitlementType, textureID, name, payloadID, link)
end

local function Enable()
	if C.db.profile.types.store.enabled then
		E:RegisterEvent("ENTITLEMENT_DELIVERED", ENTITLEMENT_DELIVERED)
		E:RegisterEvent("RAF_ENTITLEMENT_DELIVERED", RAF_ENTITLEMENT_DELIVERED)
	end
end

local function Disable()
	E:UnregisterEvent("ENTITLEMENT_DELIVERED", ENTITLEMENT_DELIVERED)
	E:UnregisterEvent("RAF_ENTITLEMENT_DELIVERED", RAF_ENTITLEMENT_DELIVERED)
end

local function Test()
	-- WoW Token
	local name, link, _, _, _, _, _, _, _, icon = GetItemInfo(122270)
	if link then
		Toast_SetUp("ENTITLEMENT_TEST", Enum.WoWEntitlementType.Item, icon, name, 122270, link)
	end

	-- Golden Gryphon
	name, _, icon = C_MountJournal.GetMountInfoByID(129)
	Toast_SetUp("ENTITLEMENT_TEST", Enum.WoWEntitlementType.Mount, icon, name, 129)
end

E:RegisterOptions("store", {
	enabled = true,
	anchor = 1,
	dnd = false,
	sfx = true,
	left_click = false,
}, {
	name = L["BLIZZARD_STORE"],
	get = function(info)
		return C.db.profile.types.store[info[#info]]
	end,
	set = function(info, value)
		C.db.profile.types.store[info[#info]] = value
	end,
	args = {
		enabled = {
			order = 1,
			type = "toggle",
			name = L["ENABLE"],
			set = function(_, value)
				C.db.profile.types.store.enabled = value

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
		left_click = {
			order = 4,
			type = "toggle",
			name = L["HANDLE_LEFT_CLICK"],
			desc = L["COLLECTIONS_TAINT_WARNING"],
			image = "Interface\\DialogFrame\\UI-Dialog-Icon-AlertNew",
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

E:RegisterSystem("store", Enable, Disable, Test)
