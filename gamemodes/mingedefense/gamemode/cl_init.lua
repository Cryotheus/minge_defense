DEFINE_BASECLASS("gamemode_sandbox")
include("shared.lua")

--gamemode functions
function GM:Initialize()
	print("Initialized gamemode by provided function. (Client)")
	
	BaseClass.Initialize(self)
end

--we don't need an intricate spawn menu for this gamemode, convenient for debugging though, so it gets to stay for now
--function GM:SpawnMenuEnabled() return false end

--finish off with the rest of the scripts
include("loader.lua")