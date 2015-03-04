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