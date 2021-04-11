AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

--ent functions
function ENT:Agress(ply)
	--maybe play an angry sound here
	self.Activity = ACT_RUN
	self.Agressive = true
	self.Target = ply
	
	self:BehaviourSetup()
	self:SetSpeed(300)
end

function ENT:AttackedPlayer(ply) self:Agress(ply) end

function ENT:AttackedByPlayer(damage_info)
	local attacker = damage_info:GetAttacker()
	
	if IsValid(attacker) and attacker:IsPlayer() then self:Agress(attacker) end
end

function ENT:Behave()
	local path = self.Path
	local target = self.Target
	
	self:StartActivity(self.Activity)
	
	if self.Agressive then
		if IsValid(target) and target:Alive() then path:Chase(self, self.Target)
		else
			self:CalmDown()
			
			path:Update(self)
			
			return
		end
	else path:Update(self) end
end

function ENT:BehaviourSetup()
	local path
	
	if self.Agressive then
		path = Path("Chase")
		
		self.Path = path
		
		path:SetMinLookAheadDistance(300)
		path:SetGoalTolerance(20)
	else
		path = Path("Follow")
		
		self.Path = path
		
		path:SetMinLookAheadDistance(300)
		path:SetGoalTolerance(20)
		
		self:CreatePath()
	end
	
	return path
end

function ENT:CalmDown()
	self.Activity = ACT_WALK
	self.Agressive = false
	self.Target = nil
	
	self:BehaviourSetup()
	self:SetSpeed(80)
end

function ENT:OnOtherKilled(victim, damage_info)
	if IsValid(victim) and victim.IsMinge and victim.AggressWorth >= self.AggressWorthThreshold then
		local attacker = damage_info:GetAttacker()
		
		if IsValid(attacker) and attacker:IsPlayer() then
			--make sure they are within range, and yes it is fine to use Distance instead of DistToSqr, square roots only take ONE cycle on modern CPUs, stop over reacting
			if attacker:GetPos():Distance(self:GetPos()) < self.MaxAgressDistance then self:Agress(attacker) end
		end
	end
end
