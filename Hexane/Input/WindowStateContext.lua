--[[
	Hexane for LuaJIT
	WindowStateContext
]]

local Hexane = (...)
local Carbon = Hexane.Carbon
local OOP = Carbon.OOP
local InputContext = Hexane.Input.InputContext

local ffi = require("ffi")

local WindowStateContext = OOP:Class()
	:Inherits(InputContext)
	:Members {
		Name = "WindowState"
	}

function WindowStateContext:Init(window)
	local status, exception = InputContext.Init(self, window)
	if (exception) then
		return false, exception
	end

	local callback_close = ffi.cast("GLFWwindowclosefun", function()
		window:Fire("Close")
	end)

	GLFW.SetWindowCloseCallback(window.__context, callback_close)
end

return WindowStateContext