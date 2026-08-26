
Citizen.CreateThread(function()
    for k,v in pairs(Config.FoodDelivery.restaurants) do
        ESX.Streaming.RequestModel(v.ped)
        G_RestaurantNPC[k] = CreatePed(5, GetHashKey(v.ped), v.coords.x, v.coords.y, v.coords.z-1, v.coords.w, false, true)
        PlaceObjectOnGroundProperly(G_RestaurantNPC[k])
        TaskStartScenarioInPlace(G_RestaurantNPC[k], "WORLD_HUMAN_CLIPBOARD", 0, true)
        FreezeEntityPosition(G_RestaurantNPC[k], true)
        SetEntityInvincible(G_RestaurantNPC[k], true)
        SetBlockingOfNonTemporaryEvents(G_RestaurantNPC[k], true)
    end
end)

-- Events

RegisterNetEvent('elder_jobs:client:food_delivery_job')
AddEventHandler('elder_jobs:client:food_delivery_job', function()
    if ESX.Game.IsSpawnPointClear(Config.FoodDelivery.vehicle_pos, 5) then
        ESX.Game.SpawnVehicle(Config.FoodDelivery.vehicle, Config.FoodDelivery.vehicle_pos, Config.FoodDelivery.vehicle_pos.w , function(vehicle)
            G_Vehicle = vehicle
            local inVehicle = false
            G_CurrentJob = "food_delivery"
            Citizen.CreateThread(function() 
                while G_CurrentJob and not inVehicle do 
                    Citizen.Wait(5)
                    DrawMarker(20, Config.FoodDelivery.vehicle_pos.x, Config.FoodDelivery.vehicle_pos.y, Config.FoodDelivery.vehicle_pos.z+1, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 1.0, 1.0, 1.0, 0, 0, 255, 150, true, true, 2, false, false, false, false)
                    MissionAlert("Get into the ~y~vehicle~s~")
                    if IsPedInAnyVehicle(GetPlayerPed(-1)) then
                        local veh = GetVehiclePedIsIn(GetPlayerPed(-1),false)
                        if veh == vehicle then
                            inVehicle = true
                            Citizen.Wait(1000)
                            StartJob(vehicle)
                        end
                    end
                end
            end)
        end)
    else
        Notify('Please clear the spawn point', 'warning')
    end  
end)


RegisterNetEvent('elder_jobs:client:leave_food_job')
AddEventHandler('elder_jobs:client:leave_food_job', function()
    if not G_CurrentJob then return end
    G_CurrentJob = nil 
    if G_PickUpBlip then RemoveBlip(G_PickUpBlip) end
    if G_DeliveryBlip then RemoveBlip(G_DeliveryBlip) end
    if G_Object then DeleteEntity(G_Object) end
    ESX.Game.DeleteVehicle(G_Vehicle)
    Notify('You have left the job', 'success')
    TriggerServerEvent('elder_jobs:server:food_job:pay')
    --MissionSuccess("~y~service ended~s~", "see you next time+")
end)


-- function

