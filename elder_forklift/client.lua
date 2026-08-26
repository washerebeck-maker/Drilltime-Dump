ESX = exports['es_extended']:getSharedObject()

local OnDuty = false
local JobVehicle = nil
local InProgress = false
local CurrentObject = nil
local Blip = nil

function Notify(msg, type)
	lib.notify({
        description = msg,
        position = position or 'center-left',
        type = type,
        duration = 10000
    })
end

RegisterNetEvent("elder_forklift:client:notify")
AddEventHandler("elder_forklift:client:notify", function(msg, type) 
	Notify(msg, type)
end)

Citizen.CreateThread(function()
    local coords = Config.Location.npc_coords
    local model = Config.Location.npc

    ESX.Streaming.RequestModel(model)
    NPC = CreatePed(5, GetHashKey(model), coords.x, coords.y, coords.z-0.9, coords.w, false, true)
    PlaceObjectOnGroundProperly(NPC)
    FreezeEntityPosition(NPC, true)
    SetEntityInvincible(NPC, true)
    SetBlockingOfNonTemporaryEvents(NPC, true)

    local blip = AddBlipForCoord(coords)
	SetBlipSprite(blip,317)
	SetBlipColour(blip,1)
	SetBlipAlpha(blip,250)
	SetBlipScale(blip,1.0)
    SetBlipAsShortRange(blip,true)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString("ForKlift Company")
	EndTextCommandSetBlipName(blip)

    local point = lib.points.new({ coords = coords, distance = 2.0})
    function point:nearby()
        if IsControlJustPressed(0, 38) then        
            lib.hideTextUI()
            Duty()
        end
    end
    function point:onEnter()
        lib.showTextUI(OnDuty and '[E] Clock Out.' or '[E] Clock In.', { position = "right-center", icon = 'fa-dolly', iconColor = OnDuty and 'red' or 'green'}) 
    end
    function point:onExit()
        lib.hideTextUI()
    end

    local delivery_location = Config.Location.delivery_location
    local delivery = lib.points.new({ coords = delivery_location, distance = 50.0})
    local showTextUI = false
    function delivery:nearby()
        if true or OnDuty then
            DrawMarker(1, delivery_location.x, delivery_location.y, delivery_location.z - 1.5, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 8.0, 8.0, 1.0, 255, 215, 0, 150, true, true, 2, false, false, false, false)
            DrawMarker(24, delivery_location.x, delivery_location.y, delivery_location.z + 1.0 , 0.0, 0.0, 0.0, 0, 0.0, 0.0, 1.0, 1.0, 1.0, 255, 215, 0, 255, true, true, 2, false, false, false, false)
            if self.currentDistance < 5.0 then
                if not showTextUI then
                    showTextUI = true
                    lib.showTextUI('[E] To Deliver Package')
                end
                if IsControlJustPressed(0, 38) then
                    lib.hideTextUI()
                    DeliverPackage()
                end
            else
                if showTextUI == true then 
                    lib.hideTextUI()
                    showTextUI = false
                end
            end
        end
    end

end)

Duty = function()
    if not OnDuty and not CanWork() then
        Notify('No work is available now', 'error')
        return
    end
    OnDuty = not OnDuty
    if OnDuty then
        Work()
    else
        ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
            TriggerEvent('skinchanger:loadSkin', skin)
        end)
        Notify('You finished all tasks.')
        TriggerServerEvent('elder_forklift:server:endWork')
        DeleteObject(CurrentObject)
        DeleteVehicle(JobVehicle)
    end
end

function WorkClothes()
    local gender = GetEntityModel(cache.ped)
	if gender == GetHashKey('mp_m_freemode_01') then
		for k, v in pairs(Config.Clothes.male.components) do
			SetPedComponentVariation(cache.ped, v['component_id'], v['drawable'], v['texture'], 0)
		end
        for k, v in pairs(Config.Clothes.male.props) do
			ClearPedProp(cache.ped, v['prop_id'])
            SetPedPropIndex(cache.ped, v['prop_id'], v['drawable'], v['texture'], true)
		end  
	else
		for k, v in pairs(Config.Clothes.female.components) do
			SetPedComponentVariation(PlayerPed, v['component_id'], v['drawable'], v['texture'], 0)
		end
        for k, v in pairs(Config.Clothes.female.props) do
			ClearPedProp(cache.ped, v['prop_id'])
            SetPedPropIndex(cache.ped, v['prop_id'], v['drawable'], v['texture'], true)
		end    
	end
