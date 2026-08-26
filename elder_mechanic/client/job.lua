--[[


    Do NOT CHANGE any of the code in this file,
    
    if you do so, do it on your own risk and no support will be given


]]

ESX = nil
PlayerData = {}

jobName = nil

CreateThread(function()
    while (ESX == nil) do
		ESX = exports["es_extended"]:getSharedObject()
		Wait(100)
    end
    
    while (ESX.GetPlayerData() == nil or ESX.GetPlayerData().job == nil or ESX.GetPlayerData().job.name == nil) do
		Wait(100)
	end

    PlayerData = ESX.GetPlayerData()
    
    jobName = getJobName()
    updateUICurrentJob()
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    PlayerData = xPlayer   
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    PlayerData.job = job
    
    jobName = getJobName()
    updateUICurrentJob()
end)

function getJobName()
    if (PlayerData ~= nil and PlayerData.job ~= nil and PlayerData.job.name ~= nil) then
        return PlayerData.job.name
	end
	return nil
end


CreateThread(function()
    while PlayerData.job == nil do Wait(10) end
    while true do
        local wait = 3000
		local ped = PlayerPedId()
		local ped_coords = GetEntityCoords(ped)
		if Config.Positions[PlayerData.job.name] and PlayerData.job.grade_name == 'boss' then
            local location = Config.Positions[PlayerData.job.name].boss
            local distance = GetDistanceBetweenCoords(ped_coords, location ,true)
			if distance <= 15.0 then
				wait = 0
                DrawMarker(21,location, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 1.0, 1.0, 1.0, 0, 0,255 ,100 ,false, true, 2, true, false, false, false)
                if distance <=2.0 then
                    ESX.ShowHelpNotification("~b~[E]~s~ BOSS MENU")
                    if IsControlJustReleased(0, 38) then
                        TriggerEvent('esx_society:openBossMenu', PlayerData.job.name, function(data, menu)
                            menu.close()
                        end, {wash = false})
                    end
                end 
			end
        else
            wait = 3000
        end
		
        Citizen.Wait(wait)
    end
end)