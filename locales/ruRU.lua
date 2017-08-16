-- Contributors: ls-@GitHub, BLizzatron@Curse

local _, addonTable = ...
local L = addonTable.L

-- Lua
local _G = getfenv(0)

if _G.GetLocale() ~= "ruRU" then return end

L["ANCHOR"] = "Крепление уведомления"
L["ANCHOR_FRAME"] = "Фрейм крепления"
L["COLORS"] = "Окрашивать имена"
L["COLORS_TOOLTIP"] = "Окрашивать названия предметов и имена соратников в соответствии с качеством, а названия локальных заданий и миссий в соответствии с редкостью."
L["COPPER_THRESHOLD"] = "Порог меди"
L["COPPER_THRESHOLD_DESC"] = "Наименьшее количество медных монет, для которого будет отображено уведомление."
L["DND"] = "Не беспокоить"
L["DND_TOOLTIP"] = "Уведомления в режиме \"Не беспокоить\" не будут отображаться в бою, но будут добавлены в очередь. Они начнут появляться на Вашем экране, как только Вы покинете бой."
L["FADE_OUT_DELAY"] = "Задержка исчезновения"
L["GROWTH_DIR"] = "Направление роста"
L["GROWTH_DIR_DOWN"] = "Вниз"
L["GROWTH_DIR_LEFT"] = "Влево"
L["GROWTH_DIR_RIGHT"] = "Вправо"
L["GROWTH_DIR_UP"] = "Вверх"
L["OPEN_CONFIG"] = "Открыть настройки"
L["SCALE"] = "Масштаб"
L["SETTINGS_TYPE_LABEL"] = "Типы уведомлений"
L["SHOW_ILVL"] = "Показывать ур. пр."
L["SHOW_ILVL_DESC"] = "Показывать уровень предмета рядом с его названием."
L["SKIN"] = "Обложка"
L["STRATA"] = "Слой"
L["TEST"] = "Тест"
L["TEST_ALL"] = "Тестировать всё"
L["TOAST_NUM"] = "Количество уведомлений"
L["TRANSMOG_ADDED"] = "Модель добавлена"
L["TRANSMOG_REMOVED"] = "Модель удалена"
L["TYPE_ACHIEVEMENT"] = "Достижение"
L["TYPE_ARCHAEOLOGY"] = "Археология"
L["TYPE_CLASS_HALL"] = "Оплот класса"
L["TYPE_DUNGEON"] = "Подземелье"
L["TYPE_GARRISON"] = "Гарнизон"
L["TYPE_LOOT_COMMON"] = "Добыча (Обычная)"
L["TYPE_LOOT_COMMON_DESC"] = "Уведомления, вызванные событиями чата, например: необычные, редкие, некоторые эпические предметы, все то, что не показывается посредством уведомлений об особой добыче."
L["TYPE_LOOT_CURRENCY"] = "Добыча (Валюта)"
L["TYPE_LOOT_GOLD"] = "Добыча (Золото)"
L["TYPE_LOOT_SPECIAL"] = "Добыча (Особая)"
L["TYPE_LOOT_SPECIAL_DESC"] = "Уведомления, вызванные специальными событиями добычи, например: выигранный розыгрыш добычи, легендарная или персональная добыча, и т. д."
L["TYPE_RECIPE"] = "Рецепт"
L["TYPE_TRANSMOG"] = "Трансмогрификация"
L["TYPE_WORLD_QUEST"] = "Локальное задание"
