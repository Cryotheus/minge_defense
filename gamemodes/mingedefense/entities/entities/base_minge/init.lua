AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
util.AddNetworkString("minge_defense_minge_killed")

--custom to entity
ENT.Activity = ACT_WALK
ENT.AggressWorth = 0
ENT.CanAttack = true
ENT.Damage = 5
ENT.DamageCooldown = 0.25
ENT.PathPatience = 4 --how many seconds do we wait before recomputing the path
ENT.Speed = 80
ENT.StartHealth = 50
ENT.Stuck = false
ENT.TargetPos = Vector(1920, 0, 696.031250) --just to test for now

ENT.AttackSounds = {
	"vo/k_lab/kl_diditwork.wav",
	"vo/k_lab/kl_excellent.wav",
	"vo/k_lab/kl_fiddlesticks.wav"
}

ENT.DeathSounds = {
	"vo/k_lab/kl_fiddlesticks.wav",
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

function ENT:Behave()
	local path = self.Path
	
	self:StartActivity(self.Activity)
	
	if path:GetAge() > self.PathPatience then self:CreatePath() end
	
	path:Update(self)
end

function ENT:BehaviourSetup()
	local path = Path("Follow")
	
	self.Path = path
	
	path:SetMinLookAheadDistance(300)
	path:SetGoalTolerance(20)
	path:Compute(self, self.TargetPos)
	
	self:CreatePath()
	
	return path
end

function ENT:CreatePath() self.Path:Compute(self, self.TargetPos) end
function ENT:EmitVOSound(choices, max_index) self:EmitSound(choices[math.random(max_index)], 60, math.random(190, 200), 1, CHAN_VOICE) end

function ENT:HandleStuck()
	--we should make a better anti stuck, like make them solid when they are no longer inside something, and try to make them get out of what ever they are stuck in by pushing them away
	local id = "minge_stuck_" .. self:EntIndex()
	
	self:SetSolidMask(MASK_NPCSOLID_BRUSHONLY)
	
	--if timer.Exists(id) then timer.Adjust(id, 5)
	--else timer.Create(id, 5, 1, function() if IsValid(self) then self:SetSolidMask(MASK_NPCSOLID) end end) end
	
	self.Stuck = true
	
	self.loco:ClearStuck()
end

function ENT:Initialize()
	--run the initialize that is shared, in shared.lua
	self:SetModel("models/player/kleiner.mdl")
	
	--some settings
	self:SetHealth(self.StartHealth)
	self:SetLagCompensated(true)
	self:SetSolid(SOLID_BBOX)
	self:SetSpeed(self.Speed)
	--self:SetSolidMask(MASK_NPCSOLID_BRUSHONLY)
	
	--locomotion settings
	self.loco:SetStepHeight(40) --seems like a lot, dontworryaboutit
	self.loco:SetMaxYawRate(600) --250 is default
	
	--recalculate them in case they are using a different list of sounds
	self.AttackSoundCount = #self.AttackSounds
	self.HurtSoundCount = #self.HurtSounds
	self.DeathSoundCount = #self.DeathSounds
	
	--weapon
	local weapon = ents.Create(self.WeaponClass)
	weapon.Minge = self
	self.WeaponEntity = weapon
	
	weapon:Spawn()
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
	
	--if they didn't die, play the hurt sound
	if damage < health then self:EmitVOSound(self.HurtSounds, self.HurtSoundCount) end
	
	self:AttackedByPlayer(damage_info)
end

function ENT:OnKilled(damage_info)
	local damage_force = damage_info:GetDamageForce()
	
	net.Start("minge_defense_minge_killed")
	net.WriteEntity(self)
	net.WriteVector(damage_force)
	net.Broadcast()
	
	self.WeaponEntity:Drop(damage_force)
	
	self:BecomeRagdoll(damage_info)
	self:EmitVOSound(self.DeathSounds, self.DeathSoundCount)
	
	timer.Remove("minge_stuck_" .. self:EntIndex())
end

function ENT:OnRemove() timer.Remove("minge_stuck_" .. self:EntIndex()) end

function ENT:RunBehaviour()
	--make them move to the target
	local path = self:BehaviourSetup()
	
	while true do
		--what do we do when they are stuck? PANIC!
		if self.loco:IsStuck() then
			--are they really stuck? or are we being dumb?
			if self:GetVelocity():LengthSqr() > 1 then self.loco:ClearStuck()
			else self:HandleStuck() end
		else self:Behave() end
		
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

function ENT:Think()
	if self.Stuck then
		local filter = self:GetChildren()
		
		table.insert(filter, self)
		
		local trace = util.TraceHull({
			endpos = self:GetPos() + Vector(0, 0, 72),
			filter = filter,
			ignoreworld = true,
			mask = MASK_NPCSOLID,
			maxs = Vector(13, 13, 0),
			mins = Vector(-13, -13, 0),
			start = self:GetPos(),
		})
		
		if not IsValid(trace.Entity) then
			self:SetSolidMask(MASK_NPCSOLID)
			
			self.Stuck = false
		end
	end
end