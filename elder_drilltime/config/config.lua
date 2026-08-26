Config = {}

Config.DebugMode = false

Config.SuperAdminGroup = "superadmin"
Config.AdminGroup = "admin"
Config.ModeratorGroup = "moderator"

Config.ImagesPath = 'nui://ox_inventory/web/images/'


Config.CrateDrop = {
    Command = 'blabla',
    Models = {"p_cargo_chute_s", "ex_prop_adv_case_sm", "prop_box_wood02a_pu", "hei_prop_heist_ammo_box"},
    NotifyTime =  60, 
    LootTime = 30 ,
    Rewards = {
        [1] =  {item = "ammo-9", amount = 150},
        [2] =  {item = "ammo-rifle", amount = 150},
        [3] =  {item = "cocainebrick", amount = 1},
        [4] =  {item = "gmrmollythree", amount = 65},
        [5] =  {item = "dtokenmodveta", amount = 1},
        [6] =  {item = "cocainebrick", amount = 1},
        [7] =  {item = "prmgunlicense", amount = 50},
        [8] =  {item = "ammo-rifle2", amount = 150},
        [9] =  {item = "swiper", amount = 5},
        [10] =  {item = "gmrmollythree", amount = 65},
    }
}


Config.HairStyleJob = {
    Locations = {
        ["Shop1"] = {coords = vector3(-1443.6754, -394.8885, 35.8653), lenght = 16.0, width = 27.0 },
    },
    Job = 'hairsalon',
    Price = 45000,
    Collect = {
        [1] = {
            coords = vector4(-1443.1345, -385.3157, 35.8627, 170.6767), 
            label = 'Press ~INPUT_PICKUP~ to collect Hair Dye',
            items = {
                [1] = {item = "reddye", count = 6},
                [2] = {item = "pinkdye", count = 6},
                [3] = {item = "blonddye", count = 6},
            }
        },
        [2] = {
            coords = vector4(-1447.0205, -401.6516, 35.8627, 125.2080),
            label = 'Press ~INPUT_PICKUP~ to collect bundles',
            items = {
                [1] = {item = "blackhair", count = 10},
            }
        }
    },
    Craft = {
        coords = vector4(-1436.4131, -398.2050, 35.8627, 106.9905),
        label = 'Press ~INPUT_PICKUP~ to process Hair items',
        recipes = {
            [1] = {
                ingredients = {
                    [1] = {item = "reddye", count = 5},
                    [2] = {item = "blackhair", count = 15},
                },
                item = "red_pooch",
                count = 5,
                anim = true,
            },
            [2] = {
                ingredients = {
                    [1] = {item = "pinkdye", count = 5},
                    [2] = {item = "blackhair", count = 15},
                },
                item = "pink_pooch",
                count = 5,
                anim = true,
            },
            [3] = {
                ingredients = {
                    [1] = {item = "blonddye", count = 5},
                    [2] = {item = "blackhair", count = 15},
                },
                item = "blond_pooch",
                count = 5,
                anim = true,
            },
        }
    }

}

Config.Hostage = {
    ZiptieItem = "ziptie",
    Command = 'hostage',
    AutoReleaseTime = 5 * 60, -- Seconds
    AutoReleasePosition = vector4(72.6839, -69.8288, 4.9391, 296.3837)
}

Config.PersonalMenu = {
    Command = 'reloadchar',
    ReloadCharCooldown = 60 * 1000,
    FixCharCooldown = 60 * 1000,
    ChangeNamePrice = 1000000,

}

Config.BulletCraft = {
    Location = {coords = vector4(317.9413, -768.1840, -19.8841, 341.5439), npc = 'g_m_m_armboss_01'},
    Categories = {
        [1] = {
            level = {min = 700, max = 799},
            items = {
                [1] = {name = 'gunpowder', count = {min = 15, max = 30}, price = 500},
                [2] = {name = 'ammo9craft', count = {min = 15, max = 30}, price = 1000},
            }
        },
        [2] = {
            level = {min = 800, max = 899},
            items = {
                [1] = {name = 'gunpowder', count = {min = 15, max = 40}, price = 500},
                [2] = {name = 'ammo9craft', count = {min = 15, max = 40}, price = 1000},
                [3] = {name = 'ammoriflecraft', count = {min = 15, max = 40}, price = 1300},
            }
        },
        [3] = {
            level = {min = 900, max = 999},
            items = {
                [1] = {name = 'gunpowder', count = {min = 15, max = 50}, price = 500},
                [2] = {name = 'ammo9craft', count = {min = 15, max = 50}, price = 1000},
                [3] = {name = 'ammoriflecraft', count = {min = 15, max = 50}, price = 1300},
                [4] = {name = 'ammo762craft', count = {min = 15, max = 50}, price = 1600},
            }
        },
        [4] = {
            level = {min = 1000, max = 99999999},
            items = {
                [1] = {name = 'gunpowder', count = {min = 15, max = 60}, price = 500},
                [2] = {name = 'ammo9craft', count = {min = 15, max = 60}, price = 1000},
                [3] = {name = 'ammoriflecraft', count = {min = 15, max = 60}, price = 1300},
                [4] = {name = 'ammo762craft', count = {min = 15, max = 60}, price = 1600},
                [5] = {name = 'ammoshotguncraft', count = {min = 15, max = 60}, price = 2000,},
            }
        },  
    }

}

