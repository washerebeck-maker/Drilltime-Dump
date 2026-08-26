local ESX = exports.es_extended:getSharedObject()

local DrawMarker = DrawMarker

local FirstBox = nil
local SecondBox = nil
local InsideFirstBox = false
local InsideSecondBox = false
local HardPoint = nil
local FirstBlip = nil
local SecondBlip = nil
local IsInFightMode = false
local FightTimeLeft = 0
local CanCollectReward = false
local CollectTimeLeft = 0
local CollectPoint = nil
local PropPoint = nil
local PlayerGang = nil
local GangScore = {}
local CollectHardPoint = nil


local function isPlayerLoaded()
    return ESX.IsPlayerLoaded()
end

local function isDead()
	return exports.esx_ambulancejob:IsPlayerDead()
end

local function getPlayerGang()
    return exports.elder_gangs:get_player_gang()
end

local function drawWallMarkers(location)
    for _, coords in ipairs(location.Arrows) do 
        DrawMarker(20, coords.x, coords.y, coords.z, 0.0, 0.0, 0.0, 180.0, 0.0, 0.0, 0.7, 0.7, 0.7, 255, 0, 0, 200, true, true, 2, false, false, false, false)
    end
end

local function drawPropMarkers(location)
    DrawMarker(1, location.Prop.x, location.Prop.y, location.Prop.z - 2.5, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 4.0, 4.0, 2.0, 255, 0, 0, 200, true, true, 2, false, false, false, false)
    DrawMarker(3, location.Prop.x, location.Prop.y, location.Prop.z , 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 255, 0, 0, 200, true, true, 2, false, false, false, false)

end

local function deleteVehicle()
    if IsPedInAnyVehicle(cache.ped,false) then
        local vehicle = GetVehiclePedIsIn(cache.ped, false)
        if GetPedInVehicleSeat(vehicle, -1) == cache.ped then
            DeleteEntity(vehicle)
        end
    end
end

