local _, addonTable = ...
local E = addonTable.E

-- Lua
local _G = getfenv(0)

-- Mine
E.CHANGELOG = [[
- Added 10.2 support.
- Added "LS: Toasts" entry to the addon compartment in the top right corner of the minimap.
- Tweaked toast borders so that the texture looks more consistent with no warping or shifting.
  Doesn't affect ElvUI skins.

### Transmogrification

- Fixed an issue where sometimes a toast wouldn't show up. It's primarily affecting "Quantum Items" that unlock
  a random appearance on use.
]]
