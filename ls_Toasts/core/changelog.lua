local _, addonTable = ...
local E = addonTable.E

-- Lua
local _G = getfenv(0)

-- Mine
E.CHANGELOG = [[
- Added "Traveler's Log" toasts for monthly activities.

### Loot (Currency)

- Added support for Trader's Tenders. They might be buggy due to how they're implemented on Blizz end. Unlike other
  currencies these update reliably only when the Trading Post UI is shown, that's why if you gain them while you're away
  from the Trading Post you may or may not get the toast.
]]
