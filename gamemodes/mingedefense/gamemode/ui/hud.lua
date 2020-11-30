--contains code for the HUD elements of the user interface
local blocked_elements = {
	CHudBattery = true,
	CHudHealth = true
}

--global functions
function GM:HUDShouldDraw(name) return not blocked_elements[name] end