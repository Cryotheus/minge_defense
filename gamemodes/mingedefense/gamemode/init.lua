DEFINE_BASECLASS("gamemode_sandbox")
include("shared.lua")

--gamemode functions
function GM:Initialize()
	print("Initialized gamemode by provided function. (Server)")
	
	BaseClass.Initialize(self)
end

function GM:PlayerSpawn(ply, transiton)
	ply:UnSpectate()
	ply:SetupHands()
	
	player_manager.SetPlayerClass(ply, "player_defender")
	player_manager.OnPlayerSpawn(ply, transiton)
	player_manager.RunClass(ply, "Spawn")
	
	--if we are in transition, do not touch player's weapons
	if not transiton then hook.Call("PlayerLoadout", GAMEMODE, ply) end
	
	--stupid addons
	hook.Call("PlayerSetModel", GAMEMODE, ply)
end

--we won't want them spawning crap with gm_spawn and stuff when the gamemode is ready, leaving it for debugging purpose as of right now
--function GM:PlayerSpawnObject(ply, model, skin) return false end

--finish off with the rest of the scripts
include("loader.lua")