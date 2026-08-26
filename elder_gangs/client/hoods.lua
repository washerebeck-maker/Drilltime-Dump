InMyHood = false
InOtherHood = false
HoodsCurrentZones = {}

local zones_by_gang = {}

local alerting = {}
local persistent_label = nil

local function is_police()
    return client.framework.player.get_job_name() == (Config.PoliceJob or 'police')
end

local function alert_config()
    return Config.HoodAlert or {}
end

local function alert_enabled()
    local cfg = alert_config()
    if cfg.Enabled == false then return false end
    return GetResourceState(cfg.Resource or 'mythic_notify') == 'started'
end

local function fill(pattern, label)
    if type(pattern) ~= 'string' or pattern == '' then return nil end
    return (pattern:gsub('{hood}', function() return label end))
end

local function apply_hood_alert()
    if not alert_enabled() then return end
    local cfg = alert_config()
    local id = cfg.Id or 'Gangs'

    local _, label = next(alerting)
    if label == persistent_label then return end

    if persistent_label then
        persistent_label = nil
        pcall(function() exports[cfg.Resource or 'mythic_notify']:PersistentAlert('end', id) end)
    end

    local text = label and fill(cfg.Enter, label)
    if text then
        persistent_label = label
        pcall(function()
            exports[cfg.Resource or 'mythic_notify']:PersistentAlert('start', id, cfg.EnterType or 'error', text)
        end)
    end
end

local function send_left_alert(label)
    if not alert_enabled() then return end
    local cfg = alert_config()
    local text = fill(cfg.Exit, label)
    if not text then return end
    pcall(function()
        exports[cfg.Resource or 'mythic_notify']:SendAlert(cfg.ExitType or 'Success', text)
    end)
end

local function clear_hood_alert(key)
    local label = alerting[key]
    if not label then return end
    alerting[key] = nil
    apply_hood_alert()
    return label
end

local function spawn_zone_for(gang)
    if not gang or not gang.id then return end
    local cp = gang.checkpoints
    if not cp or not cp.coords then return end
    local key = tostring(gang.id)
    if zones_by_gang[key] then return end

    local alerts = gang.alert_system == true
    local label = gang.name or ('Gang ' .. key)
    zones_by_gang[key] = lib.zones.sphere({
        coords = vector3(cp.coords.x, cp.coords.y, cp.coords.z),
        radius = cp.radius or 40.0,
        debug = false,
        onEnter = function()
            HoodsCurrentZones[key] = true
            local own = key == get_player_gang_id()
            if own then
                InMyHood = true
            else
                InOtherHood = true
            end
            if not own or alert_config().OwnHood == true then
                alerting[key] = label
                apply_hood_alert()
            end
            if alerts and is_police() then
                TriggerServerEvent('elder_gangs:server:cops_in_hood', key)
            end
        end,
        onExit = function()
            HoodsCurrentZones[key] = nil
            if key == get_player_gang_id() then
                InMyHood = false
            else
                InOtherHood = false
            end
            local left = clear_hood_alert(key)
            if left then send_left_alert(left) end
        end,
    })
end

local function teardown_zone_for(gangId)
    if not gangId then return end
    local key = tostring(gangId)
    local z = zones_by_gang[key]
    if z then z:remove(); zones_by_gang[key] = nil end
    HoodsCurrentZones[key] = nil
    clear_hood_alert(key)
end

local function spawn_all_zones()
    if not client.datastore or not client.datastore.gangs.loaded then return end
    for _, gang in pairs(client.datastore.gangs.data) do
        if gang.active then spawn_zone_for(gang) end
    end
end

HoodsSpawnZoneFor = spawn_zone_for
HoodsTeardownZoneFor = teardown_zone_for

AddEventHandler('elder_gangs:client:gangs:ready', spawn_all_zones)

shared.serializer.register_net('elder_gangs:datastore:gangs:create', function(gang)
    if gang and gang.active then spawn_zone_for(gang) end
end)

shared.serializer.register_net('elder_gangs:datastore:gangs:update', function(gang)
    if not gang then return end
    teardown_zone_for(gang.id)
    if gang.active then spawn_zone_for(gang) end
end)

shared.serializer.register_net('elder_gangs:datastore:gangs:enable', function(gang)
    if gang then spawn_zone_for(gang) end
end)

shared.serializer.register_net('elder_gangs:datastore:gangs:disable', function(gang)
    if gang then teardown_zone_for(gang.id) end
end)

RegisterNetEvent('elder_gangs:datastore:gangs:remove', function(id)
    teardown_zone_for(id)
end)

AddEventHandler('onResourceStop', function(name)
    if name ~= cache.resource then return end
    for key, z in pairs(zones_by_gang) do z:remove(); zones_by_gang[key] = nil end
    alerting = {}
    apply_hood_alert()
end)
