local NPC = nil
local WorkVehicle = nil
local WorkInProgress = false
local Locations = {}
local IsPlayerInVehicle = false
local FinishedTasks = 0
local HasBag = false
local CanTakeBag = true
local GarbageObject = nil
local WorkVehicleBlip = nil
local MaxGarbageTasks = 0
local EndedJobReason = {WorkVehicleNotFound = 0, AllTasksDone = 1, ClockOut = 2}

local function GetRandomLocations(count)
    local locations = table.clone(Config.GarbageJob.Locations)
    local result = {}
    for i = 1, count, 1 do
        local index = math.random(1, #locations)
        result[#result + 1] = locations[index]
        table.remove(locations,index)
    end
    return result
end

CreateWorkVehicleBlip = function(coords)
    WorkVehicleBlip = AddBlipForCoord(coords)
    SetBlipSprite(WorkVehicleBlip,318)
    SetBlipColour(WorkVehicleBlip,61)
    SetBlipAlpha(WorkVehicleBlip,250)
    SetBlipScale(WorkVehicleBlip,1.0)
    --[[ SetBlipAsShortRange(blip,true) ]]
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("garbage vehicle")
    EndTextCommandSetBlipName(WorkVehicleBlip)
end

local function MakeLocations(locations)
    for k,v in ipairs(locations) do
        local coords = v
        Locations[k] = {}
        Locations[k].coords = coords
        Locations[k].done = false
        local blip = AddBlipForCoord(coords)
        SetBlipSprite(blip,318)
        SetBlipColour(blip,1)
        SetBlipAlpha(blip,250)
        SetBlipScale(blip,0.7)
        SetBlipAsShortRange(blip,true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("garbage")
        EndTextCommandSetBlipName(blip)
        Locations[k].blip = blip

        local point = lib.points.new({ coords = coords, distance = 2.0, index = k})
        function point:nearby()
            if Locations[self.index].done == false and not HasBag then
                if not IsPlayerInVehicle then
                    if IsControlJustPressed(0, 38) then
                        print('task started', self.index)
                        lib.hideTextUI()
                        StartGarbageTask(self.index)
                    end
                else
                    MissionAlert("Get out of the ~r~vehicle~s~")
                end
            end
        end
        function point:onEnter()
            if Locations[self.index].done == false and not HasBag then
                lib.showTextUI('[E] Grab a garbage bag.', { position = "right-center", icon = 'fa-sack-xmark', iconColor = 'green'})
            end
        end
        function point:onExit()
            lib.hideTextUI()
        end
        Locations[k].point = point  
    end
end

local function CanWork()
    local result = promise:new()
    ESX.TriggerServerCallback('elder_drilltime:garbagejob:server:can_work', function(data) 
        result:resolve(data)  
    end)
    return Citizen.Await(result)
end

local function WorkClothes()
    local gender = GetEntityModel(PlayerPedId())
	local PlayerPed = PlayerPedId()
	if gender == GetHashKey('mp_m_freemode_01') then
		for k, v in pairs(Config.GarbageJob.Clothes.male.components) do
			SetPedComponentVariation(PlayerPed, v['component_id'], v['drawable'], v['texture'], 0)
		end
        for k, v in pairs(Config.GarbageJob.Clothes.male.props) do
			ClearPedProp(PlayerPedId(), v['prop_id'])
            SetPedPropIndex(PlayerPedId(), v['prop_id'], v['drawable'], v['texture'], true)
		end  
	else
		for k, v in pairs(Config.GarbageJob.Clothes.female.components) do
			SetPedComponentVariation(PlayerPed, v['component_id'], v['drawable'], v['texture'], 0)
		end
        for k, v in pairs(Config.GarbageJob.Clothes.female.props) do
			ClearPedProp(PlayerPedId(), v['prop_id'])
            SetPedPropIndex(PlayerPedId(), v['prop_id'], v['drawable'], v['texture'], true)
		end    
	end
end

local function ClockIn()
    if WorkInProgress then 
        return Notify("You are already clocked in.", "error")
    end
    if not CanWork() then
        return Notify("The garbage company is not hiring workers right now.", "warning")
    end
    GarbageJobWork()
end

local function ClockOut()
    if not ClockedOut then 
        ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
            TriggerEvent('skinchanger:loadSkin', skin)
        end)
        OnWorkFinished(EndedJobReason.ClockOut)
        ClockedOut = true
        ESX.Game.DeleteVehicle(WorkVehicle)
        TriggerServerEvent('elder_drilltime:garbagejob:server:pay_job')
    end
end

local function ClockMenu()
    local menuOptions = {}  
    table.insert(menuOptions, {title = 'Clock In', description = 'Get job clothes and start work.', arrow = true, icon = 'fa-dumpster', iconColor = 'green', onSelect = function() ClockIn() end})
    table.insert(menuOptions, {title = 'Clock Out', description = 'Get civ clothes and finish work.', arrow = true, icon = 'fa-circle-left', iconColor = 'red', onSelect = function() ClockOut() end})
    lib.registerContext({
        id = 'gj_clockin_menu',
        title = '🗑 Garbage Company',
        options = menuOptions,
    })
    lib.showContext('gj_clockin_menu')
end

Citizen.CreateThread(function()
    local coords = Config.GarbageJob.ClockIn.Coords
    local model = Config.GarbageJob.ClockIn.Model
    --npc
    ESX.Streaming.RequestModel(model)
    NPC = CreatePed(5, GetHashKey(model), coords.x, coords.y, coords.z-0.9, coords.w, false, true)
    PlaceObjectOnGroundProperly(NPC)
    FreezeEntityPosition(NPC, true)
    SetEntityInvincible(NPC, true)
    SetBlockingOfNonTemporaryEvents(NPC, true)
    --blip
    local blip = AddBlipForCoord(coords)
	SetBlipSprite(blip,318)
	SetBlipColour(blip,2)
	SetBlipAlpha(blip,250)
	SetBlipScale(blip,1.0)
    SetBlipAsShortRange(blip,true)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString("Garbage Company")
	EndTextCommandSetBlipName(blip)
end)

Citizen.CreateThread(function()
    local coords = Config.GarbageJob.ClockIn.Coords
    local markerTextUi = false
    while true do
        local sleep
        local distance = GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), coords, true)
        if distance <= 2.0 then
            sleep = 1
            if not markerTextUi then
                lib.showTextUI('[E] to clock in.', { position = "right-center", icon = 'fa-dumpster', iconColor = 'green'})
                markerTextUi = true
            end
            if IsControlJustPressed(0, 38) then
                lib.hideTextUI()
                markerTextUi = false
                ClockMenu()
            end
        else
            sleep = (distance > 2.0 and distance <= 20.0) and 1000 or 2000
            if markerTextUi then
                markerTextUi = false
                lib.hideTextUI()
            end
        end
        Wait(sleep)
    end
end)

