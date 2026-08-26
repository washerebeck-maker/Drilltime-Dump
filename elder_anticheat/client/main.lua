ESX = exports['es_extended']:getSharedObject()

local NewPlayer = false

CreateThread(function()
    if ESX.IsPlayerLoaded() then
        NewPlayer = GetPlayTime() <= Config.PlayerTime
    end
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    local playtime = GetPlayTime()
    NewPlayer = playtime <= Config.PlayerTime
    print('player infos', playtime, NewPlayer)
end)

GetPlayTime = function()
    local result = promise:new()
    ESX.TriggerServerCallback('elder_anticheat:server:getPlayTime', function(data) 
		result:resolve(data)  
    end, plate)
    return Citizen.Await(result)
end

IsNewPlayer = function()
    return NewPlayer
end

local GetNewPlayerItems = function()
    return Config.NewPlayerItems
end

exports('IsNewPlayer', IsNewPlayer)
exports('GetNewPlayerItems', GetNewPlayerItems)


--[[CreateThread(function()
    while not ESX.IsPlayerLoaded() do Wait(100) end
    while IsNewPlayer() do
        Wait(5 * 60 * 1000)
        TriggerServerEvent('elder_anticheat:server:checkPlayer')
    end
end)]]