Config.Survivals = {
    CommandName = 'infected',
    PreliminaryPhaseDuration = 60,
    CountDownPhaseDuration = 20,
    MainPhaseDuration = 500,
    Position = vector3(2515.6218, -384.2580, 93.140),
    RejectPosition = vector3(-89.6267, -169.5538, 4.7852),
    Radius = 180.0,
    Weapons = {"WEAPON_TKSEMI", "WEAPON_COMBATSHOTGUN", "WEAPON_COMBATPISTOL"},
    Ammo = 250,
    InitialInfectionTime = 22,
    InitialInfectionCount = 3,
    ReviveAfterTime = 3,
    RespawnCoords = {
        vector3(2571.6841, -381.5432, 92.9929),
        vector3(2513.0625, -479.5928, 93.0211),
        vector3(2441.3267, -403.3286, 92.7783),
        vector3(2478.8418, -315.7108, 92.9049),
    }
}

Config.Chugjug = {
    Shop = {coords = vector3(-42.7698, 1954.8539, 20.4410), heading = 0.0},
    SpeedTime = 10 * 60,
    Price = 10000000,
    IllimitedUse = {'char1:0a54c46305433aa8553708a9dbee5cbe99be9aaa', 'char1:da046e37aebe2d67d8377125d5f118261c85fe19', 'char1:8bc1180f9a8eb6ffe65b2261106da88b922e357b','char1:9bd21045ae2ce3bbf268e6d3bb5ffc1145302ab0', 'char1:94a5d675bedd1394615434371063254dbddb72de', 'char2:5a21f529025c4dbc14f1fa3a9d9509484d0d824e'},
    UseCooldown = 20 * 60,
    SoundDistance = 5.0,
}

Config.KillHouse = {
    Location = {coords = vector3(-1304.4919, 638.8783, 6.2147)},
    Points = {
        vec3(-1286.6718, 669.9999, 3.8020),
        vec3(-1275.0026, 666.7988, 3.8020),
        vec3(-1277.1920, 632.5709, 3.8020),
        vec3(-1312.0680, 632.0707, 3.8020),  
        vec3(-1310.5913, 648.1621, 3.8020),  
        vec3(-1286.9871, 648.3389, 3.8020), 
    },
    RejectLocation = vector4(-292.9727, 156.6858, 6.0421, 0.0),
    EntranceFees = 5000,
    FightEvent = {
        Location = {coords = vector3(-176.7864, 2083.3171, 20.4229), radius = 200.0},
        SpawnAfterDeath = {
            vector3(30.0702, 2051.2388, 18.2449),
            vector3(26.1804, 2138.1155, 18.6078),
            vector3(-8.1451, 2212.3787, 15.0266),
            vector3(-121.8442, 2289.8870, 8.6753),
            vector3(-409.2376, 2096.9993, 12.2848),
            vector3(-342.2581, 1950.9397, 9.9387),
            vector3(-312.6378, 1904.6388, 15.4979),
            vector3(-218.3627, 1875.3656, 16.0671),
        },
        ReviveAfterTime = 30,
        CommandName = 'killhouse',
        PreliminaryPhaseDuration = 180,
        CountDownPhaseDuration = 15,
        MainPhaseDuration =  600 , -- 3600
        RejectFightCoords = vector3(-292.9727, 156.6858, 6.0421),

    },
    StealItems = {
        'double_cup', 'weed_pooch', 'whippetscartridges', 'streettax', 'oneweedweed', 'pooch_whippets', 'pcpppcp', '22ww23ww', 'hpweed', 'bb22cc221', 'wwhp1', 'qpweed', 'wwqp1', 'hero_pooch', 'wwlb', 'perc_pooch', 'exotic', 'heroin_shot', 'w33d', 'spice_pooch', 'coke_pooch', 'tuzi_pooch', 'meth_poooch', 'meth_pooch', 'crackpooch',
        'lsdtab', 'nuggsxawax', 'weedrrnewewx', 'waxempress', 'finxsdwax', 'bbkush', 'hyacid', 'spfentpooch', 'sdemiaroiuds', 'gmrmolly', 'purpdustlc', 'poochdilemama', 'raweedkos', 'rawweedygx', 'runtzbagog', 'wwbagogx', 'weednugskos', 'weednugsygsx', 'oxi_pooch', 'weed_haze_pooch', 'bbbkush', 'cocainebrick', 'crackpooch3000', 'wwgram1', 'weedhazenew', 'opium_pooch', 'crackb', 'hero', 'bottle_xanaxnew', 'bulkc', 'mollybulkbag', 
        'lean_bottle', 'lsddrop', 'newdrugxll', 'newromxm', 'meth', 'k2drgxnew', 'spicalodrgbw', 'icoke', 'oxycodone', 'opium', 'dpil2', 'weed_leaf', 'rawfent', 'heroin', 'cc22cc23', 'snow_man_joint', 'cookies_pooch', 'rom', 'pooch_romm', 'bulkrom', 'rawww1', 'nitrowhip', 'ww_pooch', 'cokef_pooch', 'white_runtz_joint',
    },
    CanStealBlackMoney = true,
    WebHook = "https://discord.com/api/webhooks/1502781889755349154/uZWZcun74PLz28g9COgpM56ClDzER9kFdPFxgoW_2SIcbmBROZ_SkBvuWhQHKbtaTKSA",
}

Config.BankTicket = {
    Shop = {Coords = vector4(930.8837, 35.5573, 81.1045, 354.8033), Model = "cs_casey"},
    Locker = vector3(922.6180, 28.4306, 81.1236),
    Price = 5000000,
    Item = 'bankkeycard',
    CommunityServiceActions = 20,
}

