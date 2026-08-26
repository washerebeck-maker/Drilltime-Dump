
ESX = exports['es_extended']:getSharedObject()


Citizen.CreateThread(function()
	

	while ESX.GetPlayerData().job == nil do
		Citizen.Wait(10)
	end

	__G.PlayerJob = ESX.GetPlayerData().job

end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)  
    __G.PlayerJob  = xPlayer.job
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)  
    __G.PlayerJob  = job
end)