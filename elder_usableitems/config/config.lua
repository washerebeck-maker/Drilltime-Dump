Config = {}

Config.Items = {
    {
        name = 'burritonewmgnew',
        useTime = 3,
        useLabel = 'You are eating a burrito',
        anim = {
            dict = 'mp_player_inteat@burger',
            clip = 'mp_player_int_eat_burger_fp'
        },
        prop = {
            model = `prop_cs_burger_01`,
            pos = vec3(0.02, 0.02, -0.02),
            rot = vec3(0.0, 0.0, 0.0)
        },
        effects = {
            hunger = 175000,
            thirst = 175000,
            armor = 15,
            speed = { multiplier = 1.55, duration = 90},
        }
    },
    {
        name = 'tacomealnew',
        useTime = 3,
        useLabel = 'You are eating a taco',
        anim = {
            dict = 'mp_player_inteat@burger',
            clip = 'mp_player_int_eat_burger_fp'
        },
        prop = {
            model = `prop_cs_burger_01`,
            pos = vec3(0.02, 0.02, -0.02),
            rot = vec3(0.0, 0.0, 0.0)
        },
        effects = {
            hunger = 155000,
            thirst = 155000,
            armor = 10,
            speed = { multiplier = 1.55, duration = 90},
        }
    },
    {
        name = 'tamalnewmgdrug',
        useTime = 3,
        useLabel = 'You are eating a tamal',
        anim = {
            dict = 'mp_player_inteat@burger',
            clip = 'mp_player_int_eat_burger_fp'
        },
        prop = {
            model = `prop_food_bs_chips`,
            pos = vec3(0.02, 0.02, -0.02),
            rot = vec3(0.0, 0.0, 0.0)
        },
        effects = {
            hunger = 125000,
            thirst = 125000,
            armor = 8,
            speed = { multiplier = 1.55, duration = 90},
        }
    },
    {
        name = 'tortanewmgnew',
        useTime = 3,
        useLabel = 'You are eating a torta',
        anim = {
            dict = 'mp_player_inteat@burger',
            clip = 'mp_player_int_eat_burger_fp'
        },
        prop = {
            model = `prop_food_juice01`,
            pos = vec3(0.02, 0.02, -0.02),
            rot = vec3(0.0, 0.0, 0.0)
        },
        effects = {
            hunger = 105000,
            thirst = 105000,
            armor = 5,
            speed = { multiplier = 1.55, duration = 90},
        }
    },
}