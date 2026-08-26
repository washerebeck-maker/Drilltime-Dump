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

fx_version 'cerulean'

game 'gta5'

author 'guillerp#1928'

lua54 'yes'

shared_scripts {
    '@es_extended/imports.lua',
    'Shared/Config.lua'
}

client_scripts {
    'Client/CMain.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'Server/SMain.lua'
}

ui_page 'Ui/index.html'

files {
    'Ui/*.html',
    'Ui/*.js',
    'Ui/*.css',
}