Config.ConstructionJob = {
    CloakIn = {Coords = vector4(43.4166, -434.6939, 39.9207, 251.8929), Model = 's_m_y_construct_01'},
    MaxWorkers = 55,
    TasksCount = {min = 35, max = 65},
    TaskReward = {min = 7850, max = 9500},
    WorkReward = {min = 500, max = 1500},
    TimePerTask = 10000,
    Tasks = {
        {coords = vector4(82.8654, -412.5055, 37.4723, 276.2157), type = 'digging_grave'},
        {coords = vector4(46.5251, -318.5345, 44.6132, 18.5940), type = 'digging_grave'},
        {coords = vector4(34.0239, -404.5569, 39.9117, 220.4754), type = 'digging_grave'},
        {coords = vector4(23.0425, -436.9188, 39.8773, 247.3540), type = 'digging_grave'},
        {coords = vector4(5.9746, -425.2833, 39.5930, 330.5678), type = 'digging_grave'},
        {coords = vector4(77.6703, -452.2899, 37.5492, 238.9355), type = 'drill'},
        {coords = vector4(70.2676, -380.8805, 39.9182, 340.2010), type = 'drill'},
        {coords = vector4(105.6877, -387.3580, 41.4439, 273.4305), type = 'drill'},
        {coords = vector4(105.0806, -356.6102, 42.7810, 350.9004), type = 'drill'},
        {coords = vector4(81.9080, -331.9311, 43.9632, 49.6097), type = 'drill'},
        {coords = vector4(55.6791, -341.1004, 43.2438, 80.7942), type = 'broom'},
        {coords = vector4(56.4068, -387.2872, 39.7401, 85.3601), type = 'broom'},
        {coords = vector4(116.0447, -439.3922, 41.1332, 283.2635), type = 'broom'},
        {coords = vector4(126.7511, -410.1474, 41.0936, 308.9078), type = 'broom'},
        {coords = vector4(145.2172, -359.8937, 43.0513, 341.7534), type = 'broom'},
        {coords = vector4(90.8454, -363.8061, 42.1959, 267.4733), type = 'weld'},
        {coords = vector4(37.1792, -456.9187, 39.9209, 99.3648), type = 'weld'},
        {coords = vector4(79.5918, -422.3546, 37.5522, 263.0326), type = 'weld'},
        {coords = vector4(76.9378, -448.2862, 37.5523, 353.5322), type = 'weld'},
        {coords = vector4(59.9598, -397.7268, 39.9148, 46.7216), type = 'weld'},
        {coords = vector4(22.3434, -388.4718, 39.5684, 266.8382), type = 'hammer'},
        {coords = vector4(58.6874, -462.0506, 39.9214, 167.2099), type = 'hammer'},
        {coords = vector4(78.7523, -460.0031, 37.5004, 204.8474), type = 'hammer'},
        {coords = vector4(96.2849, -415.3777, 37.5523, 260.0524), type = 'hammer'},
        {coords = vector4(92.0142, -374.8527, 41.8994, 343.5916), type = 'hammer'},
    },
    Clothes = {
        male = {
            components = {
                { ['component_id'] = 0,  ['texture'] = 0, ['drawable'] = 0 },
                { ['component_id'] = 1,  ['texture'] = 0, ['drawable'] = 31 },
                { ['component_id'] = 3,  ['texture'] = 0, ['drawable'] = 0 },
                { ['component_id'] = 4,  ['texture'] = 0, ['drawable'] = 223 },
                { ['component_id'] = 5,  ['texture'] = 0, ['drawable'] = 0 },
                { ['component_id'] = 6,  ['texture'] = 0, ['drawable'] = 176 },
                { ['component_id'] = 7,  ['texture'] = 0, ['drawable'] = 0 },
                { ['component_id'] = 8,  ['texture'] = 0, ['drawable'] = 215 },
                { ['component_id'] = 9,  ['texture'] = 0, ['drawable'] = 0 },
                { ['component_id'] = 10, ['texture'] = 0, ['drawable'] = 0 },
                { ['component_id'] = 11, ['texture'] = 0, ['drawable'] = 257 }
            },
            props = {
                { ["drawable"] = 211, ["prop_id"] = 0, ["texture"] = -1}--helmet
            }
        },
        female = {
            components = {
                { ['component_id'] = 0,  ['texture'] = 0, ['drawable'] = 0 },
                { ['component_id'] = 1,  ['texture'] = 0, ['drawable'] = 2 },-- mask
                { ['component_id'] = 3,  ['texture'] = 0, ['drawable'] = 4 },-- hands
                { ['component_id'] = 4,  ['texture'] = 0, ['drawable'] = 220 },--legs
                { ['component_id'] = 5,  ['texture'] = 0, ['drawable'] = 0 },
                { ['component_id'] = 6,  ['texture'] = 0, ['drawable'] = 132 },--shoes
                { ['component_id'] = 7,  ['texture'] = 0, ['drawable'] = 0 },
                { ['component_id'] = 8,  ['texture'] = 0, ['drawable'] = 172 },--shirt
                { ['component_id'] = 9,  ['texture'] = 0, ['drawable'] = 6 },
                { ['component_id'] = 10, ['texture'] = 0, ['drawable'] = 0 },
                { ['component_id'] = 11, ['texture'] = 0, ['drawable'] = 159 }--jacket
            },
            props = {
                { ["drawable"] = 211, ["prop_id"] = 0, ["texture"] = 177} --helmet
            }
        }
    },
}

