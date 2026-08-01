local _, addon = ...
local C, D, L = addon.C, addon.D, addon.L
addon.Tooltip = {}

--Lua
local _G = getfenv(0)
local pcall = _G.pcall
local s_split = _G.string.split
local t_concat = _G.table.concat
local tonumber = _G.tonumber

-- Mine
-- local tooltip = CreateFrame("GameTooltip", "LSToastsTooltip", UIParent, "GameTooltipTemplate")
-- tooltip:SetScript("OnUpdate", function(self, elapsed)
-- 	self.updateTooltipTimer = (self.updateTooltipTimer or 0.2) - elapsed
-- 	if self.updateTooltipTimer > 0 then return end

-- 	if self.shouldRefreshData then
-- 		-- stolen from p3lim :v
-- 		local info = self:GetPrimaryTooltipInfo()
-- 		if info and info.getterName and info.getterArgs then
-- 			if self[info.getterName:gsub("Get", "Set")](self, unpack(info.getterArgs)) then
-- 				self:Show()
-- 			end
-- 		end

-- 		self.shouldRefreshData = false
-- 	end

-- 	self.updateTooltipTimer = 0.2
-- end)
-- tooltip:Hide()

-- tooltip.supportsItemComparison = true
-- tooltip.shoppingTooltips = {}

-- for i = 1, 2 do
-- 	local tt = CreateFrame("GameTooltip", "LSToastsShoppingTooltip" .. i, UIParent, "ShoppingTooltipTemplate")
-- 	tt:SetClampedToScreen(true)
-- 	tt:SetFrameStrata("TOOLTIP")
-- 	tt:Hide()

-- 	tooltip.shoppingTooltips[i] = tt
-- end

function addon.Tooltip:SetAnchor(frame, p, rP, x, y)
	GameTooltip:Hide()
	GameTooltip:SetOwner(frame, "ANCHOR_NONE")
	GameTooltip:SetPoint(p, frame, rP, x, y)
end

function addon.Tooltip:ShowHyperlink(link)
	GameTooltip:SetHyperlink(link)
	GameTooltip:Show()
end

function addon.Tooltip:ShowPet(petLink)
	local _, speciesID, level, breedQuality, maxHealth, power, speed = s_split(":", petLink)
	speciesID, level, breedQuality, maxHealth, power, speed = tonumber(speciesID), tonumber(level), tonumber(breedQuality), tonumber(maxHealth), tonumber(power), tonumber(speed)
	if speciesID and speciesID > 0 then
		local name, _, petType = C_PetJournal.GetPetInfoBySpeciesID(speciesID)
		local data = {
			speciesID = speciesID,
			name = name,
			level = level,
			breedQuality = breedQuality,
			petType = petType,
			maxHealth = maxHealth,
			power = power,
			speed = speed,
		}

		BattlePetTooltipTemplate_SetBattlePet(BattlePetTooltip, data)

		local owned = C_PetJournal.GetOwnedBattlePetString(speciesID)
		BattlePetTooltip.Owned:SetText(owned)

		BattlePetTooltip:SetSize(260, owned and 136 or 122)
		BattlePetTooltip:Show()
		BattlePetTooltip:ClearAllPoints()
		BattlePetTooltip:SetPoint(GameTooltip:GetPoint(1))
	end
end

-- based on function RuneforgePowerBaseMixin:OnEnter()
function addon.Tooltip:ShowRuneforgePower(powerID)
	local info = C_LegendaryCrafting.GetRuneforgePowerInfo(powerID)

	local r, g, b = LEGENDARY_ORANGE_COLOR:GetRGB()
	GameTooltip:AddLine(info.name, r, g, b, true)

	r, g, b = GREEN_FONT_COLOR:GetRGB()
	GameTooltip:AddLine(info.description, r, g, b, true)

	local slots = C_LegendaryCrafting.GetRuneforgePowerSlots(powerID)
	if #slots > 0 or info.source or info.specName then
		GameTooltip:AddLine(" ")

		if #slots > 0 then
			r, g, b = NORMAL_FONT_COLOR:GetRGB()
			GameTooltip:AddLine(L["RUNECARVING_SLOT_FORMAT"]:format(t_concat(slots, LIST_DELIMITER)), r, g, b, true)
		end

		if info.source then
			r, g, b = NORMAL_FONT_COLOR:GetRGB()
			GameTooltip:AddLine(L["RUNECARVING_SOURCE_FORMAT"]:format(info.source), r, g, b, true)
		end

		if info.specName then
			r, g, b = info.matchesSpec and NORMAL_FONT_COLOR:GetRGB() or RED_FONT_COLOR:GetRGB()
			GameTooltip:AddLine(L["RUNECARVING_SPEC_FORMAT"]:format(info.specName), r, g, b, true)
		end
	end

	if info.state ~= Enum.RuneforgePowerState.Available then
		GameTooltip:AddLine(" ")

		r, g, b = RED_FONT_COLOR:GetRGB()
		GameTooltip:AddLine(L["RUNECARVING_NOT_COLLECTED"], r, g, b, true)
	end

	GameTooltip:Show()
