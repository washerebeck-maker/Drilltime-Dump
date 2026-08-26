local isHijacking = false

local function ticker_notification(msg)
    AddTextEntry('elderHoodsHijackNotification', msg)
    BeginTextCommandThefeedPost('elderHoodsHijackNotification')
    EndTextCommandThefeedPostTicker(false)
end

local function repair_current_vehicle()
    lib.progressBar({
        duration = 10 * 1000,
        label = 'Repairing Vehicle via ProPad',
        useWhileDead = false,
        canCancel = false,
        disable = { car = true, move = true, combat = true },
        anim = { dict = 'anim@gangops@facility@servers@bodysearch@', clip = 'player_search' },
    })

    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    if vehicle == 0 then return end

    local fuel = GetVehicleFuelLevel(vehicle)
    SetVehicleFixed(vehicle)
    SetVehicleDirtLevel(vehicle, 0.0)
    SetVehicleFuelLevel(vehicle, fuel)
end

local function hijack_targeted_vehicle(playerPed, vehicle)
    TriggerServerEvent('elder_gangs:server:hijack:check_alarm',
        GetVehicleNumberPlateText(vehicle), GetEntityCoords(vehicle))

    isHijacking = true
    FreezeEntityPosition(playerPed, true)
    ExecuteCommand('e tablet2')
    Wait(5000)
    exports['rpemotes']:EmoteCancel()
    ClearPedTasksImmediately(playerPed)

    local success = lib.skillCheck({ 'medium', 'hard', 'easy' })
    if not success then
        FreezeEntityPosition(playerPed, false)
        client.framework.notify('Try again')
        isHijacking = false
        return
    end

    ExecuteCommand('e tablet2')
    CreateThread(function()
        if lib.progressBar({ duration = 30000, label = 'Vehicle PC being altered ...', canCancel = false }) then
            exports['rpemotes']:EmoteCancel()
            FreezeEntityPosition(playerPed, false)
            SetVehicleDoorsLocked(vehicle, 1)
            SetVehicleDoorsLockedForAllPlayers(vehicle, false)
            ClearPedTasksImmediately(playerPed)
            client.framework.notify('vehicle unlocked')
            isHijacking = false
        end
    end)
end

RegisterNetEvent('elder_gangs:client:hijack:use', function()
    if isHijacking then
        client.framework.notify('You cannot do this action now')
        return
    end

    local playerPed = PlayerPedId()
    if IsPedSittingInAnyVehicle(playerPed) then
        repair_current_vehicle()
        return
    end

    local vehicle = client.framework.vehicle.get_in_direction()
    if not DoesEntityExist(vehicle) then
        client.framework.notify('no vehicle nearby')
        return
    end

    hijack_targeted_vehicle(playerPed, vehicle)
end)

RegisterNetEvent('elder_gangs:client:hijack:alarm_alert', function(plate, coords)
    CreateThread(function()
        local blip = AddBlipForCoord(coords)
        SetBlipSprite(blip, 227)
        SetBlipScale(blip, 1.2)
        SetBlipColour(blip, 1)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString('Your Car')
        EndTextCommandSetBlipName(blip)
        SetBlipAsShortRange(blip, true)
        PulseBlip(blip)

        local radiusBlip = AddBlipForCoord(coords)
        SetBlipSprite(radiusBlip, 161)
        SetBlipScale(radiusBlip, 2.0)
        SetBlipColour(radiusBlip, 1)
        PulseBlip(radiusBlip)

        ticker_notification('~r~Vehicle Alarm~s~ is ON !!! Plate : ~y~' .. plate .. '~s~')
        Wait(25000)
        RemoveBlip(blip)
        RemoveBlip(radiusBlip)
    end)
end)
