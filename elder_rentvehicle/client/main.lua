ESX = exports['es_extended']:getSharedObject()

local inProgress = false

local LastStation, LastPart, LastPartNum, LastEntity, CurrentAction, CurrentActionMsg, agency


Citizen.CreateThread(function()
	

	while ESX.GetPlayerData().job == nil do
		Citizen.Wait(10)
	end
	PlayerData = ESX.GetPlayerData()
	
end)


AddEventHandler('GLD_RentVehicle:hasEnteredMarker', function(part)
	if part == 'rent_vehicle' then
		CurrentAction     = 'rent_vehicle'
		CurrentActionMsg  = 'Press ~INPUT_CONTEXT~ to rent a vehicle'
		CurrentActionData = {}
	elseif part == 'restore_vehicle' then
		CurrentAction     = 'restore_vehicle'
		CurrentActionMsg  = 'Press ~INPUT_CONTEXT~ to store the vehicle'
		CurrentActionData = {}
	end
	
end)


AddEventHandler('GLD_RentVehicle:hasExitedMarker', function(station, part, partNum)
	if not isInShopMenu then
		ESX.UI.Menu.CloseAll()
	end
	CurrentAction = nil
end)


-- Display markers
Citizen.CreateThread(function()
Citizen.Wait(100)
	while true do
		Citizen.Wait(0)
		

		local playerPed = PlayerPedId()
		local coords    = GetEntityCoords(playerPed)
		local isInMarker, hasExited, letSleep = false, false, true
		local currentStation, currentPart, currentPartNum
	
		
		for k,v in pairs(Config.RentZone) do
			local distance = GetDistanceBetweenCoords(coords, v.Coords, true)
			if distance < 50.0 then
				DrawMarker(36, v.Coords, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 1.0, 1.0, 1.0, 143, 0, 255, 255, false, true, 2, true, false, false, false)
				letSleep = false
			end

			if distance < 2.0 then
				isInMarker, currentStation, currentPart, currentPartNum, agency = true, k, 'rent_vehicle', i, k
			end
		end
		
		for k,v in pairs(Config.RestoreRentZone) do
			local distance = GetDistanceBetweenCoords(coords, v.Coords, true)
			if distance < 50.0 then
				DrawMarker(36, v.Coords, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 1.0, 1.0, 1.0, 255, 0, 0, 255, false, true, 2, true, false, false, false)
				letSleep = false
			end

			if distance < 2.0 then
				isInMarker, currentStation, currentPart, currentPartNum, agency = true, k, 'restore_vehicle', i, k
			end
		end
			
		if isInMarker and not HasAlreadyEnteredMarker or (isInMarker and (LastStation ~= currentStation or LastPart ~= currentPart or LastPartNum ~= currentPartNum)) then
			if (LastStation and LastPart and LastPartNum) and (LastStation ~= currentStation or LastPart ~= currentPart or LastPartNum ~= currentPartNum) then
				TriggerEvent('GLD_RentVehicle:hasExitedMarker', LastStation, LastPart, LastPartNum)
				hasExited = true
				
			end
			
			HasAlreadyEnteredMarker = true
			LastStation             = currentStation
			LastPart                = currentPart
			LastPartNum             = currentPartNum
			TriggerEvent('GLD_RentVehicle:hasEnteredMarker', currentPart)
		end

		if not hasExited and not isInMarker and HasAlreadyEnteredMarker then
			HasAlreadyEnteredMarker = false
			TriggerEvent('GLD_RentVehicle:hasExitedMarker', LastStation, LastPart, LastPartNum)
		end

		if letSleep then
			Citizen.Wait(500)
		end
	
	end	
end)


-- Key Controls
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		if CurrentAction then
			ESX.ShowHelpNotification(CurrentActionMsg)
			if IsControlJustReleased(0, 38) then
				if CurrentAction == 'rent_vehicle' then
					OpenRentvehicleMenu(agency)
				end
				if CurrentAction == 'restore_vehicle' then
					RestoreVehicle()
				end
			end
		end
	end
