
--ESX = exports['es_extended']:getSharedObject()
ESX = exports.es_extended:getSharedObject()

local polePoints = {}

local poleProps = {}

local CanAccessNightClub = false

local Gender = nil


CreateThread(function()
	while ESX.GetPlayerData().job == nil do
		Citizen.Wait(10)
	end
	PlayerJob = ESX.GetPlayerData().job
    if PlayerJob.name == Config.Job then
        CanAccessNightClub = true
    end
    TriggerEvent('skinchanger:getSkin', function(skin)
        Gender = skin.sex
    end)
end)

local ClubZone = BoxZone:Create(vector3(-431.8497, 267.2101, 83.4243), 3.0, 3.0, {
    name="box_zone",
    offset={0.0, 0.0, 0.0},
    scale={1.0, 1.0, 1.0},
    debugPoly=false,
})

CreateThread(function()
    local blip = AddBlipForCoord(Config.NightClub)
    SetBlipSprite(blip, 93)
    SetBlipColour(blip, 61)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("LUST CLUB")
    EndTextCommandSetBlipName(blip)
    SetBlipAsShortRange(blip,true)
    SetBlipScale(blip, 1.0)
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function()
    Wait(3000)
    while not PlayerJob do Wait(10) end
    if PlayerJob.name == Config.Job then
        CanAccessNightClub = true
        CreateTargets()
    end

    TriggerEvent('skinchanger:getSkin', function(skin)
        Gender = skin.sex
    end)

end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)  
    PlayerJob = job
    if PlayerJob.name == Config.Job then
        CanAccessNightClub = true
        CreateTargets()
    else
        DestroyTargets()
    end
end)

lib.registerContext({
    id = 'dance_menu',
    title = 'Select Your Dance',
    options = {
        { title = 'Dance Options' }, 
    {
        title = 'Pole Dance #1',
        icon = 'shoe-prints',
        event = 'bm_dance:start',
        args = { dance = 1 }
    }, {
        title = 'Pole Dance #2',
        icon = 'shoe-prints',
        event = 'bm_dance:start',
        args = { dance = 2 }
    }, {
        title = 'Pole Dance #3',
        icon = 'shoe-prints',
        event = 'bm_dance:start',
        args = { dance = 3 }
    }, {
        title = 'Lap Dance #1',
        icon = 'shoe-prints',
        event = 'bm_dance:start',
        args = {
            lapdance = 1,
            anim = 'lap_dance_girl',
            dict = 'mp_safehouse'
        }
    }, {
        title = 'Lap Dance #2',
        icon = 'shoe-prints',
        event = 'bm_dance:start',
        args = {
            lapdance = 2,
            anim = 'priv_dance_idle',
            dict = 'mini@strip_club@private_dance@idle'
        }
    }, {
        title = 'Lap Dance #3',
        icon = 'shoe-prints',
        event = 'bm_dance:start',
        args = {
            lapdance = 3,
            anim = 'priv_dance_p1',
            dict = 'mini@strip_club@private_dance@part1'
        }
    }, {
        title = 'Lap Dance #4',
        icon = 'shoe-prints',
        event = 'bm_dance:start',
        args = {
            lapdance = 4,
            anim = 'priv_dance_p2',
            dict = 'mini@strip_club@private_dance@part2'
        }
    }, {
        title = 'Lap Dance #5',
        icon = 'shoe-prints',
        event = 'bm_dance:start',
        args = {
            lapdance = 5,
            anim = 'priv_dance_p3',
            dict = 'mini@strip_club@private_dance@part3'
        }
    }, {
        title = 'Lap Dance #6',
        icon = 'shoe-prints',
        event = 'bm_dance:start',
        args = {
            lapdance = 6,
            anim = 'yacht_ld_f',
            dict = 'oddjobs@assassinate@multi@yachttarget@lapdance'
        }
    }
    }
})

