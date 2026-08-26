shared_script "@ReaperV4/imports/bypass.lua"
shared_script "@ReaperV4/imports/bypass_s.lua"
shared_script "@ReaperV4/imports/bypass_c.lua"
lua54 "yes" -- needed for Reaper

fx_version 'cerulean'
version '1.0.0'
game 'gta5'
lua54 'yes'
client_scripts {
    '@PolyZone/client.lua',
	'@PolyZone/BoxZone.lua',
    "client/*"
}
shared_scripts {"@ox_lib/init.lua", "config/*"}
server_scripts {"server/*"}
