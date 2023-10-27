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
	"C_Container",
	"C_CurrencyInfo",
	"C_Timer",
	"CreateFrame",
	"DressUpItemLink",
	"FormatLargeNumber",
	"FormatShortDate",
	"GameTooltip",
	"GameTooltip_ShowCompareItem",
	"GetAchievementInfo",
	"GetAddOnMetadata",
	"GetCurrencyListInfo",
	"GetCurrencyListSize",
	"GetCVarBool",
	"GetDetailedItemLevelInfo",
	"GetItemInfo",
	"GetItemInfoInstant",
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
	"NUM_BAG_SLOTS",
	"OpenBag",
	"PlaySound",
	"PlaySoundFile",
	"Settings",
	"SettingsPanel",
	"ShoppingTooltip1",
	"ShoppingTooltip2",
	"ShowUIPanel",
	"SquareButton_SetIcon",
	"UIParent",
	"UnitGUID",
	"UnitName",
}
