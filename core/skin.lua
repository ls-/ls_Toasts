local _, addonTable = ...
local E, C = addonTable.E, addonTable.C

-- Lua
local _G = getfenv(0)
local next = _G.next
local type = _G.type

-- Mine
local num = 1
local skins = {
	Default = {
		func = function() end
	},
}

function E.RegisterSkin(_, name, func)
	if not name then
		return false, "no_name"
	elseif not func then
		return false, "no_func"
	elseif type(func) ~= "function" then
		return false, "func_invalid"
	elseif skins[name] then
		return false, "name_taken"
	elseif name == "handler" or name == "num" then
		return false, "name_prohibited"
	end

	num = num + 1

	skins[name] = {
		func = func
	}

	return true
end

function E.SetSkin(_, name)
	if not name then
		return false, "no_name"
	elseif not skins[name] then
		return false, "no_skin"
	elseif name == "handler" or name == "num" then
		return false, "invalid"
	end

	C.db.profile.skin = name

	E:FlushToastsCache()

	return true
end

function E.GetSkinFunc()
	return skins[C.db.profile.skin] and skins[C.db.profile.skin].func or  skins.Default.func
end

function E.GetNumSkins()
	return num
end

function E.GetAllSkins()
	local t = {}

	for k in next, skins do
		t[k] = k
	end

	return t
end
