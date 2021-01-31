--this is the default config to load for the map
--there will be others like easy, hard, endless, and more in the future but for now it is just normal.lua
--this file will be written to with a in game config tool
return {
	meta = {
		spawn_groups = {"generic"}
	},
	
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
	}
}