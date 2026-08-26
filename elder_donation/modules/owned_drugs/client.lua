local g_identifier = nil

CreateThread(function()
    if ESX.IsPlayerLoaded() then
        g_identifier = ESX.GetPlayerData().identifier:match('char%d+:(.+)')
    end
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(Player)
   g_identifier = Player.identifier:match('char%d+:(.+)')
end)

local function ingredientsMenu()
    local options = {}
    local crafted_item = config.owned_drugs.owners[g_identifier]
    if not crafted_item then return end
    for k,v in pairs(config.owned_drugs.ingredients) do 
        options[#options + 1] = {
            title = getItemLabel(v.item),
            description = ('required x%s | you have x%s'):format(v.count, exports.ox_inventory:Search('count', v.item)),
            icon = getItemImage(v.item),
            readOnly = true,
        }
    end
    options[#options + 1] = {
        title = getItemLabel(crafted_item),
        description = ('you will got x%s %s'):format(config.owned_drugs.crafting_count, getItemLabel(crafted_item)),
        icon = getItemImage(crafted_item),
        readOnly = true,
        arrow = true,
    }

    lib.registerContext({
        id = 'ingredients_menu',
        title = 'Ingredients Menu',
        options = options
    })
    lib.showContext('ingredients_menu')
end

local function craft()
    for k,v in pairs(config.owned_drugs.ingredients) do 
        if exports.ox_inventory:Search('count', v.item) < v.count then
            notify('you dont have enough ingredients', 'error')
            return 
        end
    end
    lib.progressCircle({
		duration = config.owned_drugs.crafting_time * 1000,
		label = 'Crafting',
		useWhileDead = false,
		allowRagdoll = false,
		allowCuffed = false,
		allowFalling = false,
		canCancel = false,
		anim = { dict = 'anim@gangops@facility@servers@bodysearch@', clip = 'player_search' },
		disable = { car = true, move = true, combat = true } 
	})
    TriggerServerEvent('elder_donation:owned_drugs:server:craft')
end

RegisterNetEvent('elder_donation:owned_drugs:client:onDrugUse')
AddEventHandler('elder_donation:owned_drugs:client:onDrugUse', function()
	lib.requestAnimDict("mp_suicide")
    TaskPlayAnim(cache.ped, "mp_suicide", "pill_fp", 8.0, 8.0, -1, 50, 0, false, false, false)
    Wait(3000)
	ClearPedSecondaryTask(cache.ped)
    notify('100% armor added')
    SetPedArmour(cache.ped, GetPedArmour(cache.ped) + 100)
end)

CreateThread(function()
    while not g_identifier do Wait(10) end
    if not config.owned_drugs.owners[g_identifier] then 
        return 
    end
    for k,v in pairs(config.owned_drugs.crafting_locations) do 
        local blip = AddBlipForCoord(v)
        SetBlipSprite(blip, 384)
        SetBlipColour(blip, 1)
        SetBlipAlpha(blip, 250)
        SetBlipScale(blip, 1.0)
        SetBlipAsShortRange(blip,true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("drug craft")
        EndTextCommandSetBlipName(blip)

        local craft_marker_location = lib.points.new(v, 50.0)
        function craft_marker_location:nearby()
            DrawMarker(1, self.coords.x, self.coords.y, self.coords.z-1.65, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 5.0, 5.0, 1.0, 255, 0, 0, 255, 0, 0, 2)
        end

        local craft_location = lib.points.new(v, 2.5)
        function craft_location:onEnter()
            lib.showTextUI('[E] - Craft  \n [G] - Recipes')
        end
        function craft_location:onExit()
            lib.hideTextUI()
        end
        function craft_location:nearby()
            if IsControlJustReleased(0, 38) then
                craft()
            end
            if IsControlJustReleased(0, 47) then
                ingredientsMenu()
            end  
        end
    end
end)

