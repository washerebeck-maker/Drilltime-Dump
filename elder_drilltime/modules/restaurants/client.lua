
local Busy = false
local NPC = {}
local InDelay = false

local function ShowUI(text)
    lib.showTextUI(text, {
        position = "right-center",
        icon = 'fa-utensils',
    })
end

local function PlayCraftAnim(h)
	local playerPed = PlayerPedId()
    SetEntityHeading(playerPed, h)
    TaskStartScenarioInPlace(playerPed, "PROP_HUMAN_BBQ", 0, true)
    FreezeEntityPosition(playerPed, true)
	Citizen.Wait(7500)
    FreezeEntityPosition(playerPed, false)
	ClearPedTasksImmediately(playerPed)
end

local function Craft(id, craft_id)
    local menuOptions = {} 
    local craft = Config.Restaurants[id].craft.recipes[craft_id]
    for k,v in ipairs(craft.ingredients) do 
        table.insert(menuOptions, {title = GetItemLabel(v.item), readOnly = true, description = 'x'.. v.count .. ' '.. GetItemLabel(v.item) , arrow = true, icon = Config.ImagesPath .. v.item .. '.png', onSelect = function() Collect(id, v.item, v.count) end })
    end 
    table.insert(menuOptions, {title = 'Prepare', iconColor = 'gold', arrow = true, icon = 'fa-circle-check' , onSelect = function() CraftProcess(id, craft_id) end})
    table.insert(menuOptions, {title = 'Cancel' , iconColor = 'red', arrow = true, icon = 'fa-circle-xmark' , onSelect = function() CraftMenu(id) end})         
    
    lib.registerContext({
        id = 'rest_craft_ex_menu',
        title = 'Prepare x'.. craft.count ..' of ' .. GetItemLabel(craft.item),
        options = menuOptions,
    })
    lib.showContext('rest_craft_ex_menu')
end

function CraftMenu(id)
    local menuOptions = {}  
    for k,v in ipairs(Config.Restaurants[id].craft.recipes) do 
        table.insert(menuOptions, {title = GetItemLabel(v.item), description = 'Craft x'.. v.count .. ' '.. GetItemLabel(v.item) , arrow = true, icon = Config.ImagesPath .. v.item .. '.png', onSelect = function() Craft(id, k) end })
    end            
    
    lib.registerContext({
        id = 'rest_craft_menu',
        title = '🍟 Restaurant 🍟',
        options = menuOptions,
    })
    lib.showContext('rest_craft_menu')
end

function CraftProcess(id, craft_id)
    ESX.TriggerServerCallback('elder_drilltime:restaurants:server:check_craft', function(can_craft)
        if can_craft then
            Busy = true
            PlayCraftAnim(Config.Restaurants[id].craft.coords.w)
            Wait(1000)
            TriggerServerEvent('elder_drilltime:restaurants:server:on_craft', id, craft_id)
            Busy = false
        else
            Notify('You dont have enough ingredients.', 'error')
        end
    end, id, craft_id)
end

Citizen.CreateThread(function()
    for k,v in pairs(Config.Restaurants) do 
        if v.blip.enable then
            local blip = AddBlipForCoord(v.coords)
            SetBlipSprite(blip, v.blip.sprite)
            SetBlipDisplay(blip, 4)
            SetBlipScale(blip, v.blip.scale)
            SetBlipColour(blip, v.blip.colour)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(v.blip.name)
            EndTextCommandSetBlipName(blip)
        end
    end
end)

Citizen.CreateThread(function()
    for k,v in pairs(Config.Restaurants) do
        ESX.Streaming.RequestModel("s_m_y_waiter_01")
        NPC[k] = CreatePed(5, GetHashKey("s_m_y_waiter_01"), v.waiter.x, v.waiter.y, v.waiter.z-1, v.waiter.w, false, true)
        PlaceObjectOnGroundProperly(NPC[k])
        --TaskStartScenarioInPlace(NPC[k], "WORLD_HUMAN_CLIPBOARD", 0, true)
        FreezeEntityPosition(NPC[k], true)
        SetEntityInvincible(NPC[k], true)
        SetBlockingOfNonTemporaryEvents(NPC[k], true)
    end
end)

