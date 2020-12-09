include("shared.lua")

SWEP.Author = "Cryotheum"
SWEP.Category = "Minge Defense"
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false
SWEP.Instructions = "Left click to interact with the PDA, right click to select entities."
SWEP.PrintName = "Minge Defense PDA"
SWEP.Purpose = "Personal Digital Assistant for Minge Defense."

--custom to weapon
SWEP.ActivatedTime = nil
SWEP.DeactivatedTime = nil
SWEP.Menu = nil

--swep functions
function SWEP:Deploy() self:SetSkin(1) end

function SWEP:Holster()
	if IsValid(self.Menu) then self.Menu:Remove() end
	
	self.ActivatedTime = nil
	self.DeactivatedTime = nil
	
	hook.Remove("PostDrawHUD", "minge_defense_pda")
end

function SWEP:Initialize()
	self:SharedInitialize()
	self:SetSkin(1)
end

function SWEP:PostDrawViewModel(entity, weapon, ply)
	--0.00572916666 is scaled to 11 / ScrW()
	--0.00590277777 is scaled to 6.375 / ScrH()
	--so the scale should be math.min(11 / ScrW(), 6.375 / ScrH())
	
	if IsValid(self.Menu) and self.ScreenPos then
		cam.Start3D2D(self.ScreenPos, self.ScreenAngle, math.min(11 / ScrW(), 6.375 / ScrH()))
			self.Menu:PaintAt(100, 100)
		cam.End3D2D()
	end
end

function SWEP:PreDrawViewModel(entity, weapon, ply)
	local activated_time = self.ActivatedTime
	local cur_time = CurTime()
	local deactivated_time = self.DeactivatedTime
	local swep = self
	
	local eye_ang = ply:EyeAngles()
	local eye_pos = ply:EyePos()
	
	local activated_pos, activated_angles = LocalToWorld(Vector(21, 1.4, -9), Angle(-20, 180, 90), eye_pos, eye_ang)
	local deactivated_pos, deactivated_angles = LocalToWorld(Vector(18, -10, -10), Angle(-20, 160, 90), eye_pos, eye_ang)
	local deactivated_pos_sway, deactivated_angles_sway = deactivated_pos + entity:GetPos() - eye_pos, deactivated_angles + entity:GetAngles() - eye_ang
	
	if activated_time then
		--behaviour when activating and active
		local activated_time_diff = cur_time - activated_time
		
		if activated_time_diff < 0.25 then
			--animating
			local fraction = activated_time_diff / 0.25
			
			entity:SetAngles(LerpAngle(fraction, deactivated_angles_sway, activated_angles))
			entity:SetPos(LerpVector(fraction, deactivated_pos_sway, activated_pos))
			entity:SetSkin(0)
		elseif IsValid(swep.Menu) then
			--menu is active
			local frame = swep.Menu
			
			entity:SetAngles(activated_angles)
			entity:SetPos(activated_pos)
			entity:SetSkin(2)
			--x / 1920  = 0.0057
			self.ScreenPos, self.ScreenAngle = LocalToWorld(Vector(3.9, 4, 3.6), Angle(90, 0, 0), activated_pos, activated_angles)
		else
			--finished animating, activate menu
			local frame = vgui.Create("DFrame", GetHUDPanel(), "MingeDefensePDA")
			swep.Menu = frame
			
			frame:SetDraggable(false)
			frame:SetPos(100, 100)
			frame:SetPaintedManually(true)
			frame:SetSize(ScrW() - 500, ScrH() - 500)
			frame:SetTitle("Minge Defense PDA")
			
			--make sure they can deactivate the pda
			function frame:OnRemove()
				swep.ActivatedTime = nil
				swep.DeactivatedTime = CurTime()
				swep.Menu = nil
				
				hook.Remove("PostDrawHUD", "minge_defense_pda")
			end
			
			local form = vgui.Create("DForm", frame)
			
			form:Dock(FILL)
			form:SetName("Cool PDA Test Initiative #040")
			
			form:Button("This is a button", "say")
			form:Button("This is also a button", "say")
			form:CheckBox("I think this is pretty cool", "say")
			form:CheckBox("Even if we are rendering the panel twice", "say")
			form:CheckBox("It's a cool effect", "say")
			form:ControlHelp("This is the PDA that will be used to buy stuff in my new gamemode: Minge Defense")
			form:Help("You can buy upgrades, weapons, and towers here.")
			form:NumSlider("The copy of the GUI updates live on the PDA as it is a re-render.", "say", 0, 4, 1)
			form:TextEntry("I'm real excitied to kill some minges, how about you?", "say")
			
			--finally show the frame
			frame:MakePopup()
			
			--render the frame because we do it manually
			hook.Add("PostDrawHUD", "minge_defense_pda", function() frame:PaintManual() end)
			
			entity:SetAngles(activated_angles)
			entity:SetPos(activated_pos)
			entity:SetSkin(2)
		end
	elseif deactivated_time then
		--behaviour when deactivating
		local deactivated_time_diff = cur_time - deactivated_time
		
		if deactivated_time_diff < 0.25 then
			local fraction = deactivated_time_diff / 0.25
			
			entity:SetAngles(LerpAngle(fraction, activated_angles, deactivated_angles_sway))
			entity:SetPos(LerpVector(fraction, activated_pos, deactivated_pos_sway))
		else
			self.DeactivatedTime = nil
			
			entity:SetAngles(deactivated_angles_sway)
			entity:SetPos(deactivated_pos_sway)
		end
		
		entity:SetSkin(1)
	else
		--behaviour when deactivated
		entity:SetAngles(deactivated_angles_sway)
		entity:SetPos(deactivated_pos_sway)
		entity:SetSkin(1)
	end
end

function SWEP:PrimaryAttack()
	if self.ActivatedTime or self.DeactivatedTime then self:SetNextPrimaryFire(0.1)
	else
		local cur_time = CurTime()
		
		self.ActivatedTime = cur_time
		
		self:SetNextPrimaryFire(cur_time + 0.5)
	end
end