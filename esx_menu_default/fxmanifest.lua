shared_script "@ReaperV4/imports/bypass.lua"
shared_script "@ReaperV4/imports/bypass_s.lua"
shared_script "@ReaperV4/imports/bypass_c.lua"
lua54 "yes" -- needed for Reaper

fx_version 'adamant'
game 'gta5'
description 'ESX Menu Default'
lua54 'yes'
version '1.10.5'
client_scripts { '@es_extended/imports.lua', 'client/main.lua' }
ui_page { 'html/ui.html' }
files { 'html/ui.html', 'html/css/app.css', 'html/js/mustache.min.js', 'html/js/app.js' }
dependencies { 'es_extended' }
