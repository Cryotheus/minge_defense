GM.PlayersReady = {}
GM.ReadyTimer = false

--local variables
local ready = false

--net
net.Receive("minge_defense_ready", function()
	local game_mode = GAMEMODE
	local local_ply = LocalPlayer()
	local ready_players = game_mode.PlayersReady
	
	--debug
	--game_mode.TeamPanel.LabelTimer:SetActivity(true, net.ReadFloat())
	local itt = 0
	
	repeat
		if itt > 255 then ErrorNoHaltWithStack("Reached maximum itteraions in ready players networked data!") break end
		
		itt = itt + 1
		local ply = Entity(net.ReadUInt(8))
		local ply_ready = net.ReadBool()
		
		--might be a bit confusing, but the key is calculated before the value
		ready_players[ply] = ply_ready or nil
		
		hook.Call("HUDTeamPanelUpdatePlayer", game_mode, ply, ply_ready)
	until net.ReadBool()
	
	ready = ready_players[local_ply] or false
end)

--[[
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
]]

net.Receive("minge_defense_timer", function()
	if net.ReadBool() then GAMEMODE.TeamPanel.LabelTimer:SetActivity(true, net.ReadFloat())
	else GAMEMODE.TeamPanel.LabelTimer:SetActivity(false) end
end)