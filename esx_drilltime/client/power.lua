
local Power = false
local CurrentTimer = 0
local UseTime = 150

RegisterNetEvent('esx_drilltime:client:power')
AddEventHandler('esx_drilltime:client:power', function()
    if not Power then
        Power = true
        CurrentTimer = UseTime
        StartPower()
        StartTimer()
    end
end)


StartPower = function()
    AddArmourToPed(PlayerPedId(), 100)
    SetEntityHealth(PlayerPedId(), GetEntityMaxHealth(PlayerPedId()))
    CreateThread(function()
        while Power do
            Wait(0)
            SetPedMoveRateOverride(PlayerPedId(), 1.5)
            SetRunSprintMultiplierForPlayer(PlayerPedId(), 1.5)
        end
    end)
    PlayAnim()
end

StartTimer = function()
    CreateThread(function()
        while CurrentTimer > 0 do
            CurrentTimer = CurrentTimer - 1
            --[[ if CurrentTimer > 60 then
                MissionAlert("mr.fentanyl blues powers : ~y~" ..  CurrentTimer .. "~s~")
            else
                MissionAlert("mr.fentanyl blues powers : ~r~" ..  CurrentTimer .. "~s~")
            end ]]
            Wait(1000)
        end
        Power = false
        local chance = math.random(2,4)
        if chance == 1 then
            SetEntityHealth(PlayerPedId(), 0)
            ESX.ShowNotification("Overdose, you are dead !")
        end
        TriggerServerEvent('esx_drilltime:server:endpower')
    end)
end


function MissionAlert(text)
    ClearPrints()
    SetTextEntry_2("STRING")
    AddTextComponentString(text)
    DrawSubtitleTimed(1000, 1)
end

PlayAnim = function()
    SetTimecycleModifier("spectator5")
    SetPedMotionBlur(PlayerPedId(), true)
    SetPedMovementClipset(PlayerPedId(), "MOVE_M@QUICK", true)
    SetPedIsDrunk(PlayerPedId(), true)
	SetPedMoveRateOverride(PlayerId(),10.0)
    SetRunSprintMultiplierForPlayer(PlayerId(),1.49)
    AnimpostfxPlay("DrugsMichaelAliensFight", 10000001, true)
    ShakeGameplayCam("DRUNK_SHAKE", 3.0)
    Citizen.Wait(179000)
    SetPedMoveRateOverride(PlayerId(),1.0)
    SetRunSprintMultiplierForPlayer(PlayerId(),1.0)
    SetPedIsDrunk(GetPlayerPed(-1), false)		
    SetPedMotionBlur(PlayerPedId(), false)
    ResetPedMovementClipset(GetPlayerPed(-1))
    AnimpostfxStopAll()
    ShakeGameplayCam("DRUNK_SHAKE", 0.0)
    SetTimecycleModifierStrength(0.0)
end