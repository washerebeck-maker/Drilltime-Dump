

function createBlip(coords, sprite, color, text, scale, range, flash)
    local x,y,z = table.unpack(coords)
    local blip = AddBlipForCoord(x, y, z)
    SetBlipSprite(blip, sprite)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, scale)
    SetBlipColour(blip, color)
    if flash then
		SetBlipFlashes(blip, true)
	end
    if not range then
        SetBlipAsShortRange(blip, true)
    end
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(text)
    EndTextCommandSetBlipName(blip)
    return blip
end

local function exportQBHandler(exportName, func)
    AddEventHandler(('__cfx_export_qb-policejob_%s'):format(exportName), function(setCB)
        setCB(func)
    end)
end

local firstToUpper = function(str)
    return (str:gsub("^%l", string.upper))
end

local addCommas = function(n)
	return tostring(math.floor(n)):reverse():gsub("(%d%d%d)","%1,")
								  :gsub(",(%-?)$","%1"):reverse()
end

function GetVehicleInDirection()
	local coords = GetEntityCoords(cache.ped)
	local inDirection  = GetOffsetFromEntityInWorldCoords(cache.ped, 0.0, 5.0, 0.0)
	local rayHandle    = StartExpensiveSynchronousShapeTestLosProbe(coords, inDirection, 10, cache.ped, 0)
	local numRayHandle, hit, endCoords, surfaceNormal, entityHit = GetShapeTestResult(rayHandle)

	if hit == 1 and GetEntityType(entityHit) == 2 then
		local entityCoords = GetEntityCoords(entityHit)
		return entityHit, entityCoords
	end

	return nil
end

function ShowHelpNotification(msg, thisFrame, beep, duration)
	AddTextEntry('HelpNotification', msg)

	if thisFrame then
		DisplayHelpTextThisFrame('HelpNotification', false)
	else
		if beep == nil then beep = true end
		BeginTextCommandDisplayHelp('HelpNotification')
		EndTextCommandDisplayHelp(0, false, beep, duration or -1)
	end
end

function IsHandcuffed()
    return isCuffed
end

exportQBHandler('IsHandcuffed', IsHandcuffed)

openOutfits = function(station)
    if Framework == 'qb' then return end
	local data = Config.Locations[station].cloakroom.uniforms
	local Options = {
		{
			title = Strings.civilian_wear,
			description = '',
			arrow = false,
			event = 'elder_police:changeClothes',
			args = 'civ_wear'
		}
	}
	for i=1, #data do
        if data[i].minGrade then
            local _job, grade = HasGroup(Config.policeJobs)
            if grade and grade >= data[i].minGrade then
                Options[#Options + 1] = {
                    title = data[i].label,
                    description = '',
                    arrow = false,
                    event = 'elder_police:changeClothes',
                    args = {male = data[i].male, female = data[i].female}
                }
            end 
        else
            Options[#Options + 1] = {
                title = data[i].label,
                description = '',
                arrow = false,
                event = 'elder_police:changeClothes',
                args = {male = data[i].male, female = data[i].female}
            }
        end
	end
	lib.registerContext({
		id = 'pd_cloakroom',
		title = Strings.cloakroom,
		options = Options
	})
	lib.showContext('pd_cloakroom')
end

exports('openOutfits', openOutfits)

escortPlayer = function(targetId)
    local targetCuffed = lib.callback.await('elder_police:isCuffed', 100, targetId)
    if targetCuffed then
        TriggerServerEvent('elder_police:escortPlayer', targetId)
    else
        TriggerEvent('elder_police:notify', Strings.not_restrained, Strings.not_restrained_desc, 'error')
    end
end

exports('escortPlayer', escortPlayer)

handcuffPlayer = function(targetId, hard)
    if not HasGroup(Config.policeJobs) then return end
    if deathCheck(targetId) then
        TriggerEvent('elder_police:notify', Strings.unconcious, Strings.unconcious_desc, 'error')
    else
        TriggerServerEvent('elder_police:handcuffPlayer', targetId, hard)
    end
end

local startCuffTimer = function()
    if Config.handcuff.timer and cuffTimer.active then
        ClearTimeout(cuffTimer.timer)
    end
    cuffTimer.active = true
    cuffTimer.timer = SetTimeout(Config.handcuff.timer,function()
        TriggerEvent('elder_police:uncuff')
    end)
end

