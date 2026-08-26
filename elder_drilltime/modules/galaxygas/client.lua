local gIsUsing = false
local gInProgress = false
local ItemCooldown = false

--GetResourceKvpString

local props = {
	chug_jug = {
		model = 'chug_jug',
		offset = vec3(0.0, 0, -0.30566311856812),
		rot = vec3(0.0, 0.0, -40),
        bone = 60309,
		sound = 'chugjug',
        dic = 'mp_player_intdrink',
        anim = 'loop_bottle',
        duration = 2500,
	},
	galaxy_gas = {
		model = 'galaxy_gas',
		offset = vec3(-0.00065065998421687, -0.063523202890832, -0.2253462321714),
		rot = vec3(0, 0, 0),
        bone = 60309,
		sound = 'gas',
        dic = 'mp_player_intdrink',
        anim = 'loop_bottle',
        duration = 2500,
	},
    blue_balloon = {
		model = 'blueballoon',
		offset = vec3(0.0, 0.0, 0.14),
		rot = vec3( 11.068666937055, 84.82872950947, 177.67471969297),
        bone = 60309,
		sound = 'sparrowballon',
        dic = 'mp_player_intdrink',
        anim = 'loop_bottle',
        duration = 2500,
	},
    red_balloon = {
		model = 'redballoon',
		offset = vec3(0.0, 0.0, 0.14),
		rot = vec3( 11.068666937055, 84.82872950947, 177.67471969297),
        bone = 60309,
		sound = 'sparrowballon',
        dic = 'mp_player_intdrink',
        anim = 'loop_bottle',
        duration = 2500,
	},
    smoke = {
        model = 'prop_cs_ciggy_01',
		offset = vec3(0.0, 0.0, 0.0),
		rot = vec3( 0.0, 0.0, 0.0),
        bone = 28422,
		sound = 'smoke',
        dic = 'amb@world_human_aa_smoke@male@idle_a',
        anim = 'idle_c',
        duration = 3500,
    }
}

RegisterCommand('gas', function()
	if gIsUsing then return end
	local menuOptions = {}  
    local prop_key = GetResourceKvpString('galaxy') or 'galaxy_gas'
    table.insert(menuOptions,{
		title = 'Chug Jug' .. (prop_key == 'chug_jug' and '✅' or ''), 
		onSelect = function()
			SetResourceKvp('galaxy', 'chug_jug')
		end
	})

	table.insert(menuOptions,{
		title = 'Galaxy Gas' .. (prop_key == 'galaxy_gas' and '✅' or ''),
		onSelect = function()
			SetResourceKvp('galaxy', 'galaxy_gas')
		end
	})

    table.insert(menuOptions,{
		title = 'Blue Balloon' .. (prop_key == 'blue_balloon' and '✅' or ''),
		onSelect = function()
			SetResourceKvp('galaxy', 'blue_balloon')
		end
	})

    table.insert(menuOptions,{
		title = 'Red Balloon' .. (prop_key == 'red_balloon' and '✅' or ''),
		onSelect = function()
			SetResourceKvp('galaxy', 'red_balloon')
		end
	})

    table.insert(menuOptions,{
		title = 'Smoke' .. (prop_key == 'smoke' and '✅' or ''),
		onSelect = function()
			SetResourceKvp('galaxy', 'smoke')
		end
	})
     
    lib.registerContext({
        id = 'galaxy_menu',
        title = 'Choose Galaxy Gas Prop',
        options = menuOptions,
    })
    lib.showContext('galaxy_menu')
end)


p_smoke_location = {
	20279,
}
p_smoke_particle = "exp_grd_bzgas_smoke"
p_smoke_particle_asset = "core" 

exports('galaxy_use', function(data, slot)
    if gIsUsing then
        return Notify('You are already using this', 'error')
    end 
    TriggerServerEvent('elder_drilltime:galaxygas:server:onUse', data, slot)
end)


