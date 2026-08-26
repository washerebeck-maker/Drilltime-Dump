CreateThread(function()
	while true do
        local sleep = 2000
		local player_ped = PlayerPedId()
        if IsPedInAnyVehicle(player_ped,false) then
            local vehicle = GetVehiclePedIsIn(player_ped,false)
            if IsVehicleNoWeapon(GetEntityModel(vehicle)) then
                if IsPedArmed(player_ped, 6) then
                    sleep = 100
                    ESX.ShowNotification("⛔️ You are not allowed to use weapon in this vehicle.")
                    TriggerEvent('ox_inventory:disarm', true)
                else
                    sleep = 500
                end
            end
        end
        Wait(sleep)	
    end
end)


IsVehicleNoWeapon = function(model)
    for _,v in pairs(Config.VehiclesNoWeapon) do
        if GetHashKey(v) == model then return true end
    end
    return false
end



 ----


-- Citizen.CreateThread(function()
	-- while true do
        -- local sleep = 2000
		-- local player_ped = PlayerPedId()
        -- if IsPedInAnyVehicle(player_ped,false) then
            -- local vehicle = GetVehiclePedIsIn(player_ped,false) 
            -- if not IsVehicleWhitelisted(GetEntityModel(vehicle)) or GetPedInVehicleSeat(vehicle, -1) == player_ped then
                -- if IsPedArmed(player_ped, 6) then
                    -- sleep = 100
                    -- ESX.ShowNotification("⛔️ You are not allowed to use weapon in this vehicle.")
                    -- TriggerEvent('ox_inventory:disarm', true)
                -- else
                    -- sleep = 500
                -- end
            -- end
        -- end
        -- Wait(sleep)	
    -- end
-- end)

--[[IsVehicleWhitelisted = function(model)
    for _,v in pairs(Config.VehicleWhitelisted) do
        if GetHashKey(v) == model then return true end
    end
    return false
end]]