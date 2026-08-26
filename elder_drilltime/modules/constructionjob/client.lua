local NPC = nil
local WorkInProgress = false
local Blip = nil
local CloakedOut = false


local function CanWork()
    local result = promise:new()
    ESX.TriggerServerCallback('elder_drilltime:constructionjob:server:can_work', function(data) 
        result:resolve(data)  
    end)
    return Citizen.Await(result)
end

local function WorkClothes()
    local gender = GetEntityModel(PlayerPedId())
	local PlayerPed = PlayerPedId()
	if gender == GetHashKey('mp_m_freemode_01') then
		for k, v in pairs(Config.ConstructionJob.Clothes.male.components) do
			SetPedComponentVariation(PlayerPed, v['component_id'], v['drawable'], v['texture'], 0)
		end
        ClearPedProp(PlayerPedId(), 0)
        SetPedPropIndex(PlayerPedId(), 0, 211, 0, true)
        
	else
		for k, v in pairs(Config.ConstructionJob.Clothes.female.components) do
			SetPedComponentVariation(PlayerPed, v['component_id'], v['drawable'], v['texture'], 0)
		end
        ClearPedProp(PlayerPedId(), 0)
        SetPedPropIndex(PlayerPedId(), 0, 211, 0, true)
        
	end
end

local function CloakIn()
    if WorkInProgress then 
        return Notify("You are already clocked in.", "error")
    end
    if not CanWork() then
        return Notify("The construction company is not hiring workers right now.", "warning")
    end
    WorkClothes()
    StartConstrunctionJobWork()
end

local function CloakOut()
    if not CloakedOut then 
        ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
            TriggerEvent('skinchanger:loadSkin', skin)
        end)
        WorkInProgress = false
        CloakedOut = true
        TriggerServerEvent('elder_drilltime:constructionjob:server:pay_job')
    end
end

local function CloakMenu()
    local menuOptions = {}  
    table.insert(menuOptions, {title = 'Clock In', description = 'Get job clothes and start work.', arrow = true, icon = 'fa-person-digging', iconColor = 'green', onSelect = function() CloakIn() end})
    table.insert(menuOptions, {title = 'Clock Out', description = 'Get civ clothes and finish work.', arrow = true, icon = 'fa-circle-left', iconColor = 'red', onSelect = function() CloakOut() end})
    lib.registerContext({
        id = 'cj_cloakin_menu',
        title = '🧱 Construnction Company',
        options = menuOptions,
    })
    lib.showContext('cj_cloakin_menu')
end

local function CreateBlip(coords)
    Blip = AddBlipForCoord(coords)
	SetBlipSprite(Blip,280)
	SetBlipColour(Blip,1)
	SetBlipAlpha(Blip,250)
	SetBlipScale(Blip,0.75)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString("task")
	EndTextCommandSetBlipName(Blip)
end


Citizen.CreateThread(function()
    local coords = Config.ConstructionJob.CloakIn.Coords
    local model = Config.ConstructionJob.CloakIn.Model
    --npc
    ESX.Streaming.RequestModel(model)
    NPC = CreatePed(5, GetHashKey(model), coords.x, coords.y, coords.z-0.9, coords.w, false, true)
    PlaceObjectOnGroundProperly(NPC)
    FreezeEntityPosition(NPC, true)
    SetEntityInvincible(NPC, true)
    SetBlockingOfNonTemporaryEvents(NPC, true)
    --blip
    local blip = AddBlipForCoord(coords)
	SetBlipSprite(blip,214)
	SetBlipColour(blip,2)
	SetBlipAlpha(blip,250)
	SetBlipScale(blip,1.0)
    SetBlipAsShortRange(blip,true)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString("Construction Company")
	EndTextCommandSetBlipName(blip)
end)

Citizen.CreateThread(function()
    local coords = Config.ConstructionJob.CloakIn.Coords
    local markerTextUi = false
    while true do
        local sleep
        local distance = GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), coords, true)
        if distance <= 2.0 then
            sleep = 1
            if not markerTextUi then
                lib.showTextUI('[E] to clock in.', { position = "right-center", icon = 'fa-person-digging', iconColor = 'green'})
                markerTextUi = true
            end
            if IsControlJustPressed(0, 38) then
                lib.hideTextUI()
                markerTextUi = false
                CloakMenu()
            end
        else
            sleep = (distance > 2.0 and distance <= 20.0) and 2000 or 4000
            if markerTextUi then
                markerTextUi = false
                lib.hideTextUI()
            end
        end
        Wait(sleep)
    end
end)

local function DoJdGraveTask()
    return lib.progressCircle({
		duration = Config.ConstructionJob.TimePerTask,
		label = 'Digging Grave',
		useWhileDead = false,
		allowRagdoll = false,
		allowCuffed = false,
		allowFalling = false,
		canCancel = false,
		anim = { dict = 'anim@amb@drug_field_workers@rake@male_a@base', clip = 'base' },
		prop = { model = `prop_tool_shovel006`, bone = 28422, pos = { x = 0.0, y = 0.1, z = -0.6 }, rot = { x = 0.0, y = 0.0, z = 180.0 } },
		disable = { move = true, combat = true } 
	})
end