RegisterNetEvent('elder_drilltime:galaxygas:client:onUse')
AddEventHandler('elder_drilltime:galaxygas:client:onUse', function()
	if not gIsUsing then
		local prop_key = GetResourceKvpString('galaxy')
		if not prop_key then prop_key = 'galaxy_gas' end
		local prop_name = props[prop_key].model
		local prop_offset = props[prop_key].offset
		local prop_rot = props[prop_key].rot
        local bone = props[prop_key].bone
		local sound = props[prop_key].sound
        local dic = props[prop_key].dic
        local anim = props[prop_key].anim
        local duration = props[prop_key].duration
		
		gIsUsing = true

		CreateThread(function()
			local x,y,z = table.unpack(GetEntityCoords(cache.ped))
			lib.requestModel(prop_name)
			local prop = CreateObject(GetHashKey(prop_name), x, y, z + 0.2, true, true, true)
			local boneIndex = GetPedBoneIndex(cache.ped, bone)
			AttachEntityToEntity(prop, cache.ped, boneIndex, prop_offset.x, prop_offset.y, prop_offset.z, prop_rot.x, prop_rot.y, prop_rot.z, true, true, false, true, 1, true)

			ESX.Streaming.RequestAnimDict(dic, function()
				TaskPlayAnim(cache.ped, dic, anim, 3.0, 1.0, -1, 49, 0, 0, 0, 0)
                PlayGalaxySound(sound)
				Wait(duration)
                TriggerServerEvent("elder_drilltime:galaxygas:server:c_eff_smokes", PedToNet(cache.ped))
                ClearPedSecondaryTask(cache.ped)
                TaskPlayAnim(cache.ped, dic, anim, 3.0, 1.0, -1, 49, 0, 0, 0, 0)
                PlayGalaxySound(sound)
                Wait(duration)
				ClearPedSecondaryTask(cache.ped)
				DeleteObject(prop)
				gIsUsing = false
				if not gInProgress then
                	StartEffect()
				end
			end)
		end)
	end
end)

StartEffect = function()
	gInProgress = true
    local timer = Config.GalaxyGas.SpeedTime
    CreateThread(function()
        while gInProgress and timer > 0 do
            Wait(1000)
            timer = timer - 1
        end
        gInProgress = false
        CreateThread(function()
            Wait(Config.GalaxyGas.Cooldown * 1000)
        end)
    end)
    CreateThread(function()
        while gInProgress do
            RestorePlayerStamina(PlayerId(), 100.0)
            SetPedMoveRateOverride(PlayerPedId(), 1.55)
            Wait(1)
        end
    end)
end

PlayGalaxySound = function(sound)
    CreateThread(function()
        local nearbyPlayers = lib.getNearbyPlayers(GetEntityCoords(cache.ped), 5.0, true)
        local players = {}
        for i = 1 , #nearbyPlayers, 1 do
            table.insert(players, GetPlayerServerId(nearbyPlayers[i].id))
        end
        TriggerServerEvent('elder_drilltime:galaxygas:server:play_sound', players, sound)
    end)
end


RegisterNetEvent('elder_drilltime:galaxygas:client:use_xpills')
AddEventHandler('elder_drilltime:galaxygas:client:use_xpills', function()
	if gIsUsing then
        return Notify('You cant use this now', 'error')
    end 
	TriggerServerEvent('elder_drilltime:galaxygas:server:onUseXpills')
end)

RegisterNetEvent('elder_drilltime:galaxygas:client:use_item')
AddEventHandler('elder_drilltime:galaxygas:client:use_item', function(item)
	if gIsUsing then
        return Notify('You cant use this now', 'error')
    end 
	if ItemCooldown then
		return Notify('Candy Speed cooldown', 'error')
	end
	TriggerServerEvent('elder_drilltime:galaxygas:server:onUseItem', item)
end)


RegisterNetEvent('elder_drilltime:galaxygas:client:onUseXpills')
AddEventHandler('elder_drilltime:galaxygas:client:onUseXpills', function()
	if not gIsUsing then
		gIsUsing = true
		CreateThread(function()
			if lib.progressBar({
				duration = 1750,
				label = 'Taking Mini Chug',
				useWhileDead = false,
				canCancel = false,
				anim = {
					dict = 'mp_suicide',
					clip = 'pill_fp'
				},
				}) then
				gIsUsing = false
				gInProgress = false
				Wait(1500)
				Notify('You have speed for 2 minutes!')
				if not gInProgress then
					StartEffect()
				end
			end
		end)
	end
end)

