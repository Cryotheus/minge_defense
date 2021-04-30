--defines a global table of colors
local temp = 0.6

--globals
GM.UIColors = {
	--the md logo's colors
	Logo = {
		Red = Color(255, 1, 1),
		RedShadow = Color(155, 0, 0)
	},
	
	--general colors for the HUD
	HUD = {
		--colors for the player's status, like health and armor
		Status = {
			Armor = Color(128, 255, 128),
			Background = Color(20, 20, 20, 96),
			Health = Color(192, 32, 32),
			HealthBackground = Color(115, 19, 19),
			Metal = Color(64, 192, 64),
			MetalBackground = Color(12, 115, 12)
		},
		
		TargetID = {
			ShadowDeep = Color(0, 0, 0, 120),
			ShadowShallow = Color(0, 0, 0, 50),
			Text = Color(0, 192, 0)
		},
		
		Team = {
			Background = Color(20, 20, 20, 96),
			BackgroundPlayer = Color(64, 64, 64, 255),
			BackgroundPlayers = Color(20, 20, 20, 32),
			BackgroundReadyPlayer = Color(128, 255, 128, 255)
		}
	},
	
	--fancy projected derma screens
	Screens = {
		Wave = {
			Background = Color(20, 20, 20, 96)
		}
	},
}

--gamemode functions
function GM:ColorsLoaded(colors) end

--hooks
hook.Call("ColorsLoaded", GM, GM.UIColors)