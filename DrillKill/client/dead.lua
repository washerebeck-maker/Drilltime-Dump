-- Dead peds tracking and gore system
local deadPeds = {}
local lastPlayerPosition = vector3(0, 0, 0)
local currentPlayerPed = 0
local lastHeadshotCheckTime = 0

-- Cached native functions for performance
local PlayerPedId = PlayerPedId
local GetEntityCoords = GetEntityCoords
local IsEntityDead = IsEntityDead
local DoesEntityExist = DoesEntityExist
local GetGamePool = GetGamePool

-- Check if current weapon can cause gore effects
function IsGoreWeapon()
    local weaponHash = GetSelectedPedWeapon(currentPlayerPed)
    local isGoreWeapon = Config.goreWeapons[weaponHash]
    return isGoreWeapon or false
end

-- Clean up invalid dead peds from tracking
function CleanupInvalidDeadPeds()
    local invalidPeds = {}
    
    for pedEntity, pedData in pairs(deadPeds) do
        if not DoesEntityExist(pedEntity) then
            table.insert(invalidPeds, pedEntity)
        end
    end
    
    for i = 1, #invalidPeds do
        local pedToRemove = invalidPeds[i]
        deadPeds[pedToRemove] = nil
    end
end

-- Scan for dead peds in range and track them
function ScanForDeadPeds()
    local playerPed = PlayerPedId()
    currentPlayerPed = playerPed
    local playerCoords = GetEntityCoords(currentPlayerPed)
    
    -- Movement-based optimization: skip scan if player hasn't moved much
    local movementDistance = #(playerCoords - lastPlayerPosition)
    if movementDistance < Config.movementThreshold then
        local currentTime = GetGameTimer()
        if not lastScanTime then
            lastScanTime = 0
        end
        
        local timeSinceLastScan = currentTime - lastScanTime
        if timeSinceLastScan < 5000 then -- 5 second minimum between scans
            return
        end
        lastScanTime = currentTime
    end
    
    lastPlayerPosition = playerCoords
    local scanRange = Config.scanRange
    local allPeds = GetGamePool("CPed")
    
    -- Check each ped in the game pool
    for i = 1, #allPeds do
        local pedEntity = allPeds[i]
        
        if pedEntity ~= currentPlayerPed and not deadPeds[pedEntity] then
            if IsEntityDead(pedEntity) then
                local pedCoords = GetEntityCoords(pedEntity)
                local distanceToPlayer = #(playerCoords - pedCoords)
                
                if scanRange >= distanceToPlayer then
                    deadPeds[pedEntity] = {
                        coords = pedCoords,
                        headCoords = nil, -- Lazy-loaded when needed
                        timestamp = GetGameTimer(),
                        isPlayer = IsPedAPlayer(pedEntity)
                    }
                end
            end
        end
    end
    
    CleanupInvalidDeadPeds()
end

-- Main dead ped scanning thread
CreateThread(function()
    if Config.shootDead then
        while true do
            ScanForDeadPeds()
            Wait(Config.scanInterval)
        end
    end
end)

-- Export function to get tracked dead peds
function GetDeadPeds()
    return deadPeds
end

-- Get cached head coordinates for a ped (lazy-loaded)
function GetPedHeadCoords(pedEntity)
    local pedData = deadPeds[pedEntity]
    if not pedData then
        return nil
    end
    
    if not pedData.headCoords then
        pedData.headCoords = GetPedBoneCoords(pedEntity, 31086, 0.0, 0.0, 0.0) -- Head bone
    end
    
    return pedData.headCoords
end

-- Process headshot detection and effects
function ProcessHeadshotDetection()
    if not (IsPedShooting(currentPlayerPed) or IsPedRunningMeleeTask(currentPlayerPed)) then
        return
    end
    
    if not IsGoreWeapon() then
        return
    end
    
    local impactFound, impactCoords = GetPedLastWeaponImpactCoord(currentPlayerPed)
    if not impactFound then
        return
    end
    
    -- Check all tracked dead peds for headshot proximity
    for pedEntity, pedData in pairs(deadPeds) do
        if DoesEntityExist(pedEntity) then
            local headCoords = GetPedHeadCoords(pedEntity)
            if headCoords then
                local distanceToImpact = #(impactCoords - headCoords)
                
                if distanceToImpact <= 0.2 then -- Close enough to be considered a headshot
                    local pedModel = GetEntityModel(pedEntity)
                    
                    -- Skip ignored ped models
                    if not Config.PedModelsToIgnore[pedModel] then
                        local entityState = Entity(pedEntity).state
                        
                        -- Only process if not already marked as headshot
                        if not entityState.isHeadshot then
                            SetHeadshotState(pedEntity, true)
                            
                            -- Apply blood splatter effects if enabled
                            if Config.bloodSplatter then
                                ApplyBloodEffects(pedEntity)
                            end
                        end
                    end
                end
            end
        end
    end
end

-- Apply blood splatter particle effects
function ApplyBloodEffects(pedEntity)
    -- Primary blood impact effect
    SpawnNetworkedParticleOnPed(
        pedEntity,
        "scr_solomon3",
        "scr_trev4_747_blood_impact",
        vec3(-0.1, 0.02, 0.0),
        vec3(180.0, 0.0, 0.0),
        0.25
    )
    
    -- Secondary blood spray effect
    SpawnNetworkedParticleOnPed(
        pedEntity,
        "core",
        "ent_sht_blood",
        vec3(0.0, 0.02, 0.0),
        vec3(0.0, 0.0, 0.0),
        0.25
    )
end

-- Headshot detection thread with optimized timing
CreateThread(function()
    while true do
        if Config.shootDead then
            local currentTime = GetGameTimer()
            
            if currentTime - lastHeadshotCheckTime >= 16 then -- ~60 FPS check rate
                ProcessHeadshotDetection()
                lastHeadshotCheckTime = currentTime
            end
        else
            Wait(1000) -- Sleep when feature is disabled
        end
        
        Wait(0)
    end
end)

-- Performance monitoring function
function GetPerformanceStats()
    local deadPedCount = 0
    for _ in pairs(deadPeds) do
        deadPedCount = deadPedCount + 1
    end
    
    return {
        deadPedCount = deadPedCount,
        memoryUsage = collectgarbage("count"),
        scanRange = Config.scanRange
    }
end

-- Export functions for external access
exports("getPerformanceStats", GetPerformanceStats)
exports("getDeadPeds", GetDeadPeds)
