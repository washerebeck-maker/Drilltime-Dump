
local InPreliminaryPhase = false
local InGunGameMatch = false
local InCountDownPhase = false
local InMainPhase = false
local LastPosition = nil
local PlayerLevel = nil
local GunGameScore = {}
local IsWinner = false


RegisterNetEvent('elder_events:gungame:client:preliminary_phase_start')
AddEventHandler('elder_events:gungame:client:preliminary_phase_start', function()  
    InPreliminaryPhase = true
    StartGunGamePreliminaryPhase()
end)

RegisterNetEvent('elder_events:gungame:client:preliminary_phase_end')
AddEventHandler('elder_events:gungame:client:preliminary_phase_end', function()  
    InPreliminaryPhase = false
end)

StartGunGamePreliminaryPhase = function()
    local timer = Config.GunGame.PreliminaryPhaseDuration
    Citizen.CreateThread(function()
        while InPreliminaryPhase and timer > 0 do
            Citizen.Wait(1000)
            timer = timer - 1
        end
    end)
    Citizen.CreateThread(function()
        while InPreliminaryPhase do
            Citizen.Wait(1)
            if InGunGameMatch then
                DrawGunGamePreliminaryPhase(0.70, 0.95, SecondsToClock(timer), "The Fight Starts Soon. Please Wait ...","DRILLTIME GUNGAME MATCH", {255, 255, 255},{ 255, 255, 255 }, 0.5)
                DisablePlayerFiring(GetPlayerPed(-1),true)
                DisableControlAction(0, 106, true)
            else
                DrawGunGamePreliminaryPhase(0.70, 0.95, SecondsToClock(timer), "Type ~b~/gungame~s~ to participate.","DRILLTIME GUNGAME MATCH", {255, 255, 255},{ 255, 255, 255 }, 0.5)
            end
        end
    end)
end

RegisterNetEvent('elder_events:gungame:client:reject_join')
AddEventHandler('elder_events:gungame:client:reject_join', function()  
    InPreliminaryPhase = false
    Notify('You cannot join, max number of players reached.')
end)

