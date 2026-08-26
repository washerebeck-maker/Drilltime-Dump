

--Customize notifications
RegisterNetEvent('elder_police:notify', function(title, desc, style)
    lib.notify({
        title = title,
        description = desc,
        duration = 3500,
        type = style
    })
end)

--Custom Car lock
addCarKeys = function(plate, model)
    
end

--Send to jail
RegisterNetEvent('elder_police:sendToJail', function(target, time)
    -- Add your jail event trigger here? WILL BE ADDING BUILT IN JAIL SYSTEM SOON!
    -- 'target' = Server ID of target / 'time' minutes input for months
    print('Jailing '..target..' for '..time..' minutes')
end)

--Impound Vehicle
impoundSuccessful = function(vehicle)
    if not DoesEntityExist(vehicle) then return end
    SetEntityAsMissionEntity(vehicle, false, false)
    DeleteEntity(vehicle)
    if not DoesEntityExist(vehicle) then
        TriggerEvent('elder_police:notify', Strings.success, Strings.car_impounded_desc, 'success')
    end
end

--Death check
deathCheck = function(serverId)
    local ped = GetPlayerPed(GetPlayerFromServerId(serverId))
    return IsPedFatallyInjured(ped)
	or IsEntityPlayingAnim(ped, 'dead', 'dead_a', 3)
	or IsEntityPlayingAnim(ped, 'mini@cpr@char_b@cpr_def', 'cpr_pumpchest_idle', 3)
end

--Search player
searchPlayer = function(player, full)
    if Config.inventory == 'ox' then
        --exports.ox_inventory:openNearbyInventory()
        TriggerServerEvent('elder_police:removeIllegalItems', GetPlayerServerId(player), full)
    elseif Config.inventory == 'qs' or Config.inventory == 'qb' then
        TriggerServerEvent("inventory:server:OpenInventory", "otherplayer", GetPlayerServerId(player))
    elseif Config.inventory == 'mf' then
        local identifier = GetIdentifier(player)
        exports["mf-inventory"]:openOtherInventory(identifier)
    elseif Config.inventory == 'cheeza' then
        TriggerEvent("inventory:openPlayerInventory", GetPlayerServerId(player), true)
    elseif Config.inventory == 'custom' then
        -- INSERT CUSTOM SEARCH PLAYER FOR YOUR INVENTORY
    end
end

exports('searchPlayer', searchPlayer)


-- Customize target
AddEventHandler('elder_police:addTarget', function(d)
    if d.targetType == 'AddBoxZone' then
        exports.qtarget:AddBoxZone(d.identifier, d.coords, d.width, d.length, {
            name=d.identifier,
            heading=d.heading,
            debugPoly=false,
            minZ=d.minZ,
            maxZ=d.maxZ,
            useZ = true,
        }, {
            options = d.options,
            job = (d.job or false),
            distance = d.distance,
        })
    elseif d.targetType == 'Player' then
        exports.qtarget:Player({
            options = d.options,
            job = (d.job or false),
            distance = d.distance,
        })
    elseif d.targetType == 'Vehicle' then
        exports.qtarget:Vehicle({
            options = d.options,
            job = (d.job or false),
            distance = d.distance
        })
    elseif d.targetType == 'Model' then
        exports.qtarget:AddTargetModel(d.models, {
            options = d.options,
            job = (d.job or false),
            distance = d.distance,
        })
    end
end)

--Change clothes(Cloakroom)
AddEventHandler('elder_police:changeClothes', function(data) 
    -- BENZO (This all needs rewrite, not expecting you to; but maybe find me how qb clothes are configured and changed)
    if Config.skinScript == 'qb' then
        -- QB HERE
    else
        ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin, jobSkin)
            if data == 'civ_wear' then
                if Config.skinScript == 'appearance' then
                        skin.sex = nil
                        exports['fivem-appearance']:setPlayerAppearance(skin)
                else
                TriggerEvent('skinchanger:loadClothes', skin)
                end
            elseif skin.sex == 0 then
                TriggerEvent('skinchanger:loadClothes', skin, data.male)
            elseif skin.sex == 1 then
                TriggerEvent('skinchanger:loadClothes', skin, data.female)
            end
        end)
    end
