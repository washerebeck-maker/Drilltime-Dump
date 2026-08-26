client = client or {}
client.datastore = client.datastore or {}
local datastore = client.datastore
local framework = client.framework

datastore.gangs = {data = {}, loaded = false}
datastore.player = {data = nil, loaded = false}


local function gang_key(id_or_gang)
    local id = type(id_or_gang) == 'table' and id_or_gang.id or id_or_gang
    return tonumber(id) or id
end

function datastore.gangs.set_all(map)
    local out = {}
    for k, v in pairs(map or {}) do
        local id = tonumber(k) or (v and v.id and tonumber(v.id))
        if id and v then out[id] = v end
    end
    datastore.gangs.data = out
    datastore.gangs.loaded = true
end

function datastore.gangs.set(gang)
    if not gang or not gang.id then return end
    datastore.gangs.data[gang_key(gang)] = gang
end

function datastore.gangs.remove(id)
    if not id then return end
    datastore.gangs.data[gang_key(id)] = nil
end

function datastore.gangs.load()
    local packed = lib.callback.await('elder_gangs:datastore:get_gangs', false)
    datastore.gangs.set_all(shared.serializer.unpack(packed))

    TriggerEvent('elder_gangs:client:gangs:ready')
    return datastore.gangs.data
end

function datastore.gangs.get(id)
    if not datastore.gangs.loaded then datastore.gangs.load() end
    return datastore.gangs.data[tonumber(id) or 0]
end

function datastore.gangs.get_all()
    if not datastore.gangs.loaded then datastore.gangs.load() end
    local list = {}
    for _, gang in pairs(datastore.gangs.data) do list[#list + 1] = gang end
    table.sort(list, function(a, b) return a.id < b.id end)
    return list
end

function datastore.gangs.invalidate()
    datastore.gangs.loaded = false
    datastore.gangs.data = {}
end

function datastore.player.set(data)
    datastore.player.data = data
    datastore.player.loaded = true
end

function datastore.player.load()
    datastore.player.set({
        identifier = framework.player.get_data()?.identifier,
        gang = lib.callback.await('elder_gangs:player:get_gang', false),
        is_admin = lib.callback.await('elder_gangs:admin:is_admin', false) == true
    })
    return datastore.player.data
end

function datastore.player.get()
    if not datastore.player.loaded then datastore.player.load() end
    return datastore.player.data
end

function datastore.player.invalidate()
    datastore.player.loaded = false
    datastore.player.data = nil
end

function datastore.player.refresh_gang()
    if not datastore.player.loaded or not datastore.player.data then return end
    datastore.player.data.gang = lib.callback.await('elder_gangs:player:get_gang', false)
end

shared.serializer.register_net('elder_gangs:datastore:gangs:create', function(gang)
    if not gang then return end
    datastore.gangs.set(gang)
end)

shared.serializer.register_net('elder_gangs:datastore:gangs:update', function(gang)
    if not gang then return end
    datastore.gangs.set(gang)
    if datastore.player.data?.gang?.id == gang.id then
        datastore.player.refresh_gang()
    end
end)

shared.serializer.register_net('elder_gangs:datastore:gangs:enable', function(gang)
    if not gang then return end
    if datastore.player.loaded and datastore.player.data?.gang == nil then
        datastore.player.refresh_gang()
    end
end)

shared.serializer.register_net('elder_gangs:datastore:gangs:disable', function(gang)
    if not gang then return end

end)

RegisterNetEvent('elder_gangs:player:update', function(old_gang, new_gang)
    if not datastore.player.loaded then return end
    datastore.player.refresh_gang()
end)

RegisterNetEvent('elder_gangs:datastore:gangs:remove', function(id)
    datastore.gangs.remove(id)
    if datastore.player.data?.gang?.id == id then
        datastore.player.data.gang = nil
    end
end)

RegisterNetEvent('esx:playerLoaded', function()
    datastore.gangs.load()
    datastore.player.load()
end)

AddEventHandler('onClientResourceStart', function(res)
    if res ~= GetCurrentResourceName() then return end
    if framework.player.is_loaded() then
        datastore.gangs.load()
        datastore.player.load()
    end
end)
