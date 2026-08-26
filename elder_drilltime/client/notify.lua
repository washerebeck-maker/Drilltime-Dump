function Notify(msg, type, time)
	lib.notify({
        description = msg,
        position = 'center-left',
        type = type,
        duration = time
    })
end

RegisterNetEvent("elder_drilltime:client:notify")
AddEventHandler("elder_drilltime:client:notify", function(msg, type) 
	Notify(msg, type)
end)

function DrawText3D(coords,text,scale)
    ESX.Game.Utils.DrawText3D({
        x = coords.x,
        y = coords.y,
        z = coords.z
    }, text, scale)
end


function ShowTextUI(text)
    lib.showTextUI(text, {
        position = "right-center",
        icon = 'fa-store',
    })
end

function MeasureStringWidth(str, font, scale)
	BeginTextCommandWidth("STRING")
	AddTextComponentSubstringPlayerName(str)
	SetTextFont(font or 0)
	SetTextScale(1.0, scale or 0)
	return EndTextCommandGetWidth(true)
end

function SecondsToClock(seconds)
	if seconds <= 0 then
		return "00:00";
	else
		mins = string.format("%02.f", math.floor(seconds / 60 - (math.floor(seconds / 3600) * 60)));
		secs = string.format("%02.f", math.floor(seconds - math.floor(seconds / 3600) * 3600 - mins * 60));
		return mins .. ":" .. secs
	end
end

function DrawHUDRect(posX, posY, textA, textB, textC, inverse, color1,color2, scale)
	local width, width2,width3 = MeasureStringWidth(textA, 4, scale) * 1.1, MeasureStringWidth(textB, 4, scale) * 1.1, MeasureStringWidth(textC, 4, scale) * 1.1
	if inverse then
		DrawRect(posX - width / 2, posY, width, 0.05, 7, 151, 240, 180)
		DrawRect(posX - width - width2 / 2, posY, width2, 0.05, 0, 0, 0, 120)
		DrawRect(posX - width - width2 - width3 / 2, posY, width3, 0.05, 7, 151, 240, 180)
	else
		DrawRect(posX - width / 2, posY, width, 0.05, 0, 0, 0, 100)
		DrawRect(posX - width - width2 / 2, posY, width2, 0.05, 255, 215, 0, 150)
	end
	DrawNiceText(posX - width / 2, posY - 0.0175, scale, textA, 4, 2, 1, color1)
	DrawNiceText(posX - width - width2 / 2, posY - 0.0175, scale, textB, 4, 1, 1,color2)
	DrawNiceText(posX - width - width2 - width3 / 2 , posY - 0.0175, scale, textC, 4, 1, 1,color2)
	return width + width2 + width3
end

function DrawTimer(posX, posY, textA, textB, inverse, color1,color2, scale)
	local width, width2 = MeasureStringWidth(textA, 4, scale) * 1.1, MeasureStringWidth(textB, 4, scale) * 1.1
	width = MeasureStringWidth("01:28", 4, scale) * 1.1
	if inverse then
		DrawRect(posX - width / 2, posY, width, 0.05, 7, 151, 240, 180)
		DrawRect(posX - width - width2 / 2, posY, width2, 0.05, 0, 0, 0, 120)
	end
	DrawNiceText(posX - width / 2, posY - 0.0175, scale, textA, 4, 2, 1, color1)
	DrawNiceText(posX - width - width2 / 2, posY - 0.0175, scale, textB, 4, 1, 1,color2)
	return width + width2
end

function DrawSurvivals(posX, posY, textA, textB, inverse, color1,color2, scale)
	local width, width2 = MeasureStringWidth(textA, 4, scale) * 1.1, MeasureStringWidth(textB, 4, scale) * 1.1
    width = MeasureStringWidth("01:28", 4, scale) * 1.1
	width2 = MeasureStringWidth("REMAINNING TIME", 4, scale) * 1.1
	if inverse then
		DrawRect(posX - width / 2, posY, width, 0.05, 0, 255, 0, 150)
		DrawRect(posX - width - width2 / 2, posY, width2, 0.05, 0, 0, 0, 120)
	end
	DrawNiceText(posX - width / 2, posY - 0.0175, scale, textA, 4, 2, 1, color1)
	DrawNiceText(posX - width - width2 / 2, posY - 0.0175, scale, textB, 4, 1, 1,color2)
	return width + width2
end

function DrawInfected(posX, posY, textA, textB, inverse, color1,color2, scale)
	local width, width2 = MeasureStringWidth(textA, 4, scale) * 1.1, MeasureStringWidth(textB, 4, scale) * 1.1
    width = MeasureStringWidth("01:28", 4, scale) * 1.1
    width2 = MeasureStringWidth("REMAINNING TIME", 4, scale) * 1.1
	if inverse then
		DrawRect(posX - width / 2, posY, width, 0.05, 255, 0, 0, 150)
		DrawRect(posX - width - width2 / 2, posY, width2, 0.05, 0, 0, 0, 120)
	end
	DrawNiceText(posX - width / 2, posY - 0.0175, scale, textA, 4, 2, 1, color1)
	DrawNiceText(posX - width - width2 / 2, posY - 0.0175, scale, textB, 4, 1, 1,color2)
	return width + width2
