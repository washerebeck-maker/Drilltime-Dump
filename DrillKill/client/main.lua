-- Global tracking tables
local headlessEntities = {}
local isMainLoopRunning = false
local enabledHeadlessStates = {}
local needsMainLoopUpdate = false
local settingsPrefix = "kgore_setting_"

-- Settings management functions
function LoadSavedSettings()
    local settingNames = {"playerGore", "npcGore", "bloodSplatter", "shootDead", "painSystem"}
    
    for _, settingName in ipairs(settingNames) do
        local savedValue = GetResourceKvpString(settingsPrefix .. settingName)
        if savedValue ~= nil then
            Config[settingName] = (savedValue == "true")
        end
    end
end

function SaveSetting(settingName, value)
    SetResourceKvp(settingsPrefix .. settingName, tostring(value))
end

CreateThread(function()
    Wait(500)
    LoadSavedSettings()
end)

-- Cached native functions
local GetEntityCoords = GetEntityCoords
local DoesEntityExist = DoesEntityExist
local PlayerPedId = PlayerPedId
local IsEntityAPed = IsEntityAPed
local IsPedAPlayer = IsPedAPlayer
local GetEntityFromStateBagName = GetEntityFromStateBagName
local RequestModel = RequestModel
local HasModelLoaded = HasModelLoaded
local GetGameTimer = GetGameTimer
local SetPedResetFlag = SetPedResetFlag
local DeleteEntity = DeleteEntity
local GetEntityHeading = GetEntityHeading
local GetEntityBoneIndex = GetEntityBoneIndex
local GetEntityModel = GetEntityModel
local RequestNamedPtfxAsset = RequestNamedPtfxAsset
local HasPtfxAssetLoaded = HasPtfxAssetLoaded
local UseParticleFxAsset = UseParticleFxAsset
local Wait = Wait

-- Constants
local lastCleanupTime = 0
local lastParticleCleanupTime = 0
local headBoneIndex = 31086

-- Set headshot state for entity
function SetHeadshotState(pedEntity, isHeadshot)
    if not DoesEntityExist(pedEntity) or not IsEntityAPed(pedEntity) then
        return
    end
    
    -- Check if ped model should be ignored
    local pedModel = GetEntityModel(pedEntity)
    if Config.PedModelsToIgnore[pedModel] then
        return
    end
    
    -- Update entity state
    local entityState = Entity(pedEntity).state
    entityState:set("isHeadshot", isHeadshot, true)
    
    -- Register/unregister with server
    local networkId = NetworkGetNetworkIdFromEntity(pedEntity)
    if networkId ~= 0 then
        if isHeadshot then
            TriggerServerEvent("kGore:registerHeadless", networkId)
        else
            TriggerServerEvent("kGore:unregisterHeadless", networkId)
        end
    end
end

-- Calculate rotation and position for decapitation effects
function GetRotations(pedEntity)
    local rotationOffset = 90.0
    local playerCoords = GetEntityCoords(PlayerPedId())
    local pedCoords = GetEntityCoords(pedEntity)
    local pedHeading = GetEntityHeading(pedEntity)
    
    local headCoords = GetPedBoneCoords(pedEntity, headBoneIndex, 0.0, 0.0, 0.0)
    local headRotation = GetEntityBoneRotation(pedEntity, GetPedBoneIndex(pedEntity, headBoneIndex))
    
    -- Calculate angle between player and ped
    local deltaX = playerCoords.x - pedCoords.x
    local deltaY = playerCoords.y - pedCoords.y
    local angleToPlayer = math.atan2(deltaY, deltaX) * 180.0 / math.pi
    local relativeBearing = angleToPlayer - pedHeading
    
    -- Normalize angle to [-180, 180] range
    while relativeBearing > 180 do
        relativeBearing = relativeBearing - 360
    end
    while relativeBearing < -180 do
        relativeBearing = relativeBearing + 360
    end
    
    -- Determine direction and rotation
    local direction = ""
    local effectRotation = nil
    
    if relativeBearing >= -45 and relativeBearing < 45 then
        direction = "LEFT"
        effectRotation = vec3(headRotation.x, headRotation.y + rotationOffset, headRotation.z)
    elseif relativeBearing >= 45 and relativeBearing < 135 then
        direction = "FRONT"
        effectRotation = vec3(headRotation.x, headRotation.y, headRotation.z + rotationOffset)
    elseif relativeBearing >= 135 or relativeBearing < -135 then
        direction = "RIGHT"
        effectRotation = vec3(headRotation.x, headRotation.y - rotationOffset, headRotation.z)
    else
        direction = "BEHIND"
        effectRotation = vec3(headRotation.x, headRotation.y, headRotation.z - rotationOffset)
    end
    
    return effectRotation, direction
