ESX = exports['es_extended']:getSharedObject()

cachedData = {}

Citizen.CreateThread(function()
    while true do
        local sleep = 1000

        if ESX.UI.Menu.IsOpen('default', GetCurrentResourceName(), 'main_garage_menu')
        or ESX.UI.Menu.IsOpen('default', GetCurrentResourceName(), 'main_vehicle_menu')
        or ESX.UI.Menu.IsOpen('default', GetCurrentResourceName(), 'second_vehicle_menu') then

            sleep = 0

            -- Main background
            DrawRect(0.500, 0.930, 0.165, 0.032, 0, 0, 0, 160)

            -- BACKSPACE key
            DrawRect(0.447, 0.930, 0.050, 0.028, 255, 255, 255, 255)

            -- BACKSPACE text
            SetTextFont(4)
            SetTextScale(0.30, 0.30)
            SetTextColour(0, 0, 0, 255)
            SetTextCentre(true)
            BeginTextCommandDisplayText("STRING")
            AddTextComponentSubstringPlayerName("BACKSPACE")
            EndTextCommandDisplayText(0.447, 0.918)

            -- Close text
            SetTextFont(4)
            SetTextScale(0.36, 0.36)
            SetTextColour(255, 255, 255, 255)
            SetTextCentre(false)
            BeginTextCommandDisplayText("STRING")
            AddTextComponentSubstringPlayerName("to close garage.")
            EndTextCommandDisplayText(0.477, 0.917)
        end

        Citizen.Wait(sleep)
    end
end)

Citizen.CreateThread(function()
	while not ESX do
		
		Citizen.Wait(0)
	end

	if Config.VehicleMenu then
		while true do
			Citizen.Wait(100)

			if IsControlJustPressed(0, Config.VehicleMenuButton) then
				OpenVehicleMenu()
			end
		end
	end
end)

RegisterNetEvent("esx:playerLoaded")
AddEventHandler("esx:playerLoaded", function(playerData)
	ESX.PlayerData = playerData
end)

RegisterNetEvent("esx:setJob")
AddEventHandler("esx:setJob", function(newJob)
	ESX.PlayerData["job"] = newJob
end)

Citizen.CreateThread(function()
	local CanDraw = function(action)
		if action == "vehicle" then
			if IsPedInAnyVehicle(PlayerPedId()) then
				local vehicle = GetVehiclePedIsIn(PlayerPedId())

				if GetPedInVehicleSeat(vehicle, -1) == PlayerPedId() then
					return true
				else
					return false
				end
			else
				return false
			end
		end

		return true
	end

	local GetDisplayText = function(action, garage)
		if not Config.Labels[action] then Config.Labels[action] = action end

		return string.format(Config.Labels[action], action == "vehicle" and GetLabelText(GetDisplayNameFromVehicleModel(GetEntityModel(GetVehiclePedIsUsing(PlayerPedId())))) or garage)
	end

	for garage, garageData in pairs(Config.Garages) do
		if garageData["blip"] then
			local garageBlip = AddBlipForCoord(garageData["positions"]["menu"]["position"])
			SetBlipSprite(garageBlip, 289)
			SetBlipDisplay(garageBlip, 4)
			SetBlipScale (garageBlip, 0.8)
			SetBlipColour(garageBlip, 67)
			SetBlipAsShortRange(garageBlip, true)
			BeginTextCommandSetBlipName("STRING")
			AddTextComponentString("Garage: " .. garage)
			EndTextCommandSetBlipName(garageBlip)
		end
	end

	while true do
		local sleepThread = 500

		local ped = PlayerPedId()
		local pedCoords = GetEntityCoords(ped)

		for garage, garageData in pairs(Config.Garages) do
			for action, actionData in pairs(garageData["positions"]) do
				local dstCheck = #(pedCoords - actionData["position"])

				if dstCheck <= 10.0 then
					sleepThread = 5

					local draw = CanDraw(action)

					if draw then
						local markerSize = action == "vehicle" and 5.0 or 1.5

						if dstCheck <= markerSize - 0.1 then
							local usable, displayText = not DoesCamExist(cachedData["cam"]), GetDisplayText(action, garage)

							ESX.ShowHelpNotification(usable and displayText or "Choosing vehicle.")

							if usable then
								if IsControlJustPressed(0, 38) then
									cachedData["currentGarage"] = garage

									HandleAction(action)
								end
							end
						end

						DrawScriptMarker({
							["type"] = 27,
							["pos"] = actionData["position"] - vector3(0.0, 0.0, 0.985),
							["sizeX"] = markerSize,
							["sizeY"] = markerSize,
							["sizeZ"] = markerSize,
							["r"] = 60,
							["g"] = 255,
							["b"] = 0
						})
					end
				end
			end
		end

		Citizen.Wait(sleepThread)
	end
end)


