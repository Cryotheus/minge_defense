AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

--custom to entity
ENT.Damage = 8
ENT.StartHealth = 100

--local funcitons
local function behave(self)
	--if there is no player target or we failed to path to the target go to normal objective based targetting
	if not IsValid(self.Target) or self:MoveToPos(self.Target:GetPos(), {repath = 1, tolerance = 0}) == "failed" then
		--normal objective based targetting
		self:MoveToPos(self.TargetPos, {repath = 1, tolerance = 40})
	end
end

--ent functions
function ENT:Agress(ply)
	--maybe play an angry sound here
	self.Target = ply
	
	--behave(self)
	
	self:SetSpeed(160)
end

function ENT:AttackedPlayer(ply)
	PrintMessage(HUD_PRINTTALK, "Attacked " .. tostring(ply))
	
	self:Agress(ply)
end

function ENT:AttackedByPlayer(ply)
	PrintMessage(HUD_PRINTTALK, "Attacked " .. tostring(ply))
	
	self:Agress(ply)
end

function ENT:RunBehaviour()
	--make them move to the target
	while true do
		--behave(self)
		
		PrintMessage(HUD_PRINTTALK, "Target: " .. tostring(self.Target))
		print("Target:", self.Target)
		if not IsValid(self.Target) or self:MoveToPos(self.Target:GetPos(), {repath = 1, tolerance = 0}) == "failed" then
			--normal objective based targetting
			self:MoveToPos(self.TargetPos, {repath = 1, tolerance = 40}) --has coroutine crap inside
		end
		
		
		coroutine.wait(2)
		coroutine.yield()
	end
end