shared_script "@ReaperV4/imports/bypass.lua"
shared_script "@ReaperV4/imports/bypass_s.lua"
shared_script "@ReaperV4/imports/bypass_c.lua"
lua54 "yes" -- needed for Reaper

fx_version 'cerulean'
game 'gta5'
lua54 'yes'
author 'Elder'
description 'Elder Fuel — Fuel Station Management UI'
version '0.1.0'
ui_page 'web/build/index.html'
dependencies {
    'ox_lib',
    'oxmysql',
    'es_extended',
}
shared_scripts {
    '@ox_lib/init.lua',
    'config/*.lua'
}
client_scripts {
    'client/*.lua'
}
server_scripts {
    'server/*.lua'
}
files {
    'web/build/index.html',
    'web/build/**/*'
}
