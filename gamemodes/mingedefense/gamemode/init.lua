DEFINE_BASECLASS("gamemode_sandbox")
include("shared.lua")

--temporary
--heil franklin gothic heavy
resource.AddSingleFile("resource/fonts/minge_defense.ttf")
resource.AddSingleFile("resource/localization/en/mingedefense.properties")

resource.AddFile("models/minge_defense/weapons/c_wrench/c_wrench.mdl")
resource.AddFile("materials/models/minge_defense/weapons/c_wrench/c_wrench.vmt")
resource.AddSingleFile("materials/models/minge_defense/weapons/c_wrench/light_warp.vtf")

resource.AddSingleFile("materials/minge_defense/gui/icon24.png")
resource.AddSingleFile("materials/minge_defense/gui/icon32.png")
resource.AddSingleFile("materials/minge_defense/gui/icon512.png")
resource.AddSingleFile("materials/minge_defense/gui/logo512.png")

resource.AddSingleFile("sound/minge_defense/weapons/wrench/hit_fail.wav")
resource.AddSingleFile("sound/minge_defense/weapons/wrench/hit_flesh_1.wav")
resource.AddSingleFile("sound/minge_defense/weapons/wrench/hit_flesh_2.wav")
resource.AddSingleFile("sound/minge_defense/weapons/wrench/hit_flesh_3.wav")
resource.AddSingleFile("sound/minge_defense/weapons/wrench/hit_flesh_4.wav")
resource.AddSingleFile("sound/minge_defense/weapons/wrench/hit_success_1.wav")
resource.AddSingleFile("sound/minge_defense/weapons/wrench/hit_success_2.wav")
resource.AddSingleFile("sound/minge_defense/weapons/wrench/hit_world.wav")
resource.AddSingleFile("sound/minge_defense/weapons/wrench/swing.wav")

util.AddNetworkString("minge_defense_player_init")
util.AddNetworkString("minge_defense_player_load")

--local variables
local loading_players = {}

--gamemode functions
function GM:CreateEntityRagdoll(owner, ragdoll)
	--
	PrintMessage(HUD_PRINTTALK, "Ragdoll created. " .. tostring(owner) .. ", " .. tostring(ragdoll))
end

function GM:Initialize()
	print("Initialized gamemode by provided function. (Server)")
	
	BaseClass.Initialize(self)
end

function GM:PlayerDisconnected(ply)
	loading_players[ply] = nil
	
	--lets not make Round too greedy
	hook.Call("RoundPlayerDisconnect", self, ply)
end

function GM:PlayerInitialSpawn(ply, ...)
	BaseClass.PlayerInitialSpawn(self, ply, ...)
	
	loading_players[ply] = true
end

function GM:PlayerLoad(ply)
	net.Start("minge_defense_player_init")
	net.WriteEntity(ply)
	net.Broadcast()
	
	if player.GetCount() == 1 then hook.Call("RoundInitialize", self, "normal") end
end

--[[
function GM:PlayerShouldTakeDamage(ply, attacker)
	if attacker:IsValid() and attacker:IsPlayer() and ply ~= attacker then return false end
	
	return true
end
]]

function GM:PlayerSpawn(ply, transiton)
	ply:UnSpectate()
	ply:SetupHands()
	
	--player_manager.SetPlayerClass(ply, ply:SteamID() == "STEAM_0:1:72956761" and "player_flugel" or "player_defender")
	player_manager.SetPlayerClass(ply, "player_defender")
	player_manager.OnPlayerSpawn(ply, transiton)
	player_manager.RunClass(ply, "Spawn")
	
	--if we are in transition, do not touch player's weapons
	if not transiton then hook.Call("PlayerLoadout", GAMEMODE, ply) end
	
	--stupid addons
	hook.Call("PlayerSetModel", GAMEMODE, ply)
end

function GM:PreCleanupMap() MingeDefenseMingeSpawns = {} end

function GM:Tick()
	--special crud
	hook.Call("RoundTick", self)
end

--we won't want them spawning crap with gm_spawn and stuff when the gamemode is ready, leaving it for debugging purpose as of right now
--function GM:PlayerSpawnObject(ply, model, skin) return false end

--net
net.Receive("minge_defense_player_load", function(length, ply)
	if loading_players[ply] then
		loading_players[ply] = nil
		
		hook.Call("PlayerLoad", GAMEMODE, ply)
	else ErrorNoHaltWithStack("A player (", ply, ") tried to send a load net message but has yet to be spawned!") end
end)

--finish off with the rest of the scripts
include("loader.lua")