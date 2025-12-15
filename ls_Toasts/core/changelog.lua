local _, addonTable = ...
local E = addonTable.E

-- Lua
local _G = getfenv(0)

-- Mine
E.CHANGELOG = [[
- Added an option to disable the glow/shine visual effects on toasts. It can be toggled for each toast type individually. You can disable them at /LST > Toast Types > Toast Type > Visual Effects.

### Loot (Common)

- Added a way to white-/blacklist items by ID. These lists will ignore the quality threshold setting. However, you can't whitelist items that got filtered out by the "Legacy Equipment" pre-filter.
]]
