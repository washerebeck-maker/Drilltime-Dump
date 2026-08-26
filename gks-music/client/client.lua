-- gks-music :: client
-- Mirrors the server's broadcast list, drives xsound, and answers the phone app.
--
-- Every listener runs this independently, which is the whole point: the volume
-- you hear is computed on your machine, so you can turn someone down or mute
-- them outright without touching what anyone else hears.

local Broadcasts = {}   -- [ownerId] = broadcast from the server
local Sounds     = {}   -- [ownerId] = { url, stamp, createdAt }
local Local      = { master = 1.0, muteAll = false, muted = {} }

local KVP_KEY = 'gksmusic:settings'

local function debug(...)
    if Config.Debug then print('[gks-music]', ...) end
end

--#region local settings

local function loadSettings()
    local raw = GetResourceKvpString(KVP_KEY)
    if not raw then return end

    local ok, data = pcall(json.decode, raw)
    if not ok or type(data) ~= 'table' then return end

    Local.master  = tonumber(data.master) or 1.0
    Local.muteAll = data.muteAll == true
    Local.muted   = type(data.muted) == 'table' and data.muted or {}
end

local function saveSettings()
    SetResourceKvp(KVP_KEY, json.encode({
        master  = Local.master,
        muteAll = Local.muteAll,
        muted   = Local.muted,
    }))
end

--#endregion

--#region helpers

local function soundName(owner)
    return 'gksmusic_' .. tostring(owner)
end

local function xsoundReady()
    return GetResourceState('xsound') == 'started'
end

-- xsound indexes its internal table without nil checking, so calling Position,
-- setVolume, Distance or setTimeStamp on a sound it does not know about throws.
-- Everything goes through this.
local function withSound(owner, fn)
    if not xsoundReady() then return end

    local name = soundName(owner)
    if not exports.xsound:soundExists(name) then return end

    fn(name)
end

local function ownerPed(owner)
    local player = GetPlayerFromServerId(tonumber(owner) or -1)
    if player == -1 then return nil end

    local ped = GetPlayerPed(player)
    if not ped or ped == 0 or not DoesEntityExist(ped) then return nil end

    return ped
end

local function isMine(owner)
    return tonumber(owner) == GetPlayerServerId(PlayerId())
end

-- Elapsed seconds, extrapolated from the last sync so the progress bar moves
-- smoothly instead of stepping once per server update.
local function elapsedOf(bc)
    if not bc then return 0 end
    if bc.paused then return bc.elapsed or 0 end

    return (bc.elapsed or 0) + ((GetGameTimer() - (bc.syncedAt or GetGameTimer())) / 1000)
end

-- What this specific listener should hear. xsound applies distance falloff on
-- top of whatever we set here.
local function listenVolume(bc)
    local base = (bc.volume or Config.DefaultBroadcastVolume) * (Local.master or 1.0)

    if not isMine(bc.owner) then
        if Local.muteAll then return 0.0 end
        if Local.muted[tostring(bc.owner)] then return 0.0 end
    end

    return math.max(0.0, math.min(1.0, base))
end

local function destroySound(owner)
    if not xsoundReady() then
        Sounds[owner] = nil
        return
    end

    local name = soundName(owner)
    if exports.xsound:soundExists(name) then
        exports.xsound:Destroy(name)
    end

    Sounds[owner] = nil
end

local function destroyAll()
    for owner in pairs(Sounds) do
        destroySound(owner)
    end
end

--#endregion

--#region playback

local function startSound(bc, coords)
    local name = soundName(bc.owner)

    exports.xsound:PlayUrlPos(name, bc.url, listenVolume(bc), coords, false)
    Sounds[bc.owner] = { url = bc.url, stamp = bc.stamp, createdAt = GetGameTimer() }

    withSound(bc.owner, function(n)
        exports.xsound:Distance(n, bc.range or Config.DefaultRange)
    end)

    debug('started', name, bc.url)

    -- Join a track already in progress, and hand the real duration back to the
    -- server once xsound has actually loaded it.
    local owner, stamp, wantSeek = bc.owner, bc.stamp, elapsedOf(bc)

    CreateThread(function()
        local deadline = GetGameTimer() + 10000

        while GetGameTimer() < deadline do
            Wait(200)

            local mine = Sounds[owner]
            if not mine or mine.stamp ~= stamp then return end

            local duration = 0
            withSound(owner, function(n)
                duration = exports.xsound:getMaxDuration(n) or 0
            end)

            if duration > 0 then
                if wantSeek > 3 and wantSeek < duration then
                    withSound(owner, function(n)
                        exports.xsound:setTimeStamp(n, wantSeek)
                    end)
                end

                if isMine(owner) then
                    TriggerServerEvent('gks-music:reportDuration', duration)
                end
                return
            end
        end
    end)
