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
		hook.Call("HUDDrawStatus", self, ply)
	end
end

function GM:HUDShouldDraw(name) return not blocked_elements[name] end

--hooks
hook.Add("LocalPlayerInitialized", "minge_defense_hud", function(local_ply) ply = local_ply end)