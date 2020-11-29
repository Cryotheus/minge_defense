include("shared.lua")

--part of entity structure
ENT.Category = "Minge Defense"
ENT.PrintName = "Minge Base" --required with this gamemode!

--custom to entity
ENT.ShirtVector = Vector(1, 1, 1)
ENT.WeaponModel = "models/weapons/w_physics.mdl"

--changes the shirt color to ShirtVector
function ENT:GetPlayerColor() return self.ShirtVector end

function ENT:InitialLoad()
	local minge_class_path = string.Split(self.Folder, "/")
	
	language.Add(minge_class_path[#minge_class_path], self.PrintName)
	util.PrecacheModel(self.WeaponModel)
end

function ENT:Initialize()
	local minge = self
	
	--init function from shared.lua that init.lua also uses
	minge:SharedInitialize()
	
	--local variables
	local shirt_color = minge.ShirtColor
	local weapon_entity = ClientsideModel(self.WeaponModel, RENDERGROUP_OPAQUE)
	
	--we make a function here, because these models supposedly unparent when the parent leaves the PVS
	function weapon_entity:ParentToMinge()
		--set up the position on the minge 
		self:SetAngles(minge:LocalToWorldAngles(Angle(0, 0, 0)))
		self:SetSkin(1) --still don't know how to control color
		self:SetPos(minge:LocalToWorld(Vector(12, 0, 36)))
		
		--finally, actually parent the model
		self:SetParent(minge)
	end
	
	weapon_entity:ParentToMinge()
	weapon_entity:Spawn()
	
	--outgoing variables to be accessed somewhere else
	minge.WeaponEntity = weapon_entity
end

function ENT:OnKilled()
	local weapon_entity = self.WeaponEntity
	
	LocalPlayer():PrintMessage(HUD_PRINTTALK, "Minge killed")
	
	if IsValid(weapon_entity) then
		local weapon_prop = ents.CreateClientProp(self.WeaponModel)
		
		weapon_prop:SetAngles(weapon_entity:GetAngles())
		weapon_prop:SetPos(weapon_entity:GetPos())
		weapon_prop:Spawn()
		
		timer.Simple(5, function() if IsValid(weapon_prop) then weapon_prop:Remove() end end)
		
		weapon_entity:Remove()
	end
end

function ENT:OnRemove()
	--remove client side model
	local weapon_entity = self.WeaponEntity
	
	if IsValid(weapon_entity) then weapon_entity:Remove() end
end

function ENT:Think()
	
end

--incoming ent
net.Receive("minge_defense_minge_killed", function()
	local minge = net.ReadEntity()
	
	if IsValid(minge) then minge:OnKilled() end
end)

--list
list.Set("NPC", "minge_base", {
	Name = ENT.PrintName,
	Class = "minge_base",
	Category = "Minge Defense"
})

--post
ENT:InitialLoad()