function StartJob(vehicle)
    local restaurant_location = Config.FoodDelivery.restaurants[math.random(1, # Config.FoodDelivery.restaurants)].coords
    G_PickUpBlip = CreateBlip(restaurant_location, 525,5,"Restaurant")
    local delivery_received = false
    Citizen.CreateThread(function()
        local wait
        while G_CurrentJob and not delivery_received do
            local ped = PlayerPedId()
            local ped_coords = GetEntityCoords(ped)
            if GetDistanceBetweenCoords(ped_coords, restaurant_location,true) <= 1.5 then
                wait = 1
                MissionAlert('Press ~y~E~s~ to collect ~y~food~s~ from waiter')
                if IsControlJustReleased(0, 38) then
                    delivery_received = true
                    RemoveBlip(G_PickUpBlip)
                    local delivery_count = Config.FoodDelivery.delivery_count
                    StartMissions(vehicle,delivery_count, 0)
                end
            else
                MissionAlert('Drive to the ~y~restaurant~s~')
                wait = 1000
            end
            Citizen.Wait(wait)
        end
    end)
end

function StartMissions(vehicle, max_count, current)
    local delivery_location = Config.FoodDelivery.delivery_locations[math.random(1, #Config.FoodDelivery.delivery_locations)]
    G_DeliveryBlip = CreateBlip(delivery_location, 162,81,"Customer")
    local delivered = false
    local collected = false
    local paid = false

    Citizen.CreateThread(function()
        while G_CurrentJob and not delivered do
            local wait = 0
            local ped = PlayerPedId()
            local ped_coords = GetEntityCoords(ped)
            local vehicle_coords = GetWorldPositionOfEntityBone(vehicle, GetEntityBoneIndexByName(vehicle, "engine"))
            local arrived = false
            local offVehicle = false
            if GetDistanceBetweenCoords(delivery_location, vehicle_coords,true) <= 40.0 and not collected then
                wait = 1
                arrived = true
                if not offVehicle then
                    MissionAlert('Get out of the ~y~vehicle~s~')
                end
                if not IsPedInAnyVehicle(GetPlayerPed(-1)) then
                    offVehicle = true
                end
                if offVehicle then
                    DrawMarker(20, vehicle_coords.x, vehicle_coords.y, vehicle_coords.z+1.0, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 0.5, 0.5, 0.5, 255, 215, 0, 200, true, true, 2, false, false, false, false)
                end
            end
            if GetDistanceBetweenCoords(ped_coords, vehicle_coords,true) <= 1.5 and not collected and arrived and offVehicle then
                wait = 1
                --ESX.ShowHelpNotification('Press ~b~~h~[E]~h~~s~ to collect~b~~h~ food ~h~~s~ from vehicle')
                MissionAlert('Press ~y~E~s~ to collect ~b~food~s~ from vehicle')
                if IsControlJustReleased(0, 38) then
                    collected = true
                    TriggerServerEvent('elder_jobs:server:food_job:collected', delivery_location)
                    PlayCollectFoodAnim()
                end
            end

            if GetDistanceBetweenCoords(ped_coords, delivery_location,true) <= 25.0 and collected then
                wait = 1
                DrawMarker(30, delivery_location.x, delivery_location.y, delivery_location.z , 0.0, 0.0, 0.0, 0, 0.0, 0.0, 1.0, 1.0, 1.0, 0, 120, 0, 200, false, true, 2, false, false, false, false)
            end
            if GetDistanceBetweenCoords(ped_coords, delivery_location,true) <= 1.5 and collected then
                wait = 1
                --ESX.ShowHelpNotification('Press ~b~~h~[E]~h~~s~ to deliver~b~~h~ food ~h~~s~')
                MissionAlert('Press ~y~E~s~ to deliver ~y~food~s~')
                if IsControlJustReleased(0, 38) and not paid then
                    paid = true
                    DeleteEntity(G_Object)
                    ClearPedTasks(PlayerPedId())
                    delivered = true
                    RemoveBlip(G_DeliveryBlip)
                    TriggerServerEvent('elder_jobs:server:food_job:pay_tip')
                end
            end
            if wait == 0 then 
                MissionAlert('Drive to the ~y~customer~s~')
                wait = 1000
            end
            Citizen.Wait(wait)
        end

        if G_CurrentJob and delivered and current + 1 < max_count then
            StartMissions(vehicle, max_count, current + 1)
        end
        if current + 1 == max_count and G_CurrentJob then
            Notify('go to next restaurant to get more deliveries', 'success')
            StartJob(vehicle)
        end
    end)
end


function PlayCollectFoodAnim()
    if IsPedArmed(PlayerPedId(), 7) then
        SetCurrentPedWeapon(PlayerPedId(), joaat('WEAPON_UNARMED'), true)
    end
    ClearPedTasks(PlayerPedId())
    if not LoadAnim("move_weapon@jerrycan@generic") then return end
    TaskPlayAnim(PlayerPedId(), "move_weapon@jerrycan@generic", "idle", 5.0, 5.0, -1, 51, 0, false, false,false)
    RemoveAnimDict("move_weapon@jerrycan@generic")
    AddPropToPlayer("prop_food_bs_bag_01", 57005, 0.3300,0.0,-0.0300, 0.0017365,-79.9999997,110.0651988, "props")
end