ESX = exports['es_extended']:getSharedObject()

local kos_manager = false
local kos_in_progress = false
local can_request = false
local ui_open = false

local accepted = false
local joined_team = nil
local team_points = {}
local prompt_team = nil

local blue_team = {}
local red_team = {}

local in_round = false
local round_frozen = false

local TEAM_RGB = {
    red = { 255, 45, 45 },
    blue = { 46, 125, 255 }
}

local EXIT_RGB = { 176, 38, 255 }
local EXIT_LIFETIME = 60000
local exit_gates = {}
local exit_gate_seq = 0
local exit_prompt_shown = false

local function is_kos_manager()
    return lib.callback.await('elder_kos:server:is_kos_manager', false)
end

local function notify(title, message, duration)
    SendNUIMessage({
        action = 'notify',
        data = {
            title = title,
            description = message,
            duration = duration or 5000
        }
    })
end


local function hide_prompt()
    if not prompt_team then return end
    prompt_team = nil
    SendNUIMessage({ action = 'setPrompt', data = { open = false } })
end

local function show_prompt(team)
    if prompt_team == team then return end
    prompt_team = team
    SendNUIMessage({
        action = 'setPrompt',
        data = { open = true, title = 'JOIN ' .. string.upper(team) .. ' TEAM', color = team }
    })
end

local function create_team_point(team, coords)
    if team_points[team] then return end
    local rgb = TEAM_RGB[team] or TEAM_RGB.red
    local point = lib.points.new({ coords = coords, distance = 30.0 })
    point.team = team

    function point:nearby()
        DrawMarker(
            1,
            self.coords.x, self.coords.y, self.coords.z,
            0.0, 0.0, 0.0,
            0.0, 0.0, 0.0,
            1.5, 1.5, 1.0,
            rgb[1], rgb[2], rgb[3], 255,
            false, false, 2, false
        )

        if not accepted or joined_team then
            if prompt_team == self.team then hide_prompt() end
            return
        end

        if self.currentDistance < 1.5 then
            show_prompt(self.team)
            if IsControlJustReleased(0, 38) then
                hide_prompt()
                TriggerServerEvent('elder_kos:server:join_team', self.team)
            end
        elseif prompt_team == self.team then
            hide_prompt()
        end
    end

    function point:onExit()
        if prompt_team == self.team then hide_prompt() end
    end

    team_points[team] = point
end

local function remove_team_points()
    for k, p in pairs(team_points) do
        p:remove()
        team_points[k] = nil
    end
    hide_prompt()
end

local HEAD_BONE = 0x796e

local function draw_team_overhead(team, rgb, origin)
    if not (team.players and next(team.players)) then return false end
    for _, p in pairs(team.players) do
        local id = GetPlayerFromServerId(p.id)
        if id ~= -1 and NetworkIsPlayerActive(id) then
            local player_ped = GetPlayerPed(id)
            local player_coords = GetEntityCoords(player_ped)
            if #(origin - player_coords) <= 150.0 then
                local bone = GetPedBoneCoords(player_ped, HEAD_BONE)
                DrawMarker(3, bone.x, bone.y, bone.z + 0.4, 0.0, 0.0, 10.0, 0.0, 0.0, 0.0, 0.25, 0.25, 0.25, rgb[1], rgb[2], rgb[3], 255, false, true, 2, false)
            end
        end
    end
    return true
end

local function start_kos_management()
    CreateThread(function()
        while next(red_team) or next(blue_team) do
            local origin = GetEntityCoords(cache.ped)
            local active = false
            if draw_team_overhead(red_team, TEAM_RGB.red, origin) then active = true end
            if draw_team_overhead(blue_team, TEAM_RGB.blue, origin) then active = true end
            Wait(active and 0 or 1000)
        end
    end)
end