RegisterNetEvent("elder_drilltime:galaxygas:client:c_eff_smokes")
AddEventHandler("elder_drilltime:galaxygas:client:c_eff_smokes", function(c_ped)
	for _,bones in pairs(p_smoke_location) do
		if not c_ped or not NetworkDoesEntityExistWithNetworkId(c_ped) then
        return
    end

	local ped = NetToPed(c_ped)

    if ped == 0 or not DoesEntityExist(ped) or IsEntityDead(ped) then
        return
    end

				if ped ~= 0 and DoesEntityExist(ped) and not IsEntityDead(ped) then
			createdSmoke = UseParticleFxAssetNextCall(p_smoke_particle_asset)
			createdPart = StartParticleFxLoopedOnEntityBone(p_smoke_particle, ped, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, GetPedBoneIndex(ped, bones), 0.5, 0.0, 0.0, 0.0)
			Wait(4800)
			while DoesParticleFxLoopedExist(createdSmoke) do
				StopParticleFxLooped(createdSmoke, 1)
			    Wait(0)
			end
			while DoesParticleFxLoopedExist(createdPart) do
				StopParticleFxLooped(createdPart, 1)
			    Wait(0)
			end
			Wait(2800 * 3 )
			if not c_ped or not NetworkDoesEntityExistWithNetworkId(c_ped) then
        return
    end

	local ped = NetToPed(c_ped)

    if ped == 0 or not DoesEntityExist(ped) or IsEntityDead(ped) then
        return
    end

			if ped ~= 0 and DoesEntityExist(ped) then
				RemoveParticleFxFromEntity(ped)
			end
			break
		end
	end
end)

RegisterNetEvent('elder_drilltime:galaxygas:client:play_sound')
AddEventHandler('elder_drilltime:galaxygas:client:play_sound', function(sound)
    TriggerEvent('InteractSound_CL:PlayOnOne', sound, 1.0)
end)

RegisterNetEvent('elder_drilltime:galaxygas:client:onUseItem')
AddEventHandler('elder_drilltime:galaxygas:client:onUseItem', function()
	if not gIsUsing then
		gIsUsing = true
		CreateThread(function()
			if lib.progressBar({
				duration = 3000,
				label = 'Taking rare candy',
				useWhileDead = false,
				canCancel = false,
				anim = {
					dict = 'mp_suicide',
					clip = 'pill_fp'
				},
				}) then
				gInProgress = false
				gIsUsing = false
				Wait(1500)
				Notify('You have candy speed for 3 minutes!')
				if not gInProgress then
					StartSpeedEffect()
				end
			end
		end)
	end
end)

StartSpeedEffect = function()
	ItemCooldown = true
	gInProgress = true
    local timer = 3 * 60
    CreateThread(function()
        while gInProgress and timer > 0 do
            Wait(1000)
            timer = timer - 1
        end
        gInProgress = false
        CreateThread(function()
            Wait(60 * 1000)
			ItemCooldown = false
        end)
    end)
    CreateThread(function()
        while gInProgress do
            RestorePlayerStamina(PlayerId(), 100.0)
            SetPedMoveRateOverride(PlayerPedId(), 1.55)
            Wait(1)
        end
    end)
end



------------------------------------ Stamina --------------------------------

RegisterNetEvent('elder_drilltime:galaxygas:client:use_newdrugxll')
AddEventHandler('elder_drilltime:galaxygas:client:use_newdrugxll', function()
	StartStaminaEffect()
end)

StartStaminaEffect = function()
	RequestAnimDict("mp_suicide")
    while not HasAnimDictLoaded("mp_suicide") do
        Wait(10)
    end
    TaskPlayAnim(cache.ped, "mp_suicide", "pill_fp", 8.0, 8.0, -1, 50, 0, false, false, false)
    Wait(3000)
	ClearPedSecondaryTask(cache.ped)
	Notify('This drug gives you stamina & speed!')
	local in_progress = true
    local timer = 3.5 * 60
    CreateThread(function()
        while in_progress and timer > 0 do
            Wait(1000)
            timer = timer - 1
        end
        in_progress = false
    end)
    CreateThread(function()
        while in_progress do
            RestorePlayerStamina(PlayerId(), 100.0)
            SetPedMoveRateOverride(cache.ped, 1.55)
            Wait(1)
        end
    end)
end

RegisterNetEvent('elder_drilltime:galaxygas:client:use_gmrmolly')
AddEventHandler('elder_drilltime:galaxygas:client:use_gmrmolly', function(armor)
	RequestAnimDict("mp_suicide")
    while not HasAnimDictLoaded("mp_suicide") do
        Wait(10)
    end
    TaskPlayAnim(cache.ped, "mp_suicide", "pill_fp", 8.0, 8.0, -1, 50, 0, false, false, false)
    Wait(3000)
	ClearPedSecondaryTask(cache.ped)
	Notify(armor .. '% armor added')
	SetPedArmour(cache.ped, GetPedArmour(cache.ped) + armor)
end)