
ESX = exports['es_extended']:getSharedObject()

Citizen.CreateThread(function()
	
	if ESX.IsPlayerLoaded() then
		while ESX.GetPlayerData().job == nil do
			Citizen.Wait(10)
		end
		__G.PlayerJob = ESX.GetPlayerData().job
		__G.PlayerGang = GetGangJob()
		__G.DrugDealerZonesLevel = GetLevel()
	end
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)  
    __G.PlayerJob  = xPlayer.job
	__G.PlayerGang = GetGangJob()
	__G.DrugDealerZonesLevel = GetLevel()
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)  
    __G.PlayerJob  = job
end)
