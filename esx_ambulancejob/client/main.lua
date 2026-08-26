local firstSpawn = true

isDead, isSearched, medic = false, false, 0

g_playerCoords = nil

g_distressSent = false

local canRespawn = false


CreateThread(function()
  while true do 
    g_playerCoords = GetEntityCoords(GetPlayerPed(-1))
    Wait(250)
  end
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
  ESX.PlayerLoaded = true
end)

RegisterNetEvent('esx:onPlayerLogout')
AddEventHandler('esx:onPlayerLogout', function()
  ESX.PlayerLoaded = false
  firstSpawn = true
end)

AddEventHandler('esx:onPlayerSpawn', function()
  isDead = false
   HideDeathNui()
  ClearTimecycleModifier()
  SetPedMotionBlur(PlayerPedId(), false)
  ClearExtraTimecycleModifier()
  --EndDeathCam()
  if firstSpawn then
    firstSpawn = false

    if Config.SaveDeathStatus then
      while not ESX.PlayerLoaded do
        Wait(1000)
      end

      ESX.TriggerServerCallback('esx_ambulancejob:getDeathStatus', function(shouldDie)
        if shouldDie then
          Wait(1000)
          SetEntityHealth(PlayerPedId(), 0)
        end
      end)
    end
  end
end)

-- Create blips
CreateThread(function()
  for k, v in pairs(Config.Hospitals) do
    local blip = AddBlipForCoord(v.Blip.coords)

    SetBlipSprite(blip, v.Blip.sprite)
    SetBlipScale(blip, v.Blip.scale)
    SetBlipColour(blip, v.Blip.color)
    SetBlipAsShortRange(blip, true)

    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName(_U('blip_hospital'))
    EndTextCommandSetBlipName(blip)
  end

  while true do
    local Sleep = 1500

    if isDead then
      Sleep = 0
      DisableAllControlActions(0)
      EnableControlAction(0, 47, true) -- G 
      EnableControlAction(0, 245, true) -- T
      EnableControlAction(0, 38, true) -- E

     -- ProcessCamControls()
      if isSearched then
        local playerPed = PlayerPedId()
        local ped = GetPlayerPed(GetPlayerFromServerId(medic))
        isSearched = false

        AttachEntityToEntity(playerPed, ped, 11816, 0.54, 0.54, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
        Wait(1000)
        DetachEntity(playerPed, true, false)
        ClearPedTasksImmediately(playerPed)
      end
    end

    Wait(Sleep)
  end
end)

RegisterNetEvent('esx_ambulancejob:clsearch')
AddEventHandler('esx_ambulancejob:clsearch', function(medicId)
  local playerPed = PlayerPedId()

  if isDead then
    local coords = GetEntityCoords(playerPed)
    local playersInArea = ESX.Game.GetPlayersInArea(coords, 50.0)

    for i = 1, #playersInArea, 1 do
      local player = playersInArea[i]
      if player == GetPlayerFromServerId(medicId) then
        medic = tonumber(medicId)
        isSearched = true
        break
      end
    end
  end
end)

function OnPlayerDeath()
  isDead = true
  g_distressSent = false
  ESX.UI.Menu.CloseAll()
  ClearTimecycleModifier()
  SetTimecycleModifier("REDMIST_blend")
  SetTimecycleModifierStrength(0.7)
  SetExtraTimecycleModifier("fp_vig_red")
  SetExtraTimecycleModifierStrength(1.0)
  SetPedMotionBlur(PlayerPedId(), true)
  TriggerServerEvent('esx_ambulancejob:setDeathStatus', true)
  StartDeathTimer()
  --StartDistressSignal()
end

RegisterNetEvent('esx_ambulancejob:useItem')
AddEventHandler('esx_ambulancejob:useItem', function(itemName)
  ESX.UI.Menu.CloseAll()

  if itemName == 'medikit' then
    local lib, anim = 'anim@heists@narcotics@funding@gang_idle', 'gang_chatting_idle01' -- TODO better animations
    local playerPed = PlayerPedId()

    ESX.Streaming.RequestAnimDict(lib, function()
      TaskPlayAnim(playerPed, lib, anim, 8.0, -8.0, -1, 0, 0, false, false, false)
      RemoveAnimDict(lib)

      wait(1000)
      while IsEntityPlayingAnim(playerPed, lib, anim, 3) do
        Wait(0)
        DisableAllControlActions(0)
      end

      TriggerEvent('esx_ambulancejob:heal', 'big', true)
      ESX.ShowNotification(_U('used_medikit'))
    end)

  elseif itemName == 'bandage' then
    local lib, anim = 'anim@heists@narcotics@funding@gang_idle', 'gang_chatting_idle01' -- TODO better animations
    local playerPed = PlayerPedId()

    ESX.Streaming.RequestAnimDict(lib, function()
      TaskPlayAnim(playerPed, lib, anim, 8.0, -8.0, -1, 0, 0, false, false, false)
      RemoveAnimDict(lib)

      wait(1000)
      while IsEntityPlayingAnim(playerPed, lib, anim, 3) do
        Wait(0)
        DisableAllControlActions(0)
      end

      TriggerEvent('esx_ambulancejob:heal', 'small', true)
      ESX.ShowNotification(_U('used_bandage'))
    end)
  end
end)

function StartDistressSignal()
    CreateThread(function()
        local timer = Config.BleedoutTimer
        while timer > 0 and isDead do
            Wait(0)
            timer = timer - 30
            if IsControlJustReleased(0, 47) then
                SendDistressSignal()
                break
            end
        end
    end)
end

function SendDistressSignal()
    local playerPed = PlayerPedId()
    local myPos = GetEntityCoords(playerPed)
    /*local GPS = 'GPS: ' .. myPos.x .. ', ' .. myPos.y
    local label = "Emergency aid notification"
    ESX.TriggerServerCallback('gksphone:namenumber', function(Races)
      local name = Races[2].firstname .. ' ' .. Races[2].lastname
      TriggerServerEvent('gksphone:gkcs:jbmessage', name, Races[1].phone_number, label, '', GPS, '["ambulance"]', false)
    end)*/

    if not g_distressSent then
      g_distressSent = true
      TriggerServerEvent('esx_ambulancejob:civDown', myPos)
    end 

    /*if not g_distressSent then
      g_distressSent = true
      exports['elder_dispatch']:CitizenDown()
    end*/


end

function DrawGenericTextThisFrame()
  SetTextFont(4)
  SetTextScale(0.0, 0.5)
  SetTextColour(255, 255, 255, 255)
  SetTextDropshadow(0, 0, 0, 0, 255)
  SetTextDropShadow()
  SetTextOutline()
  SetTextCentre(true)
end

function secondsToClock(seconds)
  local seconds, hours, mins, secs = tonumber(seconds), 0, 0, 0

  if seconds <= 0 then
    return 0, 0
  else
    local hours = string.format('%02.f', math.floor(seconds / 3600))
    local mins = string.format('%02.f', math.floor(seconds / 60 - (hours * 60)))
    local secs = string.format('%02.f', math.floor(seconds - hours * 3600 - mins * 60))

    return mins, secs
  end
end

function HideDeathNui()
	g_distressSent = false
	SendNUIMessage({ action = 'hideDeathScreen' })
end

function StartDeathTimer()
    local canPayFine = false
    canRespawn = false
    if Config.EarlyRespawnFine then
        ESX.TriggerServerCallback('esx_ambulancejob:checkBalance', function(canPay)
            canPayFine = canPay
        end)
    end

    local respawnTime = Config.EarlyRespawnTimer
    if ESX.PlayerData and ESX.PlayerData.job and ESX.PlayerData.job.name == "police" then
        respawnTime = 120000
    end
    local earlySpawnTimer = ESX.Math.Round(respawnTime / 1000)
    local bleedoutTimer = ESX.Math.Round(Config.BleedoutTimer / 1000)

    SendNUIMessage({
		action = 'displayDeathScreen',
		counter = earlySpawnTimer,
		dispatched = false,
		canRespawn = canRespawn,
		type = Config.UI.DeathScreenType,
		color = Config.UI.UIColor,
		translationStrings = Config.UI.UIStrings,
		--emsOnline = EMSAvailable or 0,
		emsOnline = ambulanceCount,
		showCount = true
	})

    CreateThread(function()
        while earlySpawnTimer > 0 and isDead do
            Wait(1000)

            if earlySpawnTimer > 0 then
                earlySpawnTimer = earlySpawnTimer - 1

                if isDead then
					SendNUIMessage({
						action = 'updateDeathScreen',
						counter = earlySpawnTimer,
						dispatched = g_distressSent and true or false,
						canRespawn = canRespawn,
						--emsOnline = EMSAvailable or 0,
                        emsOnline = ambulanceCount,
						color = Config.UI.UIColor,
						type = Config.UI.DeathScreenType,
						showCount = true
					})
				else
					HideDeathNui()
					break
				end
            end
        end

        while bleedoutTimer > 0 and isDead do
            Wait(1000)
            if bleedoutTimer > 0 then
                bleedoutTimer = bleedoutTimer - 1
                if isDead then
					SendNUIMessage({
						action = 'updateDeathScreen',
						counter = bleedoutTimer,
						dispatched = g_distressSent or false,
						canRespawn = canRespawn,
						--emsOnline = EMSAvailable or 0,
                        emsOnline = ambulanceCount,
						color = Config.UI.UIColor,
						type = Config.UI.DeathScreenType,
						showCount = true
					})
				else
					HideDeathNui()
					break
				end
            end
        end
    end)

    CreateThread(function()
        local text, timeHeld

        while earlySpawnTimer > 0 and isDead do
            Wait(0)
            if not g_distressSent then
				if IsControlJustReleased(0, 47) then 
					SendDistressSignal()
				end
			else
				Wait(1000)
			end
        end

        while bleedoutTimer > 0 and isDead do
            Wait(0)
            if not g_distressSent then
				if IsControlJustReleased(0, 47) then
					SendDistressSignal()
				end
			end

            if not canRespawn then
				SendNUIMessage({
					action = 'updateDeathScreen',
					counter = bleedoutTimer,
					dispatched = g_distressSent or false,
					canRespawn = true,
					--emsOnline = EMSAvailable or 0,
                    emsOnline = ambulanceCount,
					color = Config.UI.UIColor,
					type = Config.UI.DeathScreenType,
					showCount = true
				})
				canRespawn = true
			end

            if not Config.EarlyRespawnFine then
                if IsControlPressed(0, 38) and timeHeld > 120 then
                    RemoveItemsAfterRPDeath()
                    break
                end
            elseif Config.EarlyRespawnFine and canPayFine then
                if IsControlPressed(0, 38) and timeHeld > 120 then
                    TriggerServerEvent('esx_ambulancejob:payFine')
                    RemoveItemsAfterRPDeath()
                    break
                end
            end
            if IsControlPressed(0, 38) then
                timeHeld += 1
            else
                timeHeld = 0
            end
        end

        if bleedoutTimer < 1 and isDead then
            RemoveItemsAfterRPDeath()
        end
    end)
end

function GetClosestRespawnPoint()
  local PlyCoords = GetEntityCoords(PlayerPedId())
  local ClosestDist, ClosestHospital, ClosestCoord = 10000, {}, nil

  for k, v in pairs(Config.RespawnPoints) do
    local Distance = #(PlyCoords - vector3(v.coords.x, v.coords.y, v.coords.z))
    if Distance <= ClosestDist then
      ClosestDist = Distance
      ClosestHospital = v
      ClosestCoord = vector3(v.coords.x, v.coords.y, v.coords.z)
    end
  end

  return ClosestCoord, ClosestHospital
end

function RemoveItemsAfterRPDeath()
  TriggerServerEvent('esx_ambulancejob:setDeathStatus', false)

  CreateThread(function()
    ESX.TriggerServerCallback('esx_ambulancejob:removeItemsAfterRPDeath', function()
      --local RespawnCoords, ClosestHospital = GetClosestRespawnPoint()

      -- Check if player is dead in cayo
      local playerPed = PlayerPedId()
    
    
    local index=math.random(1,#Config.RespawnPoints)
    spawnPoint = Config.RespawnPoints[index]
    


      ESX.SetPlayerData('loadout', {})

      DoScreenFadeOut(400)
      HideDeathNui()
      RespawnPed(playerPed, spawnPoint.coords, spawnPoint.heading)
      --TriggerServerEvent('ak47_crutch:set', GetPlayerServerId(PlayerId()), 7)
      if not ESX.PlayerData.job or ESX.PlayerData.job.name ~= 'police' then
        --exports.wasabi_crutch:SetCrutchTime(GetPlayerServerId(PlayerId()), 10)
      end
      while not IsScreenFadedOut() do
        Wait(0)
      end
      DoScreenFadeIn(400)
      exports['esx_drilltime']:GiveLevelArmor()
    end)
  end)
end

function RespawnPed(ped, coords, heading)
HideDeathNui()
  SetEntityCoordsNoOffset(cache.ped, coords.x, coords.y, coords.z, false, false, false)
  NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z, heading, true, false)
  -- for test sparrow
  --print("debug1 : ", GetEntityCoords(cache.ped, true))
  Wait(250)

  --print("debug2 : ", GetEntityCoords(cache.ped, true))
  SetPlayerInvincible(cache.ped, false)
  ClearPedBloodDamage(cache.ped)

  TriggerServerEvent('esx:onPlayerSpawn')
  TriggerEvent('esx:onPlayerSpawn')
  TriggerEvent('playerSpawned') -- compatibility with old scripts, will be removed soon
  Wait(250)
  --print("debug3 : ", GetEntityCoords(cache.ped, true))
end

RegisterNetEvent('esx_phone:loaded')
AddEventHandler('esx_phone:loaded', function(phoneNumber, contacts)
  local specialContact = {name = 'Ambulance', number = 'ambulance',
                          base64Icon = 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAABHNCSVQICAgIfAhkiAAAAAlwSFlzAAALEwAACxMBAJqcGAAABp5JREFUWIW1l21sFNcVhp/58npn195de23Ha4Mh2EASSvk0CPVHmmCEI0RCTQMBKVVooxYoalBVCVokICWFVFVEFeKoUdNECkZQIlAoFGMhIkrBQGxHwhAcChjbeLcsYHvNfsx+zNz+MBDWNrYhzSvdP+e+c973XM2cc0dihFi9Yo6vSzN/63dqcwPZcnEwS9PDmYoE4IxZIj+ciBb2mteLwlZdfji+dXtNU2AkeaXhCGteLZ/X/IS64/RoR5mh9tFVAaMiAldKQUGiRzFp1wXJPj/YkxblbfFLT/tjq9/f1XD0sQyse2li7pdP5tYeLXXMMGUojAiWKeOodE1gqpmNfN2PFeoF00T2uLGKfZzTwhzqbaEmeYWAQ0K1oKIlfPb7t+7M37aruXvEBlYvnV7xz2ec/2jNs9kKooKNjlksiXhJfLqf1PXOIU9M8fmw/XgRu523eTNyhhu6xLjbSeOFC6EX3t3V9PmwBla9Vv7K7u85d3bpqlwVcvHn7B8iVX+IFQoNKdwfstuFtWoFvwp9zj5XL7nRlPXyudjS9z+u35tmuH/lu6dl7+vSVXmDUcpbX+skP65BxOOPJA4gjDicOM2PciejeTwcsYek1hyl6me5nhNnmwPXBhjYuGC699OpzoaAO0PbYJSy5vgt4idOPrJwf6QuX2FO0oOtqIgj9pDU5dCWrMlyvXf86xsGgHyPeLos83Brns1WFXLxxgVBorHpW4vfQ6KhkbUtCot6srns1TLPjNVr7+1J0PepVc92H/Eagkb7IsTWd4ZMaN+yCXv5zLRY9GQ9xuYtQz4nfreWGdH9dNlkfnGq5/kdO88ekwGan1B3mDJsdMxCqv5w2Iq0khLs48vSllrsG/Y5pfojNugzScnQXKBVA8hrX51ddHq0o6wwIlgS8Y7obZdUZVjOYLC6e3glWkBBVHC2RJ+w/qezCuT/2sV6Q5VYpowjvnf/iBJJqvpYBgBS+w6wVB5DLEOiTZHWy36nNheg0jUBs3PoJnMfyuOdAECqrZ3K7KcACGQp89RAtlysCphqZhPtRzYlcPx+ExklJUiq0le5omCfOGFAYn3qFKS/fZAWS7a3Y2wa+GJOEy4US+B3aaPUYJamj4oI5LA/jWQBt5HIK5+JfXzZsJVpXi/ac8+mxWIXWzAG4Wb4g/jscNMp63I4U5FcKaVvsNyFALokSA47Kx8PVk83OabCHZsiqwAKEpjmfUJIkoh/R+L9oTpjluhRkGSPG4A7EkS+Y3HZk0OXYpIVNy01P5yItnptDsvtIwr0SunqoVP1GG1taTHn1CloXm9aLBEIEDl/IS2W6rg+qIFEYR7+OJTesqJqYa95/VKBNOHLjDBZ8sDS2998a0Bs/F//gvu5Z9NivadOc/U3676pEsizBIN1jCYlhClL+ELJDrkobNUBfBZqQfMN305HAgnIeYi4OnYMh7q/AsAXSdXK+eH41sykxd+TV/AsXvR/MeARAttD9pSqF9nDNfSEoDQsb5O31zQFprcaV244JPY7bqG6Xd9K3C3ALgbfk3NzqNE6CdplZrVFL27eWR+UASb6479ULfhD5AzOlSuGFTE6OohebElbcb8fhxA4xEPUgdTK19hiNKCZgknB+Ep44E44d82cxqPPOKctCGXzTmsBXbV1j1S5XQhyHq6NvnABPylu46A7QmVLpP7w9pNz4IEb0YyOrnmjb8bjB129fDBRkDVj2ojFbYBnCHHb7HL+OC7KQXeEsmAiNrnTqLy3d3+s/bvlVmxpgffM1fyM5cfsPZLuK+YHnvHELl8eUlwV4BXim0r6QV+4gD9Nlnjbfg1vJGktbI5UbN/TcGmAAYDG84Gry/MLLl/zKouO2Xukq/YkCyuWYV5owTIGjhVFCPL6J7kLOTcH89ereF1r4qOsm3gjSevl85El1Z98cfhB3qBN9+dLp1fUTco+0OrVMnNjFuv0chYbBYT2HcBoa+8TALyWQOt/ImPHoFS9SI3WyRajgdt2mbJgIlbREplfveuLf/XXemjXX7v46ZxzPlfd8YlZ01My5MUEVdIY5rueYopw4fQHkbv7/rZkTw6JwjyalBCHur9iD9cI2mU0UzD3P9H6yZ1G5dt7Gwe96w07dl5fXj7vYqH2XsNovdTI6KMrlsAXhRyz7/C7FBO/DubdVq4nBLPaohcnBeMr3/2k4fhQ+Uc8995YPq2wMzNjww2X+vwNt1p00ynrd2yKDJAVN628sBX1hZIdxXdStU9G5W2bd9YHR5L3f/CNmJeY9G8WAAAAAElFTkSuQmCC'}

  TriggerEvent('esx_phone:addSpecialContact', specialContact.name, specialContact.number, specialContact.base64Icon)
end)

AddEventHandler('esx:onPlayerDeath', function(data)
  OnPlayerDeath()
end)

RegisterNetEvent('esx_ambulancejob:revive')
AddEventHandler('esx_ambulancejob:revive', function(isems)
  local playerPed = PlayerPedId()
  local coords = GetEntityCoords(playerPed)
  TriggerServerEvent('esx_ambulancejob:setDeathStatus', false)

  DoScreenFadeOut(200)

  while not IsScreenFadedOut() do
    Wait(50)
  end

  
  local index=math.random(1,#Config.RespawnPoints)
  spawnPoint = Config.RespawnPoints[index]
  

  RespawnPed(playerPed, spawnPoint.coords, spawnPoint.heading)
  
  if isems then
    --TriggerServerEvent('ak47_crutch:set', GetPlayerServerId(PlayerId()), 7)
    if not ESX.PlayerData.job or ESX.PlayerData.job.name ~= 'police' then
      --exports.wasabi_crutch:SetCrutchTime(GetPlayerServerId(PlayerId()), 10)
    end
  end
  isDead = false
  ClearTimecycleModifier()
  SetPedMotionBlur(playerPed, false)
  ClearExtraTimecycleModifier()
  --EndDeathCam()
  DoScreenFadeIn(200)
  restorePlayerHead()
  exports['esx_drilltime']:GiveLevelArmor()
end)

RegisterNetEvent('esx_ambulancejob:revive_deathmatch')
AddEventHandler('esx_ambulancejob:revive_deathmatch', function(isems)
  local coords = cache.coords or GetEntityCoords(cache.ped, false)
  local distance = #(g_playerCoords - coords)
  if distance > 2.0 then
    print('debug position :', coords, g_playerCoords)
    coords = g_playerCoords
  end
  print("debug position dead : ", coords.x, coords.y, coords.z)
  TriggerServerEvent('esx_ambulancejob:setDeathStatus', false)

  DoScreenFadeOut(200)

  while not IsScreenFadedOut() do
    Wait(50)
  end

  RespawnPed(cache.ped, coords, 0.0)
  if isems then
    --TriggerServerEvent('ak47_crutch:set', GetPlayerServerId(PlayerId()), 7)
    --exports.wasabi_crutch:SetCrutchTime(GetPlayerServerId(PlayerId()), 10)
  end
  isDead = false
  ClearTimecycleModifier()
  SetPedMotionBlur(cache.ped, false)
  ClearExtraTimecycleModifier()
  EndDeathCam()
  DoScreenFadeIn(200)
  restorePlayerHead()
end)

RegisterNetEvent('esx_ambulancejob:revive_in_position')
AddEventHandler('esx_ambulancejob:revive_in_position', function(_coords)
  TriggerServerEvent('esx_ambulancejob:setDeathStatus', false)

  DoScreenFadeOut(200)

  while not IsScreenFadedOut() do
    Wait(50)
  end

  local formattedCoords = {x = ESX.Math.Round(_coords.x, 1), y = ESX.Math.Round(_coords.y, 1), z = ESX.Math.Round(_coords.z, 1)}

  RespawnPed(cache.ped, formattedCoords, 0.0)
  isDead = false
  ClearTimecycleModifier()
  SetPedMotionBlur(cache.ped, false)
  ClearExtraTimecycleModifier()
  EndDeathCam()
  DoScreenFadeIn(200)
  restorePlayerHead()
end)

RegisterNetEvent('esx_ambulancejob:revive_freeze')
AddEventHandler('esx_ambulancejob:revive_freeze', function()
  local playerPed = PlayerPedId()
  local coords = GetEntityCoords(playerPed)
  TriggerServerEvent('esx_ambulancejob:setDeathStatus', false)

  DoScreenFadeOut(200)

  while not IsScreenFadedOut() do
    Wait(50)
  end

  --local formattedCoords = {x = ESX.Math.Round(coords.x, 1), y = ESX.Math.Round(coords.y, 1), z = ESX.Math.Round(coords.z, 1)}
  local index=math.random(1,#Config.RespawnPoints)
  local spawnPoint = Config.RespawnPoints[index]

  RespawnPed(playerPed, spawnPoint.coords, spawnPoint.heading)
  isDead = false
  ClearTimecycleModifier()
  SetPedMotionBlur(playerPed, false)
  ClearExtraTimecycleModifier()
  --EndDeathCam()
  DoScreenFadeIn(200)
  restorePlayerHead()
  FreezeEntityPosition(playerPed, true)
  Wait(5000)
  FreezeEntityPosition(playerPed, false)
end)

-- Load unloaded IPLs
if Config.LoadIpl then
  RequestIpl('Coroner_Int_on') -- Morgue
end

local cam = nil

local angleY = 0.0

local angleZ = 0.0

-------------------------------------------------------

-----------------DEATH CAMERA FUNCTIONS ---------------

--------------------------------------------------------

-- initialize camera

function StartDeathCam()
  ClearFocus()
  local playerPed = PlayerPedId()
  cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", GetEntityCoords(playerPed), 0, 0, 0, GetGameplayCamFov())
  SetCamActive(cam, true)
  RenderScriptCams(true, true, 1000, true, false)
end

-- destroy camera

function EndDeathCam()
  ClearFocus()
  RenderScriptCams(false, false, 0, true, false)
  DestroyCam(cam, false)
  cam = nil
end
-- process camera controls
function ProcessCamControls()
  local playerPed = PlayerPedId()
  local playerCoords = GetEntityCoords(playerPed)
  -- disable 1st person as the 1st person camera can cause some glitches
  DisableFirstPersonCamThisFrame()
  -- calculate new position
  local newPos = ProcessNewPosition()
  SetFocusArea(newPos.x, newPos.y, newPos.z, 0.0, 0.0, 0.0)
  -- set coords of cam
  SetCamCoord(cam, newPos.x, newPos.y, newPos.z)
  -- set rotation
  PointCamAtCoord(cam, playerCoords.x, playerCoords.y, playerCoords.z + 0.5)
end

function ProcessNewPosition()
  local mouseX = 0.0
  local mouseY = 0.0
  -- keyboard
  if (IsInputDisabled(0)) then
    -- rotation
    mouseX = GetDisabledControlNormal(1, 1) * 8.0

    mouseY = GetDisabledControlNormal(1, 2) * 8.0
    -- controller
  else
    mouseX = GetDisabledControlNormal(1, 1) * 1.5

    mouseY = GetDisabledControlNormal(1, 2) * 1.5
  end

  angleZ = angleZ - mouseX -- around Z axis (left / right)

  angleY = angleY + mouseY -- up / down
  -- limit up / down angle to 90°

  if (angleY > 89.0) then
    angleY = 89.0
  elseif (angleY < -89.0) then
    angleY = -89.0
  end
  local pCoords = GetEntityCoords(PlayerPedId())
  local behindCam = {x = pCoords.x + ((Cos(angleZ) * Cos(angleY)) + (Cos(angleY) * Cos(angleZ))) / 2 * (5.5 + 0.5),

                     y = pCoords.y + ((Sin(angleZ) * Cos(angleY)) + (Cos(angleY) * Sin(angleZ))) / 2 * (5.5 + 0.5),

                     z = pCoords.z + ((Sin(angleY))) * (5.5 + 0.5)}
  local rayHandle = StartShapeTestRay(pCoords.x, pCoords.y, pCoords.z + 0.5, behindCam.x, behindCam.y, behindCam.z, -1, PlayerPedId(), 0)

  local a, hitBool, hitCoords, surfaceNormal, entityHit = GetShapeTestResult(rayHandle)

  local maxRadius = 1.9
  if (hitBool and Vdist(pCoords.x, pCoords.y, pCoords.z + 0.5, hitCoords) < 5.5 + 0.5) then
    maxRadius = Vdist(pCoords.x, pCoords.y, pCoords.z + 0.5, hitCoords)
  end

  local offset = {x = ((Cos(angleZ) * Cos(angleY)) + (Cos(angleY) * Cos(angleZ))) / 2 * maxRadius,
                  y = ((Sin(angleZ) * Cos(angleY)) + (Cos(angleY) * Sin(angleZ))) / 2 * maxRadius, z = ((Sin(angleY))) * maxRadius}

  local pos = {x = pCoords.x + offset.x, y = pCoords.y + offset.y, z = pCoords.z + offset.z}

  return pos
end


local disabled = false

Citizen.CreateThread(function()
    while true do
        if isDead then
           if not disabled then
				disabled = true
				exports['pma-voice']:overrideProximityCheck(function(player)
					return false
				end)
		   end
		else
			if disabled then
				disabled = false
				exports['pma-voice']:resetProximityCheck()
			end
        end
    	Citizen.Wait(1000)
    end
end)

function IsTargetDead(target)
  local result = promise:new()
    ESX.TriggerServerCallback('esx_ambulancejob:getPlayerDeathStatus', function(data) 
		  result:resolve(data)  
    end, target)
    return Citizen.Await(result)
end

function IsPlayerDead()
  local result = promise:new()
    ESX.TriggerServerCallback('esx_ambulancejob:getPlayerDeathStatus', function(data) 
		  result:resolve(data)  
    end)
    return Citizen.Await(result)
end

exports('IsPlayerDead', IsPlayerDead)
exports('IsTargetDead', IsTargetDead)

RegisterNetEvent('esx_ambulancejob:removeCrutch')
AddEventHandler('esx_ambulancejob:removeCrutch', function()
  --exports.wasabi_crutch:RemoveCrutch(GetPlayerServerId(PlayerId()))
end)

function restorePlayerHead()
  if GetResourceState("DrillKill") == "started" then 
    exports['DrillKill']:restorePlayerHead(cache.ped)
  end
end

