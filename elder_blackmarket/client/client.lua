
ESX = exports['es_extended']:getSharedObject() 

Global = {}
Global.Identifier = nil
Global.BlackMarkets = nil
Global.NPC = {}

Citizen.CreateThread(function()
	while ESX == nil do
		Citizen.Wait(10)
	end

	ESX.PlayAnim = function(dict, anim, speed, time, flag)
		ESX.Streaming.RequestAnimDict(dict, function()
			TaskPlayAnim(PlayerPedId(), dict, anim, speed, speed, time, flag, 1, false, false, false)
		end)
	end

	ESX.PlayAnimOnPed = function(ped, dict, anim, speed, time, flag)
		ESX.Streaming.RequestAnimDict(dict, function()
			TaskPlayAnim(ped, dict, anim, speed, speed, time, flag, 1, false, false, false)
		end)
	end
end)

RegisterCommand('setbm', function(source, args, rawCommand)
	local ped = PlayerPedId()
	local coords = GetEntityCoords(ped)
	local heading = GetEntityHeading(ped)
    TriggerServerEvent('elder_blackmarket:server:setbm', args, coords, heading)
end,false)


RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)  
	Citizen.Wait(2000)
	Global.BlackMarkets, Global.Identifier = lib.callback.await('elder_blackmarket:server:getBlackMarkets')
end)


AddEventHandler('onResourceStart', function(resourceName)
	Citizen.Wait(2000)
    Global.BlackMarkets, Global.Identifier = lib.callback.await('elder_blackmarket:server:getBlackMarkets')
end)

Citizen.CreateThread(function()
	while not Global.BlackMarkets do Citizen.Wait(100) end
	for k,v in pairs(Global.BlackMarkets) do
		local ped_hash = GetHashKey("mp_m_weapexp_01")
		local coords = json.decode(v.position)
		ESX.Streaming.RequestModel(ped_hash)
		Global.NPC[k] = CreatePed(5, ped_hash, coords.x, coords.y, coords.z-1, coords.heading, false, true)
		PlaceObjectOnGroundProperly(Global.NPC[k])
		TaskStartScenarioInPlace(Global.NPC[k], "WORLD_HUMAN_DRUG_DEALER_HARD", 0, true)
		FreezeEntityPosition(Global.NPC[k], true)
		SetEntityInvincible(Global.NPC[k], true)
		SetBlockingOfNonTemporaryEvents(Global.NPC[k], true)	
	end
end)

Citizen.CreateThread(function()
	while not Global.BlackMarkets do Citizen.Wait(100) end
    while true do
		local wait = 1000
		local ped = cache.ped
		local ped_coords = GetEntityCoords(ped)
		for k,v in pairs(Global.BlackMarkets) do
			local position
			if type(v.position) == 'string' then
				position = json.decode(v.position)
			else
				position = v.position
			end
			
			if GetDistanceBetweenCoords(ped_coords, vector3(position.x,position.y,position.z),true) <= 1.5 then
				wait = 1
				ESX.ShowHelpNotification('Press ~INPUT_CONTEXT~ to open ~y~black market~s~')
				if IsControlJustReleased(0, 38) then
					OpenShop(k,v.id)
				end
			end
		end
        Citizen.Wait(wait)
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
	if (GetCurrentResourceName() == resourceName) then
		for k,v in pairs(Global.NPC) do
			SetPedAsNoLongerNeeded(v)
			DeleteEntity(v)
			Global.NPC[k] = nil
		end
	end
end)

RegisterNetEvent('elder_blackmarket:client:onBlackmarketCreated')
AddEventHandler('elder_blackmarket:client:onBlackmarketCreated', function(id, owner,coords,heading)  
	local ped_hash = GetHashKey("u_m_m_markfost")
	ESX.Streaming.RequestModel(ped_hash)
	Global.NPC[id] = CreatePed(5, ped_hash, coords.x, coords.y, coords.z-1, heading, false, true)
	PlaceObjectOnGroundProperly(Global.NPC[id])
	TaskStartScenarioInPlace(Global.NPC[id], "WORLD_HUMAN_DRUG_DEALER_HARD", 0, true)
	FreezeEntityPosition(Global.NPC[id], true)
	SetEntityInvincible(Global.NPC[id], true)
	SetBlockingOfNonTemporaryEvents(Global.NPC[id], true)
	Global.BlackMarkets[owner] = {owner = owner, position = {x=coords.x,y=coords.y,z=coords.z,h=heading}, id = id}
end)

