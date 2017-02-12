-- Contributors: pas06@Curse, Ithilrandir@Curse

local _, addonTable = ...
local L = addonTable.L

-- Lua
local _G = _G

if _G.GetLocale() ~= "deDE" then return end

L["ANCHOR"] = "Anker der Benachrichtigung"
L["ANCHOR_FRAME"] = "Anker Rahmen"
L["APPEARANCE_TITLE"] = "Aussehen"
L["COLORS"] = "Farben"
-- L["COLORS_TOOLTIP"] = "Colours item, follower names by quality, and world quest, mission titles by rarity."
-- L["DND"] = "DND"
-- L["DND_TOOLTIP"] = "Toasts in DND mode won't be displayed in combat, but will be queued up in the system instead. Once you leave combat, they'll start popping up."
L["FADE_OUT_DELAY"] = "Ausblendungsverzögerung"
L["GROWTH_DIR"] = "Ausbreitungsrichtung"
L["GROWTH_DIR_DOWN"] = "Nach unten"
L["GROWTH_DIR_LEFT"] = "Nach links"
L["GROWTH_DIR_RIGHT"] = "Nach rechts"
L["GROWTH_DIR_UP"] = "Nach oben"
-- L["PROFILE"] = "Profile"
-- L["PROFILE_COPY_FROM"] = "Copy from:"
-- L["PROFILE_CREATE_NEW"] = "Create New Profile"
-- L["PROFILE_DELETE_CONFIRM"] = "Are you sure you want to delete |cffffffff%s|r profile?"
-- L["PROFILE_RESET_CONFIRM"] = "Are you sure you want to reset |cffffffff%s|r profile?"
-- L["PROFILES_TITLE"] = "Profiles"
L["SCALE"] = "Skalierung"
-- L["SETTINGS_GENERAL_DESC"] = "Thome thettings, duh...\\nI strongly recommend to |cffe52626/reload|r UI after you're done setting up the addon. Even if you opened and closed this panel without changing anything, |cffe52626/reload|r UI. |cffffd200By doing so, you'll remove this config entry from the system and prevent possible taints.|r"
-- L["SETTINGS_TYPE_DESC"] = "Moar thettings..."
L["SETTINGS_TYPE_LABEL"] = "Benachrichtigungstypen"
L["TEST"] = "Test"
L["TOAST_NUM"] = "Anzahl der Benachrichtigungen"
L["TRANSMOG_ADDED"] = "Vorlage hinzugefügt"
L["TRANSMOG_REMOVED"] = "Vorlage entfernt"
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
L["TYPE_WORLD_QUEST"] = "Weltquest"
