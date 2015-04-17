--[[
	Hexane for LuaJIT
	InputContextAlreadyRegisteredException
]]

local Hexane = (...)

local InputContextAlreadyRegisteredException = Hexane.Carbon.OOP:Class()
	:Inherits(Hexane.Carbon.Exception)

function InputContextAlreadyRegisteredException:Init(name)
	self.Message = "The input context for '" .. name .. "' has already been registered and cannot be registered again."
end

return InputContextAlreadyRegisteredException