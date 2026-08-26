Config = {}

Config.JobCenter = {
    coords = vector4(1234.0470, -354.8069, 69.0822, 79.1226),
    ped = 'csb_tomcasino',
}

Config.Jobs = {
    --[[["cookies_delivery"] = {
        title = 'Cookies Delivery',
        description = '',
        icon = 'fa-cannabis',
        color = 'green',
        event = 'elder_jobs:client:cookies_delivery_job',
        leave_job_event = 'elder_jobs:client:leave_cookies_job',
        limited = {enabled = true, limit = 10},
    },]]
    ["food_delivery"] = {
        title = 'Food Delivery',
        description = '',
        icon = 'fa-burger',
        color = 'orange',
        event = 'elder_jobs:client:food_delivery_job',
        leave_job_event = 'elder_jobs:client:leave_food_job',
        limited = {enabled = false, limit = 0},
    },
    ["taxi"] = {
        title = 'Taxi Driver',
        description = '',
        icon = 'fa-taxi',
        color = 'yellow',
        event = 'elder_jobs:client:taxi_job',
        leave_job_event = '',
        limited = {enabled = false, limit = 0},
    },
}

Config.FoodDelivery = {
    restaurants = {
        { coords = vector4(1231.0568, -347.9370, 69.0927, 95.0390), ped = 's_m_y_waiter_01'},
        { coords = vector4(1230.2177, -359.6459, 69.0932, 110.4184), ped = 's_m_y_waiter_01'},
        { coords = vector4(1240.9697, -368.3104, 69.0822, 155.7055), ped = 's_m_y_waiter_01'},
    },
    delivery_locations = {
        vector3(1172.1128, -377.4226, 68.1825),
        vector3(1301.1876, -573.8095, 71.732),
        vector3(1138.9554, -962.5208, 47.5327),
        vector3(759.3430, -909.5929, 25.2784),
        vector3(372.4881, -1072.6887, 29.4828),
        vector3(-295.4728, -829.5255, 32.4157),
        vector3(-308.1477, -163.8860, 40.4245),
        vector3(-718.6053, -854.7600, 23.0250),
        vector3(-1213.2434, -406.9316, 34.1401),
        vector3(-581.5990, -1000.8513, 22.3297),
        vector3(-42.1721, -1792.2412, 27.8282),
        vector3(87.4220, -1670.2296, 29.1848),
        vector3(494.0048, -1541.7330, 29.2875),
        vector3(440.4207, -1584.3845, 29.2886),
        vector3(1147.9946, -451.1563, 66.9843),
    },
    vehicle = 'hymn_delivery',
    vehicle_pos = vector4(1228.8547, -354.7068, 69.0925, 71.6622),
    delivery_count = ( math.random(1,100) % 30 ) + 1,
    price_per_delivery = math.random(4700,5700),
    price_tip = math.random(5,100),
}

Config.CookiesDelivery = {
    pickup = {
        { coords = vector4(560.0681, 2329.7356, 17.9283, 179.0751), ped = 'a_m_m_og_boss_01'},
    },
    delivery_locations = {
        vector3(1172.1128, -377.4226, 68.1825),
        vector3(1301.1876, -573.8095, 71.732),
        vector3(1138.9554, -962.5208, 47.5327),
        vector3(759.3430, -909.5929, 25.2784),
        vector3(372.4881, -1072.6887, 29.4828),
        vector3(-295.4728, -829.5255, 32.4157),
        vector3(-308.1477, -163.8860, 40.4245),
        vector3(-718.6053, -854.7600, 23.0250),
        vector3(-1213.2434, -406.9316, 34.1401),
        vector3(-581.5990, -1000.8513, 22.3297),
        vector3(-42.1721, -1792.2412, 27.8282),
        vector3(87.4220, -1670.2296, 29.1848),
        vector3(494.0048, -1541.7330, 29.2875),
        vector3(440.4207, -1584.3845, 29.2886),
        vector3(1147.9946, -451.1563, 66.9843),
    },
    vehicle = 'cookies',
    vehicle_pos = vector4(295.2129, 681.1378, 14.7503, 88.814),
    delivery_count = ( math.random(1,100) % 30 ) + 1,
    price_per_delivery = math.random(5300,7400),
    price_tip = math.random(5,100),
}