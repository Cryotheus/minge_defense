print(" !!! !!! status.lua loaded")

--locals
local material_shield = Material("minge_defense/hud/stripes.png", "noclamp")
local material_shield_scale = 32 * 2 --it is 32x32 but we need a higher res one... I'm thinking 128x128
local pi = math.pi

----colors
	local associated_colors = MingeDefenseColors.HUD.Status
	local color_armor = associated_colors.Armor
	local color_background = associated_colors.Background
	local color_health = associated_colors.Health
	local color_health_background = associated_colors.HealthBackground

----localized functions
	local fl_draw_SimpleText = draw.SimpleText
	local fl_math_floor = math.floor
	local fl_math_sin = math.sin
	local fl_surface_DrawRect = surface.DrawRect
	local fl_surface_DrawText = surface.DrawText
	local fl_surface_DrawTexturedRectUV = surface.DrawTexturedRectUV
	local fl_surface_GetTextSize = surface.GetTextSize
	local fl_surface_SetDrawColor = surface.SetDrawColor
	local fl_surface_SetFont = surface.SetFont
	local fl_surface_SetMaterial = surface.SetMaterial
	local fl_surface_SetTextColor = surface.SetTextColor
	local fl_surface_SetTextPos = surface.SetTextPos
	local fl_surface = nil

----calculated variables
	local error_px_half = 0.5 / 32 -- half pixel anticorrection for surface.DrawTexturedRectUV
	local error_px_div = 1 - error_px_half * 2
	local margin = 8
	local money_h
	local money_w
	local money_y
	local status_armor_bar_h
	local status_armor_bar_w
	local status_armor_bar_x
	local status_armor_bar_y
	local status_bar_h
	local status_bar_w
	local status_bar_x
	local status_bar_y
	local status_h
	local status_armor_margin = 4
	local status_margin = 8
	local status_w
	local status_y

--local functions
local function even_floor(value) return fl_math_floor(value * 0.5) * 2 end

local function draw_uv_texture(x, y, width, height, start_u, start_v, end_u, end_v)
	fl_surface_DrawTexturedRectUV(
		x,
		y,
		width,
		height,
		
		(start_u - error_px_half) / error_px_div,
		(start_v - error_px_half) / error_px_div,
		(end_u - error_px_half) / error_px_div,
		(end_v - error_px_half) / error_px_div
	)
end

--gamemode functions
--TODO: cache text displayed so we dont keep translating health and armor to text
function GM:HUDDrawStatus(ply)
	--later, just make this hook start from InitPostEntity
	local armor = ply:Armor()
	local max_health = ply:GetMaxHealth()
	local health = ply:Health()
	local text
	
	if ply:Alive() then text = tostring(health)
	else
		armor = 0
		text = "DEAD"
	end
	
	fl_surface_SetDrawColor(color_background)
	fl_surface_DrawRect(margin, status_y, status_w, status_h)
	
	fl_surface_SetDrawColor(color_health_background)
	fl_surface_DrawRect(status_bar_x, status_bar_y, status_bar_w, status_bar_h)
	
	fl_surface_SetDrawColor(color_health)
	fl_surface_DrawRect(status_bar_x, status_bar_y, status_bar_w * health / max_health, status_bar_h)
	
	if armor > 0 then
		local max_armor = ply:GetMaxArmor()
		local real_time = RealTime()
		local scaled_width = status_armor_bar_w * armor / max_armor
		local scale_u, scale_v = scaled_width / material_shield_scale, status_armor_bar_h / material_shield_scale
		local scroll = real_time * 0.5 % status_armor_bar_w
		
		local pulse = fl_math_sin(real_time * 4)
		local pulse_rg = pulse * 20 + 215
		
		fl_surface_SetDrawColor(pulse_rg, pulse_rg, 255, pulse * 68 + 104)
		fl_surface_SetMaterial(material_shield)
		draw_uv_texture(status_armor_bar_x, status_armor_bar_y, scaled_width, status_armor_bar_h, scroll, 0, scale_u + scroll, scale_v)
		
		pulse = fl_math_sin(real_time * 4 + pi)
		pulse_rg = pulse * 20 + 215
		scroll = scroll + 0.25
		
		fl_surface_SetDrawColor(pulse_rg, pulse_rg, 255, pulse * 68 + 104)
		draw_uv_texture(status_armor_bar_x, status_armor_bar_y, scaled_width, status_armor_bar_h, scroll, 0, scale_u + scroll, scale_v)
		
		fl_draw_SimpleText(text, "MingeDefenseUIStatusLarge", status_bar_x + status_bar_w * 0.5, status_armor_bar_y, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
		fl_draw_SimpleText(tostring(armor), "MingeDefenseUIStatusSmall", status_bar_x + status_bar_w * 0.5, status_armor_bar_y + status_armor_bar_h, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
	else fl_draw_SimpleText(text, "MingeDefenseUIStatusLarge", status_bar_x + status_bar_w * 0.5, status_bar_y + status_bar_h * 0.5, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER) end
end

function GM:HUDStatusCalculateVariables(width, height)
	local status_margin_double = status_margin * 2
	local status_armor_margin_double = status_armor_margin * 2
	local status_scale = even_floor(width * 0.15)
	
	status_h = even_floor(status_scale * 0.15)
	status_w = status_scale
	status_y = height - status_h - margin
	
	status_bar_h = status_h - status_margin_double
	status_bar_w = status_w - status_margin_double
	status_bar_x = margin + status_margin
	status_bar_y = status_y + status_margin
	
	status_armor_bar_h = status_h - status_armor_margin_double
	status_armor_bar_w = status_w - status_armor_margin_double
	status_armor_bar_x = margin + status_armor_margin
	status_armor_bar_y = status_y + status_armor_margin
	
	money_h = status_h
end