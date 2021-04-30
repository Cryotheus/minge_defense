GM.PlayersReady = {}
GM.ReadyTimer = false

--local variables
local ready = false
local ready_allowed = false
local round_preparation = false
local wave_active = false

--local functions
local function decide_text()
	local text = "NO TEXT"
	
	if wave_active then text = string.upper(GetHostName())
	elseif not ready_allowed then language.GetPhrase("mingedefense.ui.team.header.inactive")
	elseif ready then text = language.GetPhrase("mingedefense.ui.team.header.ready")
	else
		local bind = input.LookupBinding("md_ready") or input.LookupBinding("gm_showspare2")
		
		if bind then text = GAMEMODE:LanguageFormat("mingedefense.ui.team.header.unready", {key = string.upper(bind)})
		else text = language.GetPhrase("mingedefense.ui.team.header.unbound") end
	end
	
	--print("\nText decided upon: " .. text)
	
	hook.Call("HUDTeamPanelSetHeaderText", GAMEMODE, "round", text)
end

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
		
		hook.Call("HUDTeamPanelUpdatePlayer", game_mode, local_ply, ply_ready)
	until net.ReadBool()
	
	ready = ready_players[local_ply] or false
	
	decide_text()
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

net.Receive("minge_defense_ready_capabilities", function()
	local old_wave_active = wave_active
	ready_allowed = net.ReadBool()
	round_preparation = net.ReadBool()
	wave_active = net.ReadBool()
	
	--print("\nwe got a minge_defense_ready_capabilities sync with:")
	--print("ready_allowed", ready_allowed)
	--print("round_preparation", round_preparation)
	--print("wave_active", wave_active)
	
	if old_wave_active ~= wave_active then hook.Call("HUDTeamPanelUpdateStatus", GAMEMODE, wave_active) end
	
	decide_text()
end)

net.Receive("minge_defense_ready_timer", function()
	local label = GAMEMODE.TeamPanel.LabelTimer
	
	--print("\nminge_defense_ready_timer sync!")
	
	if IsValid(label) then
		if net.ReadBool() then
			local cur_time = CurTime()
			local server_cur_time = net.ReadFloat()
			local timer_time = net.ReadFloat()
			
			if math.abs(server_cur_time - cur_time) > math.min(1, LocalPlayer():Ping()) then
				print("Large difference between server's and client's synced time!\nServer's report: " .. server_cur_time .. " versus client's report: " .. cur_time .. "\nThis will be compensated for.")
				
				label:SetActivity(true, timer_time + cur_time - server_cur_time)
			else label:SetActivity(true, timer_time) end
		else label:SetActivity(false) end
	else print("Tried to sync time without a label to display the time on!") end
end)