local _, addonTable = ...
local E = addonTable.E

-- Lua
local _G = getfenv(0)

-- Mine
E.CHANGELOG = [[
- Added 11.1.5 support.

### Loot (Common) & Loot (Special)

- Added an option to suppress toasts for legacy armour and weapons. You can disable toasts for legacy equipment by
  unchecking /LST > Toast Types > Loot (Common|Special) > Legacy Equipment, enabled by default.
]]
