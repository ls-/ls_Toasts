﻿-- Contributors:

local _, addonTable = ...
local L = addonTable.L

-- Lua
local _G = getfenv(0)

if GetLocale() ~= "esMX" then return end

L["ANCHOR"] = "Marco Toast"
L["ANCHOR_FRAME"] = "Marco de anclaje"
-- L["BORDER"] = "Border"
-- L["COLLECTIONS_TAINT_WARNING"] = "Enabling this option may cause errors when opening \"Collections\" panel in combat."
-- L["COLORS"] = "Colours"
-- L["COORDS"] = "Coordinates"
-- L["COPPER_THRESHOLD"] = "Copper Threshold"
-- L["COPPER_THRESHOLD_DESC"] = "Min amount of copper to create a toast for."
L["DND"] = "DND"
L["DND_TOOLTIP"] = "Toasts en modo DND no se mostrarán en combate, pero se pondrán a la cola del sistema. Una vez salgas de combate, aparecerán."
L["FADE_OUT_DELAY"] = "Retraso de desvanecimiento"
-- L["FONTS"] = "Fonts"
L["GROWTH_DIR"] = "Dirección de aparición"
L["GROWTH_DIR_DOWN"] = "Abajo"
L["GROWTH_DIR_LEFT"] = "Izquierda"
L["GROWTH_DIR_RIGHT"] = "Derecha"
L["GROWTH_DIR_UP"] = "Arriba"
-- L["HANDLE_LEFT_CLICK"] = "Handle Left Click"
-- L["ICON_BORDER"] = "Icon Border"
-- L["NAME"] = "Name"
-- L["OPEN_CONFIG"] = "Open Config"
-- L["RARITY_THRESHOLD"] = "Rarity Threshold"
L["SCALE"] = "Escala"
L["SETTINGS_TYPE_LABEL"] = "Tipos de Toasts"
-- L["SHOW_ILVL"] = "Show iLvl"
-- L["SHOW_ILVL_DESC"] = "Show item level next to item name."
-- L["SHOW_QUEST_ITEMS"] = "Show Quest Items"
-- L["SHOW_QUEST_ITEMS_DESC"] = "Show quest items regardless of their quality."
-- L["SIZE"] = "Size"
-- L["SKIN"] = "Skin"
-- L["STRATA"] = "Strata"
L["TEST"] = "Test"
-- L["TEST_ALL"] = "Test All"
L["TOAST_NUM"] = "Número de toasts"
L["TRANSMOG_ADDED"] = "Appariencia añadida"
L["TRANSMOG_REMOVED"] = "Apariencia eliminada"
L["TYPE_ACHIEVEMENT"] = "Logro"
L["TYPE_ARCHAEOLOGY"] = "Arquelogía"
L["TYPE_CLASS_HALL"] = "Sede de clase"
-- L["TYPE_COLLECTION"] = "Collection"
-- L["TYPE_COLLECTION_DESC"] = "Toasts for newly collected mounts, pets and toys."
L["TYPE_DUNGEON"] = "Mazmorra"
L["TYPE_GARRISON"] = "Ciudadela"
L["TYPE_LOOT_COMMON"] = "Botín (Común)"
L["TYPE_LOOT_COMMON_DESC"] = "Toasts activados por eventos de chat, ej. verdes, azules, algunos épicos, cualquier cosa que no sea recogida por toasts de botines especiales."
L["TYPE_LOOT_CURRENCY"] = "Botín (Moneda)"
-- L["TYPE_LOOT_GOLD"] = "Loot (Gold)"
L["TYPE_LOOT_SPECIAL"] = "Botín (Especial)"
L["TYPE_LOOT_SPECIAL_DESC"] = "Toasts activados por eventos de botín especial, ej. tiradas ganadas, caídas de legendarios, botín personal, etc."
L["TYPE_RECIPE"] = "Receta"
L["TYPE_TRANSMOG"] = "Transmogrificación"
-- L["TYPE_WAR_EFFORT"] = "War Effort"
L["TYPE_WORLD_QUEST"] = "Misión de mundo"
