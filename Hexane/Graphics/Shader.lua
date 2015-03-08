--[[
	Hexane for LuaJIT
	Shader Class

	Contains individual shaders, like vertex shaders and pixel shaders.
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

local Shader = OOP:Class()

function Shader:_init(shader_type, source)
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

	self.Type = shader_type
	self.__source = source
	self.__shader = shader

	return shader
end

return Shader