CreateThread(function()
    while not PlayerJob do Wait(10) end
    if PlayerJob.name == Config.Job  then
        for _, v in ipairs(Config.Poles) do
            local polePoints = lib.points.new({
                coords = v.position,
                distance = 3.0,
            })
            polePoints[#polePoints + 1] = v
        end
    end
end)

function CreateTargets()
    DestroyTargets()
    for k, v in pairs(Config.Poles) do
        if v.spawn then
            lib.requestModel('prop_strip_pole_01')
           local pole = CreateObject(joaat('prop_strip_pole_01'), v.position.x, v.position.y, v.position.z, false, false,
                false)
            poleProps[#poleProps + 1] = pole
        end
        local params = {
            coords = vec3(v.position.x, v.position.y, v.position.z + 1.0),
            size = vec3(1, 1, 1),
            rotation = v.position.w,
            onEnter = function()
                lib.showTextUI('Press [E] to dance')
            end,
            inside = function()
                if IsEntityPlayingAnim(cache.ped, 'mini@strip_club@pole_dance@pole_dance1', 'pd_dance_01', 3) or IsEntityPlayingAnim(cache.ped, 'mini@strip_club@pole_dance@pole_dance2', 'pd_dance_02', 3) or IsEntityPlayingAnim(cache.ped, 'mini@strip_club@pole_dance@pole_dance3', 'pd_dance_03', 3) then
                    lib.hideTextUI()
                    lib.showTextUI('Press [X] to stop dancing')
                    if IsControlJustPressed(0, 73) then
                        ClearPedTasks(cache.ped)
                        lib.hideTextUI()
                    end
                end
                if IsControlJustReleased(0, 38) then
                    lib.showContext('dance_menu')
                end
            end,
            onExit = function()
                lib.hideTextUI()
            end,
            debug = false,
        }
        local poleZone = lib.zones.box(params)
        polePoints[#polePoints + 1] = poleZone
    end
end

function DestroyTargets()
    lib.hideTextUI()
    for i = 1, #polePoints do
        local pole = polePoints[i]
        pole:remove()
    end
    for i = 1, #poleProps do
        local pole = poleProps[i]
        if DoesEntityExist(pole) then
            DeleteObject(pole)
            DeleteEntity(pole)
        end
    end
end

RegisterNetEvent('bm_dance:start', function(args)
    local position = GetEntityCoords(cache.ped)
    local usePolePosition = false
    if not args.coords then args.coords = position end
    if false and args.dance then
        local nearbyObjects = lib.getNearbyObjects(args.coords, 1.5)
        if #nearbyObjects > 0 then
            local closestObject = nearbyObjects[1]
            local scene = NetworkCreateSynchronisedScene(closestObject.coords.x + 0.07, closestObject.coords.y + 0.3,
                closestObject.coords.z + 1.15, 0.0, 0.0, 0.0, 2, false, true, 1065353216, 0, 1.3)
            NetworkAddPedToSynchronisedScene(cache.ped, scene, 'mini@strip_club@pole_dance@pole_dance' .. args.dance,
                'pd_dance_0' .. args.dance, 1.5, -4.0, 1, 1, 1148846080, 0)
            NetworkStartSynchronisedScene(scene)
        else

            usePolePosition = true
        end
    elseif args.lapdance then
        lib.requestAnimDict(args.dict)
        TaskPlayAnim(cache.ped, args.dict, args.anim, 1.0, 1.0, -1, 1, 0, 0, 0, 0)
    else
        for _, point in ipairs(polePoints) do
            local distance = #(point.coords - GetEntityCoords(cache.ped))
            if distance <= point.distance then
                usePolePosition = true
                break
            end
        end
    end
    if usePolePosition then
        local closestPoint = lib.points.getClosestPoint()
        if closestPoint then
            args.coords = closestPoint.coords
            local scene = NetworkCreateSynchronisedScene(args.coords.x + 0.07, args.coords.y + 0.3,
            args.coords.z + 1.15, 0.0, 0.0, 0.0, 2, false, true, 1065353216, 0, 1.3)
            NetworkAddPedToSynchronisedScene(cache.ped, scene, 'mini@strip_club@pole_dance@pole_dance' .. args.dance,
                'pd_dance_0' .. args.dance, 1.5, -4.0, 1, 1, 1148846080, 0)
            NetworkStartSynchronisedScene(scene)
        end
    end
end)



openJobMenu = function()
    if not PlayerJob or PlayerJob.name ~= Config.Job then return end
    local Options = {}

    Options[#Options + 1] = {
        title = 'Lap dance',
        description = '',
        icon = 'fa-heart',
        iconColor = 'red',
        arrow = true,
        event = 'elder_poledance:client:lap_dance',
    }
    Options[#Options + 1] = {
        title = 'More than a lapdance',
        description = '',
        icon = 'fa-heart',
        iconColor = 'red',
        arrow = true,
        event = 'elder_poledance:client:sex',
    }
    Options[#Options + 1] = {
        title = 'Tips',
        description = '',
        icon = 'fa-hand-holding-dollar',
        iconColor = 'green',
        arrow = true,
        event = 'elder_poledance:client:tips',
    }
    Options[#Options + 1] = {
        title = 'Drink service',
        description = '',
        icon = 'fa-martini-glass-citrus',
        iconColor = 'purple',
        arrow = true,
        event = 'elder_poledance:client:drink',
    }
    Options[#Options + 1] = {
        title = 'Get free ticket',
        description = 'Get a free ticket to enter the club',
        icon = 'fa-ticket',
        iconColor = 'gold',
        arrow = true,
        event = 'elder_poledance:client:ticket',
    }
   
    lib.registerContext({
        id = 'nc_job_menu',
        title = 'Night Club',
        options = Options
    })
    lib.showContext('nc_job_menu')
end


-------------------------------------- LAP DANCE ----------------------------------

RegisterNetEvent('elder_poledance:client:lap_dance')
AddEventHandler('elder_poledance:client:lap_dance', function()
    local coords = GetEntityCoords(cache.ped)
    local player = lib.getClosestPlayer(vec3(coords.x, coords.y, coords.z), 2.0, false)
    --local player = NetworkGetPlayerIndexFromPed(cache.ped)
    if not player then
        TriggerEvent('elder_poledance:notify', 'No One Found', 'There appears to be no one around', 'error')
    else
        TriggerServerEvent('elder_poledance:server:lap_dance', GetPlayerServerId(player))
    end
end)

RegisterNetEvent('elder_poledance:client:lap_dance_request')
AddEventHandler('elder_poledance:client:lap_dance_request', function(stripper)
    local alert = lib.alertDialog({
        header = 'You have asked for a lap dance in our night club',
        content = 'Price : '.. ESX.Math.GroupDigits(Config.LapDancePrice),
        centered = true,
        cancel = true,
        labels = {
            cancel=  "Pay",
            confirm=  "Decline",
        }
    })

    if alert == 'cancel' then
        TriggerServerEvent('elder_poledance:server:lap_dance_pay', stripper)
    else
        TriggerServerEvent('elder_poledance:server:lap_dance_cancel', stripper)
    end
end)


------------------------------------------ TIPS ---------------------

RegisterNetEvent('elder_poledance:client:tips')
AddEventHandler('elder_poledance:client:tips', function()
    local coords = GetEntityCoords(cache.ped)
    local player = lib.getClosestPlayer(vec3(coords.x, coords.y, coords.z), 2.0, false)
    --local player = NetworkGetPlayerIndexFromPed(cache.ped)
    if not player then
        TriggerEvent('elder_poledance:notify', 'No One Found', 'There appears to be no one around', 'error')
    else
        TriggerServerEvent('elder_poledance:server:tips', GetPlayerServerId(player))
    end
end)

RegisterNetEvent('elder_poledance:client:tips_request')
AddEventHandler('elder_poledance:client:tips_request', function(stripper)
    local input = lib.inputDialog('Stripper ask for tips', {
        { type = 'number', label = 'Tips', min = 0, max = 1000000, description = 'Give money to the stripper', required = true }
    }, { allowCancel = true })
    if not input then return end
    if not input[1] or not tonumber(input[1]) or tonumber(input[1]) < 0 then 
        TriggerEvent('elder_poledance:notify', 'Night Club', 'Invalid.', 'error')
        return
    end
    TriggerServerEvent('elder_poledance:server:tips_pay', stripper, tonumber(input[1]))
end)



------------------------------------------------ SEX ------------------------------------

RegisterNetEvent('elder_poledance:client:sex')
AddEventHandler('elder_poledance:client:sex', function()
    local coords = GetEntityCoords(cache.ped)
    local player = lib.getClosestPlayer(vec3(coords.x, coords.y, coords.z), 2.0, false)
    --local player = NetworkGetPlayerIndexFromPed(cache.ped)
    if not player then
        TriggerEvent('elder_poledance:notify', 'No One Found', 'There appears to be no one around', 'error')
    else
        TriggerServerEvent('elder_poledance:server:sex', GetPlayerServerId(player))
    end
end)

RegisterNetEvent('elder_poledance:client:sex_request')
AddEventHandler('elder_poledance:client:sex_request', function(stripper)
    local alert = lib.alertDialog({
        header = 'You have asked for more than lap dance in our night club',
        content = 'Price : '.. ESX.Math.GroupDigits(Config.MoreThanLapDancePrice),
        centered = true,
        cancel = true,
        labels = {
            cancel=  "Pay",
            confirm=  "Decline",
        }
    })

    if alert == 'cancel' then
        TriggerServerEvent('elder_poledance:server:sex_pay', stripper)
    else
        TriggerServerEvent('elder_poledance:server:sex_cancel', stripper)
    end
end)


RegisterNetEvent("elder_poledance:viagrasync")
AddEventHandler("elder_poledance:viagrasync",function(stripper)
    
    RequestAnimDict("mp_suicide")
    while not HasAnimDictLoaded("mp_suicide") do
        Citizen.Wait(100)
    end
    TaskPlayAnim(cache.ped, "mp_suicide", "pill_fp", 8.0, 8.0, -1, 50, 0, false, false, false)
    Citizen.Wait(3000)
    ClearPedSecondaryTask(cache.ped)
    TriggerServerEvent("elder_poledance:starteweyan", stripper)
end)


RegisterNetEvent("elder_poledance:gayaeweyan")
AddEventHandler("elder_poledance:gayaeweyan", function(target)
    local playerPed = GetPlayerPed(-1)
    local targetPed = GetPlayerPed(GetPlayerFromServerId(target))
    local pedPos = GetEntityCoords(playerPed, false)
    Citizen.Wait(5000)
    DoScreenFadeOut(5000)
    Citizen.Wait(5000)
    DoScreenFadeIn(5000)
    FreezeEntityPosition(playerPed, true)
    RequestAnimDict("misscarsteal2pimpsex")
    while not HasAnimDictLoaded("misscarsteal2pimpsex") do
        Citizen.Wait(10)
    end
    AttachEntityToEntity(playerPed, targetPed, 9816, 0.0, 0.60, 0.0, 120.0, 0.0, 180.0, 0, 0, 0, 0, 2, 1)
    TaskPlayAnim(playerPed, "misscarsteal2pimpsex", "pimpsex_hooker", 1.0, -1.0, -1, 1, 1, false, false, false)
    Citizen.Wait(15000)
    DoScreenFadeOut(5000)
    Citizen.Wait(5000)
    DoScreenFadeIn(5000)
    DetachEntity(GetPlayerPed(-1), true, false)
    RequestAnimDict("misscarsteal2pimpsex")
    while not HasAnimDictLoaded("misscarsteal2pimpsex") do
        Citizen.Wait(10)
    end
    AttachEntityToEntity(playerPed, targetPed, 9816, 0.05, 0.35, -0.1, 120.0, 0.0, 180.0, 0, 0, 0, 0, 2, 1)
    TaskPlayAnim(playerPed, "misscarsteal2pimpsex", "shagloop_hooker", 1.0, -1.0, -1, 1, 1, false, false, false)
    Citizen.Wait(15000)
    DoScreenFadeOut(5000)
    Citizen.Wait(5000)
    DoScreenFadeIn(5000)
    DetachEntity(GetPlayerPed(-1), true, false)
    RequestAnimDict("rcmpaparazzo_2")
    while not HasAnimDictLoaded("rcmpaparazzo_2") do
        Citizen.Wait(10)
    end
    AttachEntityToEntity(playerPed, targetPed, 9816, 0.015, 0.25, 0.0, 0.9, 0.3, 0.0, 0, 0, 0, 0, 2, 1)
    TaskPlayAnim(playerPed, "rcmpaparazzo_2", "shag_loop_poppy", 1.0, -1.0, -1, 1, 1, false, false, false)
    Citizen.Wait(15000)
    DoScreenFadeOut(5000)
    Citizen.Wait(5000)
    DoScreenFadeIn(5000)
    DetachEntity(playerPed, true, false)
    SetEntityCoords(playerPed, pedPos.x, pedPos.y, pedPos.z - 1.8)
    RequestAnimDict("oddjobs@towing")
    while not HasAnimDictLoaded("oddjobs@towing") do
        Citizen.Wait(10)
    end
    AttachEntityToEntity(playerPed, targetPed, 9816, 0.8, -0.1, -0.1, 0.0, 0.3, 0.0, 0, 0, 0, 0, 2, 1)
    TaskPlayAnim(playerPed, "oddjobs@towing", "f_blow_job_loop", 1.0, -1.0, -1, 1, 1, false, false, false)
    Citizen.Wait(15000)
    DoScreenFadeOut(5000)
    Citizen.Wait(5000)
    DoScreenFadeIn(5000)
    DetachEntity(playerPed, true, false)
    RequestAnimDict("mini@prostitutes@sexlow_veh")
    while not HasAnimDictLoaded("mini@prostitutes@sexlow_veh") do
        Citizen.Wait(10)
    end
    AttachEntityToEntity(playerPed, targetPed, 9816, 0.8, 0.0, 0.0, 0.0, 0.3, 0.0, 0, 0, 0, 0, 2, 1)
    TaskPlayAnim(playerPed,"mini@prostitutes@sexlow_veh","low_car_sex_loop_female",1.0,-1.0,-1,1,1,false,false,false)
    Citizen.Wait(15000)
    DoScreenFadeOut(5000)
    Citizen.Wait(5000)
    DoScreenFadeIn(5000)
    DetachEntity(playerPed, true, false)
    RequestAnimDict("oddjobs@assassinate@vice@sex")
    while not HasAnimDictLoaded("oddjobs@assassinate@vice@sex") do
        Citizen.Wait(10)
    end
    AttachEntityToEntity(playerPed, targetPed, 9816, 0.8, -0.1, 0.0, 0.0, 0.3, 0.0, 0, 0, 0, 0, 2, 1)
    TaskPlayAnim(playerPed,"oddjobs@assassinate@vice@sex","frontseat_carsex_loop_f",1.0,-1.0,-1,1,1,false,false,false)
    Citizen.Wait(15000)
    DoScreenFadeOut(5000)
    Citizen.Wait(5000)
    DoScreenFadeIn(5000)
    DetachEntity(playerPed, true, false)
    RequestAnimDict("random@drunk_driver_2")
    while not HasAnimDictLoaded("random@drunk_driver_2") do
        Citizen.Wait(10)
    end
    AttachEntityToEntity(playerPed, targetPed, 9816, -0.7, 0.0, -0.01, 0.0, 0.3, 0.0, 0, 0, 0, 0, 2, 1)
    TaskPlayAnim(playerPed, "random@drunk_driver_2", "cardrunksex_loop_f", 1.0, -1.0, -1, 1, 1, false, false, false)
    Citizen.Wait(15000)
    DetachEntity(playerPed, true, false)
    FreezeEntityPosition(playerPed, false)
    ClearPedTasks(playerPed)
end)

RegisterNetEvent("elder_poledance:gayaeweyan2")
AddEventHandler("elder_poledance:gayaeweyan2",function()
    local playerPed = GetPlayerPed(-1)
    local pedPos = GetEntityCoords(playerPed, false)
    Citizen.Wait(5000)
    DoScreenFadeOut(5000)
    Citizen.Wait(5000)
    DoScreenFadeIn(5000)
    FreezeEntityPosition(playerPed, true)
    RequestAnimDict("misscarsteal2pimpsex")
    while not HasAnimDictLoaded("misscarsteal2pimpsex") do
        Citizen.Wait(10)
    end
    TaskPlayAnim(playerPed, "misscarsteal2pimpsex", "pimpsex_punter", 1.0, -1.0, -1, 1, 1, false, false, false)
    Citizen.Wait(15000)
    DoScreenFadeOut(5000)
    Citizen.Wait(5000)
    DoScreenFadeIn(5000)
    TaskPlayAnim(playerPed, "misscarsteal2pimpsex", "shagloop_pimp", 1.0, -1.0, -1, 1, 1, false, false, false)
    Citizen.Wait(15000)
    DoScreenFadeOut(5000)
    Citizen.Wait(5000)
    DoScreenFadeIn(5000)
    RequestAnimDict("rcmpaparazzo_2")

    while not HasAnimDictLoaded("rcmpaparazzo_2") do
        Citizen.Wait(10)
    end
    TaskPlayAnim(playerPed, "rcmpaparazzo_2", "shag_loop_a", 1.0, -1.0, -1, 1, 1, false, false, false)
    Citizen.Wait(15000)
    DoScreenFadeOut(5000)
    Citizen.Wait(5000)
    DoScreenFadeIn(5000)
    SetEntityCoords(playerPed, pedPos.x, pedPos.y, pedPos.z - 1.8)
    RequestAnimDict("oddjobs@towing")
    while not HasAnimDictLoaded("oddjobs@towing") do
        Citizen.Wait(10)
    end
    TaskPlayAnim(playerPed, "oddjobs@towing", "m_blow_job_loop", 1.0, -1.0, -1, 1, 1, false, false, false)
    Citizen.Wait(15000)
    DoScreenFadeOut(5000)
    Citizen.Wait(5000)
    DoScreenFadeIn(5000)
    RequestAnimDict("mini@prostitutes@sexlow_veh")

    while not HasAnimDictLoaded("mini@prostitutes@sexlow_veh") do
        Citizen.Wait(10)
    end
    TaskPlayAnim(playerPed,"mini@prostitutes@sexlow_veh","low_car_sex_loop_player",1.0,-1.0,-1,1,1,false,false,false)
    Citizen.Wait(15000)
    DoScreenFadeOut(5000)
    Citizen.Wait(5000)
    DoScreenFadeIn(5000)
    RequestAnimDict("oddjobs@assassinate@vice@sex")
    while not HasAnimDictLoaded("oddjobs@assassinate@vice@sex") do
        Citizen.Wait(10)
    end
    TaskPlayAnim(playerPed,"oddjobs@assassinate@vice@sex","frontseat_carsex_loop_m",1.0,-1.0,-1,1,1,false,false,false)

    Citizen.Wait(15000)
    DoScreenFadeOut(5000)
    Citizen.Wait(5000)
    DoScreenFadeIn(5000)
    RequestAnimDict("random@drunk_driver_2")
    while not HasAnimDictLoaded("random@drunk_driver_2") do
        Citizen.Wait(10)
    end
    TaskPlayAnim(playerPed, "random@drunk_driver_2", "cardrunksex_loop_m", 1.0, -1.0, -1, 1, 1, false, false, false)
    Citizen.Wait(15000)
    FreezeEntityPosition(playerPed, false)
    ClearPedTasks(playerPed)
end)



-------------------------------------------------------------- DRINK ----------------------------------

CurrentCart = {}

RegisterNetEvent('elder_poledance:client:drink')
AddEventHandler('elder_poledance:client:drink', function()
    local coords = GetEntityCoords(cache.ped)
    local player = lib.getClosestPlayer(vec3(coords.x, coords.y, coords.z), 2.0, false)
    --local player = NetworkGetPlayerIndexFromPed(cache.ped)
    if not player then
        TriggerEvent('elder_poledance:notify', 'No One Found', 'There appears to be no one around', 'error')
    else
        TriggerServerEvent('elder_poledance:server:drink', GetPlayerServerId(player))
    end
end)

RegisterNetEvent('elder_poledance:client:drink_request')
AddEventHandler('elder_poledance:client:drink_request', function(stripper)
    local Options = {}
    
    Options[#Options + 1] = {
        title = 'Drinks menu',
        description = 'List of all our available drinks',
        icon = 'fa-wine-bottle',
        onSelect = function()
            OpenDrinkMenu()
        end
    }
    Options[#Options + 1] = {
        title = 'Cart',
        description = 'Check out your cart',
        icon = 'fa-cart-shopping',
        onSelect = function()
            OpenCart(stripper)
        end
    }
    
    lib.registerContext({
        id = 'nc_drink_menu',
        title = 'Night Club : Drink Menu',
        menu = 'nc_job_menu',
        options = Options
    })
    lib.showContext('nc_drink_menu')
end)

OpenDrinkMenu = function()
    local Options = {}
    for k,v in pairs(Config.Drinks) do
        Options[#Options + 1] = {
            title = GetItemLabel(v.name),
            description = '🔞Alchool drink | 💲' .. ESX.Math.GroupDigits(v.price),
            icon = Config.ImagesPath..v.name..'.png',
            close = false,
            onSelect = function()
                AddToCart(v.name)
                TriggerEvent('elder_poledance:notify', 'Night Club', 'Drink added to cart', 'success')
                OpenDrinkMenu()
            end
        }
    end
    lib.registerContext({
        id = 'nc_drink_list_menu',
        title = 'Drinks Menu',
        menu = 'nc_drink_menu',
        options = Options
    })
    lib.showContext('nc_drink_list_menu')
end

AddToCart = function(item)
    if not CurrentCart[item] then 
        CurrentCart[item] = 1 
    else
        CurrentCart[item] = CurrentCart[item] + 1 
    end
end

OpenCart = function(stripper)
    local Options = {}
    local total_price = GetTotalPrice()
    for k,v in pairs(CurrentCart) do
        if v > 0 then
            Options[#Options + 1] = {
                title = GetItemLabel(k),
                description = 'x'..v .. ' in cart',
                icon = Config.ImagesPath..k..'.png',
                onSelect = function()
                RemoveFromCart(k)
                TriggerEvent('elder_poledance:notify', 'Night Club', 'Drink removed from cart', 'success')
                OpenCart(stripper)
                end
            }
        end
    end
    if total_price > 0 then
        Options[#Options + 1] = {
            title = 'Pay $' .. ESX.Math.GroupDigits(GetTotalPrice()),
            description = 'Pay cash or bank',
            icon = 'fa-hand-holding-dollar',
            iconColor = 'green',
            onSelect = function()
                TriggerServerEvent('elder_poledance:server:drink_pay', stripper, CurrentCart, total_price)
                CurrentCart = {}
            end
        }

        Options[#Options + 1] = {
            title = 'Clear cart',
            description = 'remove all drinks in your cart',
            icon = 'fa-trash',
            iconColor = 'red',
            onSelect = function()
            CurrentCart = {}
            TriggerEvent('elder_poledance:notify', 'Night Club', 'Cart cleared', 'success')
            OpenCart(OpenCart)
            end
        }
    else
        Options[#Options + 1] = {
            title = 'Cart is empty',
            description = 'add your drinks from the menu',
            icon = 'fa-circle-exclamation',
            iconColor = 'red',
        }
    end

    lib.registerContext({
        id = 'nc_drink_cart_menu',
        title = 'Drinks Menu',
        menu = 'nc_drink_menu',
        options = Options
    })
    lib.showContext('nc_drink_cart_menu')
end

RemoveFromCart = function(item)
    if CurrentCart[item] and CurrentCart[item] > 0 then
        CurrentCart[item] = CurrentCart[item] - 1
    end
end

GetTotalPrice = function()
    local price = 0
    for k,v in pairs(CurrentCart) do
        price = price + (v * GetDrinkPrice(k))
    end
    return price
end

GetDrinkPrice = function(item)
    for k,v in pairs(Config.Drinks) do
        if v.name == item then return v.price end
    end
    return 0
end


-----------------------------------------------

Citizen.CreateThread(function()
    while not PlayerJob do Wait(10) end
    while true do
        local wait = 5000
        if PlayerJob.name == Config.Job and PlayerJob.grade == 1 then
            wait = 1000
            local ped = PlayerPedId()
            local ped_coords = GetEntityCoords(ped)
            local distance = GetDistanceBetweenCoords(ped_coords, Config.Boss,true)
            if distance <= 10.0 then
                wait = 1
                DrawMarker(21, Config.Boss.x,Config.Boss.y,Config.Boss.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 0.5, 0.5, 0.5, 0, 0, 255, 255, false, true, 2, true, false, false, false)
                if distance <= 2.0 then 
                    ESX.ShowHelpNotification('[E] Boss Menu')
                    if IsControlJustReleased(0, 38) then
                        OpenBossMenu()
                    end
                end
            end
        end
        Citizen.Wait(wait)
    end
end)

function OpenBossMenu()
    TriggerEvent('esx_society:openBossMenu', PlayerJob.name, function(data, menu)
        menu.close()
    end, {wash = false})
end

RegisterCommand('NightClubJobMenu', function()
    if not PlayerJob or PlayerJob.name ~= Config.Job then return end
    local ped = PlayerPedId()
    local ped_coords = GetEntityCoords(ped)
    if false and not ClubZone:isPointInside(ped_coords) then
        TriggerEvent('elder_poledance:notify', 'Night Club', 'You should be in the nightclub to use this.', 'error')
    else
        openJobMenu()
    end
end)

RegisterKeyMapping('NightClubJobMenu', 'Night Club Job Menu', 'keyboard', 'F6')


RegisterNetEvent('elder_poledance:notify', function(title, desc, style)
    lib.notify({
        title = title,
        description = desc,
        duration = 3500,
        type = style,
        position = 'top'
    })
end)


AddEventHandler('onClientResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    while not PlayerJob do Wait(10) end
    if PlayerJob.name == Config.Job then
        CreateTargets()
    end
end)
AddEventHandler('onClientResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    DestroyTargets()
    DestroyBoss()
    while not PlayerJob do Wait(10) end
    if PlayerJob.name == Config.Job  then
        DestroyTargets()
    end 
end)

GetItemLabel = function(_item)
	local item  = exports.ox_inventory:Items(_item)
	return item and item.label or _item
end



--------------------------------------------- GARD --------------------------


local NPC = nil

Citizen.CreateThread(function()  
    local ped_hash = GetHashKey(Config.Guard.guard.model)
    local coords = Config.Guard.guard.coords
    ESX.Streaming.RequestModel(ped_hash)
    NPC = CreatePed(5, ped_hash, coords.x, coords.y, coords.z-1, coords.w, false, true)
    PlaceObjectOnGroundProperly(NPC)
    FreezeEntityPosition(NPC, true)
    SetEntityInvincible(NPC, true)
    SetBlockingOfNonTemporaryEvents(NPC, true)	     
    TaskStartScenarioInPlace(NPC, "WORLD_HUMAN_GUARD_STAND", 0, true)
end)

Citizen.CreateThread(function()
	local coords = Config.Guard.guard.coords
    while true do
        if CanAccessNightClub then break end
		local wait = 1000
		local ped = PlayerPedId()
		local ped_coords = GetEntityCoords(ped)
		if GetDistanceBetweenCoords(ped_coords, coords,true) <= 3.0 then
			wait = 1
			ESX.ShowHelpNotification('Press ~INPUT_CONTEXT~ to pay entrance fees ~g~'..ESX.Math.GroupDigits(Config.Guard.price)..'~s~')
			if IsControlJustReleased(0, 38) then
				if not CanAccessNightClub then
                    ESX.TriggerServerCallback('elder_poledance:server:pay_guard', function(paid)
                        if paid then
                            CanAccessNightClub = true
                            TriggerEvent('elder_poledance:notify', 'Night Club', 'You can now access to the night club.', 'success')
                        else
                            TriggerEvent('elder_poledance:notify', 'Night Club', 'You dont have enough money.', 'error')
                        end
                    end)
                else
                    TriggerEvent('elder_poledance:notify', 'Night Club', 'You have already paid for entrance.', 'info')
                end
			end
		end	
        Citizen.Wait(wait)
    end
end)

Citizen.CreateThread(function()
    while true do
        local wait = 1000
        if not CanAccessNightClub then
            local ped = PlayerPedId()
            local ped_coords = GetEntityCoords(ped)
            if ClubZone:isPointInside(ped_coords) then
                ESX.Game.Teleport(ped, vector4(-430.3970, 256.5434, 83.0219, 118.3416))
            end
        else
            wait = 5000
        end
        Citizen.Wait(wait)
    end
end)


----------------------------------------------------- KICK -----------------------------------

local CASINO_BEING_KICKED = false

RegisterNetEvent('elder_poledance:client:kick')
AddEventHandler('elder_poledance:client:kick', function()
    local coords = GetEntityCoords(cache.ped)
    local player = lib.getClosestPlayer(vec3(coords.x, coords.y, coords.z), 2.0, false)
    --local player = NetworkGetPlayerIndexFromPed(cache.ped)
    if not player then
        TriggerEvent('elder_poledance:notify', 'No One Found', 'There appears to be no one around', 'error')
    else
        TriggerServerEvent('elder_poledance:server:kick', GetPlayerServerId(player))
    end
end)

RegisterNetEvent('elder_poledance:client:kickout')
AddEventHandler('elder_poledance:client:kickout', function()
    if PlayerJob and PlayerJob.name == Config.Job then
        return
    end
    StartCasinoBouncerScene()
end)

function StartCasinoBouncerScene()
    StartCasinoLeaveScene()
--[[
    if CASINO_BEING_KICKED then
        return
    end
    CASINO_BEING_KICKED = true
    CreateThread(function()
        while CASINO_BEING_KICKED do
            HideHudAndRadarThisFrame()
            Wait(0)
        end
    end)
    DoScreenFadeOut(500)
    Wait(500)
    ESX.Game.Teleport(PlayerPedId(), vector4(-355.9083, 408.4752, 5.7649, 5.0112))
    Wait(500)

    local tOutDict = "mini@strip_club@throwout_d@"

    RequestModel(GetHashKey("s_m_m_bouncer_01"))
    RequestModel(GetHashKey("s_m_m_bouncer_02"))
    RequestAnimDict(tOutDict)

    while not HasAnimDictLoaded(tOutDict) or not HasModelLoaded(GetHashKey("s_m_m_bouncer_01")) or
        not HasModelLoaded(GetHashKey("s_m_m_bouncer_02")) do
        Wait(33)
    end

    local sceneCoords = vector3(-355.5612, 400.8557, 6.5819 - 0.9)
    local bouncer1 = CreatePed(4, GetHashKey("s_m_m_bouncer_01"), sceneCoords)
    local bouncer2 = CreatePed(4, GetHashKey("s_m_m_bouncer_02"), sceneCoords)
    local myself = ClonePed(PlayerPedId(), 0.0, false)
    print(myself)

    SetModelAsNoLongerNeeded(GetHashKey("s_m_m_bouncer_01"))
    SetModelAsNoLongerNeeded(GetHashKey("s_m_m_bouncer_02"))

    SetPedDefaultComponentVariation(bouncer1)
    SetPedComponentVariation(bouncer1, 0, 0, 2, 0)
    SetPedComponentVariation(bouncer1, 2, 1, 0, 0)
    SetPedComponentVariation(bouncer1, 3, 1, 1, 0)
    SetPedComponentVariation(bouncer1, 4, 0, 0, 0)
    SetPedComponentVariation(bouncer1, 11, 0, 0, 0)
    SetPedComponentVariation(bouncer1, 8, 1, 0, 0)

    local cam = CreateCam("DEFAULT_ANIMATED_CAMERA", true)
    SetCamCoord(cam, -355.5612, 400.8557, 6.5819)
    SetCamActive(cam, true)
    RenderScriptCams(true, true, 1, true, true)
    PlayCamAnim(cam, "throwout_d_cam", tOutDict, -353.5612, 398.8557, 6.5819, 0.0, 0.0, 300.0, 0, 0)

    local initialPos, initialRot = GetInitialAnimOffsets(tOutDict, "throwout_d_victim", sceneCoords, 0, 0, 0)
    local scene = CreateSynchronizedScene(initialPos, initialRot, 2)

    TaskSynchronizedScene(myself, scene, tOutDict, "throwout_d_victim", 2.0, -1.5, 13, 16, 2.0, 0)
    TaskSynchronizedScene(bouncer1, scene, tOutDict, "throwout_d_bouncer_a", 2.0, -1.5, 13, 16, 2.0, 0)
    TaskSynchronizedScene(bouncer2, scene, tOutDict, "throwout_d_bouncer_b", 2.0, -1.5, 13, 16, 2.0, 0)

    Wait(500)
    DoScreenFadeIn(1000)
    PlayPedAmbientSpeechWithVoiceNative(bouncer1, "BOUNCER_EJECT_GENERIC", "", "SPEECH_PARAMS_FORCE_NORMAL", 0)

    Wait(5000)
    PlayPedAmbientSpeechWithVoiceNative(bouncer1, "BOUNCER_EJECT_GENERIC", "", "SPEECH_PARAMS_FORCE_NORMAL", 0)

    Wait(2000)
    DoScreenFadeOut(1000)
    Wait(2000)

    ClearPedTasks(PlayerPedId())
    SetEntityCoordsNoOffset(PlayerPedId(), GetEntityCoords(myself))

    DeleteEntity(bouncer1)
    DeleteEntity(bouncer2)
    DeleteEntity(myself)

    RenderScriptCams(false, true, 1, true, true)
    SetCamActive(cam, false)
    DestroyCam(cam)
    CASINO_BEING_KICKED = false

    StartCasinoLeaveScene() ]]
end

function GetInitialAnimOffsets(animDict, animName, x, y, z, rx, ry, rz)
    return GetAnimInitialOffsetPosition(animDict, animName, x, y, z, rx, ry, rz, 0.01, 2),
        GetAnimInitialOffsetRotation(animDict, animName, x, y, z, rx, ry, rz, 0.01, 2)
end

function StartCasinoLeaveScene()
    if CASINO_BEING_KICKED then
        return
    end
    CASINO_BEING_KICKED = true
    CreateThread(function()
        DoScreenFadeOut(500)
        Wait(500)
        ESX.Game.Teleport(PlayerPedId(), vector4(-430.5725, 255.8596, 83.0245, 171.9519))
        Wait(2000)
        DoScreenFadeIn(500)
        CASINO_BEING_KICKED = false
        CanAccessNightClub = false
    end)
end

-------------------------- TICKET --------------

RegisterNetEvent('elder_poledance:client:ticket')
AddEventHandler('elder_poledance:client:ticket', function()
    TriggerServerEvent('elder_poledance:server:ticket')
end)


CreateThread(function()
    while not Gender do Wait(10) end
    if Gender == 0 then return end
    while true do
        local sleep = 2000
        local distance = GetDistanceBetweenCoords(GetEntityCoords(cache.ped), Config.StripJobDutyLocation, true)
        if PlayerJob.name ~= Config.Job then
            if distance <= 10 then
                sleep = 1
                DrawMarker(21, Config.StripJobDutyLocation.x,Config.StripJobDutyLocation.y,Config.StripJobDutyLocation.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 0.5, 0.5, 0.5, 255, 105, 180, 255, false, true, 2, true, false, false, false)
                if distance <= 2.0 then 
                    ESX.ShowHelpNotification('Press ~INPUT_PICKUP~ to clock in as striper')
                    if IsControlJustReleased(0, 38) then
                        TriggerServerEvent('elder_poledance:server:stripjob')
                    end
                end
            end
        end
        Wait(sleep)
    end
end)

Config.Cooldown = 120 --Timer

for i = 0, 3 do
    StatSetInt(GetHashKey("mp" .. i .. "_shooting_ability"), Config.Cooldown, true)
    StatSetInt(GetHashKey("sp" .. i .. "_shooting_ability"), Config.Cooldown, true)
  end
