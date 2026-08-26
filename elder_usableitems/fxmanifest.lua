shared_script "@ReaperV4/imports/bypass.lua"
shared_script "@ReaperV4/imports/bypass_s.lua"
shared_script "@ReaperV4/imports/bypass_c.lua"
lua54 "yes" -- needed for Reaper

fx_version "cerulean"
game "gta5"
lua54 "yes"
author "Elder Scripts"
shared_scripts {
  "@ox_lib/init.lua",
  "config/config.lua",
}
client_scripts {
  "client/*.lua"
}
server_scripts {
  "server/*.lua"
}
