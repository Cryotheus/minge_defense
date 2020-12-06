include("shared.lua")

--part of entity structure
ENT.PrintName = "Minge Defense Wave Info Screen"

--custom to entity
ENT.PanelScale = 0.2

--locals
local associated_colors = MingeDefenseColors.Screens.Wave
local color_background = associated_colors.Background
local logo = Material("minge_defense/gui/logo512.png")

--entity functions
function ENT:CreatePanel()
	LocalPlayer():PrintMessage(HUD_PRINTCENTER, "Reloaded " .. tostring(self))
	
	local panel = vgui.Create("DPanel")
	local panel_h, panel_w = 540, 960
	
	do --panel: parent panel
		panel:SetPaintedManually(true)
		panel:SetPos(0, 0)
		panel:SetSize(panel_w, panel_h)
		
		function panel:Paint(width, height)
			surface.SetDrawColor(color_background)
			surface.DrawRect(0, 0, width, height)
		end
	end
	
	do --panel_logo: logo
		local panel_logo = vgui.Create("Panel", panel)
		
		panel_logo:SetSize(512, 512)
		panel_logo:Center()
		
		function panel_logo:Paint(width, height)
			surface.SetDrawColor(255, 255, 255)
			surface.SetMaterial(logo)
			surface.DrawTexturedRect(0, 0, width, height)
		end
	end
	
	do --label: info text
		local label = vgui.Create("DLabel", panel)
		
		label:Dock(FILL)
		--label:DockMargin(0, 12, 0, panel_w - 60)
		label:DockMargin(0, 4, 0, 0)
		label:SetContentAlignment(8)
		label:SetFont("MingeDefenseUIStatus")
		label:SetTextColor(color_white)
		label:SetText(string.upper("MINGE DEFENSE INFO SCREEN TEST"))
	end
	
	self:SetPanelOffset(panel_w * -0.5, panel_h * -0.5, panel_w, panel_h, self.PanelScale)
	
	self.Panel = panel
end