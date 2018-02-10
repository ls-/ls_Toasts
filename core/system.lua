local _, addonTable = ...
local E, C = addonTable.E, addonTable.C

-- Lua
local _G = getfenv(0)
local next = _G.next
local type = _G.type

-- Mine
local systems = {}
local function dummy() end

function E.RegisterSystem(_, name, enableFunc, disableFunc, testFunc)
	if not name then
		return false, "no_name"
	elseif systems[name] then
		return false, "name_taken"
	elseif not enableFunc then
		return false, "no_enabler"
	elseif not disableFunc then
		return false, "no_disabler"
	end

	systems[name] = {
		Enable = enableFunc,
		Disable = disableFunc,
		Test = testFunc or dummy,
		isEnabled = false,
	}

	return true
end

function E.EnableSystem(_, name)
	local system = systems[name]

	if system and not system.isEnabled then
		system:Enable()

		system.isEnabled = true
	end
end

function E.DisableSystem(_, name)
	local system = systems[name]

	if system and system.isEnabled then
		system:Disable()

		system.isEnabled = false
	end
end

function E.TestSystem(_, name)
	if systems[name] then
		systems[name]:Test()
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

function E.RegisterOptions(_, name, dbTable, optionsTable)
	if not name then
		return false, "no_name"
	elseif db[name] then
		return false, "name_taken"
	elseif not dbTable then
		return false, "no_cfg_table"
	end

	db[name] = dbTable

	if IsLoggedIn() then
		C.db.profile.types[name] = {}
		updateTable(db[name], C.db.profile.types[name])
	end

	if optionsTable then
		options[name] = optionsTable
		options[name].guiInline = true
		options[name].order = order
		options[name].type = "group"

		order = order + 1

		if IsLoggedIn() then
			C.options.args.types.args[name] = {}
			updateTable(options[name], C.options.args.types.args[name])
		end
	end
end

function E.UpdateDB()
	updateTable(db, C.db.profile.types)
end

function E.UpdateOptions()
	updateTable(options, C.options.args.types.args)
end
