shared_script "@ReaperV4/imports/bypass.lua"
shared_script "@ReaperV4/imports/bypass_s.lua"
shared_script "@ReaperV4/imports/bypass_c.lua"
lua54 "yes" -- needed for Reaper

fx_version 'adamant'
game 'gta5'
ui_page 'ui/index.html'
client_script('client.lua')
files {
	'ui/index.html',
	'ui/main.js',
	'ui/style.css',
	'ui/sounds/*',
	'ui/icons/*',
}
