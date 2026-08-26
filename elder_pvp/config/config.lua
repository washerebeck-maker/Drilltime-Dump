Config = {}

Config.ImagesPath = 'nui://ox_inventory/web/images/'

Config.OpenCommand = 'pvp'

Config.PreliminaryPhaseDuration = 10

Config.CountDownPhaseDuration = 5

Config.GamePhaseDuration = 60

Config.CityLocation = vector3(3747.0801, 1178.5304, 5.7392)

Config.MapLocations = {
    coords = vector3(-1951.4087, -1502.4005, 320.8635),
    radius = 50,
    coords1 = vector4(3761.8042, 1179.2761, 6.5249, 97.0665),
    coords2 = vector4(3731.7495, 1178.5306, 6.5249, 256.2793),
}

Config.GetItemLabel = function(_item)
	local item  = exports.ox_inventory:Items(_item)
	return item and item.label or _item
end

Config.Weapons = {
    {   value = 'WEAPON_DTP',
        label = Config.GetItemLabel('WEAPON_DTP')
    },
    { 
        value = 'WEAPON_DTAP',          
        label = Config.GetItemLabel('WEAPON_DTAP')
    },
    { 
        value = 'WEAPON_GFXSIX',    
        label = Config.GetItemLabel('WEAPON_GFXSIX')
    },
}
