local _, addonTable = ...
local E, C = addonTable.E, addonTable.C

-- Lua
local _G = getfenv(0)
local error = _G.error
local next = _G.next
local type = _G.type

-- Mine
local systems = {}
local function dummy() end

function E.RegisterSystem(_, id, enableFunc, disableFunc, testFunc)
	if type(id) ~= "string" then
		error("invalid system id", 2)
		return
	elseif systems[id] then
		error("system id taken", 2)
		return
	elseif type(enableFunc) ~= "function" then
		error("invalid enable func", 2)
		return
	elseif type(disableFunc) ~= "function" then
		error("invalid disable func", 2)
		return
	elseif type(testFunc) ~= "function" and type(testFunc) ~= "nil" then
		error("invalid test func", 2)
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
		error("invalid config id", 2)
		return
	elseif db[id] then
		error("options id taken", 2)
		return
	elseif type(dbTable) ~= "table" then
		error("invalid config table", 2)
		return
	elseif type(optionsTable) ~= "table" and type(optionsTable) ~= "nil" then
		error("invalid options table", 2)
		return
	end

	db[id] = dbTable

	if IsLoggedIn() then
		C.db.profile.types[id] = {}
		updateTable(db[id], C.db.profile.types[id])
	end

	if optionsTable then
		options[id] = optionsTable
		options[id].guiInline = true
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
