local _, addon = ...
local E = addon.E

-- Lua
local _G = getfenv(0)

-- Mine
E.CHANGELOG = [[
### Loot (Common)

- Fixed an issue where secret player GUID could break the toast. Some toasts will be missing, but overall it shouldn't be too bad.
]]