end)

-- Billing event
AddEventHandler('elder_police:finePlayer', function()
    if not HasGroup(Config.policeJobs) then return end
    local hasJob, _grade = HasGroup(Config.policeJobs)
    local coords = GetEntityCoords(cache.ped)
    local player = lib.getClosestPlayer(vec3(coords.x, coords.y, coords.z), 2.0, false)
    if not player then
        TriggerEvent('elder_police:notify', Strings.no_nearby, Strings.no_nearby_desc, 'error')
    else
        local job, _grade = HasGroup(Config.policeJobs)
        local jobLabel = lib.callback.await('elder_police:getJobLabel', 100)
        local targetId = GetPlayerServerId(player)
        local input = lib.inputDialog('Bill Patient', {'Amount'})
        if not input then return end
        local amount = math.floor(tonumber(input[1]))
        if amount < 1 then
            TriggerEvent('elder_police:notify', Strings.invalid_entry, Strings.invalid_entry_desc, 'error')
        elseif Config.billingSystem == 'okok' then
            local data =  {
                target = targetId,
                invoice_value = amount,
                invoice_item = Strings.fines,
                society = 'society_'..hasJob,
                society_name = jobLabel,
                invoice_notes = ''
            }
            TriggerServerEvent('okokBilling:CreateInvoice', data)
        elseif Config.billingSystem == 'esx' then
            TriggerServerEvent('esx_billing:sendBill', targetId, 'society_'..hasJob, jobLabel, amount)
        elseif Config.billingSystem == 'qb' then
            TriggerServerEvent('elder_police:pdBill', targetId, amount, hasJob)
            local gender = Strings.mr
            if QBCore.Functions.GetPlayerData().charinfo.gender == 1 then
                gender = Strings.mrs
            end
            local charinfo = QBCore.Functions.GetPlayerData().charinfo
            TriggerServerEvent('qb-phone:server:sendNewMail', {
                sender = jobLabel,
                subject = Strings.debt_collection,
                message = (Strings.db_email):format(gender, charinfo.lastname, amount),
                button = {}
            })
        else
            -- Custom here?
        end
    end
end)



AddEventHandler('elder_police:armour', function()
    SetPedArmour(GetPlayerPed(-1), 100)
    TriggerEvent('elder_police:notify', 'Police', 'You have worn an armour', 'success')
end)

AddEventHandler('elder_police:ammo', function()
    TriggerServerEvent('elder_police:ammo')
end)



local alertInProgress = false

local AlertBlips = nil

RegisterNetEvent('elder_police:client:raid')
AddEventHandler('elder_police:client:raid', function()
    OpenRaidMenu()
end)

RegisterNetEvent('elder_police:client:create_raid')
AddEventHandler('elder_police:client:create_raid', function()
    if alertInProgress == false then
        local WaypointHandle = GetFirstBlipInfoId(8) 
        if DoesBlipExist(WaypointHandle) then
            local waypointCoords = GetBlipInfoIdCoord(WaypointHandle)

            local input = lib.inputDialog('Raid Name', {'Name'})
            if not input or not input[1] or input[1] == '' then 
                TriggerEvent('elder_police:notify', 'Police', 'Invalid raid name !', 'error')
                return 
            end

            TriggerServerEvent('elder_police:server:create_raid', waypointCoords, input[1])

        else
            TriggerEvent('elder_police:notify', 'Police', 'You should mark a location on map', 'error')
        end
        
    else
        TriggerEvent('elder_police:notify', 'Police', 'There is already a raid', 'error')
    end
end)

RegisterNetEvent('elder_police:client:stop_raid')
AddEventHandler('elder_police:client:stop_raid', function()
    if alertInProgress == false then
        TriggerEvent('elder_police:notify', 'Police', 'There is no active raid', 'error')
    else
        TriggerServerEvent('elder_police:server:stop_raid')
    end
end)

function MissionAlert(text)
    ClearPrints()
    SetTextEntry_2("STRING")
    AddTextComponentString(text)
    DrawSubtitleTimed(1000, 1)
end

