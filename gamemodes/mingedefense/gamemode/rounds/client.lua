GM.PlayersReady = {}
GM.ReadyTimer = false

--local variables
local ready = false

--net
net.Receive("minge_defense_ready", function()
	local game_mode = GAMEMODE
	local local_ply = LocalPlayer()
	
	if net.ReadBool() then
		for ply, ply_ready in pairs(game_mode.PlayersReady) do
			if not ply_ready then
				GAMEMODE.PlayersReady[ply] = true
				
				hook.Call("HUDTeamPanelUpdatePlayer", GAMEMODE, ply, true)
			end
		end
		
		hook.Call("HUDTeamPanelUpdateHeader", game_mode, true, ready_allowed, ready)
	else
		local ready_allowed = net.ReadBool()
		local ready_timer = net.ReadBool()
		local sync_players = net.ReadBool()
		
		if ready_timer then game_mode.TeamPanel.LabelTimer:SetActivity(true, net.ReadFloat())
		else game_mode.TeamPanel.LabelTimer:SetActivity(false) end
		
		if ready_allowed and sync_players then
			--TODO: don't use net.ReadTable
			local plys = net.ReadTable()
			local plys_old = table.Copy(game_mode.PlayersReady)
			game_mode.PlayersReady = plys
			
			for ply, ply_ready in pairs(plys) do if plys_old[ply] ~= ply_ready then hook.Call("HUDTeamPanelUpdatePlayer", game_mode, ply, ply_ready) end end
			
			ready = plys[LocalPlayer()] or false
		end
		
		hook.Call("HUDTeamPanelUpdateHeader", game_mode, false, ready_allowed, ready)
	end
end)