end)


function OpenRentvehicleMenu(agency)
	ESX.UI.Menu.CloseAll()

	local elements = {}
	
	for k,v in pairs(Config.AuthorizedVehicles) do
		table.insert(elements, {label = v.label ..' $'.. ESX.Math.GroupDigits(v.price), model = v.model, price = v.price})
	end
	
	

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'vehicle_spawner', 
		{ title    = 'Drilltime Vehicle Rental', 
		  align    = 'top-left', 
		  elements = elements
	}, function(data, menu)
		
		
		if not inProgress then 
		
			inProgress = true
			
			if not ESX.Game.IsSpawnPointClear(Config.RentZone[agency].VehicleSpawnPoint, 5.0) then
				exports['okokNotify']:Alert('Vehicle Rental','Clear spawn point' , 5000, "error")
				return
			end

			menu.close()
			
			ESX.TriggerServerCallback("GLD_RentVehicle:CanRentModel", function(canRent)
			
				if canRent then
				
					ESX.TriggerServerCallback("GLD_RentVehicle:HaveMoney", function(buy)	
					
						if buy == true then
							ESX.Game.SpawnVehicle(data.current.model, Config.RentZone[agency].VehicleSpawnPoint, Config.RentZone[agency].Heading, function(vehicle)
								local playerPed = PlayerPedId()
								TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
								TriggerServerEvent("GLD_RentVehicle:RentVehicle", data.current.model, data.current.price )
							end)
						else
							exports['okokNotify']:Alert('Vehicle Rental','You dont have enough money' , 5000, "error")
						end
						
					end, data.current.price)
				
				else
					exports['okokNotify']:Alert('Vehicle Rental','Already rent this car' , 5000, "error")
				end
			
			end,data.current.model)
			
			inProgress = false
		
		end 
		
	    end, function(data, menu)
		    menu.close()
	end)
end

-- Create Blips
Citizen.CreateThread(function()

	for k,v in pairs(Config.RentZone) do
		local blip = AddBlipForCoord(v.Coords)
		SetBlipSprite (blip, 326)
		SetBlipDisplay(blip, 4)
		SetBlipColour (blip, 27)
		SetBlipScale (blip, 0.0)
		SetBlipAsShortRange(blip, true)
		BeginTextCommandSetBlipName('STRING')
		AddTextComponentString('Vehicle rental')
		EndTextCommandSetBlipName(blip)	
	end
end)

-- Create Blips
Citizen.CreateThread(function()

	--[[for k,v in pairs(Config.RestoreRentZone) do
		local blip = AddBlipForCoord(v.Coords)
		SetBlipSprite (blip, 435)
		SetBlipDisplay(blip, 4)
		SetBlipColour (blip, 1)
		SetBlipScale (blip, 1.0)
		SetBlipAsShortRange(blip, true)
		BeginTextCommandSetBlipName('STRING')
		AddTextComponentString('Vehicle rental')
		EndTextCommandSetBlipName(blip)	
	end]]
end)




function RestoreVehicle()

	local playerPed = PlayerPedId()
	
	if IsPedInAnyVehicle(playerPed, true) then
		vehicle = GetVehiclePedIsIn(playerPed, false)
		local model  = GetDisplayNameFromVehicleModel(GetEntityModel(vehicle))
		ESX.TriggerServerCallback("GLD_RentVehicle:canRestoreVehicle", function(canRestore)
			if canRestore == true then
				ESX.Game.DeleteVehicle(vehicle)
				TriggerServerEvent("GLD_RentVehicle:RestoreVehicle", model)
			else
				exports['okokNotify']:Alert('Vehicle Rental','You cant store the vehicle' , 5000, "error")
			end
		end,model)
	else
		exports['okokNotify']:Alert('Vehicle Rental','Should be in vehicle' , 5000, "error")
	end
end
