

local isGettingDrugs = false
local ped = nil
local point = nil

local function openPhone()
    ClearPedTasksImmediately(cache.ped)
    TaskStartScenarioInPlace(cache.ped, "WORLD_HUMAN_STAND_MOBILE", 0, true)
    SetNuiFocus(true, true)
    SendNUIMessage({ action = "open", items = Config.DrugRunTypes})
end

local function startDrugRun(type)
    TriggerServerEvent('elder_drugruns:server:startDrugRun', type)
end

local function getDrugs()
    TriggerServerEvent('elder_drugruns:server:getDrugs')
    SetEntityAsNoLongerNeeded(ped)
    point:remove()
    Wait(5000)
    DeleteEntity(ped)
end

local function startDrugRunNpc()
    local coords = Config.DrugRunTypes['npc'].Locations[math.random(1, #Config.DrugRunTypes['npc'].Locations)]
    local model = Config.DrugRunTypes['npc'].Peds[math.random(1, #Config.DrugRunTypes['npc'].Peds)]
    local animation = Config.DrugRunTypes['npc'].Animations[math.random(1, #Config.DrugRunTypes['npc'].Animations)]
    lib.requestModel(model)
    ped = CreatePed(0, model, coords.x, coords.y, coords.z - 1.0, coords.w, false, true)
    FreezeEntityPosition(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    TaskStartScenarioInPlace(ped, animation, 0, true)
	SetEntityInvincible(ped, true)
    SetNewWaypoint(coords.x, coords.y)
    point = lib.points.new({
        coords = coords.xyz,
        distance = 1.5,
        onEnter = function()
            lib.showTextUI('[E] Get Drugs')
        end,
        onExit = function()
            lib.hideTextUI()
        end,
        nearby = function()
            if IsControlJustReleased(0, 38) and not isGettingDrugs then
                lib.hideTextUI()
                isGettingDrugs = true
                getDrugs()
                SetTimeout(3000, function()
                    isGettingDrugs = false
                end)
            end
        end,
    })
end

RegisterNetEvent('elder_drugruns:client:notification')
AddEventHandler('elder_drugruns:client:notification', function(message, type)
    lib.notify({
        description = message,
        type = type,
        position = 'center-right',
    })
end)

RegisterNetEvent('elder_drugruns:client:usePhone')
AddEventHandler('elder_drugruns:client:usePhone', function()
    openPhone()
end)

RegisterNUICallback('onClose', function(_, cb)
    SetNuiFocus(false, false)
    cb("ok")
    ClearPedTasks(cache.ped)
end)

RegisterNUICallback('onSelect', function(data, cb)
    SetNuiFocus(false, false)
    cb("ok")
    ClearPedTasks(cache.ped)
    startDrugRun(data.selected)
end)

RegisterNetEvent('elder_drugruns:client:startDrugRunNpc')
AddEventHandler('elder_drugruns:client:startDrugRunNpc', function()
    TriggerServerEvent('elder_drugruns:server:removeItem')
    startDrugRunNpc()
end)

RegisterNetEvent('elder_drugruns:client:startDrop')
AddEventHandler('elder_drugruns:client:startDrop', function()
    local coords = Config.DrugRunTypes['drop'].Locations[math.random(1, #Config.DrugRunTypes['drop'].Locations)]
    if exports.elder_drilltime:createDrop(coords) then 
        TriggerServerEvent('elder_drugruns:server:removeItem')
        TriggerEvent('elder_drugruns:client:notification', 'drop will be created soon !', 'success')
    else
        TriggerEvent('elder_drugruns:client:notification', 'You cannot use this now !', 'error')
    end
end)
