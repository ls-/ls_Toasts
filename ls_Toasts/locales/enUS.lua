-- Contributors:

local _, addonTable = ...

-- Lua
local _G = getfenv(0)

-- Mine
local L = {}
addonTable.L = L

L["LS_TOASTS"] = "LS: |cff00cc99Toasts|r"
L["CURSEFORGE"] = "CurseForge"
L["DISCORD"] = "Discord"
L["GITHUB"] = "GitHub"
L["WAGO"] = "Wago"
L["WOWINTERFACE"] = "WoWInterface"

L["ACHIEVEMENT_UNLOCKED"] = _G.ACHIEVEMENT_UNLOCKED
L["ADD"] = _G.ADD
L["DELETE"] = _G.DELETE
L["ENABLE"] = _G.ENABLE
L["GENERAL"] = _G.GENERAL_LABEL
L["GUILD_ACHIEVEMENT_UNLOCKED"] = _G.GUILD_ACHIEVEMENT_UNLOCKED
L["ID"] = _G.ID
L["ITEM_LEGENDARY"] = _G.LEGENDARY_ITEM_LOOT_LABEL
L["LOOT_THRESHOLD"] = _G.LOOT_THRESHOLD
L["NEW"] = _G.NEW
L["OKAY"] = _G.OKAY
L["PETS"] = _G.PETS
L["QUEST_ITEMS"] = _G.AUCTION_CATEGORY_QUEST_ITEMS
L["RELOADUI"] = _G.RELOADUI
L["RESET"] = _G.RESET
L["SFX"] = _G.ENABLE_SOUNDFX

-- Require translation
L["ANCHOR_FRAME_#"] = "Anchor Frame #%d"
L["ANCHOR_FRAMES"] = "Anchor Frames"
L["ANCHOR_RESET_DESC"] = "|cffffffffShift-Click|r to reset the position."
L["BORDER"] = "Border"
L["CHANGELOG"] = "Changelog"
L["CHANGELOG_FULL"] = "Full"
L["COLORS"] = "Colours"
L["COORDS"] = "Coordinates"
L["COPPER_THRESHOLD"] = "Copper Threshold"
L["COPPER_THRESHOLD_DESC"] = "Min amount of copper to create a toast for."
L["DEFAULT_VALUE"] = "Default value: |cffffd200%s|r"
L["DND"] = "DND"
L["DND_TOOLTIP"] = "Toasts in DND mode won't be displayed in combat, but will be queued up in the system. Once you leave combat, they'll start popping up."
L["DOWNLOADS"] = "Downloads"
L["FADE_OUT_DELAY"] = "Fade Out Delay"
L["FILTERS"] = "Filters"
L["FLUSH_QUEUE"] = "Flush Queue"
L["FONTS"] = "Fonts"
L["GROWTH_DIR"] = "Growth Direction"
L["GROWTH_DIR_DOWN"] = "Down"
L["GROWTH_DIR_LEFT"] = "Left"
L["GROWTH_DIR_RIGHT"] = "Right"
L["GROWTH_DIR_UP"] = "Up"
L["ICON_BORDER"] = "Icon Border"
L["INFORMATION"] = "Info"
L["NAME"] = "Name"
L["OPEN_CONFIG"] = "Open Config"
L["RARITY_THRESHOLD"] = "Rarity Threshold"
L["SCALE"] = "Scale"
L["SHOW_ILVL"] = "Show iLvl"
L["SHOW_ILVL_DESC"] = "Show item level next to item name."
L["SIZE"] = "Size"
L["SKIN"] = "Skin"
L["STRATA"] = "Strata"
L["SUPPORT"] = "Support"
L["TEST"] = "Test"
L["TEST_ALL"] = "Test All"
L["TOAST_NUM"] = "Number of Toasts"
L["TOAST_TYPES"] = "Toast Types"
L["TOGGLE_ANCHORS"] = "Toggle Anchors"
L["TRACK_LOSS"] = "Track Loss"
L["TRACK_LOSS_DESC"] = "This option ignores set copper threshold."
L["TYPE_LOOT_GOLD"] = "Loot (Gold)"
L["X_OFFSET"] = "xOffset"
L["Y_OFFSET"] = "yOffset"
L["YOU_LOST"] = "You Lost"
L["YOU_RECEIVED"] = "You Received"

-- Classic
L["ITEM_FILTERS_DESC"] = "These items ignore the loot quality threshold."
L["NEW_ITEM_FILTER_DESC"] = "Enter an item ID."
L["TYPE_LOOT_ITEMS"] = "Loot (Items)"

-- WotLK
L["CURRENCY_THRESHOLD_DESC"] = "Enter |cffffd200-1|r to ignore the currency, |cffffd2000|r to disable the filter, or |cffffd200any number above 0|r to set the threshold below which no toasts will be created."
L["NEW_CURRENCY_FILTER_DESC"] = "Enter a currency ID."
L["THRESHOLD"] = "Threshold"
L["TYPE_ACHIEVEMENT"] = "Achievement"
L["TYPE_LOOT_CURRENCY"] = "Loot (Currency)"
