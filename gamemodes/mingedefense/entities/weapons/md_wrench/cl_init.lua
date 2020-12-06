include("shared.lua")

SWEP.Author = "Cryotheum"
SWEP.Category = "Minge Defense"
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = true
SWEP.Instructions = "Left click to swing wrench and heal buildings, right click to pick up buildings to relocate them."
SWEP.PrintName = "Wrench"
SWEP.Purpose = "Hit things."
SWEP.UseHands = true
SWEP.ViewModelFOV = 54

--swep functions
function SWEP:Initialize() self:SharedInitialize() end

function SWEP:OnRemove() if IsValid(self.WrenchEntity) then self.WrenchEntity:Remove() end end

--[[function SWEP:PostDrawViewModel(...) move_view_model(...) end
function SWEP:PreDrawViewModel(...) move_view_model(...) end]]