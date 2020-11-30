SWEP.AutoSwitchTo = false
SWEP.Slot = 3
SWEP.SlotPos = 0
SWEP.Spawnable = true
SWEP.ViewModel = "models/player/items/cyoa_pda/cyoa_pda.mdl"
SWEP.ViewModelFOV = 70
SWEP.WorldModel = "models/player/items/cyoa_pda/cyoa_pda.mdl"

SWEP.Primary = {
	Ammo = "none",
	Automatic = false,
	ClipSize = -1,
	DefaultClip = -1
}

SWEP.Secondary = {
	Ammo = "none",
	Automatic = false,
	ClipSize = -1,
	DefaultClip = -1
}

--swep functions
function SWEP:Reload() end
function SWEP:SecondaryAttack() self:SetNextSecondaryFire(0) end

function SWEP:SharedInitialize()
	--more here?
	self:SetHoldType("slam")
end