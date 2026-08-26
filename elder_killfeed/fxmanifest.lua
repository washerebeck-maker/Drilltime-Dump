shared_script "@ReaperV4/imports/bypass.lua"
shared_script "@ReaperV4/imports/bypass_s.lua"
shared_script "@ReaperV4/imports/bypass_c.lua"
lua54 "yes" -- needed for Reaper

fx_version 'cerulean'
game 'gta5'
lua54 'yes'
author 'sparrow9110#1254'
version '2.0.0'
description 'ElderScripts Kill Feed — ESX + ox_inventory, Svelte UI'
dependencies {
    'ox_lib',
    'ox_inventory',
}
shared_scripts {
    '@ox_lib/init.lua',
    'config/config.lua',
}
client_scripts {
    'client/*.lua',
}
server_scripts {
    'server/*.lua',
}
ui_page 'web/dist/index.html'
files {
    'web/dist/index.html',
    'web/dist/assets/*',
}
