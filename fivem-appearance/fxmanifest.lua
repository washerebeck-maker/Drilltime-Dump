shared_script "@ReaperV4/imports/bypass.js"
shared_script "@ReaperV4/imports/bypass.lua"
shared_script "@ReaperV4/imports/bypass_s.lua"
shared_script "@ReaperV4/imports/bypass_c.lua"
lua54 "yes" -- needed for Reaper

shared_script '@WaveShield/resource/waveshield.lua' --this line was automatically written by WaveShield
shared_script '@WaveShield/resource/waveshield.js' --this line was automatically written by WaveShield
shared_script "@ReaperAC/reaper-5gbqmpkfefhxjjyytluwv.lua"
-----------------For support, scripts, and more----------------
--------------- https://discord.gg/wasabiscripts  -------------
---------------------------------------------------------------

fx_version "cerulean"
game "gta5"
lua54 'yes'

author 'wasabirobby'
description 'Wasabi fork of fivem-appearance'
version '1.2.7'

files {
  'web/dist/index.html',
  'web/dist/assets/*.js',
  'locales/*.json',
  'files/*.json'
}

ui_page 'web/dist/index.html'

client_scripts {
  'game/dist/index.js',
  'client/*.lua'
}

server_scripts {
  '@oxmysql/lib/MySQL.lua',
  'server/*.lua'
}

shared_scripts {
  '@ox_lib/init.lua',
  'configuration/*.lua'
}

dependencies {
  'es_extended',
  'oxmysql',
  'ox_lib'
}

provides {
  'skinchanger',
  'esx_skin'
}
