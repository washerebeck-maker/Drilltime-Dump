Config                            = {}

Config.DrawDistance               = 10.0 -- How close do you need to be in order for the markers to be drawn (in GTA units).
Config.Debug                      = ESX.GetConfig().EnableDebug
Config.Marker                     = {type = 1, x = 1.5, y = 1.5, z = 0.5, r = 102, g = 0, b = 102, a = 100, rotate = false}

Config.ReviveReward               = 15000  -- Revive reward, set to 0 if you don't want it enabled
Config.SaveDeathStatus              = true -- Save Death Status?
Config.LoadIpl                    = true -- Disable if you're using fivem-ipl or other IPL loaders

Config.Locale                     = 'en'

Config.DistressBlip = {
	Sprite = 310,
	Color = 48,
	Scale = 2.0
}

Config.EarlyRespawnTimer          = 60000 * 4  -- time til respawn is available
Config.BleedoutTimer              = 60000 * 4 -- time til the player bleeds out


Config.EnablePlayerManagement     = true -- Enable society managing (If you are using esx_society).

Config.RemoveWeaponsAfterRPDeath  = false
Config.RemoveCashAfterRPDeath     = false
Config.RemoveItemsAfterRPDeath    = false

-- Let the player pay for respawning early, only if he can afford it.
Config.EarlyRespawnFine           = false
Config.EarlyRespawnFineAmount     = 5000

Config.OxInventory                = ESX.GetConfig().OxInventory
Config.RespawnPoints = {
		{coords = vector3(312.3168, -589.2931, 43.2841), heading = 48.5},
		{coords = vector3(-1271.0358, 328.2797, 65.4975), heading = 167.71},
		{coords = vector3(-857.9754, -2168.1677, 9.9185), heading = 113.7397},
}

Config.Hospitals = {

	CentralLosSantos = {

		Blip = {
			coords = vector3(312.3867, -589.3220, 43.2841),
			sprite = 61,
			scale  = 1.2,
			color  = 2
		},

		AmbulanceActions = {
			vector3(304.2003, -600.3714, 43.2841)
		},

		Pharmacies = {
			vector3(306.6451, -601.7540, 43.2841)
		},

		Vehicles = {
			{
				Spawner = vector3(66.3599, -80.8669, -0.1587),
				InsideShop = vector3(69.2341, -79.6678, -0.1587),
				Marker = {type = 36, x = 1.0, y = 1.0, z = 1.0, r = 100, g = 50, b = 200, a = 100, rotate = true},
				SpawnPoints = {
					{coords = vector3(59.3, -100.5, 4.8), heading = 227.6, radius = 4.0},
					{coords = vector3(61.23, -94.2, 4.8), heading = 227.6, radius = 4.0},
					{coords = vector3(61.0, -85.7, 4.8), heading = 227.6, radius = 6.0}
				}
			}
		},

		Helicopters = {
			{
				Spawner = vector3(317.5, -1449.5, 46.5),
				InsideShop = vector3(305.6, -1419.7, 41.5),
				Marker = {type = 34, x = 1.5, y = 1.5, z = 1.5, r = 100, g = 150, b = 150, a = 100, rotate = true},
				SpawnPoints = {
					{coords = vector3(313.5, -1465.1, 46.5), heading = 142.7, radius = 10.0},
					{coords = vector3(299.5, -1453.2, 46.5), heading = 142.7, radius = 10.0}
				}
			}
		},

		FastTravels = {
			{
				From = vector3(294.7, -1448.1, 29.0),
				To = {coords = vector3(272.8, -1358.8, 23.5), heading = 0.0},
				Marker = {type = 1, x = 2.0, y = 2.0, z = 0.5, r = 102, g = 0, b = 102, a = 100, rotate = false}
			},

			{
				From = vector3(275.3, -1361, 23.5),
				To = {coords = vector3(295.8, -1446.5, 28.9), heading = 0.0},
				Marker = {type = 1, x = 2.0, y = 2.0, z = 0.5, r = 102, g = 0, b = 102, a = 100, rotate = false}
			},

			{
				From = vector3(247.3, -1371.5, 23.5),
				To = {coords = vector3(333.1, -1434.9, 45.5), heading = 138.6},
				Marker = {type = 1, x = 1.5, y = 1.5, z = 0.5, r = 102, g = 0, b = 102, a = 100, rotate = false}
			},

			{
				From = vector3(335.5, -1432.0, 45.50),
				To = {coords = vector3(249.1, -1369.6, 23.5), heading = 0.0},
				Marker = {type = 1, x = 2.0, y = 2.0, z = 0.5, r = 102, g = 0, b = 102, a = 100, rotate = false}
			},

			{
				From = vector3(234.5, -1373.7, 20.9),
				To = {coords = vector3(320.9, -1478.6, 28.8), heading = 0.0},
				Marker = {type = 1, x = 1.5, y = 1.5, z = 1.0, r = 102, g = 0, b = 102, a = 100, rotate = false}
			},

			{
				From = vector3(317.9, -1476.1, 28.9),
				To = {coords = vector3(238.6, -1368.4, 23.5), heading = 0.0},
				Marker = {type = 1, x = 1.5, y = 1.5, z = 1.0, r = 102, g = 0, b = 102, a = 100, rotate = false}
			}
		},

		FastTravelsPrompt = {
			{
				From = vector3(237.4, -1373.8, 26.0),
				To = {coords = vector3(251.9, -1363.3, 38.5), heading = 0.0},
				Marker = {type = 1, x = 1.5, y = 1.5, z = 0.5, r = 102, g = 0, b = 102, a = 100, rotate = false},
				Prompt = _U('fast_travel')
			},

			{
				From = vector3(256.5, -1357.7, 36.0),
				To = {coords = vector3(235.4, -1372.8, 26.3), heading = 0.0},
				Marker = {type = 1, x = 1.5, y = 1.5, z = 0.5, r = 102, g = 0, b = 102, a = 100, rotate = false},
				Prompt = _U('fast_travel')
			}
		}

	}
}

