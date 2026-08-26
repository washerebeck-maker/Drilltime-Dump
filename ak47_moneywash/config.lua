Config = {}
Config.Locale = 'en'
Config.SharedObjectName = 'esx:getSharedObject'

Config.RemoveOnUse = false
Config.MinimumWash = 5000
Config.MaximumWash = 5000000
Config.WashTimeMultiplier = 0  -- 30 sec per 10k
Config.WashingTax = 0.80        -- player will get 80% money
Config.WaitAfterWash = 0.5        -- minutes (this is also the cooldown time, you can't disable cooldown)

Config.Keys = {
    [1] = 38, --E
    [2] = 74, --H
}

Config.LoadDistance = 10.0

Config.LaundryPlaces = {
    [1] = {
        pos = vector3(1136.3949, -992.0630, 46.1131),
        machine = {
            pos = vector4(-817.8839, 1620.0974, 12.6017, 92.1449),
            state = 1,
        }
    },
    [2] = {
        pos = vector3(1136.2023, -990.7628, 46.1131),
        machine = {
            pos = vector4(-817.9641, 1621.8455, 12.6017, 92.1449),
            state = 1,
        }
    },
    [3] = {
        pos = vector3(1136.0875, -989.4627, 46.1131), -- marker position
        machine = {
            pos = vector4(-806.7615, 1621.2197, 12.7254, 92.1449),
            state = 1,
        }
    },
    [4] = {
        pos = vector3(1135.8136, -988.1544, 46.1131),
        machine = {
            pos = vector4(-804.4997, 1632.3105, 12.7254, 359.5291),
            state = 1,
        }
    },
    [5] = {
        pos = vector3(685.3232, 1263.7756, 354.9349),
        machine = {
            pos = vector4(762.4851, 580.1621, 139.4138, 186.8614),
            state = 1,
        }
    },
    [6] = {
        pos = vector3(-2793.7205, 1415.1550, 89.4077),
        machine = {
            pos = vector4(-2793.8467, 1414.2114, 88.4077, 178.1378),
            state = 1,
        }
    },
    [7] = {
        pos = vector3(256.9430, -997.8204, -99.0086),
        machine = {
            pos = vector4(-817.9641, 1621.8455, 12.6017, 92.1449),
            state = 1,
        }
    },
    [8] = {
        pos = vector3(-1234.6722, 798.4756, 186.2216),
        machine = {
            pos = vector4(-3678.4854, -8444.1914, 1.5060, 152.8390),
            state = 1,
        }
    },
}

Config.Blips = {
    --{enable = false, pos = vector3(255.76, 274.29, 105.81), name = 'Money Wash', sprite = 207, size = 1.0, color = 40}, -- to disable blip, remove this line or make enable = false
}

Config.Teleports = {
   -- ['Money Wash'] = {enter = vector3(255.76, 274.29, 105.81), exit = vector3(1138.05, -3199.19, -39.67)},
}

Config.Props = {
    [1] = `bkr_prop_prtmachine_dryer`,
    [2] = `bkr_prop_prtmachine_dryer_op`,
    [3] = `bkr_prop_prtmachine_dryer_spin`,
}