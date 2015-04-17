--[[
	Hexane for LuaJIT
	Window
]]

local Hexane = (...)
local Carbon = Hexane.Carbon
local OOP = Carbon.OOP
local ContextInfo = Hexane.Graphics.ContextInfo
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

local depths = {
	["never"] = GL.NEVER,
	["less"] = GL.LESS,
	["equal"] = GL.EQUAL,
	["lequal"] = GL.LEQUAL,
	["greater"] = GL.GREATER,
	["notequal"] = GL.NOTEQUAL,
	["gequal"] = GL.GEQUAL,
	["always"] = GL.ALWAYS
}

local features = {
	["depth"] = GL.DEPTH_TEST,
	["blending"] = GL.BLEND
}

local Window = OOP:Class()
	:Attributes {
		InstanceIndirection = true
	}

function Window:Init(info)
	info = info or ContextInfo:New()

	local context, exception = info:CreateContext()

	if (context == nil) then
		return nil, exception
	end

	self.__info = info
	self.__context = context

	self:Use()
end

function Window:SetTube(tube)
	self.__tube = tube
end

function Window:GetTube()
	return self.__tube
end

function Window:Fire(name, ...)
	if (self.__tube) then
		self.__tube:Fire(name, ...)
	end
end

function Window:SetBlendMode(a, b)
	gl.BlendFunc(blends[a], blends[b])
end

function Window:SetDepthFunction(name)
	gl.DepthFunc(depths[name])
end

function Window:EnableFeature(feature)
	gl.Enable(features[feature])
end

function Window:DisableFeature(feature)
	gl.Disable(features[feature])
end

function Window:GetSize()
	local size = ffi.new("int[2]")
	GLFW.GetWindowSize(self.__context, size, size + 1)
	return size[0], size[1]
end

function Window:SetSize(w, h)
	GLFW.SetWindowSize(self.__context, w, h)
end

function Window:GetPosition()
	local pos = ffi.new("int[2]")
	GLFW.GetWindowPos(self.__context, pos, pos + 1)
	return pos[0], pos[1]
end

function Window:SetPosition(x, y)
	GLFW.SetWindowPos(self.__context, x, y)
end

function Window:GetNativeHandle()
	return self.__context
end

function Window:GetContextVersionString()
	return ("OpenGL %s.%s.%s %s Context"):format(self:GetContextVersion())
end

function Window:GetContextVersion()
	local major = GLFW.GetWindowAttrib(self.__context, GLFW.CONTEXT_VERSION_MAJOR)
	local minor = GLFW.GetWindowAttrib(self.__context, GLFW.CONTEXT_VERSION_MINOR)
	local revision = GLFW.GetWindowAttrib(self.__context, GLFW.CONTEXT_REVISION)
	local glfw_profile = GLFW.GetWindowAttrib(self.__context, GLFW.OPENGL_PROFILE)
	local profile = inverse_profiles[tonumber(glfw_profile)]

	return major, minor, revision, profile
end

function Window:ShouldClose()
	return (GLFW.WindowShouldClose(self.__context) ~= 0)
end

function Window:SwapBuffers()
	GLFW.SwapBuffers(self.__context)
end

function Window:PollEvents()
	GLFW.PollEvents()
end

function Window:WaitEvents()
	GLFW.WaitEvents()
end

function Window:PostEmptyEvent()
	GLFW.PostEmptyEvent()
end

function Window:GetClipboardString()
	return ffi.string(GLFW.GetClipboardString(self.__context))
end

function Window:SetClipboardString(body)
	GLFW.SetClipboardString(self.__context, body)
end

function Window:SetVSync(vsync)
	if (vsync) then
		GLFW.SwapInterval(1)
	else
		GLFW.SwapInterval(0)
	end
end

function Window:Use()
	GLFW.MakeContextCurrent(self.__context)
end

function Window:Copy()
	return self
end

function Window:Destroy()
	if (self.__context) then
		GLFW.DestroyWindow(self.__context)
	end
end

return Window