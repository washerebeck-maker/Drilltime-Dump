local ESX = nil

local gInSwapLocation = false

local gPlayerJob = nil

g_engine_vehicles = {}

CreateThread(function()
    while ESX == nil do
        pcall(function() ESX = exports['es_extended']:getSharedObject() end)
        if ESX == nil then
            TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        end
        Wait(50)
        while ESX.GetPlayerData().job == nil do
            Citizen.Wait(10)
        end
        gPlayerJob = ESX.GetPlayerData().job 
        CreateZoneBlip()
    end 
end)

CreateThread(function()
        
    if ESX and ESX.IsPlayerLoaded() then
        --Wait(5000)
        --g_engine_vehicles = GetVehicles()   
    end
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
   gPlayerJob = xPlayer.job
   CreateZoneBlip()
   g_engine_vehicles = GetVehicles()   
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)  
    gPlayerJob = job
end)

function Notify(msg, type)
	lib.notify({
        description = msg,
        position = position or 'center-left',
        type = type,
        duration = time
    })
end

RegisterNetEvent("elder_cartheft:client:notify")
AddEventHandler("elder_cartheft:client:notify", function(msg, type) 
	Notify(msg, type)
end)

CreateZoneBlip = function()
    while gPlayerJob == nil do Wait(100) end
    if IsStriker() then
        local blip = AddBlipForCoord(Config.SwapLocation.blip)
        SetBlipSprite(blip , 227)
        SetBlipScale(blip , 1.2)
		SetBlipColour(blip, 1)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("Vin Swap")
        EndTextCommandSetBlipName(blip)
        SetBlipAsShortRange(blip,true)
    end
end

CreateThread(function()
    local swap_location = lib.zones.poly({
        points = Config.SwapLocation.points,
        thickness = 5,
        debug = false,
        inside = function() end ,
        onEnter = function() OnSwapLocationEnter() end,
        onExit = function() OnSwapLocationExit() end
    })

    local sell_location = lib.points.new({coords = Config.SellLocation.coords, distance = 15})
    function sell_location:nearby()
        OnSellLocationNearby(self)
    end
end)

OnSwapLocationEnter = function(id)
    gInSwapLocation = true
end

OnSwapLocationExit = function(id)
    gInSwapLocation = false
end

StartSwapVehicle = function(vehicle)
    TaskLeaveVehicle(cache.ped, vehicle, 0)
    Wait(1000)
    TaskStartScenarioInPlace(cache.ped, 'WORLD_HUMAN_WELDING', 0, true)
    Wait(10000)
    ClearPedTasks(cache.ped)
    TriggerServerEvent('elder_cartheft:server:updateVehicle', ESX.Math.Trim(GetVehicleNumberPlateText(vehicle)))
end

OnSellLocationNearby = function(self)
    if not IsPedInAnyVehicle(cache.ped,false) or GetPedInVehicleSeat(GetVehiclePedIsIn(cache.ped, false), -1) ~= cache.ped then
        gShowTextUI = false
        return lib.hideTextUI()
    end
    DrawMarker(1, self.coords.x, self.coords.y, self.coords.z - 1.5, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 3.0, 3.0, 2.0, 255, 0, 0, 200, false, false, 2, false, false, false, false)
    if self.currentDistance < 2.0 then
        if not gShowTextUI then
            gShowTextUI = true
            lib.showTextUI('[E] Sell vehicle')
        end
        
        if IsControlJustPressed(0, 38) then
            SellVehicle()
        end
    else
        if gShowTextUI == true then 
            lib.hideTextUI()
            gShowTextUI = false
        end
    end
end

SellVehicle = function()
    if not IsStriker() then
        return Notify('You striker role on discord.', 'error')
    end
    if not IsPedInAnyVehicle(cache.ped,false) or GetPedInVehicleSeat(GetVehiclePedIsIn(cache.ped, false), -1) ~= cache.ped then
        return Notify('You should be in the vehicle.', 'error')
    end
    local vehicle = GetVehiclePedIsIn(cache.ped, false)
    local plate = ESX.Math.Trim(GetVehicleNumberPlateText(vehicle))
    if not IsVehicleStolen(plate) then
        return Notify('You cannot sell this vehicle.', 'error')
    end
    if GetRemaningStealTime(plate) < (Config.DurationUnit *  Config.SellDurationUnit) then
        return Notify('Too late to sell vehicle, cops are alerted of stolen vehicle', 'error')
    end
    TriggerServerEvent('elder_cartheft:server:sellVehicle', plate)
    TaskLeaveVehicle(cache.ped, vehicle, 0)
    Wait(1500)
    DeleteEntity(vehicle)
