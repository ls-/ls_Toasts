local _, addonTable = ...
local E, L, C = addonTable.E, addonTable.L, addonTable.C

-- Lua
local _G = getfenv(0)
local m_abs = _G.math.abs
local m_floor = _G.math.floor
local m_random = _G.math.random
local next = _G.next
local t_insert = _G.table.insert
local t_sort = _G.table.sort
local t_wipe = _G.table.wipe
local tonumber = _G.tonumber
local tostring = _G.tostring

-- Mine
-- GENERATED-DATA-START
local BLACKLIST = {
	[  22] = true, -- Birmingham Test Item 3
	[ 384] = true, -- Dwarf Archaeology Fragment
	[ 385] = true, -- Troll Archaeology Fragment
	[ 393] = true, -- Fossil Archaeology Fragment
	[ 394] = true, -- Night Elf Archaeology Fragment
	[ 395] = true, -- Justice Points
	[ 396] = true, -- Valor Points
	[ 397] = true, -- Orc Archaeology Fragment
	[ 398] = true, -- Draenei Archaeology Fragment
	[ 399] = true, -- Vrykul Archaeology Fragment
	[ 400] = true, -- Nerubian Archaeology Fragment
	[ 401] = true, -- Tol'vir Archaeology Fragment
	[ 483] = true, -- Conquest Arena Meta
	[ 484] = true, -- Conquest Rated BG Meta
	[ 676] = true, -- Pandaren Archaeology Fragment
	[ 677] = true, -- Mogu Archaeology Fragment
	[ 692] = true, -- Conquest Random BG Meta
	[ 754] = true, -- Mantid Archaeology Fragment
	[ 821] = true, -- Draenor Clans Archaeology Fragment
	[ 828] = true, -- Ogre Archaeology Fragment
	[ 829] = true, -- Arakkoa Archaeology Fragment
	[ 830] = true, -- n/a
	[1171] = true, -- Artifact Knowledge
	[1172] = true, -- Highborne Archaeology Fragment
	[1173] = true, -- Highmountain Tauren Archaeology Fragment
	[1174] = true, -- Demonic Archaeology Fragment
	[1191] = true, -- Valor
	[1324] = true, -- Horde Qiraji Commendation
	[1325] = true, -- Alliance Qiraji Commendation
	[1347] = true, -- Legionfall Building - Personal Tracker - Mage Tower (Hidden)
	[1349] = true, -- Legionfall Building - Personal Tracker - Command Tower (Hidden)
	[1350] = true, -- Legionfall Building - Personal Tracker - Nether Tower (Hidden)
	[1501] = true, -- Writhing Essence
	[1506] = true, -- Argus Waystone
	[1534] = true, -- Zandalari Archaeology Fragment
	[1535] = true, -- Drust Archaeology Fragment
	[1553] = true, -- Azerite
	[1579] = true, -- Champions of Azeroth
	[1585] = true, -- Warband Wide Honor
	[1586] = true, -- Honor Level
	[1592] = true, -- Order of Embers
	[1593] = true, -- Proudmoore Admiralty
	[1594] = true, -- Storm's Wake
	[1595] = true, -- Talanji's Expedition
	[1596] = true, -- Voldunai
	[1597] = true, -- Zandalari Empire
	[1598] = true, -- Tortollan Seekers
	[1599] = true, -- 7th Legion
	[1600] = true, -- Honorbound
	[1703] = true, -- PVP Season Rated Participation Currency
	[1705] = true, -- Warfronts - Personal Tracker - Iron in Chest (Hidden)
	[1714] = true, -- Warfronts - Personal Tracker - Wood in Chest (Hidden)
	[1722] = true, -- Azerite Ore
	[1723] = true, -- Lumber
	[1728] = true, -- Phantasma
	[1738] = true, -- Unshackled
	[1739] = true, -- Ankoan
	[1740] = true, -- Rustbolt Resistance (Hidden)
	[1742] = true, -- Rustbolt Resistance
	[1744] = true, -- Corrupted Memento
	[1745] = true, -- Nazjatar Ally - Neri Sharpfin
	[1746] = true, -- Nazjatar Ally - Vim Brineheart
	[1747] = true, -- Nazjatar Ally - Poen Gillbrack
	[1748] = true, -- Nazjatar Ally - Bladesman Inowari
	[1749] = true, -- Nazjatar Ally - Hunter Akana
	[1750] = true, -- Nazjatar Ally - Farseer Ori
	[1752] = true, -- Honeyback Hive
	[1757] = true, -- Uldum Accord
	[1758] = true, -- Rajani
	[1761] = true, -- Enemy Damage
	[1762] = true, -- Enemy Health
	[1763] = true, -- Deaths
	[1769] = true, -- Quest Experience (Standard, Hidden)
	[1794] = true, -- Atonement Anima
	[1804] = true, -- Ascended
	[1805] = true, -- Undying Army
	[1806] = true, -- Wild Hunt
	[1807] = true, -- Court of Harvesters
	[1808] = true, -- Channeled Anima
	[1810] = true, -- Redeemed Soul
	[1822] = true, -- Renown
	[1837] = true, -- The Ember Court
	[1838] = true, -- The Countess
	[1839] = true, -- Rendle and Cudgelface
	[1840] = true, -- Stonehead
	[1841] = true, -- Cryptkeeper Kassir
	[1842] = true, -- Baroness Vashj
	[1843] = true, -- Plague Deviser Marileth
	[1844] = true, -- Grandmaster Vole
	[1845] = true, -- Alexandros Mograine
	[1846] = true, -- Sika
	[1847] = true, -- Kleia and Pelegos
	[1848] = true, -- Polemarch Adrestes
	[1849] = true, -- Mikanikos
	[1850] = true, -- Choofa
	[1851] = true, -- Droman Aliothe
	[1852] = true, -- Hunt-Captain Korayn
	[1853] = true, -- Lady Moonberry
	[1877] = true, -- Bonus Experience
	[1878] = true, -- Stitchmasters
	[1880] = true, -- Ve'nari
	[1883] = true, -- Soulbind Conduit Energy
	[1884] = true, -- The Avowed
	[1887] = true, -- Court of Night
	[1888] = true, -- Marasmius
	[1889] = true, -- Adventure Campaign Progress
	[1891] = true, -- Honor from Rated
	[1902] = true, -- 9.1 - Torghast XP - Prototype - LJS
	[1903] = true, -- Invisible Reward
	[1907] = true, -- Death's Advance
	[1909] = true, -- Torghast - Scoreboard - Clear Percent
	[1910] = true, -- Torghast - Scoreboard - Souls Percent
	[1911] = true, -- Torghast - Scoreboard - Urns Percent
	[1912] = true, -- Torghast - Scoreboard - Hot Streak Percent
	[1913] = true, -- Torghast - Scoreboard - Total Time
	[1914] = true, -- Torghast - Scoreboard - Par Time
	[1915] = true, -- Torghast - Scoreboard - Deaths Excess Count
	[1916] = true, -- Torghast - Scoreboard - Deaths Start Count
	[1917] = true, -- Torghast - Scoreboard - Floor Reached
	[1918] = true, -- Torghast - Scoreboard - Toast Display - Time Score
	[1919] = true, -- Torghast - Scoreboard - Toast Display - Hot Streak Score
	[1920] = true, -- Torghast - Scoreboard - Toast Display - Deaths Excess Score
	[1921] = true, -- Torghast - Scoreboard - Toast Display - Total Score
	[1922] = true, -- Torghast - Scoreboard - Toast Display - Total Rewards
	[1923] = true, -- Torghast - Scoreboard - Toast Display - Bonus - Souls Rescued
	[1924] = true, -- Torghast - Scoreboard - Toast Display - Bonus - Urns Broken
	[1925] = true, -- Torghast - Scoreboard - Toast Display - Deaths Zero
	[1926] = true, -- Torghast - Scoreboard - Toast Display - Stars
	[1932] = true, -- Torghast - Scoreboard - Toast Display - Boss Killed
	[1933] = true, -- Torghast - Scoreboard - Toast Display - Bonus - Chests Opened
	[1934] = true, -- Torghast - Scoreboard - Toast Display - Bonus - Escorts Complete
	[1935] = true, -- Torghast - Scoreboard - Toast Display - Bonus - No Trap Damage
	[1936] = true, -- Torghast - Scoreboard - Toast Display - Bonus - Kill Boss Fast
	[1937] = true, -- Torghast - Scoreboard - Toast Display - Bonus - Single Stacks
	[1938] = true, -- Torghast - Scoreboard - Toast Display - Bonus - 5 Stacks
	[1939] = true, -- Torghast - Scoreboard - Toast Display - Bonus - Broker Killer
	[1940] = true, -- Torghast - Scoreboard - Toast Display - Bonus - Elite Slayer
	[1941] = true, -- Torghast - Scoreboard - Toast Display - Bonus - 1000 Phantasma
	[1942] = true, -- Torghast - Scoreboard - Toast Display - Bonus - 500 Phant Left
	[1943] = true, -- Torghast - Scoreboard - Toast Display - Bonus - No Deaths
	[1944] = true, -- Torghast - Scoreboard - Toast Display - Bonus - No Epics
	[1945] = true, -- Torghast - Scoreboard - Toast Display - Bonus - Elite Unnatural
	[1946] = true, -- Torghast - Scoreboard - Toast Display - Total Rewards - AV Bonus
	[1947] = true, -- Bonus Valor
	[1948] = true, -- Torghast - Scoreboard - Toast Display - Bonus - Kill Boss Faster
	[1949] = true, -- Torghast - Scoreboard - Toast Display - Bonus - 30+ Count
	[1950] = true, -- Torghast - Scoreboard - Toast Display - 1 Star Value
	[1951] = true, -- Torghast - Scoreboard - Toast Display - 2 Star Value
	[1952] = true, -- Torghast - Scoreboard - Toast Display - 3 Star Value
	[1953] = true, -- Torghast - Scoreboard - Toast Display - 4 Star Value
	[1954] = true, -- Torghast - Scoreboard - Toast Display - 5 Star Value
	[1955] = true, -- Torghast - Scoreboard - Toast Display - Points While Empowered
	[1956] = true, -- Torghast - Scoreboard - Toast Display - Points Empowered Score
	[1957] = true, -- Torghast - Scoreboard - Floor Clear Percent Floor 1
	[1958] = true, -- Torghast - Scoreboard - Floor Clear Percent Floor 2
	[1959] = true, -- Torghast - Scoreboard - Floor Clear Percent Floor 3
	[1960] = true, -- Torghast - Scoreboard - Floor Clear Percent Floor 4
	[1961] = true, -- Torghast - Scoreboard - Floor Empowered Percent Floor 1
	[1962] = true, -- Torghast - Scoreboard - Floor Empowered Percent Floor 2
	[1963] = true, -- Torghast - Scoreboard - Floor Empowered Percent Floor 3
	[1964] = true, -- Torghast - Scoreboard - Floor Empowered Percent Floor 4
	[1965] = true, -- Torghast - Scoreboard - Floor Time Floor 1
	[1966] = true, -- Torghast - Scoreboard - Floor Time Floor 2
	[1967] = true, -- Torghast - Scoreboard - Floor Time Floor 3
	[1968] = true, -- Torghast - Scoreboard - Floor Time Floor 4
	[1969] = true, -- Torghast - Scoreboard - Floor Par Time Floor 1
	[1970] = true, -- Torghast - Scoreboard - Floor Par Time Floor 2
	[1971] = true, -- Torghast - Scoreboard - Floor Par Time Floor 3
	[1972] = true, -- Torghast - Scoreboard - Floor Par Time Floor 4
	[1976] = true, -- Torghast - Scoreboard - Toast Display - Bonus - Phant Left Group
	[1980] = true, -- Torghast - Scoreboard - Run Layer
	[1981] = true, -- Torghast - Scoreboard - Run ID
	[1982] = true, -- The Enlightened
	[1986] = true, -- Players Remaining
	[1997] = true, -- Archivists' Codex
	[2000] = true, -- Motes of Fate
	[2001] = true, -- Paden Test Currency
	[2002] = true, -- Renown-Maruuk Centaur
	[2016] = true, -- Dragon Racing - Scoreboard - Race Complete Time
	[2017] = true, -- Dragon Racing - Scoreboard - Race Complete Time - Fraction 1
	[2018] = true, -- Dragon Racing - Temp Storage - Race Quest ID
	[2019] = true, -- Dragon Racing - Scoreboard - Race Complete Time - Silver
	[2020] = true, -- Dragon Racing - Scoreboard - Race Complete Time - Gold
	[2021] = true, -- Renown-Dragonscale Expedition
	[2022] = true, -- Dragon Racing - Multiplayer Race Placement
	[2023] = true, -- Dragon Isles Blacksmithing Knowledge
	[2024] = true, -- Dragon Isles Alchemy Knowledge
	[2025] = true, -- Dragon Isles Leatherworking Knowledge
	[2026] = true, -- Dragon Isles Tailoring Knowledge
	[2027] = true, -- Dragon Isles Engineering Knowledge
	[2028] = true, -- Dragon Isles Inscription Knowledge
	[2029] = true, -- Dragon Isles Jewelcrafting Knowledge
	[2030] = true, -- Dragon Isles Enchanting Knowledge
	[2031] = true, -- Dragonscale Expedition
	[2032] = true, -- Trader's Tender
	[2033] = true, -- Dragon Isles Skinning Knowledge
	[2034] = true, -- Dragon Isles Herbalism Knowledge
	[2035] = true, -- Dragon Isles Mining Knowledge
	[2036] = true, -- Ancient Waygate Energy
	[2037] = true, -- Dragon Racing - Scoreboard - Race Complete Time -Silver Fract 1
	[2038] = true, -- Dragon Racing - Scoreboard - Race Complete Time - Gold Fract 1
	[2039] = true, -- Dragon Racing - Scoreboard - Personal Best - Waking Shores 1
	[2040] = true, -- Dragon Racing - Scoreboard - Personal Best Time
	[2041] = true, -- Dragon Racing - Scoreboard - Personal Best Time - Fraction 1
	[2042] = true, -- Dragon Racing - Personal Best Record - Waking Shores 01 Easy
	[2043] = true, -- Dragon Racing - Personal Best Record - Waking Shores 01 Medium
	[2044] = true, -- Dragon Racing - Personal Best Record - Waking Shores 01 Hard
	[2046] = true, -- Dragon Racing - Personal Best Record - Waking Shores 07 Easy
	[2047] = true, -- Dragon Racing - Personal Best Record - Waking Shores 07 Hard
	[2048] = true, -- Dragon Racing - Personal Best Record - Waking Shores 02 Easy
	[2049] = true, -- Dragon Racing - Personal Best Record - Waking Shores 02 Hard
	[2050] = true, -- Dragon Racing - Personal Best Record - Waking Shores 08 Easy
	[2051] = true, -- Dragon Racing - Personal Best Record - Waking Shores 08 Hard
	[2052] = true, -- Dragon Racing - Personal Best Record - Waking Shores 03 Easy
	[2053] = true, -- Dragon Racing - Personal Best Record - Waking Shores 03 Hard
	[2054] = true, -- Dragon Racing - Personal Best Record - Waking Shores 04 Easy
	[2055] = true, -- Dragon Racing - Personal Best Record - Waking Shores 04 Hard
	[2056] = true, -- Dragon Racing - Personal Best Record - Waking Shores 05 Easy
	[2057] = true, -- Dragon Racing - Personal Best Record - Waking Shores 05 Hard
	[2058] = true, -- Dragon Racing - Personal Best Record - Waking Shores 06 Easy
	[2059] = true, -- Dragon Racing - Personal Best Record - Waking Shores 06 Hard
	[2060] = true, -- Dragon Racing - Personal Best Record - Ohn'ahran Plains 01 Easy
	[2061] = true, -- Dragon Racing - Personal Best Record - Ohn'ahran Plains 01 Hard
	[2062] = true, -- Dragon Racing - Personal Best Record - Ohn'ahran Plains 02 Easy
	[2063] = true, -- Dragon Racing - Personal Best Record - Ohn'ahran Plains 02 Hard
	[2064] = true, -- Dragon Racing - Personal Best Record - Ohn'ahran Plains 03 Easy
	[2065] = true, -- Dragon Racing - Personal Best Record - Ohn'ahran Plains 03 Hard
	[2066] = true, -- Dragon Racing - Personal Best Record - Ohn'ahran Plains 04 Easy
	[2067] = true, -- Dragon Racing - Personal Best Record - Ohn'ahran Plains 04 Hard
	[2069] = true, -- Dragon Racing - Personal Best Record - Ohn'ahran Plains D05 Easy
	[2070] = true, -- Dragon Racing - Personal Best Record - Ohn'ahran Plains D06 Easy
	[2074] = true, -- Dragon Racing - Personal Best Record - Azure Span 01 Easy
	[2075] = true, -- Dragon Racing - Personal Best Record - Azure Span 01 Hard
	[2076] = true, -- Dragon Racing - Personal Best Record - Azure Span 02 Easy
	[2077] = true, -- Dragon Racing - Personal Best Record - Azure Span 02 Hard
	[2078] = true, -- Dragon Racing - Personal Best Record - Azure Span 03 Easy
	[2079] = true, -- Dragon Racing - Personal Best Record - Azure Span 03 Hard
	[2080] = true, -- Dragon Racing - Personal Best Record - Thaldraszus 01 Easy
	[2081] = true, -- Dragon Racing - Personal Best Record - Thaldraszus 01 Hard
	[2082] = true, -- Dragon Racing - Personal Best Record - Waking Shores MP 1
	[2083] = true, -- Dragon Racing - Personal Best Record - Azure Span 04 Easy
	[2084] = true, -- Dragon Racing - Personal Best Record - Azure Span 04 Hard
	[2085] = true, -- Dragon Racing - Personal Best Record - Azure Span 05 Easy
	[2086] = true, -- Dragon Racing - Personal Best Record - Azure Span 05 Hard
	[2087] = true, -- Renown-Iskaara Tuskarr
	[2088] = true, -- Renown-Valdrakken
	[2089] = true, -- Dragon Racing - Personal Best Record - Azure Span 06 Easy
	[2090] = true, -- Dragon Racing - Personal Best Record - Azure Span 06 Hard
	[2091] = true, -- Dragon Racing - Tracking [DNT]
	[2092] = true, -- Dragon Racing - Personal Best Record - Thaldraszus 02 Easy
	[2093] = true, -- Dragon Racing - Personal Best Record - Thaldraszus 02 Hard
	[2094] = true, -- [DNT] AC Major Faction Test Renown
	[2095] = true, -- Dragon Racing - Personal Best Record - Thaldraszus MP 1
	[2096] = true, -- Dragon Racing - Personal Best Record - Thaldraszus 03 Easy
	[2097] = true, -- Dragon Racing - Personal Best Record - Thaldraszus 03 Hard
	[2098] = true, -- Dragon Racing - Personal Best Record - Thaldraszus 04 Easy
	[2099] = true, -- Dragon Racing - Personal Best Record - Thaldraszus 04 Hard
	[2100] = true, -- Dragon Racing - Versioning [DNT]
	[2101] = true, -- Dragon Racing - Personal Best Record - Thaldraszus 05 Easy
	[2102] = true, -- Dragon Racing - Personal Best Record - Thaldraszus 05 Hard
	[2103] = true, -- Dragon Racing - Personal Best Record - Thaldraszus 06 Easy
	[2104] = true, -- Dragon Racing - Personal Best Record - Thaldraszus 06 Hard
	[2106] = true, -- Valdrakken Accord
	[2107] = true, -- Artisan's Consortium - Dragon Isles Branch
	[2108] = true, -- Maruuk Centaur
	[2109] = true, -- Iskaara Tuskarr
	[2110] = true, -- Dragon Racing - Personal Best Record - Ohn'ahran Plains MP 1
	[2111] = true, -- Dragon Racing - Personal Best Record - Azure Span MP 1
	[2113] = true, -- Tuskarr - Fishing Net - Location 01 - Net 01 - Loot
	[2114] = true, -- Tuskarr - Fishing Net - Location 01 - Net 04 (Quest) - Loot
	[2115] = true, -- Tuskarr - Fishing Net - Location 01 - Net 02 - Loot
	[2116] = true, -- Tuskarr - Fishing Net - Location 01 - Net 03 - Loot
	[2119] = true, -- Dragon Racing - Personal Best Record - Ohn'ahran Plains 07 Easy
	[2120] = true, -- Dragon Racing - Personal Best Record - Ohn'ahran Plains 07 Hard
	[2124] = true, -- Dragon Racing - Scoreboard - Race Complete Time - Fraction 10
	[2125] = true, -- Dragon Racing - Scoreboard - Race Complete Time - Fraction 100
	[2126] = true, -- Dragon Racing - Scoreboard - Race Complete Time -Silver Fract 10
	[2128] = true, -- Dragon Racing - Scoreboard - Race Complete Time -Silver Fract100
	[2129] = true, -- Dragon Racing - Scoreboard - Race Complete Time - Gold Fract 10
	[2130] = true, -- Dragon Racing - Scoreboard - Race Complete Time - Gold Fract 100
	[2131] = true, -- Dragon Racing - Scoreboard - Personal Best Time - Fraction 10
	[2132] = true, -- Dragon Racing - Scoreboard - Personal Best Time - Fraction 100
	[2133] = true, -- Dragonriding - Accepting Passengers [DNT]
	[2135] = true, -- Tuskarr - Fishing Net - Location 02 - Net 01 - Loot
	[2136] = true, -- Tuskarr - Fishing Net - Location 02 - Net 02 - Loot
	[2137] = true, -- Tuskarr - Fishing Net - Location 03 - Net 01 - Loot
	[2138] = true, -- Tuskarr - Fishing Net - Location 03 - Net 02 - Loot
	[2139] = true, -- Tuskarr - Fishing Net - Location 04 - Net 01 - Loot
	[2140] = true, -- Tuskarr - Fishing Net - Location 04 - Net 02 - Loot
	[2141] = true, -- Tuskarr - Fishing Net - Location 05 - Net 01 - Loot
	[2142] = true, -- Tuskarr - Fishing Net - Location 05 - Net 02 - Loot
	[2148] = true, -- Red Whelp (Fire Shot)
	[2149] = true, -- Red Whelp (Lobbing Fire Nova)
	[2150] = true, -- Red Whelp (Curing Whiff)
	[2151] = true, -- Red Whelp (Mending Breath)
	[2152] = true, -- Red Whelp (Sleepy Ruby Warmth)
	[2153] = true, -- Red Whelp (Under Red Wings)
	[2154] = true, -- Dragon Racing - Personal Best Record - Waking Shores 01 Reverse
	[2155] = true, -- Dragon Racing - Best Time Display - Whole
	[2156] = true, -- Dragon Racing - Best Time Display - Fraction 1
	[2157] = true, -- Dragon Racing - Best Time Display - Fraction 10
	[2158] = true, -- Dragon Racing - Best Time Display - Fraction 100
	[2159] = true, -- Dragon Racing - Best Time Display - Advanced - Whole
	[2160] = true, -- Dragon Racing - Best Time Display - Advanced - Fraction 1
	[2161] = true, -- Dragon Racing - Best Time Display - Advanced - Fraction 10
	[2162] = true, -- Dragon Racing - Best Time Display - Advanced - Fraction 100
	[2165] = true, -- Profession - Public Order Capacity - Blacksmithing
	[2166] = true, -- Renascent Lifeblood
	[2167] = true, -- Catalyst Charges
	[2169] = true, -- Profession - Public Order Capacity - Leatherworking
	[2170] = true, -- Profession - Public Order Capacity - Alchemy
	[2171] = true, -- Profession - Public Order Capacity - Tailoring
	[2172] = true, -- Profession - Public Order Capacity - Engineering
	[2173] = true, -- Profession - Public Order Capacity - Enchanting
	[2174] = true, -- Profession - Public Order Capacity - Jewelcrafting
	[2175] = true, -- Profession - Public Order Capacity - Inscription
	[2176] = true, -- Dragon Racing - Personal Best Record - Waking Shores 02 Reverse
	[2177] = true, -- Dragon Racing - Personal Best Record - Waking Shores 03 Reverse
	[2178] = true, -- Dragon Racing - Personal Best Record - Waking Shores 04 Reverse
	[2179] = true, -- Dragon Racing - Personal Best Record - Waking Shores 05 Reverse
	[2180] = true, -- Dragon Racing - Personal Best Record - Waking Shores 06 Reverse
	[2181] = true, -- Dragon Racing - Personal Best Record - Waking Shores 07 Reverse
	[2182] = true, -- Dragon Racing - Personal Best Record - Waking Shores 08 Reverse
	[2183] = true, -- Dragon Racing - Personal Best Record - Ohn'ahran Plains01Reverse
	[2184] = true, -- Dragon Racing - Personal Best Record - Ohn'ahran Plains02Reverse
	[2185] = true, -- Dragon Racing - Personal Best Record - Ohn'ahran Plains03Reverse
	[2186] = true, -- Dragon Racing - Personal Best Record - Ohn'ahran Plains04Reverse
	[2187] = true, -- Dragon Racing - Personal Best Record - Ohn'ahran Plains07Reverse
	[2188] = true, -- Dragon Racing - Personal Best Record - Azure Span 01 Reverse
	[2189] = true, -- Dragon Racing - Personal Best Record - Azure Span 02 Reverse
	[2190] = true, -- Dragon Racing - Personal Best Record - Azure Span 03 Reverse
	[2191] = true, -- Dragon Racing - Personal Best Record - Azure Span 04 Reverse
	[2192] = true, -- Dragon Racing - Personal Best Record - Azure Span 05 Reverse
	[2193] = true, -- Dragon Racing - Personal Best Record - Azure Span 06 Reverse
	[2194] = true, -- Dragon Racing - Personal Best Record - Thaldraszus 01 Reverse
	[2195] = true, -- Dragon Racing - Personal Best Record - Thaldraszus 02 Reverse
	[2196] = true, -- Dragon Racing - Personal Best Record - Thaldraszus 03 Reverse
	[2197] = true, -- Dragon Racing - Personal Best Record - Thaldraszus 04 Reverse
	[2198] = true, -- Dragon Racing - Personal Best Record - Thaldraszus 05 Reverse
	[2199] = true, -- Dragon Racing - Personal Best Record - Thaldraszus 06 Reverse
	[2201] = true, -- Dragon Racing - Personal Best Record - F Reach 01
	[2202] = true, -- Dragon Racing - Personal Best Record - F Reach 02
	[2203] = true, -- Dragon Racing - Personal Best Record - F Reach 03
	[2204] = true, -- Dragon Racing - Personal Best Record - F Reach 04
	[2205] = true, -- Dragon Racing - Personal Best Record - F Reach 05
	[2206] = true, -- Dragon Racing - Personal Best Record - F Reach 06
	[2207] = true, -- Dragon Racing - Personal Best Record - F Reach 01 Advanced
	[2208] = true, -- Dragon Racing - Personal Best Record - F Reach 02 Advanced
	[2209] = true, -- Dragon Racing - Personal Best Record - F Reach 03 Advanced
	[2210] = true, -- Dragon Racing - Personal Best Record - F Reach 04 Advanced
	[2211] = true, -- Dragon Racing - Personal Best Record - F Reach 05 Advanced
	[2212] = true, -- Dragon Racing - Personal Best Record - F Reach 06 Advanced
	[2213] = true, -- Dragon Racing - Personal Best Record - F Reach 01 Reverse
	[2214] = true, -- Dragon Racing - Personal Best Record - F Reach 02 Reverse
	[2215] = true, -- Dragon Racing - Personal Best Record - F Reach 03 Reverse
	[2216] = true, -- Dragon Racing - Personal Best Record - F Reach 04 Reverse
	[2217] = true, -- Dragon Racing - Personal Best Record - F Reach 05 Reverse
	[2218] = true, -- Dragon Racing - Personal Best Record - F Reach 06 Reverse
	[2224] = true, -- Dragon Racing - Best Time Display - Reverse - Whole
	[2225] = true, -- Dragon Racing - Best Time Display - Reverse - Fraction 1
	[2226] = true, -- Dragon Racing - Best Time Display - Reverse - Fraction 10
	[2227] = true, -- Dragon Racing - Best Time Display - Reverse - Fraction 100
	[2228] = true, -- Tuskarr - Fishing Net - Location 06 - Net 01 - Loot
	[2230] = true, -- Darkmoon Prize Ticket (Void)
	[2231] = true, -- Players
	[2235] = true, -- 10.0 Dragonrider PVP - Whirling Surge Dismounts 10.0.2 [DNT]
	[2236] = true, -- Dragon Racing - Scoreboard - Race Complete Time MS
	[2237] = true, -- 10.0 Dragonrider PVP - Whirling Surge Dismounts 10.0.5 [DNT]
	[2244] = true, -- Forbidden Reach Return - Renown Dailies Completed
	[2246] = true, -- Dragon Racing - Personal Best Record - Z Cavern 01
	[2247] = true, -- Dragon Racing - Personal Best Record - Z Cavern 02
	[2248] = true, -- Dragon Racing - Personal Best Record - Z Cavern 03
	[2249] = true, -- Dragon Racing - Personal Best Record - Z Cavern 04
	[2250] = true, -- Dragon Racing - Personal Best Record - Z Cavern 05
	[2251] = true, -- Dragon Racing - Personal Best Record - Z Cavern 06
	[2252] = true, -- Dragon Racing - Personal Best Record - Z Cavern 01 Advanced
	[2253] = true, -- Dragon Racing - Personal Best Record - Z Cavern 02 Advanced
	[2254] = true, -- Dragon Racing - Personal Best Record - Z Cavern 03 Advanced
	[2255] = true, -- Dragon Racing - Personal Best Record - Z Cavern 04 Advanced
	[2256] = true, -- Dragon Racing - Personal Best Record - Z Cavern 05 Advanced
	[2257] = true, -- Dragon Racing - Personal Best Record - Z Cavern 06 Advanced
	[2258] = true, -- Dragon Racing - Personal Best Record - Z Cavern 01 Reverse
	[2259] = true, -- Dragon Racing - Personal Best Record - Z Cavern 02 Reverse
	[2260] = true, -- Dragon Racing - Personal Best Record - Z Cavern 03 Reverse
	[2261] = true, -- Dragon Racing - Personal Best Record - Z Cavern 04 Reverse
	[2262] = true, -- Dragon Racing - Personal Best Record - Z Cavern 05 Reverse
	[2263] = true, -- Dragon Racing - Personal Best Record - Z Cavern 06 Reverse
	[2264] = true, -- Account HWM - Helm [DNT]
	[2265] = true, -- Account HWM - Neck [DNT]
	[2266] = true, -- Account HWM - Shoulders [DNT]
	[2267] = true, -- Account HWM - Chest [DNT]
	[2268] = true, -- Account HWM - Waist [DNT]
	[2269] = true, -- Account HWM - Legs [DNT]
	[2270] = true, -- Account HWM - Feet [DNT]
	[2271] = true, -- Account HWM - Wrist [DNT]
	[2272] = true, -- Account HWM - Hands [DNT]
	[2273] = true, -- Account HWM - Ring [DNT]
	[2274] = true, -- Account HWM - Trinket [DNT]
	[2275] = true, -- Account HWM - Cloak [DNT]
	[2276] = true, -- Account HWM - Two Hand [DNT]
	[2277] = true, -- Account HWM - Main Hand [DNT]
	[2278] = true, -- Account HWM - One Hand [DNT]
	[2279] = true, -- Account HWM - One Hand (Second) [DNT]
	[2280] = true, -- Account HWM - Off Hand [DNT]
	[2281] = true, -- Dragon Racing - Personal Best Record - Test
	[2312] = true, -- Dragon Racing - Personal Best Record - Kalimdor 01
	[2313] = true, -- Dragon Racing - Personal Best Record - Kalimdor 02
	[2314] = true, -- Dragon Racing - Personal Best Record - Kalimdor 03
	[2315] = true, -- Dragon Racing - Personal Best Record - Kalimdor 04
	[2316] = true, -- Dragon Racing - Personal Best Record - Kalimdor 05
	[2317] = true, -- Dragon Racing - Personal Best Record - Kalimdor 06
	[2318] = true, -- Dragon Racing - Personal Best Record - Kalimdor 07
	[2319] = true, -- Dragon Racing - Personal Best Record - Kalimdor 08
	[2320] = true, -- Dragon Racing - Personal Best Record - Kalimdor 09
	[2321] = true, -- Dragon Racing - Personal Best Record - Kalimdor 10
	[2322] = true, -- Dragon Racing - Personal Best Record - Kalimdor 11
	[2323] = true, -- Dragon Racing - Personal Best Record - Kalimdor 12
	[2324] = true, -- Dragon Racing - Personal Best Record - Kalimdor 13
	[2325] = true, -- Dragon Racing - Personal Best Record - Kalimdor 14
	[2326] = true, -- Dragon Racing - Personal Best Record - Kalimdor 15
	[2327] = true, -- Dragon Racing - Personal Best Record - Kalimdor 16
	[2328] = true, -- Dragon Racing - Personal Best Record - Kalimdor 17
	[2329] = true, -- Dragon Racing - Personal Best Record - Kalimdor 18
	[2330] = true, -- Dragon Racing - Personal Best Record - Kalimdor 19
	[2331] = true, -- Dragon Racing - Personal Best Record - Kalimdor 20
	[2332] = true, -- Dragon Racing - Personal Best Record - Kalimdor 21
	[2333] = true, -- Dragon Racing - Personal Best Record - Kalimdor 22
	[2334] = true, -- Dragon Racing - Personal Best Record - Kalimdor 23
	[2335] = true, -- Dragon Racing - Personal Best Record - Kalimdor 24
	[2336] = true, -- Dragon Racing - Personal Best Record - Kalimdor 25
	[2337] = true, -- Dragon Racing - Personal Best Record - Kalimdor 26
	[2338] = true, -- Dragon Racing - Personal Best Record - Kalimdor 27
	[2339] = true, -- Dragon Racing - Personal Best Record - Kalimdor 28
	[2340] = true, -- Dragon Racing - Personal Best Record - Kalimdor 29
	[2341] = true, -- Dragon Racing - Personal Best Record - Kalimdor 30
	[2342] = true, -- Dragon Racing - Personal Best Record - Kalimdor 01 Advanced
	[2343] = true, -- Dragon Racing - Personal Best Record - Kalimdor 02 Advanced
	[2344] = true, -- Dragon Racing - Personal Best Record - Kalimdor 03 Advanced
	[2345] = true, -- Dragon Racing - Personal Best Record - Kalimdor 04 Advanced
	[2346] = true, -- Dragon Racing - Personal Best Record - Kalimdor 05 Advanced
	[2347] = true, -- Dragon Racing - Personal Best Record - Kalimdor 06 Advanced
	[2348] = true, -- Dragon Racing - Personal Best Record - Kalimdor 07 Advanced
	[2349] = true, -- Dragon Racing - Personal Best Record - Kalimdor 08 Advanced
	[2350] = true, -- Dragon Racing - Personal Best Record - Kalimdor 09 Advanced
	[2351] = true, -- Dragon Racing - Personal Best Record - Kalimdor 10 Advanced
	[2352] = true, -- Dragon Racing - Personal Best Record - Kalimdor 11 Advanced
	[2353] = true, -- Dragon Racing - Personal Best Record - Kalimdor 12 Advanced
	[2354] = true, -- Dragon Racing - Personal Best Record - Kalimdor 13 Advanced
	[2355] = true, -- Dragon Racing - Personal Best Record - Kalimdor 14 Advanced
	[2356] = true, -- Dragon Racing - Personal Best Record - Kalimdor 15 Advanced
	[2357] = true, -- Dragon Racing - Personal Best Record - Kalimdor 16 Advanced
	[2358] = true, -- Dragon Racing - Personal Best Record - Kalimdor 17 Advanced
	[2359] = true, -- Dragon Racing - Personal Best Record - Kalimdor 18 Advanced
	[2360] = true, -- Dragon Racing - Personal Best Record - Kalimdor 19 Advanced
	[2361] = true, -- Dragon Racing - Personal Best Record - Kalimdor 20 Advanced
	[2362] = true, -- Dragon Racing - Personal Best Record - Kalimdor 21 Advanced
	[2363] = true, -- Dragon Racing - Personal Best Record - Kalimdor 22 Advanced
	[2364] = true, -- Dragon Racing - Personal Best Record - Kalimdor 23 Advanced
	[2365] = true, -- Dragon Racing - Personal Best Record - Kalimdor 24 Advanced
	[2366] = true, -- Dragon Racing - Personal Best Record - Kalimdor 25 Advanced
	[2367] = true, -- Dragon Racing - Personal Best Record - Kalimdor 26 Advanced
	[2368] = true, -- Dragon Racing - Personal Best Record - Kalimdor 27 Advanced
	[2369] = true, -- Dragon Racing - Personal Best Record - Kalimdor 28 Advanced
	[2370] = true, -- Dragon Racing - Personal Best Record - Kalimdor 29 Advanced
	[2371] = true, -- Dragon Racing - Personal Best Record - Kalimdor 30 Advanced
	[2372] = true, -- Dragon Racing - Personal Best Record - Kalimdor 01 Reverse
	[2373] = true, -- Dragon Racing - Personal Best Record - Kalimdor 02 Reverse
	[2374] = true, -- Dragon Racing - Personal Best Record - Kalimdor 03 Reverse
	[2375] = true, -- Dragon Racing - Personal Best Record - Kalimdor 04 Reverse
	[2376] = true, -- Dragon Racing - Personal Best Record - Kalimdor 05 Reverse
	[2377] = true, -- Dragon Racing - Personal Best Record - Kalimdor 06 Reverse
	[2378] = true, -- Dragon Racing - Personal Best Record - Kalimdor 07 Reverse
	[2379] = true, -- Dragon Racing - Personal Best Record - Kalimdor 08 Reverse
	[2380] = true, -- Dragon Racing - Personal Best Record - Kalimdor 09 Reverse
	[2381] = true, -- Dragon Racing - Personal Best Record - Kalimdor 10 Reverse
	[2382] = true, -- Dragon Racing - Personal Best Record - Kalimdor 11 Reverse
	[2383] = true, -- Dragon Racing - Personal Best Record - Kalimdor 12 Reverse
	[2384] = true, -- Dragon Racing - Personal Best Record - Kalimdor 13 Reverse
	[2385] = true, -- Dragon Racing - Personal Best Record - Kalimdor 14 Reverse
	[2386] = true, -- Dragon Racing - Personal Best Record - Kalimdor 15 Reverse
	[2387] = true, -- Dragon Racing - Personal Best Record - Kalimdor 16 Reverse
	[2388] = true, -- Dragon Racing - Personal Best Record - Kalimdor 17 Reverse
	[2389] = true, -- Dragon Racing - Personal Best Record - Kalimdor 18 Reverse
	[2390] = true, -- Dragon Racing - Personal Best Record - Kalimdor 19 Reverse
	[2391] = true, -- Dragon Racing - Personal Best Record - Kalimdor 20 Reverse
	[2392] = true, -- Dragon Racing - Personal Best Record - Kalimdor 21 Reverse
	[2393] = true, -- Dragon Racing - Personal Best Record - Kalimdor 22 Reverse
	[2394] = true, -- Dragon Racing - Personal Best Record - Kalimdor 23 Reverse
	[2395] = true, -- Dragon Racing - Personal Best Record - Kalimdor 24 Reverse
	[2396] = true, -- Dragon Racing - Personal Best Record - Kalimdor 25 Reverse
	[2397] = true, -- Dragon Racing - Personal Best Record - Kalimdor 26 Reverse
	[2398] = true, -- Dragon Racing - Personal Best Record - Kalimdor 27 Reverse
	[2399] = true, -- Dragon Racing - Personal Best Record - Kalimdor 28 Reverse
	[2400] = true, -- Dragon Racing - Personal Best Record - Kalimdor 29 Reverse
	[2401] = true, -- Dragon Racing - Personal Best Record - Kalimdor 30 Reverse
	[2402] = true, -- Renown - Loamm Niffen
	[2408] = true, -- Bonus Flightstones
	[2409] = true, -- Whelpling Crest Fragment Tracker [DNT]
	[2410] = true, -- Drake Crest Fragment Tracker [DNT]
	[2411] = true, -- Wyrm Crest Fragment Tracker [DNT]
	[2412] = true, -- Aspect Crest Fragment Tracker [DNT]
	[2413] = true, -- 10.1 Professions - Personal Tracker - S2 Spark Drops (Hidden)
	[2414] = true, -- 10.1.5 Whelp Daycare - Whelp Racing - Black - 001 (OJF)
	[2415] = true, -- 10.1.5 Whelp Daycare - Whelp Racing - Blue - 001 (OJF)
	[2416] = true, -- 10.1.5 Whelp Daycare - Whelp Racing - Bronze - 001 (OJF)
	[2417] = true, -- 10.1.5 Whelp Daycare - Whelp Racing - Green - 001 (OJF)
	[2418] = true, -- 10.1.5 Whelp Daycare - Whelp Racing - Red - 001 (OJF)
	[2419] = true, -- Test Currency Main [DNT]
	[2420] = true, -- Loamm Niffen
	[2421] = true, -- Dragon Racing - Personal Best Record - Waking Shores 01 Challeng
	[2422] = true, -- Dragon Racing - Personal Best Record - Waking Shores 01 ChallenR
	[2423] = true, -- Dragon Racing - Personal Best Record - Waking Shores 02 Challeng
	[2424] = true, -- Dragon Racing - Personal Best Record - Waking Shores 02 ChallenR
	[2425] = true, -- Dragon Racing - Personal Best Record - Waking Shores 03 Challeng
	[2426] = true, -- Dragon Racing - Personal Best Record - Waking Shores 03 ChallenR
	[2427] = true, -- Dragon Racing - Personal Best Record - Waking Shores 04 Challeng
	[2428] = true, -- Dragon Racing - Personal Best Record - Waking Shores 04 ChallenR
	[2429] = true, -- Dragon Racing - Personal Best Record - Waking Shores 05 Challeng
	[2430] = true, -- Dragon Racing - Personal Best Record - Waking Shores 05 ChallenR
	[2431] = true, -- Dragon Racing - Personal Best Record - Waking Shores 06 Challeng
	[2432] = true, -- Dragon Racing - Personal Best Record - Waking Shores 06 ChallenR
	[2433] = true, -- Dragon Racing - Personal Best Record - Waking Shores 07 Challeng
	[2434] = true, -- Dragon Racing - Personal Best Record - Waking Shores 07 ChallenR
	[2435] = true, -- Dragon Racing - Personal Best Record - Waking Shores 08 Challeng
	[2436] = true, -- Dragon Racing - Personal Best Record - Waking Shores 08 ChallenR
	[2437] = true, -- Dragon Racing - Personal Best Record - Ohn'ahran Plains 01 Chall
	[2439] = true, -- Dragon Racing - Personal Best Record - Ohn'ahran Plains 01 ChalR
	[2440] = true, -- Dragon Racing - Personal Best Record - Ohn'ahran Plains 02 Chall
	[2441] = true, -- Dragon Racing - Personal Best Record - Ohn'ahran Plains 02 ChalR
	[2442] = true, -- Dragon Racing - Personal Best Record - Ohn'ahran Plains 03 Chall
	[2443] = true, -- Dragon Racing - Personal Best Record - Ohn'ahran Plains 03 ChalR
	[2444] = true, -- Dragon Racing - Personal Best Record - Ohn'ahran Plains 04 Chall
	[2445] = true, -- Dragon Racing - Personal Best Record - Ohn'ahran Plains 04 ChalR
	[2446] = true, -- Dragon Racing - Personal Best Record - Ohn'ahran Plains 05 Chall
	[2447] = true, -- Dragon Racing - Personal Best Record - Ohn'ahran Plains 06 Chall
	[2448] = true, -- Dragon Racing - Personal Best Record - Ohn'ahran Plains 07 Chall
	[2449] = true, -- Dragon Racing - Personal Best Record - Ohn'ahran Plains 07 ChalR
	[2450] = true, -- Dragon Racing - Personal Best Record - Azure Span 01 Challenge
	[2451] = true, -- Dragon Racing - Personal Best Record - Azure Span 01 Challenge R
	[2452] = true, -- Dragon Racing - Personal Best Record - Azure Span 02 Challenge
	[2453] = true, -- Dragon Racing - Personal Best Record - Azure Span 02 Challenge R
	[2454] = true, -- Dragon Racing - Personal Best Record - Azure Span 03 Challenge
	[2455] = true, -- Dragon Racing - Personal Best Record - Azure Span 03 Challenge R
	[2456] = true, -- Dragon Racing - Personal Best Record - Azure Span 04 Challenge
	[2457] = true, -- Dragon Racing - Personal Best Record - Azure Span 04 Challenge R
	[2458] = true, -- Dragon Racing - Personal Best Record - Azure Span 05 Challenge
	[2459] = true, -- Dragon Racing - Personal Best Record - Azure Span 05 Challenge R
	[2460] = true, -- Dragon Racing - Personal Best Record - Azure Span 06 Challenge
	[2461] = true, -- Dragon Racing - Personal Best Record - Azure Span 06 Challenge R
	[2462] = true, -- Dragon Racing - Personal Best Record - Thaldraszus 01 Challenge
	[2463] = true, -- Dragon Racing - Personal Best Record - Thaldraszus 01 ChallengeR
	[2464] = true, -- Dragon Racing - Personal Best Record - Thaldraszus 02 Challenge
	[2465] = true, -- Dragon Racing - Personal Best Record - Thaldraszus 02 ChallengeR
	[2466] = true, -- Dragon Racing - Personal Best Record - Thaldraszus 03 Challenge
	[2467] = true, -- Dragon Racing - Personal Best Record - Thaldraszus 03 ChallengeR
	[2468] = true, -- Dragon Racing - Personal Best Record - Thaldraszus 04 Challenge
	[2469] = true, -- Dragon Racing - Personal Best Record - Thaldraszus 04 ChallengeR
	[2470] = true, -- Dragon Racing - Personal Best Record - Thaldraszus 05 Challenge
	[2471] = true, -- Dragon Racing - Personal Best Record - Thaldraszus 05 ChallengeR
	[2472] = true, -- Dragon Racing - Personal Best Record - Thaldraszus 06 Challenge
	[2473] = true, -- Dragon Racing - Personal Best Record - Thaldraszus 06 ChallengeR
	[2474] = true, -- Dragon Racing - Personal Best Record - F Reach 01 Challenge
	[2475] = true, -- Dragon Racing - Personal Best Record - F Reach 01 Challenge R
	[2476] = true, -- Dragon Racing - Personal Best Record - F Reach 02 Challenge
	[2477] = true, -- Dragon Racing - Personal Best Record - F Reach 02 Challenge R
	[2478] = true, -- Dragon Racing - Personal Best Record - F Reach 03 Challenge
	[2479] = true, -- Dragon Racing - Personal Best Record - F Reach 03 Challenge R
	[2480] = true, -- Dragon Racing - Personal Best Record - F Reach 04 Challenge
	[2481] = true, -- Dragon Racing - Personal Best Record - F Reach 04 Challenge R
	[2482] = true, -- Dragon Racing - Personal Best Record - F Reach 05 Challenge
	[2483] = true, -- Dragon Racing - Personal Best Record - F Reach 05 Challenge R
	[2484] = true, -- Dragon Racing - Personal Best Record - F Reach 06 Challenge
	[2485] = true, -- Dragon Racing - Personal Best Record - F Reach 06 Challenge R
	[2486] = true, -- Dragon Racing - Personal Best Record - Z Cavern 01 Challenge
	[2487] = true, -- Dragon Racing - Personal Best Record - Z Cavern 01 Challenge R
	[2488] = true, -- Dragon Racing - Personal Best Record - Z Cavern 02 Challenge
	[2489] = true, -- Dragon Racing - Personal Best Record - Z Cavern 02 Challenge R
	[2490] = true, -- Dragon Racing - Personal Best Record - Z Cavern 03 Challenge
	[2491] = true, -- Dragon Racing - Personal Best Record - Z Cavern 03 Challenge R
	[2492] = true, -- Dragon Racing - Personal Best Record - Z Cavern 04 Challenge
	[2493] = true, -- Dragon Racing - Personal Best Record - Z Cavern 04 Challenge R
	[2494] = true, -- Dragon Racing - Personal Best Record - Z Cavern 05 Challenge
	[2495] = true, -- Dragon Racing - Personal Best Record - Z Cavern 05 Challenge R
	[2496] = true, -- Dragon Racing - Personal Best Record - Z Cavern 06 Challenge
	[2497] = true, -- Dragon Racing - Personal Best Record - Z Cavern 06 Challenge R
	[2498] = true, -- Dragon Racing - Personal Best Record - Kalimdor 01 Challenge
	[2499] = true, -- Dragon Racing - Personal Best Record - Kalimdor 01 Challenge R
	[2500] = true, -- Dragon Racing - Personal Best Record - Kalimdor 02 Challenge
	[2501] = true, -- Dragon Racing - Personal Best Record - Kalimdor 02 Challenge R
	[2502] = true, -- Dragon Racing - Personal Best Record - Kalimdor 03 Challenge
	[2503] = true, -- Dragon Racing - Personal Best Record - Kalimdor 03 Challenge R
	[2504] = true, -- Dragon Racing - Personal Best Record - Kalimdor 04 Challenge
	[2505] = true, -- Dragon Racing - Personal Best Record - Kalimdor 04 Challenge R
	[2506] = true, -- Dragon Racing - Personal Best Record - Kalimdor 05 Challenge
	[2507] = true, -- Dragon Racing - Personal Best Record - Kalimdor 05 Challenge R
	[2508] = true, -- Dragon Racing - Personal Best Record - Kalimdor 06 Challenge
	[2509] = true, -- Dragon Racing - Personal Best Record - Kalimdor 06 Challenge R
	[2510] = true, -- Dragon Racing - Personal Best Record - Kalimdor 07 Challenge
	[2511] = true, -- Dragon Racing - Personal Best Record - Kalimdor 07 Challenge R
	[2512] = true, -- Dragon Racing - Personal Best Record - Kalimdor 08 Challenge
	[2513] = true, -- Dragon Racing - Personal Best Record - Kalimdor 08 Challenge R
	[2514] = true, -- Dragon Racing - Personal Best Record - Kalimdor 09 Challenge
	[2515] = true, -- Dragon Racing - Personal Best Record - Kalimdor 09 Challenge R
	[2516] = true, -- Dragon Racing - Personal Best Record - Kalimdor 10 Challenge
	[2517] = true, -- Dragon Racing - Personal Best Record - Kalimdor 10 Challenge R
	[2518] = true, -- Dragon Racing - Personal Best Record - Kalimdor 11 Challenge
	[2519] = true, -- Dragon Racing - Personal Best Record - Kalimdor 11 Challenge R
	[2520] = true, -- Dragon Racing - Personal Best Record - Kalimdor 12 Challenge
	[2521] = true, -- Dragon Racing - Personal Best Record - Kalimdor 12 Challenge R
	[2522] = true, -- Dragon Racing - Personal Best Record - Kalimdor 13 Challenge
	[2523] = true, -- Dragon Racing - Personal Best Record - Kalimdor 13 Challenge R
	[2524] = true, -- Dragon Racing - Personal Best Record - Kalimdor 14 Challenge
	[2525] = true, -- Dragon Racing - Personal Best Record - Kalimdor 14 Challenge R
	[2526] = true, -- Dragon Racing - Personal Best Record - Kalimdor 15 Challenge
	[2527] = true, -- Dragon Racing - Personal Best Record - Kalimdor 15 Challenge R
	[2528] = true, -- Dragon Racing - Personal Best Record - Kalimdor 16 Challenge
	[2529] = true, -- Dragon Racing - Personal Best Record - Kalimdor 16 Challenge R
	[2533] = true, -- Renascent Shadowflame
	[2536] = true, -- Dragon Racing - Personal Best Record - E Kingdoms 01
	[2537] = true, -- Dragon Racing - Personal Best Record - E Kingdoms 02
	[2538] = true, -- Dragon Racing - Personal Best Record - E Kingdoms 03
	[2539] = true, -- Dragon Racing - Personal Best Record - E Kingdoms 04
	[2540] = true, -- Dragon Racing - Personal Best Record - E Kingdoms 05
	[2541] = true, -- Dragon Racing - Personal Best Record - E Kingdoms 06
	[2542] = true, -- Dragon Racing - Personal Best Record - E Kingdoms 07
	[2543] = true, -- Dragon Racing - Personal Best Record - E Kingdoms 08
	[2544] = true, -- Dragon Racing - Personal Best Record - E Kingdoms 09
	[2545] = true, -- Dragon Racing - Personal Best Record - E Kingdoms 10
	[2546] = true, -- Dragon Racing - Personal Best Record - E Kingdoms 11
	[2547] = true, -- Dragon Racing - Personal Best Record - E Kingdoms 12
	[2548] = true, -- Dragon Racing - Personal Best Record - E Kingdoms 13
	[2549] = true, -- Dragon Racing - Personal Best Record - E Kingdoms 14
	[2550] = true, -- Dragon Racing - Personal Best Record - E Kingdoms 15
	[2551] = true, -- Dragon Racing - Personal Best Record - E Kingdoms 16
	[2552] = true, -- Dragon Racing - Personal Best Record - E Kingdoms 01 Advanced
	[2553] = true, -- Dragon Racing - Personal Best Record - E Kingdoms 02 Advanced
	[2554] = true, -- Dragon Racing - Personal Best Record - E Kingdoms 03 Advanced
	[2555] = true, -- Dragon Racing - Personal Best Record - E Kingdoms 04 Advanced
	[2556] = true, -- Dragon Racing - Personal Best Record - E Kingdoms 05 Advanced
	[2557] = true, -- Dragon Racing - Personal Best Record - E Kingdoms 06 Advanced
	[2558] = true, -- Dragon Racing - Personal Best Record - E Kingdoms 07 Advanced
	[2559] = true, -- Dragon Racing - Personal Best Record - E Kingdoms 08 Advanced
	[2560] = true, -- Dragon Racing - Personal Best Record - E Kingdoms 09 Advanced
	[2561] = true, -- Dragon Racing - Personal Best Record - E Kingdoms 10 Advanced
	[2562] = true, -- Dragon Racing - Personal Best Record - E Kingdoms 11 Advanced
	[2563] = true, -- Dragon Racing - Personal Best Record - E Kingdoms 12 Advanced
	[2564] = true, -- Dragon Racing - Personal Best Record - E Kingdoms 13 Advanced
	[2565] = true, -- Dragon Racing - Personal Best Record - E Kingdoms 14 Advanced
	[2566] = true, -- Dragon Racing - Personal Best Record - E Kingdoms 15 Advanced
	[2567] = true, -- Dragon Racing - Personal Best Record - E Kingdoms 16 Advanced
	[2568] = true, -- Dragon Racing - Personal Best Record - E Kingdoms 01 Reverse
	[2569] = true, -- Dragon Racing - Personal Best Record - E Kingdoms 02 Reverse
	[2570] = true, -- Dragon Racing - Personal Best Record - E Kingdoms 03 Reverse
	[2571] = true, -- Dragon Racing - Personal Best Record - E Kingdoms 04 Reverse
	[2572] = true, -- Dragon Racing - Personal Best Record - E Kingdoms 05 Reverse
	[2573] = true, -- Dragon Racing - Personal Best Record - E Kingdoms 06 Reverse
	[2574] = true, -- Dragon Racing - Personal Best Record - E Kingdoms 07 Reverse
	[2575] = true, -- Dragon Racing - Personal Best Record - E Kingdoms 08 Reverse
	[2576] = true, -- Dragon Racing - Personal Best Record - E Kingdoms 09 Reverse
	[2577] = true, -- Dragon Racing - Personal Best Record - E Kingdoms 10 Reverse
	[2578] = true, -- Dragon Racing - Personal Best Record - E Kingdoms 11 Reverse
	[2579] = true, -- Dragon Racing - Personal Best Record - E Kingdoms 12 Reverse
	[2580] = true, -- Dragon Racing - Personal Best Record - E Kingdoms 13 Reverse
	[2581] = true, -- Dragon Racing - Personal Best Record - E Kingdoms 14 Reverse
	[2582] = true, -- Dragon Racing - Personal Best Record - E Kingdoms 15 Reverse
	[2583] = true, -- Dragon Racing - Personal Best Record - E Kingdoms 16 Reverse
	[2595] = true, -- Dragon Racing - Medal Widget - Normal [DNT]
	[2596] = true, -- Dragon Racing - Medal Widget - Advanced [DNT]
	[2597] = true, -- Dragon Racing - Medal Widget - Reverse [DNT]
	[2598] = true, -- Dragon Racing - Medal Widget - Temp [DNT]
	[2599] = true, -- Dragon Racing - Medal Widget - Temp2 [DNT]
	[2600] = true, -- Dragon Racing - Personal Best Record - Outland 01
	[2601] = true, -- Dragon Racing - Personal Best Record - Outland 02
	[2602] = true, -- Dragon Racing - Personal Best Record - Outland 03
	[2603] = true, -- Dragon Racing - Personal Best Record - Outland 04
	[2604] = true, -- Dragon Racing - Personal Best Record - Outland 05
	[2605] = true, -- Dragon Racing - Personal Best Record - Outland 06
	[2606] = true, -- Dragon Racing - Personal Best Record - Outland 07
	[2607] = true, -- Dragon Racing - Personal Best Record - Outland 08
	[2608] = true, -- Dragon Racing - Personal Best Record - Outland 09
	[2609] = true, -- Dragon Racing - Personal Best Record - Outland 10
	[2610] = true, -- Dragon Racing - Personal Best Record - Outland 11
	[2611] = true, -- Dragon Racing - Personal Best Record - Outland 12
	[2612] = true, -- Dragon Racing - Personal Best Record - Outland 13
	[2613] = true, -- Dragon Racing - Personal Best Record - Outland 14
	[2614] = true, -- Dragon Racing - Personal Best Record - Outland 15
	[2615] = true, -- Dragon Racing - Personal Best Record - Outland 01 Advanced
	[2616] = true, -- Dragon Racing - Personal Best Record - Outland 02 Advanced
	[2617] = true, -- Dragon Racing - Personal Best Record - Outland 03 Advanced
	[2618] = true, -- Dragon Racing - Personal Best Record - Outland 04 Advanced
	[2619] = true, -- Dragon Racing - Personal Best Record - Outland 05 Advanced
	[2620] = true, -- Dragon Racing - Personal Best Record - Outland 06 Advanced
	[2621] = true, -- Dragon Racing - Personal Best Record - Outland 07 Advanced
	[2622] = true, -- Dragon Racing - Personal Best Record - Outland 08 Advanced
	[2623] = true, -- Dragon Racing - Personal Best Record - Outland 09 Advanced
	[2624] = true, -- Dragon Racing - Personal Best Record - Outland 10 Advanced
	[2625] = true, -- Dragon Racing - Personal Best Record - Outland 11 Advanced
	[2626] = true, -- Dragon Racing - Personal Best Record - Outland 12 Advanced
	[2627] = true, -- Dragon Racing - Personal Best Record - Outland 13 Advanced
	[2628] = true, -- Dragon Racing - Personal Best Record - Outland 14 Advanced
	[2629] = true, -- Dragon Racing - Personal Best Record - Outland 15 Advanced
	[2630] = true, -- Dragon Racing - Personal Best Record - Outland 01 Reverse
	[2631] = true, -- Dragon Racing - Personal Best Record - Outland 02 Reverse
	[2632] = true, -- Dragon Racing - Personal Best Record - Outland 03 Reverse
	[2633] = true, -- Dragon Racing - Personal Best Record - Outland 04 Reverse
	[2634] = true, -- Dragon Racing - Personal Best Record - Outland 05 Reverse
	[2635] = true, -- Dragon Racing - Personal Best Record - Outland 06 Reverse
	[2636] = true, -- Dragon Racing - Personal Best Record - Outland 07 Reverse
	[2637] = true, -- Dragon Racing - Personal Best Record - Outland 08 Reverse
	[2638] = true, -- Dragon Racing - Personal Best Record - Outland 09 Reverse
	[2639] = true, -- Dragon Racing - Personal Best Record - Outland 10 Reverse
	[2640] = true, -- Dragon Racing - Personal Best Record - Outland 11 Reverse
	[2641] = true, -- Dragon Racing - Personal Best Record - Outland 12 Reverse
	[2642] = true, -- Dragon Racing - Personal Best Record - Outland 13 Reverse
	[2643] = true, -- Dragon Racing - Personal Best Record - Outland 14 Reverse
	[2644] = true, -- Dragon Racing - Personal Best Record - Outland 15 Reverse
	[2645] = true, -- Soridormi's Recognition
	[2649] = true, -- [DNT] The Currency Formerly Named Dream Ephemera
	[2652] = true, -- Dream Wardens
	[2653] = true, -- Renown - Dream Wardens
	[2654] = true, -- Dragon Racing - Kalimdor Cup Preferred Mount
	[2655] = true, -- Revives
	[2658] = true, -- Dragon Racing - Personal Best Record - Outland 16
	[2659] = true, -- Dragon Racing - Personal Best Record - Outland 17
	[2660] = true, -- Dragon Racing - Personal Best Record - Outland 18
	[2661] = true, -- Dragon Racing - Personal Best Record - Outland 19
	[2662] = true, -- Dragon Racing - Personal Best Record - Outland 20
	[2663] = true, -- Dragon Racing - Personal Best Record - Outland 21
	[2664] = true, -- Dragon Racing - Personal Best Record - Outland 16 Advanced
	[2665] = true, -- Dragon Racing - Personal Best Record - Outland 17 Advanced
	[2666] = true, -- Dragon Racing - Personal Best Record - Outland 18 Advanced
	[2667] = true, -- Dragon Racing - Personal Best Record - Outland 19 Advanced
	[2668] = true, -- Dragon Racing - Personal Best Record - Outland 20 Advanced
	[2669] = true, -- Dragon Racing - Personal Best Record - Outland 21 Advanced
	[2670] = true, -- Dragon Racing - Personal Best Record - Outland 16 Reverse
	[2671] = true, -- Dragon Racing - Personal Best Record - Outland 17 Reverse
	[2672] = true, -- Dragon Racing - Personal Best Record - Outland 18 Reverse
	[2673] = true, -- Dragon Racing - Personal Best Record - Outland 19 Reverse
	[2674] = true, -- Dragon Racing - Personal Best Record - Outland 20 Reverse
	[2675] = true, -- Dragon Racing - Personal Best Record - Outland 21 Reverse
	[2676] = true, -- Dragon Racing - Personal Best Record - Emerald Dream 01
	[2677] = true, -- Dragon Racing - Personal Best Record - Emerald Dream 02
	[2678] = true, -- Dragon Racing - Personal Best Record - Emerald Dream 03
	[2679] = true, -- Dragon Racing - Personal Best Record - Emerald Dream 04
	[2680] = true, -- Dragon Racing - Personal Best Record - Emerald Dream 05
	[2681] = true, -- Dragon Racing - Personal Best Record - Emerald Dream 06
	[2682] = true, -- Dragon Racing - Personal Best Record - Emerald Dream 01 Advanced
	[2683] = true, -- Dragon Racing - Personal Best Record - Emerald Dream 02 Advanced
	[2684] = true, -- Dragon Racing - Personal Best Record - Emerald Dream 03 Advanced
	[2685] = true, -- Dragon Racing - Personal Best Record - Emerald Dream 04 Advanced
	[2686] = true, -- Dragon Racing - Personal Best Record - Emerald Dream 05 Advanced
	[2687] = true, -- Dragon Racing - Personal Best Record - Emerald Dream 06 Advanced
	[2688] = true, -- Dragon Racing - Personal Best Record - Emerald Dream 01 Reverse
	[2689] = true, -- Dragon Racing - Personal Best Record - Emerald Dream 02 Reverse
	[2690] = true, -- Dragon Racing - Personal Best Record - Emerald Dream 03 Reverse
	[2691] = true, -- Dragon Racing - Personal Best Record - Emerald Dream 04 Reverse
	[2692] = true, -- Dragon Racing - Personal Best Record - Emerald Dream 05 Reverse
	[2693] = true, -- Dragon Racing - Personal Best Record - Emerald Dream 06 Reverse
	[2694] = true, -- Dragon Racing - Personal Best Record - ED 01 Challenge
	[2695] = true, -- Dragon Racing - Personal Best Record - ED 01 Challenge R
	[2696] = true, -- Dragon Racing - Personal Best Record - ED 02 Challenge
	[2697] = true, -- Dragon Racing - Personal Best Record - ED 02 Challenge R
	[2698] = true, -- Dragon Racing - Personal Best Record - ED 03 Challenge
	[2699] = true, -- Dragon Racing - Personal Best Record - ED 03 Challenge R
	[2700] = true, -- Dragon Racing - Personal Best Record - ED 04 Challenge
	[2701] = true, -- Dragon Racing - Personal Best Record - ED 04 Challenge R
	[2702] = true, -- Dragon Racing - Personal Best Record - ED 05 Challenge
	[2703] = true, -- Dragon Racing - Personal Best Record - ED 05 Challenge R
	[2704] = true, -- Dragon Racing - Personal Best Record - ED 06 Challenge
	[2705] = true, -- Dragon Racing - Personal Best Record - ED 06 Challenge R
	[2706] = true, -- Whelpling's Dreaming Crest
	[2707] = true, -- Drake's Dreaming Crest
	[2708] = true, -- Wyrm's Dreaming Crest
	[2709] = true, -- Aspect's Dreaming Crest
	[2710] = true, -- Study of Shadowflame
	[2715] = true, -- Whelpling's Dreaming Crests
	[2716] = true, -- Drake's Dreaming Crests
	[2717] = true, -- Wyrm's Dreaming Crests
	[2718] = true, -- Aspect's Dreaming Crests
	[2720] = true, -- Dragon Racing - Personal Best Record - Northrend 01
	[2721] = true, -- Dragon Racing - Personal Best Record - Northrend 02
	[2722] = true, -- Dragon Racing - Personal Best Record - Northrend 03
	[2723] = true, -- Dragon Racing - Personal Best Record - Northrend 04
	[2724] = true, -- Dragon Racing - Personal Best Record - Northrend 05
	[2725] = true, -- Dragon Racing - Personal Best Record - Northrend 06
	[2726] = true, -- Dragon Racing - Personal Best Record - Northrend 07
	[2727] = true, -- Dragon Racing - Personal Best Record - Northrend 08
	[2728] = true, -- Dragon Racing - Personal Best Record - Northrend 09
	[2729] = true, -- Dragon Racing - Personal Best Record - Northrend 10
	[2730] = true, -- Dragon Racing - Personal Best Record - Northrend 11
	[2731] = true, -- Dragon Racing - Personal Best Record - Northrend 12
	[2732] = true, -- Dragon Racing - Personal Best Record - Northrend 13
	[2733] = true, -- Dragon Racing - Personal Best Record - Northrend 14
	[2734] = true, -- Dragon Racing - Personal Best Record - Northrend 15
	[2735] = true, -- Dragon Racing - Personal Best Record - Northrend 16
	[2736] = true, -- Dragon Racing - Personal Best Record - Northrend 17
	[2737] = true, -- Dragon Racing - Personal Best Record - Northrend 18
	[2738] = true, -- Dragon Racing - Personal Best Record - Northrend 01 Advanced
	[2739] = true, -- Dragon Racing - Personal Best Record - Northrend 02 Advanced
	[2740] = true, -- Dragon Racing - Personal Best Record - Northrend 03 Advanced
	[2741] = true, -- Dragon Racing - Personal Best Record - Northrend 04 Advanced
	[2742] = true, -- Dragon Racing - Personal Best Record - Northrend 05 Advanced
	[2743] = true, -- Dragon Racing - Personal Best Record - Northrend 06 Advanced
	[2744] = true, -- Dragon Racing - Personal Best Record - Northrend 07 Advanced
	[2745] = true, -- Dragon Racing - Personal Best Record - Northrend 08 Advanced
	[2746] = true, -- Dragon Racing - Personal Best Record - Northrend 09 Advanced
	[2747] = true, -- Dragon Racing - Personal Best Record - Northrend 10 Advanced
	[2748] = true, -- Dragon Racing - Personal Best Record - Northrend 11 Advanced
	[2749] = true, -- Dragon Racing - Personal Best Record - Northrend 12 Advanced
	[2750] = true, -- Dragon Racing - Personal Best Record - Northrend 13 Advanced
	[2751] = true, -- Dragon Racing - Personal Best Record - Northrend 14 Advanced
	[2752] = true, -- Dragon Racing - Personal Best Record - Northrend 15 Advanced
	[2753] = true, -- Dragon Racing - Personal Best Record - Northrend 16 Advanced
	[2754] = true, -- Dragon Racing - Personal Best Record - Northrend 17 Advanced
	[2755] = true, -- Dragon Racing - Personal Best Record - Northrend 18 Advanced
	[2756] = true, -- Dragon Racing - Personal Best Record - Northrend 01 Reverse
	[2757] = true, -- Dragon Racing - Personal Best Record - Northrend 02 Reverse
	[2758] = true, -- Dragon Racing - Personal Best Record - Northrend 03 Reverse
	[2759] = true, -- Dragon Racing - Personal Best Record - Northrend 04 Reverse
	[2760] = true, -- Dragon Racing - Personal Best Record - Northrend 05 Reverse
	[2761] = true, -- Dragon Racing - Personal Best Record - Northrend 06 Reverse
	[2762] = true, -- Dragon Racing - Personal Best Record - Northrend 07 Reverse
	[2763] = true, -- Dragon Racing - Personal Best Record - Northrend 08 Reverse
	[2764] = true, -- Dragon Racing - Personal Best Record - Northrend 09 Reverse
	[2765] = true, -- Dragon Racing - Personal Best Record - Northrend 10 Reverse
	[2766] = true, -- Dragon Racing - Personal Best Record - Northrend 11 Reverse
	[2767] = true, -- Dragon Racing - Personal Best Record - Northrend 12 Reverse
	[2768] = true, -- Dragon Racing - Personal Best Record - Northrend 13 Reverse
	[2769] = true, -- Dragon Racing - Personal Best Record - Northrend 14 Reverse
	[2770] = true, -- Dragon Racing - Personal Best Record - Northrend 15 Reverse
	[2771] = true, -- Dragon Racing - Personal Best Record - Northrend 16 Reverse
	[2772] = true, -- Dragon Racing - Personal Best Record - Northrend 17 Reverse
	[2773] = true, -- Dragon Racing - Personal Best Record - Northrend 18 Reverse
	[2774] = true, -- 10.2 Professions - Personal Tracker - S3 Spark Drops (Hidden)
	[2780] = true, -- Echoed Ephemera Tracker [DNT]
	[2784] = true, -- 10.2 Legendary - Progressive Advance - Tracker
	[2785] = true, -- Khaz Algar Alchemy Knowledge
	[2786] = true, -- Khaz Algar Blacksmithing Knowledge
	[2787] = true, -- Khaz Algar Enchanting Knowledge
	[2788] = true, -- Khaz Algar Engineering Knowledge
	[2789] = true, -- Khaz Algar Herbalism Knowledge
	[2790] = true, -- Khaz Algar Inscription Knowledge
	[2791] = true, -- Khaz Algar Jewelcrafting Knowledge
	[2792] = true, -- Khaz Algar Leatherworking Knowledge
	[2793] = true, -- Khaz Algar Mining Knowledge
	[2794] = true, -- Khaz Algar Skinning Knowledge
	[2795] = true, -- Khaz Algar Tailoring Knowledge
	[2796] = true, -- Renascent Dream
	[2799] = true, -- [DNT] Beetle Ranch Invisible Currency
	[2800] = true, -- 10.2.6 Professions - Personal Tracker - S4 Spark Drops (Hidden)
	[2805] = true, -- Whelpling's Awakened Crest
	[2808] = true, -- Drake's Awakened Crest
	[2810] = true, -- Wyrm's Awakened Crest
	[2811] = true, -- Aspect's Awakened Crest
	[2813] = true, -- Harmonized Silk
	[2814] = true, -- Renown-Keg Leg's Crew
	[2819] = true, -- Azerothian Archives
	[2822] = true, -- [DNT] Corgi Cache
	[2853] = true, -- 10.2.7 Timewalking Season - Artifact - Cloak - Primary
	[2854] = true, -- 10.2.7 Timewalking Season - Artifact - Cloak - Stamina
	[2855] = true, -- 10.2.7 Timewalking Season - Artifact - Cloak - Critical Strike
	[2856] = true, -- 10.2.7 Timewalking Season - Artifact - Cloak - Haste
	[2857] = true, -- 10.2.7 Timewalking Season - Artifact - Cloak - Leech
	[2858] = true, -- 10.2.7 Timewalking Season - Artifact - Cloak - Mastery
	[2859] = true, -- 10.2.7 Timewalking Season - Artifact - Cloak - Speed
	[2860] = true, -- 10.2.7 Timewalking Season - Artifact - Cloak - Versatility
	[2861] = true, -- 10.2.7 Timewalking Season - Artifact - Head - Aberration
	[2862] = true, -- 10.2.7 Timewalking Season - Artifact - Head - Beast
	[2863] = true, -- 10.2.7 Timewalking Season - Artifact - Head - Demon
	[2864] = true, -- 10.2.7 Timewalking Season - Artifact - Head - Dragonkin
	[2865] = true, -- 10.2.7 Timewalking Season - Artifact - Head - Elemental
	[2866] = true, -- 10.2.7 Timewalking Season - Artifact - Head - Giant
	[2867] = true, -- 10.2.7 Timewalking Season - Artifact - Head - Humanoid
	[2868] = true, -- 10.2.7 Timewalking Season - Artifact - Head - Mechanical
	[2869] = true, -- 10.2.7 Timewalking Season - Artifact - Head - Undead
	[2870] = true, -- 10.2.7 Timewalking Season - Artifact - Waist - Physical
	[2871] = true, -- 10.2.7 Timewalking Season - Artifact - Waist - Arcane
	[2872] = true, -- 10.2.7 Timewalking Season - Artifact - Waist - Fire
	[2873] = true, -- 10.2.7 Timewalking Season - Artifact - Waist - Frost
	[2874] = true, -- 10.2.7 Timewalking Season - Artifact - Waist - Holy
	[2875] = true, -- 10.2.7 Timewalking Season - Artifact - Waist - Shadow
	[2876] = true, -- 10.2.7 Timewalking Season - Artifact - Waist - Nature
	[2878] = true, -- 10.2 Professions - Personal Tracker - Legendary - Restored Leaf
	[2897] = true, -- Council of Dornogal
	[2898] = true, -- Renown - The Assembly of the Deeps
	[2899] = true, -- Hallowfall Arathi
	[2900] = true, -- Renown - Council of Dornogal
	[2901] = true, -- Renown - Hallowfall Arathi
	[2902] = true, -- The Assembly of the Deeps
	[2903] = true, -- The Severed Threads
	[2904] = true, -- Renown - The Severed Threads
	[2906] = true, -- Plunder
	[2907] = true, -- Pirate Booty Visual
	[2908] = true, -- Dominance Offensive
	[2909] = true, -- Operation: Shieldwall
	[2910] = true, -- The Klaxxi
	[2911] = true, -- Order of the Cloud Serpent
	[2912] = true, -- Renascent Awakening
	[2913] = true, -- Shado-Pan
	[2918] = true, -- Weathered Harbinger Crest
	[2919] = true, -- Carved Harbinger Crest
	[2920] = true, -- Runed Harbinger Crest
	[2921] = true, -- Gilded Harbinger Crest
	[2922] = true, -- Plunder
	[2923] = true, -- Dragon Racing - Personal Best Record - 11 Z1 R1 Easy
	[2924] = true, -- Dragon Racing - Personal Best Record - 11 Z1 R2 Easy
	[2925] = true, -- Dragon Racing - Personal Best Record - 11 Z1 R3 Easy
	[2926] = true, -- Dragon Racing - Personal Best Record - 11 Z1 R4 Easy
	[2927] = true, -- Dragon Racing - Personal Best Record - 11 Z1 R5 Easy
	[2928] = true, -- Dragon Racing - Personal Best Record - 11 Z1 R6 Easy
	[2929] = true, -- Dragon Racing - Personal Best Record - 11 Z1 R1 Advanced
	[2930] = true, -- Dragon Racing - Personal Best Record - 11 Z1 R2 Advanced
	[2931] = true, -- Dragon Racing - Personal Best Record - 11 Z1 R3 Advanced
	[2932] = true, -- Dragon Racing - Personal Best Record - 11 Z1 R4 Advanced
	[2933] = true, -- Dragon Racing - Personal Best Record - 11 Z1 R5 Advanced
	[2934] = true, -- Dragon Racing - Personal Best Record - 11 Z1 R6 Advanced
	[2935] = true, -- Dragon Racing - Personal Best Record - 11 Z1 R1 Reverse
	[2936] = true, -- Dragon Racing - Personal Best Record - 11 Z1 R2 Reverse
	[2937] = true, -- Dragon Racing - Personal Best Record - 11 Z1 R3 Reverse
	[2938] = true, -- Dragon Racing - Personal Best Record - 11 Z1 R4 Reverse
	[2939] = true, -- Dragon Racing - Personal Best Record - 11 Z1 R5 Reverse
	[2940] = true, -- Dragon Racing - Personal Best Record - 11 Z1 R6 Reverse
	[2941] = true, -- Dragon Racing - Personal Best Record - 11 Z2 R1 Easy
	[2942] = true, -- Dragon Racing - Personal Best Record - 11 Z2 R2 Easy
	[2943] = true, -- Dragon Racing - Personal Best Record - 11 Z2 R3 Easy
	[2944] = true, -- Dragon Racing - Personal Best Record - 11 Z2 R4 Easy
	[2945] = true, -- Dragon Racing - Personal Best Record - 11 Z2 R5 Easy
	[2946] = true, -- Dragon Racing - Personal Best Record - 11 Z2 R6 Easy
	[2947] = true, -- Dragon Racing - Personal Best Record - 11 Z2 R1 Advanced
	[2948] = true, -- Dragon Racing - Personal Best Record - 11 Z2 R2 Advanced
	[2949] = true, -- Dragon Racing - Personal Best Record - 11 Z2 R3 Advanced
	[2950] = true, -- Dragon Racing - Personal Best Record - 11 Z2 R4 Advanced
	[2951] = true, -- Dragon Racing - Personal Best Record - 11 Z2 R5 Advanced
	[2952] = true, -- Dragon Racing - Personal Best Record - 11 Z2 R6 Advanced
	[2953] = true, -- Dragon Racing - Personal Best Record - 11 Z2 R1 Reverse
	[2954] = true, -- Dragon Racing - Personal Best Record - 11 Z2 R2 Reverse
	[2955] = true, -- Dragon Racing - Personal Best Record - 11 Z2 R3 Reverse
	[2956] = true, -- Dragon Racing - Personal Best Record - 11 Z2 R4 Reverse
	[2957] = true, -- Dragon Racing - Personal Best Record - 11 Z2 R5 Reverse
	[2958] = true, -- Dragon Racing - Personal Best Record - 11 Z2 R6 Reverse
	[2959] = true, -- Dragon Racing - Personal Best Record - 11 Z3 R1 Easy
	[2960] = true, -- Dragon Racing - Personal Best Record - 11 Z3 R2 Easy
	[2961] = true, -- Dragon Racing - Personal Best Record - 11 Z3 R3 Easy
	[2962] = true, -- Dragon Racing - Personal Best Record - 11 Z3 R4 Easy
	[2963] = true, -- Dragon Racing - Personal Best Record - 11 Z3 R5 Easy
	[2964] = true, -- Dragon Racing - Personal Best Record - 11 Z3 R6 Easy
	[2965] = true, -- Dragon Racing - Personal Best Record - 11 Z3 R1 Advanced
	[2966] = true, -- Dragon Racing - Personal Best Record - 11 Z3 R2 Advanced
	[2967] = true, -- Dragon Racing - Personal Best Record - 11 Z3 R3 Advanced
	[2968] = true, -- Dragon Racing - Personal Best Record - 11 Z3 R4 Advanced
	[2969] = true, -- Dragon Racing - Personal Best Record - 11 Z3 R5 Advanced
	[2970] = true, -- Dragon Racing - Personal Best Record - 11 Z3 R6 Advanced
	[2971] = true, -- Dragon Racing - Personal Best Record - 11 Z3 R1 Reverse
	[2972] = true, -- Dragon Racing - Personal Best Record - 11 Z3 R2 Reverse
	[2973] = true, -- Dragon Racing - Personal Best Record - 11 Z3 R3 Reverse
	[2974] = true, -- Dragon Racing - Personal Best Record - 11 Z3 R4 Reverse
	[2975] = true, -- Dragon Racing - Personal Best Record - 11 Z3 R5 Reverse
	[2976] = true, -- Dragon Racing - Personal Best Record - 11 Z3 R6 Reverse
	[2977] = true, -- Dragon Racing - Personal Best Record - 11 Z5 R1 Easy
	[2978] = true, -- Dragon Racing - Personal Best Record - 11 Z5 R2 Easy
	[2979] = true, -- Dragon Racing - Personal Best Record - 11 Z5 R3 Easy
	[2980] = true, -- Dragon Racing - Personal Best Record - 11 Z5 R4 Easy
	[2981] = true, -- Dragon Racing - Personal Best Record - 11 Z5 R5 Easy
	[2982] = true, -- Dragon Racing - Personal Best Record - 11 Z5 R6 Easy
	[2983] = true, -- Dragon Racing - Personal Best Record - 11 Z5 R1 Advanced
	[2984] = true, -- Dragon Racing - Personal Best Record - 11 Z5 R2 Advanced
	[2985] = true, -- Dragon Racing - Personal Best Record - 11 Z5 R3 Advanced
	[2986] = true, -- Dragon Racing - Personal Best Record - 11 Z5 R4 Advanced
	[2987] = true, -- Dragon Racing - Personal Best Record - 11 Z5 R5 Advanced
	[2988] = true, -- Dragon Racing - Personal Best Record - 11 Z5 R6 Advanced
	[2989] = true, -- Dragon Racing - Personal Best Record - 11 Z5 R1 Reverse
	[2990] = true, -- Dragon Racing - Personal Best Record - 11 Z5 R2 Reverse
	[2991] = true, -- Dragon Racing - Personal Best Record - 11 Z5 R3 Reverse
	[2992] = true, -- Dragon Racing - Personal Best Record - 11 Z5 R4 Reverse
	[2993] = true, -- Dragon Racing - Personal Best Record - 11 Z5 R5 Reverse
	[2994] = true, -- Dragon Racing - Personal Best Record - 11 Z5 R6 Reverse
	[3000] = true, -- 10.2.7 Timewalking Season - Random Gem Counter
	[3001] = true, -- 10.2.7 Timewalking Season - Artifact - Cloak - Experience Gain
	[3002] = true, -- The Weaver (Notoriety)
	[3003] = true, -- The General (Notoriety)
	[3004] = true, -- The Vizier (Notoriety)
	[3005] = true, -- The General (Notoriety)
	[3006] = true, -- The Vizier (Notoriety)
	[3007] = true, -- The Weaver (Notoriety)
	[3009] = true, -- Bonus Valorstones
	[3010] = true, -- 10.2.6 Rewards - Personal Tracker - S4 Dinar Drops (Hidden)
	[3011] = true, -- Plunder
	[3013] = true, -- Jewelcrafting Concentration
	[3022] = true, -- Renown - Season 1 Delves
	[3023] = true, -- 11.0 Professions - Personal Tracker - S1 Spark Drops (Hidden)
	[3024] = true, -- Cosmetic
	[3025] = true, -- Cosmetic
	[3026] = true, -- Cosmetic
	[3027] = true, -- Cosmetic
	[3040] = true, -- Blacksmithing Concentration
	[3041] = true, -- Tailoring Concentration
	[3042] = true, -- Leatherworking Concentration
	[3043] = true, -- Inscription Concentration
	[3044] = true, -- Engineering Concentration
	[3045] = true, -- Alchemy Concentration
	[3046] = true, -- Enchanting Concentration
	[3047] = true, -- Jewelcrafting Concentration
	[3048] = true, -- Tailoring Concentration
	[3049] = true, -- Leatherworking Concentration
	[3050] = true, -- Blacksmithing Concentration
	[3051] = true, -- Enchanting Concentration
	[3052] = true, -- Engineering Concentration
	[3053] = true, -- Inscription Concentration
	[3054] = true, -- Alchemy Concentration
	[3057] = true, -- 11.0 Professions - Tracker - Weekly Alchemy Knowledge
	[3058] = true, -- 11.0 Professions - Tracker - Weekly Blacksmithing Knowledge
	[3059] = true, -- 11.0 Professions - Tracker - Weekly Enchanting Knowledge
	[3060] = true, -- 11.0 Professions - Tracker - Weekly Engineering Knowledge
	[3061] = true, -- 11.0 Professions - Tracker - Weekly Herbalism Knowledge
	[3062] = true, -- 11.0 Professions - Tracker - Weekly Inscription Knowledge
	[3063] = true, -- 11.0 Professions - Tracker - Weekly Jewelcrafting Knowledge
	[3064] = true, -- 11.0 Professions - Tracker - Weekly Leatherworking Knowledge
	[3065] = true, -- 11.0 Professions - Tracker - Weekly Mining Knowledge
	[3066] = true, -- 11.0 Professions - Tracker - Weekly Skinning Knowledge
	[3067] = true, -- 11.0 Professions - Tracker - Weekly Tailoring Knowledge
	[3068] = true, -- Delver's Journey
	[3069] = true, -- 11.0 Professions - Tailoring - Fishing - Khaz Algar - Skill
	[3070] = true, -- 11.0 Professions - Fishing - Algari Weaverthread - Perception
	[3071] = true, -- 11.0 Professions - Fishing - Algari Weaverthread - Skill
	[3072] = true, -- Everburning Ignition Refund
	[3073] = true, -- 11.0 Professions - Tracker - Insc Book - Tailoring Knowledge
	[3074] = true, -- 11.0 Professions - Tracker - Insc Book - Skinning Knowledge
	[3075] = true, -- 11.0 Professions - Tracker - Insc Book - Mining Knowledge
	[3076] = true, -- 11.0 Professions - Tracker - Insc Book - Leatherworking Know.
	[3077] = true, -- 11.0 Professions - Tracker - Insc Book - Jewelcrafting Knowledge
	[3078] = true, -- 11.0 Professions - Tracker - Insc Book - Inscription Knowledge
	[3079] = true, -- 11.0 Professions - Tracker - Insc Book - Herbalism Knowledge
	[3080] = true, -- 11.0 Professions - Tracker - Insc Book - Engineering Knowledge
	[3081] = true, -- 11.0 Professions - Tracker - Insc Book - Enchanting Knowledge
	[3082] = true, -- 11.0 Professions - Tracker - Insc Book - Blacksmithing Knowledge
	[3083] = true, -- 11.0 Professions - Tracker - Insc Book - Alchemy Knowledge
	[3084] = true, -- 11.0 Professions - Tracker - Insc Book - Inscription Knowledge
	[3085] = true, -- 11.0 Delves - Personal Tracker - S1 Weekly Elise Turn-In(Hidden)
	[3086] = true, -- DPS
	[3087] = true, -- Tank
	[3088] = true, -- Healer
	[3094] = true, -- 11.0 Raid - Nerubian - Account Quest Complete Tracker (Hidden)
	[3099] = true, -- 11.0 Raid - Nerubian - Nerubar Finery Tracking Currency (Hidden)
	[3102] = true, -- Bronze Celebration Token
	[3103] = true, -- 11.0 Delves - System - Seasonal Affix - Events Active
	[3104] = true, -- 11.0 Delves - System - Seasonal Affix - Events Maximum
	[3115] = true, -- [DNT] Worldsoul Memory Score
	[3142] = true, -- 11.0 Delves - Bountiful Tracker - Brann EXP Cap
	[3143] = true, -- 11.0 Delves - Bountiful Tracker - Delver's Journey Cap
	[3144] = true, -- 11.0.5 20th Anniversary - Tracker
	[3145] = true, -- 11.0.5 20th Anniversary - Tracker
	[3146] = true, -- 11.0.5 20th Anniversary - Tracker
}