RegisterNetEvent('elder_police:client:trigger_raid')
AddEventHandler('elder_police:client:trigger_raid', function(coords,name)
    exports["okokNotify"]:Alert("Police", "Beware "..name.." is now being raided by NYCPD", 10000, "warning")
	local blip = AddBlipForRadius(coords, 100.0)
	SetBlipHighDetail(blip, true)
	SetBlipColour(blip, 1)
	SetBlipAlpha (blip, 200)
	AlertBlips =  blip
	alertInProgress = true
	Citizen.CreateThread( function()
		while alertInProgress do
			Citizen.Wait(0)
			SetBlipColour(AlertBlips,1)
			Citizen.Wait(1000)
			SetBlipColour(AlertBlips,38)
			Citizen.Wait(1000)
		end
	end)

    if PlayerData.job.name ~= 'police' then
        Citizen.CreateThread( function()
            while not PlayerData.job do Wait(10) end
            while alertInProgress do
                Citizen.Wait(500)
                local player_coords = GetEntityCoords(cache.ped)
                if GetDistanceBetweenCoords(player_coords, coords) <= 100 then
                    MissionAlert("⛔️ This area is currently being raided ! ⛔️")
                end
            end
        end)
    end
end)



RegisterNetEvent('elder_police:client:remove_raid')
AddEventHandler('elder_police:client:remove_raid', function(name)
    alertInProgress = false
	RemoveBlip(AlertBlips)
	exports["okokNotify"]:Alert("Police","Raiding "..name.." is now over",10000, "warning")
end)

local InCell = false

RegisterNetEvent('elder_police:playerToCell')
AddEventHandler('elder_police:playerToCell', function(reason, cell)
    ESX.Game.Teleport(cache.ped, Config.Cells[cell])
    if not InCell then
        InCell = true
        CreateThread(function()
            Wait(1000 * Config.CellTime)
            InCell = false
            if GetDistanceBetweenCoords(GetEntityCoords(cache.ped), Config.Cells[cell].xyz, true) < 5.0 then
                ESX.Game.Teleport(cache.ped, Config.CellRelease)
            end
            TriggerServerEvent('elder_police:playerReleaseCell')
        end)
    end
    
end)



--[[ local VehiclePlate = nil ]]

local G_Vehicle = nil


AddEventHandler('elder_police:cardel', function()

    local playerPed = PlayerPedId()
	if IsPedInAnyVehicle(playerPed, true) then
        vehicle = GetVehiclePedIsIn(playerPed, false)
        if GetPedInVehicleSeat(vehicle, -1) == playerPed then
            --[[ local plate = ESX.Math.Trim(GetVehicleNumberPlateText(vehicle)) ]]
            if DoesEntityExist(vehicle) then
                DeleteEntity(vehicle)
                --[[ if plate == VehiclePlate then VehiclePlate = nil end ]]
            end
        end
    end 
end)


AddEventHandler('elder_police:pedcars', function()
   
    if DoesEntityExist(G_Vehicle) then
        DeleteEntity(G_Vehicle)
    end
    if DoesEntityExist(G_Vehicle) then

        TriggerEvent('elder_police:notify', Strings.error, 'You cant spawn any more police vehicle. limit reached.', 'error')
        return
    end
    
    local model = Config.PoliceVehicleModel
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
        TriggerEvent('elder_police:notify', Strings.error, 'Invalid vehicle model.', 'error')
	end

end)

AddEventHandler('elder_police:weapon_license', function()
    WeaponLicenseMenu()
end)

AddEventHandler('elder_police:cancel_license', function()
    local input = lib.inputDialog('Citizen ID', {'Citizen'})
    if not input or not tonumber(input[1]) then
        TriggerEvent('elder_police:notify', 'Police', 'Wrong Citizen ID', 'error')
        return 
    end
    local target = tonumber(input[1])
    TriggerServerEvent('esx_drilltime:weapon_license:server:cancel_license', target)
end)

AddEventHandler('elder_police:renew_license', function()
    local coords = GetEntityCoords(PlayerPedId())
    local player = lib.getClosestPlayer(vec3(coords.x, coords.y, coords.z), 3.0, false)
    if not player then
        TriggerEvent('elder_police:notify', Strings.no_nearby, Strings.no_nearby_desc, 'error')
    else
        local targetId = GetPlayerServerId(player)
        TriggerServerEvent('esx_drilltime:weapon_license:server:police_renew_license', targetId)
    end
end)


