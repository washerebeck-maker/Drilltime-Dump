ESX = exports['es_extended']:getSharedObject()

local ClosestDumper = nil

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
   Wait(2000)
   TriggerServerEvent('elder_dumpster:client:onPlayerLoaded')
end)

function Notify(msg, type)
	lib.notify({
        description = msg,
        position = position or 'center-left',
        type = type,
        duration = time
    })
end

RegisterNetEvent("elder_dumpster:client:notify")
AddEventHandler("elder_dumpster:client:notify", function(msg, type) 
	Notify(msg, type)
end)

CreateThread(function()
    while true do 
        local coords = GetEntityCoords(cache.ped)
        local object, coords = lib.getClosestObject(coords, 5.0)
        if IsDumpster(GetEntityModel(object)) then
            ClosestDumper = object
        end
        Wait(500)
    end
end)

local ShowUI = false

CreateThread(function()
    while true do 
        local wait = 250
        if ClosestDumper then
            if GetDistanceBetweenCoords(GetEntityCoords(cache.ped), GetEntityCoords(ClosestDumper), true) <= 1.5 then
                wait = 1
                if not ShowUI then
                    ShowUI = true
                    lib.showTextUI('[H] - Loot Dumpster', {icon = 'fa-dumpster', iconColor = 'red'})
                end
                if IsControlJustReleased(0, 74) then
                    lib.hideTextUI()
                    OpenDumpster()
                end
            else 
                ClosestDumper = nil
                if ShowUI then
                    ShowUI = false
                    lib.hideTextUI()
                end
            end
        end
        Wait(wait)
    end
end)

--[[ CreateThread(function()
    for k,v in pairs(Config.Dumpsters) do 
        exports.ox_target:addModel(v, {
            {
                icon = 'fas fa-dumpster',
                iconColor = 'red',
                label = 'Loot Dumpster',
                distance = 1.0,
                onSelect = function()
                    OpenDumpster(v)
                end,
            }
        })
    end
end) ]]

--[[ OpenDumpster = function(model)
    FreezeEntityPosition(cache.ped, true)
    if lib.progressBar({
        duration = 5 * 1000,
        label = 'Looting Dumpster',
        useWhileDead = false,
        canCancel = false,
        disable = {
            car = true,
            move = true,
            combat = true
        },
        anim = {
            dict = 'amb@prop_human_bum_bin@idle_b',
            clip = 'idle_d'
        },

    }) then
        local coords = GetEntityCoords(cache.ped)
        local dumpster = GetClosestObjectOfType(coords.x, coords.y, coords.z, 1.5, model, false, false, false)
        TriggerServerEvent('elder_dumpster:server:openDumpster', tostring(GetEntityCoords(dumpster)))
    end
    FreezeEntityPosition(cache.ped, false)
end ]]

OpenDumpster = function()
    FreezeEntityPosition(cache.ped, true)
    if lib.progressBar({
        duration = 5 * 1000,
        label = 'Looting Dumpster',
        useWhileDead = false,
        canCancel = false,
        disable = {
            car = true,
            move = true,
            combat = true
        },
        anim = {
            dict = 'amb@prop_human_bum_bin@idle_b',
            clip = 'idle_d'
        },

    }) then
        local coords = GetEntityCoords(cache.ped)
        TriggerServerEvent('elder_dumpster:server:openDumpster', GetEntityCoords(ClosestDumper), ClosestDumper)
    end
    FreezeEntityPosition(cache.ped, false)
end

IsDumpster = function(model)
    for k,v in pairs(Config.Dumpsters) do 
        if model == GetHashKey(v) then
            return true
        end
    end
    return false
end
