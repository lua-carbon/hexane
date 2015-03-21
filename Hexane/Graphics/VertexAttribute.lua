--[[
	Hexane for LuaJIT
	VertexAttribute
]]

local Hexane = (...)
local Carbon = Hexane.Carbon
local OOP = Carbon.OOP

local ffi = require("ffi")

Hexane.Bindings.OpenGL:ImportAll()

local types = {
	float = GL.FLOAT
}

local VertexAttribute = OOP:Class()

function VertexAttribute:Init(position, count, typeof, stride, size)
	self.__position = position
	self.__count = count
	self.__type = types[typeof]
	self.__stride = stride * ffi.sizeof(typeof)
	self.__size = ffi.cast("void*", size * ffi.sizeof(typeof))
end

function VertexAttribute:Apply()
	gl.VertexAttribPointer(self.__position, self.__count, self.__type, GL.FALSE, self.__stride, self.__size)
	gl.EnableVertexAttribArray(self.__position)
end

return VertexAttribute