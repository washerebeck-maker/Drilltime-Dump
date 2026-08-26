local CurrentAction, CurrentActionMsg, CurrentActionData = nil, '', {}
local HasAlreadyEnteredMarker, LastHospital, LastPart, LastPartNum
local isBusy, deadPlayers, deadPlayerBlips, isOnDuty = false, {}, {}, false
isInShopMenu = false

local G_Vehicle = nil

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	ESX.PlayerData = xPlayer
	ESX.PlayerLoaded = true
	if ESX.PlayerData.job.name == 'ambulance' then
		ToggleGodMode(true)
	else
		ToggleGodMode(false)
	end
end)


function OpenAmbulanceActionsMenu()
	local elements = {{label = _U('cloakroom'), value = 'cloakroom'}}

	if Config.EnablePlayerManagement and ESX.PlayerData.job.grade_name == 'boss' then
		table.insert(elements, {label = _U('boss_actions'), value = 'boss_actions'})
	end

	ESX.UI.Menu.CloseAll()

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'ambulance_actions', {
		title    = _U('ambulance'),
		align    = 'bottom-right',
		elements = elements
	}, function(data, menu)
		if data.current.value == 'cloakroom' then
			OpenCloakroomMenu()
		elseif data.current.value == 'boss_actions' then
			TriggerEvent('esx_society:openBossMenu', 'ambulance', function(data, menu)
				menu.close()
			end, {wash = false})
		end
	end, function(data, menu)
		menu.close()
	end)
end

local function IsAmbulanceVehicle(vehile)
	local model = GetEntityModel(vehicle)
	for k,v in pairs(Config.AmbulanceVehicles) do 
		if GetHashKey(v) == model then 
			return true
		end
	end
	return false
end

CreateThread(function()
    while true do
		if ESX.PlayerData.job and ESX.PlayerData.job.name ~= 'ambulance' then
            local playerPed = PlayerPedId()
            if IsPedInAnyVehicle(playerPed, true) then
                vehicle = GetVehiclePedIsIn(playerPed, false)
                if GetPedInVehicleSeat(vehicle, -1) == playerPed then
                    if DoesEntityExist(vehicle) and IsAmbulanceVehicle(vehicle) then
                        TaskLeaveVehicle(playerPed, vehicle, 4160) 
                    end
                end
            end 

        end
        Wait(1000)
    end
end)



