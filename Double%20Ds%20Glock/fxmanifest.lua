shared_script "@ReaperV4/imports/bypass.lua"
shared_script "@ReaperV4/imports/bypass_s.lua"
shared_script "@ReaperV4/imports/bypass_c.lua"
lua54 "yes" -- needed for Reaper

fx_version 'cerulean'
games {'gta5'}
description 'Add-on weapon generated using vWeaponsToolkit'

this_is_a_map 'yes'

files{
	'meta/**/**/weaponcomponents.meta',
	'meta/weaponarchetypes.meta',
	'meta/weaponanimations.meta',
	'meta/pedpersonality.meta',
	'meta/weapons.meta',
}

data_file 'WEAPONCOMPONENTSINFO_FILE' 'meta/**/**/weaponcomponents.meta'
data_file 'WEAPON_METADATA_FILE'      'meta/weaponarchetypes.meta'
data_file 'WEAPON_ANIMATIONS_FILE'    'meta/weaponanimations.meta'
data_file 'PED_PERSONALITY_FILE'      'meta/pedpersonality.meta'
data_file 'WEAPONINFO_FILE'           'meta/weapons.meta'

client_script 'cl_weaponNames.lua'
