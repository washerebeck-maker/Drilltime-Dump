local BACKUP_REQUEST_COOLDOWN_MS = 60000
local lastBackupRequestMs = -BACKUP_REQUEST_COOLDOWN_MS

local function GetWeaponLabel(weaponName)
    if not weaponName or weaponName == 'unknown' then return 'unknown' end
    local ok, item = pcall(function()
        return exports.ox_inventory:Items(weaponName)
    end)
    if ok and item and item.label then return item.label end
    return weaponName
end

local function isWeaponWhitelisted(weaponHash)
    if not weaponHash or weaponHash == 0 then return true end
    if weaponHash == `WEAPON_UNARMED` then return true end
    local wl = Config.Shooting and Config.Shooting.WhitelistWeapons
    if type(wl) ~= 'table' then return false end
    return wl[weaponHash] == true
end

local function isShooterJobIgnored()
    local list = Config.Shooting and Config.Shooting.IgnoreJobs
    if type(list) ~= 'table' or next(list) == nil then return false end
    if not playerJob then return false end
    return lib.table.contains(list, playerJob)
end

local function isWeaponSilenced(ped)
    local ok, silenced = pcall(IsPedCurrentWeaponSilenced, ped)
    return ok and silenced
end

local function isPoliceMember()
    return playerJob == 'police'
end

local function sendBackupRequestAlert()
    if not isPoliceMember() then
        return
    end

    local now = GetGameTimer()
    if (now - lastBackupRequestMs) < BACKUP_REQUEST_COOLDOWN_MS then
        return
    end

    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local coordsTable = { x = coords.x, y = coords.y, z = coords.z }

    local image = getScreenshot()
    SendDispatchAlertClient({
        title = 'Emergency Assistance',
        codePrimary = '10',
        codeSecondary = '33',
        message = 'Backup requested by a police officer.',
        coords = coordsTable,
        sound = 'dispatch',
        jobs = { 'police' },
        flash = true,
        image = image
    })

    lastBackupRequestMs = now
end

RegisterCommand('elder_dispatch_backup_request', function()
    sendBackupRequestAlert()
end, false)

RegisterKeyMapping('elder_dispatch_backup_request', 'Dispatch - backup request (police)', 'keyboard', 'O')

if Config.Shooting and Config.Shooting.Enable then
    CreateThread(function()
        local wasShooting = false

        while true do
            local waitMs = 500
            local ped = PlayerPedId()
            local hasWeapon, weaponHash = GetCurrentPedWeapon(ped, true)
            if hasWeapon and weaponHash and weaponHash ~= 0 and weaponHash ~= `WEAPON_UNARMED` then
                waitMs = 5
            end

            local loudShot = IsPedShooting(ped) and not isWeaponSilenced(ped)

            if not loudShot then
                wasShooting = false
            elseif not wasShooting then
                wasShooting = true
                _, weaponHash = GetCurrentPedWeapon(ped, true)
                if GlobalState.elder_dispatch_shooting_ready ~= false and not isWeaponWhitelisted(weaponHash) and not isShooterJobIgnored() then
                    local coords = GetEntityCoords(ped)
                    local weaponName = 'unknown'
                    local okCw, cw = pcall(function()
                        return exports.ox_inventory:getCurrentWeapon()
                    end)
                    if okCw and cw and cw.name then weaponName = cw.name end
                    local weaponLabel = GetWeaponLabel(weaponName)
                    local message = (
                        'Gunshots have been reported at this location. Weapon involved: %s.'
                    ):format(weaponLabel)

                    local coordsTable = { x = coords.x, y = coords.y, z = coords.z }
                    local image = getScreenshot()
                    TriggerServerEvent('elder_dispatch:server:shootingAlert', {
                        title = Config.Shooting.Title,
                        codePrimary = Config.Shooting.codePrimary,
                        codeSecondary = Config.Shooting.codeSecondary,
                        street = streetFromCoords(coordsTable),
                        message = message,
                        coords = coordsTable,
                        sound = Config.Shooting.sound,
                        jobs = Config.Shooting.AlertJobs,
                        image = image,
                        flash = true,
                    })
                end
            end

            Wait(waitMs)
        end
    end)
end
