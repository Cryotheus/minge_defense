STATUS_PANEL.BaseName = "DPanel"
STATUS_PANEL.Name = "Health"

--locals
local material_shield = Material("minge_defense/hud/stripes.png", "noclamp")
local material_shield_scale = 32 * 2 --it is 32x32 but we need a higher res one... I'm thinking 128x128
local pi = math.pi
local ply

local dimensions = STATUS_PANEL.Supplies.Dimensions
local margin = dimensions.Margin
local margin_double = dimensions.MarginDouble

----colors
	local associated_colors = GM.UIColors.HUD.Status
	local color_armor = associated_colors.Armor
	local color_background = associated_colors.Background
	local color_health = associated_colors.Health
	local color_health_background = associated_colors.HealthBackground

----localized functions
	local fl_draw_SimpleText = draw.SimpleText
	local fl_math_sin = math.sin
	local fl_Supplies_DrawUVTexture = STATUS_PANEL.Supplies.DrawUVTexture
	local fl_Supplies_EvenFloor = STATUS_PANEL.Supplies.EvenFloor
	local fl_surface_DrawRect = surface.DrawRect
	local fl_surface_DrawText = surface.DrawText
	local fl_surface_DrawTexturedRectUV = surface.DrawTexturedRectUV
	local fl_surface_GetTextSize = surface.GetTextSize
	local fl_surface_SetDrawColor = surface.SetDrawColor
	local fl_surface_SetFont = surface.SetFont
	local fl_surface_SetMaterial = surface.SetMaterial
	local fl_surface_SetTextColor = surface.SetTextColor
	local fl_surface_SetTextPos = surface.SetTextPos

--panel functions
function STATUS_PANEL:CalculateVariables(width, height, old_width, old_height, local_ply) ply = local_ply end

function STATUS_PANEL:Init()
	self:SetTooltip("Health")
	self:SetZPos(10)
end

function STATUS_PANEL:Paint(width, height)
	local armor = ply:Armor()
	local max_health = ply:GetMaxHealth()
	local health = ply:Health()
	local text
	
	local inner_height = height - margin_double
	local inner_width = width - margin_double
	
	if ply:Alive() then text = tostring(health)
	else
		armor = 0
		text = "DEAD"
	end
	
	fl_surface_SetDrawColor(color_background)
	fl_surface_DrawRect(0, 0, width, height)
	
	if armor > 0 then
		local max_armor = ply:GetMaxArmor()
		local real_time = RealTime()
		local scaled_width = width * armor / max_armor
		local scale_u, scale_v = scaled_width / material_shield_scale, height / material_shield_scale
		local scroll = real_time * 0.5 % width
		
		local pulse = fl_math_sin(real_time * 4)
		local pulse_rg = pulse * 20 + 215
		
		fl_surface_SetDrawColor(color_health_background)
		fl_surface_DrawRect(0, 0, width, height)
		
		fl_surface_SetDrawColor(color_health)
		fl_surface_DrawRect(margin, margin, inner_width * health / max_health, inner_height)
		
		fl_surface_SetDrawColor(pulse_rg, pulse_rg, 255, pulse * 68 + 104)
		fl_surface_SetMaterial(material_shield)
		fl_Supplies_DrawUVTexture(0, 0, scaled_width, height, scroll, 0, scale_u + scroll, scale_v)
		
		pulse = fl_math_sin(real_time * 4 + pi)
		pulse_rg = pulse * 20 + 215
		scroll = scroll + 0.25
		
		fl_surface_SetDrawColor(pulse_rg, pulse_rg, 255, pulse * 68 + 104)
		fl_Supplies_DrawUVTexture(0, 0, scaled_width, height, scroll, 0, scale_u + scroll, scale_v)
		
		fl_draw_SimpleText(text, "MingeDefenseUIStatusLarge", width * 0.5, 0, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
		fl_draw_SimpleText(tostring(armor), "MingeDefenseUIStatusSmall", width * 0.5, height, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
	else
		fl_surface_SetDrawColor(color_health_background)
		fl_surface_DrawRect(0, 0, width, height)
		
		fl_surface_SetDrawColor(color_health)
		fl_surface_DrawRect(0, 0, width * health / max_health, height)
		
		fl_draw_SimpleText(text, "MingeDefenseUIStatusLarge", width * 0.5, height * 0.5, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
end