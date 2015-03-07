--[[
	Hexane for LuaJIT
	Mesh Class
]]

local Hexane = (...)
local Carbon = Hexane.Carbon
local OOP = Carbon.OOP
local GraphicsNotInitializedException = Hexane.Exceptions.GraphicsNotInitializedException

Hexane.Bindings.OpenGL:ImportAll()

local ffi = require("ffi")

local types = {
	float = GL.FLOAT
}

local Mesh = OOP:Class()

function Mesh:_init(l_vertices, l_elements, attributes)
	if (not Hexane.Graphics:IsInitialized()) then
		return nil, GraphicsNotInitializedException:New()
	end

	local p_vao = ffi.new("GLuint[1]")
	gl.GenVertexArrays(1, p_vao)
	gl.BindVertexArray(p_vao[0])
	self.__vao = p_vao[0]

	local vertices = ffi.new("float[?]", #l_vertices, l_vertices)
	self.__vertices = vertices
	self.__vertex_count = #l_vertices

	local p_vbo = ffi.new("GLuint[1]")
	gl.GenBuffers(1, p_vbo)
	gl.BindBuffer(GL.ARRAY_BUFFER, p_vbo[0])
	gl.BufferData(GL.ARRAY_BUFFER, ffi.sizeof(vertices), vertices, GL.STATIC_DRAW)
	self.__vbo = p_vbo[0]

	if (l_elements) then
		local elements = ffi.new("GLuint[?]", #l_elements, l_elements)
		self.__elements = elements
		self.__element_count = #l_elements

		local p_ebo = ffi.new("GLuint[1]")
		gl.GenBuffers(1, p_ebo)
		gl.BindBuffer(GL.ELEMENT_ARRAY_BUFFER, p_ebo[0])
		gl.BufferData(GL.ELEMENT_ARRAY_BUFFER, ffi.sizeof(elements), elements, GL.STATIC_DRAW)
		self.__ebo = p_ebo[0]
	end

	if (attributes) then
		for i, v in ipairs(attributes) do
			v:Apply()
		end
	end
end

function Mesh:AddAttribute(attribute)
	gl.BindVertexArray(self.__vao)
	attribute:Apply()
end

function Mesh:Draw()
	gl.BindVertexArray(self.__vao)

	if (self.__elements) then
		gl.DrawElements(GL.TRIANGLES, self.__element_count, GL.UNSIGNED_INT, nil)
	else
		gl.DrawArrays(GL.TRIANGLES, 0, self.__vertex_count)
	end
end

return Mesh