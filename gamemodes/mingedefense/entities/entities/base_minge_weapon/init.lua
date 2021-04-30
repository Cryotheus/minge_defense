AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

--entity functions
function ENT:Drop(damage_force)
	local physics = self.Physics
	self.Dropped = true
	
	self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
	self:SetParent()
	
	self:SetAngles(self.Minge:LocalToWorldAngles(self.WeaponOffsetAngles))
	self:SetPos(self.Minge:LocalToWorld(self.WeaponOffsetPos))
	
	physics:EnableMotion(true)
	
	self:PhysWake()
	
	physics:SetVelocity(damage_force / self.WeaponMass * 0.9)
	
	timer.Simple(5, function() if IsValid(self) then self:Remove() end end)
end

function ENT:Initialize()
	--more here?
	self:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
	self:SetModel(self.WeaponModel)
	self:SetSkin(self.WeaponSkin)
	
	--we want to make it drop so we need physics
	self:PhysicsInit(SOLID_VPHYSICS)
	
	--but since we start with it parented to the minge, disable physics
	self:ParentToMinge()
	
	--lets also store the physics object for later
	self.Physics = self:GetPhysicsObject()
	
	self.Physics:EnableMotion(false)
	self.Physics:SetMass(self.WeaponMass)
end

function ENT:ParentToMinge()
	local minge = self.Minge
	
	if IsValid(minge) then
		--set up the position on the minge
		self:SetAngles(minge:LocalToWorldAngles(self.WeaponOffsetAngles))
		self:SetPos(minge:LocalToWorld(self.WeaponOffsetPos))
		self:SetSkin(self.WeaponSkin) --still don't know how to control color
		
		--finally, actually parent the model
		self:SetParent(minge)
	elseif SERVER then
		print(self, "had invalid parent", minge)
		
		self:Remove()
	end
end