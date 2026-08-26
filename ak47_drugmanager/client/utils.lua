ESX = ESX or nil
CustomProps = {}
PlayerData = nil

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent(Config.SharedObjectName, function(obj) ESX = obj end)
        Citizen.Wait(0)
    end
    while ESX.GetPlayerData() == nil do
        Citizen.Wait(0)
    end
    while ESX.GetPlayerData().job == nil do
        Citizen.Wait(0)
    end
    PlayerData = ESX.GetPlayerData()
    for k, v in pairs(Config.Props) do
        ESX.Game.SpawnLocalObject(v.prop, v.coords, function(obj)
            SetEntityHeading(obj, v.heading)
            SetEntityCoords(obj, v.coords)
            FreezeEntityPosition(obj, true)
            table.insert(CustomProps, obj)
        end)
    end
    RequestModel('prop_bong_01')
    RequestModel('p_cs_lighter_01')
    RequestAnimDict('anim@safehouse@bong')
    CreateBlip()
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    PlayerData.job = job
end)

RegisterNetEvent('ak47_drugmanager:notify')
AddEventHandler('ak47_drugmanager:notify', function(msg)
    ESX.ShowNotification(msg)
end)

RegisterNetEvent('ak47_drugmanager:progress')
AddEventHandler('ak47_drugmanager:progress', function(msg, time)
    TriggerEvent('inventory:progress', time, msg)
end)

RegisterNetEvent('ak47_drugmanager:stop:progress')
AddEventHandler('ak47_drugmanager:stop:progress', function()
    
end)

RegisterNetEvent('ak47_drugmanager:policeAlert')
AddEventHandler('ak47_drugmanager:policeAlert', function(targetCoords, street)
    if not Config.CustomDispatch then
        if Config.Cops[PlayerData.job.name] then
            TriggerEvent('ak47_drugmanager:notify', '~b~Citizen Report:~s~ ~r~Drug sell in progress at '..street)
            local alpha = 250
            local sellerBlip = AddBlipForRadius(targetCoords.x, targetCoords.y, targetCoords.z, 50.0)
            SetBlipHighDetail(sellerBlip, true)
            SetBlipColour(sellerBlip, 1)
            SetBlipAlpha(sellerBlip, alpha)
            SetBlipAsShortRange(sellerBlip, true)
            while alpha ~= 0 do
                Citizen.Wait(Config.CopAlertBlipTime * 4)
                alpha = alpha - 1
                SetBlipAlpha(sellerBlip, alpha)
                if alpha == 0 then
                    RemoveBlip(sellerBlip)
                    return
                end
            end
        end
    else
        --Place your dispatch export here
    end
end)

function afkCheck(k)
    local Keys = {W = 32, A = 34, S = 33, D = 35}
    local inChecking = true
    local totalKeys = 0
    for i, v in pairs(Keys) do
        totalKeys = totalKeys + 1
    end
    local randomKey = math.random(1, totalKeys)
    local keyName = nil
    local keyId = nil
    local count = 0
    for i, v in pairs(Keys) do
        count = count + 1
        if count == randomKey then
            keyName = i
            keyId = v
            break
        end
    end
    while inChecking do
        Citizen.Wait(0)
        ESX.ShowHelpNotification(_U('press_continue', keyName))
        DisableControlAction(0, 30, true)
        DisableControlAction(0, 31, true)
        if IsDisabledControlJustReleased(0, keyId) then
            return true
        end
        local playerPed = PlayerPedId()
        local coords = GetEntityCoords(playerPed)
        local distance = #(coords - vector3(k.pos.x, k.pos.y, k.pos.z))
        if distance > tonumber(k.size / 2) + 0.4 then
            return false
        end
    end
end

function afkCheckNpc()
    local Keys = {W = 32, A = 34, S = 33, D = 35}
    local inChecking = true
    local totalKeys = 0
    for i, v in pairs(Keys) do
        totalKeys = totalKeys + 1
    end
    local randomKey = math.random(1, totalKeys)
    local keyName = nil
    local keyId = nil
    local count = 0
    for i, v in pairs(Keys) do
        count = count + 1
        if count == randomKey then
            keyName = i
            keyId = v
            break
        end
    end
    while inChecking and sellStarted do
        Citizen.Wait(0)
        ESX.ShowHelpNotification(_U('press_continue', keyName))
        DisableControlAction(0, 30, true)
        DisableControlAction(0, 31, true)
        if IsDisabledControlJustReleased(0, keyId) then
            return true
        end
    end
