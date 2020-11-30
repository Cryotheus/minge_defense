include("shared.lua")

function ENT:Initialize()
	self.Minge = self:GetParent()
	
	self:SharedInitialize()
end