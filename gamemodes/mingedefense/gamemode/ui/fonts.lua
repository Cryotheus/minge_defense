--localized functions
local fl_surface_CreateFont = surface.CreateFont

--local functions
local function font(name, struct) fl_surface_CreateFont("MingeDefense" .. name, struct) end

--post
font("UIStatus", {
	font = "Franklin Gothic Heavy",
	size = 28
})