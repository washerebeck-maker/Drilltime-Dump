--███████╗██████╗  █████╗ ███╗   ███╗███████╗██╗    ██╗ ██████╗ ██████╗ ██╗  ██╗
--██╔════╝██╔══██╗██╔══██╗████╗ ████║██╔════╝██║    ██║██╔═══██╗██╔══██╗██║ ██╔╝
--█████╗  ██████╔╝███████║██╔████╔██║█████╗  ██║ █╗ ██║██║   ██║██████╔╝█████╔╝ 
--██╔══╝  ██╔══██╗██╔══██║██║╚██╔╝██║██╔══╝  ██║███╗██║██║   ██║██╔══██╗██╔═██╗ 
--██║     ██║  ██║██║  ██║██║ ╚═╝ ██║███████╗╚███╔███╔╝╚██████╔╝██║  ██║██║  ██╗
--╚═╝     ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝     ╚═╝╚══════╝ ╚══╝╚══╝  ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝

local ESX = nil

local AdminZones = {}
local AdminZoneBlips = {}
local closestZone = nil
local IsModerator = false

local AllowAdminChat = false

ESX = exports['es_extended']:getSharedObject()

CreateThread(function()
    if ESX.IsPlayerLoaded() then
        AllowAdminChat = GetAllowAdminChat()
    end
end)


RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer) 
	AdminZones = GetAdminZones()
    AllowAdminChat = GetAllowAdminChat()
    for k,v in pairs(AdminZones) do
        CreateBlip(k,v)
    end
end)

GetAdminZones = function()
	local result = promise:new()
    ESX.TriggerServerCallback('drilltime_admin:server:get_admin_zones', function(data) 
		result:resolve(data)  
    end)
    return Citizen.Await(result)
end

GetAllowAdminChat = function()
    local result = promise:new()
    ESX.TriggerServerCallback('drilltime_admin:server:is_admin_chat_allowed', function(data) 
		result:resolve(data)  
    end)
    return Citizen.Await(result)
end

RegisterNetEvent("drilltime_admin:killPlayer")
AddEventHandler("drilltime_admin:killPlayer", function()
    SetEntityHealth(PlayerPedId(), 0)
end)

RegisterNetEvent('drilltime_admin:healPlayer')
AddEventHandler('drilltime_admin:healPlayer', function()
	TriggerEvent('esx_status:set', 'hunger', 1000000)
	TriggerEvent('esx_status:set', 'thirst', 1000000)
	SetEntityHealth(PlayerPedId(), GetEntityMaxHealth(PlayerPedId()))
end)

RegisterNetEvent("drilltime_admin:revivePlayer")
AddEventHandler("drilltime_admin:revivePlayer", function()
    if IsEntityDead(PlayerPedId()) then 
        TriggerEvent("esx_ambulancejob:revive_deathmatch")
        ESX.ShowNotification("You have been revived by ~b~admin~s~.")	
    end
end)

RegisterNetEvent("drilltime_admin:tpm")
AddEventHandler("drilltime_admin:tpm", function()
    local GetEntityCoords = GetEntityCoords
    local GetGroundZFor_3dCoord = GetGroundZFor_3dCoord

    local blipMarker <const> = GetFirstBlipInfoId(8)
    if not DoesBlipExist(blipMarker) then
        ESX.ShowNotification("~r~Select waypoint on map.~s~")	
        return
    end
    DoScreenFadeOut(650)
    while not IsScreenFadedOut() do
        Wait(0)
    end
    local ped, coords <const> = PlayerPedId(), GetBlipInfoIdCoord(blipMarker)
    local vehicle = GetVehiclePedIsIn(ped, false)
    local oldCoords <const> = GetEntityCoords(ped)

    local x, y, groundZ, Z_START = coords['x'], coords['y'], 850.0, 950.0
    local found = false
    if vehicle > 0 then
        FreezeEntityPosition(vehicle, true)
    else
        FreezeEntityPosition(ped, true)
    end
    for i = Z_START, 0, -25.0 do
        local z = i
        if (i % 2) ~= 0 then
            z = Z_START - i
        end
        NewLoadSceneStart(x, y, z, x, y, z, 50.0, 0)
        local curTime = GetGameTimer()
        while IsNetworkLoadingScene() do
            if GetGameTimer() - curTime > 1000 then
                break
            end
            Wait(0)
        end
        NewLoadSceneStop()
        SetPedCoordsKeepVehicle(ped, x, y, z)
        while not HasCollisionLoadedAroundEntity(ped) do
            RequestCollisionAtCoord(x, y, z)
            if GetGameTimer() - curTime > 1000 then
                break
            end
            Wait(0)
        end
        found, groundZ = GetGroundZFor_3dCoord(x, y, z, false);
        if found then
            Wait(0)
            SetPedCoordsKeepVehicle(ped, x, y, groundZ)
            break
        end
        Wait(0)
    end
    DoScreenFadeIn(650)
    if vehicle > 0 then
        FreezeEntityPosition(vehicle, false)
    else
        FreezeEntityPosition(ped, false)
    end
    if not found then
        SetPedCoordsKeepVehicle(ped, oldCoords['x'], oldCoords['y'], oldCoords['z'] - 1.0)
        ESX.ShowNotification("~r~Error when teleporting.~s~")	
    end
    SetPedCoordsKeepVehicle(ped, x, y, groundZ)
    ESX.ShowNotification("You teleported to waypoint.")	
end)

