Config = {}

Config.EnableHUD = true

Config.cascadingFailureThreshold = 360.0

Config.fuelRefuelDuration = 15

Config.fuelRefuelPrice = 7500

Config.fuelRefuelCooldownSeconds = 10

Config.fuelTankDurationSeconds = 48 * 60 * 60

Config.stationRefuelPrice = 5000

Config.fuelCancelDistance = 5.0

Config.FuelDecor = '_FUEL_LEVEL'

Config.Classes = {
    [0]  = 1.0,  
    [1]  = 1.0,  
    [2]  = 1.0,  
    [3]  = 1.0,  
    [4]  = 1.0,  
    [5]  = 1.0,  
    [6]  = 1.0,  
    [7]  = 1.0,  
    [8]  = 1.0,  
    [9]  = 1.0,  
    [10] = 1.0,  
    [11] = 1.0,  
    [12] = 1.0,  
    [13] = 0.0,  
    [14] = 1.0,  
    [15] = 1.0,  
    [16] = 1.0,  
    [17] = 1.0,  
    [18] = 1.0,  
    [19] = 1.0,  
    [20] = 1.0,  
    [21] = 1.0,  
}

Config.FuelUsage = {
    [1.0] = 1.4,
    [0.9] = 1.2,
    [0.8] = 1.0,
    [0.7] = 0.9,
    [0.6] = 0.8,
    [0.5] = 0.7,
    [0.4] = 0.5,
    [0.3] = 0.4,
    [0.2] = 0.2,
    [0.1] = 0.1,
    [0.0] = 0.0,
}

Config.pumpInteractionDistance = 3.0

Config.Strings = {
    ExitVehicle = 'Exit the vehicle to refuel',
    EToRefuel   = 'Press [E] to refuel vehicle  [$%s]',
    FullTank    = 'Tank is full',
}

Config.PumpModels = {
    [-2007231801] = true,
    [ 1339433404] = true,
    [ 1694452750] = true,
    [ 1933174915] = true,
    [ -462817101] = true,
    [ -469694731] = true,
    [ -164877493] = true,
}

