local iplLoaded = false

local settings = {
    ipls = {
        { id = 'casino1', ipl = 'k4mb1_casino1_milo_', position = vector3(939.1166, 23.05949, 80.79772) },
        { id = 'casino2', ipl = 'k4mb1_casino2_milo_', position = vector3(965.5146, 52.25026, 83.01856),
          entitySets = {
              k4_luckywheel = true, 
              k4_luckywheel2 = false, 
              k4_gamble2_poker_tables = true,
              k4_gamble3_poker_tables = true, 
              k4_k4casinogaming_poker_tables = true,
              k4_k4casinocashier_tables = true, 
              k4_k4casinomain_tables = true,
              k4_k4casinomain_slotmachine = true, 
              k4_big_poker_table = true,
              k4_big_poker_table_appetizers = true,
          }
        },
        { id = 'casino3', ipl = 'k4mb1_casino3_milo_', position = vector3(957.2334, 37.21077, 97.71499) },
        { id = 'casino4', ipl = 'k4mb1_casino4_milo_', position = vector3(966.0747, 48.36978, 113.10854) },
        { id = 'casino5', ipl = 'k4mb1_casino5_milo_', position = vector3(960.9944, 28.87757, 74.43959),
          entitySets = { 
            k4_display = true, 
            k4_trollys = true, 
            k4_paintings = true 
          }
        },
        { id = 'casino6', ipl = 'k4mb1_casino6_milo_', position = vector3(957.7612, 31.35768, 105.2141),
          entitySets = { 
            k4_number = true 
          }
        },
        { id = 'casino7', ipl = 'k4mb1_casino7_milo_', position = vector3(957.7612, 31.35768, 101.106) },
        { id = 'casino8', ipl = 'k4mb1_casino8_milo_', position = vector3(913.2510, -2.53473, 107.1101) },
        { id = 'casino9', ipl = 'k4mb1_casino9_milo_', position = vector3(964.8596, 6.09291, 81.63757) }
    },
    emitters = {
        { enabled = false, name = 'se_vw_dlc_casino_exterior_main_entrance' },
        { enabled = false, name = 'se_h4_dlc_int_02_h4_entrance_doorway' },
        { enabled = false, name = 'dlc_h4_se_safe_codes_penthouse_music_lounge' },
        { enabled = false, name = 'se_vw_dlc_casino_apart_apart_lounge_room_radio' },
        { enabled = false, name = 'dlc_h4_se_safe_codes_penthouse_music_entryway' },
        { enabled = false, name = 'se_vw_dlc_casino_apart_apart_party_music_03' },
        { enabled = false, name = 'se_vw_dlc_casino_apart_apart_party_music_02' },
        { enabled = false, name = 'dlc_h4_se_safe_codes_penthouse_music' },
        { enabled = false, name = 'se_vw_dlc_casino_apart_apart_default_room_radio' },
        { enabled = false, name = 'se_vw_dlc_casino_apart_apart_arcade_room_radio' }
    },
    sounds = {
        { name = 'iz_k4mb1_casino2_col_k4casinomain', enabled = true, forceUpdate = true }
    }
}

-- Load an IPL and manage entity sets and interior refresh
local function loadIPL(iplData)
    RequestIpl(iplData.ipl)
    Wait(50)  -- Reduced wait time for smoother execution

    local interiorId = GetInteriorAtCoords(iplData.position.x, iplData.position.y, iplData.position.z)
    if iplData.entitySets then
        for entitySet, enabled in pairs(iplData.entitySets) do
            if enabled then
                ActivateInteriorEntitySet(interiorId, entitySet)
            else
                DeactivateInteriorEntitySet(interiorId, entitySet)
            end
        end
    end
    RefreshInterior(interiorId)
end

-- Load all settings (IPLs, Emitters, Sounds)
local function loadAllSettings()
    for _, iplData in ipairs(settings.ipls) do
        loadIPL(iplData)
    end
    for _, emitter in ipairs(settings.emitters) do
        SetStaticEmitterEnabled(emitter.name, emitter.enabled)
    end
    for _, sound in ipairs(settings.sounds) do
        SetAmbientZoneState(sound.name, sound.enabled, sound.forceUpdate)
    end
end

-- Framework detection
local function detectFramework()
    local resources = { 'qb-core', 'es_extended', 'vrp', 'qbox' }
    for _, res in ipairs(resources) do
        if GetResourceState(res) == 'started' then
            return res
        end
    end
    return 'standalone'
end

-- Register events based on framework
local function registerFrameworkEvents()
    local framework = detectFramework()
    local eventMap = {
        ['qb-core'] = 'QBCore:Client:OnPlayerLoaded',
        ['es_extended'] = 'esx:playerLoaded',
        ['vrp'] = 'vRP:playerSpawn',
        ['qbx_core'] = 'QBCore:Client:OnPlayerLoaded',
        ['standalone'] = 'playerSpawned'
    }

    RegisterNetEvent(eventMap[framework])
    AddEventHandler(eventMap[framework], function()
        Wait(500)  -- Reduced wait time
        iplLoaded = true
        loadAllSettings()
    end)
end

-- Command to reload IPLs
RegisterCommand('reloadIPLs', function()
    iplLoaded = false
    loadAllSettings()
end, false)

-- Initialize
registerFrameworkEvents()