end

-- Particle effect management
local activeParticleEffects = {}

function SpawnNetworkedParticleOnPed(pedEntity, assetName, effectName, offset, rotation, scale)
    if not DoesEntityExist(pedEntity) or not IsEntityAPed(pedEntity) then
        return
    end
    
    -- Load particle asset
    RequestNamedPtfxAsset(assetName)
    while not HasNamedPtfxAssetLoaded(assetName) do
        Wait(10)
    end
    
    UseParticleFxAsset(assetName)
    local pedCoords = GetEntityCoords(pedEntity)
    local headBoneId = GetPedBoneIndex(pedEntity, headBoneIndex)
    local effectRotation, direction = GetRotations(pedEntity)
    
    local particleId = StartNetworkedParticleFxNonLoopedOnEntityBone(
        effectName, pedEntity, offset, effectRotation, headBoneId, 
        scale, false, false, false
    )
    
    RemoveNamedPtfxAsset(assetName)
    
    -- Track the effect
    activeParticleEffects[particleId] = {
        ped = pedEntity,
        asset = assetName,
        effectName = effectName,
        createdTime = GetGameTimer()
    }
    
    return particleId
end

function CleanupParticleEffects()
    for particleId, effectData in pairs(activeParticleEffects) do
        if DoesParticleFxLoopedExist(particleId) then
            StopParticleFxLooped(particleId, false)
        end
    end
    activeParticleEffects = {}
end

function SpawnParticleAtCoords(assetName, effectName, coords, rotation, scale)
    RequestNamedPtfxAsset(assetName)
    while not HasNamedPtfxAssetLoaded(assetName) do
        Wait(10)
    end
    
    UseParticleFxAsset(assetName)
    local particleId = StartNetworkedParticleFxNonLoopedAtCoord(
        effectName, coords.x, coords.y, coords.z, 
        rotation.x, rotation.y, rotation.z, 
        scale, false, false, false
    )
    
    activeParticleEffects[particleId] = {
        asset = assetName,
        effectName = effectName
    }
    
    return particleId
end

-- Create skull cap model for headless effect
function CreateSkullCap(pedEntity)
    if not pedEntity or not DoesEntityExist(pedEntity) then
        return
    end
    
    local pedModel = GetEntityModel(pedEntity)
    if Config.PedModelsToIgnore[pedModel] then
        return
    end
    
    -- Clean up existing cap if it exists
    local existingData = headlessEntities[pedEntity]
    if existingData and existingData.cap then
        if DoesEntityExist(existingData.cap) then
            DeleteEntity(existingData.cap)
        end
    end
    
    -- Load skull cap model
    local function LoadSkullCapModel()
        local skullCapModel = 1025345587 -- Skull cap model hash
        if not HasModelLoaded(skullCapModel) then
            RequestModel(skullCapModel)
            while not HasModelLoaded(skullCapModel) do
                Wait(10)
            end
        end
        return skullCapModel
    end
    
    local skullCapModel = LoadSkullCapModel()
    local neckBoneIndex = GetPedBoneIndex(pedEntity, 24818) -- Neck bone
    local pedCoords = GetEntityCoords(pedEntity)
    
    -- Create skull cap object
    local skullCapObject = CreateObject(skullCapModel, pedCoords.x, pedCoords.y, pedCoords.z, false, false, false)
    SetEntityCollision(skullCapObject, false, false)
    
    -- Attach to neck bone
    AttachEntityToEntity(
        skullCapObject, pedEntity, neckBoneIndex,
        0.294, 0.023, -0.0, 0.0, -90.0, 160.0,
        false, false, false, false, 2, true
    )
    
    -- Store reference
    headlessEntities[pedEntity] = {cap = skullCapObject}
    SetModelAsNoLongerNeeded(skullCapModel)
    
    return skullCapObject
end