RegisterNetEvent('elder_events:gungame:client:accept_join')
AddEventHandler('elder_events:gungame:client:accept_join', function()  
    LastPosition = GetEntityCoords(cache.ped)
    InGunGameMatch = true
    Teleport(PlayerPedId(), Config.GunGame.SpawnPoints[math.random(1, #Config.GunGame.SpawnPoints)], true)
    --TriggerEvent('esx_ambulancejob:revive_deathmatch') 
end)

RegisterCommand('gungame', function()
    if not InPreliminaryPhase or InGunGameMatch then 
        return 
    end
    TriggerServerEvent('elder_events:gungame:server:join')
end)

-- Coutdonw

RegisterNetEvent('elder_events:gungame:client:countdown_phase_start')
AddEventHandler('elder_events:gungame:client:countdown_phase_start', function()  
    if not InGunGameMatch then 
        return 
    end
    InCountDownPhase = true
    StartGunGameCountDownPhase()
end)

RegisterNetEvent('elder_events:gungame:client:countdown_phase_end')
AddEventHandler('elder_events:gungame:client:countdown_phase_end', function()  
    if not InGunGameMatch then 
        return 
    end
    InCountDownPhase = false
end)

StartGunGameCountDownPhase = function()
    local timer = Config.GunGame.CountDownPhaseDuration
    Citizen.CreateThread(function()
        while InCountDownPhase and timer > 0 do
            Citizen.Wait(1000)
            timer = timer - 1
            if timer == 10 then
                TriggerEvent('InteractSound_CL:PlayOnOne', 'count_down', 1.0)
            end
        end
    end)
    Citizen.CreateThread(function()
        while InCountDownPhase do
            Citizen.Wait(1)
            DrawGunGamePreliminaryPhase(0.70, 0.95, SecondsToClock(timer), "Count Down Started. Get Ready !","DRILLTIME GUNGAME MATCH", {255, 255, 255},{ 255, 255, 255 }, 0.5)
            if InGunGameMatch then
                DisablePlayerFiring(GetPlayerPed(-1),true)
                DisableControlAction(0, 106, true)
            end
        end
    end)
end

-- Main Phase

RegisterNetEvent('elder_events:gungame:client:main_phase_start')
AddEventHandler('elder_events:gungame:client:main_phase_start', function(score)  
    if not InGunGameMatch then 
        return 
    end
    InMainPhase = true
    GunGameScore = score
    PlayerLevel = 1
    GiveLevelWeapon()
    StartGunGameMainPhase()
    SetPedArmour(cache.ped, 100)
    TriggerEvent('InteractSound_CL:PlayOnOne', 'gungame', 1.0)
end)

RegisterNetEvent('elder_events:gungame:client:main_phase_end')
AddEventHandler('elder_events:gungame:client:main_phase_end', function(score)  
    if not InGunGameMatch then 
        return 
    end
    if not IsWinner then
        TriggerEvent('InteractSound_CL:PlayOnOne', 'gungame_lost', 1.0)
    end
    DrawGunGameWinner(score)
    RemoveAllPedWeapons(cache.ped)
    Teleport(cache.ped, LastPosition, false)
    InMainPhase = false
    InGunGameMatch = false
    LastPosition = nil
    PlayerLevel = nil
    GunGameScore = {}
    IsWinner = false
end)

StartGunGameMainPhase = function()
    Citizen.CreateThread(function()
        while InMainPhase do
            Citizen.Wait(1)
            if GunGameScore[1] then
                DrawGunGamePlayerRank(0.17, 0.45, 0.5, string.upper(GunGameScore[1]), "1", {255,255,255}, {255,255,255}, {0,0,0, 120}, {255,215,0,220})
            end
            if GunGameScore[2] then
                DrawGunGamePlayerRank(0.17, 0.51, 0.5, string.upper(GunGameScore[2]), "2", {255,255,255}, {255,255,255}, {0,0,0, 120}, {192,192,192,220})
            end
            if GunGameScore[2] then
                DrawGunGamePlayerRank(0.17, 0.57, 0.5, string.upper(GunGameScore[2]), "3", {255,255,255}, {255,255,255}, {0,0,0, 120}, {205,127,50,220})
            end
            CheckWeapons()
        end
    end)
end

GiveLevelWeapon = function()
    RemoveAllPedWeapons(cache.ped)
    GiveWeaponToPed(cache.ped, Config.GunGame.Guns[PlayerLevel], 250, true, true)
end

CheckWeapons = function()
    if IsPedArmed(cache.ped, 6) then
        local hasWeapon, currentWeapon = GetCurrentPedWeapon(cache.ped, true)
        if not IsValidWeapon(currentWeapon) then
            TriggerEvent('ox_inventory:disarm', true)
            GiveLevelWeapon()
        end
    end
end

IsValidWeapon = function(weapon_hash)
    return weapon_hash == GetHashKey(Config.GunGame.Guns[PlayerLevel])
end

DrawGunGameWinner = function(score)
    local timer = 15
    CreateThread(function()
        while timer > 0 do
            Wait(1000)
            timer = timer - 1
        end
    end)
    CreateThread(function()
        while timer > 0 do
            if Config.GunGame.Reward.Enable then
                DrawGunGameWinnerReward(0.69, 0.05, 0.5, "REWARD : "..Config.GunGame.Reward.Count .." "..GetItemLabel(Config.GunGame.Reward.Item), "GUNGAME WINNER >> " .. string.upper(score[1]), {255,255,255}, {255,255,255}, {7, 151, 240,220},{255,0,0, 220})
            else
                DrawGunGameWinnerReward(0.69, 0.05, 0.5, "REWARD : NO REWARD", "GUNGAME WINNER >> " .. string.upper(score[1]), {255,255,255}, {255,255,255}, {7, 151, 240,220},{255,0,0, 220})
            end
            Wait(1)
        end
    end)
end

RegisterNetEvent('elder_events:gungame:client:upgrade_level')
AddEventHandler('elder_events:gungame:client:upgrade_level', function()  
    PlayerLevel = PlayerLevel + 1
    TriggerEvent('InteractSound_CL:PlayOnOne', 'level_up', 1.0)
    GiveLevelWeapon()
    SetPedArmour(cache.ped, 100)
    TriggerEvent('esx_basicneeds:healPlayer')
    SetPedArmour(PlayerPedId(), 100)
end)

RegisterNetEvent('elder_events:gungame:client:update_score')
AddEventHandler('elder_events:gungame:client:update_score', function(score)  
    GunGameScore = score
end)

RegisterNetEvent('elder_events:gungame:client:update_winner')
AddEventHandler('elder_events:gungame:client:update_winner', function()  
    IsWinner = true
    TriggerEvent('InteractSound_CL:PlayOnOne', 'gungame_winner', 1.0)
end)

-- DEATH

AddEventHandler('gameEventTriggered', function(name, data)
    if name == "CEventNetworkEntityDamage" then
		if not InGunGameMatch then 
            return 
        end
        local victim = tonumber(data[1])
		local killer = tonumber(data[2])
        local weapon = data[7]
        local victim_died = tonumber(data[6]) == 1
        if not victim_died then return end
        if victim ~= cache.ped then return end
        TriggerEvent('elder_events:gungame:client:revive')
        if victim == killer or not IsPedAPlayer(killer) then
            return
        end
        local killer_id = GetPlayerServerId(NetworkGetPlayerIndexFromPed(killer))
        TriggerServerEvent('elder_events:gungame:server:on_death', killer_id, weapon)
    end
end)

RegisterNetEvent('elder_events:gungame:client:revive')
AddEventHandler('elder_events:gungame:client:revive', function() 
    Wait(Config.GunGame.ReviveTime * 1000)
    local coords = Config.GunGame.SpawnPoints[math.random(1, #Config.GunGame.SpawnPoints)]
    if not InGunGameMatch then
        coords = LastPosition
    end
	TriggerServerEvent('esx_ambulancejob:setDeathStatus', false)
	SetEntityCoordsNoOffset(cache.ped, coords.x, coords.y, coords.z, false, false, false, true)
	NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z, 0.0, true, false)
	SetPlayerInvincible(cache.ped, false)
	ClearPedBloodDamage(cache.ped)
	TriggerServerEvent('esx:onPlayerSpawn')
	TriggerEvent('esx:onPlayerSpawn')
	TriggerEvent('playerSpawned')
    --TriggerEvent('esx_ambulancejob:revive_in_position',coords)
    SetPedArmour(cache.ped, 100)
    GiveLevelWeapon()
end)


------ TEST

RegisterCommand("hhh", function()
    DrawGunGameWinner({[1] = "Tsd sd sdsd"})
end)

RegisterCommand("hhh1", function()
    DrawEndRound("red")
end)




