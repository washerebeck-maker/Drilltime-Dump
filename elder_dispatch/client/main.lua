local ESX = exports['es_extended']:getSharedObject()
playerJob = nil

local alerts = {}
local currentIndex = 1
local panelOpen = false
local interactMode = false

CreateThread(function()
    while ESX == nil do
        Wait(500)
    end
    while ESX.GetPlayerData().job == nil do
        Wait(10)
    end
    playerJob = ESX.GetPlayerData().job.name
end)

local function hasJob(jobs)
    return lib.table.contains(jobs, playerJob)
end

local function canOpenDispatch()
    if not playerJob then
        return false
    end
    local list = Config.DispatchAllowedJobs
    if type(list) ~= 'table' or next(list) == nil then
        return true
    end
    return lib.table.contains(list, playerJob)
end

local function maxDispatchDisplayCap()
    local cap = Config.MaxDispatchAlerts
    if type(cap) ~= 'number' or cap < 1 then
        cap = 5
    end
    return math.floor(cap)
end

function streetFromCoords(coords)
    if not coords then return '—' end
    local x = coords.x or coords[1]
    local y = coords.y or coords[2]
    local z = coords.z or coords[3] or 0.0
    if not x or not y then return '—' end
    local s1, s2 = GetStreetNameAtCoord(x + 0.0, y + 0.0, z + 0.0)
    local a = GetStreetNameFromHashKey(s1)
    local b = GetStreetNameFromHashKey(s2)
    if b and b ~= '' and b ~= a then
        return ('%s / %s'):format(a, b)
    end
    return (a and a ~= '') and a or '—'
end

function SendDispatchAlertClient(data)
    if type(data) ~= 'table' then return end
    local jobs = data.jobs
    if type(jobs) ~= 'table' or next(jobs) == nil then
        return
    end
    TriggerServerEvent('elder_dispatch:server:dispatchAlert', {
        title = data.title,
        codePrimary = data.codePrimary,
        codeSecondary = data.codeSecondary,
        street = streetFromCoords(data.coords),
        message = data.message,
        coords = data.coords,
        sound = data.sound,
        jobs = jobs,
        image = data.image,
        flash = data.flash == true,
    })
end

local function sendNui(action, data)
    SendNUIMessage({
        action = action,
        data = data or {},
    })
end

local function pushDispatchAlertsToNui()
    sendNui('setDispatchAlerts', {
        alerts = alerts,
        index = currentIndex,
        maxDisplay = maxDispatchDisplayCap(),
    })
end

local function playAlertSound(sound)
    if not sound then
        return
    end
    if not (panelOpen and canOpenDispatch()) then
        return
    end
    TriggerEvent('InteractSound_CL:PlayOnOne', sound, 1.0)
end

local function applyNuiFocus()
    if interactMode and panelOpen and canOpenDispatch() then
        SetNuiFocus(true, true)
    else
        SetNuiFocus(false, false)
    end
end

local function refreshNuiVisibility()
    local show = canOpenDispatch() and panelOpen
    sendNui('setVisible', { visible = show })
    sendNui('setInteractMode', { active = interactMode })
    applyNuiFocus()
end

local function closePanelState()
    panelOpen = false
    interactMode = false
    SetNuiFocus(false, false)
end

RegisterNetEvent('esx:playerLoaded', function(player)
    playerJob = player.job.name
    if not canOpenDispatch() then
        closePanelState()
        refreshNuiVisibility()
        pushDispatchAlertsToNui()
    end
end)

RegisterNetEvent('esx:setJob', function(job)
    playerJob = job.name
    if not canOpenDispatch() then
        closePanelState()
        refreshNuiVisibility()
        pushDispatchAlertsToNui()
    end
end)