Citizen.CreateThread(function()
    while not PlayerJob do Wait(10) end
    local markerTextUi = false
    while true do
        local sleep = 5000
        for k,v in pairs(Config.Restaurants) do 
            if k == PlayerJob.name then
                sleep = 1000
                if GetDistanceBetweenCoords(cache.coords, v.craft.coords) <= 1.0 then
                    sleep = 1
                    if not markerTextUi and not Busy then
                        ShowUI('[E] to prepare food')
                        markerTextUi = true
                    end
                    if IsControlJustPressed(0, 38) and not Busy then
                        lib.hideTextUI()
                        markerTextUi = false
                        CraftMenu(k)
                    end
                else
                    if markerTextUi then
                        markerTextUi = false
                        lib.hideTextUI()
                    end
                end
            end
        end
        Wait(sleep)
    end
end)

Citizen.CreateThread(function()
    while not PlayerJob do Wait(10) end
    local markerTextUi = false
    while true do
        local sleep = 5000
        for k,v in pairs(Config.Restaurants) do 
            if k == PlayerJob.name and PlayerJob.grade_name == 'boss' then
                sleep = 1000
                local distance = GetDistanceBetweenCoords(cache.coords, v.boss)
                if distance <= 10.0 then
                    sleep = 1
                    DrawMarker(21, v.boss.x,v.boss.y,v.boss.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 0.5, 0.5, 0.5, 0, 0, 255, 255, false, true, 2, true, false, false, false)
                end
                if distance <= 1.0 then
                    sleep = 1
                    if not markerTextUi then
                        ShowUI('[E] to open boss menu')
                        markerTextUi = true
                    end
                    if IsControlJustPressed(0, 38) then
                        lib.hideTextUI()
                        markerTextUi = false
                        OpenBossMenu(k)
                    end
                else
                    if markerTextUi then
                        markerTextUi = false
                        lib.hideTextUI()
                    end
                end
            end
        end
        Wait(sleep)
    end
end)

Citizen.CreateThread(function()
    local markerTextUi = false
    while true do
        local sleep = 2000
        for k,v in pairs(Config.Restaurants) do 
            local distance = GetDistanceBetweenCoords(cache.coords, v.menu)
            if distance <= 10.0 then
                sleep = 1
                DrawMarker(21, v.menu.x,v.menu.y,v.menu.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 0.2, 0.2, 0.2, 0, 139, 139, 255, false, true, 2, true, false, false, false)
            end
            if distance <= 1.0 then
                sleep = 1
                if not markerTextUi then
                    ShowUI('[E] to make order')
                    markerTextUi = true
                end
                if IsControlJustPressed(0, 38) then
                    lib.hideTextUI()
                    markerTextUi = false
                    OrderMenu(k)
                end
            else
                if markerTextUi then
                    markerTextUi = false
                    lib.hideTextUI()
                end
            end   
        end
        Wait(sleep)
    end
end)

Citizen.CreateThread(function()
    while not PlayerJob do Wait(10) end
    local markerTextUi = false
    while true do
        local sleep = 5000
        for k,v in pairs(Config.Restaurants) do 
            if k == PlayerJob.name then
                sleep = 1000
                if GetDistanceBetweenCoords(cache.coords, v.waiter) <= 1.0 then
                    sleep = 1
                    if not markerTextUi and not Busy then
                        ShowUI('[E] to view orders')
                        markerTextUi = true
                    end
                    if IsControlJustPressed(0, 38) and not Busy then
                        lib.hideTextUI()
                        markerTextUi = false
                        OrdersMenu(k)
                    end
                else
                    if markerTextUi then
                        markerTextUi = false
                        lib.hideTextUI()
                    end
                end
            end
        end
        Wait(sleep)
    end
end)

