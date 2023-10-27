-- Contributors: Daniel8513@Curse, agstegiel@Curse, Braincell1980@Curse

local _, addonTable = ...
local L = addonTable.L

-- Lua
local _G = getfenv(0)

if GetLocale() ~= "frFR" then return end

L["ANCHOR_FRAME_#"] = "Fenêtre d'ancrage #%d"
L["ANCHOR_FRAMES"] = "Fenêtres d'ancrage"
L["ANCHOR_RESET_DESC"] = "|cffffffffShift-Click|r pour réinitialiser la position."
L["BORDER"] = "Bordure"
L["CHANGELOG"] = "Liste des changements "
L["CHANGELOG_FULL"] = "Tout"
L["COLORS"] = "Couleurs"
L["COORDS"] = "Coordonnées"
L["COPPER_THRESHOLD"] = "Seuil (en pièces de cuivre)"
L["COPPER_THRESHOLD_DESC"] = "Seuil minimum en pièce de cuivre permettant de générer un 'Toast'"
L["DEFAULT_VALUE"] = "Valeur par défaut : |cffffd200%s|r"
L["DND"] = "NPD"
L["DND_TOOLTIP"] = "Les 'Toast' en mode NPD (Ne Pas Déranger) ne s'afficheront pas en combat mais seront stockés dans le système. Quand le combat s'achève, les 'Toast' s'affichent."
L["DOWNLOADS"] = "Téléchargements"
L["FADE_OUT_DELAY"] = "Délai de disparition en fondu"
L["FILTERS"] = "Filtres"
L["FLUSH_QUEUE"] = "Vider la file d'attente"
L["FONTS"] = "Polices"
L["GROWTH_DIR"] = "Sens d'affichage"
L["GROWTH_DIR_DOWN"] = "Bas"
L["GROWTH_DIR_LEFT"] = "Gauche"
L["GROWTH_DIR_RIGHT"] = "Droite"
L["GROWTH_DIR_UP"] = "Haut"
L["ICON_BORDER"] = "Bordure d'icône"
L["INFORMATION"] = "Info"
L["NAME"] = "Nom"
L["OPEN_CONFIG"] = "Ouvrir Configuration"
L["RARITY_THRESHOLD"] = "Seuil de rareté"
L["SCALE"] = "Echelle"
L["SHOW_ILVL"] = "Montrer l'iLvl"
L["SHOW_ILVL_DESC"] = "Afficher le niveau de l'objet près de son nom"
L["SIZE"] = "Taille"
L["SKIN"] = "Apparence"
L["STRATA"] = "Strate"
L["SUPPORT"] = "Assistance"
L["TEST"] = "Test"
L["TEST_ALL"] = "Tester tout"
L["TOAST_NUM"] = "Nombre de 'Toast' simultanés"
L["TOAST_TYPES"] = "Types de 'Toast'"
L["TOGGLE_ANCHORS"] = "Basculer les Ancres"
L["TRACK_LOSS"] = "Suivre les pertes"
L["TRACK_LOSS_DESC"] = "Cette option ignore le seuil défini pour le Cuivre."
L["TYPE_LOOT_GOLD"] = "Butin (Gold)"
L["X_OFFSET"] = "xOffset"
L["Y_OFFSET"] = "yOffset"
L["YOU_LOST"] = "Vous avez perdu"
L["YOU_RECEIVED"] = "Vous avez reçu"

-- Classic
L["TYPE_LOOT_ITEMS"] = "Butin (Objets)"

-- WotLK
L["CURRENCY_THRESHOLD_DESC"] = "Entrez |cffffd200-1|r pour ignorer la devise, |cffffd2000|r pour désactiver le filtre, ou |cffffd200tout nombre supérieur à 0|r pour définir le seuil en dessous duquel aucun toast ne sera créé."
L["NEW_CURRENCY_FILTER_DESC"] = "Entrez un ID de monnaie."
L["THRESHOLD"] = "Rareté"
L["TYPE_ACHIEVEMENT"] = "Haut-Fait"
L["TYPE_LOOT_CURRENCY"] = "Butin (Breloques)"
