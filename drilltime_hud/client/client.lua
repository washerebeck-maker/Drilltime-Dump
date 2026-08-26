local Hud = lib.class('Hud')

local SETTINGS <const> = {
    ejectVelocity = (60 / 2.236936),
    unknownEjectVelocity = (70 / 2.236936),
    unknownModifier = 17.0,
    minDamage = 20
}

function Hud:constructor()
    self.currentWeapon = nil
    self.hunderSound = false
    self.hungerSoundValue = 15
    self.hunger = 100
    self.thirst = 100

    RegisterCommand('hud', function()
        self:openSettings()
    end, false)

    -- Seatbelt command handler (works with keybind)
    RegisterCommand('seatbelt', function()
        if cache.vehicle then
            self.seatBelt = not self.seatBelt
            self:EnableSeatbelt(self.seatBelt)
            print(string.format("^2[Seatbelt] Command toggled: %s^0", self.seatBelt and "ON" or "OFF"))
        end
    end, false)

    TriggerEvent('chat:addSuggestion', '/seatbelt', 'Toggle seatbelt')

    RegisterNUICallback('hud:closeUI', function(_, cb)
        self:closeSettings()
        cb(1)
    end)

    RegisterNUICallback('hud:variantChanged', function(data, cb)
        SetResourceKvp('hud_variant', data.variant)
        lib.notify({ type = 'success', title = 'Variant Changed', description = 'Your HUD variant has been changed!' })
        cb(1)
    end)

    RegisterNUICallback('hud:carVariantChanged', function(data, cb)
        SetResourceKvp('hud_car_variant', data.variant)
        lib.notify({ type = 'success', title = 'Car Variant Changed', description = 'Your car HUD variant has been changed!' })
        cb(1)
    end)

    RegisterNUICallback('hud:fetchVariant', function(_, cb)
        cb(GetResourceKvpString('hud_variant') or false)
    end)

    RegisterNUICallback('hud:fetchCarVariant', function(_, cb)
        cb(GetResourceKvpString('hud_car_variant') or false)
    end)

    -- Edit Layout mode (drag-and-drop HUD positioning)
    RegisterNUICallback('hud:startEditMode', function(_, cb)
        -- NUI focus already active from settings panel, just redirect to edit mode
        SetNuiFocus(true, true)
        self:send('hud:enterEditMode')
        cb(1)
    end)

    RegisterNUICallback('hud:exitEditMode', function(_, cb)
        SetNuiFocus(false, false)
        cb(1)
    end)

    RegisterNUICallback('hud:savePositions', function(data, cb)
        if next(data) == nil then
            DeleteResourceKvp('hud_positions')
        else
            SetResourceKvp('hud_positions', json.encode(data))
        end
        lib.notify({ type = 'success', title = 'Layout Saved', description = 'Your HUD layout has been saved!' })
        cb(1)
    end)

    RegisterCommand('hudmove', function()
        SetNuiFocus(true, true)
        self:send('hud:enterEditMode')
    end, false)

    TriggerEvent('chat:addSuggestion', '/hudmove', 'Edit HUD layout positions')

    AddEventHandler('ox_inventory:currentWeapon', function(wep)
        self:onWeaponChanged(wep)
    end)

    lib.onCache('vehicle', function(veh)
        self:send('hud:setInCar', veh and true or false)
    end)

    -- ESX Status event handlers for real-time updates
    AddEventHandler('esx_status:onTick', function(data)
        -- Cache hunger/thirst from tick data to avoid per-loop TriggerEvent calls
        if type(data) == 'table' then
            for _, status in ipairs(data) do
                if status.name == 'hunger' then
                    self.hunger = status.val / 10000
                elseif status.name == 'thirst' then
                    self.thirst = status.val / 10000
                end
            end
        end
        local ped = cache.ped
        local currentHealth = GetEntityHealth(ped) - 100
        local currentArmor = GetPedArmour(ped)
        self:send('hud:updateStatus', {
            health = math.max(0, currentHealth),
            armor  = currentArmor,
            hunger = self.hunger,
            thirst = self.thirst
        })
    end)

    -- ESX BasicNeeds event handlers (alternative)
    AddEventHandler('esx_basicneeds:onUpdateStatus', function()
        local ped = cache.ped
        local currentHealth = GetEntityHealth(ped) - 100
        local currentArmor = GetPedArmour(ped)
        self:send('hud:updateStatus', {
            health = math.max(0, currentHealth),
            armor  = currentArmor,
            hunger = self.hunger,
            thirst = self.thirst
        })
    end)

    -- self:setMinimap()
    self:loopPlayer()
    self:loopVehicle()
    
    -- Initialize seatbelt state
    self.seatBelt = false
    
    -- Register keybind for seatbelt (alternative method)
    RegisterKeyMapping('seatbelt', 'Toggle Seatbelt', 'keyboard', 'B')
    
    -- Keep radar visible
    CreateThread(function()
        while true do
            DisplayRadar(true)
            Wait(5000)
        end
    end)

    -- Load saved HUD positions from KVP and send to NUI
    CreateThread(function()
        Wait(2000)
        local savedPositions = GetResourceKvpString('hud_positions')
        if savedPositions then
            self:send('hud:loadPositions', savedPositions)
        end
    end)
