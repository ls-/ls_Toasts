local _, addon = ...
local E = addon.E

-- Lua
local _G = getfenv(0)

-- Mine
E.CHANGELOG = [[
- Fixed an issue where profile import/export leaked into other addons. TIL.
]]