handcuffed = function(hard)
    isCuffed = true
    TriggerServerEvent('elder_police:setCuff', true)
    SetEnableHandcuffs(cache.ped, true)
 --   SetEnableBoundAnkles(cache.ped, true)
    SetCurrentPedWeapon(cache.ped, `WEAPON_UNARMED`, true)
    SetPedCanPlayGestureAnims(cache.ped, false)
    FreezeEntityPosition(cache.ped, true)
    lib.requestAnimDict('mp_arresting', 100)
    TaskPlayAnim(cache.ped, 'mp_arresting', 'idle', 8.0, -8, 3000, 49, 0, 0, 0, 0)
    Wait(3000)
    if not hard then 
        FreezeEntityPosition(cache.ped, false)
    end
    if Config.handcuff.timer then
        if cuffTimer.active then
            ClearTimeout(cuffTimer.timer)
        end
        startCuffTimer()
    end
end

uncuffed = function()
    if not isCuffed then return end
    isCuffed = false
    if escorted?.active then
        escorted.active = nil
    end
    TriggerServerEvent('elder_police:setCuff', false)
    SetEnableHandcuffs(cache.ped, false)
    DisablePlayerFiring(cache.ped, false)
    SetPedCanPlayGestureAnims(cache.ped, true)
    FreezeEntityPosition(cache.ped, false)
    DisplayRadar(true)
    if Config.handcuff.timer and cuffTimer.active then
        ClearTimeout(cuffTimer.timer)
    end
    Wait(250) -- Only in fivem ;)
    ClearPedTasks(cache.ped)
    ClearPedSecondaryTask(cache.ped)
    if cuffProp and DoesEntityExist(cuffProp) then
        SetEntityAsMissionEntity(cuffProp, true, true)
        DetachEntity(cuffProp)
        DeleteObject(cuffProp)
        cuffProp = nil
    end
end

manageId = function(data)
    local targetId, license = data.targetId, data.license
    lib.registerContext({
        id = 'pd_manage_id',
        title = (license.label or firstToUpper(tostring(license.type))),
        options = {
            {
                title = Strings.go_back,
                description = '',
                icon = '',
                arrow = false,
                event = 'elder_police:checkId',
                args = targetId
            },
            {
                title = Strings.revoke_license,
                description = '',
                icon = '',
                arrow = false,
                event = 'elder_police:revokeLicense',
                args = {targetId = targetId, license = license.type}
            },

        }
    })
    lib.showContext('pd_manage_id')
end

openLicenseMenu = function(data)
    local targetId, licenses = data.targetId, data.licenses
    local Options = {
        {
            title = Strings.go_back,
            description = '',
            icon = '',
            arrow = false,
            event = 'elder_police:checkId',
            args = targetId
        }
    }
    for i=1, #licenses do
        Options[#Options + 1] = {
            title = (licenses[i].label or firstToUpper(tostring(licenses[i].type))),
            description = '',
            icon = '',
            arrow = true,
            event = 'elder_police:manageId',
            args = {targetId = targetId, license = licenses[i]}
        }
    end
    lib.registerContext({
        id = 'pd_license_check',
        title = Strings.licenses,
        options = Options
    })
    lib.showContext('pd_license_check')
end

checkPlayerId = function(targetId)
    local data = lib.callback.await('elder_police:checkPlayerId', 100, targetId)
    local Options = {
        {
            title = Strings.go_back,
            description = '',
            icon = '',
            arrow = false,
            event = 'elder_police:pdJobMenu', 
        },
        {
            title = Strings.name,
            description = data.name,
            icon = 'id-badge',
            arrow = false,
            event = 'elder_police:pdJobMenu', 
        },
        {
            title = Strings.job,
            description = data.job,
            icon = 'briefcase',
            arrow = false,
            event = 'elder_police:pdJobMenu', 
        },
        {
            title = Strings.job_position,
            description = data.position,
            icon = 'briefcase',
            arrow = false,
            event = 'elder_police:pdJobMenu', 
        },
        {
            title = Strings.dob,
            description = data.dob,
            icon = 'cake-candles',
            arrow = false,
            event = 'elder_police:pdJobMenu', 
        },
        {
            title = Strings.sex,
            description = data.sex,
            icon = 'venus-mars',
            arrow = false,
            event = 'elder_police:pdJobMenu', 
        }
    }
    if data.drunk then
        Options[#Options + 1] = {
            title = Strings.bac,
            description = data.drunk,
            icon = 'champagne-glasses',
            arrow = false,
            event = 'elder_police:pdJobMenu', 
        }
    end
    if not data.licenses or #data.licenses < 1 then
        Options[#Options + 1] = {
            title = Strings.licenses,
            description = Strings.no_licenses,
            icon = 'id-card',
            arrow = true,
            event = 'elder_police:pdJobMenu',
        }
    else
        Options[#Options + 1] = {
            title = Strings.licenses,
            description = Strings.total_licenses..' '..#data.licenses,
            icon = 'id-card',
            arrow = true,
            event = 'elder_police:licenseMenu',
            args = {licenses = data.licenses, targetId = targetId}
        }
    end
    lib.registerContext({
        id = 'pd_id_check',
        title = Strings.id_result_menu,
        options = Options
    })
    lib.showContext('pd_id_check')
