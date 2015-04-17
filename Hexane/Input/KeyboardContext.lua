--[[
	Hexane for LuaJIT
	KeyboardContext
]]

local Hexane = (...)
local Carbon = Hexane.Carbon
local OOP = Carbon.OOP
local InputContext = Hexane.Input.InputContext

local ffi = require("ffi")

local KeyboardContext = OOP:Class()
	:Inherits(InputContext)
	:Members {
		Name = "Keyboard"
	}

function KeyboardContext:Init(window)
	local status, exception = InputContext.Init(self, window)
	if (exception) then
		return false, exception
	end

	--[[
		NOTE:
		It might be a good idea to keep a single callback for each event and a context/window lookup table as
		LuaJIT has a limited number of callbacks.
	]]

	local callback_key = ffi.cast("GLFWkeyfun", function(context, key, scancode, action, mods)
		window:Fire("Key", key, scancode, action, mods)
	end)

	local callback_text = ffi.cast("GLFWcharfun", function(context, codepoint)
		window:Fire("Text", codepoint)
	end)

	GLFW.SetKeyCallback(window.__context, callback_key)
	GLFW.SetCharCallback(window.__context, callback_text)
end

return KeyboardContext