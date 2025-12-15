local _, addonTable = ...
local E, L, C = addonTable.E, addonTable.L, addonTable.C

-- Lua
local _G = getfenv(0)
local next = _G.next
local t_wipe = _G.table.wipe

-- Mine
local function Toast_OnClick(self)
	if self._data.source_id then
		if IsModifiedClick("DRESSUP") then
			DressUpVisual(self._data.source_id)
		elseif C.db.profile.types.transmog.left_click and not InCombatLockdown() then
			TransmogUtil.OpenCollectionToItem(self._data.source_id)
		end
	end
end

local function Toast_SetUp(event, sourceID, isAdded, attempt)
	local _, visualID, _, icon, _, _, link = C_TransmogCollection.GetAppearanceSourceInfo(sourceID)
	local name
	link, _, _, _, name = E:SanitizeLink(link)
	if not link then
		return attempt < 4 and C_Timer.After(0.25, function() Toast_SetUp(event, sourceID, isAdded, attempt + 1) end)
	end

	if E:FindToast(event, "visual_id", visualID) then
		return
	end

	local toast, isNew, isQueued = E:GetToast(nil, "source_id", sourceID)
	if isNew then
		if C.db.profile.colors.border then
			toast.Border:SetVertexColor(1, 0.5, 1)
		end

		if C.db.profile.colors.icon_border then
			toast.IconBorder:SetVertexColor(1, 0.5, 1)
		end

		toast:SetBackground("transmog")
		toast.Title:SetText(isAdded and L["TRANSMOG_ADDED"] or L["TRANSMOG_REMOVED_RED"])
		toast.Text:SetText(name)
		toast.Icon:SetTexture(icon)
		toast.IconBorder:Show()

		toast._data.event = event
		toast._data.link = link
		toast._data.sound_file = C.db.profile.types.transmog.sfx and 187694 -- SOUNDKIT.UI_COSMETIC_ITEM_TOAST_SHOW
		toast._data.vfx = C.db.profile.types.transmog.vfx
		toast._data.source_id = sourceID
		toast._data.visual_id = visualID

		toast:HookScript("OnClick", Toast_OnClick)
		toast:Spawn(C.db.profile.types.transmog.anchor, C.db.profile.types.transmog.dnd)
	else
		toast.Title:SetText(isAdded and L["TRANSMOG_ADDED"] or L["TRANSMOG_REMOVED_RED"])

		if not isQueued then
			toast.AnimOut:Stop()
			toast.AnimOut:Play()
		end
	end
end

local RESULT_NO_DATA = 1
local RESULT_YES = 2

local function isCollectedFromAnotherSource(sourceID)
	local _, visualID = C_TransmogCollection.GetAppearanceSourceInfo(sourceID)
	if not visualID then return RESULT_NO_DATA end

	-- C_TransmogCollection.GetAllAppearanceSources returns all sources, known and unknown
	-- C_TransmogCollection.GetAppearanceSources only returns known sources
	local sources = C_TransmogCollection.GetAppearanceSources(visualID)
	if not sources then return RESULT_NO_DATA end

	for _, source in next, sources do
		if source.sourceID ~= sourceID and source.isCollected then
			return RESULT_YES
		end
	end
end

local pendingSources = {}

local function TRANSMOG_COLLECTION_SOURCE_ADDED(sourceID)
	local result = isCollectedFromAnotherSource(sourceID)
	if result == RESULT_NO_DATA then
		pendingSources[sourceID] = (pendingSources[sourceID] or 0) + 1
		if pendingSources[sourceID] > 3 then
			pendingSources[sourceID] = nil

			return
		end

		C_Timer.After(0.25, function() TRANSMOG_COLLECTION_SOURCE_ADDED(sourceID) end)
	elseif result ~= RESULT_YES then
		Toast_SetUp("TRANSMOG_COLLECTION_SOURCE_ADDED", sourceID, true, 1)
	end

	pendingSources[sourceID] = nil
end