Config.GarbageJob = {
    ClockIn = {Coords = vector4(-317.0790, -1539.3998, 27.6680, 344.2398), Model = 's_m_y_construct_01'},
    WorkVehicle = {Coords = vector4(-322.0408, -1526.5428, 27.1334, 276.0987), Model = "trash"},
    MaxWorkers = 55,
    MinTasksCount = 30,
    TaskReward = {min = 5000, max = 10000},
    WorkReward = {min = 500, max = 1500},
    Locations = {
        vector3(-139.3276, -1362.4130, 29.3174),
        vector3(-87.4261, -1330.3783, 29.2790),
        vector3(138.7339, -1363.7560, 29.1343),
        vector3(300.4816, -1286.3033, 30.3662),
        vector3(482.1389, -1447.9357, 29.1247),
        vector3(948.6873, -1454.4384, 31.1665),
        vector3(1219.5851, -1381.5586, 35.2448),
        vector3(956.6951, -914.9799, 42.9920),
        vector3(372.5941, -835.4023, 29.2917),
        vector3(240.5106, -595.3303, 42.8214),
        vector3(298.5330, -905.4565, 29.1577),
        vector3(255.2740, -985.6612, 29.1792),
        vector3(379.3650, -1117.2848, 29.4091),
        vector3(484.3905, -1118.3058, 29.2744),
        vector3(449.3914, -574.2039, 28.4998),
        vector3(521.8262, -162.4013, 56.6100),
        vector3(-4.1141, -1083.3680, 27.0471),
        vector3(115.2783, -1050.2543, 29.2539),
        vector3(490.5123, -998.6262, 27.6075),
        vector3(-252.4057, -733.0046, 33.2112),
        vector3(-771.1277, -217.6935, 37.2836),
        vector3(-581.3064, 190.7287, 71.3276),
        vector3(-623.3729, 293.0882, 82.0240),
        vector3(-759.7621, 365.2285, 87.8659),
        vector3(-1274.3411, -1085.4841, 7.6835),
        vector3(-1194.5514, -1374.4893, 4.3617),
        vector3(-978.0340, -1582.8463, 5.3053),
        vector3(-1146.8336, -1379.2074, 4.8719),
        vector3(-1146.8336, -1379.2074, 4.8719),
        vector3(137.9281, -1724.7710, 29.1990),
        vector3(188.8867, -1554.3348, 29.1218),
        vector3(129.4660, -1487.1331, 29.2182),
        vector3(481.7512, -1448.2277, 29.1382),
        vector3(378.8288, -1264.8351, 32.4918),
        vector3(115.2783, -1050.2543, 29.2539),
        vector3(490.5123, -998.6262, 27.6075),
        vector3(-252.4057, -733.0046, 33.2112),
        vector3(-771.1277, -217.6935, 37.2836),
        vector3(-581.3064, 190.7287, 71.3276),
        vector3(-623.3729, 293.0882, 82.0240),
        vector3(-759.7621, 365.2285, 87.8659),
        vector3(-1274.3411, -1085.4841, 7.6835),
        vector3(-1194.5514, -1374.4893, 4.3617),
        vector3(-978.0340, -1582.8463, 5.3053),
        vector3(-1146.8336, -1379.2074, 4.8719),
        vector3(-1146.8336, -1379.2074, 4.8719),
        vector3(137.9281, -1724.7710, 29.1990),
        vector3(188.8867, -1554.3348, 29.1218),
        vector3(129.4660, -1487.1331, 29.2182),
        vector3(481.7512, -1448.2277, 29.1382),
        vector3(378.8288, -1264.8351, 32.4918),
    },
    Clothes = {
        male = {
            components = {
                { ['component_id'] = 0,  ['texture'] = 0, ['drawable'] = 0 },
                { ['component_id'] = 1,  ['texture'] = 0, ['drawable'] = 0 },-- mask
                { ['component_id'] = 3,  ['texture'] = 0, ['drawable'] = 0 },-- hands
                { ['component_id'] = 4,  ['texture'] = 0, ['drawable'] = 140 },--legs
                { ['component_id'] = 5,  ['texture'] = 0, ['drawable'] = 0 },
                { ['component_id'] = 6,  ['texture'] = 0, ['drawable'] = 191 },--shoes
                { ['component_id'] = 7,  ['texture'] = 0, ['drawable'] = 0 },
                { ['component_id'] = 8,  ['texture'] = 0, ['drawable'] = 15 },--shirt
                { ['component_id'] = 9,  ['texture'] = 0, ['drawable'] = 0 },
                { ['component_id'] = 10, ['texture'] = 0, ['drawable'] = 0 },
                { ['component_id'] = 11, ['texture'] = 0, ['drawable'] = 177 }--jacket
            },
            props = {
            
            }
        },
        female = {
            components = {
                { ['component_id'] = 0,  ['texture'] = 0, ['drawable'] = 0 },
                { ['component_id'] = 1,  ['texture'] = 0, ['drawable'] = 0 },-- mask
                { ['component_id'] = 3,  ['texture'] = 0, ['drawable'] = 3 },-- hands
                { ['component_id'] = 4,  ['texture'] = 0, ['drawable'] = 121 },--legs
                { ['component_id'] = 5,  ['texture'] = 0, ['drawable'] = 0 },
                { ['component_id'] = 6,  ['texture'] = 0, ['drawable'] = 0 },--shoes
                { ['component_id'] = 7,  ['texture'] = 0, ['drawable'] = 0 },
                { ['component_id'] = 8,  ['texture'] = 0, ['drawable'] = 16 },--shirt
                { ['component_id'] = 9,  ['texture'] = 0, ['drawable'] = 0 },
                { ['component_id'] = 10, ['texture'] = 0, ['drawable'] = 0 },
                { ['component_id'] = 11, ['texture'] = 0, ['drawable'] = 171 }--jacket
            },
            props = {
                
            }
        }
    }
}

