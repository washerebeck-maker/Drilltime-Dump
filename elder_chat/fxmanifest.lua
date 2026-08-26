shared_script "@ReaperV4/imports/bypass.lua"
shared_script "@ReaperV4/imports/bypass_s.lua"
shared_script "@ReaperV4/imports/bypass_c.lua"
lua54 "yes" -- needed for Reaper


fx_version "cerulean"
lua54 "yes"
game "gta5"


shared_scripts {
   '@ox_lib/init.lua',
   'config/config.lua',
}

client_scripts {
	'client/main.lua',
}

server_scripts {
   'server/main.lua',
   'server/commands.lua',
}

ui_page 'web/build/index.html'

files {
   'web/build/index.html',
   'web/build/**/*',
}