local function open_ui()
    if not kos_manager then return end

    local status = lib.callback.await('elder_kos:server:get_status', false)
    SendNUIMessage({ action = 'setState', data = status })

    if status.teams then
        red_team = status.teams.red or {}
        blue_team = status.teams.blue or {}
        if status.teams.red and status.teams.red.coords then
            create_team_point('red', status.teams.red.coords)
        end
        if status.teams.blue and status.teams.blue.coords then
            create_team_point('blue', status.teams.blue.coords)
        end
    end

    ui_open = true
    SetNuiFocus(true, true)
    SendNUIMessage({ action = 'setVisible', data = true })
end


local function rot_to_direction(rot)
    local z = math.rad(rot.z)
    local x = math.rad(rot.x)
    local num = math.abs(math.cos(x))
    return vector3(-math.sin(z) * num, math.cos(z) * num, math.sin(x))
end

local function ground_raycast(ped)
    local cam = GetGameplayCamCoord()
    local dest = cam + rot_to_direction(GetGameplayCamRot(2)) * 1000.0
    local ray = StartExpensiveSynchronousShapeTestLosProbe(cam.x, cam.y, cam.z, dest.x, dest.y, dest.z, 1, ped, 4)
    local _, hit, endCoords = GetShapeTestResult(ray)
    return hit == 1, endCoords
end

local placing = false

local function start_team_placement(team, name)
    if placing then return end
    placing = true

    ui_open = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'setVisible', data = false })

    local rgb = TEAM_RGB[team] or TEAM_RGB.red

    CreateThread(function()
        while placing do
            Wait(0)
            local ped = PlayerPedId()

            DisableControlAction(0, 24, true)
            DisableControlAction(0, 25, true)
            DisableControlAction(0, 257, true)
            DisableControlAction(0, 263, true)

            local hit, coords = ground_raycast(ped)
            if hit then
                local origin = GetEntityCoords(ped) + vector3(0.0, 0.0, 0.4)
                DrawLine(origin.x, origin.y, origin.z, coords.x, coords.y, coords.z, rgb[1], rgb[2], rgb[3], 200)
                DrawMarker(1, coords.x, coords.y, coords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, rgb[1], rgb[2], rgb[3], 150, false, false, 2, false)

                if IsDisabledControlJustPressed(0, 24) then
                    TriggerServerEvent('elder_kos:server:create_team', team, name, coords)
                    placing = false
                    open_ui()
                    return
                end
            end

            if IsDisabledControlJustPressed(0, 25) then
                placing = false
                open_ui()
                return
            end
        end
    end)
end

local function show_exit_prompt()
    if exit_prompt_shown then return end
    exit_prompt_shown = true
    SendNUIMessage({ action = 'setPrompt', data = { open = true, title = 'EXIT KOS', color = 'purple' } })
end

local function hide_exit_prompt()
    if not exit_prompt_shown then return end
    exit_prompt_shown = false
    SendNUIMessage({ action = 'setPrompt', data = { open = false } })
end

