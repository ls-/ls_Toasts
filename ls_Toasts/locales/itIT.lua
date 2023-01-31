-- Contributors: vabatta@GitHub

local _, addonTable = ...
local L = addonTable.L

-- Lua
local _G = getfenv(0)

if GetLocale() ~= "itIT" then return end

L["ANCHOR_RESET_DESC"] = "|cffffffffSHIFT-Clicca|r per reimpostare la posizione."
L["BORDER"] = "Bordo"
L["COLORS"] = "Colori"
L["COORDS"] = "Coordinate"
L["COPPER_THRESHOLD"] = "Soglia rame"
L["COPPER_THRESHOLD_DESC"] = "Minimo ammontare di rame per creare un toast."
L["DEFAULT_VALUE"] = "Valore predefinito: |cffffd200%s|r"
L["DND"] = "ND"
L["DND_TOOLTIP"] = "I toast in modalità ND non verranno mostrati in combattimento, ma verranno messi in coda nel sistema. Una volta uscito dal combattimento, verranno mostrate."
L["FADE_OUT_DELAY"] = "Ritardo dissolvenza in uscita"
L["FLUSH_QUEUE"] = "Azzera coda"
L["GROWTH_DIR"] = "Direzione crescita"
L["GROWTH_DIR_DOWN"] = "Giù"
L["GROWTH_DIR_LEFT"] = "Sinistra"
L["GROWTH_DIR_RIGHT"] = "Destra"
L["GROWTH_DIR_UP"] = "Su"
L["ICON_BORDER"] = "Bordo icone"
L["NAME"] = "Nome"
L["RARITY_THRESHOLD"] = "Soglia rarità"
L["SCALE"] = "Scala"
L["SHOW_ILVL"] = "Mostra iLvl"
L["SHOW_ILVL_DESC"] = "Mostra livello oggetto vicino al suo nome."
L["SHOW_QUEST_ITEMS"] = "Mostra oggetti missioni"
L["SHOW_QUEST_ITEMS_DESC"] = "Mostra oggetti missioni indipendentemente dalla qualità."
L["SIZE"] = "Dimensione"
L["TEST"] = "Prova"
L["TEST_ALL"] = "Prova tutte"
L["TOAST_NUM"] = "Numero di toast"
L["TOAST_TYPES"] = "Tipi toast"
L["TOGGLE_ANCHORS"] = "Attiva / Disattiva Anchors"
L["TRACK_LOSS"] = "Ignora soglia"
L["TRACK_LOSS_DESC"] = "Con questa opzione ignori la soglia di rame."
L["TYPE_LOOT_GOLD"] = "Bottino (Oro)"
L["YOU_LOST"] = "Hai perso"
L["YOU_RECEIVED"] = "Hai ricevuto"

-- WotLK
L["CURRENCY_THRESHOLD_DESC"] = "Inserisci |cffffd200-1|r per ignorare la valuta, |cffffd2000|r per disabilitare il filtro, o |cffffd200un qualsiasi numero sopra 0|r per impostare una soglia sotto la quale i toast non verranno creati."
L["FILTERS"] = "Filtri"
L["NEW_CURRENCY_FILTER_DESC"] = "Inserici l'ID della valuta."
L["THRESHOLD"] = "Soglia"
L["TYPE_ACHIEVEMENT"] = "Imprese"
L["TYPE_LOOT_CURRENCY"] = "Bottino (Valute)"
