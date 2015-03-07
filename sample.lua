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

-- Create a 'Clearer' which manages clearing the buffer between frames
local clearer = Hexane.Graphics.Clearer:New()

-- Create a mesh given a list of vertices (VBO) and elements (EBO)
local vertices = {
	-0.5, 0.5, 1, 0, 0,
	0.5, 0.5, 0, 1, 0,
	0.5, -0.5, 0, 0, 1,
	-0.5, -0.5, 1, 1, 1
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

out vec3 Color;

void main() {
	Color = color;
	gl_Position = vec4(rect_position + position, 0.0, 1.0);
}
]]

local fragment_source = [[
#version 150

in vec3 Color;

out vec4 outColor;

void main() {
	outColor = vec4(Color, 1.0);
}
]]

-- Create a shader using our sources above
local shader = Hexane.Graphics.Shader:New()
shader:Attach("vertex", vertex_source)
shader:Attach("fragment", fragment_source)

-- Assign these attributes positions
shader:AddAttribute(0, "position")
shader:AddAttribute(1, "color")

-- Link and use the shader!
shader:Link()
shader:Use()

-- Bind our pixel data out location
shader:BindFragDataLocation(0, "outColor")

-- Add a rect_position uniform for positioning our rectangles
shader:AddUniform("rect_position", "2f")
shader:SetUniform("rect_position", 0, 0)

-- Create some attributes to define our mesh data
local position_attribute = Hexane.Graphics.VertexAttribute:New(0, 2, "float", 5, 0)
local color_attribute = Hexane.Graphics.VertexAttribute:New(1, 3, "float", 5, 2)

-- Group these attributes!
local attributes = {
	position_attribute,
	color_attribute
}

-- Create meshes with the given vertices, elements, and attributes
local mesh = Hexane.Graphics.Mesh:New(vertices, elements, attributes)
local mesh2 = Hexane.Graphics.Mesh:New(vertices, elements, attributes)

-- Begin loop preparations
local tube = Nanotube.Global
tube.StepPeriod = 1 / 120 -- Fastest framerate: 120 FPS

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
		t = Time:Get()
		dt = t - ot

		window:PollEvents()
		tube:Fire("Update", dt)
		tube:Fire("Draw")
		window:SwapBuffers()

		ot = t
	end
end)

tube:Loop()