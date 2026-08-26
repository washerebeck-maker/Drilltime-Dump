Config = {}

Config.Framework = 'esx' -- qbcore | esx

Config.ActionTime = 5000

Config.checkForUpdates = true

Config.InteractionType = 'points' -- Either ox_target or points (Qtarget maybe soon?)

Config.EnableWebhook = true

-- # By how many services a player's community service gets extended if he tries to escape
Config.ServiceExtensionOnEscape = 1

-- # Don't change this unless you know what you are doing.
Config.StartLocation = vector4(1680.2766, 2512.6475, 45.5648, 318.1547)

-- # Don't change this unless you know what you are doing.
Config.ReleaseLocation = vector4(433.8115, -981.6835, 30.7107, 83.0957) 

Config.ReleasePedLocation = vector4(-105.5593, 3049.8008, 30.3904, 64.4569)

Config.ReleasePrice = 350222220000

-- # Don't change this unless you know what you are doing.
Config.ServiceLocations = {
    { type = 'sweep', coords = vector4(1691.8119, 2517.5417, 45.5649, 306.8740) },
    { type = 'sweep', coords = vector4(1679.3597, 2523.1340, 45.5649, 67.9442) },
    { type = 'sweep', coords = vector4(1666.9401, 2519.6409, 45.5649, 104.0263) },
    { type = 'sweep', coords = vector4(1660.5824, 2506.6650, 45.5649, 112.4238) },
    { type = 'sweep', coords = vector4(1676.3654, 2497.1580, 45.5649, 248.0612) },
    { type = 'sweep', coords = vector4(1686.4304, 2505.2812, 45.5649, 318.1157) },
    { type = 'sweep', coords = vector4(1682.1187, 2517.0918, 45.5649, 27.2373) },
    { type = 'sweep', coords = vector4(1683.8381, 2529.5964, 45.5649, 356.7797) },
}

Config.PoliceJob = 'police'

Config.Clothes = {
    male = {
        components = {
            { ['component_id'] = 0,  ['texture'] = 0, ['drawable'] = 0 },
            { ['component_id'] = 1,  ['texture'] = 0, ['drawable'] = 0 },-- mask
            { ['component_id'] = 3,  ['texture'] = 0, ['drawable'] = 0 },-- hands
            { ['component_id'] = 4,  ['texture'] = 1, ['drawable'] = 11 },--legs
            { ['component_id'] = 5,  ['texture'] = 0, ['drawable'] = 0 },
            { ['component_id'] = 6,  ['texture'] = 0, ['drawable'] = 80 },--shoes
            { ['component_id'] = 7,  ['texture'] = 0, ['drawable'] = 0 },
            { ['component_id'] = 8,  ['texture'] = 0, ['drawable'] = 15 },--shirt
            { ['component_id'] = 9,  ['texture'] = 0, ['drawable'] = 0 },
            { ['component_id'] = 10, ['texture'] = 0, ['drawable'] = 0 },
            { ['component_id'] = 11, ['texture'] = 1, ['drawable'] = 126 }--jacket
        }
    },
    female = {
        components = {
            { ['component_id'] = 0,  ['texture'] = 0, ['drawable'] = 0 },
            { ['component_id'] = 1,  ['texture'] = 0, ['drawable'] = 0 },-- mask
            { ['component_id'] = 3,  ['texture'] = 0, ['drawable'] = 14 },-- hands
            { ['component_id'] = 4,  ['texture'] = 1, ['drawable'] = 16 },--legs
            { ['component_id'] = 5,  ['texture'] = 0, ['drawable'] = 0 },
            { ['component_id'] = 6,  ['texture'] = 9, ['drawable'] = 115 },--shoes
            { ['component_id'] = 7,  ['texture'] = 0, ['drawable'] = 0 },
            { ['component_id'] = 8,  ['texture'] = 0, ['drawable'] = 232 },--shirt
            { ['component_id'] = 9,  ['texture'] = 0, ['drawable'] = 75 },
            { ['component_id'] = 10, ['texture'] = 0, ['drawable'] = 0 },
            { ['component_id'] = 11, ['texture'] = 1, ['drawable'] = 55 }--jacket
        }
    }
}

Config.Messages = {
    [1] = " is now in jail for Drug-Related Offenses",
    [2] = " is going to jail for Physical Assault",
    [3] = " is going to jail for Violating Traffic Laws",
    [4] = " is now in jail for Robbery",
    [5] = " is now in jail for buying crack from a undercover cop.",
    [6] = " is going to jail for Sexual Assault",
    [7] = " is going to jail for Cybercrimes / Fraud",
    [8] = " is now in jail for drug dealing.",
    [9] = " is in jail for Murder/Homicide",
    [10] = " is in jail for car theft",
}


Config.Cells = {
    { coords = vector4(-70.0456, -86.7776, 0.2515, 297.0269)},
}

Config.Escape = {
    cop = {coords = vector4(-843.5417, 59.3776, 2.2581, 186.0977), model = "s_m_y_sheriff_01"},
    espace_coords = vector4(718.4636, 1580.5688, 2.7146, 269.6691),
    price = 15000,
    msg = "Fugitive name name broke out of jail all police be on lookout ."
}

Config.ItemsToRemove = {
    In = {"WEAPON_SHANKCMG", "WEAPON_SHANKCMGTWO"},
    Out = {"k2drgxnew", "WEAPON_SHANKCMG", "WEAPON_SHANKCMGTWO"},
}

Config.WhitelistedWeapons = {"WEAPON_SHANKCMG", "WEAPON_SHANKCMGTWO"}