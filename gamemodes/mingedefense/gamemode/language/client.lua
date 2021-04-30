--local variables
local enumerated_message_functions = {
	function(...)
		print("aw fuck")
		print("I cahn't believe you've done this", ...)
	end
}

--pre function setup
for hud_enum = 2, 4 do enumerated_message_functions[hud_enum] = function(text) LocalPlayer():PrintMessage(hud_enum, text) end end

--gamemode functions
function GM:LanguageFormat(key, phrases)
	if not phrases then
		phrases = key
		key = key.key
	end
	
	--[[
	
	%[%:	= match these characters: "[:"
	(.-)	= match any character from every character (".") to ("-") no character ("")
	%]		= match this character: "]"
	
	]]
	
	return string.gsub(language.GetPhrase(key), "%[%:(.-)%]", phrases)
end

function GM:LanguageMessage(enumeration, key, phrases)
	local text = phrases and hook.Call("LanguageFormat", self, key, phrases) or language.GetPhrase(key)
	
	return enumerated_message_functions[enumeration](text)
end

--net
net.Receive("minge_defense_message", function()
	local enumeration = net.ReadUInt(2) + 1
	local key = net.ReadString()
	
	--we have finished if there are no phrases
	if net.ReadBool() then hook.Call("LanguageMessage", GAMEMODE, enumeration, key)
	else
		local phrases = {}
		
		repeat phrases[net.ReadString()] = net.ReadString()
		until net.ReadBool()
		
		hook.Call("LanguageMessage", GAMEMODE, enumeration, key, phrases)
	end
end)