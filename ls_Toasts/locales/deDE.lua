-- Contributors: Bullseiify@Curse, Merathilis@Curse, staratnight@Curse

local _, addonTable = ...
local L = addonTable.L

-- Lua
local _G = getfenv(0)

if GetLocale() ~= "deDE" then return end

L["ANCHOR_FRAME_#"] = "Ankerrahmen #%d"
L["ANCHOR_FRAMES"] = "Ankerrahmen"
L["ANCHOR_RESET_DESC"] = "|cffffffffShift-Klick|r um die Position zurückzusetzen."
L["BORDER"] = "Rahmen"
L["COLORS"] = "Farben"
L["COORDS"] = "Koordinaten"
L["COPPER_THRESHOLD"] = "Kupferschwelle"
L["COPPER_THRESHOLD_DESC"] = "Minimale Anzahl Kupfer. Ab dieser Anzahl wird eine Benachrichtigung erstellt."
L["DEFAULT_VALUE"] = "Standartwert: |cffffd200%s|r"
L["DND"] = "DND"
L["DND_TOOLTIP"] = "Benachrichtigungen im DND-Modus werden nicht im Kampf angezeigt, sie werden jedoch in einer Warteschlange gesammelt. Sobald du den Kampf verlässt, werden sie auftauchen."
L["FADE_OUT_DELAY"] = "Ausblendungsverzögerung"
L["FLUSH_QUEUE"] = "Warteschlange"
L["FONTS"] = "Schriften"
L["GROWTH_DIR"] = "Ausbreitungsrichtung"
L["GROWTH_DIR_DOWN"] = "Nach unten"
L["GROWTH_DIR_LEFT"] = "Nach links"
L["GROWTH_DIR_RIGHT"] = "Nach rechts"
L["GROWTH_DIR_UP"] = "Nach oben"
L["ICON_BORDER"] = "Symbolrahmen"
L["NAME"] = "Name"
L["RARITY_THRESHOLD"] = "Schwellenwert der Seltenheit"
L["SCALE"] = "Skalierung"
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
L["TOAST_TYPES"] = "Benachrichtigungstypen"
L["TOGGLE_ANCHORS"] = "Ankerpunkte umschalten"
L["TRACK_LOSS"] = "Verlust Verfolgung"
L["TRACK_LOSS_DESC"] = "Diese Option ignoriert die Kupferschwelle."
L["TYPE_LOOT_GOLD"] = "Beute (Gold)"
L["X_OFFSET"] = "X-Versatz"
L["Y_OFFSET"] = "Y-Versatz"
L["YOU_LOST"] = "Ihr verliert"
L["YOU_RECEIVED"] = "Ihr erhaltet"

-- Classic
L["TYPE_LOOT_ITEMS"] = "Beute (Gegenstände)"

-- WotLK
L["TYPE_ACHIEVEMENT"] = "Erfolg"
L["TYPE_LOOT_CURRENCY"] = "Beute (Abzeichen)"
