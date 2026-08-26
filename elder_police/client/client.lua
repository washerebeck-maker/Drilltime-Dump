
playerLoaded, isDead, isBusy, disableKeys, cuffProp, isCuffed, inMenu, isRagdoll, cuffTimer, escorting, escorted = nil, nil, nil, nil, nil, nil, nil, nil, {}, {}, {}

RegisterNetEvent('elder_police:tackled', function(targetId)
    getTackled(targetId)
end)

RegisterNetEvent('elder_police:tackle', function()
    tacklePlayer()
end)

AddEventHandler('elder_police:onPlayerSpawn', function()
    isDead = false
end)

AddEventHandler('elder_police:onPlayerDeath', function()
    isDead = true
    if isCuffed then
        uncuffed()
    end
    if escorting?.active then
        escorting.active = nil
        escorting.target = nil
    end
    if HasGroup(Config.policeJobs) then
        TriggerServerEvent('elder_police:copDown', GetEntityCoords(cache.ped)) 
    end
end)

RegisterNetEvent('elder_police:copDown')
AddEventHandler('elder_police:copDown', function(coords)
    if not HasGroup(Config.policeJobs) and not HasGroup(Config.emsJobs) then return end
    CreateThread(function()
        PlaySoundFrontend(-1, "TIMER_STOP", "HUD_MINI_GAME_SOUNDSET", 1)
        local s1, s2 = GetStreetNameAtCoord(coords.x, coords.y, coords.z)
        local street1 = GetStreetNameFromHashKey(s1)
        local street2 = GetStreetNameFromHashKey(s2)
        ShowNotification("~b~[Police] ~s~ Officer down in ~y~".. street1 .. (s2 and ("/"..street2) or "" ) .. "~s~")
        local blip = AddBlipForCoord(coords)
        SetBlipSprite(blip, 153)
        SetBlipColour(blip, 1)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("police")
        EndTextCommandSetBlipName(blip)
        --SetBlipAsShortRange(blip,true)
        SetBlipScale(blip, 1.2)
        --SetBlipFlashTimer(blip, 120000)
        local blip2 = AddBlipForCoord(coords)
        SetBlipSprite(blip2, 161)
        SetBlipColour(blip2, 1)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("police")
        EndTextCommandSetBlipName(blip2)
        --SetBlipAsShortRange(blip,true)
        SetBlipScale(blip2, 1.2)
        --SetBlipFlashTimer(blip2, 120000)
        Wait(120000)
        RemoveBlip(blip)
        RemoveBlip(blip2)
    end)
end)

ShowNotification = function(msg)
	AddTextEntry('elderNotification', msg)
	BeginTextCommandThefeedPost('elderNotification')
	EndTextCommandThefeedPostTicker(false)
end

AddEventHandler('elder_police:searchPlayer', function()
    searchPlayerMenu()
end)

AddEventHandler('elder_police:searchPlayerFull', function()
    if not HasGroup(Config.policeJobs) then return end
    local coords = GetEntityCoords(cache.ped)
    local player = lib.getClosestPlayer(vec3(coords.x, coords.y, coords.z), 2.0, false)
    if not player then
        TriggerEvent('elder_police:notify', Strings.no_nearby, Strings.no_nearby_desc, 'error')
    else
        searchPlayer(player, true)
    end
end)

AddEventHandler('elder_police:searchPlayerPartial', function()
    if not HasGroup(Config.policeJobs) then return end
    local coords = GetEntityCoords(cache.ped)
    local player = lib.getClosestPlayer(vec3(coords.x, coords.y, coords.z), 2.0, false)
    if not player then
        TriggerEvent('elder_police:notify', Strings.no_nearby, Strings.no_nearby_desc, 'error')
    else
        searchPlayer(player, false)
    end
end)

AddEventHandler('elder_police:jailPlayer', function()
    if not HasGroup(Config.policeJobs) then return end
    local coords = GetEntityCoords(cache.ped)
    local player = lib.getClosestPlayer(vec3(coords.x, coords.y, coords.z), 2.0, false)
    if not player then
        TriggerEvent('elder_police:notify', Strings.no_nearby, Strings.no_nearby_desc, 'error')
    else
        local input = lib.inputDialog(Strings.minutes_dialog, {Strings.minutes_dialog_field})
        if not input then return end
        local quantity = math.floor(tonumber(input[1]))
        if quantity < 1 then
            TriggerEvent('elder_police:notify', Strings.invalid_amount, Strings.invalid_amount_desc, 'error')
        else
            TriggerEvent('elder_police:sendToJail', GetPlayerServerId(player), quantity)
        end
    end
end)

