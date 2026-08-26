shared_script "@ReaperV4/imports/bypass.lua"
shared_script "@ReaperV4/imports/bypass_s.lua"
shared_script "@ReaperV4/imports/bypass_c.lua"
lua54 "yes" -- needed for Reaper

fx_version 'cerulean'
games {"gta5", "rdr3"}
author "Trase"
version '1.0.0'
lua54 'yes'
ui_page 'web/build/index.html'
shared_scripts {
  '@ox_lib/init.lua',
  '@es_extended/imports.lua'
}
client_script "client/client.lua"
server_script "server/**/*"
files {
  'web/build/index.html',
  'web/build/**/*'
}
