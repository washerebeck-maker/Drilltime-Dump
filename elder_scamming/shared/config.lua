Config = {}

Config.PlayerScamming = {
    HackingTime = 90,
    GameDigitNumber = 6,
    HackerGameTimer = 40,
    HackedGameTimer = 50,
    FraudMoney = math.random(50000, 150000),
    RemoteHackAmount = math.random(25000,55000),
    MinPlayers = 5,
    MaxPlayers = 10,
    HackingItem = 'swiper',
    CyberCrimeFineAmount = 15000,
    HackingLocations = {
        vector3(-54.1185, -1213.6105, 28.6878),
    },
    HackingItems = {'cardhack', 'phonehack', 'scanhack'},
}

Config.ATMFraud = {
    ATMDistance = 2.0,
    ATMReaderTimer = 5 * 60,
    Reward = {Min = 45000, Max = 245000},
    ATMReaderItem = 'atmreader',
    LapTopItem = 'smlaptnewits',
    EmbosserItem = 'embosser',
    BlankCardItem = 'cardhack',
    ATMFileItem = 'atmfile',
    EmbossCardItem = 'embosscard',
    FraudCardItem = 'fraudcard',
    ATMModels = {-870868698, -1126237515, -1364697528, 506770882},
}

Config.DarkWeb = {
    Items = {
        ["atmreader"] = {
            name = "atmreader",
            price = 9500,
            weeklyStock = 25,
        },
        ["embosser"] = {
            name = "embosser",
            price = 500000,
            weeklyStock = 2,
        },
        ["cardhack"] = {
            name = "cardhack",
            price = 2680,
            weeklyStock = 30,
        },
        ["newswiper"] = {
            name = "newswiper",
            price = 15000,
            weeklyStock = 20,
        },
        ["phonehack"] = {
            name = "phonehack",
            price = 5000,
            weeklyStock = 12,
        },
        ["scanhack"] = {
            name = "scanhack",
            price = 8000,
            weeklyStock = 12,
        },
        ["swiper"] = {
            name = "swiper",
            price = 15000,
            weeklyStock = 10,
        },
    }  
}