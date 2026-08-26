
local insideFuelStation   = false
local currentStationIndex = nil
local nearestPump         = nil
local isRefueling         = false
local promptShown         = false

local function notification(msg)
    lib.notify({ description = msg, type = 'inform', position = 'center-left' })
end

local function isPedDrivingAVehicle()
    local ped = PlayerPedId()
    if not IsPedInAnyVehicle(ped, false) then return false end
    local vehicle = GetVehiclePedIsIn(ped, false)
    if GetPedInVehicleSeat(vehicle, -1) ~= ped then return false end
    local class = GetVehicleClass(vehicle)
    if class == 13 or class == 15 or class == 16 or class == 21 then return false end
    return true
end

local function findNearestFuelPump(coords, maxRadius)
    if not Config.PumpModels then return nil, math.huge end
    local best, bestDist = nil, math.huge
    for hash in pairs(Config.PumpModels) do
        local obj = GetClosestObjectOfType(coords.x, coords.y, coords.z, maxRadius, hash, false, false, false)
        if obj ~= 0 then
            local d = #(coords - GetEntityCoords(obj))
            if d < bestDist then
                best, bestDist = obj, d
            end
        end
    end
    return best, bestDist
end

local function showProgress(label, durationSec)
    SendNUIMessage({ action = 'progress:start', label = label, duration = durationSec })
end

local function hideProgress()
    SendNUIMessage({ action = 'progress:stop' })
end

local function showPrompt(text, anchor)
    local onScreen, sx, sy = World3dToScreen2d(anchor.x, anchor.y, anchor.z + 1.2)
    if not onScreen then
        if promptShown then
            SendNUIMessage({ action = 'prompt:hide' })
            promptShown = false
        end
        return
    end
    SendNUIMessage({ action = 'prompt:show', text = text, x = sx, y = sy })
    promptShown = true
end

local function hidePrompt()
    if not promptShown then return end
    SendNUIMessage({ action = 'prompt:hide' })
    promptShown = false
end

local function startFullService(vehicle, pump)
    if isRefueling then return end
    if not vehicle or not DoesEntityExist(vehicle) then return end
    if not pump or not DoesEntityExist(pump) then return end

    isRefueling = true
    hidePrompt()
    FreezeEntityPosition(vehicle, true)

    local duration   = Config.fuelRefuelDuration or 15
    local cancelDist = Config.fuelCancelDistance or 5.0
    local pumpCoords = GetEntityCoords(pump)
    showProgress('Refueling…', duration)

    CreateThread(function()
        local endTime     = GetGameTimer() + (duration * 1000)
        local cancelReason

        while GetGameTimer() < endTime do
            if not DoesEntityExist(pump) then
                cancelReason = 'pump'
                break
            end
            local ped = PlayerPedId()
            if GetVehiclePedIsIn(ped, false) == vehicle then
                cancelReason = 'entered'
                break
            end
            local dist = #(GetEntityCoords(ped) - pumpCoords)
            if dist > cancelDist then
                cancelReason = 'distance'
                break
            end
            Wait(200)
        end

        hideProgress()
        if DoesEntityExist(vehicle) then
            FreezeEntityPosition(vehicle, false)
        end
        isRefueling = false

        if cancelReason == 'entered' then
            notification('Refueling cancelled — you got back in the vehicle.')
            return
        elseif cancelReason then
            notification('Refueling cancelled — you moved too far away.')
            return
        end

        if DoesEntityExist(vehicle) then
            SetVehicleFixed(vehicle)
            SetVehicleEngineHealth(vehicle, 1000.0)
            SetVehiclePetrolTankHealth(vehicle, 1000.0)
            SetVehicleBodyHealth(vehicle, 1000.0)
            SetVehicleUndriveable(vehicle, false)
            SetVehicleOilLevel(vehicle, 5.0)
            SetFuel(vehicle, 100.0) 
        end
        notification('Vehicle fully repaired and refueled.')
    end)
end

local purchasePending = false
local cooldownUntil   = 0

local function tryPurchaseAndStart(vehicle, pump)
    if purchasePending or isRefueling then return end
    if not insideFuelStation or not currentStationIndex then return end
    local station = Config.FuelStations[currentStationIndex]
    if not station or not station.name then return end

    if GetGameTimer() < cooldownUntil then
        local remaining = math.ceil((cooldownUntil - GetGameTimer()) / 1000)
        notification(('Try again in %ds.'):format(remaining))
        return
    end

    purchasePending = true
    CreateThread(function()
        local ok, err, code = lib.callback.await('elder_fuel:purchaseRefuel', false, station.name)
        purchasePending = false
        if ok then
            startFullService(vehicle, pump)
        else
            if code == 'no_money' then
                cooldownUntil = GetGameTimer() + ((Config.fuelRefuelCooldownSeconds or 10) * 1000)
            end
            notification(err or 'Refuel failed.')
        end
    end)
end

local function formatPrice(n)
    local s = tostring(math.floor(n or 0))
    return (s:reverse():gsub('(%d%d%d)', '%1,'):reverse():gsub('^,', ''))
end

