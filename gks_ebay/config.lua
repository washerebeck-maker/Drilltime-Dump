Config = {}
Config.Locale = 'en'

Config.ESXResourceName      = "es_extended"       -- Filename of ESX Framework script
Config.ESXSharedObject      = "esx:getSharedObject"  -- ESX SharedObject Function
Config.ESXName = "esx"
Config.NPCEnable = true
Config.NPCIdyenileehliyet	=  "g_f_y_vagos_01"
Config.NPCKonummrpd	=   {  x = 1353.38, y = 1156.89, z = -113.76, h = 221.36 }
Config.DrawDistance = 5
Config.ESXVersion = "1.2"       --- ESX Version 1.1 OR 1.2

Config.EyeTarget        = false    -- required qtarget


Config.BlacklistItem = {
    "kes",
    "weapon_appistol",
    "weapon_assaultrifle"
}


ESX = nil
pcall(function() ESX = exports[Config.ESXResourceName]:getSharedObject() end)
if ESX == nil then
    TriggerEvent(Config.ESXSharedObject, function(obj) ESX = obj end)
end
Config.ESX = ESX