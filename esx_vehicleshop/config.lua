Config                            = {}
Config.DrawDistance               = 10
Config.MarkerColor                = {r = 120, g = 120, b = 240}
Config.EnablePlayerManagement     = false -- enables the actual car dealer job. You'll need esx_addonaccount, esx_billing and esx_society
Config.ResellPercentage           = 50

Config.Locale                     = 'en'

Config.LicenseEnable = false -- require people to own drivers license when buying vehicles? Only applies if EnablePlayerManagement is disabled. Requires esx_license

-- looks like this: 'LLL NNN'
-- The maximum plate length is 8 chars (including spaces & symbols), don't go past it!
Config.PlateLetters  = 3
Config.PlateNumbers  = 3
Config.PlateUseSpace = true

Config.Blip = {
	show = true,
	Sprite = 326,
	Display = 4,
	Scale = 1.0
}

Config.OxInventory = ESX.GetConfig().OxInventory

Config.Zones = {

	ShopEntering = {
		Pos   = vector3(-36.4073, -1101.6482, 25.4223),
		Size  = {x = 1.5, y = 1.5, z = 1.0},
		Type  = 1
	},

	ShopInside = {
		Pos     = vector3(-41.7370, -1098.9686, 26.0127),
		Size    = {x = 1.5, y = 1.5, z = 1.0},
		Heading = 167.2674,
		Type    = -1
	},

	ShopOutside = {
		Pos     = vector3(-46.3347, -1077.1653, 26.3232),
		Size    = {x = 1.5, y = 1.5, z = 1.0},
		Heading = 76.5519,
		Type    = -1
	},

	BossActions = {
		Pos   = vector3(320.24, 1297.52, 20.16),
		Size  = {x = 1.5, y = 1.5, z = 1.0},
		Type  = -1
	},

	GiveBackVehicle = {
		Pos   = vector3(-18.2, -1078.5, 25.6),
		Size  = {x = 3.0, y = 3.0, z = 1.0},
		Type  = (Config.EnablePlayerManagement and 1 or -1)
	},

	ResellVehicle = {
		Pos   = vector3(800.4, 345.1, 273.6),
		Size  = {x = 3.0, y = 3.0, z = 1.0},
		Type  = 1
	}

}
