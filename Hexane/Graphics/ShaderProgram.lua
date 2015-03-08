--[[
	Hexane for LuaJIT
	ShaderProgram Class
]]

local Hexane = (...)
local Carbon = Hexane.Carbon
local OOP = Carbon.OOP
local Shader = Hexane.Graphics.Shader

local ffi = require("ffi")

Hexane.Bindings.OpenGL:ImportAll()



local types = {
	float = GL.FLOAT
}

local ShaderProgram = OOP:Class()
	:Members {
		__uniforms = {},
		__shaders = {}
	}

function ShaderProgram:_init()
	self.Program = gl.CreateProgram()
end

function ShaderProgram:Destroy()
	if (self.Program) then
		gl.DeleteProgram(self.Program)
	end
end

function ShaderProgram:GetAttributeLocation(name)
	return gl.GetAttribLocation(self.Program, name)
end

function ShaderProgram:AddUniform(name, suffix)
	self.__uniforms[name] = {suffix, gl.GetUniformLocation(self.Program, name)}
end

function ShaderProgram:SetUniform(name, ...)
	local uniform = self.__uniforms[name]

	if (uniform) then
		local suffix = uniform[1]
		local location = uniform[2]
		gl["Uniform" .. suffix](location, ...)
	end
end

function ShaderProgram:AddAttribute(position, name)
	gl.BindAttribLocation(self.Program, position, name)
end

function ShaderProgram:BindFragDataLocation(position, name)
	gl.BindFragDataLocation(self.Program, position, name)
end

function ShaderProgram:Attach(shader)
	gl.AttachShader(self.Program, shader.__shader)
end

function ShaderProgram:AttachSource(shader_type, source)
	local shader = Shader:New(shader_type, source)

	self:Attach(shader)

	return shader
end

function ShaderProgram:Link()
	gl.LinkProgram(self.Program)
end

function ShaderProgram:Use()
	gl.UseProgram(self.Program)
end

return ShaderProgram