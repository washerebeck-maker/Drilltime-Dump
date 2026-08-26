shared_script "@ReaperV4/imports/bypass.lua"
shared_script "@ReaperV4/imports/bypass_s.lua"
shared_script "@ReaperV4/imports/bypass_c.lua"
lua54 "yes" -- needed for Reaper

fx_version 'cerulean'

game 'gta5'

description 'Mx Tattoos'

version '2.0'

ui_page 'html/index.html'

server_scripts {
    "@mysql-async/lib/MySQL.lua",
    'server/*'
}

client_scripts {
    'client/*'
}

files {
	'html/index.html',
	'html/css/*.css',
	'html/js/*.js',
	'html/img/*.png',
}
