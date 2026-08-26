local HandStyle

RegisterCommand('handstyle', function()
    local current_animation = GetResourceKvpString('handStyle') or 'twohand'
    lib.registerContext({
        id = 'handstyle',
        title = 'Pistol Hand Style',
        options = {
            {
                title = 'One-Hand AP' .. (current_animation == 'twohand' and '✅' or ''),
                description = 'Regular ADS',
                onSelect = function()
                    HandStyle = 'twohand'
                    SetResourceKvp('handStyle', HandStyle)
                    lib.notify({
                        title = 'Hand Style Selected',
                        description = 'Pistol style: One-Hand',
                        type = 'success',
                        position = 'top-right'
                    })
                end
            },
            {
                title = 'Two-Hand AP' .. (current_animation == 'onehand' and '✅' or ''),
                description = 'Fast ADS',
                onSelect = function()
                    HandStyle = 'onehand'
                    SetResourceKvp('handStyle', HandStyle)
                    lib.notify({
                        title = 'Hand Style Selected',
                        description = 'Pistol style: Two-Hand',
                        type = 'success',
                        position = 'top-right'
                    })
                end
            }
        }
    })
	lib.showContext('handstyle')
end, false)

CreateThread(function()
    while not ESX.IsPlayerLoaded() do Wait(100) end
    HandStyle = GetResourceKvpString('handStyle') or 'twohand'
    while HandStyle do 
        local hasWeapon, currentWeapon = GetCurrentPedWeapon(PlayerPedId(), true)
        if hasWeapon then
            local weaponType = GetWeapontypeGroup(currentWeapon) 
            if HandStyle == 'onehand' then
                if IsPedUsingActionMode(cache.ped) and weaponType ~= `GROUP_PISTOL` then
                    SetPedUsingActionMode(cache.ped, false, -1, 'DEFAULT_ACTION')
                end
            else 
                SetPedUsingActionMode(cache.ped, false, -1, 'DEFAULT_ACTION')
            end
        else
            Wait(500)
        end
        Wait(50)
    end
end)

