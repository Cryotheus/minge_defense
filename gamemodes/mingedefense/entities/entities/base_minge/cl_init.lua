include("shared.lua")

print("whoop")

--locals
local render_size = 1024
--local render_target = GetRenderTarget("minge_defense_icon_generator", render_size, render_size)
local render_name = "minge_defense_icon_generator_" .. 15
local render_target = GetRenderTargetEx(render_name, render_size, render_size, RT_SIZE_OFFSCREEN, MATERIAL_RT_DEPTH_SEPARATE, 256, 0, IMAGE_FORMAT_BGRA8888)
local test_mat = CreateMaterial(render_name, "UnlitGeneric", {
	["$basetexture"] = "models/weapons/v_toolgun/screen_bg",
	["$translucent"] = 1,
	["$vertexcolor"] = 1
})

--part of entity structure
ENT.Category = "Minge Defense"
ENT.PrintName = "Minge Base" --required with this gamemode!

--custom to entity
ENT.ShirtVector = Vector(1, 1, 1)
ENT.WeaponSkin = 1

--does not exist after initialization
ENT.IconCamera = {
	AutoLighting = {
		Default = {1, 1, 1},
		Position = vector_origin,
		--[[
		Sides = {
			{1, 1, 1},
			{1, 1, 1},
			{1, 1, 1},
			{1, 1, 1},
			{1, 1, 1},
			{1, 1, 1},
		} --]]
	},
	
	Far = 4096,
	FOV = 10,
	Near = 5,
	Position = Vector(500, 500, 500),
	TargetPosition = Vector(0, 0, 4)
}

--entity functions
function ENT:DrawIconModels()
	--does not exist after initialization
	--THIS FUNCTION IS NOT GIVEN AN ENTITY, IT IS GIVEN THE WHOLE ENT TABLE
	local color = self.ShirtVector
	local model = ClientsideModel("models/player/kleiner.mdl", RENDERGROUP_OTHER)
	
	function model:GetPlayerColor() return color end
	
	--model:SetIK(false)
	
	model:DrawModel()
	model:Remove()
end

function ENT:GetPlayerColor() return self.ShirtVector end

function ENT:Initialize()
	--these should never get called by the entity or with an entity
	--they're meant to be called externally without an entity
	self.DrawIconModels = nil
	self.IconCamera = nil
end

function ENT:OnKilled(damage_force)
	--make the minge drop the weapon when they die
	local weapon_entity = self.WeaponEntity
	
	if IsValid(weapon_entity) then weapon_entity:Drop(damage_force) end
end

function ENT:OnRemove()
	--remove client side model
	local weapon_entity = self.WeaponEntity
	
	if IsValid(weapon_entity) then weapon_entity:Remove() end
end

--net
net.Receive("minge_defense_minge_killed", function()
	local minge = net.ReadEntity()
	
	if IsValid(minge) then minge:OnKilled(net.ReadVector()) end
end)

--post
AddPrintNameToLanguage(ENT)