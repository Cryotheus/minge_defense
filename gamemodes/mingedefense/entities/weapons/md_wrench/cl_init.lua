include("shared.lua")

SWEP.Author = "Cryotheum"
SWEP.Category = "Minge Defense"
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false
SWEP.Instructions = "Left click to swing wrench and heal buildings, right click to pick up buildings to relocate them."
SWEP.PrintName = "Wrench"
SWEP.Purpose = "Hit things."

function SWEP:Initialize() self:SharedInitialize() end