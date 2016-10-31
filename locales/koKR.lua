-- Contributors: WetU@GitHub

local _, addonTable = ...
local L = addonTable.L

-- Lua
local _G = _G

if _G.GetLocale() ~= "koKR" then return end

L["ANCHOR"] = "알림창 위치"
L["TRANSMOG_ADDED"] = "형상이 추가되었습니다"
L["TRANSMOG_REMOVED"] = "형상이 제거되었습니다"

-- Config General
-- L["SETTINGS_GENERAL_DESC"] = "Thome thettings, duh... |cffffd200They are saved per character.|r\nI strongly recommend to |cffe52626/reload|r UI after you're done setting up the addon. Even if you opened and closed this panel without changing anything, |cffe52626/reload|r UI. |cffffd200By doing so, you'll remove this config entry from the system and prevent possible taints.|r"

L["ANCHOR_FRAME"] = "위치 고정 창"
L["APPEARANCE_TITLE"] = "외형"
L["COLOURS"] = "이름 색상화"
L["COLOURS_TOOLTIP"] = "아이템, 추종자 이름, 전역 퀘스트, 임무 이름에 등급 별 색상을 입힙니다."
L["FADE_OUT_DELAY"] = "서서히 사라질 시간"
L["GROWTH_DIR"] = "성장 방향"
L["GROWTH_DIR_DOWN"] = "아래로"
L["GROWTH_DIR_LEFT"] = "왼쪽으로"
L["GROWTH_DIR_RIGHT"] = "오른쪽으로"
L["GROWTH_DIR_UP"] = "위로"
L["PROFILE_DESC"] = "아래 버튼을 클릭하면 현재 설정을 기본 프리셋으로 저장합니다. 여러 캐릭터가 거의 비슷한 배치를 사용할 때 이 기능은 꽤 편리합니다. 이 방법은 당신이 최소한의 설정만 할 수 있게 해줍니다. |cffffd200오직 1개의 프리셋만 만들 수 있다는 걸 기억하세요. 다른 캐릭터에서 이 버튼을 누르면 저장된 설정을 덮어 쓰게됩니다.|r"
L["PROFILE_SAVE"] = "설정 저장"
L["PROFILE_TITLE"] = "설정 전송"
-- L["PROFILE_WIPE"] = "Wipe Preset"
L["SCALE"] = "크기 비율"
L["TOAST_NUM"] = "알림창의 갯수"

-- Config Type
-- L["SETTINGS_TYPE_LABEL"] = "Toast Types"
-- L["SETTINGS_TYPE_DESC"] = "Moar thettings..."
L["DND"] = "대기"
L["DND_TOOLTIP"] = "대기 모드의 알림창은 전투 중에 표시되지 않고, 대신 시스템 내부에 대기하게 됩니다. 전투에서 벗어나면 대기 중이던 알림이 나타나기 시작합니다."
L["TEST"] = "테스트"
L["TYPE"] = "유형"
L["TYPE_ACHIEVEMENT"] = "업적"
L["TYPE_ARCHAEOLOGY"] = "고고학"
-- L["TYPE_CLASS_HALL"] = "Class Hall"
L["TYPE_DUNGEON"] = "던전"
L["TYPE_GARRISON"] = "주둔지"
-- L["TYPE_LOOT_COMMON"] = "Loot (Common)"
-- L["TYPE_LOOT_COMMON_TOOLTIP"] = "Toasts triggered by chat events, e.g. greens, blues, some epics, everything that isn't handled by special loot toasts."
-- L["TYPE_LOOT_CURRENCY"] = "Loot (Currency)"
-- L["TYPE_LOOT_SPECIAL"] = "Loot (Special)"
-- L["TYPE_LOOT_SPECIAL_TOOLTIP"] = "Toasts triggered by special loot events, e.g. won rolls, legendary drops, personal loot, etc."
L["TYPE_RECIPE"] = "제조법"
L["TYPE_TRANSMOG"] = "형상변환"
L["TYPE_WORLD QUEST"] = "전역 퀘스트"