function OpenMobileAmbulanceActionsMenu()
	ESX.UI.Menu.CloseAll()

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'mobile_ambulance_actions', {
		title    = _U('ambulance'),
		align    = 'bottom-right',
		elements = {
			{label = _U('ems_menu'), value = 'citizen_interaction'}
	}}, function(data, menu)
		if data.current.value == 'citizen_interaction' then
			ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'citizen_interaction', {
				title    = _U('ems_menu_title'),
				align    = 'bottom-right',
				elements = {
					{label = _U('ems_menu_revive'), value = 'revive'},
					{label = _U('ems_menu_small'), value = 'small'},
					{label = _U('ems_menu_big'), value = 'big'},
					{label = _U('ems_menu_putincar'), value = 'put_in_vehicle'},
					{label = _U('ems_menu_search'), value = 'search'},
					{label = 'Remove patient crutch', value = 'crutch'},
					{label = 'Spawn EMS Vehicle', value = 'vehicle'},
					{label = 'EMS MDT', value = 'mdt'}
			}}, function(data, menu)
				if isBusy then return end

				local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()

				if data.current.value == 'search' then
					TriggerServerEvent('esx_ambulancejob:svsearch')
				elseif data.current.value == 'vehicle' then
						SpawnEmsVehicle()
				elseif data.current.value == 'mdt' then
						if exports.ox_inventory:Search('count', 'emttablet') > 0 then
							ExecuteCommand('openmdt')
						else
							ESX.ShowNotification('You dont have mdt')
						end
				elseif closestPlayer == -1 or closestDistance > 1.0 then
					ESX.ShowNotification(_U('no_players'))
				else
					if data.current.value == 'revive' then
						revivePlayer(closestPlayer)
					elseif data.current.value == 'crutch' then
						RemoveCrutch(closestPlayer)
					elseif data.current.value == 'small' then
						ESX.TriggerServerCallback('esx_ambulancejob:getItemAmount', function(quantity)
							if quantity > 0 then
								local closestPlayerPed = GetPlayerPed(closestPlayer)
								local health = GetEntityHealth(closestPlayerPed)

								if health > 0 then
									local playerPed = PlayerPedId()

									isBusy = true
									ESX.ShowNotification(_U('heal_inprogress'))
									TaskStartScenarioInPlace(playerPed, 'CODE_HUMAN_MEDIC_TEND_TO_DEAD', 0, true)
									Wait(10000)
									ClearPedTasks(playerPed)

									TriggerServerEvent('esx_ambulancejob:removeItem', 'bandage')
									TriggerServerEvent('esx_ambulancejob:heal', GetPlayerServerId(closestPlayer), 'small')
									ESX.ShowNotification(_U('heal_complete', GetPlayerName(closestPlayer)))
									isBusy = false
								else
									ESX.ShowNotification(_U('player_not_conscious'))
								end
							else
								ESX.ShowNotification(_U('not_enough_bandage'))
							end
						end, 'bandage')

					elseif data.current.value == 'big' then

						ESX.TriggerServerCallback('esx_ambulancejob:getItemAmount', function(quantity)
							if quantity > 0 then
								local closestPlayerPed = GetPlayerPed(closestPlayer)
								local health = GetEntityHealth(closestPlayerPed)

								if health > 0 then
									local playerPed = PlayerPedId()

									isBusy = true
									ESX.ShowNotification(_U('heal_inprogress'))
									TaskStartScenarioInPlace(playerPed, 'CODE_HUMAN_MEDIC_TEND_TO_DEAD', 0, true)
									Wait(10000)
									ClearPedTasks(playerPed)

									TriggerServerEvent('esx_ambulancejob:removeItem', 'medikit')
									TriggerServerEvent('esx_ambulancejob:heal', GetPlayerServerId(closestPlayer), 'big')
									ESX.ShowNotification(_U('heal_complete', GetPlayerName(closestPlayer)))
									isBusy = false
								else
									ESX.ShowNotification(_U('player_not_conscious'))
								end
							else
								ESX.ShowNotification(_U('not_enough_medikit'))
							end
						end, 'medikit')

					elseif data.current.value == 'put_in_vehicle' then
						TriggerServerEvent('esx_ambulancejob:putInVehicle', GetPlayerServerId(closestPlayer))
					end
				end
			end, function(data, menu)
				menu.close()
			end)
		end

	end, function(data, menu)
		menu.close()
	end)
end

function revivePlayer(closestPlayer)
	isBusy = true

	ESX.TriggerServerCallback('esx_ambulancejob:getItemAmount', function(quantity)
		if quantity > 0 then
			local closestPlayerPed = GetPlayerPed(closestPlayer)

			if IsPedDeadOrDying(closestPlayerPed, 1) then
				local playerPed = PlayerPedId()
				local lib, anim = 'mini@cpr@char_a@cpr_str', 'cpr_pumpchest'
				ESX.ShowNotification(_U('revive_inprogress'))

				for i=1, 15 do
					Wait(900)

					ESX.Streaming.RequestAnimDict(lib, function()
						TaskPlayAnim(playerPed, lib, anim, 8.0, -8.0, -1, 0, 0.0, false, false, false)
						RemoveAnimDict(lib)
					end)
				end

				TriggerServerEvent('esx_ambulancejob:removeItem', 'medikit')
				TriggerServerEvent('esx_ambulancejob:revive', GetPlayerServerId(closestPlayer), true)
			else
				ESX.ShowNotification(_U('player_not_unconscious'))
			end
		else
			ESX.ShowNotification(_U('not_enough_medikit'))
		end
		isBusy = false
	end, 'medikit')
end

function RemoveCrutch(target)
	TriggerServerEvent('esx_ambulance:server:crutch_pay_request', GetPlayerServerId(target))
	--[[ TriggerEvent('ak47_crutch:remove',xTarget.source) ]]
end

