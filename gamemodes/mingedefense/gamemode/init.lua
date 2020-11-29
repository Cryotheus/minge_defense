AddCSLuaFile("cl_init.lua")
AddCSLuaFile("player_class/player_defender.lua")
AddCSLuaFile("shared.lua")
DEFINE_BASECLASS("gamemode_sandbox")
include("shared.lua")

function GM:Initialize()
	print("Initialized gamemode by provided function. (Server)")
	
	BaseClass.Initialize(self)
end

function GM:PlayerSpawn(ply, transiton)
	player_manager.SetPlayerClass(ply, "player_defender")
	BaseClass.PlayerSpawn(self, ply, transiton)
end

--function GM:PlayerSpawnObject(ply, model, skin) return false end