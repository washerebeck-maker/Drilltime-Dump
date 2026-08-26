
local CrateDropObject, ParachuteObject, PickupObject, SoundID

local InProgress = false

RegisterNetEvent("elder_drilltime:cratedrop:client:create_drop")
AddEventHandler("elder_drilltime:cratedrop:client:create_drop", function() 
	if not InProgress then
        InProgress = true
        Citizen.CreateThread(function()
            local playerCoords = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 10.0, 0.0)
            local ray = StartShapeTestRay(vector3(playerCoords.x, playerCoords.y, playerCoords.z) + vector3(0.0, 0.0, 500.0), vector3(playerCoords.x, playerCoords.y, playerCoords.z), -1, -1, 0)
            local _, hit, impactCoords = GetShapeTestResult(ray)
            if hit == 0 or (hit == 1 and #(vector3(playerCoords.x, playerCoords.y, playerCoords.z) - vector3(impactCoords)) < 10.0) then
                CrateDrop(playerCoords)
            else
                InProgress = false
                Notify(Strings.cant_create_drop, 'error')
                return
            end
        end)
    else
        Notify(Strings.drop_in_progress, 'error')
    end
end)

function createDrop(coords)
	if not InProgress then
        InProgress = true        
        local ray = StartShapeTestRay(vector3(coords.x, coords.y, coords.z) + vector3(0.0, 0.0, 500.0), vector3(coords.x, coords.y, coords.z), -1, -1, 0)
        local _, hit, impactCoords = GetShapeTestResult(ray)
        if hit == 0 or (hit == 1 and #(vector3(coords.x, coords.y, coords.z) - vector3(impactCoords)) < 10.0) then
            CreateThread(function() 
				CrateDrop2(coords)
			end)
			return true
        else
            InProgress = false               
            return false
        end 
    else
        return false
    end
end

exports('createDrop',createDrop)

CrateDrop2 = function(coords)
    TriggerServerEvent('elder_drilltime:cratedrop:server:notify_all', Strings.crate_drop_create_notify)
    Wait(Config.CrateDrop.NotifyTime * 1000)
    Citizen.CreateThread(function()
        for i = 1, #Config.CrateDrop.Models do
            RequestModel(GetHashKey(Config.CrateDrop.Models[i]))
            while not HasModelLoaded(GetHashKey(Config.CrateDrop.Models[i])) do
                Wait(1)
            end
        end

        local crate_spawn_coords = vector3(coords.x, coords.y, coords.z - 1.0)
        CrateDropObject = CreateObject(GetHashKey("prop_box_wood02a_pu"), crate_spawn_coords, true, true, true) 
        --SetEntityLodDist(CrateDropObject, 1000)
        --ActivatePhysics(CrateDropObject)
        --SetDamping(CrateDropObject, 2, 0.1)
        --SetEntityVelocity(CrateDropObject, 0.0, 0.0, -0.2)

        ParachuteObject = CreateObject(GetHashKey("p_cargo_chute_s"), crate_spawn_coords, true, true, true)
        --SetEntityLodDist(ParachuteObject, 1000)
        --SetEntityVelocity(ParachuteObject, 0.0, 0.0, -0.2)

       
        PickupObject = CreateObject(GetHashKey("hei_prop_heist_ammo_box"), crate_spawn_coords, true, true, true)
        --ActivatePhysics(PickupObject)
        --SetDamping(PickupObject, 2, 0.0245)
        --SetEntityVelocity(PickupObject, 0.0, 0.0, -0.2)

       -- SoundID = GetSoundId() 
       -- PlaySoundFromEntity(SoundID, "Crate_Beeps", PickupObject, "MP_CRATE_DROP_SOUNDS", true, 0)

        

        RequestNamedPtfxAsset('core')
        while not HasNamedPtfxAssetLoaded('core') do 
            Citizen.Wait(10) 
        end

        UseParticleFxAssetNextCall("core")
        SetParticleFxNonLoopedColour(1.0, 0.0, 0.0)
        StartParticleFxLoopedOnEntity('exp_grd_flare', PickupObject, 0.0, 0.0, -0.5, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0)


        AttachEntityToEntity(ParachuteObject, PickupObject, 0, 0.0, 0.0, 0.1, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
        AttachEntityToEntity(PickupObject, CrateDropObject, 0, 0.0, 0.0, 0.3, 0.0, 0.0, 0.0, false, false, true, false, 2, true) 

        

        TriggerServerEvent('elder_drilltime:cratedrop:server:notify_all', 'Crate dropped. Location marked on map')
        
        DetachEntity(ParachuteObject, true, true)
        DeleteEntity(ParachuteObject)
        DetachEntity(PickupObject)
        
        FreezeEntityPosition(PickupObject,true)
        

        local data = {
            coords = coords,
            pickup = PickupObject,
            soundid = SoundID
        }

        TriggerServerEvent('elder_drilltime:cratedrop:server:on_cratedrop_created', data)
    end)
end

CrateDrop = function(coords)
    TriggerServerEvent('elder_drilltime:cratedrop:server:notify_all', Strings.crate_drop_create_notify)
    Wait(Config.CrateDrop.NotifyTime * 1000)
    Citizen.CreateThread(function()
        for i = 1, #Config.CrateDrop.Models do
            RequestModel(GetHashKey(Config.CrateDrop.Models[i]))
            while not HasModelLoaded(GetHashKey(Config.CrateDrop.Models[i])) do
                Wait(1)
            end
        end

        local crate_spawn_coords = vector3(coords.x, coords.y, coords.z + 2.0)
        CrateDropObject = CreateObject(GetHashKey("prop_box_wood02a_pu"), crate_spawn_coords, true, true, true) 
        SetEntityLodDist(CrateDropObject, 1000)
        ActivatePhysics(CrateDropObject)
        SetDamping(CrateDropObject, 2, 0.1)
        SetEntityVelocity(CrateDropObject, 0.0, 0.0, -0.2)

        ParachuteObject = CreateObject(GetHashKey("p_cargo_chute_s"), crate_spawn_coords, true, true, true)
        SetEntityLodDist(ParachuteObject, 1000)
        SetEntityVelocity(ParachuteObject, 0.0, 0.0, -0.2)

       
        PickupObject = CreateObject(GetHashKey("hei_prop_heist_ammo_box"), crate_spawn_coords, true, true, true)
        ActivatePhysics(PickupObject)
        SetDamping(PickupObject, 2, 0.0245)
        SetEntityVelocity(PickupObject, 0.0, 0.0, -0.2)

       -- SoundID = GetSoundId() 
       -- PlaySoundFromEntity(SoundID, "Crate_Beeps", PickupObject, "MP_CRATE_DROP_SOUNDS", true, 0)

        

        RequestNamedPtfxAsset('core')
        while not HasNamedPtfxAssetLoaded('core') do Citizen.Wait(10) end

        UseParticleFxAssetNextCall("core")
        SetParticleFxNonLoopedColour(1.0, 0.0, 0.0)
        StartParticleFxLoopedOnEntity('exp_grd_flare', PickupObject, 0.0, 0.0, -0.5, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0)


        AttachEntityToEntity(ParachuteObject, PickupObject, 0, 0.0, 0.0, 0.1, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
        AttachEntityToEntity(PickupObject, CrateDropObject, 0, 0.0, 0.0, 0.3, 0.0, 0.0, 0.0, false, false, true, false, 2, true) 

        while HasObjectBeenBroken(CrateDropObject) == false do
            Wait(1)
        end

        TriggerServerEvent('elder_drilltime:cratedrop:server:notify_all', 'Crate dropped. Location marked on map')
       
        DetachEntity(ParachuteObject, true, true)
        DeleteEntity(ParachuteObject)
        DetachEntity(PickupObject)
        Wait(2000)
        FreezeEntityPosition(PickupObject,true)
        

        local data = {
            coords = coords,
            pickup = PickupObject,
            soundid = SoundID
        }

        TriggerServerEvent('elder_drilltime:cratedrop:server:on_cratedrop_created', data)
    end)
end

local CurrentDropCoords = nil
local CurrentPickUp = nil
local CurrentSoundID = nil
local CurrentDropBlip = nil
local CurrentZoneBlip = nil


RegisterNetEvent("elder_drilltime:cratedrop:client:on_cratedrop_created")
AddEventHandler("elder_drilltime:cratedrop:client:on_cratedrop_created", function(data) 
    CurrentDropCoords = data.coords
    CurrentPickUp = data.pickup
    CurrentSoundID = data.soundid
    CreateCrateBlip()
    StartLootDrop()
end)

RegisterNetEvent("elder_drilltime:cratedrop:client:on_cratedrop_ended")
AddEventHandler("elder_drilltime:cratedrop:client:on_cratedrop_ended", function(data) 
    Wait(1000)
    RemoveBlip(CurrentDropBlip)
    RemoveBlip(CurrentZoneBlip)
    CurrentDropBlip = nil
    CurrentZoneBlip = nil
    CurrentDropCoords = nil
    InProgress = false
    for i = 1, #Config.CrateDrop.Models do
        Wait(0)
        SetModelAsNoLongerNeeded(GetHashKey(Config.CrateDrop.Models[i]))
    end
end)

local IsLooting = false

StartCheckDistance = function(coords)
    CreateThread(function()
        while IsLooting do 
            local distance = GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), coords, true)
            if distance > 2.5 then
                lib.cancelProgress()
            end
            Wait(100)
        end
    end)
end

StartLootDrop = function()
    Citizen.CreateThread(function()
        while CurrentDropCoords do
            local wait = 500
            local ped = PlayerPedId()
            local distance = GetDistanceBetweenCoords(GetEntityCoords(ped), CurrentDropCoords, true)
            if distance < 15.0 then
                wait = 1
                if IsPedInAnyVehicle(ped, false) then
                    DeleteVehicle(GetVehiclePedIsIn(ped, false))
                end
                if distance < 2.0 then
                    ESX.ShowHelpNotification('Press ~INPUT_CONTEXT~ to capture the drop')
                    if IsControlJustPressed(0, 38) then
                        IsLooting = true
                        StartCheckDistance(CurrentDropCoords)
                        FreezeEntityPosition(ped, true)
                        if lib.progressBar({
                            duration = Config.CrateDrop.LootTime * 1000,
                            label = 'Looting Drop ( X to cancel )',
                            useWhileDead = false,
                            canCancel = true,
                            disable = {
                                car = true,
                                move = true,
                                combat = true
                            },
                            anim = {
                                dict = 'anim@gangops@facility@servers@bodysearch@',
                                clip = 'player_search'
                            },

                        }) then
                            FreezeEntityPosition(ped, false)
                            TriggerServerEvent('elder_drilltime:cratedrop:server:on_cratedrop_ended')
                            RemovePickUp(CurrentDropCoords)
                            IsLooting = false
                        else 
                            FreezeEntityPosition(ped, false)
                            IsLooting = false
                        end
                    end
                end
            end
            Citizen.Wait(wait)
        end
    end)
end

CreateCrateBlip = function()
    CurrentDropBlip = AddBlipForCoord(CurrentDropCoords)
	SetBlipSprite(CurrentDropBlip,  94)
	SetBlipColour(CurrentDropBlip,  5)
	SetBlipAlpha(CurrentDropBlip, 250)
	SetBlipScale(CurrentDropBlip, 1.0)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString('CrateDrop')
	EndTextCommandSetBlipName(CurrentDropBlip)

    CurrentZoneBlip = AddBlipForRadius(CurrentDropCoords, 150.0)
    SetBlipHighDetail(CurrentZoneBlip, true)
	SetBlipColour(CurrentZoneBlip, 1)
	SetBlipAlpha (CurrentZoneBlip, 128)
end

local function RequestNetworkControl(entity)
    NetworkRequestControlOfEntity(entity)
    local timeout = 2000
    while timeout > 0 and not NetworkHasControlOfEntity(entity) do
        Wait(100)
        timeout = timeout - 100
    end
    SetEntityAsMissionEntity(entity, true, true)
    timeout = 2000
    while timeout > 0 and not IsEntityAMissionEntity(entity) do
        Wait(100)
        timeout = timeout - 100
    end
    return NetworkHasControlOfEntity(entity)
end

RemovePickUp = function()
    local objPool = GetGamePool('CObject')
    for i = 1, #objPool do
        local ent = objPool[i]
        if GetEntityModel(ent) == GetHashKey("hei_prop_heist_ammo_box") then
            if #(GetEntityCoords(ent) - CurrentDropCoords) < 2.0 then
                RequestNetworkControl(ent)
                DeleteObject(ent)
            end
        end
    end
end

AddEventHandler('esx:onPlayerDeath', function(data)
    if not CurrentDropCoords then return end
    local distance = GetDistanceBetweenCoords(vector3(data.victimCoords.x,data.victimCoords.y,data.victimCoords.z), CurrentDropCoords, true)
    if distance <= 150 then
        Wait(30 * 1000)
        TriggerEvent('esx_ambulancejob:revive')
    end
end)