RegisterNetEvent('esx_ambulance:client:crutch_pay_request')
AddEventHandler('esx_ambulance:client:crutch_pay_request', function(ems)
	local alert = lib.alertDialog({
        header = 'You have received a bill from EMS to remove crutch',
        content = 'Price : $28700',
        centered = true,
        cancel = true,
        labels = {
            cancel=  "Pay",
            confirm=  "Decline",
        }
    })

    if alert == 'cancel' then
        TriggerServerEvent('esx_ambulance:server:crutch_pay', ems)
    else
        TriggerServerEvent('esx_ambulance:server:crutch_pay_cancel', ems)
    end
end)



function FastTravel(coords, heading)
	local playerPed = PlayerPedId()

	DoScreenFadeOut(800)

	while not IsScreenFadedOut() do
		wait(1000)
	end

	ESX.Game.Teleport(playerPed, coords, function()
		DoScreenFadeIn(800)

		if heading then
			SetEntityHeading(playerPed, heading)
		end
	end)
end

-- Draw markers & Marker logic
CreateThread(function()
	while true do
		local sleep = 1500

		if ESX.PlayerData.job and ESX.PlayerData.job.name == 'ambulance' then
			local playerCoords = GetEntityCoords(PlayerPedId())
			local isInMarker, hasExited = false, false
			local currentHospital, currentPart, currentPartNum

			for hospitalNum,hospital in pairs(Config.Hospitals) do
				-- Ambulance Actions
				for k,v in ipairs(hospital.AmbulanceActions) do
					local distance = #(playerCoords - v)

					if distance < Config.DrawDistance then
						sleep = 0
						DrawMarker(Config.Marker.type, v, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, Config.Marker.x, Config.Marker.y, Config.Marker.z, Config.Marker.r, Config.Marker.g, Config.Marker.b, Config.Marker.a, false, false, 2, Config.Marker.rotate, nil, nil, false)
						

						if distance < Config.Marker.x then
							isInMarker, currentHospital, currentPart, currentPartNum = true, hospitalNum, 'AmbulanceActions', k
						end
					end
				end

				-- Pharmacies
				for k,v in ipairs(hospital.Pharmacies) do
					local distance = #(playerCoords - v)

					if distance < Config.DrawDistance then
						sleep = 0
						DrawMarker(Config.Marker.type, v, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, Config.Marker.x, Config.Marker.y, Config.Marker.z, Config.Marker.r, Config.Marker.g, Config.Marker.b, Config.Marker.a, false, false, 2, Config.Marker.rotate, nil, nil, false)
						

						if distance < Config.Marker.x then
							isInMarker, currentHospital, currentPart, currentPartNum = true, hospitalNum, 'Pharmacy', k
						end
					end
				end

				-- Vehicle Spawners
				for k,v in ipairs(hospital.Vehicles) do
					local distance = #(playerCoords - v.Spawner)

					if distance < Config.DrawDistance then
						sleep = 0
						DrawMarker(v.Marker.type, v.Spawner, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, v.Marker.x, v.Marker.y, v.Marker.z, v.Marker.r, v.Marker.g, v.Marker.b, v.Marker.a, false, false, 2, v.Marker.rotate, nil, nil, false)
						

						if distance < v.Marker.x then
							isInMarker, currentHospital, currentPart, currentPartNum = true, hospitalNum, 'Vehicles', k
						end
					end
				end

				-- Helicopter Spawners
				for k,v in ipairs(hospital.Helicopters) do
					local distance = #(playerCoords - v.Spawner)

					if distance < Config.DrawDistance then
						sleep = 0
						DrawMarker(v.Marker.type, v.Spawner, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, v.Marker.x, v.Marker.y, v.Marker.z, v.Marker.r, v.Marker.g, v.Marker.b, v.Marker.a, false, false, 2, v.Marker.rotate, nil, nil, false)
						

						if distance < v.Marker.x then
							isInMarker, currentHospital, currentPart, currentPartNum = true, hospitalNum, 'Helicopters', k
						end
					end
				end

				-- Fast Travels (Prompt)
				for k,v in ipairs(hospital.FastTravelsPrompt) do
					local distance = #(playerCoords - v.From)

					if distance < Config.DrawDistance then
						sleep = 0
						DrawMarker(v.Marker.type, v.From, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, v.Marker.x, v.Marker.y, v.Marker.z, v.Marker.r, v.Marker.g, v.Marker.b, v.Marker.a, false, false, 2, v.Marker.rotate, nil, nil, false)
						

						if distance < v.Marker.x then
							isInMarker, currentHospital, currentPart, currentPartNum = true, hospitalNum, 'FastTravelsPrompt', k
						end
					end
				end
			end

			-- Logic for exiting & entering markers
			if isInMarker and not HasAlreadyEnteredMarker or (isInMarker and (LastHospital ~= currentHospital or LastPart ~= currentPart or LastPartNum ~= currentPartNum)) then
				if
					(LastHospital ~= nil and LastPart ~= nil and LastPartNum ~= nil) and
					(LastHospital ~= currentHospital or LastPart ~= currentPart or LastPartNum ~= currentPartNum)
				then
					TriggerEvent('esx_ambulancejob:hasExitedMarker', LastHospital, LastPart, LastPartNum)
					hasExited = true
				end

				HasAlreadyEnteredMarker, LastHospital, LastPart, LastPartNum = true, currentHospital, currentPart, currentPartNum

				TriggerEvent('esx_ambulancejob:hasEnteredMarker', currentHospital, currentPart, currentPartNum)
			end

			if not hasExited and not isInMarker and HasAlreadyEnteredMarker then
				HasAlreadyEnteredMarker = false
				TriggerEvent('esx_ambulancejob:hasExitedMarker', LastHospital, LastPart, LastPartNum)
			end
		end
		Wait(sleep)
	end
end)

