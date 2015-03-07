--[[
	Hexane for LuaJIT
	ModuleNotInitializedException
]]

local Hexane = (...)

local ModuleNotInitializedException = Hexane.Carbon.OOP:Class()
	:Inherits(Hexane.Carbon.Exception)

function ModuleNotInitializedException:_init(module_name)
	self.Message = ("Module '%s' must be initialized to use this functionality!"):format(module_name)
	self.Module = module_name
end

return ModuleNotInitializedException