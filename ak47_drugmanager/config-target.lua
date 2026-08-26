Config.UseTarget = false -- enable if you are using qtarget

if Config.UseTarget then
    local registeredTargets = {}

    function registerCollect(data)
        local target = exports['qtarget']:AddCircleZone(data.item_label, data.pos, tonumber(data.size / 2), {
            name = data.pos.x..'x'..data.pos.y,
            debugPoly = false,
            minZ = 5.0,
            maxZ = 5.0
        }, {
            options = {
                {
                    event = "ak47_drugmanager:startCollect",
                    icon = "fas fa-flask",
                    label = "Collect "..data.item_label,
                    lab = data,
                },
            },
            distance = tonumber(data.size / 2)
        })
        table.insert(registeredTargets, target.name)
    end

    function registerProcess(data)
        local target = exports['qtarget']:AddCircleZone(data.item_label, data.pos, tonumber(data.size / 2), {
            name = data.pos.x..'x'..data.pos.y,
            debugPoly = false,
            minZ = 5.0,
            maxZ = 5.0
        }, {
            options = {
                {
                    event = "ak47_drugmanager:startProcess",
                    icon = "fas fa-flask",
                    label = "Process "..data.item_label,
                    lab = data,
                },
            },
            distance = tonumber(data.size / 2)
        })
        table.insert(registeredTargets, target.name)
    end

    RegisterNetEvent('ak47_drugmanager:startCollect', function(data)
       startCollect(data.lab)
    end)

    RegisterNetEvent('ak47_drugmanager:startProcess', function(data)
        startProcess(data.lab)
    end)

    AddEventHandler('onResourceStop', function(resource)
        if resource == GetCurrentResourceName() then
            for k, v in pairs(registeredTargets) do
                exports['qtarget']:RemoveZone(v)
            end
        end
    end)
end