AddEventHandler('esx_ambulancejob:hasEnteredMarker', function(hospital, part, partNum)
	if part == 'AmbulanceActions' then
		CurrentAction = part
		CurrentActionMsg = _U('actions_prompt')
		CurrentActionData = {}
	elseif part == 'Pharmacy' then
		CurrentAction = part
		CurrentActionMsg = _U('open_pharmacy')
		CurrentActionData = {}
	elseif part == 'Vehicles' then
		CurrentAction = part
		CurrentActionMsg = _U('garage_prompt')
		CurrentActionData = {hospital = hospital, partNum = partNum}
	elseif part == 'Helicopters' then
		CurrentAction = part
		CurrentActionMsg = _U('helicopter_prompt')
		CurrentActionData = {hospital = hospital, partNum = partNum}
	elseif part == 'FastTravelsPrompt' then
		local travelItem = Config.Hospitals[hospital][part][partNum]

		CurrentAction = part
		CurrentActionMsg = travelItem.Prompt
		CurrentActionData = {to = travelItem.To.coords, heading = travelItem.To.heading}
	end

	ESX.TextUI(CurrentActionMsg)
end)

AddEventHandler('esx_ambulancejob:hasExitedMarker', function(hospital, part, partNum)
	if not isInShopMenu then
		ESX.UI.Menu.CloseAll()
	end
	ESX.HideUI()
	CurrentAction = nil
end)

-- Key Controls
CreateThread(function()
	while true do
		local sleep = 1500

		if CurrentAction then
			sleep = 0

			if IsControlJustReleased(0, 38) then
				if CurrentAction == 'AmbulanceActions' then
					OpenAmbulanceActionsMenu()
				elseif CurrentAction == 'Pharmacy' then
					OpenPharmacyMenu()
				elseif CurrentAction == 'Vehicles' then
					OpenVehicleSpawnerMenu('car', CurrentActionData.hospital, CurrentAction, CurrentActionData.partNum)
				elseif CurrentAction == 'Helicopters' then
					OpenVehicleSpawnerMenu('helicopter', CurrentActionData.hospital, CurrentAction, CurrentActionData.partNum)
				elseif CurrentAction == 'FastTravelsPrompt' then
					FastTravel(CurrentActionData.to, CurrentActionData.heading)
				end

				CurrentAction = nil
			end
		end

		local playerCoords, letSleep = GetEntityCoords(PlayerPedId()), true

		for hospitalNum,hospital in pairs(Config.Hospitals) do
			-- Fast Travels
			for k,v in ipairs(hospital.FastTravels) do
				local distance = #(playerCoords - v.From)

				if distance < Config.DrawDistance then
					sleep = 0
					DrawMarker(v.Marker.type, v.From, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, v.Marker.x, v.Marker.y, v.Marker.z, v.Marker.r, v.Marker.g, v.Marker.b, v.Marker.a, false, false, 2, v.Marker.rotate, nil, nil, false)
					

					if distance < v.Marker.x then
						FastTravel(v.To.coords, v.To.heading)
					end
				end
			end
		end
		Wait(sleep)
	end
end)

