local _, addon = ...
local E = addon.E

-- Lua
local _G = getfenv(0)

-- Mine
E.CHANGELOG = [[
### Loot (Currency)

- Fixed an issue where invalid currency IDs in the filter would break the addon. Now it will remove them before
  attempting anything else.
]]
