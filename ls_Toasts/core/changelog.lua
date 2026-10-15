local _, addon = ...
local E = addon.E

-- Lua
local _G = getfenv(0)

-- Mine
E.CHANGELOG = [[
- Added the manager for layout-specific settings. There you can reset, copy, and delete them. Available at the "Layouts" tab in Blizz config panel.
- Added the /lst reparentanchors command (case-insensitive) to reset positions of all anchors in case they got lost for some reason.
]]
