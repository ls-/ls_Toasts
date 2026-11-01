local _, addon = ...
local E = addon.E

-- Lua
local _G = getfenv(0)

-- Mine
E.CHANGELOG = [[
- Added a button to reset the anchor frame's position to the config panel. It should help in cases where the frame gets lost due to past shenanigans from other addons.
- Added info on where to find anchor frames and their settings to the config panel.
- Added a frame to adjust the position of the anchor frame while in Edit Mode. Unfortunately, for now it's not pixel-perfect because this requires a more substantial updated to the underlying Edit Mode library rather than my addon.
- Added dummy toasts to anchor frames in Edit Mode which should make it easier to locate them on the screen.
]]
