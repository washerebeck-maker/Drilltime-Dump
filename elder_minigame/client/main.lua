ESX = exports['es_extended']:getSharedObject()

function Notify(msg, type)
	lib.notify({
        description = msg,
        position = position or 'center-left',
        type = type,
        duration = time
    })
end

RegisterNetEvent("elder_minigame:client:notify")
AddEventHandler("elder_minigame:client:notify", function(msg, type) 
	Notify(msg, type)
end)

GetItemLabel = function(_item)
	local item  = exports.ox_inventory:Items(_item)
	return item and item.label or _item
end

Teleport = function(ped, coords, freeze)
    ESX.Game.Teleport(ped, coords)
    if freeze then
        Wait(500)
        FreezeEntityPosition(ped, true)
        Wait(5000)
        FreezeEntityPosition(ped, false)
    end
end

function GetStringWidth(str, font, scale)
	BeginTextCommandWidth("STRING")
	AddTextComponentSubstringPlayerName(str)
	SetTextFont(font or 0)
	SetTextScale(1.0, scale or 0)
	return EndTextCommandGetWidth(true)
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

function SecondsToClock(seconds)
	if seconds <= 0 then
		return "00:00";
	else
		mins = string.format("%02.f", math.floor(seconds / 60 - (math.floor(seconds / 3600) * 60)));
		secs = string.format("%02.f", math.floor(seconds - math.floor(seconds / 3600) * 3600 - mins * 60));
		return mins .. ":" .. secs
	end
end

function DrawGunGamePreliminaryPhase(posX, posY, textA, textB, textC, color1,color2, scale)
	local width = GetStringWidth(textA, 4, scale) * 1.1
	local width2 = GetStringWidth(textB, 4, scale) * 1.1
	local width3 = GetStringWidth(textC, 4, scale) * 1.1
	DrawRect(posX - width / 2, posY, width, 0.05, 0, 0, 0, 220)
	DrawRect(posX - width - width2 / 2, posY, width2, 0.05, 0, 0, 0, 120)
	DrawRect(posX - width - width2 - width3 / 2, posY, width3, 0.05, 0, 0, 0, 220)
	DrawNiceText(posX - width / 2, posY - 0.0175, scale, textA, 4, 2, 1, color1)
	DrawNiceText(posX - width - width2 / 2, posY - 0.0175, scale, textB, 4, 1, 1,color2)
	DrawNiceText(posX - width - width2 - width3 / 2 , posY - 0.0175, scale, textC, 4, 1, 1,color2)
	return width + width2 + width3
end

function DrawGunGameScoreBoard(posX, posY, textA, textB, textC, textD, textE, textF, color1,color2, scale)
	local width = GetStringWidth("AAAAAAAAAAAAAAAA", 4, scale) * 1.1
	local width2 = GetStringWidth("AAAA", 4, scale) * 1.1
	local width3 = GetStringWidth("AAAAAAAAAAA", 4, scale) * 1.1
	local width4 = GetStringWidth("AAAA", 4, scale) * 1.1
	local width5 = GetStringWidth("AAAAAAAAAAAAAAAA", 4, scale) * 1.1
	local width6 = GetStringWidth("AAAAAAAAAAAAAAAAAAAAAAAAAAA", 4, scale) * 1.1
	DrawRect(posX - width / 2, posY, width, 0.05, 255, 0, 0, 200)
	DrawRect(posX - width - width2 / 2, posY, width2, 0.05, 0, 0, 0, 200)
	DrawRect(posX - width - width2 - width3 / 2, posY, width3, 0.05, 169,169,169, 250)
	DrawRect(posX - width - width2 - width3 - width4 / 2, posY, width4, 0.05, 0, 0, 0, 200)
	DrawRect(posX - width - width2 - width3 - width4 - width5 / 2, posY, width5, 0.05, 0, 0, 255, 200)
	DrawRect(posX - width - width2 - width3 - width4 - width5 - width6 / 2, posY, width6, 0.05, 0, 0, 0, 200)
	DrawNiceText(posX - width / 2, posY - 0.0175, scale, textA, 4, 2, 1, color2)
	DrawNiceText(posX - width - width2 / 2, posY - 0.0175, scale, textB, 4, 1, 1,color2)
	DrawNiceText(posX - width - width2 - width3 / 2 , posY - 0.0175, scale, textC, 4, 1, 1,color2)
	DrawNiceText(posX - width - width2 - width3 - width4 / 2 , posY - 0.0175, scale, textD, 4, 1, 1,color2)
	DrawNiceText(posX - width - width2 - width3 - width4 - width5 / 2 , posY - 0.0175, scale, textE, 4, 1, 1,color2)
	DrawNiceText(posX - width - width2 - width3 - width4 - width5 - width6 / 2 , posY - 0.0175, scale, textF, 4, 1, 1,color2)
	return width + width2 + width3 + width4 + width5 + width6
end

function DrawRoundStart(posX, posY, textA,color, scale)
	local width = GetStringWidth("AAAAAAAAAAAAAAAAAAAA", 4, scale) * 1.1
	DrawRect(posX - width / 2, posY, width, 0.15, 0, 0, 0, 120)
	DrawNiceText(posX - width / 2, posY - 0.0495, scale, textA, 4, 2, 1, color)
	return width
end

function DrawRoundEnd(posX, posY, textA,color, scale)
	local width = GetStringWidth("AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA", 4, scale) * 1.1
	DrawRect(posX - width / 2, posY, width, 0.15, 0, 0, 0, 120)
	DrawNiceText(posX - width / 2, posY - 0.0495, scale, textA, 4, 2, 1, color)
	return width
end

function DrawWinnerGunGame(posX, posY, textA,color, scale)
	local width = GetStringWidth("AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA", 4, scale) * 1.1
	DrawRect(posX - width / 2, posY, width, 0.15, 0, 0, 0, 120)
	DrawNiceText(posX - width / 2, posY - 0.0495, scale, textA, 4, 2, 1, color)
	return width
end

function DrawGunGamePlayerRank(posX, posY, scale, textA, textB, color1,color2, bg1,bg2)
	local width = GetStringWidth("AAAAAAAAAAAAAAAAAAAAAAAA", 4, scale) * 1.1
	local width2 = GetStringWidth("AAAA", 4, scale) * 1.1
	DrawRect(posX - width / 2, posY, width, 0.05, bg1[1], bg1[2], bg1[3], bg1[4])
	DrawRect(posX - width - width2 / 2, posY, width2, 0.05, bg2[1], bg2[2], bg2[3], bg2[4])
	DrawNiceText(posX - width / 2, posY - 0.0175, scale, textA, 4, 2, 1, color1)
	DrawNiceText(posX - width - width2 / 2, posY - 0.0175, scale, textB, 4, 1, 1,color2)
	return width + width2
end

function DrawGunGameWinnerReward(posX, posY, scale, textA, textB, color1,color2, bg1,bg2)
	local width = GetStringWidth("AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA", 4, scale) * 1.1
	local width2 = GetStringWidth("AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA", 4, scale) * 1.1
	DrawRect(posX - width / 2, posY, width, 0.05, bg1[1], bg1[2], bg1[3], bg1[4])
	DrawRect(posX - width - width2 / 2, posY, width2, 0.05, bg2[1], bg2[2], bg2[3], bg2[4])
	DrawNiceText(posX - width / 2, posY - 0.0175, scale, textA, 4, 2, 1, color1)
	DrawNiceText(posX - width - width2 / 2, posY - 0.0175, scale, textB, 4, 1, 1,color2)
	return width + width2
end



