local _, addonTable = ...
local E, P, C, D, L = addonTable.E, addonTable.P, addonTable.C, addonTable.D, addonTable.L

-- Lua
local _G = getfenv(0)
local error = _G.error
local m_min = _G.math.min
local next = _G.next
local s_format = _G.string.format
local type = _G.type

--[[ luacheck: globals
	IsLoggedIn
]]

-- Mine
local systems = {}
local function dummy() end

function E:RegisterSystem(id, enableFunc, disableFunc, testFunc)
	if type(id) ~= "string" then
		error(s_format("Invalid argument #1 to 'RegisterSystem' method, expected a string, got a '%s'", type(id)), 2)
		return
	elseif systems[id] then
		error(s_format("Invalid argument #1 to 'RegisterSystem' method, '%s' id is already taken", id), 2)
		return
	elseif type(enableFunc) ~= "function" then
		error(s_format("Invalid argument #2 to 'RegisterSystem' method, expected a function, got a '%s'", type(enableFunc)), 2)
		return
	elseif type(disableFunc) ~= "function" then
		error(s_format("Invalid argument #3 to 'RegisterSystem' method, expected a function, got a '%s'", type(disableFunc)), 2)
		return
	elseif type(testFunc) ~= "function" and type(testFunc) ~= "nil" then
		error(s_format("Invalid argument #3 to 'RegisterSystem' method, expected a function or nil, got a '%s'", type(testFunc)), 2)
		return
	end

	systems[id] = {
		Enable = enableFunc,
		Disable = disableFunc,
		Test = testFunc or dummy,
		isEnabled = false,
	}
end

function P:EnableSystem(id)
	local system = systems[id]

	if system and not system.isEnabled then
		system:Enable()

		system.isEnabled = true
	end
end

function P:DisableSystem(id)
	local system = systems[id]

	if system and system.isEnabled then
		system:Disable()

		system.isEnabled = false
	end
end

function P:TestSystem(id)
	if systems[id] then
		systems[id]:Test()
	end
end

function P:EnableAllSystems()
	for _, system in next, systems do
		if not system.isEnabled then
			system:Enable()

			system.isEnabled = true
		end
	end
end

function P:DisableAllSystems()
	for _, system in next, systems do
		if system.isEnabled then
			system:Disable()

			system.isEnabled = false
		end
	end
end

function P:TestAllSystems()
	for _, system in next, systems do
			system:Test()
	end
end

local db = {} -- for profile switching
local options = {}
local order = 1

function E:RegisterOptions(id, dbTable, optionsTable)
	if type(id) ~= "string" then
		error(s_format("Invalid argument #1 to 'RegisterOptions' method, expected a string, got a '%s'", type(id)), 2)
		return
	elseif db[id] then
		error(s_format("Invalid argument #1 to 'RegisterOptions' method, '%s' id is already taken", id), 2)
		return
	elseif type(dbTable) ~= "table" then
		error(s_format("Invalid argument #2 to 'RegisterOptions' method, expected a table, got a '%s'", type(dbTable)), 2)
		return
	elseif type(optionsTable) ~= "table" and type(optionsTable) ~= "nil" then
		error(s_format("Invalid argument #3 to 'RegisterOptions' method, expected a table or nil, got a '%s'", type(optionsTable)), 2)
		return
	end

	dbTable.anchor = dbTable.anchor or 1

	db[id] = dbTable

	if IsLoggedIn() then
		C.db.profile.types[id] = {}
		P:UpdateTable(db[id], C.db.profile.types[id])

		C.db.profile.types[id].anchor = m_min(C.db.profile.types[id].anchor, #C.db.profile.anchors)
	end

	if optionsTable then
		options[id] = optionsTable
		options[id].order = order
		options[id].type = "group"

		order = order + 1

		if IsLoggedIn() then
			C.options.args.types.args[id] = {}
			P:UpdateTable(options[id], C.options.args.types.args[id])
			P:UpdateAnchorsOptions()
		end
	end
end

function P:UpdateDB()
	P:UpdateTable(db, C.db.profile.types)

	for id in next, db do
		C.db.profile.types[id].anchor = m_min(C.db.profile.types[id].anchor, #C.db.profile.anchors)
	end
end

function P:UpdateOptions()
	P:UpdateTable(options, C.options.args.types.args)
	P:UpdateAnchorsOptions()
end
