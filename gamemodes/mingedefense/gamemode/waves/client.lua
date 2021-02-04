MingeDefenseMingeSENTS = MingeDefenseMingeSENTS or {}
MingeDefenseMingeIcons = MingeDefenseMingeIcons or {}

local render_size = 512

function GM:WaveGenerateIcon(class, ENT, sobel, sobel_passes)
	local camera_data = ENT.IconCamera
	local existing_material = MingeDefenseMingeIcons[class]
	local lighting = camera_data.AutoLighting
	local render_target = GetRenderTargetEx("mdiconrt_" .. class, render_size, render_size, RT_SIZE_OFFSCREEN, MATERIAL_RT_DEPTH_SEPARATE, 256, 0, IMAGE_FORMAT_BGRA8888)
	
	render.PushRenderTarget(render_target)
		--the depth buffer NEEDS to be cleared, but the stencil buffer probably doesn't matter
		render.Clear(0, 0, 0, 0, true, true)
		
		cam.Start3D(camera_data.Position, camera_data.Angles or (camera_data.TargetPosition - camera_data.Position):Angle(), camera_data.FOV, 0, 0, ScrW(), ScrH(), camera_data.Near, camera_data.Far)
			--automtically light up the entity with good settings
			if lighting then
				local lighting_side = lighting.Sides or {}
				
				render.SuppressEngineLighting(true)
				render.SetLightingOrigin(lighting.Position or vector_origin)
				
				if lighting.Default then render.ResetModelLighting(unpack(lighting.Default))
				else render.ResetModelLighting(1, 1, 1) end
			end
			
			ENT:DrawIconModels()
			
			if ENT.DrawIconWeaponModels then ENT:DrawIconWeaponModels() end
			if sobel and sobel >= 0 then for pass = 1, sobel_passes or 1 do DrawSobel(sobel) end end
			
			render.SuppressEngineLighting(false)
		cam.End3D()
	render.PopRenderTarget()
	
	if existing_material then
		existing_material:SetTexture("$basetexture", render_target)
		
		return existing_material
	else
		return CreateMaterial("mdicon_" .. class, "UnlitGeneric", {
			["$basetexture"] = render_target:GetName(),
			["$translucent"] = 1, --we could also try $alphatest as it makes the model transparent not translucent
			["$vertexcolor"] = 1
		})
	end
end

function GM:WaveScanSENTS()
	for class, data in pairs(scripted_ents.GetList()) do
		local ENT = scripted_ents.GetStored(class)
		local overrides = data.t
		
		if ENT.DrawIconModels then
			--debugging! only do the first one right now
			local material = hook.Call("WaveGenerateIcon", self, class, ENT, 0.99, 2)
			
			print("material generated!", material, material:GetName())
			
			ENT.IconOverride = material:GetName() --materials/entities/<ClassName>.png
			ENT.IconMaterial = material
			MingeDefenseMingeIcons[class] = material
			MingeDefenseMingeSENTS[class] = ENT
		elseif ENT.IsMinge then MingeDefenseMingeSENTS[class] = true end
	end
end

function GM:WaveTestIcons()
	local frame = vgui.Create("DFrame")
	
	frame:SetSize(1038, 1062)
	frame:SetTitle("Icon test with " .. table.Count(MingeDefenseMingeIcons) .. " icons")
	
	local layout = vgui.Create("DIconLayout", frame)
	
	layout:Dock(FILL)
	layout:SetSpaceX(4, 4)
	layout:SetSpaceY(4, 4)
	
	for class, icon in pairs(MingeDefenseMingeIcons) do
		local test = layout:Add("DPanel")
		
		function test:Paint(width, height)
			surface.SetDrawColor(255, 255, 255)
			surface.SetMaterial(icon)
			surface.DrawTexturedRect(0, 0, width, height)
			
			surface.SetDrawColor(0, 0, 0, 64)
			surface.DrawRect(0, 0, width, height)
		end
		
		test:SetSize(512, 512)
	end
	
	frame:Center()
	frame:MakePopup()
end

--concommands
concommand.Add("gm_showspare2", function(command, ply, arguments, arguments_string)
	local state = tobool(arguments[1])
	
	net.Start("minge_defense_wave_ready")
	net.WriteBool()
	net.SendToServer()
end, nil, "Mark yourself as ready for the next wave.")

--net
net.Receive("minge_defense_wave_ready", function()
	local plys = net.ReadTable()
	
	--do stuff like update the hud... maybe make a file in the ui folder
end)