shared_script "@ReaperV4/imports/bypass.lua"
shared_script "@ReaperV4/imports/bypass_s.lua"
shared_script "@ReaperV4/imports/bypass_c.lua"
lua54 "yes" -- needed for Reaper

fx_version 'adamant'
game 'gta5'
description 'Adds a way for resources to store items for players'
lua54 'yes'
version '1.0' 
legacyversion '1.9.1'
server_scripts {
	'@es_extended/imports.lua',
	'@oxmysql/lib/MySQL.lua',
	'server/classes/addoninventory.lua',
	'server/main.lua'
}
server_exports {
    'GetSharedInventory',
    'AddSharedInventory'
}
dependency 'es_extended'
