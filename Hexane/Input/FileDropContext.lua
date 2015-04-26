--[[
	Hexane for LuaJIT
	FileDropContext
]]

local Hexane = (...)
local Carbon = Hexane.Carbon
local OOP = Carbon.OOP
local InputContext = Hexane.Input.InputContext

local ffi = require("ffi")

local FileDropContext = OOP:Class()
	:Inherits(InputContext)
	:Members {
		Name = "FileDrop"
	}

function FileDropContext:Init(window)
	local status, exception = InputContext.Init(self, window)
	if (exception) then
		return false, exception
	end

	local callback_drop = ffi.cast("GLFWdropfun", function(context, count, paths)
		local files = {}

		for i = 0, count do
			table.insert(files, ffi.string(paths[i]))
		end

		window:QueueEvent("FileDrop", files)
	end)

	GLFW.SetDropCallback(window.__context, callback_drop)
end

return FileDropContext