-- Contributors: BNSSNB@Curse

local _, addonTable = ...
local L = addonTable.L

-- Lua
local _G = _G

if _G.GetLocale() ~= "zhTW" then return end

-- Toast
L["ANCHOR"] = "通知定位點"
L["TRANSMOG_ADDED"] = "外觀已加入"
L["TRANSMOG_REMOVED"] = "外觀已移除"

-- Config General
L["SETTINGS_GENERAL_DESC"] = "|cffffd200這會依照每個角色儲存。|r\nI 強烈建議 |cffe52626/重載|r UI在你設置完此插件之後。即使你只是開啟與關閉選項面板什麼也沒更改， |cffe52626/重載|r UI. |cffffd200這麼做之後，您將從系統中刪除此配置項，並防止可能的污染。|r"
L["ANCHOR_FRAME"] = "定位框架"
L["APPEARANCE_TITLE"] = "外觀"
L["COLOURS"] = "著色名稱"
L["COLOURS_TOOLTIP"] = "根據品質著色物品與追隨者名稱，並且根據稀有度著色世界任務與任務標題。"
L["FADE_OUT_DELAY"] = "淡出延遲"
L["GROWTH_DIR"] = "成長方向"
L["GROWTH_DIR_DOWN"] = "下"
L["GROWTH_DIR_LEFT"] = "左"
L["GROWTH_DIR_RIGHT"] = "右"
L["GROWTH_DIR_UP"] = "上"
L["PROFILE_DESC"] = "要儲存當前設置為預設設定請點擊下方按鈕。這項功能可能很方便，如果你在許多角色想使用更多相同的佈局。這樣你就不需要太多的調整。|cffffd200請注意只能有一個預設設定。在不同的角色按下此按鈕將會覆蓋已存在的範本。|r"
L["PROFILE_SAVE"] = "儲存預設"
L["PROFILE_TITLE"] = "設置轉移"
L["PROFILE_WIPE"] = "清除預設"
L["SCALE"] = "縮放"
L["TOAST_NUM"] = "通知數量"

-- Config Type
L["SETTINGS_TYPE_LABEL"] = "通知類型"
-- L["SETTINGS_TYPE_DESC"] = "Moar thettings..."
L["DND"] = "勿擾"
L["DND_TOOLTIP"] = "通知處於勿擾模式將不會在戰鬥中顯示，但會取代成在系統佇列。一但你離開戰鬥，就會開始跳出通知。"
L["TEST"] = "測試"
L["TYPE"] = "類型"
L["TYPE_ACHIEVEMENT"] = "成就"
L["TYPE_ARCHAEOLOGY"] = "考古"
L["TYPE_CLASS_HALL"] = "職業大廳"
L["TYPE_DUNGEON"] = "地城"
L["TYPE_GARRISON"] = "要塞"
L["TYPE_LOOT_COMMON"] = "拾取(一般)"
L["TYPE_LOOT_COMMON_TOOLTIP"] = "由聊天事件觸發的通知，例如：綠色藍色或某些史詩，一切其他不屬於特殊戰利品的處理。"
L["TYPE_LOOT_CURRENCY"] = "拾取(貨幣)"
L["TYPE_LOOT_SPECIAL"] = "拾取(特殊)"
L["TYPE_LOOT_SPECIAL_TOOLTIP"] = "由特殊戰利品觸發的通知，例如：贏得擲骰、傳說掉落、個人拾取..等等。"
L["TYPE_RECIPE"] = "專業圖紙"
L["TYPE_TRANSMOG"] = "塑形提醒"
L["TYPE_WORLD QUEST"] = "世界任務"
