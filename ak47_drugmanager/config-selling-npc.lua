Config.GiveBlack = true -- give black money? if disabled it'll give regular cash.

Config.CustomDispatch = false -- if you want to use custom dispatch alert then enable this and add you alert in client/utils.lua

Config.StartSell = 'start-sell'
Config.StopSell = 'stop-sell'

function canSellNpc() -- if you want to do some additional check, you can place your code here
    return false
end

Config.DrugList = {
    ['weed_pooch'] = {
        quantity = {min = 1, max = 3},
        price = {min = 500, max = 1000},
    },
    ['molly_pooch'] = {
        quantity = {min = 1, max = 2},
        price = {min = 150, max = 300},
    },
    ['spice_pooch'] = {
        quantity = {min = 1, max = 2},
        price = {min = 250, max = 500},
    },
    ['opium_pooch'] = {
        quantity = {min = 1, max = 2},
        price = {min = 100, max = 300},
    },
    ['shroom_pooch'] = {
        quantity = {min = 1, max = 2},
        price = {min = 250, max = 450},
    },
    ['heroin_shot'] = {
        quantity = {min = 1, max = 2},
        price = {min = 600, max = 900},
    },
    ['coke_pooch'] = {
        quantity = {min = 1, max = 2},
        price = {min = 500, max = 800},
    },
    ['crack_pooch'] = {
        quantity = {min = 1, max = 2},
        price = {min = 700, max = 900},
    },
    ['meth_pooch'] = {
        quantity = {min = 1, max = 2},
        price = {min = 350, max = 650},
    },
    ['perc_pooch'] = {
        quantity = {min = 1, max = 2},
        price = {min = 100, max = 250},
    },
    ['ketamine'] = {
        quantity = {min = 1, max = 2},
        price = {min = 100, max = 250},
    },
    ['blacktar'] = {
        quantity = {min = 1, max = 2},
        price = {min = 100, max = 250},
    },
    ['speedball'] = {
        quantity = {min = 1, max = 2},
        price = {min = 100, max = 250},
    },
    ['flakka'] = {
        quantity = {min = 1, max = 2},
        price = {min = 100, max = 250},
    },
    
}

Config.CopRequired = 100
Config.CopAlertPercentage = 20 --% max 100
Config.CopAlertBlipTime = 60 --in sec
Config.Cops = {
    ['police'] = true,
    ['sheriff'] = true,
}
Config.RestrictedJobs = {
    ['police'] = false,
    ['sheriff'] = false,
    ['ambulance'] = false,
}

Config.AutoSelling = false -- disable Anti_AFK_Sell if you want this
Config.Anti_AFK_Sell = true
Config.Check_AFK_Sell = {min = 3, max = 5} -- in minute

--=====================================Sell to Local NPC IF UseExistingPed is enabled ===================================
Config.UseExistingPed = false -- Enable if you want to use existing NPC
Config.DistanceForExistingNpc = 30.0
Config.WantToUsePedList = false
Config.PedList = {  -- list of peds that will triggered on start-sell
    [`g_f_y_families_01`] = true,
    [`g_m_y_ballaeast_01`] = true,
    [`g_f_y_ballas_01`] = true,
    [`g_m_y_ballaorig_01`] = true,
    [`g_f_y_vagos_01`] = true,
    [`g_m_y_famca_01`] = true,
    [`g_m_y_famdnf_01`] = true,
    [`g_m_y_ballasout_01`] = true,
    [`a_f_y_soucent_02`] = true,
    [`a_f_y_soucent_01`] = true,
    [`a_m_m_afriamer_01`] = true,
    [`a_m_m_hillbilly_02`] = true,
    [`a_m_m_soucent_03`] = true,
    [`a_m_m_soucent_01`] = true,
    [`a_m_m_tramp_01`] = true,
    [`a_m_m_trampbeac_01`] = true,
    [`a_m_o_soucent_02`] = true,
    [`a_m_o_soucent_03`] = true,
    [`a_m_o_tramp_01`] = true,
} --more peds https://docs.fivem.net/docs/game-references/ped-models
--===========================================================================================

--=====================================Sell to Spawned NPC IF UseExistingPed is disabled ===================================
Config.MaxCustomer = 3
Config.RejectPercentage = 20 --% max 100
Config.CustomerPeds = {--more peds https://docs.fivem.net/docs/game-references/ped-models
    `g_f_y_families_01`,
    `g_m_y_ballaeast_01`,
    `g_f_y_ballas_01`,
    `g_m_y_ballaorig_01`,
    `g_f_y_vagos_01`,
    `g_m_y_ballasout_01`,
    `g_m_y_famca_01`,
    `g_m_y_famdnf_01`,
    `a_f_y_soucent_02`,
    `a_f_y_soucent_01`,
    `a_m_m_afriamer_01`,
    `a_m_m_hillbilly_02`,
    `a_m_m_soucent_01`,
    `a_m_m_soucent_03`,
    `a_m_m_tramp_01`,
    `a_m_m_trampbeac_01`,
    `a_m_o_soucent_02`,
    `a_m_o_soucent_03`,
    `a_m_o_tramp_01`,
}
--===========================================================================================

--===================================Enable if you want to make zones for drug selling====================
Config.PolyZoneSell = false -- required PolyZone https://github.com/mkafrin/PolyZone
Config.DebugPoly = false
Config.AllowedZones = {
    grove = {       -- unique name for this config
        drugs = {   -- remove this, if you want to sell all drugs from Config.DrugList
            ['weed_pooch'] = {
                quantity = {min = 1, max = 3},
                price = {min = 500, max = 1000},
            },
            ['spice_pooch'] = {
                quantity = {min = 1, max = 2},
                price = {min = 250, max = 500},
            },
        },
        zone = {
            vector2(123.16938018799, -1937.4445800781),
            vector2(122.71690368652, -1945.1173095703),
            vector2(118.6974029541, -1952.9333496094),
            vector2(111.18740844727, -1957.8994140625),
            vector2(99.199844360352, -1960.0234375),
            vector2(88.683479309082, -1960.4962158203),
            vector2(80.69393157959, -1936.0451660156),
            vector2(24.110830307007, -1888.6108398438),
            vector2(-34.693851470947, -1838.3955078125),
            vector2(-53.204639434814, -1860.5461425781),
            vector2(-84.18017578125, -1834.83203125),
            vector2(-65.354019165039, -1812.3083496094),
            vector2(-77.551910400391, -1801.9088134766),
            vector2(-61.918254852295, -1784.1629638672),
            vector2(-36.637001037598, -1805.2908935547),
            vector2(-10.519665718079, -1774.1127929688),
            vector2(8.064642906189, -1797.1517333984),
            vector2(-16.082714080811, -1823.6583251953),
            vector2(-5.0899410247803, -1832.5422363281),
            vector2(15.734113693237, -1803.6323242188),
            vector2(27.537557601929, -1813.6357421875),
            vector2(10.478675842285, -1832.3507080078),
            vector2(14.07594203949, -1835.6130371094),
            vector2(7.8493189811707, -1843.3927001953),
            vector2(59.444324493408, -1886.5167236328),
            vector2(82.796524047852, -1858.6134033203),
            vector2(104.94819641113, -1870.8851318359),
            vector2(78.168190002441, -1902.1865234375),
            vector2(95.838455200195, -1916.55078125),
            vector2(117.83142089844, -1926.1085205078),
        },
    },
}
