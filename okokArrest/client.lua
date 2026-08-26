ESX = exports['es_extended']:getSharedObject()

RegisterNetEvent('okokArrest:GetCivInfo')
AddEventHandler('okokArrest:GetCivInfo', function(source_playername, date, reason, search, source)
	local playerPed = PlayerPedId()
	local coords = GetEntityCoords(playerPed)
	local closestPlayer, playerDistance = ESX.Game.GetClosestPlayer()
	local sellerID = source
	target = GetPlayerServerId(closestPlayer)

	if closestPlayer ~= -1 and playerDistance <= 3.0 then
		
		ESX.TriggerServerCallback("okokArrest:GetTargetName", function(targetName)
			SetNuiFocus(true, true)
			SendNUIMessage({
				action = 'openContractSeller',
				source_playername = source_playername,
				sourceID = sellerID,
				target_playername = targetName,
				targetID = target,
				date = date,
				reason = reason,
				search = search
			})
		end, target)
		
	else
		ClearPedTasks(PlayerPedId())
		exports['okokNotify']:Alert("LSPD", "You need to be near someone in order to do that ", 10000, 'error')
	end
end)

RegisterNetEvent('okokArrest:OpenContractInfo')
AddEventHandler('okokArrest:OpenContractInfo', function()
	SetNuiFocus(true, true)
	SendNUIMessage({
		action = 'openContractInfo'
	})
end)

RegisterNetEvent('okokArrest:OpenContractOnBuyer')
AddEventHandler('okokArrest:OpenContractOnBuyer', function(data)
	SetNuiFocus(true, true)
	SendNUIMessage({
		action = 'openContractOnBuyer',
		source_playername = data.sourceName,
		sourceID = data.sourceID,
		target_playername = data.targetName,
		targetID = data.targetID,
		date = data.date,
		reason = data.reason,
		search = data.search
	})
end)

RegisterNUICallback("action", function(data, cb)
	if data.action == "submitContractInfo" then
		TriggerServerEvent("okokArrest:SendCivInfo", data.pd_reason, data.search_type)
		SetNuiFocus(false, false)
	elseif data.action == "signContract1" then
		TriggerServerEvent("okokArrest:SendContractToBuyer", data)
		ClearPedTasks(PlayerPedId())
		SetNuiFocus(false, false)
	elseif data.action == "signContract2" then
		TriggerServerEvent("okokArrest:Punish", data, false)
		print(data.search)
		TriggerServerEvent('crack_police:removeIllegalItemsFromArrest', data.sourceIDSeller, data.targetIDSeller, data.search ~= "Partial Search")
		ClearPedTasks(PlayerPedId())
		SetNuiFocus(false, false)
	elseif data.action == "close" then
		ClearPedTasks(PlayerPedId())
		SetNuiFocus(false, false)
	elseif data.action == "close1" then
		ClearPedTasks(PlayerPedId())
		SetNuiFocus(false, false)
		TriggerServerEvent("okokArrest:Punish", data, true)
		print(data.search)
		TriggerServerEvent('crack_police:removeIllegalItemsFromArrest', data.sourceIDSeller, data.targetIDSeller, data.search ~= "Partial Search")
	end
end)

RegisterNetEvent('okokArrest:startContractAnimation')
AddEventHandler('okokArrest:startContractAnimation', function(player)
	loadAnimDict('anim@amb@nightclub@peds@')
	TaskStartScenarioInPlace(PlayerPedId(), 'WORLD_HUMAN_CLIPBOARD', 0, false)
end)

function loadAnimDict(dict)
	while (not HasAnimDictLoaded(dict)) do
		RequestAnimDict(dict)
		Citizen.Wait(0)
	end
end