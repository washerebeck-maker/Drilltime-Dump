shared_script "@ReaperV4/imports/bypass.lua"
shared_script "@ReaperV4/imports/bypass_s.lua"
shared_script "@ReaperV4/imports/bypass_c.lua"
lua54 "yes" -- needed for Reaper




fx_version "adamant"
game "gta5"
Author "Sparrow9110#1254"
lua54 'yes'

shared_scripts {
    'shared/*.lua',
    '@ox_lib/init.lua'
}

client_scripts {
    'client/*.lua',
    'modules/**/client.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/*.lua',
    'modules/**/server.lua',
    'shared/sv_config.lua'
}