function OpenBossMenu()
    TriggerEvent('esx_society:openBossMenu', PlayerJob.name, function(data, menu)
        menu.close()
    end, {wash = false})
end

---------------------------------------------- JOB ORDER MENUU ---------------

function GetOrders(id)
    local result = promise:new()
    ESX.TriggerServerCallback('elder_drilltime:restaurants:server:get_orders', function(data) 
        result:resolve(data)  
    end,id)
    return Citizen.Await(result)
end

function OrdersMenu(id)
    local orders = GetOrders(id)
    local sorted_orders = {}
    local menuOptions = {}
    local no_order = true  
    if not orders then orders = {} end
    for k,v in pairs(orders) do 
        for kk,vv in pairs(v) do 
            if vv.canceled == false then
                sorted_orders[vv.seq] = vv
            end
        end
    end
    for k,v in pairs(sorted_orders) do 
        no_order = false
        table.insert(menuOptions,{title = 'Order #'..v.seq, description = 'Click to see order details',iconColor = v.done and 'green' or 'silver', icon = v.done and 'fa-square-check' or 'fa-spinner', onSelect = function() OpenOrderDetails(id,v) end})
    end
    if no_order then
        table.insert(menuOptions,{title = 'No orders', description = 'There is no new orders',iconColor = 'red', icon = 'fa-circle-exclamation'})
    end
    lib.registerContext({
        id = 'rest_list_order_menu',
        title = '🍟 Restaurant 🍟',
        options = menuOptions,
    })
    lib.showContext('rest_list_order_menu')
end

function OpenOrderDetails(id, order)
    local menuOptions = {}  

    for k,v in pairs(order.data) do 
        if v > 0 then
            table.insert(menuOptions,{title = GetItemLabel(k), description = 'x'..v , icon = Config.ImagesPath..k..'.png'})
        end
    end

    table.insert(menuOptions,{title = 'Price : 💲' .. ESX.Math.GroupDigits(order.price), icon = 'fa-money-check-dollar'})

    if not order.done then
        table.insert(menuOptions,{title = 'Fill Order', icon = 'fa-box-open', onSelect = function() FillOrder(id,order) end})
    end

    lib.registerContext({
        id = 'rest_list_order_det_menu',
        title = '🍟 Restaurant 🍟',
        canClose = false,
        menu = 'rest_list_order_menu',
        options = menuOptions
    })
    lib.showContext('rest_list_order_det_menu')
end

function FillOrder(id, order)
    TriggerServerEvent('elder_drilltime:restaurants:server:fill_order', id, order.seq, order.identifier)
end

--------------------------------------------- ORDER MENU ----------------------------

CurrentCart = {}

function OrderMenu(id)
    local menuOptions = {}  
    table.insert(menuOptions, {title = 'New Order', description = '' , arrow = true, icon = 'fa-pizza-slice', onSelect = function() NewOrder(id) end })
    table.insert(menuOptions, {title = 'My Orders', description = '' , arrow = true, icon = 'fa-list-check', onSelect = function() MyOrders(id) end })
    lib.registerContext({
        id = 'rest_order_menu',
        title = '🍟 Restaurant 🍟',
        options = menuOptions,
        onExit = function() CurrentCart = {} end
    })
    lib.showContext('rest_order_menu')
end

function NewOrder(id)
    local menuOptions = {}  
    table.insert(menuOptions,{title = 'Restaurant Menu', description = 'List of food & drinks', icon = 'fa-pizza-slice', onSelect = function() OpenFoodMenu(id) end})
    table.insert(menuOptions,{title = 'Cart', description = 'Check out your cart', icon = 'fa-cart-shopping', onSelect = function() OpenCart(id) end})
    lib.registerContext({
        id = 'rest_new_order_menu',
        title = '🍟 Restaurant 🍟',
        canClose = false,
        menu = 'rest_order_menu',
        options = menuOptions
    })
    lib.showContext('rest_new_order_menu')
end

