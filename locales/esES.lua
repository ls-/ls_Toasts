-- Contributors: Gotxiko

local _, addonTable = ...
local L = addonTable.L

-- Lua
local _G = getfenv(0)

if _G.GetLocale() ~= "esES" then return end

L["ACHIEVEMENT_PROGRESSED"] = _G.ACHIEVEMENT_PROGRESSED
L["ACHIEVEMENT_UNLOCKED"] = _G.ACHIEVEMENT_UNLOCKED
L["BLIZZARD_STORE_PURCHASE_DELIVERED"] = _G.BLIZZARD_STORE_PURCHASE_COMPLETE
L["CANCEL"] = _G.CANCEL
L["DELETE"] = _G.DELETE
L["DIGSITE_COMPLETED"] = _G.ARCHAEOLOGY_DIGSITE_COMPLETE_TOAST_FRAME_TITLE
L["DUNGEON_COMPLETED"] = _G.DUNGEON_COMPLETED
L["ENABLE"] = _G.ENABLE
L["ENABLE_SOUND"] = _G.ENABLE_SOUND
L["GARRISON_MISSION_ADDED"] = _G.GARRISON_MISSION_ADDED_TOAST1
L["GARRISON_MISSION_COMPLETED"] = _G.GARRISON_MISSION_COMPLETE
L["GARRISON_NEW_BUILDING"] = _G.GARRISON_UPDATE
L["GARRISON_NEW_TALENT"] = _G.GARRISON_TALENT_ORDER_ADVANCEMENT
L["ITEM_LEGENDARY"] = _G.LEGENDARY_ITEM_LOOT_LABEL
L["ITEM_UPGRADED"] = _G.ITEM_UPGRADED_LABEL
L["ITEM_UPGRADED_FORMAT"] = string.format(_G.LOOTUPGRADEFRAME_TITLE, "%s%s|r")
L["LS_TOASTS"] = "ls: |cff1a9fc0Toasts|r"
L["OKAY"] = _G.OKAY
L["RECIPE_LEARNED"] = _G.NEW_RECIPE_LEARNED_TITLE
L["RECIPE_UPGRADED"] = _G.UPGRADED_RECIPE_LEARNED_TITLE
L["RELOADUI"] = _G.RELOADUI
L["RESET"] = _G.RESET
L["SCENARIO_COMPLETED"] = _G.SCENARIO_COMPLETED
L["SCENARIO_INVASION_COMPLETED"] = _G.SCENARIO_INVASION_COMPLETE
L["SETTINGS_GENERAL_LABEL"] = _G.GENERAL_LABEL
L["WORLD_QUEST_COMPLETED"] = _G.WORLD_QUEST_COMPLETE
L["XP_FORMAT"] = _G.BONUS_OBJECTIVE_EXPERIENCE_FORMAT
L["YOU_RECEIVED"] = _G.YOU_RECEIVED_LABEL
L["YOU_WON"] = _G.YOU_WON_LABEL

-- Require translation
L["ANCHOR"] = "Marco Toast"
L["ANCHOR_FRAME"] = "Marco de anclaje"
L["APPEARANCE_TITLE"] = "Apariencia"
L["COLORS"] = "Nombres de coloes"
L["COLORS_TOOLTIP"] = "Colorea los nombres de seguidor, objeto por calidad, y las misiones de mundo y títulos de misiones por rareza."
L["DND"] = "DND"
L["DND_TOOLTIP"] = "Toasts en modo DND no se mostrarán en combate, pero se pondrán a la cola del sistema. Una vez salgas de combate, aparecerán."
L["FADE_OUT_DELAY"] = "Retraso de desvanecimiento"
L["GROWTH_DIR"] = "Dirección de aparición"
L["GROWTH_DIR_DOWN"] = "Abajo"
L["GROWTH_DIR_LEFT"] = "Izquierda"
L["GROWTH_DIR_RIGHT"] = "Derecha"
L["GROWTH_DIR_UP"] = "Arriba"
L["PROFILE"] = "Perfil"
L["PROFILE_COPY_FROM"] = "Copiar desde:"
L["PROFILE_CREATE_NEW"] = "Crear Nuevo Perfil"
L["PROFILE_DELETE_CONFIRM"] = "¿Estás seguro de querer eliminar el perfil |cffffffff%s|r?"
L["PROFILE_RESET_CONFIRM"] = "¿Estas seguro de querer reiniciar el perfil |cffffffff%s|r?"
L["PROFILES_TITLE"] = "Perfiles"
L["SCALE"] = "Escala"
L["SETTINGS_GENERAL_DESC"] = "Algunas opciones.\nSe recomienda realizar |cffe52626/reload|r UI después de configurar el addon. Incluso si has abierto y cerrado este panel sin cambiar nada, |cffe52626/reload|r UI. |cffffd200Al hacer eso, eliminarás ésta entrade de configuración de sistema y prever posibles conflictos.|r"
L["SETTINGS_TYPE_DESC"] = "Más opciones..."
L["SETTINGS_TYPE_LABEL"] = "Tipos de Toasts"
L["TAINT_HEADER"] = "|cffff0000¡Estos toasts están desactivados debido a variables modificadas!|r\n"
L["TAINT_LINE"] = "\n\"%s\" fue modificado por \"|cffffd200%s|r\""
L["TEST"] = "Test"
L["TOAST_NUM"] = "Número de toasts"
L["TRANSMOG_ADDED"] = "Appariencia añadida"
L["TRANSMOG_REMOVED"] = "Apariencia eliminada"
L["TYPE"] = "Tipo"
L["TYPE_ACHIEVEMENT"] = "Logro"
L["TYPE_ARCHAEOLOGY"] = "Arquelogía"
L["TYPE_CLASS_HALL"] = "Sede de clase"
L["TYPE_DUNGEON"] = "Mazmorra"
L["TYPE_GARRISON"] = "Ciudadela"
L["TYPE_LOOT_COMMON"] = "Botín (Común)"
L["TYPE_LOOT_COMMON_TOOLTIP"] = "Toasts activados por eventos de chat, ej. verdes, azules, algunos épicos, cualquier cosa que no sea recogida por toasts de botines especiales."
L["TYPE_LOOT_CURRENCY"] = "Botín (Moneda)"
L["TYPE_LOOT_SPECIAL"] = "Botín (Especial)"
L["TYPE_LOOT_SPECIAL_TOOLTIP"] = "Toasts activados por eventos de botín especial, ej. tiradas ganadas, caídas de legendarios, botín personal, etc."
L["TYPE_RECIPE"] = "Receta"
L["TYPE_TRANSMOG"] = "Transmogrificación"
L["TYPE_WORLD_QUEST"] = "Misión de mundo"