GarbageJobWork = function()
    local vehicle_coords = Config.GarbageJob.WorkVehicle.Coords
    local vehicle_model = Config.GarbageJob.WorkVehicle.Model
    if ESX.Game.IsSpawnPointClear(vehicle_coords, 5) then
        ESX.Game.SpawnVehicle(vehicle_model, vehicle_coords.xyz, vehicle_coords.w , function(vehicle)
            WorkVehicle = vehicle
            WorkInProgress = true
            local in_vehicle = false
            TriggerServerEvent('elder_drilltime:garbagejob:server:start_work')
            WorkClothes()
            Citizen.CreateThread(function() 
                while WorkInProgress and not in_vehicle do 
                    Citizen.Wait(5)
                    DrawMarker(20, vehicle_coords.x, vehicle_coords.y, vehicle_coords.z+3.5, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 1.0, 1.0, 1.0, 0, 255, 0, 150, true, true, 2, false, false, false, false)
                    MissionAlert("Get into the ~y~vehicle~s~")
                    if IsPedInAnyVehicle(GetPlayerPed(-1)) then
                        local veh = GetVehiclePedIsIn(GetPlayerPed(-1),false)
                        if veh == vehicle then
                            in_vehicle = true
                            Citizen.Wait(1000)
                            StartGarbageJobWork()
                        end
                    end
                end
            end)
        end)
    else
        Notify('Please clear the spawn point', 'warning')
    end
end

