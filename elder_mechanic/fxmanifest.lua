shared_script "@ReaperV4/imports/bypass.lua"
shared_script "@ReaperV4/imports/bypass_s.lua"
shared_script "@ReaperV4/imports/bypass_c.lua"
lua54 "yes" -- needed for Reaper










fx_version 'cerulean'
game 'gta5'

author 'DiVouz'
description 'Mechanic'
version '1.1.2'

lua54 'on'

ui_page 'client/ui/index.html'
files {
	'client/ui/index.html',
	'client/ui/js/**/*.js',
	'client/ui/css/**/*.css',
	'client/ui/img/**/*.png',
	'client/ui/sounds/**/*.ogg'
}

shared_scripts {
    '@ox_lib/init.lua',
}

client_scripts {
	'config/core.lua',
	'config/prices.lua',
	
	'config/client_functions.lua',
	
	'client/menus.lua',
	'client/labels.lua',
	'client/helper.lua',
	'client/job.lua',
	'client/api.lua',
	'client/core.lua'
}

server_scripts {
	'@oxmysql/lib/MySQL.lua', -- uncomment if you using [mysql-async] and want to auto save vehicle properties (enable `Config.AutoSaveVehiclePropertiesOnApply` in file `config/core.lua`)
	'config/core.lua',
	'config/server_functions.lua',
	'server/core.lua'
}











