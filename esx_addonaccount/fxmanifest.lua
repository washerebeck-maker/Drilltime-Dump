shared_script "@ReaperV4/imports/bypass.lua"
shared_script "@ReaperV4/imports/bypass_s.lua"
shared_script "@ReaperV4/imports/bypass_c.lua"
lua54 "yes" -- needed for Reaper

fx_version 'adamant'
game 'gta5'
author 'ESX-Framework'
description 'Allows resources to store account data, such as society funds'
lua54 'yes'
version '1.0' 
server_scripts {
	'@es_extended/imports.lua',
	'@oxmysql/lib/MySQL.lua',
	'server/classes/addonaccount.lua',
	'server/main.lua'
}
server_exports {
    'GetSharedAccount',
    'AddSharedAccount'
}
dependency 'es_extended'
