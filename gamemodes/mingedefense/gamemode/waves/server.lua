--this script handles the wave and game stages on the server

--holds tables by mdgroupid which contains a table of positions referenced by their entity index
MingeDefenseMingeSpawns = MingeDefenseMingeSpawns or {}

--locals
local wave = 1
local wave_generator --function to generate default waves

--temp locals
local test_wave_table = {
	--this is an enemy spawn definition, squads are not yet implemented
	{
		count = 15, --how many to spawn, nil means 1 for right now, but later it will mean dont stop spawning them
		enemy = "minge_basic", --what enemy to spawn
		interval = 3, --how much time to space between spawning squads, nil to spawn them all at once
		squad = 5, --how big a squad is, leave nil if you want them to be individuals, if interval is also nil the whole count will be a squad
		time = 0 --at what time does the first enemy/squad spawn, nil means 0
	},
	{
		count = 5,
		enemy = "minge_bag",
		interval = 1,
		time = 2
	},
	spawns = {
		
	}
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
			
		end
	end
	
	return wave_groups, wave_order
end

--gamemode functions
function GM:MapWavesLoad(data)
	--more to come
	wave_generator = data.wave_generator
end

function GM:WaveEnd()
	--yarp
	hook.Remove("Tick", "minge_defense_wave")
end

function GM:WaveGetTable()
	local wave_table
	
	if wave_generator then wave_table = wave_generator(wave) end
	if not wave_table then wave_table = test_wave_table --[[config crap]] end
	
	return wave_table
end

function GM:WaveSpawn(enemy, count)
	local spawn_position = vector_origin
	
	--just get the first spawn point right now, we will do more complex crap later
	for group_id, group in pairs(MingeDefenseMingeSpawns) do
		for entity_index, position in pairs(group) do
			spawn_point = position
			
			break
		end
		
		break
	end
	
	for amount = 1, count or 1 do
		local minge = ents.Create(enemy)
		
		minge:SetPos(spawn_position)
		minge:Spawn()
	end
end

function GM:WaveStart(wave)
	local wave_start_time = CurTime()
	local wave_table = self:WaveGetTable(test_wave_table)
	
	--processed info for the wave's progression
	local wave_ending = false
	local wave_groups, wave_order = generate_wave_spawn_order(wave_table)
	local wave_next_time = wave_order[1]
	local wave_pointer = 1
	
	hook.Add("Tick", "minge_defense_wave", function()
		if wave_ending then
			--check if all minges and enemies and stuff are dead
			local all_dead = true
			
			if all_dead then
				--yarp
				self:WaveEnd()
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
					for enemy, count in pairs(wave_groups[wave_last_time]) do self:WaveSpawn(enemy, count) end
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
	local test_1, test_2 = generate_wave_spawn_order(test_wave_table)
	
	print("\nwave groups:")
	
	for time, wave_group in pairs(test_1) do print("@ time " .. time .. " the following will spawn:") for enemy, count in pairs(wave_group) do print("    " .. enemy .. ": " .. count) end end
	
	print("\nwave order:")
	PrintTable(test_2)
end

--hooks
hook.Add("OnReloaded", "minge_defense_wave", function() TestWaveGen() end)