end

function Hud:send(action, data)
    SendNUIMessage({ action = action, data = data })
end

function Hud:openSettings()
    self:send('hud:openSettings')
    SetNuiFocus(true, true)
end

function Hud:closeSettings()
    SetNuiFocus(false, false)
end

function Hud:getAccount(name)
    local accounts = ESX.PlayerData and ESX.PlayerData.accounts or {}
    for i = 1, #accounts do
        local a = accounts[i]
        if a and a.name == name then return a.money or 0 end
    end
    return 0
end

function Hud:getHunger()
    return self.hunger
end

function Hud:getThirst()
    return self.thirst
end

-- Redo this to make it return the correct drug level based on your framework's implementation
function Hud:getDrugLevel()
    return exports.elder_drugs.getDrugLevel()
end

function Hud:onWeaponChanged(currentWeapon)
    if not currentWeapon or not currentWeapon.hash or currentWeapon.melee then
        self.currentWeapon = nil
        self:send('hud:setWeapon', false)
        return
    end
    self.currentWeapon = currentWeapon
end

function Hud:updateWeapon()
    if not self.currentWeapon or self.currentWeapon.melee then return end
    local ped = cache.ped
    local w = table.clone(self.currentWeapon)
    w.ammo = GetAmmoInPedWeapon(ped, w.hash)
    self:send('hud:setWeapon', w)
end

function Hud:setMinimap()
    CreateThread(function()
        -- Wait for proper game state
        while not NetworkIsSessionStarted() do
            Wait(100)
        end
        
        -- Additional wait for resources
        Wait(2000)
        
        local defaultAspect = 1920 / 1080
        local sx, sy = GetActiveScreenResolution()
        local aspect = sx / sy
        local offset = 0.0
        if aspect > defaultAspect then
            offset = ((defaultAspect - aspect) / 3.6) - 0.007
        end

        -- Request resources
        RequestStreamedTextureDict('squaremap', true)
        while not HasStreamedTextureDictLoaded('squaremap') do
            Wait(10)
        end
        
        -- Apply texture replacements
        AddReplaceTexture('platform:/textures/graphics', 'radarmasksm', 'squaremap', 'radarmasksm')
        AddReplaceTexture('platform:/textures/graphics', 'radarmask1g', 'squaremap', 'radarmasksm')

        local yOffset = -0.02

        -- Set minimap type and positions
        SetMinimapClipType(0)
        
        -- Force radar on
        SetRadarBigmapEnabled(true, true)
        DisplayRadar(true)
        
        Wait(100)
        
        SetMinimapComponentPosition('minimap',      'L','B', 0.0 + offset,  -0.047 + yOffset, 0.1638, 0.183)
        SetMinimapComponentPosition('minimap_mask', 'L','B', 0.0 + offset,   0.000 + yOffset, 0.128,  0.200)
        SetMinimapComponentPosition('minimap_blur', 'L','B', -0.01 + offset, 0.025 + yOffset, 0.262,  0.300)

        -- Hide north blip
        SetBlipAlpha(GetNorthRadarBlip(), 0)
        
        -- Final ensure radar is displayed
        DisplayRadar(true)
        SetRadarBigmapEnabled(false, false)
        
        print("^2[HUD] Minimap initialized successfully^0")

        Wait(5000)
        SetRadarBigmapEnabled(false, false)
    end)
