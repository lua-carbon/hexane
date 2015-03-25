--[[
	Hexane for LuaJIT
	Clearer
]]

local Hexane = (...)
local Carbon = Hexane.Carbon
local OOP = Carbon.OOP

Hexane.Bindings.OpenGL:ImportAll()

local bit = require("bit")

local clear_values = {
	GL.COLOR_BUFFER_BIT,
	GL.DEPTH_BUFFER_BIT
}

local Clearer = OOP:Class()

function Clearer:Init(color, depth)
	color = (color == nil) and true or color
	depth = (depth == nil) and true or depth

	self.__clears = {color, depth}
	self.__color = {0, 0, 0, 1}

	self.__mask = 0
	for i, value in ipairs(self.__clears) do
		if (value) then
			self.__mask = bit.bor(self.__mask, clear_values[i])
		end
	end
end

function Clearer:SetColor(r, g, b, a)
	self.__color[1] = r or self.__color[1]
	self.__color[2] = g or self.__color[2]
	self.__color[3] = b or self.__color[3]
	self.__color[4] = a or self.__color[4]
end

function Clearer:Draw()
	gl.ClearColor(self.__color[1], self.__color[2], self.__color[3], self.__color[4])
	gl.Clear(self.__mask)
end

return Clearer