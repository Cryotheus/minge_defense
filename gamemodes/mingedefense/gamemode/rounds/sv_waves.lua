--holds tables by mdgroupid which contains a table of positions referenced by their entity index
MingeDefenseMingeSpawns = MingeDefenseMingeSpawns or {}

--locals
local spawn_cursors
local spawn_totals
local wave_difficulty = "normal"
local wave_max = 1

--gamemode functions
function GM:WaveCalculateSpawns(spawn_group_id)
	spawn_cursors[spawn_group_id] = 1
	spawn_totals[spawn_group_id] = 0
	
	for index, entity in pairs(MingeDefenseMingeSpawns[spawn_group_id] or {}) do spawn_totals[spawn_group_id] = spawn_totals[spawn_group_id] + 1 end
end

function GM:WaveEnd(wave, wave_table, wave_start_time, wave_end_time)
	--yarp
	hook.Remove("Tick", "minge_defense_wave")
	print("WaveEnd ran")
	
	if wave < wave_max then hook.Call("RoundGetWaveTable", self, wave + 1)
	else hook.Call("RoundWin", self) end
end

function GM:WaveSpawn(enemy, count, spawn_group_id)
	local spawn_points = MingeDefenseMingeSpawns[spawn_group_id]
	
	for index = 1, count or 1 do
		spawn_cursors[spawn_group_id] = (spawn_cursors[spawn_group_id] % spawn_totals[spawn_group_id]) + 1
		
		spawn_points[spawn_cursors[spawn_group_id]]:QueueSpawn(enemy)
	end
end

function GM:WaveStart(wave, wave_table, wave_groups, wave_order)
	local wave_start_time = CurTime()
	
	--processed info for the wave's progression
	local wave_ending = false
	local wave_next_time = wave_order[1]
	local wave_pointer = 1
	
	--spawn processing
	spawn_cursors = {}
	spawn_totals = {}
	
	--calculate the spawns for all spawn groups
	for index, spawn_group_id in pairs(wave_table.meta.spawn_groups) do hook.Call("WaveCalculateSpawns", self, spawn_group_id) end
	
	--wave clock
	hook.Add("Tick", "minge_defense_wave", function()
		if wave_ending then
			--check if all minges and enemies and stuff are dead
			local all_dead = true
			
			if all_dead then
				--yarp
				hook.Call("WaveEnd", self, wave, wave_table, wave_start_time, CurTime())
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