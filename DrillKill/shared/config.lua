Config = {}
Config.Debug = false
Config.MenuKeybinding = 'f11' -- Key to open the gore settings menu

-- ========================
-- GORE SYSTEM CONFIGURATION
-- ========================
Config.playerGore = true        -- Enable or disable player gore effects
Config.npcGore = true          -- Enable or disable NPC gore effects
Config.bloodSplatter = true   -- Enable or disable blood splatter effects
Config.shootDead = true         -- Allow shooting dead peds to cause gore effects
Config.painSystem = true       -- Enable or disable pain system for peds

-- ========================
-- DEAD PED SCANNING CONFIG
-- ========================
Config.scanRange = 50.0        -- Range to scan for dead peds (in meters)
Config.scanInterval = 1000     -- How often to scan for dead peds (milliseconds)
Config.movementThreshold = 10.0 -- Only scan if player moved this distance

-- ========================
-- Performance Stuff
-- ========================
Config.cleanupInterval = 5000   -- How often to clean up invalid entities (milliseconds)
Config.tickRate = 0   -- tickRate for the main loop 

-- ========================
-- HEADLESS SYSTEM CONFIG
-- ========================
Config.headCapDistance = 300.0     -- Distance to render head caps
Config.nearbyDistance = 300.0      -- Distance for nearby headshot effects

-- ========================
-- SERVER CLEANUP CONFIG
-- ========================
Config.autoCleanup = true           -- Enable automatic server cleanup
Config.cleanupInterval = 60         -- Cleanup interval in minutes (default: 60 minutes)
-- ========================
-- GORE WEAPONS CONFIG
-- ========================

Config.PedModelsToIgnore = { -- List of ped models to ignore for gore effects
    [`a_c_boar`] = true,
    [`a_c_cat_01`] = true,
    [`a_c_chickenhawk`] = true,
    [`a_c_chimp`] = true,
    [`a_c_chop`] = true,
    [`a_c_cormorant`] = true,
    [`a_c_cow`] = true,
    [`a_c_coyote`] = true,
    [`a_c_crow`] = true,
    [`a_c_deer`] = true,
    [`a_c_dolphin`] = true,
    [`a_c_fish`] = true,
    [`a_c_hen`] = true,
    [`a_c_humpback`] = true,
    [`a_c_husky`] = true,
    [`a_c_killerwhale`] = true,
    [`a_c_mtlion`] = true,
    [`a_c_pig`] = true,
    [`a_c_pigeon`] = true,
    [`a_c_poodle`] = true,
    [`a_c_pug`] = true,
    [`a_c_rabbit_01`] = true,
    [`a_c_rat`] = true,
    [`a_c_retriever`] = true,
    [`a_c_rhesus`] = true,
    [`a_c_rottweiler`] = true,
    [`a_c_seagull`] = true,
    [`a_c_sharkhammer`] = true,
    [`a_c_sharktiger`] = true,
    [`a_c_shepherd`] = true,
    [`a_c_stingray`] = true,
    [`a_c_westy`] = true,
    
}

Config.goreWeapons = { -- Weapons that cause gore effects
    -- Handguns
    [`WEAPON_LONEFNX`] = true,
    [`WEAPON_M82`] = true,
    [`WEAPON_DRACOBLACKGMSHOP`] = true,
    [`WEAPON_GFLEXGLOCK17`] = true
}

