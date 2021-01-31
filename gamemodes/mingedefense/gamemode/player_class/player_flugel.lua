DEFINE_BASECLASS("player_defender")

local PLAYER = {
	DisplayName = "Server Defender",
	JumpPower = 240,
	MaxHealth = 400,
	RunSpeed = 450,
	StartArmor = 50,
	StartHealth = 400,
	TeammateNoCollide = true,
	WalkSpeed = 220
}

AccessorFunc(PLAYER, "FlugelHalo", "FlugelHalo")

--unfortunately I have been unable to successfuly split the realms into their own lua scripts for player classes
--at least, not without crashing the game
if SERVER then
	local function remove_halo(self)
		local flugel_halo = self:GetFlugelHalo()
		
		if IsValid(flugel_halo) then flugel_halo:Remove() end
		
		self:SetFlugelHalo(nil)
	end
	
	function PLAYER:Death() remove_halo(self) end
	
	function PLAYER:SetModel()
		BaseClass.SetModel(self)
		
		local flugel_halo = ents.Create("mdply_flugel_halo")
		
		flugel_halo:SetFlugel(self.Player)
		flugel_halo:Spawn()
		
		self:SetFlugelHalo(flugel_halo)
	end
end

player_manager.RegisterClass("player_flugel", PLAYER, "player_defender")