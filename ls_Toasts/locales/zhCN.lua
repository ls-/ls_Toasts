-- Contributors: y368413@Curse, dxlmike@Curse, vk1103ing@Curse

local _, addonTable = ...
local L = addonTable.L

-- Lua
local _G = getfenv(0)

if GetLocale() ~= "zhCN" then return end

L["ANCHOR_FRAME_#"] = "锚点框架#%d"
L["ANCHOR_FRAMES"] = "锚点框架"
L["ANCHOR_RESET_DESC"] = "|cffffffffShift-点击左键|r 重置位置。"
L["BORDER"] = "边框"
L["COLORS"] = "着色"
L["COORDS"] = "方位"
L["COPPER_THRESHOLD"] = "拾取最小值(铜)"
L["COPPER_THRESHOLD_DESC"] = "至少要多少銅才会显示拾取提示面板。"
L["DEFAULT_VALUE"] = "默认参数：|cffffd200%s|r"
L["DND"] = "勿扰"
L["DND_TOOLTIP"] = "提示处于勿扰模式将不会在战斗中显示，但仍在后台队列，一旦你离开战斗，就会开始弹出提示。"
L["FADE_OUT_DELAY"] = "淡出延迟"
L["FLUSH_QUEUE"] = "刷新分组"
L["FONTS"] = "字体"
L["GROWTH_DIR"] = "延伸方向"
L["GROWTH_DIR_DOWN"] = "下"
L["GROWTH_DIR_LEFT"] = "左"
L["GROWTH_DIR_RIGHT"] = "右"
L["GROWTH_DIR_UP"] = "上"
L["ICON_BORDER"] = "图标边框"
L["NAME"] = "名称"
L["OPEN_CONFIG"] = "打开设置"
L["RARITY_THRESHOLD"] = "品质限定"
L["SCALE"] = "缩放"
L["SHOW_ILVL"] = "显示装等"
L["SHOW_ILVL_DESC"] = "在装备名称前显示装备等级"
L["SIZE"] = "大小"
L["SKIN"] = "皮肤"
L["STRATA"] = "层级"
L["TEST"] = "测试"
L["TEST_ALL"] = "测试全部"
L["TOAST_NUM"] = "提示框数量"
L["TOAST_TYPES"] = "提示框类型"
L["TOGGLE_ANCHORS"] = "移动位置"
L["TRACK_LOSS"] = "追踪损失"
L["TRACK_LOSS_DESC"] = "开启该选项后将忽略 拾取最小值 设置。"
L["TYPE_LOOT_GOLD"] = "拾取(金币)"
L["X_OFFSET"] = "水平偏移量"
L["Y_OFFSET"] = "垂直偏移量"
L["YOU_LOST"] = "你损失了"
L["YOU_RECEIVED"] = "你获得了"

-- Classic
L["TYPE_LOOT_ITEMS"] = "拾取(物品)"

-- WotLK
L["TYPE_ACHIEVEMENT"] = "成就"
L["TYPE_LOOT_CURRENCY"] = "拾取(货币)"
