ENT.Base = "base_point"
ENT.Type = "point"

--serverside only, only the above is needed shared
if CLIENT then return end

--custom to entity
ENT.Keys = {}

--entity functions
function ENT:Initialize()
	print("Minge path target initialized!", self)
	PrintTable(self.Keys, 1)
end

function ENT:KeyValue(key, value)
	self.Keys[key] = value
	
	--mdgroupid
	--mduniqueid
end