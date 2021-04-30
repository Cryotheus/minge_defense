--https://github.com/Cryotheus/preconfigured_loader
local config = {
	--files at gamemode root, these are not run by this loader
	cl_init = 4,	--0 100
	loader = 4,		--0 100 this is some inception crap what the fuuuuuuck
	shared = 4,		--0 100
	
	--folders
	global_functions = {client = 13},	--01 101
	
	--folders with actual content
	language = {
		client = 21,	--10 101
		server = 18,	--10 010
	},
	
	player_class = {
		player_defender = 23,	--10 111
		player_flugel = 31,		--11 111
	},
	
	ui = {
		panels = {marquee_label = 21},	--010 101
		
		status_panels = {
			health = 12,	--1 100
			metal = 12		--1 100
		},
		
		colors = 21,	--010 101
		fonts = 21,		--010 101
		hud = 29,		--011 101
		status = 37,	--100 101
		target_id = 29,	--011 101
		team = 37,		--100 101
	},
	
	rounds = {
		client = 21,	--10 101
		server = 18,	--10 010
		cl_waves = 29,	--11 101
		sv_waves = 26	--11 010
	}
}

--what do we say we are when we load up?
local branding = "Minge Defense"

--maximum amount of folders it may go down in the config tree
local max_depth = 4

--reload command
local reload_command = "md_reload"

--colors
local color_generic = Color(255, 255, 255)
local color_significant = Color(255, 64, 64)

--end of configurable variables



----local variables, don't change
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

--local functions
local function construct_order(config_table, depth, path)
	local tabs = " ]" .. string.rep("    ", depth)
	
	for key, value in pairs(config_table) do
		if istable(value) then
			MsgC(color_generic, tabs .. key .. ":\n")
			
			if depth < max_depth then construct_order(value, depth + 1, path .. key .. "/")
			else MsgC(color_significant, tabs .. "    !!! MAX DEPTH !!!\n") end
		else
			MsgC(color_generic, tabs .. key .. " = 0d" .. value .. "\n")
			
			local priority = fl_bit_rshift(value, load_function_shift)
			local script_path = path .. key
			
			if priority > highest_priority then highest_priority = priority end
			if load_order[priority] then load_order[priority][script_path] = fl_bit_band(value, 7)
			else load_order[priority] = {[script_path] = fl_bit_band(value, 7)} end
		end
	end
end

local function load_by_order()
	for priority = 0, highest_priority do
		local script_paths = load_order[priority]
		
		if script_paths then
			if priority == 0 then MsgC(color_generic, " Loading scripts at level 0...\n")
			else MsgC(color_generic, "\n Loading scripts at level " .. priority .. "...\n") end
			
			for script_path, bits in pairs(script_paths) do
				local script_path_extension = script_path .. ".lua"
				
				MsgC(color_generic, " ]    0d" .. bits .. "	" .. script_path_extension .. "\n")
				
				for bit_flag, func in pairs(load_functions) do if fl_bit_band(bits, bit_flag) > 0 then func(script_path_extension) end end
			end
		else MsgC(color_significant, "Skipping level " .. priority .. " as it contains no scripts.\n") end
	end
end

local function load_map() end

--gamemode functions
function GM:LoadScripts(reload)
	load_order = {}
	local load_start_time = SysTime()
	
	MsgC(color_generic, "\n\\\\\\ ", color_significant, branding, color_generic, " ///\n\nConstructing load order...\n")
	construct_order(config, 1, "")
	MsgC(color_significant, "\nConstructed load order.\n\nLoading scripts by load order...\n")
	load_by_order()
	MsgC(color_significant, "\nLoaded gamemode scripts.\n\nLoading map scripts...")
	load_map()
	MsgC(color_significant, "\nLoaded scripts.\n\n", color_generic, "/// ", color_significant, "All scripts loaded.", color_generic, " \\\\\\\n")
	
	local load_finish_time = SysTime()
	local load_duration = load_finish_time - load_start_time
	
	hook.Call("LoadFinished", self, load_start_time, load_finish_time, load_duration)
end

function GM:LoadFinished(load_start_time, load_finish_time, load_duration)
	local load_message = string.format("Gamemode file loading finished! Lasted %.3f seconds.", load_duration)
	
	MsgC(color_generic, load_message .. "\n\n")
	
	return load_start_time, load_finish_time, load_duration, load_message
end

function GM:ReloadScripts() hook.Call("LoadScripts", self, true) end

--concommands
concommand.Add(reload_command, function(ply)
	--broke?
	--is it possible to run a command from client and execute the serverside command when the command is shared?
	if not IsValid(ply) or IsValid(LocalPlayer()) and ply == LocalPlayer() then
		--put what you need before reloading here
		hook.Call("ReloadScripts", GAMEMODE)
		--put what you need after reloading here
	end
end, nil, "Reload all " .. branding .. " scripts.")

--post function setup
hook.Call("LoadScripts", GM, false)