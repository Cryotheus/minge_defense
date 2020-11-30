AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function SWEP:Initialize() self:SharedInitialize() end
function SWEP:PrimaryAttack() self:SetNextPrimaryFire(0) end
function SWEP:ShouldDropOnDie() return false end