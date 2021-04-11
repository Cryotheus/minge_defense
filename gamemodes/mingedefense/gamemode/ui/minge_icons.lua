GM.MingeSENTS = GAMEMODE.MingeSENTS or {}
GM.MingeIcons = GAMEMODE.MingeIcons or {}

--local variables
local destructing_keys = {
	DrawIconModels = true,
	DrawIconWeaponModels = true,
	IconCamera = true,
	ReleaseIconModels = true,
	SetupIconModels = true
}

local render_size = 128

--local function
local function draw_models(ENT, lighting)
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
	if lighting then render.SuppressEngineLighting(false) end
end

--gamemode functions
function GM:MingeIconsGenerate(class, ENT, outline, outline_step, outline_minimum)
	local camera_data = ENT.IconCamera
	local existing_material = self.MingeIcons[class]
	local lighting = camera_data.AutoLighting
	local outline_minimum = outline_minimum or outline and -outline
	local outline_step = outline_step or 1
	local render_target = GetRenderTargetEx("mdicons/" .. class, render_size, render_size, RT_SIZE_OFFSCREEN, MATERIAL_RT_DEPTH_SEPARATE, 256, 0, IMAGE_FORMAT_BGRA8888)
	local render_target_background = GetRenderTargetEx("mdicon_backgrounds/" .. class, render_size, render_size, RT_SIZE_OFFSCREEN, MATERIAL_RT_DEPTH_SEPARATE, 256, 0, IMAGE_FORMAT_BGRA8888)
	local render_target_background_material = CreateMaterial("mdicon_background_materials/" .. class, "UnlitGeneric", {
		["$basetexture"] = render_target_background:GetName(),
		["$translucent"] = 1, --we could also try $alphatest as it makes the model transparent not translucent
		["$vertexcolor"] = 1
	})
	
	local camera_parameters = {
		camera_data.Position,
		camera_data.Angles or (camera_data.TargetPosition - camera_data.Position):Angle(),
		camera_data.FOV,
		0,
		0,
		render_size,
		render_size,
		camera_data.Near,
		camera_data.Far
	}
	
	--create the models and prepare for DrawIconModels to be called several times
	ENT:SetupIconModels()
	
	--create a silhouette of the models
	render.PushRenderTarget(render_target_background)
		--the depth buffer NEEDS to be cleared, but the stencil buffer probably doesn't matter
		render.Clear(0, 0, 0, 0, true, true)
		
		cam.Start3D(unpack(camera_parameters))
			render.OverrideColorWriteEnable(true, false)
			
			draw_models(ENT, false)
			
			render.OverrideColorWriteEnable(false)
		cam.End3D()
	render.PopRenderTarget()
	
	--create the texture itself
	render.PushRenderTarget(render_target)
		render.Clear(0, 0, 0, 0, true, true)
		
		if outline then
			--draw an outline using the silhouette
			cam.Start2D()
				surface.SetDrawColor(255, 255, 255, 255)
				surface.SetMaterial(render_target_background_material)
				
				for x = outline_minimum, outline, outline_step do
					for y = outline_minimum, outline, outline_step do
						if x == 0 and y == 0 then continue end
						
						surface.DrawTexturedRect(x, y, 512, 512)
					end
				end
			cam.End2D()
		end
			
		--draw the model itself
		cam.Start3D(unpack(camera_parameters))
			--more?
			draw_models(ENT, lighting)
		cam.End3D()
	render.PopRenderTarget()
	
	--delete models created by SetupIconModels
	ENT:ReleaseIconModels()
	
	if existing_material then existing_material:SetTexture("$basetexture", render_target)
	else
		existing_material = CreateMaterial("mdicon_" .. class, "UnlitGeneric", {
			["$basetexture"] = render_target:GetName(),
			["$translucent"] = 1, --we could also try $alphatest as it makes the model transparent not translucent
			["$vertexcolor"] = 1
		})
	end
	
	return existing_material
end

function GM:MingeIconsScanSENTS()
	for class, data in pairs(scripted_ents.GetList()) do
		local ENT = scripted_ents.Get(class)
		--local overrides = data.t
		
		if ENT.GenerateIcon then
			--debugging! only do the first one right now
			local material = hook.Call("MingeIconsGenerate", self, class, ENT, 2)
			local stored = scripted_ents.GetStored(class)
			
			ENT.IconOverride = material:GetName()
			ENT.IconMaterial = material
			self.MingeIcons[class] = material
			self.MingeSENTS[class] = ENT
			
			--probably not good for reload...
			--for key, value in pairs(stored) do if destructing_keys[key] then stored[key] = nil end end
		elseif ENT.IsMinge then self.MingeSENTS[class] = ENT end
	end
end

function GM:MingeIconsTestIcons()
	local count = 0
	local frame = vgui.Create("DFrame")
	
	frame:SetSize(1038, 1062)
	
	----icon layout
		local layout = vgui.Create("DIconLayout", frame)
		
		layout:Dock(FILL)
		layout:SetSpaceX(4, 4)
		layout:SetSpaceY(4, 4)
	
	for class, icon in pairs(self.MingeIcons) do
		count = count + 1
		local panel = layout:Add("DPanel")
		
		panel:SetSize(512, 512)
		
		function test:Paint(width, height)
			surface.SetDrawColor(255, 255, 255)
			surface.SetMaterial(icon)
			surface.DrawTexturedRect(0, 0, width, height)
			
			surface.SetDrawColor(0, 0, 0, 64)
			surface.DrawRect(0, 0, width, height)
		end
		
		do
			local label = vgui.Create("DLabel", panel)
			
			label:Dock(FILL)
			label:SetContentAlignment(2)
			label:SetText(class)
		end
	end
	
	frame:Center()
	frame:MakePopup()
	frame:SetTitle("Icon test with " .. count .. " icons")
end