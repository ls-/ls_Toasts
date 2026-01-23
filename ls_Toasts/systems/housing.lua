local _, addon = ...
local E, L, C = addon.E, addon.L, addon.C

-- Lua
local _G = getfenv(0)

-- Mine
local function TaskToast_SetUp(event, taskName)
	local toast = E:GetToast()

	toast.Title:SetText(L["HOUSING_ENDEAVOR_COMPLETED"])
	toast.Text:SetText(taskName)
	toast.Icon:SetTexture("Interface\\ICONS\\UI_Homestone-64")
	toast.IconBorder:Show()

	toast._data.event = event
	toast._data.sound_file = C.db.profile.types.housing.sfx and 333048 -- SOUNDKIT.HOUSING_ENDEAVORS_TASK_COMPLETE_TOAST
	toast._data.vfx = C.db.profile.types.housing.vfx

	toast:Spawn(C.db.profile.types.housing.anchor, C.db.profile.types.housing.dnd)
end

local function INITIATIVE_TASK_COMPLETED(...)
	TaskToast_SetUp("INITIATIVE_TASK_COMPLETED", ...)
end

local houseItemTitles = {
	[Enum.HousingItemToastType.Decor] = L["HOUSING_DECOR"],
	[Enum.HousingItemToastType.Customization] = L["HOUSING_CUSTOMIZATION"],
	[Enum.HousingItemToastType.Fixture] = L["HOUSING_FIXTURE"],
	[Enum.HousingItemToastType.Room] = L["HOUSING_ROOM"],
};

local houseItemIcons = {
	[Enum.HousingItemToastType.Customization] = "Interface\\Housing\\INV_12PH_GenericCustomization",
	[Enum.HousingItemToastType.Fixture] = "Interface\\Housing\\INV_12PH_GenericFixture",
	[Enum.HousingItemToastType.Room] = "Interface\\Housing\\INV_12PH_GenericRoom",
}

local function ItemToast_SetUp(event, itemType, itemName, itemIcon)
	local toast = E:GetToast()

	toast.Title:SetText(houseItemTitles[itemType])
	toast.Text:SetText(itemName)
	toast.Icon:SetTexture(itemIcon or houseItemIcons[itemType])
	toast.IconBorder:Show()

	toast._data.event = event
	toast._data.sound_file = C.db.profile.types.housing.sfx and 317872 -- SOUNDKIT.HOUSING_ITEM_ACQUIRED
	toast._data.vfx = C.db.profile.types.housing.vfx

	toast:Spawn(C.db.profile.types.housing.anchor, C.db.profile.types.housing.dnd)
end

local function NEW_HOUSING_ITEM_ACQUIRED(...)
	ItemToast_SetUp("NEW_HOUSING_ITEM_ACQUIRED", ...)
end

local function Enable()
	if C.db.profile.types.housing.enabled then
		E:RegisterEvent("INITIATIVE_TASK_COMPLETED", INITIATIVE_TASK_COMPLETED)
		E:RegisterEvent("NEW_HOUSING_ITEM_ACQUIRED", NEW_HOUSING_ITEM_ACQUIRED)
	end
end

local function Disable()
	E:UnregisterEvent("INITIATIVE_TASK_COMPLETED", INITIATIVE_TASK_COMPLETED)
	E:UnregisterEvent("NEW_HOUSING_ITEM_ACQUIRED", NEW_HOUSING_ITEM_ACQUIRED)
end

local function Test()
	-- Decor, Voidspire Vanquisher's Trophy
	local info = C_HousingCatalog.GetCatalogEntryInfoByRecordID(Enum.HousingCatalogEntryType.Decor, 17630, false)
	if info then
		ItemToast_SetUp("HOUSING_ITEM_TEST", Enum.HousingItemToastType.Decor, info.name, info.iconTexture)
	end

	-- Room
	ItemToast_SetUp("HOUSING_ITEM_TEST", Enum.HousingItemToastType.Room, "Test Room")

	-- Fixture
	ItemToast_SetUp("HOUSING_ITEM_TEST", Enum.HousingItemToastType.Fixture, "Test Fixture")

	-- Customisation
	ItemToast_SetUp("HOUSING_ITEM_TEST", Enum.HousingItemToastType.Customization, "Test Customization")

	-- Endeavor
	TaskToast_SetUp("HOUSING_TASK_TEST", "Test Endeavor")
end

E:RegisterOptions("housing", {
	enabled = true,
	anchor = 1,
	dnd = false,
	sfx = true,
	vfx = true,
}, {
	name = L["TYPE_HOUSING"],
	get = function(info)
		return C.db.profile.types.housing[info[#info]]
	end,
	set = function(info, value)
		C.db.profile.types.housing[info[#info]] = value
	end,
	args = {
		enabled = {
			order = 1,
			type = "toggle",
			name = L["ENABLE"],
			set = function(_, value)
				C.db.profile.types.housing.enabled = value

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
		test = {
			type = "execute",
			order = 99,
			width = "full",
			name = L["TEST"],
			func = Test,
		},
	},
})

E:RegisterSystem("housing", Enable, Disable, Test)
