DEFINE_BASECLASS("gamemode_sandbox")
include("shared.lua")

--gamemode functions
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
		hook.Call("WaveScanSENTS", self)
	end)
end

function GM:LocalPlayerInitialized(ply)
	--
	print("LocalPlayerInitialized ran,", ply)
end

--we don't need an intricate spawn menu for this gamemode, convenient for debugging though, so it gets to stay for now
--we will use PlayerBindPressed with +menu to make them swap to their last weapon
--function GM:SpawnMenuEnabled() return false end

--net
net.Receive("minge_defense_url", function() gui.OpenURL(net.ReadString()) end)

--finish off with the rest of the scripts
include("loader.lua")