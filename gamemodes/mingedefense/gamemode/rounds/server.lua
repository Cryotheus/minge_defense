util.AddNetworkString("minge_defense_ready")
util.AddNetworkString("minge_defense_timer")
util.AddNetworkString("minge_defense_wave_data")

--local variables
local current_difficulty
local current_wave
local current_wave_data
local current_wave_table
local map = game.GetMap()
local ready_allowed = false
local ready_cooldown = 1
local ready_cooldowns = false
local ready_players = {}
local ready_timer = false
local round_table

local ready_players_check = {}
local ready_players_changed = false
local ready_players_changed_count = 0

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

--local function change_ready_status(ply, ready, punish)
local function change_ready_status(ply, ready, punish)
	if ready_players_check[ply] then return false end
	
	ready_players[ply] = ready or nil
	ready_players_check[ply] = true
	ready_players_changed_count = ready_players_changed_count + 1
	
	if punish then
		if ready_cooldowns then ready_cooldowns[ply] = CurTime() + ready_cooldown
		else ready_cooldowns = {[ply] = CurTime() + ready_cooldown} end
	end
	
	if ready_players_changed then table.insert(ready_players_changed, ply)
	else ready_players_changed = {ply} end
	
	return true
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

local function ready_player(ply, arguments) 
	if not ready_allowed then return GAMEMODE:LanguageSend(ply, HUD_PRINTCONSOLE, "mingedefense.message.ready.disabled") end
	if not IsValid(ply) then return GAMEMODE:LanguageSend(ply, HUD_PRINTCONSOLE, "mingedefense.message.ready.invalid") end
	if ready_cooldown and ready_cooldowns and ready_cooldowns[ply] then return GAMEMODE:LanguageSendFormat(ply, HUD_PRINTCONSOLE, "mingedefense.message.ready.wait", {delay = ready_cooldowns[ply] - CurTime()}) end
	
	local argument = arguments and arguments[1]
	local ready = ready_players[ply]
	local state
	
	if argument then state = tobool(argument) end
	if state == nil then state = not ready end
	
	if state ~= ready then
		GAMEMODE:LanguageSend(ply, HUD_PRINTCONSOLE, state and "mingedefense.message.ready" or "mingedefense.message.unready") 
		hook.Call("RoundPlayerReady", GAMEMODE, ply, state)
	else GAMEMODE:LanguageSend(ply, HUD_PRINTCONSOLE, state and "mingedefense.message.ready.unchanged" or "mingedefense.message.unready.unchanged") end
end

local function unready_all()
	ready_players_changed = {}
	ready_players_changed_count = 0
	
	for ply in pairs(ready_players) do
		ready_players[ply] = nil
		ready_players_check[ply] = true
		ready_players_changed_count = ready_players_changed_count + 1
		
		table.insert(ready_players_changed, ply)
	end
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
		
		print("RoundGetWaveTable", hook.Call("RoundGetWaveTable", self, current_wave, true))
		
		--round_table
	else
		--there are no configs, this is likely because a map creator is making this map
		
		print("NO CONFIGS?!?!")
	end
end

function GM:RoundLoadConfiguration(difficulty)
	round_table = nil
	
	print("configuration load!", difficulty)
	
	for attempt, fetching_function in ipairs(fetching_functions) do
		print("Attempting to fetch the wave table, attempt #" .. attempt .. ".")
		
		round_table = fetching_functions[attempt](difficulty, wave)
		
		if round_table then return round_table end
	end
end

function GM:RoundPlayerDisconnect(ply) change_ready_status(ply, false) end

--TODO: add a count down from when a player marks themself ready to when 
function GM:RoundPlayerReady(ready_ply, ready, force)
	if not ready_allowed then return nil end
	
	local ply_count = 0
	local ready_count = 0
	
	change_ready_status(ready_ply, ready, not force)
	
	for index, ply in ipairs(player.GetAll()) do
		if ready_players[ply] then ready_count = ready_count + 1 end
		
		ply_count = ply_count + 1
	end
	
	if ready_count >= ply_count then hook.Call("RoundReady", self, true)
	elseif ready_count > 0 then --TODO: make a convar for this, like what percent of players have to be ready before we can start the timer?
		if ready_timer then
			--decrease time on timer
			
		else
			--start timer
			
			hook.Call("RoundSetTimer", self, true, CurTime() + 90)
			
			ready_timer = true
		end
	else
		if ready_timer then
			hook.Call("RoundSetTimer", self, false)
		end
	end
	
	return ready_count
end

function GM:RoundReady(forced)
	ready_allowed = false
	ready_timer = true
	
	if forced then hook.Call("RoundSetTimer", self, true, CurTime() + 10) end
	
	hook.Call("WaveStart", self, current_wave, current_wave_table, unpack(current_wave_data))
	unready_all()
end

function GM:RoundSetTimer(enabled, hit_time)
	--more here!
	ready_timer = enabled or false
end

function GM:RoundTick()
	if ready_players_changed then
		net.Start("minge_defense_ready")
		
		for index, ply in ipairs(ready_players_changed) do
			net.WriteUInt(index, 8)
			net.WriteBool(ready_players[ply] or false)
			net.WriteBool(index == ready_players_changed_count)
		end
		
		ready_players_check = {}
		ready_players_changed = false
		ready_players_changed_count = 0
		
		net.Broadcast()
	end
	
	if ready_cooldowns then
		for ply, expires in pairs(ready_cooldowns) do if CurTime() > expires then table.insert(removals, ply) end end
		
		ready_cooldowns = false
	end
end

function GM:ShowSpare2(ply) ready_player(ply) end

--commands
--TODO: figure out a way to localize this
concommand.Add("md_ready", function(ply, command, arguments, arguments_string) ready_player(ply, arguments) end)

--hooks
hook.Add("Think", "minge_defense_round", function()

end)

hook.Add("WaveEnd", "minge_defense_round", function() ready_allowed = true end)