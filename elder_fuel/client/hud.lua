

if Config and Config.EnableHUD == false then return end

local function DrawAdvancedText(x, y, w, h, sc, text, r, g, b, a, font, jus)
    SetTextFont(font)
    SetTextProportional(0)
    SetTextScale(sc, sc)
    N_0x4e096588b13ffeca(jus)
    SetTextColour(r, g, b, a)
    SetTextDropShadow(0, 0, 0, 0, 255)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry('STRING')
    AddTextComponentString(text)
    DrawText(x - 0.1 + w, y - 0.02 + h)
end

local mph        = '0'
local kmh        = '0'
local fuel       = '0'
local displayHud = false

local x = 0.01135
local y = 0.002

CreateThread(function()
    while true do
        local ped = PlayerPedId()

        if IsPedInAnyVehicle(ped, false) then
            local vehicle = GetVehiclePedIsIn(ped, false)
            local speed   = GetEntitySpeed(vehicle)

            mph  = tostring(math.ceil(speed * 2.236936))
            kmh  = tostring(math.ceil(speed * 3.6))
            fuel = tostring(math.ceil(GetVehicleFuelLevel(vehicle)))

            displayHud = true
            Wait(50)
        else
            displayHud = false
            Wait(500)
        end
    end
end)

CreateThread(function()
    while true do
        if displayHud then
            DrawAdvancedText(0.130 - x,  0.77   - y, 0.005, 0.0028, 0.6, mph,  255, 255, 255, 255, 6, 1)
            DrawAdvancedText(0.174 - x,  0.77   - y, 0.005, 0.0028, 0.6, kmh,  255, 255, 255, 255, 6, 1)
            DrawAdvancedText(0.2195 - x, 0.77   - y, 0.005, 0.0028, 0.6, fuel, 255, 255, 255, 255, 6, 1)
            DrawAdvancedText(0.148 - x,  0.7765 - y, 0.005, 0.0028, 0.4,
                'mp/h              km/h              Fuel',
                255, 255, 255, 255, 6, 1)
            Wait(0)
        else
            Wait(750)
        end
    end
end)
