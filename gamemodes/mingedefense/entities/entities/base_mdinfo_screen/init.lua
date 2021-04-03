AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:SetCalculatedBounds(off_x, off_y, width, height, scale)
	if self.DynamicPhysics then
		local world_off_vector = Vector(0, off_x, -off_y)
		
		self:PhysicsInitBox(world_off_vector, world_off_vector + Vector(1, width * scale, height * scale))
		self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
		self:SetSolid(SOLID_OBB)
		
		local physics = self:GetPhysicsObject()
		
		physics:EnableMotion(self.DynamicPhysicsMotion or false)
	else self:PhysicsInitStatic(SOLID_NONE) end
end