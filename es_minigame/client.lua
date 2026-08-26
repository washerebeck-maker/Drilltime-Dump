local MinigameActive = false
local MinigameFinished = false
local SuccessTrigger = nil
local FailTrigger = nil
local Success = false


function StartMinigame(data, cb)
    if MinigameActive then return end

    if data ~= nil then
        local rows = 7

        if data.rows then rows = data.rows end

        SetNuiFocus(true, true)
        SendNUIMessage({action = 'start', fails = data.maxFails, squares = data.maxSquares, rows = rows})
        MinigameActive = true
        MinigameFinished = false

        while MinigameActive do
            Citizen.Wait(500)
        end

        if cb then
            cb(Success)
        end

        return Success
    end
end

exports('StartMinigame', StartMinigame)

RegisterNUICallback('success', function(data, cb)
    print('done')
    SetNuiFocus(false, false)
    Success = true
    MinigameFinished = false
    MinigameActive = false
    cb('ok')
end)

RegisterNUICallback('fail', function(data, cb)
    print('done')
    SetNuiFocus(false, false)
    MinigameActive = false
    Success = false
    cb('ok')
end)