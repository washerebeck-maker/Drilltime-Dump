shared_script "@ReaperV4/imports/bypass.lua"
shared_script "@ReaperV4/imports/bypass_s.lua"
shared_script "@ReaperV4/imports/bypass_c.lua"
lua54 "yes" -- needed for Reaper


fx_version 'cerulean'
games { 'gta5' }
description 'GKSHOP - Mcadence'
version '1.0'

files {
    -- TEST
	'img/*.jpg',
	'img/*.png'
}


-- Client Scripts
client_script "config.lua"
client_script "client.lua"
client_script "clientAPI.lua"
-- Server Scripts
server_script "config.lua"
server_script "server.lua"

lua54 'yes'

escrow_ignore {
	'config.lua', 
	'clientAPI.lua'  
}
dependency '/assetpacks'
