shared_script "@ReaperV4/imports/bypass.lua"
shared_script "@ReaperV4/imports/bypass_s.lua"
shared_script "@ReaperV4/imports/bypass_c.lua"
lua54 "yes" -- needed for Reaper


fx_version "adamant"
game "gta5"
Author "Sparrow9110"
lua54 'yes'

shared_scripts {
    'config.lua',
    '@ox_lib/init.lua',
}
client_script {
    'client.lua',
}
server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server.lua',
}
