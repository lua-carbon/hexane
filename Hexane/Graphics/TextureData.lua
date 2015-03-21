--[[
	Hexane for LuaJIT
	TextureData
]]

local Hexane = (...)
local Carbon = Hexane.Carbon
local OOP = Carbon.OOP
local C = Hexane.Bindings.C

local ffi = require("ffi")

local format_sizes = {
	["rgb"] = 3,
	["rgba"] = 4,
	["srgb"] = 3
}

local TextureData = OOP:Class()
	:Attributes {
		InstanceIndirection = true
	}

-- TODO: use malloc/free instead
function TextureData:Init(typeof, format, w, h)
	local size = w * h
	self.__type = typeof
	self.__data = ffi.cast(typeof .. "*", C.malloc(size * format_sizes[format] * ffi.sizeof(typeof)))
	self.__format = format
	self.Size = size
	self.Width = w
	self.Height = h
end

function TextureData:Destroy()
	if (self.__data ~= nil) then
		--C.free(self.__data)
	end
end

function TextureData:Resize(w, h)
	self.Width = w
	self.Height = h

	local size = w * h
	self.Size = size

	if (self.__data == nil) then
		self.__data = ffi.cast(self.__type .. "*", C.malloc(size * format_sizes[self.__format] * ffi.sizeof(typeof)))
	else
		self.__data = ffi.cast(self.__type .. "*", C.realloc(self.__data, size * format_sizes[self.__format] * ffi.sizeof(typeof)))
	end
end

function TextureData:SetFormat(format)
	self.__format = format
end

function TextureData:GetFormat()
	return self.__format
end

function TextureData:SetData(data, len)
	if (type(data) == "table") then
		for i = 1, len or #data do
			self.__data[i - 1] = data[i]
		end
	else
		if (len) then
			ffi.copy(self.__data, data, len)
		else
			ffi.copy(self.__data, data)
		end
	end
end

return TextureData