CreateThread(function()
    local S = Config.Strings or {}
    local exitMsg     = S.ExitVehicle or 'Exit the vehicle to refuel'
    local pressMsgFmt = S.EToRefuel   or 'Press [E] to refuel vehicle  [$%s]'
    local fullMsg     = S.FullTank    or 'Tank is full'
    local pressMsg    = pressMsgFmt:format(formatPrice(Config.fuelRefuelPrice or 0))

    while true do
        local sleep = 1000

        if insideFuelStation and not isRefueling then
            local ped       = PlayerPedId()
            local pedCoords = GetEntityCoords(ped)
            local pump, pumpDist = findNearestFuelPump(pedCoords, 8.0)
            local interactRng    = Config.pumpInteractionDistance or 3.0

            if pump and pumpDist <= interactRng then
                nearestPump = pump
                local pumpCoords = GetEntityCoords(pump)

                if isPedDrivingAVehicle() then

                    showPrompt(exitMsg, pumpCoords)
                    sleep = 0
                else

                    local vehicle    = GetPlayersLastVehicle()
                    local hasVehicle = vehicle and vehicle ~= 0 and DoesEntityExist(vehicle)
                    local vehDist    = hasVehicle and #(pedCoords - GetEntityCoords(vehicle)) or math.huge
                    local seatEmpty  = hasVehicle and not DoesEntityExist(GetPedInVehicleSeat(vehicle, -1))

                    if hasVehicle and vehDist <= 4.0 and seatEmpty then
                        local fuel = GetVehicleFuelLevel(vehicle)
                        if fuel >= 95.0 then
                            showPrompt(fullMsg, pumpCoords)
                        else
                            showPrompt(pressMsg, pumpCoords)
                            if IsControlJustReleased(0, 38) then
                                tryPurchaseAndStart(vehicle, pump)
                            end
                        end
                        sleep = 0
                    else
                        hidePrompt()
                        sleep = 250
                    end
                end
            else
                hidePrompt()
                nearestPump = nil
                sleep = 300
            end
        else
            hidePrompt()
            nearestPump = nil
        end

        Wait(sleep)
    end
end)

local function repairAndFuel()
    if not isPedDrivingAVehicle() then
        notification('You need to be driving a vehicle.')
        return
    end

    if insideFuelStation then
        notification('Use the station menu — this command is for stranded vehicles.')
        return
    end

    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)

    if GetVehicleEngineHealth(vehicle) >= Config.cascadingFailureThreshold + 5 then
        return
    end

    if GetVehicleOilLevel(vehicle) <= 0 then
        notification('Your vehicle was too badly damaged. Unable to repair!')
        return
    end

    SetVehicleUndriveable(vehicle, false)
    SetVehicleEngineHealth(vehicle, Config.cascadingFailureThreshold + 5)
    SetVehiclePetrolTankHealth(vehicle, 750.0)
    SetVehicleEngineOn(vehicle, true, false)
    SetVehicleOilLevel(vehicle, (GetVehicleOilLevel(vehicle) / 3) - 0.5)
    notification('Vehicle partially repaired and refueled.')
end

RegisterCommand('fuel',   function() repairAndFuel() end, false)
RegisterCommand('repair', function() repairAndFuel() end, false)

local managementOpen   = false
local managedStation   = nil  

local function currentStationName()
    if not insideFuelStation or not currentStationIndex then return nil end
    local s = Config.FuelStations[currentStationIndex]
    return s and s.name or nil
end

RegisterCommand('managefuel', function()
    local name = currentStationName()
    if not name then
        notification('You must be inside a fuel station.')
        return
    end
    TriggerServerEvent('elder_fuel:requestManageUi', name)
end, false)

RegisterNetEvent('elder_fuel:openManageUi', function(payload)
    managementOpen = true
    managedStation = payload and payload.station or nil
    SetNuiFocus(true, true)
    SendNUIMessage({ action = 'ui:open', payload = payload })
end)

RegisterNetEvent('elder_fuel:syncStation', function(payload)
    SendNUIMessage({ action = 'ui:update', payload = payload })
end)

RegisterNetEvent('elder_fuel:notify', function(msg, kind)
    lib.notify({ description = msg, type = kind or 'inform', position = 'center-left' })
end)

local function closeManageUi()
    if not managementOpen then return end
    managementOpen = false
    managedStation = nil
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'ui:close' })
end

RegisterNUICallback('close', function(_, cb)
    closeManageUi()
    cb({ ok = true })
end)

RegisterNUICallback('withdraw', function(data, cb)
    local amount = tonumber(data and data.amount) or 0
    if amount <= 0 or not managedStation then
        cb({ ok = false, message = 'Invalid request' })
        return
    end
    TriggerServerEvent('elder_fuel:withdraw', managedStation, amount)
    cb({ ok = true })
end)

RegisterNUICallback('refuel', function(_, cb)
    if not managedStation then
        cb({ ok = false, message = 'No active station' })
        return
    end
    TriggerServerEvent('elder_fuel:refuelStation', managedStation)
    cb({ ok = true })
end)

AddEventHandler('onResourceStop', function(res)
    if res == GetCurrentResourceName() and managementOpen then
        SetNuiFocus(false, false)
    end
end)

CreateThread(function()
    if not Config or not Config.FuelStations then return end

    for i, station in ipairs(Config.FuelStations) do
        local blip = AddBlipForCoord(station.coords.x, station.coords.y, station.coords.z)
        SetBlipSprite(blip, 361)
        SetBlipColour(blip, 0)
        SetBlipScale(blip, 0.8)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentSubstringPlayerName('Fuel Station')
        EndTextCommandSetBlipName(blip)

        lib.zones.sphere({
            coords = station.coords,
            radius = station.radius,
            debug = false,
            onEnter = function()
                insideFuelStation = true
                currentStationIndex = i
            end,
            onExit = function()
                insideFuelStation = false
                currentStationIndex = nil
                hidePrompt()
                nearestPump = nil
            end,
        })
    end
end)
