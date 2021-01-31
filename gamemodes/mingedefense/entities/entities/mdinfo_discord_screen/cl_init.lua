include("shared.lua")

--part of entity structure
ENT.PrintName = "Minge Defense Discord Screen"

--custom to entity
ENT.PanelScale = 0.2

--local funcrtions
local color_background = MingeDefenseColors.Screens.Wave.Background

--entity functions
function ENT:CreatePanel()
	local panel = vgui.Create("DPanel")
	local panel_h, panel_w = 960, 540
	
	do --base parent panel
		panel:SetPaintedManually(true)
		panel:SetPos(0, 0)
		
		--the width needs 8 and the height needs 16 pixels extra to keep the scroll bar from appearing
		panel:SetSize(panel_w + 8, panel_h + 16)
		
		--we don't want the panel to draw, just the html panel
		function panel:Paint(width, height) --[[
			surface.SetDrawColor(color_background)
			surface.DrawRect(0, 0, width, height) --]]
		end
	end
	
	do --html discord widget
		local html_panel = vgui.Create("DHTML", panel)
		
		--TODO: allow custom discord URLs
		html_panel:Dock(FILL)
		html_panel:DockMargin(0, 0, 0, 0)
		html_panel:SetHTML([=[<iframe src="https://discord.com/widget?id=785233414374686720&theme=dark" width="]=] .. panel_w .. [=[" height="]=] .. panel_h .. [=[" allowtransparency="true" frameborder="0" sandbox="allow-popups allow-popups-to-escape-sandbox allow-same-origin allow-scripts"></iframe>]=])
	end
	
	self:SetPanelOffsetCentered(panel_w, panel_h, self.PanelScale)
	
	self.Panel = panel
end