Config.BodyBag = {
    Item = "bxanewbsparrow",
    Prop = "xm_prop_body_bag",
    PropTime = 180,
}

Config.Marijuana = {
    Coords = vector4(894.6906, 1880.4292, 9.0468, 125.5709), 
    Reject = vector3(906.2935, 1870.9332, 14.2308),
    Model = 'a_m_y_mexthug_01', 
    Price = 25000,
    Owners = {'char2:33a24beeb66ae46de16400c7f9c7d1d9b6adf7bd'}
}

Config.Restaurants = {
    ["wafflehouse"] = {
        coords = vector3(786.0920, 517.6461, 8.9709),
        blip = {enable = false, sprite = 489, colour = 61, scale = 1.0, name = "UWU Cafe"},
        boss = vector3(-769.2123, 2214.7063, 24.7939),
        waiter = vector4(787.0039, 525.4971, 8.9871, 190.2739),
        menu = vector3(785.5624, 521.0815, 9.0099),
        craft = {
            coords = vector4(790.1522, 527.5043, 8.9871, 1.3131),
            recipes = {
                [1] = {
                    ingredients = {
                        [1] = {item = "salt", count = 5},
                        [2] = {item = "flour", count = 5},
                        [3] = {item = "butter", count = 5},
                    },
                    item = "bentofish",
                    count = 5,
                },
                [2] = {
                    ingredients = {
                        [1] = {item = "salt", count = 5},
                        [2] = {item = "flour", count = 5},
                        [3] = {item = "butter", count = 5},
                    },
                    item = "bentosushi",
                    count = 5,
                },
                [3] = {
                    ingredients = {
                        [1] = {item = "salt", count = 5},
                        [2] = {item = "flour", count = 5},
                        [3] = {item = "butter", count = 5},
                    },
                    item = "bobachoco",
                    count = 5,
                },
                [4] = {
                    ingredients = {
                        [1] = {item = "salt", count = 5},
                        [2] = {item = "flour", count = 5},
                        [3] = {item = "butter", count = 5},
                    },
                    item = "bobacottoncandy",
                    count = 5,

                },
                [5] = {
                    ingredients = {
                        [1] = {item = "salt", count = 5},
                        [2] = {item = "flour", count = 5},
                        [3] = {item = "butter", count = 5},
                    },
                    item = "bobavanilla",
                    count = 5,
                },
                [6] = {
                    ingredients = {
                        [1] = {item = "salt", count = 5},
                        [2] = {item = "flour", count = 5},
                        [3] = {item = "butter", count = 5},
                    },
                    item = "chocoloco",
                    count = 5,
                },
                [7] = {
                    ingredients = {
                        [1] = {item = "salt", count = 5},
                        [2] = {item = "flour", count = 5},
                        [3] = {item = "butter", count = 5},
                    },
                    item = "cookieshake",
                    count = 5,
                },
                
                [8] = {
                    ingredients = {
                        [1] = {item = "salt", count = 5},
                        [2] = {item = "flour", count = 5},
                        [3] = {item = "butter", count = 5},
                    },
                    item = "galaxyuwutea",
                    count = 5,
                },
                [9] = {
                    ingredients = {
                        [1] = {item = "salt", count = 5},
                        [2] = {item = "flour", count = 5},
                        [3] = {item = "butter", count = 5},
                    },
                    item = "golduwutea",
                    count = 5,
                },
                [10] = {
                    ingredients = {
                        [1] = {item = "salt", count = 5},
                        [2] = {item = "flour", count = 5},
                        [3] = {item = "butter", count = 5},
                    },
                    item = "macaron",
                    count = 5,
                },
                [11] = {
                    ingredients = {
                        [1] = {item = "salt", count = 5},
                        [2] = {item = "flour", count = 5},
                        [3] = {item = "butter", count = 5},
                    },
                    item = "macaron2",
                    count = 5,
                },
                [12] = {
                    ingredients = {
                        [1] = {item = "salt", count = 5},
                        [2] = {item = "flour", count = 5},
                        [3] = {item = "butter", count = 5},
                    },
                    item = "macaron3",
                    count = 5,
                },
                [13] = {
                    ingredients = {
                        [1] = {item = "salt", count = 5},
                        [2] = {item = "flour", count = 5},
                        [3] = {item = "butter", count = 5},
                    },
                    item = "milkshakenew",
                    count = 5,
                },
                [14] = {
                    ingredients = {
                        [1] = {item = "salt", count = 5},
                        [2] = {item = "flour", count = 5},
                        [3] = {item = "butter", count = 5},
                    },
                    item = "pandafoodbox",
                    count = 5,
                },
                [15] = {
                    ingredients = {
                        [1] = {item = "salt", count = 5},
                        [2] = {item = "flour", count = 5},
                        [3] = {item = "butter", count = 5},
                    },
                    item = "ramenbowl",
                    count = 5,
                },
                [16] = {
                    ingredients = {
                        [1] = {item = "salt", count = 5},
                        [2] = {item = "flour", count = 5},
                        [3] = {item = "butter", count = 5},
                    },
                    item = "ramenbowlxl",
                    count = 5,
                },
                [17] = {
                    ingredients = {
                        [1] = {item = "salt", count = 5},
                        [2] = {item = "flour", count = 5},
                        [3] = {item = "butter", count = 5},
                    },
                    item = "rasuwutea",
                    count = 5,
                },
                [18] = {
                    ingredients = {
                        [1] = {item = "salt", count = 5},
                        [2] = {item = "flour", count = 5},
                        [3] = {item = "butter", count = 5},
                    },
                    item = "strawloco",
                    count = 5,
                },
                [19] = {
                    ingredients = {
                        [1] = {item = "salt", count = 5},
                        [2] = {item = "flour", count = 5},
                        [3] = {item = "butter", count = 5},
                    },
                    item = "uwuwaffles",
                    count = 5,
                },
                [20] = {
                    ingredients = {
                        [1] = {item = "salt", count = 5},
                        [2] = {item = "flour", count = 5},
                        [3] = {item = "butter", count = 5},
                    },
                    item = "uwuwaffles2",
                    count = 5,
                },
                [21] = {
                    ingredients = {
                        [1] = {item = "salt", count = 5},
                        [2] = {item = "flour", count = 5},
                        [3] = {item = "butter", count = 5},
                    },
                    item = "veggiewrap",
                    count = 5,
                },
                [22] = {
                    ingredients = {
                        [1] = {item = "salt", count = 5},
                        [2] = {item = "flour", count = 5},
                        [3] = {item = "butter", count = 5},
                    },
                    item = "energy",
                    count = 5,
                },
                [23] = {
                    ingredients = {
                        [1] = {item = "salt", count = 5},
                        [2] = {item = "flour", count = 5},
                        [3] = {item = "butter", count = 5},
                    },
                    item = "snapple",
                    count = 5,
                },
            }

        },
        prices = {
            ["bentofish"] = 750,
            ["bentosushi"] = 750,
            ["bobachoco"] = 750,
            ["bobacottoncandy"] = 750,
            ["bobavanilla"] = 750,
            ["chocoloco"] = 750,
            ["cookieshake"] = 750,
            ["galaxyuwutea"] = 750,
            ["golduwutea"] = 750,
            ["macaron"] = 750,
            ["macaron2"] = 750,
            ["macaron3"] = 750,
            ["milkshakenew"] = 750,
            ["pandafoodbox"] = 750,
            ["ramenbowl"] = 750,
            ["ramenbowlxl"] = 750,
            ["rasuwutea"] = 750,
            ["strawloco"] = 750,
            ["uwuwaffles"] = 750,
            ["uwuwaffles2"] = 750,
            ["veggiewrap"] = 750,
            ["energy"] = 750,
            ["snapple"] = 750,
        },
        auto_orders = {
            coords = vector3(788.1989, 521.1829, 9.0099),
            orders = { min = 37, max = 70 },
            items = { min = 3, max = 10 },
            delay = {min = 20, max = 70}
        },
        cats = {
            {coords = vector4(792.5817, 516.5228, 8.9750, 103.1043), sitting = true},
            {coords = vector4(777.9435, 514.2086, 9.6213, 270.0629), sitting = true},
            {coords = vector4(780.5830, 521.3865, 8.9750, 183.6230), sitting = false},
        },
    },
    ["uwucafe"] = {
        coords = vector3(-1191.1584, -891.8932, 14.3805),
        blip = {enable = false, sprite = 489, colour = 61, scale = 1.0, name = "BURGER SHOT"},
        boss = vector3(-1204.3445, -891.6002, 14.3816),
        waiter = vector4(-1186.9718, -895.7167, 14.3805, 33.8071),
        menu = vector3(-1187.4003, -895.0204, 14.7971),
        craft = {
            coords = vector4(-1183.3881, -898.1694, 14.3805, 297.3722),
            recipes = {
                [1] = {
                    ingredients = {
                        [1] = {item = "salt", count = 5},
                        [2] = {item = "flour", count = 5},
                        [3] = {item = "butter", count = 5},
                    },
                    item = "tortanewmgnew",
                    count = 5,
                },
                [2] = {
                    ingredients = {
                        [1] = {item = "salt", count = 6},
                        [2] = {item = "flour", count = 6},
                        [3] = {item = "butter", count = 6},
                    },
                    item = "tamalnewmgdrug",
                    count = 5,
                },
                [3] = {
                    ingredients = {
                        [1] = {item = "salt", count = 7},
                        [2] = {item = "flour", count = 7},
                        [3] = {item = "butter", count = 7},
                    },
                    item = "tacomealnew",
                    count = 5,
                },
                [4] = {
                    ingredients = {
                        [1] = {item = "salt", count = 8},
                        [2] = {item = "flour", count = 8},
                        [3] = {item = "butter", count = 8},
                    },
                    item = "burritonewmgnew",
                    count = 5,

                },
            }

        },
        prices = {
            ["burritonewmgnew"] = 1500,
            ["tacomealnew"] = 1300,
            ["tamalnewmgdrug"] = 1100,
            ["tortanewmgnew"] = 900,
        },
        auto_orders = {
            coords = vector3(-1190.8965, -897.7351, 14.7971),
            orders = { min = 37, max = 70 },
            items = { min = 3, max = 10 },
            delay = {min = 20, max = 70}
        },
        cats = {
            
        },
    }
}

