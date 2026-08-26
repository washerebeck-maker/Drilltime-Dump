Config = {}
Config.Locale = 'en'

Config.Marker = {
	r = 250, g = 0, b = 0, a = 100,  -- red color
	x = 1.0, y = 1.0, z = 1.5,       -- tiny, cylinder formed circle
	DrawDistance = 15.0, Type = 2    -- default circle type, low draw distance due to indoors area
}

Config.PoliceNumberRequired = 3
Config.TimerBeforeNewRob    = 2600 -- The cooldown timer on a store after robbery was completed / canceled, in seconds

Config.MaxDistance    = 15   -- max distance from the robbary, going any longer away from it will to cancel the robbary
Config.GiveBlackMoney = true -- give black money? If disabled it will give cash instead

Stores = {
    ["ConvenienceStore1"] = {
        position = vector3(1961.1873, 3748.8645, 32.3437),
        reward = math.random(82000, 200000),
        nameOfStore = "Convenience Store",
        secondsRemaining = 200, 
        lastRobbed = 900
    },
    ["ConvenienceStore2"] = {
        position = vector3(1160.6149, -314.2176, 69.2052),
        reward = math.random(82000, 200000),
        nameOfStore = "Convenience Store",
        secondsRemaining = 200, 
        lastRobbed = 900
    },
    ["ConvenienceStore3"] = {
        position = vector3(379.0352, 332.4716, 103.5664),
        reward = math.random(82000, 200000),
        nameOfStore = "Convenience Store",
        secondsRemaining = 200, 
        lastRobbed = 900
    },
    ["ConvenienceStore4"] = {
        position = vector3(29.0361, -1340.0282, 29.4970),
        reward = math.random(82000, 200000),
        nameOfStore = "Convenience Store",
        secondsRemaining = 200, 
        lastRobbed = 900
    },
    ["ConvenienceStore5"] = {
        position = vector3(-43.8379, -1749.1329, 29.4210),
        reward = math.random(82000, 200000),
        nameOfStore = "Convenience Store",
        secondsRemaining = 200, 
        lastRobbed = 900
    },
    ["iphone"] = {
        position = vector3(162.4191, -1056.2678, 29.3517),
        reward = math.random(82000, 200000),
        nameOfStore = "Iphone",
        secondsRemaining = 200, 
        lastRobbed = 900
    },
    ["bank"] = {
        position = vector3(146.6772, -1044.8774, 29.3778),
        reward = math.random(85000, 140000),
        nameOfStore = "Bank",
        secondsRemaining = 300, 
        lastRobbed = 900
    },
    ["Bank2"] = {
        position = vector3(310.8181, -283.1609, 54.1745),
        reward = math.random(58000, 105000),
        nameOfStore = "Bank",
        secondsRemaining = 200, 
        lastRobbed = 900
    },
    ["Bank3"] = {
        position = vector3(-354.0517, -53.9889, 49.0463),
        reward = math.random(58000, 105000),
        nameOfStore = "Bank",
        secondsRemaining = 200, 
        lastRobbed = 900
    },
    ["Bank5"] = {
        position = vector3(-1211.6790, -335.8490, 37.7908),
        reward = math.random(58000, 105000),
        nameOfStore = "Bank",
        secondsRemaining = 200, 
        lastRobbed = 900
    },
    ["Bank4"] = {
        position = vector3(254.0910, 224.9566, 101.8758),
        reward = math.random(185000, 310000),
        nameOfStore = "Big Bank",
        secondsRemaining = 200, 
        lastRobbed = 900
    },
}
