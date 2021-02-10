DEFINE_BASECLASS("gamemode_sandbox")
include("shared.lua")

--gamemode functions
function GM:CLPlayerInitialSpawn(ply)
	if ply ~= LocalPlayer() then
		hook.Call("HUDTeamPanelCalculateVariables", self, ScrW(), ScrH())
		hook.Call("HUDCreateTeamPanel", self)
	end
end

function GM:CreateClientsideRagdoll(entity, ragdoll)
	if IsValid(entity) and entity.IsMinge then
		local color = entity.ShirtColor
		local start_time = RealTime()
		
		function ragdoll:GetPlayerColor() return color end
		
		timer.Simple(5, function() if IsValid(ragdoll) and ragdoll:IsRagdoll() then ragdoll:SetSaveValue("m_bFadingOut", true) end end)
	end
end

function GM:Initialize()
	print("Initialized gamemode by provided function. (Client)")
	
	BaseClass.Initialize(self)
end

function GM:InitPostEntity()
	hook.Call("LocalPlayerInitialized", self, LocalPlayer())
	
	timer.Simple(5, function()
		--we need to delay it I guess
		hook.Call("RoundScanSENTS", self)
	end)
end

function GM:LocalPlayerInitialized(ply)
	hook.Call("HUDCalculateVariables", self, ScrW(), ScrH(), nil, nil, ply)
	hook.Call("HUDCreateTeamPanel", GAMEMODE, ply)
end

function GM:OnReloaded() hook.Call("HUDCalculateVariables", self, ScrW(), ScrH()) end

function GM:OnScreenSizeChanged(old_width, old_height)
	local width, height = ScrW(), ScrH()
	
	hook.Call("HUDCalculateVariables", self, width, height, old_width, old_height)
end

--we don't need an intricate spawn menu for this gamemode, convenient for debugging though, so it gets to stay for now
--we will use PlayerBindPressed with +menu to make them swap to their last weapon
--function GM:SpawnMenuEnabled() return false end

--net
net.Receive("minge_defense_player_init", function() hook.Call("CLPlayerInitialSpawn", GAMEMODE, net.ReadEntity()) end)
net.Receive("minge_defense_url", function() gui.OpenURL(net.ReadString()) end)

--finish off with the rest of the scripts
include("loader.lua")