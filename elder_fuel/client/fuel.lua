

local fuelSynced = false

function GetFuel(vehicle)
    return DecorGetFloat(vehicle, Config.FuelDecor)
end

function SetFuel(vehicle, fuel)
    if type(fuel) ~= 'number' or fuel < 0 or fuel > 100 then return end
    SetVehicleFuelLevel(vehicle, fuel + 0.0)
    DecorSetFloat(vehicle, Config.FuelDecor, GetVehicleFuelLevel(vehicle))
end

function ManageFuelUsage(vehicle)
	if not DecorExistOn(vehicle, Config.FuelDecor) then
		SetFuel(vehicle, math.random(200, 800) / 10)
	elseif not fuelSynced then
		SetFuel(vehicle, GetFuel(vehicle))

		fuelSynced = true
	end

	if IsVehicleEngineOn(vehicle) then
		SetFuel(vehicle, GetVehicleFuelLevel(vehicle) - Config.FuelUsage[Round(GetVehicleCurrentRpm(vehicle), 1)] * (Config.Classes[GetVehicleClass(vehicle)] or 1.0) / 10)
	end
end

CreateThread(function()
    DecorRegister(Config.FuelDecor, 1) 

    while true do
        Wait(1000)

        local ped = PlayerPedId()
        if IsPedInAnyVehicle(ped, false) then
            local vehicle = GetVehiclePedIsIn(ped, false)

            if GetPedInVehicleSeat(vehicle, -1) == ped then
                ManageFuelUsage(vehicle)
            end
        elseif fuelSynced then
            fuelSynced = false
        end
    end
end)
