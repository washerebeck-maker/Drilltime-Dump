local CEventNetworkEntityDamageArgsIndex = {
    fatal = 6,
    weapon = 7
}
local PunshCounter = 0
local Active = false
local Timer = 0

RegisterNetEvent("ko:helpPlayer")
AddEventHandler("ko:helpPlayer", function(sender)
	if #(GetEntityCoords(GetPlayerPed(GetPlayerFromServerId(sender)))-GetEntityCoords(ko.ped)) < 10.0 then
		Active=false
		Timer=0
		SetPedToRagdoll(GetPlayerPed(-1), 100, 100, 0, 0, 0, 0)
		if KO_Config.blackOutScreen then DoScreenFadeIn(8000) end
	end
end)

function KnockoutPlayer(timer)
	local playerPed = GetPlayerPed(-1)
	Timer = timer
	Active=true
	SetEntityInvincible(playerPed, true)
	SetPedToRagdoll(playerPed, 6000, 6000, 0, 0, 0, 0)
	ShowNotification("~r~You were knocked out!")
	if KO_Config.blackOutScreen then DoScreenFadeOut(1000) end
	Citizen.CreateThread(function()
		while Active do
			Wait(5000)
			print(Timer)
			Timer=Timer-5
			if Timer <= 0 then
				if KO_Config.blackOutScreen then DoScreenFadeIn(10000) end
				Active = false
				SetEntityInvincible(playerPed, false)
			else
				SetPedToRagdoll(playerPed, 6000, 6000, 0, 0, 0, 0)
				ResetPedRagdollTimer(playerPed)
			end
		end
	end)
end

--[[ Citizen.CreateThread(function()
	local playerPed = GetPlayerPed(-1)
	SetEntityMaxHealth(playerPed, 200)
	while true do
		Wait(1)
		playerPed = GetPlayerPed(-1)

		if Active and not KO_Config.blackOutScreen then
			DisablePlayerFiring(playerPed, true)
		end

		if Active and KO_Config.dieAfterKnockout then
			-- Let player receive damage
		else
			if PunshCounter == 8 then
				KnockoutPlayer(KO_Config.knockoutLengthFist)
				PunshCounter = 0
			end
		end
		
	end
end) ]]

Citizen.CreateThread(function()
	local playerPed = GetPlayerPed(-1)
	SetEntityMaxHealth(playerPed, 200)
	while true do
		local sleep = 1000
		playerPed = GetPlayerPed(-1)
		if Active then
			sleep = 1
			DisablePlayerFiring(playerPed, true)
		end
		if PunshCounter == 8 then
			KnockoutPlayer(KO_Config.knockoutLengthFist)
			PunshCounter = 0
		end	
		Wait(sleep)
	end
end)

Citizen.CreateThread(function()
    while true do
    	N_0x4757f00bc6323cfe(GetHashKey("WEAPON_UNARMED"), 0.001)
    	Wait(5000)
    end
end)

function ShowNotification(text)
	SetNotificationTextEntry("STRING")
	AddTextComponentString(text)
	DrawNotification(false, false)
end

local function OnEntityDamage(args)
    local fatal = args[CEventNetworkEntityDamageArgsIndex.fatal]
    if fatal ~= 0 then return end
    local playerPed = PlayerPedId()
    local victim = args[1]
    if playerPed ~= victim then return end
    local weaponHash = args[CEventNetworkEntityDamageArgsIndex.weapon]
    if weaponHash ~= GetHashKey("WEAPON_UNARMED") then return end
	if Active == true then return end
    PunshCounter = PunshCounter + 1
    Citizen.Wait(100)
end

AddEventHandler('gameEventTriggered', function(event, args)
	if event == "CEventNetworkEntityDamage" then
        OnEntityDamage(args)
    end
end)