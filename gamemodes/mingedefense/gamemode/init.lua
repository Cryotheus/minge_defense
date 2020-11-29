DEFINE_BASECLASS("gamemode_sandbox")
include("shared.lua")

--gamemode functions
function GM:Initialize()
	print("Initialized gamemode by provided function. (Server)")
	
	BaseClass.Initialize(self)
end

function GM:PlayerSpawn(ply, transiton)
	player_manager.SetPlayerClass(ply, "player_defender")
	BaseClass.PlayerSpawn(self, ply, transiton)
end

--we won't want them spawning crap with gm_spawn and stuff when the gamemode is ready, leaving it for debugging purpose as of right now
--function GM:PlayerSpawnObject(ply, model, skin) return false end

--finish off with the rest of the scripts
include("loader.lua")