
ESX = exports['es_extended']:getSharedObject()

local PlayerJob = {}
local Cooldown = false
local Blips = {}
local BossDealerBusy = false
local HoodDealerBusy = false
local CheckerHood = true
local CheckerBoss = true

local DrugLevel = nil

RegisterNetEvent('elder_drugs:client:UpdateDrugLevel')
AddEventHandler('elder_drugs:client:UpdateDrugLevel', function(level)
    DrugLevel = level
end)

exports('getDrugLevel', function()
    return DrugLevel
end)

Citizen.CreateThread(function()
	
	while ESX.GetPlayerData().job == nil do
		Citizen.Wait(10)
	end

	PlayerJob = ESX.GetPlayerData().job

	ESX.Streaming.RequestStreamedTextureDict('WEB_MORGANCHESTER')

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

	ESX.Game.MakeEntityFaceEntity = function(entity1, entity2)
		local p1 = GetEntityCoords(entity1, true)
		local p2 = GetEntityCoords(entity2, true)
		local dx = p2.x - p1.x
		local dy = p2.y - p1.y
		local heading = GetHeadingFromVector_2d(dx, dy)
		SetEntityHeading( entity1, heading )
	end
end)

CreateThread(function()
    if ESX.IsPlayerLoaded() then
        ESX.TriggerServerCallback('elder_drugs:get_level', function(level)
            DrugLevel = level
	    end)
    end
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)  
    PlayerJob = xPlayer.job or {}
    ESX.TriggerServerCallback('elder_drugs:get_level', function(level)
        DrugLevel = level
	end)
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)  
    PlayerJob = job or {}
end)


--[[ RegisterCommand('dealer', function()
    if not Cooldown then
		Cooldown = true
		for i = 1, Config.maxCustomerCout do
			local next_customer = Start()
			if not next_customer then
				TriggerEvent('elder_drugs:start_cooldown')
				return
			end
		end
		TriggerEvent('elder_drugs:start_cooldown')
	else
		ESX.ShowAdvancedNotification(Config.notify.title, '', Config.notify.cooldown, 'WEB_MORGANCHESTER', 1)
	end
end) ]]

RegisterCommand('bossdealer', function()
    if BossDealerBusy == false then
		ESX.TriggerServerCallback('elder_drugs:get_level', function(level)
			if level >= Config.bossDealerLevel then
				StartBossDealer()
			else
				ESX.ShowAdvancedNotification(Config.notify.title, '', 'You should advance to level ~b~ ' .. Config.bossDealerLevel, 'WEB_MORGANCHESTER', 1)
			end
		end)
	else
		ESX.ShowAdvancedNotification(Config.notify.title, '', '~r~There is a dealer waiting for you !~s~', 'WEB_MORGANCHESTER', 1)
	end  
end)

RegisterCommand('hooddealer', function()
    if HoodDealerBusy == false then
		HoodDealerBusy = true
		ESX.TriggerServerCallback('elder_drugs:get_level', function(level)
			if level >= Config.hoodDealerLevel then
				StartHoodDealer()
			else
				ESX.ShowAdvancedNotification(Config.notify.title, '', 'You should advance to level ~b~ ' .. Config.hoodDealerLevel, 'WEB_MORGANCHESTER', 1)
				HoodDealerBusy = false
			end
		end)
	else
		ESX.ShowAdvancedNotification(Config.notify.title, '', '~r~There is a dealer waiting for you !~s~', 'WEB_MORGANCHESTER', 1)
	end  
end)

RegisterNetEvent('elder_drugs:start_cooldown')
AddEventHandler('elder_drugs:start_cooldown', function()
	CreateThread(function()
		while true do
			Wait(Config.cooldown * 1000)
			Cooldown = false
			break
		end
	end)
end)