end

function CreateBlip()
    for i, v in pairs(Config.Blips) do
        if v and v.enable then
            local coords = v.pos
            local radius = v.radius
            local blipRd = AddBlipForRadius(coords, radius)
            SetBlipHighDetail(blipRd, true)
            SetBlipColour(blipRd, v.color)
            SetBlipAlpha (blipRd, 128)
            SetBlipAsShortRange(blipRd, true)
            SetBlipDisplay(blipRd, 3)
            local blip = AddBlipForCoord(coords)
            SetBlipHighDetail(blip, true)
            SetBlipSprite (blip, v.id)
            SetBlipScale  (blip, v.size)
            SetBlipColour (blip, v.color)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(v.name)
            EndTextCommandSetBlipName(blip)
        end
    end
end

function playAnim(dir, anim, blendIn, blendOut, duration, flag, playbackRate)
    local playerPed = GetPlayerPed(-1)
    RequestAnimDict(dir)
    while not HasAnimDictLoaded(dir) do
        Citizen.Wait(0)
    end
    TaskPlayAnim(playerPed, dir, anim, blendIn + 0.0, blendOut + 0.0, duration, flag, playbackRate, 0, 0, 0)
end

function drawMarker(type, posX, posY, posZ, scaleX, scaleY, scaleZ, r, g, b, a)
    DrawMarker(type, posX, posY, posZ, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, scaleX, scaleY, scaleZ, r, g, b, a, false, false, 2, false, false, false, false)
end

function tofloat(value)
    return tonumber(string.format("%.2f", value))
end

FormatCoord = function(coord)
    return tonumber(string.format("%.2f", coord))
end

toBool = function(num)
    if tonumber(num) == 1 then
        return true
    else
        return false
    end
end

DrawTxt3D = function(coords, text)
    local str = text
    AddTextEntry(GetCurrentResourceName(), str)
    BeginTextCommandDisplayHelp(GetCurrentResourceName())
    EndTextCommandDisplayHelp(2, false, false, -1)
    SetFloatingHelpTextWorldPosition(1, coords)
    SetFloatingHelpTextStyle(1, 1, 2, -1, 3, 0)
end

function GetStreet()
    local playerCoords = GetEntityCoords(PlayerPedId())
    streetName, _ = GetStreetNameAtCoord(playerCoords.x, playerCoords.y, playerCoords.z)
    playerStreet = GetStreetNameFromHashKey(streetName)
    return playerStreet
end

