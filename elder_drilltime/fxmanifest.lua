shared_script "@ReaperV4/imports/bypass.lua"
shared_script "@ReaperV4/imports/bypass_s.lua"
shared_script "@ReaperV4/imports/bypass_c.lua"
lua54 "yes" -- needed for Reaper




fx_version "adamant"
game "gta5"
Author "Sparrow9110#1254"
lua54 'yes'

shared_scripts {
    'config/config.lua',
    'locales/strings.lua',
    '@ox_lib/init.lua'
}

files {
    'modules/bodybag/web/build/**/*',
}

ui_page 'modules/bodybag/web/build/index.html'

client_scripts {
    'client/*.lua',
    'modules/**/client.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/*.lua',
    'modules/**/server.lua',
}
