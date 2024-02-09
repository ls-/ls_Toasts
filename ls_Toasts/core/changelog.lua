local _, addonTable = ...
local E = addonTable.E

-- Lua
local _G = getfenv(0)

-- Mine
E.CHANGELOG = [[
### Loot (Special)

- Added loot roll info. It's a returning feature. However, there's a caveat, I don't know if "transmog" rolls are
  actually a thing in this particular case because it's basically an undocumented feature. I added it based on my
  assumptions, so if it works, good, if it doesn't, oh well. But "need", "greed", and "disenchant" rolls should work as
  expected.
]]
