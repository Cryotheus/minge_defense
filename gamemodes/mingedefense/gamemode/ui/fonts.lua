--localized functions
local fl_surface_CreateFont = surface.CreateFont

--local functions
local function font(name, struct) fl_surface_CreateFont("MingeDefense" .. name, struct) end

--post
font("UIStatusLarge", {
	font = "Franklin Gothic Heavy",
	size = 26
})

font("UIStatusSmall", {
	font = "Franklin Gothic Heavy",
	size = 18
})

font("UITeamHeader", {
	font = "Franklin Gothic Heavy",
	size = 18
})