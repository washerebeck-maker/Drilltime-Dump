shared_script "@ReaperV4/imports/bypass.lua"
shared_script "@ReaperV4/imports/bypass_s.lua"
shared_script "@ReaperV4/imports/bypass_c.lua"
lua54 "yes" -- needed for Reaper

fx_version "cerulean"
use_experimental_fxv2_oal 'yes'
lua54 'yes'
game 'gta5'
version '1.6.0'
dependencies {
  '/onesync',
}
shared_scripts {
  'require.lua',
  'init.lua',
}
files {
  'utils.lua',
  'client/**/*.lua',
  'imports/client.lua',
}
