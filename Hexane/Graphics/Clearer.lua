--[[
	Hexane for LuaJIT
	Clearer
]]

local Hexane = (...)
local Carbon = Hexane.Carbon
local OOP = Carbon.OOP

Hexane.Bindings.OpenGL:ImportAll()

local Clearer = OOP:Class()

function Clearer:_init(r, g, b, a)
	r = r or 0
	g = g or 0
	b = b or 0
	a = a or 1

	self.__color = {r, g, b, a}
end

function Clearer:Draw()
	gl.ClearColor(self.__color[1], self.__color[2], self.__color[3], self.__color[4])
	gl.Clear(GL.COLOR_BUFFER_BIT)
end

return Clearer