local function create_exit_gate(coords)
    exit_gate_seq = exit_gate_seq + 1
    local id = exit_gate_seq
    local gate = {
        id = id,
        coords = vector3(coords.x, coords.y, coords.z),
        expires = GetGameTimer() + EXIT_LIFETIME,
        dead = false
    }
    exit_gates[id] = gate

    CreateThread(function()
        local near = false
        while not gate.dead and GetGameTimer() < gate.expires do
            local pcoords = GetEntityCoords(PlayerPedId())
            local dist = #(pcoords - gate.coords)
            local remaining = math.ceil((gate.expires - GetGameTimer()) / 1000)

            if dist < 60.0 then
                DrawMarker(
                    1,
                    gate.coords.x, gate.coords.y, gate.coords.z,
                    0.0, 0.0, 0.0,
                    0.0, 0.0, 0.0,
                    1.5, 1.5, 1.0,
                    EXIT_RGB[1], EXIT_RGB[2], EXIT_RGB[3], 255,
                    false, false, 2, false
                )

                local on_screen, sx, sy = World3dToScreen2d(gate.coords.x, gate.coords.y, gate.coords.z + 1.2)
                if on_screen then
                    SendNUIMessage({ action = 'exitGate', data = { open = true, id = id, x = sx, y = sy, remaining = remaining } })
                else
                    SendNUIMessage({ action = 'exitGate', data = { open = false, id = id } })
                end

                if dist < 1.5 then
                    near = true
                    show_exit_prompt()
                    if IsControlJustReleased(0, 38) then
                        TriggerServerEvent('elder_kos:server:exit_kos')
                    end
                elseif near then
                    near = false
                    hide_exit_prompt()
                end
                Wait(0)
            else
                if near then near = false hide_exit_prompt() end
                SendNUIMessage({ action = 'exitGate', data = { open = false, id = id } })
                Wait(500)
            end
        end

        exit_gates[id] = nil
        if near then hide_exit_prompt() end
        SendNUIMessage({ action = 'exitGate', data = { open = false, id = id } })
    end)
end

local function remove_exit_gates()
    for id, gate in pairs(exit_gates) do
        gate.dead = true
        SendNUIMessage({ action = 'exitGate', data = { open = false, id = id } })
    end
    exit_gates = {}
    hide_exit_prompt()
end

local function start_exit_placement()
    if placing then return end
    placing = true

    ui_open = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'setVisible', data = false })

    CreateThread(function()
        while placing do
            Wait(0)
            local ped = PlayerPedId()

            DisableControlAction(0, 24, true)
            DisableControlAction(0, 25, true)
            DisableControlAction(0, 257, true)
            DisableControlAction(0, 263, true)

            local hit, coords = ground_raycast(ped)
            if hit then
                local origin = GetEntityCoords(ped) + vector3(0.0, 0.0, 0.4)
                DrawLine(origin.x, origin.y, origin.z, coords.x, coords.y, coords.z, EXIT_RGB[1], EXIT_RGB[2], EXIT_RGB[3], 200)
                DrawMarker(1, coords.x, coords.y, coords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, EXIT_RGB[1], EXIT_RGB[2], EXIT_RGB[3], 150, false, false, 2, false)

                if IsDisabledControlJustPressed(0, 24) then
                    TriggerServerEvent('elder_kos:server:create_exit', coords)
                    placing = false
                    open_ui()
                    return
                end
            end

            if IsDisabledControlJustPressed(0, 25) then
                placing = false
                open_ui()
                return
            end
        end
    end)
end

RegisterNetEvent('elder_kos:client:exit_created', function(coords)
    create_exit_gate(coords)
end)

RegisterNetEvent('elder_kos:client:do_exit', function(coords)
    local ped = PlayerPedId()
    SetEntityCoords(ped, coords.x, coords.y, coords.z, false, false, false, false)
end)

RegisterNUICallback('createExit', function(_, cb)
    cb({})
    start_exit_placement()
end)

RegisterNetEvent('elder_kos:client:requests_updated', function(list)
    if not ui_open then return end
    SendNUIMessage({ action = 'setRequests', data = list })
end)

RegisterNUICallback('startKos', function(_, cb)
    TriggerServerEvent('elder_kos:server:start_kos')
    cb({})
end)

RegisterNUICallback('startRound', function(_, cb)
    TriggerServerEvent('elder_kos:server:start_round')
    cb({})
end)

RegisterNUICallback('restartRound', function(_, cb)
    TriggerServerEvent('elder_kos:server:restart_round')
    cb({})
end)

RegisterNUICallback('cancelRound', function(_, cb)
    TriggerServerEvent('elder_kos:server:cancel_round')
    cb({})
end)

RegisterNUICallback('acceptRequest', function(data, cb)
    TriggerServerEvent('elder_kos:server:respond_request', data.id, true)
    cb({})
end)