end

--███████╗██╗   ██╗███████╗███╗   ██╗████████╗███████╗
--██╔════╝██║   ██║██╔════╝████╗  ██║╚══██╔══╝██╔════╝
--█████╗  ██║   ██║█████╗  ██╔██╗ ██║   ██║   ███████╗
--██╔══╝  ╚██╗ ██╔╝██╔══╝  ██║╚██╗██║   ██║   ╚════██║
--███████╗ ╚████╔╝ ███████╗██║ ╚████║   ██║   ███████║
--╚══════╝  ╚═══╝  ╚══════╝╚═╝  ╚═══╝   ╚═╝   ╚══════╝

RegisterNetEvent('elder_cartheft:client:startCarTheft')
AddEventHandler('elder_cartheft:client:startCarTheft', function()
    if not IsStriker() then
        return Notify('You need striker discord role for this.', 'error')
    end
    if exports.ox_inventory:Search('count', Config.Item) == 0 then
        return
    end
    if not gInSwapLocation then
        return Notify('You should be in swap location.', 'error')
    end
    if not IsPedInAnyVehicle(cache.ped,false) then
        return Notify('You should be in a vehicle', 'error')
    end
    local vehicle = GetVehiclePedIsIn(cache.ped, false)
    if GetPedInVehicleSeat(vehicle, -1) ~= cache.ped then
        return Notify('You should be the driver of the vehicle', 'error')
    end
    if not IsVehicleOwned(ESX.Math.Trim(GetVehicleNumberPlateText(vehicle))) then
        return Notify('You cant swap this vehicle.', 'error')
    end
    TriggerServerEvent('elder_cartheft:server:onCarTheftStarted')
	TriggerEvent("mhacking:show")
	TriggerEvent("mhacking:start", 6, 60,  function(result)
		if result == true then
			TriggerEvent('mhacking:hide') 
            TriggerServerEvent('elder_cartheft:server:mhacking', ESX.Math.Trim(GetVehicleNumberPlateText(vehicle)))
            StartSwapVehicle(vehicle)
		else
			TriggerEvent('mhacking:hide')
		end
	end)
end)

local gBlips = {}
local gBlips2 = {}

RegisterNetEvent('elder_cartheft:client:notifyCops')
AddEventHandler('elder_cartheft:client:notifyCops', function(coords, plate)
    if gPlayerJob and gPlayerJob.name == 'police' then
        RemoveBlip(gBlips[plate])
        RemoveBlip(gBlips2[plate])
        gBlips[plate] = AddBlipForCoord(coords)
        SetBlipSprite(gBlips[plate] , 161)
        SetBlipScale(gBlips[plate] , 2.0)
		SetBlipColour(gBlips[plate], 1)
		PulseBlip(gBlips[plate])
        gBlips2[plate] = AddBlipForCoord(coords)
        SetBlipSprite(gBlips2[plate] , 227)
        SetBlipScale(gBlips2[plate] , 1.2)
		SetBlipColour(gBlips2[plate], 1)
		PulseBlip(gBlips2[plate])
        ShowNotification('Stolen car ~r~'..plate..'~s~ alert. ~y~Vehicle~s~ tracker will be active on your ~b~radar~s~')
    end
end)

RegisterNetEvent('elder_cartheft:client:stopNotifyCops')
AddEventHandler('elder_cartheft:client:stopNotifyCops', function(plate)
    if gPlayerJob and gPlayerJob.name == 'police' then
        RemoveBlip(gBlips[plate])
        RemoveBlip(gBlips2[plate])
    end
end)

--███████╗██╗   ██╗███╗   ██╗ ██████╗████████╗██╗ ██████╗ ███╗   ██╗███████╗
--██╔════╝██║   ██║████╗  ██║██╔════╝╚══██╔══╝██║██╔═══██╗████╗  ██║██╔════╝
--█████╗  ██║   ██║██╔██╗ ██║██║        ██║   ██║██║   ██║██╔██╗ ██║███████╗
--██╔══╝  ██║   ██║██║╚██╗██║██║        ██║   ██║██║   ██║██║╚██╗██║╚════██║
--██║     ╚██████╔╝██║ ╚████║╚██████╗   ██║   ██║╚██████╔╝██║ ╚████║███████║
--╚═╝      ╚═════╝ ╚═╝  ╚═══╝ ╚═════╝   ╚═╝   ╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚══════╝

IsVehicleOwned = function(plate)
    local result = promise:new()
    ESX.TriggerServerCallback('elder_cartheft:server:isVehicleOwned', function(data) 
		result:resolve(data)  
    end, plate)
    return Citizen.Await(result)
