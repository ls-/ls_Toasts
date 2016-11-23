-- Contributors: pas06@Curse

local _, addonTable = ...
local L = addonTable.L

-- Lua
local _G = _G

if _G.GetLocale() ~= "deDE" then return end

-- Toast
L["ANCHOR"] = "Anker der Benachrichtigung"
L["TRANSMOG_ADDED"] = "Vorlage hinzugefügt"
L["TRANSMOG_REMOVED"] = "Vorlage entfernt"

-- Config General
-- L["SETTINGS_GENERAL_DESC"] = "Thome thettings, duh... |cffffd200They are saved per character.|r\\nI strongly recommend to |cffe52626/reload|r UI after you're done setting up the addon. Even if you opened and closed this panel without changing anything, |cffe52626/reload|r UI. |cffffd200By doing so, you'll remove this config entry from the system and prevent possible taints.|r"
-- L["ANCHOR_FRAME"] = "Anchor Frame"
-- L["APPEARANCE_TITLE"] = "Appearance"
-- L["COLOURS"] = "Colour Names"
-- L["COLOURS_TOOLTIP"] = "Colours item, follower names by quality, and world quest, mission titles by rarity."
L["FADE_OUT_DELAY"] = "Ausblendungsverzögerung"
L["GROWTH_DIR"] = "Ausbreitungsrichtung"
L["GROWTH_DIR_DOWN"] = "Nach unten"
L["GROWTH_DIR_LEFT"] = "Nach links"
L["GROWTH_DIR_RIGHT"] = "Nach rechts"
L["GROWTH_DIR_UP"] = "Nach oben"
-- L["PROFILE_DESC"] = "To save current settings as a default preset click the button below. This feature may be quite handy, if you use more or less same layout on many characters. This way you'll need to tweak fewer things. |cffffd200Please note that there can be only 1 preset. Hitting this button on a different character will overwrite existing template.|r"
L["PROFILE_SAVE"] = "Voreinstellung speichern"
L["PROFILE_TITLE"] = "Einstellungsübertragung"
-- L["PROFILE_WIPE"] = "Wipe Preset"
L["SCALE"] = "Skalierung"
L["TOAST_NUM"] = "Anzahl der Benachrichtigungen"

-- Config Type
L["SETTINGS_TYPE_LABEL"] = "Benachrichtigungstypen"
-- L["SETTINGS_TYPE_DESC"] = "Moar thettings..."
-- L["DND"] = "DND"
-- L["DND_TOOLTIP"] = "Toasts in DND mode won't be displayed in combat, but will be queued up in the system instead. Once you leave combat, they'll start popping up."
L["TEST"] = "Test"
L["TYPE"] = "Typ"
L["TYPE_ACHIEVEMENT"] = "Erfolg"
L["TYPE_ARCHAEOLOGY"] = "Archäologie"
L["TYPE_CLASS_HALL"] = "Klassenhalle"
L["TYPE_DUNGEON"] = "Dungeon"
L["TYPE_GARRISON"] = "Garnison"
L["TYPE_LOOT_COMMON"] = "Beute (Gewöhnlich)"
L["TYPE_LOOT_COMMON_TOOLTIP"] = "Benachrichtigungen, die von Chatereignissen ausgelöst werden wie grüne, blaue Gegenstände, manche epischen Gegenstände, alles was nicht von der Benachrichtigung für besondere Beute abgedeckt wird."
L["TYPE_LOOT_CURRENCY"] = "Beute (Abzeichen)"
L["TYPE_LOOT_SPECIAL"] = "Beute (Spezial)"
L["TYPE_LOOT_SPECIAL_TOOLTIP"] = "Benachrichtigung, die von besonderen Beuteereignissen wie gewonnene Würfe, legendäre Gegenstände, persönliche Beute etc.."
L["TYPE_RECIPE"] = "Rezept"
L["TYPE_TRANSMOG"] = "Transmogrifikation"
L["TYPE_WORLD QUEST"] = "Weltquest"