local MULT = {
	[ 944] = 0.01, -- Artifact Fragment
	[ 980] = 0.01, -- Dingy Iron Coins
	[1268] = 0.01, -- Timeworn Artifact
	[1565] = 0.01, -- Rich Azerite Fragment
	[1602] = 0.01, -- Conquest
	[2123] = 0.01, -- Bloody Tokens
	[2134] = 0.01, -- Cobalt Assembly
}
-- GENERATED-DATA-END

local function Toast_OnEnter(self)
	if self._data.tooltip_link then
		GameTooltip:SetHyperlink(self._data.tooltip_link)
		GameTooltip:Show()
	end
end

local function PostSetAnimatedValue(self, value)
	self:SetText(value == 1 and "" or FormatLargeNumber(m_abs(value)))
end

local function Toast_SetUp(event, id, quantity)
	local link = "currency:" .. id
	local toast, isNew, isQueued = E:GetToast(event, "link", link)
	if isNew then
		if C.db.profile.types.loot_currency.filters[id] and m_abs(quantity) < C.db.profile.types.loot_currency.filters[id] then
			toast:Recycle()

			return
		end

		local info = C_CurrencyInfo.GetCurrencyInfoFromLink(link)
		if info then
			local color = ITEM_QUALITY_COLORS[info.quality] or ITEM_QUALITY_COLORS[1]

			toast.IconText1.PostSetAnimatedValue = PostSetAnimatedValue

			if info.quality >= C.db.profile.colors.threshold then
				if C.db.profile.colors.name then
					toast.Text:SetTextColor(color.r, color.g, color.b)
				end

				if C.db.profile.colors.border then
					toast.Border:SetVertexColor(color.r, color.g, color.b)
				end

				if C.db.profile.colors.icon_border then
					toast.IconBorder:SetVertexColor(color.r, color.g, color.b)
				end
			end

			toast.Title:SetText(quantity > 0 and L["YOU_RECEIVED"] or L["YOU_LOST_RED"])
			toast.Text:SetText(info.name)
			toast.Icon:SetTexture(info.iconFileID)
			toast.IconBorder:Show()
			toast.IconText1:SetAnimatedValue(quantity, true)

			toast._data.count = quantity
			toast._data.event = event
			toast._data.link = link
			toast._data.sound_file = C.db.profile.types.loot_currency.sfx and 31578 -- SOUNDKIT.UI_EPICLOOT_TOAST
			toast._data.tooltip_link = link

			if C.db.profile.types.loot_currency.tooltip then
				toast:HookScript("OnEnter", Toast_OnEnter)
			end

			toast:Spawn(C.db.profile.types.loot_currency.anchor, C.db.profile.types.loot_currency.dnd)
		else
			toast:Recycle()
		end
	else
		toast._data.count = toast._data.count + quantity
		toast.Title:SetText(toast._data.count > 0 and L["YOU_RECEIVED"] or L["YOU_LOST_RED"])

		if isQueued then
			toast.IconText1:SetAnimatedValue(toast._data.count, true)
		else
			toast.IconText1:SetAnimatedValue(toast._data.count)

			toast.IconText2:SetText(quantity)
			toast.IconText2.Blink:Stop()
			toast.IconText2.Blink:Play()

			toast.AnimOut:Stop()
			toast.AnimOut:Play()
		end
	end