Config.AuthorizedVehicles = {
	car = {
		ambulance = {
			{model = 'dodgeems', price = 500},
			{model = 'emslambo', price = 3500000},
			{model = 'DBDLM5EMS', price = 4000000}
		},

		doctor = {
			{model = 'dodgeems', price = 500}
		},

		chief_doctor = {
			{model = 'dodgeems', price = 500}
		},

		boss = {
			{model = 'dodgeems', price = 500}
		}
	},

	helicopter = {
		ambulance = {},

		doctor = {
			{model = 'buzzard2', price = 150000}
		},

		chief_doctor = {
			{model = 'buzzard2', price = 150000},
			{model = 'seasparrow', price = 300000}
		},

		boss = {
			{model = 'buzzard2', price = 10000},
			{model = 'seasparrow', price = 250000}
		}
	}
}


Config.EMSVehicle = 'DBDLM5EMS'

Config.AmbulanceVehicles = {'ambo','dodgeems', 'ReepEms', 'DBDLM5EMS',}

Config.UI = {

    DeathScreenType = 3,
    UIColor = '#6a03a7ff',

    UIStrings = {
        player_dying = "YOU ARE DYING",
        player_passed = "YOU PASSED AWAY",
        ems_on_the_way = "Emergency services are on the way!",
        press_ems_services = "for Emergency Services",
        press_for_light = "to see the light",
        hold = "Hold",
        time_to_respawn = "Time left till respawn",
        press = "Press",
        player_hurt_critical = "Critical Condition!",
        player_hurt_severe = "You are severely hurt",
        player_hurt_unconscious = "Unconscious",
        player_hurt_unconscious_direct = "You are unconscious",
        player_hurt_find_help_or_ems = "Press <span class='color'>G</span> to request emergency services",
        player_hurt_time_to_live = "Bleeding out",
        player_hurt_auto_respawn = "Vitals fading",
        player_hurt_respawn = "Hold E to see the light",
        ems_online = "ASSISTANCE IS ONLINE",
        ems_offline = "ASSISTANCE UNAVAILABLE",
        currently_online = "CURRENTLY ONLINE: "
    }
}