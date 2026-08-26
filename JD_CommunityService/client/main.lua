local inService, targetList, drawMarker, markerData, obj, existingActions = false, {}, false, nil, nil, nil

local canEscape = true

local FromArrest = false

PlayerJob = nil

if Config.Framework == 'qbcore' then
	QBCore = GetResourceState('qb-core') == 'started' and exports['qb-core']:GetCoreObject()

	RegisterNetEvent('QBCore:Client:OnPlayerLoaded')
	AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
		Wait(2000)
		local count = lib.callback.await('JD_CommunityService:getCurrentActions', false)
		local admintag = lib.callback.await('JD_CommunityService:getAdminTag', false)
		if count == nil then return print("JD_CommunityService | Something went wrong!") end
		TriggerEvent('JD_CommunityService:beginService', count, false)
	end)

	ShowNotification = function(msg)
		QBCore.Functions.Notify(msg, 'success', 5000)
	end
elseif Config.Framework == 'esx' then
	ESX = GetResourceState('es_extended') == 'started' and exports.es_extended:getSharedObject()

	CreateThread(function()
		while ESX.GetPlayerData().job == nil do
			Citizen.Wait(10)
		end
		PlayerJob = ESX.GetPlayerData().job
	end)
	
	RegisterNetEvent('esx:setJob')
	AddEventHandler('esx:setJob', function(job)  
    	PlayerJob = job
	end)

	RegisterNetEvent('esx:playerLoaded')
	AddEventHandler('esx:playerLoaded', function()
		Wait(2000)
		local count = lib.callback.await('JD_CommunityService:getCurrentActions', false)
		local admintag = lib.callback.await('JD_CommunityService:getAdminTag', false)
		if count == nil then return print("JD_CommunityService | Something went wrong!") end
		if admintag == 1 then
			TriggerServerEvent('crack_police:removeIllegalItemsFromQuit', true)
		end
		TriggerEvent('JD_CommunityService:beginService', count, false)
	end)
----
	 AddEventHandler('onResourceStart', function(resourceName)
		if (GetCurrentResourceName() ~= resourceName) then
		  return
		end
		Wait(2000)
		local count = lib.callback.await('JD_CommunityService:getCurrentActions', false)
		local admintag = lib.callback.await('JD_CommunityService:getAdminTag', false)
		if count == nil then return print("JD_CommunityService | Something went wrong!") end
		if admintag == 1 then
			TriggerServerEvent('crack_police:removeIllegalItemsFromQuit', true)
		end
		TriggerEvent('JD_CommunityService:beginService', count, false)
	  end)
------
	ShowNotification = function(msg)
		ESX.ShowNotification(msg)
	end
end

CreateThread(function()
	while true do
		local threadSleep = 1500
		if drawMarker then
			threadSleep = 0
			DrawMarker(20, markerData.x, markerData.y, markerData.z + 1.0, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 0.4, 0.4, 0.4, 235, 64, 52, 100, true, false, 2, true, false, false, false)
		end
		Wait(threadSleep)
	end
end)

function onExit(self)
	if inService then
		if Config.ServiceExtensionOnEscape >= 1 then
			local currentNumber = existingActions
			local extensionCount = Config.ServiceExtensionOnEscape
			existingActions = currentNumber + extensionCount
			ShowNotification('Your time has been extended by ' .. extensionCount .. ' actions!')
		end
		tpToZone()
	end
end

local poly = lib.zones.poly({
	points = {
		vec3(1701.3120, 2455.5027, 45.56),
		vec3(1622.6514, 2497.1960, 45.56),
		vec3(1663.9547, 2569.1921, 45.56),
		vec3(1759.5876, 2565.3320, 45.56),
	},
	thickness = 16.0,
	debug = false,
	onExit = onExit
})

RegisterNetEvent('JD_CommunityService:beginService')
AddEventHandler('JD_CommunityService:beginService', function(count, intro, escape)
	if inService then 
		existingActions = count
		return
	end
	FromArrest = escape and true or false
	if intro then 
		playScene()
		playScene_photo()
	end
	inService = true
	beginService(count)
end)

RegisterNetEvent('JD_CommunityService:releaseService')
AddEventHandler('JD_CommunityService:releaseService', function(count)
	inService = false
	releaseZone()
	lib.callback.await('JD_CommunityService:completeService')
	ShowNotification('You have been released from community service. Best behaviour, citizen!')
end)