RegisterNetEvent("drilltime_admin:info")
AddEventHandler("drilltime_admin:info", function(args)
    OpenInfoMenu(args.id,args.name,args.data)
end)

RegisterNetEvent("drilltime_admin:wipe")
AddEventHandler("drilltime_admin:wipe", function(radius)
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    
    local peds = GetGamePool('CPed')
    local objects = GetGamePool('CObject')
    
    for _, ped in pairs(peds) do
        local pedCoords = GetEntityCoords(ped)
        local distance = Vdist2(pedCoords.x, pedCoords.y, pedCoords.z, playerCoords.x, playerCoords.y, playerCoords.z)
        
        if distance < radius then
            DeleteEntity(ped)
        end
    end
    
    for _, object in pairs(objects) do
        local objectCoords = GetEntityCoords(object)
        local distance = Vdist2(objectCoords.x, objectCoords.y, objectCoords.z, playerCoords.x, playerCoords.y, playerCoords.z)
        
        if distance < radius then 
            DeleteEntity(object)
        end
    end
end)



RegisterNetEvent("drilltime_admin:client:vehicles")
AddEventHandler("drilltime_admin:client:vehicles", function(args)
    local Options = {}
    for k,v in pairs(args.data.vehicle_money) do
        Options[#Options + 1] = {
            title = v.plate,
            description = 'Trunk : ' .. ESX.Math.GroupDigits(tonumber(v.trunk_money) or 0),
            icon = 'fa-car',
            iconColor = 'gold',
            arrow = true,
        }
        Options[#Options + 1] = {
            title = v.plate ,
            description = 'Glovebox : ' .. ESX.Math.GroupDigits(tonumber(v.glovebox_money) or 0),
            icon = 'fa-car',
            iconColor = 'silver',
            arrow = true,
        }
    end

    Options[#Options + 1] = {
        title = 'Back',
        icon = 'fa-circle-arrow-left',
        iconColor = 'red',
        arrow = true,
        event = 'drilltime_admin:info',
        args = {id = args.id, name = args.name, data = args.data}
    }

    lib.registerContext({
        id = 'vehiles_menu',
        title = 'Vehicles Info',
        options = Options
    })

    lib.showContext('vehiles_menu')
end)

RegisterNetEvent("drilltime_admin:client:houses")
AddEventHandler("drilltime_admin:client:houses", function(args)
    local Options = {}
    for k,v in pairs(args.data.house_money) do
        Options[#Options + 1] = {
            title = v.name ,
            description = 'Money : ' .. ESX.Math.GroupDigits(tonumber(v.count) or 0),
            icon = 'fa-house',
            iconColor = 'gold',
            arrow = true,
        }
    end

    Options[#Options + 1] = {
        title = 'Back',
        icon = 'fa-circle-arrow-left',
        iconColor = 'red',
        arrow = true,
        event = 'drilltime_admin:info',
        args = {id = args.id, name = args.name, data = args.data}
    }

    lib.registerContext({
        id = 'vehiles_menu',
        title = 'Vehicles Info',
        options = Options
    })

    lib.showContext('vehiles_menu')
end)

