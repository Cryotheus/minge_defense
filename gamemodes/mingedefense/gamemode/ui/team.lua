local local_ready_allowed = false
local local_wave_active = false

----render parameters
	local label_timer_h
	local label_timer_rl
	local label_timer_t
	local marquee_label_b
	local panel_b
	local panel_h
	local panel_lr
	local panel_oversized
	local panel_players_b
	local panel_players_t
	local panel_w

----colors
	local associated_colors = MingeDefenseColors.HUD.Team
	local color_background = associated_colors.Background
	local color_background_player = associated_colors.BackgroundPlayer
	local color_background_players = associated_colors.BackgroundPlayers
	local color_background_ready_player = associated_colors.BackgroundReadyPlayer

--local functions
--so we don't define a function per player panel, but instead two for all of them
local function paint_ready(self, width, height)
	surface.SetDrawColor(color_background_ready_player)
	surface.DrawRect(0, 0, width, height)
end

local function paint_unready(self, width, height)
	surface.SetDrawColor(color_background_player)
	surface.DrawRect(0, 0, width, height)
end

--gamemode functions
function GM:HUDCreateTeamPanel()
	hook.Call("HUDRemoveTeamPanel", self)
	
	local panel = vgui.Create("DPanel", GetHUDPanel(), "MingeDefenseTeam")
	
	panel:Dock(FILL)
	panel:DockMargin(panel_lr, 0, panel_lr, panel_b)
	
	do --marquee text
		local marquee_label = vgui.Create("MDMarqueeLabel", panel)
		
		marquee_label:Dock(FILL)
		marquee_label:DockMargin(0, 0, 0, marquee_label_b)
		marquee_label:SetFont("MingeDefenseUITeamHeader")
		marquee_label:SetText(hook.Call("HUDTeamPanelGetHeaderText", self, local_wave_active, local_ready_allowed, self.PlayersReady[LocalPlayer()]))
		
		panel.MarqueeLabel = marquee_label
	end
	
	do --player panel TODO: optimize the scrolling effect
		local panel_players = vgui.Create("DHorizontalScroller", panel)
		local panel_players_scroll = 0
		
		panel_players.Players = {}
		
		panel_players:Dock(FILL)
		panel_players:DockMargin(0, panel_players_t, 0, label_timer_h)
		
		panel_players.btnLeft:SetVisible(false)
		panel_players.btnRight:SetVisible(false)
		
		--speed stuff up
		function panel_players:PerformLayout(width, height) end
		
		--create the avatar for each player
		for index, ply in ipairs(player.GetAll()) do
			if not IsValid(ply) then continue end
			
			local panel_player = vgui.Create("DPanel", panel_players)
			
			panel_players:AddPanel(panel_player)
			panel_player:Dock(LEFT)
			panel_player:DockMargin(4, 4, 0, 4)
			
			panel_player.Paint = self.PlayersReady[ply] and paint_ready or paint_unready
			
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
			
			panel_players.Players[ply] = panel_player
		end
		
		--we should just make a skin
		function panel_players:Paint(width, height)
			surface.SetDrawColor(color_background_players)
			surface.DrawRect(0, 0, width, height)
		end
		
		--we don't need all this extra crap like clamped scrolling
		--need to optimize the canvas_width algorithm
		--could literally be a math expression but too lazy to calculate the values right now
		function panel_players:PerformLayout(width, height)
			local canvas_width = 4
			
			for ply, panel_player in pairs(self.Players) do canvas_width = canvas_width + panel_player:GetWide() + 4 end
			
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
			self.Time = self.Time or time
			
			if self.Active ~= active then
				self.Active = active
				
				if active then self:SetVisible(true)
				else self:SetVisible(self.Percent ~= 0) end
			end
		end
		
		function label:Paint(width, height)
			surface.SetDrawColor(color_background)
			surface.DrawRect(0, 0, width, height)
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
			
			self:SetText(
				tostring(
					math.max(
						math.floor(
							self.Time - CurTime()
						),
						0
					)
				)
			)
		end
		
		label:SetActivity(false, CurTime() + 6)
		
		panel.LabelTimer = label
	end
	
	function panel:Paint(width, height)
		surface.SetDrawColor(color_background)
		surface.DrawRect(0, 0, width, label_timer_t)
	end
	
	self.TeamPanel = panel
	
	return panel
end

function GM:HUDOnRemoveTeamPanel(...) return true end --only gets called if the panel was valid

function GM:HUDTeamPanelGetHeaderText(wave_active, ready_allowed, ready)
	--this lets servers make custom text on the header for adverts or whatever they want
	if wave_active then return GetHostName() end
	if not ready_allowed then return language.GetPhrase("mingedefense.ui.team.header.inactive") end
	if ready then return language.GetPhrase("mingedefense.ui.team.header.ready") end
	
	--tell them how to ready up
	local bind = input.LookupBinding("md_ready") or input.LookupBinding("gm_showspare2")
	
	if bind then return self:LanguageFormat("mingedefense.ui.team.header.unready", {key = string.upper(bind)}) end
	
	return language.GetPhrase("mingedefense.ui.team.header.unbound")
end

function GM:HUDTeamPanelUpdateHeader(wave_active, ready_allowed, ...)
	--cache them for when the team panel is made
	local_ready_allowed = ready_allowed
	local_wave_active = wave_active
	
	self.TeamPanel.MarqueeLabel:SetText(hook.Call("HUDTeamPanelGetHeaderText", self, wave_active, ready_allowed, ...))
end

function GM:HUDTeamPanelUpdatePlayer(ply, ready)
	if self.TeamPanel then
		local panel_player = self.TeamPanel.PanelPlayers.Players[ply]
		
		panel_player.Paint = ready and paint_ready or paint_unready
	end
end

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

function GM:HUDTeamPanelCalculateVariables(width, height)
	local count = math.max(player.GetCount(), 6)
	local panel_max_w = width * 0.8
	
	panel_h = width * 0.05
	panel_w = count * math.floor(panel_h * 0.75 - 4) + 6
	
	if panel_w > panel_max_w then
		panel_oversized = true
		panel_w = panel_max_w
	else panel_oversized = false end
	
	panel_b = height - panel_h
	panel_lr = (width - panel_w) * 0.5
	
	--docking margins
	marquee_label_b = panel_h * 0.75
	panel_players_b = panel_h * 0.2
	panel_players_t = panel_h * 0.25
	label_timer_h = panel_h * 0.2
	label_timer_rl = (panel_w - (panel_h - panel_players_b - panel_players_t)) * 0.5
	label_timer_t = panel_h * 0.8
	
	hook.Call("HUDCreateTeamPanel", self, LocalPlayer())
end