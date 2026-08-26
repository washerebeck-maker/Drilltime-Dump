RegisterNetEvent('elder_gangs:client:cops_in_hood_alert', function(gangLabel)
    hoods_notify({
        gang        = gangLabel or 'YOUR HOOD',
        title       = 'The pigs at your block',
        description = 'Be sure to be on 10 cause they out to get yall.',
        duration    = 10000,
        type        = 'cops',
    })
end)
