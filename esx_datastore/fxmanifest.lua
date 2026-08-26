shared_script "@ReaperV4/imports/bypass.lua"
shared_script "@ReaperV4/imports/bypass_s.lua"
shared_script "@ReaperV4/imports/bypass_c.lua"
lua54 "yes" -- needed for Reaper

fx_version 'adamant'
game 'gta5'
description 'Used for storing Data, such as society inventories'
version '1.0'
legacyversion '1.9.1'
lua54 'yes'
server_scripts {
	'@es_extended/imports.lua',
	'@oxmysql/lib/MySQL.lua',
	'server/classes/datastore.lua',
	'server/main.lua'
}