beginService = function(actionCount)
	existingActions = actionCount
	TriggerEvent('JD_CommunityService:startCheckWeapon')
	tpToZone()
	startActions()
	changeClothing()
end

startActions = function()
	local indexNumber = math.random(1, #Config.ServiceLocations)

	drawMarker = true
	markerData = Config.ServiceLocations[indexNumber].coords.xyz
	if Config.InteractionType == 'ox_target' then
		local target = exports.ox_target:addSphereZone({
			coords = Config.ServiceLocations[indexNumber].coords.xyz,
			radius = 1,
			options = {
				{
					name = 'sweep',
					onSelect = targetInteract,
					icon = 'fa-solid fa-location-crosshairs',
					label = 'Sweep',
					canInteract = function(entity, distance, coords, name)
						return not lib.progressActive()
					end
				}
			}
		})
		table.insert(targetList, target)
	elseif Config.InteractionType == 'points' then
		local point = lib.points.new(Config.ServiceLocations[indexNumber].coords.xyz, 2, {})
		function point:onExit()
			lib.hideTextUI()
		end

		function point:nearby()
			lib.showTextUI('[E] - Sweep rubbish')
			if IsControlJustReleased(0, 38) then
				startSweep(point)
			end
		end
	end

	--local modelHash = 'v_ind_rc_rubbishppr' -- The ` return the jenkins hash of a string. see more at: https://cookbook.fivem.net/2019/06/23/lua-support-for-compile-time-jenkins-hashes/

	--if not HasModelLoaded(modelHash) then
		-- If the model isnt loaded we request the loading of the model and wait that the model is loaded
		--RequestModel(modelHash)

		--while not HasModelLoaded(modelHash) do
			--Wait(1)
		--end
	--end

	
	--obj = CreateObject(modelHash, Config.ServiceLocations[indexNumber].coords.xyz, true)
end

tpToZone = function()
	SetEntityCoords(PlayerPedId(), Config.StartLocation.xyz)
end

releaseZone = function()
	returnClothing()
	lib.hideTextUI()
	SetEntityCoords(PlayerPedId(), Config.ReleaseLocation.xyz)
	canEscape = true
	FromArrest = false
end

removeInteracts = function()
	if Config.InteractionType == 'ox_target' then
		for k, v in pairs(targetList) do
			exports.ox_target:removeZone(v)
			targetList[k] = nil
		end
	end
	drawMarker = false
	markerData = nil
end

targetInteract = function(data)
	if data.name == 'sweep' then
		startSweep()
	end
end

startSweep = function(point)
	if Config.InteractionType == 'points' then
		point:remove()
	end
	lib.hideTextUI()
	local progress = lib.progressCircle({
		duration = Config.ActionTime,
		label = 'Sweeping ground',
		useWhileDead = false,
		allowRagdoll = false,
		allowCuffed = false,
		allowFalling = false,
		canCancel = false,
		anim = { dict = 'amb@world_human_janitor@male@idle_a', clip = 'idle_a' },
		prop = { model = `prop_tool_broom`, bone = 28422, pos = { x = -0.005, y = 0.0, z = 0.0 }, rot = { x = 360.0, y = 360.0, z = 0.0 } },
		disable = { move = true, combat = true }
	})

	TriggerServerEvent('JD_CommunityService:server:reward')

	existingActions = existingActions - 1
	if existingActions >= 1 then
		ShowNotification('Actions remaining: ' .. existingActions)
	end
	if existingActions >= 1 and existingActions % 5 == 0 then
		updateActions()
	end
	updateFunction()
end

updateFunction = function()
	removeInteracts()
	DeleteObject(obj)
	obj = nil
	if existingActions >= 1 then
		startActions()
	else
		inService = false
		releaseZone()
		lib.callback.await('JD_CommunityService:completeService')
		ShowNotification('You have been released from community service. Best behaviour, citizen!')
	end
end

changeClothing = function()
	local gender = GetEntityModel(PlayerPedId())
	local PlayerPed = PlayerPedId()
	if gender == GetHashKey('mp_m_freemode_01') then
		for k, v in pairs(Config.Clothes.male.components) do
			SetPedComponentVariation(PlayerPed, v['component_id'], v['drawable'], v['texture'], 0)
		end
	else
		for k, v in pairs(Config.Clothes.female.components) do
			SetPedComponentVariation(PlayerPed, v['component_id'], v['drawable'], v['texture'], 0)
		end
	end
end

returnClothing = function()
	if Config.Framework == 'qbcore' then
		TriggerServerEvent("qb-clothes:loadPlayerSkin") -- LOADING PLAYER'S CLOTHES
		TriggerServerEvent("qb-clothing:loadPlayerSkin") -- LOADING PLAYER'S CLOTHES - Event 2
	else
		ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
			TriggerEvent('skinchanger:loadSkin', skin)
		end)
	end
end

lib.callback.register('JD_CommunityService:inputCallback', function()
	local input = lib.inputDialog('Community Service', {
		{ type = 'input', label = 'Citizen ID', description = 'Citizen ID of the person to be released', required = true },
		{ type = 'input', label = 'Number of actions', description = 'Number of actions citizen will need to carry out', required = true }
	}, { allowCancel = false })
	return input
end)

lib.callback.register('JD_CommunityService:inputCallbackAdmin', function()
	local input = lib.inputDialog('Community Service', {
		{ type = 'input', label = 'Citizen ID', description = 'Citizen ID of the person to be released', required = true },
		{ type = 'select', label = 'Number of actions', description = 'Number of actions citizen will need to carry out', options = {{value = "150", label = "150 RDM VDM NLR"}} , required = true },
		{ type = 'textarea', label = 'Reason', description = 'Give more details', required = true },
	}, { allowCancel = true })
	return input
end)

lib.callback.register('JD_CommunityService:inputCallbackPolice', function()
	local input = lib.inputDialog('Community Service', {
		{ type = 'input', label = 'Citizen ID', description = 'Citizen ID of the person to be released', required = true },
		{ type = 'input', disabled = true , label = 'Number of actions', description = 'Number of actions citizen will need to carry out', default = "60"}
	}, { allowCancel = false })
	return input
end)

lib.callback.register('JD_CommunityService:inputCallbackGM', function()
	local input = lib.inputDialog('Community Service', {
		{ type = 'input', label = 'Citizen ID', description = 'Citizen ID of the person to be released', required = true },
		{ type = 'input', disabled = true , label = 'Number of actions', description = 'Number of actions citizen will need to carry out', default = "150"},
		{ type = 'textarea', label = 'Reason', description = 'Give more details', required = true },
	}, { allowCancel = false })
	return input
end)

lib.callback.register('JD_CommunityService:inputCallbackQuit', function()
	local input = lib.inputDialog('Community Service F8 QUIT', {
		{ type = 'input', label = 'License', description = 'License of the person', required = true },
		{ type = 'input', label = 'Number of actions', description = 'Number of actions citizen will need to carry out', required = true }
	}, { allowCancel = false })
	return input
end)

lib.callback.register('JD_CommunityService:inputCallbackRelease', function()
	local input = lib.inputDialog('Community Service', {
		{ type = 'input', label = 'Citizen ID', description = 'Citizen ID of the person to be released', required = true } 
	}, { allowCancel = false })
	return input
end)

local function IsWhitelistedWeapons(weapon)
    for k,v in pairs(Config.WhitelistedWeapons) do 
        if GetHashKey(v) == weapon then return true end
    end
    return false
end

RegisterNetEvent('JD_CommunityService:startCheckWeapon')
AddEventHandler('JD_CommunityService:startCheckWeapon', function()
	
	Citizen.CreateThread(function()
		while inService do
			if IsPedArmed(PlayerPedId(), 7) then
                local hasWeapon, currentWeapon = GetCurrentPedWeapon(PlayerPedId(), true)
                if not IsWhitelistedWeapons(currentWeapon) then 
				    SetCurrentPedWeapon(PlayerPedId(), GetHashKey('WEAPON_UNARMED'), true)
                end
			end
			Citizen.Wait(100)
		end
	end)

end)



Citizen.CreateThread(function()
    while true do
        local sleep = 2000
        local ped_coords = GetEntityCoords(PlayerPedId())
        local distance = GetDistanceBetweenCoords(ped_coords, Config.ReleasePedLocation.x, Config.ReleasePedLocation.y, Config.ReleasePedLocation.z, true)
        if distance <= 15 then
            sleep = 1
            if distance <= 10 then
                DrawText3D(Config.ReleasePedLocation.x, Config.ReleasePedLocation.y, Config.ReleasePedLocation.z, '~w~Press [~b~E~w~] to bail out of community service ~g~$~w~'.. Config.ReleasePrice)
                DrawMarker(27, Config.ReleasePedLocation.x, Config.ReleasePedLocation.y, Config.ReleasePedLocation.z-0.9, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 1.0, 1.0, 1.0, 8, 158, 231, 100, false, true, 2, false, false, false, false)
                if distance <= 1.5 then
                    if IsControlJustPressed(0, 38) then
						if inService then 
							ESX.TriggerServerCallback('JD_CommunityService:CheckPayment', function(result)
								if result then
									TriggerEvent('JD_CommunityService:releaseService')
									removeInteracts()
									DeleteObject(obj)
									obj = nil
								else
									exports['okokNotify']:Alert('Community Service', 'You dont have enough money !', 5000, 'error')
								end
							end)
						else
							exports['okokNotify']:Alert('Community Service', 'You are not in service !', 5000, 'error')
						end
                    end
                end
            end
        end
        Citizen.Wait(sleep)
    end
end)

Citizen.CreateThread(function()
    RequestModel(GetHashKey('csb_cop'))
    while not HasModelLoaded(GetHashKey('csb_cop')) do
        Wait(1)
    end   
	local ped = CreatePed(4, GetHashKey('csb_cop'), Config.ReleasePedLocation.x, Config.ReleasePedLocation.y, Config.ReleasePedLocation.z-1.0, Config.ReleasePedLocation.w, false, true)
	SetEntityHeading(ped, Config.ReleasePedLocation.w)
	FreezeEntityPosition(ped, true)
	SetEntityInvincible(ped, true)
	SetBlockingOfNonTemporaryEvents(ped, true)
end)

function DrawText3D(x,y,z,text,size)
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)

    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x,_y)
    local factor = (string.len(text)) / 370
    DrawRect(_x,_y+0.0125, 0.015+ factor, 0.03, 41, 11, 41, 68)
end

local cam = nil

playScene_photo = function()
	DoScreenFadeOut(100)
	Citizen.Wait(250)
	RequestModel(-1320879687)
	while not HasModelLoaded(-1320879687) do
		Citizen.Wait(10)
	end
	local PolicePosition = vector4(-51.2270, -87.5172, -1.0186, 114.6659)
	local PlayerPosition = vector4(-54.3347, -89.3014, -2.0098, 298.2685)
	local Police = CreatePed(5, -1320879687, PolicePosition.x, PolicePosition.y, PolicePosition.z, PolicePosition.w, false)
	TaskStartScenarioInPlace(Police, "WORLD_HUMAN_PAPARAZZI", 0, false)
	local PlayerPed = PlayerPedId()
	ESX.Game.Teleport(PlayerPed, PlayerPosition)
	FreezeEntityPosition(PlayerPed, true)
	exports["rpemotes"]:EmoteCommandStart("mugshot", 0)
	Cam()
	Citizen.Wait(1000)
	DoScreenFadeIn(100)
	Citizen.Wait(10000)
	DoScreenFadeOut(250)
	DeleteEntity(Police)
	SetModelAsNoLongerNeeded(-1320879687)
	Citizen.Wait(1000)
	DoScreenFadeIn(250)
	RenderScriptCams(false,  false,  0,  true,  true)
	FreezeEntityPosition(PlayerPed, false)
	DestroyCam(cam)
	exports["rpemotes"]:EmoteCancel()
end

playScene = function()
	DoScreenFadeIn(100)
	DoScreenFadeOut(100)
	Citizen.Wait(250)
	local CellPosition = Config.Cells[math.random(1, #Config.Cells)].coords
	local PlayerPed = PlayerPedId()
	TriggerEvent('InteractSound_CL:PlayOnOne', 'cell', 1.0)
	ESX.Game.Teleport(PlayerPed, CellPosition)
	Citizen.Wait(1000)
	FreezeEntityPosition(PlayerPed, true)
	DoScreenFadeIn(100)
	
	lib.progressBar({
        duration = 10000,
        label = 'Waiting for Trial',
        useWhileDead = false,
        canCancel = false,
        disable = {
            move = true,
            car = true
        }
    }) 

	DoScreenFadeOut(250)
	Citizen.Wait(1000)
	DoScreenFadeIn(250)
	FreezeEntityPosition(PlayerPed, false)
end

function Cam()
	local CamOptions = { position = vector3(-48.475918, -86.090500, 0.452281), rotation = vector3(-7.237511, 0.000000, 107.397400)}
	cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    SetCamCoord(cam, CamOptions.position.x, CamOptions.position.y, CamOptions.position.z)
	SetCamRot(cam, CamOptions.rotation.x, CamOptions.rotation.y, CamOptions.rotation.z)
	RenderScriptCams(true, false, 0, true, true)
end

AddEventHandler('esx:onPlayerDeath', function(data)
    if not inService then return end
 	Wait(1 * 1000)
    TriggerEvent('esx_ambulancejob:revive_deathmatch')
end)

InCommunityService = function()
	return inService
end

exports('InCommunityService', InCommunityService)


updateActions = function()
	TriggerServerEvent('JD_CommunityService:saveActions', existingActions)
end


local COP = nil

Citizen.CreateThread(function()  
    local ped_hash = GetHashKey(Config.Escape.cop.model)
    local coords = Config.Escape.cop.coords
    ESX.Streaming.RequestModel(ped_hash)
    COP = CreatePed(5, ped_hash, coords.x, coords.y, coords.z-1, coords.w, false, true)
    PlaceObjectOnGroundProperly(COP)
    FreezeEntityPosition(COP, true)
    SetEntityInvincible(COP, true)
    SetBlockingOfNonTemporaryEvents(COP, true)	     
end)

Citizen.CreateThread(function()
	local coords = Config.Escape.cop.coords
    while true do
		local wait = 1000
		local ped = PlayerPedId()
		local ped_coords = GetEntityCoords(ped)
		if GetDistanceBetweenCoords(ped_coords, coords,true) <= 2.0 then
			wait = 1
			ESX.ShowHelpNotification('Press ~INPUT_CONTEXT~ to escape for ~g~'..ESX.Math.GroupDigits(Config.Escape.price)..'~s~')
			if IsControlJustReleased(0, 38) then
				if FromArrest then
					Escape()
				else
					ESX.ShowNotification('~r~No way to escape~s~')
				end
			end
		end	
        Citizen.Wait(wait)
    end
end)

function Escape()
	if not inService then
		ESX.ShowNotification('~r~You are not in community service~s~')
		return 
	end
	if not canEscape then
		ESX.ShowNotification('~r~You already tried to escape, no more tries~s~')
		return 
	end
	ESX.TriggerServerCallback('JD_CommunityService:payEscape', function(paid)
		if paid then
			canEscape = false
			local success = lib.skillCheck({'hard', 'medium', 'hard'} )
			if success then
				OnEscape()
			else
				ESX.ShowNotification('~r~You failed to escape.~s~')
			end
		else
			ESX.ShowNotification('~r~You dont have enough money~s~')
		end
	end)
end

function OnEscape()
	inService = false
	canEscape = true
	returnClothing()
	lib.callback.await('JD_CommunityService:completeService')
	ESX.Game.Teleport(PlayerPedId(), Config.Escape.espace_coords)
	ShowNotification('You escaped. you be tracked for 3 minutes.')
	TriggerServerEvent('JD_CommunityService:escaped')
	StartGPS()
end

StartGPS = function()
	local n = 6
	CreateThread(function()
		while n > 0 do
			n = n - 1
			local ped_coords = GetEntityCoords(PlayerPedId())
			TriggerServerEvent('JD_CommunityService:notifyPolice', ped_coords)
			Wait(30000)
		end
	end)
end

local Blips = {}

RegisterNetEvent('JD_CommunityService:notifyPolice')
AddEventHandler('JD_CommunityService:notifyPolice', function(coords, source)
	if PlayerJob and PlayerJob.name == 'police' then
		if Blips[source] then
			RemoveBlip(Blips[source])
		end
		Blips[source] = AddBlipForCoord(coords)
		SetBlipSprite(Blips[source], 480)
		SetBlipColour(Blips[source], 1)
		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString("Fugitive")
		EndTextCommandSetBlipName(Blips[source])
		SetBlipAsShortRange(Blips[source],true)
		SetBlipScale(Blips[source], 1.2)
		SetBlipFlashTimer(Blips[source], 30000)
	end
end)

