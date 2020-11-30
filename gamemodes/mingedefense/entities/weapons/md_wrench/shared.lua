SWEP.AutoSwitchTo = true
SWEP.Slot = 2
SWEP.SlotPos = 0
SWEP.Spawnable = true
SWEP.ViewModel = "models/player/items/cyoa_pda/cyoa_pda.mdl"
SWEP.ViewModelFOV = 70
SWEP.Weight = 2
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

function SWEP:PrimaryAttack() end
function SWEP:Reload() end
function SWEP:SecondaryAttack() end

function SWEP:SharedInitialize()
	--more here?
	self:SetHoldType("melee")
end