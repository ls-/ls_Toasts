local _, addonTable = ...
local E, C = addonTable.E, addonTable.C

-- Lua
local _G = getfenv(0)
local error = _G.error
local next = _G.next
local s_format = _G.string.format
local type = _G.type

-- Mine
local systems = {}
local function dummy() end

function E.RegisterSystem(_, id, enableFunc, disableFunc, testFunc)
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

function E.EnableSystem(_, id)
	local system = systems[id]

	if system and not system.isEnabled then
		system:Enable()

		system.isEnabled = true
	end
end

function E.DisableSystem(_, id)
	local system = systems[id]

	if system and system.isEnabled then
		system:Disable()

		system.isEnabled = false
	end
end

function E.TestSystem(_, id)
	if systems[id] then
		systems[id]:Test()
	end
end

function E.EnableAllSystems()
	for _, system in next, systems do
		if not system.isEnabled then
			system:Enable()

			system.isEnabled = true
		end
	end
end

function E.DisableAllSystems()
	for _, system in next, systems do
		if system.isEnabled then
			system:Disable()

			system.isEnabled = false
		end
	end
end

function E.TestAllSystems()
	for _, system in next, systems do
			system:Test()
	end
end

local db = {} -- for profile switching
local options = {}
local order = 1

local function updateTable(src, dest)
	if type(dest) ~= "table" then
		dest = {}
	end

	for k, v in next, src do
		if type(v) == "table" then
			dest[k] = updateTable(v, dest[k])
		else
			if dest[k] == nil then
				dest[k] = v
			end
		end
	end

	return dest
end

function E.RegisterOptions(_, id, dbTable, optionsTable)
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

	db[id] = dbTable

	if IsLoggedIn() then
		C.db.profile.types[id] = {}
		updateTable(db[id], C.db.profile.types[id])
	end

	if optionsTable then
		options[id] = optionsTable
		options[id].order = order
		options[id].type = "group"

		order = order + 1

		if IsLoggedIn() then
			C.options.args.types.args[id] = {}
			updateTable(options[id], C.options.args.types.args[id])
		end
	end
end

function E.UpdateDB()
	updateTable(db, C.db.profile.types)
end

function E.UpdateOptions()
	updateTable(options, C.options.args.types.args)
end
