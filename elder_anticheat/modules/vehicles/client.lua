
CreateThread(function()
    if ESX.IsPlayerLoaded() then
        TriggerServerEvent('elder_anticheat:server:checkVehicles')
    end
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(player)
    Wait(1000)
    TriggerServerEvent('elder_anticheat:server:checkVehicles')
end)

lib.callback.register('elder_anticheat:client:checkVehicles', function(data)
    local result = {}
	for k,v in pairs(data) do 
        local old_label = GetDisplayNameFromVehicleModel(tonumber(v.audit_model))
        local old_vehicle_name = GetLabelText(old_label)
        local new_label = GetDisplayNameFromVehicleModel(tonumber(v.current_model))
        local new_vehicle_name = GetLabelText(new_label)
        table.insert(result, {owner = v.owner, original_owner = v.original_owner, plate = v.plate, old = old_label..' | '..old_vehicle_name, new = new_label..' | '..new_vehicle_name})
        end
    return result
end)
