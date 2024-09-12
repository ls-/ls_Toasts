local _, addonTable = ...
local E = addonTable.E

-- Lua
local _G = getfenv(0)

-- Mine
E.CHANGELOG = [[
- Added a workaround for buggy guild achievement spam. If your character is in a guild, the addon will add already
  completed guild achievements to the blacklist on log in, you still will be able to see guild achievements if they're
  earned for the first time. If you join a guild at some point, reload the UI, the achievement API is super laggy, so I
  avoid rebuilding the blacklist during the actual game session.
- Added an option to disable tooltips on mouseover.
]]
