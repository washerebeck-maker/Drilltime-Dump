-- Killfeed: X kills Y with Weapon Z — ESX + ox_inventory, players only

local CEventNetworkEntityDamageArgsIndex = { fatal = 6, weapon = 7 }
local recentDeaths = {}
local IsActivated = true

local function AddKill(idx, killer, victim, weaponLabel)
    SendNUIMessage({
        action = "ADD_KILL",
        data = { id = idx, killer = killer, victim = victim, weapon = weaponLabel or "KILLED" }
    })
end

local function IsPlayerNearKillLocation(victimCoords)
    if not victimCoords or type(victimCoords) ~= "table" then return true end
    local x, y, z = victimCoords.x, victimCoords.y, victimCoords.z
    if not x or not y or not z then return true end
    local myCoords = GetEntityCoords(PlayerPedId())
    local killPos = vector3(x, y, z)
    return #(myCoords - killPos) <= Config.KillFeedZoneRadius
end

local function ProcessDeath(killerPed, victimPed)
    if not DoesEntityExist(killerPed) then return end

    local killer = {}
    if killerPed == -1 then
        killer.netId = 0
    else
        killer.netId = PedToNet(killerPed)
        if not IsPedAPlayer(killerPed) then return end
        killer.type = "player"
        killer.sourceId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(killerPed))
    end

    local victim = {}
    victim.netId = PedToNet(victimPed)
    if not IsPedAPlayer(victimPed) then return end
    victim.type = "player"
    victim.sourceId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(victimPed))

    local weaponName = "killed"
    if killerPed == PlayerPedId() then
        local cw = exports.ox_inventory:getCurrentWeapon()
        if cw and cw.name then weaponName = cw.name end
    end

    local victimCoords = GetEntityCoords(victimPed)
    TriggerServerEvent('killfeed:server:AddKill', killer, victim, weaponName, {
        x = victimCoords.x,
        y = victimCoords.y,
        z = victimCoords.z
    })
end

local function OnEntityDamage(args)
    if args[CEventNetworkEntityDamageArgsIndex.fatal] == 0 then return end

    local victim = args[1]
    local killer = args[2]
    if not IsEntityAPed(victim) or recentDeaths[victim] then return end

    local playerPed = PlayerPedId()
    if playerPed == killer or (not IsPedAPlayer(killer) and NetworkHasControlOfEntity(victim)) then
        if not IsPedAPlayer(killer) or not IsPedAPlayer(victim) then return end
        recentDeaths[victim] = true
        ProcessDeath(killer, victim)
        Wait(1000)
        recentDeaths[victim] = nil
    end
end

AddEventHandler('gameEventTriggered', function(event, args)
    if event == "CEventNetworkEntityDamage" then OnEntityDamage(args) end
end)

RegisterNetEvent('killfeed:client:AddKill')
AddEventHandler('killfeed:client:AddKill', function(idx, killer, victim, weaponLabel, victimCoords)
    if not IsActivated then return end
    if not IsPlayerNearKillLocation(victimCoords) then return end
    AddKill(idx, killer, victim, weaponLabel)
end)

RegisterNetEvent('killfeed:client:ToggleKillFeed')
AddEventHandler('killfeed:client:ToggleKillFeed', function(toggle)
    IsActivated = toggle
    if IsActivated then
        SendNUIMessage({
            action = "CONFIG",
            data = {
                showTime = Config.DisplayTimer,
                maxLines = Config.MaxKillsDisplay,
                useAutoHide = Config.UseAutoHide,
                currentPlayerId = GetPlayerServerId(PlayerId())
            }
        })
        SendNUIMessage({ action = "SET_VISIBLE", data = { visible = true } })
        CreateThread(function()
            Wait(2500)
            if GetGameBuildNumber() < 2060 then
                CEventNetworkEntityDamageArgsIndex.fatal = 4
                CEventNetworkEntityDamageArgsIndex.weapon = 5
            end
        end)
    else
        SendNUIMessage({ action = "CLOSE" })
    end
end)

RegisterNUICallback("close", function(_, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterCommand(Config.ShowKillFeedCommand, function()
    TriggerEvent('killfeed:client:ToggleKillFeed', true)
    lib.notify({ title = 'Killfeed', description = 'Killfeed enabled', type = 'success' })
end, false)

RegisterCommand(Config.HideKillFeedCommand, function()
    TriggerEvent('killfeed:client:ToggleKillFeed', false)
    lib.notify({ title = 'Killfeed', description = 'Killfeed disabled', type = 'inform' })
end, false)


RegisterCommand(Config.MoveKillFeedCommand, function()
    SetNuiFocus(true, true)
end, false)

-- Killfeed enabled by default
CreateThread(function()
    Wait(1000)
    TriggerEvent('killfeed:client:ToggleKillFeed', true)
end)
