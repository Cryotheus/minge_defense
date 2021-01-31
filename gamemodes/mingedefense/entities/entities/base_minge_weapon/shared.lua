ENT.Base = "base_anim"
ENT.Spawnable = false
ENT.Type = "anim"

ENT.IsMingeWeapon = true --don't change this
ENT.Minge = nil --here to remind you this is required
ENT.WeaponMass = 30 --damn the physics gun is fucking heavy
ENT.WeaponModel = "models/weapons/w_physics.mdl"
ENT.WeaponOffsetAngles = angle_zero
ENT.WeaponOffsetPos = Vector(12, 0, 36)
ENT.WeaponSkin = 1

function ENT:Drop(damage_force)
	local physics = self.Physics
	
	self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
	self:SetParent()
	
	self:SetAngles(self.Minge:LocalToWorldAngles(self.WeaponOffsetAngles))
	self:SetPos(self.Minge:LocalToWorld(self.WeaponOffsetPos))
	
	physics:EnableMotion(true)
	
	self:PhysWake()
	
	physics:SetVelocity(damage_force / self.WeaponMass)
	
	timer.Simple(5, function() if IsValid(self) then self:Remove() end end)
end

function ENT:IsMingeWeapon() return true end