function OpenFoodMenu(id)
    local menuOptions = {}  
    for k,v in pairs(Config.Restaurants[id].prices) do
        table.insert(menuOptions,{title = GetItemLabel(k), description = 'price : 💲' .. ESX.Math.GroupDigits(v), icon = Config.ImagesPath..k..'.png', onSelect = function() AddToCart(id,k) end})
    end
    lib.registerContext({
        id = 'rest_food_order_menu',
        title = '🍟 Restaurant 🍟',
        canClose = false,
        menu = 'rest_new_order_menu',
        options = menuOptions
    })
    lib.showContext('rest_food_order_menu')
end

function AddToCart(id,item)
    Notify('Added to cart', 'success')
    if not CurrentCart[item] then 
        CurrentCart[item] = 1 
    else
        CurrentCart[item] = CurrentCart[item] + 1 
    end
    OpenFoodMenu(id)
end

function RemoveFromCart(id,item)
    Notify('removed from cart', 'success')
    if CurrentCart[item] and CurrentCart[item] > 0 then
        CurrentCart[item] = CurrentCart[item] - 1
    end
    OpenCart(id)
end

function ClearCart(id)
    CurrentCart = {}
    Notify('cart cleared.', 'success')
    OpenCart(id)
end

function OpenCart(id)
    local menuOptions = {}  
    local total_price = GetTotalPrice(id)
    for k,v in pairs(CurrentCart) do
        if v > 0 then
            table.insert(menuOptions,{title = GetItemLabel(k), description = 'x'..v .. ' in cart', icon = Config.ImagesPath..k..'.png', onSelect = function() RemoveFromCart(id,k) end})
        end
    end
    if total_price > 0 then
        table.insert(menuOptions,{title = 'Pay $' .. ESX.Math.GroupDigits(total_price), description = 'Pay cash or bank', icon = 'fa-hand-holding-dollar', onSelect = function() Pay(id) end})
        table.insert(menuOptions,{title = 'Clear cart', description = 'remove all foods in your cart', iconColor = 'red',  icon = 'fa-trash', onSelect = function() ClearCart(id) end})
    else
        table.insert(menuOptions,{title = 'Cart is empty', description = 'add your food & drink from the menu', iconColor = 'red',  icon = 'fa-circle-exclamation'})
    end

    lib.registerContext({
        id = 'rest_cart_order_menu',
        title = '🍟 Restaurant 🍟',
        canClose = false,
        menu = 'rest_new_order_menu',
        options = menuOptions
    })
    lib.showContext('rest_cart_order_menu')
end

function Pay(id)
    local total_price = GetTotalPrice(id)
    local alert = lib.alertDialog({
        header = 'Are you sure you want to sumbit payment for below order',
        content = 'Price : '.. ESX.Math.GroupDigits(total_price),
        centered = true,
        cancel = true,
        labels = {
            cancel=  "Pay",
            confirm=  "Decline",
        }
    })

    if alert == 'cancel' then
        TriggerServerEvent('elder_drilltime:restaurants:server:pay_order',id, total_price, CurrentCart)
    else
        Notify('order canceled')
    end
    CurrentCart = {}
end

function GetTotalPrice(id)
    local price = 0
    for k,v in pairs(CurrentCart) do
        price = price + (v * Config.Restaurants[id].prices[k])
    end
    return price
end

function GetMyOrders(id)
    local result = promise:new()
    ESX.TriggerServerCallback('elder_drilltime:restaurants:server:my_orders', function(data) 
        result:resolve(data)  
    end,id)
    return Citizen.Await(result)
end

function MyOrders(id)
    local orders = GetMyOrders(id)
    local menuOptions = {} 
    local no_order = true

    if not orders then orders = {} end
    
    for k,v in pairs(orders) do 
        if v.canceled == false then
            no_order = false
            table.insert(menuOptions,{title = 'Order #'..v.seq, description = 'Click to see order details',iconColor = v.done and 'green' or 'silver', icon = v.done and 'fa-square-check' or 'fa-spinner', onSelect = function() OpenMyOrderDetails(id,v) end})
        end
    end


    if no_order then
        table.insert(menuOptions,{title = 'No orders', description = 'You dont have any order',iconColor = 'red', icon = 'fa-circle-exclamation'})
    end

    lib.registerContext({
        id = 'rest_my_order_menu',
        title = '🍟 Restaurant 🍟',
        canClose = false,
        menu = 'rest_order_menu',
        options = menuOptions
    })
    lib.showContext('rest_my_order_menu')