RegisterNetEvent('elder_drugs:notify_cops')
AddEventHandler('elder_drugs:notify_cops', function(coords)	
	if PlayerJob ~= nil and PlayerJob.name == 'police' then
		street = GetStreetNameAtCoord(coords.x, coords.y, coords.z)
		street2 = GetStreetNameFromHashKey(street)
		ESX.ShowAdvancedNotification(Config.notify.police_notify_title, Config.notify.police_notify_subtitle, street2, "CHAR_CALL911", 1)
		PlaySoundFrontend(-1, "Bomb_Disarmed", "GTAO_Speed_Convoy_Soundset", 0)

		blip = AddBlipForCoord(coords)
		SetBlipSprite(blip,  403)
		SetBlipColour(blip,  1)
		SetBlipAlpha(blip, 250)
		SetBlipScale(blip, 1.2)
		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString('# Sprzedaz narkotykow')
		EndTextCommandSetBlipName(blip)
		table.insert(Blips, blip)
		Wait(50000)
		for i in pairs(Blips) do
			RemoveBlip(Blips[i])
			Blips[i] = nil
		end
	end
end)

function Start()
	print(GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), Config.cityPoint, true))
	if Config.cityPoint ~= false and GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), Config.cityPoint, true) < 2000.0 then
		ESX.ShowAdvancedNotification(Config.notify.title, '', Config.notify.toofar, 'WEB_MORGANCHESTER', 1)
		return false
	end

	local cops_multiplier = 1

	local item = nil
	
	ESX.TriggerServerCallback('elder_drugs:check_drugs', function(result)
		item = result
	end, cops_multiplier)

	Wait(1000)

	if item then
		return StartDeal(item)	
	else
		ESX.ShowAdvancedNotification(Config.notify.title, '', Config.notify.nodrugs, 'WEB_MORGANCHESTER', 1)
		return false
	end
end


function StartDeal(item)
	local playerPed = PlayerPedId()
	TaskStartScenarioInPlace(playerPed, "WORLD_HUMAN_STAND_MOBILE", 0, true)
	ESX.ShowAdvancedNotification(Config.notify.title, '', Config.notify.searching .. item.label, 'WEB_MORGANCHESTER', 1)
	Wait(math.random(5000, 10000))
	ClearPedTasks(playerPed) 
	return StartSell(item)	
end

