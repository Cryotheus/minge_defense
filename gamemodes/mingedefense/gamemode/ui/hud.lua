--we want to call the base gamemode's HUDPaint
DEFINE_BASECLASS("gamemode_base")

--locals
local blocked_elements = {
	CHudBattery = true,
	CHudHealth = true,
	CHudSecondaryAmmo = true,
	CHudZoom = true
}

local ply = LocalPlayer()

--global functions
function GM:HUDPaint()
	--do what we normally do
	BaseClass.HUDPaint(self)
	
	if IsValid(ply) then
		--more?
		--hook.Call("HUDDrawStatus", self, ply)
	end
end

function GM:HUDCalculateVariables(width, height, old_width, old_height, local_ply)
	--called when the screen size changes, when the local player initializes, and when the gamemode is reloaded
	--calculate you variables for the HUD here
	ply = IsValid(ply) and ply or local_ply
	
	hook.Call("HUDStatusCalculateVariables", self, width, height, old_width, old_height, local_ply)
	hook.Call("HUDTeamPanelCalculateVariables", self, width, height, old_width, old_height, local_ply)
end

function GM:HUDShouldDraw(name) return not blocked_elements[name] end