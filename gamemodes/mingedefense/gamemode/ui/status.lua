print(" !!!  status.lua loaded")
--
--locals
local ply = LocalPlayer() --we set this here in case we are reloading the script, the player will be valid

----colors
	local associated_colors = MingeDefenseColors.Status
	local color_armor = associated_colors.Armor
	local color_background = associated_colors.Background
	local color_health = associated_colors.Health
	local color_health_background = associated_colors.HealthBackground

----localized functions
	local fl_math_floor = math.floor
	local fl_surface_DrawRect = surface.DrawRect
	local fl_surface_DrawText = surface.DrawText
	local fl_surface_GetTextSize = surface.GetTextSize
	local fl_surface_SetDrawColor = surface.SetDrawColor
	local fl_surface_SetFont = surface.SetFont
	local fl_surface_SetTextColor = surface.SetTextColor
	local fl_surface_SetTextPos = surface.SetTextPos
	local fl_surface = nil

----calculated variables
	local margin = 8
	local money_h
	local money_w
	local money_y
	local status_bar_h
	local status_bar_w
	local status_bar_x
	local status_bar_y
	local status_h
	local status_margin = 8
	local status_w
	local status_y

--local functions
local function even_floor(value) return fl_math_floor(value * 0.5) * 2 end

local function calc_vars(scr_w, scr_h)
	local status_margin_double = status_margin * 2
	local status_scale = even_floor(scr_w * 0.15)
	
	status_h = even_floor(status_scale * 0.15)
	status_w = status_scale
	status_y = scr_h - status_h - margin
	
	status_bar_h = status_h - status_margin_double
	status_bar_w = status_w - status_margin_double
	status_bar_x = margin + status_margin
	status_bar_y = status_y + status_margin
	
	money_h = status_h
end

--gamemode functions
function GM:HUDDrawStatus()
	--later, just make this hook start from InitPostEntity
	if IsValid(ply) then
		local max_health = ply:GetMaxHealth()
		local health = ply:Health()
		local text
		
		if ply:Alive() then text = tostring(health)
		else text = "DEAD" end
		
		fl_surface_SetDrawColor(color_background)
		fl_surface_DrawRect(margin, status_y, status_w, status_h)
		
		fl_surface_SetDrawColor(color_health_background)
		fl_surface_DrawRect(status_bar_x, status_bar_y, status_bar_w, status_bar_h)
		
		fl_surface_SetDrawColor(color_health)
		fl_surface_DrawRect(status_bar_x, status_bar_y, status_bar_w * health / max_health, status_bar_h)
		
		fl_surface_SetFont("MingeDefenseUIStatus")
		fl_surface_SetTextColor(color_white)
		
		local width, height = fl_surface_GetTextSize(text)
		
		fl_surface_SetTextPos(status_bar_x + (status_bar_w - width) * 0.5, status_bar_y)
		
		fl_surface_DrawText(text)
	end
end

--hooks
hook.Add("minge_defense_status", "OnScreenSizeChanged", function() calc_vars(ScrW(), ScrH()) end)
hook.Add("minge_defense_status", "InitPostEntity", function()
	ply = LocalPlayer()
	
	print("status ply", ply)
	
	hook.Remove("minge_defense_status", "InitPostEntity")
end)

--post
calc_vars(ScrW(), ScrH())