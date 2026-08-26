ESX = exports['es_extended']:getSharedObject()

local playerIdentifier = nil
local playerLoaded = false

local function registerStorage(name, slots, maxweight)
	local result = promise:new()
    ESX.TriggerServerCallback('elder_gangstorage:server:registerStorage', function(data) 
		result:resolve(data)  
    end, name, slots, maxweight)
    return Citizen.Await(result)
end

local function openGangStorage(storage, gang)
    local name = tostring(gang.id)..'_'..playerIdentifier
    if exports.ox_inventory:openInventory('stash', name) == false then
        registerStorage(name, storage.slots, storage.maxweight)
        exports.ox_inventory:openInventory('stash', name)
    end  
end

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    playerLoaded = true
    playerIdentifier = xPlayer.identifier
end)

if Config.Debug then
    CreateThread(function()
        playerLoaded = true
        playerIdentifier = ESX.PlayerData.identifier
    end)
end

CreateThread(function()
    while not playerLoaded do Wait(1000) end 
    while true do 
        local wait = 3000
        local playerGang = exports.elder_gangs:get_player_gang()
        if playerGang then
            local storage = Config.Storages[tostring(playerGang.id)]
            if storage then
                local distance = #(GetEntityCoords(PlayerPedId()) - storage.coords)
                if distance < 15.0 then
                    wait = 1
                    DrawMarker(1, storage.coords.x, storage.coords.y,storage.coords.z-1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.5, 1.5, 1.5, 0, 255, 0, 200, 0, 0, 0, 0, 0, 0, 0)
                    if distance <= 2.0 then
                        ESX.ShowHelpNotification('Press ~INPUT_PICKUP~ to open ~r~gang storage~s~')
                        if IsControlJustPressed(0, 38) then
                            openGangStorage(storage, playerGang)
                        end
                    end
                end
            end
        end
        Wait(wait)
    end
end)