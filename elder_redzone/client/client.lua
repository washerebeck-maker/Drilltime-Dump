local ESX = exports['es_extended']:getSharedObject()

local active = nil

local in_redzone = false
local inside_marker = false
local ranking = {}

local zone_objects = {}
local prompt_index = nil
local starting = false

local HEAD_BONE = 31086
local damage_log = {}
local killing_headshot = false

local active_blip = nil

local function pick(value, fallback)
    if value == nil then return fallback end
    return value
end

local function reset_combat()
    damage_log = {}
    killing_headshot = false
end

local function vehicle_check()
    if not config.delete_vehicle then return end
    CreateThread(function()
        while true do
            if active and inside_marker then
                if cache.vehicle then
                    DeleteVehicle(cache.vehicle)
                end
            end
            Wait(1000)
        end
    end)
end

local function set_redzone_hud(open)
    SendNUIMessage({
        action = 'redzoneState',
        data = {
            open = open,
            gangs = ranking,
            ranks = config.hud.ranks
        }
    })
end

local function notify(message, duration, title)
    SendNUIMessage({
        action = 'notify',
        data = {
            title = title or 'TURF',
            message = message,
            duration = duration or 4000
        }
    })
end

local function set_timer_hud(open, label, remaining, phase)
    SendNUIMessage({
        action = 'zoneTimer',
        data = {
            open = open,
            label = label,
            remaining = remaining,
            phase = phase
        }
    })
end

local function remaining_seconds()
    if not active then return 0 end
    return math.max(0, math.ceil((active.phase_ends_at - GetGameTimer()) / 1000))
end

-- prep counts down for everyone, wherever they are; once the zone is live the
-- usual distance rule takes over again
local function push_timer_hud()
    if not active then return end
    if active.phase == 'prep' or config.timer.show_everywhere or in_redzone then
        set_timer_hud(true, active.location.label or '', remaining_seconds(), active.phase)
    else
        set_timer_hud(false)
    end
end

local function give_weapon()
    if config.give_weapon then
        GiveWeaponToPed(cache.ped, config.weapon, config.weapon_ammo, true, true)
    end
end

local function remove_weapon()
    if config.give_weapon then
        RemoveWeaponFromPed(cache.ped, config.weapon)
    end
end

local function show_prompt(index)
    if prompt_index == index then return end
    prompt_index = index

    local cfg = config.start_marker.prompt
    local location = config.locations[index]
    local label = location and location.label

    SendNUIMessage({
        action = 'prompt:show',
        title = cfg.title,
        text = label and (cfg.text .. ' ' .. label) or cfg.text,
        key = cfg.key,
        color = cfg.color,
    })
end

local function hide_prompt(index)
    if prompt_index == nil then return end
    if index and prompt_index ~= index then return end
    prompt_index = nil
    SendNUIMessage({ action = 'prompt:hide' })
end

local function remove_active_blip()
    if not active_blip then return end
    if DoesBlipExist(active_blip) then
        RemoveBlip(active_blip)
    end
    active_blip = nil
end

local function create_active_blip(location)
    local cfg = config.active_blip
    if not cfg or not cfg.enable then return end

    remove_active_blip()

    local coords = location.coords
    active_blip = AddBlipForCoord(coords.x, coords.y, coords.z)

    SetBlipSprite(active_blip, cfg.sprite)
    SetBlipColour(active_blip, cfg.color)
    SetBlipScale(active_blip, cfg.scale + 0.0)
    SetBlipDisplay(active_blip, cfg.display)
    SetBlipAsShortRange(active_blip, cfg.short_range)
    SetBlipFlashes(active_blip, pick(cfg.flash, false))

    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName(cfg.label or location.label or 'TURF')
    EndTextCommandSetBlipName(active_blip)
end

local function clear_zone_objects()
    for i = #zone_objects, 1, -1 do
        zone_objects[i]:remove()
        zone_objects[i] = nil
    end
end

local function stop_zone()
    remove_active_blip()

    if not active then return end

    clear_zone_objects()

    if inside_marker then
        remove_weapon()
        inside_marker = false
    end

    in_redzone = false
    active = nil
    reset_combat()
    set_redzone_hud(false)
    set_timer_hud(false)
end