Config.FuelStations = {
    {
        name   = 'FuelStation1',
        coords = vec3(49.4187, 2778.793, 58.043),
        radius = 25.0,
        owner  = '8bc1180f9a8eb6ffe65b2261106da88b922e357b',
    },
    {
        name   = 'FuelStation2',
        coords = vec3(263.894, 2606.463, 44.983),
        radius = 25.0,
        owner  = '8bc1180f9a8eb6ffe65b2261106da88b922e357b',
    },
    {
        name   = 'FuelStation3',
        coords = vec3(1039.958, 2671.134, 39.550),
        radius = 25.0,
        owner  = '8bc1180f9a8eb6ffe65b2261106da88b922e357b',
    },
    {
        name   = 'FuelStation4',
        coords = vec3(1207.260, 2660.175, 37.899),
        radius = 25.0,
        owner  = '8bc1180f9a8eb6ffe65b2261106da88b922e357b',
    },
    {
        name   = 'FuelStation5',
        coords = vec3(2539.685, 2594.192, 37.944),
        radius = 25.0,
        owner  = '8bc1180f9a8eb6ffe65b2261106da88b922e357b',
    },
    {
        name   = 'FuelStation6',
        coords = vec3(2679.858, 3263.946, 55.240),
        radius = 25.0,
        owner  = '8bc1180f9a8eb6ffe65b2261106da88b922e357b',
    },
    {
        name   = 'FuelStation7',
        coords = vec3(2005.055, 3773.887, 32.403),
        radius = 25.0,
        owner  = '8bc1180f9a8eb6ffe65b2261106da88b922e357b',
    },
    {
        name   = 'FuelStation8',
        coords = vec3(1687.156, 4929.392, 42.078),
        radius = 25.0,
        owner  = '8bc1180f9a8eb6ffe65b2261106da88b922e357b',
    },
    {
        name   = 'FuelStation9',
        coords = vec3(1701.314, 6416.028, 32.763),
        radius = 25.0,
        owner  = '8bc1180f9a8eb6ffe65b2261106da88b922e357b',
    },
    {
        name   = 'FuelStation10',
        coords = vec3(179.857, 6602.839, 31.868),
        radius = 25.0,
        owner  = '8bc1180f9a8eb6ffe65b2261106da88b922e357b',
    },
    {
        name   = 'FuelStation11',
        coords = vec3(-94.4619, 6419.594, 31.489),
        radius = 25.0,
        owner  = '8bc1180f9a8eb6ffe65b2261106da88b922e357b',
    },
    {
        name   = 'FuelStation12',
        coords = vec3(-2554.996, 2334.40, 33.078),
        radius = 25.0,
        owner  = '8bc1180f9a8eb6ffe65b2261106da88b922e357b',
    },
    {
        name   = 'FuelStation13',
        coords = vec3(-1800.375, 803.661, 138.651),
        radius = 25.0,
        owner  = '8bc1180f9a8eb6ffe65b2261106da88b922e357b',
    },
    {
        name   = 'FuelStation14',
        coords = vec3(-1437.622, -276.747, 46.207),
        radius = 25.0,
        owner  = '8bc1180f9a8eb6ffe65b2261106da88b922e357b',
    },
    {
        name   = 'FuelStation15',
        coords = vec3(-2096.243, -320.286, 13.168),
        radius = 25.0,
        owner  = '8bc1180f9a8eb6ffe65b2261106da88b922e357b',
    },
    {
        name   = 'FuelStation16',
        coords = vec3(-724.619, -935.1631, 19.213),
        radius = 25.0,
        owner  = '33a24beeb66ae46de16400c7f9c7d1d9b6adf7bd',
	--youngworld
    },
    {
        name   = 'FuelStation17',
        coords = vec3(-526.019, -1211.003, 18.184),
        radius = 25.0,
        owner  = '8bc1180f9a8eb6ffe65b2261106da88b922e357b',
    },
    {
        name   = 'FuelStation18',
        coords = vec3(-70.2148, -1761.792, 29.534),
        radius = 25.0,
        owner  = '33a24beeb66ae46de16400c7f9c7d1d9b6adf7bd',
	--youngworld
    },
    {
        name   = 'FuelStation19',
        coords = vec3(265.648, -1261.309, 29.292),
        radius = 25.0,
        owner  = '7b0a9d168972aa0bac2d38639f5df15b1add9b43',
	--Caneyelive
    },
    {
        name   = 'FuelStation20',
        coords = vec3(819.653, -1028.846, 26.403),
        radius = 25.0,
        owner  = '8bc1180f9a8eb6ffe65b2261106da88b922e357b',
    },
    {
        name   = 'FuelStation21',
        coords = vec3(1208.951, -1402.567, 35.224),
        radius = 25.0,
        owner  = '8bc1180f9a8eb6ffe65b2261106da88b922e357b',
    },
    {
        name   = 'FuelStation22',
        coords = vec3(1181.381, -330.847, 69.316),
        radius = 25.0,
        owner  = '9d61ecf39fb3eacfde959de2cf0d65eaa5aa4939',
        --shamurda187
    },
    {
        name   = 'FuelStation23',
        coords = vec3(620.843, 269.100, 103.089),
        radius = 25.0,
        owner  = '8bc1180f9a8eb6ffe65b2261106da88b922e357b',
    },
    {
        name   = 'FuelStation24',
        coords = vec3(2581.321, 362.039, 108.468),
        radius = 25.0,
        owner  = '8bc1180f9a8eb6ffe65b2261106da88b922e357b',
    },
    {
        name   = 'FuelStation25',
        coords = vec3(-3678.4854, -8444.1914, -1.0620),
        radius = 25.0,
        owner  = '8bc1180f9a8eb6ffe65b2261106da88b922e357b',
    },
    {
        name   = 'FuelStation26',
        coords = vec3(-319.292, -1471.715, 30.549),
        radius = 25.0,
        owner  = '8bc1180f9a8eb6ffe65b2261106da88b922e357b',
    },
    {
        name   = 'FuelStation27',
        coords = vec3(1784.324, 3330.55, 41.253),
        radius = 25.0,
        owner  = '8bc1180f9a8eb6ffe65b2261106da88b922e357b',
    },
    {
        name   = 'FuelStation28',
        coords = vec3(-209.2952, -1977.5089, 22.6889),
        radius = 25.0,
        owner  = '8bc1180f9a8eb6ffe65b2261106da88b922e357b',
    },
}
