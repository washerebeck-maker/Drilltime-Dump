--███████╗██████╗  █████╗ ███╗   ███╗███████╗██╗    ██╗ ██████╗ ██████╗ ██╗  ██╗
--██╔════╝██╔══██╗██╔══██╗████╗ ████║██╔════╝██║    ██║██╔═══██╗██╔══██╗██║ ██╔╝
--█████╗  ██████╔╝███████║██╔████╔██║█████╗  ██║ █╗ ██║██║   ██║██████╔╝█████╔╝ 
--██╔══╝  ██╔══██╗██╔══██║██║╚██╔╝██║██╔══╝  ██║███╗██║██║   ██║██╔══██╗██╔═██╗ 
--██║     ██║  ██║██║  ██║██║ ╚═╝ ██║███████╗╚███╔███╔╝╚██████╔╝██║  ██║██║  ██╗
--╚═╝     ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝     ╚═╝╚══════╝ ╚══╝╚══╝  ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝

ESX = exports['es_extended']:getSharedObject()


local G_NPC = nil
local G_UpgradedVehicles = {}
local G_InRaceZone = false

--████████╗██╗  ██╗██████╗ ███████╗ █████╗ ██████╗ ███████╗
--╚══██╔══╝██║  ██║██╔══██╗██╔════╝██╔══██╗██╔══██╗██╔════╝
--   ██║   ███████║██████╔╝█████╗  ███████║██║  ██║███████╗
--   ██║   ██╔══██║██╔══██╗██╔══╝  ██╔══██║██║  ██║╚════██║
--   ██║   ██║  ██║██║  ██║███████╗██║  ██║██████╔╝███████║
--   ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═════╝ ╚══════╝

if Config.Racezone.enable then
    CreateThread(function()
        local whitelisted_location = lib.zones.poly({
            points = Config.Racezone.points,
            thickness = 10,
            debug = false,
            inside = function() end ,
            onEnter = function() G_InRaceZone = true end,
            onExit = function() G_InRaceZone = false end
        })
    end)
end

Citizen.CreateThread(function()
	--[[ local blip = AddBlipForCoord(Config.Shop.coords)
    SetBlipSprite(blip, 304)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, 1.2)
    SetBlipColour(blip, 38)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Speedy")
    EndTextCommandSetBlipName(blip) ]]
	ESX.Streaming.RequestModel(Config.Shop.ped_model)
    G_NPC = CreatePed(5, GetHashKey(Config.Shop.ped_model), Config.Shop.coords.x, Config.Shop.coords.y, Config.Shop.coords.z-1, Config.Shop.coords.w, false, true)
    PlaceObjectOnGroundProperly(G_NPC)
    TaskStartScenarioInPlace(G_NPC, "WORLD_HUMAN_CLIPBOARD", 0, true)
    FreezeEntityPosition(G_NPC, true)
    SetEntityInvincible(G_NPC, true)
    SetBlockingOfNonTemporaryEvents(G_NPC, true)  
end)

Citizen.CreateThread(function()
    local wait
    while true do
        local player_coords = GetEntityCoords( PlayerPedId())
        if GetDistanceBetweenCoords(player_coords, Config.Shop.coords,true) <= 1.5 then
            wait = 1
            ESX.ShowHelpNotification('Press ~INPUT_CONTEXT~ to open ~y~shop~s~')
            if IsControlJustReleased(0, 38) then
                OpenShopMenu()
            end
        else
            wait = 1000
        end
        Citizen.Wait(wait)
    end
end)

Citizen.CreateThread(function()
	while true do
		Wait(500)
		local player_ped = PlayerPedId()
  		if not IsPedInAnyVehicle(player_ped,false) then goto continue end
		local vehicle = GetVehiclePedIsIn(player_ped,false)
		if IsWhiteListedVehicle(GetEntityModel(vehicle)) then goto continue end
		if GetPedInVehicleSeat(vehicle, -1) ~= player_ped then goto continue end
		local plate = GetVehicleNumberPlateText(vehicle)
        if G_InRaceZone then 
            SetEntityMaxSpeed(vehicle,999999.0)
            goto continue 
        end
		for _,v in pairs(Config.Zones) do
			local distance = GetDistanceBetweenCoords(GetEntityCoords(player_ped,true), v.coords , false)
			if distance < v.radius then
				local RealMaxSpeed = G_UpgradedVehicles[plate] or v.MaxSpeed
				if exports.elder_cartheft:DoesVehicleHasEngineRemoved(plate) then
					RealMaxSpeed = 30.0
				end
				local MaxSpeed = RealMaxSpeed / (Config.MPH and 2.237 or  3.6)
				
				SetEntityMaxSpeed(vehicle,MaxSpeed)
				
				break
			end	
    	end	
		::continue::
 	end
end)