end

function OpenMyOrderDetails(id, order)
    local menuOptions = {}  

    for k,v in pairs(order.data) do 
        if v > 0 then
            table.insert(menuOptions,{title = GetItemLabel(k), description = 'x'..v , icon = Config.ImagesPath..k..'.png'})
        end
    end

    table.insert(menuOptions,{title = 'Price : 💲' .. ESX.Math.GroupDigits(order.price), icon = 'fa-money-check-dollar'})

    if order.done then
        table.insert(menuOptions,{title = 'Collect Order', icon = 'fa-hand-holding', onSelect = function() CollectOrder(id,order) end})
    else
        table.insert(menuOptions,{title = 'Cancel Order', icon = 'fa-hand-holding-dollar', onSelect = function() CancelOrder(id,order) end})
    end

    lib.registerContext({
        id = 'rest_my_order_det_menu',
        title = '🍟 Restaurant 🍟',
        canClose = false,
        menu = 'rest_my_order_menu',
        options = menuOptions
    })
    lib.showContext('rest_my_order_det_menu')
end

function CollectOrder(id, order)
    TriggerServerEvent('elder_drilltime:restaurants:server:collect_order', id, order.seq, order.identifier)
end

function CancelOrder(id, order)
    local alert = lib.alertDialog({
        header = 'Are you sure you want to cancel order? 5% will be removed from price',
        content = 'Price : $'.. ESX.Math.GroupDigits(order.price) .. ' , Refund : $' .. ESX.Math.GroupDigits(order.price * 0.95),
        centered = true,
        cancel = true,
        labels = {
            cancel=  "Cancel Order",
            confirm=  "Keep Order",
        }
    })

    if alert == 'cancel' then
        TriggerServerEvent('elder_drilltime:restaurants:server:cancel_order', id, order.seq, order.identifier)
    end
end

--------------------------------------------- JOB MENU --------------------------------------------

local function Sell(item, count, job)
    if count == 0 then
        Notify('You dont have enought quantity of ' .. GetItemLabel(item), 'error')
        return
    end
    local player = lib.getClosestPlayer(cache.coords, 2.0, false)
    --local player = NetworkGetPlayerIndexFromPed(cache.ped)
    if not player then
        Notify('There appears to be no one around', 'error')
    else
        local input = lib.inputDialog('Quantity', {
            { type = 'number', label = 'Qty', min = 1, max = 100, description = 'Quantity of food', required = true }
        }, { allowCancel = true })
        if not input then return end
        if not input[1] or not tonumber(input[1]) or tonumber(input[1]) <= 0 then 
            return
        end
        if tonumber(input[1]) > count then 
            Notify('You dont have enought quantity of ' .. GetItemLabel(item), 'error')
            return
        end
        TriggerServerEvent('elder_drilltime:restaurants:server:sell_food', GetPlayerServerId(player), item, tonumber(input[1]), job)
    end
end

local function RestaurantMenu()
    ExecuteCommand('e foodtrayj')
    local menuOptions = {}  
    for k,v in ipairs(Config.Restaurants[PlayerJob.name].craft.recipes) do 
        local count = exports.ox_inventory:Search('count', v.item)
        table.insert(menuOptions, {title = GetItemLabel(v.item) .. ' x'..count, description = 'Sell '.. GetItemLabel(v.item) .. ' to nearby player.', arrow = true, icon = Config.ImagesPath .. v.item .. '.png', onSelect = function() Sell(v.item, count, PlayerJob.name) end })
    end            
    
    lib.registerContext({
        id = 'rest_job_menu',
        title = '🍟 Restaurant 🍟',
        options = menuOptions,
    })
    lib.showContext('rest_job_menu')
