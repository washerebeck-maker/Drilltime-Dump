shared_script "@ReaperV4/imports/bypass.lua"
shared_script "@ReaperV4/imports/bypass_s.lua"
shared_script "@ReaperV4/imports/bypass_c.lua"
lua54 "yes" -- needed for Reaper

fx_version 'cerulean'
games { 'gta5' }
description 'GKSHOP - GKS EBAY'
version '1.1'


files {
    -- TEST
	'img/*.jpg',
	'img/*.png'
}

shared_scripts {
    "locales.lua",
	"config.lua",
	"locales/*.lua",
}

-- Client Scripts
client_scripts {
	"locales/en.lua",
	'config.lua',
	'client/main.lua',
}

-- Server Scripts
server_scripts {
	--'@oxmysql/lib/MySQL.lua',
	'@mysql-async/lib/MySQL.lua',
	"locales/en.lua",
	'config.lua',
	'server/main.lua',
	'server/mainAPI.lua',
}

lua54 'yes'


escrow_ignore {
	'config.lua' ,
	"locales/en.lua",
	'server/*.lua',
	'client/*.lua'
}
dependency '/assetpacks'
