local _, addonTable = ...
local E = addonTable.E

-- Lua
local _G = getfenv(0)

-- Mine
E.CHANGELOG = [[
- Added "Profession Materials" filter to item toasts. It should catch most mats, if it doesn't, use the ID filter.
- Fixed an issue where currency toasts would display bogus values. It primarily affected honour, valour, justice, and
  conquest points.
]]
