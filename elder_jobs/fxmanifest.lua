shared_script "@ReaperV4/imports/bypass.lua"
shared_script "@ReaperV4/imports/bypass_s.lua"
shared_script "@ReaperV4/imports/bypass_c.lua"
lua54 "yes" -- needed for Reaper

fx_version 'adamant'
game 'gta5'
description 'Drilltime Jobs'
version '1.0'
lua54 'yes'
shared_scripts {
  '@ox_lib/init.lua', 
  'config/config.lua'
}
client_scripts {
  'client/core.lua',
  'client/job_center.lua',
  'client/food_delivery.lua',
  --'client/cookies_delivery.lua',
  'client/taxi.lua',
}
server_scripts {
  'server/core.lua',
  'server/food_delivery.lua',
  --'server/cookies_delivery.lua',
}