--███████╗██╗   ██╗███████╗███╗   ██╗████████╗███████╗
--██╔════╝██║   ██║██╔════╝████╗  ██║╚══██╔══╝██╔════╝
--█████╗  ██║   ██║█████╗  ██╔██╗ ██║   ██║   ███████╗
--██╔══╝  ╚██╗ ██╔╝██╔══╝  ██║╚██╗██║   ██║   ╚════██║
--███████╗ ╚████╔╝ ███████╗██║ ╚████║   ██║   ███████║
--╚══════╝  ╚═══╝  ╚══════╝╚═╝  ╚═══╝   ╚═╝   ╚══════╝

RegisterNetEvent('es_drilltime_speedcontrol:client:buy')
AddEventHandler('es_drilltime_speedcontrol:client:buy', function(args)
   TriggerServerEvent('es_drilltime_speedcontrol:server:buy', args.item)
end)

RegisterNetEvent('es_drilltime_speedcontrol:client:upgrade')
AddEventHandler('es_drilltime_speedcontrol:client:upgrade', function(plate, speed)
   G_UpgradedVehicles[plate] = speed
end)

RegisterNetEvent('es_drilltime_speedcontrol:client:use')
AddEventHandler('es_drilltime_speedcontrol:client:use', function(item, slot)
	UseSpeedyItem(item, slot)
end)


--███████╗██╗   ██╗███╗   ██╗ ██████╗████████╗██╗ ██████╗ ███╗   ██╗███████╗
--██╔════╝██║   ██║████╗  ██║██╔════╝╚══██╔══╝██║██╔═══██╗████╗  ██║██╔════╝
--█████╗  ██║   ██║██╔██╗ ██║██║        ██║   ██║██║   ██║██╔██╗ ██║███████╗
--██╔══╝  ██║   ██║██║╚██╗██║██║        ██║   ██║██║   ██║██║╚██╗██║╚════██║
--██║     ╚██████╔╝██║ ╚████║╚██████╗   ██║   ██║╚██████╔╝██║ ╚████║███████║
--╚═╝      ╚═════╝ ╚═╝  ╚═══╝ ╚═════╝   ╚═╝   ╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚══════╝

function UseSpeedyItem(item, owner)
	if not IsPedInAnyVehicle(PlayerPedId(),false) then
		ESX.ShowNotification('You should be in a ~r~vehicle~s~')
		return
	end
	local vehicle = GetVehiclePedIsIn(PlayerPedId(),false)
	if IsVehicleCompatible(item, GetEntityModel(vehicle)) then
		TriggerServerEvent('es_drilltime_speedcontrol:server:upgrade', item, GetVehicleNumberPlateText(vehicle), owner)
	else
		ESX.ShowNotification('Item ~r~not compatible~s~ with vehicle')
	end
end

function OpenShopMenu()
    local Options = {}
    for k,v in pairs(Config.SpeedItems) do
		Options[#Options + 1] = 
        {
            title = v.label,
            description = 'Speed up to ' .. v.max_speed .. ' for $'.. ESX.Math.GroupDigits(v.price) ,
            icon = 'fa-gauge-high',
            iconColor = v.color,
            arrow = true,
            event = 'es_drilltime_speedcontrol:client:buy',
            args = {item = k}
        }
    end	
	lib.registerContext({
		id = 'speedy_shop_menu',
		title = 'Welcome to Drilltime Speedy',
		options = Options
	})
	lib.showContext('speedy_shop_menu')
end

function IsVehicleCompatible(item, model)
	if Config.SpeedItems[item].whitelisted then
		for k,v in pairs(Config.SpeedItems[item].vehicles) do
			if GetHashKey(v) == model then 
				return true
			end
		end
		return false
	else
		for k,v in pairs(Config.SpeedItems[item].vehicles) do
			if GetHashKey(v) == model then 
				return false
			end
		end
		return true
	end
end
		
function ShowNotification(text)
    ClearPrints()
    SetTextEntry_2("STRING")
    AddTextComponentString(text)
    DrawSubtitleTimed(1000, 1)
end

function IsWhiteListedVehicle(model)
	for k,v in pairs(Config.WhiteListedVehicles) do
		if model == GetHashKey(v) then
			return true
		end
	end
	return false
end
