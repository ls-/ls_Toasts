local _, addonTable = ...
local E, P, C, D, L = addonTable.E, addonTable.P, addonTable.C, addonTable.D, addonTable.L

-- Lua
local _G = getfenv(0)
local m_floor = _G.math.floor
local next = _G.next
local s_upper = _G.string.upper
local t_insert = _G.table.insert
local tonumber = _G.tonumber
local tostring = _G.tostring

--[[ luacheck: globals
	CreateFrame GameTooltip IsShiftKeyDown SquareButton_SetIcon UIParent
]]

-- Mine
local anchors = {}
local activeAnchors = {}

local buttons = {
	Up = {
		point1 = {"TOPLEFT", "TOPLEFT", 12, 0},
		point2 = {"BOTTOMRIGHT", "TOPRIGHT", -12, -12},
		offset_x = 0,
		offset_y = 1,
	},
	Down = {
		point1 = {"BOTTOMLEFT", "BOTTOMLEFT", 12, 0},
		point2 = {"TOPRIGHT", "BOTTOMRIGHT", -12, 12},
		offset_x = 0,
		offset_y = -1,
	},
	Left = {
		point1 = {"TOPLEFT", "TOPLEFT", 0, -12},
		point2 = {"BOTTOMRIGHT", "BOTTOMLEFT", 12, 12},
		offset_x = -1,
		offset_y = 0,
	},
	Right = {
		point1 = {"TOPRIGHT", "TOPRIGHT", 0, -12},
		point2 = {"BOTTOMLEFT", "BOTTOMRIGHT", -12, 12},
		offset_x = 1,
		offset_y = 0,
	},
}

local isToggled = false

local function calculatePosition(self)
	local selfCenterX, selfCenterY = self:GetCenter()
	local screenWidth = UIParent:GetRight()
	local screenHeight = UIParent:GetTop()
	local screenCenterX, screenCenterY = UIParent:GetCenter()
	local screenLeft = screenWidth / 3
	local screenRight = screenWidth * 2 / 3
	local p, x, y

	if selfCenterY >= screenCenterY then
		p = "TOP"
		y = self:GetTop() - screenHeight
	else
		p = "BOTTOM"
		y = self:GetBottom()
	end

	if selfCenterX >= screenRight then
		p = p .. "RIGHT"
		x = self:GetRight() - screenWidth
	elseif selfCenterX <= screenLeft then
		p = p .. "LEFT"
		x = self:GetLeft()
	else
		x = selfCenterX - screenCenterX
	end

	return p, p, m_floor(x + 0.5), m_floor(y + 0.5)
end

local function anchor_Refresh(self)
	local config = C.db.profile.anchors[self:GetID()]

	self:SetMovable(true)
	self:ClearAllPoints()
	self:SetSize(224 * config.scale, 48 * config.scale)
	self:SetPoint(config.point.p, "UIParent", config.point.rP, config.point.x, config.point.y)
	self:SetShown(isToggled)
end

local function anchor_OnEnter(self)
	local p, _, x, y = calculatePosition(self)

	GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
	GameTooltip:AddLine(L["COORDS"])
	GameTooltip:AddLine("|cffffd100P:|r " .. p .. ", |cffffd100X:|r " .. x .. ", |cffffd100Y:|r " .. y, 1, 1, 1)
	GameTooltip:AddLine(" ")
	GameTooltip:AddLine(L["ANCHOR_RESET_DESC"])
	GameTooltip:Show()
end

local function anchor_OnLeave()
	GameTooltip:Hide()
end

local function anchor_OnUpdate(self, elapsed)
	self.elapsed = (self.elapsed or 0) + elapsed

	if self.elapsed > 0.1 then
		if GameTooltip:IsOwned(self) then
			anchor_OnEnter(self)
		end

		self.elapsed = 0
	end
end

local function anchor_OnDragStart(self)
	self:StartMoving()
	self:SetScript("OnUpdate", anchor_OnUpdate)
end

local function anchor_OnDragStop(self)
	self:StopMovingOrSizing()
	self:SetScript("OnUpdate", nil)

	local p, rP, x, y = calculatePosition(self)

	self:ClearAllPoints()
	self:SetPoint(p, "UIParent", rP, x, y)

	local config = C.db.profile.anchors[self:GetID()]
	if not config.point then
		config.point = {}
	end

	config.point.p = p
	config.point.rP = rP
	config.point.x = x
	config.point.y = y
end