end

Work = function()
    local vehicle_coords = Config.Location.vehicle_coords
    local vehicle_model = Config.Location.vehicle
    if ESX.Game.IsSpawnPointClear(vehicle_coords, 5) then
        ESX.Game.SpawnVehicle(vehicle_model, vehicle_coords.xyz, vehicle_coords.w , function(vehicle)
            JobVehicle = vehicle
            local in_vehicle = false
            TriggerServerEvent('elder_forklift:server:startWork')
            WorkClothes()
            Citizen.CreateThread(function() 
                while OnDuty and not in_vehicle do 
                    Citizen.Wait(1)
                    DrawMarker(20, vehicle_coords.x, vehicle_coords.y, vehicle_coords.z+2.5, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 1.0, 1.0, 1.0, 0, 0, 255, 250, true, true, 2, false, false, false, false)
                    MissionAlert("Get into the ~y~vehicle~s~")
                    if IsPedInAnyVehicle(cache.ped) then
                        local veh = GetVehiclePedIsIn(cache.ped,false)
                        if veh == vehicle then
                            in_vehicle = true
                            Citizen.Wait(1000)
                            StartWork()
                        end
                    end
                end
            end)
        end)
    else
        OnDuty = false
        Notify('A vehicle is blocking spawn location.', 'warning')
    end
end

StartWork = function()
    local count = math.random(Config.Deliveries.min, Config.Deliveries.max)
    local total = count
    local InProgress = true
    while InProgress and OnDuty do
        Wait(1)
        if not CurrentObject and count == 0 then 
            Notify('Work finished, clock out to get your paycheck.')
            break
        end
        if not CurrentObject then
            local coords = Config.Deliveries.locations[math.random(1,#Config.Deliveries.locations)]
            CurrentObject = CreateObject(joaat('prop_boxpile_06b'), coords.x, coords.y, coords.z, false, false, false)
            PlaceObjectOnGroundProperly(CurrentObject)
            CreateBlip(coords)
            count = count - 1
        end
        if CurrentObject then
            local coords = GetEntityCoords(CurrentObject)
            MissionAlert(('Deliver the ~r~package~s~ (%s/%s)'):format(total-count,total))
            DrawMarker(20, coords.x, coords.y, coords.z+2.5, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 0.5, 0.5, 0.5, 255, 0, 0, 250, true, true, 2, false, false, false, false)
        end
    end
    InProgress = false
end

DeliverPackage = function()
    if not CurrentObject then
        Notify('No package available.', 'error')
        return
    end
    local coords = GetEntityCoords(CurrentObject)
    local distance = #(coords - Config.Location.delivery_location)
    if distance <= 2.0 then
        DeleteObject(CurrentObject)
        CurrentObject = nil
        RemoveBlip(Blip)
        TriggerServerEvent('elder_forklift:server:onTaskEnded')
    else
        Notify('you are out of delivery zone', 'error')
    end
end

function MissionAlert(text)
    ClearPrints()
    SetTextEntry_2("STRING")
    AddTextComponentString(text)
    DrawSubtitleTimed(1000, 1)
end

function CreateBlip(coords)
    Blip = AddBlipForCoord(coords)
	SetBlipSprite(Blip,409)
	SetBlipColour(Blip,1)
	SetBlipAlpha(Blip,250)
	SetBlipScale(Blip,0.75)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString("package")
	EndTextCommandSetBlipName(Blip)
end

AddEventHandler('onResourceStop', function(resource)
	if resource == GetCurrentResourceName() then
		DeleteObject(CurrentObject)
        DeleteVehicle(JobVehicle)
	end
end)

CanWork = function()
    local result = promise:new()
    ESX.TriggerServerCallback('elder_forklift:server:canWork', function(data) 
		result:resolve(data)  
    end)
    return Citizen.Await(result)
end