--[[
	Hexane for LuaJIT
	Shader Class
]]

local Hexane = (...)
local Carbon = Hexane.Carbon
local OOP = Carbon.OOP

local ffi = require("ffi")

Hexane.Bindings.OpenGL:ImportAll()

local shader_types = {
	vertex = GL.VERTEX_SHADER,
	fragment = GL.FRAGMENT_SHADER
}

local types = {
	float = GL.FLOAT
}

local Shader = OOP:Class()
	:Members {
		__uniforms = {}
	}

function Shader:_init()
	self.Program = gl.CreateProgram()
end

function Shader:GetAttributeLocation(name)
	return gl.GetAttribLocation(self.Program, name)
end

function Shader:AddUniform(name, suffix)
	self.__uniforms[name] = {suffix, gl.GetUniformLocation(self.Program, name)}
end

function Shader:SetUniform(name, ...)
	local uniform = self.__uniforms[name]

	if (uniform) then
		local suffix = uniform[1]
		local location = uniform[2]
		gl["Uniform" .. suffix](location, ...)
	end
end

function Shader:AddAttribute(position, name)
	gl.BindAttribLocation(self.Program, position, name)
end

function Shader:BindFragDataLocation(position, name)
	gl.BindFragDataLocation(self.Program, position, name)
end

function Shader:Attach(shader_type, source)
	local interned = ffi.new("const char *const[1]", ffi.new("const char*", source))

	local shader = gl.CreateShader(shader_types[shader_type])
	gl.ShaderSource(shader, 1, interned, nil)
	gl.CompileShader(shader)

	local status = ffi.new("GLint[1]")
	gl.GetShaderiv(shader, GL.COMPILE_STATUS, status)

	if (status[0] ~= GL.TRUE) then
		local buffer = ffi.new("char[512]")
		gl.GetShaderInfoLog(shader, 512, nil, buffer)
		error(ffi.string(buffer))
	end

	gl.AttachShader(self.Program, shader)

	return shader
end

function Shader:Link()
	gl.LinkProgram(self.Program)
end

function Shader:Use()
	gl.UseProgram(self.Program)
end

return Shader