StartGarbageJobWork = function()
    local task_count = math.random(Config.GarbageJob.MinTasksCount, #Config.GarbageJob.Locations)
    local locations = GetRandomLocations(task_count)
    MaxGarbageTasks = task_count
    MakeLocations(locations)
    TriggerServerEvent('elder_drilltime:garbagejob:server:sync_locations', Locations)
    StartGetPlayerDataThread(task_count)
    StartMarkersThread()
end

ResetTask = function(index)
    Locations[index].done = true
    FinishedTasks = FinishedTasks + 1
    RemoveBlip(Locations[index].blip)
    local point = Locations[index].point
    point:remove()
end

StartGarbageTask = function(index)
    ResetTask(index)
    print('started')
    TakeAnim()
    CanTakeBag = false
    HasBag = true
    StartDeliverBagThread(index)
end

StartGetPlayerDataThread = function(max_count)
    CreateThread(function()
        while WorkInProgress do
            IsPlayerInVehicle = IsPedInAnyVehicle(GetPlayerPed(-1))
            MissionAlert("Garbage job : ~y~"..FinishedTasks.."/"..max_count.."~s~")
            Wait(1000)
        end
    end)
end

StartMarkersThread = function()
    CreateThread(function()
        while WorkInProgress do
            for k,v in pairs(Locations) do
                if Locations[k].done == false then
                    DrawMarker(2, v.coords.x,v.coords.y,v.coords.z+1.0 , 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.5, 0.5, 0.5, 255, 0, 0, 255, 1, 0, 0, 0, 0, 0, 0)
                end 
            end
            Wait(1)
        end
    end)
end

StartDeliverBagThread = function(index)
    CreateThread(function()
        local markerTextUi = false
        local in_delivery = false
        while HasBag do
            local ped = PlayerPedId()
            local pos = GetEntityCoords(ped)
            if not DoesEntityExist(WorkVehicle) then
                OnWorkFinished(EndedJobReason.WorkVehicleNotFound)
            end 
            local coords = GetOffsetFromEntityInWorldCoords(WorkVehicle, 0.0, -4.5, 0.0)
            local distance = #(pos - coords)
            DrawMarker(20, coords.x, coords.y, coords.z+1.5, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 1.0, 1.0, 1.0, 0, 255, 0, 150, true, true, 2, false, false, false, false)
            local message = "Dispose the garbage Bag in the ~y~Vehicle~s~"
            if distance < 1.5 then
                if not markerTextUi then
                    markerTextUi = true
                    lib.showTextUI('[E] Dispose of Garbage Bag', { position = "right-center", icon = 'fa-sack-xmark', iconColor = 'green'})
                end
                if IsControlJustPressed(0, 38) and not in_delivery then
                    in_delivery = true
                    lib.hideTextUI()
                    StopAnimTask(PlayerPedId(), 'missfbi4prepp1', '_bag_walk_garbage_man', 1.0)
                    DeliverAnim(index)
                end
            else
                if distance > 20.0 then
                    message = message .. "\nThe garbage vehicle is ~r~far~s~"
                    if not WorkVehicleBlip then
                        CreateWorkVehicleBlip(coords)
                    end
                else
                    RemoveBlip(WorkVehicleBlip)
                    WorkVehicleBlip = nil
                end
                if markerTextUi then
                    markerTextUi = false
                    lib.hideTextUI()
                end
            end
            MissionAlert(message)
            Wait(1)
        end
    end)
end

function TakeAnim()
    print('anim')
    local ped = PlayerPedId()
    FreezeEntityPosition(ped, true)
    lib.progressBar({
        duration = 5000,
        label = 'Searching Garbage Bag',
        useWhileDead = false,
        canCancel = false,
        disable = {
            car = true,
            move = true,
            combat = true
        },
        anim = {
            dict = 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@',
            clip = 'machinic_loop_mechandplayer'
        },
        })
    FreezeEntityPosition(ped, false)
    LoadAnimation('missfbi4prepp1')
    TaskPlayAnim(ped, 'missfbi4prepp1', '_bag_walk_garbage_man', 6.0, -6.0, -1, 49, 0, 0, 0, 0)
    GarbageObject = CreateObject(`prop_cs_rub_binbag_01`, 0, 0, 0, true, true, true)
    AttachEntityToEntity(GarbageObject, ped, GetPedBoneIndex(ped, 57005), 0.12, 0.0, -0.05, 220.0, 120.0, 0.0, true, true, false, true, 1, true)
end

DeliverAnim = function(index)
    local ped = PlayerPedId()
    HasBag = false
    LoadAnimation('missfbi4prepp1')
    TaskPlayAnim(ped, 'missfbi4prepp1', '_bag_throw_garbage_man', 8.0, 8.0, 1100, 48, 0.0, 0, 0, 0)
    FreezeEntityPosition(ped, true)
    SetEntityHeading(ped, GetEntityHeading(WorkVehicle))
    SetTimeout(1250, function()
        DetachEntity(GarbageObject, 1, false)
        DeleteObject(GarbageObject)
        TaskPlayAnim(ped, 'missfbi4prepp1', 'exit', 8.0, 8.0, 1100, 48, 0.0, 0, 0, 0)
        FreezeEntityPosition(ped, false)
        GarbageObject = nil
        CanTakeBag = true
        HasBag = false
    end)
    TriggerServerEvent('elder_drilltime:garbagejob:server:pay_task', index)
    if FinishedTasks == MaxGarbageTasks then
        OnWorkFinished(EndedJobReason.AllTasksDone)
    end
end

OnWorkFinished = function(reason)
    if not WorkInProgress then return end
    local ped = PlayerPedId()
    for k,v in pairs(Locations) do
        RemoveBlip(Locations[k].blip)
        local point = Locations[k].point
        point:remove()
    end
    Locations = {}
    if HasBag then
        DetachEntity(GarbageObject, 1, false)
        DeleteObject(GarbageObject)
        TaskPlayAnim(ped, 'missfbi4prepp1', 'exit', 8.0, 8.0, 1100, 48, 0.0, 0, 0, 0)
        GarbageObject = nil
        HasBag = false
        CanTakeBag = true
    end
    WorkInProgress = false
    MaxGarbageTasks = 0
    if reason == EndedJobReason.AllTasksDone then
        Notify("You did all tasks, clock out to get your reward")
    elseif reason == EndedJobReason.WorkVehicleNotFound then
        Notify("You lost your working vehicle, you are fired !")
    elseif reason == EndedJobReason.ClockOut then
        Notify("You clocked out, job ended !")
    else
        Notify("Unexpected error happened, job will be ended")
    end
    
end