local function anchor_OnClick(self)
	if IsShiftKeyDown() then
		local defaults = D.profile.anchors[1].point

		self:ClearAllPoints()
		self:SetPoint(defaults.p, "UIParent", defaults.rP, defaults.x, defaults.y)

		local config = C.db.profile.anchors[self:GetID()]
		if not config.point then
			config.point = {}
		end

		config.point.p = defaults.p
		config.point.rP = defaults.rP
		config.point.x = defaults.x
		config.point.y = defaults.y
	end
end

local function button_OnEnter(self)
	anchor_OnEnter(self:GetParent())
end

local function button_OnLeave(self)
	anchor_OnLeave(self:GetParent())
end

local function button_OnClick(self)
	local anchor = self:GetParent()
	local p, rP, x, y = calculatePosition(anchor)

	anchor:ClearAllPoints()
	anchor:SetPoint(p, "UIParent", rP, x + self.offset_x, y + self.offset_y)

	p, rP, x, y = calculatePosition(anchor)

	local config = C.db.profile.anchors[anchor:GetID()]
	if not config.point then
		config.point = {}
	end

	config.point.p = p
	config.point.rP = rP
	config.point.x = x
	config.point.y = y

	anchor_OnEnter(anchor)
end

local function costructAnchor(index)
	local anchor = CreateFrame("Button", "LSToastAnchor" .. index, UIParent)
	anchor:SetID(index)
	anchor:RegisterForDrag("LeftButton")
	anchor:RegisterForClicks("LeftButtonUp")
	anchor:SetClampedToScreen(true)
	anchor:SetClampRectInsets(-4, 4, 4, -4)
	anchor:SetFlattensRenderLayers(true)
	anchor:SetFrameStrata("DIALOG")
	anchor:SetToplevel(true)
	anchor:Hide()
	anchor:SetScript("OnClick", anchor_OnClick)
	anchor:SetScript("OnDragStart", anchor_OnDragStart)
	anchor:SetScript("OnDragStop", anchor_OnDragStop)
	anchor:SetScript("OnEnter", anchor_OnEnter)
	anchor:SetScript("OnLeave", anchor_OnLeave)

	local texture = anchor:CreateTexture(nil, "BACKGROUND")
	texture:SetColorTexture(0.1, 0.1, 0.1, 0.9)
	texture:SetAllPoints()
	anchor.BG = texture

	local text = anchor:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	text:SetAllPoints()
	text:SetJustifyH("CENTER")
	text:SetJustifyV("MIDDLE")
	text:SetText(L["ANCHOR_FRAME_#"]:format(index))
	anchor.Text = text

	for dir, data in next, buttons do
		local button = CreateFrame("Button", "$parentButton" .. dir, anchor, "UIPanelSquareButton")
		button:GetHighlightTexture():SetColorTexture(0.4, 0.4, 0.4, 0.8)
		button:GetNormalTexture():SetColorTexture(0.2, 0.2, 0.2, 0.8)
		button:GetPushedTexture():SetColorTexture(0.1, 0.1, 0.1, 0.8)
		button:SetFlattensRenderLayers(true)
		button:SetPoint(data.point1[1], anchor, data.point1[2], data.point1[3], data.point1[4])
		button:SetPoint(data.point2[1], anchor, data.point2[2], data.point2[3], data.point2[4])
		button:SetSize(0, 0)
		button:SetScript("OnClick", button_OnClick)
		button:SetScript("OnEnter", button_OnEnter)
		button:SetScript("OnLeave", button_OnLeave)

		button.offset_x = data.offset_x
		button.offset_y = data.offset_y

		SquareButton_SetIcon(button, s_upper(dir))
	end

	anchor.Refresh = anchor_Refresh

	t_insert(anchors, index, anchor)

	return anchor
end

function P:GetAnchor(index)
	return activeAnchors[index]
end

local options = {}