RegisterNetEvent('elder_blackmarket:client:onBlackmarketDeleted')
AddEventHandler('elder_blackmarket:client:onBlackmarketDeleted', function(id)  
	SetPedAsNoLongerNeeded(Global.NPC[id])
	DeleteEntity(Global.NPC[id])
	Global.NPC[id] = nil
	Global.BlackMarkets[id] = nil
end)


function OpenShop(owner,id)

	local status = lib.callback.await('elder_blackmarket:server:get_menu_status',1, id)
	if status then
		ESX.ShowNotification('~r~ Shop not available, someone is in the shop.~s~')
		return
	end

	TriggerServerEvent('elder_blackmarket:server:open',id)

	local balance = lib.callback.await('elder_blackmarket:server:get_balance',1, id)

	
	local Options = {}
	if owner == Global.Identifier then
		Options[#Options + 1] = 
		{
			title = 'Balance : $' .. ESX.Math.GroupDigits(balance),
			description = 'withdraw money',
			icon = 'fa-wallet',
			iconColor = 'green',
			arrow = true,
			event = 'elder_blackmarket:client:withdraw',
			args = {id = id}
		}

		Options[#Options + 1] = 
		{
			title = 'Manage Market',
			description = 'add/remove items',
			icon = 'fa-gear',
			iconColor = 'yellow',
			arrow = true,
			event = 'elder_blackmarket:client:manage_market',
			args = {id = id}
		}
	end

	Options[#Options + 1] = 
    {
        title = 'Open Market',
        description = 'Buy Items',
        icon = 'fa-cart-plus',
        iconColor = 'red',
        arrow = true,
        event = 'elder_blackmarket:client:open_market',
		args = {id = id}
    }
	
	lib.registerContext({
		id = 'bm_'..id,
		title = 'Black Market',
		options = Options,
		onExit = function()
			TriggerServerEvent('elder_blackmarket:server:close', id)
		end
	})
	lib.showContext('bm_'..id)
end

function GetLabel(_item)
	local item  = exports.ox_inventory:Items(_item)
	return item and item.label or _item
end


RegisterNetEvent('elder_blackmarket:client:open_market')
AddEventHandler('elder_blackmarket:client:open_market', function(args)  
	local items = lib.callback.await('elder_blackmarket:server:get_market_items', nil ,args.id)
	OpenShopItems(args.id,items)
end)

RegisterNetEvent('elder_blackmarket:client:manage_market')
AddEventHandler('elder_blackmarket:client:manage_market', function(args) 
	local items = lib.callback.await('elder_blackmarket:server:get_market_items', nil ,args.id)
	OpenShopManagement(args.id,items)
end)

function OpenShopManagement(id,items)
	local Options = {}
 
	for i=1, 5 , 1 do

		if items and items[tostring(i)] then
			local item = items[tostring(i)]
			Options[#Options + 1] = {
				title = GetLabel(item.item) .. ' - ' .. item.durability .. '%',
				description = '$' .. ESX.Math.GroupDigits(tonumber(item.price)),
				icon = 'nui://ox_inventory/web/images/'..item.item..'.png',
				arrow = true,
				image = 'nui://ox_inventory/web/images/'..item.item..'.png',
				event = 'elder_blackmarket:client:remove_item',
				args = {slot = i, id = id, item = item.item, durability = item.durability }
			}
		else
			Options[#Options + 1] = {
				title = 'Empty Slot',
				description = 'Add a weapon',
				icon = 'fa-plus',
				iconColor = 'white',
				arrow = true,
				event = 'elder_blackmarket:client:list_item',
				args = {slot = i, id = id }
			}
		end

	end
	
	lib.registerContext({
		id = 'bmi_'..id,
		menu = 'bm_'..id,
		title = 'Black Market',
		options = Options,
		onExit = function()
			TriggerServerEvent('elder_blackmarket:server:close', id)
		end
	})
	lib.showContext('bmi_'..id)
end

function OpenShopItems(id,items)
	local Options = {}

	for k,v in pairs(items) do
		local item = items[k]
		Options[#Options + 1] = {
			title = GetLabel(v.item) .. ' - ' .. v.durability .. '%',
			description = '$' .. ESX.Math.GroupDigits(tonumber(v.price)),
			icon = 'nui://ox_inventory/web/images/'..v.item..'.png',
			arrow = true,
			image = 'nui://ox_inventory/web/images/'..v.item..'.png',
			event = 'elder_blackmarket:client:buy_item',
			args = {slot = v.slot, id = id, item = v.item, durability = v.durability, price = v.price}
		}
	end
	
	if #Options == 0 then
		Options[#Options + 1] = {
			title = 'No available items',
			description = '',
			icon = 'circle-xmark',
			iconColor = 'red',
			arrow = true,
		}
	end
	
	lib.registerContext({
		id = 'bmshop_'..id,
		menu = 'bm_'..id,
		title = 'Black Market',
		options = Options,
		onExit = function()
			TriggerServerEvent('elder_blackmarket:server:close', id)
		end
	})
	lib.showContext('bmshop_'..id)
end

RegisterNetEvent('elder_blackmarket:client:list_item')
AddEventHandler('elder_blackmarket:client:list_item', function(args) 
	local inv = lib.callback.await('ox_inventory:getInventory')
	local items = {}
	if inv and inv.items then
		for k,v in pairs(inv.items) do
			if string.sub(v.name,1,string.len("WEAPON"))== "WEAPON" then 
				items[#items+1] = {name = v.name, durability = v.metadata.durability , slot = v.slot}
			end
		end
	end
	local Options = {}
	if #items == 0 then
		Options[#Options + 1] = {
			title = 'No available items',
			description = '',
			icon = 'circle-xmark',
			iconColor = 'red',
			arrow = true,
		}
	else
		for k, v in pairs(items) do
			Options[#Options + 1] = {
				title = GetLabel(v.name),
				description = tostring(v.durability) .. '%',
				icon = 'fa-gun',
				iconColor = 'white',
				arrow = true,
				event = 'elder_blackmarket:client:add_item',
				args = {id = args.id, invslot = v.slot, slot = args.slot,item = v.name, durability = v.durability}
			}
		end
	end
	lib.registerContext({
		id = 'myitems',
		title = 'My Inventory',
		options = Options,
		onExit = function()
			TriggerServerEvent('elder_blackmarket:server:close', args.id)
		end
	})
	lib.showContext('myitems')
end)

RegisterNetEvent('elder_blackmarket:client:add_item')
AddEventHandler('elder_blackmarket:client:add_item', function(args)
	local input = lib.inputDialog('Price', {'Price'})
	if not input then
		return 
	end
	if not input[1] or not tonumber(input[1]) then
		ESX.ShowNotification('Wrong Price')
		return 
	end

	SetCurrentPedWeapon(GetPlayerPed(-1), "WEAPON_UNARMED", true)

	TriggerServerEvent('elder_blackmarket:server:add_item',args, tonumber(input[1]))

	TriggerServerEvent('elder_blackmarket:server:close', args.id)
end) 

RegisterNetEvent('elder_blackmarket:client:remove_item')
AddEventHandler('elder_blackmarket:client:remove_item', function(args)
	
	local alert = lib.alertDialog({
		header =  'Are you sure to remove the item?',
		content = 'Item : ' .. GetLabel(args.item),
		centered = true,
		cancel = true
	}) 

	if alert == 'confirm' then
		TriggerServerEvent('elder_blackmarket:server:remove_item',args)
	end 

	
	TriggerServerEvent('elder_blackmarket:server:close', args.id)
	

end) 

RegisterNetEvent('elder_blackmarket:client:buy_item')
AddEventHandler('elder_blackmarket:client:buy_item', function(args)
	
	local alert = lib.alertDialog({
		header =  'Are you sure to buy the item?',
		content = 'Item : ' .. GetLabel(args.item) .. ' - Price : ' .. ESX.Math.GroupDigits(args.price) ,
		centered = true,
		cancel = true
	}) 

	if alert == 'confirm' then
		TriggerServerEvent('elder_blackmarket:server:buy_item',args)
	end 

	TriggerServerEvent('elder_blackmarket:server:close', args.id)

end) 


RegisterNetEvent('elder_blackmarket:client:withdraw')
AddEventHandler('elder_blackmarket:client:withdraw', function(args)
	local input = lib.inputDialog('Amount', {'amount'})
	if not input then
		TriggerServerEvent('elder_blackmarket:server:close', args.id)
		return 
	end
	if not input[1] or not tonumber(input[1]) then
		ESX.ShowNotification('Wrong Amount')
		TriggerServerEvent('elder_blackmarket:server:close', args.id)
		return 
	end
	TriggerServerEvent('elder_blackmarket:server:withdraw',args, tonumber(input[1]))

	TriggerServerEvent('elder_blackmarket:server:close', args.id)
end) 


