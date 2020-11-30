--part of entity structure
ENT.Base = "base_nextbot"
ENT.Spawnable = true
ENT.Type = "nextbot"

--custom to entity
ENT.IsMinge = true --don't change this
ENT.WeaponClass = "base_minge_weapon"

--entity functions
function ENT:SharedInitialize()
	--more here?
	self:SetModel("models/player/kleiner.mdl")
end