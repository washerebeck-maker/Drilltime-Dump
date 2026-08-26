shared_script "@ReaperV4/imports/bypass.lua"
shared_script "@ReaperV4/imports/bypass_s.lua"
shared_script "@ReaperV4/imports/bypass_c.lua"
lua54 "yes" -- needed for Reaper

--shared_script "@ReaperAC/reaper-5gbqmpkfefhxjjyytluwv.lua"
fx_version 'cerulean'
game 'gta5'
lua54 'yes'
description 'ESX/QBCore Police Job'
author 'Sparrow9110'
version '1.2.4'
shared_scripts { '@ox_lib/init.lua', 'configuration/*.lua' }
client_scripts { 'bridge/**/client.lua', 'client/*.lua' }
server_scripts { '@mysql-async/lib/MySQL.lua', 'bridge/**/server.lua', 'server/*.lua' }
dependencies { 'mysql-async', 'ox_lib' }
provides { 'esx_policejob', 'qb-policejob' }
escrow_ignore {
  'configuration/*.lua',
  'bridge/**/*.lua'
}
