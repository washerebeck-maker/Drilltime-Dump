exports('laptop_use', function(data, slot) 
    TriggerServerEvent('scamming:server:laptop', data, slot)
end)

RegisterNUICallback('darkweb/items', function(data, cb)
    local items = {}
    
    for name, item in pairs(Config.DarkWeb.Items) do
        local itemLabel = getItemLabel(item.name)
        local itemImage = item.image
        if not itemImage then
            itemImage = 'nui://ox_inventory/web/images/' .. item.name .. '.png'
        elseif not string.find(itemImage, 'nui://') then
            itemImage = 'nui://' .. itemImage
        end
        
        items[#items + 1] = {
            name = item.name,
            label = itemLabel,
            image = itemImage,
            price = item.price,
            weeklyStock = item.weeklyStock,
            category = item.category or "hacking", 
        }
    end
    
    cb(items)
end)

RegisterNUICallback('darkweb/weeklyStock', function(data, cb)
    ESX.TriggerServerCallback('scamming:server:getWeeklyStock', function(weeklyStock)
        cb(weeklyStock)
    end)
end)

RegisterNUICallback('laptop/checkout', function(data, cb)
    if not data or not data.cart then
        cb({ status = "error", message = "Invalid cart data" })
        return
    end
    
    ESX.TriggerServerCallback('scamming:server:darkwebCheckout', function(result)
        cb(result)
    end, data.cart)
end)

RegisterNUICallback('getapp', function(data, cb)
    local apps = {
        {
            name = "darkweb",
            icon = "skull",
            text = "Dark Web",
            color = "#fff",
            background = "rgba(0, 0, 0, 0.9)",
            isopen = false,
            useimage = false,
        }
    }
    cb(apps)
end)

function OpenLaptop()
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = "toggle",
        status = true
    })
end

RegisterNetEvent('scamming:client:openLaptop', function()
    OpenLaptop()
end)

RegisterNUICallback('close', function(data, cb)
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = "toggle",
        status = false
    })
    cb('ok')
end)

RegisterNUICallback('loaded', function(data, cb)
    cb('ok')
end)

RegisterNUICallback('setting/get', function(data, cb)
    cb({ status = false, data = {} })
end)

