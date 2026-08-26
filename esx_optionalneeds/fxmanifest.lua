shared_script "@ReaperV4/imports/bypass.lua"
shared_script "@ReaperV4/imports/bypass_s.lua"
shared_script "@ReaperV4/imports/bypass_c.lua"
lua54 "yes" -- needed for Reaper

fx_version 'adamant'
game 'gta5'
description 'Adds the ability to get drunk'
lua54 'yes'
version '1.0'
legacyversion '1.9.1'
shared_script '@es_extended/imports.lua'
server_scripts {
    '@es_extended/locale.lua',
    'locales/*.lua',
    'config.lua',
    'server/main.lua'
}
client_scripts {
    'client/main.lua'
}
