STATUS_PANEL.BaseName = "DPanel"
STATUS_PANEL.Name = "Metal"

--locals
local max_metal = 200
local ply

local dimensions = STATUS_PANEL.Supplies.Dimensions
local margin = dimensions.Margin
local margin_double = dimensions.MarginDouble

----colors
	local associated_colors = GM.UIColors.HUD.Status
	local color_metal = associated_colors.Metal
	local color_metal_background = associated_colors.MetalBackground

----localized functions
	local fl_draw_SimpleText = draw.SimpleText
	local fl_Supplies_EvenFloor = STATUS_PANEL.Supplies.EvenFloor
	local fl_surface_DrawRect = surface.DrawRect
	local fl_surface_DrawText = surface.DrawText
	local fl_surface_SetDrawColor = surface.SetDrawColor
	local fl_surface_SetFont = surface.SetFont
	local fl_surface_SetMaterial = surface.SetMaterial

--panel functions
function STATUS_PANEL:CalculateVariables(width, height, old_width, old_height, local_ply) ply = local_ply end
function STATUS_PANEL:Init()
	self:SetTooltip("Metal")
	self:SetVisible(false)
end

function STATUS_PANEL:Paint(width, height)
	local inner_height = height - margin_double
	local inner_width = width - margin_double
	local metal = math.min(ply:Frags() * 10, max_metal)
	
	fl_surface_SetDrawColor(color_metal_background)
	fl_surface_DrawRect(0, 0, width, height)
	
	fl_surface_SetDrawColor(color_metal)
	fl_surface_DrawRect(0, 0, width * metal / max_metal, height)
	
	fl_draw_SimpleText(tostring(metal), "MingeDefenseUIStatusLarge", width * 0.5, height * 0.5, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end