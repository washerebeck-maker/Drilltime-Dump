
ESX = exports['es_extended']:getSharedObject()


PlayerJob = nil

CreateThread(function()
    while ESX.GetPlayerData().job == nil do
		Citizen.Wait(10)
	end
	PlayerJob = ESX.GetPlayerData().job 
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
   PlayerJob = xPlayer.job
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)  
    PlayerJob = job
end)

LoadAnimation = function(animDict)
    RequestAnimDict(animDict) 
    while not HasAnimDictLoaded(animDict) do 
        Citizen.Wait(1) 
    end
end

LoadModel = function(model)
    if not HasModelLoaded(model) and IsModelInCdimage(model) then
        RequestModel(model)
        while not HasModelLoaded(model) do
            Citizen.Wait(0)
        end
    end
end

IsVehicleLocked = function(vehEntity)
    local lockedStatus = GetVehicleDoorLockStatus(vehEntity)
    if lockedStatus == 1 or lockedStatus == 0 then 
        return false
    elseif lockedStatus == 2 or lockedStatus == 10 then 
        return true
    end
end

GetItemLabel = function(_item)
	local item  = exports.ox_inventory:Items(_item)
	return item and item.label or _item
end

RegisterNetEvent('elder_drilltime:client:washCar')
AddEventHandler('elder_drilltime:client:washCar', function()
    if IsPedInAnyVehicle(cache.ped,false) then
        return Notify('You should be outside vehicle', 'error')
    end
    local vehicle = lib.getClosestVehicle(GetEntityCoords(cache.ped), 3.0, false)
    if not vehicle or vehicle <= 0 then
        return Notify('No vehicle nearby', 'error')
    end
    if GetVehicleDirtLevel(vehicle) <= 0 then
        return Notify('Your vehicle is clean', 'error')
    end
    FreezeEntityPosition(ped, true)
    TriggerServerEvent('elder_drilltime:server:carWashed')
    if lib.progressBar({
        duration = 8 * 1000,
        label = 'Washing Car',
        useWhileDead = false,
        canCancel = false,
        disable = {
            car = true,
            move = true,
            combat = true
        },
        anim = {
            dict = 'timetable@floyd@clean_kitchen@base',
            clip = 'base'
        },
        }) then
        FreezeEntityPosition(ped, false)
        SetVehicleDirtLevel(vehicle, 0.0)           
    else 
        FreezeEntityPosition(ped, false)
    end
end)