end

local function IsRestaurantJob(job)
    for k,v in pairs(Config.Restaurants) do 
        if k == job then return true end
    end
    return false
end

RegisterCommand('RestaurantJobMenu', function()
    if not PlayerJob or not IsRestaurantJob(PlayerJob.name) then return end
    RestaurantMenu()
end)

RegisterKeyMapping('RestaurantJobMenu', 'Restaurant Menu', 'keyboard', 'F6')


RegisterNetEvent('elder_drilltime:restaurants:server:sell_food_request')
AddEventHandler('elder_drilltime:restaurants:server:sell_food_request', function(waiter, item, count, job)
    local alert = lib.alertDialog({
        header = 'You have asked for x' .. count .. ' ' .. GetItemLabel(item),
        content = 'Price : '.. ESX.Math.GroupDigits(count * Config.Restaurants[job].prices[item]),
        centered = true,
        cancel = true,
        labels = {
            cancel=  "Pay",
            confirm=  "Decline",
        }
    })

    if alert == 'cancel' then
        TriggerServerEvent('elder_drilltime:restaurants:server:pay', waiter, item, count, Config.Restaurants[job].prices[item])
    else
        TriggerServerEvent('elder_drilltime:restaurants:server:cancel', waiter)
    end
end)

RegisterNetEvent('elder_drilltime:restaurants:server:onNewOrder')
AddEventHandler('elder_drilltime:restaurants:server:onNewOrder', function(id)
    if PlayerJob and PlayerJob.name == id then
        Notify('You have received new order !')
    end
end)


Citizen.CreateThread(function()
    local markerTextUi = false
    while true do
        local sleep = 2000
        for k,v in pairs(Config.Restaurants) do 
            if PlayerJob and k == PlayerJob.name then
                local distance = GetDistanceBetweenCoords(cache.coords, v.auto_orders.coords)
                if distance <= 10.0 then
                    sleep = 1
                    DrawMarker(21, v.auto_orders.coords.x,v.auto_orders.coords.y,v.auto_orders.coords.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 0.2, 0.2, 0.2, 0, 139, 139, 255, false, true, 2, true, false, false, false)
                end
                if distance <= 1.0 then
                    sleep = 1
                    if not markerTextUi then
                        ShowUI('[E] to check orders')
                        markerTextUi = true
                    end
                    if IsControlJustPressed(0, 38) then
                        if not InDelay then
                            lib.hideTextUI()
                            markerTextUi = false
                            AutoOrderMenu()
                        else
                            Notify('You have no orders for now', 'error')
                        end
                    end
                else
                    if markerTextUi then
                        markerTextUi = false
                        lib.hideTextUI()
                    end
                end
            end  
        end
        Wait(sleep)
    end
end)

function AutoOrderMenu()
    local orders = GetAutoOrders()
    local menuOptions = {}  
    if orders and next(orders) then 
        for k,v in ipairs(orders) do 
            if not v.done then
                table.insert(menuOptions,{
                    title = 'Order #'..k, 
                    description = 'Click to see order details',
                    iconColor = v.done and 'green' or 'silver', 
                    icon = v.done and 'fa-square-check' or 'fa-spinner', 
                    onSelect = function() OpenAutoOrderDetails(k,v) end,
                })
                break
            end
        end
    end
    
    lib.registerContext({
        id = 'auto_orders_menu',
        title = '🍟 Restaurant 🍟',
        options = menuOptions,
    })
    lib.showContext('auto_orders_menu')
end

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    Wait(2000)
    LoadAutoOrders()
end)

LoadAutoOrders = function()
    TriggerServerEvent('elder_drilltime:restaurants:server:loadAutoOrders')
end

function GetAutoOrders()
    local result = promise:new()
    ESX.TriggerServerCallback('elder_drilltime:restaurants:server:getAutoOrders', function(data) 
        result:resolve(data)  
    end,id)
    return Citizen.Await(result)
end

