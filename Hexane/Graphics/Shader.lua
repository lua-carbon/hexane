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

function Shader:_init()
	self.Program = gl.CreateProgram()
end

function Shader:AddAttribute(name, count, typeof, stride, size)
	local attrib = gl.GetAttribLocation(self.Program, name)
	gl.VertexAttribPointer(attrib, count, types[typeof], GL.FALSE, stride * ffi.sizeof(typeof), ffi.cast("void*", size * ffi.sizeof(typeof)))
	gl.EnableVertexAttribArray(attrib)
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