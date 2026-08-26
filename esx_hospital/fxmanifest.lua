shared_script "@ReaperV4/imports/bypass.lua"
shared_script "@ReaperV4/imports/bypass_s.lua"
shared_script "@ReaperV4/imports/bypass_c.lua"
lua54 "yes" -- needed for Reaper

 

-- THIS MUST BE ABOVE ALL OTHER SCRIPTS
--x
--
------------------------------------------

-- THIS MUST BE ABOVE ALL OTHER SCRIPTS
--x
--
------------------------------------------

fx_version "adamant"
game "gta5"
Author "Draco#7539"

description 'Draco-Customs'

client_scripts {
    'client/client.lua',
    'config.lua',
    'client/clutch.lua'
}

server_scripts {
    'server/server.lua',
    'config.lua'
}
