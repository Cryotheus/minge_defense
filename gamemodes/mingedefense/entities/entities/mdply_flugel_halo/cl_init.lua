include("shared.lua")

--locals
local attach_angles = Angle(90, 135, 0)
local attach_position = Vector(-3, 7, 0)
local flip_angle = Angle(180, 0, 0)
local local_ply = LocalPlayer()

--materials
local halo_material = Material("minge_defense/flugel/halo/halo.png")
local halo_material_bloodlust = Material("minge_defense/flugel/halo/bloodlust.png")
local halo_material_curiosity = Material("minge_defense/flugel/halo/curiosity.png")
local halo_material_faith = Material("minge_defense/flugel/halo/faith.png")

--local functions
local function draw_attribute(material)
	surface.SetMaterial(material)
	surface.DrawTexturedRect(-256, -256, 512, 512)
end

local function draw_halo(position, angles, size)
	cam.Start3D2D(position, angles, size)
		surface.SetDrawColor(255, 255, 255)
		
		draw_attribute(halo_material)
		draw_attribute(halo_material_bloodlust)
		draw_attribute(halo_material_curiosity)
		draw_attribute(halo_material_faith)
	cam.End3D2D()
end

local function draw_halo_double(position, angles, size)
	--draw a double sided halo
	--reminder: vector_origin is a global in gmod!
	draw_halo(position, angles, size)
	draw_halo(position, select(2, LocalToWorld(vector_origin, flip_angle, position, angles)), size)
end

local function entity_draw(self)
	--overrides DrawTranslucent when we have local player and the parent
	--the parent will be invalid when they are out of pvs
	if IsValid(self.Flugel) and (self.Flugel ~= local_ply or local_ply:ShouldDrawLocalPlayer()) then
		local real_time = RealTime()
		
		local translated_position, translated_angles = LocalToWorld(
			vector_origin,
			Angle(0, real_time * 20 % 360, 0),
			
			self:LocalToWorld(attach_position),
			self:LocalToWorldAngles(attach_angles)
		)
		
		draw_halo_double(translated_position, translated_angles, math.sin(real_time * 2) *  0.002 + 0.075)
	end
end

--entity functions
function ENT:Initialize() end

function ENT:DrawTranslucent()
	--we get the values we need before we start drawing the halo
	--we need the parent and the local player, so once we get them we can override this funciton with entity_draw
	local parent = self:GetParent()
	
	if not IsValid(local_ply) then local_ply = LocalPlayer() end
	
	if IsValid(local_ply) and IsValid(parent) then
		self.DrawTranslucent = entity_draw
		self.Flugel = parent
	end
end
