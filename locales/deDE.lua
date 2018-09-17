-- Contributors: pas06@Curse, Ithilrandir@Curse, staratnight@Curse

local _, addonTable = ...
local L = addonTable.L

-- Lua
local _G = getfenv(0)

if GetLocale() ~= "deDE" then return end

L["ANCHOR"] = "Anker der Benachrichtigung"
L["ANCHOR_FRAME"] = "Ankerrahmen"
--[[ L["ANCHOR_RESET_DESC"] = "|cffffffffShift-Click|r to reset the position." ]]
L["BORDER"] = "Rahmen"
L["COLLECTIONS_TAINT_WARNING"] = "Diese Option kann Probleme verursachen, wenn das Sammlungsfenster während des Kampfes geöffnet wird."
L["COLORS"] = "Farben"
L["COORDS"] = "Koordinaten"
L["COPPER_THRESHOLD"] = "Kupferschwelle"
L["COPPER_THRESHOLD_DESC"] = "Minimale Anzahl Kupfer. Ab dieser Anzahl wird eine Benachrichtigung erstellt."
L["DND"] = "DND"
L["DND_TOOLTIP"] = "Benachrichtigungen im DND-Modus werden nicht im Kampf angezeigt, sie werden jedoch in einer Warteschlange gesammelt. Sobald du den Kampf verlässt, werden sie auftauchen."
L["FADE_OUT_DELAY"] = "Ausblendungsverzögerung"
L["FONTS"] = "Schriften"
L["GROWTH_DIR"] = "Ausbreitungsrichtung"
L["GROWTH_DIR_DOWN"] = "Nach unten"
L["GROWTH_DIR_LEFT"] = "Nach links"
L["GROWTH_DIR_RIGHT"] = "Nach rechts"
L["GROWTH_DIR_UP"] = "Nach oben"
L["HANDLE_LEFT_CLICK"] = "Linksklick behandeln"
L["ICON_BORDER"] = "Symbolrahmen"
L["NAME"] = "Name"
L["OPEN_CONFIG"] = "Konfiguration öffnen"
L["RARITY_THRESHOLD"] = "Schwellenwert der Seltenheit"
L["SCALE"] = "Skalierung"
L["SETTINGS_TYPE_LABEL"] = "Benachrichtigungstypen"
L["SHOW_ILVL"] = "GS anzeigen"
L["SHOW_ILVL_DESC"] = "Zeigt die Gegenstandsstufe neben dem Gegenstandsnamen."
L["SHOW_QUEST_ITEMS"] = "Questgegenstände zeigen"
L["SHOW_QUEST_ITEMS_DESC"] = "Zeigt alle Questgegenstände, ungeachtet deren Qualität."
L["SIZE"] = "Größe"
L["SKIN"] = "Oberfläche"
L["STRATA"] = "Ebene"
L["TEST"] = "Test"
L["TEST_ALL"] = "Alle testen"
L["TOAST_NUM"] = "Anzahl der Benachrichtigungen"
L["TRANSMOG_ADDED"] = "Vorlage hinzugefügt"
L["TRANSMOG_REMOVED"] = "Vorlage entfernt"
L["TYPE_ACHIEVEMENT"] = "Erfolg"
L["TYPE_ARCHAEOLOGY"] = "Archäologie"
L["TYPE_CLASS_HALL"] = "Klassenhalle"
L["TYPE_COLLECTION"] = "Sammlung"
L["TYPE_COLLECTION_DESC"] = "Benachrichtigungen für erhaltene Reittiere, Haustiere und Spielzeuge."
L["TYPE_DUNGEON"] = "Dungeon"
L["TYPE_GARRISON"] = "Garnison"
L["TYPE_LOOT_COMMON"] = "Beute (Gewöhnlich)"
L["TYPE_LOOT_COMMON_DESC"] = "Benachrichtigungen, die von Chatereignissen ausgelöst werden wie grüne, blaue Gegenstände, manche epischen Gegenstände, alles was nicht von der Benachrichtigung für besondere Beute abgedeckt wird."
L["TYPE_LOOT_CURRENCY"] = "Beute (Abzeichen)"
L["TYPE_LOOT_GOLD"] = "Beute (Gold)"
L["TYPE_LOOT_SPECIAL"] = "Beute (Spezial)"
L["TYPE_LOOT_SPECIAL_DESC"] = "Benachrichtigungen, die von besonderen Beuteereignissen wie gewonnene Würfe, legendäre Gegenstände, persönliche Beute etc. ausgelöst werden."
L["TYPE_RECIPE"] = "Rezept"
L["TYPE_TRANSMOG"] = "Transmogrifikation"
--[[ L["TYPE_WAR_EFFORT"] = "War Effort" ]]
L["TYPE_WORLD_QUEST"] = "Weltquest"
