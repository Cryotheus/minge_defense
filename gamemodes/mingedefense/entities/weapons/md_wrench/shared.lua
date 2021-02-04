SWEP.AutoSwitchTo = true
SWEP.Slot = 2
SWEP.SlotPos = 0
SWEP.Spawnable = true
--SWEP.ViewModel = "models/minge_defense/wrench/cryotheum_reference.mdl" --"models/weapons/c_crowbar.mdl"
--SWEP.ViewModel = "models/weapons/c_crowbar.mdl"
SWEP.ViewModel = "models/minge_defense/weapons/c_wrench/c_wrench.mdl"
SWEP.Weight = 2
SWEP.WorldModel = "models/weapons/w_models/w_wrench.mdl"

local md_wrench_debug = CreateConVar("md_wrench_debug", "0", {FCVAR_DONTRECORD, FCVAR_REPLICATED, FCVAR_CHEAT}, "development", 0, 1)

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

function SWEP:SetupDataTables()
    self:NetworkVar("Float", 0, "NextIdleTime")
end

function SWEP:PrimaryAttack()
    local owner = self:GetOwner()
    local shootpos = owner:GetShootPos()
    local aimvector = owner:GetAimVector()
    local activity = ACT_VM_MISSCENTER
    local tracedata = {}
    tracedata.start = shootpos
    tracedata.endpos = shootpos + aimvector * 72
    tracedata.mins = Vector(-6, -6, -6)
    tracedata.maxs = Vector(6, 6, 6)
    tracedata.mask = MASK_SHOT_HULL
    tracedata.filter = owner
    owner:LagCompensation(true)
    local trace = util.TraceHull(tracedata)

    if IsFirstTimePredicted() and md_wrench_debug:GetBool() then
        local angle = (tracedata.endpos - tracedata.start):Angle()
        local color = Either(SERVER, Color(0, 0, 255, 25), Color(255, 0, 0, 25)) -- equivalent of C++'s condition ? truevar : falsevar
        local mins = tracedata.mins
        local maxs = tracedata.maxs + Vector((tracedata.endpos - tracedata.start):Length(), 0, 0)
        debugoverlay.BoxAngles(tracedata.start, mins, maxs, angle, 4, Color(0, 255, 0, 25))
        debugoverlay.BoxAngles(trace.HitPos, tracedata.mins, tracedata.maxs, trace.Normal:Angle(), 4, color)

        if IsValid(trace.Entity) then
            debugoverlay.BoxAngles(trace.Entity:GetPos(), trace.Entity:OBBMins(), trace.Entity:OBBMaxs(), trace.Entity:GetAngles(), 4, color)
        end
    end

    if trace.Hit then
        activity = ACT_VM_HITCENTER
        local sndeffect = "minge_defense/weapons/wrench/hit_world.wav"

        --[[|| util.GetSurfaceInfo(trace.SurfaceProps.Name).Surface == SURF_HITBOX]]
        if (trace.MatType == MAT_FLESH) then
            -- play a different sound when we hit flesh.
            sndeffect = "minge_defense/weapons/wrench/hit_flesh_" .. math.random(4) .. ".wav"
        end

        local hitentity = trace.Entity

        if IsValid(hitentity) and SERVER then
            local dmginfo = DamageInfo()
            dmginfo:SetInflictor(self)
            dmginfo:SetAttacker(owner)
            dmginfo:SetDamage(25)
            dmginfo:SetDamageType(DMG_CLUB)
            dmginfo:SetDamagePosition(trace.HitPos)
            dmginfo:SetDamageForce(trace.Normal * 5000) -- God knows how many newtons this is
            hitentity:TakeDamageInfo(dmginfo)
        end

        -- Fake the impact effect
        local impacttrace = util.TraceLine(tracedata)

        if impacttrace.Hit then
            owner:FireBullets({
                Src = trace.StartPos,
                Dir = trace.Normal,
                Tracer = 0,
                Force = 0,
                Damage = 0
            })
        end

        self:EmitSound(sndeffect)
    else
        self:EmitSound("minge_defense/weapons/wrench/swing.wav")
    end

    self:SendWeaponAnim(activity)
    self:SetNextPrimaryFire(CurTime() + 0.8)
    self:SetNextIdleTime(CurTime() + self:SequenceDuration(self:SelectWeightedSequence(activity)))
    owner:SetAnimation(PLAYER_ATTACK1)
    owner:LagCompensation(false)
end

function SWEP:Reload()
end

function SWEP:SecondaryAttack()
end

function SWEP:SharedInitialize()
    self:SetHoldType("melee")
end

function SWEP:Think()
    if self:GetNextIdleTime() ~= 0 and CurTime() > self:GetNextIdleTime() then
        self:SetNextIdleTime(0)
        self:SendWeaponAnim(ACT_VM_IDLE)
    end
end