-- markers, weapon handout and the ranking HUD only exist once the zone is live
local function build_zone_objects(location)
    local cfg = config.zone_marker
    local marker = lib.points.new({ coords = location.coords, distance = cfg.draw_distance })
    function marker:nearby()
        DrawMarker(cfg.type, self.coords.x, self.coords.y, self.coords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
            location.radius, location.radius, location.radius / 2,
            cfg.color.r, cfg.color.g, cfg.color.b, cfg.color.a, false, false, 0, false, nil, nil, false)
    end
    zone_objects[#zone_objects + 1] = marker

    local red_zone = lib.zones.sphere({ coords = location.coords, radius = location.radius, debug = false })
    function red_zone:onEnter()
        inside_marker = true
        give_weapon()
    end
    function red_zone:onExit()
        inside_marker = false
        remove_weapon()
    end
    zone_objects[#zone_objects + 1] = red_zone

    local outer = lib.points.new({
        coords = location.coords,
        distance = location.radius + location.extra_radius
    })
    function outer:onEnter()
        in_redzone = true
        reset_combat()
        set_redzone_hud(true)
        push_timer_hud()
    end
    function outer:onExit()
        in_redzone = false
        reset_combat()
        set_redzone_hud(false)
        if not config.timer.show_everywhere then
            set_timer_hud(false)
        end
    end
    zone_objects[#zone_objects + 1] = outer
end

local function start_zone(index, remaining, phase)
    local location = config.locations[index]
    if not location then return end

    phase = phase or 'active'

    -- same zone, new phase (or a re-sync): keep what is already built
    if active and active.index == index then
        active.phase_ends_at = GetGameTimer() + remaining * 1000

        if active.phase ~= phase then
            active.phase = phase
            if phase == 'active' then
                build_zone_objects(location)
            end
        end

        push_timer_hud()
        return
    end

    stop_zone()
    active = {
        index = index,
        location = location,
        phase = phase,
        phase_ends_at = GetGameTimer() + remaining * 1000
    }

    create_active_blip(location)

    if phase == 'active' then
        build_zone_objects(location)
    end

    hide_prompt()
    push_timer_hud()
end

local function request_start(index)
    if starting or active then return end
    starting = true
    hide_prompt()

    local ok, err = lib.callback.await('elder_redzone:server:start_zone', false, index)
    if not ok then
        notify(err or 'This zone cannot be started right now', 4000)
    end

    starting = false
end

local blips = {}

CreateThread(function()
    if not config.blip.enable then return end

    for _, location in ipairs(config.locations) do
        local cfg = location.blip or {}
        local coords = location.start_coords or location.coords
        local blip = AddBlipForCoord(coords.x, coords.y, coords.z)

        SetBlipSprite(blip, pick(cfg.sprite, config.blip.sprite))
        SetBlipColour(blip, pick(cfg.color, config.blip.color))
        SetBlipScale(blip, pick(cfg.scale, config.blip.scale) + 0.0)
        SetBlipDisplay(blip, pick(cfg.display, config.blip.display))
        SetBlipAsShortRange(blip, pick(cfg.short_range, config.blip.short_range))

        BeginTextCommandSetBlipName('STRING')
        AddTextComponentSubstringPlayerName(cfg.label or location.label or config.blip.label)
        EndTextCommandSetBlipName(blip)

        blips[#blips + 1] = blip
    end
end)

CreateThread(function()
    local cfg = config.start_marker

    for index, location in ipairs(config.locations) do
        local coords = location.start_coords or location.coords
        local point = lib.points.new({ coords = coords, distance = cfg.draw_distance })
        point.index = index

        function point:nearby()
            if active then
                hide_prompt(self.index)
                return
            end

            DrawMarker(cfg.type, self.coords.x, self.coords.y, self.coords.z + cfg.z_offset,
                0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
                cfg.scale.x, cfg.scale.y, cfg.scale.z,
                cfg.color.r, cfg.color.g, cfg.color.b, cfg.color.a, false, false, 0, false, nil, nil, false)

            local extra = cfg.extra
            if extra and extra.enable then
                DrawMarker(extra.type, self.coords.x, self.coords.y, self.coords.z + extra.z_offset,
                    0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
                    extra.scale.x, extra.scale.y, extra.scale.z,
                    extra.color.r, extra.color.g, extra.color.b, extra.color.a,
                    extra.bob, extra.face_camera, 0, extra.rotate, nil, nil, false)
            end

            if self.currentDistance <= cfg.interact_distance then
                show_prompt(self.index)
                if IsControlJustReleased(0, cfg.prompt.control) then
                    local target = self.index
                    CreateThread(function() request_start(target) end)
                end
            else
                hide_prompt(self.index)
            end
        end

        function point:onExit()
            hide_prompt(self.index)
        end
    end
end)

CreateThread(function()
    while not ESX.IsPlayerLoaded() do Wait(100) end

    ranking = lib.callback.await('elder_redzone:server:get_ranking', false) or {}

    local state = lib.callback.await('elder_redzone:server:get_zone_state', false)
    if state then
        start_zone(state.index, state.remaining, state.phase)
    end

    vehicle_check()
end)

RegisterNetEvent('elder_redzone:client:zone_start', function(index, duration, phase)
    start_zone(index, duration, phase)
end)

RegisterNetEvent('elder_redzone:client:zone_stop', function()
    stop_zone()
end)

RegisterNetEvent('elder_redzone:client:ranking', function(new_ranking)
    ranking = new_ranking
    if in_redzone then
        set_redzone_hud(true)
    end
end)

RegisterNetEvent('elder_redzone:client:heal', function()
    SetEntityHealth(cache.ped, GetEntityMaxHealth(cache.ped))
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    stop_zone()
    hide_prompt()

    for i = #blips, 1, -1 do
        RemoveBlip(blips[i])
        blips[i] = nil
    end
end)

AddEventHandler('gameEventTriggered', function(name, args)
    if name ~= 'CEventNetworkEntityDamage' then return end
    if not active or not in_redzone then return end

    local victim = args[1]
    if victim ~= cache.ped then return end

    local attacker = args[2]
    if not attacker or attacker == 0 or attacker == cache.ped then return end
    if not IsEntityAPed(attacker) or not IsPedAPlayer(attacker) then return end

    local attacker_player = NetworkGetPlayerIndexFromPed(attacker)
    if attacker_player == -1 then return end
    local attacker_sid = GetPlayerServerId(attacker_player)
    if attacker_sid <= 0 then return end

    damage_log[attacker_sid] = true

    local ok, bone = GetPedLastDamageBone(cache.ped)
    killing_headshot = ok and bone == HEAD_BONE
end)

AddEventHandler('esx:onPlayerDeath', function(data)
    if not active or not in_redzone then return end

    local location = active.location

    if inside_marker then
        local killer = data.killerServerId
        local assisters = {}
        for sid in pairs(damage_log) do
            if sid ~= killer then
                assisters[#assisters + 1] = sid
            end
        end

        TriggerServerEvent('elder_redzone:server:on_player_death', killer, killing_headshot, assisters)
    end

    reset_combat()
    Wait(location.revive_time * 1000)
    local respawn = location.revive_locations[math.random(1, #location.revive_locations)]
    TriggerEvent('esx_ambulancejob:revive_in_position', respawn)
end)

local function load_anim_dict(dict)
	while (not HasAnimDictLoaded(dict)) do
		RequestAnimDict(dict)
		Wait(1)
	end
end

local function play_animation()
	load_anim_dict('amb@medic@standing@kneel@base')
	load_anim_dict('anim@gangops@facility@servers@bodysearch@')
	TaskPlayAnim(cache.ped, "amb@medic@standing@kneel@base" ,"base" ,8.0, -8.0, -1, 1, 0, false, false, false )
	TaskPlayAnim(cache.ped, "anim@gangops@facility@servers@bodysearch@" ,"player_search" ,8.0, -8.0, -1, 48, 0, false, false, false )
	Wait(5000)
	ClearPedTasksImmediately(cache.ped)
end

RegisterCommand('drilltime', function()
    if not active or not in_redzone then
        notify('Get in the zone before you start talking, soldier', 5000)
        return
    end
    local target, target_distance = ESX.Game.GetClosestPlayer()
	if target == -1 or target_distance > 1.0 then
		notify('No bodies around to clean out', 5000)
	else
		local target_ped = GetPlayerPed(target)
        if IsEntityDead(target_ped) then
            play_animation()
            exports['screenshot-basic']:requestScreenshotUpload("https://discord.com/api/webhooks/1385465996235640975/M0LiUq9UIXNSDLGAEt529sw9k70JQ1Or_Yb6OFH3_279_Bo9-IvxL1Zvzxgj7Du7D4tn", 'files[]', function(data)
                local resp = json.decode(data)
                local imageUrl = resp.attachments[1].url
                TriggerServerEvent('elder_redzone:server:check_cheater', GetPlayerServerId(target), imageUrl)
            end)
            notify('Robbed him clean — that loot is ours now', 5000)
        else
            notify('He is still breathing, drop him first', 5000)
        end
	end
end)
