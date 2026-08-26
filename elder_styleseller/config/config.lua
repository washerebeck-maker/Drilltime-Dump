Config = {}

Config.CommandName = 'hairsalon'

Config.MaxCustomerAtOnce = 2

Config.MaxZoneRadius = 25.0

Config.PaymentAccount = 'money'


Config.Products = {
    ['red_pooch'] = 1025,
    ['pink_pooch'] = 1025,
    ['blond_pooch'] = 1015,
}

Config.ToogleKeys = {
    { key = "F", value = 23 },
    { key = "E", value = 38 },
    { key = "H", value = 74 },
}

Config.Props = {
    [1] = {
        model = "prop_cs_shopping_bag",
        bone = 28422,
        pos = vector3(0.24,0.03,-0.04),
        rot = vector3(0.00,-90.00,10.00)
    },
    [2] = {
        model = "prop_shopping_bags02",
        bone = 28422,
        pos = vector3(0.05,0.02,0.00),
        rot = vector3(178.80,91.19,9.97)
    }
}

Config.Animation = {
    [1] = {dict = 'timetable@gardener@smoking_joint', anim = 'idle_cough'},
    [2] = {dict = 'friends@frj@ig_1', anim = 'wave_c'},
    [3] = {dict = 'friends@frj@ig_1', anim = 'wave_a'},
    [4] = {dict = 'anim@arena@celeb@flat@solo@no_props@', anim = 'angry_clap_a_player_a'},
    [5] = {dict = 'mp_player_inteat@pnq', anim = 'loop'},
}

Config.Locales = {
    in_progress    = "You are already selling products.",
    no_products       = "You have no products to sell.",
    start_selling  = "You started selling products.",
    wrong_position  = "Customers cannot come to this place, change your position.",
    out_of_zone    = "you left the product selling zone.",
    sold_product       = "You sold ~b~%sx~s~ ~y~%s~s~ for ~g~$%s~s~",
    start_sell       = "Press ~b~[%s]~s~ to serve the customer.",
    reject         = "~r~Go sell this bullshit to yo bitch.",
    title = "Products",
    searching = "You're searching for clients to sell products",
    death = "damn you died, products selling is over for now."
}

Config.PedsList = {    
    'a_f_m_bevhills_01',
    'a_f_y_bevhills_01',
    'a_f_y_bevhills_04',
    'a_f_y_clubcust_02',
    'a_f_y_soucent_01',
    'a_f_y_smartcaspat_01',
    'cs_gurk',
    'cs_movpremf_01',
    'cs_tanisha',
    'csb_bride',
    'mp_f_deadhooker',
    'mp_f_execpa_01',
    's_f_y_clubbar_01',
    's_f_y_hooker_02',
    's_f_y_movprem_01',
    'ig_kerrymcintosh',
}

Config.CayoPoint = vector3(5028.7383, -5101.8418, 6.0018)


