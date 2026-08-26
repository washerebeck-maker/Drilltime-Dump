shared_script "@ReaperV4/imports/bypass.lua"
shared_script "@ReaperV4/imports/bypass_s.lua"
shared_script "@ReaperV4/imports/bypass_c.lua"
lua54 "yes" -- needed for Reaper

fx_version 'adamant'
game 'gta5'
author "MenanAk47 (MenanAk47#3129)"
version "1.7"

shared_script "@es_extended/imports.lua"

client_scripts {
    'config.lua',
    'client/utils.lua',
    'client/main.lua',
    'client/teleport.lua',
    
    'locales/locale.lua',
    'locales/en.lua',
}

server_scripts {
    'config.lua',
    'server/utils.lua',
    'server/main.lua',
    'webhook.lua',

    'locales/locale.lua',
    'locales/en.lua',
}

dependencies {
    '/onesync',
    'es_extended',
}

escrow_ignore {
    "config.lua",
    "locales/*.lua",
    "server/utils.lua",
    "client/utils.lua",
    "webhook.lua",
}

lua54 'yes'
dependency '/assetpacks'