end

vehicleInfoMenu = function(vehicle)
    if not DoesEntityExist(vehicle) then
        TriggerEvent('elder_police:notify', Strings.vehicle_not_found, Strings.vehicle_not_found_desc, 'error')
    else
        local plate = GetVehicleNumberPlateText(vehicle)
        plate = Trim(plate)
        local ownerData = lib.callback.await('elder_police:getVehicleOwner', 100, plate)
        local Options = {
            {
                title = Strings.go_back,
                description = '',
                arrow = false,
                event = 'elder_police:vehicleInteractions',
            },
            {
                title = Strings.plate,
                description = plate,
                arrow = false,
                event = 'elder_police:pdJobMenu',
            }
        }
        if ownerData and ownerData.owner then
            Options[#Options + 1] = {
                title = Strings.owner,
                description = ownerData.owner,
                arrow = false,
                event = 'elder_police:pdJobMenu',
            }
            Options[#Options + 1] = {
                title = 'Stolen',
                description = ownerData.stolen and 'This vehicle is stolen' or 'this vehicle is not stolen',
                arrow = false,
                event = 'elder_police:pdJobMenu',
            }
            if ownerData.stolen then
                Options[#Options + 1] = {
                    title = 'Give Back Vehicle',
                    description = '',
                    arrow = false,
                    event = 'elder_police:GiveBackVehicle',
                    args = {plate = plate, vehicle = vehicle}
                }
            end
        else
            Options[#Options + 1] = {
                title = Strings.possibly_stolen,
                description = Strings.possibly_stolen_desc,
                arrow = false,
                event = 'elder_police:pdJobMenu',
            }
        end
        lib.registerContext({
            id = 'pd_veh_info_menu',
            title = Strings.vehicle_interactions,
            options = Options,
        })
        lib.showContext('pd_veh_info_menu')
    end
end

lockpickVehicle = function(vehicle)
    if not DoesEntityExist(vehicle) then
        TriggerEvent('elder_police:notify', Strings.vehicle_not_found, Strings.vehicle_not_found_desc, 'error')
    else
        local playerCoords = GetEntityCoords(cache.ped)
        local targetCoords = GetEntityCoords(vehicle)
        local dist = #(playerCoords - targetCoords)
        if dist < 2.5 then
            TaskTurnPedToFaceCoord(cache.ped, targetCoords.x, targetCoords.y, targetCoords.z, 2000)
            Wait(2000)
            if lib.progressCircle({
                duration = 7500,
                position = 'bottom',
                label = Strings.lockpick_progress,
                useWhileDead = false,
                canCancel = true,
                disable = {
                    car = true,
                },
                anim = {
                    scenario = 'PROP_HUMAN_PARKING_METER',
                },
            }) then
                SetVehicleDoorsLocked(vehicle, 1)
                SetVehicleDoorsLockedForAllPlayers(vehicle, false)
                TriggerEvent('elder_police:notify', Strings.lockpicked, Strings.lockpicked_desc, 'success')
            else
                TriggerEvent('elder_police:notify', Strings.cancelled, Strings.cancelled_desc, 'error')
            end
        else
            TriggerEvent('elder_police:notify', Strings.too_far, Strings.too_far_desc, 'error')
        end
    end
end

