include("shared.lua")

--not yet functional, ENT:Draw doesnt get called, probably because its a point entity lol
--part of entity structure
ENT.PrintName = "Minge Defense Wave Info Screen"
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

--custom to entity
ENT.PanelScale = 0.2

--locals
local panel_3d2d_local_angle = Angle(0, 90, 90)

--entity functions
function ENT:CreatePanel()
	local frame = vgui.Create("DFrame")
	local frame_h, frame_w = 540, 960
	
	frame:SetDraggable(false)
	frame:SetPaintedManually(true)
	frame:SetPos(0, 0)
	frame:SetSize(frame_w, frame_h)
	frame:SetTitle("Minge Defense Info - Base Screen")
	
	self:SetPanelOffset(frame_w * -0.5, frame_h * -0.5, frame_w, frame_h, self.PanelScale)
	
	self.Panel = frame
end

function ENT:DrawTranslucent()
	if IsValid(self.Panel) then
		cam.Start3D2D(self:LocalToWorld(Vector(1, self.WorldOffsetX, self.WorldOffsetY)), self:LocalToWorldAngles(panel_3d2d_local_angle), self.PanelScale)
		self.Panel:PaintManual()
		cam.End3D2D()
	end
end

function ENT:Initialize() self:CreatePanel() end

function ENT:OnReloaded()
	if IsValid(self.Panel) then self.Panel:Remove() end
	
	self:CreatePanel()
end

function ENT:OnRemove()
	local panel = self.Panel
	
	--zero timer because of full updates, removes the panel if the entity was removed for some reason
	timer.Simple(0, function() if not IsValid(self) and IsValid(panel) then panel:Remove() end end)
end

function ENT:SetPanelOffset(off_x, off_y, width, height, scale)
	local world_off_x = off_x * scale
	local world_off_y = off_y * -scale
	
	self.WorldOffsetX = world_off_x
	self.WorldOffsetY = world_off_y
	
	self:SetCalculatedRenderBounds(world_off_x, world_off_y, width, height, scale)
end

function ENT:SetPanelOffsetCentered(width, height, scale) self:SetPanelOffset(width * -0.5, height * -0.5, width, height, scale) end

function ENT:SetCalculatedRenderBounds(off_x, off_y, width, height, scale)
	local world_off_vector = Vector(0, off_x, -off_y)
	
	self:SetRenderBounds(world_off_vector, world_off_vector + Vector(1, width * scale, height * scale))
end

--hooks
hook.Add("LocalPlayerInitialized", "minge_defense_screen", function(local_ply)
	hook.Add("KeyPress", "minge_defense_screen", function(ply, key)
		if ply == local_ply and key == IN_USE then
			print("in use!")
		end
	end)
end)

hook.Add("OnReloaded", "minge_defense_screen", function() hook.GetTable().LocalPlayerInitialized.minge_defense_screen(LocalPlayer()) end)