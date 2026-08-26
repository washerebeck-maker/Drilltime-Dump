if GetCurrentResourceName() ~= "drillopti" then
    print('----------------------------------------- \n Don\'t rename drillopti \n-----------------------------------------')
    print('----------------------------------------- \n Don\'t rename drillopti \n-----------------------------------------')
    print('----------------------------------------- \n Don\'t rename drillopti \n-----------------------------------------')
    print('----------------------------------------- \n Don\'t rename drillopti \n-----------------------------------------')
    while true do 
    end 
end

local fpsSettings = {}
local isNUILoaded = false

local Wolf = {}
Wolf.GlobalSettings = {
    ["peds"] = false,
    ["vehicles"] = false,
    ["objects"] = false,
    ["particles"] = false,

    ["rain"] = false,
    ["shadows"] = false,
    ["lights"] = false,

    ["broken"] = false,
    ["unnecessary"] = false,
    ["ped"] = false,
    ["lowTexture"] = false,
}

CreateThread(function()
    Citizen.Wait(5000)
    isNUILoaded = true
    local savedSettings = GetResourceKvpString("drillopti")
    
    if savedSettings == nil then
        fpsSettings = Wolf.GlobalSettings
    else
        fpsSettings = json.decode(savedSettings)
    end
end)

CreateThread(function()
    while true do
        Citizen.Wait(1000)
        
        for option, enabled in pairs(fpsSettings) do
            if enabled then
                if option == "unnecessary" then
                    ClearBrief()
                    ClearGpsFlags()
                    ClearPrints()
                    ClearSmallPrints()
                    ClearReplayStats()
                    ClearFocus()
                    ClearHdArea()
                    LeaderboardsReadClearAll()
                    LeaderboardsClearCacheData()
                    ClearExtraTimecycleModifier()
                    ClearTimecycleModifier()
                    DisableScreenblurFade()
                end
                
                if option == "broken" then
                    ClearAllBrokenGlass()
                end
                
                if option == "ped" then
                    ClearPedBloodDamage(PlayerPedId())
                    ClearPedWetness(PlayerPedId())
                    ClearPedEnvDirt(PlayerPedId())
                    ResetPedVisibleDamage(PlayerPedId())
                end
                
                if option == "rain" then
                    SetRainLevel(0.0)
                    SetWindSpeed(0.0)
                end
            end
        end
    end
end)

CreateThread(function()
    while true do
        Citizen.Wait(100)
        
        for option, enabled in pairs(fpsSettings) do
            if enabled and option == "particles" then
                local playerCoords = GetEntityCoords(PlayerPedId())
                RemoveParticleFxInRange(playerCoords, 25.0)
            end
        end
    end
end)

CreateThread(function()
    while true do
        Citizen.Wait(0)
        
        if fpsSettings.lowTexture then
            OverrideLodscaleThisFrame(0.6)
            DisableOcclusionThisFrame()
            SetDisableDecalRenderingThisFrame()
        end
        
        if fpsSettings.lights then
            DisableVehicleDistantlights(false)
            SetFlashLightFadeDistance(3.0)
            SetLightsCutoffDistanceTweak(3.0)
            SetArtificialLightsState(true)
        end
    end
end)

RegisterNUICallback("changeOption", function(data, cb)
    fpsSettings[data.option] = data.boolean
    local shadowsEnabled = true
    local shadowScale = 1.0
    
    if fpsSettings.shadows then
        shadowsEnabled = false
        shadowScale = 0.0
    end
    
    CascadeShadowsClearShadowSampleType()
    RopeDrawShadowEnabled(shadowsEnabled)
    CascadeShadowsSetAircraftMode(shadowsEnabled)
    CascadeShadowsEnableEntityTracker(shadowsEnabled)
    CascadeShadowsSetDynamicDepthMode(shadowsEnabled)
    CascadeShadowsSetEntityTrackerScale(shadowScale)
    CascadeShadowsSetDynamicDepthValue(shadowScale)
    CascadeShadowsSetCascadeBoundsScale(shadowScale)
    
    if not fpsSettings.lights then
        SetFlashLightFadeDistance(10.0)
        SetLightsCutoffDistanceTweak(10.0)
        SetArtificialLightsState(false)
    end
    
    SetResourceKvp("drillopti", json.encode(fpsSettings))
end)

RegisterNUICallback("exitMenu", function()
    SetNuiFocus(false, false)
end)

RegisterCommand("wolf_fps_boost", function()
    if isNUILoaded then
        SetNuiFocus(true, true)
        SendNUIMessage({
            action = "openMenu",
            settings = fpsSettings
        })
    end
end)

RegisterKeyMapping(
    "wolf_fps_boost",
    "FPS optimization menu",
    "keyboard",
    Config.Key
)