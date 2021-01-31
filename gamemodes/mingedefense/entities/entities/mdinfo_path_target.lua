ENT.Base = "base_point"
ENT.Type = "point"

--serverside only, only the above is needed shared
if CLIENT then return end

--custom to entity
ENT.Keys = {}

--entity functions
function ENT:Initialize()
	--do some stuff here
	--like take the mduniqueid or mdgroupid and plug it into a global table
end

function ENT:KeyValue(key, value)
	self.Keys[key] = value
	
	--mdgroupid
	--mduniqueid
	
	--example PrintTable of keys
	--[[
		Minge path target initialized!  Entity [57][mdinfo_path_target]
			angles =		0 0 0
			classname =		mdinfo_path_target
			hammerid =		8109
			mduniqueid =	cat_walk
			origin =		-960 960 128
	]]
end