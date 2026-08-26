Citizen.CreateThread(function()
    while true do
        local sleep = 5000
        local ped_coords = GetEntityCoords(PlayerPedId())

        for k, v in pairs(Config.Clutch.Locations) do
            local distance = GetDistanceBetweenCoords(ped_coords, v.coords.x, v.coords.y, v.coords.z, true)

            if distance <= 15 then
                sleep = 1
                if distance <= 10 then
                    DrawText3D(v.coords.x, v.coords.y, v.coords.z, 'Press [E] to get physical therapy  $'.. Config.Clutch.Price)
                    DrawMarker(27, v.coords.x, v.coords.y, v.coords.z-0.9, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 1.0, 1.0, 1.0, 8, 158, 231, 100, false, true, 2, false, false, false, false)
                    if distance <= 1.5 then
                        if IsControlJustPressed(0, 38) then
                            ESX.TriggerServerCallback('crack-custom:crutch_check', function(result)
								if result then
									--exports.wasabi_crutch:RemoveCrutch(GetPlayerServerId(PlayerId()))
									SetEntityCoords(PlayerPedId(), v.therapy_room.x, v.therapy_room.y, v.therapy_room.z, false, false, false, false)
									SetEntityHeading(PlayerPedId(),  v.therapy_room.w)
									Wait(1000)
									PlayAnim()
								else
									exports['okokNotify']:Alert('Medical Center', 'You dont have enough money for therapy session !', 5000, 'error')
								end
							end)
                        end
                    end
                end
            end

        end
        Citizen.Wait(sleep)
    end
end)

Citizen.CreateThread(function()
    if Config.Clutch.EnableNPC then
        RequestModel(GetHashKey(Config.Clutch.NPCModel))
        while not HasModelLoaded(GetHashKey(Config.Clutch.NPCModel)) do
            Wait(1)
        end
        for _, v in pairs(Config.Clutch.Locations) do
			local ped = CreatePed(4, GetHashKey(Config.Clutch.NPCModel), v.coords.x, v.coords.y, v.coords.z-1.0, v.coords.w, false, true)
			SetEntityHeading(ped, v.coords.w)
			FreezeEntityPosition(ped, true)
			SetEntityInvincible(ped, true)
			SetBlockingOfNonTemporaryEvents(ped, true)
		end
	end
end)

function PlayAnim()
    RequestAnimDict(Config.Clutch.Anim)
	while (not HasAnimDictLoaded(Config.Clutch.Anim)) do
		RequestAnimDict(Config.Clutch.Anim)
		Citizen.Wait(1)
	end		
	TaskPlayAnim(PlayerPedId(), Config.Clutch.Anim ,"base_a" ,8.0, -8.0, -1, 1, 0, false, false, false )		
	Citizen.Wait(Config.Clutch.AnimDuration * 1000)			
	ClearPedTasksImmediately(PlayerPedId())
    exports['okokNotify']:Alert('Medical Center', 'You have completed your therapy session !', 5000, 'success')
end