function OpenInfoMenu(id,name,data)
    local Options = {}
    Options[#Options + 1] = {
		title = 'Cash : ' .. ESX.Math.GroupDigits(data.money),
		icon = 'fa-money-bill',
        iconColor = 'green',
		arrow = true,
	}
	Options[#Options + 1] = {
		title = 'Bank : ' .. ESX.Math.GroupDigits(data.bank),
		icon = 'fa-building-columns',
        iconColor = 'green',
		arrow = true,
	}
	Options[#Options + 1] = {
		title = 'Black Money : ' .. ESX.Math.GroupDigits(data.black_money),
		icon = 'fa-sack-dollar',
        iconColor = 'red',
		arrow = true,
	}

    Options[#Options + 1] = {
		title = 'Vehicles : ' .. #data.vehicle_money,
		icon = 'fa-car-side',
        iconColor = 'gold',
		arrow = true,
        event = 'drilltime_admin:client:vehicles',
        args = {id=id,name=name,data=data}
	}

    Options[#Options + 1] = {
		title = 'Houses : ' .. #data.house_money,
		icon = 'fa-house',
        iconColor = 'brown',
		arrow = true,
        event = 'drilltime_admin:client:houses',
        args = {id=id,name=name,data=data}
	}

	lib.registerContext({
        id = 'info_menu',
        title = '['..id..'] - '..name..' Info',
        options = Options
    })

    lib.showContext('info_menu')
end

RegisterNetEvent("drilltime_admin:client:admin_zone")
AddEventHandler("drilltime_admin:client:admin_zone", function(coords, id)
    AdminZones[id] = coords
    CreateBlip(id,coords)
end)

RegisterNetEvent("drilltime_admin:client:delete_admin_zone")
AddEventHandler("drilltime_admin:client:delete_admin_zone", function(id)
    AdminZones[id] = nil
    RemoveBlip(AdminZoneBlips[id])
end)

RegisterNetEvent("drilltime_admin:client:txrdm")
AddEventHandler("drilltime_admin:client:txrdm", function(target)
    local killerPed = GetPedSourceOfDeath(GetPlayerPed(GetPlayerFromServerId(target)))
    if killerPed <= 0 then
        ESX.ShowNotification('This player is dead and has no killer')
        ExecuteCommand('txrevive ' .. target)
    else
        local killer = GetPlayerServerId(NetworkGetPlayerIndexFromPed(killerPed))
        ExecuteCommand('txrevive ' .. killer)
        Wait(2000)
        ExecuteCommand('txbring '.. killer)
    end
end)

Citizen.CreateThread(function()
	while true do
		local playerPed = PlayerPedId()
		local x, y, z = table.unpack(GetEntityCoords(playerPed, true))
		local minDistance = 100000
		Citizen.Wait(1)
		for k,v in pairs(AdminZones) do
			dist = Vdist(v.x, v.y, v.z, x, y, z)
			if dist < minDistance then
				minDistance = dist
				closestZone = k
			end
		end
	end
end)


CreateThread(function()
    local sleep = 100
    while true do
        if closestZone and AdminZones[closestZone] then
            local player = PlayerPedId()
            local x,y,z = table.unpack(GetEntityCoords(player, true))
            local dist = Vdist(AdminZones[closestZone].x, AdminZones[closestZone].y, AdminZones[closestZone].z, x, y, z)
            if dist <= Config.Radius then
                sleep = 100
                MissionAlert("📛 You are in ~r~Admin Zone~s~ 📛")
                if IsPedArmed(player, 7) then
                    TriggerEvent('ox_inventory:disarm', true)
                else
                    sleep = 500
                end
            else
                sleep = 1000
            end
            
        end
        Citizen.Wait(sleep)
    end
end)


function MissionAlert(text)
    ClearPrints()
    SetTextEntry_2("STRING")
    AddTextComponentString(text)
    DrawSubtitleTimed(1000, 1)
end

CreateBlip = function(id,coords)
    AdminZoneBlips[id] = AddBlipForRadius(coords.x, coords.y, coords.z, Config.Radius)
	SetBlipHighDetail(AdminZoneBlips[id], true)
	SetBlipColour(AdminZoneBlips[id], 46)
	SetBlipAlpha (AdminZoneBlips[id], 200)
end

RegisterNetEvent('drilltime_admin:client:client_create_screenshot')
AddEventHandler('drilltime_admin:client:client_create_screenshot', function(admin)
    exports['screenshot-basic']:requestScreenshotUpload(Config.ScreenshotWebHook, 'files[]', function(data) 
        local resp = json.decode(data)
        local imageUrl = resp.attachments[1].url
        TriggerServerEvent('drilltime_admin:server:client_create_screenshot', imageUrl, admin)
    end)
end)

local PaperCooldown = 0