impoundVehicle = function(vehicle)
    if not DoesEntityExist(vehicle) then
        TriggerEvent('elder_police:notify', Strings.vehicle_not_found, Strings.vehicle_not_found_desc, 'error')
    else
        local playerCoords = GetEntityCoords(cache.ped)
        local targetCoords = GetEntityCoords(vehicle)
        local dist = #(playerCoords - targetCoords)
        if dist < 2.5 then
            local driver = GetPedInVehicleSeat(vehicle, -1)
            if driver == 0 then
                SetVehicleDoorsLocked(vehicle, 2)
                SetVehicleDoorsLockedForAllPlayers(vehicle, true)
                TaskTurnPedToFaceCoord(cache.ped, targetCoords.x, targetCoords.y, targetCoords.z, 2000)
                Wait(2000)
                if lib.progressCircle({
                    duration = 7500,
                    position = 'bottom',
                    label = Strings.impounding_progress,
                    useWhileDead = false,
                    canCancel = true,
                    disable = {
                        car = true,
                    },
                    anim = {
                        scenario = 'PROP_HUMAN_PARKING_METER',
                    },
                }) then
                    impoundSuccessful(vehicle)
                else
                    TriggerEvent('elder_police:notify', Strings.cancelled, Strings.cancelled_desc, 'error')
                end
            else
                TriggerEvent('elder_police:notify', Strings.driver_in_car, Strings.driver_in_car_desc, 'error')
            end
        else
            TriggerEvent('elder_police:notify', Strings.too_far, Strings.too_far_desc, 'error')
        end
    end
end

vehicleInteractionMenu = function()
    lib.registerContext({
        id = 'pd_veh_menu',
        title = Strings.vehicle_interactions,
        options = {
            {
                title = Strings.go_back,
                description = '',
                arrow = false,
                event = 'elder_police:pdJobMenu',
            },
            {
                title = Strings.vehicle_information,
                description = Strings.vehicle_information_desc,
                icon = 'magnifying-glass',
                arrow = false,
                event = 'elder_police:vehicleInfo',
            },
            {
                title = Strings.lockpick_vehicle,
                description = Strings.locakpick_vehicle_desc,
                icon = 'lock-open',
                arrow = false,
                event = 'elder_police:lockpickVehicle',
            },
            {
                title = Strings.impound_vehicle,
                description = Strings.impound_vehicle_desc,
                icon = 'reply',
                arrow = false,
                event = 'elder_police:impoundVehicle',
            },
            {
                title = 'Pull Over',
                description = 'Pullover Vehicle In Front Of Your Car',
                icon = 'link',
                arrow = false,
                event = 'elder_police:pullOver',
            },

        }
    })
    lib.showContext('pd_veh_menu')
end


civilianInteractionMenu = function()
    lib.registerContext({
        id = 'pd_civ_menu',
        title = 'Civilian Interractions',
        menu = 'pd_job_menu',
        options = {
            {
                title = 'Warrant Suspect',
                description = 'Tag a suspect as wanted.',
                icon = 'fa-user-tag',
                arrow = false,
                event = 'elder_police:client:warm',
            },
            {
                title = 'View Weapons',
                description = 'View weapons of nearby suspect',
                icon = 'fa-person-rifle',
                arrow = false,
                event = 'elder_police:viewWeapons',
            },
            {
                title = 'Traffic Ticket',
                description = 'Traffic Ticket to nearby suspect',
                icon = 'file-invoice',
                arrow = false,
                event = 'elder_police:trafficTicket',
            },
            {
                title = 'Arrest suspect',
                description = 'Arrest nearby suspect',
                icon = 'file-signature',
                arrow = false,
                event = 'elder_police:arrestCivilian',
            },
            {
                title = 'Handcuff Suspect (hard)',
                description = 'Handcuff a nearby suspect (hard)',
                icon = 'hands-bound',
                arrow = false,
                event = 'elder_police:handcuffPlayerHard',
            },
            {
                title = 'Handcuff Suspect (soft)',
                description = 'Handcuff a nearby suspect (hard)',
                icon = 'hands-bound',
                arrow = false,
                event = 'elder_police:handcuffPlayer',
            },
            {
                title = Strings.escort_player,
                description = Strings.escort_player_desc,
                icon = 'hand-holding-hand',
                arrow = false,
                event = 'elder_police:escortPlayer',
            },
            {
                title = Strings.put_in_vehicle,
                description = Strings.put_in_vehicle_desc,
                icon = 'arrow-right-to-bracket',
                arrow = false,
                event = 'elder_police:inVehiclePlayer',
            },
            {
                title = Strings.take_out_vehicle,
                description = Strings.take_out_vehicle_desc,
                icon = 'arrow-right-from-bracket',
                arrow = false,
                event = 'elder_police:outVehiclePlayer',
            },
            {
                title = 'Jail Suspect',
                description = 'Send suspect to cell',
                icon = 'fa-door-closed',
                arrow = false,
                event = 'elder_police:sendPlayerToCell',
            },
            {
                title = 'Jail List',
                description = 'Check jail list',
                icon = 'fa-door-closed',
                arrow = false,
                event = 'elder_police:checkJailList',
            },
        }
    })
    lib.showContext('pd_civ_menu')
