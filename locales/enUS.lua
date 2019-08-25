-- Contributors:

local _, addonTable = ...

-- Lua
local _G = getfenv(0)

-- Mine
local L = {}
addonTable.L = L

L["ADD"] = _G.ADD
L["DELETE"] = _G.DELETE
L["ENABLE"] = _G.ENABLE
L["GENERAL"] = _G.GENERAL_LABEL
L["ITEM_LEGENDARY"] = _G.LEGENDARY_ITEM_LOOT_LABEL
L["LOOT_THRESHOLD"] = _G.LOOT_THRESHOLD
L["LS_TOASTS"] = "ls: |cff1a9fc0Toasts|r"
L["OKAY"] = _G.OKAY
L["RELOADUI"] = _G.RELOADUI
L["RESET"] = _G.RESET
L["SFX"] = _G.ENABLE_SOUNDFX

-- Require translation
L["ANCHOR_FRAME_#"] = "Anchor Frame #%d"
L["ANCHOR_FRAMES"] = "Anchor Frames"
L["ANCHOR_RESET_DESC"] = "|cffffffffShift-Click|r to reset the position."
L["BORDER"] = "Border"
L["COLORS"] = "Colours"
L["COORDS"] = "Coordinates"
L["COPPER_THRESHOLD"] = "Copper Threshold"
L["COPPER_THRESHOLD_DESC"] = "Min amount of copper to create a toast for."
L["DEFAULT_VALUE"] = "Default value: |cffffd200%s|r"
L["DND"] = "DND"
L["DND_TOOLTIP"] = "Toasts in DND mode won't be displayed in combat, but will be queued up in the system. Once you leave combat, they'll start popping up."
L["FADE_OUT_DELAY"] = "Fade Out Delay"
L["FLUSH_QUEUE"] = "Flush Queue"
L["FONTS"] = "Fonts"
L["GROWTH_DIR"] = "Growth Direction"
L["GROWTH_DIR_DOWN"] = "Down"
L["GROWTH_DIR_LEFT"] = "Left"
L["GROWTH_DIR_RIGHT"] = "Right"
L["GROWTH_DIR_UP"] = "Up"
L["ICON_BORDER"] = "Icon Border"
L["NAME"] = "Name"
L["RARITY_THRESHOLD"] = "Rarity Threshold"
L["SCALE"] = "Scale"
L["SHOW_ILVL"] = "Show iLvl"
L["SHOW_ILVL_DESC"] = "Show item level next to item name."
L["SHOW_QUEST_ITEMS"] = "Show Quest Items"
L["SHOW_QUEST_ITEMS_DESC"] = "Show quest items regardless of their quality."
L["SIZE"] = "Size"
L["SKIN"] = "Skin"
L["STRATA"] = "Strata"
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
L["TYPE_LOOT_ITEMS"] = "Loot (Items)"
