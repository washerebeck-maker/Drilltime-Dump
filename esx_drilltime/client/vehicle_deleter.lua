local entityEnumerator = {
    __gc = function(enum)
      if enum.destructor and enum.handle then
        enum.destructor(enum.handle)
      end
      enum.destructor = nil
      enum.handle = nil
    end
}
  
local function EnumerateEntities(initFunc, moveFunc, disposeFunc)
    return coroutine.wrap(function()
      local iter, id = initFunc()
      if not id or id == 0 then
        disposeFunc(iter)
        return
      end
      
      local enum = {handle = iter, destructor = disposeFunc}
      setmetatable(enum, entityEnumerator)
      
      local next = true
      repeat
        coroutine.yield(id)
        next, id = moveFunc(iter)
      until not next
      
      enum.destructor, enum.handle = nil, nil
      disposeFunc(iter)
    end)
end
  
function EnumerateVehicles()
    return EnumerateEntities(FindFirstVehicle, FindNextVehicle, EndFindVehicle)
end

function IsWhitelistedVehicle(model)
    for k,v in pairs(Config.WhitelistedVehicles) do
        if model == GetHashKey(v) then
            return true
        end
    end
    return false
end
  
RegisterNetEvent("txdelallvip")
AddEventHandler("txdelallvip", function ()
    if Config.Alerts then
        TriggerEvent('chat:addMessage', {
            template = '<div style="padding: 0.5vw; margin: 0.5vw; background-color: rgba( 255, 0, 0, 1); border-radius: 3px;"><i class="fas fa-car-crash"></i> {0}:<br> {1}</div>',
            args = { 'CarWipe', 'A car wipe is coming in '..Config.WipeAfter..' seconds.' }
        })
        Citizen.Wait(Config.WipeAfter * 1000)
        
        Citizen.Wait(1000)
        TriggerEvent('chat:addMessage', {
            template = '<div style="padding: 0.5vw; margin: 0.5vw; background-color: rgba( 255, 0, 0, 1); border-radius: 3px;"><i class="fas fa-car-crash"></i> {0}:<br> {1}</div>',
            args = { 'CarWipe', 'A car wipe is coming in 1 second.' }
        })
    end
    Citizen.Wait(1000) 
    for vehicle in EnumerateVehicles() do
        if not IsWhitelistedVehicle(GetEntityModel(vehicle)) then           
            if (not IsPedAPlayer(GetPedInVehicleSeat(vehicle, -1))) then 
                if Config.OnlyWipeBroken == true then
                    if GetVehicleEngineHealth(vehicle) <= 100.0 then
                        SetVehicleHasBeenOwnedByPlayer(vehicle, false) 
                        SetEntityAsMissionEntity(vehicle, false, false) 
                        DeleteVehicle(vehicle)
                        if Config.UseESX then
                            ESX.Game.DeleteVehicle(vehicle)
                        end
                        DeleteEntity(vehicle)
                        DeleteVehicle(vehicle) 
                        if Config.UseESX then
                            ESX.Game.DeleteVehicle(vehicle)
                        end
                        DeleteEntity(vehicle)
                        if (DoesEntityExist(vehicle)) then 
                            DeleteVehicle(vehicle) 
                            if Config.UseESX then
                                ESX.Game.DeleteVehicle(vehicle)
                            end
                            DeleteEntity(vehicle)
                            DeleteVehicle(vehicle)
                            if Config.UseESX then 
                                ESX.Game.DeleteVehicle(vehicle)
                            end
                            DeleteEntity(vehicle)
                        end
                    end
                else
                    SetVehicleHasBeenOwnedByPlayer(vehicle, false) 
                    SetEntityAsMissionEntity(vehicle, false, false) 
                    DeleteVehicle(vehicle)
                    if Config.UseESX then
                        ESX.Game.DeleteVehicle(vehicle)
                    end
                    DeleteEntity(vehicle)
                    DeleteVehicle(vehicle) 
                    if Config.UseESX then
                        ESX.Game.DeleteVehicle(vehicle)
                    end
                    DeleteEntity(vehicle)
                    if (DoesEntityExist(vehicle)) then 
                        DeleteVehicle(vehicle) 
                        if Config.UseESX then
                            ESX.Game.DeleteVehicle(vehicle)
                        end
                        DeleteEntity(vehicle)
                        DeleteVehicle(vehicle)
                        if Config.UseESX then 
                            ESX.Game.DeleteVehicle(vehicle)
                        end
                        DeleteEntity(vehicle)
                    end
                end
                if Config.Use10msdelay then
                    Citizen.Wait(10)
                end
            end
        end
    end
    if Config.DoneNotify then
        TriggerEvent('chat:addMessage', {
            template = '<div style="padding: 0.5vw; margin: 0.5vw; background-color: rgba(202, 45, 45, 1); border-radius: 3px;"><i class="fas fa-car-crash"></i> {0}:<br> {1}</div>',
            args = { 'CarWipe', 'Carwipe completed!' }
        })
    end
end)