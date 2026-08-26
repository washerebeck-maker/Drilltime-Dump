local panelOpen = false

local function pushSettings()
    local saved = GetResourceKvpString('crosshair_settings')
    if saved then
        SendNUIMessage({ action = 'loadSettings', data = saved })
    end
end

RegisterCommand('crosshair', function()
    panelOpen = not panelOpen
    if panelOpen then
        SetNuiFocus(true, true)
        SendNUIMessage({ action = 'toggle' })
    else
        SetNuiFocus(false, false)
        SendNUIMessage({ action = 'toggle' })
    end
end, false)

TriggerEvent('chat:addSuggestion', '/crosshair', 'Open crosshair settings')

RegisterNUICallback('closeUI', function(_, cb)
    panelOpen = false
    SetNuiFocus(false, false)
    cb(1)
end)

RegisterNUICallback('saveSettings', function(data, cb)
    if data and data.settings then
        SetResourceKvp('crosshair_settings', data.settings)
    end
    cb(1)
end)

CreateThread(function()
    Wait(300)
    pushSettings()
end)