local function blockEntryTime()
    if IsInFightMode and FightTimeLeft <= Config.BlockEntryTime then
        local coords = Config.Locations[HardPoint].ReviveLocations[math.random(1, #Config.Locations[HardPoint].ReviveLocations)]
        ESX.Game.Teleport(cache.ped, coords) 
    end
end

local function rejectPlayer()
    if not PlayerGang then 
        local coords = Config.Locations[HardPoint].RejectLocations[math.random(1, #Config.Locations[HardPoint].RejectLocations)]
        ESX.Game.Teleport(cache.ped, coords) 
        return true
    end
    return false
end

local function toggleKillFeed(bool)
    TriggerEvent('c4u_killfeed:client:ToggleKillFeed', bool, false)
end

local function createBlips(location)
    FirstBlip = AddBlipForCoord(location.Prop)
	SetBlipSprite(FirstBlip,  478)
	SetBlipColour(FirstBlip,  5)
	SetBlipAlpha(FirstBlip, 250)
	SetBlipScale(FirstBlip, 1.0)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString('Hard Point')
	EndTextCommandSetBlipName(FirstBlip)

    SecondBlip = AddBlipForRadius(location.Prop, 150.0)
    SetBlipHighDetail(SecondBlip, true)
	SetBlipColour(SecondBlip, 1)
	SetBlipAlpha (SecondBlip, 128)
end

local function updateGangLeaderboard(visible)
    local gangsToSend = GangScore or {}
    SendNUIMessage({
        action = 'hardpoint:gang-leaderboard',
        data = {
            visible = visible,
            gangs = gangsToSend
        }
    })
end

local function showWinner(winnerGangName)
    local playerGang = getPlayerGang()
    local isWinnerGang = winnerGangName and playerGang and playerGang.name == winnerGangName
    
    SendNUIMessage({
        action = 'hardpoint:winner',
        data = {
            visible = true,
            winnerGangName = winnerGangName or "No Winner",
            showCollectMessage = isWinnerGang
        }
    })
end

local function hideWinner()
    SendNUIMessage({
        action = 'hardpoint:winner',
        data = {
            visible = false,
            winnerGangName = ""
        }
    })
end

local function registerEntry()
    if not IsInFightMode then return end
    TriggerServerEvent('hardpoint:server:onEntry')
end

local function registerExit()
    TriggerServerEvent('hardpoint:server:onExit')
end

local function startHardPoint()
    local location = Config.Locations[HardPoint]
    if not location then return end
    PlayerGang = getPlayerGang()

    if PlayerGang then

        createBlips(location)
        FirstBox = lib.zones.poly({
            points = location.FirstBox,
            thickness = 50,
            debug = true,
            inside = function() 
                InsideFirstBox = true
                deleteVehicle()
            end,
            onEnter = function()
                InsideFirstBox = true
                registerEntry()
                blockEntryTime()
            end,
            onExit = function()
                InsideFirstBox = false
                registerExit()
            end
        })
    end

    SecondBox = lib.zones.poly({
        points = location.SecondBox,
        thickness = 100,
        debug = false,
        inside = function()
            InsideSecondBox = true
            drawWallMarkers(location)
            drawPropMarkers(location)
        end,
        onEnter = function()
            if rejectPlayer() then return end
            InsideSecondBox = true
            toggleKillFeed(true)
            if IsInFightMode then 
                updateGangLeaderboard(true)
            end
        end,
        onExit = function()
            InsideSecondBox = false
            toggleKillFeed(false)
            updateGangLeaderboard(false)
        end
    })
end

local function endHardPoint()
    if FirstBox then FirstBox:remove() end
    if SecondBox then SecondBox:remove() end
    RemoveBlip(FirstBlip)
    RemoveBlip(SecondBlip)
    SendNUIMessage({ action = 'hardpoint:timer', data = { visible = false} })
    updateGangLeaderboard(false)
    IsInFightMode = false
    FightTimeLeft = 0
    FirstBox = nil
    SecondBox = nil
    InsideFirstBox = false
    InsideSecondBox = false
    HardPoint = nil
    FirstBlip = nil
    SecondBlip = nil
end

local function updateTimer(phase, timeLeft, totalTime)
    SendNUIMessage({
        action = 'hardpoint:timer',
        data = {
            visible = true,
            phase = phase,
            timeLeft = timeLeft,
            totalTime = totalTime
        }
    })
end

local function updateRewardPrompt(visible)
    SendNUIMessage({
        action = 'hardpoint:reward-prompt',
        data = {
            visible = visible
        }
    })
end

local function showRewardPopup()
    SendNUIMessage({
        action = 'hardpoint:reward-popup',
        data = {
            visible = true
        }
    })
    SetNuiFocus(true, true)
end

local function hideRewardPopup()
    SendNUIMessage({
        action = 'hardpoint:reward-popup',
        data = {
            visible = false
        }
    })
    SetNuiFocus(false, false)
end

local function startCollect(hardpoint)
    CollectHardPoint = hardpoint
    if CollectPoint then
        CollectPoint:remove()
        CollectPoint = nil
    end
    if PropPoint then
        PropPoint:remove()
        PropPoint = nil
    end

    CollectPoint = lib.points.new({
        coords = Config.Locations[hardpoint].Prop,
        distance = 2.0,
        onEnter = function()
            updateRewardPrompt(true)
        end,
        onExit = function()
            updateRewardPrompt(false)
            hideRewardPopup()
        end,
        nearby = function()
            if IsControlJustReleased(0, 38) then
                if CanCollectReward then
                    showRewardPopup()
                end
            end
        end,
    })
    
    PropPoint = lib.points.new({
        coords = Config.Locations[hardpoint].Prop,
        distance = 20.0,
        nearby = function()
            drawPropMarkers(Config.Locations[hardpoint])
        end,
    })
end

local function startNotificationTimer()
    CreateThread(function()
        local time = Config.NotificationTime
        updateTimer('notify', time, Config.NotificationTime)
        
        while time > 0 do
            Wait(1000)
            time = time - 1
            if time >= 0 then
                updateTimer('notify', time, Config.NotificationTime)
            end
        end
    end)
end

local function startFightTimer()
    CreateThread(function()
        FightTimeLeft = Config.FightTime
        updateTimer('fight', FightTimeLeft, Config.FightTime)
        
        while FightTimeLeft > 0 do
            Wait(1000)
            FightTimeLeft = FightTimeLeft - 1
            if FightTimeLeft >= 0 then
                updateTimer('fight', FightTimeLeft, Config.FightTime)
            end
        end
    end)
end

local function startWeaponCheck()
    CreateThread(function()
        while HardPoint and not IsInFightMode do 
            if InsideSecondBox and IsPedArmed(cache.ped, 1|2|4|6|7) then 
                TriggerEvent('ox_inventory:disarm', true)
            end
            Wait(100)
        end
    end)
end

RegisterNUICallback('collectReward', function(data, cb)
    if CanCollectReward then
        CanCollectReward = false
        hideRewardPopup()
        updateRewardPrompt(false)
        TriggerServerEvent('hardpoint:server:collectReward', CollectHardPoint)
        CollectHardPoint = nil
        if CollectPoint then
            CollectPoint:remove()
            CollectPoint = nil
        end
        if PropPoint then
            PropPoint:remove()
            PropPoint = nil
        end
    end
    cb('ok')
end)

RegisterNUICallback('closeRewardPopup', function(data, cb)
    hideRewardPopup()
    cb('ok')
end)


RegisterNetEvent('hardpoint:client:onNotifyPhaseStarted')
AddEventHandler('hardpoint:client:onNotifyPhaseStarted', function(hardpoint)
    HardPoint = hardpoint
    startHardPoint()
    startWeaponCheck()
    if PlayerGang then 
        startNotificationTimer()
    end
end)

RegisterNetEvent('hardpoint:client:onFightPhaseStarted')
AddEventHandler('hardpoint:client:onFightPhaseStarted', function()
    if not PlayerGang then 
        SendNUIMessage({ action = 'hardpoint:timer', data = { visible = false} })
        return 
    end
    IsInFightMode = true

    if InsideFirstBox then 
        registerEntry()
    end

    Wait(100)
    
    SendNUIMessage({
        action = 'hardpoint:timer',
        data = {
            visible = true,
            phase = 'fight-started',
            showMessage = true
        }
    })

    if InsideSecondBox then 
        updateGangLeaderboard(true)
    end
    
    Wait(3000)
    
    startFightTimer()
    
end)

RegisterNetEvent('hardpoint:client:onFightPhaseEnded')
AddEventHandler('hardpoint:client:onFightPhaseEnded', function(winner, hardpoint)
    endHardPoint()

    if not PlayerGang then return end

    local winnerGangName = winner and winner.gangName or nil
    showWinner(winnerGangName)

    CreateThread(function()
        Wait(10000)
        hideWinner()
    end)

    if not winnerGangName then return end

    if PlayerGang.name == winnerGangName then 
        CanCollectReward = true
        TriggerServerEvent('hardpoint:server:setCanCollectReward', hardpoint)
        startCollect(hardpoint)
        CreateThread(function()
            CollectTimeLeft = Config.CollectTime 
            
            while CollectTimeLeft > 0 and CanCollectReward do
                Wait(1000)
                CollectTimeLeft = CollectTimeLeft - 1
            end
            
            if CollectTimeLeft <= 0 and CanCollectReward then
                CanCollectReward = false
                hideRewardPopup()
                updateRewardPrompt(false)
                if CollectPoint then
                    CollectPoint:remove()
                    CollectPoint = nil
                end
                if PropPoint then
                    PropPoint:remove()
                    PropPoint = nil
                end
            end
        end)
    end   
end)

RegisterNetEvent('esx:onPlayerDeath')
AddEventHandler('esx:onPlayerDeath', function(data)
    if not HardPoint or not IsInFightMode then
        return
    end
    if not InsideFirstBox and not InsideSecondBox then 
        return
    end
    if InsideSecondBox and not InsideFirstBox and data.killerServerId then
        TriggerServerEvent('hardpoint:server:onPlayerDeath', data.killerServerId)
    elseif InsideSecondBox and data.killerServerId then 
        TriggerServerEvent('hardpoint:server:onPlayerDeathStat', data.killerServerId)
    end
    registerExit()
    Wait(Config.Locations[HardPoint].ReviveTime * 1000)
    local coords = Config.Locations[HardPoint].ReviveLocations[math.random(1, #Config.Locations[HardPoint].ReviveLocations)]
    ESX.Game.Teleport(cache.ped, coords)
    Wait(150)
    TriggerEvent('esx_ambulancejob:revive_in_position', coords)
end)

lib.callback.register('hardpoint:client:isInSecondBox', function()
	return InsideSecondBox and not InsideFirstBox
end)

local function updatePunishmentTimer(visible, timeLeft)
    SendNUIMessage({
        action = 'hardpoint:punishment',
        data = {
            visible = visible,
            timeLeft = timeLeft
        }
    })
end

local function punishPlayer()
    if not HardPoint then return end
    local coords = Config.Locations[HardPoint].ReviveLocations[math.random(1, #Config.Locations[HardPoint].ReviveLocations)]
    ESX.Game.Teleport(cache.ped, coords)
    Wait(500)
    FreezeEntityPosition(cache.ped, true)
    
    updatePunishmentTimer(true, Config.PunishmentTime)
    
    local timer = lib.timer(Config.PunishmentTime * 1000, function() 
        FreezeEntityPosition(cache.ped, false)
        updatePunishmentTimer(false, 0)
    end, true)
    
    CreateThread(function()
        while timer:getTimeLeft('ms') > 0 do
            Wait(100)
            local timeLeftSeconds = math.floor(timer:getTimeLeft('s'))
            updatePunishmentTimer(true, timeLeftSeconds)
            if IsPedArmed(cache.ped, 1|2|4|6|7) then
                TriggerEvent('ox_inventory:disarm', true)
            end
        end
        updatePunishmentTimer(false, 0)
    end)
end

RegisterNetEvent('hardpoint:client:punish')
AddEventHandler('hardpoint:client:punish', function()
    punishPlayer()
end)

RegisterNetEvent('hardpoint:client:onScoreUpdate')
AddEventHandler('hardpoint:client:onScoreUpdate', function(data)
    if not PlayerGang then return end
    if not IsInFightMode then return end
    GangScore = data
    if IsInFightMode then 
        updateGangLeaderboard(InsideSecondBox)
    end
end)

exports('IsInHardPoint', function()
    if not HardPoint or not IsInFightMode then
        return false
    end
    if not InsideFirstBox and not InsideSecondBox then 
        return false
    end
    return true
end)

