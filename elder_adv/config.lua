Config = {}

Config.Command = 'adv'

Config.CoolDown = 600 -- seconds

Config.ADV = {
    ['uwucafe'] = {
        [1] = {
            title = 'BURGER SHOT',
            text = '[BURGER SHOT OPEN] Postal 8092 stop by and make an order.',
            color = {166,0,0},
            icon = 'fa-mug-hot',
            allowedgrades = {0, 1, 2, 3, 4},
            price = 5000
        },
        [2] = {
            title = 'BURGER SHOT',
            text = 'UWU Cafe Open!! stop by!!!, Postal 8092',
            color = {166,0,0},
            icon = 'fa-mug-hot',
            allowedgrades = {0, 1, 2, 3, 4},
            price = 5000
        },
	},
    ['Ammunation'] = {
        [1] = {
            title = 'Ammunation',
            text = '[AMMUNATION OPEN] Postal 8168 stop by for bullet needs.',
            color = {139,0,0},
            icon = 'fa-store',
            allowedgrades = {0, 1, 2, 3, 4},
            price = 5
        },
	},
    ['shoestore'] = {
        [1] = {
            title = 'Drill Kickz',
            text = '[SHOES IN STOCK] Postal 7188 stop by for bulk shoes',
            color = {0,153,255},
            icon = 'fa-store',
            allowedgrades = {0, 1, 2, 3, 4},
            price = 5
        },
	},
    ['mechanic1'] = {
        [1] = {
            title = 'Mechanic',
            text = 'MECHANIC SHOP OPEN @ BROOKLYN NEAR 950',
            color = {255,127,80},
            icon = 'fa-wrench',
            allowedgrades = {0, 1, 2, 3, 4},
            price = 5000
        },
	},
    ['mechanic11'] = {
        [1] = {
            title = 'Mechanic',
            text = 'MECHANIC SHOP OPEN @ POSTAL 9131',
            color = {255,127,80},
            icon = 'fa-wrench',
            allowedgrades = {0, 1, 2, 3, 4},
            price = 50
        },
	},
    ['mechanic2'] = {
        [1] = {
            title = 'Mechanic',
            text = 'MECHANIC SHOP OPEN @ POSTAL 9131',
            color = {255,127,80},
            icon = 'fa-wrench',
            allowedgrades = {0, 1, 2, 3, 4},
            price = 50
        },
	},
    ['ambulance'] = {
        [1] = {
            title = 'EMS',
            text = 'PRESS G TO CALL EMS!! WE ARE ON DUTY!!',
            color = {255,0,0},
            icon = 'fa-toolbox',
            allowedgrades = {0, 1, 2, 3, 4},
            price = 5
        },
	},
    ['mechanic3'] = {
        [1] = {
            title = 'Mechanic',
            text = 'MECHANIC SHOP OPEN @ POSTAL 302',
            color = {255,127,80},
            icon = 'fa-toolbox',
            allowedgrades = {0, 1, 2, 3, 4},
            price = 5
        },
        [2] = {
            title = 'Mechanic',
            text = 'LUCKY CASINO OPEN BRONX POSTAL 757',
            color = {238,130,238},
            icon = 'fa-die',
            allowedgrades = {0, 1, 2, 3, 4},
            price = 5
        },
        [3] = {
            title = 'Mechanic',
            text = 'BETTER ODDS!! CASINO OPEN BRONX POSTAL 757',
            color = {238,130,238},
            icon = 'fa-die',
            allowedgrades = {0, 1, 2, 3, 4},
            price = 5
        },
	},
    ['mechanic10'] = {
        [1] = {
            title = 'Mechanic',
            text = 'MECHANIC SHOP OPEN @ POSTAL 948',
            color = {255,127,80},
            icon = 'fa-toolbox',
            allowedgrades = {0, 1, 2, 3, 4},
            price = 50
        },
	},
    ['miner'] = {
        [1] = {
            title = 'DISCORD PROMO',
            text = 'BE SURE TO CHECK OUT DISCORD GG/DRILLTIME',
            color = {129,20,192},
            icon = 'fa-discord',
            allowedgrades = {0, 1, 2, 3, 4},
            price = 0
        },
        [2] = {
            title = 'REDZONE SHOP',
            text = 'Check out /leaderboard every kill at redzone is 1 coin!!',
            color = {129,20,192},
            icon = 'fa-gun',
            allowedgrades = {0, 1, 2, 3, 4},
            price = 0
        },
        [3] = {
            title = 'Mechanic',
            text = 'POSTAL 70 FOR BLACK MARKET AND MARKET PLACE',
            color = {0,0,0},
            icon = 'fa-user-secret',
            allowedgrades = {0, 1, 2, 3, 4},
            price = 0
        },
        [4] = {
            title = 'Mechanic',
            text = '[GUNSTORE] Ammu☆Nation POSTAL 8168',
            color = {102,178,178},
            icon = 'fa-crosshairs',
            allowedgrades = {0, 1, 2, 3, 4},
            price = 0
        },
	},
    ['WhiteWidow'] = {
        [1] = {
            title = 'WhiteWidow',
            text = 'WhiteWidow OPEN POSTAL 446 ( BOWS FOR 100K ) COME SHOP',
            color = {34,139,34},
            icon = 'fa-cannabis',
            allowedgrades = {0, 1, 2, 3, 4},
            price = 5000
        },
	},
    ['weedstore'] = {
        [1] = {
            title = 'WeedStore',
            text = 'BUBBA KUSH POSTAL 8065 300pack $100k',
            color = {238,130,238},
            icon = 'fa-cannabis',
            allowedgrades = {0, 1, 2, 3, 4},
            price = 5
        },
	},
    ['runtz'] = {
        [1] = {
            title = 'Runtz',
            text = 'RUNTZ OPEN POSTAL 7209 ( BOWS FOR 100K ) COME SHOP',
            color = {238,130,238},
            icon = 'fa-cannabis',
            allowedgrades = {0, 1, 2, 3, 4},
            price = 5000
        },
    },
}

Config.AutoADV = {
    [1] = {
            title = 'REPORT',
            text = '[REPORT] /REPORT ( report any RDM or NLR) 2min clip required',
            color = {255,0,0},
            icon = 'fa-hammer',
        time = 1112300,
    },
}