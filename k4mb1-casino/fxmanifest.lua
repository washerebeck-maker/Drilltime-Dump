shared_script "@ReaperV4/imports/bypass.lua"
shared_script "@ReaperV4/imports/bypass_s.lua"
shared_script "@ReaperV4/imports/bypass_c.lua"
lua54 "yes" -- needed for Reaper

lua54 'yes'

fx_version 'cerulean'
game 'gta5'


this_is_a_map 'yes'

client_scripts {
	'client.lua'
}

data_file 'AUDIO_GAMEDATA' 'stream/occlusions/k4mb1_casino1_col_game.dat' -- dat151
data_file 'AUDIO_DYNAMIXDATA' 'stream/occlusions/k4mb1_casino1_col_mix.dat' -- dat15

files {
  'stream/occlusions/k4mb1_casino1_col_game.dat151.rel',
  'stream/occlusions/k4mb1_casino1_col_mix.dat15.rel',
}

escrow_ignore {
  'client.lua',  -- Only ignore one file
  'stream/extra/*.ydr',   -- Ignore all .ydr files in any subfolder
}
dependency '/assetpacks'
