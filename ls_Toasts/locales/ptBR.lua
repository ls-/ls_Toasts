-- Contributors: paulovnas@GitHub

local _, addonTable = ...
local L = addonTable.L

-- Lua
local _G = getfenv(0)

if GetLocale() ~= "ptBR" then return end

L["ANCHOR_FRAME_#"] = "Quadro de Âncora #%d"
L["ANCHOR_FRAMES"] = "Quadros de Âncora"
L["ANCHOR_RESET_DESC"] = "|cffffffffShift-Clique|r para redefinir a posição."
L["BORDER"] = "Borda"
L["CHANGELOG"] = "Registro de Alterações"
L["CHANGELOG_FULL"] = "Completo"
L["COLORS"] = "Cores"
L["COORDS"] = "Coordenadas"
L["COPPER_THRESHOLD"] = "Limite de Cobre"
L["COPPER_THRESHOLD_DESC"] = "Quantidade mínima de cobre para criar um brinde."
L["DEFAULT_VALUE"] = "Valor padrão: |cffffd200%s|r"
L["DND"] = "Não Perturbe"
L["DND_TOOLTIP"] = "Brindes no modo Não Perturbe não serão exibidos em combate, mas serão enfileirados no sistema. Uma vez que você saia do combate, eles começarão a aparecer."
L["DOWNLOADS"] = "Downloads"
L["FADE_OUT_DELAY"] = "Atraso do Desaparecimento"
L["FILTERS"] = "Filtros"
L["FLUSH_QUEUE"] = "Limpar Fila"
L["FONTS"] = "Fontes"
L["GROWTH_DIR"] = "Direção de Crescimento"
L["GROWTH_DIR_DOWN"] = "Para Baixo"
L["GROWTH_DIR_LEFT"] = "Para a Esquerda"
L["GROWTH_DIR_RIGHT"] = "Para a Direita"
L["GROWTH_DIR_UP"] = "Para Cima"
L["ICON_BORDER"] = "Borda do Ícone"
L["INFORMATION"] = "Informação"
L["NAME"] = "Nome"
L["OPEN_CONFIG"] = "Abrir Configuração"
L["RARITY_THRESHOLD"] = "Limite de Raridade"
L["SCALE"] = "Escala"
L["SHOW_ILVL"] = "Mostrar iLvl"
L["SHOW_ILVL_DESC"] = "Mostrar nível do item ao lado do nome do item."
L["SIZE"] = "Tamanho"
L["SKIN"] = "Tema"
L["STRATA"] = "Estrato"
L["SUPPORT"] = "Suporte"
L["TEST"] = "Teste"
L["TEST_ALL"] = "Testar Todos"
L["TOAST_NUM"] = "Número de Brindes"
L["TOAST_TYPES"] = "Tipos de Brinde"
L["TOGGLE_ANCHORS"] = "Alternar Âncoras"
L["TRACK_LOSS"] = "Rastrear Perda"
L["TRACK_LOSS_DESC"] = "Esta opção ignora o limite de cobre definido."
L["TYPE_LOOT_GOLD"] = "Saque (Ouro)"
L["X_OFFSET"] = "Deslocamento X"
L["Y_OFFSET"] = "Deslocamento Y"
L["YOU_LOST"] = "Você Perdeu"
L["YOU_RECEIVED"] = "Você Recebeu"

-- Classic Era
L["ITEM_FILTERS_DESC"] = "Estes itens ignoram o limite de qualidade do saque."
L["NEW_ITEM_FILTER_DESC"] = "Digite um ID de item."
L["TYPE_LOOT_ITEMS"] = "Saque (Itens)"
