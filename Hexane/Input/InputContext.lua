--[[
	Hexane for LuaJIT
	InputContext
]]

local Hexane = (...)
local Carbon = Hexane.Carbon
local OOP = Carbon.OOP
local InputContextAlreadyRegisteredException = Hexane.Exceptions.InputContextAlreadyRegisteredException

local InputContext = OOP:Class()
	:Members {
		Name = "UnnamedInputContext"
	}

function InputContext:Init(window)
	if (window[self.Name]) then
		return false, InputContextAlreadyRegisteredException:New(self.Name)
	end

	self.__window = window
	window[self.Name] = self
end

return InputContext