shared_script "@ReaperV4/imports/bypass.lua"
shared_script "@ReaperV4/imports/bypass_s.lua"
shared_script "@ReaperV4/imports/bypass_c.lua"
lua54 "yes" -- needed for Reaper

fx_version 'adamant'
game 'gta5'
author 'XTelFou'
lua54 "yes"
version '1.0.0'
files {
    "web/*.**",
}
ui_page "web/index.html"
client_script "client/client.lua"
server_script "server/server.lua"
shared_script "config.lua"
escrow_ignore {
    "client/client.lua",
    "server/server.lua",
    "config.lua",
}