--[[RegisterCommand('paperwork', function()

    if PaperCooldown < GetGameTimer() then
        PaperCooldown = GetGameTimer() + 1000
        local coords = GetEntityCoords(PlayerPedId())
        local target = lib.getClosestPlayer(vec3(coords.x, coords.y, coords.z), 2.0, false)
        if not target then
            ESX.ShowNotification('No one is nearby')
        else
            ESX.TriggerServerCallback('drilltime_admin:server:get_paperwork', function(count, name)
                lib.notify({
                    title = 'PaperWork',
                    description = name..' has cooperated with authorities : '..count..' times',
                    position = 'top',
                    duration = 10000,
                    style = {
                        backgroundColor = '#141517',
                        color = '#C1C2C5',
                        ['.description'] = {
                          color = '#909296'
                        }
                    },
                    icon = 'user',
                    iconColor = 'green'
                })
            end, GetPlayerServerId(target))
        end
    end
end)]]


--[[ local Toggle = false
local MaxDistance = 10
local PlayersDistance = {}

RegisterNetEvent('drilltime_admin:client:toogle_players_id')
AddEventHandler('drilltime_admin:client:toogle_players_id', function()
    if false and not IsModerator then
        return
    end
    Toggle = not Toggle
    if Toggle then
        StartDistanceCheck()
        StartPlayersID()
    end
end)


function DrawText3DTag(coords, text, color)
    local camCoords = GetGameplayCamCoord()
    local dist = #(coords - camCoords)
    local scale = 200 / (GetGameplayCamFov() * dist)
    SetTextColour(250, 250, 250, 250)
    SetTextScale(0.0, 0.4 * scale)
    SetTextFont(4)
	SetTextColour(color.r, color.g, color.b, 255)
    SetTextDropshadow(0, 0, 0, 0, 255)
    SetTextEdge(2, 0, 0, 0, 150)
    SetTextOutline()
	SetTextCentre(1)
	SetTextProportional(1)
    SetTextDropShadow()
    SetTextCentre(true)
    BeginTextCommandDisplayText("STRING")
    AddTextComponentSubstringPlayerName(text)
    SetDrawOrigin(coords, 0)
    EndTextCommandDisplayText(0.0, 0.0)
    ClearDrawOrigin()
end

StartDistanceCheck = function()
    PlayersDistance = {}
    Citizen.CreateThread(function()
        while Toggle do
            for id = 0, 255 do
                if true or GetPlayerPed(id) ~= GetPlayerPed(-1) then
                    x1, y1, z1 = table.unpack(GetEntityCoords(GetPlayerPed(-1), true))
                    x2, y2, z2 = table.unpack(GetEntityCoords(GetPlayerPed(id), true))
                    distance = math.floor(GetDistanceBetweenCoords(x1,  y1,  z1,  x2,  y2,  z2,  true))
                    PlayersDistance[id] = distance
                end
            end
            Citizen.Wait(500)
        end
    end)
end

StartPlayersID = function()
    Citizen.CreateThread(function()
        while Toggle do      
            for id = 0, 255 do 
                if NetworkIsPlayerActive(id) then
                    if true or GetPlayerPed(id) ~= GetPlayerPed(-1) then
                        if (PlayersDistance[id] and PlayersDistance[id] <= MaxDistance) then
                            x2, y2, z2 = table.unpack(GetPedBoneCoords(GetPlayerPed(id) , 0x796e))
                            local color = {r=255,g=255,b=255}
                            if NetworkIsPlayerTalking(id) then
                                color = {r=255,g=215,b=0}
                            end
                            DrawText3DTag(vector3(x2, y2, z2+0.4),'['..GetPlayerServerId(id)..'] '.. GetPlayerName(id), color)
                        end  
                    end
                end
            end
            Citizen.Wait(0)
        end
    end)
end
 ]]

local Toggle = false
local playerGamerTags = {}

local fivemGamerTagCompsEnum = {
    GamerName = 0,
    CrewTag = 1,
    HealthArmour = 2,
    BigText = 3,
    AudioIcon = 4,
    UsingMenu = 5,
    PassiveMode = 6,
    WantedStars = 7,
    Driver = 8,
    CoDriver = 9,
    Tagged = 12,
    GamerNameNearby = 13,
    Arrow = 14,
    Packages = 15,
    InvIfPedIsFollowing = 16,
    RankText = 17,
    Typing = 18
}

RegisterNetEvent('drilltime_admin:client:toogle_players_id')
AddEventHandler('drilltime_admin:client:toogle_players_id', function()
    --[[ if not IsModerator then
        return
    end ]]
    Toggle = not Toggle
    _createGamerTagThread(Toggle, true)
end)

function _createGamerTagThread()
    CreateThread(function()
        while Toggle do
            _showGamerTags()
            Wait(250)
        end

        -- Remove all gamer tags and clear out active table
        _cleanAllGamerTags()
    end)
end

