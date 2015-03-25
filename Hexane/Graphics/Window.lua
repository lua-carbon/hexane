--[[
	Hexane for LuaJIT
	Window
]]

local Hexane = (...)
local Carbon = Hexane.Carbon
local OOP = Carbon.OOP
local WindowInfo = Hexane.Graphics.WindowInfo
local GLFW = Hexane.Bindings.GLFW
Hexane.Bindings.OpenGL:ImportAll()

local ffi = require("ffi")

local inverse_profiles = {
	[tonumber(GLFW.OPENGL_CORE_PROFILE)] = "Core",
	[tonumber(GLFW.OPENGL_COMPAT_PROFILE)] = "Compatibility",
	[tonumber(GLFW.OPENGL_ANY_PROFILE)] = "Any"
}

local blends = {
	["src_alpha"] = GL.SRC_ALPHA,
	["one_minus_src_alpha"] = GL.ONE_MINUS_SRC_ALPHA
	-- todo: the rest of these
}

local Window = OOP:Class()
	:Attributes {
		InstanceIndirection = true
	}

function Window:Init(info)
	info = info or WindowInfo:New()

	local window, exception = info:CreateWindow()

	if (window == nil) then
		return nil, exception
	end

	self.__info = info
	self.__window = window

	self:Use()
	gl.ClearColor(0, 0, 0, 1)
end

function Window:SetBlendMode(a, b)
	gl.BlendFunc(blends[a], blends[b])
end

function Window:EnableDepthTest()
	gl.Enable(GL.DEPTH_TEST)
end

function Window:EnableAlphaBlending()
	gl.Enable(GL.BLEND)
end

function Window:GetSize()
	local size = ffi.new("int[2]")
	GLFW.GetWindowSize(self.__window, size, size + 1)
	return size[0], size[1]
end

function Window:SetSize(w, h)
	GLFW.SetWindowSize(self.__window, w, h)
end

function Window:GetPosition()
	local pos = ffi.new("int[2]")
	GLFW.GetWindowPos(self.__window, pos, pos + 1)
	return pos[0], pos[1]
end

function Window:SetPosition(x, y)
	GLFW.SetWindowPos(self.__window, x, y)
end

function Window:GetMousePosition()
	local pos = ffi.new("double[2]")
	GLFW.GetCursorPos(self.__window, pos, pos + 1)
	return pos[0], pos[1]
end

function Window:GetNativeHandle()
	return self.__window
end

function Window:GetContextVersionString()
	return ("OpenGL %s.%s.%s %s Context"):format(self:GetContextVersion())
end

function Window:GetContextVersion()
	local major = GLFW.GetWindowAttrib(self.__window, GLFW.CONTEXT_VERSION_MAJOR)
	local minor = GLFW.GetWindowAttrib(self.__window, GLFW.CONTEXT_VERSION_MINOR)
	local revision = GLFW.GetWindowAttrib(self.__window, GLFW.CONTEXT_REVISION)
	local glfw_profile = GLFW.GetWindowAttrib(self.__window, GLFW.OPENGL_PROFILE)
	local profile = inverse_profiles[tonumber(glfw_profile)]

	return major, minor, revision, profile
end

function Window:ShouldClose()
	return (GLFW.WindowShouldClose(self.__window) ~= 0)
end

function Window:SwapBuffers()
	GLFW.SwapBuffers(self.__window)
end

function Window:PollEvents()
	GLFW.PollEvents()
end

function Window:SetVSync(vsync)
	if (vsync) then
		GLFW.SwapInterval(1)
	else
		GLFW.SwapInterval(0)
	end
end

function Window:Use()
	GLFW.MakeContextCurrent(self.__window)
end

function Window:Copy()
	return self
end

function Window:Destroy()
	if (self.__window) then
		GLFW.DestroyWindow(self.__window)
	end
end

return Window