-- Main loop for headless entity management
function StartLoop()
    local sleepTime = 0
    local currentPlayerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(currentPlayerPed)
    local lastPlayerUpdateTime = 0
    local nearbyEntities = {}
    local entityCount = 0
    local lastScanTime = GetGameTimer()
    
    local function UpdateNearbyEntities()
        nearbyEntities = {}
        entityCount = 0
        
        for pedEntity, entityData in pairs(headlessEntities) do
            if DoesEntityExist(pedEntity) and enabledHeadlessStates[pedEntity] then
                entityCount = entityCount + 1
                nearbyEntities[entityCount] = {
                    entity = pedEntity,
                    coords = GetEntityCoords(pedEntity)
                }
            end
        end
        
        needsMainLoopUpdate = false
        lastScanTime = GetGameTimer()
    end
    
    needsMainLoopUpdate = true
    UpdateNearbyEntities()
    
    while isMainLoopRunning do
        local currentTime = GetGameTimer()
        
        -- Update player position periodically
        if currentTime - lastPlayerUpdateTime > 1000 then
            currentPlayerPed = PlayerPedId()
            playerCoords = GetEntityCoords(currentPlayerPed)
            lastPlayerUpdateTime = currentTime
        end
        
        -- Update nearby entities if needed
        if needsMainLoopUpdate then
            UpdateNearbyEntities()
        end
        
        -- Force update every 5 seconds
        if currentTime - lastScanTime > 5000 then
            needsMainLoopUpdate = true
            UpdateNearbyEntities()
        end
        
        if entityCount == 0 then
            sleepTime = 500
        else
            local foundActiveEntity = false
            local validEntityCount = 0
            
            for i = 1, entityCount do
                local entityInfo = nearbyEntities[i]
                local pedEntity = entityInfo.entity
                local entityData = headlessEntities[pedEntity]
                
                if pedEntity and entityData and enabledHeadlessStates[pedEntity] then
                    validEntityCount = validEntityCount + 1
                    
                    -- Check if gore is enabled for this entity type
                    local isPlayerPed = entityData.isPlayer
                    local goreEnabled = (isPlayerPed and Config.playerGore) or (not isPlayerPed and Config.npcGore)
                    
                    if goreEnabled then
                        local entityCoords = entityInfo.coords
                        local distanceToPlayer = #(entityCoords - playerCoords)
                        
                        if distanceToPlayer < Config.headCapDistance then
                            SetPedResetFlag(pedEntity, 166, 1)
                            foundActiveEntity = true
                            
                            -- Create skull cap if not exists
                            if not entityData.cap then
                                CreateSkullCap(pedEntity)
                            end
                        else
                            -- Remove skull cap if too far
                            if entityData.cap then
                                if DoesEntityExist(entityData.cap) then
                                    DeleteEntity(entityData.cap)
                                    entityData.cap = nil
                                end
                            end
                        end
                    else
                        -- Clean up cap if gore disabled
                        if entityData.cap then
                            if DoesEntityExist(entityData.cap) then
                                DeleteEntity(entityData.cap)
                                entityData.cap = nil
                            end
                        end
                    end
                else
                    needsMainLoopUpdate = true
                end
            end
            
            if validEntityCount ~= entityCount then
                needsMainLoopUpdate = true
            end
            
            sleepTime = foundActiveEntity and (Config.tickRate or 100) or 100
        end
        
        -- Periodic cleanup (every 10 seconds)
        if currentTime - lastCleanupTime > 10000 then
            local entitiesToRemove = {}
            
            for pedEntity, entityData in pairs(headlessEntities) do
                if not DoesEntityExist(pedEntity) or not enabledHeadlessStates[pedEntity] then
                    if entityData.cap and DoesEntityExist(entityData.cap) then
                        DeleteEntity(entityData.cap)
                    end
                    table.insert(entitiesToRemove, pedEntity)
                end
            end
            
            for i = 1, #entitiesToRemove do
                local entityToRemove = entitiesToRemove[i]
                headlessEntities[entityToRemove] = nil
                enabledHeadlessStates[entityToRemove] = nil
            end
            
            if #entitiesToRemove > 0 then
                needsMainLoopUpdate = true
            end
            
            CleanupParticleEffects()
            lastCleanupTime = currentTime
        end
        
        -- Stop loop if no entities remain
        if entityCount == 0 then
            local hasEntities = next(headlessEntities)
            if not hasEntities then
                isMainLoopRunning = false
            end
        end
        
        Wait(sleepTime)
    end
    
    isMainLoopRunning = false
end

