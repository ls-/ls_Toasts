local _, addon = ...
local E = addon.E

-- Lua
local _G = getfenv(0)

-- Mine
E.CHANGELOG = [[
- Added 12.1.5 support.
- Integrated the addon into Edit Mode. From now on anchors live there.
- Reworked profile import-export to properly support layout-related data. It can be quickly accessed via /LST IE. Now it's possible to export just the data that's tied to the current Edit Mode layout and import the data to the currently active layout.

NOTE: All of your previous settings were preserved under Classic and Modern layouts. To import them into your current layout you'll have to do the following:
- Switch to either of those in the Edit Mode.
- Export only the layout specific data via the addons importer/exporter.
- Switch to your current layout in the Edit Mode.
- Import previously exported layout data.
It's cumbersome, but that's the only way I could preserve the settings without doing a complete wipe.
Maybe one day in the future I'll make a proper layout data manager, but today is not that day because I still haven't fully settled on the layout data structure I want to use across all of my addons so that the manager can be universal instead of adjusting for every single addon I make.
]]
