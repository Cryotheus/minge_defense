local font = "TargetID"
local font_small = "TargetIDSmall"
local spacing = 4

----colors
	local associated_colors = MingeDefenseColors.HUD.TargetID
	local color_shadow_shallow = associated_colors.ShadowShallow
	local color_shadow_deep = associated_colors.ShadowDeep
	local color_text = associated_colors.Text

local function draw_aa_shadow_text(text, font, x, y)
	-- The fonts internal drop shadow looks lousy with AA on
	--it really does, so they make their own
	--although, I will make one for my self later on
	--draw.SimpleText(text, font, x, y, color_white, TEXT_ALIGN_CENTER)
	draw.SimpleText(text, font, x + 1, y + 1, color_shadow_deep, TEXT_ALIGN_CENTER)
	draw.SimpleText(text, font, x + 2, y + 2, color_shadow_shallow, TEXT_ALIGN_CENTER)
	draw.SimpleText(text, font, x, y, color_text, TEXT_ALIGN_CENTER)
end

function GM:HUDDrawTargetID()
	local ply = LocalPlayer()
	
	--doesn't matter if the player isn't even initialized yet, does it?
	if not IsValid(ply) then return end
	
	--eye trace
	local trace = util.TraceLine(util.GetPlayerTrace(ply))
	
	--if we didn't hit anything or we hit the world, we aint showing anything
	if not trace.Hit or not trace.HitNonWorld then return end
	
	local text = "ERROR"
	local trace_target = trace.Entity
	
	if trace_target:IsPlayer() then text = trace_target:Nick()
	else return end
	
	surface.SetFont(font)
	
	local w, h = surface.GetTextSize(text)
	local mouse_x, mouse_y = gui.MousePos()
	
	--if are mouse isn't active, then make it the same as if our mouse was centered
	--this makes it so the text is centered as well
	if mouse_x == 0 and mouse_y == 0 then
		mouse_x = ScrW() / 2
		mouse_y = ScrH() / 2
	end
	
	mouse_y = mouse_y + 20
	
	do --fancy stencil overlay
		render.SetStencilEnable(true)
		render.ClearStencil()
		
		render.SetStencilCompareFunction(STENCIL_NEVER)
		render.SetStencilPassOperation(STENCIL_KEEP)
		render.SetStencilFailOperation(STENCIL_REPLACE)
		render.SetStencilZFailOperation(STENCIL_KEEP)
		render.SetStencilWriteMask(0xFF)
		render.SetStencilTestMask(0xFF)
		render.SetStencilReferenceValue(1)
		
		--set the values in the stencil
		if IsValid(trace_target) then
			local weapon = trace_target:GetActiveWeapon()
			
			cam.Start3D()
				trace_target:DrawModel()
				
				if IsValid(weapon) then weapon:DrawModel() end
			cam.End3D()
		end
		
		render.SetStencilCompareFunction(STENCIL_EQUAL)
		
		surface.SetDrawColor(0, 192, 0, math.sin(RealTime() * math.pi) * 16 + 48)
		surface.DrawRect(0, 0, ScrW(), ScrH())
		
		render.SetStencilEnable(false)
	end
	
	draw_aa_shadow_text(text, font, mouse_x, mouse_y)
	
	mouse_y = mouse_y + h + spacing
	
	local armor = trace_target:Armor()
	local text = trace_target:Health() .. " / " .. trace_target:GetMaxHealth()
	
	if armor > 0 then text = text .. " + (" .. armor .. " / " .. trace_target:GetMaxArmor() .. ")" end
	
	surface.SetFont(font_small)
	
	w, h = surface.GetTextSize(text)
	
	draw_aa_shadow_text(text, font, mouse_x, mouse_y)
	
	text = "100 Metal"
	w, h = surface.GetTextSize(text)
	mouse_y = mouse_y + h + spacing
	
	draw_aa_shadow_text(text, font, mouse_x, mouse_y)
end