AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
util.AddNetworkString("minge_defense_minge_killed")

--custom to entity
ENT.CanAttack = true
ENT.Damage = 5
ENT.DamageCooldown = 0.25
ENT.Speed = 80
ENT.StartHealth = 50
ENT.TargetPos = Vector(1920, 0, 696.031250) --just to test for now

ENT.AttackSounds = {
	"vo/k_lab/kl_diditwork.wav",
	"vo/k_lab/kl_excellent.wav",
	"vo/k_lab/kl_fiddlesticks.wav"
}

ENT.HurtSounds = {
	"vo/k_lab/kl_dearme.wav",
	"vo/k_lab/kl_ahhhh.wav",
	"vo/k_lab/kl_ohdear.wav",
	"vo/k_lab/kl_getoutrun01.wav"
}

--entity functions
--so we can do stuff as a mod of the base without rewriting the base
function ENT:AttackedPlayer(entity) end
function ENT:AttackedByPlayer(damage_info) end

function ENT:EmitVOSound(choices, max_index) self:EmitSound(choices[math.random(max_index)], 90, math.random(190, 200), 1, CHAN_VOICE) end

function ENT:Initialize()
	--run the initialize that is shared, in shared.lua
	self:SharedInitialize()
	
	--make the entity do Touch calls
	self:SetHealth(self.StartHealth)
	self:SetSolid(SOLID_BBOX)
	
	--slow that bitch down
	self:SetSpeed(self.Speed)
	self.loco:SetStepHeight(40) --seems like a lot, dontworryaboutit
	
	self.AttackSoundCount = #self.AttackSounds
	self.HurtSoundCount = #self.HurtSounds
end

function ENT:OnContact(entity)
	if self.CanAttack and IsValid(entity) and entity:IsPlayer() then
		self.CanAttack = false
		
		entity:TakeDamage(self.Damage, self, self)
		self:EmitVOSound(self.AttackSounds, self.AttackSoundCount)
		
		timer.Simple(self.DamageCooldown, function() self.CanAttack = true end)
		
		self:AttackedPlayer(entity)
	end
end

function ENT:OnInjured(damage_info)
	local damage = damage_info:GetDamage()
	local health = self:Health()
	
	if damage < health then self:EmitVOSound(self.HurtSounds, self.HurtSoundCount) end
	
	self:AttackedByPlayer(damage_info)
end

function ENT:OnKilled(damage_info)
	net.Start("minge_defense_minge_killed")
	net.WriteEntity(self)
	net.Broadcast()
	
	self:BecomeRagdoll(damage_info)
	
	PrintMessage(HUD_PRINTTALK, "Killed a minge: " .. tostring(self))
end

function ENT:RunBehaviour()
	--make them move to the target
	while true do
		--self:StartActivity(ACT_WALK)
		self:MoveToPos(self.TargetPos, {repath = 1, tolerance = 40})
		
		coroutine.wait(2)
		coroutine.yield()
	end
end

function ENT:SetSpeed(speed)
	local locomotive = self.loco
	
	locomotive:SetAcceleration(speed)
	locomotive:SetDeceleration(speed * 2)
	locomotive:SetDesiredSpeed(speed)
	
	self.Speed = speed
end


--post
ENT:InitialLoad()