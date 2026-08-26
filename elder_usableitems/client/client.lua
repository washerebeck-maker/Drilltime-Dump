local RemainingSpeedTime = 0
local IsPlayerInSpeedMode = false

RegisterNetEvent('usableitems:client:onUsingItem')
AddEventHandler('usableitems:client:onUsingItem', function(index)
    local item = Config.Items[index]
    if not item or not item.effects then return end

    lib.progressBar({
        duration = item.useTime * 1000,
        label = item.useLabel,
        useWhileDead = false,
        canCancel = false,
        disable = {
            car = false,
            move = false,
            combat = false
        },
        anim = item.anim,
        prop = item.prop,
    })

    local effects = item.effects

    if effects.hunger then TriggerEvent('esx_status:add', 'hunger', effects.hunger) end
    if effects.thirst then TriggerEvent('esx_status:add', 'thirst', effects.thirst) end
    if effects.armor then SetPedArmour(cache.ped, GetPedArmour(cache.ped) + effects.armor) end

    if effects.speed then
        RemainingSpeedTime = effects.speed.duration
        if not IsPlayerInSpeedMode then
            IsPlayerInSpeedMode = true
            CreateThread(function()
                while RemainingSpeedTime > 0 do
                    SetPedMoveRateOverride(cache.ped, effects.speed.multiplier)
                    RestorePlayerStamina(PlayerId(), 100.0)
                    Wait(1)
                end
                IsPlayerInSpeedMode = false
            end)
            CreateThread(function()
                while RemainingSpeedTime > 0 do
                    Wait(1000)
                    RemainingSpeedTime -= 1
                end
            end)
        end
    end
end)
