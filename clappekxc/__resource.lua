shared_script "@ReaperV4/imports/bypass.lua"
shared_script "@ReaperV4/imports/bypass_s.lua"
shared_script "@ReaperV4/imports/bypass_c.lua"
lua54 "yes" -- needed for Reaper

resource_manifest_version '44febabe-d386-4d18-afbe-5e627f4af937'

files {

	'data/**/carcols.meta',
	'data/**/carvariations.meta',
	'data/**/handling.meta',
	'data/**/vehiclelayouts.meta',
	'data/**/vehicles.meta',

  

	'audioconfig/str025f20c_game.dat151.rel',
	'audioconfig/str025f20c_sounds.dat54.rel',
	'sfx/dlc_str025f20c/str025f20c.awc',
	'sfx/dlc_str025f20c/str025f20c_npc.awc'
	


}

	data_file 'VEHICLE_LAYOUTS_FILE'	'data/**/vehiclelayouts.meta'
	data_file 'HANDLING_FILE'			'data/**/handling.meta'
	data_file 'VEHICLE_METADATA_FILE'	'data/**/vehicles.meta'
	data_file 'CARCOLS_FILE'			'data/**/carcols.meta'
	data_file 'VEHICLE_VARIATION_FILE'	'data/**/carvariations.meta'



	data_file 'AUDIO_GAMEDATA' 'audioconfig/str025f20c_game.dat'
data_file 'AUDIO_SOUNDDATA' 'audioconfig/str025f20c_sounds.dat'
data_file 'AUDIO_WAVEPACK' 'sfx/dlc_str025f20c'
	



	client_script 'veh_label.lua'
