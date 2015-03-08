-- Sample: Make a Window, draw a couple rectangle meshes

local ffi = require("ffi")
local Hexane = require("Hexane")
local Time = Hexane.Carbon.Time
local Nanotube = Hexane.Carbon.Nanotube

-- Create an object with information about the window we'll be making.
local info = Hexane.Graphics.WindowInfo:New()
info.Title = "Hexane: Sample #1"
info.Width = 1280
info.Height = 720

-- Creating a new window automatically sets it as the current window
local window, exception = Hexane.Graphics.Window:New(info)

if (window == nil) then
	exception:Throw()
end

print(window:GetContextVersionString())

-- This could be a little friendlier
window:EnableAlphaBlending()
window:SetBlendMode("src_alpha", "one_minus_src_alpha")

-- Create a 'Clearer' which manages clearing the buffer between frames
local clearer = Hexane.Graphics.Clearer:New()

-- Create a mesh given a list of vertices (VBO) and elements (EBO)
local vertices = {
	-0.5, 0.5, 1, 0, 0, 0, 0,
	0.5, 0.5, 0, 1, 0, 1, 0,
	0.5, -0.5, 0, 0, 1, 1, 1,
	-0.5, -0.5, 1, 1, 1, 0, 1,
}

local elements = {
	0, 1, 2,
	2, 3, 0
}

-- Shader sources!
local vertex_source = [[
#version 150

uniform vec2 rect_position;

in vec2 position;
in vec3 color;
in vec2 texcoord;

out vec3 Color;
out vec2 Texcoord;

void main() {
	Color = color;
	Texcoord = texcoord;
	gl_Position = vec4(rect_position + position, 0.0, 1.0);
}
]]

local fragment_source = [[
#version 150

in vec3 Color;
in vec2 Texcoord;

out vec4 outColor;

uniform sampler2D tex;

void main() {
	outColor = texture(tex, Texcoord) * vec4(Color, 1.0);
}
]]

-- Create a shader program using our sources above
-- You could also create individual Shader objects for each piece
-- and link those in to prevent recompilation.
local shader = Hexane.Graphics.ShaderProgram:New()
shader:AttachSource("vertex", vertex_source)
shader:AttachSource("fragment", fragment_source)

-- Assign these attributes positions
shader:AddAttribute(0, "position")
shader:AddAttribute(1, "color")
shader:AddAttribute(2, "texcoord")

-- Link and use the shader!
shader:Link()
shader:Use()

-- Bind our pixel data out location
shader:BindFragDataLocation(0, "outColor")

-- Add a rect_position uniform for positioning our rectangles
shader:AddUniform("rect_position", "2f")
shader:SetUniform("rect_position", 0, 0)
shader:AddUniform("tex", "1i")
shader:SetUniform("tex", 0)

-- Create some attributes to define our mesh data
local position_attribute = Hexane.Graphics.VertexAttribute:New(0, 2, "float", 7, 0)
local color_attribute = Hexane.Graphics.VertexAttribute:New(1, 3, "float", 7, 2)
local texcoord_attrib = Hexane.Graphics.VertexAttribute:New(2, 2, "float", 7, 5)

-- Group these attributes!
local attributes = {
	position_attribute,
	color_attribute,
	texcoord_attrib
}

-- Create meshes with the given vertices, elements, and attributes
local mesh = Hexane.Graphics.Mesh:New(vertices, elements, attributes)
local mesh2 = Hexane.Graphics.Mesh:New(vertices, elements, attributes)

-- Load an image using the plain STB interface
local stbi = Hexane.Bindings.STB.Image
local out = ffi.new("int[3]")
local image = stbi.stbi_load("assets/hexane-icon.png", out, out + 1, out + 2, stbi.STBI_rgb_alpha)
local format = (out[2] == 3) and "rgb" or "rgba"

-- Stuff our image into a TextureData object
local texture_data = Hexane.Graphics.TextureData:New("uint8_t", "rgba", out[0], out[1])
texture_data:SetData(image, out[0] * out[1] * out[2])

-- Get rid of the STB-provided image
stbi.stbi_image_free(image)

-- Load up a texture to contain our image
local texture = Hexane.Graphics.Texture:New()
texture:SetData(texture_data)
texture:Bind(0)

-- Begin loop preparations
local tube = Nanotube.Global
tube.UseSleep = false

local rate = 1 / 120
local ot = Time:Get()
local t = Time:Get()
local dt = t - ot

-- Tell the tube what to do on draw
tube:On("Draw", function(dt)
	clearer:Draw()

	local w, h = window:GetSize()
	local x, y = window:GetMousePosition()

	shader:SetUniform("rect_position", 0, 0)
	mesh:Draw()

	shader:SetUniform("rect_position", 2 * x / w - 1, 1 - 2 * y / h)
	mesh2:Draw()
end)

-- Tell the tube what to do every step
tube:On("Step", function()
	if (window:ShouldClose()) then
		tube:Stop()
	else
		window:PollEvents()
		tube:Fire("Update", dt)
		tube:Fire("Draw")
		window:SwapBuffers()

		Time.Sleep(rate)

		t = Time:Get()
		dt = t - ot
		ot = t
	end
end)

tube:Loop()