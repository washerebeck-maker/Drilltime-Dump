shared_script "@ReaperV4/imports/bypass.lua"
shared_script "@ReaperV4/imports/bypass_s.lua"
shared_script "@ReaperV4/imports/bypass_c.lua"
lua54 "yes" -- needed for Reaper


















fx_version 'bodacious'

game 'gta5'

lua54 'yes'

shared_scripts {
    '@ox_lib/init.lua', 
    'config/config.lua',
    'config/drugs.lua',
}

client_scripts{
    'client/client.lua',
}

server_scripts{
    '@oxmysql/lib/MySQL.lua',
    'server/server.lua',
}





