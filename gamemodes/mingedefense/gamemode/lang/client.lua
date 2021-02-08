--this file will be a language loader
--it will be used to format text from localization files

function GM:LangGetFormattedPhrase(key, phrases)
	local text
	
	if phrases then text = language.GetPhrase(key)
	else
		text = language.GetPhrase(key.key)
		phrases.text = nil
	end
	
	--[[
	
	%[%:	= match these characters: "[:"
	(.-)	= match any character from every character (".") to ("-") no character ("")
	%]		= match this character: "]"
	
	]]
	
	return string.gsub(text, "%[%:(.-)%]", phrases)
end