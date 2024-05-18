std = "none"
max_line_length = false
max_comment_line_length = 120
self = false

exclude_files = {
	".luacheckrc",
	"ls_Toasts/embeds/",
}

ignore = {
	"111/LS.*", -- Setting an undefined global variable starting with LS
	"111/SLASH_.*", -- Setting an undefined global variable starting with SLASH_
	"112/LS.*", -- Mutating an undefined global variable starting with LS
	"112/ls_Toasts", -- Mutating an undefined global variable ls_Toasts
	"113/LS.*", -- Accessing an undefined global variable starting with LS
	"113/ls_Toasts", -- Accessing an undefined global variable ls_Toasts
	"122", -- Setting a read-only field of a global variable
	"211/_G", -- Unused local variable _G
	"211/C",  -- Unused local variable C
	"211/D",  -- Unused local variable D
	"211/E",  -- Unused local variable E
	"211/L",  -- Unused local variable L
	"211/P",  -- Unused local variable P
	"432", -- Shadowing an upvalue argument
}

globals = {
	-- Lua
	"getfenv",
	"print",

	-- FrameXML
	"SlashCmdList",
}

read_globals = {
	"AchievementFrame",
	"AchievementFrame_LoadUI",
	"AchievementFrame_SelectAchievement",
	"AlertFrame",
	"C_AddOns",
	"C_Container",
	"C_CurrencyInfo",
	"C_Item",
	"C_MountJournal",
	"C_PetJournal",
	"C_Timer",
	"C_ToyBox",
	"C_TransmogCollection",
	"COLLECTIONS_JOURNAL_TAB_INDEX_APPEARANCES",
	"COLLECTIONS_JOURNAL_TAB_INDEX_MOUNTS",
	"COLLECTIONS_JOURNAL_TAB_INDEX_PETS",
	"COLLECTIONS_JOURNAL_TAB_INDEX_TOYS",
	"CollectionsJournal",
	"CollectionsJournal_LoadUI",
	"CreateFrame",
	"DressUpItemLink",
	"DressUpVisual",
	"Enum",
	"FormatLargeNumber",
	"FormatShortDate",
	"GameTooltip",
	"GameTooltip_ShowCompareItem",
	"GetAchievementInfo",
	"GetArchaeologyRaceInfoByID",
	"GetCurrencyListInfo",
	"GetCurrencyListSize",
	"GetCVarBool",
	"GetLocale",
	"GetMoney",
	"GetMoneyString",
	"HideUIPanel",
	"InCombatLockdown",
	"INVSLOT_BACK",
	"INVSLOT_CHEST",
	"INVSLOT_FEET",
	"INVSLOT_FINGER1",
	"INVSLOT_FINGER2",
	"INVSLOT_HAND",
	"INVSLOT_HEAD",
	"INVSLOT_LEGS",
	"INVSLOT_MAINHAND",
	"INVSLOT_NECK",
	"INVSLOT_OFFHAND",
	"INVSLOT_RANGED",
	"INVSLOT_SHOULDER",
	"INVSLOT_TRINKET1",
	"INVSLOT_TRINKET2",
	"INVSLOT_WAIST",
	"INVSLOT_WRIST",
	"IsLoggedIn",
	"IsModifiedClick",
	"IsShiftKeyDown",
	"ITEM_QUALITY_COLORS",
	"ITEM_QUALITY0_DESC",
	"ITEM_QUALITY1_DESC",
	"ITEM_QUALITY2_DESC",
	"ITEM_QUALITY3_DESC",
	"ITEM_QUALITY4_DESC",
	"ITEM_QUALITY5_DESC",
	"LibStub",
	"LOOT_ITEM_CREATED_SELF",
	"LOOT_ITEM_CREATED_SELF_MULTIPLE",
	"LOOT_ITEM_PUSHED_SELF",
	"LOOT_ITEM_PUSHED_SELF_MULTIPLE",
	"LOOT_ITEM_SELF",
	"LOOT_ITEM_SELF_MULTIPLE",
	"MountJournal_SelectByMountID",
	"NUM_BAG_SLOTS",
	"OpenBag",
	"PetJournal",
	"PetJournal_SelectPet",
	"PlaySound",
	"PlaySoundFile",
	"SearchBagsForItem",
	"SetCollectionsJournalShown",
	"Settings",
	"SettingsPanel",
	"ShoppingTooltip1",
	"ShoppingTooltip2",
	"ShowUIPanel",
	"SquareButton_SetIcon",
	"ToyBox",
	"ToyBox_FindPageForToyID",
	"UIParent",
	"UnitGUID",
	"UnitName",
	"WardrobeCollectionFrame",
}