-- State bag change handler for headshot detection
AddStateBagChangeHandler("isHeadshot", nil, function(bagName, key, value, reserved, replicated)
    local pedEntity = GetEntityFromStateBagName(bagName)
    
    if not DoesEntityExist(pedEntity) then
        return
    end
    
    if value then
        -- Store entity data
        local existingData = headlessEntities[pedEntity] or {}
        existingData.isPlayer = IsPedAPlayer(pedEntity)
        headlessEntities[pedEntity] = existingData
        enabledHeadlessStates[pedEntity] = true
        
        -- Apply headless effects
        KnockOffPedProp(pedEntity, true, true, true, true, true)
        ClearPedAlternateMovementAnim(pedEntity, 0, 1.0)
        ClearPedAlternateWalkAnim(pedEntity, 0, 1.0)
        ClearPedSecondaryTask(pedEntity)
        SetPedCanHeadIk(pedEntity, false)
        SetPedCanTorsoIk(pedEntity, false)
        ActivatePhysics(pedEntity)
        
        needsMainLoopUpdate = true
        
        -- Start main loop if not running
        if not isMainLoopRunning then
            isMainLoopRunning = true
            StartLoop()
        end
    else
        -- Disable headshot state
        enabledHeadlessStates[pedEntity] = false
        
        local entityData = headlessEntities[pedEntity]
        if entityData and entityData.cap then
            if DoesEntityExist(entityData.cap) then
                DeleteEntity(entityData.cap)
            end
            headlessEntities[pedEntity] = nil
        end
        
        needsMainLoopUpdate = true
    end
end)

-- Game event handler for damage detection
AddEventHandler("gameEventTriggered", function(eventName, eventData)
    if eventName ~= "CEventNetworkEntityDamage" then
        return
    end
    
    local victimEntity = eventData[1]
    local attackerEntity = eventData[2]
    local weaponHash = eventData[7]
    local isHeadshot = eventData[11]
    
    if not DoesEntityExist(victimEntity) or not IsEntityAPed(victimEntity) or not DoesEntityExist(attackerEntity) then
        return
    end
    
    if weaponHash ~= 0 and isHeadshot == 1 then
        -- Check if weapon can cause gore
        local isGoreWeapon = Config.goreWeapons[weaponHash]
        if not isGoreWeapon then
            return
        end
        
        -- Get participant names for debugging
        local victimName = IsPedAPlayer(victimEntity) and GetPlayerName(NetworkGetPlayerIndexFromPed(victimEntity)) or "NPC"
        local attackerName = IsPedAPlayer(attackerEntity) and GetPlayerName(NetworkGetPlayerIndexFromPed(attackerEntity)) or "Player"
        
        -- Check if gore should be applied
        local isVictimPlayer = IsPedAPlayer(victimEntity)
        local goreEnabled = (isVictimPlayer and Config.playerGore) or (not isVictimPlayer and Config.npcGore)
        
        -- Check if ped model should be ignored
        local victimModel = GetEntityModel(victimEntity)
        local shouldIgnore = Config.PedModelsToIgnore[victimModel]
        
        if goreEnabled and not shouldIgnore then
            local networkId = NetworkGetNetworkIdFromEntity(victimEntity)
            if networkId ~= 0 then
                SetPedCanHeadIk(victimEntity, false)
                SetHeadshotState(victimEntity, true)
                needsMainLoopUpdate = true
                
                -- Apply blood splatter effects
                if Config.bloodSplatter then
                    SpawnNetworkedParticleOnPed(
                        victimEntity, "scr_solomon3", "scr_trev4_747_blood_impact",
                        vec3(-0.1, 0.02, 0.0), vec3(180.0, 0.0, 0.0), 0.25
                    )
                    SpawnNetworkedParticleOnPed(
                        victimEntity, "core", "ent_sht_blood",
                        vec3(-0.0, 0.02, 0.0), vec3(0.0, 0.0, 0.0), 0.25
                    )
                end
            end
        end
    else
        -- Handle pain system for non-headshot hits
        if Config.goreWeapons[weaponHash] and Config.painSystem then
            if IsEntityAPed(victimEntity) and not IsPedAPlayer(victimEntity) then
                RequestAnimSet("move_injured_generic")
                while not HasAnimSetLoaded("move_injured_generic") do
                    Wait(0)
                end
                
                SetPedMovementClipset(victimEntity, "move_injured_generic", 0.0)
                StopCurrentPlayingSpeech(victimEntity, true)
                Wait(0)
                PlayPain(victimEntity, 8, 0, 0.0)
            end
        end
    end
end)