local function DoBroomTask()
    return lib.progressCircle({
		duration = Config.ConstructionJob.TimePerTask,
		label = 'Broom',
		useWhileDead = false,
		allowRagdoll = false,
		allowCuffed = false,
		allowFalling = false,
		canCancel = false,
		anim = { dict = 'anim@amb@drug_field_workers@rake@male_a@base', clip = 'base' },
		prop = { model = `prop_tool_broom`, bone = 28422, pos = { x = -0.0100, y = 0.0400, z = -0.0300 }, rot = { x = 0.0, y = 0.0, z = 0.0 } },
		disable = { move = true, combat = true } 
	})
end

local function DoDrillTask()
    FreezeEntityPosition(PlayerPedId(), true)
    TaskStartScenarioInPlace(PlayerPedId(), "WORLD_HUMAN_CONST_DRILL", 0, false)
    lib.progressCircle({
		duration = Config.ConstructionJob.TimePerTask,
		label = 'Drilling',
		useWhileDead = false,
		allowRagdoll = false,
		allowCuffed = false,
		allowFalling = false,
		canCancel = false,
		disable = { move = true, combat = true } 
	})
    ClearPedTasksImmediately(PlayerPedId())
    FreezeEntityPosition(PlayerPedId(), false)
end

local function DoWeldTask()
    FreezeEntityPosition(PlayerPedId(), true)
    TaskStartScenarioInPlace(PlayerPedId(), "WORLD_HUMAN_WELDING", 0, false)
    lib.progressCircle({
		duration = Config.ConstructionJob.TimePerTask,
		label = 'Welding',
		useWhileDead = false,
		allowRagdoll = false,
		allowCuffed = false,
		allowFalling = false,
		canCancel = false,
		disable = { move = true, combat = true } 
	})
    ClearPedTasksImmediately(PlayerPedId())
    FreezeEntityPosition(PlayerPedId(), false)
end

local function DoHammerTask()
    FreezeEntityPosition(PlayerPedId(), true)
    TaskStartScenarioInPlace(PlayerPedId(), "WORLD_HUMAN_HAMMERING", 0, false)
    lib.progressCircle({
		duration = Config.ConstructionJob.TimePerTask,
		label = 'Hammering',
		useWhileDead = false,
		allowRagdoll = false,
		allowCuffed = false,
		allowFalling = false,
		canCancel = false,
		disable = { move = true, combat = true } 
	})
    ClearPedTasksImmediately(PlayerPedId())
    FreezeEntityPosition(PlayerPedId(), false)
end

StartConstrunctionJobWork = function()
    local task_count = math.random(Config.ConstructionJob.TasksCount.min, Config.ConstructionJob.TasksCount.max)
    local max_task_count = task_count
    WorkInProgress = true
    StartCheckVehicle()
    local current_task_index = nil
    local current_task = nil
    local markerTextUi = false
    CreateThread(function()
        while WorkInProgress do
            if task_count == 0 then
                WorkInProgress = false
                goto over
            end
            if not current_task then
                current_task_index = math.random(1, #Config.ConstructionJob.Tasks)
                current_task = Config.ConstructionJob.Tasks[current_task_index]
                task_count = task_count - 1
                CreateBlip(current_task.coords)
            end
            while WorkInProgress and current_task do
                DisplayRadar(true) 
                MissionAlert('Go to the mark and finish the task - ~g~'..(max_task_count-task_count)..'/'..max_task_count..'~s~')
                DrawMarker(20, current_task.coords.xyz, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.5, 0.5, 0.5, 0, 255, 100, 255, 1, 0, 0, 0, 0, 0, 0)
                --DrawMarker(1, current_task.coords.xyz, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.5, 0.5, 1000.5, 0, 255, 100, 255, 1, 0, 0, 0, 0, 0, 0)
                local distance = GetDistanceBetweenCoords(cache.coords, current_task.coords.xyz, true)
                if distance <= 2.0 then
                    if not markerTextUi then
                        lib.showTextUI('[E] to start the work task.', { position = "right-center", icon = 'fa-person-digging', iconColor = 'green'})
                        markerTextUi = true
                    end
                    if IsControlJustPressed(0, 38) then
                        lib.hideTextUI()
                        markerTextUi = false
                        DoTask(current_task)
                        TriggerServerEvent('elder_drilltime:constructionjob:server:pay_task', current_task_index)
                        current_task = nil
                        RemoveBlip(Blip)
                    end
                else
                    if markerTextUi then
                        markerTextUi = false
                        lib.hideTextUI()
                    end
                end 
                Wait(1)
            end
            ::over::
            Wait(1)
        end
        RemoveBlip(Blip)
    end)
end

function DoTask(task)
    local result = false
    while not result do
        result = lib.skillCheck({'easy', 'easy', 'medium', 'easy', 'easy'})
        Wait(1)
    end
    if task.type == 'digging_grave' then DoJdGraveTask()
    elseif task.type == 'broom' then DoBroomTask()
    elseif task.type == 'drill' then DoDrillTask()
    elseif task.type == 'weld' then DoWeldTask()
    elseif task.type == 'hammer' then DoHammerTask()
    end  
end

function StartCheckVehicle()
    CreateThread(function()
        while WorkInProgress do
            local playerPed = PlayerPedId()
            if IsPedInAnyVehicle(playerPed, true) then
                vehicle = GetVehiclePedIsIn(playerPed, false)
                TaskLeaveVehicle(playerPed, vehicle, 4160) 
            end 
            Wait(1000)
        end
    end)
end
