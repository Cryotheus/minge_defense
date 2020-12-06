AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:KeyValue(key, value) print("mdinfo_wave_screen got a key value\n" .. key .. ": " .. tostring(value) .. "\n") end