-- Cleanup functions
function CleanupAllHeadlessEntities()
    for pedEntity, entityData in pairs(headlessEntities) do
        if entityData.cap and DoesEntityExist(entityData.cap) then
            DeleteEntity(entityData.cap)
        end
    end
    headlessEntities = {}
end

-- Network event handlers
RegisterNetEvent("kGore:cleanupHeadless")
AddEventHandler("kGore:cleanupHeadless", function(networkIds)
    local cleanedCount = 0
    
    for _, networkId in ipairs(networkIds) do
        if NetworkDoesNetworkIdExist(networkId) then
            local pedEntity = NetworkGetEntityFromNetworkId(networkId)
            
            -- Skip if it's a player
            if IsPedAPlayer(pedEntity) then
                return
            end
            
            -- Reset entity state
            local entityState = Entity(pedEntity).state
            if entityState ~= nil then
                entityState:set("isHeadshot", false, true)
            end
            
            -- Clean up associated data
            local entityData = headlessEntities[pedEntity]
            if entityData and entityData.cap then
                if DoesEntityExist(entityData.cap) then
                    DeleteEntity(entityData.cap)
                    headlessEntities[pedEntity] = nil
                    cleanedCount = cleanedCount + 1
                end
            end
        end
    end
    
    -- Clean up any remaining entities
    for pedEntity, entityData in pairs(headlessEntities) do
        local entityState = Entity(pedEntity).state
        if entityState ~= nil then
            entityState:set("isHeadshot", false, true)
        end
        
        if entityData.cap and DoesEntityExist(entityData.cap) then
            DeleteEntity(entityData.cap)
            cleanedCount = cleanedCount + 1
        end
    end
    
    headlessEntities = {}
end)

-- Resource cleanup
AddEventHandler("onResourceStop", function(resourceName)
    if GetCurrentResourceName() == resourceName then
        CleanupAllHeadlessEntities()
    end
end)

-- Export functions
exports("removePlayerHead", function(pedEntity)
    if not pedEntity then
        pedEntity = PlayerPedId()
    end
    
    if DoesEntityExist(pedEntity) and IsEntityAPed(pedEntity) then
        SetHeadshotState(pedEntity, true)
        
        if not isMainLoopRunning then
            isMainLoopRunning = true
            StartLoop()
        end
        
        return true
    end
    
    return false
end)

exports("restorePlayerHead", function(pedEntity)
    if not pedEntity then
        pedEntity = PlayerPedId()
    end
    
    if DoesEntityExist(pedEntity) and IsEntityAPed(pedEntity) then
        SetHeadshotState(pedEntity, false)
        return true
    end
    
    return false
end)

-- UI Management
local isMenuVisible = false

RegisterCommand("goresettings", function(source, args)
    isMenuVisible = not isMenuVisible
    
    SendNUIMessage({
        type = "setVisible",
        data = {
            visible = isMenuVisible,
            config = {
                playerGore = Config.playerGore,
                npcGore = Config.npcGore,
                bloodSplatter = Config.bloodSplatter,
                shootDead = Config.shootDead,
                painSystem = Config.painSystem
            }
        }
    })
    
    SetNuiFocus(isMenuVisible, isMenuVisible)
end, false)

RegisterKeyMapping("goresettings", "Toggle Gore Settings Menu", "keyboard", Config.MenuKeybinding)

-- NUI Callbacks
RegisterNUICallback("getGoreSettings", function(data, callback)
    callback({
        playerGore = Config.playerGore,
        npcGore = Config.npcGore,
        bloodSplatter = Config.bloodSplatter,
        shootDead = Config.shootDead,
        painSystem = Config.painSystem
    })
end)

RegisterNUICallback("updateGoreSetting", function(data, callback)
    local settingName = data.setting
    local value = data.value
    
    if settingName and type(settingName) == "string" and Config[settingName] ~= nil then
        if type(value) == "boolean" then
            Config[settingName] = value
            SaveSetting(settingName, value)
            callback({success = true})
            return
        end
    end
    
    callback({success = false, error = "Invalid setting or value"})
end)

RegisterNUICallback("closeMenu", function(data, callback)
    isMenuVisible = false
    
    SendNUIMessage({
        type = "setVisible",
        data = {visible = false}
    })
    
    SetNuiFocus(false, false)
    callback({success = true})
end)