-- I'm still not sure why this event was added, it always(?) fires alongside TRANSMOG_COLLECTION_SOURCE_ADDED with
-- identical payload, but I'll keep it registered jic
local function TRANSMOG_COSMETIC_COLLECTION_SOURCE_ADDED(sourceID)
	local result = isCollectedFromAnotherSource(sourceID)
	if result == RESULT_NO_DATA then
		pendingSources[sourceID] = (pendingSources[sourceID] or 0) + 1
		if pendingSources[sourceID] > 3 then
			pendingSources[sourceID] = nil

			return
		end

		C_Timer.After(0.25, function() TRANSMOG_COSMETIC_COLLECTION_SOURCE_ADDED(sourceID) end)
	elseif result ~= RESULT_YES then
		Toast_SetUp("TRANSMOG_COSMETIC_COLLECTION_SOURCE_ADDED", sourceID, true, 1)
	end

	pendingSources[sourceID] = nil
end

local function TRANSMOG_COLLECTION_SOURCE_REMOVED(sourceID)
	local result = isCollectedFromAnotherSource(sourceID)
	if result == RESULT_NO_DATA then
		pendingSources[sourceID] = (pendingSources[sourceID] or 0) + 1
		if pendingSources[sourceID] > 3 then
			pendingSources[sourceID] = nil

			return
		end

		C_Timer.After(0.25, function() TRANSMOG_COLLECTION_SOURCE_REMOVED(sourceID) end)
	elseif result ~= RESULT_YES then
		Toast_SetUp("TRANSMOG_COLLECTION_SOURCE_REMOVED", sourceID, nil, 1)
	end

	pendingSources[sourceID] = nil
end

local function Enable()
	if C.db.profile.types.transmog.enabled then
		E:RegisterEvent("TRANSMOG_COLLECTION_SOURCE_ADDED", TRANSMOG_COLLECTION_SOURCE_ADDED)
		E:RegisterEvent("TRANSMOG_COSMETIC_COLLECTION_SOURCE_ADDED", TRANSMOG_COSMETIC_COLLECTION_SOURCE_ADDED)
		E:RegisterEvent("TRANSMOG_COLLECTION_SOURCE_REMOVED", TRANSMOG_COLLECTION_SOURCE_REMOVED)
	end
end

local function Disable()
	E:UnregisterEvent("TRANSMOG_COLLECTION_SOURCE_ADDED", TRANSMOG_COLLECTION_SOURCE_ADDED)
	E:UnregisterEvent("TRANSMOG_COSMETIC_COLLECTION_SOURCE_ADDED", TRANSMOG_COSMETIC_COLLECTION_SOURCE_ADDED)
	E:UnregisterEvent("TRANSMOG_COLLECTION_SOURCE_REMOVED", TRANSMOG_COLLECTION_SOURCE_REMOVED)

	t_wipe(pendingSources)
end

local function Test()
	local appearance = C_TransmogCollection.GetCategoryAppearances(1) and C_TransmogCollection.GetCategoryAppearances(1)[1]
	local source = C_TransmogCollection.GetAppearanceSources(appearance.visualID) and C_TransmogCollection.GetAppearanceSources(appearance.visualID)[1]

	if source then
		Toast_SetUp("TRANSMOG_TEST", source.sourceID, true, 1)
	end
end

E:RegisterOptions("transmog", {
	enabled = true,
	anchor = 1,
	dnd = false,
	sfx = true,
	vfx = true,
	left_click = false,
}, {
	name = L["TYPE_TRANSMOG"],
	get = function(info)
		return C.db.profile.types.transmog[info[#info]]
	end,
	set = function(info, value)
		C.db.profile.types.transmog[info[#info]] = value
	end,
	args = {
		enabled = {
			order = 1,
			type = "toggle",
			name = L["ENABLE"],
			set = function(_, value)
				C.db.profile.types.transmog.enabled = value

				if value then
					Enable()
				else
					Disable()
				end
			end,
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
		vfx = {
			order = 4,
			type = "toggle",
			name = L["VFX"],
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

E:RegisterSystem("transmog", Enable, Disable, Test)
