local TargetClone = nil

local wantedIsOpen = false
local wantedName = ''
local wantedByName = ''
local wantedMessage = 'person got found lacking and now bodybagged by'

local function sendWanted(open, imgUrl)
    SendNUIMessage({
        action = 'wanted:set',
        open = open,
        name = wantedName,
        player1Name = wantedName,
        player2Name = wantedByName ~= '' and wantedByName or wantedName,
        message = wantedMessage,
        imgUrl = imgUrl or ''
    })
end

local function fetchPedHeadshot(ped)
    if not ped or ped == 0 or not DoesEntityExist(ped) then
        return nil, nil, nil
    end

    local handle = RegisterPedheadshot(ped)
    local start = GetGameTimer()

    while not IsPedheadshotValid(handle) do
        if (GetGameTimer() - start) > 2500 then
            return nil, nil, nil
        end
        Wait(0)
    end

    while not IsPedheadshotReady(handle) do
        if (GetGameTimer() - start) > 5000 then
            return nil, nil, nil
        end
        Wait(0)
    end

    local txd = GetPedheadshotTxdString(handle)
    local cacheBuster = GetGameTimer()
    local imgUrl = ('https://nui-img/%s/%s?t=%d'):format(txd, txd, cacheBuster)

    return handle, txd, imgUrl
end

local function closeWantedOverlay()
    if not wantedIsOpen then return end
    wantedIsOpen = false
    sendWanted(false)
end

local function openWantedOverlay(victimDisplayName, attackerDisplayName, imgUrl)
    if wantedIsOpen then return end
    wantedIsOpen = true

    wantedName = (victimDisplayName and victimDisplayName ~= '') and victimDisplayName or 'Unknown'
    wantedByName = (attackerDisplayName and attackerDisplayName ~= '') and attackerDisplayName or 'Unknown'

    local url = (type(imgUrl) == 'string' and imgUrl ~= '') and imgUrl or nil
    sendWanted(true, url)

    CreateThread(function()
        Wait(15000)
        closeWantedOverlay()
    end)
end

RegisterNetEvent('elder_bodybag:client:wanted_overlay', function(victimDisplayName, attackerDisplayName, imgUrl)
    openWantedOverlay(victimDisplayName, attackerDisplayName, imgUrl)
end)

CreateThread(function()
    SetNuiFocus(false, false)
    while true do
        if wantedIsOpen then
            if IsControlJustReleased(0, 322) or IsControlJustReleased(0, 177) then
                closeWantedOverlay()
            end
            Wait(0)
        else
            Wait(100)
        end
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    sendWanted(false)
end)

local function IsPlayerDead(target)
    local target_id = GetPlayerServerId(target)
    return exports['esx_ambulancejob']:IsTargetDead(target_id)
end

local function CheckTarget(target)
    local result = promise:new()
    ESX.TriggerServerCallback('elder_bodybag:server:check_target', function(data)
        result:resolve(data)
    end, GetPlayerServerId(target))
    return Citizen.Await(result)
end

local function ClonePlayer(target)
    TargetClone = ClonePed(target, false, false, true)
    local coords = GetEntityCoords(target)
    SetEntityCoords(TargetClone, coords.x, coords.y, coords.z - 0.9)
    SetEntityHealth(TargetClone, 0)
end