end

CreateThread(function()
    loadSettings()
    Wait(1500)
    TriggerServerEvent('gks-music:requestSync')

    while true do
        Wait(Config.UpdateInterval)

        if not xsoundReady() then goto continue end

        -- Respect xsound's streamer mode rather than fighting it.
        if exports.xsound:isPlayerInStreamerMode() then
            destroyAll()
            goto continue
        end

        local myPed = PlayerPedId()
        local myCoords = GetEntityCoords(myPed)

        for owner, bc in pairs(Broadcasts) do
            local ped = ownerPed(owner)

            if not ped then
                -- Owner is not streamed in, so there is nothing to hear anyway.
                if Sounds[owner] then destroySound(owner) end
            else
                local coords = GetEntityCoords(ped)
                local distance = #(myCoords - coords)
                local audible = distance < (bc.range or Config.DefaultRange) + 40.0
                local active = Sounds[owner]

                if not audible then
                    if active then destroySound(owner) end
                elseif not active or active.stamp ~= bc.stamp or active.url ~= bc.url then
                    if active then destroySound(owner) end
                    startSound(bc, coords)
                else
                    withSound(owner, function(n)
                        exports.xsound:Position(n, coords)
                        exports.xsound:setVolume(n, listenVolume(bc))
                        exports.xsound:Distance(n, bc.range or Config.DefaultRange)

                        if bc.paused and exports.xsound:isPlaying(n) then
                            exports.xsound:Pause(n)
                        elseif not bc.paused and exports.xsound:isPaused(n) then
                            exports.xsound:Resume(n)
                        end
                    end)

                    -- xsound deletes a sound when the track runs out. Only the
                    -- owner reports that, and only for a sound old enough that
                    -- it cannot just be mid load.
                    if isMine(owner) and not bc.paused
                        and (GetGameTimer() - active.createdAt) > 5000
                        and not exports.xsound:soundExists(soundName(owner)) then
                        Sounds[owner] = nil
                        TriggerServerEvent('gks-music:finished')
                    end
                end
            end
        end

        ::continue::
    end
end)

--#endregion

--#region server sync

RegisterNetEvent('gks-music:sync', function(payload)
    local incoming = {}
    local now = GetGameTimer()

    for _, bc in ipairs(payload or {}) do
        bc.syncedAt = now
        incoming[bc.owner] = bc
    end

    -- Anyone who stopped gets torn down here.
    for owner in pairs(Broadcasts) do
        if not incoming[owner] then destroySound(owner) end
    end

    Broadcasts = incoming
end)

RegisterNetEvent('gks-music:error', function(message)
    SendNUIMessage({ event = 'gksmusic:error', message = message })
    pcall(function()
        exports['gksphone']:NuiSendMessage({ event = 'gksmusic:error', message = message })
    end)
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    destroyAll()
end)

--#endregion

--#region app registration

-- Registration lives on the client because some gksphone v2 builds only expose
-- AddCustomApp as a client export; calling the server-side one on those builds
-- throws "No such export AddCustomApp in resource gksphone". Client-side works
-- on both old and current builds.
CreateThread(function()
    while GetResourceState('gksphone') ~= 'started' do
        Wait(500)
    end
    Wait(2000) -- give the phone NUI a moment to finish booting

    local resource = GetCurrentResourceName()

    local labels = {}
    for _, lang in ipairs({
        'af', 'ar', 'cs', 'de', 'en', 'es', 'fr', 'id', 'nl',
        'pt-PT', 'ro', 'sv', 'th', 'tr', 'uk', 'zh-TW',
    }) do
        labels[lang] = Config.AppLabel
    end

    local appData = {
        name        = 'gksmusic',
        icons       = ('https://cfx-nui-%s/%s'):format(resource, Config.AppIcon),
        categori    = 'mix',
        description = Config.AppDescription,
        appurl      = ('https://cfx-nui-%s/ui/index.html'):format(resource),
        url         = '/customapp',
        blockedjobs = Config.BlockedJobs,
        allowjob    = Config.AllowedJobs,
        -- false on purpose: the audio pipeline is ours, not the phone's network
        -- sim, so a signal-zone setup must never be able to hide the app.
        signal      = false,
        show        = true,                          -- listed in the App Store
        startapp    = Config.AutoAddToHomeScreen,    -- and put straight on the home screen
        labelLangs  = labels,
    }

    -- gksphone builds before the v2 custom-app system (roughly pre-2.x) never
    -- expose AddCustomApp at all, and calling a missing export always fails
    -- immediately on the first try, never intermittently. So there is nothing
    -- to gain from retrying: either it works now, or this build doesn't have
    -- it and never will until gksphone itself is updated.
    local ok, err = pcall(function()
        exports['gksphone']:AddCustomApp(appData)
    end)

    if ok then
        print(('[gks-music] "%s" registered with the phone via AddCustomApp.'):format(Config.AppLabel))
        return
    end

    if tostring(err):find('No such export') then
        print(('^3[gks-music] This gksphone build has no AddCustomApp export, so "%s" was not auto-registered.^0'):format(Config.AppLabel))
        print('^3[gks-music] This is normal on older gksphone versions. Add the app manually instead: see README.md, "Older gksphone (no AddCustomApp)".^0')
    else
        print('^1[gks-music] AddCustomApp exists but threw an error: ' .. tostring(err) .. '^0')
    end
end)