function getRandomOffset()
    local x = {
        [1] = 2.0,
        [2] = 2.2,
        [3] = 2.4,
        [4] = 2.6,
        [5] = 2.8,
        [6] = 3.0,
        [7] = -2.0,
        [8] = -2.2,
        [9] = -2.4,
        [10] = -2.6,
        [11] = -2.8,
        [12] = -3.0,
    }
    local y = {
        [1] = 2.0,
        [2] = 2.2,
        [3] = 2.4,
        [4] = 2.6,
        [5] = 2.8,
        [6] = 3.0,
        [7] = -2.0,
        [8] = -2.2,
        [9] = -2.4,
        [10] = -2.6,
        [11] = -2.8,
        [12] = -3.0,
    }
    return x[math.random(1,#x)], y[math.random(1,#y)]
end

Scaleforms = {}

Scaleforms.LoadMovie = function(name)
    local scaleform = RequestScaleformMovie(name)
    while not HasScaleformMovieLoaded(scaleform) do Wait(0); end
    return scaleform
end

Scaleforms.LoadInteractive = function(name)
    local scaleform = RequestScaleformMovieInteractive(name)
    while not HasScaleformMovieLoaded(scaleform) do Wait(0); end
    return scaleform
end

Scaleforms.UnloadMovie = function(scaleform)
    SetScaleformMovieAsNoLongerNeeded(scaleform)
end

Scaleforms.LoadAdditionalText = function(gxt, count)
    for i = 0, count, 1 do
        if not HasThisAdditionalTextLoaded(gxt, i) then
            ClearAdditionalText(i, true)
            RequestAdditionalText(gxt, i)
            while not HasThisAdditionalTextLoaded(gxt, i) do Wait(0); end
        end
    end
end

Scaleforms.SetLabels = function(scaleform, labels)
    PushScaleformMovieFunction(scaleform, "SET_LABELS")
    for i = 1, #labels, 1 do
        local txt = labels[i]
        BeginTextCommandScaleformString(txt)
        EndTextCommandScaleformString()
    end
    PopScaleformMovieFunctionVoid()
end

Scaleforms.PopMulti = function(scaleform, method, ...)
    PushScaleformMovieFunction(scaleform, method)
    for _, v in pairs({...}) do
        local trueType = Scaleforms.TrueType(v)
        if trueType == "string" then
            PushScaleformMovieFunctionParameterString(v)
        elseif trueType == "boolean" then
            PushScaleformMovieFunctionParameterBool(v)
        elseif trueType == "int" then
            PushScaleformMovieFunctionParameterInt(v)
        elseif trueType == "float" then
            PushScaleformMovieFunctionParameterFloat(v)
        end
    end
    PopScaleformMovieFunctionVoid()
end

Scaleforms.PopFloat = function(scaleform, method, val)
    PushScaleformMovieFunction(scaleform, method)
    PushScaleformMovieFunctionParameterFloat(val)
    PopScaleformMovieFunctionVoid()
end

Scaleforms.PopInt = function(scaleform, method, val)
    PushScaleformMovieFunction(scaleform, method)
    PushScaleformMovieFunctionParameterInt(val)
    PopScaleformMovieFunctionVoid()
end

Scaleforms.PopBool = function(scaleform, method, val)
    PushScaleformMovieFunction(scaleform, method)
    PushScaleformMovieFunctionParameterBool(val)
    PopScaleformMovieFunctionVoid()
end

Scaleforms.PopRet = function(scaleform, method)
    PushScaleformMovieFunction(scaleform, method)
    return PopScaleformMovieFunction()
end

Scaleforms.PopVoid = function(scaleform, method)
    PushScaleformMovieFunction(scaleform, method)
    PopScaleformMovieFunctionVoid()
end

Scaleforms.RetBool = function(ret)
    return GetScaleformMovieFunctionReturnBool(ret)
end

Scaleforms.RetInt = function(ret)
    return GetScaleformMovieFunctionReturnInt(ret)
end

Scaleforms.TrueType = function(val)
    if type(val) ~= "number" then return type(val); end
    local s = tostring(val)
    if string.find(s, '.') then
        return "float"
    else
        return "int"
    end
end

createInstructionalScaleform = function(controls)
    local scaleform = Scaleforms.LoadMovie('INSTRUCTIONAL_BUTTONS')
    Scaleforms.PopVoid(scaleform, 'CLEAR_ALL')
    Scaleforms.PopInt(scaleform, 'SET_CLEAR_SPACE', 200)
    for i = 1, #controls, 1 do
        PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
        PushScaleformMovieFunctionParameterInt(i - 1)
        for k = 1, #controls[i].codes, 1 do
            ScaleformMovieMethodAddParamPlayerNameString(GetControlInstructionalButton(0, controls[i].codes[k], true))
        end
        BeginTextCommandScaleformString("STRING")
        AddTextComponentScaleform(controls[i].label)
        EndTextCommandScaleformString()
        PopScaleformMovieFunctionVoid()
    end
    Scaleforms.PopVoid(scaleform, 'DRAW_INSTRUCTIONAL_BUTTONS')
    return scaleform
end

getScaleformControls = function(...)
    local res = {}
    local count = select("#", ...)
    for i = 1, count, 1 do
        local controlIndex = select(i, ...)
        local cameraControl = Config.ActionControls[controlIndex]
        table.insert(res, cameraControl)
    end
    return res
end



