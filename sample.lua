-- Sample: Make a Window, draw a cube rotated with the mouse.

local ffi = require("ffi")
local Hexane = require("Hexane")
local Carbon = Hexane.Carbon

local Time = Carbon.Time
local Nanotube = Carbon.Nanotube
local Vector3 = Carbon.Math.Vector3
local Matrix4x4 = Carbon.Math.Matrix4x4

-- Create an object with information about the window we'll be making.
local info = Hexane.Graphics.WindowInfo:New()
info.Title = "Hexane: Sample #1"
info.Width = 1280
info.Height = 720
info.DepthBits = 24

-- Creating a new window automatically sets it as the current window
local window, exception = Hexane.Graphics.Window:New(info)

if (window == nil) then
	exception:Throw()
end

print(window:GetContextVersionString())

window:EnableDepthTest()

window:SetDepthFunction("less")
window:SetBlendMode("src_alpha", "one_minus_src_alpha")

-- Create a 'Clearer' which manages clearing the buffer between frames
local clearer = Hexane.Graphics.Clearer:New()
clearer:SetColor(100/255, 149/255, 237/255)

local w, h = window:GetSize()
local ratio = h / w

-- Create a mesh given a list of vertices
local vertices = {
	-0.5, -0.5, -0.5, 0.8, 0.4, 0.2, 0.0, 0.0,
	 0.5, -0.5, -0.5, 0.8, 0.4, 0.2, 1.0, 0.0,
	 0.5,  0.5, -0.5, 0.8, 0.4, 0.2, 1.0, 1.0,
	 0.5,  0.5, -0.5, 0.8, 0.4, 0.2, 1.0, 1.0,
	-0.5,  0.5, -0.5, 0.8, 0.4, 0.2, 0.0, 1.0,
	-0.5, -0.5, -0.5, 0.8, 0.4, 0.2, 0.0, 0.0,

	-0.5, -0.5,  0.5, 0.8, 0.4, 0.2, 0.0, 0.0,
	 0.5, -0.5,  0.5, 0.8, 0.4, 0.2, 1.0, 0.0,
	 0.5,  0.5,  0.5, 0.8, 0.4, 0.2, 1.0, 1.0,
	 0.5,  0.5,  0.5, 0.8, 0.4, 0.2, 1.0, 1.0,
	-0.5,  0.5,  0.5, 0.8, 0.4, 0.2, 0.0, 1.0,
	-0.5, -0.5,  0.5, 0.8, 0.4, 0.2, 0.0, 0.0,

	-0.5,  0.5,  0.5, 0.8, 0.4, 0.2, 1.0, 0.0,
	-0.5,  0.5, -0.5, 0.8, 0.4, 0.2, 1.0, 1.0,
	-0.5, -0.5, -0.5, 0.8, 0.4, 0.2, 0.0, 1.0,
	-0.5, -0.5, -0.5, 0.8, 0.4, 0.2, 0.0, 1.0,
	-0.5, -0.5,  0.5, 0.8, 0.4, 0.2, 0.0, 0.0,
	-0.5,  0.5,  0.5, 0.8, 0.4, 0.2, 1.0, 0.0,

	 0.5,  0.5,  0.5, 0.8, 0.4, 0.2, 1.0, 0.0,
	 0.5,  0.5, -0.5, 0.8, 0.4, 0.2, 1.0, 1.0,
	 0.5, -0.5, -0.5, 0.8, 0.4, 0.2, 0.0, 1.0,
	 0.5, -0.5, -0.5, 0.8, 0.4, 0.2, 0.0, 1.0,
	 0.5, -0.5,  0.5, 0.8, 0.4, 0.2, 0.0, 0.0,
	 0.5,  0.5,  0.5, 0.8, 0.4, 0.2, 1.0, 0.0,

	-0.5, -0.5, -0.5, 0.8, 0.4, 0.2, 0.0, 1.0,
	 0.5, -0.5, -0.5, 0.8, 0.4, 0.2, 1.0, 1.0,
	 0.5, -0.5,  0.5, 0.8, 0.4, 0.2, 1.0, 0.0,
	 0.5, -0.5,  0.5, 0.8, 0.4, 0.2, 1.0, 0.0,
	-0.5, -0.5,  0.5, 0.8, 0.4, 0.2, 0.0, 0.0,
	-0.5, -0.5, -0.5, 0.8, 0.4, 0.2, 0.0, 1.0,

	-0.5,  0.5, -0.5, 0.8, 0.4, 0.2, 0.0, 1.0,
	 0.5,  0.5, -0.5, 0.8, 0.4, 0.2, 1.0, 1.0,
	 0.5,  0.5,  0.5, 0.8, 0.4, 0.2, 1.0, 0.0,
	 0.5,  0.5,  0.5, 0.8, 0.4, 0.2, 1.0, 0.0,
	-0.5,  0.5,  0.5, 0.8, 0.4, 0.2, 0.0, 0.0,
	-0.5,  0.5, -0.5, 0.8, 0.4, 0.2, 0.0, 1.0
}

-- Shader sources!
local vertex_source = [[
#version 150

uniform mat4 transform_model;
uniform mat4 transform_view;
uniform mat4 transform_projection;

in vec3 position;
in vec3 color;
in vec2 texcoord;

out vec3 Color;
out vec2 Texcoord;

void main() {
	Color = color;
	Texcoord = texcoord;
	gl_Position = transform_projection * transform_view * transform_model * vec4(position, 1.0);
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

-- Add uniforms for matrix MVP transforms
shader:AddUniform("transform_model", "Matrix4fv")
shader:AddUniform("transform_view", "Matrix4fv")
shader:AddUniform("transform_projection", "Matrix4fv")

-- Add a texture uniform
shader:AddUniform("tex", "1i")
shader:SetUniform("tex", 0)

-- Create some attributes to define our mesh data
local position_attribute = Hexane.Graphics.VertexAttribute:New(0, 3, "float", 8, 0)
local color_attribute = Hexane.Graphics.VertexAttribute:New(1, 3, "float", 8, 3)
local texcoord_attrib = Hexane.Graphics.VertexAttribute:New(2, 2, "float", 8, 6)

-- Group these attributes!
local attributes = {
	position_attribute,
	color_attribute,
	texcoord_attrib
}

-- Create cube mesh with the given vertices, elements, and attributes
local mesh = Hexane.Graphics.Mesh:New(vertices, nil, attributes)

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

	local x_theta = math.pi * (2 * x / w - 1)
	local y_theta = math.pi * (2 * y / h - 1)

	local model = Matrix4x4:NewIdentity():Rotate(x_theta, y_theta, 0)
	local view = Matrix4x4:NewIdentity()
	--Perspective seems to screw everything up!
	--local projection = Matrix4x4:NewPerspective(math.rad(40), w / h, -1, 1)
	local projection = Matrix4x4:NewOrthographic(-w / h, w / h, -1, 1, -1, 1)

	local nope = 0
	shader:SetUniform("transform_view", 1, nope, view:GetNative())
	shader:SetUniform("transform_projection", 1, nope, projection:GetNative())
	shader:SetUniform("transform_model", 1, nope, model:GetNative())
	mesh:Draw()
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