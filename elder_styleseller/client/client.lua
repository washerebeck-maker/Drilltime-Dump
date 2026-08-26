--[[################################################### GLOBAL ###################################################]]

__G = {}
__G.PlayerJob = nil
__G.InProgress = false
__G.SellingPosition = nil
__G.Customers = {}
__G.CurrentCustomer = nil
__G.CurrentToogleKey = Config.ToogleKeys[1]
__G.AntiSpam = false
__G.ZoneBlip = nil
__G.CreatePosition = nil

--[[################################################### COMMANDS ###################################################]]

RegisterCommand(Config.CommandName, function()
	if not __G.PlayerJob or __G.PlayerJob.name ~= 'hairsalon' then
		return
	end
	if exports['loaf_housing']:IsInHouse() then
		Helper.NotifyError("You cannot sell products in you house")
		return
	end
	if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), Config.CayoPoint, true) < 2000.0 then
		ESX.ShowNotification("You cant sell products at Cayo Island!")
		return
	end
	if not __G.InProgress then
		CheckAndStartProductsSeller()
	else
		Helper.NotifyError(Config.Locales.in_progress)
	end
end)

--[[################################################### EVENTS  ###################################################]]

RegisterNetEvent('elder_styleseller:client:respawn_customer')
AddEventHandler('elder_styleseller:client:respawn_customer', function(index)  
    RespawnCustomer(index)
end)

AddEventHandler('esx:onPlayerDeath', function(data)
	if __G.InProgress then
		__G.InProgress = false
		Wait(5000)
		Helper.NotifySuccess(Config.Locales.death)
		DeleteAllCustomers()
	end
end)

RegisterNetEvent('elder_styleseller:client:delete_customer')
AddEventHandler('elder_styleseller:client:delete_customer', function(index)  
    DeleteCustomer(index)
end)

RegisterNetEvent('elder_styleseller:client:customer_spawner')
AddEventHandler('elder_styleseller:client:customer_spawner', function()  
    StartCustomerSpawner()
end)

AddEventHandler('onResourceStop', function(resource)
	if resource == GetCurrentResourceName() then
		for k, v in ipairs(__G.Customers) do
			SetPedAsNoLongerNeeded(v)
			DeleteEntity(v)
		end
	end
end)

--[[################################################### FUNCTIONS ###################################################]]

HasProducts = function()
	local result = promise:new()
	ESX.TriggerServerCallback('elder_styleseller:server:has_products', function(has_products)
		result:resolve(has_products)
	end)
	return Citizen.Await(result)
end

SellProducts = function()
	local result = promise:new()
	ESX.TriggerServerCallback('elder_styleseller:server:sell_products', function(data)
		result:resolve(data)
	end)
	return Citizen.Await(result)
end

CheckAndStartProductsSeller = function()
	if HasProducts() then
		Helper.NotifySuccess(Config.Locales.start_selling)
		__G.InProgress = true
		StartProductsSelling()
	else
		Helper.NotifyError(Config.Locales.no_products)
	end
end

StartProductsSelling = function()
	__G.SellingPosition = GetEntityCoords(PlayerPedId())
	__G.CreatePosition =  GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 6.0, 5.0)
	StartPlayerAnimation()
	StartCheckPosition()
	TriggerEvent('elder_styleseller:client:customer_spawner')
	StartSelling()
end

StartSelling = function()
	CreateThread(function()
		while __G.InProgress do
			if __G.Customers[__G.CurrentCustomer] then
				local customer_coords = GetEntityCoords(__G.Customers[__G.CurrentCustomer])
				DrawMarker(20, customer_coords.x, customer_coords.y, customer_coords.z+1.0, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 0.3, 0.3, 0.3, 255, 105, 180, 200, true, true, 2, false, false, false, false)
				local distance = Vdist2(GetEntityCoords(PlayerPedId()), customer_coords)
				if distance < 2.0 then
					ESX.ShowHelpNotification((Config.Locales.start_sell):format(__G.CurrentToogleKey.key))
					if IsControlJustPressed(0, __G.CurrentToogleKey.value) and not __G.AntiSpam then
						__G.AntiSpam = true
						if ProcessDeal() then
							TriggerEvent('elder_styleseller:client:respawn_customer', __G.CurrentCustomer)
							NextCustomer()
						else
							__G.AntiSpam = false
							__G.InProgress = false
							Helper.NotifyError(Config.Locales.no_products)
							DeleteAllCustomers()
						end
					end
				end
			end
			Wait(1)
		end
	end)
end

ProcessDeal = function()
	local result = true
	reject = math.random(1, 100)
	if reject % 20 == 0 then
		Helper.NotifyError(Config.Locales.reject)
		PlayAmbientSpeech1(__G.Customers[__G.CurrentCustomer], 'GENERIC_HI', 'SPEECH_PARAMS_STANDARD')
	else
		local data = SellProducts()
		if data then
			PlayDealAnimation()
			Helper.ShowNotification((Config.Locales.sold_product):format(data.count, Helper.GetLabel(data.name), ESX.Math.GroupDigits(data.price)))
		else
			result = false
		end
	end
	__G.AntiSpam = false
	return result
end

StartPlayerAnimation = function()
	local player_ped = PlayerPedId()
	TaskStartScenarioInPlace(player_ped, "WORLD_HUMAN_STAND_MOBILE", 0, true)
	ESX.ShowAdvancedNotification(Config.Locales.title, '', Config.Locales.searching, 'CHAR_WENDY', 1)
	Wait(5000)
	ClearPedTasks(player_ped) 
end

PlayDealAnimation = function()
	local player_ped = PlayerPedId()
	local customer = __G.Customers[__G.CurrentCustomer]
	Helper.MakeEntityFaceEntity(player_ped, customer)
	Helper.MakeEntityFaceEntity(customer, player_ped)
	SetPedTalk(customer)
	PlayAmbientSpeech1(customer, 'GENERIC_HI', 'SPEECH_PARAMS_STANDARD')
	local prop = Config.Props[math.random(1,#Config.Props)]
	obj = CreateObject(GetHashKey(prop.model), 0, 0, 0, true)
	AttachEntityToEntity(obj, player_ped, GetPedBoneIndex(player_ped,  prop.bone), prop.pos.x, prop.pos.y, prop.pos.z, prop.rot.x, prop.rot.y, prop.rot.z, 1, false, 0, 1, 0, 1)
	obj2 = CreateObject(GetHashKey('hei_prop_heist_cash_pile'), 0, 0, 0, true)
	AttachEntityToEntity(obj2, customer, GetPedBoneIndex(customer,  57005), 0.13, 0.02, 0.0, -90.0, 0, 0, 1, false, 0, 1, 0, 1)
	Helper.PlayAnim('mp_common', 'givetake1_a', 8.0, -1, 0)
	Helper.PlayAnimOnPed(customer, 'mp_common', 'givetake1_a', 8.0, -1, 0)
	Wait(1000)
	AttachEntityToEntity(obj2, player_ped, GetPedBoneIndex(player_ped,  57005), 0.13, 0.02, 0.0, -90.0, 0, 0, 1, false, 0, 1, 0, 1)
	AttachEntityToEntity(obj, customer, GetPedBoneIndex(customer,  prop.bone), prop.pos.x, prop.pos.y, prop.pos.z, prop.rot.x, prop.rot.y, prop.rot.z, 1, false, 0, 1, 0, 1)
	Wait(1000)
	DeleteEntity(obj)
	DeleteEntity(obj2)
	PlayAmbientSpeech1(customer, 'GENERIC_THANKS', 'SPEECH_PARAMS_STANDARD')
end

StartCheckPosition = function()
	__G.ZoneBlip = AddBlipForRadius(__G.SellingPosition, Config.MaxZoneRadius)
	SetBlipColour(__G.ZoneBlip, 23)
	SetBlipAlpha(__G.ZoneBlip, 200)
	SetBlipDisplay(__G.ZoneBlip, 8)
	CreateThread(function()
		while __G.InProgress do
			if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), __G.SellingPosition, true) > Config.MaxZoneRadius then
				__G.InProgress = false
				DeleteAllCustomers()
				Helper.NotifySuccess(Config.Locales.out_of_zone)
			end
			Wait(1000)
		end
		RemoveBlip(__G.ZoneBlip)
	end)
end

StartCustomerSpawner = function()
	__G.CurrentCustomer = 1
	for index = 1, Config.MaxCustomerAtOnce, 1 do
		if not __G.Customers[index] then
			CreateCustomer(index)
			Wait(5000)
		end
	end
	GoToWithAnimation(__G.CurrentCustomer)
end

CreateCustomer = function(index)
	if not __G.InProgress then return false end
	local player_ped = PlayerPedId()
	local npc_coords = __G.CreatePosition
	local retval, z = GetGroundZFor_3dCoord(npc_coords.x, npc_coords.y, npc_coords.z, 0)
	if retval == false then
		Helper.NotifyError(Config.Locales.wrong_position)
		return false
	end
	local ped_hash = GetHashKey(Config.PedsList[math.random(1, #Config.PedsList)])
	ESX.Streaming.RequestModel(ped_hash)
	local x_offset, y_offset = Helper.GetRandomOffset()
	__G.Customers[index] = CreatePed(5, ped_hash, npc_coords.x + x_offset, npc_coords.y + y_offset, z , 0.0, true, true)
	PlaceObjectOnGroundProperly(__G.Customers[index])
	SetEntityAsMissionEntity(__G.Customers[index])
	SetEntityInvincible(__G.Customers[index], true)
	SetBlockingOfNonTemporaryEvents(__G.Customers[index], true)
	TaskGoToEntity(__G.Customers[index], player_ped, 60000, Helper.RandomFloat(2.0,5.0), 1.0, 0, 0)
	return true
end

RespawnCustomer = function(index)
	if not __G.Customers[index] then return end
	SetPedAsNoLongerNeeded(__G.Customers[index])
	Wait(5000)
	DeleteEntity(__G.Customers[index])
	__G.Customers[index] = nil
	Wait(1000)
	CreateCustomer(index)
end

DeleteCustomer = function(index)
	if not __G.Customers[index] then return end
	SetPedAsNoLongerNeeded(__G.Customers[index])
	Wait(3000)
	DeleteEntity(__G.Customers[index])
	__G.Customers[index] = nil
end

DeleteAllCustomers = function()
	for k, v in ipairs(__G.Customers) do
		TriggerEvent('elder_styleseller:client:delete_customer', k)
	end
end

NextCustomer = function()
	if __G.CurrentCustomer == Config.MaxCustomerAtOnce then
		__G.CurrentCustomer = 1
	else
		__G.CurrentCustomer = __G.CurrentCustomer + 1
	end
	__G.CurrentToogleKey = Config.ToogleKeys[math.random(1,#Config.ToogleKeys)]
	GoToWithAnimation(__G.CurrentCustomer)
end

GoToWithAnimation = function(index)
	--local anim_index = math.random(1, #Config.Animation)
	--Helper.PlayAnimOnPed(__G.Customers[index], Config.Animation[anim_index].dict, Config.Animation[anim_index].anim, 8.0, -1, 0)
	Wait(2000)
	TaskGoToEntity(__G.Customers[index], PlayerPedId(), 60000, 1.0, 1.0, 0, 0)
end

