GM.MingeSENTS = GM.MingeSENTS or {}
GM.MingeIcons = GM.MingeIcons or {}
GM.PlayersReady = {}
GM.ReadyTimer = false

local ready = false
local render_size = 512

function GM:RoundGenerateIcon(class, ENT, sobel, sobel_passes)
	local camera_data = ENT.IconCamera
	local existing_material = self.MingeIcons[class]
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

function GM:RoundScanSENTS()
	for class, data in pairs(scripted_ents.GetList()) do
		local ENT = scripted_ents.Get(class)
		local overrides = data.t
		
		if ENT.DrawIconModels then
			--debugging! only do the first one right now
			local material = hook.Call("RoundGenerateIcon", self, class, ENT, 0.99, 2)
			
			print("material generated!", material, material:GetName())
			
			ENT.IconOverride = material:GetName() --materials/entities/<ClassName>.png
			ENT.IconMaterial = material
			self.MingeIcons[class] = material
			self.MingeSENTS[class] = ENT
		elseif ENT.IsMinge then self.MingeSENTS[class] = ENT end
	end
end

function GM:RoundTestIcons()
	local frame = vgui.Create("DFrame")
	
	frame:SetSize(1038, 1062)
	frame:SetTitle("Icon test with " .. table.Count(self.MingeIcons) .. " icons")
	
	local layout = vgui.Create("DIconLayout", frame)
	
	layout:Dock(FILL)
	layout:SetSpaceX(4, 4)
	layout:SetSpaceY(4, 4)
	
	for class, icon in pairs(self.MingeIcons) do
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

--net
net.Receive("minge_defense_ready", function()
	--TODO: don't use net.ReadTable
	--TODO: the timer code, lol. it should be its own panel parented to the team header, maybe give it a stencil scroll in animation
	local gm = GAMEMODE
	local local_ply = LocalPlayer()
	
	if net.ReadBool() then
		for ply, ply_ready in pairs(gm.PlayersReady) do
			if not ply_ready then
				GAMEMODE.PlayersReady[ply] = true
				
				hook.Call("HUDTeamPanelUpdatePlayer", GAMEMODE, ply, true)
			end
		end
		
		hook.Call("HUDTeamPanelUpdateHeader", gm, true, ready_allowed, ready)
	else
		local ready_allowed = net.ReadBool()
		local ready_timer = net.ReadBool()
		local sync_players = net.ReadBool()
		
		if ready_timer then gm.TeamPanel.LabelTimer:SetActivity(true, net.ReadFloat())
		else gm.TeamPanel.LabelTimer:SetActivity(false) end
		
		if ready_allowed and sync_players then
			local plys = net.ReadTable()
			local plys_old = table.Copy(gm.PlayersReady)
			gm.PlayersReady = plys
			
			for ply, ply_ready in pairs(plys) do if plys_old[ply] ~= ply_ready then hook.Call("HUDTeamPanelUpdatePlayer", gm, ply, ply_ready) end end
			
			ready = plys[LocalPlayer()] or false
		end
		
		hook.Call("HUDTeamPanelUpdateHeader", gm, false, ready_allowed, ready)
	end
end)