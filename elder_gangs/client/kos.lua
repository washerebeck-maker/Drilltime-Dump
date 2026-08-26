local datastore = client.datastore
local framework = client.framework

local blips  = {}
local wanted = {}
local synced = false
local locked = {}
local lock_timer_pending = false
local active = {}
local active_timer_pending = false

local function config()
    return Config.Kos or {}
end

local function gang_coords(gang)
    local cp = gang and gang.checkpoints
    local c = cp and cp.coords
    if not c or not c.x or not c.y or not c.z then return nil end
    return vector3(c.x + 0.0, c.y + 0.0, c.z + 0.0)
end

local function blip_label(gang, id)
    local name = (gang and gang.name) or ('Gang ' .. tostring(id))
    local fmt = config().Label
    if type(fmt) ~= 'string' or fmt == '' then return name end
    local ok, out = pcall(string.format, fmt, name)
    return ok and out or name
end

local function remove_blip(id)
    local entry = blips[id]
    if not entry then return end
    for i = 1, #entry do
        if DoesBlipExist(entry[i]) then RemoveBlip(entry[i]) end
    end
    blips[id] = nil
end

local function is_kos_active(id)
    local until_ms = active[id]
    return until_ms ~= nil and GetGameTimer() < until_ms
end

-- Colour / short-range pair to use for a hood blip right now.
local function blip_style(id)
    local cfg = config()
    if is_kos_active(id) then
        local short = cfg.ActiveShortRange
        if short == nil then short = cfg.ShortRange end
        return tonumber(cfg.ActiveColour) or tonumber(cfg.Colour) or 1, short == true
    end
    return tonumber(cfg.Colour) or 1, cfg.ShortRange == true
end

local function style_blip(id)
    local entry = blips[id]
    if not entry then return end
    local colour, short = blip_style(id)
    for i = 1, #entry do
        if DoesBlipExist(entry[i]) then
            SetBlipColour(entry[i], colour)
            SetBlipAsShortRange(entry[i], short)
        end
    end
end

local function restyle_blips()
    for id in pairs(blips) do style_blip(id) end
end

local function create_blip(id)
    if blips[id] then return end
    local gang = datastore.gangs.data[id]
    if not gang or not gang.active then return end

    local coords = gang_coords(gang)
    if not coords then return end

    local cfg = config()
    local colour, short_range = blip_style(id)

    local blip = AddBlipForCoord(coords)
    SetBlipSprite(blip, tonumber(cfg.Sprite) or 84)
    SetBlipColour(blip, colour)
    SetBlipScale(blip, (tonumber(cfg.Scale) or 0.9) + 0.0)
    SetBlipAsShortRange(blip, short_range)
    SetBlipDisplay(blip, 4)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName(blip_label(gang, id))
    EndTextCommandSetBlipName(blip)

    local area = AddBlipForCoord(coords)
    SetBlipSprite(area, 161)
    SetBlipColour(area, colour)
    SetBlipScale(area, (tonumber(cfg.AreaScale) or 2.0) + 0.0)
    SetBlipAlpha(area, math.floor(tonumber(cfg.AreaAlpha) or 128))
    SetBlipAsShortRange(area, short_range)

    blips[id] = { blip, area }
end

local function player_has_gang()
    return get_player_gang_id ~= nil and get_player_gang_id() ~= nil
end

local function apply()
    if not player_has_gang() then
        for id in pairs(blips) do remove_blip(id) end
        return
    end

    if not datastore.gangs.loaded then
        if next(wanted) == nil then return end
        datastore.gangs.load()
        if not datastore.gangs.loaded then return end
    end
    for id in pairs(wanted) do
        if not blips[id] then create_blip(id) end
    end
    for id in pairs(blips) do
        if not wanted[id] then remove_blip(id) end
    end
end

function is_gang_kos(gangId)
    local id = tonumber(gangId)
    if not id or not wanted[id] then return false end
    local until_ms = locked[id]
    return not (until_ms and GetGameTimer() < until_ms)
end

