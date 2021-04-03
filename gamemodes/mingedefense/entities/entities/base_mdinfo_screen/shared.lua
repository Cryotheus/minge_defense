--part of entity structure
ENT.Base = "base_anim"
ENT.Type = "anim" --we can't use point entities because they don't ever run ENT:Draw

--custom to entity
ENT.IsMDScreen = true
ENT.PanelHeight = 540
ENT.PanelScale = 0.2
ENT.PanelWidth = 960

function ENT:DoOffsets() self:SetPanelOffsetCentered(self.PanelWidth, self.PanelHeight, self.PanelScale) end

function ENT:Initialize()
	if CLIENT then self:CreatePanel() end
	
	self:DoOffsets()
end

function ENT:SetPanelOffset(off_x, off_y, width, height, scale)
	local world_off_x = off_x * scale
	local world_off_y = off_y * -scale
	
	self.WorldOffsetX = world_off_x
	self.WorldOffsetY = world_off_y
	
	self:SetCalculatedBounds(world_off_x, world_off_y, width, height, scale)
end

function ENT:SetPanelOffsetCentered(width, height, scale) self:SetPanelOffset(width * -0.5, height * -0.5, width, height, scale) end