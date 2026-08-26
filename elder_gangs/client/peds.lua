local DEALER_MODEL = `s_m_y_dealer_01`

local peds = {}
local far_points = {}
local near_points = {}

local function spawn_dealer(key, ped_coords)
    if peds[key] then return end
    if not lib.requestModel(DEALER_MODEL, 5000) then return end
    local heading = ped_coords.h or 0.0
    local ped = CreatePed(5, DEALER_MODEL, ped_coords.x, ped_coords.y, ped_coords.z - 1.0, heading, false, true)
    PlaceObjectOnGroundProperly(ped)
    SetEntityHeading(ped, heading)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    SetModelAsNoLongerNeeded(DEALER_MODEL)
    FreezeEntityPosition(ped, true)
    peds[key] = ped
end

local function despawn_dealer(key)
    local ped = peds[key]
    if not ped then return end
    if DoesEntityExist(ped) then DeleteEntity(ped) end
    peds[key] = nil
end

local current_prompt_key = nil

local function show_prompt_for(key)
    local playerGangId = get_player_gang_id()
    if not playerGangId then
        SendNUIMessage({ action = 'prompt:hide' })
        return
    end
    if playerGangId == key then
        SendNUIMessage({ action = 'prompt:show', title = 'Gang Hood', text = 'Open Hood UI', key = 'E' })
    elseif playerGangId then
        local msg = { action = 'prompt:show', title = 'ROB', text = 'Rob Gang Hood', key = 'E', color = 'red' }
        if is_gang_kos and is_gang_kos(key) then
            msg.second = { title = 'KOS', text = 'Notification', key = 'H', color = 'red' }
        end
        SendNUIMessage(msg)
    end
end

function refresh_hood_prompt()
    if current_prompt_key then show_prompt_for(current_prompt_key) end
end

local function spawn_zone_for(gang)
    if not gang or not gang.id then return end
    local cp = gang.checkpoints
    if not cp or not cp.coords or not cp.ped then return end
    local key = tostring(gang.id)
    if far_points[key] then return end

    local ped_coords = cp.ped
    local ref_coords = vector3(ped_coords.x, ped_coords.y, ped_coords.z)

    local far = lib.points.new({
        coords = ref_coords,
        distance = 50.0,
        gangKey = key,
        pedCoords = ped_coords,
    })
    function far:onEnter() spawn_dealer(self.gangKey, self.pedCoords) end
    function far:onExit()  despawn_dealer(self.gangKey) end
    far_points[key] = far

    local near = lib.points.new({
        coords = ref_coords,
        distance = 2.0,
        gangKey = key,
    })
    function near:onEnter()
        current_prompt_key = self.gangKey
        show_prompt_for(self.gangKey)
    end
    function near:onExit()
        if current_prompt_key == self.gangKey then current_prompt_key = nil end
        SendNUIMessage({ action = 'prompt:hide' })
    end
    function near:nearby()
        local playerGangId = get_player_gang_id()
        if not playerGangId then return end

        if IsControlJustReleased(0, 38) then
            if playerGangId == self.gangKey then
                open_hoods_ui()
            else
                if start_rob_attempt then start_rob_attempt(self.gangKey) end
            end
            return
        end

        if IsControlJustReleased(0, 74) and playerGangId ~= self.gangKey then
            if is_gang_kos and is_gang_kos(self.gangKey) then
                TriggerServerEvent('elder_gangs:server:kos:call', self.gangKey)
            end
        end
    end
    near_points[key] = near
end

local function teardown_zone_for(gangId)
    if not gangId then return end
    local key = tostring(gangId)
    if current_prompt_key == key then
        current_prompt_key = nil
        SendNUIMessage({ action = 'prompt:hide' })
    end
    despawn_dealer(key)
    if far_points[key]  then far_points[key]:remove();  far_points[key]  = nil end
    if near_points[key] then near_points[key]:remove(); near_points[key] = nil end
end

local function spawn_all_zones()
    if not client.datastore or not client.datastore.gangs.loaded then return end
    for _, gang in pairs(client.datastore.gangs.data) do
        if gang.active then spawn_zone_for(gang) end
    end
end

PedsSpawnZoneFor = spawn_zone_for
PedsTeardownZoneFor = teardown_zone_for

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
    for key in pairs(peds) do despawn_dealer(key) end
    for key, p in pairs(far_points)  do p:remove(); far_points[key]  = nil end
    for key, p in pairs(near_points) do p:remove(); near_points[key] = nil end
    SendNUIMessage({ action = 'prompt:hide' })
end)
