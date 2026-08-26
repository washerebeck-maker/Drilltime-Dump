


local Ready = false
local Locations = {}
local CurrentShopCoords = nil
local Sitting = false
local CurrentChair = nil
local CurrentChairCoords = nil
local MaxHairStyles = 0
local HairColors = {}


RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
   Wait(5000)
   MaxHairStyles = GetNumberOfPedDrawableVariations(cache.ped, 2) - 1
   for a = 0, GetNumHairColors(), 1  do
       local c = {GetPedHairRgbColor(a)}
       HairColors[#HairColors + 1] = c 
   end
end)
------------------------------------------------------ CHAIR SYSTEM ------------------------------------

Citizen.CreateThread(function()
    ------ DEV MODE
     --[[MaxHairStyles = GetNumberOfPedDrawableVariations(cache.ped, 2) - 1
    for a = 0, GetNumHairColors(), 1  do
        local c = {GetPedHairRgbColor(a)}
        HairColors[#HairColors + 1] = c 
    end ]]
    ------
    for k,v in pairs(Config.HairStyleJob.Locations) do
        Locations[k] = lib.zones.box({
            coords = v.coords,
            size = vec3(27, 16, 25),
            rotation = 0.0,
            debug = Config.DebugMode,
            inside = inside,
            onEnter = onEnter,
            onExit = onExit
        })
    end
    Ready = true
end)

Citizen.CreateThread(function()
    local markerTextUi = false
    while not Ready do Wait(10) end
    while true do
        local wait = 1000
        if CurrentShopCoords then
            wait = 1
            local object = GetClosestObjectOfType(cache.coords, 3.0, GetHashKey("v_ilev_hd_chair"), false, false, false)
            if DoesEntityExist(object) then
                local coords = GetEntityCoords(object)
                if GetDistanceBetweenCoords(cache.coords, coords) <= 1.5 then
                    if not markerTextUi then
                        ShowTextUI('[E] to sit/leave')
                        markerTextUi = true
                    end
                    DrawMarker(20, coords.x, coords.y, coords.z+1, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 0.3, 0.3, 0.3, 255, 0, 144, 150, true, true, 2, false, false, false, false)
                    if IsControlJustPressed(0, 38) then
                        lib.hideTextUI()
                        markerTextUi = false
                        UseChair(object,coords)
                    end
                else
                    if markerTextUi then
                        markerTextUi = false
                        lib.hideTextUI()
                    end
                end
            end
        else
            if markerTextUi then
                markerTextUi = false
                lib.hideTextUI()
            end
        end
        Wait(wait)
    end
end)

CreateThread(function()
	while true do
		local wait = 1000
		if sitting and not IsPedUsingScenario(cache.ped, "PROP_HUMAN_SEAT_BENCH") then
			Leave()
		end

		Wait(wait)
	end
end)


function onEnter(self)
    CurrentShopCoords = self.coords
end
 
function onExit(self)
    CurrentShopCoords = nil
end
 
function inside(self)

end

function UseChair(object, coords)
    if not Sitting then
        Sit(object,coords)
    else
        Leave()
    end
end

function Sit(object,coords)

    --[[ if not HasEntityClearLosToEntity(PlayerPedId(), object, 17) then
        return
    end ]]
    CurrentChair = object

    ESX.TriggerServerCallback('elder_drilltime:hairstylejob:server:check_sit', function(check)
        if check then
            ESX.ShowNotification('There is someone on this chair')
        else
   
            CurrentChairCoords = coords

            TriggerServerEvent('elder_drilltime:hairstylejob:server:sit', true , coords)
            TaskStartScenarioAtPosition(cache.ped, "PROP_HUMAN_SEAT_BENCH", coords.x, coords.y, coords.z + (cache.coords.z - coords.z)/2, 
                GetEntityHeading(object) + 180.0, 0, true, false)
            Wait(2500)
            if GetEntitySpeed(cache.ped) > 0 then
                ClearPedTasks(cache.ped)
                TaskStartScenarioAtPosition(cache.ped, "PROP_HUMAN_SEAT_BENCH", coords.x, coords.y, coords.z + (cache.coords.z - coords.z)/2, 
                    GetEntityHeading(object) + 180.0, 0, true, true)
            end
            Sitting = true
            --lib.disableControls()
        end
    end, coords)
end

function Leave()
    TaskStartScenarioAtPosition(cache.ped, "PROP_HUMAN_SEAT_BENCH", 0.0, 0.0, 0.0, 180.0, 2, true, false)
	while IsPedUsingScenario(cache.ped, "PROP_HUMAN_SEAT_BENCH") do
		Wait(100)
	end
	ClearPedTasks(cache.ped)
	FreezeEntityPosition(cache.ped, false)
	TriggerServerEvent('elder_drilltime:hairstylejob:server:sit', false, CurrentChairCoords)
	CurrentChairCoords = nil
	Sitting = false
end

---------------------------------------------- HAIR STYLES ---------------------------------
local CurrentStyle = 0
local CurrentColor = 0

RegisterNetEvent('elder_drilltime:hairstylejob:client:show_hair_styles')
AddEventHandler('elder_drilltime:hairstylejob:client:show_hair_styles', function()
    local player = lib.getClosestPlayer(cache.coords, 2.0, false)
    --local player = NetworkGetPlayerIndexFromPed(cache.ped)
    if not player then
        Notify('There appears to be no one around', 'error')
    else
        local target = GetPlayerServerId(player)
        OpenHairStyleMenu(target, 0)
        UpdateTargetHair(target,0,0)
        SetPedComponentVariation(GetPlayerPed(GetPlayerFromServerId(target)), 2, 0,0,0)
        SetPedHairColor(GetPlayerPed(GetPlayerFromServerId(target)), 0, 0)
    end
end)

function OpenHairStyleMenu(target, style_number)
    CurrentStyle = style_number
    local Options = {}
    Options[#Options + 1] = {
        title = 'Hair Styles #'..style_number,
        description = 'Press to apply and show colors.',
        icon = 'fa-scissors',
        iconColor = '#e00ddc',
        arrow = true,
        onSelect = function()
            OpenHairColorsMenu(target, style_number, 0)
        end  
    }
    Options[#Options + 1] = {
        title = 'Hair Style #'..CurrentStyle..' | color #'..CurrentColor,
        description = 'Current Style',
        icon = 'fa-droplet',
        iconColor = 'rgb('..HairColors[CurrentColor+1][1]..','..HairColors[CurrentColor+1][2]..','..HairColors[CurrentColor+1][3]..')',
        arrow = true, 
    }
    Options[#Options + 1] = {
        title = 'Next',
        description = '',
        icon = 'fa-square-plus',
        arrow = true,
        onSelect = function()
            local new_style = style_number + 1 > MaxHairStyles and 0 or style_number + 1
            OpenHairStyleMenu(target, new_style)
            UpdateTargetHair(target,new_style,0)
            SetPedComponentVariation(GetPlayerPed(GetPlayerFromServerId(target)), 2, new_style,0,0)
            SetPedHairColor(GetPlayerPed(GetPlayerFromServerId(target)), 0, 0)
        end
    }
    Options[#Options + 1] = {
        title = 'Previous',
        description = '',
        icon = 'fa-square-minus',
        arrow = true,
        onSelect = function()
            local new_style = style_number - 1 < 0 and MaxHairStyles or style_number -1
            OpenHairStyleMenu(target, new_style)
            UpdateTargetHair(target,new_style,0)
            SetPedComponentVariation(GetPlayerPed(GetPlayerFromServerId(target)), 2, new_style,0,0)
            SetPedHairColor(GetPlayerPed(GetPlayerFromServerId(target)), 0, 0)
        end 
    }
    Options[#Options + 1] = {
        title = 'Confirm & Send Bill',
        description = 'Apply the style and send bill to client',
        icon = 'fa-square-check',
        iconColor = 'green',
        arrow = true,
        onSelect = function()
            TriggerServerEvent('elder_drilltime:hairstylejob:server:pay_request', target, CurrentStyle, CurrentColor)
            CurrentStyle = 0
            CurrentColor = 0   
        end 
    }
    Options[#Options + 1] = {
        title = 'Cancel',
        description = 'Remove the style and finish work',
        icon = 'fa-rectangle-xmark',
        iconColor = 'red',
        arrow = true,
        onSelect = function()
            TriggerServerEvent('elder_drilltime:hairstylejob:server:reload_char',target)
            CurrentStyle = 0
            CurrentColor = 0  
        end 
    }
    lib.registerContext({
        id = 'hs_job_menu',
        title = 'Hair Styles',
        menu = 'barber_job_menu',
        options = Options,
        onExit = function()
            CurrentStyle = 0
            CurrentColor = 0
        end,
    })
    lib.showContext('hs_job_menu')
end


function OpenHairColorsMenu(target,style_number, color)
    CurrentColor = color
    local Options = {}
    Options[#Options + 1] = {
        title = 'Hair Color #'..color,
        description = 'Press to apply and show colors.',
        icon = 'fa-droplet',
        iconColor = 'rgb('..HairColors[color+1][1]..','..HairColors[color+1][2]..','..HairColors[color+1][3]..')',
        arrow = true,
        onSelect = function()
            
        end  
    }
    Options[#Options + 1] = {
        title = 'Next',
        description = '',
        icon = 'fa-square-plus',
        arrow = true,
        onSelect = function()
            OpenHairColorsMenu(target, style_number, color + 1 > #HairColors - 1 and 0 or color + 1)
            UpdateTargetHair(target,style_number,color)
            SetPedComponentVariation(GetPlayerPed(GetPlayerFromServerId(target)), 2, style_number,0,0)
            SetPedHairColor(GetPlayerPed(GetPlayerFromServerId(target)), color, 0)
        end
    }
    Options[#Options + 1] = {
        title = 'Previous',
        description = '',
        icon = 'fa-square-minus',
        arrow = true,
        onSelect = function()
            OpenHairColorsMenu(target, style_number, color - 1 < 0 and #HairColors - 1 or color - 1)
            UpdateTargetHair(target,style_number,color)
            SetPedComponentVariation(GetPlayerPed(GetPlayerFromServerId(target)), 2, style_number,0,0)
            SetPedHairColor(GetPlayerPed(GetPlayerFromServerId(target)), color, 0)
        end 
    }
    Options[#Options + 1] = {
        title = 'Back',
        description = '',
        icon = 'fa-square-caret-left',
        arrow = true,
        onSelect = function()
            OpenHairStyleMenu(target, CurrentStyle)
        end 
    }
        
    lib.registerContext({
        id = 'hsc_job_menu',
        title = 'Hair Styles Colors #' ..style_number,
        --menu = 'hs_job_menu',
        options = Options,
        onExit = function()
            CurrentStyle = 0
            CurrentColor = 0
        end,

    })
    lib.showContext('hsc_job_menu')
end

RegisterNetEvent('elder_drilltime:hairstylejob:client:reload_char')
AddEventHandler('elder_drilltime:hairstylejob:client:reload_char', function()  
    ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(appearance)
        exports['fivem-appearance']:setPlayerAppearance(appearance)
    end)
end)

function UpdateTargetHair(target,style, color)
    TriggerServerEvent('elder_drilltime:hairstylejob:server:update_style', target,style, color)
end

RegisterNetEvent('elder_drilltime:hairstylejob:client:update_style')
AddEventHandler('elder_drilltime:hairstylejob:client:update_style', function(style, color)
    SetPedComponentVariation(cache.ped, 2, style,0,0)
    SetPedHairColor(cache.ped, color, 0)
end)

RegisterNetEvent('elder_drilltime:hairstylejob:client:apply_style')
AddEventHandler('elder_drilltime:hairstylejob:client:apply_style', function(target,style,color)  
   --[[ while (not HasAnimDictLoaded("misshair_shop@barbers")) do
		RequestAnimDict("misshair_shop@barbers")
		Citizen.Wait(5)
	end
    local target_coords = GetOffsetFromEntityInWorldCoords(GetPlayerPed(GetPlayerFromServerId(target)), 0.0, 0 - 0.5, -0.5);
    TaskPedSlideToCoord(cache.ped, target_coords.x, target_coords.y, target_coords.z, GetEntityHeading(GetPlayerPed(GetPlayerFromServerId(target))), 1.0)
    Citizen.Wait(2000)
    TaskPlayAnim(cache.ped, "misshair_shop@barbers", "keeper_idle_b", 8.0, 8.0, 15000, 0, 0, -1, -1, -1)
    Citizen.Wait(11500)]]
    TriggerServerEvent('elder_drilltime:hairstylejob:server:apply_style', target,style,color)
end)

RegisterNetEvent('elder_drilltime:hairstylejob:client:apply_style_client')
AddEventHandler('elder_drilltime:hairstylejob:client:apply_style_client', function(style,color)  
    ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(appearance)
        appearance.hair.style = style
        appearance.hair.color = color 
        exports['fivem-appearance']:setPlayerAppearance(appearance)
        TriggerServerEvent('fivem-appearance:save', appearance)
    end)
end)



RegisterNetEvent('elder_drilltime:hairstylejob:client:pay_request')
AddEventHandler('elder_drilltime:hairstylejob:client:pay_request', function(barber, style, color)  
    local alert = lib.alertDialog({
        header = 'You have received a bill from Hair Style Store',
        content = 'Price : '.. ESX.Math.GroupDigits(Config.HairStyleJob.Price),
        centered = true,
        cancel = true,
        labels = {
            cancel=  "Pay",
            confirm=  "Decline",
        }
    })

    if alert == 'cancel' then
        TriggerServerEvent('elder_drilltime:hairstylejob:server:pay', barber, style, color)
    else
        TriggerServerEvent('elder_drilltime:hairstylejob:server:cancel_pay', barber)
    end
end)

--------------------------------------------- JOB MENU --------------------------------------------

function OpenJobMenu()
    local Options = {}
    Options[#Options + 1] = {
        title = 'Hair Styles',
        description = 'Show hair styles to client.',
        icon = 'fa-street-view',
        iconColor = 'pink',
        arrow = true,
        event = 'elder_drilltime:hairstylejob:client:show_hair_styles',
    }
    lib.registerContext({
        id = 'barber_job_menu',
        title = 'Fashion Club',
        options = Options,
        onExit = function()
            CurrentStyle = 0
            CurrentColor = 0
        end,
    })
    lib.showContext('barber_job_menu')
end

RegisterCommand('HairStyleJobMenu', function()
    if not PlayerJob or PlayerJob.name ~= Config.HairStyleJob.Job then return end
    if not CurrentShopCoords(cache.coords) then
        Notify('You should be in the Hair style store to use this.', 'error')
    else
        OpenJobMenu()
    end
end)

RegisterKeyMapping('HairStyleJobMenu', 'Hair Style', 'keyboard', 'F6')


--########################################################### SELLING ###############################################################

local Busy = false

local function PlayCollectAnim(h)
	local playerPed = PlayerPedId()
	LoadAnimation('anim@gangops@facility@servers@bodysearch@')
    SetEntityHeading(playerPed, h)
	TaskPlayAnim(playerPed, "anim@gangops@facility@servers@bodysearch@" ,"player_search" ,8.0, -8.0, -1, 48, 0, false, false, false )	  
	Citizen.Wait(2000)
	ClearPedTasksImmediately(playerPed)
end

local function PlayCraftAnim(h, do_anim)
	--[[ local playerPed = PlayerPedId()
	LoadAnimation('anim@gangops@facility@servers@bodysearch@')
    SetEntityHeading(playerPed, h)
	TaskPlayAnim(playerPed, "anim@gangops@facility@servers@bodysearch@" ,"player_search" ,8.0, -8.0, -1, 48, 0, false, false, false )	   ]]
    local playerPed = PlayerPedId()
    SetEntityHeading(playerPed, h)
    if do_anim then
        exports["rpemotes"]:EmoteCommandStart("tag6", 0)
        Citizen.Wait(6000)
        exports["rpemotes"]:EmoteCancel()
    else
        Citizen.Wait(2000)
    end
    
	--[[ ClearPedTasksImmediately(playerPed) ]]
end

local function Collect(id, item, count)
    Busy = true
    PlayCollectAnim(Config.HairStyleJob.Collect[id].coords.w)
    Wait(1000)
    TriggerServerEvent('elder_drilltime:hairstylejob:server:on_collect', item, count)
    Busy = false
end

local function CollectMenu(id)
    local menuOptions = {}  
    for k,v in ipairs(Config.HairStyleJob.Collect[id].items) do 
        table.insert(menuOptions, {title = GetItemLabel(v.item), description = 'Collect x'.. v.count .. ' of '.. GetItemLabel(v.item) , arrow = true, icon = Config.ImagesPath .. v.item .. '.png', onSelect = function() Collect(id,v.item, v.count) end })
    end            
    
    lib.registerContext({
        id = 'hs_collect_menu',
        title = 'Hair Style Store',
        options = menuOptions,
    })
    lib.showContext('hs_collect_menu')
end

local function Craft(craft_id)
    local menuOptions = {} 
    local craft = Config.HairStyleJob.Craft.recipes[craft_id]
    for k,v in ipairs(craft.ingredients) do 
        table.insert(menuOptions, {title = GetItemLabel(v.item), readOnly = true, description = 'x'.. v.count .. ' '.. GetItemLabel(v.item) , arrow = true, icon = Config.ImagesPath .. v.item .. '.png'})
    end 
    table.insert(menuOptions, {title = 'Prepare', iconColor = 'gold', arrow = true, icon = 'fa-circle-check' , onSelect = function() CraftStyleProcess(craft_id) end})
    table.insert(menuOptions, {title = 'Cancel' , iconColor = 'red', arrow = true, icon = 'fa-circle-xmark' , onSelect = function() CraftStyleMenu() end})         
    
    lib.registerContext({
        id = 'hs_craft_ex_menu',
        title = 'Prepare x'.. craft.count ..' of ' .. GetItemLabel(craft.item),
        options = menuOptions,
    })
    lib.showContext('hs_craft_ex_menu')
end

function CraftStyleMenu()
    local menuOptions = {}  
    for k,v in ipairs(Config.HairStyleJob.Craft.recipes) do 
        table.insert(menuOptions, {title = GetItemLabel(v.item), description = 'Craft x'.. v.count .. ' '.. GetItemLabel(v.item) , arrow = true, icon = Config.ImagesPath .. v.item .. '.png', onSelect = function() Craft(k) end })
    end            
    
    lib.registerContext({
        id = 'hs_craft_menu',
        title = 'Hair Salon',
        options = menuOptions,
    })
    lib.showContext('hs_craft_menu')
end

function CraftStyleProcess(craft_id)
    ESX.TriggerServerCallback('elder_drilltime:hairstylejob:server:check_craft', function(can_craft)
        if can_craft then
            Busy = true
            PlayCraftAnim(Config.HairStyleJob.Craft.coords.w, Config.HairStyleJob.Craft.recipes[craft_id].anim)
            Wait(1000)
            TriggerServerEvent('elder_drilltime:hairstylejob:server:on_craft', craft_id)
            Busy = false
        else
            Notify('You dont have enough ingredients.', 'error')
        end
    end, craft_id)
end

Citizen.CreateThread(function()
    while not PlayerJob do Wait(10) end
    while true do
        local inzone = false
        if PlayerJob.name == Config.HairStyleJob.Job then
            for k,v in pairs(Config.HairStyleJob.Collect) do 
                if GetDistanceBetweenCoords(cache.coords, v.coords) <= 4.0 then
                    inzone = true
                    ESX.ShowHelpNotification(v.label)
                    if IsControlJustPressed(0, 38) and not Busy then
                        CollectMenu(k)
                    end
                end
            end
        else
            Wait(4000)
        end
        Wait(inzone and 1 or 1000)
    end
end)

Citizen.CreateThread(function()
    while not PlayerJob do Wait(10) end
    while true do
        local inzone = false
        if PlayerJob.name == Config.HairStyleJob.Job then  
            if GetDistanceBetweenCoords(cache.coords,Config.HairStyleJob.Craft.coords) <= 2.0 then
                inzone = true
                ESX.ShowHelpNotification(Config.HairStyleJob.Craft.label)
                if IsControlJustPressed(0, 38) and not Busy then
                    CraftStyleMenu()
                end
            end    
        else
            Wait(4000)
        end
        Wait(inzone and 1 or 1000)
    end
end)
