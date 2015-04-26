--[[
	Hexane for LuaJIT
	KeyboardContext
]]

local Hexane = (...)
local Carbon = Hexane.Carbon
local OOP = Carbon.OOP
local InputContext = Hexane.Input.InputContext
local GLFW = Hexane.Bindings.GLFW
local KeyMap = Hexane.Input.KeyMap

local ffi = require("ffi")

local function fix_ffi_map(dict)
	local out = {}

	for key, value in pairs(dict) do
		out[tonumber(key)] = value
	end

	return out
end

local actions = fix_ffi_map {
	[GLFW.PRESS] = "press",
	[GLFW.RELEASE] = "release"
}

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

	local callback_key = ffi.cast("GLFWkeyfun", function(context, glfw_key, scancode, glfw_action, mods)
		local key = KeyMap[glfw_key]
		local action = actions[glfw_action]

		window:QueueEvent("Key", key, scancode, action, mods)

		if (action == "press") then
			window:QueueEvent("KeyDown", key, scancode, mods)
		elseif (action == "release") then
			window:QueueEvent("KeyUp", key, scancode, mods)
		end
	end)

	local callback_text = ffi.cast("GLFWcharfun", function(context, codepoint)
		window:QueueEvent("Text", codepoint)
	end)

	GLFW.SetKeyCallback(window.__context, callback_key)
	GLFW.SetCharCallback(window.__context, callback_text)
end

function KeyboardContext:IsKeyDown(key)
	local state = GLFW.GetKey(self.__window.__context, KeyMap.Inverse[key])

	if (state == GLFW.PRESS) then
		return true
	else
		return false
	end
end

return KeyboardContext