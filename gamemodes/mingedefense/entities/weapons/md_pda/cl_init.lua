include("shared.lua")

SWEP.Author = "Cryotheum"
SWEP.Category = "Minge Defense"
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false
SWEP.Instructions = language.GetPhrase("#mingedefense.weapons.pda.instructions")
SWEP.PrintName = language.GetPhrase("#mingedefense.weapons.pda")
SWEP.Purpose = language.GetPhrase("#mingedefense.weapons.pda.purpose")

--local variables
local blur = true

----calculated variables
	local frame_margin = 100
	local frame_margin_double = frame_margin * 2
	local frame_h
	local frame_w

--local funcitons
local function calc_vars(scr_w, scr_h)
	frame_h = scr_h - frame_margin_double
	frame_w = scr_w - frame_margin_double
end

--swep functions
function SWEP:Deploy() self:SetSkin(1) end

function SWEP:Holster()
	if IsValid(self.Canvas) then self.Canvas:Remove() end
	if IsValid(self.Menu) then self.Menu:Remove() end
	
	self.ActivatedTime = nil
	self.DeactivatedTime = nil
	
	hook.Remove("PostRenderVGUI", "minge_defense_pda")
end

function SWEP:Initialize()
	self:SharedInitialize()
	self:SetSkin(1)
end

function SWEP:PostDrawViewModel(entity, weapon, ply)
	--0.00572916666 is scaled to 11 / ScrW()
	--0.00590277777 is scaled to 6.375 / ScrH()
	--so the scale should be math.min(11 / ScrW(), 6.375 / ScrH())
	local menu_panel = self.Menu
	
	if IsValid(menu_panel) and self.ScreenPos then
		local width, height = 11 / ScrW(), 6.375 / ScrH()
		local scale = math.min(height, width)
		
		cam.Start3D2D(self.ScreenPos, self.ScreenAngle, scale)
			blur = false
			
			menu_panel:PaintAt(frame_margin + (width - scale) * 0.5, frame_margin + (height - scale) * 0.5)
			
			blur = true
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
		else --finished animating, activate menu
			local canvas
			local frame
			
			do --canvas, just for rendering the frame properly
				canvas = vgui.Create("DPanel", GetHUDPanel())
				
				canvas:Dock(FILL)
				
				function canvas:Paint(width, height) frame:PaintManual() end
			end
			
			do --frame
				frame = vgui.Create("DFrame", GetHUDPanel(), "MingeDefensePDA")
				frame.ShouldBlur = true
				
				frame:SetBackgroundBlur(true)
				frame:SetDraggable(false)
				frame:SetPos(frame_margin, frame_margin)
				frame:SetPaintedManually(true)
				frame:SetSize(frame_w, frame_h)
				frame:SetTitle("#mingedefense.pda.title")
				
				--make sure they can deactivate the pda
				function frame:OnRemove()
					swep.ActivatedTime = nil
					swep.DeactivatedTime = CurTime()
					swep.Menu = nil
					
					canvas:Remove()
					
					hook.Remove("PostRenderVGUI", "minge_defense_pda")
				end
				
				function frame:Paint(width, height)
					local create_time = self.m_fCreateTime
					
					if blur then Derma_DrawBackgroundBlur(self, create_time - (SysTime() - create_time) * 6) end
					
					surface.SetDrawColor(0, 0, 0, 128)
					surface.DrawRect(0, 0, width, height)
				end
				
				do --button
					local button = vgui.Create("DButton", frame)
					
					button:Dock(LEFT)
					button:DockMargin(4, frame_h * 0.1, 0, frame_h * 0.7)
					button:SetText("#mingedefense.pda.button")
					button:SetWidth(frame_w * 0.25)
					
					function button:Paint(width, height)
						surface.SetDrawColor(0, 0, 0, 128)
						surface.DrawRect(0, 0, width, height)
					end
				end
				
				--finally show the frame
				frame:MakePopup()
			end
			
			swep.Menu = frame
			swep.Canvas = canvas
			
			--render the frame because we do it manually
			--hook.Add("PostRenderVGUI", "minge_defense_pda", function() frame:PaintManual() end)
			
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

--post function setup
calc_vars(ScrW(), ScrH())

--hooks
hook.Add("OnScreenSizeChanged", "minge_defense_pda", function() calc_vars(ScrW(), ScrH()) end)