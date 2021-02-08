SWEP.AutoSwitchTo = true
SWEP.Slot = 2
SWEP.SlotPos = 0
SWEP.Spawnable = true
SWEP.ViewModel = "models/minge_defense/weapons/c_wrench/c_wrench.mdl"
SWEP.Weight = 2
SWEP.WorldModel = "models/weapons/w_models/w_wrench.mdl"

SWEP.Primary = {
	Ammo = "none",
	Automatic = true,
	ClipSize = -1,
	DefaultClip = -1
}

SWEP.Secondary = {
	Ammo = "none",
	Automatic = false,
	ClipSize = -1,
	DefaultClip = -1
}

--local vars
local hull_maxs = Vector(6, 6, 6)
local hull_mins = -hull_maxs
local md_wrench_debug = CreateConVar("md_wrench_debug", "1", {FCVAR_DONTRECORD, FCVAR_REPLICATED, FCVAR_CHEAT}, "Debug the wrench hit scan.", 0, 1)

--swep functions
function SWEP:Initialize() self:SetHoldType("melee") end

function SWEP:PrimaryAttack()
	local owner = self:GetOwner()
	
	local activity = ACT_VM_MISSCENTER
	local aim_vector = owner:GetAimVector()
	local shoot_pos = owner:GetShootPos()
	local trace_data = {
		endpos = shoot_pos + aim_vector * 72,
		filter = owner,
		mask = MASK_SHOT_HULL,
		maxs = hull_maxs,
		mins = hull_mins,
		start = shoot_pos
	}
	
	owner:LagCompensation(true)
	
	local trace = util.TraceHull(trace_data)
	
	---[[
	if IsFirstTimePredicted() and md_wrench_debug:GetBool() then
		local angle = (trace_data.endpos - shoot_pos):Angle()
		local color = SERVER and Color(0, 0, 255, 25) or Color(255, 0, 0, 25) -- equivalent of C++'s condition ? truevar : falsevar --just use and or, Either is not necessary
		local mins = trace_data.mins
		local maxs = trace_data.maxs + Vector((trace_data.endpos - shoot_pos):Length(), 0, 0)
		
		debugoverlay.BoxAngles(shoot_pos, hull_mins, hull_maxs, angle, 4, Color(0, 255, 0, 25))
		debugoverlay.BoxAngles(trace.HitPos, hull_mins, hull_maxs, trace.Normal:Angle(), 4, color)

		if IsValid(trace.Entity) then
			--ahhhhhhhhhhhhhhhhhhh
			debugoverlay.BoxAngles(trace.Entity:GetPos(), trace.Entity:OBBMins(), trace.Entity:OBBMaxs(), trace.Entity:GetAngles(), 4, color)
		end
	end --]]

	if trace.Hit then
		activity = ACT_VM_HITCENTER
		local sound_effect = "minge_defense/weapons/wrench/hit_world.wav"

		--or util.GetSurfaceInfo(trace.SurfaceProps.Name).Surface == SURF_HITBOX
		if trace.MatType == MAT_FLESH then
			--play a different sound when we hit flesh.
			sound_effect = "minge_defense/weapons/wrench/hit_flesh_" .. math.random(4) .. ".wav"
		end

		local hit_entity = trace.Entity

		if IsValid(hit_entity) and SERVER then
			local damage_info = DamageInfo()
			
			damage_info:SetInflictor(self)
			damage_info:SetAttacker(owner)
			damage_info:SetDamage(25)
			damage_info:SetDamageType(DMG_CLUB)
			damage_info:SetDamagePosition(trace.HitPos)
			damage_info:SetDamageForce(trace.Normal * 5000) -- God knows how many newtons this is --a lot, like, enough to smash my canteen
			
			hit_entity:TakeDamageInfo(damage_info)
		end

		-- Fake the impact effect
		local impact_trace = util.TraceLine(trace_data)

		if impact_trace.Hit then
			owner:FireBullets({
				Src = trace.StartPos,
				Dir = trace.Normal,
				Tracer = 0,
				Force = 0,
				Damage = 0
			})
		end

		self:EmitSound(sound_effect)
	else self:EmitSound("minge_defense/weapons/wrench/swing.wav") end

	self:SendWeaponAnim(activity)
	self:SetNextPrimaryFire(CurTime() + 0.8)
	self:SetNextIdleTime(CurTime() + self:SequenceDuration(self:SelectWeightedSequence(activity)))
	
	owner:LagCompensation(false)
	owner:SetAnimation(PLAYER_ATTACK1)
end

function SWEP:Reload() end
function SWEP:SecondaryAttack() end
function SWEP:SetupDataTables() self:NetworkVar("Float", 0, "NextIdleTime") end

function SWEP:Think()
	if self:GetNextIdleTime() ~= 0 and CurTime() > self:GetNextIdleTime() then
		self:SetNextIdleTime(0)
		self:SendWeaponAnim(ACT_VM_IDLE)
	end
end