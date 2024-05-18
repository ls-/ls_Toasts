local _, addonTable = ...
local E, L, C = addonTable.E, addonTable.L, addonTable.C

-- Lua
local _G = getfenv(0)

-- Mine
local function Toast_OnClick(self)
	if self._data.collection_id then
		if IsModifiedClick("DRESSUP") then
			-- ! This stuff doesn't work in Cata
			-- if self._data.is_mount then
			-- 	DressUpMount(self._data.collection_id)
			-- elseif self._data.is_pet then
			-- 	local speciesID, _, _, _, _, displayID, _, _, _, _, creatureID = C_PetJournal.GetPetInfoByPetID(self._data.collection_id)
			-- 	DressUpBattlePet(creatureID, displayID, speciesID)
			-- end
		elseif C.db.profile.types.collection.left_click and not InCombatLockdown() then
			if not CollectionsJournal then
				CollectionsJournal_LoadUI()
			end

			if CollectionsJournal then
				if self._data.is_mount then
					SetCollectionsJournalShown(true, COLLECTIONS_JOURNAL_TAB_INDEX_MOUNTS)
					MountJournal_SelectByMountID(self._data.collection_id)
				elseif self._data.is_pet then
					SetCollectionsJournalShown(true, COLLECTIONS_JOURNAL_TAB_INDEX_PETS)
					PetJournal_SelectPet(PetJournal, self._data.collection_id)
				elseif self._data.is_toy then
					SetCollectionsJournalShown(true, COLLECTIONS_JOURNAL_TAB_INDEX_TOYS)

					local page = ToyBox_FindPageForToyID(self._data.collection_id)
					if page then
						ToyBox.PagingFrame:SetCurrentPage(page)
					end
				end
			end
		end
	end
end

local function PostSetAnimatedValue(self, value)
	self:SetText(value == 1 and "" or value)
end

local function Toast_SetUp(event, ID, isMount, isPet, isToy)
	local toast, isNew, isQueued = E:GetToast(event, "collection_id", ID)
	if isNew then
		local name, icon, _

		if isMount then
			name, _, icon = C_MountJournal.GetMountInfoByID(ID)
		elseif isPet then
			local customName
			_, customName, _, _, _, _, _, name, icon = C_PetJournal.GetPetInfoByPetID(ID)
			name = customName or name
		elseif isToy then
			_, name, icon = C_ToyBox.GetToyInfo(ID)
		end

		if not name then
			return toast:Release()
		end

		toast.IconText1.PostSetAnimatedValue = PostSetAnimatedValue

		toast:SetBackground("collection")
		toast.Title:SetText(L["YOU_COLLECTED"])
		toast.Text:SetText(name)
		toast.Icon:SetTexture(icon)
		toast.IconBorder:Show()
		toast.IconText1:SetAnimatedValue(1, true)

		toast._data.collection_id = ID
		toast._data.count = 1
		toast._data.event = event
		toast._data.is_mount = isMount
		toast._data.is_pet = isPet
		toast._data.is_toy = isToy
		toast._data.sound_file = C.db.profile.types.collection.sfx and "Interface\\AddOns\\ls_Toasts\\assets\\ui-common-loot-toast.OGG"

		toast:HookScript("OnClick", Toast_OnClick)
		toast:Spawn(C.db.profile.types.collection.anchor, C.db.profile.types.collection.dnd)
	else
		if isQueued then
			toast._data.count = toast._data.count + 1
			toast.IconText1:SetAnimatedValue(toast._data.count, true)
		else
			toast._data.count = toast._data.count + 1
			toast.IconText1:SetAnimatedValue(toast._data.count)

			toast.IconText2:SetText("+1")
			toast.IconText2.Blink:Stop()
			toast.IconText2.Blink:Play()

			toast.AnimOut:Stop()
			toast.AnimOut:Play()
		end
	end
end

local function NEW_MOUNT_ADDED(mountID)
	Toast_SetUp("NEW_MOUNT_ADDED", mountID, true)
end

local function NEW_PET_ADDED(petID)
	Toast_SetUp("NEW_PET_ADDED", petID, nil, true)
end

local function NEW_TOY_ADDED(toyID)
	Toast_SetUp("NEW_TOY_ADDED", toyID, nil, nil, true)
end

local function Enable()
	if C.db.profile.types.collection.enabled then
		E:RegisterEvent("NEW_MOUNT_ADDED", NEW_MOUNT_ADDED)
		E:RegisterEvent("NEW_PET_ADDED", NEW_PET_ADDED)
		E:RegisterEvent("NEW_TOY_ADDED", NEW_TOY_ADDED)
	end
end

local function Disable()
	E:UnregisterEvent("NEW_MOUNT_ADDED", NEW_MOUNT_ADDED)
	E:UnregisterEvent("NEW_PET_ADDED", NEW_PET_ADDED)
	E:UnregisterEvent("NEW_TOY_ADDED", NEW_TOY_ADDED)
end

local function Test()
	-- Golden Gryphon
	Toast_SetUp("MOUNT_TEST", 129, true)

	-- Pet
	local petID = C_PetJournal.GetPetInfoByIndex(1)
	if petID then
		Toast_SetUp("PET_TEST", petID, nil, true)
	end

	-- Argent Crusader's Banner
	Toast_SetUp("TOY_TEST", 46843, nil, nil, true)
end

E:RegisterOptions("collection", {
	enabled = true,
	anchor = 1,
	dnd = false,
	sfx = true,
	left_click = false,
}, {
	name = L["TYPE_COLLECTION"],
	get = function(info)
		return C.db.profile.types.collection[info[#info]]
	end,
	set = function(info, value)
		C.db.profile.types.collection[info[#info]] = value
	end,
	args = {
		desc = {
			order = 1,
			type = "description",
			name = L["TYPE_COLLECTION_DESC"],
		},
		enabled = {
			order = 2,
			type = "toggle",
			name = L["ENABLE"],
			set = function(_, value)
				C.db.profile.types.collection.enabled = value

				if value then
					Enable()
				else
					Disable()
				end
			end
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
		left_click = {
			order = 5,
			type = "toggle",
			name = L["HANDLE_LEFT_CLICK"],
			desc = L["TAINT_WARNING"],
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

E:RegisterSystem("collection", Enable, Disable, Test)
