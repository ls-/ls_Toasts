local _, addonTable = ...
local E = addonTable.E

-- Lua
local _G = getfenv(0)

-- Mine
E.CHANGELOG = [[
- Added 10.0.2 support.
- Fixed an issue where the addon would load the achievement UI too early which in turn could cause
  errors.
]]
