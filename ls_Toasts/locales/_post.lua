local _, addon = ...
local L = addon.L

-- Lua
local _G = getfenv(0)

-- Mine
-- These rely on custom strings
L["YOU_LOST_RED"] = "|cffdc4436" .. L["YOU_LOST"] .. "|r"
L["TRANSMOG_REMOVED_RED"] = "|cffdc4436" .. L["TRANSMOG_REMOVED"] .. "|r"
