SWEP.AutoSwitchTo = true
SWEP.Slot = 2
SWEP.SlotPos = 0
SWEP.Spawnable = true
--SWEP.ViewModel = "models/minge_defense/wrench/cryotheum_reference.mdl" --"models/weapons/c_crowbar.mdl"
--SWEP.ViewModel = "models/weapons/c_crowbar.mdl"
SWEP.ViewModel = "models/minge_defense/weapons/c_wrench/c_wrench.mdl"
SWEP.Weight = 2
SWEP.WorldModel = "models/weapons/w_models/w_wrench.mdl"

SWEP.Primary = {
	Ammo = "none",
	Automatic = true,
	ClipSize = -1,
	DefaultClip = -1
}

SWEP.Secondary = {
	Ammo = "none",
	Automatic = false,
	ClipSize = -1,
	DefaultClip = -1
}

function SWEP:PrimaryAttack()
	local act
	local cur_time = CurTime()
	local owner = self:GetOwner()
	local trace = owner:GetEyeTrace()
	
	if trace.HitPos:Distance(owner:GetShootPos()) <= 75 then
		act = ACT_VM_HITCENTER
		
		owner:FireBullets({
				Num =	1,
				Src =	self.Owner:GetShootPos(),
				Dir =	self.Owner:GetAimVector(),
				Spread =	Vector(0, 0, 0),
				Tracer =	0,
				Force =		5,
				Damage =	25
		})
		
		self:EmitSound("Weapon_Crowbar.Melee_Hit")
	else
		act = ACT_VM_MISSCENTER
		
		owner:SetAnimation(PLAYER_ATTACK1)
		self:EmitSound("Weapon_Crowbar.Single")
	end
	
	self:SendWeaponAnim(act)
	self:SetNextPrimaryFire(cur_time + 0.8)
	
	self.NextIdleTime = CurTime() + self:SequenceDuration(self:SelectWeightedSequence(act))
end

function SWEP:Reload() end
function SWEP:SecondaryAttack() end

function SWEP:SharedInitialize() self:SetHoldType("melee") end

function SWEP:Think()
	if self.NextIdleTime and CurTime() > self.NextIdleTime then
		self.NextIdleTime = nil
		
		self:SendWeaponAnim(ACT_VM_IDLE)
	end
end