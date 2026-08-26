shared_script "@ReaperV4/imports/bypass.lua"
shared_script "@ReaperV4/imports/bypass_s.lua"
shared_script "@ReaperV4/imports/bypass_c.lua"
lua54 "yes" -- needed for Reaper

fx_version 'adamant'
game 'gta5'
author 'ESX-Framework'
lua54 'yes'
version '1.10.5'
description 'ESX Progressbar'
client_scripts { 'Progress.lua' }
shared_script '@es_extended/imports.lua'
ui_page 'nui/index.html'
files {
    'nui/index.html',
    'nui/js/*.js',
    'nui/css/*.css',
}
