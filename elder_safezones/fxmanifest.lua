shared_script "@ReaperV4/imports/bypass.lua"
shared_script "@ReaperV4/imports/bypass_s.lua"
shared_script "@ReaperV4/imports/bypass_c.lua"
lua54 "yes" -- needed for Reaper





author 'Swqpping'
description 'FiveM Script to add safezones'
game 'gta5'
fx_version 'cerulean'
shared_scripts {
    '@ox_lib/init.lua',
}
client_scripts {
    'config.lua',
    'client.lua'
} 
server_scripts {'server.lua'}





