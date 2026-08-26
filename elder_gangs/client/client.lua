local isOpen = false

local function build_available_ranks()
    local list = {}
    if Config and Config.Ranks then
        for id, rank in pairs(Config.Ranks) do
            if not rank.isLeader then
                list[#list + 1] = {
                    id            = id,
                    name          = rank.name,
                    canManageGang = rank.canManageGang == true,
                    isDefault     = rank.isDefault     == true,
                }
            end
        end
    end
    table.sort(list, function(a, b) return a.id < b.id end)
    return list
end

local function send_open_hood(gang, profile)
    SendNUIMessage({
        action = 'openHood',
        gang = {
            name = gang.name,
            rank = gang.rank_name,
            leaderName = gang.leaderName,
            canManageGang = gang.can_manage_gang == true,
            isLeader = gang.is_leader == true,
            availableRanks = build_available_ranks(),
        },
        profile = profile,
        defaultAvatar = Config.DefaultAvatar,
        levels = Config.Levels,
    })
end

local function close_ui()
    if not isOpen then return end
    isOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'close' })
end

local function get_profile(gangName)
    return lib.callback.await('elder_gangs:get_profile', false, gangName)
end

local function get_player_display_name()
    local data = client.framework.player.get_data()
    if not data then return nil end
    local first = data.firstName or (data.charinfo and data.charinfo.firstname)
    local last = data.lastName or (data.charinfo and data.charinfo.lastname)
    if first and last then return first .. ' ' .. last end
    return first or last
end

function open_hoods_ui()
    CreateThread(function()
        if isOpen then return end
        local gang = get_player_gang()
        if not gang then return end

        isOpen = true
        SetNuiFocus(true, true)
        SendNUIMessage({ action = 'openHood:loading' })

        local profile = get_profile(gang.name) or { ops = 0, offense = 0, defense = 0 }
        profile.name = get_player_display_name() or profile.name
        send_open_hood(gang, profile)
    end)
end

RegisterNUICallback('close', function(_, cb)
    close_ui()
    cb('ok')
end)

RegisterNUICallback('leaveGang', function(_, cb)
    local res = lib.callback.await('elder_gangs:player:leave_gang', false)
    if res and res.ok then close_ui() end
    cb(res or { ok = false })
end)

local function refresh_hood_profile()
    if not isOpen then return end
    local gang = get_player_gang()
    if not gang then return end
    local profile = get_profile(gang.name)
    if not profile then return end
    profile.name = get_player_display_name() or profile.name
    SendNUIMessage({ action = 'update', profile = profile })
end

local function get_nearby_player_sources(radius)
    local my_ped = PlayerPedId()
    local my_coords = GetEntityCoords(my_ped)
    local r = tonumber(radius) or 10.0
    local out = {}
    for _, player_id in ipairs(GetActivePlayers()) do
        if player_id ~= PlayerId() then
            local ped = GetPlayerPed(player_id)
            if ped ~= 0 and DoesEntityExist(ped) then
                local coords = GetEntityCoords(ped)
                if #(coords - my_coords) <= r then
                    out[#out + 1] = GetPlayerServerId(player_id)
                end
            end
        end
    end
    return out
end

RegisterNUICallback('invite:nearby', function(_, cb)
    local sources = get_nearby_player_sources(10.0)
    local res = lib.callback.await('elder_gangs:invite:enrich_nearby', false, sources)
    cb(res or { ok = false })
end)

RegisterNUICallback('invite:send', function(data, cb)
    local target  = data and data.identifier
    local rank_id = data and data.rank_id
    local res = lib.callback.await('elder_gangs:invite:send', false, target, rank_id)
    cb(res or { ok = false })
end)

RegisterNUICallback('invite:respond', function(data, cb)
    local accepted = data and data.accepted == true
    local res = lib.callback.await('elder_gangs:invite:respond', false, accepted)

    if accepted then
        SetNuiFocus(false, false)
        SendNUIMessage({ action = 'invite:close' })
    end
    cb(res or { ok = false })
end)

RegisterNetEvent('elder_gangs:client:invite:incoming', function(payload)
    if not payload then return end
    SetNuiFocus(true, true)
    SendNUIMessage({
        action     = 'invite:incoming',
        fromName   = payload.fromName,
        gangName   = payload.gangName,
        rankName   = payload.rankName,
        timeoutSec = payload.timeoutSec or 60,
    })
end)

RegisterNUICallback('invite:dismiss', function(_, cb)
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'invite:close' })
    cb({ ok = true })
end)

RegisterNUICallback('member:promote', function(data, cb)
    local target  = data and data.id
    local rank_id = data and data.rank_id
    local res = lib.callback.await('elder_gangs:player:promote', false, target, rank_id)
    if res and res.ok then refresh_hood_profile() end
    cb(res or { ok = false })
end)

RegisterNUICallback('member:kick', function(data, cb)
    local target = data and data.id
    local res = lib.callback.await('elder_gangs:player:kick', false, target)
    if res and res.ok then refresh_hood_profile() end
    cb(res or { ok = false })
end)

RegisterNUICallback('mission:setActive', function(data, cb)
    if data and data.id then
        local missions = lib.callback.await('elder_gangs:set_active_mission', false, data.id)
        SendNUIMessage({ action = 'update', missions = missions })
    end
    cb('ok')
end)

RegisterNUICallback('mission:claim', function(data, cb)
    if data and data.id then
        local missions = lib.callback.await('elder_gangs:claim_mission', false, data.id)
        SendNUIMessage({ action = 'update', missions = missions })
    end
    cb('ok')
end)

RegisterNUICallback('mission:cancel', function(data, cb)
    if data and data.id then
        local missions = lib.callback.await('elder_gangs:cancel_mission', false, data.id)
        SendNUIMessage({ action = 'update', missions = missions })
    end
    cb('ok')
end)

RegisterNUICallback('craft:start', function(data, cb)
    if data and data.index then
        local crafting = lib.callback.await('elder_gangs:start_craft', false, tonumber(data.index), tonumber(data.amount) or 1)
        SendNUIMessage({ action = 'update', crafting = crafting })
    end
    cb('ok')
end)

RegisterNUICallback('craft:claim', function(_, cb)
    local crafting = lib.callback.await('elder_gangs:claim_craft', false)
    SendNUIMessage({ action = 'update', crafting = crafting })
    cb('ok')
end)

RegisterNUICallback('sell:start', function(data, cb)
    if data and data.item then
        local drugs = lib.callback.await('elder_gangs:start_sell', false, data.item, tonumber(data.count) or 0)
        SendNUIMessage({ action = 'update', drugs = drugs })
    end
    cb('ok')
end)

RegisterNUICallback('sell:claim', function(_, cb)
    local drugs = lib.callback.await('elder_gangs:claim_sell', false)
    SendNUIMessage({ action = 'update', drugs = drugs })
    cb('ok')
end)

RegisterCommand('gangmenu', function()
    open_hoods_ui()
end)

RegisterKeyMapping('gangmenu', 'Open Gang Menu', "keyboard", 'F10')