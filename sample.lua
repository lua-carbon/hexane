-- Sample: Make a Window!
local Hexane = require("Hexane")
local Time = Hexane.Carbon.Time
local Nanotube = Hexane.Carbon.Nanotube
Hexane.Graphics:Import("Window", "WindowInfo")
Hexane.Bindings.OpenGL:Import("GL", "gl")

local info = WindowInfo:New()
info.Title = "Hexane: Sample #1"
info.Width = 1280
info.Height = 720

local window, exception = Window:New(info)

if (window == nil) then
	exception:Throw()
end

window:MakeCurrent()

print(window:GetContextVersionString())

local tube = Nanotube.Global
tube.StepPeriod = 1 / 120

local ot = Time:Get()
local t = Time:Get()
local dt = t - ot

tube:On("Draw", function(dt)
	local x = 0.25 + 0.25 * math.cos(t)

	gl.ClearColor(x, x, x, 1.0)
	gl.Clear(GL.COLOR_BUFFER_BIT)
end)

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