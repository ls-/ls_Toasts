local _, addonTable = ...
local E, L, C = addonTable.E, addonTable.L, addonTable.C

-- Lua
local _G = getfenv(0)
local t_concat = _G. table.concat

-- Mine
local function Toast_OnClick(self)
	if self._data.runecarving_id and not InCombatLockdown() then
		if not EncounterJournal then
			EncounterJournal_LoadUI()
		end

		if EncounterJournal then
			EncounterJournal_OpenToPowerID(self._data.runecarving_id)
		end
	end
end

-- based on function RuneforgePowerBaseMixin:OnEnter()
local function Toast_OnEnter(self)
	if self._data.runecarving_id then
		local info = C_LegendaryCrafting.GetRuneforgePowerInfo(self._data.runecarving_id)

		GameTooltip_SetTitle(GameTooltip, info.name, LEGENDARY_ORANGE_COLOR)
		GameTooltip_AddColoredLine(GameTooltip, info.description, GREEN_FONT_COLOR)

		local slots = C_LegendaryCrafting.GetRuneforgePowerSlots(self._data.runecarving_id)
		if #slots > 0 then
			slots = HIGHLIGHT_FONT_COLOR:WrapTextInColorCode(t_concat(slots, LIST_DELIMITER))

			GameTooltip_AddBlankLineToTooltip(GameTooltip)
			GameTooltip_AddNormalLine(GameTooltip, L["RUNECARVING_SLOT_FORMAT"]:format(slots))
		end

		if info.source then
			GameTooltip_AddBlankLineToTooltip(GameTooltip)
			GameTooltip_AddNormalLine(GameTooltip, L["RUNECARVING_SOURCE_FORMAT"]:format(HIGHLIGHT_FONT_COLOR:WrapTextInColorCode(info.source)))
		end

		if info.specName then
			GameTooltip_AddBlankLineToTooltip(GameTooltip)

			if info.matchesSpec then
				GameTooltip_AddNormalLine(GameTooltip, L["RUNECARVING_SPEC_FORMAT"]:format(HIGHLIGHT_FONT_COLOR:WrapTextInColorCode(info.specName)))
			else
				GameTooltip_AddErrorLine(GameTooltip, L["RUNECARVING_SPEC_FORMAT"]:format(info.specName))
			end
		end

		if info.state ~= Enum.RuneforgePowerState.Available then
			GameTooltip_AddBlankLineToTooltip(GameTooltip)
			GameTooltip_AddErrorLine(GameTooltip, L["RUNECARVING_NOT_COLLECTED"])
		end

		GameTooltip:Show()
	end
end

local function Toast_SetUp(event, powerID)
	local info = C_LegendaryCrafting.GetRuneforgePowerInfo(powerID)
	if info and info.name ~= "" then
		local toast = E:GetToast()
		local name = info.name
		local color = ITEM_QUALITY_COLORS[5]

		if C.db.profile.colors.name then
			name = color.hex .. name .. "|r"
		end

		if C.db.profile.colors.border then
			toast.Border:SetVertexColor(color.r, color.g, color.b)
		end

		if C.db.profile.colors.icon_border then
			toast.IconBorder:SetVertexColor(color.r, color.g, color.b)
		end

		toast.Title:SetText(L["YOU_RECEIVED"])
		toast.Text:SetText(name)
		toast.Icon:SetTexture(info.iconFileID)
		toast.IconBorder:Show()

		toast._data.event = event
		toast._data.runecarving_id = powerID
		toast._data.sound_file = C.db.profile.types.runecarving.sfx and 166314 -- SOUNDKIT.UI_RUNECARVING_OPEN_MAIN_WINDOW

		toast:HookScript("OnClick", Toast_OnClick)
		toast:HookScript("OnEnter", Toast_OnEnter)
		toast:Spawn(C.db.profile.types.runecarving.anchor, C.db.profile.types.runecarving.dnd)
	end
end

local function NEW_RUNEFORGE_POWER_ADDED(powerID)
	Toast_SetUp("NEW_RUNEFORGE_POWER_ADDED", powerID)
end

local function Enable()
	if C.db.profile.types.runecarving.enabled then
		E:RegisterEvent("NEW_RUNEFORGE_POWER_ADDED", NEW_RUNEFORGE_POWER_ADDED)
		-- I'm still not sure if this one is useful, the only info that's missing at the initial
		-- GetRuneforgePowerInfo call is the description, but in my case it's only useful for the
		-- OnEnter handler, but it'll be updated by then, so eh?
		-- E:RegisterEvent("RUNEFORGE_POWER_INFO_UPDATED", RUNEFORGE_POWER_INFO_UPDATED)
	end
end

local function Disable()
	E:UnregisterEvent("NEW_RUNEFORGE_POWER_ADDED", NEW_RUNEFORGE_POWER_ADDED)
	-- E:UnregisterEvent("RUNEFORGE_POWER_INFO_UPDATED", RUNEFORGE_POWER_INFO_UPDATED)
end

local function Test()
	-- Slick Ice
	Toast_SetUp("RUNECARVING_TEST", 2)
end

E:RegisterOptions("runecarving", {
	enabled = true,
	anchor = 1,
	dnd = false,
	sfx = true,
}, {
	name = L["TYPE_RUNECARVING"],
	get = function(info)
		return C.db.profile.types.runecarving[info[#info]]
	end,
	set = function(info, value)
		C.db.profile.types.runecarving[info[#info]] = value
	end,
	args = {
		enabled = {
			order = 1,
			type = "toggle",
			name = L["ENABLE"],
			set = function(_, value)
				C.db.profile.types.runecarving.enabled = value

				if value then
					Enable()
				else
					Disable()
				end
			end
		},
		dnd = {
			order = 2,
			type = "toggle",
			name = L["DND"],
			desc = L["DND_TOOLTIP"],
		},
		sfx = {
			order = 3,
			type = "toggle",
			name = L["SFX"],
		},
		test = {
			type = "execute",
			order = 99,
			width = "full",
			name = L["TEST"],
			func = Test,
		},
	},
})

E:RegisterSystem("runecarving", Enable, Disable, Test)