function OpenAutoOrderDetails(order_id,order)
    local menuOptions = {}  

    for k,v in pairs(order.data) do  
        table.insert(menuOptions,{title = GetItemLabel(v.item), description = 'x'..v.count , icon = Config.ImagesPath..v.item..'.png'}) 
    end

    table.insert(menuOptions,{title = 'Price : 💲' .. ESX.Math.GroupDigits(order.price), icon = 'fa-money-check-dollar'})

    if not order.done then
        table.insert(menuOptions,{title = 'Fill Order', icon = 'fa-box-open', onSelect = function() FillAutoOrder(order_id) end})
    end

    lib.registerContext({
        id = 'rest_list_auto_order_det_menu',
        title = '🍟 Restaurant 🍟',
        canClose = false,
        menu = 'auto_orders_menu',
        options = menuOptions
    })
    lib.showContext('rest_list_auto_order_det_menu')
end

function FillAutoOrder(order_id)
    ESX.TriggerServerCallback('elder_drilltime:restaurants:server:fillAutoOrder', function(result)
        if result then
            InDelay = true
            local delay = math.random(Config.Restaurants[PlayerJob.name].auto_orders.delay.min, Config.Restaurants[PlayerJob.name].auto_orders.delay.max)
            Wait(delay * 1000)
            InDelay = false
            TriggerEvent('InteractSound_CL:PlayOnOne', 'uwu', 1.0)
            Notify('New order has arrived!')
        end
    end, order_id)
end

local Spawned = {}

CreateThread(function()
    for k,v in pairs(Config.Restaurants) do 
        local point = lib.points.new({ coords = v.coords, distance = 50.0})
        function point:onEnter()
            if not Spawned[k] then
                Spawned[k] = true
                SpawnCATS(k)
            end
        end   
    end
end)

function SpawnCATS(id)
    local restaurant = Config.Restaurants[id]
    for key, value in pairs(restaurant.cats) do
        local hash = GetHashKey('a_c_cat_01')
        RequestModel(hash)
        while not HasModelLoaded(hash) do
            Citizen.Wait(10)
        end
        if value.sitting  == true then
            local ped = CreatePed(28, hash, value.coords.x, value.coords.y, value.coords.z - 0.9, value.coords.w, false, true)
            DoRequestAnimSet('creatures@cat@amb@world_cat_sleeping_ground@idle_a')
            TaskPlayAnim(ped, 'creatures@cat@amb@world_cat_sleeping_ground@idle_a', 'idle_a' ,8.0, -8, -1, 1, 0, false, false, false)
            SetPedCanBeTargetted(ped, false)
            SetEntityAsMissionEntity(ped, true,true)
            SetBlockingOfNonTemporaryEvents(ped, true)
            FreezeEntityPosition(ped, true)
            SetEntityInvincible(ped, true)
        else
            local ped = CreatePed(0, hash, value.coords.x, value.coords.y, value.coords.z - 1.0, value.coords.w, false, true)
            SetPedCanBeTargetted(ped, false)
            SetEntityAsMissionEntity(ped, true,true)
            SetEntityInvincible(ped, true)
            SetBlockingOfNonTemporaryEvents(ped, true)
            FreezeEntityPosition(ped, true)
            CreateThread(function()
                DoRequestAnimSet('creatures@cat@player_action@')
                DoRequestAnimSet('creatures@cat@move')
                while true do 
                    Wait(5000)
                    TaskPlayAnim(ped, 'creatures@cat@player_action@', 'action_a' ,8.0, -8, -1, 1, 0, false, false, false)
                    Wait(3000)
                    TaskPlayAnim(ped, 'creatures@cat@move', 'idle_turn_r' ,8.0, -8, -1, 1, 0, false, false, false)
                    Wait(2000)
                    ClearPedTasksImmediately(ped)
                end
            end)
        end
    end
end

function DoRequestAnimSet(anim)
	RequestAnimDict(anim)
	while not HasAnimDictLoaded(anim) do
		Citizen.Wait(1)
	end
end
