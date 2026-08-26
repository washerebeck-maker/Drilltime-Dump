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
__G.PoliceBlips = {}
__G.CreatePosition = nil
__G.DrugDealerZonesLevel = 1


local AntiSpam = false

local function getGang()
	local gang = exports.elder_gangs:get_player_gang()
	return gang and tostring(gang.id) or nil
end

--[[################################################### COMMANDS ###################################################]]

RegisterCommand(Config.CommandName, function()
	if AntiSpam then 
		return ESX.ShowNotification("Stop spamming you motherfucka!")
	end

	AntiSpam = true

	if exports['loaf_housing']:IsInHouse() then
		Helper.NotifyError("You cannot sell drugs in your house")
		AntiSpam = false
		return
	end

	if getGang() then
		local success, inHood = pcall(function()
			return exports.elder_gangs:in_gang_hood()
		end)

		if success and not inHood then
			ESX.ShowNotification("You cant sell drugs outside your gang hood!")
			AntiSpam = false
			return
		end
	end

	if not __G.InProgress then
		CheckAndStartDrugDealer()
		AntiSpam = false
	else
		Helper.NotifyError(Config.Locales.in_progress)
		AntiSpam = false
	end
end)

--[[################################################### EVENTS  ###################################################]]

RegisterNetEvent('elder_drugdealer:client:respawn_customer')
AddEventHandler('elder_drugdealer:client:respawn_customer', function(index)  
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

RegisterNetEvent('elder_drugdealer:client:delete_customer')
AddEventHandler('elder_drugdealer:client:delete_customer', function(index)  
    DeleteCustomer(index)
end)

RegisterNetEvent('elder_drugdealer:client:customer_spawner')
AddEventHandler('elder_drugdealer:client:customer_spawner', function()  
    StartCustomerSpawner()
end)

RegisterNetEvent('elder_drugdealer:client:notify_cops')
AddEventHandler('elder_drugdealer:client:notify_cops', function(coords)	
	if __G.PlayerJob ~= nil and __G.PlayerJob.name == 'police' then
		street = GetStreetNameAtCoord(coords.x, coords.y, coords.z)
		street2 = GetStreetNameFromHashKey(street)
		Helper.ShowNotification((Config.Locales.police_alert):format(street2))
		PlaySoundFrontend(-1, "Bomb_Disarmed", "GTAO_Speed_Convoy_Soundset", 0)
		blip = AddBlipForCoord(coords)
		SetBlipSprite(blip,  403)
		SetBlipColour(blip,  1)
		SetBlipAlpha(blip, 250)
		SetBlipScale(blip, 2.2)
		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString('Dealer')
		EndTextCommandSetBlipName(blip)
		table.insert(__G.PoliceBlips, blip)
		Wait(50000)
		for i in pairs(__G.PoliceBlips) do
			RemoveBlip(__G.PoliceBlips[i])
			__G.PoliceBlips[i] = nil
		end
	end
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

HasDrugs = function()
	local result = promise:new()
	ESX.TriggerServerCallback('elder_drugdealer:server:has_drugs', function(has_drugs)
		result:resolve(has_drugs)
	end)
	return Citizen.Await(result)
end

SellDrugs = function()
	local result = promise:new()
	ESX.TriggerServerCallback('elder_drugdealer:server:sell_drugs', function(data)
		result:resolve(data)
	end, __G.DrugDealerZonesLevel, getGang() ~= nil)
	return Citizen.Await(result)
end

CheckAndStartDrugDealer = function()
	if HasDrugs() then
		Helper.NotifySuccess(Config.Locales.start_selling)
		__G.InProgress = true
		StartDrugDealer()
	else
		Helper.NotifyError(Config.Locales.no_drugs)
	end
end

StartDrugDealer = function()
	__G.SellingPosition = GetEntityCoords(PlayerPedId())
	__G.CreatePosition =  GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 6.0, 5.0)
	TriggerServerEvent('elder_drilltimegangs:server:drug_dealer',__G.SellingPosition)
	StartPlayerAnimation()
	StartCheckPosition()
	TriggerEvent('elder_drugdealer:client:customer_spawner')
	StartDrugSelling()
end

StartDrugSelling = function()
	CreateThread(function()
		local pedCount = 0
		while __G.InProgress do
			if __G.Customers[__G.CurrentCustomer] then
				local customer_coords = GetEntityCoords(__G.Customers[__G.CurrentCustomer])
				--ESX.Game.Utils.DrawText3D(customer_coords, "Am here !", 0.5)
				DrawMarker(20, customer_coords.x, customer_coords.y, customer_coords.z+1.0, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 0.3, 0.3, 0.3, 255, 215, 0, 200, true, true, 2, false, false, false, false)
				local distance = Vdist2(GetEntityCoords(PlayerPedId()), customer_coords)
				if distance < 2.0 then
					ESX.ShowHelpNotification((Config.Locales.start_sell):format(__G.CurrentToogleKey.key))
					if IsControlJustPressed(0, __G.CurrentToogleKey.value) and not __G.AntiSpam then
						__G.AntiSpam = true
						local success = true
						if pedCount % 10 == 0 then
							success = lib.skillCheck({areaSize = 120, speedMultiplier = 0.5}, {'w', 'a', 's', 'd'})
						end
						if success then
							if ProcessDeal() then
								pedCount = pedCount + 1
								TriggerEvent('elder_drugdealer:client:respawn_customer', __G.CurrentCustomer)
								NextCustomer()
							else
								__G.AntiSpam = false
								__G.InProgress = false
								Helper.NotifyError(Config.Locales.no_drugs)
								DeleteAllCustomers()
							end
						else
							__G.AntiSpam = false
							__G.InProgress = false
							Helper.NotifyError(Config.Locales.no_drugs)
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
		TriggerServerEvent('elder_drugdealer:server:notify_cops', GetEntityCoords(PlayerPedId()))
	else
		local data = SellDrugs()
		if data then
			PlayDealAnimation()
			Helper.ShowNotification((Config.Locales.sold_drug):format(data.count, Helper.GetLabel(data.name), ESX.Math.GroupDigits(data.price)))
			TriggerServerEvent('elder_drugs:server:update_level')
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
	ESX.ShowAdvancedNotification(Config.Locales.title, '', Config.Locales.searching, 'WEB_MORGANCHESTER', 1)
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
	obj = CreateObject(GetHashKey('prop_weed_bottle'), 0, 0, 0, true)
	AttachEntityToEntity(obj, player_ped, GetPedBoneIndex(player_ped,  57005), 0.13, 0.02, 0.0, -90.0, 0, 0, 1, false, 0, 1, 0, 1)
	obj2 = CreateObject(GetHashKey('hei_prop_heist_cash_pile'), 0, 0, 0, true)
	AttachEntityToEntity(obj2, customer, GetPedBoneIndex(customer,  57005), 0.13, 0.02, 0.0, -90.0, 0, 0, 1, false, 0, 1, 0, 1)
	Helper.PlayAnim('mp_common', 'givetake1_a', 8.0, -1, 0)
	Helper.PlayAnimOnPed(customer, 'mp_common', 'givetake1_a', 8.0, -1, 0)
	Wait(1000)
	AttachEntityToEntity(obj2, player_ped, GetPedBoneIndex(player_ped,  57005), 0.13, 0.02, 0.0, -90.0, 0, 0, 1, false, 0, 1, 0, 1)
	AttachEntityToEntity(obj, customer, GetPedBoneIndex(customer,  57005), 0.13, 0.02, 0.0, -90.0, 0, 0, 1, false, 0, 1, 0, 1)
	Wait(1000)
	DeleteEntity(obj)
	DeleteEntity(obj2)
	PlayAmbientSpeech1(customer, 'GENERIC_THANKS', 'SPEECH_PARAMS_STANDARD')
end

StartCheckPosition = function()
	__G.ZoneBlip = AddBlipForRadius(__G.SellingPosition, Config.MaxZoneRadius)
	SetBlipColour(__G.ZoneBlip, 1)
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
		TriggerEvent('elder_drugdealer:client:delete_customer', k)
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
	local anim_index = math.random(1, #Config.Animation)
	Helper.PlayAnimOnPed(__G.Customers[index], Config.Animation[anim_index].dict, Config.Animation[anim_index].anim, 8.0, -1, 0)
	Wait(4000)
	TaskGoToEntity(__G.Customers[index], PlayerPedId(), 60000, 1.0, 1.0, 0, 0)
end

--################################### ZONES & LEVELS ###########################


GetGangs = function()
	local result = promise:new()
    ESX.TriggerServerCallback('elder_drugdealer:server:get_gangs', function(cb_result) 
		result:resolve(cb_result)  
    end)
    return Citizen.Await(result)
end



GetGangNames = function()
	local result = promise:new()
    ESX.TriggerServerCallback('elder_drugdealer:server:get_gang_names', function(cb_result) 
		result:resolve(cb_result)  
    end)
    return Citizen.Await(result)
end


GetGangJob = function()
	local result = promise:new()
    ESX.TriggerServerCallback('elder_drugdealer:server:get_gang_job', function(job) 
		result:resolve(job)  
    end)
    return Citizen.Await(result)
end

GetLevel = function()
	local result = promise:new()
    ESX.TriggerServerCallback('elder_drugdealer:server:get_level', function(level) 
		result:resolve(level)  
    end)
    return Citizen.Await(result)
end

RegisterNetEvent('elder_drugdealer:client:refresh_level')
AddEventHandler('elder_drugdealer:client:refresh_level', function(gang, level)
	if getGang() == gang then
		if __G.DrugDealerZonesLevel ~= level then
			Helper.NotifySuccess('Gang Hood Level UP : ~y~'..level..'~s~')
		end
		__G.DrugDealerZonesLevel = level
	end
end)

function drawText3DTag(coords, text, color)
    local camCoords = GetGameplayCamCoord()
    local dist = #(coords - camCoords)
    local scale = 200 / (GetGameplayCamFov() * dist)
    SetTextColour(250, 250, 250, 250)
    SetTextScale(0.0, 0.4 * scale)
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


function GetColor(xp)
	if xp == Config.XpPerItem * 1 then
		return {r=255,g=0,b=0}
	elseif xp == Config.XpPerItem * 2 then
		return {r=255,g=255,b=0}
	elseif xp == Config.XpPerItem * 3 then
		return {r=0,g=255,b=0}
	elseif xp == Config.XpPerItem * 4 then
		return {r=0,g=191,b=255}
	else
		return {r=255,g=0,b=255}
	end
end

RegisterNetEvent('elder_drugdealer:client:drawXP')
AddEventHandler('elder_drugdealer:client:drawXP', function(xp)
	local timer = lib.timer(3000, function() end, true)

	CreateThread(function()
		while timer:getTimeLeft('ms') > 0 do
			Wait(1)
			local coords = GetEntityCoords(cache.ped)
			drawText3DTag(vector3(coords.x, coords.y+0.5, coords.z +0.48), Config.DrugDealerZonesLevels[__G.DrugDealerZonesLevel].label, {r=255,g=255,b=255})
			drawText3DTag(vector3(coords.x, coords.y+0.5, coords.z +0.4), "+"..tostring(xp), GetColor(xp))
		end
	end)
end)

function IsInGangHood()
    local gang = exports.elder_gangnpc:GetGang()
    local gangs = exports.elder_gangnpc:GetGangHoods()
    if not gangs[gang.name] then return true end
    for k,v in pairs(gangs) do 
        if GetDistanceBetweenCoords(GetEntityCoords(cache.ped), v.drugdealerlocation.coords, true) <= v.drugdealerlocation.radius then 
            return true
        end
    end
    return false
end