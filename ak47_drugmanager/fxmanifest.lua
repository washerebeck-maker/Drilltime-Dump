shared_script "@ReaperV4/imports/bypass.lua"
shared_script "@ReaperV4/imports/bypass_s.lua"
shared_script "@ReaperV4/imports/bypass_c.lua"
lua54 "yes" -- needed for Reaper

fx_version 'adamant'
game 'gta5'
description 'Ak47 Drug Manager'
version '2.7'
ui_page 'nui/index.html'
shared_scripts {
	'@es_extended/imports.lua',
    'config.lua',
    'config-*.lua',
    'locales/locale.lua',
    'locales/en.lua',
}
files {
    'nui/**/*'
}
server_scripts {
	'@mysql-async/lib/MySQL.lua',
	'server/utils.lua',
	'server/field.lua',
	'server/lab.lua',
	'server/drugdealer.lua',
	'server/npc_sell.lua',
	'server/usable.lua',
}
client_scripts {	
	'@PolyZone/client.lua',
    '@PolyZone/BoxZone.lua',
    '@PolyZone/EntityZone.lua',
    '@PolyZone/CircleZone.lua',
    '@PolyZone/ComboZone.lua',
    
	'client/utils.lua',
	'client/field.lua',
	'client/lab.lua',
	'client/drugdealer.lua',
	'client/npc_sell.lua',
	'client/teleport.lua',
	'client/usable/*.lua',
}
dependencies {
    '/onesync',
    'es_extended',
    'PolyZone',
}
escrow_ignore {
    "config*.lua",
    "shops/*.lua",
    "locales/*.lua",
    "server/utils.lua",
    "client/utils.lua",
}
lua54 'yes'
dependency '/assetpacks'