end

function DrawTotalPlayers(posX, posY, textA, textB, inverse, color1,color2, scale)
	local width, width2 = MeasureStringWidth(textA, 4, scale) * 1.1, MeasureStringWidth(textB, 4, scale) * 1.1
    width = MeasureStringWidth("01:28", 4, scale) * 1.1
	if inverse then
		DrawRect(posX - width / 2, posY, width, 0.05, 7, 151, 240, 180)
		DrawRect(posX - width - width2 / 2, posY, width2, 0.05, 0, 0, 0, 120)
	end
	DrawNiceText(posX - width / 2, posY - 0.0175, scale, textA, 4, 2, 1, color1)
	DrawNiceText(posX - width - width2 / 2, posY - 0.0175, scale, textB, 4, 1, 1,color2)
	return width + width2
end

function DrawNiceText(x, y, scale, text, f, c, n, color)
	color = color or { 255, 255, 255 }
	SetTextFont(f or 4)
	SetTextProportional(0)
	SetTextScale(scale, scale)
	SetTextColour(color[1], color[2], color[3], color[4] or 255)
	SetTextCentre(c)
	if not n then
		SetTextDropShadow()
		SetTextOutline()
		SetTextDropShadow(0, 0, 0, 0,255)
		SetTextEdge(2, 0, 0, 0, 255)
	end
	SetTextEntry("STRING")
	AddTextComponentString(text)
	DrawText(x, y)
end


function SurvivalsWin()
	Citizen.CreateThread(function()
		function Initialize(scaleform)
			local scaleform = RequestScaleformMovie(scaleform)
			while not HasScaleformMovieLoaded(scaleform) do
				Citizen.Wait(0)
			end
			PushScaleformMovieFunction(scaleform, "SHOW_SHARD_WASTED_MP_MESSAGE")
			PushScaleformMovieFunctionParameterString("~g~Survivors Win~s~")
			PushScaleformMovieFunctionParameterString("Drilltime Survival Game")
			PopScaleformMovieFunctionVoid()
			return scaleform
		end
		scaleform = Initialize("mp_big_message_freemode")
		local temps = 0
		while temps < 500 do
			Citizen.Wait(0)
			DrawScaleformMovieFullscreen(scaleform, 255, 255, 255, 255, 0)
			temps = temps + 1
		end
		Citizen.Wait(500)
	end)
end

function InfectedWin()
	Citizen.CreateThread(function()
		function Initialize(scaleform)
			local scaleform = RequestScaleformMovie(scaleform)
			while not HasScaleformMovieLoaded(scaleform) do
				Citizen.Wait(0)
			end
			PushScaleformMovieFunction(scaleform, "SHOW_SHARD_WASTED_MP_MESSAGE")
			PushScaleformMovieFunctionParameterString("~r~Infected Win~s~")
			PushScaleformMovieFunctionParameterString("Drilltime Survival Game")
			PopScaleformMovieFunctionVoid()
			return scaleform
		end
		scaleform = Initialize("mp_big_message_freemode")
		local temps = 0
		while temps < 500 do
			Citizen.Wait(0)
			DrawScaleformMovieFullscreen(scaleform, 255, 255, 255, 255, 0)
			temps = temps + 1
		end
		Citizen.Wait(500)
	end)
end

function effectHandlerEntity(asset,name,entity,time,r,g,b,a,scale)
    CreateThread(function()
        if not HasNamedPtfxAssetLoaded(asset) then

            RequestNamedPtfxAsset(asset)
            while not HasNamedPtfxAssetLoaded(asset) do
                Citizen.Wait(1)
            end
        end
    
        SetPtfxAssetNextCall(asset)
    
        local fx = StartParticleFxLoopedOnEntity(name,entity, 0.0,0.0, 0.0, 0.0, 0.0, 0.0,scale, false, false, false, false)
        SetParticleFxLoopedColour(fx, r, g, b, 0)
        SetParticleFxLoopedAlpha(fx, a)
        Wait(time)
        StopParticleFxLooped(fx, 0)
    end)
end

function poisonGasPtfx(entity)
    effectHandlerEntity('core','blood_stab',entity,1000,0.0,10.0,0.0,1.0,1.0)
    effectHandlerEntity('core','bang_blood',entity,1000,0.0,10.0,0.0,1.0,1.0)
end