local function schedule_lock_refresh()
    if lock_timer_pending then return end
    local now = GetGameTimer()
    local soonest
    for _, until_ms in pairs(locked) do
        if until_ms > now and (not soonest or until_ms < soonest) then soonest = until_ms end
    end
    if not soonest then return end

    lock_timer_pending = true
    SetTimeout((soonest - now) + 250, function()
        lock_timer_pending = false
        if refresh_hood_prompt then refresh_hood_prompt() end
        schedule_lock_refresh()
    end)
end

local function apply_locks(map)
    locked = {}
    local now = GetGameTimer()
    for id, remaining in pairs(map or {}) do
        local key = tonumber(id)
        local secs = tonumber(remaining)
        if key and secs and secs > 0 then locked[key] = now + secs * 1000 end
    end
    schedule_lock_refresh()
end

-- Restore the normal blip style once the highlight window runs out.
local function schedule_active_refresh()
    if active_timer_pending then return end
    local now = GetGameTimer()
    local soonest
    for _, until_ms in pairs(active) do
        if until_ms > now and (not soonest or until_ms < soonest) then soonest = until_ms end
    end
    if not soonest then return end

    active_timer_pending = true
    SetTimeout((soonest - now) + 250, function()
        active_timer_pending = false
        restyle_blips()
        schedule_active_refresh()
    end)
end

local function apply_active(map)
    active = {}
    local now = GetGameTimer()
    for id, remaining in pairs(map or {}) do
        local key = tonumber(id)
        local secs = tonumber(remaining)
        if key and secs and secs > 0 then active[key] = now + secs * 1000 end
    end
    restyle_blips()
    schedule_active_refresh()
end

local function set_wanted(list)
    wanted = {}
    for _, id in ipairs(list or {}) do
        local key = tonumber(id)
        if key then wanted[key] = true end
    end
    synced = true
    apply()
    if refresh_hood_prompt then refresh_hood_prompt() end
end

local function request_sync()
    local data = lib.callback.await('elder_gangs:kos:blips:get', false)
    if type(data) ~= 'table' then return end
    apply_locks(data.locks)
    apply_active(data.active)
    set_wanted(data.blipped)
end

RegisterNetEvent('elder_gangs:kos:blips:sync', function(list)
    set_wanted(list)
end)

RegisterNetEvent('elder_gangs:player:update', function()
    SetTimeout(500, function()
        apply()
        if refresh_hood_prompt then refresh_hood_prompt() end
    end)
end)

RegisterNetEvent('elder_gangs:kos:locks:sync', function(map)
    apply_locks(map)
    if refresh_hood_prompt then refresh_hood_prompt() end
end)

RegisterNetEvent('elder_gangs:kos:active:sync', function(map)
    apply_active(map)
end)

RegisterNetEvent('elder_gangs:client:kos:notify', function(data)
    if type(data) ~= 'table' then return end
    hoods_notify(data)
end)

shared.serializer.register_net('elder_gangs:datastore:gangs:update', function(gang)
    local id = gang and tonumber(gang.id)
    if not id or not wanted[id] then return end
    remove_blip(id)
    create_blip(id)
end)

shared.serializer.register_net('elder_gangs:datastore:gangs:disable', function(gang)
    local id = gang and tonumber(gang.id)
    if not id then return end
    wanted[id] = nil
    remove_blip(id)
end)

RegisterNetEvent('elder_gangs:datastore:gangs:remove', function(id)
    local key = tonumber(id)
    if not key then return end
    wanted[key] = nil
    remove_blip(key)
end)

AddEventHandler('elder_gangs:client:gangs:ready', function()
    if synced then apply() else request_sync() end
end)

RegisterNetEvent('esx:playerLoaded', function()
    request_sync()
end)

AddEventHandler('onClientResourceStart', function(res)
    if res ~= GetCurrentResourceName() then return end
    if framework.player.is_loaded() then request_sync() end
end)

AddEventHandler('onResourceStop', function(res)
    if res ~= cache.resource then return end
    for id in pairs(blips) do remove_blip(id) end
end)