local function delete(info)
	P:RemoveAnchor(tonumber(info[#info - 1]))

	GameTooltip:Hide()
end

local function getAnchor(info)
	return C.db.profile.types[info[#info]].anchor == tonumber(info[#info - 1])
end

local function setAnchor(info)
	C.db.profile.types[info[#info]].anchor = tonumber(info[#info - 1])
end

local function getOption(info)
	return C.db.profile.anchors[tonumber(info[#info - 1])][info[#info]]
end

local function setMaxActiveToasts(info, value)
	C.db.profile.anchors[tonumber(info[#info - 1])].max_active_toasts = value
end

local function setScale(info, value)
	C.db.profile.anchors[tonumber(info[#info - 1])].scale = value

	P:UpdateScale(tonumber(info[#info - 1]))
end

local function setFadeOutDelay(info, value)
	C.db.profile.anchors[tonumber(info[#info - 1])].fadeout_delay = value

	P:UpdateFadeOutDelay(tonumber(info[#info - 1]))
end

local function setGrowthDirection(info, value)
	C.db.profile.anchors[tonumber(info[#info - 1])].growth_direction = value

	P:RefreshQueues()
end

local function setGrowthOffsetX(info, value)
	C.db.profile.anchors[tonumber(info[#info - 1])].growth_offset_x = value

	P:RefreshQueues()
end

local function setGrowthOffsetY(info, value)
	C.db.profile.anchors[tonumber(info[#info - 1])].growth_offset_y = value

	P:RefreshQueues()
end

function P:AddAnchor(index)
	if not activeAnchors[index] then
		activeAnchors[index] = anchors[index] or costructAnchor(index)

		C.db.profile.anchors[index] = P:UpdateTable(D.profile.anchors[1], C.db.profile.anchors[index])

		if not options[index] then
			options[index] = {
				order = 9 + index,
				type = "group",
				name = L["ANCHOR_FRAME_#"]:format(index),
				inline = true,
				get = getAnchor,
				set = setAnchor,
				args = {
					spacer_1 = {
						order = 9990,
						type = "description",
						name = " ",
					},
					max_active_toasts = {
						order = 9991,
						type = "range",
						name = L["TOAST_NUM"],
						desc = L["DEFAULT_VALUE"]:format(D.profile.anchors[1].max_active_toasts),
						min = 1, max = 20, step = 1,
						get = getOption,
						set = setMaxActiveToasts,
					},
					scale = {
						order = 9992,
						type = "range",
						name = L["SCALE"],
						min = 0.8, max = 2, step = 0.1,
						get = getOption,
						set = setScale,
					},
					fadeout_delay = {
						order = 9993,
						type = "range",
						name = L["FADE_OUT_DELAY"],
						desc = L["DEFAULT_VALUE"]:format(D.profile.anchors[1].fadeout_delay),
						min = 0.8, max = 10, step = 0.4,
						get = getOption,
						set = setFadeOutDelay,
					},
					growth_direction = {
						order = 9994,
						type = "select",
						name = L["GROWTH_DIR"],
						values = {
							UP = L["GROWTH_DIR_UP"],
							DOWN = L["GROWTH_DIR_DOWN"],
							LEFT = L["GROWTH_DIR_LEFT"],
							RIGHT = L["GROWTH_DIR_RIGHT"],
						},
						get = getOption,
						set = setGrowthDirection,
					},
					growth_offset_x = {
						order = 9995,
						type = "range",
						name = L["X_OFFSET"],
						desc = L["DEFAULT_VALUE"]:format(D.profile.anchors[1].growth_offset_x),
						min = 4, max = 48, step = 2,
						get = getOption,
						set = setGrowthOffsetX,
					},
					growth_offset_y = {
						order = 9996,
						type = "range",
						name = L["Y_OFFSET"],
						desc = L["DEFAULT_VALUE"]:format(D.profile.anchors[1].growth_offset_y),
						min = 4, max = 48, step = 2,
						get = getOption,
						set = setGrowthOffsetY,
					},
				},
			}

			if index ~= 1 then
				options[index].args.spacer_2 = {
					order = 9998,
					type = "description",
					name = " ",
				}
				options[index].args.delete = {
					order = 9999,
					name = L["DELETE"],
					type = "execute",
					width = "full",
					func = delete,
				}
			end
		end

		C.options.args.anchors.args[tostring(index)] = options[index]
	end
end

function P:RemoveAnchor(index)
	if index ~= 1 and activeAnchors[index] then
		self:FlushQueue(index)

		activeAnchors[index]:Hide()
		activeAnchors[index] = nil

		C.db.profile.anchors[index] = nil

		C.options.args.anchors.args[tostring(index)] = nil

		for _, v in next, C.db.profile.types do
			if v.anchor == index then
				v.anchor = 1
			end
		end
	end
end

function P:ToggleAnchors()
	isToggled = not isToggled

	for _, anchor in next, activeAnchors do
		anchor:SetShown(isToggled)
	end
end

function P:UpdateAnchors()
	for i = 1, #C.db.profile.anchors do
		self:AddAnchor(i)
		self:GetAnchor(i):Refresh()
	end

	for i = #C.db.profile.anchors + 1, #anchors do
		self:RemoveAnchor(i)
	end
end

function P:UpdateAnchorsOptions()
	for index in next, C.db.profile.anchors do
		index = tostring(index)

		for type in next, C.db.profile.types do
			if C.options.args.types.args[type] and C.options.args.anchors.args[index] and not C.options.args.anchors.args[index].args[type] then
				C.options.args.anchors.args[index].args[type] = {
					order = C.options.args.types.args[type].order,
					type = "toggle",
					name = C.options.args.types.args[type].name,
				}
			end
		end
	end
end
