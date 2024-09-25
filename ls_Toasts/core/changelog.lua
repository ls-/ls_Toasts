local _, addonTable = ...
local E = addonTable.E

-- Lua
local _G = getfenv(0)

-- Mine
E.CHANGELOG = [[
- Reworked the workaround for the guild achievement spam. After further investigating the issue it became apparent that
  it's impossible to reliably automate it without affecting newer smaller guilds that might want to see toasts for these
  achievements. For this reason I'm adding a toggle to enable filtering for guild achievements if your guild is
  experiencing it. This will block toasts for a bunch of faction-specific PvP and reputation achievements. Can be found
  at /LST > Toast Types > Achievement > Filter Guild Achievements, disabled by default.
- Updated Traditional Chinese translation. Translated by BNS333@Curse.
]]