function DrawKillHouseOwner(posX, posY, textA, textB, inverse, color1,color2, scale)
	local width, width2 = MeasureStringWidth(textA, 4, scale) * 1.1, MeasureStringWidth(textB, 4, scale) * 1.1
    width = MeasureStringWidth("AAAAAAAAAAAAA", 4, scale) * 1.1
   --width2 = MeasureStringWidth("KILLHOUSE OWNER", 4, scale) * 1.1
	if inverse then
		DrawRect(posX - width / 2, posY, width, 0.05, 255, 0, 0, 150)
		DrawRect(posX - width - width2 / 2, posY, width2, 0.05, 0, 0, 0, 120)
	end
	DrawNiceText(posX - width / 2, posY - 0.0175, scale, textA, 4, 2, 1, color1)
	DrawNiceText(posX - width - width2 / 2, posY - 0.0175, scale, textB, 4, 1, 1,color2)
	return width + width2
end

function DrawKillHouseWinnerFight(posX, posY, textA, textB, inverse, color1,color2, scale)
	local width, width2 = MeasureStringWidth(textA, 4, scale) * 1.1, MeasureStringWidth(textB, 4, scale) * 1.1
    width = MeasureStringWidth("AAAAAAAAAAAAA", 4, scale) * 1.1
   --width2 = MeasureStringWidth("KILLHOUSE OWNER", 4, scale) * 1.1
	if inverse then
		DrawRect(posX - width / 2, posY, width, 0.05, 255, 0, 0, 150)
		DrawRect(posX - width - width2 / 2, posY, width2, 0.05, 0, 0, 0, 120)
	end
	DrawNiceText(posX - width / 2, posY - 0.0175, scale, textA, 4, 2, 1, color1)
	DrawNiceText(posX - width - width2 / 2, posY - 0.0175, scale, textB, 4, 1, 1,color2)
	return width + width2
end

function DrawKillHousePreliminaryPhase(posX, posY, textA, textB, textC, inverse, color1,color2, scale)
	local width, width2,width3 = MeasureStringWidth(textA, 4, scale) * 1.1, MeasureStringWidth(textB, 4, scale) * 1.1, MeasureStringWidth(textC, 4, scale) * 1.1
	if inverse then
		DrawRect(posX - width / 2, posY, width, 0.05, 255, 0, 0, 180)
		DrawRect(posX - width - width2 / 2, posY, width2, 0.05, 0, 0, 0, 120)
		DrawRect(posX - width - width2 - width3 / 2, posY, width3, 0.05, 255, 0, 0, 180)
	else
		DrawRect(posX - width / 2, posY, width, 0.05, 0, 0, 0, 100)
		DrawRect(posX - width - width2 / 2, posY, width2, 0.05, 255, 215, 0, 150)
	end
	DrawNiceText(posX - width / 2, posY - 0.0175, scale, textA, 4, 2, 1, color1)
	DrawNiceText(posX - width - width2 / 2, posY - 0.0175, scale, textB, 4, 1, 1,color2)
	DrawNiceText(posX - width - width2 - width3 / 2 , posY - 0.0175, scale, textC, 4, 1, 1,color2)
	return width + width2 + width3
end

function DrawKillHouseTimer(posX, posY, textA, textB, inverse, color1,color2, scale)
	local width, width2 = MeasureStringWidth(textA, 4, scale) * 1.1, MeasureStringWidth(textB, 4, scale) * 1.1
	width = MeasureStringWidth("AAAAAAAA", 4, scale) * 1.1
	--width2 = MeasureStringWidth("01:28", 4, scale) * 1.1
	if inverse then
		DrawRect(posX - width / 2, posY, width, 0.05, 7, 151, 240, 180)
		DrawRect(posX - width - width2 / 2, posY, width2, 0.05, 0, 0, 0, 120)
	end
	DrawNiceText(posX - width / 2, posY - 0.0175, scale, textA, 4, 2, 1, color1)
	DrawNiceText(posX - width - width2 / 2, posY - 0.0175, scale, textB, 4, 1, 1,color2)
	return width + width2
end

function DrawKillHouseWinner(text1, text2)
	Citizen.CreateThread(function()
		function Initialize(scaleform)
			local scaleform = RequestScaleformMovie(scaleform)
			while not HasScaleformMovieLoaded(scaleform) do
				Citizen.Wait(0)
			end
			PushScaleformMovieFunction(scaleform, "SHOW_SHARD_WASTED_MP_MESSAGE")
			PushScaleformMovieFunctionParameterString(text1)
			PushScaleformMovieFunctionParameterString(text2)
			PopScaleformMovieFunctionVoid()
			return scaleform
		end
		scaleform = Initialize("mp_big_message_freemode")
		local temps = 0
		while temps < 500 do
			Citizen.Wait(0)
			DrawScaleformMovieFullscreen(scaleform, 255, 255, 255, 255, 0)
			temps = temps + 1
		end
		Citizen.Wait(500)
	end)
end

function MissionAlert(text)
    ClearPrints()
    SetTextEntry_2("STRING")
    AddTextComponentString(text)
    DrawSubtitleTimed(1000, 1)
end