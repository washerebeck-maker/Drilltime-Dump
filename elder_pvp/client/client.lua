ESX = exports['es_extended']:getSharedObject()

CurrentMatch = nil
CurrentRound = nil
InPreliminaryPhase = false
InCountDownPhase = false
LastPosition = nil

CreateThread(function()
	Wait(1000)
	TriggerServerEvent('elder_pvp:server:loaded')
end)

RegisterCommand(Config.OpenCommand, function()
	if CurrentMatch then 
		return Notify('You are in a pvp match', 'warning')
	end
	OpenPVPMenu()
end)

RegisterNetEvent("elder_pvp:client:notify")
AddEventHandler("elder_pvp:client:notify", function(msg, type) 
	Notify(msg, type)
end)

RegisterNetEvent('elder_pvp:client:create', function()
	if exports.esx_ambulancejob:IsPlayerDead() then
		return Notify('You cannot create match while you dead', 'error')
	end
	CreateMatch()
end)

RegisterNetEvent('elder_pvp:client:listJoin', function()
	ListJoin()
end)

RegisterNetEvent('elder_pvp:client:listOnGoing', function()
	ListOnGoing()
end)

RegisterNetEvent('elder_pvp:client:ranks', function()
	RanksMenu()
end)

RegisterNetEvent('elder_pvp:client:join', function(args)
	if CurrentMatch then 
		return Notify('You are in a pvp match', 'warning')
	end
	if not exports.esx_ambulancejob:IsPlayerDead() then
		JoinMatch(args)
	else
		return Notify('You cant join while dead !', 'error')
	end
end)

RegisterNetEvent('elder_pvp:client:preliminaryPhaseStart', function(match)
	lib.hideContext()
	CurrentMatch = match
	InPreliminaryPhase = true
	local time = Config.PreliminaryPhaseDuration
	CreateThread(function()
		while InPreliminaryPhase and time > 0 do 
			Wait(1000)
			time = time - 1
		end
	end)
	CreateThread(function()
		while InPreliminaryPhase do 
			Wait(1)
			DrawNiceText(0.01,0.60 ,0.48,('PVP will begin in ~r~%s~s~'):format(SecondsToClock(time)))
		end
	end)
end)

RegisterNetEvent('elder_pvp:client:preliminaryPhaseEnd', function()
	InPreliminaryPhase = false
	LastPosition = GetEntityCoords(PlayerPedId())
end)

RegisterNetEvent('elder_pvp:client:countDownPhaseStart', function(id)
	RemoveAllPedWeapons(cache.ped, true)
	lib.hideContext()
	InCountDownPhase = true
	local time = Config.CountDownPhaseDuration
	SetEntityHealth(PlayerPedId(), GetEntityMaxHealth(PlayerPedId()))
	SetPedArmour(PlayerPedId(), 100)
	FreezeEntityPosition(PlayerPedId(), true)

	CreateThread(function()
		while InCountDownPhase and time > 0 do 
			Wait(1000)
			time = time - 1
		end
	end)
	CreateThread(function()
		while InCountDownPhase do 
			Wait(1)
			DrawNiceText(0.01,0.65 ,0.48,('Round start in %s'):format(SecondsToClock(time)))
		end
	end)
end)

RegisterNetEvent('elder_pvp:client:countDownPhaseEnd', function()
	InCountDownPhase = false
	FreezeEntityPosition(PlayerPedId(), false)
	GiveWeaponToPed(PlayerPedId(), GetHashKey(CurrentMatch.weapon), 500, true, true)
end)

RegisterNetEvent('elder_pvp:client:roundStart', function(id, round)
	CurrentRound = round
	StartRoundMessage(CurrentRound)
	local time = Config.GamePhaseDuration
	CreateThread(function()
		while CurrentRound and time > 0 do 
			Wait(1000)
			time = time - 1
		end
	end)
	CreateThread(function()
		while CurrentRound do 
			Wait(1)
			DrawNiceText(0.01,0.65 ,0.48,('Round ~y~%s~s~ in progress ~r~%s~s~'):format(CurrentRound, SecondsToClock(time)))
		end
	end)
end)


RegisterNetEvent('elder_pvp:client:roundEnd', function(id, round, result)
	EndRoundMessage(round)
	RemoveWeaponFromPed(PlayerPedId(), CurrentMatch.weapon)
	CurrentRound = nil
end)

RegisterNetEvent("gameEventTriggered", function(eventName, args)
    if eventName == "CEventNetworkEntityDamage" then
        if not CurrentMatch then return end
		local victimEntity, isFatal = args[1], args[6] == 1
        if victimEntity ~= PlayerPedId() then return end
		if isFatal then
			if CurrentRound and CurrentRound <= CurrentMatch.rounds then
				TriggerServerEvent('elder_pvp:server:onDeath', CurrentMatch.id, CurrentRound)
				Wait(2000)
				local playerPed = PlayerPedId()
                local coords = GetEntityCoords(playerPed)
				TriggerServerEvent('esx_ambulancejob:setDeathStatus', false)
				SetEntityCoordsNoOffset(playerPed, coords.x, coords.y, coords.z, false, false, false, true)
				NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z, 0.0, true, false)
				SetPlayerInvincible(playerPed, false)
				ClearPedBloodDamage(playerPed)
				TriggerServerEvent('esx:onPlayerSpawn')
				TriggerEvent('esx:onPlayerSpawn')
				TriggerEvent('playerSpawned')
			end
        end
    end
end)

RegisterNetEvent('elder_pvp:client:matchResult', function(result)
	CurrentMatch = nil
	CurrentRound = nil
	EndFightMessage(result)
	SetEntityCoordsNoOffset(PlayerPedId(), LastPosition.x, LastPosition.y, LastPosition.z, false, false, false, true)
	LastPosition = nil
end)

RegisterNetEvent('elder_pvp:client:cancelMatch', function(result)
	if CurrentMatch then
		RemoveWeaponFromPed(PlayerPedId(), CurrentMatch.weapon)
	end
	CurrentMatch = nil
	CurrentRound = nil
	EndFightMessage('draw')
	SetEntityCoordsNoOffset(PlayerPedId(), LastPosition.x, LastPosition.y, LastPosition.z, false, false, false, true)
	LastPosition = nil
end)

RegisterNetEvent('elder_pvp:client:cityTeleport', function()
	local distance = GetDistanceBetweenCoords(GetEntityCoords(cache.ped), Config.MapLocations.coords, true)
	if distance > Config.MapLocations.radius then
		return Notify('You can use this onlt in PVP Map', 'warning')
	end
	ESX.Game.Teleport(cache.ped, Config.CityLocation)
end)

AddEventHandler('onResourceStop', function(resource)
	if resource == GetCurrentResourceName() then
		TriggerServerEvent('elder_pvp:server:set')
		if CurrentMatch then
			RemoveWeaponFromPed(PlayerPedId(), CurrentMatch.weapon)
		end
		CurrentMatch = nil
		CurrentRound = nil
		if LastPosition then
			SetEntityCoordsNoOffset(PlayerPedId(), LastPosition.x, LastPosition.y, LastPosition.z, false, false, false, true)
			LastPosition = nil
		end
	end
end)