end

function Hud:getDirectionAbbrev(heading)
    local dirs = { 'N','NE','E','SE','S','SW','W','NW','N' }
    local idx = math.floor((heading % 360) / 45 + 1.5)
    return dirs[idx]
end

function Hud:getStreetName(ped)
    local c = GetEntityCoords(ped)
    local hash = GetStreetNameAtCoord(c.x, c.y, c.z)
    return GetStreetNameFromHashKey(hash)
end

function Hud:getVoiceMode()
    local m = LocalPlayer.state.proximity or 2
    if m == 1 then return 'whisper' end
    if m == 2 then return 'normal' end
    return 'shout'
end

function Hud:isTalking()
    return NetworkIsPlayerTalking(cache.playerId) or false
end

function Hud:loopPlayer()
    CreateThread(function()
        while true do
            local pd = ESX.GetPlayerData()

            -- Single-pass account lookup instead of 3 separate array iterations
            local money, blackMoney, bank = 0, 0, 0
            local accounts = pd and pd.accounts or {}
            for i = 1, #accounts do
                local a = accounts[i]
                if a then
                    if     a.name == 'money'       then money      = a.money or 0
                    elseif a.name == 'black_money'  then blackMoney = a.money or 0
                    elseif a.name == 'bank'         then bank       = a.money or 0
                    end
                end
            end

            self:send('hud:update', {
                job        = pd.job and pd.job.label or 'Unemployed',
                rank       = pd.job and pd.job.grade_label or '',
                money      = money,
                blackMoney = blackMoney,
                bank       = bank,
                drugLevel  = self:getDrugLevel(),
                serverId   = cache.serverId
            })

            local ped     = cache.ped
            local street  = self:getStreetName(ped)
            local dir     = self:getDirectionAbbrev(GetEntityHeading(ped))
            local voice   = self:getVoiceMode()
            local talking = self:isTalking()

            local currentHealth = GetEntityHealth(ped) - 100
            local currentArmor  = GetPedArmour(ped)
            -- Cache hunger/thirst locally — single read per loop, reused in both sends
            local hunger = self:getHunger()
            local thirst = self:getThirst()

            self:send('hud:setPlayer', {
                health    = math.max(0, currentHealth),
                armor     = currentArmor,
                hunger    = hunger,
                thirst    = thirst,
                streetName = street,
                direction = dir,
                voice     = voice,
                talking   = talking
            })

            self:loopHungerSound(hunger)

            self:send('hud:updateStatus', {
                health = math.max(0, currentHealth),
                armor  = currentArmor,
                hunger = hunger,
                thirst = thirst
            })

            if self.currentWeapon then
                self:updateWeapon()
            end

            Wait(100)
        end
    end)
end

