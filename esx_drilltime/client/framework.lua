
ESX = exports['es_extended']:getSharedObject()

PlayerJob = {}
IsAuthorizedJob = false
PlayerLoaded = false
Streamers = {}
Staff = {}
TrailStaff = {}
ModStaff = {}
GangManagers = {}
KosManagers = {}

function CheckJob()
	if PlayerJob then
		for _,v in pairs(Config.PlayersID.jobs) do
			if PlayerJob.name == v then return true end
		end
	end
	return false
end

CreateThread(function()
    while ESX == nil do
        Wait(50)
    end
    PlayerJob = ESX.PlayerData.job or {} 
    IsAuthorizedJob = CheckJob()    
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)  
    PlayerJob = xPlayer.job or {}
    IsAuthorizedJob = CheckJob()
    PlayerLoaded = true
    ESX.TriggerServerCallback('esx_drilltime:staff_streamer:server:get_data', function(result)
        Staff = result.Staff
        TrailStaff = result.TrailStaff
        ModStaff = result.ModStaff
        Streamer = result.Streamer
        GangManagers = result.GangManagers
        KosManagers = result.KosManagers
    end)
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)  
    PlayerJob = job or {}
    IsAuthorizedJob = CheckJob()
end)