Races = {}
Config = {}
Config.ESXResourceName      = "es_extended"       -- Filename of ESX Framework script
Config.ESXSharedObject      = "esx:getSharedObject"  -- ESX SharedObject Function

Config.NonBlockFullPhasing = false  -- (If you set this to true, full phasing won't be disrupted in any way when any player comes near you)
Config.APPName = "Race"
Config.VehiclePed = "You must be in the vehicle to create a race"
Config.disqualified = "You have been disqualified from the race"
Config.racealert = "Race Alert :"
Config.laps = "Laps"
Config.Finish = "Finished Race"
Config.Cancel = "Race Cancelled"
Config.Quit = "Quit Race"
Config.RaceMap = "There is already a race in this Map"
Config.RaceMessage = "Race Message: "
Config.MapSettings = "[K] Save | [U] Cancel  | [E] Add | [Shift+E] Remove | ⬆ Radius ⬇ | ⬅ Rotation ➡ "

ESX = nil
pcall(function() ESX = exports[Config.ESXResourceName]:getSharedObject() end)
if ESX == nil then
    TriggerEvent(Config.ESXSharedObject, function(obj) ESX = obj end)
end