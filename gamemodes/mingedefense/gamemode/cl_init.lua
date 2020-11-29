DEFINE_BASECLASS("gamemode_sandbox")
include("shared.lua")

function GM:Initialize()
	print("Initialized gamemode by provided function. (Client)")
	
	BaseClass.Initialize(self)
end

--we don't need an intricate spawn menu for this gamemode
--function GM:SpawnMenuEnabled() return false end