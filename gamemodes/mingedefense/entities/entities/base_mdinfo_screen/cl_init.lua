include("shared.lua")

--not yet functional, ENT:Draw doesnt get called, probably because its a point entity lol
--part of entity structure
ENT.PrintName = "Minge Defense Wave Info Screen"
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

--locals
local panel_3d2d_local_angle = Angle(0, 90, 90)

--entity functions
function ENT:CreatePanel()
	local frame = vgui.Create("DFrame")
	local frame_w, frame_h = self.PanelWidth, self.PanelHeight
	
	frame:SetDraggable(false)
	frame:SetPaintedManually(true)
	frame:SetPos(0, 0)
	frame:SetSize(frame_w, frame_h)
	frame:SetTitle("Minge Defense Info - Base Screen")
	
	self.Panel = frame
end

function ENT:DebugShowPsychokineticBounds() debugoverlay.BoxAngles(self:GetPos(), self.PsychokineticBounds.Mins, self.PsychokineticBounds.Maxs, self:GetAngles(), 1, Color(255, 0, 255, 128)) end

function ENT:DrawTranslucent()
	if IsValid(self.Panel) then
		cam.Start3D2D(self:LocalToWorld(Vector(1, self.WorldOffsetX, self.WorldOffsetY)), self:LocalToWorldAngles(panel_3d2d_local_angle), self.PanelScale)
		self.Panel:PaintManual()
		cam.End3D2D()
	end
end

function ENT:OnReloaded()
	if IsValid(self.Panel) then self.Panel:Remove() end
	
	self:CreatePanel()
end

function ENT:OnRemove()
	local panel = self.Panel
	
	--zero timer because of full updates, removes the panel if the entity was removed for some reason
	timer.Simple(0, function()
		if not IsValid(self) and IsValid(panel) then
			GAMEMODE.PsychokineticEntities[self] = nil
			
			panel:Remove()
		end
	end)
end

--this is a use function that works from any distance, and is client sided only
--this can be overriden on ANY entity
--function ENT:PsychokineticUse(start, hit, normal, ray) self:DebugShowPsychokineticBounds() return true end

function ENT:SetCalculatedBounds(off_x, off_y, width, height, scale)
	local world_off_vector = Vector(0, off_x, -off_y)
	local world_open_bounds = world_off_vector + Vector(1, width * scale, height * scale)
	
	self:SetRenderBounds(world_off_vector, world_open_bounds)
	
	if self.PsychokineticUse then
		local bounds = {
			Maxs = world_open_bounds,
			Mins = world_off_vector
		}
		
		GAMEMODE.PsychokineticEntities[self] = bounds
		self.PsychokineticBounds = bounds
	end
end