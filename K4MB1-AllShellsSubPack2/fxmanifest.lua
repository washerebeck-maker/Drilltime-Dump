

shared_script "@ReaperV4/imports/bypass.lua"
shared_script "@ReaperV4/imports/bypass_s.lua"
shared_script "@ReaperV4/imports/bypass_c.lua"
lua54 "yes" -- needed for Reaper

lua54 'yes'

fx_version 'cerulean'
game 'gta5'

this_is_a_map 'yes'

files {
      'stream/allshellsbundle2_k4mb1.ytyp'
}

client_scripts {
      'AllShellsSubPack.lua'
}

escrow_ignore {
  'AllShellsSubPack.lua'
}

data_file 'DLC_ITYP_REQUEST' 'stream/allshellsbundle2_k4mb1.ityp'

dependency '/assetpacks'
