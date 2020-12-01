DEFINE_BASECLASS("player_default")

local PLAYER = {
	DisplayName = "Server Defender",
	JumpPower = 240,
	RunSpeed = 350,
	TeammateNoCollide = true,
	WalkSpeed = 200
}

function PLAYER:Loadout()
	local ply = self.Player
	
	ply:RemoveAllItems()
	
	ply:Give("gmod_tool")
	ply:Give("md_wrench")
	ply:Give("md_pda")
	ply:Give("weapon_physgun")
end

player_manager.RegisterClass("player_defender", PLAYER, "player_default")