--[[
	Hexane for LuaJIT
	ContextInfo
]]

local Hexane = (...)
local Carbon = Hexane.Carbon
local OOP = Carbon.OOP
local Graphics = Hexane.Graphics
local GLFW = Hexane.Bindings.GLFW
Hexane.Bindings.OpenGL:ImportAll()

local profiles = {
	Any = GLFW.OPENGL_ANY_PROFILE,
	Core = GLFW.OPENGL_CORE_PROFILE,
	Compatibility = GLFW.OPENGL_COMPAT_PROFILE
}

local ContextInfo = OOP:Class()
	:Members {
		Debug = false,
		Resizable = false,
		ForwardCompatible = false,
		VSync = false,
		Windowed = true,
		Borderless = false,
		DepthBits = 0,
		ContextVersions = {
			{4.5, "Compatibility"},
			{4.4, "Compatibility"},
			{4.3, "Compatibility"},
			{4.2, "Compatibility"},
			{4.1, "Compatibility"},
			{4.0, "Compatibility"},
			{3.3, "Compatibility"},
			{3.2, "Compatibility"},
			{3.2, "Core"},
			{3.1, "Core"},
			{3.0, "Core"},
			{2.1, "Any"}
		},
		Width = 800,
		Height = 600,
		Title = "Hexane",
		ShareResourcesWith = nil
	}

function ContextInfo:Init()
end

local function try_context(self, version)
	local version_num, profile
	if (type(version) == "table") then
		version_num = version[1]
		profile = version[2] or "Any"
	else
		version_num = version
		profile = "Any"
	end

	local glfw_profile = profiles[profile]
	if (not glfw_profile) then
		error("Cannot apply ContextInfo: invalid profile '" .. tostring(profile) .. "'", 2)
	end

	local major, minor = math.modf(version_num)
	minor = math.floor(minor * 10)

	GLFW.WindowHint(GLFW.CONTEXT_VERSION_MAJOR, major)
	GLFW.WindowHint(GLFW.CONTEXT_VERSION_MINOR, minor)
	GLFW.WindowHint(GLFW.OPENGL_PROFILE, glfw_profile)
	
	if (self.Windowed) then
		return GLFW.CreateWindow(self.Width, self.Height, self.Title, nil, self.ShareResourcesWith and self.ShareResourcesWith.__window)
	else
		return GLFW.CreateWindow(self.Width, self.Height, self.Title, GLFW.GetPrimaryMonitor(), self.ShareResourcesWith and self.ShareResourcesWith.__window)
	end
end

function ContextInfo:CreateContext()
	Graphics:Initialize()

	GLFW.WindowHint(GLFW.OPENGL_FORWARD_COMPAT, self.ForwardCompatible and GL.TRUE or GL.FALSE)
	GLFW.WindowHint(GLFW.RESIZABLE, self.Resizable and GL.TRUE or GL.FALSE)
	GLFW.WindowHint(GLFW.OPENGL_DEBUG_CONTEXT, self.Debug and GL.TRUE or GL.FALSE)
	GLFW.WindowHint(GLFW.DEPTH_BITS, self.DepthBits)

	local context
	if (self.ContextVersion) then
		context = try_context(self, self.ContextVersion)
	end

	if (not context and self.ContextVersions) then
		for i = 1, #self.ContextVersions do
			context, version = try_context(self, self.ContextVersions[i])

			if (context ~= nil) then
				break
			end
		end
	end

	if (context == nil) then
		return nil, Hexane.Exceptions.ContextCreationException:New()
	end

	GLFW.MakeContextCurrent(context)

	if (self.VSync) then
		GLFW.SwapInterval(1)
	else
		GLFW.SwapInterval(0)
	end

	return context
end

return ContextInfo