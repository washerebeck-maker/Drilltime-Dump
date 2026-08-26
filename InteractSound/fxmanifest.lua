shared_script "@ReaperV4/imports/bypass.lua"
shared_script "@ReaperV4/imports/bypass_s.lua"
shared_script "@ReaperV4/imports/bypass_c.lua"
lua54 "yes" -- needed for Reaper

fx_version 'cerulean'
game 'gta5'
client_script 'client/main.lua'
-- Server Scripts
server_script 'server/main.lua'
-- NUI Default Page
ui_page('client/html/index.html')
-- Files needed for NUI
-- DON'T FORGET TO ADD THE SOUND FILES TO THIS!
files({
    'client/html/index.html',
	"client/html/sounds/*.ogg",
})
