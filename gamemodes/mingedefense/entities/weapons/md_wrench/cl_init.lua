include("shared.lua")

SWEP.Author = "Cryotheum"
SWEP.Category = "Minge Defense"
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = true
SWEP.Instructions = "#mingedefense.weapons.wrench.instructions"
SWEP.PrintName = language.GetPhrase("mingedefense.weapons.wrench")
SWEP.Purpose = "#mingedefense.weapons.wrench.purpose"
SWEP.UseHands = true
SWEP.ViewModelFOV = 54

--swep functions
function SWEP:OnRemove() if IsValid(self.WrenchEntity) then self.WrenchEntity:Remove() end end