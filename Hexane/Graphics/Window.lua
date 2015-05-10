--[[
	Hexane for LuaJIT
	Window
]]

local Hexane = (...)
local Carbon = Hexane.Carbon
local OOP = Carbon.OOP
local Nanotube = Carbon.Nanotube
local Time = Carbon.Time
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
	["blending"] = GL.BLEND,
	["face_culling"] = GL.CULL_FACE
}

local Window = OOP:Class()
	:Inherits(Nanotube)
	:Attributes {
		InstanceIndirection = true
	}
	:Members {
		__queued_events = {},
		MaxRate = 1 / 120,
		LastTime = 0,
		Time = 0,
		DeltaTime = 0
	}

function Window:Init(info)
	Nanotube.Init(self)
	self.UseSleep = false

	info = info or ContextInfo:New()

	local context, exception = info:CreateContext()

	if (context == nil) then
		return nil, exception
	end

	self.__info = info
	self.__context = context

	self.LastTime = Time:Get()
	self.Time = Time:Get()
	self.DeltaTime = 0

	self:Use()
end

function Window:QueueEvent(name, ...)
	table.insert(self.__queued_events, {name, ...})
end

function Window:FireEvents()
	for key, event in ipairs(self.__queued_events) do
		self:Fire(unpack(event))
	end
	
	self.__queued_events = {}
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

function Window:GetFramebufferSize()
	local size = ffi.new("int[2]")
	GLFW.GetFramebufferSize(self.__context, size, size + 1)
	return size[0], size[1]
end

function Window:GetWindowSize()
	local size = ffi.new("int[2]")
	GLFW.GetWindowSize(self.__context, size, size + 1)
	return size[0], size[1]
end

function Window:SetWindowSize(w, h)
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

function Window:Step()
	if (self:ShouldClose()) then
		self:Stop()
	else
		self:PollEvents()
		self:FireEvents()

		self:Fire("Update", self.DeltaTime)
		self:Fire("Draw")
		self:SwapBuffers()

		Time.Sleep(self.MaxRate)

		self.Time = Time:Get()
		self.DeltaTime = self.Time - self.LastTime
		self.LastTime = self.Time
	end
end

return Window