RegisterCommand("ambulancejob", function(src)
	if ESX.PlayerData.job and ESX.PlayerData.job.name == 'ambulance' and not ESX.PlayerData.dead then
		OpenMobileAmbulanceActionsMenu()
	end
end)

RegisterKeyMapping("ambulancejob", "Open Ambulance Actions Menu", "keyboard", "F6")

RegisterNetEvent('esx_ambulancejob:putInVehicle')
AddEventHandler('esx_ambulancejob:putInVehicle', function()
	local playerPed = PlayerPedId()
	local vehicle, distance = ESX.Game.GetClosestVehicle()

	if vehicle and distance < 5 then
		local maxSeats, freeSeat = GetVehicleMaxNumberOfPassengers(vehicle)

		for i=maxSeats - 1, 0, -1 do
			if IsVehicleSeatFree(vehicle, i) then
				freeSeat = i
				break
			end
		end

		if freeSeat then
			TaskWarpPedIntoVehicle(playerPed, vehicle, freeSeat)
		end
	end
end)

function OpenCloakroomMenu()
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'cloakroom', {
		title    = _U('cloakroom'),
		align    = 'bottom-right',
		elements = {
			{label = _U('ems_clothes_civil'), value = 'citizen_wear'},
			{label = _U('ems_clothes_ems'), value = 'ambulance_wear'},
	}}, function(data, menu)
		if data.current.value == 'citizen_wear' then
			ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin, jobSkin)
				TriggerEvent('skinchanger:loadSkin', skin)
				isOnDuty = false
				for playerId,v in pairs(deadPlayerBlips) do
					RemoveBlip(v)
					deadPlayerBlips[playerId] = nil
				end
				deadPlayers = {}
				if Config.Debug then 
					print("[INFO] Now Off Duty")
				end
			end)
		elseif data.current.value == 'ambulance_wear' then
			ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin, jobSkin)
				if skin.sex == 0 then
					TriggerEvent('skinchanger:loadClothes', skin, jobSkin.skin_male)
				else
					TriggerEvent('skinchanger:loadClothes', skin, jobSkin.skin_female)
				end

				isOnDuty = true
				ESX.TriggerServerCallback('esx_ambulancejob:getDeadPlayers', function(_deadPlayers)
					TriggerEvent('esx_ambulancejob:setDeadPlayers', _deadPlayers)
				end)
				if Config.Debug then 
					print("[INFO] Player Sex |" .. tostring(skin.sex))
					print("[INFO] Now On Duty")
				end
			end)
		end

		menu.close()
	end, function(data, menu)
		menu.close()
	end)
end

function OpenPharmacyMenu()
	ESX.UI.Menu.CloseAll()

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'pharmacy', {
		title    = _U('pharmacy_menu_title'),
		align    = 'bottom-right',
		elements = {
			{label = _U('pharmacy_take', _U('medikit')), item = 'medikit', type = 'slider', value = 1, min = 1, max = 100},
			{label = _U('pharmacy_take', _U('bandage')), item = 'bandage', type = 'slider', value = 1, min = 1, max = 100}
	}}, function(data, menu)
		if Config.Debug then 
			print("[INFO] Attempting to Give Item |" .. tostring(data.current.item))
		end
		TriggerServerEvent('esx_ambulancejob:giveItem', data.current.item, data.current.value)
	end, function(data, menu)
		menu.close()
	end)
end

