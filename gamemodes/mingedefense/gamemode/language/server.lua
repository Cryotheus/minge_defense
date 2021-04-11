util.AddNetworkString("minge_defense_message")

--gamemode functions
function GM:LanguageSend(target, enumeration, key)
	net.Start("minge_defense_message")
	net.WriteUInt(enumeration - 1, 2)
	net.WriteString(key)
	net.WriteBool(true)
	
	if target then net.Send(target)
	else net.Broadcast() end
end

function GM:LanguageSendFormat(target, enumeration, key, phrases)
	if not phrases then
		phrases = key
		key = key.key
	end
	
	net.Start("minge_defense_message")
	net.WriteUInt(enumeration - 1, 2)
	net.WriteString(key)
	
	for tag, phrase in pairs(phrases) do
		net.WriteBool(false)
		net.WriteString(tag)
		net.WriteString(phrase)
	end
	
	net.WriteBool(true)
	
	if target then net.Send(target)
	else net.Broadcast() end
end