WeaponLicenseMenu = function()
    local Options = {}
    Options[#Options + 1] = {
        title = 'Cancel Weapon License',
        icon = 'fa-person-rifle',
        arrow = false,
        event = 'elder_police:cancel_license',
    }
    Options[#Options + 1] = {
        title = 'Renew Weapon License',
        icon = 'fa-person-rifle',
        arrow = false,
        event = 'elder_police:renew_license',
    }

    lib.registerContext({
        id = 'pd_license_menu',
        title = 'Weapon License',
        menu = 'pd_job_menu',
        options = Options
    })
    lib.showContext('pd_license_menu')
end



CanUseRaid = function(grade)
    for k,v in pairs(Config.RaidGrades) do
        if v == grade then
            return true
        end
    end
    return false
end

OpenRaidMenu = function()
    local Options = {}
    Options[#Options + 1] = {
        title = 'Create Raid',
        description = '',
        icon = 'fa-circle-plus',
        arrow = true,
        event = 'elder_police:client:create_raid',
    }
    Options[#Options + 1] = {
        title = 'Stop Current Raid',
        description = '',
        icon = 'fa-trash-can',
        arrow = true,
        event = 'elder_police:client:stop_raid',
    }
    lib.registerContext({
        id = 'pd_raid_menu',
        title = 'Raid Menu',
        menu = 'pd_pd_menu',
        options = Options
    })
    lib.showContext('pd_raid_menu')
end

-- Job menu
openJobMenu = function()
    if not HasGroup(Config.policeJobs) then return end
    local jobLabel = Strings.police
    local Options = {}

    local hasJob, _grade = HasGroup(Config.policeJobs)

    if Config.searchPlayers then
        Options[#Options + 1] = {
            title = Strings.search_player,
            description = Strings.search_player_desc,
            icon = 'magnifying-glass',
            arrow = true,
            event = 'elder_police:searchPlayer',
        }
    end
    Options[#Options + 1] = {
        title = Strings.check_id,
        description = Strings.check_id_desc,
        icon = 'id-card',
        arrow = true,
        event = 'elder_police:checkId',
    }
    if Config.customJail then
        Options[#Options + 1] = {
            title = Strings.jail_player,
            description = Strings.jail_player_desc,
            icon = 'lock',
            arrow = false,
            event = 'elder_police:jailPlayer',
        }
    end
    Options[#Options + 1] = {
        title = 'Civilian Interactions',
        description = 'Interract with civilians',
        icon = 'user',
        arrow = true,
        event = 'elder_police:civilianInteractions',
    }
    Options[#Options + 1] = {
        title = Strings.vehicle_interactions,
        description = Strings.vehicle_interactions_desc,
        icon = 'car',
        arrow = true,
        event = 'elder_police:vehicleInteractions',
    }
    Options[#Options + 1] = {
        title = 'Police Interractions',
        description = 'All Police utilities',
        icon = 'building-shield',
        arrow = true,
        event = 'elder_police:pdInteractions',
    }
    if Config.weapon_license then
        Options[#Options + 1] = {
            title = 'Weapon License',
            description = 'Renew/Cancel weapon licenses',
            icon = 'fa-person-rifle',
            arrow = true,
            event = 'elder_police:weapon_license',
        }
    end
    Options[#Options+1] = 
    {
        title = Strings.pedcars,
        description = Strings.pedcars_desc,
        icon = 'fa-car-on',
        arrow = false,
        event = 'elder_police:pedcars',
    }
    Options[#Options + 1] = {
        title = 'Report Player',
        description = 'Report player for Stopping RP',
        icon = 'flag',
        arrow = false,
        event = 'elder_police:report',
    }
    if Config.billingSystem then
        Options[#Options + 1] = {
            title = Strings.fines,
            description = Strings.fines_desc,
            icon = 'file-invoice',
            arrow = false,
            event = 'elder_police:finePlayer',
        }
    end
    lib.registerContext({
        id = 'pd_job_menu',
        title = jobLabel,
        options = Options
    })
    lib.showContext('pd_job_menu')
end
