local RobInProgress = false
local LastAttempt   = 0

function is_rob_in_progress()
    return RobInProgress
end

function start_rob_attempt(gangId)
    if not gangId then return end
    if RobInProgress then
        hoods_notify({ title = 'Hood Rob', description = 'You are already robbing', type = 'error', duration = 4000 })
        return
    end
    if GetGameTimer() - LastAttempt < 2000 then return end
    LastAttempt = GetGameTimer()

    local playerGangId = get_player_gang_id()
    if not playerGangId then
        hoods_notify({ title = 'Hood Rob', description = 'You must be in a gang to rob', type = 'error', duration = 4000 })
        return
    end
    if playerGangId == tostring(gangId) then return end

    local skill = Config.RobSkillCheck or { 'hard', 'hard', 'hard' }
    local success = lib.skillCheck(skill)
    if not success then
        hoods_notify({ title = 'Hood Rob', description = 'Try again', type = 'error', duration = 4000 })
        return
    end

    TriggerServerEvent('elder_gangs:server:rob:start', tostring(gangId))
end

RegisterNetEvent('elder_gangs:client:rob:notify', function(data)
    if not data then return end
    hoods_notify(data)
end)

RegisterNetEvent('elder_gangs:client:rob:start', function(gangId)
    if RobInProgress then return end
    RobInProgress = true

    local gang = client.datastore.gangs.get(gangId)
    local dealer_ped = gang and gang.checkpoints and gang.checkpoints.ped
    local timer = tonumber(Config.RobTimer) or 180
    local maxRadius = tonumber(Config.MaxRadiusToRob) or 15.0
    local endsAt = GetGameTimer() + timer * 1000

    hoods_notify({
        title = 'Hood Rob',
        description = ('Hold near the dealer for %d seconds'):format(timer),
        type = 'info',
        duration = 6000,
    })

    CreateThread(function()
        while RobInProgress and GetGameTimer() < endsAt do
            Wait(500)
            local ped = PlayerPedId()
            if IsEntityDead(ped) then
                RobInProgress = false
                TriggerServerEvent('elder_gangs:server:rob:cancel')
                return
            end
            if dealer_ped then
                local pcoords = GetEntityCoords(ped)
                local d = #(pcoords - vector3(dealer_ped.x, dealer_ped.y, dealer_ped.z))
                if d > maxRadius then
                    RobInProgress = false
                    TriggerServerEvent('elder_gangs:server:rob:cancel')
                    return
                end
            end
        end
        if RobInProgress then
            TriggerServerEvent('elder_gangs:server:rob:end')
        end
    end)

    CreateThread(function()
        while RobInProgress do
            local remaining = math.max(0, math.ceil((endsAt - GetGameTimer()) / 1000))
            if remaining <= 0 then break end
            hoods_notify({
                title = 'Hood Rob',
                description = ('Defend yourself - %d seconds left'):format(remaining),
                type = 'shooting',
                duration = 10000,
            })
            Wait(10000)
        end
    end)
end)

RegisterNetEvent('elder_gangs:client:rob:cancel', function()
    if not RobInProgress then return end
    RobInProgress = false
    hoods_notify({ title = 'Hood Rob', description = 'Rob canceled', type = 'error', duration = 5000 })
end)

RegisterNetEvent('elder_gangs:client:rob:end', function(seizedItems, seizedMoney)
    RobInProgress = false
    local items = tonumber(seizedItems) or 0
    local money = tonumber(seizedMoney) or 0
    local desc
    if items > 0 and money > 0 then
        desc = ('Robbery successful - %d items + $%d taken'):format(items, money)
    elseif items > 0 then
        desc = ('Robbery successful - %d items taken'):format(items)
    elseif money > 0 then
        desc = ('Robbery successful - $%d taken'):format(money)
    else
        desc = 'Robbery successful - nothing to take'
    end
    hoods_notify({
        title = 'Hood Rob',
        description = desc,
        type = 'success',
        duration = 6000,
    })
end)

RegisterNetEvent('elder_gangs:client:rob:gang_alert', function(data)
    if not data then return end
    if data.gangId ~= get_player_gang_id() then return end
    hoods_notify({
        title = data.title or 'Hood',
        description = data.description or '',
        type = data.type or 'shooting',
        duration = data.duration or 8000,
    })
end)
