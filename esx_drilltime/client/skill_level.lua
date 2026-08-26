
local NPCs = {}
local StaminaLevel = nil

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)  
	Wait(2000)
    GiveLevelArmor()
    GiveLevelStamina()
end)

Citizen.CreateThread(function()
	for k,v in pairs(Config.SkillLevel.shops) do
        local ped_hash = GetHashKey(v.model)
        ESX.Streaming.RequestModel(ped_hash)
        NPCs[k] = CreatePed(5, ped_hash, v.coords.x, v.coords.y, v.coords.z-1, v.coords.w, false, true)
        PlaceObjectOnGroundProperly(NPCs[k])
        FreezeEntityPosition(NPCs[k], true)
        SetEntityInvincible(NPCs[k], true)
        SetBlockingOfNonTemporaryEvents(NPCs[k], true)	 
	end
end)

Citizen.CreateThread(function()
    while true do
		local wait = 1000
		local ped = PlayerPedId()
		local ped_coords = GetEntityCoords(ped)
		for k,v in pairs(Config.SkillLevel.shops) do
            local distance = GetDistanceBetweenCoords(ped_coords, vector3(v.coords.x,v.coords.y,v.coords.z),true)
			if distance <= 5.0 then
				wait = 1
                Draw3dText(v.coords.x,v.coords.y,v.coords.z+1.2, v.icon )
                if distance <= 2.0 then
                    ESX.ShowHelpNotification(v.label)
                    if IsControlJustReleased(0, 38) then
                        OpenShop(v.type)
                    end
                end
			end
		end
        Citizen.Wait(wait)
    end
end)

OpenShop = function(type)
    if type == 'armor' then
        ArmorLevelShop()
    elseif type == 'stamina' then
        StaminaLevelShop()
    end
end

ArmorLevelShop = function()
    local level = GetPlayerArmorLevel()

    local options = {}

    for k,v in pairs(Config.SkillLevel.armor_levels) do
        options[#options + 1] = 
		{
			title = 'Armor Level ' .. k,
			description = level >= k and 'Level Aquiered ✔️' or (level+1 == k and "Price : $" .. ESX.Math.GroupDigits(v.price) .. " | Item : ".. GetItemLabel(v.item).. "[".. v.count .."]" or 'Level locked 🔒'),   
			icon = 'fa-shield-halved',
            iconColor = level >= k and '#09752f' or (level+1 == k and 'purple' or 'gold'),
			arrow = level ==  k - 1,
			event = 'esx_drilltime:skill_level:client:buy_level',
			args = {type = 'armor', current_level = level, level = k, data = v}
		}
    end

    lib.registerContext({
		id = 'armor_menu',
		title = '💵 Armor Level Shop : Lvl [' .. level .. ']' ,
		options = options,
	})
	lib.showContext('armor_menu')

end

StaminaLevelShop = function()
    local level = GetPlayerStaminaLevel()

    local options = {}

    for k,v in ipairs(Config.SkillLevel.stamina_levels) do
        options[#options + 1] = 
		{
			title = 'Infinite Stamina',
			description = level >= k and 'Level Aquiered ✔️' or (level+1 == k and "Price : $" .. ESX.Math.GroupDigits(v.price) .. " | Item : ".. GetItemLabel(v.item).. "[".. v.count .."]" or 'Level locked 🔒'),   
			icon = 'fa-person-running',
            iconColor = level >= k and '#09752f' or (level+1 == k and 'purple' or 'gold'),
			arrow = level ==  k - 1,
			event = 'esx_drilltime:skill_level:client:buy_level',
			args = {type = 'stamina', current_level = level, level = k, data = v}
		}
    end

    lib.registerContext({
		id = 'stamina_menu',
		title = '💵 Stamina Level Shop : Lvl [' .. level .. ']' ,
		options = options,
	})
	lib.showContext('stamina_menu')

end

GetPlayerArmorLevel = function()
    local result = promise:new()
    ESX.TriggerServerCallback('esx_drilltime:skill_level:server:get_armor_level', function(level) 
		result:resolve(level)  
    end)
    return Citizen.Await(result)   
end

GetPlayerStaminaLevel = function()
    local result = promise:new()
    ESX.TriggerServerCallback('esx_drilltime:skill_level:server:get_stamina_level', function(level) 
		result:resolve(level)  
    end)
    return Citizen.Await(result)   
end

GetPlayerDrugLevel = function()
    local result = promise:new()
    ESX.TriggerServerCallback('esx_drilltime:skill_level:server:get_drug_level', function(level) 
		result:resolve(level)  
    end)
    return Citizen.Await(result)   
end

GetItemLabel = function(_item)
	local item  = exports.ox_inventory:Items(_item)
	return item and item.label or _item
end

RegisterNetEvent('esx_drilltime:skill_level:client:buy_level')
AddEventHandler('esx_drilltime:skill_level:client:buy_level', function(args)  
	if args.current_level >= args.level then
        lib.notify({
            title = 'Drilltime',
            description = 'Level already aquiered.',
            position = 'bottom',
        })
        return
    end
    if args.current_level + 1 < args.level then
        lib.notify({
            title = 'Drilltime',
            description = 'Level locked.',
            position = 'bottom',
        })
        return
    end

    if args.type == 'stamina' then
        local drug_level = GetPlayerDrugLevel()
        if drug_level < 500 then
            lib.notify({
                title = 'Drilltime',
                description = 'You should be drug level 500.',
                position = 'bottom',
            })
            return 
        end
    end
    TriggerServerEvent('esx_drilltime:skill_level:server:buy_level', args.type, args.data)
end)

RegisterNetEvent('esx_drilltime:skill_level:client:notify')
AddEventHandler('esx_drilltime:skill_level:client:notify', function(msg, type)  
	lib.notify({
        title = 'Drilltime',
        description = msg,
        position = 'bottom',
        type = type
    })
end)

RegisterNetEvent('esx_drilltime:skill_level:client:update_skill')
AddEventHandler('esx_drilltime:skill_level:client:update_skill', function(type)  
	if type == 'armor' then
        GiveLevelArmor()
    elseif type == 'stamina' then
        GiveLevelStamina()
    end
end)

GiveLevelArmor = function()
    local ped = PlayerPedId()
    local level = GetPlayerArmorLevel()
    local current_armor = GetPedArmour(ped)
    local new_armor = level * 5
    if new_armor > current_armor then
        SetPedArmour(ped, new_armor)
        lib.notify({
            title = 'Drilltime',
            description = 'You got ' .. new_armor .. '/100 armor',
            position = 'bottom',
        })
    end
end

exports('GiveLevelArmor', GiveLevelArmor)

GiveLevelStamina = function()
    StaminaLevel = GetPlayerStaminaLevel()
end

function Draw3dText(x, y, z, text)
    local factor = string.len(string.gsub(text, '~%a*~', '')) / 470
    SetTextFont(4)
	SetTextScale(0.45, 0.45)
    SetTextCentre(true)
    SetTextColour(255, 255, 255, 215)
    BeginTextCommandDisplayText('STRING')
    AddTextComponentSubstringPlayerName(text)
    SetDrawOrigin(x, y, z, 0)
    DrawText(0.0, 0.0)
    --DrawRect(0.0, 0.0125, factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end

CreateThread(function()
    while StaminaLevel == nil do Wait(10) end
    local sleep 
    while true do
        if StaminaLevel == 1 then
            ResetPlayerStamina(PlayerId())
            sleep = 10
        else
            sleep = 3000
        end
        Wait(sleep)
    end
end)

