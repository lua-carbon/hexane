

local ffi = require("ffi")
local Hexane = (...)
local Carbon = Hexane.Carbon

local Time = Carbon.Time
local Nanotube = Carbon.Nanotube
local Vector2 = Carbon.Math.Vector2
local Vector3 = Carbon.Math.Vector3
local Vector4 = Carbon.Math.Vector4
local Quaternion = Carbon.Math.Quaternion
local Matrix4x4 = Carbon.Math.Matrix4x4

local info = Hexane.Graphics.ContextInfo:New()
info.Title = "Hexane: Sample #1"
info.Width = 1280
info.Height = 720
info.DepthBits = 24

local window, exception = Hexane.Graphics.Window:New(info)

if (window == nil) then
	exception:Throw()
end

print(window:GetContextVersionString())

window:EnableFeature("depth")
window:EnableFeature("face_culling")

window:SetDepthFunction("less")
window:SetBlendMode("src_alpha", "one_minus_src_alpha")

Hexane.Input.MouseContext:New(window)
Hexane.Input.KeyboardContext:New(window)

local clearer = Hexane.Graphics.Clearer:New()
clearer:SetColor(100/255, 149/255, 237/255)

local w, h = window:GetFramebufferSize()

local vertices = {
	-0.5, -0.5, -0.5, 0.8, 0.4, 0.2, 0.0, 0.0,
	-0.5,  0.5, -0.5, 0.8, 0.4, 0.2, 0.0, 1.0,
	 0.5,  0.5, -0.5, 0.8, 0.4, 0.2, 1.0, 1.0,
	 0.5,  0.5, -0.5, 0.8, 0.4, 0.2, 1.0, 1.0,
	 0.5, -0.5, -0.5, 0.8, 0.4, 0.2, 1.0, 0.0,
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
	 0.5, -0.5,  0.5, 0.8, 0.4, 0.2, 0.0, 0.0,
	 0.5, -0.5, -0.5, 0.8, 0.4, 0.2, 0.0, 1.0,
	 0.5, -0.5, -0.5, 0.8, 0.4, 0.2, 0.0, 1.0,
	 0.5,  0.5, -0.5, 0.8, 0.4, 0.2, 1.0, 1.0,
	 0.5,  0.5,  0.5, 0.8, 0.4, 0.2, 1.0, 0.0,

	-0.5, -0.5, -0.5, 0.8, 0.4, 0.2, 0.0, 1.0,
	 0.5, -0.5, -0.5, 0.8, 0.4, 0.2, 1.0, 1.0,
	 0.5, -0.5,  0.5, 0.8, 0.4, 0.2, 1.0, 0.0,
	 0.5, -0.5,  0.5, 0.8, 0.4, 0.2, 1.0, 0.0,
	-0.5, -0.5,  0.5, 0.8, 0.4, 0.2, 0.0, 0.0,
	-0.5, -0.5, -0.5, 0.8, 0.4, 0.2, 0.0, 1.0,

	-0.5,  0.5, -0.5, 0.8, 0.4, 0.2, 0.0, 1.0,
	-0.5,  0.5,  0.5, 0.8, 0.4, 0.2, 0.0, 0.0,
	 0.5,  0.5,  0.5, 0.8, 0.4, 0.2, 1.0, 0.0,
	 0.5,  0.5,  0.5, 0.8, 0.4, 0.2, 1.0, 0.0,
	 0.5,  0.5, -0.5, 0.8, 0.4, 0.2, 1.0, 1.0,
	-0.5,  0.5, -0.5, 0.8, 0.4, 0.2, 0.0, 1.0
}

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

local VertexAttribute = Hexane.Graphics.VertexAttribute
local position_attribute = VertexAttribute:New(0, 3, "float", 8, 0)
local color_attribute = VertexAttribute:New(1, 3, "float", 8, 3)
local texcoord_attrib = VertexAttribute:New(2, 2, "float", 8, 6)

local shader = Hexane.Graphics.ShaderProgram:New()
shader:AttachSource("vertex", vertex_source)
shader:AttachSource("fragment", fragment_source)

shader:AddAttribute(0, "position")
shader:AddAttribute(1, "color")
shader:AddAttribute(2, "texcoord")

shader:Link()
shader:Use()

shader:BindFragDataLocation(0, "outColor")

shader:AddUniform("transform_model", "Matrix4fv")
shader:AddUniform("transform_view", "Matrix4fv")
shader:AddUniform("transform_projection", "Matrix4fv")

shader:AddUniform("tex", "1i")
shader:SetUniform("tex", 0)

local attributes = {
	position_attribute,
	color_attribute,
	texcoord_attrib
}

local mesh = Hexane.Graphics.Mesh:New(vertices, nil, attributes)

local stbi = Hexane.Bindings.STB.Image
local out = ffi.new("int[3]")
local image = stbi.stbi_load("assets/hexane-icon.png", out, out + 1, out + 2, stbi.STBI_rgb_alpha)
local format = (out[2] == 3) and "rgb" or "rgba"

local texture_data = Hexane.Graphics.TextureData:New("uint8_t", "rgba", out[0], out[1])
texture_data:SetData(image, out[0] * out[1] * out[2])

stbi.stbi_image_free(image)

local texture = Hexane.Graphics.Texture:New()
texture:SetData(texture_data)
texture:Bind(0)

window.Mouse:SetMode("disabled")

window:On("KeyDown", function(key, scancode, mods)
	if (key == "escape") then
		window:Stop()
	end
end)

local camera = Hexane.Graphics.Camera:New()
camera:SetPosition(0, 0, 3)

local mouse = Vector2(0, 0)
local old_mouse = Vector2(0, 0)
window:On("MouseMove", function(x, y)
	old_mouse:Init(mouse:GetComponents())
	mouse:Init(x, y)

	local dmouse = mouse:SubtractVector(old_mouse)
	camera.Orientation:MultiplyLooseInPlace(Quaternion:NewLooseFromLooseAngles(-dmouse[1]/100, 0, -dmouse[2]/100))
end)

window:On("Update", function(dt)
	local vec = Vector4()
	local speed = 0.05

	if (window.Keyboard:IsKeyDown("w")) then
		vec:AddLooseVectorInPlace(0, 0, 1)
	elseif (window.Keyboard:IsKeyDown("s")) then
		vec:AddLooseVectorInPlace(0, 0, -1)
	end

	if (window.Keyboard:IsKeyDown("a")) then
		vec:AddLooseVectorInPlace(1, 0, 0)
	elseif (window.Keyboard:IsKeyDown("d")) then
		vec:AddLooseVectorInPlace(-1, 0, 0)
	end

	vec:NormalizeInPlace():ScaleInPlace(speed)
	vec = camera.Orientation:TransformVector(vec)
	camera:AddPosition(vec[1], vec[2], vec[3])
end)

window:On("Draw", function(dt)
	clearer:Draw()

	local omodel = Matrix4x4:NewIdentity()
	local model = omodel

	camera:Update()

	local projection = Matrix4x4:NewPerspective(math.rad(70), 16/9, 0.01, 10)
	
	local function draw()
		shader:SetMatrixUniform("transform_view", camera.View:GetNative())
		shader:SetMatrixUniform("transform_projection", projection:GetNative())
		shader:SetMatrixUniform("transform_model", model:GetNative())
		mesh:Draw()
	end

	model = omodel:Translate(1, 0, 0)
	draw()

	model = omodel:Translate(0, 1, 0)
	draw()

	model = omodel:Translate(-1, 0, 0)
	draw()

	model = omodel:Translate(0, -1, 0)
	draw()
end)

window:Loop()