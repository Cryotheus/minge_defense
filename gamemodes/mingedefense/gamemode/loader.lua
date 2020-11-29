--Cryotheum#4096

--we use bits here to determine if the function is run, up to 16 bits are supported here
--	0b000 = do nothing
--	0b001 = include on client
--	0b010 = include on server
--	0b100 = AddCSLuaFile
--anything above is the priority, lower values = higher priority
--priority 1 and below should be reserved for required and deathly important files
--can't read binary? lol fuckin noob- half right face trainee give that keyboard some fuckin love
--daniel ocean
--stefan ocean
--sergei nohomo

--configurable variables
local config = {
	--files at gamemode root
	cl_init = 4,	--0100
	loader = 4,		--0100 this is some inception crap what the fuuuuuuck
	shared = 4,		--0100
	
	--folders
	player_class = {player_defender = 15},	--1111
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
			
			local priority = fl_bit_rshift(value, 3)
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

--post function setup
print("\n\\\\\\ Minge Defense is starting. ///\n\nConstructing load order...")
construct_order(config, 1, "")
print("\nConstructed load order.\n\nLoading scripts by load order...")
load_by_order()
print("\nLoaded scripts.\n\n/// All scripts loaded. \\\\\\\n")