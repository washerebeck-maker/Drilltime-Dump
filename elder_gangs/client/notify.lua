function hoods_notify(data)
    if not data then return end
    SendNUIMessage({
        action = 'notify',
        data = {
            id          = data.id,
            gang        = data.gang,
            title       = data.title,
            description = data.description,
            duration    = data.duration,
            type        = data.type,
        },
    })
end
