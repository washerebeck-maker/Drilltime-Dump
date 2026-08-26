
ESX = exports['es_extended']:getSharedObject()

InProgress = false
SellingPosition = nil
Customers = {}
CurrentCustomer = nil
CurrentToogleKey = Config.ToogleKeys[1]
AntiSpam = false
ZoneBlip = nil
CreatePosition = nil

function hasProducts()
    return lib.callback.await('shoesseller:server:hasProducts')
end

function sellProducts()
    return lib.callback.await('shoesseller:server:sellProducts')
end

function startPlayerAnimation()
	TaskStartScenarioInPlace(cache.ped, "WORLD_HUMAN_STAND_MOBILE", 0, true)
	ESX.ShowAdvancedNotification(Config.Locales.title, '', Config.Locales.searching, 'CHAR_MP_SNITCH', 1)
	Wait(5000)
	ClearPedTasks(cache.ped) 
end

function startCheckPosition()
	ZoneBlip = AddBlipForRadius(SellingPosition, Config.MaxZoneRadius)
	SetBlipColour(ZoneBlip, 2)
	SetBlipAlpha(ZoneBlip, 200)
	SetBlipDisplay(ZoneBlip, 8)
	CreateThread(function()
		while InProgress do
			if GetDistanceBetweenCoords(GetEntityCoords(cache.ped), SellingPosition, true) > Config.MaxZoneRadius then
				InProgress = false
				deleteAllCustomers()
				notifySuccess(Config.Locales.out_of_zone)
			end
			Wait(1000)
		end
		RemoveBlip(ZoneBlip)
	end)
end

function startProductsSelling()
	SellingPosition = GetEntityCoords(cache.ped)
	CreatePosition =  GetOffsetFromEntityInWorldCoords(cache.ped, 0.0, 6.0, 5.0)
	startPlayerAnimation()
	startCheckPosition()
	TriggerEvent('shoesseller:client:customerSpawner')
	startSelling()
end