--#endregion

--#region phone app bridge

local function snapshot()
    local myId = GetPlayerServerId(PlayerId())
    local myCoords = GetEntityCoords(PlayerPedId())
    local mine = Broadcasts[myId]

    local me = { playing = false }
    if mine then
        me = {
            playing  = true,
            paused   = mine.paused == true,
            title    = mine.title,
            author   = mine.author,
            art      = mine.art,
            url      = mine.url,
            volume   = mine.volume,
            range    = mine.range,
            elapsed  = elapsedOf(mine),
            duration = mine.duration or 0,
        }
    end

    local nearby = {}
    for owner, bc in pairs(Broadcasts) do
        if owner ~= myId then
            local ped = ownerPed(owner)
            if ped then
                local range = bc.range or Config.DefaultRange
                local distance = #(myCoords - GetEntityCoords(ped))

                -- The tab is called "who you can hear", so only list people
                -- whose music actually reaches this player.
                if distance <= range then
                    nearby[#nearby + 1] = {
                        owner    = owner,
                        name     = bc.name,
                        title    = bc.title,
                        author   = bc.author,
                        art      = bc.art,
                        url      = bc.url,
                        paused   = bc.paused == true,
                        distance = math.floor(distance + 0.5),
                        range    = range,
                        muted    = Local.muted[tostring(owner)] == true,
                    }
                end
            end
        end
    end

    table.sort(nearby, function(a, b) return a.distance < b.distance end)

    return {
        ready    = xsoundReady(),
        label    = Config.AppLabel,
        me       = me,
        nearby   = nearby,
        settings = { master = Local.master, muteAll = Local.muteAll },
        limits   = {
            minRange = Config.MinRange,
            maxRange = Config.MaxRange,
        },
    }
end

-- GKSPHONE fires this every time the app is opened.
RegisterNUICallback('getInfo', function(_, cb)
    TriggerServerEvent('gks-music:requestSync')
    cb(snapshot())
end)

RegisterNUICallback('getState', function(_, cb)
    cb(snapshot())
end)

RegisterNUICallback('play', function(data, cb)
    TriggerServerEvent('gks-music:play', data and data.url)
    cb('ok')
end)

RegisterNUICallback('stop', function(_, cb)
    TriggerServerEvent('gks-music:stop')
    cb('ok')
end)

RegisterNUICallback('togglePause', function(_, cb)
    TriggerServerEvent('gks-music:togglePause')
    cb('ok')
end)

RegisterNUICallback('setBroadcastVolume', function(data, cb)
    TriggerServerEvent('gks-music:setVolume', tonumber(data and data.value) or Config.DefaultBroadcastVolume)
    cb('ok')
end)

RegisterNUICallback('setRange', function(data, cb)
    TriggerServerEvent('gks-music:setRange', tonumber(data and data.value) or Config.DefaultRange)
    cb('ok')
end)

RegisterNUICallback('setMaster', function(data, cb)
    Local.master = math.max(0.0, math.min(1.0, tonumber(data and data.value) or 1.0))
    saveSettings()
    cb('ok')
end)

RegisterNUICallback('setMuteAll', function(data, cb)
    Local.muteAll = (data and data.value) == true
    saveSettings()
    cb('ok')
end)

RegisterNUICallback('setMuted', function(data, cb)
    if data and data.owner then
        local key = tostring(data.owner)
        Local.muted[key] = (data.value == true) or nil
        saveSettings()
    end
    cb('ok')
end)

-- Stops the player walking off while they are typing a link.
--
-- InputChange takes "is the phone's own input handling active", which is the
-- INVERSE of "the user is typing". GKSPHONE's own docs and template do
-- onfocus -> false, onblur -> true. Passing this the wrong way round leaves
-- input handling switched off, and the player can no longer close the phone.
RegisterNUICallback('inputFocus', function(data, cb)
    local typing = (data and data.focused) == true

    pcall(function()
        exports['gksphone']:InputChange(not typing)
    end)

    cb('ok')
end)

--#endregion
