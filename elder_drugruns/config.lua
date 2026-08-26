Config = {}

Config.ItemPhone = 'plug_phone'

Config.DrugLevel = 1000

Config.DrugRunTypes = {
    ['npc'] = {
        Label = 'Local Drug Pick Up',
        CoolDown = 3 * 24 * 60 * 60,
        Locations = {
            vector4(110.4105, -2577.0999, 6.6949, 277.6435),
            vector4(-663.3593, -709.7631, 26.8468, 184.2521),
            vector4(1400.4517, 1127.1401, 114.3345, 175.9903),
        },
        Peds = {
            'g_m_y_ballaeast_01',
            'g_m_y_ballaorig_01',
            'g_m_y_famca_01',
        },
        Animations = {
            'WORLD_HUMAN_STAND_MOBILE',
        },
        Drugs = {
            {Item = 'cocainebrick', Min = 1, Max = 3},
            {Item = 'bxanewbsparrow', Min = 1, Max = 1},
            {Item = 'coke_pooch', Min = 50, Max = 250},
            {Item = 'meth_poooch', Min = 50, Max = 250},
            {Item = 'crackpooch3000', Min = 50, Max = 250},
            {Item = 'bottle_xanaxnew', Min = 50, Max = 250},
            {Item = 'tuzi_pooch', Min = 50, Max = 250},
            {Item = 'lsdtab', Min = 50, Max = 250},
        }
    },
    ['drop'] = {
        Label = 'Advance Drug Drop',
        CoolDown = 24 * 60 * 60 ,
        Locations = {
            vector3(789.5057, -816.6552, 26.3120),
            vector3(-140.2015, -1751.3252, 30.4108),
            vector3(1398.8389, -1656.1110, 58.982),
            vector3(874.1429, -1240.0466, 26.256),
            vector3(609.1577, 86.7037, 92.1755),
            vector3(-1839.8840, 156.8770, 78.9340),
        },
    }
}
