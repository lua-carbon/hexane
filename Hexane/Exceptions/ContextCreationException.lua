--[[
	Hexane for LuaJIT
	ContextCreationException
]]

local Hexane = (...)
local Carbon = Hexane.Carbon
local OOP = Carbon.OOP

local ContextCreationException = OOP:Class()
	:Inherits(Carbon.Exception)
	:Members {
		Message = "Could not create graphics context!"
	}

function ContextCreationException:Init()
end

return ContextCreationException