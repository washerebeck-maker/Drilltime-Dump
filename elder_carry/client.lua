local carryingBackInProgress = false
local insideUncarryZone = false
local cooldown = false

local function notify(description, notifyType)
	lib.notify({
		title = 'Carry',
		description = description,
		type = notifyType or 'inform',
		duration = 5000,
	})
end

local function inSafeZone()
	return exports.elder_safezones:InSafeZone()
end

local function isDead()
	return exports.esx_ambulancejob:IsPlayerDead()
end

function IsCarryingPlayer()
	return carryingBackInProgress
end

exports('IsCarryingPlayer', IsCarryingPlayer)

local function onUncarryZoneEnter()
	insideUncarryZone = true
	if carryingBackInProgress then
		ExecuteCommand('carry')
	end
end

local function onUncarryZoneExit()
	insideUncarryZone = false
end

CreateThread(function()
	lib.zones.poly({
		points = Config.uncarryZone.points,
		thickness = Config.uncarryZone.thickness,
		debug = Config.uncarryZone.debug,
		onEnter = onUncarryZoneEnter,
		onExit = onUncarryZoneExit,
	})
end)

local function clearCarryLocal()
	carryingBackInProgress = false
	local ped = PlayerPedId()
	ClearPedSecondaryTask(ped)
	DetachEntity(ped, true, false)
end

local function tryStartCarry()
	if isDead() then
		notify('You cannot use this when you dead.', 'error')
		return
	end
	if exports.JD_CommunityService:InCommunityService() then
		notify('You cannot use this in community service.', 'error')
		return
	end
	if insideUncarryZone and not exports.elder_drilltime:InsideKillHouse() then
		notify('You cannot use this in this location.', 'error')
		return
	end
	if inSafeZone() then
		notify('Carrying not allowed in safezones !', 'error')
		return
	end
	if cooldown then
		notify('Command on cooldown', 'error')
		return
	end

	local closestPlayer, closestPed = lib.getClosestPlayer(GetEntityCoords(PlayerPedId()), Config.carryRadius, false)
	if closestPlayer == nil or closestPed == nil then
		return
	end

	carryingBackInProgress = true
	cooldown = true
	TriggerEvent('carry:cooldown')

	TriggerServerEvent('carry:sync', GetPlayerServerId(closestPlayer))
end

local function tryStopCarry()
	clearCarryLocal()
	local closestPlayer = lib.getClosestPlayer(GetEntityCoords(PlayerPedId()), Config.carryRadius, false)
	if closestPlayer == nil then
		return
	end
	TriggerServerEvent('carry:stop', GetPlayerServerId(closestPlayer))
end

RegisterCommand('carry', function()
	if not carryingBackInProgress then
		tryStartCarry()
	else
		tryStopCarry()
	end
end, false)

RegisterNetEvent('carry:cooldown')
AddEventHandler('carry:cooldown', function()
	CreateThread(function()
		Wait(Config.cooldownMs)
		cooldown = false
	end)
end)

RegisterNetEvent('carry:syncTarget')
AddEventHandler('carry:syncTarget', function(carrierServerId)
	local playerPed = PlayerPedId()
	local targetPed = GetPlayerPed(GetPlayerFromServerId(carrierServerId))
	carryingBackInProgress = true

	RequestAnimDict(Config.carry.target.dict)
	while not HasAnimDictLoaded(Config.carry.target.dict) do
		Wait(10)
	end

	AttachEntityToEntity(
		playerPed,
		targetPed,
		0,
		Config.carry.attach.distans2,
		Config.carry.attach.distans,
		Config.carry.attach.height,
		0.5,
		0.5,
		Config.carry.attach.spin,
		false,
		false,
		false,
		false,
		2,
		false
	)

	TaskPlayAnim(
		playerPed,
		Config.carry.target.dict,
		Config.carry.target.anim,
		8.0,
		-8.0,
		Config.carry.duration,
		Config.carry.target.controlFlag,
		0,
		false,
		false,
		false
	)
end)

RegisterNetEvent('carry:syncMe')
AddEventHandler('carry:syncMe', function()
	local playerPed = PlayerPedId()

	RequestAnimDict(Config.carry.carrier.dict)
	while not HasAnimDictLoaded(Config.carry.carrier.dict) do
		Wait(10)
	end

	Wait(500)

	TaskPlayAnim(
		playerPed,
		Config.carry.carrier.dict,
		Config.carry.carrier.anim,
		8.0,
		-8.0,
		Config.carry.duration,
		Config.carry.carrier.controlFlag,
		0,
		false,
		false,
		false
	)

	Wait(Config.carry.duration)
end)

RegisterNetEvent('carry:cl_stop')
AddEventHandler('carry:cl_stop', function()
	clearCarryLocal()
end)



local handsupDict = 'missminuteman_1ig_2'
local handsupAnimEnter = 'handsup_enter'
local handsupReady = false
local handsupActive = false

CreateThread(function()
	RequestAnimDict(handsupDict)
	while not HasAnimDictLoaded(handsupDict) do
		Wait(100)
	end
	handsupReady = true
end)

RegisterCommand('handsup', function()
	if not handsupReady then
		return
	end
	local ped = PlayerPedId()
	if not handsupActive then
		TaskPlayAnim(ped, handsupDict, handsupAnimEnter, 8.0, 8.0, -1, 50, 0, false, false, false)
		handsupActive = true
	else
		handsupActive = false
		ClearPedTasks(ped)
	end
end)

RegisterKeyMapping('handsup', 'Hands Up', 'keyboard', 'X')
