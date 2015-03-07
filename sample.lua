-- Sample: Make a Window, draw a triangle mesh

local ffi = require("ffi")
local Hexane = require("Hexane")
local Time = Hexane.Carbon.Time
local Nanotube = Hexane.Carbon.Nanotube

-- Create an object with information about the window we'll be making.
local info = Hexane.Graphics.WindowInfo:New()
info.Title = "Hexane: Sample #1"
info.Width = 1280
info.Height = 720
info.Resizable = true

local window, exception = Hexane.Graphics.Window:New(info)

if (window == nil) then
	exception:Throw()
end

print(window:GetContextVersionString())

-- Create a 'Clearer' which manages clearing the buffer between frames
local clearer = Hexane.Graphics.Clearer:New()

-- Create a mesh given a list of vertices (VBO) and elements (EBO)
local l_vertices = {
	-0.5, 0.5, 1, 0, 0,
	0.5, 0.5, 0, 1, 0,
	0.5, -0.5, 0, 0, 1,
	-0.5, -0.5, 1, 1, 1
}

local l_elements = {
	0, 1, 2,
	2, 3, 0
}

local mesh = Hexane.Graphics.Mesh:New(l_vertices, l_elements)

-- Shader sources!
local vertex_source = [[
#version 150

in vec2 position;
in vec3 color;

out vec3 Color;

void main() {
	Color = color;
	gl_Position = vec4(position, 0.0, 1.0);
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
shader:Link()
shader:Use()

-- Bind the output location and register some attributes, just like pure OpenGL
shader:BindFragDataLocation(0, "outColor")
shader:AddAttribute("position", 2, "float", 5, 0)
shader:AddAttribute("color", 3, "float", 5, 2)

-- Begin loop preparations
local tube = Nanotube.Global
tube.StepPeriod = 1 / 120 -- Fastest framerate: 120 FPS

local ot = Time:Get()
local t = Time:Get()
local dt = t - ot

-- Tell the tube what to do on draw
tube:On("Draw", function(dt)
	clearer:Draw()
	mesh:Draw()
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