-- Contributors: WetU@GitHub, yuk6196@Curse

local _, addonTable = ...
local L = addonTable.L

-- Lua
local _G = getfenv(0)

if _G.GetLocale() ~= "koKR" then return end

L["ANCHOR"] = "알림창 위치"
L["ANCHOR_FRAME"] = "위치 고정 창"
L["APPEARANCE_TITLE"] = "모양"
L["COLORS"] = "이름 색상화"
L["COLORS_TOOLTIP"] = "아이템, 추종자 이름, 전역 퀘스트, 임무 이름에 등급 별 색상을 입힙니다."
L["DND"] = "대기"
L["DND_TOOLTIP"] = "대기 모드의 알림창은 전투 중에 표시되지 않고, 대신 시스템 내부에 대기하게 됩니다. 전투에서 벗어나면 대기 중이던 알림이 나타나기 시작합니다."
L["FADE_OUT_DELAY"] = "서서히 사라질 시간"
L["GROWTH_DIR"] = "성장 방향"
L["GROWTH_DIR_DOWN"] = "아래로"
L["GROWTH_DIR_LEFT"] = "왼쪽으로"
L["GROWTH_DIR_RIGHT"] = "오른쪽으로"
L["GROWTH_DIR_UP"] = "위로"
-- L["PROFILE"] = "Profile"
-- L["PROFILE_COPY_FROM"] = "Copy from:"
-- L["PROFILE_CREATE_NEW"] = "Create New Profile"
-- L["PROFILE_DELETE_CONFIRM"] = "Are you sure you want to delete |cffffffff%s|r profile?"
-- L["PROFILE_RESET_CONFIRM"] = "Are you sure you want to reset |cffffffff%s|r profile?"
-- L["PROFILES_TITLE"] = "Profiles"
L["SCALE"] = "크기 비율"
L["SETTINGS_GENERAL_DESC"] = "애드온 설정을 완료한 후 UI를 |cffe52626/reload|r 할 것을 권장합니다. 변경 사항없이 이 창을 열었다가 닫은 경우에도, UI를 |cffe52626/reload|r하세요. |cffffd200이렇게 하면 시스템에서 설정 목록을 제거하고 오류 발생을 방지할 수 있습니다.|r"
L["SETTINGS_TYPE_DESC"] = "고급 설정..."
L["SETTINGS_TYPE_LABEL"] = "알림창 유형"
L["TEST"] = "테스트"
L["TOAST_NUM"] = "알림창의 갯수"
L["TRANSMOG_ADDED"] = "형상이 추가되었습니다"
L["TRANSMOG_REMOVED"] = "형상이 제거되었습니다"
L["TYPE"] = "유형"
L["TYPE_ACHIEVEMENT"] = "업적"
L["TYPE_ARCHAEOLOGY"] = "고고학"
L["TYPE_CLASS_HALL"] = "직업 전당"
L["TYPE_DUNGEON"] = "던전"
L["TYPE_GARRISON"] = "주둔지"
L["TYPE_LOOT_COMMON"] = "전리품 (일반)"
L["TYPE_LOOT_COMMON_TOOLTIP"] = "알림창이 대화 이벤트에 의해 발생됩니다, 예. 특별 전리품 알림창이 처리하지 않는 모든 고급, 희귀, 몇몇 영웅 전리품이 포함됩니다."
L["TYPE_LOOT_CURRENCY"] = "전리품 (화폐)"
L["TYPE_LOOT_SPECIAL"] = "전리품 (특별)"
L["TYPE_LOOT_SPECIAL_TOOLTIP"] = "알림창이 특별 전리품 이벤트에 의해 발생됩니다, 예. 주사위 우승, 전설 획득, 개인 획득, 기타."
L["TYPE_RECIPE"] = "제조법"
L["TYPE_TRANSMOG"] = "형상변환"
L["TYPE_WORLD_QUEST"] = "전역 퀘스트"
