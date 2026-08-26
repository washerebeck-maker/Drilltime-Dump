local g_passive_mode = false
local g_last_weapon_warn = 0
local g_dialog_promise = nil

local function is_new_player()
    return lib.callback.await('elder_newplayers:server:is_new_player', false)
end

local function show_passive_ui(state)
    SendNUIMessage({
        action = 'passiveState',
        data = { open = state }
    })
end

local function warn_weapon_locked()
    local now = GetGameTimer()
    if now - g_last_weapon_warn < 4000 then return end
    g_last_weapon_warn = now
    SendNUIMessage({
        action = 'weaponWarning',
        data = { open = true }
    })
end

local function confirm_dialog(data)
    if g_dialog_promise then return false end
    g_dialog_promise = promise.new()
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'confirmDialog',
        data = data
    })
    return Citizen.Await(g_dialog_promise)
end

RegisterNUICallback('dialogResponse', function(data, cb)
    SetNuiFocus(false, false)
    if g_dialog_promise then
        local p = g_dialog_promise
        g_dialog_promise = nil
        p:resolve(data and data.confirmed == true)
    end
    cb(1)
end)

RegisterNetEvent('elder_newplayers:client:notify', function(data)
    SendNUIMessage({
        action = 'notify',
        data = data
    })
end)

local function start_thread()
    SetEntityInvincible(cache.ped, true)
    CreateThread(function()
        while g_passive_mode do
            if IsPedArmed(cache.ped, 7) then
                TriggerEvent('ox_inventory:disarm', true)
                warn_weapon_locked()
            end
            Wait(500)
        end
    end)
end

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
   g_passive_mode = is_new_player()
   if g_passive_mode then
        show_passive_ui(true)
        start_thread()
   end
end)

RegisterNetEvent('esx:onPlayerDeath')
AddEventHandler('esx:onPlayerDeath', function(data)
    if g_passive_mode then
        TriggerEvent('esx_ambulancejob:revive_deathmatch')
    end
end)


RegisterNetEvent('elder_newplayers:client:disable_passive_mode', function()
    SetEntityInvincible(cache.ped, false)
    g_passive_mode = false
    show_passive_ui(false)
end)

RegisterNetEvent('elder_newplayers:client:enable_passive_mode', function()
    if not g_passive_mode then
        g_passive_mode = true
        show_passive_ui(true)
        start_thread()
    end
end)


RegisterCommand('passive', function()
    if g_passive_mode then
        local confirmed = confirm_dialog({
            title = 'Disable Passive Mode?',
            message = "Once your shield is down, it's down for good. Make sure you've got a weapon, a car, and a plan before you step into the open.",
            confirmLabel = 'Disable',
            cancelLabel = 'Stay Safe'
        })
        if confirmed then
            TriggerServerEvent('elder_newplayers:server:disable_passive_mode')
            SetEntityInvincible(cache.ped, false)
            g_passive_mode = false
            show_passive_ui(false)
        end
    end
end)