end

function addon.Tooltip:ShowAchievement(achievementID)
	local _, name, _, _, month, day, year, description = GetAchievementInfo(achievementID)
	if name then
		if day and day > 0 then
			GameTooltip:AddDoubleLine(name, FormatShortDate(day, month, year), nil, nil, nil, 0.5, 0.5, 0.5)
		else
			GameTooltip:AddLine(name)
		end

		if description then
			GameTooltip:AddLine(description, 1, 1, 1, true)
		end
	end

	GameTooltip:Show()
end

function addon.Tooltip:ShowGarrisonFollower(followerID)
	local isOK, link = pcall(C_Garrison.GetFollowerLink, followerID)
	if not isOK then
		isOK, link = pcall(C_Garrison.GetFollowerLinkByID, followerID)
	end

	if isOK and link then
		-- colour code, link type, ...
		local _, _, garrisonFollowerID, quality, level, itemLevel, ability1, ability2, ability3, ability4, trait1, trait2, trait3, trait4, spec1 = s_split(":", link)
		garrisonFollowerID, quality, level, itemLevel, ability1, ability2, ability3, ability4, trait1, trait2, trait3, trait4, spec1 = tonumber(garrisonFollowerID), tonumber(quality), tonumber(level), tonumber(itemLevel), tonumber(ability1), tonumber(ability2), tonumber(ability3), tonumber(ability4), tonumber(trait1), tonumber(trait2), tonumber(trait3), tonumber(trait4), tonumber(spec1)

		local data = {
			garrisonFollowerID = garrisonFollowerID,
			followerTypeID = C_Garrison.GetFollowerTypeByID(garrisonFollowerID),
			collected = false,
			hyperlink = false,
			name = C_Garrison.GetFollowerNameByID(garrisonFollowerID),
			spec = C_Garrison.GetFollowerClassSpecByID(garrisonFollowerID),
			portraitIconID = C_Garrison.GetFollowerPortraitIconIDByID(garrisonFollowerID),
			quality = quality,
			level = level,
			xp = 0,
			levelxp = 0,
			iLevel = itemLevel,
			spec1 = spec1,
			ability1 = ability1,
			ability2 = ability2,
			ability3 = ability3,
			ability4 = ability4,
			trait1 = trait1,
			trait2 = trait2,
			trait3 = trait3,
			trait4 = trait4,
			isTroop = C_Garrison.GetFollowerIsTroop(garrisonFollowerID),
		}

		local tooltip
		if data.followerTypeID == Enum.GarrisonFollowerType.FollowerType_6_0_Boat then
			tooltip = GarrisonShipyardFollowerTooltip
			GarrisonFollowerTooltipTemplate_SetShipyardFollower(tooltip, data)
		else
			tooltip = GarrisonFollowerTooltip
			GarrisonFollowerTooltipTemplate_SetGarrisonFollower(tooltip, data)
		end

		tooltip:Show()
		tooltip:ClearAllPoints()
		tooltip:SetPoint(GameTooltip:GetPoint())
	end
end

function addon.Tooltip:ShowGarrisonTalent(talentID)
	local talent = C_Garrison.GetTalentInfo(talentID)
	GameTooltip:AddLine(talent.name, 1, 1, 1)
	GameTooltip:AddLine(talent.description, nil, nil, nil, true)
	GameTooltip:Show()
end

function addon.Tooltip:ShowCommonReceivedTooltip(text)
	GameTooltip:AddLine(L["YOU_RECEIVED"])
	GameTooltip:AddLine(text, 1, 1, 1)
	GameTooltip:Show()
end

function addon.Tooltip:ShowRecipe(recipeID)
	GameTooltip:SetSpellByID(recipeID)
	GameTooltip:Show()
end