local function mergeAlertIntoLocalAlerts(alert)
    local focus = type(alert.sound) == 'string' and alert.sound == 'dispatch'
    local replaced = false
    for j = 1, #alerts do
        if alerts[j].id == alert.id then
            alerts[j] = alert
            replaced = true
            if focus then
                currentIndex = j
            end
            break
        end
    end
    if not replaced then
        alerts[#alerts + 1] = alert
        if focus then
            currentIndex = #alerts
        end
    end
end

local function onBroadcastAlert(alert)
    if type(alert) ~= 'table' then return end
    if type(alert.jobs) ~= 'table' or next(alert.jobs) == nil or not hasJob(alert.jobs) then
        return
    end

    mergeAlertIntoLocalAlerts(alert)

    if #alerts == 0 then
        closePanelState()
    end

    if currentIndex > #alerts then
        currentIndex = math.max(1, #alerts)
    end
    if currentIndex < 1 then
        currentIndex = 1
    end

    playAlertSound(alert.sound)

    sendNui('dispatchAddAlert', {
        alert = alert,
        index = currentIndex,
        maxDisplay = maxDispatchDisplayCap(),
    })
    refreshNuiVisibility()
end

RegisterNetEvent('elder_dispatch:client:BroadcastAlert', onBroadcastAlert)

AddEventHandler('onClientResourceStart', function(res)
    if res ~= GetCurrentResourceName() then return end
    closePanelState()
end)

CreateThread(function()
    while true do
        Wait(750)
        if #alerts > 0 and panelOpen then
            local ped = PlayerPedId()
            local pcoords = GetEntityCoords(ped)
            local idx = math.min(math.max(currentIndex, 1), #alerts)
            local a = alerts[idx]
            if a and a.coords then
                local c = a.coords
                local dist = #(pcoords - vector3(c.x, c.y, c.z))
                sendNui('setDistance', { distanceM = math.floor(dist + 0.5) })
            end
        end
    end
end)

local function currentAlert()
    if #alerts == 0 then return nil end
    return alerts[math.min(math.max(currentIndex, 1), #alerts)]
end

local function navPrev()
    if not canOpenDispatch() or #alerts == 0 then return end
    currentIndex = currentIndex - 1
    if currentIndex < 1 then currentIndex = #alerts end
    pushDispatchAlertsToNui()
end

local function navNext()
    if not canOpenDispatch() or #alerts == 0 then return end
    currentIndex = currentIndex + 1
    if currentIndex > #alerts then currentIndex = 1 end
    pushDispatchAlertsToNui()
end

local function respondCurrent()
    if not canOpenDispatch() or #alerts == 0 then return end
    local a = currentAlert()
    if not a or not a.id then return end
    local c = a.coords
    if c then
        local x = tonumber(c.x) or 0.0
        local y = tonumber(c.y) or 0.0
        SetNewWaypoint(x + 0.0, y + 0.0)
    end
end

RegisterNUICallback('dispatchRespond', function(body, cb)
    respondCurrent()
    cb({ ok = true })
end)

RegisterNUICallback('dispatchNav', function(body, cb)
    if body and body.dir == 'prev' then navPrev() end
    if body and body.dir == 'next' then navNext() end
    cb({ ok = true })
end)

CreateThread(function()
    while true do
        if canOpenDispatch() and panelOpen and not interactMode and #alerts > 0 then
            Wait(0)
            if IsControlJustPressed(0, 189) or IsControlJustPressed(0, 174) then
                navPrev()
            elseif IsControlJustPressed(0, 190) or IsControlJustPressed(0, 175) then
                navNext()
            elseif IsControlJustPressed(0, 172)
                or IsControlJustPressed(0, 27)
                or IsDisabledControlJustPressed(0, 172) then
                respondCurrent()
            elseif IsControlJustPressed(0, 173) or IsControlJustPressed(0, 187) then
                sendNui('toggleImagePreview', {})
            end
        else
            Wait(200)
        end
    end
end)

RegisterNUICallback('dispatchUiReady', function(_, cb)
    cb({ ok = true })
end)

RegisterNUICallback('dispatchInteractDone', function(_, cb)
    if interactMode then
        interactMode = false
        applyNuiFocus()
        sendNui('setInteractMode', { active = false })
    end
    cb({ ok = true })
end)

local function toggleDispatchPanel()
    if not canOpenDispatch() then return end
    panelOpen = not panelOpen
    if not panelOpen then
        interactMode = false
        SetNuiFocus(false, false)
    else
        pushDispatchAlertsToNui()
    end
    refreshNuiVisibility()
end

local function toggleDispatchInteract()
    if not canOpenDispatch() or not panelOpen then return end
    interactMode = not interactMode
    applyNuiFocus()
    sendNui('setInteractMode', { active = interactMode })
end

RegisterCommand('elder_dispatch_toggle_panel', toggleDispatchPanel, false)
RegisterKeyMapping('elder_dispatch_toggle_panel', 'Dispatch - show / hide', 'keyboard', 'U')

RegisterCommand('elder_dispatch_toggle_mouse', toggleDispatchInteract, false)
RegisterKeyMapping('elder_dispatch_toggle_mouse', 'Dispatch - mouse and move', 'keyboard', 'Y')

RegisterCommand('elder_dispatch_waypoint', function()
    if interactMode then return end
    if not canOpenDispatch() or not panelOpen or #alerts == 0 then return end
    respondCurrent()
end, false)
RegisterKeyMapping('elder_dispatch_waypoint', 'Dispatch - waypoint (arrow up)', 'keyboard', 'UP')

exports('SendDispatchAlertClient', SendDispatchAlertClient)
