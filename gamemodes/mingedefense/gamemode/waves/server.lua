--this script handles the wave and game stages on the server
util.AddNetworkString("minge_defense_wave_update")

--holds tables by mdgroupid which contains a table of positions referenced by their entity index
MingeDefenseMingeSpawns = MingeDefenseMingeSpawns or {}

--locals
local spawn_cursors
local spawn_totals
local wave = 1
local wave_difficulty = "normal"
local wave_generator --function to generate default waves

--local tables
local fetching_functions = {
	function() if wave_generator then return wave_generator(wave) end end, --use the wave generator function
	function() return include("minge_defense_maps/" .. game.GetMap() .. "/configs/" .. wave_difficulty .. ".lua") end, --load the selected difficulty for the map
	function() return include("minge_defense_maps/" .. game.GetMap() .. "/configs/normal.lua") end, --load the default difficulty for the map
	function() return {} end --wow still no table
}

--temp locals
local test_wave_table = include("minge_defense_maps/" .. game.GetMap() .. "/configs/normal.lua")

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

local function process_wave_table(wave_table)
	local meta = wave_table.meta
	
	if not meta.spawn_groups then meta.spawn_groups = {"generic"} end
	
	return wave_table, generate_wave_spawn_order(wave_table)
end

--gamemode functions
function GM:WaveCalculateSpawns(spawn_group_id)
	spawn_cursors[spawn_group_id] = 1
	
	for entity_index, position in pairs(MingeDefenseMingeSpawns[spawn_group_id] or {}) do spawn_totals[spawn_group_id] = spawn_totals[spawn_group_id] + 1 end
end

function GM:WaveEnd()
	--yarp
	hook.Remove("Tick", "minge_defense_wave")
	print("WaveEnd ran")
end

function GM:WaveGetTable()
	local wave_table
	
	--we have a lot of fall backs for this
	--so I made a table of functions to run until we get a table
	for attempt, fetching_function in ipairs(fetching_functions) do
		print("Attempting to fetch the wave table, attempt #" .. attempt .. ".")
		wave_table = fetching_functions[attempt]()
		
		if wave_table then break end
	end
	
	return wave_table
end

function GM:WaveSpawn(enemy, count, spawn_group_id)
	local spawn_points = MingeDefenseMingeSpawns[spawn_group_id]
	
	for amount = 1, count or 1 do
		spawn_cursors[spawn_group_id] = (spawn_cursors[spawn_group_id] % spawn_totals[spawn_group_id]) + 1
		
		spawn_points[spawn_cursors[spawn_group_id]]:QueueSpawn(enemy)
	end
end

function GM:WaveStart(wave)
	local wave_start_time = CurTime()
	local wave_table, wave_groups, wave_order = process_wave_table(hook.Call("WaveGetTable", self))
	
	--processed info for the wave's progression
	local wave_ending = false
	local wave_next_time = wave_order[1]
	local wave_pointer = 1
	
	--spawn processing
	spawn_cursors = {}
	spawn_totals = {}
	
	for index, spawn_group_id in pairs(wave_table.meta.spawn_groups) do hook.Call("WaveCalculateSpawns", self, spawn_group_id) end
	
	--wave clock
	hook.Add("Tick", "minge_defense_wave", function()
		if wave_ending then
			--check if all minges and enemies and stuff are dead
			local all_dead = true
			
			if all_dead then
				--yarp
				hook.Call("WaveEnd", self, wave_table, wave_start_time)
			else end
		else
			local wave_time = CurTime() - wave_start_time
			
			if wave_time > (wave_next_time or -1) then
				--increment the pointer
				wave_pointer = wave_pointer + 1
				
				--set the next time for an event to happen
				local wave_last_time = wave_next_time
				wave_next_time = wave_order[wave_pointer]
				
				PrintMessage(HUD_PRINTTALK, string.format("Next event! Pointer: %i, times: %f (%f); %f", wave_pointer, wave_last_time, wave_time, wave_next_time or -1))
				
				--if wave_next_time is nil that means we did all the events
				if wave_next_time then
					PrintMessage(HUD_PRINTTALK, "Spawning minges.")
					
					--perform the event, mainly spawning minges
					for enemy, count in pairs(wave_groups[wave_last_time]) do hook.Call("WaveSpawn", self, enemy, count, "generic") end
				else
					PrintMessage(HUD_PRINTTALK, "Ending wave.")
					
					--start checking if all the minges are dead, and if they are do wave ending stuff
					wave_ending = true
					
					--maybe show an OVERTIME thing at the top of the screen
				end
			end
		end
	end)
end

--global functions
function TestWaveGen()
	local wave_table = hook.Call("WaveGetTable", GAMEMODE)
	
	print("WHAT?", wave_table)
	PrintTable(wave_table or {}, 1)
	
	local test_1, test_2, test_3 = process_wave_table(wave_table)
	
	print("\nwave table:")
	PrintTable(test_1, 1)
	print("\nwave groups:")
	
	for time, wave_group in pairs(test_2) do print("@ time " .. time .. " the following will spawn:") for enemy, count in pairs(wave_group) do print("    " .. enemy .. ": " .. count) end end
	
	print("\nwave order:")
	PrintTable(test_3)
end

--hooks
hook.Add("OnReloaded", "minge_defense_wave", function() TestWaveGen() end)

hook.Add("Think", "minge_defense_wave_update", function()
	
end)