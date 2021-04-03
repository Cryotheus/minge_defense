DEFINE_BASECLASS("gamemode_sandbox")
include("shared.lua")

--local variables
local map_diagonal = 113512
local psychokinesis_trace = {}

--gamemode tables
--GM is NOT the same table as GAMEMODE 
GM.PsychokineticEntities = GAMEMODE.PsychokineticEntities or {}

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

function GM:InitPostEntity() hook.Call("LocalPlayerInitialized", self, LocalPlayer()) end

--sorry single playing peeps, no compensation yet
function GM:KeyPress(ply, key) if IsFirstTimePredicted() and key == IN_USE then self:PsychokineticUse(ply) end end

function GM:LocalPlayerInitialized(ply)
	hook.Call("HUDCalculateVariables", self, ScrW(), ScrH(), nil, nil, ply)
	hook.Call("HUDCreateTeamPanel", GAMEMODE, ply)
end

function GM:OnReloaded() hook.Call("HUDCalculateVariables", self, ScrW(), ScrH()) end

function GM:OnScreenSizeChanged(old_width, old_height)
	local width, height = ScrW(), ScrH()
	
	hook.Call("HUDCalculateVariables", self, width, height, old_width, old_height)
end

function GM:PsychokineticUse(ply)
	local start = ply:GetShootPos()
	
	psychokinesis_trace.endpos = start + ply:EyeAngles():Forward() * map_diagonal
	psychokinesis_trace.filter = ply
	psychokinesis_trace.start = start
	
	local trace = util.TraceLine(psychokinesis_trace)
	local trace_entity = trace.Entity
	local trace_hit = trace.HitPos
	
	if IsValid(trace_entity) then
		--we have an entity, run the use function
		local psychokinetic_use = trace_entity.PsychokineticUse and trace_entity:PsychokineticUse(start, trace_hit, trace.HitNormal, false) or nil
		
		if psychokinetic_use ~= nil then return trace_entity, psychokinetic_use end
	end
	
	--we failed, let PsychokineticUseRay handle it
	return hook.Call("PsychokineticUseRay", self, start, trace_hit)
end

function GM:PsychokineticUseRay(start, hit)
	local end_offset = hit - start
	local record
	local record_fraction = 2
	local record_hit
	local record_normal
	
	--test for the best candidate
	for entity, bounds in pairs(self.PsychokineticEntities) do
		if IsValid(entity) and entity.PsychokineticUse then
			local hit_pos, normal, fraction = util.IntersectRayWithOBB(start, end_offset, entity:GetPos(), entity:GetAngles(), bounds.Mins, bounds.Maxs)
			
			if fraction and fraction < record_fraction then
				record = entity
				record_fraction = fraction
				record_hit = hit_pos
				record_normal = normal
			end
		else ErrorNoHaltWithStack("Invalid entity presented to PsychokineticUseRay! " .. tostring(entity)) end
	end
	
	if record then return record, record:PsychokineticUse(start, record_hit, record_normal, true) end
end

--we don't need an intricate spawn menu for this gamemode, convenient for debugging though, so it gets to stay for now
--we will use PlayerBindPressed with +menu to make them swap to their last weapon
--function GM:SpawnMenuEnabled() return false end

--hooks
hook.Add("Think", "minge_defense_minge_icons", function()
	hook.Call("RoundScanSENTS", GAMEMODE)
	hook.Remove("Think", "minge_defense_minge_icons")
end)

--net
net.Receive("minge_defense_player_init", function() hook.Call("CLPlayerInitialSpawn", GAMEMODE, net.ReadEntity()) end)
net.Receive("minge_defense_url", function() gui.OpenURL(net.ReadString()) end)

--finish off with the rest of the scripts
include("loader.lua")