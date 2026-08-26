-----------------For support, scripts, and more----------------
--------------- https://discord.gg/wasabiscripts  -------------
---------------------------------------------------------------
local seconds, minutes = 1000, 60000
Config = {}

Config.jobMenu = 'F6' -- Default job menu key

Config.customCarlock = false -- If you use wasabi_carlock(Add your own carlock system in client/cl_customize.lua)
Config.billingSystem = false -- Current options: 'esx' (For esx_billing) / 'okok' (For okokBilling) (Easy to add more/fully customize in client/cl_customize.lua)
Config.skinScript = false -- Current options: 'esx' (For esx_skin) / 'appearance' (For wasabi-fivem-appearance) (Custom can be added in client/cl_customize.lua)
Config.customJail = false -- Set to true if you want to add jail option to menu(Requires you to edit wasabi_police:sendToJail event in client/cl_customize.lua)

Config.inventory = 'ox' -- NEEDED FOR SEARCHING PLAYERS - Current options: 'ox' (For ox_inventory) / 'mf' (For mf inventory) / 'qs' (For qs_inventory) / 'cheeza' (For cheeza_inventory) / 'custom' (Custom can be added in client/cl_customize.lua)
Config.searchPlayers = true -- Allow police jobs to search players (Must set correct inventory above)
Config.armour = true
Config.ammo = true
Config.pdcars = true
Config.weapon_license = true
Config.weaponsAsItems = true -- This is typically for older ESX and inventories that still use weapons as weapons and not items(If you're unsure leave as true!)
Config.esxIdentity = true -- Enable to gain option additional information when checking ID of suspect. (Requires esx_identity/esx_status or similar)
Config.esxLicense = false -- Enable if you use esx_license or something similar for weapon licenses/etc (May require additional config of the open portions of code)

Config.spikeStripsEnabled = true -- Enable functionility of spike strips (Disable if you use difference script for spike strips)

Config.PedVehicleSpawnLimit = 2

Config.PoliceVehicleModel = "sou_durangopd"

Config.tackle = {
    enabled = true, -- Enable tackle?
    policeOnly = true, -- Police jobs only use tackle?
    hotkey = 'G' -- What key to press while sprinting to start tackle of target
}

Config.handcuff = { -- Config in regards to cuffing
    timer = 5 * minutes, -- Time before player is automatically unrestrained(Set to false if not desired)
    hotkey = 'J', -- What key to press to handcuff people(Set to false for no hotkey)
    skilledEscape = {
        enabled = false, -- Allow criminal to simulate resisting by giving them a chance to break free from cuffs via skill check
        difficulty = {'easy', 'easy', 'easy'} -- Options: 'easy' / 'medium' / 'hard' (Can be stringed along as they are in config)
    }
}

Config.policeJobs = { -- Police jobs
    'police',
    'sheriff'
}

Config.emsJobs = { -- Police jobs
    'ambulance'
}

Config.Props = { -- What props are avaliable in the "Place Objects" section of the job menu

    {
        title = 'Barrier', -- Label
        description = '', -- Description (optional)
        model = `prop_barrier_work05`, -- Prop name within `
        groups = { -- ['job_name'] = min_rank
            ['police'] = 0,
            ['sheriff'] = 0,
        }
    },
    {
        title = 'Barricade',
        description = '',
        model = `prop_mp_barrier_01`,
        groups = {
            ['police'] = 0,
            ['sheriff'] = 0,
        }
    },
    {
        title = 'Traffic Cones',
        description = '',
        model = `prop_roadcone02a`,
        groups = {
            ['police'] = 0,
            ['sheriff'] = 0,
        }
    },
    {
        title = 'Spike Strip',
        description = '',
        model = `p_ld_stinger_s`,
        groups = {
            ['police'] = 0,
            ['sheriff'] = 0,
        }
    },

}

Config.Locations = {
    LSPD = {
        blip = {
            enabled = true,
            coords = vec3(447.9693, -985.0812, 30.6896),
            sprite = 60,
            color = 29,
            scale = 1.0,
            string = 'Mission Row PD'
        },

        bossMenu = {
            enabled = true, -- Enable boss menu?
            jobLock = 'police', -- Lock to specific police job? Set to false if not desired
            coords = vec3(460.8063, -985.6275, 30.7281), -- Location of boss menu (If not using target)
            label = '[E] - Access Boss Menu', -- Text UI label string (If not using target)
            distance = 1.5, -- Distance to allow access/prompt with text UI (If not using target)
            target = {
                enabled = false, -- If enabled, the location and distance above will be obsolete
                label = 'Access Boss Menu',
            	coords = vec3(461.8528, -998.0675, 31.1772), -- Coords of armoury
           	heading = 85.6564, -- Heading of armoury NPC
                width = 2.0,
                length = 1.0,
                minZ = 30.73-0.9,
                maxZ = 30.73+0.9
            }
        },

        armoury = {
            enabled = true, -- Set to false if you don't want to use
            coords = vec3(480.3099, -996.6699, 29.6898), -- Coords of armoury
            heading = 88.9715, -- Heading of armoury NPC
            ped = 's_f_y_cop_01',
            label = '[E] - Access Armoury', -- String of text ui
            jobLock = 'police', -- Allow only one of Config.policeJob listings / Set to false if allow all Config.policeJobs
            weapons = {
                [0] = { -- Grade number will be the name of each table(this would be grade 0)
                    ['WEAPON_PISTOL'] = { label = 'Pistol GLOCK', multiple = false, price = 50000 }, -- Set price to false if undesired
                    ['WEAPON_BAR15'] = { label = 'AR 15', multiple = false, price = 1500000 }, -- Set price to false if undesired
                    ['WEAPON_BSCAR'] = { label = 'SCAR', multiple = false, price = 2500000 }, -- Set price to false if undesired
                    ['WEAPON_BPSUNIT'] = { label = 'BLACKOPS RIFLE', multiple = false, price = 3500000 }, -- Set price to false if undesired
                    ['WEAPON_STUNGUN'] = { label = 'Stungun', multiple = false, price = 35000 }, -- Set price to false if undesired
                    ['WEAPON_NIGHTSTICK'] = { label = 'Night Stick', multiple = false, price = 2500 },
--                    ['ammo-45'] = { label = '9mm Ammo', multiple = true, price = 10 }, -- Set multiple to true if you want ability to purchase more than one at a time
--                    ['armour'] = { label = 'Bulletproof Vest', multiple = false, price = 100 }, -- Example

                },
                [1] = { -- This would be grade 1
                    ['WEAPON_PISTOL'] = { label = 'Pistol GLOCK', multiple = false, price = 50000 }, -- Set price to false if undesired
                    ['WEAPON_BAR15'] = { label = 'AR 15', multiple = false, price = 1500000 }, -- Set price to false if undesired
                    ['WEAPON_BSCAR'] = { label = 'SCAR', multiple = false, price = 2500000 }, -- Set price to false if undesired
                    ['WEAPON_BPSUNIT'] = { label = 'BLACKOPS RIFLE', multiple = false, price = 3500000 }, -- Set price to false if undesired
                    ['WEAPON_STUNGUN'] = { label = 'Stungun', multiple = false, price = 35000 }, -- Set price to false if undesired
                    ['WEAPON_NIGHTSTICK'] = { label = 'Night Stick', multiple = false, price = 2500 },
--                    ['WEAPON_NIGHTSTICK'] = { label = 'Night Stick', multiple = false, price = 50 },
--                    ['ammo-9'] = { label = '9mm Ammo', multiple = true, price = 10 }, -- Example
--                    ['armour'] = { label = 'Bulletproof Vest', multiple = false, price = 100 }, -- Example
                },
                [2] = { -- This would be grade 2
                    ['WEAPON_PISTOL'] = { label = 'Pistol GLOCK', multiple = false, price = 50000 }, -- Set price to false if undesired
                    ['WEAPON_BAR15'] = { label = 'AR 15', multiple = false, price = 1500000 }, -- Set price to false if undesired
                    ['WEAPON_BSCAR'] = { label = 'SCAR', multiple = false, price = 2500000 }, -- Set price to false if undesired
                    ['WEAPON_BPSUNIT'] = { label = 'BLACKOPS RIFLE', multiple = false, price = 3500000 }, -- Set price to false if undesired
                    ['WEAPON_STUNGUN'] = { label = 'Stungun', multiple = false, price = 35000 }, -- Set price to false if undesired
                    ['WEAPON_NIGHTSTICK'] = { label = 'Night Stick', multiple = false, price = 2500 },
--                    ['ammo-9'] = { label = '9mm Ammo', multiple = true, price = 10 }, -- Example
--                    ['ammo-rifle'] = { label = '5.56 Ammo', multiple = true, price = 20 }, -- Example
--                    ['armour'] = { label = 'Bulletproof Vest', multiple = false, price = 100 }, -- Example
                },
                [3] = { -- This would be grade 2
                    ['WEAPON_PISTOL'] = { label = 'Pistol GLOCK', multiple = false, price = 50000 }, -- Set price to false if undesired
                    ['WEAPON_BAR15'] = { label = 'AR 15', multiple = false, price = 1500000 }, -- Set price to false if undesired
                    ['WEAPON_BSCAR'] = { label = 'SCAR', multiple = false, price = 2500000 }, -- Set price to false if undesired
                    ['WEAPON_BPSUNIT'] = { label = 'BLACKOPS RIFLE', multiple = false, price = 3500000 }, -- Set price to false if undesired
                    ['WEAPON_STUNGUN'] = { label = 'Stungun', multiple = false, price = 35000 }, -- Set price to false if undesired
                    ['WEAPON_NIGHTSTICK'] = { label = 'Night Stick', multiple = false, price = 2500 },
--                    ['ammo-9'] = { label = '9mm Ammo', multiple = true, price = 10 }, -- Example
--                    ['ammo-rifle'] = { label = '5.56 Ammo', multiple = true, price = 20 }, -- Example
--                    ['armour'] = { label = 'Bulletproof Vest', multiple = false, price = 100 }, -- Example
                },
                [4] = { -- This would be grade 2
                    ['WEAPON_PISTOL'] = { label = 'Pistol GLOCK', multiple = false, price = 50000 }, -- Set price to false if undesired
                    ['WEAPON_BAR15'] = { label = 'AR 15', multiple = false, price = 1500000 }, -- Set price to false if undesired
                    ['WEAPON_BSCAR'] = { label = 'SCAR', multiple = false, price = 2500000 }, -- Set price to false if undesired
                    ['WEAPON_BPSUNIT'] = { label = 'BLACKOPS RIFLE', multiple = false, price = 3500000 }, -- Set price to false if undesired
                    ['WEAPON_STUNGUN'] = { label = 'Stungun', multiple = false, price = 35000 }, -- Set price to false if undesired
                    ['WEAPON_NIGHTSTICK'] = { label = 'Night Stick', multiple = false, price = 2500 },
--                    ['ammo-9'] = { label = '9mm Ammo', multiple = true, price = 10 }, -- Example
--                    ['ammo-rifle'] = { label = '5.56 Ammo', multiple = true, price = 20 }, -- Example
--                    ['armour'] = { label = 'Bulletproof Vest', multiple = false, price = 100 }, -- Example
                },
            }
        },

        cloakroom = {
            enabled = true, -- Set to false if you don't want to use (Compatible with esx_skin & wasabi fivem-appearance fork)
            jobLock = 'police', -- Allow only one of Config.policeJob listings / Set to false if allow all Config.policeJobs
            coords = vec3(316.06, 672.05, 14.73), -- Coords of cloakroom
            label = '[E] - Change Clothes', -- String of text ui of cloakroom
            range = 2.0, -- Range away from coords you can use.
            uniforms = { -- Uniform choices

                ['Recruit'] = { -- Name of outfit that will display in menu
                    male = { -- Male variation
                        ['tshirt_1'] = 62,  ['tshirt_2'] = 0,
                        ['torso_1'] = 5,   ['torso_2'] = 2,
                        ['arms'] = 5,
                        ['pants_1'] = 215,   ['pants_2'] = 1,
                        ['shoes_1'] = 156,   ['shoes_2'] = 1,
                        ['helmet_1'] = 0,  ['helmet_2'] = 0,
                    },
                    female = { -- Female variation
                        ['tshirt_1'] = 15,  ['tshirt_2'] = 0,
                        ['torso_1'] = 4,   ['torso_2'] = 14,
                        ['arms'] = 4,
                        ['pants_1'] = 25,   ['pants_2'] = 1,
                        ['shoes_1'] = 16,   ['shoes_2'] = 4,
                    }
                },

                ['Patrol'] = {
                    male = {
                        ['tshirt_1'] = 58,  ['tshirt_2'] = 0,
                        ['torso_1'] = 55,   ['torso_2'] = 0,
                        ['arms'] = 30,
                        ['pants_1'] = 24,   ['pants_2'] = 0,
                        ['shoes_1'] = 10,   ['shoes_2'] = 0,
                        ['helmet_1'] = 46,  ['helmet_2'] = 0,
                    },
                    female = {
                        ['tshirt_1'] = 15,  ['tshirt_2'] = 0,
                        ['torso_1'] = 4,   ['torso_2'] = 14,
                        ['arms'] = 4,
                        ['pants_1'] = 25,   ['pants_2'] = 1,
                        ['shoes_1'] = 16,   ['shoes_2'] = 4,
                    }
                },

                ['Chief'] = {
                    male = {
                        ['tshirt_1'] = 15,  ['tshirt_2'] = 0,
                        ['torso_1'] = 5,   ['torso_2'] = 2,
                        ['arms'] = 5,
                        ['pants_1'] = 6,   ['pants_2'] = 1,
                        ['shoes_1'] = 16,   ['shoes_2'] = 7,
                        ['helmet_1'] = 44,  ['helmet_2'] = 7,
                    },
                    female = {
                        ['tshirt_1'] = 15,  ['tshirt_2'] = 0,
                        ['torso_1'] = 4,   ['torso_2'] = 14,
                        ['arms'] = 4,
                        ['pants_1'] = 25,   ['pants_2'] = 1,
                        ['shoes_1'] = 16,   ['shoes_2'] = 4,
                    }
                },
                
            }

        },

        vehicles = { -- Vehicle Garage
            enabled = true, -- Enable? False if you have you're own way for medics to obtain vehicles.
            jobLock = 'police', -- Job lock? or access to all police jobs by using false
            zone = {
                coords = vec3(455.3246, -1017.4918, 28.4204), -- Area to prompt vehicle garage
                range = 5.5, -- Range it will prompt from coords above
                label = '[E] - Access Garage',
                return_label = '[E] - Return Vehicle'
            },
            spawn = {
                land = {
                    coords = vec3(463.0681, -1019.6844, 27.6844), -- Coords of where land vehicle spawn/return
                    heading = 89.2074
					},
                air = {
                    coords = vec3(678.49127197266,579.29431152344,8.7245168685913), -- Coords of where air vehicles spawn/return
                    heading = 90.0
                }
            },
            options = {

                [0] = { -- Job grade as table name
                    ['nypdtaurus'] = { -- Car/Helicopter/Vehicle Spawn Code/Model Name
                        label = 'Police Cruiser',
                        category = 'land', -- Options are 'land' and 'air'
                    },
                    ['nypdfus'] = { -- Car/Helicopter/Vehicle Spawn Code/Model Name
                        label = 'UnderCover Cruiser #2',
                        category = 'land', -- Options are 'land' and 'air'
                    },
                    ['sou_chargerpd'] = { -- Car/Helicopter/Vehicle Spawn Code/Model Name
                        label = 'Maverick',
                        category = 'land', -- Options are 'land' and 'air'
                    },
                    ['police4'] = { -- Car/Helicopter/Vehicle Spawn Code/Model Name
                        label = 'PD Truck',
                        category = 'Fast PD Cruiser #4', -- Options are 'land' and 'air'
                    },
                },

                [1] = { -- Job grade as table name
                    ['nypdtaurus'] = { -- Car/Helicopter/Vehicle Spawn Code/Model Name
                        label = 'Police Cruiser',
                        category = 'land', -- Options are 'land' and 'air'
                    },
                    ['nypdfus'] = { -- Car/Helicopter/Vehicle Spawn Code/Model Name
                        label = 'UnderCover Cruiser #2',
                        category = 'land', -- Options are 'land' and 'air'
                    },
                    ['sou_chargerpd'] = { -- Car/Helicopter/Vehicle Spawn Code/Model Name
                        label = 'Maverick',
                        category = 'land', -- Options are 'land' and 'air'
                    },
                    ['police4'] = { -- Car/Helicopter/Vehicle Spawn Code/Model Name
                        label = 'PD Truck',
                        category = 'Fast PD Cruiser #4', -- Options are 'land' and 'air'
                    },
                },

                [2] = { -- Job grade as table name
                    ['nypdtaurus'] = { -- Car/Helicopter/Vehicle Spawn Code/Model Name
                        label = 'Police Cruiser',
                        category = 'land', -- Options are 'land' and 'air'
                    },
                    ['nypdfus'] = { -- Car/Helicopter/Vehicle Spawn Code/Model Name
                        label = 'UnderCover Cruiser #2',
                        category = 'land', -- Options are 'land' and 'air'
                    },
                    ['sou_chargerpd'] = { -- Car/Helicopter/Vehicle Spawn Code/Model Name
                        label = 'Maverick',
                        category = 'land', -- Options are 'land' and 'air'
                    },
                    ['police4'] = { -- Car/Helicopter/Vehicle Spawn Code/Model Name
                        label = 'PD Truck',
                        category = 'Fast PD Cruiser #4', -- Options are 'land' and 'air'
                    },
                },

                [3] = { -- Job grade as table name
                    ['nypdtaurus'] = { -- Car/Helicopter/Vehicle Spawn Code/Model Name
                        label = 'Police Cruiser',
                        category = 'land', -- Options are 'land' and 'air'
                    },
                    ['nypdfus'] = { -- Car/Helicopter/Vehicle Spawn Code/Model Name
                        label = 'UnderCover Cruiser #2',
                        category = 'land', -- Options are 'land' and 'air'
                    },
                    ['sou_chargerpd'] = { -- Car/Helicopter/Vehicle Spawn Code/Model Name
                        label = 'Maverick',
                        category = 'land', -- Options are 'land' and 'air'
                    },
                    ['police4'] = { -- Car/Helicopter/Vehicle Spawn Code/Model Name
                        label = 'PD Truck',
                        category = 'Fast PD Cruiser #4', -- Options are 'land' and 'air'
                    },
                },

            }
        }

    },

}

Config.SearchSettings = {
    remove_black_money = true,
    remove_items = true,
    items = {'oxycodone', 'opium', 'prjbaby2', 'prjbaby2', 'poochdilemama', 'newdrugxll', 'newromxm', 'RAWWEEDYGX', 'weednugsygsx', 'wwbagogx', 'runtzbagog', 'weed_pooch', 'hyacid', 'oxibk', 'oxi_pooch', '22ww23ww', 'bb22cc221', 'lbweed', 'rawww', 'weed_leaf', 'oneweedweed', 'meth_poooch', 'hpweed', 'ww_pooch', 'wwhp', 'wwqp', 'wwlb', 'wwgram', 'wwqp', 'double_cup', 'heroin', 'lsddrop', 'meth', 'weed_leaf', 'rawfent', 'weed_poooch', 'hero_pooch', 'perc_pooch', 'exotic', 'heroin_shot', 'w33d', 'spice_pooch', 'crackpooch3000','coke_pooch', 'tuzi_pooch', 'meth_poooch', 'meth_pooch', 'crackpooch', 'lsdtab', 'crackb', 'fentbrick', 'cocainebrick', 'hero', 'lbweed', 'lbweed2', 'bottle_xanaxnew', 'methbk', 'mollybulkbag', 'whippetscartridges', 'icoke', 'pcpppcp', 'meth_raw', 'lean', 'diamond', 'jewels', 'pooch_whippets', 'lean_bottle', 'otlbrick', 'bbkush', 'bbbkush', 'rom', 'nitrowhip', 'pooch_romm', 'cc22cc23', 'snow_man_joint', 'cookies_pooch', 'bbbkush', 'white_runtz_joint', 'bubbakush', 'snow_man_joint', 'white_runtz_joint', 'blueberry_cruffin_joint', 'ww_pooch', 'rawww1', 'wwgram1', 'wwhp1', 'wwqp1', 'wwlb', 'cokef_pooch', 'eosbrick', 'weedhazenew', 'weed_haze_pooch', 'RAWEEDKOS', 'weednugskos', 'gmrmolly', 'purpdustlc'},
}

Config.PoliceWeapons = {"WEAPON_MAYO", "WEAPON_CHICAGOPD", "WEAPON_FLASHLIGHT", "WEAPON_PDNYC", "WEAPON_DTM4", "WEAPON_BAR15", "WEAPON_BSCAR", "WEAPON_NONLETHALSHOTGUN", "WEAPON_STUNGUN", "WEAPON_NIGHTSTICK", "WEAPON_M4A1T", "WEAPON_PISTOL", "WEAPON_MP5V3", "WEAPON_PUMPSHOTGUN", "WEAPON_G36KCMG", "WEAPON_PDMK18"}

Config.RaidGrades = {3,4}

Config.Cells = {
    vector4(-59.2405, -95.3182, 4.9769, 280.8788),
    vector4(-61.7765, -89.6069, 4.9769, 256.2897),
    vector4(-64.3472, -84.1773, 4.9769, 300.0004),
    vector4(-67.6846, -78.2147, 4.9724, 254.6395),
    vector4(-58.5454, -95.3751, 4.9755, 271.4423),
}

Config.CellTime = 10 * 60 -- 10 minutes

Config.CellRelease = vector4(-33.3132, -94.6588, 4.7227, 217.9302) -- release coords

Config.PoliceVehicles = {'sou_durangopd', 'hpescal21', 'nypdtaurus', 'nypdfus', 'sou_chargerpd', 'DB20Exp', 'DBChrysler300WBPD', 'pdbcla', 'DBtrhawk', '2015caravanrb', 'cpdtahoe', 'nm_uruswb'}