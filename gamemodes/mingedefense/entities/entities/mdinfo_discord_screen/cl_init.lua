include("shared.lua")

--part of entity structure
ENT.PrintName = "Minge Defense Discord Screen"

--custom to entity
ENT.PanelScale = 0.2

--local funcrtions
local color_background = MingeDefenseColors.Screens.Wave.Background

--entity functions
function ENT:CreatePanel()
	LocalPlayer():PrintMessage(HUD_PRINTCENTER, "Reloaded " .. tostring(self))
	
	local panel = vgui.Create("DPanel")
	local panel_h, panel_w = 960, 540
	
	do --panel: parent panel
		panel:SetPaintedManually(true)
		panel:SetPos(0, 0)
		panel:SetSize(panel_w, panel_h)
		--panel:SetTitle("TEMP")
		
		function panel:Paint(width, height)
			surface.SetDrawColor(color_background)
			surface.DrawRect(0, 0, width, height)
		end
	end
	
	--[[bull shit
	do
		panel:MakePopup()
		
		hook.Add("HUDPaint", "minge_defense_temp", function() if IsValid(panel) then panel:PaintManual() else hook.Remove("HUDPaint", "minge_defense_temp") end end)
	end --]]
	
	do --html: discord container
		local html_panel = vgui.Create("DHTML", panel)
		
		--TODO: allow custom discord URLs
		html_panel:Dock(FILL)
		html_panel:OpenURL("https://trello.com/b/jHVtAxUF/minge-defense")
		--html_panel:SetHTML([=[<iframe src="https://discord.com/widget?id=785233414374686720&theme=dark" width="524" height="944" allowtransparency="true" frameborder="0" sandbox="allow-popups allow-popups-to-escape-sandbox allow-same-origin allow-scripts"></iframe>]=])
	end
	
	self:SetPanelOffsetCentered(panel_w, panel_h, self.PanelScale)
	
	self.Panel = panel
end
