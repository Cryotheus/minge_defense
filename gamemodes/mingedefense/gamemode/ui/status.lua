--in the future these will be derma panels
--the status bar will be a sizable panel which automatically sizes to accommodate for appearing and disappearing panels
--cached functions

----calculated variables
	local error_px_half = 0.5 / 32 -- half pixel anticorrection for surface.DrawTexturedRectUV
	local error_px_div = 1 - error_px_half * 2
	local margin = 4
	local margin_double = margin * 2
	local margin_half = margin * 0.5
	local status_bar_h
	local status_bar_w

----colors
	local associated_colors = GM.UIColors.HUD.Status
	local color_background = associated_colors.Background

----localized functions
	local fl_math_floor = math.floor
	local fl_surface_DrawTexturedRectUV = surface.DrawTexturedRectUV

local supplies = {
	DrawUVTexture = function(x, y, width, height, start_u, start_v, end_u, end_v)
		fl_surface_DrawTexturedRectUV(
			x,
			y,
			width,
			height,
			
			(start_u - error_px_half) / error_px_div,
			(start_v - error_px_half) / error_px_div,
			(end_u - error_px_half) / error_px_div,
			(end_v - error_px_half) / error_px_div
		)
	end,
	
	EvenFloor = function(value) return fl_math_floor(value * 0.5) * 2 end,
	
	Dimensions = {
		Margin = margin,
		MarginDouble = margin_double,
		MarginHalf = margin_half
	}
}

--gamemode functions
--lua_run_cl hook.Call("HUDCreateStatusPanel", GAMEMODE, LocalPlayer())
function GM:HUDCreateStatusPanel(ply)
	hook.Call("HUDRemoveStatusPanel", self)
	
	local panel_status = vgui.Create("DSizeToContents", GetHUDPanel(), "MingeDefenseStatus")
	local panels = {}
	local scr_w, scr_h = ScrW(), ScrH()
	
	panel_status:Dock(BOTTOM)
	panel_status:DockMargin(4, 4, ScrW() * 0.85, 4)
	panel_status:DockPadding(4, 0, 4, 4)
	panel_status:SetZPos(10)
	
	function panel_status:Paint(width, height)
		surface.SetDrawColor(color_background)
		surface.DrawRect(0, 0, width, height)
	end
	
	function panel_status:PerformLayout(width, height) self:SizeToChildren(false, true) end
	
	for index, panel_name in ipairs(self.StatusPanels) do
		local panel = vgui.Create(panel_name, panel_status)
		
		panel:CalculateVariables(scr_w, scr_h, scr_w, scr_h, ply)
		panel:Dock(TOP)
		panel:DockMargin(0, 4, 0, 0)
		panel:SetHeight(panel.DockHeight or 32)
		panel:InvalidateLayout(true)
		
		table.insert(panels, panel)
	end
	
	panel_status.Panels = panels
	self.StatusPanel = panel_status
end

function GM:HUDRemoveStatusPanel()
	local existing_panels = {} 
	
	for index, panel in ipairs(GetHUDPanel():GetChildren()) do
		if panel:GetName() == "MingeDefenseStatus" then
			table.insert(existing_panels, panel)
		end
	end
	
	hook.Call("HUDOnRemoveStatusPanel", self, unpack(existing_panels))
	
	if table.IsEmpty(existing_panels) then return false end
	for index, panel in ipairs(existing_panels) do panel:Remove() end
	
	self.StatusPanel = false
	
	return true
end

function GM:HUDStatusCalculateChildVariables(...) for index, panel in ipairs(self.StatusPanel.Panels) do panel:CalculateVariables(...) end end

function GM:HUDStatusCalculateVariables(width, height, ...) --width, height, old_width, old_height, local_ply
	local dimensions = supplies.Dimensions
	--what
	
	if self.StatusPanel then hook.Call("HUDStatusCalculateChildVariables", self, width, height, ...) end
end

function GM:HUDStatusLoad()
	print(" ]	Looking for status panels...")
	
	self.StatusPanels = {}
	
	for index, script in pairs(file.Find("mingedefense/gamemode/ui/status_panels/*", "LUA") or {}) do
		print(" ]	 ]	Found status panel " .. script .. " @ " .. index)
		
		---[[
		STATUS_PANEL = {
			StatusPanel = panel_status,
			Supplies = supplies
		}
		
		include("mingedefense/gamemode/ui/status_panels/" .. script)
		
		local panel_base = STATUS_PANEL.BaseName
		local panel_name = "MDStatus" .. STATUS_PANEL.Name
		STATUS_PANEL.BaseName = nil
		STATUS_PANEL.Name = nil
		STATUS_PANEL.StatusPanel = nil
		STATUS_PANEL.Supplies = nil
		
		derma.DefineControl(panel_name, "Automatically generated panel for Minge Defense.", STATUS_PANEL, panel_base)
		table.insert(self.StatusPanels, panel_name)
		
		STATUS_PANEL = nil
		--]]
	end
end

hook.Call("HUDStatusLoad", GM)