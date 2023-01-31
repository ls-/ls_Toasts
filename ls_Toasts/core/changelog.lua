local _, addonTable = ...
local E = addonTable.E

-- Lua
local _G = getfenv(0)

-- Mine
E.CHANGELOG = [[
- Added an option to show poor quality quality items via common loot toasts. Thanks to Faqar@GitHub.
- Added leaf ornaments to achievement toasts. I can't re-enable Blizz achievement toasts, so as a
  compromise I chose to make achievement toasts more unique. If you want them to stand out even more
  create a separate anchor to display them.
- Added new "Info" panel to the config. It has links to various resourced including my Discord
  server dedicated to LS: * addons.
- Fixed corrupt beautycase border texture. It worked, but baked-in shadows were messed up.
- Updated Traditional Chinese translation. Translated by BNS333@Curse.
]]