Config.TeamArmor = {
    Item = 'armourb',
    Prop = `prop_armour_pickup`,
    Duration = 30,
}

Config.CokeBoat = {
    Coords = vector4(-734.1538, -568.9146, 8.2768, 169.2205), 
    Reject = vector3(-734.1538, -568.9146, 8.2768),
    Model = 'a_m_m_og_boss_01', 
    PlayerPrice = 5000,
    OwnerPrice = 5000,
    Owners = {'char2:a629a3db2c2c20249deb6887438b6512c98a0c84'}
}

Config.GalaxyGas = {
    Item = 'ggdrilltime',
    SpeedTime = 5 * 60,
    Cooldown = 2 * 60,
}

Config.Ammunation = {
    {
        enter = vec(723.3425, 525.0175, 8.7629, 199.2331),
        exit = vec(724.5837, 521.6605, 8.7783, 94.9550)
    },
    {
        enter = vec(705.2260, 508.9317, 41.9854, 6.4263),
        exit = vec(705.2260, 508.9317, 41.9854, 6.4263)
    },
}

Config.Printer = {
    locations = {
        vector4(-845.4246, 1121.9001, 8.2025, 180.5091), 
    },
}

Config.Moneywash = {
    coords = vector3(-816.1799, 1629.5016, 13.6016),
    role = "1309976700230176822",
    money_percentage = 0.85,
    worker_percentage = 0.05

}

