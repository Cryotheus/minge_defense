--part of entity structure
ENT.Base = "base_nextbot"
ENT.Spawnable = true
ENT.Type = "nextbot"

--custom to entity
--ENT.ShirtColor = color_white --no longer used

function ENT:InitialLoad() end

function ENT:SharedInitialize()
	--more here?
	self:SetModel("models/player/kleiner.mdl")
end