end

IsVehicleStolen = function(plate)
    local result = promise:new()
    ESX.TriggerServerCallback('elder_cartheft:server:isVehicleStolen', function(data) 
		result:resolve(data)  
    end, plate)
    return Citizen.Await(result)
end

IsVehicleStolen2 = function(plate)
    local result = promise:new()
    ESX.TriggerServerCallback('elder_cartheft:server:isVehicleStolen2', function(data) 
		result:resolve(data)  
    end, plate)
    return Citizen.Await(result)
end

GetRemaningStealTime = function(plate)
    local result = promise:new()
    ESX.TriggerServerCallback('elder_cartheft:server:getRemaningStealTime', function(data) 
		result:resolve(data)  
    end, plate)
    return Citizen.Await(result)
end

IsAnyVehicleStolen = function(plate)
    local result = promise:new()
    ESX.TriggerServerCallback('elder_cartheft:server:isAnyVehicleStolen', function(data) 
		result:resolve(data)  
    end, plate)
    return Citizen.Await(result)
end

IsStriker = function()
    local result = promise:new()
    ESX.TriggerServerCallback('elder_cartheft:server:isStriker', function(data) 
		result:resolve(data)  
    end, plate)
    return Citizen.Await(result)
end

IsEngineRemoved = function(plate)
    local result = promise:new()
    ESX.TriggerServerCallback('elder_cartheft:server:isEngineRemoved', function(data) 
		result:resolve(data)  
    end, plate)
    return Citizen.Await(result)
end

CreateThread(function()
    while true do 
        if IsPedInAnyVehicle(cache.ped,false) then
            local vehicle = GetVehiclePedIsIn(cache.ped, false)
            if GetPedInVehicleSeat(vehicle, -1) == cache.ped then
                if IsAnyVehicleStolen(ESX.Math.Trim(GetVehicleNumberPlateText(vehicle))) then
                    StartNotifCops(ESX.Math.Trim(GetVehicleNumberPlateText(vehicle)))
                end
            end
        end
        Wait(30 * 60 * 1000)
    end
end)

StartNotifCops = function(plate)
    CreateThread(function()
        local count = 5
        while count > 0 do 
            count = count - 1
            TriggerServerEvent('elder_cartheft:server:notifyCops', cache.coords, plate)
            Wait(Config.PoliceAlertFrequency * 1000)
        end
        TriggerServerEvent('elder_cartheft:server:stopNotifyCops', plate)
    end)
end

ShowNotification = function(msg)
	AddTextEntry('elderNotification', msg)
	BeginTextCommandThefeedPost('elderNotification')
	EndTextCommandThefeedPostTicker(false)
end

--------------------------- Insurance --------------------------

CreateThread(function()
    local insurance = lib.points.new({ coords = Config.InsuranceLocation.coords, distance = 15, model = Config.InsuranceLocation.model, heading = Config.InsuranceLocation.coords.w})
    function insurance:onEnter()
        RequestModel(self.model)
        while not HasModelLoaded(self.model) do
            Wait(0)
        end
        gPed = CreatePed(5, self.model, self.coords.x , self.coords.y , self.coords.z - 1 , self.heading, false, false)
        FreezeEntityPosition(gPed, true)
        SetEntityInvincible(gPed, true)
        SetBlockingOfNonTemporaryEvents(gPed, true)
    end
     
    function insurance:onExit()
        SetModelAsNoLongerNeeded(self.model)
        DeleteEntity(gPed)
    end
     
    function insurance:nearby()
        if self.currentDistance < 3.0 then
            if not gShowTextUI2 then
                gShowTextUI2 = true
                lib.showTextUI('[E] Vehicle Insurance')
            end
            
            if IsControlJustPressed(0, 38) then
                VehicleInsuranceMenu()
            end
        else
            if gShowTextUI2 == true then 
                lib.hideTextUI()
                gShowTextUI2 = false
            end
        end
    end
end)

VehicleInsuranceMenu = function()
    local vehicles = GetStolenVehicles()
    local menuOptions = {} 
    if vehicles and next(vehicles) then
        for k,v in pairs(vehicles) do  
            local props = json.decode(v.vehicle)
            local price = v.insurance > 0 and v.insurance or Config.InsurancePrice.min
            table.insert(menuOptions, 
            {title = GetDisplayNameFromVehicleModel(props.model) .. ' | ' .. v.plate, 
            description = 'Insurance price : $' .. ESX.Math.GroupDigits(price), 
            icon = 'fa-car', 
            onSelect = function() Insurance(v.plate) end
        })
        end
    end

    lib.registerContext({
        id = 'ins_menu',
        title = 'Vehicles Insurance',
        options = menuOptions,
    })
    lib.showContext('ins_menu')