end

local function CURRENCY_DISPLAY_UPDATE(id, _, quantity)
	if not id or BLACKLIST[id] or C.db.profile.types.loot_currency.filters[id] == -1 then
		return
	end

	if not C.db.profile.types.loot_currency.track_loss and quantity < 0 then
		return
	end

	quantity = m_floor(quantity * (MULT[id] or 1))
	if m_abs(quantity) < 1 then
		return
	end

	Toast_SetUp("CURRENCY_DISPLAY_UPDATE", id, quantity)
end

local TRADE_POST_TOKEN_ID = Constants.CurrencyConsts.CURRENCY_ID_PERKS_PROGRAM_DISPLAY_INFO
local isTradingPostInit = false

local function PERKS_PROGRAM_CURRENCY_REFRESH(old, new)
	if not isTradingPostInit then
		isTradingPostInit = true

		-- skip the initial update because it's just an acc-char sync
		if old == 0 then
			return
		end
	end

	if C.db.profile.types.loot_currency.filters[TRADE_POST_TOKEN_ID] == -1 then
		return
	end

	local quantity = new - old
	if quantity == 0 then
		return
	end

	if not C.db.profile.types.loot_currency.track_loss and quantity < 0 then
		return
	end

	Toast_SetUp("PERKS_PROGRAM_CURRENCY_REFRESH", TRADE_POST_TOKEN_ID, quantity)
