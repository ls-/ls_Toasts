-- Contributors: WetU@GitHub, netaras@Curse, unrealcrom96@Curse, blacknib@Curse

local _, addonTable = ...
local L = addonTable.L

-- Lua
local _G = getfenv(0)

if GetLocale() ~= "koKR" then return end

L["ANCHOR_FRAME_#"] = "고정판 #%d"
L["ANCHOR_FRAMES"] = "고정판"
L["ANCHOR_RESET_DESC"] = "|cffffffffShift-클릭|r으로 위치를 초기화 합니다."
L["BORDER"] = "테두리"
L["COLORS"] = "색상"
L["COORDS"] = "좌표"
L["COPPER_THRESHOLD"] = "코퍼 제한"
L["COPPER_THRESHOLD_DESC"] = "알림창을 만들 최소 코퍼 금액입니다."
L["DEFAULT_VALUE"] = "기본값: |cffffd200%s|r"
L["DND"] = "대기"
L["DND_TOOLTIP"] = "대기 모드의 알림창은 전투 중에 표시되지 않고, 대신 시스템 내부에 대기하게 됩니다. 전투에서 벗어나면 대기 중이던 알림이 나타나기 시작합니다."
L["FADE_OUT_DELAY"] = "페이드 아웃 지연 시간"
L["FILTERS"] = "분류"
L["FLUSH_QUEUE"] = "대기열 지우기"
L["FONTS"] = "글꼴"
L["GROWTH_DIR"] = "성장 방향"
L["GROWTH_DIR_DOWN"] = "아래로"
L["GROWTH_DIR_LEFT"] = "왼쪽으로"
L["GROWTH_DIR_RIGHT"] = "오른쪽으로"
L["GROWTH_DIR_UP"] = "위로"
L["ICON_BORDER"] = "아이콘 테두리"
L["NAME"] = "이름"
L["OPEN_CONFIG"] = "설정 열기"
L["RARITY_THRESHOLD"] = "최저 아이템 등급"
L["SCALE"] = "크기 비율"
L["SHOW_ILVL"] = "아이템 레벨 표시"
L["SHOW_ILVL_DESC"] = "아이템 이름 옆에 아이템 레벨을 표시합니다."
L["SIZE"] = "크기"
L["SKIN"] = "스킨"
L["STRATA"] = "우선순위"
L["TEST"] = "테스트"
L["TEST_ALL"] = "모두 테스트"
L["TOAST_NUM"] = "알림창의 갯수"
L["TOAST_TYPES"] = "알림창 종류"
L["TOGGLE_ANCHORS"] = "고정 전환"
L["TRACK_LOSS"] = "손실 추적"
L["TRACK_LOSS_DESC"] = "이 설정은 설정된 코퍼 임계값을 무시합니다."
L["TYPE_LOOT_GOLD"] = "전리품 (골드)"
L["X_OFFSET"] = "X 간격"
L["Y_OFFSET"] = "Y 간격"
L["YOU_LOST"] = "손실"
L["YOU_RECEIVED"] = "획득"

-- Classic
L["TYPE_LOOT_ITEMS"] = "전리품 (아이템)"

-- WotLK
L["CURRENCY_THRESHOLD_DESC"] = "이 화폐를 무시하려면 |cffffd200-1|r 입력하세요. |cffffd2000|r 을 입력하면 팝업이 생성되지 않으며, |cffffd200 0보다 높은 숫자|r를 입력해야 팝업이 생성되는 최소값이 설정합니다."
L["NEW_CURRENCY_FILTER_DESC"] = "화폐 ID를 입력하세요."
L["THRESHOLD"] = "최소수량"
L["TYPE_ACHIEVEMENT"] = "업적"
L["TYPE_LOOT_CURRENCY"] = "전리품 (화폐)"
