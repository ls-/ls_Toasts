local _, addonTable = ...
local E, L, C = addonTable.E, addonTable.L, addonTable.C

-- Lua
local _G = getfenv(0)

-- Mine
local function RecipeToast_OnClick(self)
	if self._data.tradeskill_id then
		if C.db.profile.types.recipe.left_click and not InCombatLockdown() then
			if not ProfessionsFrame then
				ProfessionsFrame_LoadUI()
			end

			if ProfessionsFrame then
				ProfessionsFrame:SetOpenRecipeResponse(self._data.skillline_id, self._data.recipe_id)
				C_TradeSkillUI.OpenTradeSkill(self._data.tradeskill_id)
			end
		end
	end
end

local function RecipeToast_OnEnter(self)
	if self._data.recipe_id then
		GameTooltip:SetSpellByID(self._data.recipe_id)
		GameTooltip:Show()
	end
end

local rankTextures = {
	[1] = "|TInterface\\LootFrame\\toast-star:12:12:0:0:32:32:0:21:0:21|t",
	[2] = "|TInterface\\LootFrame\\toast-star-2:12:24:0:0:64:32:0:42:0:21|t",
	[3] = "|TInterface\\LootFrame\\toast-star-3:12:36:0:0:64:32:0:64:0:21|t",
}

local function RecipeToast_SetUp(event, recipeID, recipeLevel)
	local skillLineID, _, tradeSkillID = C_TradeSkillUI.GetTradeSkillLineForRecipe(recipeID)
	if skillLineID then
		local spellInfo = C_Spell.GetSpellInfo(recipeID)
		if spellInfo then
			local toast = E:GetToast()

			if recipeLevel then
				toast.IconText1:SetText(rankTextures[recipeLevel])
				toast.IconText1BG:Show()
			end

			toast:SetBackground("recipe")
			toast.Title:SetText(recipeLevel and recipeLevel > 1 and L["RECIPE_UPGRADED"] or L["RECIPE_LEARNED"])
			toast.Text:SetText(spellInfo.name)
			toast.Icon:SetTexture(C_TradeSkillUI.GetTradeSkillTexture(skillLineID))
			toast.IconBorder:Show()

			toast._data.event = event
			toast._data.recipe_id = recipeID
			toast._data.skillline_id = skillLineID
			toast._data.sound_file = C.db.profile.types.recipe.sfx and 73919 -- SOUNDKIT.UI_PROFESSIONS_NEW_RECIPE_LEARNED_TOAST
			toast._data.tradeskill_id = tradeSkillID or skillLineID

			if C.db.profile.types.recipe.tooltip then
				toast:HookScript("OnEnter", RecipeToast_OnEnter)
			end

			toast:HookScript("OnClick", RecipeToast_OnClick)
			toast:Spawn(C.db.profile.types.recipe.anchor, C.db.profile.types.recipe.dnd)
		end
	end
end

local function NEW_RECIPE_LEARNED(...) -- recipeID, recipeLevel
	RecipeToast_SetUp("NEW_RECIPE_LEARNED", ...)
end

local function SkillLineToast_OnClick(self)
	if self._data.tradeskill_id then
		if C.db.profile.types.recipe.left_click and not InCombatLockdown() then
			if not ProfessionsFrame then
				ProfessionsFrame_LoadUI()
			end

			if ProfessionsFrame then
				ProfessionsFrame:SetOpenRecipeResponse(self._data.skillline_id, nil, true)
				C_TradeSkillUI.OpenTradeSkill(self._data.tradeskill_id)
			end
		end
	end
end

local function SkillLineToast_SetUp(event, skillLineID, tradeSkillID)
	local name = C_TradeSkillUI.GetTradeSkillDisplayName(skillLineID)
	if name then
		local toast = E:GetToast()

		toast:SetBackground("recipe")
		toast.Title:SetText(L["FEATURE_UNLOCKED"])
		toast.Text:SetFormattedText(L["PROFESSION_SPECIALIZATION"], C_TradeSkillUI.GetTradeSkillDisplayName(skillLineID))
		toast.Icon:SetTexture(C_TradeSkillUI.GetTradeSkillTexture(skillLineID))
		toast.IconBorder:Show()

		toast._data.event = event
		toast._data.skillline_id = skillLineID
		toast._data.sound_file = C.db.profile.types.recipe.sfx and 73919 -- SOUNDKIT.UI_PROFESSIONS_NEW_RECIPE_LEARNED_TOAST
		toast._data.tradeskill_id = tradeSkillID or skillLineID

		toast:HookScript("OnClick", SkillLineToast_OnClick)
		toast:Spawn(C.db.profile.types.recipe.anchor, C.db.profile.types.recipe.dnd)
	end
end

local function SKILL_LINE_SPECS_UNLOCKED(...) -- skillLineID, tradeSkillID
	SkillLineToast_SetUp("SKILL_LINE_SPECS_UNLOCKED", ...)
end

local function Enable()
	if C.db.profile.types.recipe.enabled then
		E:RegisterEvent("NEW_RECIPE_LEARNED", NEW_RECIPE_LEARNED)
		E:RegisterEvent("SKILL_LINE_SPECS_UNLOCKED", SKILL_LINE_SPECS_UNLOCKED)
	end
end

local function Disable()
	E:UnregisterEvent("NEW_RECIPE_LEARNED", NEW_RECIPE_LEARNED)
	E:UnregisterEvent("SKILL_LINE_SPECS_UNLOCKED", SKILL_LINE_SPECS_UNLOCKED)
end

local function Test()
	-- no rank, Elixir of Minor Defence
	RecipeToast_SetUp("RECIPE_TEST", 7183)

	-- rank 2, Word of Critical Strike
	RecipeToast_SetUp("RECIPE_TEST", 190992, C_Spell.GetSpellSkillLineAbilityRank(190992))

	-- Dragon Isles Enchanting
	SkillLineToast_SetUp("RECIPE_TEST", 2825, 333)
end

E:RegisterOptions("recipe", {
	enabled = true,
	anchor = 1,
	dnd = false,
	sfx = true,
	tooltip = true,
	left_click = false,
}, {
	name = L["TYPE_PROFESSION"],
	get = function(info)
		return C.db.profile.types.recipe[info[#info]]
	end,
	set = function(info, value)
		C.db.profile.types.recipe[info[#info]] = value
	end,
	args = {
		enabled = {
			order = 1,
			type = "toggle",
			name = L["ENABLE"],
			set = function(_, value)
				C.db.profile.types.recipe.enabled = value

				if value then
					Enable()
				else
					Disable()
				end
			end,
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
		tooltip = {
			order = 4,
			type = "toggle",
			name = L["TOOLTIPS"],
		},
		left_click = {
			order = 5,
			type = "toggle",
			name = L["HANDLE_LEFT_CLICK"],
			desc = L["TAINT_WARNING"],
			image = "Interface\\DialogFrame\\UI-Dialog-Icon-AlertNew",
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

E:RegisterSystem("recipe", Enable, Disable, Test)
