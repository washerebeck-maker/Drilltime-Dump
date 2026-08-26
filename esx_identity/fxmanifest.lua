shared_script "@ReaperV4/imports/bypass.lua"
shared_script "@ReaperV4/imports/bypass_s.lua"
shared_script "@ReaperV4/imports/bypass_c.lua"
lua54 "yes" -- needed for Reaper

fx_version 'adamant'
game 'gta5'
description 'ESX Identity'
lua54 'yes'
version '1.10.5'
shared_scripts {
	'@es_extended/imports.lua',
	'@es_extended/locale.lua',
}
server_scripts {
	'@oxmysql/lib/MySQL.lua',
	'locales/*.lua',
	'config.lua',
	'server/main.lua'
}
client_scripts {
	'locales/*.lua',
	'config.lua',
	'client/main.lua'
}
ui_page 'html/index.html'
files {
	'html/index.html',
	'html/js/script.js',
	'html/css/style.css',
}
dependency 'es_extended'
