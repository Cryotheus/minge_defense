include("shared.lua")

--part of entity structure
ENT.Category = "Minge Defense"
ENT.PrintName = "Minge Base" --required with this gamemode!
ENT.ScriptedEntityType = "npcs"

--custom to entity
ENT.GenerateIcon = true
ENT.ShirtVector = Vector(1, 1, 1)
ENT.WeaponSkin = 1

--does not exist after initialization
ENT.IconCamera = {
	AutoLighting = {
		Default = {1, 1, 1},
		Position = vector_origin
	},
	
	Far = 4096,
	FOV = 5,
	Near = 5,
	Position = Vector(500, 500, 500),
	TargetPosition = Vector(0, 0, 36)
}

--entity functions
function ENT:DrawIconModels() --does not exist after initialization
	--THIS FUNCTION IS NOT GIVEN AN ENTITY, IT IS GIVEN THE WHOLE ENT TABLE
	if self.IconModels then
		for index, model in ipairs(self.IconModels) do
			model:DrawModel()
		end
	end
end

function ENT:DrawIconWeaponModels() --does not exist after initialization
	--THIS FUNCTION IS NOT GIVEN AN ENTITY, IT IS GIVEN THE WHOLE ENT TABLE
	--[[local model = ClientsideModel("models/player/kleiner.mdl", RENDERGROUP_OTHER)
	
	model:DrawModel()
	model:Remove()]]
end

function ENT:GetPlayerColor() return self.ShirtVector end

function ENT:Initialize()
	--these should never get called by the entity or with an entity
	--they're meant to be called externally without an entity
	print(self.DrawIconModels)
	print(self.DrawIconWeaponModels)
	print(self.IconCamera)
	print(self.ReleaseIconModels)
	print(self.SetupIconModels)
end

function ENT:OnKilled(damage_force)
	--make the minge drop the weapon when they die
	local weapon_entity = self.WeaponEntity
	
	if IsValid(weapon_entity) then weapon_entity:Drop(damage_force) end
end

function ENT:OnRemove()
	--remove client side model
	local weapon_entity = self.WeaponEntity
	
	if IsValid(weapon_entity) then weapon_entity:Remove() end
end

function ENT:ReleaseIconModels() --does not exist after initialization
	--THIS FUNCTION IS NOT GIVEN AN ENTITY, IT IS GIVEN THE WHOLE ENT TABLE
	if self.IconModels then
		for index, model in ipairs(self.IconModels) do
			model:Remove()
		end
	end
	
	self.IconModels = nil
end

function ENT:SetupIconModels() --does not exist after initialization
	--THIS FUNCTION IS NOT GIVEN AN ENTITY, IT IS GIVEN THE WHOLE ENT TABLE
	local color = self.ShirtVector
	local model = ClientsideModel("models/player/kleiner.mdl", RENDERGROUP_OTHER)
	
	function model:GetPlayerColor() return color end
	
	self.IconModels = {model}
end

--net
net.Receive("minge_defense_minge_killed", function()
	local minge = net.ReadEntity()
	
	if IsValid(minge) then minge:OnKilled(net.ReadVector()) end
end)

--post
AddPrintNameToLanguage(ENT)