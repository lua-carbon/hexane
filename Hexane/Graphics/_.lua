--[[
	Hexane for LuaJIT
	Graphics Core
]]

local Hexane = (...)
local GLFW = Hexane.Bindings.GLFW
local OpenGL = Hexane.Bindings.OpenGL

OpenGL:ImportAll()

local Graphics = {
	__initialized = false
}

function Graphics:IsInitialized()
	return self.__initialized
end

function Graphics:Initialize()
	if (self.__initialized) then
		return false
	end

	GLFW.Init()
	OpenGL:SetLoader(GLFW.GetProcAddress)

	self.__initialized = true

	return true
end

function Graphics:Destroy()
	if (not self.__initialized) then
		return false
	end

	GLFW.Terminate()
	self.__initialized = false

	return true
end

return Graphics