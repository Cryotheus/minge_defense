--Cryotheum#4096

--we use bits here to determine if the function is run
--	0b001 = include on client
--	0b010 = include on server
--	0b100 = AddCSLuaFile
--anything above is priority, lower values = higher priority
--priority 1 and below should be reserved for required and deathly important files
--can't read binary? lol fuckin noob- half right face trainee give that keyboard some fuckin love

local config = {
	--files at gamemode root
	cl_init = 12,	--1100
	init = 8,		--1000
	shared = 7,		--0111
	
	--folders
	player_class = {player_defender = 7},
}

local load_order = {}

local load_functions = {
	[1] = function(path) if CLIENT then include(path) end end,
	[2] = function(path) if SERVER then include(path) end end,
	[3] = function(path) if SERVER then AddCSLuaFile(path) end end
}

local function explore(config_table, depth)
	for key, value in pairs(config) do
		
	end
end

load_config(config, depth)