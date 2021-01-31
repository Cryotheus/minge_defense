AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

AccessorFunc(ENT, "Flugel", "Flugel")

function ENT:Initialize()
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_NONE)
end

function ENT:SetFlugel(flugel)
	if isentity(flugel) and IsValid(flugel) then
		local attach = flugel:LookupAttachment("anim_attachment_head")
		
		if attach > 0 then
			local attach_orientation = flugel:GetAttachment(attach)
			
			self:SetAngles(attach_orientation.Ang)
			self:SetPos(attach_orientation.Pos)
			
			self:SetParent(flugel, attach)
		end
	end
	
	self.Flugel = flugel
end