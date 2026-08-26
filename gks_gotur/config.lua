Config              = {}
Config.Locale 	  = 'en'
Config.ESXVersion = "1.2" -- 1.1 OR 1.2

Config.ESXName = "esx"
Config.Society = "esx_society:registerSociety"
Config.SocietyBossmenu = "esx_society:openBossMenu"
Config.Setjob = "esx:setJob"
Config.EsxAddonAcc = 'esx_addonaccount:getSharedAccount'
Config.ESXResourceName      = "es_extended"       -- Filename of ESX Framework script
Config.ESXSharedObject      = "esx:getSharedObject"  -- ESX SharedObject Function


--Blip

Config.EnableBlips = true
Config.BlipSprite   = 512
Config.ZDiff        = 2.0
Config.GOTURLocations = {
	{ ['x'] = 288.36,  ['y'] = -1267.04,  ['z'] = 29.44}
}

--warehouse location
Config.DrawDistance = 10
Config.MarkerColor  = { r = 120, g = 120, b = 240 }
Config.Zones = {

	OfficeActions = {
		Pos   = { x = 288.36, y = -1267.04, z = 29.44 },
		Size  = { x = 1.5, y = 1.5, z = 1.0 },
		Type  = -1
	}
}

Config.deliverytime = 3 -- delivery time setting place


Config.BlacklistItem = {
    "weapon_pistol",
    "weapon_appistol",
    "weapon_assaultrifle"
}

ESX = nil
pcall(function() ESX = exports[Config.ESXResourceName]:getSharedObject() end)
if ESX == nil then
    TriggerEvent(Config.ESXSharedObject, function(obj) ESX = obj end)
end
Config.ESX = ESX