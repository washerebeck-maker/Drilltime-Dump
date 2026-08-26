Config = Config or {}

-- Enables the version checher on resource start (if enabled and the resource is out of date it will print in server console)
Config.EnableVersionChecker = true

-- The derailCard position on the top of the screen (0 = right, 1 = left)
Config.detailCardMenuPosition = 0

-- The cash amount position on the top of the screen (0 = right, 1 = left)
Config.cashPosition = 0

-- If this turned off every mechanic position will be able to to cosmetics and upgrades otherwise only whitelist job can do upgrades 
Config.IsUpgradesOnlyForWhitelistJobPoints = true

-- The key to access the mechanic menu, the key code and the name can be found here: https://docs.fivem.net/docs/game-references/controls/
Config.Keys = {
    action = {key = 38, label = 'E', name = '~INPUT_PICKUP~'}
}

-- Enable this to save the vehicle properties (on apply) in database in the table `owned_vehicles` in field `vehicle`
-- by default you will need `mysql-async` (https://github.com/brouznouf/fivem-mysql-async) for the database connection (uncomment the '@mysql-async/lib/MySQL.lua' in file `fxmanifest.lua`)
-- if you want to use another library for your database connection you should modify the function `saveVehicleProperties` in file `config/server_functions.lua`
Config.AutoSaveVehiclePropertiesOnApply = true

-- The default values access disrance from position if "Config.Positions" misses the value actionDistance
Config.DefaultActionDistance = 3.0

-- The default values for the blip if "Config.Positions" misses the value "blip = {}"
Config.DefaultBlip = {
    enable = false,
    type = 72,
    color = 0,
    title = 'Mechanic',
    scale = 0.5
}

-- The default values for the marker if "Config.Positions" misses the value "marker = {}"
-- The marker will only display while you are insade a vehicle and inside the `drawDistance` of each position
--      drawDistance: the dinstance from the player that the marker will draw
--      enable: if marker will draw at all or not
--      type: the type of the marker (https://docs.fivem.net/docs/game-references/markers/)
--      positionOffset: offset from the position pos
--      direction: component of the direction vector for the marker
--      rotation: rotation for the marker. Only used if the direction vector is 0.0
--      scale: the scale for the marker
--      color: marker color r: red, g: green, b: blue, a: alpha (opacity)
--      bobUpAndDownAlways: whether or not the marker should slowly animate up/down always
--      bobUpAndDownOnAccess: whether or not the marker should slowly animate up/down only if you are in range for action
--      faceCamera: if should constantly face the camera
--      rotating: if should constantly rotating
Config.DefaultMarker = {
    drawDistance = 20.0,
    enable = false,
    type = 36,
    positionOffset = {x = 0.0, y = 0.0, z = 1.0},
    direction = {x = 0.0, y = 0.0, z = 0.0},
    rotation = {x = 0.0, y = 0.0, z = 0.0},
    scale = {x = 2.0, y = 3.0, z = 2.0},
    color = {r = 255, g = 255, b = 255, a = 100},
    bobUpAndDownAlways = false,
    bobUpAndDownOnAccess = true,
    faceCamera = false,
    rotating = true
}

-- Add or remove position for mechanic access points
-- if any position miss the property "whitelistJobName" will be open for anyone and the price will have the multiple of "Config.PriceMultiplierWithoutTheJob" in "config/prices.lua"
-- if any position miss the property "societyName" will use player cash, otherwise will use society account money (this only can be used if this point has the property "whitelistJobName") (https://github.com/esx-framework/esx_society)
-- if any position miss the property "blip = {}" will be the default as seen above "Config.DefaultBlip"
-- if any position miss the property "actionDistance" will be the default as seen above "Config.DefaultActionDistance"
Config.Positions = {
    ["mechanic1"] = {
        name = "Toro Negro",
        boss = vector3(4557.9741, -10371.7207, 793.1662),
        pos = {
            [1] = vector3(-349.3795, -131.2432, 39.0217),
            [2] = vector3(-346.9902, -124.5577, 39.0216),
            [3] = vector3(-343.1781, -113.6457, 39.0198),
            [4] = vector3(-311.8396, -102.9726, 39.0172),
            [5] = vector3(-313.7973, -107.8640, 39.0173),
            [6] = vector3(-315.6145, -113.1552, 39.0173),
            [7] = vector3(-317.4306, -118.1559, 39.0167),
            [8] = vector3(-319.3432, -123.3335, 39.0170),
            [9] = vector3(-321.1790, -128.3528, 39.0168),
            [10] = vector3(-323.1249, -133.7931, 39.0173),
            [11] = vector3(-324.9642, -139.0367, 39.0170),
            [12] = vector3(-326.7884, -144.0017, 39.0163),
            [13] = vector3(-339.1807, -95.3100, 39.0164),
            [14] = vector3(-352.2206, -90.0780, 39.0156),
            [15] = vector3(-365.0600, -85.5752, 39.0157),
            [16] = vector3(806.7008, 1256.5615, 343.8961),
        },
        whitelistJobName = 'mechanic1'
    },
    ["mechanic2"] = {
        name = "Sports Custom",
        boss = vector3(4557.9741, -10371.7207, 793.1662),
        pos = {
            [1] = vector3(-349.3795, -131.2432, 39.0217),
            [2] = vector3(-346.9902, -124.5577, 39.0216),
            [3] = vector3(-343.1781, -113.6457, 39.0198),
            [4] = vector3(-311.8396, -102.9726, 39.0172),
            [5] = vector3(-313.7973, -107.8640, 39.0173),
            [6] = vector3(-315.6145, -113.1552, 39.0173),
            [7] = vector3(-317.4306, -118.1559, 39.0167),
            [8] = vector3(-319.3432, -123.3335, 39.0170),
            [9] = vector3(-321.1790, -128.3528, 39.0168),
            [10] = vector3(-323.1249, -133.7931, 39.0173),
            [11] = vector3(-324.9642, -139.0367, 39.0170),
            [12] = vector3(-326.7884, -144.0017, 39.0163),
            [13] = vector3(-339.1807, -95.3100, 39.0164),
            [14] = vector3(-352.2206, -90.0780, 39.0156),
            [15] = vector3(-365.0600, -85.5752, 39.0157),
        },
        whitelistJobName = 'mechanic2'
    },
    ["mechanic3"] = {
        name = "Bennys",
        boss = vector3(4557.9741, -10371.7207, 793.1662),
        pos = {
            [1] = vector3(-210.8835, -1322.9670, 30.4825),
            [2] = vector3(-213.4185, -1330.3915, 30.8904),
            [3] = vector3(-221.4185, -1328.9545, 30.8904),
        },
        whitelistJobName = 'mechanic3'
    },
    ["mechanic4"] = {
        name = "Mechanic Shop",
        boss = vector3(4557.9741, -10371.7207, 793.1662),
        pos = {
            [1] = vector3(-349.3795, -131.2432, 39.0217),
            [2] = vector3(-346.9902, -124.5577, 39.0216),
            [3] = vector3(-343.1781, -113.6457, 39.0198),
            [4] = vector3(-311.8396, -102.9726, 39.0172),
            [5] = vector3(-313.7973, -107.8640, 39.0173),
            [6] = vector3(-315.6145, -113.1552, 39.0173),
            [7] = vector3(-317.4306, -118.1559, 39.0167),
            [8] = vector3(-319.3432, -123.3335, 39.0170),
            [9] = vector3(-321.1790, -128.3528, 39.0168),
            [10] = vector3(-323.1249, -133.7931, 39.0173),
            [11] = vector3(-324.9642, -139.0367, 39.0170),
            [12] = vector3(-326.7884, -144.0017, 39.0163),
            [13] = vector3(-339.1807, -95.3100, 39.0164),
            [14] = vector3(-352.2206, -90.0780, 39.0156),
            [15] = vector3(-365.0600, -85.5752, 39.0157),
        },
        whitelistJobName = 'mechanic4'
    },
    ["mechanic5"] = {
        name = "4KT",
        boss = vector3(4557.9741, -10371.7207, 793.1662),
        pos = {
            [1] = vector3(-349.3795, -131.2432, 39.0217),
            [2] = vector3(-346.9902, -124.5577, 39.0216),
            [3] = vector3(-343.1781, -113.6457, 39.0198),
            [4] = vector3(-311.8396, -102.9726, 39.0172),
            [5] = vector3(-313.7973, -107.8640, 39.0173),
            [6] = vector3(-315.6145, -113.1552, 39.0173),
            [7] = vector3(-317.4306, -118.1559, 39.0167),
            [8] = vector3(-319.3432, -123.3335, 39.0170),
            [9] = vector3(-321.1790, -128.3528, 39.0168),
            [10] = vector3(-323.1249, -133.7931, 39.0173),
            [11] = vector3(-324.9642, -139.0367, 39.0170),
            [12] = vector3(-326.7884, -144.0017, 39.0163),
            [13] = vector3(-339.1807, -95.3100, 39.0164),
            [14] = vector3(-352.2206, -90.0780, 39.0156),
            [15] = vector3(-365.0600, -85.5752, 39.0157),
        },
        whitelistJobName = 'mechanic5'
    },
    ["mechanic6"] = {
        name = "Auto Exotic",
        boss = vector3(4557.9741, -10371.7207, 793.1662),
        pos = {
            [1] = vector3(-349.3795, -131.2432, 39.0217),
            [2] = vector3(-346.9902, -124.5577, 39.0216),
            [3] = vector3(-343.1781, -113.6457, 39.0198),
            [4] = vector3(-311.8396, -102.9726, 39.0172),
            [5] = vector3(-313.7973, -107.8640, 39.0173),
            [6] = vector3(-315.6145, -113.1552, 39.0173),
            [7] = vector3(-317.4306, -118.1559, 39.0167),
            [8] = vector3(-319.3432, -123.3335, 39.0170),
            [9] = vector3(-321.1790, -128.3528, 39.0168),
            [10] = vector3(-323.1249, -133.7931, 39.0173),
            [11] = vector3(-324.9642, -139.0367, 39.0170),
            [12] = vector3(-326.7884, -144.0017, 39.0163),
            [13] = vector3(-339.1807, -95.3100, 39.0164),
            [14] = vector3(-352.2206, -90.0780, 39.0156),
            [15] = vector3(-365.0600, -85.5752, 39.0157),
        },
        whitelistJobName = 'mechanic6'
    },
    ["mechanic7"] = {
        name = "Baddies Mechshop",
        boss = vector3(4557.9741, -10371.7207, 793.1662),
        pos = {
            [1] = vector3(1134.3534, -782.6852, 57.6788),
            [2] = vector3(1139.1415, -782.6210, 57.6785),
            [3] = vector3(1143.5299, -782.6388, 57.6788),
            [4] = vector3(1148.3733, -782.5154, 57.6788),
            [5] = vector3(1154.5886, -793.2737, 57.7787),
            [6] = vector3(1158.8167, -793.3605, 57.7767),
        },
        whitelistJobName = 'mechanic7'
    },
    ["mechanic8"] = {
        name = " ",
        boss = vector3(4557.9741, -10371.7207, 793.1662),
        pos = {
            [1] = vector3(-349.3795, -131.2432, 39.0217),
            [2] = vector3(-346.9902, -124.5577, 39.0216),
            [3] = vector3(-343.1781, -113.6457, 39.0198),
            [4] = vector3(-311.8396, -102.9726, 39.0172),
            [5] = vector3(-313.7973, -107.8640, 39.0173),
            [6] = vector3(-315.6145, -113.1552, 39.0173),
            [7] = vector3(-317.4306, -118.1559, 39.0167),
            [8] = vector3(-319.3432, -123.3335, 39.0170),
            [9] = vector3(-321.1790, -128.3528, 39.0168),
            [10] = vector3(-323.1249, -133.7931, 39.0173),
            [11] = vector3(-324.9642, -139.0367, 39.0170),
            [12] = vector3(-326.7884, -144.0017, 39.0163),
            [13] = vector3(-339.1807, -95.3100, 39.0164),
            [14] = vector3(-352.2206, -90.0780, 39.0156),
            [15] = vector3(-365.0600, -85.5752, 39.0157),
        },
        whitelistJobName = 'mechanic8'
    },
    ["mechanic10"] = {
        name = " ",
        boss = vector3(4557.9741, -10371.7207, 793.1662),
        pos = {
            [1] = vector3(-349.3795, -131.2432, 39.0217),
            [2] = vector3(-346.9902, -124.5577, 39.0216),
            [3] = vector3(-343.1781, -113.6457, 39.0198),
            [4] = vector3(-311.8396, -102.9726, 39.0172),
            [5] = vector3(-313.7973, -107.8640, 39.0173),
            [6] = vector3(-315.6145, -113.1552, 39.0173),
            [7] = vector3(-317.4306, -118.1559, 39.0167),
            [8] = vector3(-319.3432, -123.3335, 39.0170),
            [9] = vector3(-321.1790, -128.3528, 39.0168),
            [10] = vector3(-323.1249, -133.7931, 39.0173),
            [11] = vector3(-324.9642, -139.0367, 39.0170),
            [12] = vector3(-326.7884, -144.0017, 39.0163),
            [13] = vector3(-339.1807, -95.3100, 39.0164),
            [14] = vector3(-352.2206, -90.0780, 39.0156),
            [15] = vector3(-365.0600, -85.5752, 39.0157),
        },
        whitelistJobName = 'mechanic10'
    },
    ["mechanic11"] = {
        name = "RED LINE",
        boss = vector3(4557.9741, -10371.7207, 793.1662),
        pos = {
            [1] = vector3(-349.3795, -131.2432, 39.0217),
            [2] = vector3(-346.9902, -124.5577, 39.0216),
            [3] = vector3(-343.1781, -113.6457, 39.0198),
            [4] = vector3(-311.8396, -102.9726, 39.0172),
            [5] = vector3(-313.7973, -107.8640, 39.0173),
            [6] = vector3(-315.6145, -113.1552, 39.0173),
            [7] = vector3(-317.4306, -118.1559, 39.0167),
            [8] = vector3(-319.3432, -123.3335, 39.0170),
            [9] = vector3(-321.1790, -128.3528, 39.0168),
            [10] = vector3(-323.1249, -133.7931, 39.0173),
            [11] = vector3(-324.9642, -139.0367, 39.0170),
            [12] = vector3(-326.7884, -144.0017, 39.0163),
            [13] = vector3(-339.1807, -95.3100, 39.0164),
            [14] = vector3(-352.2206, -90.0780, 39.0156),
            [15] = vector3(-365.0600, -85.5752, 39.0157),
            [16] = vector3(-3366.0100, 1791.5962, 25.7556),
            [17] = vector3(-1228.9567, 791.5190, 186.2216),
        },
        whitelistJobName = 'mechanic11'
    },
    ["mechanic12"] = {
        name = "GMR",
        boss = vector3(4557.9741, -10371.7207, 793.1662),
        pos = {
            [1] = vector3(-349.3795, -131.2432, 39.0217),
            [2] = vector3(-346.9902, -124.5577, 39.0216),
            [3] = vector3(-343.1781, -113.6457, 39.0198),
            [4] = vector3(-311.8396, -102.9726, 39.0172),
            [5] = vector3(-313.7973, -107.8640, 39.0173),
            [6] = vector3(-315.6145, -113.1552, 39.0173),
            [7] = vector3(-317.4306, -118.1559, 39.0167),
            [8] = vector3(-319.3432, -123.3335, 39.0170),
            [9] = vector3(-321.1790, -128.3528, 39.0168),
            [10] = vector3(-323.1249, -133.7931, 39.0173),
            [11] = vector3(-324.9642, -139.0367, 39.0170),
            [12] = vector3(-326.7884, -144.0017, 39.0163),
            [13] = vector3(-339.1807, -95.3100, 39.0164),
            [14] = vector3(-352.2206, -90.0780, 39.0156),
            [15] = vector3(-365.0600, -85.5752, 39.0157),
            [16] = vector3(-159.7257, 1279.9641, 306.1068),
            [17] = vector3(-164.3058, 1274.2202, 306.1070),
            [18] = vector3(162.4455, 619.7835, 202.5997),
            [19] = vector3(170.1573, 620.0213, 202.6000),
        },
        whitelistJobName = 'mechanic12'
    },
    ["mechanic13"] = {
        name = "VFG",
        boss = vector3(4557.9741, -10371.7207, 793.1662),
        pos = {
            [1] = vector3(1953.6033, 3770.2656, 32.2198),
            [2] = vector3(1971.9336, 3776.1660, 32.1275),
            [3] = vector3(1975.9207, 3761.0564, 32.1837),
            [4] = vector3(-311.8396, -102.9726, 39.0172),
            [5] = vector3(-313.7973, -107.8640, 39.0173),
            [6] = vector3(-315.6145, -113.1552, 39.0173),
            [7] = vector3(-317.4306, -118.1559, 39.0167),
            [8] = vector3(-319.3432, -123.3335, 39.0170),
            [9] = vector3(-321.1790, -128.3528, 39.0168),
            [10] = vector3(-323.1249, -133.7931, 39.0173),
            [11] = vector3(-324.9642, -139.0367, 39.0170),
            [12] = vector3(-326.7884, -144.0017, 39.0163),
            [13] = vector3(-339.1807, -95.3100, 39.0164),
            [14] = vector3(-352.2206, -90.0780, 39.0156),
            [15] = vector3(-365.0600, -85.5752, 39.0157),
        },
        whitelistJobName = 'mechanic13'
    },
    ["mechanic14"] = {
        name = "RPT",
        boss = vector3(4557.9741, -10371.7207, 793.1662),
        pos = {
            [1] = vector3(-349.3795, -131.2432, 39.0217),
            [2] = vector3(-346.9902, -124.5577, 39.0216),
            [3] = vector3(-343.1781, -113.6457, 39.0198),
            [4] = vector3(-311.8396, -102.9726, 39.0172),
            [5] = vector3(-313.7973, -107.8640, 39.0173),
            [6] = vector3(-315.6145, -113.1552, 39.0173),
            [7] = vector3(-317.4306, -118.1559, 39.0167),
            [8] = vector3(-319.3432, -123.3335, 39.0170),
            [9] = vector3(-321.1790, -128.3528, 39.0168),
            [10] = vector3(-323.1249, -133.7931, 39.0173),
            [11] = vector3(-324.9642, -139.0367, 39.0170),
            [12] = vector3(-326.7884, -144.0017, 39.0163),
            [13] = vector3(-339.1807, -95.3100, 39.0164),
            [14] = vector3(-352.2206, -90.0780, 39.0156),
            [15] = vector3(-365.0600, -85.5752, 39.0157),
        },
        whitelistJobName = 'mechanic14'
    },
    ["mechanic15"] = {
        name = "younRPT",
        boss = vector3(4557.9741, -10371.7207, 793.1662),
        pos = {
            [1] = vector3(-349.3795, -131.2432, 39.0217),
            [2] = vector3(-346.9902, -124.5577, 39.0216),
            [3] = vector3(-343.1781, -113.6457, 39.0198),
            [4] = vector3(-311.8396, -102.9726, 39.0172),
            [5] = vector3(-313.7973, -107.8640, 39.0173),
            [6] = vector3(-315.6145, -113.1552, 39.0173),
            [7] = vector3(-317.4306, -118.1559, 39.0167),
            [8] = vector3(-319.3432, -123.3335, 39.0170),
            [9] = vector3(-321.1790, -128.3528, 39.0168),
            [10] = vector3(-323.1249, -133.7931, 39.0173),
            [11] = vector3(-324.9642, -139.0367, 39.0170),
            [12] = vector3(-326.7884, -144.0017, 39.0163),
            [13] = vector3(-339.1807, -95.3100, 39.0164),
            [14] = vector3(-352.2206, -90.0780, 39.0156),
            [15] = vector3(-365.0600, -85.5752, 39.0157),
        },
        whitelistJobName = 'mechanic15'
    },
}
