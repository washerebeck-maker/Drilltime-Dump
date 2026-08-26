shared_script "@ReaperV4/imports/bypass.lua"
shared_script "@ReaperV4/imports/bypass_s.lua"
shared_script "@ReaperV4/imports/bypass_c.lua"
lua54 "yes" -- needed for Reaper

resource_manifest_version "44febabe-d386-4d18-afbe-5e627f4af937"

files {
	'audioconfig/hellcatsound_game.dat151.rel',
	'audioconfig/hellcatsound_sounds.dat54.rel',
	'sfx/dlc_hellcatsound/hellcatsound.awc',
	'sfx/dlc_hellcatsound/hellcatsound_npc.awc'
}

data_file 'AUDIO_GAMEDATA' 'audioconfig/hellcatsound_game.dat'
data_file 'AUDIO_SOUNDDATA' 'audioconfig/hellcatsound_sounds.dat'
data_file 'AUDIO_WAVEPACK' 'sfx/dlc_hellcatsound'

client_script {
    'vehicle_names.lua'
}
