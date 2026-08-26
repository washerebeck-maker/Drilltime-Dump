shared_script "@ReaperV4/imports/bypass.lua"
shared_script "@ReaperV4/imports/bypass_s.lua"
shared_script "@ReaperV4/imports/bypass_c.lua"
lua54 "yes" -- needed for Reaper

server_script '@ElectronAC/src/include/server.lua'
client_script '@ElectronAC/src/include/client.lua'
fx_version 'cerulean'
game 'gta5'

author 'kypos'
description 'Advanced Gore and Dismemberment System'
version '0.0.1'
lua54 'yes'

ui_page 'web/build/index.html'


shared_scripts {
    'shared/config.lua'
}

client_scripts {
    'client/main.lua',
    'client/dead.lua',
}

server_scripts {
    'server/main.lua'
}

files {
    'stream/goreObjects.ytyp',
    'web/build/index.html',
    'web/build/**/*'
}

data_file 'DLC_ITYP_REQUEST' 'stream/goreObjects.ytyp'


escrow_ignore {
    'shared/config.lua'
}

dependency '/assetpacks'
