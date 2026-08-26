ESX = nil

local PlayerJob = nil
local WorkInProgress = false
local Blip = nil

CreateThread(function()
    while ESX == nil do
        pcall(function() ESX = exports['es_extended']:getSharedObject() end)
        if ESX == nil then
            TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        end
        Wait(50)
    end 
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

function Notify(msg, type)
	lib.notify({
        description = msg,
        position = position or 'center-left',
        type = type,
        duration = time
    })
end

RegisterNetEvent("elder_business:client:notify")
AddEventHandler("elder_business:client:notify", function(msg, type) 
	Notify(msg, type)
end)

function MissionAlert(text)
    ClearPrints()
    SetTextEntry_2("STRING")
    AddTextComponentString(text)
    DrawSubtitleTimed(1000, 1)
end

--- Workers Management Menu

local function HasBusinessJob()
    return PlayerJob and Config.Business[PlayerJob.name]
end

CreateThread(function()
    while PlayerJob == nil do Wait(100) end
    for k,v in pairs(Config.Business) do
        local coords = v.bossmenu
        local bossmenu = lib.points.new(coords, 5.0, {coords = coords, heading = 0.0, index = 1})
        local drawTextUI = false
        function bossmenu:onEnter()
        end
        function bossmenu:onExit()
            lib.hideTextUI()
        end
        function bossmenu:nearby()
            if not HasBusinessJob() or PlayerJob.name ~= v.job or PlayerJob.grade_name ~= 'boss' then
                lib.hideTextUI()
                return
            end
            DrawMarker(20, coords.x, coords.y, coords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.45, 0.45, 0.55, 0, 0, 220, 255, 1, 1, 2)
            if self.currentDistance < 2.0 then
                if not drawTextUI then
                    drawTextUI = true
                    lib.showTextUI('[E] - Boss Menu ['..v.job ..']')
                end
                if IsControlJustReleased(0, 38) then
                    lib.hideTextUI()
                    OpenBossMenu()
                end
            else
                lib.hideTextUI()
                drawTextUI = false
            end  
        end
    end
end)

OpenBossMenu = function()
    local menuOptions = {}  
    table.insert(menuOptions, {title = 'Workers Management', icon = 'fa-users', onSelect = function() WorkersManagement() end})
    table.insert(menuOptions, {title = 'Money Management', icon = 'fa-money-bill-transfer', onSelect = function() MoneyManagement() end})
    lib.registerContext({
        id = 'business_menu',
        title = 'Boss Menu',
        options = menuOptions,
    })
    lib.showContext('business_menu')
end

WorkersManagement = function()
    local menuOptions = {}  
    table.insert(menuOptions, {title = 'Workers List', icon = 'fa-users', onSelect = function() WorkersList() end})
    table.insert(menuOptions, {title = 'Add Worker', icon = 'fa-user', onSelect = function() AddWorkerMenu() end})
    lib.registerContext({
        id = 'business_wm_menu',
        title = 'Workers Management',
        menu = 'business_menu',
        canClose = false,
        options = menuOptions,
    })
    lib.showContext('business_wm_menu')
end

MoneyManagement = function()
    local balance = GetBusinessBalance()
    local menuOptions = {}  
    table.insert(menuOptions, {title = 'Balance : $' .. ESX.Math.GroupDigits(balance), icon = 'fa-money-check-dollar', readOnly = true})
    table.insert(menuOptions, {title = 'Withdraw', icon = 'fa-money-bill-transfer', onSelect = function() Withdraw() end})
    lib.registerContext({
        id = 'business_mm_menu',
        title = 'Money Management',
        menu = 'business_menu',
        canClose = false,
        options = menuOptions,
    })
    lib.showContext('business_mm_menu')
end

WorkersList = function()
    local workers = GetBusinessWorkers()
    local menuOptions = {} 
    for k,v in pairs(workers) do 
        table.insert(menuOptions, {title = v.name, iconColor = v.boss and 'gold' , icon = v.boss and 'fa-crown' or 'fa-user', readOnly = v.boss , onSelect = function() RemoveWorker(v.name, v.identifier) end})
    end 
    if #menuOptions == 0 then
        table.insert(menuOptions, {title = 'No Workers', icon = 'fa-users', readOnly = true})
    end
    lib.registerContext({
        id = 'business_wl_menu',
        title = 'Workers List',
        menu = 'business_wm_menu',
        canClose = false,
        options = menuOptions,
    })
    lib.showContext('business_wl_menu')
end

AddWorkerMenu = function()
    if not CanAddWorker() then
        return Notify('You cannot add more workers', 'error')
    end 
    local menuOptions = {}
    local players = lib.getNearbyPlayers(GetEntityCoords(PlayerPedId()), 10.0, true)
    for i = 1, #players do
        local playerId = GetPlayerServerId(players[i].id)
        local fullName = GetFullName(playerId)
        local menuTitle = fullName..' ['..playerId..']'
        table.insert(menuOptions, {
            title = menuTitle,
            icon = 'user',
            onSelect = function()
                AddWorker(fullName,playerId)
            end,
        })
    end
    if #menuOptions <= 0 then
        return Notify('No players nearby', 'error')
    end
    lib.registerContext({
        id = 'business_aw_menu',
        title = 'Add Worker',
        menu = 'business_wm_menu',
        canClose = false,
        options = menuOptions,
    })
    lib.showContext('business_aw_menu')
end

RemoveWorker = function(name, identifier)
    local alert = lib.alertDialog({
        header = 'Do you want to fire ' .. name,
        content = '',
        centered = true,
        cancel = true,
        labels = {
            cancel=  "Cancel",
            confirm=  "Fire",
        }
    })
    if alert ~= 'cancel' then
        TriggerServerEvent('elder_business:server:removeWorker', identifier)
    end
end

AddWorker = function(name, playerId)
    local alert = lib.alertDialog({
        header = 'Do you want to hire ' .. name,
        content = '',
        centered = true,
        cancel = true,
        labels = {
            cancel=  "Cancel",
            confirm=  "Hire",
        }
    })
    if alert ~= 'cancel' then
        TriggerServerEvent('elder_business:server:addWorker', playerId)
    end
end

GetBusinessBalance = function()
    local result = promise:new()
    ESX.TriggerServerCallback('elder_business:server:getBalance', function(data) 
		result:resolve(data)  
    end)
    return Citizen.Await(result)
end

Withdraw = function()
    TriggerServerEvent('elder_business:server:withdraw')
end

GetBusinessWorkers = function()
    local result = promise:new()
    ESX.TriggerServerCallback('elder_business:server:getWorkers', function(data) 
		result:resolve(data)  
    end)
    return Citizen.Await(result)
end

GetFullName = function(id)
    local result = promise:new()
    ESX.TriggerServerCallback('elder_business:server:getFullName', function(data) 
		result:resolve(data)  
    end, id)
    return Citizen.Await(result)
end

CanAddWorker = function()
    local result = promise:new()
    ESX.TriggerServerCallback('elder_business:server:canAddWorker', function(data) 
		result:resolve(data)  
    end, id)
    return Citizen.Await(result)
end

-- Duty Management

CreateThread(function()
    while PlayerJob == nil do Wait(100) end
    for k,v in pairs(Config.Business) do
        local coords = v.duty
        local duty = lib.points.new(coords, 5.0, {coords = coords, heading = 0.0, index = 1})
        local drawTextUI = false
        function duty:onEnter()
        end
        function duty:onExit()
            lib.hideTextUI()
        end
        function duty:nearby()
            if not HasBusinessJob() or PlayerJob.name ~= v.job then
                lib.hideTextUI()
                return
            end
            DrawMarker(20, coords.x, coords.y, coords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.45, 0.45, 0.55, 220, 0, 0, 255, 1, 1, 2)
            if self.currentDistance < 2.0 then
                if not drawTextUI then
                    drawTextUI = true
                    lib.showTextUI('[E] - Duty ['..v.job ..']')
                end
                if IsControlJustReleased(0, 38) then
                    lib.hideTextUI()
                    OpenDutyMenu()
                end
            else
                lib.hideTextUI()
                drawTextUI = false
            end  
        end
    end
end)

OpenDutyMenu = function()
    local menuOptions = {}  
    table.insert(menuOptions, {title = 'Clock In', description = 'start doing tasks and get paid.', icon = 'fa-circle-right', onSelect = function() ClockIn() end})
    table.insert(menuOptions, {title = 'Clock Out', description = 'clock out.', icon = 'fa-circle-left', onSelect = function() ClockOut() end})
    lib.registerContext({
        id = 'business_duty_menu',
        title = 'Duty',
        options = menuOptions,
    })
    lib.showContext('business_duty_menu')
end

ClockIn = function()
    if WorkInProgress or not CanWork() then
        return Notify('You are already on duty or you finished your daily tasks.', 'error')
    end
    WorkInProgress = true
    StartWork()
end

ClockOut = function()
    WorkInProgress = false
end

StartWork = function()
    local business = Config.Business[PlayerJob.name]
    local task_count = business.taskscount
    local max_task_count = task_count
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
                current_task_index = math.random(1, #business.tasks)
                current_task = business.tasks[current_task_index]
                task_count = task_count - 1
            end
            while WorkInProgress and current_task do 
                MissionAlert('Go to the mark and finish the task - ~g~'..(max_task_count-task_count)..'/'..max_task_count..'~s~')
                DrawMarker(20, current_task.coords.xyz, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.5, 0.5, 0.5, 0, 255, 100, 255, 1, 0, 0, 0, 0, 0, 0)
                local distance = GetDistanceBetweenCoords(cache.coords, current_task.coords.xyz, true)
                if distance <= 2.0 then
                    if not markerTextUi then
                        lib.showTextUI('[E] to start the work task.')
                        markerTextUi = true
                    end
                    if IsControlJustPressed(0, 38) then
                        lib.hideTextUI()
                        markerTextUi = false
                        DoTask(current_task)
                        TriggerServerEvent('elder_business:server:payTask', current_task)
                        current_task = nil
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
        result = lib.skillCheck({'easy', 'easy'})
        Wait(1)
    end
    if task.type == 'sweep' then DoSweepTask()
    elseif task.type == 'clean' then DoCleanTask()
    elseif task.type == 'clean2' then DoClean2Task()
    elseif task.type == 'garbage' then DoGarbageTask(task)
    elseif task.type == 'drug' then DoDrugDeliveryTask(task)
    end  
end

function DoSweepTask()
    local progress = lib.progressCircle({
		duration = 5000,
		label = 'Sweeping ground',
		useWhileDead = false,
		allowRagdoll = false,
		allowCuffed = false,
		allowFalling = false,
		canCancel = false,
		anim = { dict = 'amb@world_human_janitor@male@idle_a', clip = 'idle_a' },
		prop = { model = `prop_tool_broom`, bone = 28422, pos = { x = -0.005, y = 0.0, z = 0.0 }, rot = { x = 360.0, y = 360.0, z = 0.0 } },
		disable = { move = true, combat = true }
	})
    ClearPedTasksImmediately(PlayerPedId())
    ClearAreaOfObjects(GetEntityCoords(PlayerPedId()), 2.0, 0)
end

function DoCleanTask()
    local progress = lib.progressCircle({
		duration = 5000,
		label = 'Cleaning',
		useWhileDead = false,
		allowRagdoll = false,
		allowCuffed = false,
		allowFalling = false,
		canCancel = false,
		anim = { dict = 'timetable@floyd@clean_kitchen@base', clip = 'base' },
		prop = { model = `prop_sponge_01`, bone = 28422, pos = { x = 0.0, y = 0.0, z = -0.01 }, rot = { x = 90.0, y = 0.0, z = 0.0 } },
		disable = { move = true, combat = true }
	})
    ClearPedTasksImmediately(PlayerPedId())
    ClearAreaOfObjects(GetEntityCoords(PlayerPedId()), 2.0, 0)
end

function DoClean2Task()
    local progress = lib.progressCircle({
		duration = 5000,
		label = 'Cleaning',
		useWhileDead = false,
		allowRagdoll = false,
		allowCuffed = false,
		allowFalling = false,
		canCancel = false,
		anim = { dict = 'amb@world_human_maid_clean@', clip = 'base' },
		prop = { model = `prop_sponge_01`, bone = 28422, pos = { x = 0.0, y = 0.0, z = -0.01 }, rot = { x = 90.0, y = 0.0, z = 0.0 } },
		disable = { move = true, combat = true }
	})
    ClearPedTasksImmediately(PlayerPedId())
    ClearAreaOfObjects(GetEntityCoords(PlayerPedId()), 2.0, 0)
end

function DoGarbageTask(task)
    ExecuteCommand('e gbag')
    local delivered = false
    local markerTextUi = false
    while not delivered do
        Wait(1)
        MissionAlert('Drop garbage bag in garbage stash')
        DrawMarker(20, task.tocoords.xyz, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.5, 0.5, 0.5, 0, 255, 100, 255, 1, 0, 0, 0, 0, 0, 0)
        local distance = GetDistanceBetweenCoords(cache.coords, task.tocoords.xyz, true)
        if distance <= 2.0 then
            if not markerTextUi then
                lib.showTextUI('[E] to drop bag.')
                markerTextUi = true
            end
            if IsControlJustPressed(0, 38) then
                lib.hideTextUI()
                markerTextUi = false
                exports.rpemotes:EmoteCancel()
                delivered = true
            end
        else
            if markerTextUi then
                markerTextUi = false
                lib.hideTextUI()
            end
        end 
    end
end

function DoDrugDeliveryTask(task)
    ExecuteCommand('e weedbrick2')
    CreateBlip(task.tocoords)
    Wait(1000)
    exports.rpemotes:EmoteCancel()
    SetNewWaypoint(task.tocoords.x, task.tocoords.y)
    local delivered = false
    local markerTextUi = false
    while not delivered do
        Wait(1)
        MissionAlert('Deliver drug package')
        DrawMarker(20, task.tocoords.xyz, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.5, 0.5, 0.5, 0, 255, 100, 255, 1, 0, 0, 0, 0, 0, 0)
        local distance = GetDistanceBetweenCoords(cache.coords, task.tocoords.xyz, true)
        if distance <= 2.0 then
            if not markerTextUi then
                lib.showTextUI('[E] to deliver drugs.')
                markerTextUi = true
            end
            if IsControlJustPressed(0, 38) then
                lib.hideTextUI()
                markerTextUi = false
                delivered = true
                RemoveBlip(Blip)
            end
        else
            if markerTextUi then
                markerTextUi = false
                lib.hideTextUI()
            end
        end 
    end
end

function CanWork()
    local result = promise:new()
    ESX.TriggerServerCallback('elder_business:server:canWork', function(data) 
        result:resolve(data)  
    end)
    return Citizen.Await(result)
end

function CreateBlip(coords)
    Blip = AddBlipForCoord(coords)
	SetBlipSprite(Blip,280)
	SetBlipColour(Blip,1)
	SetBlipAlpha(Blip,250)
	SetBlipScale(Blip,0.75)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString("delivery")
	EndTextCommandSetBlipName(Blip)
end