local DrawMarker = DrawMarker
local Wait = Wait 
local IsControlJustReleased = IsControlJustReleased


ESX = exports['es_extended']:getSharedObject()
local StartCollecting = false
local IsCollecting = false
local CollectCounter = 0
local CanStartCollect = true
local InsideLocation = false


local function startCollect(index)
    if IsCollecting then return end
    IsCollecting = true

    lib.hideTextUI()

    local CollectPoint = Config.CollectPoints[index]
    if not CollectPoint then return end

    SendNUIMessage({
        action = "show",
        label = ("Collecting %s"):format(CollectPoint.ItemLabel or "Items"),
        duration = CollectPoint.Delay * 1000
    })

    local dict = 'random@domestic'
    local anim = 'pickup_low'
    local duration = CollectPoint.Delay * 1000
    local endTime = GetGameTimer() + duration
    local nextAnimPlay = 0

    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do Wait(10) end

    while GetGameTimer() < endTime and StartCollecting do

        if GetGameTimer() >= nextAnimPlay then
            TaskPlayAnim(cache.ped, dict, anim, 3.0, 3.0, 1500, 49, 0, false, false, false)
            nextAnimPlay = GetGameTimer() + 3000
        end
        Wait(50)
    end

    ClearPedTasks(cache.ped)

    SendNUIMessage({ action = "hide" })

    Wait(500)

    if not StartCollecting then
        IsCollecting = false
        if InsideLocation then 
            lib.showTextUI(('[E] Collect %s'):format(CollectPoint.ItemLabel), {icon = 'fa-pills', iconColor = 'purple'})
        end
        return
    end

    --TriggerServerEvent('drugmanager:server:collect', index)
    lib.callback.await('drugmanager:server:collect', false, index)

    IsCollecting = false

    CollectCounter = CollectCounter + 1
    if CollectCounter >= Config.Settings.AFKCheckAfter then
        
        LastCollectIndex = index
        StartCollecting = false
        SendNUIMessage({ action = "captcha" })
        SetNuiFocus(true, true)
        return
    end

    if StartCollecting then
        return startCollect(index)
    end

    --lib.showTextUI(('[E] Collect %s'):format(CollectPoint.ItemLabel), {icon = 'fa-pills', iconColor = 'purple'})
end


function cancelCollect()
    IsCollecting = false
    StartCollecting = false
end



CreateThread(function()
    for index, CollectPoint in pairs(Config.CollectPoints) do 
        local MarkerLocation = lib.points.new({
            coords = CollectPoint.Coords,
            distance = 20.0,
            nearby = function()
                DrawMarker(1, 
                    CollectPoint.Coords.x, 
                    CollectPoint.Coords.y, 
                    CollectPoint.Coords.z - 1, 
                    0.0, 0.0, 0.0, 0, 0.0, 0.0, 
                    CollectPoint.Radius * 2, 
                    CollectPoint.Radius * 2, 
                    Config.Settings.MarkerHeight,
                    Config.Settings.MarkerColor.R, 
                    Config.Settings.MarkerColor.G, 
                    Config.Settings.MarkerColor.B, 
                    Config.Settings.MarkerColor.A, 
                    false, false, 2, false, false, false, false
                )  
            end,
        })

        local CollectLocation = lib.points.new({
            coords = CollectPoint.Coords,
            distance = CollectPoint.Radius,
            onEnter = function()
                InsideLocation = true
                lib.showTextUI(('[E] Collect %s'):format(CollectPoint.ItemLabel), {icon = 'fa-pills', iconColor = 'purple'})
            end,
            onExit = function()
                InsideLocation = false
                lib.hideTextUI()
                if IsCollecting then 
                    cancelCollect()
                end
                CanStartCollect = true
            end,
            nearby = function()
                InsideLocation = true
                if CanStartCollect and not StartCollecting and IsControlJustReleased(0, 38) then
                    StartCollecting = true
                    CreateThread(function()
                        startCollect(index)
                    end)      
                end
            end,
        })
    end
end)

RegisterNUICallback("captchaSuccess", function(_, cb)
    SetNuiFocus(false, false)
    CollectCounter = 0
    StartCollecting = true
    if LastCollectIndex then
        CreateThread(function() startCollect(LastCollectIndex) end)
    end
    cb("ok")
end)

RegisterNUICallback("captchaFail", function(_, cb)
    SetNuiFocus(false, false)
    cancelCollect()
    CollectCounter = 0
    LastCollectIndex = nil
    CanStartCollect = false
    cb("ok")
end)