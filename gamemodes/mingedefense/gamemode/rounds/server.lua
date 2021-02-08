util.AddNetworkString("minge_defense_ready")
util.AddNetworkString("minge_defense_wave_data")

--local variables
local current_difficulty
local current_wave
local current_wave_data
local current_wave_table
local map = game.GetMap()
local network_ready_players = false
local ready_allowed = false
local ready_cooldown = true
local ready_cooldowns = {}
local ready_players = {}
local round_table

--local table constants
local fetching_functions = {
	function(difficulty) return include("minge_defense_maps/" .. map .. "/configs/" .. difficulty .. ".lua") end, --load the selected difficulty for the map
	
	--load the default difficulty for the map
	function(difficulty)
		local halt
		local round_table = include("minge_defense_maps/" .. map .. "/configs/normal.lua")
		
		if round_table and difficulty ~= "normal" then
			print("[Minge Defense] WARNING: The normal difficulty configuration has been loaded as the " .. difficulty .." difficulty configuration does not exist.")
			
			halt = true
		end
		
		return round_table, halt
	end,
}

--local functions
local function add_enemy(wave_group, enemy, count)
	--add an enemy to the wave group, given the wave group, enemy class name, and count
	if not wave_group then wave_group = {[enemy] = count}
	else wave_group[enemy] = (wave_group[enemy] or 0) + count end
	
	return wave_group
end

local function generate_wave_spawn_order(wave_table)
	--index it at a time, it will contain a table where each key is the enemy class and the value is the amount to spawn
	local wave_groups = {}
	
	--sorted table of the times order
	local wave_order = {}
	
	--keeps track of what times have been registered
	local wave_order_registry = {}
	
	--the magic
	for index, set in pairs(wave_table) do
		local count = set.count or 1
		local enemy = set.enemy or "minge_basic"
		local interval = set.interval
		local squad = set.squad
		local time = set.time or 0
		
		if interval then
			if squad then
				local count_remaining = count
				--local squad_over_flow = count % squad
				
				for increment = interval, math.ceil(count / squad) * interval, interval do
					local moment = time + increment - interval
					local size = math.min(count_remaining, squad)
					
					count_remaining = count_remaining - size --keep track of how many more we need to put in
					wave_groups[moment] = add_enemy(wave_groups[moment], enemy, size) --put it in the wave groups
					
					--put it in the wave order
					if not wave_order_registry[moment] then wave_order_registry[moment] = table.insert(wave_order, moment) end
				end
			else
				for itteration = 1, count do
					local moment = time + itteration * interval
					
					--put it in the wave groups
					wave_groups[moment] = add_enemy(wave_groups[moment], enemy, 1)
					
					--put it in the wave order
					if not wave_order_registry[moment] then wave_order_registry[moment] = table.insert(wave_order, moment) end
				end
			end
		elseif squad then
			--
			--
		end
	end
	
	return wave_groups, wave_order
end

--[[local function process_wave_table(wave_table)
	local meta = wave_table.meta
	
	if not meta.spawn_groups then meta.spawn_groups = {"generic"} end
	
	return wave_table, generate_wave_spawn_order(wave_table)
end]]

--gamemode functions
function GM:RoundCalculateWave(wave, round_table)
	local mode = round_table.mode
	local mode_load = round_table.load
	
	if mode == "content" then
		local wave_table = mode_load and include("minge_defense_maps/" .. map .. "/configs/" .. difficulty .. "/" .. wave .. ".lua") or round_table.waves[wave]
		
		return wave_table, generate_wave_spawn_order(wave_table)
	elseif mode == "generator" then print("[Minge Defense] WARNING: Generator configurations are not yet supported!") end
end

function GM:RoundGetWaveTable(wave, force)
	if force or wave ~= current_wave or not current_wave_table then
		--current_wave_data
		
		current_wave = wave
		current_wave_data = {hook.Call("RoundCalculateWave", self, wave, round_table)}
		current_wave_table = table.remove(current_wave_data, 1)
	end
	
	return current_wave_table, unpack(current_wave_data)
end

function GM:RoundInitialize(difficulty)
	current_difficulty = difficulty
	current_wave = 1
	local loaded_table, halt = hook.Call("RoundLoadConfiguration", self, difficulty)
	
	if halt then
		--try loading the normal difficulty
		print("[Minge Defense] Attempting to restart with the normal difficulty configuration...")
		
		return hook.Call("RoundInitialize", self, "normal")
	elseif loaded_table then
		--continue normally
		ready_allowed = true
		round_table = loaded_table
		
		hook.Call("RoundGetWaveTable", self, current_wave, true)
		
		--round_table
	else
		--there are no configs, this is likely because a map creator is making this map
		
	end
end

function GM:RoundLoadConfiguration(difficulty)
	round_table = nil
	
	for attempt, fetching_function in ipairs(fetching_functions) do
		print("Attempting to fetch the wave table, attempt #" .. attempt .. ".")
		
		round_table = fetching_functions[attempt](difficulty, wave)
		
		if round_table then return round_table end
	end
end

function GM:RoundPlayerDisconnect(ply)
	network_ready_players = true
	ready_players[ply] = nil
end

--TODO: add a count down from when a player marks themself ready to when 
function GM:RoundPlayerReady(ready_ply, ready)
	if not ready_allowed then return nil end
	
	network_ready_players = true
	ready_players[ready_ply] = state
	
	for index, ply in ipairs(player.GetAll()) do
		if ready_players[ply] then continue end
		
		return false
	end
	
	hook.Call("RoundReady", self)
	
	return true
end

function GM:RoundReady()
	ready_allowed = false
	ready_players = {}
	
	hook.Call("WaveStart", self, current_wave, current_wave_table, unpack(current_wave_data))
end

--commands
--TODO: figure out a way to localize this
concommand.Add("gm_showspare2", function(command, ply, arguments, arguments_string)
	if ready_allowed and IsValid(ply) and not (ready_cooldown and ready_cooldowns[ply]) then
		local argument = arguments[1]
		local state
		
		if argument then state = tobool(argument) end
		if state == nil then state = not ready_players[ply] end
		
		if state ~= ready then
			ply:PrintMessage(HUD_PRINTCONSOLE, state and "You are now ready." or "You are no longer ready.") 
			
			ready_cooldowns[ply] = true
			
			timer.Simple(1, function() if IsValid(ply) then ready_cooldowns[ply] = nil end end)
			hook.Call("RoundPlayerReady", GAMEMODE, ply, net.ReadBool())
		else ply:PrintMessage(HUD_PRINTCONSOLE, state and "You already marked yourself as ready, the state did not change." or "You already marked yourself as unready, the state did not change.") end
	else ply:PrintMessage(HUD_PRINTCONSOLE, "Please wait before updating your ready status.") end
end)

--hooks
hook.Add("Think", "minge_defense_round", function()
	if network_ready_players then
		net.Start("minge_defense_ready")
		net.WriteBool(ready_allowed)
	end
end)

hook.Add("WaveEnd", "minge_defense_round", function() ready_allowed = true end)