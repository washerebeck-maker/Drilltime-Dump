local IsRunningWorkaround = false
function StartWorkaroundTask()
	if IsRunningWorkaround then return end
	local timer = 0
	local playerPed = PlayerPedId()
	IsRunningWorkaround = true
	while timer < 100 do
		Citizen.Wait(0)
		timer = timer + 1
		local vehicle = GetVehiclePedIsTryingToEnter(playerPed)
		if DoesEntityExist(vehicle) then
			local lockStatus = GetVehicleDoorLockStatus(vehicle)
			if lockStatus == 4 then
				ClearPedTasks(playerPed)
			end
		end
	end
	IsRunningWorkaround = false
end

function ToggleVehicleLock()
    local playerPed = PlayerPedId()
	local coords = GetEntityCoords(playerPed)
	local vehicle
	Citizen.CreateThread(function()
		StartWorkaroundTask()
	end)
	if IsPedInAnyVehicle(playerPed, false) then
		vehicle = GetVehiclePedIsIn(playerPed, false)
	else
		vehicle = GetClosestVehicle(coords, 8.0, 0, 71)
	end
	if not DoesEntityExist(vehicle) then return end
	ESX.TriggerServerCallback('esx_drilltime:car_lock:server:is_owner', function(is_owner)
		if is_owner then
			local lockStatus = GetVehicleDoorLockStatus(vehicle)
			if lockStatus == 1 then -- unlocked
				lockAnimation()
				SetVehicleLights(vehicle, 2)
                Wait(300)
                SetVehicleLights(vehicle, 0)
				Wait(300)
				StartVehicleHorn (vehicle, 500, "NORMAL", -1)
				PlayVehicleDoorCloseSound(vehicle, 1)
				SetVehicleDoorsLocked(vehicle, 2)
				Citizen.Wait(450)
				PlaySoundFrontend(-1, 'Hack_Success', 'DLC_HEIST_BIOLAB_PREP_HACKING_SOUNDS', 0)
				ESX.ShowNotification('~r~Vehicle Locked 🔒~s~')
			elseif lockStatus == 2 then -- locked
				lockAnimation()
                SetVehicleLights(vehicle, 2)
                Wait(300)
                SetVehicleLights(vehicle, 0)
				Wait(300)
				StartVehicleHorn (vehicle, 500, "NORMAL", -1)
				PlayVehicleDoorOpenSound(vehicle, 0)
				SetVehicleDoorsLocked(vehicle, 1)
				Citizen.Wait(450)
				PlaySoundFrontend(-1, 'Hack_Success', 'DLC_HEIST_BIOLAB_PREP_HACKING_SOUNDS', 0)
				ESX.ShowNotification('~g~Vehicle Unlocked 🔓~s~')
			end
		end

	end, ESX.Math.Trim(GetVehicleNumberPlateText(vehicle)))
end

function lockAnimation()
    local playerPed = PlayerPedId()
    RequestAnimDict("anim@heists@keycard@")
    while not HasAnimDictLoaded("anim@heists@keycard@") do
        Wait(0)
    end
    TaskPlayAnim(playerPed, "anim@heists@keycard@", "exit", 8.0, 1.0, -1, 16, 0, 0, 0, 0)
    Wait(700)
    ClearPedTasks(playerPed)
end

RegisterCommand('car_lock', function()
    if IsInputDisabled(0) then
        ToggleVehicleLock()
    end
end)

RegisterKeyMapping('car_lock', 'Lock/Unlock Vehicle', 'keyboard', 'U')

