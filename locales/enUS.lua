local _, addonTable = ...

-- Lua
local _G = _G

-- Mine
local L = {}

-- Toast
L["ANCHOR"] = "Toast Anchor"
L["TRANSMOG_ADDED"] = "Appearance Added"
L["TRANSMOG_REMOVED"] = "Appearance Removed"

-- Config General
L["SETTINGS_GENERAL_LABEL"] = _G.GENERAL_LABEL
L["SETTINGS_GENERAL_DESC"] = "Thome thettings, duh... |cffffd200They are saved per character.|r\nI strongly recommend to |cffe52626/reload|r UI after you're done setting up the addon. Even if you opened and closed this panel without changing anything, |cffe52626/reload|r UI. |cffffd200By doing so, you'll remove this config entry from the system and prevent possible taints.|r"

L["ANCHOR_FRAME"] = "Anchor Frame"
L["APPEARANCE_TITLE"] = "Appearance"
L["COLOURS"] = "Colour Names"
L["COLOURS_TOOLTIP"] = "Colours item, follower names by quality, and world quest, mission titles by rarity."
L["ENABLE_SOUND"] = _G.ENABLE_SOUND
L["FADE_OUT_DELAY"] = "Fade Out Delay"
L["GROWTH_DIR"] = "Growth Direction"
L["GROWTH_DIR_DOWN"] = "Down"
L["GROWTH_DIR_LEFT"] = "Left"
L["GROWTH_DIR_RIGHT"] = "Right"
L["GROWTH_DIR_UP"] = "Up"
L["PROFILE_DESC"] = "To save current settings as a default preset click the button below. This feature may be quite handy, if you use more or less same layout on many characters. This way you'll need to tweak fewer things. |cffffd200Please note that there can be only 1 preset. Hitting this button on a different character will overwrite existing template.|r"
L["PROFILE_SAVE"] = "Save Preset"
L["PROFILE_TITLE"] = "Settings Transfer"
L["PROFILE_WIPE"] = "Wipe Preset"
L["SCALE"] = "Scale"
L["TOAST_NUM"] = "Number of Toasts"

-- Config Type
L["SETTINGS_TYPE_LABEL"] = "Toast Types"
L["SETTINGS_TYPE_DESC"] = "Moar thettings..."
L["DND"] = "DND"
L["DND_TOOLTIP"] = "Toasts in DND mode won't be displayed in combat, but will be queued up in the system instead. Once you leave combat, they'll start popping up."
L["ENABLE"] = _G.ENABLE
L["TEST"] = "Test"
L["TYPE"] = "Type"
L["TYPE_ACHIEVEMENT"] = "Achievement"
L["TYPE_ARCHAEOLOGY"] = "Archaeology"
L["TYPE_CLASS_HALL"] = "Class Hall"
L["TYPE_DUNGEON"] = "Dungeon"
L["TYPE_GARRISON"] = "Garrison"
L["TYPE_LOOT_COMMON"] = "Loot (Common)"
L["TYPE_LOOT_COMMON_TOOLTIP"] = "Toasts triggered by chat events, e.g. greens, blues, some epics, everything that isn't handled by special loot toasts."
L["TYPE_LOOT_CURRENCY"] = "Loot (Currency)"
L["TYPE_LOOT_SPECIAL"] = "Loot (Special)"
L["TYPE_LOOT_SPECIAL_TOOLTIP"] = "Toasts triggered by special loot events, e.g. won rolls, legendary drops, personal loot, etc."
L["TYPE_RECIPE"] = "Recipe"
L["TYPE_TRANSMOG"] = "Transmogrification"
L["TYPE_WORLD QUEST"] = "World Quest"

addonTable.L = L