RegisterNetEvent('esx_ambulancejob:heal')
AddEventHandler('esx_ambulancejob:heal', function(healType, quiet)
	local playerPed = PlayerPedId()
	local maxHealth = GetEntityMaxHealth(playerPed)

	if healType == 'small' then
		local health = GetEntityHealth(playerPed)
		local newHealth = math.min(maxHealth, math.floor(health + maxHealth / 8))
		SetEntityHealth(playerPed, newHealth)
	elseif healType == 'big' then
		SetEntityHealth(playerPed, maxHealth)
	end

	if Config.Debug then 
		print("[INFO] Healing Player |" .. tostring(healType))
	end
	if not quiet then
		ESX.ShowNotification(_U('healed'))
	end
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	if isOnDuty and job.name ~= 'ambulance' then
		for playerId,v in pairs(deadPlayerBlips) do
			if Config.Debug then 
				print("[INFO] removing dead player blip |" .. tostring(playerId))
			end
			RemoveBlip(v)
			deadPlayerBlips[playerId] = nil
		end

		isOnDuty = false
	end

	if job.name == 'ambulance'then
		ToggleGodMode(true)
	else
		ToggleGodMode(false)
	end
end)

RegisterNetEvent('esx_ambulancejob:PlayerDead')
AddEventHandler('esx_ambulancejob:PlayerDead', function(Player)
	if Config.Debug then 
		print("[INFO] Setting Player Dead |" .. tostring(Player))
	end
	deadPlayers[Player] = "dead"
end)

RegisterNetEvent('esx_ambulancejob:PlayerNotDead')
AddEventHandler('esx_ambulancejob:PlayerNotDead', function(Player)
	if deadPlayerBlips[Player] then
		RemoveBlip(deadPlayerBlips[Player])
		deadPlayerBlips[Player] = nil
	end
	if Config.Debug then 
		print("[INFO] Setting Player Not Dead |" .. tostring(Player))
	end
	deadPlayers[Player] = nil
end)

RegisterNetEvent('esx_ambulancejob:setDeadPlayers')
AddEventHandler('esx_ambulancejob:setDeadPlayers', function(_deadPlayers)
	deadPlayers = _deadPlayers

	if isOnDuty then
		for playerId,v in pairs(deadPlayerBlips) do
			RemoveBlip(v)
			deadPlayerBlips[playerId] = nil
		end

		for playerId,status in pairs(deadPlayers) do
			if Config.Debug then 
				print("[INFO] Setting Player As Dead |" .. tostring(playerId))
			end
			if status == 'distress' then
				if Config.Debug then 
					print("[INFO] Creating Distress Blip for Player |" .. tostring(playerId))
				end
				local player = GetPlayerFromServerId(playerId)
				local playerPed = GetPlayerPed(player)
				local blip = AddBlipForEntity(playerPed)

				SetBlipSprite(blip, 303)
				SetBlipColour(blip, 1)
				SetBlipFlashes(blip, true)
				SetBlipCategory(blip, 7)

				BeginTextCommandSetBlipName('STRING')
				AddTextComponentSubstringPlayerName(_U('blip_dead'))
				EndTextCommandSetBlipName(blip)

				deadPlayerBlips[playerId] = blip
			end
		end
	end
end)


RegisterNetEvent('esx_ambulancejob:PlayerDistressed')
AddEventHandler('esx_ambulancejob:PlayerDistressed', function(Player)
	deadPlayers[Player] = 'distress'

	if isOnDuty then
		if Config.Debug then 
			print("[INFO] Player Distress Recived - ID |" .. tostring(Player))
		end
				ESX.ShowNotification("[DISPATCH]: An Unconscious Person Has Been Reported", "error", 10000)
				deadPlayerBlips[Player] = nil
				local player = GetPlayerFromServerId(Player)
				local playerPed = GetPlayerPed(player)
				local blip = AddBlipForEntity(playerPed)

				SetBlipSprite(blip, Config.DistressBlip.Sprite)
				SetBlipColour(blip, Config.DistressBlip.Color)
				SetBlipScale(blip, Config.DistressBlip.Scale)
				SetBlipFlashes(blip, true)

				BeginTextCommandSetBlipName('STRING')
				AddTextComponentSubstringPlayerName(_U('blip_dead'))
				EndTextCommandSetBlipName(blip)

				deadPlayerBlips[Player] = blip
	end
end)