function StartSell(item)
	local time_to_finish_deal = 12000
	local playerPed = PlayerPedId()
	local ToggleKey = Config.ToogleKeys[math.random(1,#Config.ToogleKeys)]
	local ped_hash = GetHashKey(Config.pedlist[math.random(1, #Config.pedlist)])
	ESX.Streaming.RequestModel(ped_hash)
	local ped_coords = GetOffsetFromEntityInWorldCoords(playerPed, 0.0, 50.0, 5.0)
	local retval, z = GetGroundZFor_3dCoord(ped_coords.x, ped_coords.y, ped_coords.z, 0)
	if retval == false then
		ESX.ShowAdvancedNotification(Config.notify.title, '', Config.notify.abort, 'WEB_MORGANCHESTER', 1)
		ClearPedTasks(playerPed)
		return true
	end

	local ped_zone = GetLabelText(GetNameOfZone(ped_coords))

	local ped = CreatePed(5, ped_hash, ped_coords.x, ped_coords.y, z, 0.0, true, true)
	PlaceObjectOnGroundProperly(ped)
	SetEntityAsMissionEntity(ped)
	if IsEntityDead(ped) or GetEntityCoords(ped) == vector3(0.0, 0.0, 0.0) then
		ESX.ShowAdvancedNotification(Config.notify.title, '', Config.notify.notfound, 'WEB_MORGANCHESTER', 1)
		SetPedAsNoLongerNeeded(ped)
		DeleteEntity(ped)
		ped = nil
        return true
	end

	ESX.ShowAdvancedNotification(Config.notify.title, Config.notify.approach, Config.notify.found .. ped_zone, 'WEB_MORGANCHESTER', 1)
	TaskGoToEntity(ped, playerPed, 60000, 4.0, 2.0, 0, 0)

	local canSell = true
	while ped ~= nil and ped ~= 0 and not IsEntityDead(ped) and time_to_finish_deal > 0 do
		Wait(5)
		time_to_finish_deal = time_to_finish_deal - 5
		local playerPed = PlayerPedId()
		ped_coords = GetEntityCoords(ped)
		ESX.Game.Utils.DrawText3D(ped_coords, (Config.notify.client):format(item.count, item.label), 0.5)
		distance = Vdist2(GetEntityCoords(playerPed), ped_coords)
		SetBlockingOfNonTemporaryEvents(ped, true)
		if distance < 2.0 then
			ESX.ShowHelpNotification('Press ~b~['..ToggleKey.key..']~s~ to ~y~sell')
			if IsControlJustPressed(0, ToggleKey.value) and canSell then
				canSell = false
				reject = math.random(1, 15)
				if reject <= 3 then
					ESX.ShowAdvancedNotification(Config.notify.title, '', Config.notify.reject, 'WEB_MORGANCHESTER', 1)
					PlayAmbientSpeech1(ped, 'GENERIC_HI', 'SPEECH_PARAMS_STANDARD')
					local playerCoords = GetEntityCoords(playerPed)
					TriggerServerEvent('elder_drugs:notify_cops', playerCoords)
					if Config.npcFightOnReject then
						TaskCombatPed(ped, playerPed, 0, 16)
					end
					Wait(5000)
					SetPedAsNoLongerNeeded(ped)
					DeleteEntity(ped)
					ped = nil
					return false
				end
				if IsPedInAnyVehicle(playerPed, false) then
					ESX.ShowAdvancedNotification(Config.notify.title, Config.notify.vehicle, '', 'WEB_MORGANCHESTER', 1)
					SetPedAsNoLongerNeeded(ped)
					DeleteEntity(ped)
					ped = nil
					return false
				end
				ESX.Game.MakeEntityFaceEntity(playerPed, ped)
				ESX.Game.MakeEntityFaceEntity(ped, playerPed)

				local paymentCheck = nil
				ESX.TriggerServerCallback('elder_drugs:server:pay', function(result)
					paymentCheck = result
				end, item)

				Wait(1000)

				if paymentCheck then
					SetPedTalk(ped)
					PlayAmbientSpeech1(ped, 'GENERIC_HI', 'SPEECH_PARAMS_STANDARD')
					obj = CreateObject(GetHashKey('prop_weed_bottle'), 0, 0, 0, true)
					AttachEntityToEntity(obj, playerPed, GetPedBoneIndex(playerPed,  57005), 0.13, 0.02, 0.0, -90.0, 0, 0, 1, false, 0, 1, 0, 1)
					obj2 = CreateObject(GetHashKey('hei_prop_heist_cash_pile'), 0, 0, 0, true)
					AttachEntityToEntity(obj2, ped, GetPedBoneIndex(ped,  57005), 0.13, 0.02, 0.0, -90.0, 0, 0, 1, false, 0, 1, 0, 1)
					ESX.PlayAnim('mp_common', 'givetake1_a', 8.0, -1, 0)
					ESX.PlayAnimOnPed(ped, 'mp_common', 'givetake1_a', 8.0, -1, 0)
					Wait(1000)
					AttachEntityToEntity(obj2, playerPed, GetPedBoneIndex(playerPed,  57005), 0.13, 0.02, 0.0, -90.0, 0, 0, 1, false, 0, 1, 0, 1)
					AttachEntityToEntity(obj, ped, GetPedBoneIndex(ped,  57005), 0.13, 0.02, 0.0, -90.0, 0, 0, 1, false, 0, 1, 0, 1)
					Wait(1000)
					DeleteEntity(obj)
					DeleteEntity(obj2)
					PlayAmbientSpeech1(ped, 'GENERIC_THANKS', 'SPEECH_PARAMS_STANDARD')
					ESX.ShowAdvancedNotification(Config.notify.title, '', (Config.notify.sold):format(item.count, item.label, item.price), 'WEB_MORGANCHESTER', 1)
					Wait(5000)
					SetPedAsNoLongerNeeded(ped)
					DeleteEntity(ped)
					ped = nil
					return true
				else
					SetPedTalk(ped)
					ESX.ShowAdvancedNotification(Config.notify.title, '', "yo mom is a hoe! give me your cash, bitch!", 'WEB_MORGANCHESTER', 1)
					PlayAmbientSpeech1(ped, 'GENERIC_INSULT_HIGH', 'SPEECH_PARAMS_FORCE_NORMAL')
					ESX.PlayAnimOnPed(ped, 'anim@mp_player_intupperfinger', 'idle_a_fp', 8.0, -1, 0)
					--GiveWeaponToPed(ped, GetHashKey('weapon_knife'),1, false ,true)
					--TaskCombatPed(ped, playerPed, 0, 16)
					--FreezeEntityPosition(playerPed, true)
					Wait(5000)
					SetPedAsNoLongerNeeded(ped)
					DeleteEntity(ped)
					ped = nil
					--FreezeEntityPosition(playerPed, false)
					--SetEntityHealth(playerPed,0)
					--TriggerServerEvent('elder_drugs:steal')
					--ESX.ShowAdvancedNotification(Config.notify.title, '', "Custy, Took your money !", 'WEB_MORGANCHESTER', 1)
					return false
				end
				
			end
		end
	end
	if ped ~= nil and ped ~= 0 and IsEntityDead(ped) then
		ESX.ShowAdvancedNotification(Config.notify.title, '', "You customer get killed ! Is that you ASSHOLE !", 'WEB_MORGANCHESTER', 1)			
		Wait(5000)
		SetPedAsNoLongerNeeded(ped)
		DeleteEntity(ped)
		ped = nil
		return false
	elseif time_to_finish_deal == 0 then
		ESX.ShowAdvancedNotification(Config.notify.title, '', "Customer was waiting too long for you !", 'WEB_MORGANCHESTER', 1)	
		SetPedAsNoLongerNeeded(ped)
		DeleteEntity(ped)
		ped = nil
		return false
	end
end

--[[ function GetCopsMultiplier()
	local cops = 0
	ESX.TriggerServerCallback('elder_drugs:get_police_count', function(_cops)
		cops = _cops
	end)
	Wait(500)

	if cops == 3 then
		return 1.10
	elseif cops == 4 then
		return 1.15
	elseif cops == 5 then
		return 1.20
	elseif cops == 6 then
		return 1.25
	elseif cops >= 7 then
		return 1.30
	else
		return 1
	end
end ]]

function StartBossDealer()
	local playerPed = PlayerPedId()
	local coords = Config.locations[math.random(1,#Config.locations)].coords
	local zone = GetLabelText(GetNameOfZone(coords))
	ESX.ShowAdvancedNotification(Config.notify.title, '', "Hey Boss, Meet me at ~g~" .. zone .. "~s~ in 5 minutes !", 'WEB_MORGANCHESTER', 1)	
	
	--Ped
	local ped_hash = GetHashKey(Config.pedlist[math.random(1, #Config.pedlist)])
	ESX.Streaming.RequestModel(ped_hash)
	local ped = CreatePed(5, ped_hash, coords.x, coords.y, coords.z-1, coords.w, false, true)
	PlaceObjectOnGroundProperly(ped)
	TaskStartScenarioInPlace(ped, "WORLD_HUMAN_DRUG_DEALER_HARD", 0, true)
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)

	local item = {}
	item.name =  Config.drugsDealer[math.random(1,#Config.drugsDealer)]
	item.count = math.random(100,250)

	--Blip
	local blip = AddBlipForCoord(coords)
	SetBlipSprite(blip,  51)
	SetBlipColour(blip,  5)
	SetBlipAlpha(blip, 250)
	SetBlipScale(blip, 1.2)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString('Dealer')
	EndTextCommandSetBlipName(blip)

	BossDealerBusy = true

	while BossDealerBusy do
		Wait(1)
		ESX.Game.Utils.DrawText3D(coords, (Config.notify.dealer):format(item.count, GetLabel(item.name)), 0.5)
		distance = Vdist2(GetEntityCoords(playerPed), coords)
		if distance < 2.0 then
			ESX.ShowHelpNotification('Press ~b~[E]~s~ to give drugs')
			if IsControlJustPressed(0, 38) and CheckerBoss == true then
				CheckerBoss = false
				ESX.TriggerServerCallback('elder_drugs:server:boss_dealer', function(result)
					if result == true then
						BossDealerBusy = false
						ESX.ShowAdvancedNotification(Config.notify.title, '', "Got it ! Thank you Boss !", 'WEB_MORGANCHESTER', 1)
					else
						CheckerBoss = true
						ESX.ShowAdvancedNotification(Config.notify.title, '', "You dont have needed drugs !", 'WEB_MORGANCHESTER', 1)
					end
				end, item)
			end
		end
	end
	CheckerBoss = true
	RemoveBlip(blip)
	Wait(10000)
	SetPedAsNoLongerNeeded(ped)
	DeleteEntity(ped)
end


function StartHoodDealer()
	local playerPed = PlayerPedId()
	local item = nil
	local cops_multiplier = 1
	ESX.TriggerServerCallback('elder_drugs:check_drugs', function(result)
		item = result
	end, cops_multiplier)

	Wait(1000)

	if item then
		local coords = Config.locations[math.random(1,#Config.locations)].coords
		local zone = GetLabelText(GetNameOfZone(coords))
		ESX.ShowAdvancedNotification(Config.notify.title, '', "Hey Hood, Meet me at ~g~" .. zone .. "~s~ in 5 minutes !", 'WEB_MORGANCHESTER', 1)	
		
		--Ped
		local ped_hash = GetHashKey(Config.pedlist[math.random(1, #Config.pedlist)])
		ESX.Streaming.RequestModel(ped_hash)
		local ped = CreatePed(5, ped_hash, coords.x, coords.y, coords.z-1, coords.w, false, true)
		PlaceObjectOnGroundProperly(ped)
		TaskStartScenarioInPlace(ped, "WORLD_HUMAN_DRUG_DEALER_HARD", 0, true)
		FreezeEntityPosition(ped, true)
		SetEntityInvincible(ped, true)
		SetBlockingOfNonTemporaryEvents(ped, true)
		--Blip
		local blip = AddBlipForCoord(coords)
		SetBlipSprite(blip,  51)
		SetBlipColour(blip,  5)
		SetBlipAlpha(blip, 250)
		SetBlipScale(blip, 1.2)
		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString('Dealer')
		EndTextCommandSetBlipName(blip)

		while HoodDealerBusy do
			Wait(1)
			ESX.Game.Utils.DrawText3D(coords, (Config.notify.hood):format(item.count, GetLabel(item.name)), 0.5)
			distance = Vdist2(GetEntityCoords(playerPed), coords)
			if distance < 2.0 then
				ESX.ShowHelpNotification('Press ~b~[E]~s~ to give drugs')
				if IsControlJustPressed(0, 38) then
					if CheckerHood == true then 
						CheckerHood = false
						ESX.TriggerServerCallback('elder_drugs:server:hood_dealer', function(result)
							if result == true then
								HoodDealerBusy = false
								ESX.ShowAdvancedNotification(Config.notify.title, '', "Got it ! Thank you cuh !", 'WEB_MORGANCHESTER', 1)
							else
								ESX.ShowAdvancedNotification(Config.notify.title, '', "You dont have needed drugs !", 'WEB_MORGANCHESTER', 1)
								RemoveBlip(blip)
								Wait(10000)
								SetPedAsNoLongerNeeded(ped)
								DeleteEntity(ped)
								HoodDealerBusy = false
								return
								
							end
						end, item)
					else
						ESX.ShowNotification("~r~ Stop cheating bro ! ~s~")
					end
				end
			end
		end
		CheckerHood = true
		RemoveBlip(blip)
		Wait(10000)
		SetPedAsNoLongerNeeded(ped)
		DeleteEntity(ped)
	else
		ESX.ShowAdvancedNotification(Config.notify.title, '', Config.notify.nodrugs, 'WEB_MORGANCHESTER', 1)
		HoodDealerBusy = false
		return
	end
end


--QUESTS

-- local QuestNPC = nil
-- local InQuest = false
-- local CurrentQuest = nil
-- local CurrentBlip = nil


-- Citizen.CreateThread(function()
	-- local ped_hash = GetHashKey(Quests.NPC.model)
	-- ESX.Streaming.RequestModel(ped_hash)
	-- QuestNPC = CreatePed(5, ped_hash, Quests.NPC.coords.x, Quests.NPC.coords.y, Quests.NPC.coords.z-1, Quests.NPC.heading, false, true)
	-- PlaceObjectOnGroundProperly(QuestNPC)
	-- TaskStartScenarioInPlace(QuestNPC, "WORLD_HUMAN_DRUG_DEALER_HARD", 0, true)
    -- FreezeEntityPosition(QuestNPC, true)
    -- SetEntityInvincible(QuestNPC, true)
    -- SetBlockingOfNonTemporaryEvents(QuestNPC, true)	

	-- local blip = AddBlipForCoord(Quests.NPC.coords)
	-- SetBlipSprite(blip,  66)
	-- SetBlipColour(blip,  1)
	-- SetBlipAlpha(blip, 250)
	-- SetBlipScale(blip, 1.2)
	-- SetBlipAsShortRange(blip, true)
	-- BeginTextCommandSetBlipName("STRING")
	-- AddTextComponentString('Drilltime Quests')
	-- EndTextCommandSetBlipName(blip)
-- end)

-- AddEventHandler('onResourceStop', function(resourceName)
	-- if (GetCurrentResourceName() == resourceName) then
		-- SetPedAsNoLongerNeeded(QuestNPC)
	  	-- DeleteEntity(QuestNPC)
	-- end
-- end)


-- Citizen.CreateThread(function()
	-- local sleep = 1
	-- while true do
		-- local playerPed = PlayerPedId()
		-- local distance = GetDistanceBetweenCoords(GetEntityCoords(playerPed), Quests.NPC.coords, true)
		-- if distance < 50 then
			-- sleep = 1
			-- ESX.Game.Utils.DrawText3D(Quests.NPC.coords, "Drilltime ~b~Quests~s~" , 1.0)
			-- if distance < 2.0 then
				-- if InQuest == false then
					-- ESX.ShowHelpNotification('Press ~INPUT_CONTEXT~ to start quest.')
				-- else
					-- ESX.ShowHelpNotification('Press ~INPUT_CONTEXT~ to continue current quest.')
				-- end
				-- if IsControlJustPressed(0, 38) then
					-- ESX.TriggerServerCallback('elder_drugs:get_level', function(level)
						-- if level >= Quests.Level then
							-- ProcessQuest()
						-- else
							-- ESX.ShowNotification('You should advance to level ~b~ ' .. Quests.Level )
						-- end
					-- end)		
				-- end
			-- end
		-- else
			-- sleep = 1000
		-- end
		-- Wait(sleep)
	-- end
-- end)

-- function ProcessQuest()
	-- if InQuest == false then
		-- InQuest = true
		-- CurrentQuest = math.random(1, #Quests.Quests)
		-- CreateBlip()
		-- NPCMessage()
	-- elseif CurrentQuest ~= nil then
		-- ESX.TriggerServerCallback('elder_drugs:server:check_quest', function(done)
			-- if done then
				-- ESX.ShowNotification('You finished the quest , thank you !')
				-- ESX.ShowNotification('Here is your reward !')
				-- ESX.ShowNotification('You got ~g~'..Quests.Quests[CurrentQuest].reward..'~s~ cash !')
				-- EndQuest()
			-- else
				-- NPCMessage()
			-- end
		-- end, Quests.Quests[CurrentQuest])
	-- end
-- end



-- function EndQuest()
	-- InQuest = false
	-- Wait(1000)
	-- RemoveBlip(CurrentBlip)
	-- CurrentBlip = nil
	-- CurrentQuest = nil
-- end


-- function CreateBlip()
	-- CurrentBlip = AddBlipForCoord(Quests.Quests[CurrentQuest].coords)
	-- SetBlipSprite(CurrentBlip,  66)
	-- SetBlipColour(CurrentBlip,  5)
	-- SetBlipAlpha(CurrentBlip, 250)
	-- SetBlipScale(CurrentBlip, 1.0)
	-- BeginTextCommandSetBlipName("STRING")
	-- AddTextComponentString('Quest')
	-- EndTextCommandSetBlipName(CurrentBlip)
-- end

-- function NPCMessage()
	-- ESX.ShowNotification("I need ~b~"..Quests.Quests[CurrentQuest].count.."~s~ ~g~".. GetLabel(Quests.Quests[CurrentQuest].item))
-- end

--[[ function GetLabel(_item)
	for item, data in pairs(exports.ox_inventory:Items()) do
		if item == _item then return data.label else return _item end
	end
end ]]

function GetLabel(_item)
	local item  = exports.ox_inventory:Items(_item)
	return item and item.label or _item
end

--############################################################### CAYO DRUG NPC ########################################


local DrugNPC = nil
local CurrentNPCCoords = nil

AddEventHandler('onResourceStop', function(name)
    if name ~= cache.resource then return end
    DeleteEntity(DrugNPC)
	DrugNPC = nil
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(player)
    CurrentNPCCoords = GetPedCoords()
end)

CreateThread(function()
    if ESX.IsPlayerLoaded() then
        CurrentNPCCoords = GetPedCoords()
    end
end)

GetPedCoords = function()
    local result = promise:new()
    ESX.TriggerServerCallback('elder_drugs:server:daily_drugs_get_coords', function(data) 
		result:resolve(data)  
    end, plate)
    return Citizen.Await(result)
end


Citizen.CreateThread(function()
	while not CurrentNPCCoords do Wait(100) end
	local ped_hash = GetHashKey(DrugsConfig.NPC.ped)
	ESX.Streaming.RequestModel(ped_hash)
	DrugNPC = CreatePed(5, ped_hash, CurrentNPCCoords.x,CurrentNPCCoords.y, CurrentNPCCoords.z-1, CurrentNPCCoords.w, false, true)
	PlaceObjectOnGroundProperly(DrugNPC)
	TaskStartScenarioInPlace(DrugNPC, "WORLD_HUMAN_DRUG_DEALER_HARD", 0, true)
    FreezeEntityPosition(DrugNPC, true)
    SetEntityInvincible(DrugNPC, true)
    SetBlockingOfNonTemporaryEvents(DrugNPC, true)	
end)


Citizen.CreateThread(function()
    local wait
	while not CurrentNPCCoords do Wait(100) end
    while true do
        local ped = PlayerPedId()
        local ped_coords = GetEntityCoords(ped)
        if GetDistanceBetweenCoords(ped_coords, vector3(CurrentNPCCoords.x,CurrentNPCCoords.y,CurrentNPCCoords.z),true) <= 1.5 then
            wait = 1
            ESX.ShowHelpNotification('Press ~INPUT_CONTEXT~ to open ~y~daily drugs~s~')
            if IsControlJustReleased(0, 38) then
                ESX.TriggerServerCallback('elder_drugs:server:daily_drugs_get', function(item, price, count1, count2)
					OpenDailyDrugsMenu(item, price, count1, count2)
				end)
            end
        else
            wait = 1000
        end
        Citizen.Wait(wait)
    end
end)

function OpenDailyDrugsMenu(item, price, count1, count2)
	local Options = {}
   
    Options[#Options + 1] = 
    {
        title = GetLabel(item) .. ' - X' .. count1 .. ' - $' .. ESX.Math.GroupDigits(price),
        description = '',
        icon = 'fa-cannabis',
        iconColor = 'green',
        arrow = true,
        event = 'elder_drugs:client:daily_drugs_buy',
		args = {item = item, price = price, level = 0}
    }

	Options[#Options + 1] = 
    {
        title = GetLabel(item) .. ' - X' .. count2 .. ' - $' .. ESX.Math.GroupDigits(price),
        description = '',
        icon = 'fa-cannabis',
        iconColor = 'red',
        arrow = true,
        event = 'elder_drugs:client:daily_drugs_buy',
		args = {item = item, price = price, level = 1000}
    }
		
	lib.registerContext({
		id = 'daily_drugs_menu',
		title = 'Drilltime Daily Drugs',
		options = Options
	})
	lib.showContext('daily_drugs_menu')
end


RegisterNetEvent('elder_drugs:client:daily_drugs_buy')
AddEventHandler('elder_drugs:client:daily_drugs_buy', function(args)
	TriggerServerEvent('elder_drugs:server:daily_drugs_buy', args)
end)	