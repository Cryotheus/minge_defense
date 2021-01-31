MingeDefenseMingeSENTS = MingeDefenseMingeSENTS or {}

local render_size = 1024
local render_name = "minge_defense_icon_generator"
local render_target = GetRenderTargetEx(render_name, render_size, render_size, RT_SIZE_OFFSCREEN, MATERIAL_RT_DEPTH_SEPARATE, 256, 0, IMAGE_FORMAT_BGRA8888)
local test_mat = CreateMaterial(render_name, "UnlitGeneric", {
	["$basetexture"] = "models/weapons/v_toolgun/screen_bg",
	["$translucent"] = 1, --we could also try $alphatest as it makes the model transparent not translucent
	["$vertexcolor"] = 1
})

--test_mat:SetTexture("$basetexture", render_target)

function GM:WaveGenerateIcon(ENT, debug_draw)
	local camera_data = ENT.IconCamera
	local lighting = camera_data.AutoLighting
	local lighting_enabled = lighting and true or false
	
	--render.ClearRenderTarget(render_target, Color(0, 0, 0, 0))
	
	render.PushRenderTarget(render_target)
		--the depth buffer NEEDS to be cleared, but the stencil buffer probably doesn't matter
		render.Clear(0, 0, 0, 0, true, true)
		
		cam.Start3D(camera_data.Position, camera_data.Angles or (camera_data.TargetPosition - camera_data.Position):Angle(), camera_data.FOV, 0, 0, ScrW(), ScrH(), camera_data.Near, camera_data.Far)
			--automtically light up the entity with good settings
			if lighting_enabled then
				local lighting_side = lighting.Sides or {}
				
				render.SuppressEngineLighting(true)
				render.SetLightingOrigin(lighting.Position)
				
				if lighting.Default then render.ResetModelLighting(unpack(lighting.Default))
				else render.ResetModelLighting(1, 1, 1) end
				
				for index = 0, 5 do
					local sides = lighting_side[index + 1]
					
					if sides then render.SetModelLighting(index, unpack(sides))
					else render.SetModelLighting(index, 1, 1, 1) end
				end
			end
			
			ENT:DrawIconModels()
			
			render.SuppressEngineLighting(false)
		cam.End3D()
		
		cam.Start2D()
			--DrawSobel(0.5)
			
			surface.SetDrawColor(255, 0, 0)
			surface.DrawRect(math.random(0, 200), math.random(0, 200), 50, 50)
		cam.End2D()
	render.PopRenderTarget()
	
	test_mat:SetTexture("$basetexture", render_target)
	
	if debug_draw then --debug
		local debug_name = "minge_defense_" .. SysTime() .. "_" .. math.random(-math.huge, math.huge) 
		
		print("Debug name is: " .. debug_name)
		
		hook.Add("HUDPaint", debug_name, function()
			surface.SetDrawColor(255, 1, 1, 64)
			surface.DrawRect(0, 0, render_size, render_size)
			
			surface.SetDrawColor(255, 255, 255)
			surface.SetMaterial(test_mat)
			surface.DrawTexturedRect(0, 0, render_size, render_size)
		end)
		
		timer.Create(debug_name, 3, 1, function() hook.Remove("HUDPaint", debug_name) end)
	end
end

function GM:WaveScanSENTS()
	local first = true
	
	for class, data in pairs(scripted_ents.GetList()) do
		local ENT = data.t
		
		if ENT.IconCamera then
			print("We found an entity with an IconCamera!", class)
			--PrintTable(ENT, 1)
			
			MingeDefenseMingeSENTS[class] = ENT.IconCamera
			
			--debugging! only do the first one right now
			if first then
				first = false
				
				hook.Call("WaveGenerateIcon", GM, ENT, false)
			end
		elseif ENT.IsMinge then MingeDefenseMingeSENTS[class] = true end
	end
end

hook.Call("WaveScanSENTS", GM)