Citizen.CreateThread(function()
    while ESX.PlayerData == nil or ESX.PlayerData.job == nil do Wait(10) end
    while true do
        local wait = 5000
        if ESX.PlayerData.job.name == 'ambulance' then
            wait = 2000
            local ped = PlayerPedId()
            if IsPedArmed(ped, 7) then
                wait = 1
                TriggerEvent('ox_inventory:disarm', true)      
			end
        end
        Wait(wait)
    end
end)

ToggleGodMode = function(enabled)
	SetEntityInvincible(PlayerPedId(), enabled)
end

SpawnEmsVehicle = function()
	if DoesEntityExist(G_Vehicle) then
        DeleteEntity(G_Vehicle)
    end
    if DoesEntityExist(G_Vehicle) then
        ESX.ShowNotification('You cant spawn any more police vehicle. limit reached.')
        return
    end
    
    local model = Config.EMSVehicle
	if IsModelInCdimage(model) then
        local playerPed = PlayerPedId()
		local playerCoords, playerHeading = GetEntityCoords(playerPed), GetEntityHeading(playerPed)
		ESX.Game.SpawnVehicle(model, playerCoords, playerHeading, function(vehicle)
            G_Vehicle = vehicle
			TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
			SetVehicleDirtLevel(vehicle, 0)
			SetVehicleFuelLevel(vehicle, 100.0)
			SetEntityAsMissionEntity(vehicle, true, true)
            VehiclePlate = ESX.Math.Trim(GetVehicleNumberPlateText(vehicle))
			if Config.MaxAdminVehicles then 
				SetVehicleExplodesOnHighExplosionDamage(vehicle, true)
				SetVehicleModKit(vehicle, 0)
				SetVehicleMod(vehicle, 11, 3, false) -- modEngine
				SetVehicleMod(vehicle, 12, 2, false) -- modBrakes
				SetVehicleMod(vehicle, 13, 2, false) -- modTransmission
				SetVehicleMod(vehicle, 15, 3, false) -- modSuspension
				SetVehicleMod(vehicle, 16, 4, false) -- modArmor
				ToggleVehicleMod(vehicle, 18, true) -- modTurbo
				SetVehicleTurboPressure(vehicle, 100.0)
				SetVehicleNumberPlateTextIndex(vehicle, 1)
				SetVehicleNitroEnabled(vehicle, true)
				for i=0, 3 do
					SetVehicleNeonLightEnabled(vehicle, i, true)
				end
				SetVehicleNeonLightsColour(vehicle, 55, 140, 191)  -- ESX Blue
			end
		end)
	else
        ESX.ShowNotification('Invalid vehicle model.')
	end
end

ShowNotification = function(msg)
	AddTextEntry('elderNotification', msg)
	BeginTextCommandThefeedPost('elderNotification')
	EndTextCommandThefeedPostTicker(false)
end

RegisterNetEvent('esx_ambulancejob:civDown')
AddEventHandler('esx_ambulancejob:civDown', function(coords)
    if ESX.PlayerData.job.name ~= 'ambulance' then return end
    CreateThread(function()
        PlaySoundFrontend(-1, "TIMER_STOP", "HUD_MINI_GAME_SOUNDSET", 1)
        ShowNotification("~q~[EMS]~s~ Citizen Is Down")
        local blip = AddBlipForCoord(coords)
        SetBlipSprite(blip, 153)
        SetBlipColour(blip, 5)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("ems")
        EndTextCommandSetBlipName(blip)
        --SetBlipAsShortRange(blip,true)
        SetBlipScale(blip, 1.2)
        --SetBlipFlashTimer(blip, 120000)
        local blip2 = AddBlipForCoord(coords)
        SetBlipSprite(blip2, 161)
        SetBlipColour(blip2, 5)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("ems")
        EndTextCommandSetBlipName(blip2)
        --SetBlipAsShortRange(blip,true)
        SetBlipScale(blip2, 1.2)
        --SetBlipFlashTimer(blip2, 120000)
        Wait(120000)
        RemoveBlip(blip)
        RemoveBlip(blip2)
    end)
end)
