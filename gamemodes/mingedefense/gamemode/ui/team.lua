local header_text = "HEADER HAS INITIALIZED AND TEXT HAS YET TO BE SET"
local wave_active

local triangle = {
	{x = 0, y = 0},
	{x = 0, y = 0},
	{x = 0, y = 0}
}

----render parameters
	local label_timer_h
	local label_timer_rl
	local label_timer_t
	local marquee_label_b
	local panel_h
	local panel_oversized
	local panel_players_b
	local panel_players_t
	local panel_w
	local panel_x
	local panel_y

----colors
	local associated_colors = GM.UIColors.HUD.Team
	local associated_status_colors = GM.UIColors.HUD.Status
	local color_background = associated_colors.Background
	local color_background_player = associated_colors.BackgroundPlayer
	local color_background_players = associated_colors.BackgroundPlayers
	local color_background_ready_player = associated_colors.BackgroundReadyPlayer
	local color_health = associated_status_colors.Health
	local color_health_background = associated_status_colors.HealthBackground

----localized functions
	local fl_surface_DrawRect = surface.DrawRect
	local fl_surface_SetDrawColor = surface.SetDrawColor

--local functions
--this way we don't define a function per player panel, but instead two for all of them
local function paint_health(self, width, height)
	local ply = self.Player
	
	if IsValid(ply) then
		if ply:Alive() then
			local health_height = math.ceil(height * ply:Health() / ply:GetMaxHealth()) * 2
			
			fl_surface_SetDrawColor(color_health_background)
			fl_surface_DrawRect(0, 0, width, height)
			
			--fl_surface_SetDrawColor(color_health)
			--fl_surface_DrawRect(0, height - health_height, width, health_height)
			
			fl_surface_SetDrawColor(color_health)
			
			---[[ single status bar support
			triangle[1].y = height - health_height
			
			triangle[2].x = health_height
			triangle[2].y = height --]]
			
			--[[ double status bar support
			triangle[1].y = height - health_height
			
			triangle[2].x = health_height
			triangle[2].y = height - health_height --]]
			
			triangle[3].y = height
			
			draw.NoTexture()
			surface.DrawPoly(triangle)
		else
			fl_surface_SetDrawColor(0, 0, 0)
			fl_surface_DrawRect(0, 0, width, height)
		end
	else
		fl_surface_SetDrawColor(255, 0, 255)
		fl_surface_DrawRect(0, 0, width, height)
	end
end

local function paint_ready(self, width, height)
	fl_surface_SetDrawColor(color_background_ready_player)
	fl_surface_DrawRect(0, 0, width, height)
end

local function paint_unready(self, width, height)
	fl_surface_SetDrawColor(color_background_player)
	fl_surface_DrawRect(0, 0, width, height)
end

--gamemode functions
function GM:HUDCreateTeamPanel()
	hook.Call("HUDRemoveTeamPanel", self)
	
	local panel = vgui.Create("DPanel", GetHUDPanel(), "MingeDefenseTeam")
	
	panel:SetPos(panel_x, panel_y)
	panel:SetSize(panel_w, panel_h)
	
	do --marquee text
		local header_text = hook.Call("HUDTeamPanelGetHeaderText", self)
		local marquee_label = vgui.Create("MDMarqueeLabel", panel)
		
		marquee_label:Dock(FILL)
		marquee_label:DockMargin(0, 0, 0, marquee_label_b)
		marquee_label:SetFont("MingeDefenseUITeamHeader")
		marquee_label:SetMouseInputEnabled(true)
		marquee_label:SetText(header_text)
		marquee_label:SetTextSeperator("#mingedefense.ui.team.header.seperator")
		marquee_label:SetTooltip(header_text)
		
		panel.MarqueeLabel = marquee_label
	end
	
	do --player panel TODO: optimize the scrolling effect
		local panel_players = vgui.Create("DHorizontalScroller", panel)
		local panel_players_scroll = 0
		
		panel_players.Players = {}
		
		panel_players:Dock(FILL)
		panel_players:DockMargin(0, panel_players_t, 0, label_timer_h)
		panel_players:SetMouseInputEnabled(true)
		
		panel_players.btnLeft:SetVisible(false)
		panel_players.btnRight:SetVisible(false)
		
		--speed stuff up
		function panel_players:PerformLayout(width, height) end
		
		--create the avatar for each player
		for index, ply in ipairs(player.GetAll()) do
			if not IsValid(ply) then continue end
			
			local button_player = vgui.Create("DButton", panel_players)
			local steam_id = ply:SteamID64()
			
			panel_players:AddPanel(button_player)
			button_player:Dock(LEFT)
			button_player:DockMargin(4, 4, 0, 4)
			button_player:SetText("")
			button_player:SetTooltip(ply:Name())
			
			button_player.Paint = self.PlayersReady[ply] and paint_ready or paint_unready
			
			if steam_id then function button_player:DoClick() gui.OpenURL("https://steamcommunity.com/profiles/" .. steam_id) end
			else button_player:SetCursor("arrow") end
			
			function button_player:PerformLayout(width, height)
				local size = math.min(width, height)
				
				self:SetSize(size, size)
			end
			
			do --avatar
				local avatar = vgui.Create("AvatarImage", button_player)
				
				avatar:Dock(FILL)
				avatar:DockMargin(2, 2, 2, 2)
				avatar:SetMouseInputEnabled(false)
				avatar:SetPlayer(ply, 64)
				
				function avatar:PerformLayout(width, height)
					local size = math.min(width, height)
					
					self:SetSize(size, size)
				end
				
				button_player.Avatar = avatar
			end
			
			button_player.Player = ply
			panel_players.Players[ply] = button_player
		end
		
		--we should just make a skin
		function panel_players:Paint(width, height)
			fl_surface_SetDrawColor(color_background_players)
			fl_surface_DrawRect(0, 0, width, height)
		end
		
		--we don't need all this extra crap like clamped scrolling
		--need to optimize the canvas_width algorithm
		--could literally be a math expression but too lazy to calculate the values right now
		function panel_players:PerformLayout(width, height)
			local canvas_width = 4
			
			for ply, button_player in pairs(self.Players) do canvas_width = canvas_width + button_player:GetWide() + 4 end
			
			panel_players_scroll = canvas_width - width
			
			self.pnlCanvas:SetSize(canvas_width, height)
			self.pnlCanvas.x = -self.OffsetX
		end
		
		--if there are so many players we can't possibly fit them all on the team header
		if panel_oversized then
			function panel_players:Think()
				local scroll = RealTime() * 10
				
				self:SetScroll(math.abs(scroll % panel_players_scroll - panel_players_scroll * 0.5) * 2)
			end
		end
		
		panel.PanelPlayers = panel_players
	end
	
	do --timer label
		local label = vgui.Create("DLabel", panel)
		local speed = 3
		
		label.Active = false
		label.Percent = 0
		
		label:Dock(FILL)
		label:DockMargin(label_timer_rl, label_timer_t, label_timer_rl, label_timer_h * label.Percent)
		label:SetContentAlignment(5)
		label:SetFont("MingeDefenseUITeamTimer")
		label:SetText("32")
		label:SetTextColor(color_white)
		label:SetVisible(false)
		
		function label:SetActivity(active, time)
			self.Time = time or self.Time
			
			if self.Active ~= active then
				self.Active = active
				
				if active then self:SetVisible(true)
				else self:SetVisible(self.Percent ~= 0) end
			end
		end
		
		function label:Paint(width, height)
			fl_surface_SetDrawColor(color_background)
			fl_surface_DrawRect(0, 0, width, height)
		end
		
		function label:Think()
			local old_percent = self.Percent
			local percent = math.Clamp(old_percent + RealFrameTime() * (self.Active and speed or -speed), 0, 1)
			
			if percent ~= old_percent then
				self.Percent = percent
				
				if percent == 0 then
					self:SetHeight(label_timer_h)
					self:SetVisible(false)
				else self:SetHeight(label_timer_h * percent) end
			end
			
			self:SetText(tostring(math.max(math.floor(self.Time - CurTime()), 0)))
		end
		
		label:SetActivity(false, CurTime() + 6)
		
		panel.LabelTimer = label
	end
	
	function panel:Paint(width, height)
		fl_surface_SetDrawColor(color_background)
		fl_surface_DrawRect(0, 0, width, label_timer_t)
	end
	
	self.TeamPanel = panel
	
	return panel