end

local listSize = 0
local newID

local function validateThreshold(_, value)
	value = tonumber(value) or 0
	return value >= -1
end

local function setThreshold(info, value)
	value = tonumber(value)
	C.db.profile.types.loot_currency.filters[tonumber(info[#info - 1])] = value
end

local function getThreshold(info)
	return tostring(C.db.profile.types.loot_currency.filters[tonumber(info[#info - 1])])
end

local function populateFilters()
	listSize = C_CurrencyInfo.GetCurrencyListSize()
	if listSize > 0 then
		local info, link, id

		for i = 1, listSize do
			info = C_CurrencyInfo.GetCurrencyListInfo(i)
			if not info.isHeader then
				link = C_CurrencyInfo.GetCurrencyListLink(i)
				if link then
					id = tonumber(link:match("currency:(%d+)"))
					if id then
						if not C.db.profile.types.loot_currency.filters[id] then
							C.db.profile.types.loot_currency.filters[id] = 0 -- disabled by default
						end
					end
				end
			end
		end
	end
end

local function updateFilterOptions()
	if not C.db.profile.types.loot_currency.enabled then
		return
	end

	local options = t_wipe(C.options.args.types.args.loot_currency.plugins.filters)
	local nameToIndex = {}
	local info

	for id in next, C.db.profile.types.loot_currency.filters do
		info = C_CurrencyInfo.GetBasicCurrencyInfo(id)
		t_insert(nameToIndex, info.name)
	end

	t_sort(nameToIndex)

	for i = 1, #nameToIndex do
		nameToIndex[nameToIndex[i]] = i
	end

	for id in next, C.db.profile.types.loot_currency.filters do
		info = C_CurrencyInfo.GetBasicCurrencyInfo(id)

		options[tostring(id)] = {
			order = nameToIndex[info.name] + 10,
			type = "group",
			name = ("|T%s:0:0:0:0:64:64:4:60:4:60|t %s"):format(info.icon, info.name),
			args = {
				desc = {
					order = 1,
					type = "description",
					name = info.description,
				},
				threshold = {
					order = 2,
					type = "input",
					name = L["THRESHOLD"],
					desc = L["CURRENCY_THRESHOLD_DESC"],
					validate = validateThreshold,
					set = setThreshold,
					get = getThreshold,
				},
			},
		}
	end
end

-- Update filters and options when users discover new currencies
local function updateFilters()
	if C_CurrencyInfo.GetCurrencyListSize() == listSize then
		return
	end

	populateFilters()
	updateFilterOptions()
end

local function Enable()
	if C.db.profile.types.loot_currency.enabled then
		E:RegisterEvent("CURRENCY_DISPLAY_UPDATE", CURRENCY_DISPLAY_UPDATE)
		E:RegisterEvent("CURRENCY_DISPLAY_UPDATE", updateFilters)
		E:RegisterEvent("PERKS_PROGRAM_CURRENCY_REFRESH", PERKS_PROGRAM_CURRENCY_REFRESH)

		populateFilters()
		updateFilterOptions()
	end
end

local function Disable()
	E:UnregisterEvent("CURRENCY_DISPLAY_UPDATE", CURRENCY_DISPLAY_UPDATE)
	E:UnregisterEvent("CURRENCY_DISPLAY_UPDATE", updateFilters)
	E:UnregisterEvent("PERKS_PROGRAM_CURRENCY_REFRESH", PERKS_PROGRAM_CURRENCY_REFRESH)
end

local function Test()
	-- Order Resources
	Toast_SetUp("LOOT_CURRENCY_TEST", 1220, m_random(-600, 600))
end

E:RegisterOptions("loot_currency", {
	enabled = true,
	anchor = 1,
	dnd = false,
	sfx = true,
	tooltip = true,
	track_loss = false,
	filters = {
		[1792] = 25,
	},
}, {
	name = L["TYPE_LOOT_CURRENCY"],
	get = function(info)
		return C.db.profile.types.loot_currency[info[#info]]
	end,
	set = function(info, value)
		C.db.profile.types.loot_currency[info[#info]] = value
	end,
	disabled = function(info)
		if info[#info] == "loot_currency" then
			return false
		else
			return not C.db.profile.types.loot_currency.enabled
		end
	end,
	args = {
		enabled = {
			order = 1,
			type = "toggle",
			name = L["ENABLE"],
			disabled = false,
			set = function(_, value)
				C.db.profile.types.loot_currency.enabled = value

				if value then
					Enable()
				else
					Disable()
				end
			end,
		},
		dnd = {
			order = 2,
			type = "toggle",
			name = L["DND"],
			desc = L["DND_TOOLTIP"],
		},
		sfx = {
			order = 3,
			type = "toggle",
			name = L["SFX"],
		},
		tooltip = {
			order = 4,
			type = "toggle",
			name = L["TOOLTIPS"],
		},
		track_loss = {
			order = 5,
			type = "toggle",
			name = L["TRACK_LOSS"],
		},
		test = {
			type = "execute",
			order = 6,
			width = "full",
			name = L["TEST"],
			func = Test,
		},
		spacer_1 = {
			order = 7,
			type = "description",
			name = " ",
		},
		header_1 = {
			order = 8,
			type = "description",
			name = "   |cffffd200".. L["FILTERS"] .. "|r",
			fontSize = "medium",
		},
		new = {
			order = 9,
			type = "group",
			name = L["NEW"],
			args = {
				desc = {
					order = 1,
					type = "description",
					name = L["NEW_CURRENCY_FILTER_DESC"],
				},
				id = {
					order = 2,
					type = "input",
					name = L["ID"],
					dialogControl = "LSPreviewBoxCurrency",
					validate = function(_, value)
						value = tonumber(value)
						if value then
							return not not C_CurrencyInfo.GetCurrencyLink(value, 0)
						else
							return true
						end
					end,
					set = function(_, value)
						value = tonumber(value)
						if value and C_CurrencyInfo.GetCurrencyLink(value, 0) then
							newID = value
						else
							newID = nil -- jic
						end
					end,
					get = function()
						return tostring(newID or "")
					end,
				},
				add = {
					type = "execute",
					order = 3,
					name = L["ADD"],
					disabled = function()
						return not newID or C.db.profile.types.loot_currency.filters[newID] or BLACKLIST[newID]
					end,
					func = function()
						C.db.profile.types.loot_currency.filters[newID] = 0 -- disabled by default
						newID = nil

						updateFilterOptions()
					end,
				},
			},
		},
	},
	plugins = {
		filters = {},
	},
})

E:RegisterSystem("loot_currency", Enable, Disable, Test)
