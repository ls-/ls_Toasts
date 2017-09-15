local _, addonTable = ...
local E, L, C = addonTable.E, addonTable.L, addonTable.C

-- Lua
local _G = getfenv(0)

-- Blizz
local C_TradeSkillUI_GetTradeSkillLineForRecipe = _G.C_TradeSkillUI.GetTradeSkillLineForRecipe
local C_TradeSkillUI_GetTradeSkillTexture = _G.C_TradeSkillUI.GetTradeSkillTexture
local C_TradeSkillUI_OpenTradeSkill = _G.C_TradeSkillUI.OpenTradeSkill
local GetSpellInfo = _G.GetSpellInfo
local GetSpellRank = _G.GetSpellRank
local InCombatLockdown = _G.InCombatLockdown
local TradeSkillFrame_LoadUI = _G.TradeSkillFrame_LoadUI

-- Mine
local function Toast_OnClick(self)
	local data = self._data

	if data and not InCombatLockdown() then
		if not TradeSkillFrame then
			TradeSkillFrame_LoadUI()
		end

		if TradeSkillFrame then
			if C_TradeSkillUI_OpenTradeSkill(data.tradeskill_id) then
				TradeSkillFrame:SelectRecipe(data.recipe_id)
			end
		end
	end
end

local function Toast_OnEnter(self)
	if self._data then
		GameTooltip:SetSpellByID(self._data.recipe_id)
		GameTooltip:Show()
	end
end

local function Toast_SetUp(event, recipeID)
	local tradeSkillID = C_TradeSkillUI_GetTradeSkillLineForRecipe(recipeID)

	if tradeSkillID then
		local recipeName = GetSpellInfo(recipeID)

		if recipeName then
			local toast = E:GetToast()
			local rank = GetSpellRank(recipeID)
			local rankTexture = ""

			if rank == 1 then
				rankTexture = "|TInterface\\LootFrame\\toast-star:12:12:0:0:32:32:0:21:0:21|t"
			elseif rank == 2 then
				rankTexture = "|TInterface\\LootFrame\\toast-star-2:12:24:0:0:64:32:0:42:0:21|t"
			elseif rank == 3 then
				rankTexture = "|TInterface\\LootFrame\\toast-star-3:12:36:0:0:64:32:0:64:0:21|t"
			end

			toast.Title:SetText(rank and rank > 1 and L["RECIPE_UPGRADED"] or L["RECIPE_LEARNED"])
			toast.Text:SetText(recipeName)
			toast.BG:SetTexture("Interface\\AddOns\\ls_Toasts\\media\\toast-bg-recipe")
			toast.Icon:SetTexture(C_TradeSkillUI_GetTradeSkillTexture(tradeSkillID))
			toast.IconBorder:Show()
			toast.IconText1:SetText(rankTexture)
			toast.IconText1BG:SetShown(not not rank)

			toast._data = {
				event = event,
				recipe_id = recipeID,
				sound_file = 73919, -- SOUNDKIT.UI_PROFESSIONS_NEW_RECIPE_LEARNED_TOAST
				tradeskill_id = tradeSkillID,
			}

			toast:HookScript("OnClick", Toast_OnClick)
			toast:HookScript("OnEnter", Toast_OnEnter)
			toast:Spawn(C.db.profile.types.recipe.dnd)
		end
	end
end

local function NEW_RECIPE_LEARNED(recipeID)
	Toast_SetUp("NEW_RECIPE_LEARNED", recipeID)
end

local function Enable()
	if C.db.profile.types.recipe.enabled then
		E:RegisterEvent("NEW_RECIPE_LEARNED", NEW_RECIPE_LEARNED)
	end
end

local function Disable()
	E:UnregisterEvent("NEW_RECIPE_LEARNED", NEW_RECIPE_LEARNED)
end

local function Test()
	-- no rank, Elixir of Minor Defence
	Toast_SetUp("RECIPE_TEST", 7183)

	-- rank 2, Word of Critical Strike
	Toast_SetUp("RECIPE_TEST", 190992)
end

E:RegisterOptions("recipe", {
	enabled = true,
	dnd = false,
}, {
	name = L["TYPE_RECIPE"],
	args = {
		enabled = {
			order = 1,
			type = "toggle",
			name = L["ENABLE"],
			get = function()
				return C.db.profile.types.recipe.enabled
			end,
			set = function(_, value)
				C.db.profile.types.recipe.enabled = value

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
			get = function()
				return C.db.profile.types.recipe.dnd
			end,
			set = function(_, value)
				C.db.profile.types.recipe.dnd = value

				if value then
					Enable()
				else
					Disable()
				end
			end
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
