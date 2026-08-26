
local teleports = nil

CreateThread(function()
    while PlayerJob == nil do Wait(10) end
    if PlayerJob.name == 'Ammunation' then 
        AddTeleports()
    end
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)  
    if job.name == 'Ammunation' then
        if not teleports then
            AddTeleports()
        end
    else
        RemoveTeleports()
    end
end)

AddTeleports = function()
    teleports = {}
    for k,v in pairs(Config.Ammunation) do
        local enter = lib.points.new({
            coords = v.enter,
            distance = 5,
            target = v.exit
        })
        local exit = lib.points.new({
            coords = v.exit,
            distance = 5,
            target = v.enter
        })
        function enter:nearby()
            DrawMarker(21, self.coords.x, self.coords.y,self.coords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.5, 0.5, 0.5, 255, 255, 255, 100, 1, 0, 0, 0, 0, 0, 0)
            if self.currentDistance < 0.5 then
                ESX.ShowHelpNotification('~INPUT_PICKUP~ ~b~Enter~s~ Ammunation')
                if IsControlJustReleased(0, 38) then
                    ESX.Game.Teleport(cache.ped, self.target)
                end
            end
        end
    
        function exit:nearby()
            DrawMarker(21, self.coords.x, self.coords.y,self.coords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.5, 0.5, 0.5, 255, 255, 255, 100, 1, 0, 0, 0, 0, 0, 0)
            if self.currentDistance < 0.5 then
                ESX.ShowHelpNotification('~INPUT_PICKUP~ ~r~Exit~s~ Ammunation')
                if IsControlJustReleased(0, 38) then
                    ESX.Game.Teleport(cache.ped, self.target)
                end
            end
        end

        teleports[k] = {}
        teleports[k].enter = enter
        teleports[k].exit = exit
    end
end

RemoveTeleports = function()
    if teleports then
        for k,v in pairs(teleports) do 
            local enter = v.enter
            local exit = v.exit
            enter:remove()
            exit:remove()
        end
        teleports = nil
    end
end
