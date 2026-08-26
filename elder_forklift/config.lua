Config = {}

Config.Location = {
    npc = 's_m_y_construct_01',
    npc_coords = vector4(1197.0076, -3253.6045, 7.0952, 88.7775),
    vehicle = 'forklift',
    vehicle_coords = vector4(1187.3015, -3250.5469, 5.6157, 359.9379),
    delivery_location = vector3(1200.5527, -3239.5647, 6.0288),
}

Config.Deliveries = {
    min = 25,
    max = 45,
    locations = {
        vector3(1273.5728, -3229.9597, 5.8249),
        vector3(1278.8036, -3329.9043, 5.8589),
        vector3(1156.5558, -3133.2944, 5.8653),
        vector3(1130.3934, -3278.2734, 5.8955),
        vector3(1166.7644, -3344.6631, 5.9016),
        vector3(1258.1737, -3074.5791, 5.8387),
        vector3(1116.2664, -3135.2454, 5.9012),
        vector3(1275.8761, -3190.8555, 5.8893),
        vector3(1132.2225, -3276.6843, 5.8999),
        vector3(1144.4778, -3087.0974, 5.7722),
        vector3(1273.5728, -3229.9597, 5.8249),
        vector3(1278.8036, -3329.9043, 5.8589),
        vector3(1156.5558, -3133.2944, 5.8653),
        vector3(1130.3934, -3278.2734, 5.8955),
        vector3(1166.7644, -3344.6631, 5.9016),
        vector3(1258.1737, -3074.5791, 5.8387),
        vector3(1116.2664, -3135.2454, 5.9012),
        vector3(1275.8761, -3190.8555, 5.8893),
        vector3(1132.2225, -3276.6843, 5.8999),
        vector3(1144.4778, -3087.0974, 5.7722),
        vector3(1273.5728, -3229.9597, 5.8249),
        vector3(1278.8036, -3329.9043, 5.8589),
        vector3(1156.5558, -3133.2944, 5.8653),
        vector3(1130.3934, -3278.2734, 5.8955),
        vector3(1166.7644, -3344.6631, 5.9016),
        vector3(1258.1737, -3074.5791, 5.8387),
        vector3(1116.2664, -3135.2454, 5.9012),
        vector3(1275.8761, -3190.8555, 5.8893),
        vector3(1132.2225, -3276.6843, 5.8999),
        vector3(1144.4778, -3087.0974, 5.7722),
        vector3(1273.5728, -3229.9597, 5.8249),
        vector3(1278.8036, -3329.9043, 5.8589),
        vector3(1156.5558, -3133.2944, 5.8653),
        vector3(1130.3934, -3278.2734, 5.8955),
        vector3(1166.7644, -3344.6631, 5.9016),
        vector3(1258.1737, -3074.5791, 5.8387),
        vector3(1116.2664, -3135.2454, 5.9012),
        vector3(1275.8761, -3190.8555, 5.8893),
        vector3(1132.2225, -3276.6843, 5.8999),
        vector3(1144.4778, -3087.0974, 5.7722),
    }
}

Config.Pay = {
    task = {min = 5521, max = 6784},
    reward = {min = 1000, max = 2000},
}


Config.Clothes = {
    male = {
        components = {
            { ['component_id'] = 0,  ['texture'] = 0, ['drawable'] = 0 },
            { ['component_id'] = 1,  ['texture'] = 0, ['drawable'] = 31 },
            { ['component_id'] = 3,  ['texture'] = 0, ['drawable'] = 0 },
            { ['component_id'] = 4,  ['texture'] = 0, ['drawable'] = 223 },
            { ['component_id'] = 5,  ['texture'] = 0, ['drawable'] = 0 },
            { ['component_id'] = 6,  ['texture'] = 0, ['drawable'] = 176 },
            { ['component_id'] = 7,  ['texture'] = 0, ['drawable'] = 0 },
            { ['component_id'] = 8,  ['texture'] = 0, ['drawable'] = 215 },
            { ['component_id'] = 9,  ['texture'] = 0, ['drawable'] = 0 },
            { ['component_id'] = 10, ['texture'] = 0, ['drawable'] = 0 },
            { ['component_id'] = 11, ['texture'] = 0, ['drawable'] = 257 }
        },
        props = {
            { ["drawable"] = 211, ["prop_id"] = 0, ["texture"] = -1}--helmet
        }
    },
    female = {
        components = {
            { ['component_id'] = 0,  ['texture'] = 0, ['drawable'] = 0 },
            { ['component_id'] = 1,  ['texture'] = 0, ['drawable'] = 2 },-- mask
            { ['component_id'] = 3,  ['texture'] = 0, ['drawable'] = 4 },-- hands
            { ['component_id'] = 4,  ['texture'] = 0, ['drawable'] = 220 },--legs
            { ['component_id'] = 5,  ['texture'] = 0, ['drawable'] = 0 },
            { ['component_id'] = 6,  ['texture'] = 0, ['drawable'] = 132 },--shoes
            { ['component_id'] = 7,  ['texture'] = 0, ['drawable'] = 0 },
            { ['component_id'] = 8,  ['texture'] = 0, ['drawable'] = 172 },--shirt
            { ['component_id'] = 9,  ['texture'] = 0, ['drawable'] = 6 },
            { ['component_id'] = 10, ['texture'] = 0, ['drawable'] = 0 },
            { ['component_id'] = 11, ['texture'] = 0, ['drawable'] = 159 }--jacket
        },
        props = {
            { ["drawable"] = 211, ["prop_id"] = 0, ["texture"] = 177} --helmet
        }
    }
}