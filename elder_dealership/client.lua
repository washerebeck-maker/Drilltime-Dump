local ESX = nil
local PlayerLoaded = false
local ShowRooms = {}
local ShowRoomsLocations = {}

CreateThread(function()
    while ESX == nil do
        pcall(function() ESX = exports['es_extended']:getSharedObject() end)
        if ESX == nil then
            TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        end
        if Config.DevMode then
            Wait(1000)
            ShowRooms = GetShowRooms()
            PlayerLoaded = true
        end
    end 
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
   Wait(1000)
   ShowRooms = GetShowRooms()
   PlayerLoaded = true
end)

CreateThread(function()
    while not PlayerLoaded do Wait(100) end
    CreateBlips()
    CreateShowRooms()
    CreateBossMenu()
end)

CreateBlips = function()
    for k,v in pairs(Config.ShowRooms) do 
        local blip = AddBlipForCoord(v.bossmenu)
        SetBlipSprite(blip,823)
        SetBlipColour(blip,46)
        SetBlipAlpha(blip,250)
        SetBlipScale(blip,1.0)
        SetBlipAsShortRange(blip,true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(v.name)
        EndTextCommandSetBlipName(blip)
    end
end


-- functions

function Notify(msg, type)
	lib.notify({
        description = msg,
        position = position or 'center-left',
        type = type,
        duration = time
    })
end

GetIdentifier = function()
    local result = promise:new()
    ESX.TriggerServerCallback('elder_dealership:server:getIdentifier', function(data) 
		result:resolve(data)  
    end)
    return Citizen.Await(result)
end

IsOwner = function(showroom)
    return GetIdentifier() == Config.ShowRooms[showroom].owner
end

GetShowRooms = function()
    local result = promise:new()
    ESX.TriggerServerCallback('elder_dealership:server:getShowRooms', function(data) 
		result:resolve(data)  
    end)
    return Citizen.Await(result)
end

GetOwnedVehicles = function(plate)
    local result = promise:new()
    ESX.TriggerServerCallback('elder_dealership:server:getOwnedVehicles', function(data) 
		result:resolve(data)  
    end)
    return Citizen.Await(result)
end

GetTransactions = function(showroom)
    local result = promise:new()
    ESX.TriggerServerCallback('elder_dealership:server:getTransactions', function(data) 
		result:resolve(data)  
    end, showroom)
    return Citizen.Await(result)
end

GetAccount = function(showroom)
    local result = promise:new()
    ESX.TriggerServerCallback('elder_dealership:server:getAccount', function(data) 
		result:resolve(data)  
    end, showroom)
    return Citizen.Await(result)
end

CreateShowRooms = function()
    for k,v in pairs(Config.ShowRooms) do
        ShowRoomsLocations[k] = {}
        local owner = IsOwner(k)
        for loc, locdata in pairs(v.spawnlocations) do
            ShowRoomsLocations[k][loc] = {}
            CreateShowroomLocation(k, loc, locdata.coords, owner, locdata.distance)
        end
    end
end
 
local ShowTextUI = {}

CreateShowroomLocation = function(showroom, location, coords, owner, distance)
    local loc = lib.points.new(coords.xyz, 40, {owner = owner})
    function loc:onEnter()
        if ShowRooms[showroom][location] then
            local props = ShowRooms[showroom][location].props
            ShowRoomsLocations[showroom][location].vehicle = SpawnVehicle(props, coords)
        end
    end
    function loc:onExit()
        if DoesEntityExist(ShowRoomsLocations[showroom][location].vehicle) then
            DeleteEntity(ShowRoomsLocations[showroom][location].vehicle)
        end 
    end
    function loc:nearby()
        if ShowRooms[showroom][location] and not ShowRoomsLocations[showroom][location].vehicle then
            ShowRoomsLocations[showroom][location].vehicle = SpawnVehicle(ShowRooms[showroom][location].props, coords)
        end
        if self.currentDistance < distance then
            if not ShowTextUI[showroom..location] then
                ShowTextUI[showroom..location] = true
                local locationinfo = ShowRooms[showroom][location]
                local str = 'Welcome to '.. Config.ShowRooms[showroom].name ..'  \n ' .. 
                (locationinfo and 'Title : '.. locationinfo.title ..'  \n' or '') ..
                (locationinfo and 'Description : '.. locationinfo.description ..'  \n ' or '') ..
                (locationinfo and 'Model : '.. GetDisplayNameFromVehicleModel(locationinfo.props.model) ..'  \n ' or '') ..
                (locationinfo and 'Price $: '.. ESX.Math.GroupDigits(locationinfo.price) ..'  \n ' or '') ..
                (self.owner and '[E] Manage location' or locationinfo and '[E] Buy Vehicle' or '')

                lib.showTextUI(str, {
                    position = "bottom-center", 
                    icon = 'car',
                    iconAnimation = 'beat',
                })  
            end
            if IsControlJustReleased(0, 38) then
                lib.hideTextUI()
                if self.owner then
                    ManageLocation(showroom,location)
                else
                    BuyVehicle(showroom,location)
                end
            end
        else
            if ShowTextUI[showroom..location] == true then 
                lib.hideTextUI()
                ShowTextUI[showroom..location] = false
            end
        end
    end
    ShowRoomsLocations[showroom][location].point = loc
end

CreateBossMenu = function()
    for k,v in pairs(Config.ShowRooms) do
        if IsOwner(k) then
            local coords = v.bossmenu
            local boss = lib.points.new(coords.xyz, 10, {})
            function boss:nearby()
                DrawMarker(21, self.coords.x, self.coords.y, self.coords.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 1.0, 1.0, 1.0, 255, 0, 0, 200, false, false, 2, false, false, false, false)
                if self.currentDistance < 2.0 then
                    if not ShowTextUI[k..'boss'] then
                        ShowTextUI[k..'boss']  = true
                        lib.showTextUI('[E] Boss Menu')
                    end
                    
                    if IsControlJustPressed(0, 38) then
                        BossMenu(k)
                    end
                else
                    if ShowTextUI[k..'boss']  == true then 
                        lib.hideTextUI()
                        ShowTextUI[k..'boss']  = false
                    end
                end
            end
        end
    end
end

ManageLocation = function(showroom, location)
    local menuOptions = {}
    local locationinfo = ShowRooms[showroom][location]
    if locationinfo then
        table.insert(menuOptions, 
            {title = 'Remove Vehicle', 
            icon = 'fa-car', 
            onSelect = function() RemoveVehicle(showroom, location) end
        })
    else
        local vehicles = GetOwnedVehicles()
        for k,v in pairs(vehicles) do 
            local props = json.decode(v.vehicle)
            if IsModelInCdimage(joaat(props.model)) and not VehicleAlreadySpawned(v.plate) then
                table.insert(menuOptions, 
                    {title = GetDisplayNameFromVehicleModel(props.model) .. ' | ' .. v.plate, 
                    icon = 'fa-car', 
                    onSelect = function() AddVehicle(showroom, location, v.plate, GetDisplayNameFromVehicleModel(props.model)) end
                })
            end
        end
    end
    lib.registerContext({
        id = 'ds_manage_loc_menu',
        title = 'Manage Location',
        position = 'bottom-center',
        options = menuOptions,
    })
    lib.showContext('ds_manage_loc_menu')
end

BossMenu = function(showroom)
    if not IsOwner(showroom) then 
        return
    end
    local menuOptions = {}
    table.insert(menuOptions, {   
        title = 'Account : $' .. ESX.Math.GroupDigits(GetAccount(showroom)), 
        icon = 'fa-money-bill-transfer', 
        onSelect = function() WithdrawMoney(showroom) end
    })
    table.insert(menuOptions, {   
        title = 'Transactions', 
        icon = 'fa-car', 
        onSelect = function() TransactionsMenu(showroom) end
    })
    lib.registerContext({
        id = 'ds_manage_menu',
        title = Config.ShowRooms[showroom].name,
        position = 'bottom-center',
        options = menuOptions,
    })
    lib.showContext('ds_manage_menu')
end

TransactionsMenu = function(showroom)
    if not IsOwner(showroom) then 
        return
    end
    local menuOptions = {}
    local Transactions = GetTransactions(showroom)
    for k,v in pairs(Transactions) do 
        table.insert(menuOptions, {   
            title = 'Model : '..v.model..' | plate : '..v.plate..' | price : $'..ESX.Math.GroupDigits(v.price)..'' , 
            icon = 'fa-car', 
            onSelect = function() WithdrawMoney(showroom) end
        })
    end
    
    lib.registerContext({
        id = 'ds_manage_t_menu',
        title = Config.ShowRooms[showroom].name,
        position = 'bottom-center',
        menu = 'ds_manage_menu',
        options = menuOptions,
    })
    lib.showContext('ds_manage_t_menu')
end

WithdrawMoney = function(showroom)
    TriggerServerEvent('elder_dealership:server:withdrawMoney', showroom)
end

AddVehicle = function(showroom, location, plate, model)
	local input = lib.inputDialog(Config.ShowRooms[showroom].name, {
		{ type = 'input', label = 'Vehicle Model', disabled = true, default = model},
		{ type = 'input', label = 'Vehicle Plate', disabled = true, default = plate},
		{ type = 'input', label = 'Title', required = true, min = 5, max = 30},
		{ type = 'textarea', label = 'Description', required = true, min = 5, max = 100},
		{ type = 'number', min = 1, label = 'Price', required = true }
	}, { allowCancel = true })
	if not input then return end
    TriggerServerEvent('elder_dealership:server:addVehicle', showroom, location, plate, input[3], input[4], input[5])
end

RemoveVehicle = function(showroom, location)
    TriggerServerEvent('elder_dealership:server:removeVehicle', showroom, location)
end

BuyVehicle = function(showroom,location)
    if not ShowRooms[showroom][location] then
        return Notify('Vehicle is sold', 'error')
    end
    local alert = lib.alertDialog({
        header = 'Do you want to purshase this vehicle?',
        content = 'Price : $' .. ESX.Math.GroupDigits(ShowRooms[showroom][location].price),
        centered = true,
        cancel = true,
        labels = {
            cancel=  "Pay",
            confirm=  "Decline",
        }
    })

    if alert == 'cancel' then
        if not ShowRooms[showroom][location] then
            return Notify('Vehicle is sold', 'error')
        end
        local locationinfo = ShowRooms[showroom][location]
        TriggerServerEvent('elder_dealership:server:buyVehicle', showroom, location, locationinfo.plate, GetDisplayNameFromVehicleModel(locationinfo.props.model))
    end
end

SpawnVehicle = function(props, coords)
    lib.requestModel(props.model, 5000)
    local vehicle = CreateVehicle(props.model, coords.x, coords.y, coords.z, coords.w, false, false)
    SetEntityHeading(vehicle, coords.w)
    SetVehicleOnGroundProperly(vehicle)
    ESX.Game.SetVehicleProperties(vehicle, props)
    SetVehicleDoorsLocked(vehicle, 10)
    SetVehicleFixed(vehicle)
    SetEntityInvincible(vehicle, true)
    SetVehicleCanBreak(vehicle, false)  
	SetVehicleEngineHealth(vehicle, 1000.0)
	SetVehiclePetrolTankHealth(vehicle, 1000.0)
    FreezeEntityPosition(vehicle, true)
    return vehicle
end

VehicleAlreadySpawned = function(plate)
    for k,v in pairs(ShowRooms) do 
        for loc, data in pairs(v) do 
            if data and data.plate and data.plate == plate then
                return true
            end
        end
    end
    return false
end

RegisterNetEvent("elder_dealership:client:notify")
AddEventHandler("elder_dealership:client:notify", function(msg, type) 
	Notify(msg, type)
end)

RegisterNetEvent('elder_dealership:client:updateShowRooms')
AddEventHandler('elder_dealership:client:updateShowRooms', function(data, showroom, location)
    if not PlayerLoaded then return end
    if showroom and location and not data[showroom][location] then
        if DoesEntityExist(ShowRoomsLocations[showroom][location].vehicle) then
            DeleteEntity(ShowRoomsLocations[showroom][location].vehicle)
        end
        ShowRoomsLocations[showroom][location].vehicle = false
    end
    ShowRooms = data
end)

RegisterNetEvent("elder_dealership:client:vehicleBough")
AddEventHandler("elder_dealership:client:vehicleBough", function(showroom, plate, props) 
	lib.requestModel(props.model, 1000)
    local coords = Config.ShowRooms[showroom].buyerspawnlocation
    local vehicle = CreateVehicle(props.model, coords.x, coords.y, coords.z, coords.w, true, false)
    ESX.Game.SetVehicleProperties(vehicle, props)
    SetVehicleFixed(vehicle)
	SetVehicleEngineHealth(vehicle, 1000.0)
	SetVehiclePetrolTankHealth(vehicle, 1000.0)
    NetworkFadeInEntity(vehicle, true, true)
	SetModelAsNoLongerNeeded(props.model)
	TaskWarpPedIntoVehicle(PlayerPedId(), vehicle, -1)
    SetEntityAsMissionEntity(vehicle, true, true)
    RequestCollision(coords, vehicle)
    CheckSpawnArea(vehicle, coords.xyz)
end)

AddEventHandler('onResourceStop', function(resource)
	if resource == GetCurrentResourceName() then
		for k,v in pairs(ShowRoomsLocations) do 
            for loc, data in pairs(v) do 
                local point = data.point 
                local vehicle = data.vehicle
                point:remove()
                if vehicle and DoesEntityExist(vehicle) then
                    DeleteEntity(vehicle)
                end
            end
        end
	end
end)

function RequestCollision(coords, vehicle)
    RequestCollisionAtCoord(coords.x, coords.y, coords.z)
    while not HasCollisionLoadedAroundEntity(vehicle) do
        RequestCollisionAtCoord(coords.x, coords.y, coords.z)
        Wait(0)
    end
end

function CheckSpawnArea(veh, coords)
    local new_coords = coords
    local vehicle = GetClosestVehicle_pileupcheck(new_coords, 3, veh)
    if vehicle then
        new_coords = new_coords + GetEntityForwardVector(veh) * 6.0
        SetEntityCoords(veh, new_coords.x, new_coords.y, new_coords.z)
    else
        new_coords = nil
        return
    end

    local vehicle = GetClosestVehicle_pileupcheck(new_coords, 3, veh)
    if vehicle then
        new_coords = new_coords + GetEntityForwardVector(veh) * 6.0
        SetEntityCoords(veh, new_coords.x, new_coords.y, new_coords.z)
    else
        new_coords = nil
        return
    end

    local vehicle = GetClosestVehicle_pileupcheck(new_coords, 3, veh)
    if vehicle then
        new_coords = new_coords + GetEntityForwardVector(veh) * 6.0
        SetEntityCoords(veh, new_coords.x, new_coords.y, new_coords.z)
    else
        new_coords = nil
        return
    end

    local vehicle = GetClosestVehicle_pileupcheck(new_coords, 3, veh)
    if vehicle then
        new_coords = new_coords + GetEntityForwardVector(veh) * 6.0
        SetEntityCoords(veh, new_coords.x, new_coords.y, new_coords.z)
    else
        new_coords = nil
        return
    end
    new_coords = nil
end

function GetClosestVehicle_pileupcheck(coords, distance, myveh)
    local vehicles = GetGamePool('CVehicle')
    for i = 1, #vehicles, 1 do
        local vehicleCoords = GetEntityCoords(vehicles[i])
        local dist = #(coords-vehicleCoords)
        if dist < distance and vehicles[i] ~= myveh then
            return true
        end
    end
    return false
end
