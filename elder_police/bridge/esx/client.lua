
if GetResourceState('es_extended') ~= 'started' then return end
ESX = exports['es_extended']:getSharedObject()
Framework, PlayerLoaded, PlayerData = 'esx', nil, {}

RegisterNetEvent('esx:playerLoaded', function(xPlayer)
    PlayerData = xPlayer
    PlayerLoaded = true
end)

RegisterNetEvent('esx:onPlayerSpawn', function()
    TriggerEvent('elder_police:onPlayerSpawn')
end)

AddEventHandler('esx:onPlayerDeath', function(data)
    TriggerEvent('elder_police:onPlayerDeath')
end)

RegisterNetEvent('esx:onPlayerLogout', function()
    table.wipe(PlayerData)
    PlayerLoaded = false
end)

RegisterNetEvent('esx:setJob', function(job)
    PlayerData.job = job
end)

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName or not ESX.PlayerLoaded then return end
    PlayerData = ESX.GetPlayerData()
    PlayerLoaded = true
end)

AddEventHandler('esx:setPlayerData', function(key, value)
    if GetInvokingResource() ~= 'es_extended' then return end
    PlayerData[key] = value
end)

function HasGroup(filter)
    local type = type(filter)

    if type == 'string' then
        if PlayerData.job.name == filter then
            return PlayerData.job.name, PlayerData.job.grade
        end
    else
        local tabletype = table.type(filter)

        if tabletype == 'hash' then
            local grade = filter[PlayerData.job.name]

            if grade and grade <= PlayerData.job.grade then
                return PlayerData.job.name, PlayerData.job.grade
            end
        elseif tabletype == 'array' then
            for i = 1, #filter do
                if PlayerData.job.name == filter[i] then
                    return PlayerData.job.name, PlayerData.job.grade
                end
            end
        end
    end
end

function GetGroup()
    return PlayerData.job.name, PlayerData.job.grade
end

function GetIdentifier(target)
    return lib.callback.await('elder_police:getIdentifier', 100, GetPlayerServerId(target))
end

function OpenBossMenu()
    TriggerEvent('esx_society:openBossMenu', PlayerData.job.name, function(data, menu)
        menu.close()
    end, {wash = false})
end