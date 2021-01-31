ENT.Base = "base_point"
ENT.Type = "point"

--serverside only, only the above is needed shared
if CLIENT then return end

AccessorFunc(ENT, "QueueActive", "QueueActive", FORCE_BOOL)

--custom to entity
ENT.Keys = {}
ENT.QueuedSpawns = {}

--entity functions
function ENT:Initialize() self:SetQueueActive(false) end

--fetch mdgroupid
function ENT:KeyValue(key, value)
	self.Keys[key] = value
	
	if key == "mdgroupid" then
		if MingeDefenseMingeSpawns[value] then MingeDefenseMingeSpawns[value][self:EntIndex()] = self:GetPos()
		else MingeDefenseMingeSpawns[value] = {[self:EntIndex()] = self:GetPos()} end
	end
end

--spawn a minge from the queue
function ENT:PopQueue()
	local minge_class = table.remove(self.QueuedSpawns, 1)
	
	self:SpawnMinge(minge_class)
	
	if table.IsEmpty(self.QueuedSpawns) then self:SetQueueActive(false) end
end

--queue up minges to spawn
function ENT:QueueSpawn(minge)
	self:SetQueueActive(true)
	
	table.insert(self.QueuedSpawns, minge)
end

--spawn a minge
function ENT:SpawnMinge(minge_class)
	local minge = ents.Create(minge_class)
	
	minge:SetPos(self:GetPos())
	minge:Spawn()
	print("box", minge:GetCollisionBounds())
end

--check if we can spawn them, and if so, pop queue
function ENT:Think()
	if self.QueueActive then
		local trace = util.TraceHull({
			endpos = self:GetPos() + Vector(0, 0, 72),
			ignoreworld = true,
			mase = MASK_NPCSOLID,
			maxs = Vector(18, 18, 0),
			mins = Vector(-18, -18, 0),
			start = self:GetPos(),
		})
		
		if IsValid(trace.Entity) then return end
		
		self:PopQueue()
	end
end