include("shared.lua")

--part of entity structure
ENT.PrintName = "Minge Defense Discord Screen"

--custom to entity
ENT.PanelScale = 0.2

--entity functions
function ENT:CreatePanel()
	local panel = vgui.Create("DPanel")
	local panel_w, panel_h = self.PanelWidth, self.PanelHeight
	
	do --base parent panel
		panel:SetPaintedManually(true)
		panel:SetPos(0, 0)
		
		panel:SetSize(panel_w, panel_h + 8)
		
		function panel:Paint(width, height) end
	end
	
	do --html discord widget
		local html_panel
		local reload_html_panel
		
		local function html_panel_think(self) if self.ExpireTime and RealTime() > self.ExpireTime then reload_html_panel(600) end end
		
		function reload_html_panel(expire_time)
			if html_panel then html_panel:Remove() end
			
			html_panel = vgui.Create("DHTML", panel)
			html_panel.ExpireTime = RealTime() + expire_time
			
			--TODO: allow custom discord URLs
			html_panel:Dock(FILL)
			html_panel:DockMargin(0, 0, 0, 0)
			html_panel:SetHTML([=[<iframe src="https://discord.com/widget?id=785233414374686720&theme=dark" width="]=] .. (panel_w - 8) .. [=[" height="]=] .. (panel_h - 8) .. [=[" allowtransparency="true" frameborder="0" sandbox="allow-popups allow-popups-to-escape-sandbox allow-same-origin allow-scripts"></iframe>]=])
			
			html_panel.Think = html_panel_think
			
			panel.HTMLPanel = html_panel
		end
		
		reload_html_panel(600)
	end
	
	self.Panel = panel
end

function ENT:PsychokineticUse(start, hit, normal, ray)
	if start:Distance(hit) > 256 then return false end
	
	local html_panel = self.Panel.HTMLPanel
	
	if html_panel.AttemptingJoin then gui.OpenURL("http://discord.gg/WMeCsQhakH")
	else
		html_panel.ExpireTime = RealTime() + 5
		html_panel.AttemptingJoin = true
		
		html_panel:OpenURL("http://discord.gg/WMeCsQhakH")
		
		print(html_panel)
	end
	
	return true
end