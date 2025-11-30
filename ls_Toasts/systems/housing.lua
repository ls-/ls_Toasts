local _, addonTable = ...
local E, L, C = addonTable.E, addonTable.L, addonTable.C

-- Lua
local _G = getfenv(0)

-- Mine
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

local function Toast_SetUp(event, itemType, itemName, itemIcon)
	local toast = E:GetToast()

	toast.Title:SetText(houseItemTitles[itemType])
	toast.Text:SetText(itemName)
	toast.Icon:SetTexture(itemIcon or houseItemIcons[itemType])
	toast.IconBorder:Show()

	toast._data.event = event
	toast._data.sound_file = C.db.profile.types.housing.sfx and 317872 -- SOUNDKIT.HOUSING_ITEM_ACQUIRED

	toast:Spawn(C.db.profile.types.housing.anchor, C.db.profile.types.housing.dnd)
end

local function NEW_HOUSING_ITEM_ACQUIRED(...)
	Toast_SetUp("NEW_HOUSING_ITEM_ACQUIRED", ...)
end

local function Enable()
	if C.db.profile.types.housing.enabled then
		E:RegisterEvent("NEW_HOUSING_ITEM_ACQUIRED", NEW_HOUSING_ITEM_ACQUIRED)
	end
end

local function Disable()
	E:UnregisterEvent("NEW_HOUSING_ITEM_ACQUIRED", NEW_HOUSING_ITEM_ACQUIRED)
end

local function Test()
	-- Decor, Voidspire Vanquisher's Trophy
	local info = C_HousingCatalog.GetCatalogEntryInfoByRecordID(Enum.HousingCatalogEntryType.Decor, 17630, false)
	if info then
		Toast_SetUp("HOUSING_TEST", Enum.HousingItemToastType.Decor, info.name, info.iconTexture)
	end

	-- Room
	Toast_SetUp("HOUSING_TEST", Enum.HousingItemToastType.Room, "Test Room")

	-- Fixture
	Toast_SetUp("HOUSING_TEST", Enum.HousingItemToastType.Fixture, "Test Fixture")

	-- Customisation
	Toast_SetUp("HOUSING_TEST", Enum.HousingItemToastType.Customization, "Test Customization")
end

E:RegisterOptions("housing", {
	enabled = true,
	anchor = 1,
	dnd = false,
	sfx = true,
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
			desc = L["DND_TOOLTIP"],
		},
		sfx = {
			order = 3,
			type = "toggle",
			name = L["SFX"],
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
