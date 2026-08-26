shared_script "@ReaperV4/imports/bypass.lua"
shared_script "@ReaperV4/imports/bypass_s.lua"
shared_script "@ReaperV4/imports/bypass_c.lua"
lua54 "yes" -- needed for Reaper

fx_version 'adamant'
game 'gta5'
description 'GKS RACING'
version '1.0'
lua54 'yes'
client_scripts {
	'config.lua',
	'client/functions.lua',
	'client/main.lua',
    'client/map2.lua',
	'client/nos.lua'
}
files {
    'html/dist/index.html',
    'html/dist/css/app.css',
    'html/dist/js/app.js',
	'lang.json',
}
ui_page 'html/dist/index.html'
server_scripts {
    --'@oxmysql/lib/MySQL.lua',
	'@mysql-async/lib/MySQL.lua',
    --'@async/async.lua',
	'config.lua',
	'server/functions.lua',
	'server/main.lua'
}
escrow_ignore {
	'config.lua',
	'client/nos.lua'
}
dependency '/assetpacks'
