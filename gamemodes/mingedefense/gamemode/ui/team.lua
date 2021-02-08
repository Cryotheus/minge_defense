local panel_b
local panel_h
local panel_lr
local panel_w

----colors
	local associated_colors = MingeDefenseColors.HUD.Team
	local color_background = associated_colors.Background
	local color_background_player = associated_colors.BackgroundPlayer
	local color_background_players = associated_colors.BackgroundPlayers
	local color_background_ready_player = associated_colors.BackgroundReadyPlayer

--gamemode functions
function GM:HUDCreateTeamPanel()
	hook.Call("HUDRemoveTeamPanel", self)
	
	local panel = vgui.Create("DPanel", GetHUDPanel(), "MingeDefenseTeam")
	
	panel:Dock(FILL)
	panel:DockMargin(panel_lr, 0, panel_lr, panel_b)
	
	print("creating new panel", panel)
	
	do
		local panel_players = vgui.Create("DPanel", panel)
		
		panel_players:Dock(FILL)
		panel_players:DockMargin(0, panel_h * 0.25, 0, 0)
		
		for index, ply in ipairs(player.GetAll()) do
			local panel_player = vgui.Create("DPanel", panel_players)
			
			panel_player:Dock(LEFT)
			panel_player:DockMargin(4, 4, 0, 4)
			
			function panel_player:Paint(width, height)
				surface.SetDrawColor(ply:IsBot() and color_background_player or color_background_ready_player)
				surface.DrawRect(0, 0, width, height)
			end
			
			function panel_player:PerformLayout(width, height)
				local size = math.min(width, height)
				
				self:SetSize(size, size)
			end
			
			do --avatar
				local avatar = vgui.Create("AvatarImage", panel_player)
				
				avatar:Dock(FILL)
				avatar:DockMargin(2, 2, 2, 2)
				avatar:SetPlayer(ply, 64)
				
				function avatar:PerformLayout(width, height)
					local size = math.min(width, height)
					
					self:SetSize(size, size)
				end
				
				panel_player.Avatar = avatar
			end
			
			
			panel[ply] = panel_player
		end
		
		function panel_players:Paint(width, height)
			surface.SetDrawColor(color_background_players)
			surface.DrawRect(0, 0, width, height)
		end
		
		panel.Players = panel_players
	end
	
	function panel:Paint(width, height)
		surface.SetDrawColor(color_background)
		surface.DrawRect(0, 0, width, height)
	end
	
	return panel
end

--only gets called if the panel was valid
function GM:HUDOnRemoveTeamPanel(...) return true end

function GM:HUDRemoveTeamPanel()
	local existing_panels = {} 
	
	for index, panel in ipairs(GetHUDPanel():GetChildren()) do
		if panel:GetName() == "MingeDefenseTeam" then
			table.insert(existing_panels, panel)
		end
	end
	
	hook.Call("HUDOnRemoveTeamPanel", self, unpack(existing_panels))
	print("removing existing_panels")
	PrintTable(existing_panels, 1)
	
	if table.IsEmpty(existing_panels) then return false end
	for index, panel in ipairs(existing_panels) do panel:Remove() end
	
	return true
end

function GM:HUDTeamPanelCalculateVariables(width, height)
	local count = math.max(player.GetCount(), 6)
	
	panel_h = width * 0.04
	panel_w = math.min(count * (panel_h * 0.75 - 4) + 4, width * 0.8)
	
	panel_b = height - panel_h
	panel_lr = (width - panel_w) * 0.5
	
	hook.Call("HUDCreateTeamPanel", self, LocalPlayer())
end