Config.Jobcenter = {
    coords1 = vector4(-523.0769, -258.0452, 35.6377, 303.1415),
    coords2 = vector4(141.5508, 1324.2505, 16.2256, 249.6731),
    model = 's_m_m_highsec_01',
    jobs = {
        {title = 'Construction Job', icon = 'fa-person-digging', color = 'red', coords = vector3(50.8673, -441.2118, 39.9143)},
        {title = 'Lumberjack', icon = 'fa-tree', color = 'green', coords = vector3(-570.0721, 5353.1685, 70.2340)},
        {title = 'Food Delivery', icon = 'fa-burger', color = 'orange', coords = vector3(1233.1040, -354.4852, 69.0821)},
        {title = 'Fishing Job', icon = 'fa-fish-fins', color = 'blue', coords = vector3(-1612.9517, -986.9036, 13.0174)},
        {title = 'Mining Job', icon = 'fa-gem', color = 'cyan', coords = vector3(2954.7871, 2739.6001, 43.9862)},
        {title = 'Forklift Job', icon = 'fa-box', color = 'orange', coords = vector3(1194.7622, -3255.2717, 7.0952)},
        {title = 'Garbage Job', icon = 'fa-dumpster', color = 'green', coords = vector3(-315.6133, -1536.7716, 27.5055)},
    }
}

Config.Packages = {
    ['carepck1'] = {
        {
            { item = 'WEAPON_MACHETE', min = 1, max = 1},
            { item = 'WEAPON_KNIFE',        min = 1, max = 1},
            { item = 'WEAPON_BAT',     min = 1, max = 1},
        },
        {
            { item = 'TUZI_POOCH',  min = 100, max = 300},
            { item = 'COKE_POOCH',  min = 100, max = 300},
            { item = 'METH_POOOCH', min = 100, max = 300},
            { item = 'FENT_POOCH',  min = 100, max = 300},
        },
        {
            { item = 'MONEY',  min = 100000, max = 150000},
        },
        {
            { item = 'BANDAGE',  min = 1, max = 20},
        },
        {
            { item = 'WATER',  min = 1, max = 10},
        },
        {
            { item = 'BURGER',  min = 1, max = 10},
        },

        
    },
    ['carepck2'] = {
        {
            { item = 'WEAPON_GIRLS',         min = 1, max = 1},
            { item = 'WEAPON_GIRLS',         min = 1, max = 1},
            { item = 'WEAPON_GIRLS',         min = 1, max = 1},
            { item = 'WEAPON_GIRLS',         min = 1, max = 1},
            { item = 'WEAPON_GIRLS',         min = 1, max = 1},
            { item = 'WEAPON_GIRLS',         min = 1, max = 1},
            { item = 'WEAPON_GIRLS',         min = 1, max = 1},
            { item = 'WEAPON_GIRLS',         min = 1, max = 1},
            { item = 'WEAPON_GIRLS',         min = 1, max = 1},
            { item = 'WEAPON_GIRLS',         min = 1, max = 1},
            { item = 'WEAPON_GIRLS',         min = 1, max = 1},
            { item = 'WEAPON_GIRLS',         min = 1, max = 1},
            { item = 'WEAPON_GIRLS',         min = 1, max = 1},
            { item = 'WEAPON_GIRLS',         min = 1, max = 1},
            { item = 'WEAPON_GIRLS',         min = 1, max = 1},
            { item = 'WEAPON_GIRLS',         min = 1, max = 1},
            { item = 'WEAPON_GIRLS',         min = 1, max = 1},
            { item = 'WEAPON_GIRLS',         min = 1, max = 1},
            { item = 'WEAPON_GIRLS',         min = 1, max = 1},
            { item = 'WEAPON_GIRLS',         min = 1, max = 1},
            { item = 'WEAPON_IBAK',          min = 1, max = 1},
            { item = 'WEAPON_SURREALGFX2',   min = 1, max = 1},
            { item = 'WEAPON_SEVENSURREAL',    min = 1, max = 1},
            { item = 'WEAPON_SURREALGFX2',   min = 1, max = 1},
        },
        {
            { item = 'MONEY',  min = 300000, max = 550000},
        },
        {
            { item = 'ammo-9',  min = 100, max = 150},
        },
        {
            { item = 'BANDAGE',  min = 10, max = 30},
        },

        {
            { item = 'bobavanilla',     min = 10, max = 20},
            { item = 'bobacottoncandy', min = 10, max = 20},
            { item = 'golduwutea',      min = 10, max = 20},
        },
        {
            { item = 'bentosushi',      min = 10, max = 20},
            { item = 'cookieshake',     min = 10, max = 20},
            { item = 'chocoloco',       min = 10, max = 20},
        },

    },
}

