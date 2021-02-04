AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	--more here?
	self:SetModel("models/weapons/w_physics.mdl")
	
	--we want to make it drop so we need physics
	self:PhysicsInit(SOLID_VPHYSICS)
	
	--lets also store the physics object for later
	self.Physics = self:GetPhysicsObject()
end