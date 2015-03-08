--[[
	Hexane for LuaJIT
	C Bindings

	Provides a couple useful methods from the C standard library.
]]

local Hexane = (...)

local ffi = require("ffi")

local C = ffi.C

ffi.cdef([[
void* malloc(size_t size);
void* realloc(void* ptr, size_t size);
void free(void* ptr);
]])

return C