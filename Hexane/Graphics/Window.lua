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

local Window = OOP:Class()
	:Attributes {
		InstanceIndirection = true
	}

local inverse_profiles = {
	[tonumber(GLFW.OPENGL_CORE_PROFILE)] = "Core",
	[tonumber(GLFW.OPENGL_COMPAT_PROFILE)] = "Compatibility",
	[tonumber(GLFW.OPENGL_ANY_PROFILE)] = "Any"
}

function Window:_init(info)
	info = info or WindowInfo:New()

	local window, exception = info:CreateWindow()

	if (not window) then
		return false, exception
	end

	self.__info = info
	self.__window = window
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

function Window:MakeCurrent()
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