function _cleanAllGamerTags()
    for _, v in pairs(playerGamerTags) do
        if IsMpGamerTagActive(v.gamerTag) then
            RemoveMpGamerTag(v.gamerTag)
        end
    end
    playerGamerTags = {}
end

function _showGamerTags()
    local curCoords = GetEntityCoords(PlayerPedId())
    -- Per infinity this will only return players within 300m
    local allActivePlayers = GetActivePlayers()

    for _, pid in ipairs(allActivePlayers) do
        -- Resolving player
        local targetPed = GetPlayerPed(pid)

        -- If we have not yet indexed this player or their tag has somehow dissapeared (pause, etc)
        if not playerGamerTags[pid] or not IsMpGamerTagActive(playerGamerTags[pid].gamerTag) then
            local playerName = string.sub(GetPlayerName(pid) or "unknown", 1, 75)
            local playerStr = '[' .. GetPlayerServerId(pid) .. ']' .. ' ' .. playerName
            playerGamerTags[pid] = {
                gamerTag = CreateFakeMpGamerTag(targetPed, playerStr, false, false, 0),
                ped = targetPed
            }
        end
        local targetTag = playerGamerTags[pid].gamerTag

        -- Distance Check
        local targetPedCoords = GetEntityCoords(targetPed)
        if #(targetPedCoords - curCoords) <= 10 then
            _setGamerTagFivem(targetTag, pid)
        else
            _clearGamerTagFivem(targetTag)
        end
    end
end

 function _setGamerTagFivem(targetTag, pid)
    -- Setup name
    SetMpGamerTagVisibility(targetTag, fivemGamerTagCompsEnum.GamerName, 1)

    -- Setup Health
    SetMpGamerTagHealthBarColor(targetTag, 129)
    SetMpGamerTagAlpha(targetTag, fivemGamerTagCompsEnum.HealthArmour, 255)
    SetMpGamerTagVisibility(targetTag, fivemGamerTagCompsEnum.HealthArmour, 1)

    -- Setup AudioIcon
    SetMpGamerTagAlpha(targetTag, fivemGamerTagCompsEnum.AudioIcon, 255)
    if NetworkIsPlayerTalking(pid) then
        SetMpGamerTagVisibility(targetTag, fivemGamerTagCompsEnum.AudioIcon, true)
        SetMpGamerTagColour(targetTag, fivemGamerTagCompsEnum.AudioIcon, 12) --HUD_COLOUR_YELLOW
        SetMpGamerTagColour(targetTag, fivemGamerTagCompsEnum.GamerName, 12) --HUD_COLOUR_YELLOW
    else
        SetMpGamerTagVisibility(targetTag, fivemGamerTagCompsEnum.AudioIcon, false)
        SetMpGamerTagColour(targetTag, fivemGamerTagCompsEnum.AudioIcon, 0)
        SetMpGamerTagColour(targetTag, fivemGamerTagCompsEnum.GamerName, 0)
    end
end

--- Clears a single gamer tag (fivem)
 function _clearGamerTagFivem(targetTag)
    -- Cleanup name
    SetMpGamerTagVisibility(targetTag, fivemGamerTagCompsEnum.GamerName, 0)
    -- Cleanup Health
    SetMpGamerTagVisibility(targetTag, fivemGamerTagCompsEnum.HealthArmour, 0)
    -- Cleanup AudioIcon
    SetMpGamerTagVisibility(targetTag, fivemGamerTagCompsEnum.AudioIcon, 0)
end

RegisterNetEvent('drilltile_admin:removeCrutch')
AddEventHandler('drilltile_admin:removeCrutch', function()
    --exports.wasabi_crutch:RemoveCrutch(GetPlayerServerId(PlayerId()))
end)

-- Admin chat 

RegisterNetEvent('elder_admin:client:admin_chat')
AddEventHandler('elder_admin:client:admin_chat', function(playerName, message, time)
    if not AllowAdminChat then return end
    -- TriggerEvent('chat:addMessage', {
        -- template = [[<div style="padding: 0.5vw; margin: 0.2vw; background-color: rgba(255, 215, 0, 0.7); border-radius: 3px;">
                    -- <i class="fas fa-user-shield" style="color:rgb(0, 0, 0)"></i> 
                    -- <b>
                    -- <span style="color:rgb(0, 0, 0)">{0}</span>
                    -- &nbsp;
                    -- <span style="font-size: 14px; color:rgb(0, 0, 0);">{2}</span>
                    -- </b>
                   
                    -- <div style="margin-top: 5px; font-weight: bold;color:rgb(0, 0, 0);">{1}</div>
                    
                -- </div>]],
        -- args = { playerName, message, time }
    --})
end)
