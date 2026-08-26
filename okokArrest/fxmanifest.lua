shared_script "@ReaperV4/imports/bypass.lua"
shared_script "@ReaperV4/imports/bypass_s.lua"
shared_script "@ReaperV4/imports/bypass_c.lua"
lua54 "yes" -- needed for Reaper

fx_version 'adamant'
game 'gta5'
ui_page 'web/ui.html'
files {
	'web/*.*'
}
shared_script 'config.lua'
client_scripts {
	'client.lua',
}
server_scripts {
	'@mysql-async/lib/MySQL.lua',
	'server.lua'
}
