--[[
	Hexane for LuaJIT
	Texture
]]

local Hexane = (...)
local Carbon = Hexane.Carbon
local OOP = Carbon.OOP

local ffi = require("ffi")

Hexane.Bindings.OpenGL:ImportAll()

local repeats = {
	["repeat"] = GL.REPEAT,
	["mirrored_repeat"] = GL.MIRRORED_REPEAT,
	["clamp_to_edge"] = GL.CLAMP_TO_EDGE,
	["clamp_to_border"] = GL.CLAMP_TO_BORDER
}

local filters = {
	["linear"] = GL.LINEAR,
	["nearest"] = GL.NEAREST,
	["nearest_mipmap_nearest"] = GL.NEAREST_MIPMAP_NEAREST,
	["nearest_mipmap_linear"] = GL.NEAREST_MIPMAP_LINEAR,
	["linear_mipmap_linear"] = GL.LINEAR_MIPMAP_LINEAR,
	["linear_mipmap_nearest"] = GL.LINEAR_MIPMAP_NEAREST
}

local formats = {
	["rgb"] = GL.RGB,
	["rgba"] = GL.RGBA,
	["srgb"] = GL.SRGB
	-- todo: these
}

local types = {
	["float"] = GL.FLOAT,
	["uint8_t"] = GL.UNSIGNED_BYTE,
	["int8_t"] = GL.BYTE
}

local Texture = OOP:Class()
	:Attributes {
	}
	:Members {
		__batching = false
	}

function Texture:Init()
	local tex = ffi.new("GLuint[1]")
	gl.GenTextures(1, tex)
	self.__tex = tex

	self:BatchStart()
	self:SetFilter()
	self:SetRepeat()
	self:BatchEnd()
end

function Texture:BatchStart()
	self:Bind()
	self.__batching = true
end

function Texture:BatchEnd()
	self.__batching = false
end

function Texture:Destroy()
	gl.DeleteTextures(1, self.__tex)
end

function Texture:Bind(n)
	if (n) then
		gl.ActiveTexture(GL.TEXTURE0 + n)
	end

	if (not self.__batching) then
		gl.BindTexture(GL.TEXTURE_2D, self.__tex[0])
	end
end

function Texture:SetFilter(min, max)
	min = min or "linear"
	max = max or min

	self:Bind()
	gl.TexParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, filters[min])
	gl.TexParameteri(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, filters[max])
end

function Texture:SetRepeat(s, t)
	s = s or "clamp_to_edge"
	t = t or s

	self:Bind()
	gl.TexParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_S, repeats[s])
	gl.TexParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_T, repeats[t])
end

function Texture:SetData(data)
	self:Bind()
	gl.TexImage2D(GL.TEXTURE_2D, 0, formats[data.__format], data.Width, data.Height, 0, formats[data.__format], types[data.__type], data.__data)
end

return Texture