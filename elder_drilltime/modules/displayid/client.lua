local PlayerGangs = {}
local HidePlayersId = false
local RadioMembers = {}
local playerGamerTags = {}

local TAG_NAME = 0
local TAG_HEALTHARMOUR = 2
local TAG_AUDIOICON = 4

local RADIO_DRAW_DISTANCE = 150

CreateThread(function()
    while true do
        local ok, list = pcall(function() return exports.radiolist:getPlayersInRadio() end)
        RadioMembers = (ok and type(list) == 'table') and list or {}
        Wait(2000)
    end
end)

CreateThread(function()
    if ESX.IsPlayerLoaded() then
        TriggerServerEvent('elder_drilltime:displayid:server:onPlayerLoaded')
    end
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function()
    TriggerServerEvent('elder_drilltime:displayid:server:onPlayerLoaded')
end)

RegisterNetEvent('elder_drilltime:displayid:server:updatePlayersGang')
AddEventHandler('elder_drilltime:displayid:server:updatePlayersGang', function(data)
    PlayerGangs = data
end)

function DrawText3DTag(coords, text, color)
    SetDrawOrigin(coords, 0)
    SetTextColour(250, 250, 250, 250)
    SetTextScale(0.0, 1.0 * 0.55)
    SetTextFont(4)
    SetTextColour(color.r, color.g, color.b, 255)
    SetTextDropshadow(0, 0, 0, 0, 255)
    SetTextEdge(2, 0, 0, 0, 150)
    SetTextOutline()
    SetTextCentre(1)
    SetTextProportional(1)
    SetTextDropShadow()
    SetTextCentre(true)
    BeginTextCommandDisplayText("STRING")
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayText(0.0, 0.0)
    ClearDrawOrigin()
end

CreateThread(function()
    while not ESX.IsPlayerLoaded() do Wait(10) end
    while true do
        if not HidePlayersId then
            local coords = GetEntityCoords(PlayerPedId())
            local allActivePlayers = GetActivePlayers()
            for _, pid in ipairs(allActivePlayers) do
                local player_ped = GetPlayerPed(pid)
                if player_ped ~= GetPlayerPed(-1) then
                    local playerId = GetPlayerServerId(pid)
                    if RadioMembers[playerId] then goto continue end
                    local player_coords = GetEntityCoords(player_ped)
                    if GetDistanceBetweenCoords(coords, player_coords, true) > 6 then goto continue end
                    x2, y2, z2 = table.unpack(GetPedBoneCoords(player_ped, 0x796e))
                    z2 = z2 + 0.5
                    local color = {r=127,g=0,b=255}
                    if NetworkIsPlayerTalking(pid) then
                        color = {r=255,g=255,b=255}
                    end
                    local gang = PlayerGangs[playerId] and (' - %s'):format(PlayerGangs[playerId]) or ''
                    local displayedMessage = playerId .. gang
                    DrawText3DTag(vector3(x2, y2, z2), displayedMessage, color)
                end
                ::continue::
            end
        end
        Wait(1)
    end
end)

local function removeTagFor(pid)
    local entry = playerGamerTags[pid]
    if not entry then return end
    if IsMpGamerTagActive(entry.gamerTag) then
        RemoveMpGamerTag(entry.gamerTag)
    end
    playerGamerTags[pid] = nil
end

local function cleanAllGamerTags()
    for pid in pairs(playerGamerTags) do
        removeTagFor(pid)
    end
end

local function ensureTag(pid, ped, serverId)
    local entry = playerGamerTags[pid]
    if entry and entry.ped == ped and entry.serverId == serverId and IsMpGamerTagActive(entry.gamerTag) then
        return entry.gamerTag
    end
    if entry and IsMpGamerTagActive(entry.gamerTag) then
        RemoveMpGamerTag(entry.gamerTag)
    end
    local label = ('%s [%s]'):format(GetPlayerName(pid), serverId)
    playerGamerTags[pid] = {
        gamerTag = CreateFakeMpGamerTag(ped, label, false, false, 0),
        ped = ped,
        serverId = serverId,
    }
    return playerGamerTags[pid].gamerTag
end

local function paintTag(tag, pid)
    SetMpGamerTagVisibility(tag, TAG_NAME, 1)
    SetMpGamerTagHealthBarColor(tag, 6)
    SetMpGamerTagAlpha(tag, TAG_HEALTHARMOUR, 255)
    SetMpGamerTagVisibility(tag, TAG_HEALTHARMOUR, 1)
    SetMpGamerTagAlpha(tag, TAG_AUDIOICON, 255)
    if NetworkIsPlayerTalking(pid) then
        SetMpGamerTagVisibility(tag, TAG_AUDIOICON, true)
        SetMpGamerTagColour(tag, TAG_AUDIOICON, 12)
        SetMpGamerTagColour(tag, TAG_NAME, 12)
    else
        SetMpGamerTagVisibility(tag, TAG_AUDIOICON, false)
        SetMpGamerTagColour(tag, TAG_AUDIOICON, 0)
        SetMpGamerTagColour(tag, TAG_NAME, 0)
    end
end

local function hideTag(tag)
    SetMpGamerTagVisibility(tag, TAG_NAME, 0)
    SetMpGamerTagVisibility(tag, TAG_HEALTHARMOUR, 0)
    SetMpGamerTagVisibility(tag, TAG_AUDIOICON, 0)
end

CreateThread(function()
    while true do
        if HidePlayersId then
            cleanAllGamerTags()
            Wait(500)
        else
            local myPed = PlayerPedId()
            local myCoords = GetEntityCoords(myPed)
            local activePlayers = GetActivePlayers()
            local seen = {}

            for _, pid in ipairs(activePlayers) do
                local ped = GetPlayerPed(pid)
                if ped ~= myPed then
                    local serverId = GetPlayerServerId(pid)
                    if RadioMembers[serverId] then
                        seen[pid] = true
                        local tag = ensureTag(pid, ped, serverId)
                        local dist = #(GetEntityCoords(ped) - myCoords)
                        if dist <= RADIO_DRAW_DISTANCE then
                            paintTag(tag, pid)
                        else
                            hideTag(tag)
                        end
                    end
                end
            end

            for pid in pairs(playerGamerTags) do
                if not seen[pid] then
                    removeTagFor(pid)
                end
            end

            Wait(250)
        end
    end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        cleanAllGamerTags()
    end
end)

RegisterCommand('hideid', function()
    HidePlayersId = not HidePlayersId
    if HidePlayersId then
        StartCountDown()
    end
end)

RegisterKeyMapping('hideid', 'Hide/Display Players IDs', 'keyboard', 'F5')

function StartCountDown()
    local Counter = 45
    CreateThread(function()
        while HidePlayersId and Counter > 0 do
            Wait(1000)
            Counter = Counter - 1
        end
        HidePlayersId = false
    end)
end
