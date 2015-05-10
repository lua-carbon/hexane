--[[
	Hexane for LuaJIT
	MouseContext
]]

local Hexane = (...)
local Carbon = Hexane.Carbon
local OOP = Carbon.OOP
local InputContext = Hexane.Input.InputContext
local GLFW = Hexane.Bindings.GLFW

local ffi = require("ffi")

local mouse_modes = {
	disabled = GLFW.CURSOR_DISABLED,
	hidden = GLFW.CURSOR_HIDDEN,
	normal = GLFW.CURSOR_NORMAL
}

local actions = Hexane.FFIMap {
	[GLFW.PRESS] = "press",
	[GLFW.RELEASE] = "release"
}

local mouse_buttons = Hexane.FFIMap {
	[GLFW.MOUSE_BUTTON_1] = 1,
	[GLFW.MOUSE_BUTTON_2] = 2,
	[GLFW.MOUSE_BUTTON_3] = 3,
	[GLFW.MOUSE_BUTTON_4] = 4,
	[GLFW.MOUSE_BUTTON_5] = 5,
	[GLFW.MOUSE_BUTTON_6] = 6,
	[GLFW.MOUSE_BUTTON_7] = 7,
	[GLFW.MOUSE_BUTTON_8] = 8,
}

local MouseContext = OOP:Class()
	:Inherits(InputContext)
	:Members {
		Name = "Mouse"
	}

function MouseContext:Init(window)
	local status, exception = InputContext.Init(self, window)
	if (exception) then
		return false, exception
	end

	local callback_move = ffi.cast("GLFWcursorposfun", function(context, x, y)
		window:QueueEvent("MouseMove", x, y)
	end)

	local callback_enter = ffi.cast("GLFWcursorenterfun", function(context, state)
		window:QueueEvent("MouseEnter", state ~= 0)
	end)

	local callback_click = ffi.cast("GLFWmousebuttonfun", function(context, glfw_button, glfw_action, mods)
		local button = mouse_buttons[glfw_button]
		local action = actions[glfw_action]

		window:QueueEvent("MouseButton", button, action, mods)

		if (action == "press") then
			window:QueueEvent("MouseButtonDown", button, mods)
		elseif (action == "release") then
			window:QueueEvent("MouseButtonUp", button, mods)
		end
	end)

	local callback_scroll = ffi.cast("GLFWscrollfun", function(context, x, y)
		window:QueueEvent("MouseScroll", x, y)
	end)

	GLFW.SetCursorPosCallback(window.__context, callback_move)
	GLFW.SetCursorEnterCallback(window.__context, callback_enter)
	GLFW.SetMouseButtonCallback(window.__context, callback_click)
	GLFW.SetScrollCallback(window.__context, callback_scroll)
end

function MouseContext:IsButtonDown(button)
	local state = GLFW.GetMouseButton(self.__window.__context, mouse_buttons.Inverse[button])

	if (state == GLFW.PRESS) then
		return true
	else
		return false
	end
end

function MouseContext:SetMode(mode)
	GLFW.SetInputMode(self.__window.__context, GLFW.CURSOR, mouse_modes[mode])
end

function MouseContext:GetPosition()
	local pos = ffi.new("double[2]")
	GLFW.GetCursorPos(self.__window.__context, pos, pos + 1)
	return pos[0], pos[1]
end

function MouseContext:SetPosition(x, y)
	GLFW.SetCursorPos(self.__window.__context, x, y)
end

return MouseContext