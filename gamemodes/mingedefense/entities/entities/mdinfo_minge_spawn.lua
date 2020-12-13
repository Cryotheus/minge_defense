ENT.Base = "base_point"
ENT.Type = "point"

--serverside only, only the above is needed shared
if CLIENT then return end

--custom to entity
ENT.Keys = {}

--entity functions
function ENT:Initialize()
	print("Minge spawn initialized!", self)
	PrintTable(self.Keys, 1)
end

function ENT:KeyValue(key, value)
	self.Keys[key] = value
	
	if key == "mdgroupid" then
		if MingeDefenseMingeSpawns[value] then MingeDefenseMingeSpawns[value][self:EntIndex()] = self:GetPos()
		else MingeDefenseMingeSpawns[value] = {[self:EntIndex()] = self:GetPos()} end
	end
end