local function PlayCustScene()
    local gender = GetEntityModel(PlayerPedId())
    local scene = nil
    if gender == GetHashKey('mp_m_freemode_01') or gender == 'mp_m_freemode_01' then
        scene = 'MP_INT_MCS_18_A1'
    else
        scene = 'MP_INT_MCS_18_A2'
    end
    SetCutsceneTriggerArea(0.0, 0.0, 0.0, 0.0, 121.6249, 0.0);
    navmeshBlockingObj = AddNavmeshBlockingObject(-1314.997, -1721.084, 1.1493, 100.0, 100.0, 100.0, 0.0, false, 7)
    SetPedNonCreationArea(-1324.736, -1756.909, -10.0, -1299.695, -1688.181, 10.0)
    SetOverrideWeather('CLEARING')
    SetTransitionTimecycleModifier("Kifflom", 1.0)
    NetworkOverrideClockTime(18, 0, 0)
    N_0xfb680d403909dc70(1, PlayerId() + 32)
    SetRainLevel(0.0)
    while not HasThisCutsceneLoaded(scene) do
        RequestCutsceneWithPlaybackList(scene, 29, 8)
        Wait(0)
    end
    StartCutsceneAtCoords(vector3(-1314.997, -1721.084, 1.1493), 0)
    DoScreenFadeIn(250)
    local tripped = false
    repeat
        Wait(0)
        if (GetCutsceneTotalDuration() - GetCutsceneTime() <= 250) then
            DoScreenFadeOut(250)
            tripped = true
        end
    until not IsCutscenePlaying()
    if (not tripped) then
        DoScreenFadeOut(100)
        Wait(150)
    end
    RemoveCutscene()
    DoScreenFadeIn(500)
    ClearTimecycleModifier()
    ClearPedNonCreationArea()
    RemoveNavmeshBlockingObject(navmeshBlockingObj)
end

local function BodyBag(target)
    local targetPed = GetPlayerPed(target)
    local victimServerId = GetPlayerServerId(target)

    ClonePlayer(targetPed)

    local handle, _, imgUrl = fetchPedHeadshot(TargetClone)

    TriggerServerEvent('elder_bodybag:server:headshot_ready', imgUrl or '', victimServerId)

    if handle ~= nil then
        Wait(400)
        UnregisterPedheadshot(handle)
    end

    local player_ped = GetPlayerPed(-1)
    lib.requestAnimDict('amb@medic@standing@kneel@base')
    lib.requestAnimDict('anim@gangops@facility@servers@bodysearch@')
    TaskPlayAnim(player_ped, "amb@medic@standing@kneel@base", "base", 8.0, -8.0, -1, 1, 0, false, false, false)
    TaskPlayAnim(player_ped, "anim@gangops@facility@servers@bodysearch@", "player_search", 8.0, -8.0, -1, 48, 0, false, false, false)
    Citizen.Wait(5000)
    ClearPedTasksImmediately(player_ped)
    Wait(500)

    if DoesEntityExist(TargetClone) then
        DeletePed(TargetClone)
        TargetClone = nil
    end

    local coords = GetEntityCoords(player_ped)
    local forward = GetEntityForwardVector(player_ped)
    local x, y, z = table.unpack(coords + forward * 1.0)
    lib.requestModel(Config.BodyBag.Prop)
    local BodyBagObj = CreateObject(joaat(Config.BodyBag.Prop), x, y, z, true, false, true)
    SetEntityHeading(BodyBagObj, GetEntityHeading(player_ped))
    PlaceObjectOnGroundProperly(BodyBagObj)
    FreezeEntityPosition(BodyBagObj, true)
    Citizen.Wait(Config.BodyBag.PropTime * 1000)
    DeleteEntity(BodyBagObj)
end

RegisterNetEvent('elder_bodybag:client:use_body_bag')
AddEventHandler('elder_bodybag:client:use_body_bag', function()
    local coords = GetEntityCoords(cache.ped)
    local target = lib.getClosestPlayer(vec3(coords.x, coords.y, coords.z), 2.0, false)
    if not target or not IsPlayerDead(target) then
        return Notify('no dead player nearby', 'error')
    end

    if not CheckTarget(target) then
        return Notify('you cannot body bag this player', 'error')
    end

    TriggerServerEvent('elder_bodybag:server:used_body_bag', GetPlayerServerId(target))
    BodyBag(target)
    Notify('Sent that boi to GOD !', 'success')
end)

RegisterNetEvent('elder_bodybag:client:target_body_bag')
AddEventHandler('elder_bodybag:client:target_body_bag', function()
    SetEntityVisible(cache.ped, false, 0)
    SetEntityHealth(cache.ped, 200)
    Wait(1000)
    PlayCustScene()
    TriggerEvent('esx_ambulancejob:revive_deathmatch')
    SetEntityVisible(cache.ped, true, 0)
    TriggerServerEvent('elder_bodybag:server:send_community_service')
end)