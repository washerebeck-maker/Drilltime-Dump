Config = {}

Config.CommandName = 'sellshoes'

Config.MaxCustomerAtOnce = 2

Config.MaxZoneRadius = 25.0

Config.PaymentAccount = 'money'


Config.Products = {
    ['shnewbox3'] = {count = {min = 2, max = 6}, price = {min = 219, max = 449} },
    ['snewspwone'] = {count = {min = 2, max = 6}, price = {min = 219, max = 449} },
    ['snewspwtow'] = {count = {min = 2, max = 6}, price = {min = 219, max = 449} },
}

Config.ToogleKeys = {
    { key = "F", value = 23 },
    { key = "E", value = 38 },
    { key = "H", value = 74 },
}

Config.Props = {
    [1] = {
        model = "v_serv_abox_02",
        bone = 28422,
        pos = vector3(0.00,0.03,-0.04),
        rot = vector3(0.00,-90.00,10.00)
    },
}

Config.Animation = {
    [1] = {dict = 'timetable@gardener@smoking_joint', anim = 'idle_cough'},
    [2] = {dict = 'friends@frj@ig_1', anim = 'wave_c'},
    [3] = {dict = 'friends@frj@ig_1', anim = 'wave_a'},
    [4] = {dict = 'anim@arena@celeb@flat@solo@no_props@', anim = 'angry_clap_a_player_a'},
    [5] = {dict = 'mp_player_inteat@pnq', anim = 'loop'},
}

Config.Locales = {
    in_progress    = "You are already selling shoes.",
    no_products       = "You have no shoes to sell.",
    start_selling  = "You started selling shoes.",
    wrong_position  = "Customers cannot come to this place, change your position.",
    out_of_zone    = "you left the product selling zone.",
    sold_product       = "You sold ~b~%sx~s~ ~y~%s~s~ for ~g~$%s~s~",
    start_sell       = "Press ~b~[%s]~s~ to serve the customer.",
    reject         = "~r~Go sell this bullshit to yo bitch.",
    title = "SHOES",
    searching = "You're searching for clients to sell shoes",
    death = "damn you died, shoes selling is over for now."
}

Config.PedsList = {    
    'a_m_y_downtown_01',
    'a_m_y_latino_01',
    'a_m_y_soucent_02',
    'a_m_y_soucent_03',
    'a_m_y_stbla_01',
    'a_m_y_yoga_01',
    'a_m_m_soucent_03',
    'a_m_m_fatlatin_01',
}
