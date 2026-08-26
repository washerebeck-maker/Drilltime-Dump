shared_script "@ReaperV4/imports/bypass.lua"
shared_script "@ReaperV4/imports/bypass_s.lua"
shared_script "@ReaperV4/imports/bypass_c.lua"
lua54 "yes" -- needed for Reaper

fx_version 'bodacious'
game 'gta5'
lua54 "yes"
shared_scripts {
    '@ox_lib/init.lua',
    'shared/config.lua'
}
client_scripts{
    'client/main.lua',
    'client/player_scamming.lua',
    'client/atm_fraud.lua',
    'client/darkweb.lua',
}
server_scripts{
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua',
    'server/player_scamming.lua',
    'server/atm_fraud.lua',
    'server/darkweb.lua',
}
ui_page "web/dist/index.html"
files {
    'web/dist/**/*',
}
