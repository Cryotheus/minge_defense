--Cryotheum#4096

--we use bits here to determine if the function is run, up to 16 bits are supported here
--the first 3 digits are used to tell the loader what to do with the file
--	0b000 = 0d0 = do nothing
--	0b001 = 0d1 = include on client
--	0b010 = 0d2 = include on server
--	0b100 = 0d4 = AddCSLuaFile
--anything above 7 (0b111) is the priority, lower values = higher priority
--priority 1 and below should be reserved for required and deathly important files, or files that are just AddCSLuaFile'd
--can't read binary? lol fuckin noob- half right face trainee give that keyboard some fuckin love

--configurable variables
--this is the only table I will use trailing commas on, because it's faster with something that gets configured so often
local config = {
	--files at gamemode root, these are not run by this loader
	cl_init = 4,	--0 100
	loader = 4,		--0 100 this is some inception crap what the fuuuuuuck
	shared = 4,		--0 100
	
	--folders
	global_functions = {client = 13},		--01 101
	player_class = {player_defender = 23},	--10 111
	waves = {server = 18},					--10 010
	
	--folders with actual content
	lang = {
		client = 21,	--10 101
		languages = {	--these will not be included by the loader, lang/client will include them as it needs their return value
			en = 4,		--00 100
			--fr = 4,	--00 100
		}
	},
	
	ui = {
		colors = 21,	--010 101
		fonts = 21,		--010 101
		hud = 29,		--011 101
		status = 37,	--100 101
	},
}

--maximum amount of folders it may go down in the config tree
local max_depth = 4

--local variables, don't change
local fl_bit_band = bit.band
local fl_bit_rshift = bit.rshift
local highest_priority = 0
local load_order = {}
local load_functions = {
	[1] = function(path) if CLIENT then include(path) end end,
	[2] = function(path) if SERVER then include(path) end end,
	[4] = function(path) if SERVER then AddCSLuaFile(path) end end
}

local load_function_shift = table.Count(load_functions)
local load_start_time = SysTime()

--local functions
--explores the config and populates load_order
local function construct_order(config_table, depth, path)
	local tabs = " ]" .. string.rep("    ", depth)
	
	for key, value in pairs(config_table) do
		if type(value) == "table" then
			print(tabs .. key .. ":")
			
			if depth < max_depth then construct_order(value, depth + 1, path .. key .. "/")
			else print(tabs .. "    !!! MAX DEPTH !!!") end
		else
			print(tabs .. key .. " = 0d" .. value)
			
			local priority = fl_bit_rshift(value, load_function_shift)
			local script_path = path .. key
			
			if priority > highest_priority then highest_priority = priority end
			if load_order[priority] then load_order[priority][script_path] = fl_bit_band(value, 7)
			else load_order[priority] = {[script_path] = fl_bit_band(value, 7)} end
		end
	end
end

--loads scripts using load_order and load_functions
local function load_by_order()
	--go down the levels of priority, we can't use ipairs in case I make a mistake in assigning load orders :p
	for priority = 0, highest_priority do
		local script_paths = load_order[priority]
		
		if script_paths then
			print(" ]Loading scripts at level " .. priority .. "...")
			
			--if there are scripts in this load order, then load them
			for script_path, bits in pairs(script_paths) do
				local script_path_extension = script_path .. ".lua"
				
				print(" ]    0d" .. bits .. "	" .. script_path_extension)
				
				--finally, run the applicable functions
				for bit_flag, func in pairs(load_functions) do
					--if the script has the bit flag for the function, run the function
					if fl_bit_band(bits, bit_flag) > 0 then func(script_path_extension) end
				end
			end
		else print("Skipping level " .. priority .. " as it contains no scripts.") end
	end
end

--loads the map scripts and wave generator stuff
local function load_map()
	
end

--post function setup
print("\n\\\\\\ Minge Defense is starting. ///\n\nConstructing load order...")
construct_order(config, 1, "")
print("\nConstructed load order.\n\nLoading scripts by load order...")
load_by_order()
print("\nLoaded gamemode scripts.\n\nLoading map scripts...")
load_map()
print("\nLoaded scripts.\n\n/// All scripts loaded. \\\\\\\n")

local load_finish_time = SysTime()
local load_duration = load_finish_time - load_start_time
local load_message = string.format("Gamemode file loading finished! Lasted %.2f seconds.", load_duration)

--gamemode functions
function GM:LoadFinished()
	print(load_message)
	
	return load_start_time, load_finish_time, load_duration
end

--post gamemode funciton setup
GM:LoadFinished()