function Hud:EnableSeatbelt(bool)
    lib.notify({
        type = bool and 'success' or 'error',
        title = 'Seatbelt',
        description = bool and 'Seatbelt fastened' or 'Seatbelt unfastened'
    })

    if bool then
        -- Prevent flying through windscreen when seatbelt is ON
        SetPedConfigFlag(cache.ped, 32, true) -- Disable ragdoll on vehicle impact
        SetFlyThroughWindscreenParams(10000.0, 10000.0, 17.0, 2000.0)
    else
        -- Allow normal physics when seatbelt is OFF
        SetPedConfigFlag(cache.ped, 32, false) -- Enable ragdoll on vehicle impact
        SetFlyThroughWindscreenParams(SETTINGS.ejectVelocity, SETTINGS.unknownEjectVelocity, SETTINGS.unknownModifier, SETTINGS.minDamage)
    end
end

function Hud:loopVehicle()
    -- Set default physics (seatbelt off by default)
    SetFlyThroughWindscreenParams(SETTINGS.ejectVelocity, SETTINGS.unknownEjectVelocity, SETTINGS.unknownModifier, SETTINGS.minDamage)

    CreateThread(function()
        local wasInVehicle = false
        
        while true do
            local veh = cache.vehicle
            local ped = cache.ped
            
            if veh then
                -- Player just entered vehicle
                if not wasInVehicle then
                    wasInVehicle = true
                    self.seatBelt = false -- Always start with seatbelt OFF
                    self:EnableSeatbelt(false)
                    print("^3[Seatbelt] Entered vehicle - Seatbelt OFF^0")
                end
                
                local speed = GetEntitySpeed(veh) * 2.236936 -- Convert to MPH
                local rpm   = GetVehicleCurrentRpm(veh) or 0.0
                local fuel  = GetVehicleFuelLevel(veh) or 0.0
                local maxFuel = GetVehicleHandlingFloat(veh, 'CHandlingData', 'fPetrolTankVolume') or 65.0
                local fuelPercent = (fuel / maxFuel)
                
                -- Get engine health (0-1000, where 1000 is perfect)
                local engineHealth = GetVehicleEngineHealth(veh)
                local engineWarn = engineHealth < 400.0 -- Yellow warning when engine health is low
                
                -- Get current gear
                local gear = GetVehicleCurrentGear(veh)

                -- Send data to NUI
                self:send('hud:setCarData', {
                    speed       = math.floor(speed),
                    rpmPercent  = rpm,
                    fuelPercent = math.max(0, math.min(1, fuelPercent)),
                    engineWarn  = engineWarn,
                    seatbeltOn  = self.seatBelt,
                    gear        = gear,
                    maxSpeed    = 220
                })

                -- Seatbelt toggle is handled by the RegisterCommand above

                -- Prevent exiting vehicle if seatbelt is ON
                if self.seatBelt then
                    DisableControlAction(0, 75, true) -- F key (exit vehicle)
                end
                
                -- Keep physics updated every frame when seatbelt is on
                if self.seatBelt then
                    --SetPedConfigFlag(ped, 32, true)
                end

                Wait(500)
            else
                -- Player exited vehicle
                if wasInVehicle then
                    wasInVehicle = false
                    if self.seatBelt then
                        self.seatBelt = false
                        self:EnableSeatbelt(false)
                        print("^3[Seatbelt] Exited vehicle - Seatbelt reset^0")
                    end
                end
                
                Wait(500)
            end
        end
    end)
end

function Hud:ShowUI(bool)
    self:send('hud:show', bool)
end

function Hud:loopHungerSound(hunger)
    if hunger > self.hungerSoundValue and self.HungerSound then
        self.HungerSound = false
        return
    end
    if hunger < self.hungerSoundValue and not self.HungerSound then
        self.HungerSound = true
        CreateThread(function()
            while self.HungerSound do
                TriggerEvent('InteractSound_CL:PlayOnOne', 'hungry', 1.0)
                Wait(7000)
            end
        end)
    end
end

exports('ShowUI', function(bool, keepRadar)
    Hud:ShowUI(bool)
    if not keepRadar then
        DisplayRadar(bool)
    end
end)

Hud:new()