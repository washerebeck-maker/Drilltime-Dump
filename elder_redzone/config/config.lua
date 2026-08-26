config = {}

config.locations = {
    {
        label = 'JUNGLE',
        coords = vec3(443.6973, -1519.5159, 29.2870),
        radius = 70.0,
        extra_radius = 60.0,
        prep_duration = 120,
        duration = 7 * 60,
        revive_time = 10,
        revive_locations = {
            vec3(480.0372, -1594.6239, 29.2701),
            vec3(446.0794, -1598.1500, 29.3237),
            vec3(410.1107, -1589.8857, 29.4830),
            vec3(377.8145, -1561.6600, 29.5148),
            vec3(362.9044, -1526.4144, 29.2911),
            vec3(394.1523, -1462.0786, 29.1158),
            vec3(446.5049, -1442.2891, 29.3641),
            vec3(490.8141, -1457.1956, 29.2088),
            vec3(517.8677, -1507.0272, 29.1885),
            vec3(514.4244, -1537.4470, 29.1270),
        },
    },
    {
        label = 'LIL MEXICO',
        coords = vec3(390.3838, -345.9703, 46.8152),
        radius = 45.0,
        extra_radius = 60.0,
        prep_duration = 120,
        duration = 7 * 60,
        revive_time = 10,
        revive_locations = {
            vector3(355.9826, -382.5690, 45.2295),
            vector3(411.5435, -387.6699, 46.9593),
            vector3(429.4495, -372.3446, 47.0849),
            vector3(415.1754, -304.4941, 50.7087),
            vector3(399.1921, -298.5103, 51.8617),
            vector3(344.5406, -324.4635, 50.7953),
        },
    },
    {
        label = 'CHINA WOK',
        coords = vec3(-635.8111, -1211.9591, 12.3806),
        radius = 55.0,
        extra_radius = 60.0,
        prep_duration = 120,
        duration = 7 * 60,
        revive_time = 10,
        revive_locations = {
            vector3(-646.9477, -1276.2651, 10.7179),
            vector3(-566.7217, -1237.8898, 14.9251),
            vector3(-583.3943, -1182.0693, 17.9437),
            vector3(-592.3721, -1171.2599, 17.2338),
            vector3(-642.4929, -1150.5387, 9.0760),
            vector3(-682.8017, -1167.0098, 10.7451),
        },
    },
    {
        label = 'MEGA MALL',
        coords = vec3(1.4282, -1757.2543, 29.3029),
        radius = 55.0,
        extra_radius = 60.0,
        prep_duration = 120,
        duration = 7 * 60,
        revive_time = 10,
        revive_locations = {
            vector3(11.6970, -1822.4764, 25.0722),
            vector3(-22.6233, -1817.6271, 26.0127),
            vector3(-56.1172, -1770.0105, 28.9986),
            vector3(-55.2588, -1731.4768, 29.1959),
            vector3(-7.9851, -1700.1486, 29.3356),
            vector3(34.9785, -1704.2576, 29.3270),
            vector3(58.1642, -1722.9639, 29.3029),
        },
    },
    {
        label = 'DOCKS',
        coords = vec3(-301.3685, -2593.1897, 6.0103),
        radius = 55.0,
        extra_radius = 60.0,
        prep_duration = 120,
        duration = 7 * 60,
        revive_time = 10,
        revive_locations = {                
            vector3(-316.7722, -2534.9753, 6.0006),
            vector3(-366.2032, -2600.9280, 5.9952),
            vector3(-337.1661, -2646.0154, 5.9963),
            vector3(-265.5821, -2646.0906, 6.0050),
            vector3(-243.9382, -2617.2346, 6.0873),
            vector3(-239.2896, -2604.5488, 5.9955),
            vector3(-246.0314, -2566.9465, 6.2202),
        },
    },
}

config.blip = {
    enable = true,
    sprite = 437,
    color = 1,
    scale = 0.8,
    display = 4,
    short_range = true,
    label = 'TURF',
}

config.active_blip = {
    enable = true,
    sprite = 161,
    color = 1,
    scale = 2.0,
    display = 4,
    short_range = false,
    flash = true,
    label = 'TURF ACTIVE',
}

config.start_marker = {
    draw_distance = 20.0,
    interact_distance = 2.0,
    type = 27,
    z_offset = -0.95,
    scale = vec3(1.6, 1.6, 1.0),
    color = { r = 252, g = 38, b = 76, a = 140 },

    extra = {
        enable = true,
        type = 31,
        z_offset = 0.75,
        scale = vec3(1.5, 1.5, 1.5),
        color = { r = 252, g = 38, b = 76, a = 180 },
        bob = true,
        face_camera = true,
        rotate = false,
    },

    prompt = {
        title = 'TURF',
        text = 'Start',
        key = 'E',
        control = 38,
        color = 'red',
    },
}

config.zone_marker = {
    draw_distance = 500.0,
    type = 28,
    color = { r = 255, g = 0, b = 0, a = 85 },
}

config.cooldown = 15 * 60

config.timer = {
    show_everywhere = false,
}

config.items = {
    { item = 'xpills', min = 0, max = 1},
    { item = 'burgerwaxcin', min = 0, max = 2},
    { item = 'blood_sample', min = 0, max = 2},
    { item = 'black_money', min = 423, max = 683},
}

config.coin_multiplier = 1

config.give_weapon = true
config.weapon = `WEAPON_DTP`
config.weapon_ammo = 685
config.loot = {
    enable = false,
    items = {'burger', 'water'},
}

config.hud = {
    ranks = {
        'Radiant',
        'Immortal',
        'Ascendant',
    }
}

config.delete_vehicle = true