end

searchPlayerMenu = function()
    lib.registerContext({
        id = 'pd_search_menu',
        title = 'Civilian Interractions',
        menu = 'pd_job_menu',
        options = {
            {
                title = 'Full Search',
                description = 'Remove illegal items',
                icon = 'magnifying-glass',
                arrow = false,
                event = 'elder_police:searchPlayerFull',
            },
            {
                title = 'Partial Search',
                description = 'Remove only black money',
                icon = 'magnifying-glass',
                arrow = false,
                event = 'elder_police:searchPlayerPartial',
            },
            
        }
    })
    lib.showContext('pd_search_menu')
end


pdInteractionMenu = function()
    local hasJob, _grade = HasGroup(Config.policeJobs)
    local options = {}

    if CanUseRaid(_grade) then
        options[#options + 1] = {
            title = 'Raids',
            description = 'Create & Stop Raids',
            icon = 'fa-circle-exclamation',
            arrow = true,
            event = 'elder_police:client:raid',
        }
    end

    options[#options+1] = 
    {
        title = Strings.place_object,
        description = Strings.place_object_desc,
        icon = 'box',
        arrow = true,
        event = 'elder_police:placeObjects',
    }
    options[#options+1] = 
    {
        title = Strings.armour,
        description = Strings.armour_desc,
        icon = 'shield-alt',
        arrow = false,
        event = 'elder_police:armour',
    }
    options[#options+1] = 
    {
        title = Strings.ammo,
        description = Strings.ammo_desc,
        icon = 'gun',
        arrow = false,
        event = 'elder_police:ammo',
    }
    options[#options+1] = 
    {
        title = 'Impound Vehicle',
        description = 'Impound Vehicle',
        icon = 'fa-car-tunnel',
        arrow = false,
        event = 'elder_police:cardel',
    }

    lib.registerContext({
        id = 'pd_pd_menu',
        title = 'Police Interractions',
        menu = 'pd_job_menu',
        options = options,
    })
    lib.showContext('pd_pd_menu')
end

placeObjectsMenu = function()
    if not HasGroup(Config.policeJobs) then return end
    local job, grade = GetGroup()
    local options = {
        {
            title = Strings.go_back,
            description = '',
            arrow = false,
            event = 'elder_police:pdJobMenu',
        },
    }
    for i=1, #Config.Props do 
        local data = Config.Props[i]
        local add = true
        if (data.groups) then 
            local rank = data.groups[job]
            if not (rank and grade >= rank) then 
                add = false
            end
        end
        if (add) then 
            data.arrow = false
            data.event = "elder_police:spawnProp"
            data.args = i

            options[#options + 1] = data
        end
    end
    lib.registerContext({
        id = 'pd_object_menu',
        title = Strings.vehicle_interactions,
        options = options
    })
    lib.showContext('pd_object_menu')
end

armouryMenu = function(station)
    local data = Config.Locations[station].armoury
    local job, grade = GetGroup()
    local allow = false
    local aData
    if data.jobLock then

        if data.jobLock == job then
            allow = true
        end
    else
        allow = true
    end
    if allow then
        if grade > #data.weapons then
            aData = data.weapons[#data.weapons]
        elseif not data.weapons[grade] then
            print('[elder_police] : ARMORY NOT SET UP PROPERLY FOR GRADE: '..grade)
        else
            aData = data.weapons[grade]
        end
        local Options = {}
        for k,v in pairs(aData) do
            Options[#Options + 1] = {
                title = v.label,
                description = '',
                arrow = false,
                event = 'elder_police:purchaseArmoury',
                args = { id = station, grade = grade, itemId = k, multiple = false }
            }
            if v.price then
                Options[#Options].description = Strings.currency..addCommas(v.price)
            end
            if v.multiple then
                Options[#Options].args.multiple = true
            end
        end
        lib.registerContext({
            id = 'pd_armoury',
            title = Strings.armoury_menu,
            options = Options
        })
        lib.showContext('pd_armoury')
    else
        TriggerEvent('elder_police:notify', Strings.no_permission, Strings.no_access_desc, 'error')
    end
end

openVehicleMenu = function(station)
    if not HasGroup(Config.policeJobs) then return end
    local data, grade
    local job, level = GetGroup()
    if level > #Config.Locations[station].vehicles.options then
        grade = #Config.Locations[station].vehicles.options
        data = Config.Locations[station].vehicles.options[#Config.Locations[station].vehicles.options]
    elseif not Config.Locations[station].vehicles.options[level] then
        print('[elder_police] : Police garage not set up properly for job grade: '..level)
        return
    else
        grade = level
        data = Config.Locations[station].vehicles.options[level]
    end
    local Options = {}
    for k,v in pairs(data) do
        if v.category == 'land' then
            Options[#Options + 1] = {
                title = v.label,
                description = '',
                icon = 'car',
                arrow = true,
                event = 'elder_police:spawnVehicle',
                args = { station = station, model = k, grade = grade }
            }
        elseif v.category == 'air' then
            Options[#Options + 1] = {
                title = v.label,
                description = '',
                icon = 'helicopter',
                arrow = true,
                event = 'elder_police:spawnVehicle',
                args = { station = station, model = k, grade = grade, category = v.category }
            }
        end
    end
    lib.registerContext({
        id = 'pd_garage_menu',
        title = Strings.police_garage,
        onExit = function()
            inMenu = false
        end,
        options = Options
    })
    lib.showContext('pd_garage_menu')
end

local lastTackle = 0
attemptTackle = function()
    if not IsPedSprinting(cache.ped) then return end
    local coords = GetEntityCoords(cache.ped)
    local player = lib.getClosestPlayer(vec3(coords.x, coords.y, coords.z), 2.0, false)
    if player and not isBusy and not IsPedInAnyVehicle(cache.ped) and not IsPedInAnyVehicle(GetPlayerPed(player)) and GetGameTimer() - lastTackle > 7 * 1000 then
        if Config.tackle.policeOnly then
            if HasGroup(Config.policeJobs) then
                lastTackle = GetGameTimer()
                TriggerServerEvent('elder_police:attemptTackle', GetPlayerServerId(player))
            end
        else
            lastTackle = GetGameTimer()
            TriggerServerEvent('elder_police:attemptTackle', GetPlayerServerId(player))
        end
    end
end

getTackled = function(targetId)
    isBusy = true
    local target = GetPlayerPed(GetPlayerFromServerId(targetId))
    lib.requestAnimDict('missmic2ig_11', 100)
    AttachEntityToEntity(cache.ped, target, 11816, 0.25, 0.5, 0.0, 0.5, 0.5, 180.0, false, false, false, false, 2, false)
    TaskPlayAnim(cache.ped, 'missmic2ig_11', 'mic_2_ig_11_intro_p_one', 8.0, -8.0, 3000, 0, 0, false, false, false)
    Wait(3000)
    DetachEntity(cache.ped, true, false)
    SetPedToRagdoll(cache.ped, 1000, 1000, 0, 0, 0, 0)
    isRagdoll = true
    Wait(3000)
    isRagdoll = false
    isBusy = false
    RemoveAnimDict('missmic2ig_11')
end

tacklePlayer = function()
    isBusy = true
    lib.requestAnimDict('missmic2ig_11', 100)
    TaskPlayAnim(cache.ped, 'missmic2ig_11', 'mic_2_ig_11_intro_goon', 8.0, -8.0, 3000, 0, 0, false, false, false)
    Wait(3000)
    isBusy = false
    RemoveAnimDict('missmic2ig_11')
end


OpenViewWeapons = function(target)
    local items = lib.callback.await('elder_police:getTargetItems', 100, target)
    local Options = {}
    for k,v in ipairs(items) do
        if string.sub(v.name,1,string.len("WEAPON_")) == "WEAPON_" then
            Options[#Options + 1] = {
                title = v.label,
                description = v.metadata.serial or 'unknown',
                icon = 'fa-gun',
                arrow = true,
                readOnly = true,
            }
        end
    end

    if #Options == 0 then
        Options[#Options + 1] = {
            title = 'No Weapons',
            icon = 'fa-gun',
            arrow = true,
            readOnly = true,
        }
    end
    lib.registerContext({
        id = 'view_weapon_menu',
        title = 'Suspect Weapons',
        onExit = function()
            inMenu = false
        end,
        options = Options
    })
    lib.showContext('view_weapon_menu')
end