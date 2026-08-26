shared_script "@ReaperV4/imports/bypass.lua"
shared_script "@ReaperV4/imports/bypass_s.lua"
shared_script "@ReaperV4/imports/bypass_c.lua"
lua54 "yes" -- needed for Reaper

resource_manifest_version "44febabe-d386-4d18-afbe-5e627f4af937"

files {
  'audioconfig/demonv8_game.dat151.nametable',
  'audioconfig/demonv8_game.dat151.rel',
  'audioconfig/demonv8_sounds.dat54.nametable',
  'audioconfig/demonv8_sounds.dat54.rel',
  'sfx/dlc_demonv8/demonv8.awc',
  'sfx/dlc_demonv8/demonv8_npc.awc',
}

data_file 'AUDIO_GAMEDATA' 'audioconfig/demonv8_game.dat'
data_file 'AUDIO_SOUNDDATA' 'audioconfig/demonv8_sounds.dat'
data_file 'AUDIO_WAVEPACK' 'sfx/dlc_demonv8'

client_script {
    'vehicle_names.lua'
}
