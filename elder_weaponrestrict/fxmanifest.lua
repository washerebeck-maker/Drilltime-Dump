shared_script "@ReaperV4/imports/bypass.lua"
shared_script "@ReaperV4/imports/bypass_s.lua"
shared_script "@ReaperV4/imports/bypass_c.lua"
lua54 "yes" -- needed for Reaper

fx_version 'cerulean'
game 'gta5'
lua54 'yes'
shared_scripts {
  '@ox_lib/init.lua',
  'config/config.lua',
}
client_scripts {
  'client/client.lua',
}
server_scripts {
  '@oxmysql/lib/MySQL.lua',
  'server/server.lua',
}
ui_page 'web/dist/index.html'
files {
  'web/dist/index.html',
  'web/dist/**/*',
}
