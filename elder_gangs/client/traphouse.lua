local enter_points = {}
local exit_points = {}

local function is_police()
    return client.framework.player.get_job_name() == (Config.PoliceJob or 'police')
end

local function teleport(coords, freeze)
    local ped = PlayerPedId()
    SetEntityCoordsNoOffset(ped, coords.x, coords.y, coords.z, false, false, false)
    if freeze then
        Wait(500)
        FreezeEntityPosition(ped, true)
        Wait(5000)
        FreezeEntityPosition(ped, false)
    end
end

local function show_prompt(label, action, color)
    SendNUIMessage({
        action = 'prompt:show',
        title  = 'TRAPHOUSE',
        text   = action .. ' ' .. label,
        key    = 'E',
        color  = color,
    })
end

local function hide_prompt()
    SendNUIMessage({ action = 'prompt:hide' })
end

local function spawn_zone_for(gang)
    if not gang or not gang.id then return end
    local cp = gang.checkpoints
    if not cp or not cp.enter or not cp.exit then return end
    local key = tostring(gang.id)
    if enter_points[key] then return end

    local label = gang.name or key
    local enter_vec = vector3(cp.enter.x, cp.enter.y, cp.enter.z)
    local exit_vec  = vector3(cp.exit.x,  cp.exit.y,  cp.exit.z)

    if key ~= '0' then
        local enter = lib.points.new({
            coords = enter_vec,
            distance = 2.0,
            gangId = key,
            label = label,
            exitVec = exit_vec,
        })
        function enter:onEnter()
            show_prompt(self.label .. ' TRAPHOUSE', 'ENTER', 'purple')
        end
        function enter:onExit()
            hide_prompt()
        end
        function enter:nearby()
            if IsControlJustReleased(0, 38) then
                if self.gangId == get_player_gang_id() or is_police() then
                    hide_prompt()
                    teleport(self.exitVec, true)
                else
                    hoods_notify({
                        title = 'Traphouse',
                        description = "Can't enter this gang traphouse",
                        type = 'error',
                        duration = 4000,
                    })
                end
            end
        end
        enter_points[key] = enter
    end

    local exitPoint = lib.points.new({
        coords = exit_vec,
        distance = 2.0,
        gangId = key,
        label = label,
        enterVec = enter_vec,
    })
    function exitPoint:onEnter()
        if self.gangId == get_player_gang_id() then
            show_prompt(self.label .. ' HOUSE', 'EXIT', 'red')
        end
    end
    function exitPoint:onExit()
        hide_prompt()
    end
    function exitPoint:nearby()
        if self.gangId ~= get_player_gang_id() then return end
        if IsControlJustReleased(0, 38) then
            hide_prompt()
            teleport(self.enterVec, false)
        end
    end
    exit_points[key] = exitPoint
end

local function teardown_zone_for(gangId)
    if not gangId then return end
    local key = tostring(gangId)
    if enter_points[key] then enter_points[key]:remove(); enter_points[key] = nil end
    if exit_points[key]  then exit_points[key]:remove();  exit_points[key]  = nil end
end

local function spawn_all_zones()
    if not client.datastore or not client.datastore.gangs.loaded then return end
    for _, gang in pairs(client.datastore.gangs.data) do
        if gang.active then spawn_zone_for(gang) end
    end
end

TraphouseSpawnZoneFor = spawn_zone_for
TraphouseTeardownZoneFor = teardown_zone_for

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
    for key, p in pairs(enter_points) do p:remove(); enter_points[key] = nil end
    for key, p in pairs(exit_points)  do p:remove(); exit_points[key]  = nil end
    hide_prompt()
end)
