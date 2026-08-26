local restricted_weapon = false
local gangs_list = {}
local restrict_ends_at = 0

local function get_player_gang()
    local ok, gang = pcall(function() return exports.elder_gangs:get_player_gang() end)
    return ok and gang and gang.name or false
end

local function you_payload()
    local gang = get_player_gang()
    local kills = 0
    if gang then
        for _, g in ipairs(gangs_list) do
            if g.name == gang then
                kills = g.kills
                break
            end
        end
    end
    return { gang = gang or '', gangKills = kills }
end

local function remaining_secs()
    if restrict_ends_at <= 0 then return 0 end
    return math.max(0, math.floor((restrict_ends_at - GetGameTimer()) / 1000))
end

local function nui_score()
    SendNUIMessage({
        action = 'hud:score',
        gangs = gangs_list,
        you = you_payload(),
    })
end

local function push_state()
    SendNUIMessage({
        action = 'hud:state',
        active = restricted_weapon and get_player_gang() ~= false,
        timeLeft = remaining_secs(),
        gangs = gangs_list,
        you = you_payload(),
    })
end

local function nui_notify(message, notif_type, duration)
    SendNUIMessage({
        action = 'notify',
        message = message,
        type = notif_type or 'error',
        duration = duration or 4000,
    })
end

local function start_restricted_weapons()
    CreateThread(function()
        local had_gang = nil
        while restricted_weapon do
            local in_gang = get_player_gang() ~= false

            if in_gang ~= had_gang then
                had_gang = in_gang
                push_state()
            end

            local sleep = 500
            if in_gang and IsPedArmed(cache.ped, 6) then
                sleep = 1
                local _, current_weapon = GetCurrentPedWeapon(cache.ped, true)
                if not Config.Weapons[current_weapon] then
                    SetCurrentPedWeapon(cache.ped, `WEAPON_UNARMED`, true)
                    nui_notify('⛔️ SEMI PISTOLS ONLY !!  BUY A COMBAT PISTOL AT A GUNSTORE !! ⛔️', 'error', 4000)
                end
            end
            Wait(sleep)
        end
    end)
end

local function set_event(active, remaining)
    restrict_ends_at = active and (GetGameTimer() + (remaining or 0) * 1000) or 0
end

RegisterNetEvent('esx:playerLoaded', function()
    local data = lib.callback.await('elder_weaponrestrict:server:get', false)
    if type(data) ~= 'table' then data = {} end

    restricted_weapon = data.restricted or false
    gangs_list = data.gangs or {}

    set_event(restricted_weapon, data.timeLeft or 0)
    push_state()

    if restricted_weapon then
        start_restricted_weapons()
    end
end)

RegisterNetEvent('elder_weaponrestrict:client:set', function(payload)
    local status, remaining
    if type(payload) == 'table' then
        status = payload.status
        remaining = payload.timeLeft or 0
    else
        status = payload
        remaining = 0
    end

    if status and not restricted_weapon then
        restricted_weapon = true
        set_event(true, remaining)
        start_restricted_weapons()
        if get_player_gang() then
            nui_notify('Weapon restriction event started', 'info', 4000)
        end
    else
        restricted_weapon = status
        set_event(status, remaining)
    end

    push_state()
end)

RegisterNetEvent('elder_weaponrestrict:client:update', function(data)
    gangs_list = data or {}
    nui_score()
end)
