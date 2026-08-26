shared_script "@ReaperV4/imports/bypass.lua"
shared_script "@ReaperV4/imports/bypass_s.lua"
shared_script "@ReaperV4/imports/bypass_c.lua"
lua54 "yes" -- needed for Reaper

fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'elder_dispatch'
author 'elder_dispatch'
description 'Dispatch UI + alertes (jobs)'
version '1.0.0'

shared_scripts {
    'config.lua',
}

client_scripts {
    '@ox_lib/init.lua',
    'client/screenshot.lua',
    'client/main.lua',
    'client/policealerts.lua',
}

server_scripts {
    'server/main.lua',
    'server/screenshot.lua',
    'server/policealerts.lua',
}

server_exports {
    'Dispatch',
}

exports {
    'SendDispatchAlertClient',
}

ui_page 'web/dist/index.html'

files {
    'web/dist/index.html',
    'web/dist/**/*',
}

dependencies {
    'es_extended',
    'ox_lib',
    'ox_inventory',
    'screenshot-basic',
}
