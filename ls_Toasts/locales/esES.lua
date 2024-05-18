﻿-- Contributors: Gotxiko@GitHub, Shacoulrophobia@Curse

local _, addonTable = ...
local L = addonTable.L

-- Lua
local _G = getfenv(0)

if GetLocale() ~= "esES" and GetLocale() ~= "esMX" then return end

L["ANCHOR_FRAME_#"] = "Marco de anclaje #%d"
L["ANCHOR_FRAMES"] = "Marcos de anclaje"
L["ANCHOR_RESET_DESC"] = "|cffffffffShift-Click|r para reiniciar la posición."
L["BORDER"] = "Borde"
L["CHANGELOG"] = "Registro de cambios"
L["CHANGELOG_FULL"] = "Completo"
L["COLORS"] = "Colores"
L["COORDS"] = "Coordenadas"
L["COPPER_THRESHOLD"] = "Límite de Cobre"
L["COPPER_THRESHOLD_DESC"] = "Cantidad mínima de Cobre con la que mostrar un Toast."
L["DEFAULT_VALUE"] = "Valor por defecto: |cffffd200%s|r"
L["DND"] = "DND"
L["DND_TOOLTIP"] = "Toasts en modo DND no se mostrarán en combate, pero se pondrán a la cola del sistema. Una vez salgas de combate, aparecerán."
L["DOWNLOADS"] = "Descargas"
L["FADE_OUT_DELAY"] = "Retraso de desvanecimiento"
L["FILTERS"] = "Filtros"
L["FLUSH_QUEUE"] = "Limpiar cola"
L["FONTS"] = "Fuentes"
L["GROWTH_DIR"] = "Dirección de aparición"
L["GROWTH_DIR_DOWN"] = "Abajo"
L["GROWTH_DIR_LEFT"] = "Izquierda"
L["GROWTH_DIR_RIGHT"] = "Derecha"
L["GROWTH_DIR_UP"] = "Arriba"
L["ICON_BORDER"] = "Borde de icono"
L["INFORMATION"] = "Información"
L["NAME"] = "Nombre"
L["OPEN_CONFIG"] = "Abrir Config"
L["RARITY_THRESHOLD"] = "Límite de rareza"
L["SCALE"] = "Escala"
L["SHOW_ILVL"] = "Mostrar nivel de objeto"
L["SHOW_ILVL_DESC"] = "Muestra el nivel de objeto junto al nombre del objeto."
L["SIZE"] = "Tamaño"
L["SKIN"] = "Apariencia"
L["STRATA"] = "Altura"
L["SUPPORT"] = "Soporte"
L["TEST"] = "Test"
L["TEST_ALL"] = "Test todo"
L["TOAST_NUM"] = "Número de toasts"
L["TOAST_TYPES"] = "Tipos de Toasts"
L["TOGGLE_ANCHORS"] = "Alternar anclajes"
L["TRACK_LOSS"] = "Mostrar pérdidas"
L["TRACK_LOSS_DESC"] = "Esta opción ignora el margen de cobre establecido."
L["TYPE_LOOT_GOLD"] = "Botín (Oro)"
L["X_OFFSET"] = "xOffset"
L["Y_OFFSET"] = "yOffset"
L["YOU_LOST"] = "Has perdido"
L["YOU_RECEIVED"] = "Has recibido"

-- Classic Era
L["TYPE_LOOT_ITEMS"] = "Botín (Objetos)"

-- Classic
L["HANDLE_LEFT_CLICK"] = "Utilizar clic izquierdo"
L["NEW_CURRENCY_FILTER_DESC"] = "Introduce el ID de una moneda"
L["TAINT_WARNING"] = "Activar esta opción puede causar errores al abrir o cerrar ciertos paneles de la UI en combate."
L["THRESHOLD"] = "Umbral"
L["TRANSMOG_ADDED"] = "Appariencia añadida"
L["TRANSMOG_REMOVED"] = "Apariencia eliminada"
L["TYPE_ACHIEVEMENT"] = "Logro"
L["TYPE_COLLECTION"] = "Colección"
L["TYPE_COLLECTION_DESC"] = "Toasts para nuevas monturas, mascotas y juguetes."
L["TYPE_LOOT_CURRENCY"] = "Botín (Moneda)"
L["TYPE_TRANSMOG"] = "Transmogrificación"
L["YOU_COLLECTED"] = "Recolectaste"
