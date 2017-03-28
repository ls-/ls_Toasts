-- Contributors: BNSSNB@Curse

local _, addonTable = ...
local L = addonTable.L

-- Lua
local _G = getfenv(0)

if _G.GetLocale() ~= "zhTW" then return end

L["ANCHOR"] = "通知定位點"
L["ANCHOR_FRAME"] = "定位框架"
L["APPEARANCE_TITLE"] = "外觀"
L["COLORS"] = "著色名稱"
L["COLORS_TOOLTIP"] = "根據品質著色物品與追隨者名稱，並且根據稀有度著色世界任務與任務標題。"
L["DND"] = "勿擾"
L["DND_TOOLTIP"] = "通知處於勿擾模式將不會在戰鬥中顯示，但會取代成在系統佇列。一但你離開戰鬥，就會開始跳出通知。"
L["FADE_OUT_DELAY"] = "淡出延遲"
L["GROWTH_DIR"] = "成長方向"
L["GROWTH_DIR_DOWN"] = "下"
L["GROWTH_DIR_LEFT"] = "左"
L["GROWTH_DIR_RIGHT"] = "右"
L["GROWTH_DIR_UP"] = "上"
L["PROFILE"] = "設定檔"
L["PROFILE_COPY_FROM"] = "複製自："
L["PROFILE_CREATE_NEW"] = "建立新設定檔"
L["PROFILE_DELETE_CONFIRM"] = "你確定要刪除|cffffffff%s|r設定檔嗎？"
L["PROFILE_RESET_CONFIRM"] = "你確定要重設|cffffffff%s|r設定檔嗎？"
L["PROFILES_TITLE"] = "設定檔"
L["SCALE"] = "縮放"
L["SETTINGS_GENERAL_DESC"] = "強烈建議 |cffe52626/重載|r UI在你設置完此插件之後。即使你只是開啟與關閉選項面板什麼也沒更改， |cffe52626/重載|r UI. |cffffd200這麼做之後，您將從系統中刪除此配置項，並防止可能的污染。|r"
L["SETTINGS_TYPE_DESC"] = "更多設置..."
L["SETTINGS_TYPE_LABEL"] = "通知類型"
L["TEST"] = "測試"
L["TOAST_NUM"] = "通知數量"
L["TRANSMOG_ADDED"] = "外觀已加入"
L["TRANSMOG_REMOVED"] = "外觀已移除"
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
L["TYPE_WORLD_QUEST"] = "世界任務"
