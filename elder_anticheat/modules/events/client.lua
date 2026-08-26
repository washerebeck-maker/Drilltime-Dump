RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    TriggerServerEvent('elder_anticheat:server:job_check', job)
end)

RegisterNetEvent('esx:noclip')
AddEventHandler('esx:noclip', function(job)
    TriggerServerEvent('elder_anticheat:server:noclip_check')
end)