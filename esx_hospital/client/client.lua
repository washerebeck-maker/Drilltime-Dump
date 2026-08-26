ESX = exports['es_extended']:getSharedObject()

local PlayerData              = {}

Citizen.CreateThread(function()
    while ESX.GetPlayerData().job == nil do
        Citizen.Wait(10)
    end

    ESX.PlayerData = ESX.GetPlayerData()
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    ESX.PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    ESX.PlayerData.job = job
end)

Citizen.CreateThread(function()
   
    while true do
        local sleep = 5000
        local _source = source
        local ped = PlayerPedId()
        local pedCoords = GetEntityCoords(ped)

        for i = 1, #Config.Doctor, 1 do
            local konum = Config.Doctor[i]
            local userDst = GetDistanceBetweenCoords(pedCoords, konum.x, konum.y, konum.z, true)

            if userDst <= 15 then
                sleep = 2
                if userDst <= 5 then
                    DrawText3D(konum.x, konum.y, konum.z, 'Press [E] For Check in/Heal $'.. Config.doctorPrice)
                    DrawMarker(27, konum.x, konum.y, konum.z-0.9, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 1.0, 1.0, 1.0, 255, 195, 18, 100, false, true, 2, false, false, false, false)
                    if userDst <= 1.5 then
                        if IsControlJustPressed(0, 38) then
                            ESX.TriggerServerCallback('crack:getEms', function(cb)
                                canEms = cb
                            end, i)
                            while canEms == nil do
                                Wait(0)
                            end
                            if Config.DoctorLimit then
                                if canEms == true then
                                    
                                    ESX.TriggerServerCallback('crack-custom:parakontrol', function(hasEnoughMoney) --crack
                                        if hasEnoughMoney then
                                            local formattedCoords = {
                                                x = ESX.Math.Round(pedCoords.x, 1),
                                                y = ESX.Math.Round(pedCoords.y, 1),
                                                z = ESX.Math.Round(pedCoords.z, 1)
                                            }
                                            TriggerEvent('esx_ambulancejob:revive', formattedCoords)
                                            TriggerServerEvent('crack-custom:money')
                                        else
                                            exports['okokNotify']:Alert('Medical Center','You Dont Need Any Medical attention!', 5000, 'error') --crack
                                        end
                                    end)

                                elseif canEms == 'no_ems' then
                                    exports['okokNotify']:Alert('Medical Center', 'UFF', 5000, 'error')                          
                                end 
                            else
                                ESX.TriggerServerCallback('crack-custom:parakontrol', function(hasEnoughMoney)
                                    if hasEnoughMoney then
                                        local formattedCoords = {
                                            x = ESX.Math.Round(pedCoords.x, 1),
                                            y = ESX.Math.Round(pedCoords.y, 1),
                                            z = ESX.Math.Round(pedCoords.z, 1)
                                        }
                                        TriggerEvent('esx_ambulancejob:revive', formattedCoords)
                                        TriggerServerEvent('crack-custom:money')
                                    else
                                        exports['okokNotify']:Alert('Medical Center', 'You Dont Have Enough Money!',5000, 'error') --crack
                                    end
                                end)
                            end
                        end
                    end
                end
            end

        end

        Citizen.Wait(sleep)
    end
end)


----Ped_Here

Citizen.CreateThread(function()
    RequestModel(GetHashKey("s_m_m_doctor_01"))
	
    while not HasModelLoaded(GetHashKey("s_m_m_doctor_01")) do
        Wait(1)
    end
	
	if Config.EnablePeds then
        for _, doctor in pairs(Config.Doctor) do
            
			local npc = CreatePed(4, 0xd47303ac, doctor.x, doctor.y, doctor.z-1.0, doctor.heading, false, true)
			
			SetEntityHeading(npc, doctor.heading)
			FreezeEntityPosition(npc, true)
			SetEntityInvincible(npc, true)
			SetBlockingOfNonTemporaryEvents(npc, true)
		end
	end
end)


Citizen.CreateThread(function()
    if Config.EnableBlips then
        for k,v in pairs(Config.Doctor) do
            local blip = AddBlipForCoord(v.x, v.y, v.z)

            SetBlipSprite (blip, 403)
            SetBlipDisplay(blip, 2)
            SetBlipScale  (blip, 1.0)
            SetBlipColour (blip, 2)
            SetBlipAsShortRange(blip, true)

            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString('Hastane')
            EndTextCommandSetBlipName(blip)
        end
    end
end)



--inury
local hurt = false
Citizen.CreateThread(function()
    while true do
         Wait(5000)
        if GetEntityHealth(GetPlayerPed(-1)) <= 160 then
           -- exports['okokNotify']:Alert('Medical Center', 'You Are Injured, Go To The Hospital', 5000, 'success')
            setHurt()
        elseif hurt and GetEntityHealth(GetPlayerPed(-1)) > 161 then
            setNotHurt()
        end 
    end
end)

function setHurt()
    hurt = true
    RequestAnimSet("move_m@injured")
    SetPedMovementClipset(GetPlayerPed(-1), "move_m@injured", true)
end

function setNotHurt()
    hurt = false
    ResetPedMovementClipset(GetPlayerPed(-1))
    ResetPedWeaponMovementClipset(GetPlayerPed(-1))
    ResetPedStrafeClipset(GetPlayerPed(-1))
end

local blips = {
    
    --{title="BMF", colour=0, id=106, coords = vector3(-1560.5364, -34.6236, 56.7431)},
    --{title="HoodSt", colour=0, id=96, coords = vector3(-1073.0424, -1668.9443, 4.4552)},
    --{title="Coke Process", colour=0, id=501, coords = vector3(880.1768, -205.4097, 71.9766)},
    --{title="Meth Process", colour=3, id=499, coords = vector3(161.1355, 172.5058, 104.9200)},

}


Citizen.CreateThread(function()

    for _, info in pairs(blips) do
      info.blip = AddBlipForCoord(info.coords)
      SetBlipSprite(info.blip, info.id)
      SetBlipDisplay(info.blip, 4)
      SetBlipScale(info.blip, 1.0)
      SetBlipColour(info.blip, info.colour)
      SetBlipAsShortRange(info.blip, true)
      BeginTextCommandSetBlipName("STRING")
      AddTextComponentString(info.title)
      EndTextCommandSetBlipName(info.blip)
    end
end)