--AddEventHandler('elder_police:sendPlayerToCell', function()
--    if not HasGroup(Config.policeJobs) then return end
    

--        local input = lib.inputDialog('Send suspect to cell', {
--            { type = 'number', label = 'Id', description = 'player id', required = true },
--           { type = 'input', label = 'Reason', description = 'the reason', required = true }
--        }, { allowCancel = true })
--        if not input then return end
--        TriggerServerEvent('elder_police:sendPlayerToCell', input[1], input[2], math.random(1,#Config.Cells))
    
--end)

AddEventHandler('elder_police:checkJailList', function()
    local data = lib.callback.await('elder_police:getJailList', 100)
    local options = {}
    for k,v in pairs(data) do
        options[#options+1] = {
            title = '#'..v.id .. ':'..v.player .. ' -> ' .. v.reason,
            description = 'Jailed by ' .. v.police,
            icon = 'magnifying-glass',
            arrow = false,
            readOnly = true
        }
    end
    lib.registerContext({
        id = 'jail_menu',
        title = 'Jail Check',
        options = options
    })
    lib.showContext('jail_menu')
end)

AddEventHandler('elder_police:arrestCivilian', function()
    TriggerServerEvent('okokArrest:SendContractToCitizen')
end)

AddEventHandler('elder_police:trafficTicket', function()
	if not HasGroup(Config.policeJobs) then return end
    local coords = GetEntityCoords(cache.ped)
    local player = lib.getClosestPlayer(vec3(coords.x, coords.y, coords.z), 2.0, false)
    if not player then
        TriggerEvent('elder_police:notify', Strings.no_nearby, Strings.no_nearby_desc, 'error')
    else
        local input = lib.inputDialog('Traffic Ticket (15k)', {
            { type = 'input', label = 'Reason', description = 'the reason of the traffic ticket', required = true }
        }, { allowCancel = true })
        if not input then return end
        if not input[1] or input[1] == '' then 
            TriggerEvent('elder_police:notify', 'NYPD', 'Invalide traffic ticket.', 'error')
            return
        end
        TriggerServerEvent('elder_police:trafficTicket', GetPlayerServerId(player), input[1])
    end
end)

AddEventHandler('elder_police:viewWeapons', function()
	if not HasGroup(Config.policeJobs) then return end
    local coords = GetEntityCoords(cache.ped)
    local player = lib.getClosestPlayer(vec3(coords.x, coords.y, coords.z), 2.0, false)
    if not player then
        TriggerEvent('elder_police:notify', Strings.no_nearby, Strings.no_nearby_desc, 'error')
    else
        OpenViewWeapons(GetPlayerServerId(player))
    end
end)

AddEventHandler('elder_police:client:warm', function()
	if not HasGroup(Config.policeJobs) then return end
    local input = lib.inputDialog('Suspect Warm', {
        { type = 'number', label = 'ID', description = 'suspect id', required = true }
    }, { allowCancel = true })
    if not input then return end
    TriggerServerEvent('elder_police:server:warm', tonumber(input[1]))
end)


RegisterNetEvent('elder_police:trafficTicketRequest')
AddEventHandler('elder_police:trafficTicketRequest', function(officer, reason)
	local alert = lib.alertDialog({
        header = 'You got NYPD Traffic Ticket',
        content = 'Reason : '..reason,
        centered = true,
        cancel = true,
        labels = {
            cancel=  "Pay 35K",
            confirm=  "Community Serivice",
        }
    })

    if alert == 'cancel' then
        TriggerServerEvent('elder_police:trafficTicketPay', officer)
    else
        TriggerServerEvent('elder_police:trafficTicketComServ', officer)
    end
    
end)


AddEventHandler('elder_police:spawnVehicle', function(data)
    inMenu = false
    local model = data.model
    local category = Config.Locations[data.station].vehicles.options[data.grade][data.model].category
    local spawnLoc = Config.Locations[data.station].vehicles.spawn[category]
    if not IsModelInCdimage(GetHashKey(model)) then
       -- print('Vehicle model not found: '..model)
    else
        local nearbyVehicles = lib.getNearbyVehicles(vec3(spawnLoc.coords.x, spawnLoc.coords.y, spawnLoc.coords.z), 6.0, true)
        if #nearbyVehicles > 0 then
            TriggerEvent('elder_police:notify', Strings.spawn_blocked, Strings.spawn_blocked_desc, 'error')
            return
        end
        DoScreenFadeOut(800)
        while not IsScreenFadedOut() do
            Wait(100)
        end
        lib.requestModel(model, 100)
        local vehicle = CreateVehicle(GetHashKey(model), spawnLoc.coords.x, spawnLoc.coords.y, spawnLoc.coords.z, spawnLoc.heading, 1, 0)
        TaskWarpPedIntoVehicle(cache.ped, vehicle, -1)
        if Config.customCarlock then
            local plate = GetVehicleNumberPlateText(vehicle)
            addCarKeys(plate, model)
        end
        SetModelAsNoLongerNeeded(model)
        DoScreenFadeIn(800)
    end
end)

AddEventHandler('elder_police:handcuffPlayer', function()
    if not HasGroup(Config.policeJobs) then return end
    local coords = GetEntityCoords(cache.ped)
    local player = lib.getClosestPlayer(vec3(coords.x, coords.y, coords.z), 2.0, false)
    if not player then
        TriggerEvent('elder_police:notify', Strings.no_nearby, Strings.no_nearby_desc, 'error')
    else
        handcuffPlayer(GetPlayerServerId(player), false)
    end
end)

AddEventHandler('elder_police:handcuffPlayerHard', function()
    if not HasGroup(Config.policeJobs) then return end
    local coords = GetEntityCoords(cache.ped)
    local player = lib.getClosestPlayer(vec3(coords.x, coords.y, coords.z), 2.0, false)
    if not player then
        TriggerEvent('elder_police:notify', Strings.no_nearby, Strings.no_nearby_desc, 'error')
    else
        handcuffPlayer(GetPlayerServerId(player), true)
    end
end)

RegisterNetEvent('elder_police:arrested', function(pdId,hard)
    isBusy = true
    local escaped
    local pdPed = GetPlayerPed(GetPlayerFromServerId(pdId))
    lib.requestAnimDict('mp_arrest_paired', 1000)
    AttachEntityToEntity(cache.ped, pdPed, 11816, -0.1, 0.45, 0.0, 0.0, 0.0, 20.0, false, false, false, false, 20, false)
	TaskPlayAnim(cache.ped, 'mp_arrest_paired', 'crook_p2_back_left', 8.0, -8.0, 5500, 33, 0, false, false, false)
    if Config.handcuff.skilledEscape.enabled then
        if lib.skillCheck(Config.handcuff.skilledEscape.difficulty) then
            escaped = true
        end
    end
	FreezeEntityPosition(pdPed, true)
    Wait(2000)
	DetachEntity(cache.ped, true, false)
	FreezeEntityPosition(pdPed, false)
    RemoveAnimDict('mp_arrest_paired')
    if not escaped then
        handcuffed(hard)
    end
    isBusy = false
end)

RegisterNetEvent('elder_police:arrest', function()
    isBusy = true
    lib.requestAnimDict('mp_arrest_paired', 1000)
    TaskPlayAnim(cache.ped, 'mp_arrest_paired', 'cop_p2_back_left', 8.0, -8.0, 3400, 33, 0, false, false, false)
    Wait(3000)
    isBusy = false
end)

RegisterNetEvent('elder_police:uncuffAnim', function(target)
    local targetPed = GetPlayerPed(GetPlayerFromServerId(target))
    local targetCoords = GetEntityCoords(targetPed)
    if escorting?.active then
        escorting.active = nil
        escorting.target = nil
    end
    TaskTurnPedToFaceCoord(cache.ped, targetCoords.x, targetCoords.y, targetCoords.z, 2000)
    Wait(2000)
    TaskStartScenarioInPlace(cache.ped, 'PROP_HUMAN_PARKING_METER', 0, true)
    Wait(2000)
    ClearPedTasks(cache.ped)
end)

RegisterNetEvent('elder_police:uncuff', function()
    uncuffed()
end)

RegisterNetEvent('elder_police:stopEscorting', function()
    if not escorting.active then return end
    escorting.active = nil
    escorting.target = nil
end)

AddEventHandler('elder_police:escortPlayer', function()
    if not HasGroup(Config.policeJobs) then return end
    local coords = GetEntityCoords(cache.ped)
    local player = lib.getClosestPlayer(vec3(coords.x, coords.y, coords.z), 2.0, false)
    if not player then
        TriggerEvent('elder_police:notify', Strings.no_nearby, Strings.no_nearby_desc, 'error')
    else
        escortPlayer(GetPlayerServerId(player))
    end
end)

AddEventHandler('elder_police:lockpickVehicle', function()
    local coords = GetEntityCoords(cache.ped)
    local vehicle = lib.getClosestVehicle(vec3(coords.x, coords.y, coords.z), 5.0, false)
    if not vehicle or not DoesEntityExist(vehicle) then
        TriggerEvent('elder_police:notify', Strings.vehicle_not_found, Strings.vehicle_not_found_desc, 'error')
    else
        local vehCoords = GetEntityCoords(vehicle)
        local dist = #(vec3(coords.x, coords.y, coords.z) - vec3(vehCoords.x, vehCoords.y, vehCoords.z))
        if dist < 2.5 then
            lockpickVehicle(vehicle)
        else
            TriggerEvent('elder_police:notify', Strings.too_far, Strings.too_far_desc, 'error')
        end
    end
end)

AddEventHandler('elder_police:impoundVehicle', function()
    if not HasGroup(Config.policeJobs) then return end
    TriggerEvent('elder_impoundjob:client:impoundVehiclePolice')
end)

AddEventHandler('elder_police:vehicleInfo', function()
    local coords = GetEntityCoords(cache.ped)
    local vehicle = lib.getClosestVehicle(vec3(coords.x, coords.y, coords.z), 5.0, false)
    if not vehicle or not DoesEntityExist(vehicle) then
        TriggerEvent('elder_police:notify', Strings.vehicle_not_found, Strings.vehicle_not_found_desc, 'error')
    else
        local vehCoords = GetEntityCoords(vehicle)
        local dist = #(vec3(coords.x, coords.y, coords.z) - vec3(vehCoords.x, vehCoords.y, vehCoords.z))
        if dist < 3.5 then
            vehicleInfoMenu(vehicle)
        else
            TriggerEvent('elder_police:notify', Strings.too_far, Strings.too_far_desc, 'error')
        end
    end
end)

AddEventHandler('elder_police:openBossMenu', function()
    if not HasGroup(Config.policeJobs) then return end
    local job, _grade = HasGroup(Config.policeJobs)
    OpenBossMenu()
end)

RegisterNetEvent('elder_police:escortedPlayer', function(pdId)
    if isCuffed then
        escorted.active = not escorted.active
        escorted.pdId = pdId
    end
end)

RegisterNetEvent('elder_police:setEscort', function(targetId)
    if not HasGroup(Config.policeJobs) then return end
    escorting.active = not escorting.active
    escorting.target = targetId
end)

RegisterNetEvent('elder_police:putInVehicle', function()
    if isCuffed then
        if escorted.active then
            escorted.active = nil
            escorted.pdId = nil
            Wait(1000)
        end
        local coords = GetEntityCoords(cache.ped)
        if IsAnyVehicleNearPoint(coords, 5.0) then
			local vehicle = GetVehicleInDirection()
			if DoesEntityExist(vehicle) then
				local maxSeats, freeSeat = GetVehicleMaxNumberOfPassengers(vehicle)
				for i=maxSeats - 1, 0, -1 do
					if IsVehicleSeatFree(vehicle, i) then
						freeSeat = i
						break
					end
				end
				if freeSeat then
                    FreezeEntityPosition(cache.ped, false)
					TaskWarpPedIntoVehicle(cache.ped, vehicle, freeSeat)
                    FreezeEntityPosition(cache.ped, true)
				end
			end
		end
    end
end)

RegisterNetEvent('elder_police:takeFromVehicle', function()
	if IsPedSittingInAnyVehicle(cache.ped) then
		local vehicle = GetVehiclePedIsIn(cache.ped, false)
		TaskLeaveVehicle(cache.ped, vehicle, 64)
                FreezeEntityPosition(cache.ped, false)
	end
end)

AddEventHandler('elder_police:inVehiclePlayer', function()
    if not HasGroup(Config.policeJobs) then return end
    local coords = GetEntityCoords(cache.ped)
    local player = lib.getClosestPlayer(coords, 4.0, false)
    if not player then
        TriggerEvent('elder_police:notify', Strings.no_nearby, Strings.no_nearby_desc, 'error')
    else
        TriggerServerEvent('elder_police:inVehiclePlayer', GetPlayerServerId(player))
    end
end)

AddEventHandler('elder_police:outVehiclePlayer', function()
    if not HasGroup(Config.policeJobs) then return end
    local coords = GetEntityCoords(cache.ped)
    local player = lib.getClosestPlayer(coords, 4.0, false)
    if not player then
        TriggerEvent('elder_police:notify', Strings.no_nearby, Strings.no_nearby_desc, 'error')
    else
        TriggerServerEvent('elder_police:outVehiclePlayer', GetPlayerServerId(player))
    end
end)

AddEventHandler('elder_police:vehicleInteractions', function()
    vehicleInteractionMenu(vehicle)
end)

AddEventHandler('elder_police:civilianInteractions', function()
    civilianInteractionMenu()
end)

AddEventHandler('elder_police:pdInteractions', function()
    pdInteractionMenu()
end)

AddEventHandler('elder_police:placeObjects', function()
    placeObjectsMenu(vehicle)
end)

AddEventHandler('elder_police:report', function()
    local input = lib.inputDialog('Report Player', {'id', 'reason'})
    if not input then return end
    if not tonumber(input[1]) or tonumber(input[1]) <= 0 or not input[2] or input[2] == '' then
        TriggerEvent('elder_police:notify', 'LSPD', 'Invalid report', 'error')
        return 
    end
    local id = tonumber(input[1])
    local identifier = lib.callback.await('elder_police:checkSource', 100, id)
    if not identifier then
        TriggerEvent('elder_police:notify', 'LSPD', 'Invalid player id', 'error')
        return
    end
    exports['okokNotify']:Alert("REPORT", "Report successfully sent to the STAFF!", 20000, 'success')	
	local feedbackInfo = {subject = 'LSPD REPORT AGAINST PLAYER :  ' .. id, information = 'Player License ['..identifier..'] ** Reason ['..input[2]..']', category = 'player_report'}
	TriggerServerEvent("okokReports:NewFeedback", feedbackInfo)
end)


AddEventHandler('elder_police:spawnProp', function(index)
    local prop = Config.Props[index]
    local x, y, z = table.unpack(GetOffsetFromEntityInWorldCoords(cache.ped,0.0,2.0,0.55))
    local obj = CreateObjectNoOffset(prop.model, x, y, z, true, false)
    SetEntityHeading(obj, GetEntityHeading(cache.ped))
    PlaceObjectOnGroundProperly(obj)
    FreezeEntityPosition(obj, true)
end)

AddEventHandler('elder_police:licenseMenu', function(data)
    if not HasGroup(Config.policeJobs) then return end
    openLicenseMenu(data)
end)

AddEventHandler('elder_police:purchaseArmoury', function(data)
    if not HasGroup(Config.policeJobs) then return end
    local data = data
    data.quantity = 1
    if data.multiple then
        local input = lib.inputDialog(Strings.armoury_quantity_dialog, {Strings.quantity})
        if not input then return end
        local quantity = math.floor(tonumber(input[1]))
        if quantity < 1 then
            TriggerEvent('elder_police:notify', Strings.invalid_amount, Strings.invalid_amount_desc, 'error')
        else
            data.quantity = quantity
        end
    end
    local canPurchase = lib.callback.await('elder_police:canPurchase', 100, data)
    if canPurchase then
        TriggerEvent('elder_police:notify', Strings.success, Strings.successful_purchase_desc, 'success')
    else
        TriggerEvent('elder_police:notify', Strings.lacking_funds, Strings.lacking_funds_desc, 'error')
    end
end)

AddEventHandler('elder_police:checkId', function(targetId)
    if not HasGroup(Config.policeJobs) then return end
    if targetId and type(targetId) == 'table' then targetId = nil end
    if not targetId then
        local coords = GetEntityCoords(cache.ped)
        local player = lib.getClosestPlayer(coords, 4.0, false)
        if not player then
            TriggerEvent('elder_police:notify', Strings.no_nearby, Strings.no_nearby_desc, 'error')
        else
            checkPlayerId(GetPlayerServerId(player))
        end
    else
        checkPlayerId(targetId)
    end
end)

AddEventHandler('elder_police:revokeLicense', function(data)
    TriggerServerEvent('elder_police:revokeLicense', data.targetId, data.license)
    TriggerEvent('elder_police:notify', Strings.license_revoked, Strings.license_revoked_desc, 'success')
    Wait(420) -- lul
    checkPlayerId(data.targetId)
end)

AddEventHandler('elder_police:manageId', function(data)
    manageId(data)
end)

CreateThread(function()
    while true do
        local sleep = 1500
        if isCuffed then
            sleep = 0
            if not IsEntityPlayingAnim(cache.ped, 'mp_arresting', 'idle', 3) then
                TaskPlayAnim(cache.ped, 'mp_arresting', 'idle', 8.0, -8, -1, 49, 0.0, false, false, false)
                if not IsEntityPlayingAnim(cache.ped, 'mp_arresting', 'idle', 3) then
                    Wait(3000)
                    TaskPlayAnim(cache.ped, 'mp_arresting', 'idle', 8.0, -8, -1, 49, 0.0, false, false, false)
                    if not IsEntityPlayingAnim(cache.ped, 'mp_arresting', 'idle', 3) then
                        Wait(2000)
                        TaskPlayAnim(cache.ped, 'mp_arresting', 'idle', 8.0, -8, -1, 49, 0.0, false, false, false)
                    end
                end
            end
            DisablePlayerFiring(PlayerId(), true)
            if Config.handcuff.disableAllKeys then
                DisableAllControlActions(0)
                DisableControlAction(27, 75, true) -- Disable exit vehicle when Driving
            else
                DisableControlAction(0, 140, true)
                DisableControlAction(27, 75, true) -- Disable exit vehicle when Driving
                DisableControlAction(0, 25, true)
                DisableControlAction(0, 23, true)
            end
            if not cuffProp or not DoesEntityExist(cuffProp) then
                lib.requestModel('p_cs_cuffs_02_s', 100)
                local x, y, z = table.unpack(GetOffsetFromEntityInWorldCoords(cache.ped,0.0,3.0,0.5))
                cuffProp = CreateObjectNoOffset(`p_cs_cuffs_02_s`, x, y, z, true, false)
                SetModelAsNoLongerNeeded(`p_cs_cuffs_02_s`)
                AttachEntityToEntity(cuffProp, cache.ped, GetPedBoneIndex(cache.ped, 57005), 0.04, 0.06, 0.0, -85.24, 4.2, -106.6, true, true, false, true, 1, true)
            end
        end
        if isRagdoll then
            sleep = 0
            SetPedToRagdoll(cache.ped, 1000, 1000, 0, 0, 0, 0)
        end
        Wait(sleep)
    end
end)

-- Escorting loop
CreateThread(function()
    local alrEscorting
    while true do
        local sleep = 1500
        if escorting?.active then
            sleep = 0
            local targetPed = GetPlayerPed(GetPlayerFromServerId(escorting.target))
            if DoesEntityExist(targetPed) and IsPedOnFoot(targetPed) and not IsPedDeadOrDying(targetPed, true) then
                if not alrEscorting then
                    lib.requestAnimDict('amb@code_human_wander_drinking_fat@beer@male@base', 1000)
                    TaskPlayAnim(cache.ped, 'amb@code_human_wander_drinking_fat@beer@male@base', 'static', 8.0, 1.0, -1, 49, 0, 0, 0, 0)
                    alrEscorting = true
                    RemoveAnimDict('amb@code_human_wander_drinking_fat@beer@male@base')
                elseif alrEscorting and not IsEntityPlayingAnim(cache.ped, 'amb@code_human_wander_drinking_fat@beer@male@base', 'static', 3) then
                    lib.requestAnimDict('amb@code_human_wander_drinking_fat@beer@male@base', 1000)
                    TaskPlayAnim(cache.ped, 'amb@code_human_wander_drinking_fat@beer@male@base', 'static', 8.0, 1.0, -1, 49, 0, 0, 0, 0)
                    RemoveAnimDict('amb@code_human_wander_drinking_fat@beer@male@base')
                else
                    sleep = 1500
                end
            else
                alrEscorting = nil
                escorting.active = nil
                ClearPedTasks(cache.ped)
            end
        elseif alrEscorting then
            alrEscorting = nil
            escorting.active = nil
            ClearPedTasks(cache.ped)
        else
            sleep = 1500
        end
        Wait(sleep)
    end
end)

-- Being escorted loop
CreateThread(function()
    local alrEscorted
    while true do
        local sleep = 1500
        if isCuffed and escorted?.active then
            sleep = 0
            local pdPed = GetPlayerPed(GetPlayerFromServerId(escorted.pdId))
            if DoesEntityExist(pdPed) and IsPedOnFoot(pdPed) and not IsPedDeadOrDying(pdPed, true) then
                if not alrEscorted then
                    AttachEntityToEntity(cache.ped, pdPed, 11816, 0.26, 0.48, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
                    alrEscorted = true
                    isBusy = true
                else
                    sleep = 500
                end
                if IsPedWalking(pdPed) then
                    if not IsEntityPlayingAnim(cache.ped, 'anim@move_m@prisoner_cuffed', 'walk', 3) then
                        lib.requestAnimDict('anim@move_m@prisoner_cuffed', 1000)
                        TaskPlayAnim(cache.ped, 'anim@move_m@prisoner_cuffed', 'walk', 8.0, -8, -1, 1, 0.0, false, false, false)
                    end
                elseif IsPedRunning(pdPed) or IsPedSprinting(pdPed) then
                    if not IsEntityPlayingAnim(cache.ped, 'anim@move_m@trash', 'run', 3) then
                        lib.requestAnimDict('anim@move_m@trash', 1000)
                        TaskPlayAnim(cache.ped, 'anim@move_m@trash', 'run', 8.0, -8, -1, 1, 0.0, false, false, false)
                    end
                elseif IsEntityPlayingAnim(cache.ped, 'anim@move_m@prisoner_cuffed', 'walk', 3) or IsEntityPlayingAnim(cache.ped, 'anim@move_m@trash', 'run', 3) then
                    StopAnimTask(cache.ped, 'anim@move_m@prisoner_cuffed', 'walk', -8.0)
                    StopAnimTask(cache.ped, 'anim@move_m@trash', 'run', -8.0)
                end
            else
                alrEscorted = false
                escorted.active = nil
                isBusy = nil
                DetachEntity(cache.ped, true, false)
            end
        elseif alrEscorted then
            alrEscorted = nil
            isBusy = nil
            DetachEntity(cache.ped, true, false)
        else
            sleep = 1500
        end
        Wait(sleep)
    end
end)

CreateThread(function()
    while PlayerData.job == nil do
        Wait(1000) -- Necessary for some of the loops that use job check in these threads within threads.
    end
    if Config.useTarget then
        for i=1, #Config.policeJobs do
            local data = {
                targetType = 'Player',
                options = {},
                distance = 2.0
            }
            if Config.searchPlayers then
                data.options[#data.options + 1] = {
                    num = #data.options + 1,
                    event = 'elder_police:searchPlayer',
                    icon = 'fas fa-magnifying-glass',
                    label = Strings.search_player,
                    job = Config.policeJobs[i],
                }
            end
            data.options[#data.options + 1] = {
                num = #data.options + 1,
                event = 'elder_police:checkId',
                icon = 'fas fa-id-card',
                label = Strings.check_id,
                job = Config.policeJobs[i],
            }
            data.options[#data.options + 1] = {
                num = #data.options + 1,
                event = 'elder_police:handcuffPlayer',
                icon = 'fas fa-bandage',
                label = Strings.handcuff_player,
                job = Config.policeJobs[i],
            }
            data.options[#data.options + 1] = {
                num = #data.options + 1,
                event = 'elder_police:escortPlayer',
                icon = 'fas fa-hand-holding-hand',
                label = Strings.escort_player,
                job = Config.policeJobs[i],
            }
            data.options[#data.options + 1] = {
                num = #data.options + 1,
                event = 'elder_police:inVehiclePlayer',
                icon = 'fas fa-arrow-right-to-bracket',
                label = Strings.put_in_vehicle,
                job = Config.policeJobs[i],
            }
            data.options[#data.options + 1] = {
                num = #data.options + 1,
                event = 'elder_police:outVehiclePlayer',
                icon = 'fas fa-arrow-right-from-bracket',
                label = Strings.take_out_vehicle,
                job = Config.policeJobs[i],
            }
            TriggerEvent('elder_police:addTarget', data)
        end
    end
    for k,v in pairs(Config.Locations) do
        if v.blip.enabled then
            createBlip(v.blip.coords, v.blip.sprite, v.blip.color, v.blip.string, v.blip.scale, false, false)
        end
        if v.bossMenu.enabled then
            if v.bossMenu?.target?.enabled then
                local data = {
                    targetType = 'AddBoxZone',
                    identifier = k..'_pdboss',
                    coords = v.bossMenu.target.coords,
                    heading = v.bossMenu.target.heading,
                    width = v.bossMenu.target.width,
                    length = v.bossMenu.target.length,
                    minZ = v.bossMenu.target.minZ,
                    maxZ = v.bossMenu.target.maxZ,
                    job = Config.policeJobs,
                    distance = 2.0,
                    options = {
                        {
                            event = 'elder_police:openBossMenu',
                            icon = 'fa-solid fa-suitcase-medical',
                            label = v.bossMenu.target.label
                        }
                    }
                }
                TriggerEvent('elder_police:addTarget', data)
            else
                CreateThread(function()
                    local textUI
                    while true do
                        local sleep = 1500
                        local hasJob
                        local jobName, jobGrade = HasGroup(Config.policeJobs)
                        if jobName then hasJob = jobName end
                        if hasJob then
                            if v.bossMenu.jobLock then
                                if hasJob == v.bossMenu.jobLock then
                                    local coords = GetEntityCoords(cache.ped)
                                    local dist = #(coords - v.bossMenu.coords)
                                    if dist <= v.bossMenu.distance then
                                        if not textUI then
                                            lib.showTextUI(v.bossMenu.label)
                                            textUI = true
                                        end
                                        sleep = 0
                                        if IsControlJustReleased(0, 38) then
                                            OpenBossMenu(hasJob)
                                        end
                                    else
                                        if textUI then
                                            lib.hideTextUI()
                                            textUI = nil
                                        end
                                    end
                                end
                            else
                                local coords = GetEntityCoords(cache.ped)
                                local dist = #(coords - v.bossMenu.coords)
                                if dist <= v.bossMenu.distance then
                                    if not textUI then
                                        lib.showTextUI(v.bossMenu.label)
                                        textUI = true
                                    end
                                    sleep = 0
                                    if IsControlJustReleased(0, 38) then
                                        OpenBossMenu(hasJob)
                                    end
                                else
                                    if textUI then
                                        lib.hideTextUI()
                                        textUI = nil
                                    end
                                end
                            end
                        end
                        Wait(sleep)
                    end
                end)
            end
        end
        if v.cloakroom.enabled and Framework == 'esx' then
            CreateThread(function()
                local textUI 
                while true do
                    local sleep = 1500
                    local hasJob
                    local jobName, jobGrade = HasGroup(Config.policeJobs)
                    if jobName then hasJob = jobName end
                    if hasJob and v.cloakroom.jobLock then
                        if hasJob == v.cloakroom.jobLock then
                            local coords = GetEntityCoords(cache.ped)
                            local dist = #(coords - v.cloakroom.coords)
                            if dist <= v.cloakroom.range then
                                if not textUI then
                                    lib.showTextUI(v.cloakroom.label)
                                    textUI = true
                                end
                                sleep = 0
                                if IsControlJustReleased(0, 38) then
                                    openOutfits(k)
                                end
                            else
                                if textUI then
                                    lib.hideTextUI()
                                    textUI = nil
                                end
                            end
                        end
                    elseif hasJob and not v.cloakroom.jobLock then
                        local coords = GetEntityCoords(cache.ped)
                        local dist = #(coords - v.cloakroom.coords)
                        if dist <= v.cloakroom.range then
                            if not textUI then
                                lib.showTextUI(v.cloakroom.label)
                                textUI = true
                            end
                            sleep = 0
                            if IsControlJustReleased(0, 38) then
                                openOutfits(k)
                            end
                        else
                            if textUI then
                                lib.hideTextUI()
                                textUI = nil
                            end
                        end
                    end
                    Wait(sleep)
                end
            end)
        end
        if v.armoury.enabled then
            CreateThread(function()
                local ped, pedSpawned
                local textUI
                while true do
                    local sleep = 1500
                    local hasJob
                    local jobName, jobGrade = HasGroup(Config.policeJobs)
                    if jobName then hasJob = jobName end
                    local playerPed = cache.ped
                    local coords = GetEntityCoords(playerPed)
                    local dist = #(coords - v.armoury.coords)
                    if dist <= 30 and not pedSpawned then
                        lib.requestAnimDict('mini@strip_club@idles@bouncer@base', 1000)
                        lib.requestModel(v.armoury.ped, 100)
                        ped = CreatePed(28, v.armoury.ped, v.armoury.coords.x, v.armoury.coords.y, v.armoury.coords.z, v.armoury.heading, false, false)
                        FreezeEntityPosition(ped, true)
                        SetEntityInvincible(ped, true)
                        SetBlockingOfNonTemporaryEvents(ped, true)
                        TaskPlayAnim(ped, 'mini@strip_club@idles@bouncer@base', 'base', 8.0, 0.0, -1, 1, 0, 0, 0, 0)
                        pedSpawned = true
                    elseif dist <= 2 and pedSpawned then
                        sleep = 0
                        if not textUI and hasJob then
                            lib.showTextUI(v.armoury.label)
                            textUI = true
                        end
                        if IsControlJustReleased(0, 38) and hasJob then
                            textUI = nil
                            lib.hideTextUI()
                            armouryMenu(k)
                        end
                    elseif dist >= 2.2 and textUI then
                        sleep = 0
                        lib.hideTextUI()
                        textUI = nil
                    elseif dist >= 31 and pedSpawned then
                        local model = GetEntityModel(ped)
                        SetModelAsNoLongerNeeded(model)
                        DeletePed(ped)
                        SetPedAsNoLongerNeeded(ped)
                        RemoveAnimDict('mini@strip_club@idles@bouncer@base')
                        pedSpawned = nil
                    end
                    Wait(sleep)
                end
            end)
        end
        if v.vehicles.enabled then
            CreateThread(function()
                local zone = v.vehicles.zone
                local textUI
                while true do
                    local sleep = 1500
                    local hasJob
                    local jobName, jobGrade = HasGroup(Config.policeJobs)
                    if jobName then hasJob = jobName end
                    if hasJob then
                        if v.jobLock then
                            if hasJob == v.jobLock then
                                local coords = GetEntityCoords(cache.ped)
                                local dist = #(coords - zone.coords)
                                local dist2 = #(coords - v.vehicles.spawn.air.coords)
                                if dist < zone.range + 1 and not inMenu and not IsPedInAnyVehicle(cache.ped, false) then
                                    sleep = 0
                                    if not textUI then
                                        lib.showTextUI(zone.label)
                                        textUI = true
                                    end
                                    if IsControlJustReleased(0, 38) then
                                        textUI = nil
                                        lib.hideTextUI()
                                        openVehicleMenu(k)
                                        sleep = 1500
                                    end
                                elseif dist < zone.range + 1 and not inMenu and IsPedInAnyVehicle(cache.ped, false) then
                                    sleep = 0
                                    if not textUI then
                                        textUI = true
                                        lib.showTextUI(zone.return_label)
                                    end
                                    if IsControlJustReleased(0, 38) then
                                        textUI = nil
                                        lib.hideTextUI()
                                        if DoesEntityExist(cache.vehicle) then
                                            DoScreenFadeOut(800)
                                            while not IsScreenFadedOut() do Wait(100) end
                                            SetEntityAsMissionEntity(cache.vehicle, false, false)
                                            DeleteVehicle(cache.vehicle)
                                            DoScreenFadeIn(800)
                                        end
                                    end
                                elseif dist2 < 10 and IsPedInAnyVehicle(cache.ped, false) then
                                    sleep = 0
                                    if not textUI then
                                        textUI = true
                                        lib.showTextUI(zone.return_label)
                                    end
                                    if IsControlJustReleased(0, 38) then
                                        textUI = nil
                                        lib.hideTextUI()
                                        if DoesEntityExist(cache.vehicle) then
                                            DoScreenFadeOut(800)
                                            while not IsScreenFadedOut() do Wait(100) end
                                            SetEntityAsMissionEntity(cache.vehicle)
                                            DeleteVehicle(cache.vehicle)
                                            SetEntityCoordsNoOffset(playerPed, zone.coords.x, zone.coords.y, zone.coords.z, false, false, false, true)
                                            DoScreenFadeIn(800)
                                        end
                                    end
                                else
                                    if textUI then
                                        textUI = nil
                                        lib.hideTextUI()
                                    end
                                end
                            end
                        else
                            local coords = GetEntityCoords(cache.ped)
                            local dist = #(coords - zone.coords)
                            local dist2 = #(coords - v.vehicles.spawn.air.coords)
                            if dist < zone.range + 1 and not inMenu and not IsPedInAnyVehicle(cache.ped, false) then
                                sleep = 0
                                if not textUI then
                                    lib.showTextUI(zone.label)
                                    textUI = true
                                end
                                if IsControlJustReleased(0, 38) then
                                    textUI = nil
                                    lib.hideTextUI()
                                    openVehicleMenu(k)
                                    sleep = 1500
                                end
                            elseif dist < zone.range + 1 and not inMenu and IsPedInAnyVehicle(cache.ped, false) then
                                sleep = 0
                                if not textUI then
                                    textUI = true
                                    lib.showTextUI(zone.return_label)
                                end
                                if IsControlJustReleased(0, 38) then
                                    textUI = nil
                                    lib.hideTextUI()
                                    if DoesEntityExist(cache.vehicle) then
                                        DoScreenFadeOut(800)
                                        while not IsScreenFadedOut() do Wait(100) end
                                        SetEntityAsMissionEntity(cache.vehicle, false, false)
                                        DeleteVehicle(cache.vehicle)
                                        DoScreenFadeIn(800)
                                    end
                                end
                            elseif dist2 < 10 and IsPedInAnyVehicle(cache.ped, false) then
                                sleep = 0
                                if not textUI then
                                    textUI = true
                                    lib.showTextUI(zone.return_label)
                                end
                                if IsControlJustReleased(0, 38) then
                                    textUI = nil
                                    lib.hideTextUI()
                                    if DoesEntityExist(cache.vehicle) then
                                        DoScreenFadeOut(800)
                                        while not IsScreenFadedOut() do Wait(100) end
                                        SetEntityAsMissionEntity(cache.vehicle)
                                        DeleteVehicle(cache.vehicle)
                                        SetEntityCoordsNoOffset(playerPed, zone.coords.x, zone.coords.y, zone.coords.z, false, false, false, true)
                                        DoScreenFadeIn(800)
                                    end
                                end
                            else
                                if textUI then
                                    textUI = nil
                                    lib.hideTextUI()
                                end
                            end
                        end
                    end
                    Wait(sleep)
                end
            end)
        end
    end
end)

-- Prop placement loop
CreateThread(function()
    while PlayerData?.job == nil do Wait(500) end
    local movingProp = false
    function isEntityProp(ent)
        local model = GetEntityModel(ent)
        for i=1, #Config.Props do 
            if model == Config.Props[i].model then 
                return true, i
            end
        end
    end
    function RequestNetworkControl(entity)
        NetworkRequestControlOfEntity(entity)
        local timeout = 2000
        while timeout > 0 and not NetworkHasControlOfEntity(entity) do
            Wait(100)
            timeout = timeout - 100
        end
        SetEntityAsMissionEntity(entity, true, true)
        local timeout = 2000
        while timeout > 0 and not IsEntityAMissionEntity(entity) do
            Wait(100)
            timeout = timeout - 100
        end
        return NetworkHasControlOfEntity(entity)
    end
    while true do 
        local wait = 2500
        local hasJob
        local jobName, jobGrade = HasGroup(Config.policeJobs)
        if jobName then hasJob = jobName end
        local ped = cache.ped
        local pcoords = GetEntityCoords(ped)
        if hasJob then
            if (not movingProp) then 
                local objPool = GetGamePool('CObject')
                for i = 1, #objPool do
                    local ent = objPool[i]
                    local prop, index = isEntityProp(ent)
                    if (prop) then 
                        local dist = #(GetEntityCoords(ent) - pcoords)
                        if dist < 1.75 and not IsPedInAnyVehicle(ped, false) then 
                            wait = 0
                            ShowHelpNotification(Strings.prop_help_text)
                            if IsControlJustPressed(1, 51) then 
                                RequestNetworkControl(ent)
                                movingProp = ent
                                local c, r = vec3(0.0, 1.0, -1.0), vec3(0.0, 0.0, 0.0)
                                AttachEntityToEntity(movingProp, ped, ped, c.x, c.y, c.z, r.x, r.y, r.z, false, false, false, false, 2, true)
                                break
                            elseif IsControlJustPressed(1, 47) then
                                RequestNetworkControl(ent)
                                DeleteObject(ent)
                                break
                            end
                        end
                    end
                end
            else
                wait = 0
                ShowHelpNotification(Strings.prop_help_text2)
                if IsControlJustPressed(1, 51) then 
                    RequestNetworkControl(movingProp)
                    DetachEntity(movingProp)
                    PlaceObjectOnGroundProperly(movingProp)
                    FreezeEntityPosition(movingProp, true)
                    movingProp = nil
                end
            end
        end
        Wait(wait)
    end
end)

-- Spike strip functionality
if Config.spikeStripsEnabled then
    CreateThread(function()
        local spikes = `p_ld_stinger_s`
        while true do
            local sleep = 1500
            local coords = GetEntityCoords(cache.ped)
            local obj = GetClosestObjectOfType(coords.x, coords.y, coords.z, 100.0, spikes, false, false, false)
            if DoesEntityExist(obj) and IsPedInAnyVehicle(cache.ped, false)  then
                sleep = 0
                local vehicle = GetVehiclePedIsIn(cache.ped)
                local objCoords = GetEntityCoords(obj)
                local dist = #(vec3(coords.x, coords.y, coords.z) - vec3(objCoords.x, objCoords.y, objCoords.z))
                if dist < 3.0 then
                    for i=0, 7 do
                        if not IsVehicleTyreBurst(vehicle, i, false) then
                            SetVehicleTyreBurst(vehicle, i, true, 1000)
                        end
                    end
                    sleep = 1500
                end
            end
            Wait(sleep)
        end
    end)
end

if Config.tackle.enabled then
    RegisterCommand('tacklePlayer', function()
        attemptTackle()
    end)
    TriggerEvent('chat:removeSuggestion', '/tacklePlayer')
    RegisterKeyMapping('tacklePlayer', Strings.key_map_tackle, 'keyboard', Config.tackle.hotkey)
end

if Config.handcuff.hotkey then
    RegisterCommand('cuffPlayer', function()
        TriggerEvent('elder_police:handcuffPlayerHard')
    end)
    TriggerEvent('chat:removeSuggestion', '/cuffPlayer')
    RegisterKeyMapping('cuffPlayer', Strings.key_map_cuff, 'keyboard', Config.handcuff.hotkey)
end 

RegisterCommand('pdJobMenu', function()
    openJobMenu()
end)

AddEventHandler('elder_police:pdJobMenu', function()
    openJobMenu()
end)

AddEventHandler('elder_police:GiveBackVehicle', function(args)
    DeleteEntity(args.vehicle)
    TriggerServerEvent('elder_cartheft:server:GiveBackVehicle', args.plate)
end)

TriggerEvent('chat:removeSuggestion', '/pdJobMenu')

RegisterKeyMapping('pdJobMenu', Strings.key_map_job, 'keyboard', Config.jobMenu)



Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
    local ped = PlayerPedId()
        if IsPedArmed(ped, 6) then
       DisableControlAction(1, 140, true)
              DisableControlAction(1, 141, true)
           DisableControlAction(1, 142, true)
        end
    end
end)

local function IsPoliceVehicle(vehile)
	local model = GetEntityModel(vehicle)
	for k,v in pairs(Config.PoliceVehicles) do 
		if GetHashKey(v) == model then 
			return true
		end
	end
	return false
end

CreateThread(function()
    while not PlayerData.job do Wait(10) end
    while true do
        if PlayerData.job.name ~= 'police' then
            local playerPed = PlayerPedId()
            if IsPedInAnyVehicle(playerPed, true) then
                vehicle = GetVehiclePedIsIn(playerPed, false)
                if GetPedInVehicleSeat(vehicle, -1) == playerPed then
                    if DoesEntityExist(vehicle) and IsPoliceVehicle(vehicle) then
                        TaskLeaveVehicle(playerPed, vehicle, 4160) 
                    end
                end
            end 

        end
        Wait(1000)
    end
end)

Citizen.CreateThread(function()
    local sleep
	while not PlayerData.job do Wait(10) end
    while true do
        if PlayerData.job.name ~= 'police' then
            if IsPedArmed(cache.ped, 6) then
                sleep = 1
                local hasWeapon, currentWeapon = GetCurrentPedWeapon(cache.ped, true)
                if IsPoliceWeapon(currentWeapon) then
                    ESX.ShowNotification("⛔️ This weapons are for PD personal only")
                    SetCurrentPedWeapon(cache.ped, GetHashKey('WEAPON_UNARMED'), true)
                end
            else
                sleep = 500
            end
        else
            sleep = 3000
        end
        Wait(sleep)
    end
end)

CreateThread(function()
    while not PlayerData.job do Wait(10) end
    while true do
        local sleep = 5000
        if PlayerData.job.name == 'police' then
            ResetPlayerStamina(PlayerId())
            sleep = 100
        end
        Wait(sleep)
    end
end)

IsPoliceWeapon = function(weapon_hash)
    for k,v in pairs(Config.PoliceWeapons) do
        if GetHashKey(v) == weapon_hash then
            return true
        end
    end
    return false
end

-- Warm

local Warmed = false
local Blips = {}
local WarmedPlayers = {}

RegisterNetEvent('elder_police:client:onWarmSuspect')
AddEventHandler('elder_police:client:onWarmSuspect', function()
    StartWarm()
end)

RegisterNetEvent('elder_police:client:onWarmPolice')
AddEventHandler('elder_police:client:onWarmPolice', function(id)
    if PlayerData.job.name ~= 'police' then return end
    if #WarmedPlayers == 0 then
        table.insert(WarmedPlayers, id)
        StartPoliceWarm()
    else
        table.insert(WarmedPlayers, id)
    end
    
end)

StartPoliceWarm = function()
    CreateThread(function()
        while #WarmedPlayers > 0 do 
            Wait(1)
            for k,v in pairs(WarmedPlayers) do 
                local id = GetPlayerFromServerId(v)
                local coords = GetEntityCoords(PlayerPedId())
                local player_ped = GetPlayerPed(id) 
                local player_coords = GetEntityCoords(player_ped)
                if GetDistanceBetweenCoords(coords, player_coords, true) > 100 then goto continue end
                wait = 1
                if NetworkIsPlayerActive(id) then
                    x2, y2, z2 = table.unpack(GetPedBoneCoords(player_ped, 0x796e))
                    z2 = z2 + 0.4
                    local color = {r=193,g=15,b=36}
                    DrawText3DTag(vector3(x2, y2, z2), 'Wanted', color)   	
                end
                ::continue::
            end	
        end
    end)
end

StartWarm = function()
    Warmed = true
    local count = 30
    CreateThread(function()
        while Warmed and count > 0 do
            TriggerServerEvent('elder_police:server:warmSuspectPosition', GetEntityCoords(cache.ped)) 
            count = count - 1
            Wait(10000)
        end
        Warmed = false
        TriggerServerEvent('elder_police:server:warmS')
    end)

    CreateThread(function()
        while Warmed do
            DrawNiceText(0.01,0.65 ,0.48,'You have a ~r~warrant~s~ for your arrest!')
            Wait(1)
        end
    end)
end

function DrawNiceText(x, y, scale, text, f, c, n, color)
	color = color or { 255, 255, 255 }
	SetTextFont(f or 4)
	SetTextProportional(0)
	SetTextScale(scale, scale)
	SetTextColour(color[1], color[2], color[3], color[4] or 255)
	SetTextCentre(c)
	if not n then
		SetTextDropShadow()
		SetTextOutline()
		SetTextDropShadow(0, 0, 0, 0,255)
		SetTextEdge(2, 0, 0, 0, 255)
	end
	SetTextEntry("STRING")
	AddTextComponentString(text)
	DrawText(x, y)
end

RegisterNetEvent('elder_police:client:warmSuspectPosition')
AddEventHandler('elder_police:client:warmSuspectPosition', function(coords, id)
    if PlayerData.job.name ~= 'police' then return end
    RemoveBlip(Blips[id])
    Blips[id] = createBlip(coords, 42,1,"Suspect", 1.0, true, false)
end)

RegisterNetEvent('elder_police:client:onWarmSuspectS')
AddEventHandler('elder_police:client:onWarmSuspectS', function()
   
end)

RegisterNetEvent('elder_police:client:onWarmPoliceS')
AddEventHandler('elder_police:client:onWarmPoliceS', function(id)
    if PlayerData.job.name ~= 'police' then return end
    local key = GetValueKey(WarmedPlayers,id)
    if key > 0 then 
        table.remove(WarmedPlayers, key)
        RemoveBlip(Blips[id])
    end
end)

RegisterNetEvent('elder_police:client:onWarmPoliceQuit')
AddEventHandler('elder_police:client:onWarmPoliceQuit', function(id)
    if PlayerData.job.name ~= 'police' then return end
    local key = GetValueKey(WarmedPlayers,id)
    if key > 0 then 
        table.remove(WarmedPlayers, key)
        RemoveBlip(Blips[id])
    end
end)

GetValueKey = function(t,value)
    for k,v in pairs(t) do 
        if value == v then 
            return k
        end
    end
    return -1
end

function DrawText3DTag(coords, text, color)
    local camCoords = GetGameplayCamCoord()
    local dist = #(coords - camCoords)
    local scale = 200 / (GetGameplayCamFov() * dist)
    SetTextColour(250, 250, 250, 250)
    SetTextScale(0.0, 0.6 * 1)
    SetTextFont(4)
	SetTextColour(color.r, color.g, color.b, 255)
    SetTextDropshadow(0, 0, 0, 0, 255)
    SetTextEdge(2, 0, 0, 0, 150)
    SetTextOutline()
	SetTextCentre(1)
	SetTextProportional(1)
    SetTextDropShadow()
    SetTextCentre(true)
    BeginTextCommandDisplayText("STRING")
    AddTextComponentSubstringPlayerName(text)
    SetDrawOrigin(coords, 0)
    EndTextCommandDisplayText(0.0, 0.0)
    ClearDrawOrigin()
end

---- PullOver

PullOver = false

RegisterNetEvent('elder_police:freezeVehicle')
AddEventHandler('elder_police:freezeVehicle', function(freeze)
    local veh = GetVehiclePedIsIn(cache.ped, false)
    if veh and veh ~= 0 then
        FreezeEntityPosition(veh, freeze)
    end
end)

RegisterNetEvent('elder_police:freezeVehicleByNetId')
AddEventHandler('elder_police:freezeVehicleByNetId', function(netId, freeze)
    local veh = NetworkGetEntityFromNetworkId(netId)
    if veh and veh ~= 0 and DoesEntityExist(veh) then
        FreezeEntityPosition(veh, freeze)
    end
end)

RegisterNetEvent('elder_police:freezePullOverResult')
AddEventHandler('elder_police:freezePullOverResult', function(netId, plate, freeze)
    local veh = NetworkGetEntityFromNetworkId(netId)
    if veh and veh ~= 0 and DoesEntityExist(veh) then
        FreezeEntityPosition(veh, freeze)
    end
    if freeze then
        PullOverFrozenPlates[plate] = true
    else
        PullOverFrozenPlates[plate] = nil
    end
end)

AddEventHandler('elder_police:pullOver', function()
    if not HasGroup(Config.policeJobs) then return end
    if not IsPedInAnyVehicle(cache.ped, false) then
        TriggerEvent('elder_police:notify', 'Pull Over', 'You must be in a car to use pull over.', 'error')
        return
    end
    local veh = GetVehiclePedIsIn(cache.ped, false)
    if GetPedInVehicleSeat(veh, -1) ~= cache.ped then
        TriggerEvent('elder_police:notify', 'Pull Over', 'You must be the driver to use pull over.', 'error')
        return
    end
    PullOver = not PullOver
    Wait(500)
    StartPullOver()
end)

local PullOverHighlightedVehicle = nil
local PullOverTextUIShown = false
local PullOverLastPlate = nil
local PullOverLastFrozen = nil
local PullOverFrozenPlates = {}

function StartPullOver()
    if not PullOver then return end
    CreateThread(function()
        while PullOver do
            if not IsPedInAnyVehicle(cache.ped, false) then
                if PullOverTextUIShown then
                    lib.hideTextUI()
                    PullOverTextUIShown = false
                end
                if PullOverHighlightedVehicle and DoesEntityExist(PullOverHighlightedVehicle) then
                    SetEntityDrawOutline(PullOverHighlightedVehicle, false)
                    PullOverHighlightedVehicle = nil
                end
                Wait(500)
            else
                local playerVeh = GetVehiclePedIsIn(cache.ped, false)
                local playerCoords = GetEntityCoords(playerVeh)
                local playerHeading = GetEntityHeading(playerVeh)
                local headingRad = math.rad(playerHeading)
                local forwardX = -math.sin(headingRad)
                local forwardY = math.cos(headingRad)

                local maxDist = 10.0
                local minDotInFront = 0.0
                local nearestVeh = nil
                local nearestDist = maxDist

                for _, veh in ipairs(GetGamePool('CVehicle')) do
                    if veh ~= playerVeh and DoesEntityExist(veh) and not IsEntityDead(veh) and GetPedInVehicleSeat(veh, -1) ~= 0 then
                        local vehCoords = GetEntityCoords(veh)
                        local dx = vehCoords.x - playerCoords.x
                        local dy = vehCoords.y - playerCoords.y
                        local dist = #(playerCoords - vehCoords)
                        if dist < maxDist and dist > 2.0 then
                            local len = math.sqrt(dx * dx + dy * dy)
                            if len > 0.01 then
                                local dot = (dx * forwardX + dy * forwardY) / len
                                if dot >= minDotInFront and dist < nearestDist then
                                    nearestDist = dist
                                    nearestVeh = veh
                                end
                            end
                        end
                    end
                end

                if PullOverHighlightedVehicle and PullOverHighlightedVehicle ~= nearestVeh and DoesEntityExist(PullOverHighlightedVehicle) then
                    SetEntityDrawOutline(PullOverHighlightedVehicle, false)
                    PullOverHighlightedVehicle = nil
                end

                if nearestVeh and DoesEntityExist(nearestVeh) then
                    SetEntityDrawOutline(nearestVeh, true)
                    SetEntityDrawOutlineColor(255, 0, 0, 255)
                    SetEntityDrawOutlineShader(1)
                    PullOverHighlightedVehicle = nearestVeh
                    local plateDisplay = GetVehicleNumberPlateText(nearestVeh) or ""
                    local plateNorm = plateDisplay:gsub("%s+", "")
                    local isFrozen = PullOverFrozenPlates[plateNorm]
                    local actionText = isFrozen and "Release car" or "Pull over car"
                    if not PullOverTextUIShown or PullOverLastPlate ~= plateDisplay or PullOverLastFrozen ~= isFrozen then
                        if PullOverTextUIShown then lib.hideTextUI() end
                        lib.showTextUI(('[H] %s - %s'):format(actionText, plateDisplay))
                        PullOverTextUIShown = true
                        PullOverLastPlate = plateDisplay
                        PullOverLastFrozen = isFrozen
                    end
                    if IsControlJustPressed(0, 74) then
                        local netId = NetworkGetNetworkIdFromEntity(nearestVeh)
                        local plate = (GetVehicleNumberPlateText(nearestVeh) or ""):gsub("%s+", "")
                        local nextFrozen = not PullOverFrozenPlates[plate]
                        FreezeEntityPosition(nearestVeh, nextFrozen)
                        if nextFrozen then PullOverFrozenPlates[plate] = true else PullOverFrozenPlates[plate] = nil end
                        TriggerServerEvent('elder_police:freezePullOverVehicle', netId, plate)
                    end
                else
                    if PullOverTextUIShown then
                        lib.hideTextUI()
                        PullOverTextUIShown = false
                    end
                    if PullOverHighlightedVehicle and DoesEntityExist(PullOverHighlightedVehicle) then
                        SetEntityDrawOutline(PullOverHighlightedVehicle, false)
                    end
                    PullOverHighlightedVehicle = nil
                end
            end
            Wait(0)
        end
        if PullOverTextUIShown then
            lib.hideTextUI()
            PullOverTextUIShown = false
        end
        if PullOverHighlightedVehicle and DoesEntityExist(PullOverHighlightedVehicle) then
            SetEntityDrawOutline(PullOverHighlightedVehicle, false)
            PullOverHighlightedVehicle = nil
        end
    end)
end