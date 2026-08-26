local nextFire = 0
local POLL_MS = 500
local CLIENT_COOLDOWN_MS = 60000

CreateThread(function()
    while true do
        Wait(POLL_MS)
        if next(HoodsCurrentZones) and IsPedShooting(PlayerPedId()) and GetGameTimer() >= nextFire then
            nextFire = GetGameTimer() + CLIENT_COOLDOWN_MS
            for gangId in pairs(HoodsCurrentZones) do
                local gang = client.datastore.gangs.get(gangId)
                if gang and gang.alert_system == true then
                    TriggerServerEvent('elder_gangs:server:alert_shooting', gangId)
                end
            end
        end
    end
end)

RegisterNetEvent('elder_gangs:client:shooting_alert', function(targetGangLabel, shooterLabel)
    hoods_notify({
        gang        = targetGangLabel or 'YOUR HOOD',
        title       = 'Motherfuckers shooting at your block',
        description = (shooterLabel or 'Civilian') .. ' is shooting at your block — go handle that shit.',
        duration    = 10000,
        type        = 'error',
    })
end)
