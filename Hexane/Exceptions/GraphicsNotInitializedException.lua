--[[
	Hexane for LuaJIT
	GraphicsNotInitializedException
]]

local Hexane = (...)

local GraphicsNotInitializedException = Hexane.Carbon.OOP:Class()
	:Inherits(Hexane.Exceptions.ModuleNotInitializedException)

function GraphicsNotInitializedException:Init()
	self.Message = "The Graphics module must be initialized to use this functionality!"
	self.Module = "Graphics"
end

return GraphicsNotInitializedException