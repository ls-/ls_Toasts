-- Contributors: BNS333@Curse, 彩虹の多多@Curse

local _, addonTable = ...
local L = addonTable.L

-- Lua
local _G = getfenv(0)

if GetLocale() ~= "zhTW" then return end

L["ANCHOR_FRAME_#"] = "定位框架 #%d"
L["ANCHOR_FRAMES"] = "定位框架"
L["ANCHOR_RESET_DESC"] = "|cffffffffShift-左鍵點擊|r 重置位置。"
L["BORDER"] = "邊框"
L["CHANGELOG"] = "更新紀錄"
L["CHANGELOG_FULL"] = "全部"
L["COLORS"] = "顏色"
L["COORDS"] = "座標"
L["COPPER_THRESHOLD"] = "銅最小值"
L["COPPER_THRESHOLD_DESC"] = "至少要多少銅才會顯示通知面板。"
L["DEFAULT_VALUE"] = "預設值：|cffffd200%s|r"
L["DND"] = "勿擾"
L["DND_TOOLTIP"] = "通知處於勿擾模式將不會在戰鬥中顯示，但會取代成在系統佇列。一但你離開戰鬥，就會開始跳出通知。"
L["DOWNLOADS"] = "下載"
L["FADE_OUT_DELAY"] = "淡出延遲"
L["FLUSH_QUEUE"] = "刷新佇列"
L["FONTS"] = "字體"
L["GROWTH_DIR"] = "成長方向"
L["GROWTH_DIR_DOWN"] = "下"
L["GROWTH_DIR_LEFT"] = "左"
L["GROWTH_DIR_RIGHT"] = "右"
L["GROWTH_DIR_UP"] = "上"
L["ICON_BORDER"] = "圖示邊框"
L["INFORMATION"] = "資訊"
L["NAME"] = "名稱"
L["RARITY_THRESHOLD"] = "最低物品品質"
L["SCALE"] = "縮放"
L["SHOW_ILVL"] = "顯示物品等級"
L["SHOW_ILVL_DESC"] = "在物品名稱旁顯示物品等級。"
L["SHOW_QUEST_ITEMS"] = "顯示任務物品"
L["SHOW_QUEST_ITEMS_DESC"] = "不論品質都要顯示任務物品。"
L["SIZE"] = "大小"
L["SKIN"] = "外觀風格"
L["STRATA"] = "框架層級"
L["SUPPORT"] = "支援"
L["TEST"] = "測試"
L["TEST_ALL"] = "全部測試"
L["TOAST_NUM"] = "通知數量"
L["TOAST_TYPES"] = "通知類型"
L["TOGGLE_ANCHORS"] = "切換定位點"
L["TRACK_LOSS"] = "追蹤失去"
L["TRACK_LOSS_DESC"] = "此選項忽略設置的銅幣閥值。"
L["TYPE_LOOT_GOLD"] = "拾取(金錢)"
L["X_OFFSET"] = "水平位置"
L["Y_OFFSET"] = "垂直位置"
L["YOU_LOST"] = "你失去"
L["YOU_RECEIVED"] = "你收到"

-- Classic
L["TYPE_LOOT_ITEMS"] = "拾取(物品)"

-- WotLK
L["CURRENCY_THRESHOLD_DESC"] = "輸入 |cffffd200-1|r 來忽略此貨幣。 |cffffd2000|r來停用此過濾，或|cffffd200 0以上的任何數字|r來設置閾值，低於該閾值將不建立與跳出提示。"
L["FILTERS"] = "過濾方式"
L["NEW_CURRENCY_FILTER_DESC"] = "輸入兌換通貨 ID"
L["THRESHOLD"] = "數量最少要"
L["TYPE_ACHIEVEMENT"] = "成就"
L["TYPE_LOOT_CURRENCY"] = "拾取(貨幣)"
