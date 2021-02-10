local panel_b
local panel_h
local panel_lr
local panel_oversized
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

local function header_text(ready, ready_timer)
	--temporary, ready_timer won't be in the header but instead its own panel in the future
	if ready_timer then
		local time = math.Round(CurTime())
		
		return GAMEMODE:LangGetFormattedPhrase("mingedefense.ui.team.header.timer", {elipse = string.rep(".", time % 3 + 1), time = time % 60})
	elseif ready then return language.GetPhrase("mingedefense.ui.team.header.ready")
	else return GAMEMODE:LangGetFormattedPhrase("mingedefense.ui.team.header.unready", {key = string.upper(input.LookupBinding("gm_showspare2") or "NIL")}) end --prioritize the md_ready command in finding the key
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
		marquee_label:DockMargin(0, 0, 0, panel_h * 0.75)
		marquee_label:SetFont("MingeDefenseUITeamHeader")
		marquee_label:SetText(header_text(self.PlayersReady[LocalPlayer()], self.ReadyTimer))
		
		panel.MarqueeLabel = marquee_label
	end
	
	do --player panel TODO: optimize the scrolling effect
		local panel_players = vgui.Create("DHorizontalScroller", panel)
		local panel_players_scroll = 0
		
		panel_players.Players = {}
		
		panel_players:Dock(FILL)
		panel_players:DockMargin(0, panel_h * 0.25, 0, 0)
		
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
	
	--function panel:OnRemove() GAMEMODE.TeamPanel = nil end
	
	function panel:Paint(width, height)
		surface.SetDrawColor(color_background)
		surface.DrawRect(0, 0, width, height)
	end
	
	self.TeamPanel = panel
	self.MDTeamPanel = panel
	
	return panel
end

--only gets called if the panel was valid
function GM:HUDOnRemoveTeamPanel(...) return true end

function GM:HUDTeamPanelUpdatePlayer(ply, ready, ready_timer)
	print("updating", self.TeamPanel, self.MDTeamPanel)
	
	if self.TeamPanel then
		local panel_player = self.TeamPanel.PanelPlayers.Players[ply]
		
		panel_player.Paint = ready and paint_ready or paint_unready
		
		print("we did it with", ply, ready)
		
		if ply == LocalPlayer() then self.TeamPanel.MarqueeLabel:SetText(header_text(ready, ready_timer)) else print("not local ply") end
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
	
	panel_h = width * 0.04
	panel_w = count * math.floor(panel_h * 0.75 - 4) + 6
	
	if panel_w > panel_max_w then
		panel_oversized = true
		panel_w = panel_max_w
	else panel_oversized = false end
	
	panel_b = height - panel_h
	panel_lr = (width - panel_w) * 0.5
	
	hook.Call("HUDCreateTeamPanel", self, LocalPlayer())
end