function playDealAnimation()
	local customer = Customers[CurrentCustomer]
	makeEntityFaceEntity(cache.ped, customer)
	makeEntityFaceEntity(customer, cache.ped)
	SetPedTalk(customer)
	PlayAmbientSpeech1(customer, 'GENERIC_HI', 'SPEECH_PARAMS_STANDARD')
	local prop = Config.Props[math.random(1,#Config.Props)]
	obj = CreateObject(GetHashKey(prop.model), 0, 0, 0, true)
	AttachEntityToEntity(obj, cache.ped, GetPedBoneIndex(cache.ped,  prop.bone), prop.pos.x, prop.pos.y, prop.pos.z, prop.rot.x, prop.rot.y, prop.rot.z, 1, false, 0, 1, 0, 1)
	obj2 = CreateObject(GetHashKey('hei_prop_heist_cash_pile'), 0, 0, 0, true)
	AttachEntityToEntity(obj2, customer, GetPedBoneIndex(customer,  57005), 0.13, 0.02, 0.0, -90.0, 0, 0, 1, false, 0, 1, 0, 1)
	playAnim('mp_common', 'givetake1_a', 8.0, -1, 0)
	playAnimOnPed(customer, 'mp_common', 'givetake1_a', 8.0, -1, 0)
	Wait(1000)
	AttachEntityToEntity(obj2, cache.ped, GetPedBoneIndex(cache.ped,  57005), 0.13, 0.02, 0.0, -90.0, 0, 0, 1, false, 0, 1, 0, 1)
	AttachEntityToEntity(obj, customer, GetPedBoneIndex(customer,  prop.bone), prop.pos.x, prop.pos.y, prop.pos.z, prop.rot.x, prop.rot.y, prop.rot.z, 1, false, 0, 1, 0, 1)
	Wait(1000)
	DeleteEntity(obj)
	DeleteEntity(obj2)
	PlayAmbientSpeech1(customer, 'GENERIC_THANKS', 'SPEECH_PARAMS_STANDARD')
end

function respawnCustomer(index)
	if not Customers[index] then return end
	SetPedAsNoLongerNeeded(Customers[index])
	Wait(5000)
	DeleteEntity(Customers[index])
	Customers[index] = nil
	Wait(1000)
	createCustomer(index)
end

function goToWithAnimation(index)
	Wait(2000)
	TaskGoToEntity(Customers[index], PlayerPedId(), 60000, 1.0, 1.0, 0, 0)
end

function deleteCustomer(index)
	if not Customers[index] then return end
	SetPedAsNoLongerNeeded(Customers[index])
	Wait(3000)
	DeleteEntity(Customers[index])
	Customers[index] = nil
end

function deleteAllCustomers()
	for k, v in ipairs(Customers) do
		TriggerEvent('shoesseller:client:deleteCustomer', k)
	end
end

function nextCustomer()
	if CurrentCustomer == Config.MaxCustomerAtOnce then
		CurrentCustomer = 1
	else
		CurrentCustomer = CurrentCustomer + 1
	end
	CurrentToogleKey = Config.ToogleKeys[math.random(1,#Config.ToogleKeys)]
	goToWithAnimation(CurrentCustomer)
end

function createCustomer(index)
	if not InProgress then return false end
	local npc_coords = CreatePosition
	local retval, z = GetGroundZFor_3dCoord(npc_coords.x, npc_coords.y, npc_coords.z, 0)
	if retval == false then
		notifyError(Config.Locales.wrong_position)
		return false
	end
	local ped_hash = GetHashKey(Config.PedsList[math.random(1, #Config.PedsList)])
	ESX.Streaming.RequestModel(ped_hash)
	local x_offset, y_offset = getRandomOffset()
	Customers[index] = CreatePed(5, ped_hash, npc_coords.x + x_offset, npc_coords.y + y_offset, z , 0.0, true, true)
	PlaceObjectOnGroundProperly(Customers[index])
	SetEntityAsMissionEntity(Customers[index])
	SetEntityInvincible(Customers[index], true)
	SetBlockingOfNonTemporaryEvents(Customers[index], true)
	TaskGoToEntity(Customers[index], cache.ped, 60000, randomFloat(2.0,5.0), 1.0, 0, 0)
	return true
end


function startCustomerSpawner()
	CurrentCustomer = 1
	for index = 1, Config.MaxCustomerAtOnce, 1 do
		if not Customers[index] then
			createCustomer(index)
			Wait(5000)
		end
	end
	goToWithAnimation(CurrentCustomer)
end


function processDeal()
	local result = true
	reject = math.random(1, 100)
	if reject % 20 == 0 then
		notifyError(Config.Locales.reject)
		PlayAmbientSpeech1(Customers[CurrentCustomer], 'GENERIC_HI', 'SPEECH_PARAMS_STANDARD')
	else
		local data = sellProducts()
		if data then
			playDealAnimation()
			showNotification((Config.Locales.sold_product):format(data.count, getLabel(data.name), ESX.Math.GroupDigits(data.price)))
		else
			result = false
		end
	end
	AntiSpam = false
	return result
end

function startSelling()
	CreateThread(function()
		while InProgress do
			if Customers[CurrentCustomer] then
				local customer_coords = GetEntityCoords(Customers[CurrentCustomer])
				DrawMarker(20, customer_coords.x, customer_coords.y, customer_coords.z+1.0, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 0.3, 0.3, 0.3, 0, 0, 180, 200, true, true, 2, false, false, false, false)
				local distance = Vdist2(GetEntityCoords(cache.ped), customer_coords)
				if distance < 2.0 then
					ESX.ShowHelpNotification((Config.Locales.start_sell):format(CurrentToogleKey.key))
					if IsControlJustPressed(0, CurrentToogleKey.value) and not AntiSpam then
						AntiSpam = true
						if processDeal() then
							TriggerEvent('shoesseller:client:respawnCustomer', CurrentCustomer)
							nextCustomer()
						else
							AntiSpam = false
							InProgress = false
							notifyError(Config.Locales.no_products)
							deleteAllCustomers()
						end
					end
				end
			end
			Wait(1)
		end
	end)
end

function checkAndStartProductsSeller()
	if hasProducts() then
		notifySuccess(Config.Locales.start_selling)
		InProgress = true
		startProductsSelling()
	else
		notifyError(Config.Locales.no_products)
	end
end

RegisterCommand(Config.CommandName, function()
	if exports['loaf_housing']:IsInHouse() then
		notifyError("You cannot sell products in you house")
		return
	end
	if not InProgress then
		checkAndStartProductsSeller()
	else
		notifyError(Config.Locales.in_progress)
	end
end)

RegisterNetEvent('shoesseller:client:respawnCustomer')
AddEventHandler('shoesseller:client:respawnCustomer', function(index)  
    respawnCustomer(index)
end)

AddEventHandler('esx:onPlayerDeath', function(data)
	if InProgress then
		InProgress = false
		Wait(5000)
		notifySuccess(Config.Locales.death)
		deleteAllCustomers()
	end
end)

RegisterNetEvent('shoesseller:client:deleteCustomer')
AddEventHandler('shoesseller:client:deleteCustomer', function(index)  
    deleteCustomer(index)
end)

RegisterNetEvent('shoesseller:client:customerSpawner')
AddEventHandler('shoesseller:client:customerSpawner', function()  
    startCustomerSpawner()
end)

AddEventHandler('onResourceStop', function(resource)
	if resource == GetCurrentResourceName() then
		for k, v in ipairs(Customers) do
			SetPedAsNoLongerNeeded(v)
			DeleteEntity(v)
		end
	end
end)





















