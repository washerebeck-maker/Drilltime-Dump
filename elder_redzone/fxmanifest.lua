shared_script "@ReaperV4/imports/bypass.lua"
shared_script "@ReaperV4/imports/bypass_s.lua"
shared_script "@ReaperV4/imports/bypass_c.lua"
lua54 "yes" -- needed for Reaper

lua54 "yes"
lua54 "yes"
lua54 "yes"
fx_version 'cerulean'
game 'gta5'
lua54 "yes"
ui_page 'web/build/index.html'
shared_scripts {
    'config/config.lua',
    '@ox_lib/init.lua',
}
client_script 'client/client.lua'
server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/server.lua',
}
files {
    'web/build/index.html',
    'web/build/**/*',
}
