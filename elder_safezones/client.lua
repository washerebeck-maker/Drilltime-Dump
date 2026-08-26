local SafezoneIn = false
local SafezoneOut = false
local closestZone = 1
local allowedToUse = false
local bypass = false
local blips = {}
local zones = Config.zones

Citizen.CreateThread(function()
	TriggerServerEvent("SafeZones:isAllowed")
end)

RegisterNetEvent("SafeZones.returnIsAllowed")
AddEventHandler("SafeZones.returnIsAllowed", function(isAllowed)
    allowedToUse = isAllowed
end)

RegisterCommand("sbypass", function(source, args, rawCommand)
	if allowedToUse then
	if not bypass then
	bypass = true
	ShowInfo("~g~SafeZone Bypass Enabled!")
	elseif bypass then
	bypass = false
	ShowInfo("~r~SafeZone Bypass Disabled!")
	end
else
	ShowInfo("~r~Insufficient Permissions.")
end
end)

local function removeBlips()
    for k,v in pairs(blips) do
        RemoveBlip(v) 
    end
end

local function createBlips()
    removeBlips()
    for i = 1, #zones, 1 do
        local blip = AddBlipForRadius(zones[i].coords.x, zones[i].coords.y, zones[i].coords.z, zones[i].radius)
        SetBlipHighDetail(blip, true)
        SetBlipColour(blip, 11)
        SetBlipAlpha (blip, 128)
        local blip1 = AddBlipForCoord(x, y, z)
        SetBlipSprite (blip1, sprite)
        SetBlipDisplay(blip1, true)
        SetBlipScale  (blip1, 0.9)
        SetBlipColour (blip1, 11)
        SetBlipAsShortRange(blip1, true)
        blips[i] = blip
    end
end

Citizen.CreateThread(function()
	createBlips()
end)

Citizen.CreateThread(function()
	while true do
		local playerPed = PlayerPedId()
		local x, y, z = table.unpack(GetEntityCoords(playerPed, true))
		local minDistance = 100000
		Citizen.Wait(1)
		for i = 1, #zones, 1 do
			dist = Vdist(zones[i].coords.x, zones[i].coords.y, zones[i].coords.z, x, y, z)
			if dist < minDistance then
				minDistance = dist
				closestZone = i
			end
		end
	end
end)

Citizen.CreateThread(function()
	while true do

        if zones[closestZone] then

            local player = PlayerPedId()
            local x,y,z = table.unpack(GetEntityCoords(player, true))
            local dist = Vdist(zones[closestZone].coords.x, zones[closestZone].coords.y, zones[closestZone].coords.z, x, y, z)
            local vehicle = GetVehiclePedIsIn(player, false)
            local speed = GetEntitySpeed(vehicle)


            if dist <= zones[closestZone].radius then
                if not SafezoneIn then
                    NetworkSetFriendlyFireOption(false)
                    SetEntityCanBeDamaged(vehicle, false)
                    ClearPlayerWantedLevel(PlayerId())
                    TriggerEvent('ox_inventory:disarm', true)
                    if Config.showNotification then
                        exports['mythic_notify']:PersistentAlert('start', 'safezoneAlert', Config.notificationstyle, Config.safezoneMessage)
                    end
                    SafezoneIn = true
                    SafezoneOut = false
                end
            else
                if not SafezoneOut then
                    NetworkSetFriendlyFireOption(true)
                    if Config.showNotification then
                        exports['mythic_notify']:PersistentAlert('end', 'safezoneAlert')
                    end
                    if Config.speedlimitinSafezone then
                        SetVehicleMaxSpeed(vehicle, 1000.00)
                    end
                    SetEntityCanBeDamaged(vehicle, true)
                    SafezoneOut = true
                    SafezoneIn = false
                end
                Citizen.Wait(200)
            end
            if SafezoneIn then
                Citizen.Wait(10)
                if not bypass then
                    DisablePlayerFiring(player, true)
                    SetPlayerCanDoDriveBy(player, false)
                    DisableControlAction(2, 37, true)
                    DisableControlAction(0, 106, true)
                    DisableControlAction(0, 24, true)
                    DisableControlAction(0, 69, true)
                    DisableControlAction(0, 70, true)
                    DisableControlAction(0, 92, true)
                    DisableControlAction(0, 114, true)
                    DisableControlAction(0, 257, true)
                    DisableControlAction(0, 331, true)
                    DisableControlAction(0, 68, true)
                    DisableControlAction(0, 257, true)
                    DisableControlAction(0, 263, true)
                    DisableControlAction(0, 264, true)
                    if zones and zones[closestZone] and zones[closestZone].vehicle_not_allowed then
                        if IsPedInAnyVehicle(player,false) then
                            local vehicle = GetVehiclePedIsIn(player, false)
                            if GetPedInVehicleSeat(vehicle, -1) == player then
                                DeleteEntity(vehicle)
                            end
                        end
                    end
                    if Config.speedlimitinSafezone then
                        mphs = 2.237
                        maxspeed = Config.speedlimitinSafezone/mphs
                        SetVehicleMaxSpeed(vehicle, maxspeed)
                    end
                    if IsDisabledControlJustPressed(2, 37) then
                        TriggerEvent('ox_inventory:disarm', true)
                    end
                    if IsDisabledControlJustPressed(0, 106) then 
                        TriggerEvent('ox_inventory:disarm', true)
                    end
                end
            end
        end
        Wait(1)
    end
end)


function ShowInfo(text)
	BeginTextCommandThefeedPost("STRING")
	AddTextComponentSubstringPlayerName(text)
	EndTextCommandThefeedPostTicker(true, false)
end

InSafeZone= function()
	return SafezoneIn
end

exports("InSafeZone", InSafeZone)

lib.callback.register('SafeZones:client:inSafeZone', function()
	return SafezoneIn
end)


RegisterNetEvent('esx:onPlayerDeath')
AddEventHandler('esx:onPlayerDeath', function(data)
	if not IsCommServiceZone(closestZone) then return end
    if not data.killedByPlayer then return end
    local victimCoords = GetEntityCoords(PlayerPedId())
    local killerCoords = GetEntityCoords(GetPlayerPed(data.killerClientId))
	if GetDistanceBetweenCoords(victimCoords, vector3(zones[closestZone].coords.x, zones[closestZone].coords.y, zones[closestZone].coords.z), true) < zones[closestZone].radius + 40 then
		Wait(2000)
		TriggerServerEvent('SafeZones:server:death', data.killerServerId)
	end
end)

IsCommServiceZone = function(zone)
	for _,v in pairs(Config.CommunityServiceZones) do
		if v == zone then 
			return true
		end
	end
	return false
end


RegisterNetEvent('SafeZones:OnPurgeStart')
AddEventHandler('SafeZones:OnPurgeStart', function()
    zones = exports.elder_purge:getSpawnLocations()
    createBlips()
end)

RegisterNetEvent('SafeZones:OnPurgeStop')
AddEventHandler('SafeZones:OnPurgeStop', function()
    zones = Config.zones
    createBlips()
end)