Config.BanArea = {
    coords = {
        vec(636.0671, 564.8748, 8.0),
        vec(799.2246, 587.3367, 8.0),
        vec(814.4550, 389.6358, 8.0),
        vec(653.1705, 373.6686, 8.0)
    },
    rejection = vec(500.7091, 464.0784, 14.7122),
}

Config.WeedStore = {
    job = 'weedstore',
    items = {
        {name = 'gmrmollynew' , price = 1250},
        {name = 'gmrmollytwo', price = 2500},
        {name = 'gmrmollythree', price = 5000},
        {name = 'cheetah_piss' , price = 4650},
        {name = 'gary_payton', price = 4650},
        {name = 'cereal_milk', price = 4650},
        {name = 'cake_mix' , price = 4650},
        {name = 'gelatti', price = 4650},
        {name = 'georgia_pie', price = 4650},
        {name = 'jefe' , price = 4650},
        {name = 'cookie_craze', price = 5000},
        {name = 'butter_cookie', price = 5000},
        {name = 'blueberry_jam_cookie' , price = 5000},
    }
}

Config.VipPackage = {
    npc = {
        model = 'a_m_y_soucent_02',
        coords = vec4(-274.7338, -2211.1602, 10.0507, 92.3797),
    },
    discordrole = '1370837365102346342',
    cooldown = 24*60*60,
    items = {
        {name = 'cocainebrick', count = 1},
        {name = 'cocainebrick', count = 2},
        {name = 'ammo-9', count = 1000},
        {name = 'ammo-9', count = 750},
        {name = 'ammo-9', count = 500},
        {name = 'bxanewbsparrow', count = 1},
        {name = 'ammo-rifle', count = 1000},
        {name = 'ammo-rifle', count = 750},
        {name = 'ammo-rifle', count = 500},
        {name = 'ammo-rifle2', count = 1000},
        {name = 'ammo-rifle2', count = 750},
        {name = 'ammo-rifle2', count = 500},
        {name = 'dtokenmodveta', count = 1},
        {name = 'bxanewbsparrow', count = 1},
        {name = 'dtokenmodveta', count = 2},
        {name = 'coke_pooch', count = 330},
        {name = 'meth_poooch', count = 330},
        {name = 'crackpooch3000', count = 330},
        {name = 'bottle_xanaxnew', count = 330},
        {name = 'finxsdwax', count = 330},
        {name = 'lsdtab', count = 330},
    }
}

Config.Redzone = {
    coords = vector3(-228.9682, -2658.5803, 6.1003),
    radius = 65.0,
    extra_radius = 60.0,
    revive_time = 7,
    revive_locations = {
        vector3(-138.2364, -2631.2080, 6.0007),
        vector3(-192.2538, -2723.4155, 5.9962),
        vector3(-299.9922, -2719.8882, 6.0021),
        vector3(-332.0432, -2693.8948, 5.8901),
        vector3(-311.0307, -2588.9570, 6.0255),
        vector3(-203.2988, -2580.6001, 6.0008),
        vector3(-144.0459, -2643.5574, 6.0090),
    },
    item = 'dremgrmsaax',
    money = {min = 223, max = 483},
    give_weapon = true,
    weapon = 'WEAPON_DTP',
    weapon_ammo = 685,
    StealItems = {
        'burger', 'water',
    },
    CanStealBlackMoney = false,
}

Config.GangPackage = {
    npc = {
        model = 'g_m_m_armboss_01',
        coords = vec4(-294.8582, -2206.4724, 9.9749, 178.8734),
    },
    discordrole1 = '1420504931177332779',
    discordrole2 = '1420505133384597714',
    cooldown = 7*24*60*60,
    played_time = 50 * 60 * 60,
    rewards = {
        free = {
            perm = {
                {item = 'bxanewbsparrow', min = 1, max = 1},
                {item = 'cocainebrick', min = 3, max = 3},
                {item = 'dtokenmodveta', min = 2, max = 2},
                {item = 'spray', min = 5, max = 5},
                {item = 'xpills', min = 20, max = 20},
            },
            random = {
                
            }
        },
        level2 = {
            perm = {
                {item = 'bxanewbsparrow', min = 3, max = 3},
                {item = 'cocainebrick', min = 6, max = 6},
                {item = 'dtokenmodveta', min = 6, max = 6},
                {item = 'spray', min = 8, max = 8},
                {item = 'xpills', min = 40, max = 40},
            },
            random = {
                
            }
        },
        level3 = {
            perm = {
                {item = 'bxanewbsparrow', min = 6, max = 6},
                {item = 'cocainebrick', min = 10, max = 10},
                {item = 'dtokenmodveta', min = 10, max = 10},
                {item = 'spray', min = 12, max = 12},
                {item = 'xpills', min = 80, max = 80},
                
            },
            random = {
                
            }
        }
    }
}