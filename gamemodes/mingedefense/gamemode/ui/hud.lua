--we want to call the base gamemode's HUDPaint
DEFINE_BASECLASS("gamemode_base")

--locals
local blocked_elements = {
	CHudBattery = true,
	CHudHealth = true,
	CHudSecondaryAmmo = true,
	CHudZoom = true
}

--global functions
--we don't want the crappy built in world tips
function GM:HUDPaint()
	BaseClass.HUDPaint(self)
	
	self:HUDDrawStatus()
end

function GM:HUDShouldDraw(name) return not blocked_elements[name] end