end

function GM:HUDOnRemoveTeamPanel(...) return true end --only gets called if the panel was valid

function GM:HUDRemoveTeamPanel()
	local existing_panels = {} 
	
	for index, panel in ipairs(GetHUDPanel():GetChildren()) do
		if panel:GetName() == "MingeDefenseTeam" then
			table.insert(existing_panels, panel)
		end
	end
	
	hook.Call("HUDOnRemoveTeamPanel", self, unpack(existing_panels))
	
	if table.IsEmpty(existing_panels) then return false end
	for index, panel in ipairs(existing_panels) do panel:Remove() end
	
	self.TeamPanel = false
	
	return true
end

function GM:HUDTeamPanelGetHeaderText() return header_text end --this lets the header text get easily overridden

function GM:HUDTeamPanelSetHeaderText(id, text)
	--using the id, modders can block certain messages from appearing
	--right now, there's only round
	header_text = text
	local marquee_label = self.TeamPanel.MarqueeLabel
	
	marquee_label:SetText(header_text)
	marquee_label:SetTooltip(header_text)
end

function GM:HUDTeamPanelUpdatePlayer(ply, ready)
	if self.TeamPanel then
		local panel_player = self.TeamPanel.PanelPlayers.Players[ply]
		
		panel_player.Paint =wave_active and paint_health or ready and paint_ready or paint_unready
	end
end

function GM:HUDTeamPanelUpdateStatus(new_wave_state)
	wave_active = new_wave_state
	--[[print("HUDTeamPanelUpdateStatus called, reporting wave activity", wave_active)
	
	if wave_active then for ply, button_player in pairs(self.TeamPanel.PanelPlayers.Players) do button_player.Paint = paint_health end
	else
		local players_ready = self.PlayersReady
		
		for ply, button_player in pairs(self.TeamPanel.PanelPlayers.Players) do button_player.Paint = players_ready[ply] and paint_ready or paint_unready end
	end]]
end

function GM:HUDTeamPanelCalculateVariables(width, height)
	local count = math.max(player.GetCount(), 6)
	local panel_max_w = width * 0.8
	
	panel_h = width * 0.05
	panel_w = count * math.floor(panel_h * 0.75 - 4) + 6
	
	if panel_w > panel_max_w then
		panel_oversized = true
		panel_w = panel_max_w
	else panel_oversized = false end
	
	panel_x = (width - panel_w) * 0.5
	panel_y = 0
	
	--docking margins
	marquee_label_b = panel_h * 0.75
	panel_players_b = panel_h * 0.2
	panel_players_t = panel_h * 0.25
	label_timer_h = panel_h * 0.2
	label_timer_rl = (panel_w - (panel_h - panel_players_b - panel_players_t)) * 0.5
	label_timer_t = panel_h * 0.8
	
	hook.Call("HUDCreateTeamPanel", self, LocalPlayer())
end