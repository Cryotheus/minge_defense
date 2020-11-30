include("shared.lua")

--part of entity structure
ENT.Category = "Minge Defense"
ENT.PrintName = "Minge Base" --required with this gamemode!

--custom to entity
ENT.ShirtVector = Vector(1, 1, 1)
ENT.WeaponSkin = 1

--changes the shirt color to ShirtVector
function ENT:GetPlayerColor() return self.ShirtVector end

function ENT:Initialize() self:SharedInitialize() end

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

--net
net.Receive("minge_defense_minge_killed", function()
	local minge = net.ReadEntity()
	
	if IsValid(minge) then minge:OnKilled(net.ReadVector()) end
end)

--post
AddPrintNameToLanguage(ENT)