RegisterNUICallback('refuseRequest', function(data, cb)
    TriggerServerEvent('elder_kos:server:respond_request', data.id, false)
    cb({})
end)

RegisterNUICallback('createTeam', function(data, cb)
    cb({})
    start_team_placement(data.team, data.name)
end)

RegisterNetEvent('elder_kos:client:team_created', function(team, coords)
    if joined_team then return end
    if accepted or kos_manager then
        create_team_point(team, coords)
    end
end)

RegisterNetEvent('elder_kos:client:joined_team', function(team)
    joined_team = team
    remove_team_points()
end)

RegisterNetEvent('elder_kos:client:close_join_markers', function()
    remove_team_points()
end)

local function run_round_intro(round, countdown, on_finish)
    CreateThread(function()
        for c = countdown, 1, -1 do
            SendNUIMessage({ action = 'roundIntro', data = { open = true, round = round, count = c } })
            Wait(1000)
        end
        SendNUIMessage({ action = 'roundIntro', data = { open = false } })
        if on_finish then on_finish() end
    end)
end

RegisterNetEvent('elder_kos:client:round_intro', function(round, countdown)
    run_round_intro(round, countdown)
end)

local function give_round_weapon()
    if not config.weapon then return end
    local ped = PlayerPedId()
    local hash = GetHashKey(config.weapon)
    GiveWeaponToPed(ped, hash, 250, false, true)
    SetPedAmmo(ped, hash, 250)
end

local function remove_round_weapon()
    if not config.weapon then return end
    RemoveWeaponFromPed(PlayerPedId(), GetHashKey(config.weapon))
end

RegisterNetEvent('elder_kos:client:round_start', function(coords, round, countdown)
    in_round = true
    round_frozen = true

    if exports.esx_ambulancejob:IsPlayerDead() then
        TriggerEvent('esx_ambulancejob:revive_deathmatch')
        Wait(750)
    end

    local ped = PlayerPedId()
    SetEntityCoords(ped, coords.x, coords.y, coords.z, false, false, false, false)
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)

    give_round_weapon()

    CreateThread(function()
        while round_frozen do
            DisableControlAction(0, 24, true)
            DisableControlAction(0, 25, true)
            DisableControlAction(0, 257, true)
            DisableControlAction(0, 263, true)
            Wait(0)
        end
    end)

    run_round_intro(round, countdown, function()
        round_frozen = false
        local p = PlayerPedId()
        FreezeEntityPosition(p, false)
        SetEntityInvincible(p, false)
    end)

    CreateThread(function()
        while in_round do
            if not round_frozen and IsEntityDead(PlayerPedId()) then
                TriggerServerEvent('elder_kos:server:player_died')
                while in_round and IsEntityDead(PlayerPedId()) do Wait(500) end
            end
            Wait(300)
        end
    end)
end)

RegisterNetEvent('elder_kos:client:round_end', function(data)
    in_round = false
    round_frozen = false

    remove_round_weapon()

    SendNUIMessage({
        action = 'matchResult',
        data = {
            open = true,
            scope = 'round',
            team = data.team,
            teamName = data.teamName,
            round = data.round,
            redScore = data.redScore,
            blueScore = data.blueScore
        }
    })

    SetTimeout(data.cooldown * 1000, function()
        SendNUIMessage({ action = 'matchResult', data = { open = false } })
    end)
end)

RegisterNetEvent('elder_kos:client:round_cancel', function()
    in_round = false
    round_frozen = false

    remove_round_weapon()

    local ped = PlayerPedId()
    FreezeEntityPosition(ped, false)
    SetEntityInvincible(ped, false)

    -- hide any round intro/result overlay; the round simply never happened
    SendNUIMessage({ action = 'roundIntro', data = { open = false } })
    SendNUIMessage({ action = 'matchResult', data = { open = false } })
end)

RegisterNetEvent('elder_kos:client:score_updated', function(red, blue)
    if not ui_open then return end
    SendNUIMessage({ action = 'setScore', data = { red = red, blue = blue } })
end)

