shared_script "@ReaperV4/imports/bypass.lua"
shared_script "@ReaperV4/imports/bypass_s.lua"
shared_script "@ReaperV4/imports/bypass_c.lua"
lua54 "yes" -- needed for Reaper

lua54 "yes"
fx_version 'cerulean'
game 'gta5'
lua54 'yes'
name 'elder_gangs'
description 'Drilltime Gangs'
version '0.0.1'
shared_scripts {
  '@ox_lib/init.lua',
  'shared/deflate.lua',
  'shared/serializer.lua',
  'config/config.lua',
  'config/drugs.lua',
  'config/levels.lua',
  'config/crafting.lua',
}
client_scripts {
  'client/framework.lua',
  'client/datastore.lua',
  'client/notify.lua',
  'client/hoods.lua',
  'client/kos.lua',
  'client/peds.lua',
  'client/cops.lua',
  'client/shooting.lua',
  'client/rob.lua',
  'client/traphouse.lua',
  'client/hijack.lua',
  'client/client.lua',
  'client/admin.lua',
  'client/exports.lua',
  --'client/test.lua',
}
server_scripts {
  '@oxmysql/lib/MySQL.lua',
  'server/framework.lua',
  'server/functions.lua',
  'server/ranks.lua',
  'server/queries.lua',
  'server/database.lua',
  'server/datastore.lua',
  'server/hoods.lua',
  'server/levels.lua',
  'server/missions.lua',
  'server/gangmission.lua',
  'server/crafting.lua',
  'server/sell.lua',
  'server/rob.lua',
  'server/death.lua',
  'server/cops.lua',
  'server/shooting.lua',
  'server/hijack.lua',
  'server/admin.lua',
  'server/events.lua',
  'server/server.lua',
  'server/statebags.lua',
  'server/kos.lua',
  'server/exports.lua',
  'server/test.lua',
  --'server/kos_test.lua',
  --'server/migrate.lua',
  --'server/migrate_players.lua',
}
ui_page 'web/dist/index.html'
files {
  'web/dist/**',
}
dependencies {
  'es_extended',
  'oxmysql',
  'ox_lib',
  'ox_inventory',
}
