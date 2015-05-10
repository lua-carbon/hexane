--[[
	Hexane for LuaJIT
	Core
]]

assert(jit, "Hexane for LuaJIT requires LuaJIT!")

local libHexane = (...)
local ffi = require("ffi")

libHexane:AddGrapheneSubmodule("Carbon")

local Hexane = {
	Version = {1, 0, 0},

	Config = {
	}
}

Hexane.VersionString = ("%d.%d.%d%s%s"):format(
	Hexane.Version[1],
	Hexane.Version[2],
	Hexane.Version[3],
	Hexane.Version[4] and "-" or "",
	Hexane.Version[4] or ""
)

Hexane.FFIMap = function(dict)
	local out = {
		Inverse = {}
	}

	for key, value in pairs(dict) do
		out[tonumber(key)] = value
		out.Inverse[value] = tonumber(key)
	end

	return out
end

do
	local unpack_cache = {}
	local function generate_unpack(n)
		local str_buffer = {}
		for i = 1, n do
			table.insert(str_buffer, ("arr[%d]"):format(i))
		end
		local str = table.concat(str_buffer, ",")

		return loadstring(("return function(arr) return %s end"):format(str))()
	end

	Hexane.UnpackN = function(array, n)
		n = n or #array

		if (n > 8) then
			return unpack(array)
		end

		if (not __unpack_cache[n]) then
			unpack_cache[n] = generate_unpack(n)
		end

		return unpack_cache[n](array)
	end
end

-- Shims for Hexane core!
for key, value in pairs(Hexane) do
	libHexane[key] = value
end

-- Windows!
if (ffi.os == "Windows") then
	ffi.cdef([[
		int SetDllDirectoryA(const char* lpPathName);
	]])

	ffi.C.SetDllDirectoryA("bin");
end

return Hexane