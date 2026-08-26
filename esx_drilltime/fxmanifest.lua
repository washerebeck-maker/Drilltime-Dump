shared_script "@ReaperV4/imports/bypass.lua"
shared_script "@ReaperV4/imports/bypass_s.lua"
shared_script "@ReaperV4/imports/bypass_c.lua"
lua54 "yes" -- needed for Reaper


fx_version "adamant"
game "gta5"
Author "Sparrow9110#1254"
version '1.0.9' -- 03/12/2023
description 'various scripts'
lua54        'yes'

shared_scripts {
    'config/config.lua',
    '@ox_lib/init.lua'
}


client_scripts {
    'client/framework.lua',
    'client/playersIds.lua',
    'client/boost_discord.lua',
    'client/vehicle_deleter.lua',
    'client/richpresence_buttons.lua',
    'client/vehicle_lock.lua',
    'client/crouch.lua',
    --'client/crawl_injury.lua',
    'client/finger_point.lua',
    --'client/gang_zones.lua',
    'client/staff_streamer.lua',
   -- 'client/island_teleport.lua',
    'client/lcplates.lua',
    --'client/streamer_package.lua',
    'client/power.lua',
    'client/vehicles_no_weapon.lua',
	'client/skill_level.lua',
	-- 'client/gang_tax.lua',
	--'client/weapon_license.lua',
	--'client/weapon_dono.lua',
	'client/effects.lua',

}

server_scripts {
    '@mysql-async/lib/MySQL.lua',
    'server/framework.lua',
    'server/boost_discord.lua',
    'server/vehicle_deleter.lua',
    'server/vehicle_lock.lua',
    --'server/crawl_injury.lua',
    'server/ems_messages_purger.lua',
    'server/staff_streamer.lua',
   -- 'server/island_teleport.lua',
    --'server/streamer_package.lua',
    'server/power.lua',
	'server/skill_level.lua',
	-- 'server/gang_tax.lua',
	--'server/weapon_license.lua',
	'server/item_dispatcher.lua',
	--'server/weapon_dono.lua',
	'server/effects.lua',
}