RegisterNetEvent('elder_kos:client:round_active', function(active)
    if not ui_open then return end
    SendNUIMessage({ action = 'setRoundActive', data = active })
end)

RegisterNetEvent('elder_kos:client:scoreboard', function(data)
    SendNUIMessage({ action = 'scoreboard', data = data })
end)

RegisterNetEvent('elder_kos:client:kos_ended', function(data)
    in_round = false
    round_frozen = false

    remove_round_weapon()

    local ped = PlayerPedId()
    FreezeEntityPosition(ped, false)
    SetEntityInvincible(ped, false)

    SendNUIMessage({
        action = 'matchResult',
        data = {
            open = true,
            scope = 'game',
            team = data.team,
            teamName = data.teamName,
            round = 0,
            redScore = data.redScore,
            blueScore = data.blueScore
        }
    })

    SetTimeout(8000, function()
        SendNUIMessage({ action = 'matchResult', data = { open = false } })
    end)
end)

RegisterNetEvent('elder_kos:client:teams_updated', function(teams)
    if kos_manager then
        red_team = teams.red or {}
        blue_team = teams.blue or {}
        start_kos_management()
    end
    if not ui_open then return end
    SendNUIMessage({ action = 'setTeams', data = teams })
end)

RegisterNUICallback('cancelKos', function(_, cb)
    TriggerServerEvent('elder_kos:server:cancel_kos')
    cb({})
end)

RegisterNUICallback('logKos', function(data, cb)
    TriggerServerEvent('elder_kos:server:log_kos', data)
    cb({})
end)

RegisterNUICallback('endKos', function(data, cb)
    TriggerServerEvent('elder_kos:server:end_kos', data)
    cb({})
end)

RegisterNetEvent('elder_kos:client:kos_reset', function()
    kos_in_progress = false
    can_request = false
    accepted = false
    joined_team = nil
    red_team = {}
    blue_team = {}
    in_round = false
    round_frozen = false

    local ped = PlayerPedId()
    FreezeEntityPosition(ped, false)
    SetEntityInvincible(ped, false)

    remove_team_points()
    remove_exit_gates()
    SendNUIMessage({ action = 'roundIntro', data = { open = false } })
    SendNUIMessage({ action = 'scoreboard', data = { open = false } })
    SendNUIMessage({
        action = 'setState',
        data = { in_progress = false, requests = {} }
    })
end)

CreateThread(function()
    while not ESX.IsPlayerLoaded() do Wait(100) end
    kos_manager = is_kos_manager()
end)

RegisterNUICallback('closeUi', function(_, cb)
    ui_open = false
    SetNuiFocus(false, false)
    cb({})
end)

local function on_kos_started()
    notify('Drilltime KOS', 'KOS started, to particpate type <b>/joinkos</b>', 60000)
    start_kos_management()
end

local function start_kos()
    kos_in_progress = true
    can_request = true
    on_kos_started()
end

RegisterNetEvent('elder_kos:client:request_accepted', function(coords, teams)
    accepted = true
    notify('Drilltime KOS', 'Your request has been accepted.', 5000)
    SetEntityCoords(PlayerPedId(), coords.x, coords.y, coords.z, false, false, false, false)

    if teams then
        if teams.red and teams.red.coords then create_team_point('red', teams.red.coords) end
        if teams.blue and teams.blue.coords then create_team_point('blue', teams.blue.coords) end
    end
end)

RegisterNetEvent('elder_kos:client:start_kos', function(moderator)
    start_kos()
    SendNUIMessage({
        action = 'setState',
        data = { in_progress = true, moderator = moderator }
    })
end)

RegisterCommand('kos', function()
    open_ui()
end)

RegisterCommand('joinkos', function()
    if not can_request then return end
    can_request = false
    TriggerServerEvent('elder_kos:server:request_join')
end)

