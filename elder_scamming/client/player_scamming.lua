local IsHacking = false
local IsUnHacking = false
local CurrentTimer = nil

local function DrawHUD(posX, posY, textA, textB, inverse, colorA, colorB)

    local function ToClock(v)
        if type(v) ~= "number" then return tostring(v) end
        if v <= 0 then return "00:00" end
        local mins = math.floor(v / 60)
        local secs = math.floor(v % 60)
        return string.format("%02d:%02d", mins, secs)
    end

    textA = ToClock(textA)

    local function Measure(str)
        BeginTextCommandWidth("STRING")
        AddTextComponentSubstringPlayerName(str)
        SetTextFont(4)
        SetTextScale(1.0, 0.85)
        return EndTextCommandGetWidth(true) * 1.1
    end

    local function DrawTextNice(x, y, text, color)
        color = color or {255, 255, 255}
        SetTextFont(4)
        SetTextProportional(0)
        SetTextScale(0.85, 0.85)
        SetTextColour(color[1], color[2], color[3], color[4] or 255)
        SetTextCentre(1)
        SetTextDropShadow()
        SetTextOutline()
        SetTextEntry("STRING")
        AddTextComponentString(text)
        DrawText(x, y)
    end

    local widthA = Measure(textA)
    local widthB = Measure(textB)

    if inverse then
        DrawRect(posX - widthA / 2, posY, widthA, 0.05, 0, 0, 0, 100)
        DrawRect(posX - widthA - widthB / 2, posY, widthB, 0.05, 220, 220, 220, 25)
    else
        DrawRect(posX - widthA / 2, posY, widthA, 0.05, 220, 220, 220, 25)
        DrawRect(posX - widthA - widthB / 2, posY, widthB, 0.05, 0, 0, 0, 100)
    end

    DrawTextNice(posX - widthA / 2, posY - 0.0275, textA, colorA)
    DrawTextNice(posX - widthA - widthB / 2, posY - 0.0275, textB, colorB)

    return widthA + widthB
end


RegisterNetEvent('scamming:client:startRemoteHack')
AddEventHandler('scamming:client:startRemoteHack', function()
    local success = exports['es_minigame']:StartMinigame({
        maxFails = 3,
        maxSquares = 6,
        rows = 7
    })

    if not success then
        return notify('You lost the game, hacking failed.', 'error', 10000)
    end

    TriggerEvent("utk_fingerprint:Start", 1, 2, 1, function(outcome)
        if outcome then
            TriggerServerEvent('scamming:server:startRemoteHack')
        else
            notify('You lost the game, hacking failed.', 'error', 10000)
        end
    end)
end)

local function startHacking()
    IsHacking = true
    if not lib.callback.await('scamming:server:startHacking') then 
        IsHacking = false
        return 
    end
    TriggerEvent("mhacking:show")
	TriggerEvent("mhacking:show")
	TriggerEvent("mhacking:start", Config.PlayerScamming.GameDigitNumber, Config.PlayerScamming.HackerGameTimer,  function(output)
		if output == true then
			TriggerEvent('mhacking:hide')
			TriggerServerEvent('scamming:server:hack')
		else
			IsHacking = false
			TriggerEvent('mhacking:hide')
            notify('Fraud has Failed.', 'error')
		end
	end)
end

RegisterNetEvent('scamming:client:timer')
AddEventHandler('scamming:client:timer', function()
	CurrentTimer = Config.PlayerScamming.HackingTime
	CreateThread(function()
		while CurrentTimer and CurrentTimer > 0 do
			Wait(1000)
			CurrentTimer = CurrentTimer - 1
		end
	end)
	CreateThread(function()
		while CurrentTimer and CurrentTimer > 0 do
			Wait(0)
			DrawHUD(0.30, 0.95, CurrentTimer, 'Timer', true, {255,0,0},{ 255, 255, 255 })
		end
		Wait(2000)
		CurrentTimer = nil
		IsHacking = false
		IsUnHacking = false
	end)
end)

CreateThread(function()
    for _,coords in pairs(Config.PlayerScamming.HackingLocations) do 
        local point = lib.points.new({
            coords = coords,
            distance = 30.0,
        })
        function point:nearby()
            DrawMarker(1, self.coords.x, self.coords.y,self.coords.z - 1.25 , 0, 0, 0, 0, 0, 0, 3.0, 3.0, 1.0, 31,94,255, 255, 0, 0, 2, 1, 0, 0, 0)
            if self.currentDistance < 2.0 then
                ESX.ShowHelpNotification('Press ~INPUT_CONTEXT~ to start ~r~hacking~s~')
                if IsControlJustReleased(0, 38) and not IsHacking then
                    startHacking()
                end
            end
        end
    end
end)


RegisterCommand('stopfraud', function()
    if IsUnHacking then 
        return notify('you should wait !', 'error')
    end

    IsUnHacking = true
    if not lib.callback.await('scamming:server:check_unhack') then 
        notify('Cant use this command at the moment.', 'error')
		IsUnHacking = false
        return 
    end
    TriggerEvent("mhacking:show")
	TriggerEvent("mhacking:show")
	TriggerEvent("mhacking:start", Config.PlayerScamming.GameDigitNumber, Config.PlayerScamming.HackedGameTimer,  function(output)
		if output == true then
			TriggerEvent('mhacking:hide')
			if CurrentTimer and CurrentTimer > 0 then
				TriggerServerEvent('scamming:server:unhack')
			else
				notify('Fraud was successful took to long to complete identity check.', 'error')
		    end
		else
			TriggerEvent('mhacking:hide')
			notify('Fraud was successful took to long to complete identity check.', 'error')
		end
	end)
end)