end

GetStolenVehicles = function(plate)
    local result = promise:new()
    ESX.TriggerServerCallback('elder_cartheft:server:getStolenVehicles', function(data) 
		result:resolve(data)  
    end)
    return Citizen.Await(result)
end

Insurance = function(plate)
    TriggerServerEvent('elder_cartheft:server:insurance', plate)
end

------------------------------------------- Engine ----------------------------------


local function IsEngineVehicle(model)
    for k,v in pairs(Config.EngineVehicles) do 
        if GetHashKey(v) == model then return true end
    end
    return false
end

RegisterNetEvent('elder_cartheft:client:startEngineRemove')
AddEventHandler('elder_cartheft:client:startEngineRemove', function()
    if not IsStriker() then
        return Notify('You need striker discord role for this.', 'error')
    end
    if exports.ox_inventory:Search('count', Config.RemoveEngineToolItem) == 0 then
        return Notify('You should have the engine tool.', 'error')
    end
    
    local coords = GetEntityCoords(cache.ped)
    local vehicle = lib.getClosestVehicle(vec3(coords.x, coords.y, coords.z), 5.0, false)
    if not vehicle or not DoesEntityExist(vehicle) then
        return Notify('No vehicle around.', 'error')
    end

    local plate = ESX.Math.Trim(GetVehicleNumberPlateText(vehicle))
    local model = GetEntityModel(vehicle)

    if not IsEngineVehicle(model) then 
        return Notify('You cant remove engine of this vehicle.', 'error')
    end

    if not IsVehicleStolen(plate) then
        return Notify('You cant remove engine of this vehicle.', 'error')
    end

    if IsEngineRemoved(plate) then 
        return Notify('This vehicle has no engine.', 'error')
    end

    lib.progressBar({
        duration = Config.AddEngineTime * 1000,
        label = 'Removing Vehicle Engine',
        useWhileDead = false,
        canCancel = false,
        disable = {
            car = true,
            move = true,
            combat = true
        },
        anim = {
            dict = 'anim@gangops@facility@servers@bodysearch@',
            clip = 'player_search'
        },
    })


    TriggerServerEvent('elder_cartheft:server:onEngineRemoved', plate)

end)

GetVehicles = function(plate)
    local result = promise:new()
    ESX.TriggerServerCallback('elder_cartheft:server:getVehicles', function(data) 
		result:resolve(data)  
    end)
    return Citizen.Await(result)
end

RegisterNetEvent('elder_cartheft:client:updateVehicles')
AddEventHandler('elder_cartheft:client:updateVehicles', function(vehicles)
    g_engine_vehicles = vehicles
end)

function trim(s)
    return (s:gsub("^%s*(.-)%s*$", "%1"))
end

exports('DoesVehicleHasEngineRemoved', function(plate)
    local plate = trim(plate)
    return g_engine_vehicles[plate]
end)

RegisterNetEvent('elder_cartheft:client:startEngineAdd')
AddEventHandler('elder_cartheft:client:startEngineAdd', function()
    /*if not IsStriker() then
        return Notify('You need striker discord role for this.', 'error')
    end*/
    if exports.ox_inventory:Search('count', Config.EngineItem) == 0 then
        return Notify('You should have the engine.', 'error')
    end
    
    local coords = GetEntityCoords(cache.ped)
    local vehicle = lib.getClosestVehicle(vec3(coords.x, coords.y, coords.z), 5.0, false)
    if not vehicle or not DoesEntityExist(vehicle) then
        return Notify('No vehicle around.', 'error')
    end

    local plate = ESX.Math.Trim(GetVehicleNumberPlateText(vehicle))
    local model = GetEntityModel(vehicle)

    if not IsEngineVehicle(model) then 
        return Notify('You cant add engine to this vehicle.', 'error')
    end

    if not IsVehicleStolen2(plate) then
        return Notify('You cant add engine to this vehicle.', 'error')
    end

    if not IsEngineRemoved(plate) then 
        return Notify('This vehicle has already an engine.', 'error')
    end

    lib.progressBar({
        duration = Config.AddEngineTime * 1000,
        label = 'Adding Vehicle Engine',
        useWhileDead = false,
        canCancel = false,
        disable = {
            car = true,
            move = true,
            combat = true
        },
        anim = {
            dict = 'anim@gangops@facility@servers@bodysearch@',
            clip = 'player_search'
        },
    })


    TriggerServerEvent('elder_cartheft:server:onEngineAdded', plate)
end)

