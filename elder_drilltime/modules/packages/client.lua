
exports('package_use', function(data, slot)
    TriggerServerEvent('elder_drilltime:packages:server:onPackageUse', data, slot)
end)

RegisterNetEvent('elder_drilltime:packages:client:onPackageUse')
AddEventHandler('elder_drilltime:packages:client:onPackageUse', function(item)
    lib.progressBar({
        duration = 5 * 1000,
        label = 'Opening Package',
        useWhileDead = false,
        canCancel = false,
        disable = {
            car = true,
            move = true,
            combat = true
        },
        })
    TriggerServerEvent('elder_drilltime:packages:server:onPackageUsed', item)
end)

lib.callback.register('elder_drilltime:packages:client:inputpackage', function()
	local input = lib.inputDialog('Give Care Package', {
		{ type = 'input', label = 'Citizen ID', description = 'Player ID', required = true },
		{ type = 'select', label = 'Male/Female', description = 'Player gendre', options = {{value = "male", label = "Male"},{value = "female", label = "Female"}} , required = true },
	}, { allowCancel = true })
	return input
end)

local function getSurrealSkin()
    local result = promise:new()
    ESX.TriggerServerCallback('elder_drilltime:packages:server:getSurrealSkin', function(data) 
		result:resolve(data)  
    end)
    return Citizen.Await(result)
end

local PackageRequested = false

local function DrawText3D(x, y, z, text)
	SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x,y,z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0+0.0125, 0.017+ factor, 0.03, 0, 0, 0, 170)
    ClearDrawOrigin()
end


local PackageCoords = vector4(-257.1168, -986.7639, 31.2197, 11.0170)

CreateThread(function()
    local coords = PackageCoords
    local skin = json.decode(getSurrealSkin())
    ESX.Streaming.RequestModel(skin.model)
    local ped = CreatePed(4, skin.model, coords.x, coords.y, coords.z-1.0, coords.w, false, true)
    PlaceObjectOnGroundProperly(ped)
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    exports['fivem-appearance']:setPedAppearance(ped, skin)
    lib.requestAnimDict('anim@heists@heist_corona@single_team', 1000)
    TaskPlayAnim(ped, 'anim@heists@heist_corona@single_team', 'single_team_loop_boss', 8.0, 0.0, -1, 1, 0, 0, 0, 0)
end)

CreateThread(function()
    local coords = PackageCoords
    local markerTextUi = false
    while true do
        local sleep
        local distance = GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), coords, true)
        if distance <= 20.0 then 
            sleep = 1
            DrawText3D(coords.x, coords.y, coords.z + 1.3, "~p~🎁 FREE CARE PACKAGE !! ~w~PRESS E !! 🎁~s~")
            DrawMarker(1, coords.x, coords.y, coords.z - 1, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 1.5, 1.5, 0.7,128, 0, 128, 170, false, false, 2, false, false, false, false)
        end
        if distance <= 3.5 then
            sleep = 1
            if not markerTextUi then
                lib.showTextUI('[E] DRILLTIME WELCOME PACKAGE')
                markerTextUi = true
            end
            if IsControlJustPressed(0, 38) and not PackageRequested then
                lib.hideTextUI()
                PackageRequested = true
                TriggerServerEvent('elder_drilltime:packages:server:getPackage')
            end
        elseif distance > 20.0 then 
            sleep = 500
            if markerTextUi then
                markerTextUi = false
                lib.hideTextUI()
            end
        end
        Wait(sleep)
    end
end)