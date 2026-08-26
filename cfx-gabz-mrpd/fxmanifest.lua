shared_script "@ReaperV4/imports/bypass.lua"
shared_script "@ReaperV4/imports/bypass_s.lua"
shared_script "@ReaperV4/imports/bypass_c.lua"
lua54 "yes" -- needed for Reaper

fx_version 'cerulean'
game 'gta5'
author 'Gabz'
description 'MRPD'
version '1.0.0'
lua54 'yes'
this_is_a_map 'yes'

dependencies {
    '/server:4960',     -- ⚠️PLEASE READ⚠️; Requires at least SERVER build 4960.
    '/gameBuild:2545',  -- ⚠️PLEASE READ⚠️; Requires at least GAME build 2545.
}

escrow_ignore {
    'stream/**/*.ytd',
    'mrpd.lua',
}

data_file 'TIMECYCLEMOD_FILE' 'gabz_mrpd_timecycle.xml'

files {
	'gabz_mrpd_timecycle.xml',
}

client_script {
    "gabz_mrpd_entitysets.lua"
}
dependency '/assetpacks'
